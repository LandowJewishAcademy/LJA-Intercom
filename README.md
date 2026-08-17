# LJA Intercom

Classroom paging system: call one room (two-way), page a whole floor, or
page the whole school (one-way, with a private-reply option).

## What's in here

```
supabase/schema.sql          rooms + call_log tables, seeded with real room numbers
netlify/functions/           serverless function that mints LiveKit tokens
public/admin/                admin console (used from the office)
public/room/                 the receiver page each classroom tablet loads
public/shared/               config, styling, and the call-routing logic
```

## About the room list

I pulled every room number that actually shows up in the 2026-2027
ParentLocker schedule export. That gave **33 rooms**, not 40:

- Floor 1 (K-1st): 104, 105, 106, 107
- Floor 2 (2nd-5th): 201–210 (complete)
- Floor 3 (Middle school): 301, 303–310 — **302 never appears**
- Floor 4 (High school): 401–410 (complete)

Two gaps worth checking with you directly:
- **100–103** don't appear anywhere in the schedule — if those numbers exist
  physically (office, nurse, extended day, etc.) but aren't classrooms, that's
  probably fine to leave out. If they're real K-1 classrooms just not showing
  up because of how the schedule export works, let me know and I'll add them.
- **302** is the one gap in an otherwise-complete floor. Same question — real
  room that's just not scheduled this term, or a number that was skipped?

Also found in the schedule but **not added** as classrooms yet, since they
don't have room numbers: Gym, Weight Room, Learning Lab, PE Field, Soccer
Field, Front Carpool Loop. Say the word if any of these should get their own
receiver (e.g. a speaker in the gym) — I'd just add them to `schema.sql` with
a text ID instead of a number.

Edit `supabase/schema.sql` directly to add/remove rows, then re-run it.

## One-time setup

**1. Supabase**
- Create a project at supabase.com.
- Open the SQL editor, paste in `supabase/schema.sql`, run it.
- Settings → API → copy the Project URL and the `anon` public key.
- Paste both into `public/shared/config.js`.

**2. LiveKit Cloud**
- Create a project at cloud.livekit.io (free tier covers this easily — 40
  rooms is small for their limits).
- Settings → Keys → create an API key. Note the key, secret, and the
  WebSocket URL (`wss://your-project.livekit.cloud`).

**3. Netlify**
- Push this folder to a GitHub repo, then "Import from Git" in Netlify
  (or drag-and-drop deploy for a first test).
- Site settings → Environment variables → add `LIVEKIT_API_KEY`,
  `LIVEKIT_API_SECRET`, `LIVEKIT_URL` (see `.env.example`).
- Deploy.

**4. Test before buying tablets**
- Open `/admin/` in one browser tab, `/room/104` in another (or on your
  phone). Call room 104, answer it, confirm you can hear each other.
- Try a floor page and the whole-school page the same way.

## Hardware (once the software checks out)

- Android or Amazon Fire tablets, one per classroom — built-in mic, speaker,
  and screen means no extra wiring. Budget roughly $50–70 each.
- Install **Fully Kiosk Browser** (free/paid tiers) on each tablet, set it to
  auto-launch fullscreen at boot, pointed at `https://yoursite.netlify.app/room/104`
  (swap in the right room number per tablet), and lock down navigation so
  students/staff can't back out to the home screen.
- Keep each tablet plugged in permanently — this is meant to run 24/7.

## Known v1 limitations (worth knowing, easy to extend later)

- **One call at a time, system-wide.** The admin console doesn't support
  calling room 104 while also paging floor 2. For a single-operator office
  this mirrors how a real intercom handset works, but if two staff members
  need to page simultaneously from different devices, this needs a queueing
  layer.
- **No admin login yet** — `/admin/` is reachable by anyone with the URL.
  Fine on a private school network; if you want a real gate, easiest fix is
  Netlify's built-in password protection on the `/admin/*` path, or a proper
  Supabase Auth login screen later.
- **Reply routing is simplified** — if two rooms reply privately at the
  exact same moment, the second ring is dropped rather than queued. Unlikely
  in practice, but worth knowing.
- This is **not a life-safety fire/lockdown system**. Great for daily
  announcements, dismissal calls, and "can you send Sarah to the office" —
  but if local code requires a dedicated fire-alarm-integrated PA, this
  should sit alongside it, not replace it.
