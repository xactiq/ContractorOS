-- Migration 001: Fix broken signup (Issue #11)
-- All new signups fail with HTTP 500 because SECURITY DEFINER functions
-- lack SET search_path, so unqualified table references fail during the
-- auth transaction.
--
-- Run this in Supabase SQL Editor: supabase.com → project → SQL Editor
-- Paste the entire contents and click "Run"

ALTER FUNCTION public.add_subscriber_to_owner_globe()  SET search_path = public, pg_temp;
ALTER FUNCTION public.sync_subscriber_to_owner_globe() SET search_path = public, pg_temp;
ALTER FUNCTION public.handle_new_user()                SET search_path = public, pg_temp;
ALTER FUNCTION public.is_org_member_of(uuid)           SET search_path = public, pg_temp;
ALTER FUNCTION public.update_tasks_updated_at()        SET search_path = public, pg_temp;
