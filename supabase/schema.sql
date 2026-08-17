-- LJA Intercom — Supabase schema
-- Run this once in the Supabase SQL editor (or via `supabase db push`).

create table if not exists rooms (
  id            uuid primary key default gen_random_uuid(),
  room_number   text unique not null,
  floor         int not null,
  grade_band    text not null,
  display_name  text not null,
  created_at    timestamptz not null default now()
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
insert into rooms (room_number, floor, grade_band, display_name) values
  ('104', 1, 'K-1st',        'Room 104'),
  ('105', 1, 'K-1st',        'Room 105'),
  ('106', 1, 'K-1st',        'Room 106'),
  ('107', 1, 'K-1st',        'Room 107'),
  ('201', 2, '2nd-5th',      'Room 201'),
  ('202', 2, '2nd-5th',      'Room 202'),
  ('203', 2, '2nd-5th',      'Room 203'),
  ('204', 2, '2nd-5th',      'Room 204'),
  ('205', 2, '2nd-5th',      'Room 205'),
  ('206', 2, '2nd-5th',      'Room 206'),
  ('207', 2, '2nd-5th',      'Room 207'),
  ('208', 2, '2nd-5th',      'Room 208'),
  ('209', 2, '2nd-5th',      'Room 209'),
  ('210', 2, '2nd-5th',      'Room 210'),
  ('301', 3, 'Middle School', 'Room 301'),
  ('303', 3, 'Middle School', 'Room 303'),
  ('304', 3, 'Middle School', 'Room 304'),
  ('305', 3, 'Middle School', 'Room 305'),
  ('306', 3, 'Middle School', 'Room 306'),
  ('307', 3, 'Middle School', 'Room 307'),
  ('308', 3, 'Middle School', 'Room 308'),
  ('309', 3, 'Middle School', 'Room 309'),
  ('310', 3, 'Middle School', 'Room 310'),
  ('401', 4, 'High School',  'Room 401'),
  ('402', 4, 'High School',  'Room 402'),
  ('403', 4, 'High School',  'Room 403'),
  ('404', 4, 'High School',  'Room 404'),
  ('405', 4, 'High School',  'Room 405'),
  ('406', 4, 'High School',  'Room 406'),
  ('407', 4, 'High School',  'Room 407 — Science Lab'),
  ('408', 4, 'High School',  'Room 408'),
  ('409', 4, 'High School',  'Room 409'),
  ('410', 4, 'High School',  'Room 410')
on conflict (room_number) do nothing;
