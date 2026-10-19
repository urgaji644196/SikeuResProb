create table if not exists public.rekap (
  id text primary key,
  data jsonb not null check (jsonb_typeof(data) = 'object'),
  created_at timestamptz not null default now()
);

create table if not exists public.detail (
  id text primary key,
  data jsonb not null check (jsonb_typeof(data) = 'object'),
  created_at timestamptz not null default now()
);

create table if not exists public.kas (
  id text primary key,
  data jsonb not null check (jsonb_typeof(data) = 'object'),
  created_at timestamptz not null default now()
);

create table if not exists public.talangan (
  id text primary key,
  data jsonb not null check (jsonb_typeof(data) = 'object'),
  created_at timestamptz not null default now()
);

create table if not exists public.dashboard_summary (
  id text primary key check (id = 'public'),
  data jsonb not null check (jsonb_typeof(data) = 'object'),
  updated_at timestamptz not null default now()
);

create table if not exists public.app_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.rekap enable row level security;
alter table public.detail enable row level security;
alter table public.kas enable row level security;
alter table public.talangan enable row level security;
alter table public.dashboard_summary enable row level security;
alter table public.app_admins enable row level security;

create or replace function public.is_sikeu_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.app_admins
    where user_id = (select auth.uid())
  );
$$;

revoke all on function public.is_sikeu_admin() from public;
grant execute on function public.is_sikeu_admin() to authenticated;

revoke all on public.rekap, public.detail, public.kas, public.talangan,
  public.dashboard_summary, public.app_admins from anon, authenticated;
grant select on public.rekap, public.dashboard_summary to anon, authenticated;
grant select, insert, update, delete on public.rekap, public.detail, public.kas,
  public.talangan, public.dashboard_summary to authenticated;

drop policy if exists "Public can read GUP recap" on public.rekap;
create policy "Public can read GUP recap"
  on public.rekap for select to anon, authenticated
  using (true);

drop policy if exists "Admins can insert GUP recap" on public.rekap;
create policy "Admins can insert GUP recap"
  on public.rekap for insert to authenticated
  with check ((select public.is_sikeu_admin()));

drop policy if exists "Admins can update GUP recap" on public.rekap;
create policy "Admins can update GUP recap"
  on public.rekap for update to authenticated
  using ((select public.is_sikeu_admin()))
  with check ((select public.is_sikeu_admin()));

drop policy if exists "Admins can delete GUP recap" on public.rekap;
create policy "Admins can delete GUP recap"
  on public.rekap for delete to authenticated
  using ((select public.is_sikeu_admin()));

drop policy if exists "Public can read dashboard summary" on public.dashboard_summary;
create policy "Public can read dashboard summary"
  on public.dashboard_summary for select to anon, authenticated
  using (id = 'public');

drop policy if exists "Admins can insert dashboard summary" on public.dashboard_summary;
create policy "Admins can insert dashboard summary"
  on public.dashboard_summary for insert to authenticated
  with check ((select public.is_sikeu_admin()) and id = 'public');

drop policy if exists "Admins can update dashboard summary" on public.dashboard_summary;
create policy "Admins can update dashboard summary"
  on public.dashboard_summary for update to authenticated
  using ((select public.is_sikeu_admin()))
  with check ((select public.is_sikeu_admin()) and id = 'public');

drop policy if exists "Admins can read GUP detail" on public.detail;
create policy "Admins can read GUP detail"
  on public.detail for select to authenticated
  using ((select public.is_sikeu_admin()));

drop policy if exists "Admins can write GUP detail" on public.detail;
create policy "Admins can write GUP detail"
  on public.detail for all to authenticated
  using ((select public.is_sikeu_admin()))
  with check ((select public.is_sikeu_admin()));

drop policy if exists "Admins can read cash ledger" on public.kas;
create policy "Admins can read cash ledger"
  on public.kas for select to authenticated
  using ((select public.is_sikeu_admin()));

drop policy if exists "Admins can write cash ledger" on public.kas;
create policy "Admins can write cash ledger"
  on public.kas for all to authenticated
  using ((select public.is_sikeu_admin()))
  with check ((select public.is_sikeu_admin()));

drop policy if exists "Admins can read advance ledger" on public.talangan;
create policy "Admins can read advance ledger"
  on public.talangan for select to authenticated
  using ((select public.is_sikeu_admin()));

drop policy if exists "Admins can write advance ledger" on public.talangan;
create policy "Admins can write advance ledger"
  on public.talangan for all to authenticated
  using ((select public.is_sikeu_admin()))
  with check ((select public.is_sikeu_admin()));

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'rekap', 'detail', 'kas', 'talangan', 'dashboard_summary'
  ] loop
    if not exists (
      select 1
      from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = table_name
    ) then
      execute format(
        'alter publication supabase_realtime add table public.%I',
        table_name
      );
    end if;
  end loop;
end;
$$;
