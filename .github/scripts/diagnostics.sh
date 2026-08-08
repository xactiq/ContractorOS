#!/usr/bin/env bash
set -uo pipefail

SITE_URL="${SITE_URL:-https://app.xactiq.net}"
REPORT="diagnostic-report.md"
SUMMARY_JSON="diagnostic-summary.json"
SECTIONS_FILE=$(mktemp)
DATE=$(date '+%Y-%m-%d %H:%M UTC')
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

CRITICAL=0; WARNINGS=0; PASSED=0
RECOMMENDATIONS=""; MAJOR_CHANGES=""

pass()   { echo "  [PASS] $1"; PASSED=$((PASSED + 1)); }
warn()   { echo "  [WARN] $1"; WARNINGS=$((WARNINGS + 1)); }
fail()   { echo "  [FAIL] $1"; CRITICAL=$((CRITICAL + 1)); }
sec()    { echo ""; echo "=== $1 ==="; }
append() { printf '%s\n' "$1" >> "$SECTIONS_FILE"; }
nl()     { echo "" >> "$SECTIONS_FILE"; }

sec "1. Website Health"
append "## 1. Website Health — \`${SITE_URL}\`"; nl
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 20 "$SITE_URL" 2>/dev/null || echo "000")
RESP_TIME=$(curl -s -o /dev/null -w "%{time_total}" --max-time 20 "$SITE_URL" 2>/dev/null || echo "N/A")
if [ "$HTTP_CODE" = "200" ]; then
    pass "Site is UP — HTTP $HTTP_CODE (${RESP_TIME}s)"
    append "- **Status:** ✅ HTTP 200 OK"
    append "- **Response time:** ${RESP_TIME}s"
    if awk "BEGIN { exit !($RESP_TIME > 3.0) }" 2>/dev/null; then
        warn "Slow response: ${RESP_TIME}s"
        append "- **Performance:** ⚠️ Slow — ${RESP_TIME}s (threshold: 3s)"
        RECOMMENDATIONS="${RECOMMENDATIONS}\n- Slow response on app.xactiq.net (${RESP_TIME}s); investigate Vercel edge caching."
    else
        append "- **Performance:** ✅ Fast (${RESP_TIME}s)"
    fi
elif [ "$HTTP_CODE" = "000" ]; then
    warn "Site unreachable — not deployed yet"
    append "- **Status:** ⚠️ UNREACHABLE — not yet deployed"
    MAJOR_CHANGES="${MAJOR_CHANGES}\n- **Site Offline:** Push to GitHub → connect Vercel → add DNS CNAME."
else
    fail "Site returned HTTP $HTTP_CODE"
    append "- **Status:** ❌ HTTP $HTTP_CODE"
fi
SSL_EXPIRY=$(echo | timeout 10 openssl s_client -servername app.xactiq.net -connect app.xactiq.net:443 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | sed 's/notAfter=//' || echo "")
if [ -n "$SSL_EXPIRY" ]; then
    DAYS_LEFT=$(( ($(date -d "$SSL_EXPIRY" +%s 2>/dev/null || echo 0) - $(date +%s)) / 86400 ))
    if   [ "$DAYS_LEFT" -lt 14 ]; then fail "SSL expires in $DAYS_LEFT days!"; append "- **SSL:** ❌ Expires in $DAYS_LEFT days"; MAJOR_CHANGES="${MAJOR_CHANGES}\n- **SSL EXPIRY:** $DAYS_LEFT days left — renew now."
    elif [ "$DAYS_LEFT" -lt 30 ]; then warn "SSL expires in $DAYS_LEFT days";  append "- **SSL:** ⚠️ Expires in $DAYS_LEFT days"
    else pass "SSL valid $DAYS_LEFT days"; append "- **SSL:** ✅ Valid — $DAYS_LEFT days remaining"; fi
else append "- **SSL:** ⏭️ Not checked (site unreachable)"; fi
nl

