-- LJA Intercom — Supabase schema
-- Run this once in the Supabase SQL editor (or via `supabase db push`).

create table if not exists rooms (
  id              uuid primary key default gen_random_uuid(),
  room_number     text unique not null,
  floor           int not null,
  grade_band      text not null,
  display_name    text not null,
  teachers        text[] not null default '{}',
  teachers_shared boolean not null default false,  -- true if the room rotates between multiple teachers by period
  created_at      timestamptz not null default now()
);

create table if not exists call_log (
  id             uuid primary key default gen_random_uuid(),
  call_type      text not null check (call_type in ('individual', 'floor', 'all_school')),
  target         text not null,           -- room_number, floor number as text, or 'all'
  initiated_by   text not null,           -- 'admin' or a room_number (for reply calls)
  livekit_room   text not null,
  started_at     timestamptz not null default now(),
  ended_at       timestamptz
);

alter table rooms enable row level security;
alter table call_log enable row level security;

-- Room directory is not sensitive — every tablet needs to read it on load.
create policy "rooms are readable by anyone" on rooms
  for select using (true);

-- Call log: anyone on the school network can write/read for now (v1, no per-user auth yet).
-- Tighten this later with Supabase Auth if you want to restrict who can start calls.
create policy "call log readable by anyone" on call_log
  for select using (true);
create policy "call log writable by anyone" on call_log
  for insert with check (true);
create policy "call log updatable by anyone" on call_log
  for update using (true);

-- Seed data, extracted from the 2026-2027 ParentLocker schedule export.
-- 33 rooms found in active use across 4 floors. See README for the gaps
-- (100–103 and 302 don't appear anywhere in the schedule).
-- teachers_shared = true means multiple teachers rotate through that room
-- by period (mostly Middle School) — teachers[] lists them in that case.
insert into rooms (room_number, floor, grade_band, display_name, teachers, teachers_shared) values
  ('104', 1, 'K-1st',        'Room 104', '{"Taly Liberman"}', false),
  ('105', 1, 'K-1st',        'Room 105', '{"Judy Weinberg"}', false),
  ('106', 1, 'K-1st',        'Room 106', '{"Danielle Green"}', false),
  ('107', 1, 'K-1st',        'Room 107', '{"Orrel Biton"}', false),
  ('201', 2, '2nd-5th',      'Room 201', '{"Ella Smith"}', false),
  ('202', 2, '2nd-5th',      'Room 202', '{"Yisroel Lavrinoff"}', false),
  ('203', 2, '2nd-5th',      'Room 203', '{"Shameka Lewis"}', false),
  ('204', 2, '2nd-5th',      'Room 204', '{"Shameka Lewis"}', false),
  ('205', 2, '2nd-5th',      'Room 205', '{"Jacob Albert"}', false),
  ('206', 2, '2nd-5th',      'Room 206', '{"Abigail Treasure"}', false),
  ('207', 2, '2nd-5th',      'Room 207', '{"Yaakov Krasny","Jacob Albert"}', true),
  ('208', 2, '2nd-5th',      'Room 208', '{"Lissette Torres"}', false),
  ('209', 2, '2nd-5th',      'Room 209', '{"Solomon Dahari"}', false),
  ('210', 2, '2nd-5th',      'Room 210', '{"Elisa Valentin"}', false),
  ('301', 3, 'Middle School', 'Room 301', '{"Ester Halpert","Javelle Campbell","Omar Vasile"}', true),
  ('303', 3, 'Middle School', 'Room 303', '{"Chad Simpson"}', false),
  ('304', 3, 'Middle School', 'Room 304', '{"Rebecka Plummer"}', false),
  ('305', 3, 'Middle School', 'Room 305', '{"Javelle Campbell","Ester Halpert","Omar Vasile"}', true),
  ('306', 3, 'Middle School', 'Room 306', '{"Kristian Gellibert"}', false),
  ('307', 3, 'Middle School', 'Room 307', '{"Adam Kadosh","Ami Uzan","Rabbi Aviel Avidan"}', true),
  ('308', 3, 'Middle School', 'Room 308', '{"Adam Kadosh","Ami Uzan","Rabbi Aviel Avidan"}', true),
  ('309', 3, 'Middle School', 'Room 309', '{"Monica Martinez"}', false),
  ('310', 3, 'Middle School', 'Room 310', '{"Daniela Herrera"}', false),
  ('401', 4, 'High School',  'Room 401', '{"Oland Lafleur"}', false),
  ('402', 4, 'High School',  'Room 402', '{"Kobe Stallings"}', false),
  ('403', 4, 'High School',  'Room 403', '{"Julia Wainwright"}', false),
  ('404', 4, 'High School',  'Room 404', '{"Hila Levinson"}', false),
  ('405', 4, 'High School',  'Room 405', '{"Christopher Schulz"}', false),
  ('406', 4, 'High School',  'Room 406', '{"Michael Duque"}', false),
  ('407', 4, 'High School',  'Room 407 — Science Lab', '{"Francesa Konwufine"}', false),
  ('408', 4, 'High School',  'Room 408', '{"Aleksandar Chonevski"}', false),
  ('409', 4, 'High School',  'Room 409', '{"Alexis Langberg"}', false),
  ('410', 4, 'High School',  'Room 410', '{"James Jenkins"}', false)
on conflict (room_number) do nothing;
