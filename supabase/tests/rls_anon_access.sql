-- RLS verification script (manual/CI-friendly checks)
-- Run against a SQL session that enforces RLS (non-bypass role).
-- Example: psql ... -v ON_ERROR_STOP=1 -f supabase/tests/rls_anon_access.sql
-- Or via Supabase SQL editor as a role without bypass privileges.

begin;

-- Anonymous role must not be able to read orders or related sensitive tables.
do $$
begin
  perform set_config('role', 'anon', true);

  begin
    perform 1 from public.orders limit 1;
    raise exception 'RLS TEST FAILED: anon can read public.orders';
  exception
    when insufficient_privilege then
      null; -- expected
    when others then
      -- permission denied / RLS-related errors are acceptable
      if position('permission denied' in lower(sqlerrm)) = 0 then
        raise;
      end if;
  end;

  begin
    perform 1 from public.payments limit 1;
    raise exception 'RLS TEST FAILED: anon can read public.payments';
  exception
    when insufficient_privilege then null;
    when others then
      if position('permission denied' in lower(sqlerrm)) = 0 then raise; end if;
  end;

  begin
    perform 1 from public.admin_users limit 1;
    raise exception 'RLS TEST FAILED: anon can read public.admin_users';
  exception
    when insufficient_privilege then null;
    when others then
      if position('permission denied' in lower(sqlerrm)) = 0 then raise; end if;
  end;

  raise notice 'RLS anon access checks passed (orders/payments/admin_users denied).';
end $$;

rollback;