sec "2. CDN Dependencies"
append "## 2. CDN Dependency Status"; nl
append "| Dependency | Status | Response Time |"
append "|---|---|---|"
check_cdn() {
    local name="$1" url="$2" code time
    code=$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 15 "$url" 2>/dev/null || echo "000")
    time=$(curl -s -o /dev/null -w "%{time_total}" -L --max-time 15 "$url" 2>/dev/null || echo "N/A")
    if [[ "$code" =~ ^[23] ]]; then pass "CDN: $name — $code"; append "| $name | ✅ HTTP $code | ${time}s |"
    else fail "CDN down: $name ($code)"; append "| $name | ❌ HTTP $code | — |"
        MAJOR_CHANGES="${MAJOR_CHANGES}\n- **CDN Failure:** $name unreachable (HTTP $code). App will fail to load."; fi
}
check_cdn "React 18"           "https://unpkg.com/react@18/umd/react.production.min.js"
check_cdn "ReactDOM 18"        "https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"
check_cdn "Supabase JS v2"     "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.js"
check_cdn "Tabler Icons (CSS)" "https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css"
nl

sec "3. Supabase API + Growth"
append "## 3. Supabase API Connectivity"; nl
SUPA_URL=$(grep -oP "(?<=const SUPABASE_URL = ')[^']+" index.html 2>/dev/null | head -1 || echo "")
SUPA_KEY=$(grep -oP "(?<=const SUPABASE_KEY = ')[^']+" index.html 2>/dev/null | head -1 || echo "")
if [ -z "$SUPA_URL" ]; then
    warn "Could not extract Supabase URL"; append "- **Config:** ⚠️ Supabase URL not found in index.html"
else
    append "- **Project URL:** \`$SUPA_URL\`"
    # Query a real table instead of the bare /rest/v1/ root — the root endpoint
    # legitimately 401s on some Supabase projects even when table access works fine,
    # which was producing a false "auth issue" warning on every run.
    SUPA_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "${SUPA_URL}/rest/v1/clients?select=id&limit=1" -H "apikey: $SUPA_KEY" -H "Authorization: Bearer $SUPA_KEY" 2>/dev/null || echo "000")
    if [[ "$SUPA_STATUS" =~ ^2 ]]; then
        pass "Supabase reachable (HTTP $SUPA_STATUS)"; append "- **REST API:** ✅ Reachable"
    elif [ "$SUPA_STATUS" = "401" ]; then
        fail "Supabase REST: HTTP 401 — anon key rejected; verify the API key is active in Supabase dashboard"; append "- **REST API:** ❌ HTTP 401 (anon key rejected)"
    else fail "Supabase HTTP $SUPA_STATUS"; append "- **REST API:** ❌ HTTP $SUPA_STATUS"; fi
    nl; append "### Database Growth Tracking"; nl
    append "| Table | Record Count |"; append "|---|---|"
    for TABLE in clients jobs estimates supplements docs; do
        # content-range is "start-end/total" OR "*/total" when count-only; total is
        # always the digits after the slash, so anchor on that instead of requiring
        # digits on both sides (which never matched "*/N" and always printed N/A).
        COUNT=$(curl -s --max-time 15 "${SUPA_URL}/rest/v1/${TABLE}?select=count" \
            -H "apikey: $SUPA_KEY" -H "Authorization: Bearer $SUPA_KEY" -H "Prefer: count=exact" \
            -I 2>/dev/null | grep -i "content-range" | grep -oP '(?<=/)\d+' || echo "N/A")
        pass "Table $TABLE: $COUNT records"; append "| \`$TABLE\` | $COUNT |"
    done
fi
nl

sec "4. Codebase Health"
append "## 4. Codebase Health Analysis"; nl
INDEX_BYTES=$(wc -c < index.html 2>/dev/null || echo 0)
INDEX_LINES=$(wc -l < index.html 2>/dev/null || echo 0)
INDEX_KB=$(awk "BEGIN { printf \"%.1f\", $INDEX_BYTES/1024 }")
append "- **index.html:** ${INDEX_LINES} lines, ${INDEX_KB} KB"
MISSING_TABS=""
for TAB in Dashboard Pipeline Clients Jobs Estimates Supplements Docs; do
    grep -q "$TAB" index.html 2>/dev/null || MISSING_TABS="${MISSING_TABS} $TAB"
done
if [ -z "$MISSING_TABS" ]; then pass "All 7 tabs present"; append "- **Navigation tabs:** ✅ All 7 present"
else fail "Missing:${MISSING_TABS}"; append "- **Navigation tabs:** ❌ Missing:${MISSING_TABS}"; fi
JS_BLOCK=$(sed -n '/<script>/,/<\/script>/p' index.html | grep -v '<script>' | grep -v '</script>' || echo "")
if [ -n "$JS_BLOCK" ]; then
    echo "$JS_BLOCK" > /tmp/app-extract.js
    { echo "(function(){"; cat /tmp/app-extract.js; echo "})();"; } > /tmp/app-check.js
    if node --check /tmp/app-check.js 2>/dev/null; then pass "JS syntax valid"; append "- **JS Syntax:** ✅ No errors"
    else warn "JS syntax issue"; append "- **JS Syntax:** ⚠️ Possible issue — review manually"; fi
