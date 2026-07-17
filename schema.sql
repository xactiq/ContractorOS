-- ContractorOS — Supabase Schema
-- Run this in your Supabase SQL Editor (supabase.com → project → SQL Editor)

CREATE TABLE clients (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  phone       TEXT,
  email       TEXT,
  address     TEXT,
  type        TEXT DEFAULT 'Residential',
  stage       TEXT DEFAULT 'Lead',
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE jobs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id   UUID REFERENCES clients(id) ON DELETE SET NULL,
  title       TEXT NOT NULL,
  type        TEXT DEFAULT 'Roofing',
  status      TEXT DEFAULT 'Pending',
  value       NUMERIC,
  start_date  DATE,
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE estimates (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id   UUID REFERENCES clients(id) ON DELETE SET NULL,
  title       TEXT NOT NULL,
  value       NUMERIC,
  status      TEXT DEFAULT 'Draft',
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE supplements (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id    UUID REFERENCES clients(id) ON DELETE SET NULL,
  carrier      TEXT,
  claim_num    TEXT,
  xacti_amount NUMERIC,
  supp_amount  NUMERIC,
  status       TEXT DEFAULT 'Pending',
  notes        TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE docs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id   UUID REFERENCES clients(id) ON DELETE SET NULL,
  job_id      UUID REFERENCES jobs(id) ON DELETE SET NULL,
  title       TEXT NOT NULL,
  type        TEXT DEFAULT 'Contract',
  url         TEXT,
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Production has RLS enabled on all tables above (verified via Supabase advisors).
-- Do NOT disable it here — re-running this file against production would strip
-- row-level protection from live customer data. Define policies before granting
-- anon access to any table; the anon key currently returns 0 rows on all of them.
ALTER TABLE clients    ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs       ENABLE ROW LEVEL SECURITY;
ALTER TABLE estimates  ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplements ENABLE ROW LEVEL SECURITY;
ALTER TABLE docs       ENABLE ROW LEVEL SECURITY;
