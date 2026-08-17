-- Run this in the Supabase SQL editor on your EXISTING project.
-- Safe to run once — adds two new columns and fills them in, doesn't
-- touch your existing tables or policies.

alter table rooms add column if not exists teachers text[] not null default '{}';
alter table rooms add column if not exists teachers_shared boolean not null default false;

update rooms set teachers = '{"Taly Liberman"}', teachers_shared = false where room_number = '104';
update rooms set teachers = '{"Judy Weinberg"}', teachers_shared = false where room_number = '105';
update rooms set teachers = '{"Danielle Green"}', teachers_shared = false where room_number = '106';
update rooms set teachers = '{"Orrel Biton"}', teachers_shared = false where room_number = '107';
update rooms set teachers = '{"Ella Smith"}', teachers_shared = false where room_number = '201';
update rooms set teachers = '{"Yisroel Lavrinoff"}', teachers_shared = false where room_number = '202';
update rooms set teachers = '{"Shameka Lewis"}', teachers_shared = false where room_number = '203';
update rooms set teachers = '{"Shameka Lewis"}', teachers_shared = false where room_number = '204';
update rooms set teachers = '{"Jacob Albert"}', teachers_shared = false where room_number = '205';
update rooms set teachers = '{"Abigail Treasure"}', teachers_shared = false where room_number = '206';
update rooms set teachers = '{"Yaakov Krasny","Jacob Albert"}', teachers_shared = true where room_number = '207';
update rooms set teachers = '{"Lissette Torres"}', teachers_shared = false where room_number = '208';
update rooms set teachers = '{"Solomon Dahari"}', teachers_shared = false where room_number = '209';
update rooms set teachers = '{"Elisa Valentin"}', teachers_shared = false where room_number = '210';
update rooms set teachers = '{"Ester Halpert","Javelle Campbell","Omar Vasile"}', teachers_shared = true where room_number = '301';
update rooms set teachers = '{"Chad Simpson"}', teachers_shared = false where room_number = '303';
update rooms set teachers = '{"Rebecka Plummer"}', teachers_shared = false where room_number = '304';
update rooms set teachers = '{"Javelle Campbell","Ester Halpert","Omar Vasile"}', teachers_shared = true where room_number = '305';
update rooms set teachers = '{"Kristian Gellibert"}', teachers_shared = false where room_number = '306';
update rooms set teachers = '{"Adam Kadosh","Ami Uzan","Rabbi Aviel Avidan"}', teachers_shared = true where room_number = '307';
update rooms set teachers = '{"Adam Kadosh","Ami Uzan","Rabbi Aviel Avidan"}', teachers_shared = true where room_number = '308';
update rooms set teachers = '{"Monica Martinez"}', teachers_shared = false where room_number = '309';
update rooms set teachers = '{"Daniela Herrera"}', teachers_shared = false where room_number = '310';
update rooms set teachers = '{"Oland Lafleur"}', teachers_shared = false where room_number = '401';
update rooms set teachers = '{"Kobe Stallings"}', teachers_shared = false where room_number = '402';
update rooms set teachers = '{"Julia Wainwright"}', teachers_shared = false where room_number = '403';
update rooms set teachers = '{"Hila Levinson"}', teachers_shared = false where room_number = '404';
update rooms set teachers = '{"Christopher Schulz"}', teachers_shared = false where room_number = '405';
update rooms set teachers = '{"Michael Duque"}', teachers_shared = false where room_number = '406';
update rooms set teachers = '{"Francesa Konwufine"}', teachers_shared = false where room_number = '407';
update rooms set teachers = '{"Aleksandar Chonevski"}', teachers_shared = false where room_number = '408';
update rooms set teachers = '{"Alexis Langberg"}', teachers_shared = false where room_number = '409';
update rooms set teachers = '{"James Jenkins"}', teachers_shared = false where room_number = '410';
