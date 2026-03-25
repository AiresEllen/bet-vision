create table if not exists favorites (
  id bigint generated always as identity primary key,
  user_id uuid not null,
  fixture_id text not null,
  league text,
  home_team text,
  away_team text,
  created_at timestamp with time zone default now()
);

alter table favorites enable row level security;

create policy "Usuarios veem os proprios favoritos"
on favorites
for select
using (auth.uid() = user_id);

create policy "Usuarios inserem os proprios favoritos"
on favorites
for insert
with check (auth.uid() = user_id);

create policy "Usuarios removem os proprios favoritos"
on favorites
for delete
using (auth.uid() = user_id);