fi
CRUD_OPS=()
grep -q '\.insert(' index.html 2>/dev/null && CRUD_OPS+=("INSERT")
grep -q '\.select(' index.html 2>/dev/null && CRUD_OPS+=("SELECT")
grep -q '\.update(' index.html 2>/dev/null && CRUD_OPS+=("UPDATE")
grep -q '\.delete(' index.html 2>/dev/null && CRUD_OPS+=("DELETE")
if   [ "${#CRUD_OPS[@]}" -ge 4 ]; then pass "Full CRUD: ${CRUD_OPS[*]}"; append "- **CRUD:** ✅ All 4 present"
elif [ "${#CRUD_OPS[@]}" -ge 2 ]; then warn "Partial CRUD: ${CRUD_OPS[*]}"; append "- **CRUD:** ⚠️ ${#CRUD_OPS[@]}/4"
else fail "No CRUD ops found"; append "- **CRUD:** ❌ Not detected"; fi
grep -q "catch\b" index.html 2>/dev/null \
    && { pass "Error handling present"; append "- **Error Handling:** ✅ try/catch present"; } \
    || { warn "No catch blocks"; append "- **Error Handling:** ⚠️ No catch blocks"; RECOMMENDATIONS="${RECOMMENDATIONS}\n- Add try/catch around Supabase calls."; }
grep -q -i "csv" index.html 2>/dev/null \
    && { pass "CSV export present"; append "- **CSV Export:** ✅ Detected"; } \
    || { warn "No CSV export"; append "- **CSV Export:** ⚠️ Not found"; }
if awk "BEGIN { exit !($INDEX_BYTES > 102400) }" 2>/dev/null; then
    warn "index.html ${INDEX_KB}KB — large"; append "- **File Size:** ⚠️ ${INDEX_KB}KB"
    RECOMMENDATIONS="${RECOMMENDATIONS}\n- index.html is ${INDEX_KB}KB; split before adding more features."
else pass "File size OK: ${INDEX_KB}KB"; append "- **File Size:** ✅ ${INDEX_KB}KB"; fi
nl

sec "5. Security Scan"
append "## 5. Security Scan"; nl
grep -qi "service_role" index.html 2>/dev/null \
    && { fail "service_role key in HTML!"; append "- **Service Role Key:** ❌ CRITICAL — exposed in client HTML"
         MAJOR_CHANGES="${MAJOR_CHANGES}\n- **🚨 SECURITY:** service_role key in index.html — remove immediately."; } \
    || { pass "No service_role in HTML"; append "- **Service Role Key:** ✅ Not exposed"; }
if [ -f schema.sql ]; then
    if   grep -qi "DISABLE ROW LEVEL SECURITY" schema.sql 2>/dev/null; then
        warn "RLS disabled"; append "- **RLS:** ⚠️ Explicitly DISABLED — all data open to anon key"
        RECOMMENDATIONS="${RECOMMENDATIONS}\n- Enable RLS before multi-tenant launch."
    elif grep -qi "ENABLE ROW LEVEL SECURITY"  schema.sql 2>/dev/null; then
        pass "RLS enabled"; append "- **RLS:** ✅ Enabled"
    else warn "No RLS config"; append "- **RLS:** ⚠️ Not configured"; fi
fi
grep -qP "dangerouslySetInnerHTML|\.innerHTML\s*=" index.html 2>/dev/null \
    && { warn "innerHTML usage found"; append "- **XSS Risk:** ⚠️ innerHTML/dangerouslySetInnerHTML detected"; } \
    || { pass "No innerHTML patterns"; append "- **XSS Risk:** ✅ Clean"; }
grep -qP "\beval\s*\(" index.html 2>/dev/null \
    && { warn "eval() used"; append "- **eval():** ⚠️ Found — review"; } \
    || { pass "No eval()"; append "- **eval():** ✅ Not used"; }
nl

sec "6. UI Integrity"
append "## 6. UI Component Integrity"; nl
# Matches both JSX ("onClick=") and hyperscript/h() object-property style
# ("onClick:") — this app uses the latter, which the old JSX-only pattern
# never matched, always reporting 0 handlers.
ONCLICK_COUNT=$(grep -cP "onClick[:=]" index.html 2>/dev/null) || ONCLICK_COUNT=0
append "- **onClick handlers:** $ONCLICK_COUNT"
FORM_COUNT=$(grep -cE "const save\s*=|onSubmit|handleSubmit|saveLead|addRecord" index.html 2>/dev/null) || FORM_COUNT=0
[ "$FORM_COUNT" -gt 0 ] \
    && { pass "$FORM_COUNT form patterns"; append "- **Forms:** ✅ $FORM_COUNT patterns"; } \
    || { warn "No form patterns"; append "- **Forms:** ⚠️ None detected"; }
STATE_COUNT=$(grep -c "useState\b" index.html 2>/dev/null) || STATE_COUNT=0
append "- **useState hooks:** $STATE_COUNT"
[ "$STATE_COUNT" -gt 0 ] && pass "State management: $STATE_COUNT hooks" || warn "No useState hooks"
EFFECT_COUNT=$(grep -c "useEffect\b" index.html 2>/dev/null) || EFFECT_COUNT=0
append "- **useEffect hooks:** $EFFECT_COUNT (data loaders)"
[ "$EFFECT_COUNT" -gt 0 ] && pass "Data loaders: $EFFECT_COUNT hooks" || warn "No useEffect hooks"
nl

sec "7. Recent Activity"
append "## 7. Recent Git Activity"; nl
RECENT=$(git log --oneline -10 2>/dev/null || echo "No git history")
append '```'; append "$RECENT"; append '```'; nl
append "- **Last commit:** $(git log -1 --format='%ar' 2>/dev/null || echo 'unknown')"; nl

[ -n "$RECOMMENDATIONS" ] && { append "## 8. Recommendations"; nl; echo -e "$RECOMMENDATIONS" >> "$SECTIONS_FILE"; nl; }
[ -n "$MAJOR_CHANGES" ]   && { append "## ⚠️ 9. Major Changes — Owner Approval Required"; nl
    append "> The following need your review before any automated action."; nl
    echo -e "$MAJOR_CHANGES" >> "$SECTIONS_FILE"; nl; }

TOTAL=$((CRITICAL + WARNINGS + PASSED))
[ "$CRITICAL" -gt 0 ] && OVERALL="🔴 Critical Issues Found" \
    || { [ "$WARNINGS" -gt 0 ] && OVERALL="🟡 Warnings — Review Needed" || OVERALL="🟢 All Systems Healthy"; }
APPROVAL_NOTE=""
[ -n "$MAJOR_CHANGES" ] && APPROVAL_NOTE="> ⚠️ **OWNER ACTION REQUIRED** — Section 9 needs your approval."

cat > "$REPORT" << REPORT_EOF
# ContractorOS — Daily Diagnostic Report
**Date:** ${DATE}
**Overall Status:** ${OVERALL}
**Branch:** \`${GIT_BRANCH}\` @ \`${GIT_SHA}\`

## Summary
| | Count |
|---|---|
| ✅ Passed | ${PASSED} |
| ⚠️ Warnings | ${WARNINGS} |
| ❌ Critical | ${CRITICAL} |
| **Total** | **${TOTAL}** |

${APPROVAL_NOTE}

---

$(cat "$SECTIONS_FILE")

---
*Report generated by GitHub Actions — ContractorOS Daily Diagnostics*
REPORT_EOF

cat > "$SUMMARY_JSON" << JSON_EOF
{
  "date": "$(date '+%Y-%m-%d')",
  "timestamp": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "status": "$OVERALL",
  "passed": $PASSED,
  "warnings": $WARNINGS,
  "critical": $CRITICAL,
  "total": $TOTAL,
  "major_changes_required": $([ -n "$MAJOR_CHANGES" ] && echo "true" || echo "false")
}
JSON_EOF

rm -f "$SECTIONS_FILE" /tmp/app-extract.js /tmp/app-check.js
echo ""
echo "══════════════════════════════════════════════════"
echo "  DIAGNOSTIC COMPLETE — ContractorOS"
echo "  Status  : $OVERALL"
echo "  Passed  : $PASSED  |  Warnings: $WARNINGS  |  Critical: $CRITICAL"
echo "══════════════════════════════════════════════════"
[ "$CRITICAL" -eq 0 ]
