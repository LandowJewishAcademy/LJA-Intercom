// Shared helpers used by both /admin and /room pages.
// Depends on: window.supabase (from the Supabase UMD script) and
// window.LivekitClient (from the LiveKit UMD script), loaded before this file.

const supabaseClient = window.supabase.createClient(
  window.LJA_CONFIG.SUPABASE_URL,
  window.LJA_CONFIG.SUPABASE_ANON_KEY
);

// Fetch a LiveKit token from our Netlify function. Never mint tokens client-side.
async function fetchLiveKitToken(identity, room, canPublish, canSubscribe) {
  const res = await fetch("/.netlify/functions/livekit-token", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ identity, room, canPublish, canSubscribe }),
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.error || "Failed to fetch LiveKit token");
  }
  return res.json(); // { token, url }
}

// Connect to a LiveKit room. If canPublish, turns the mic on immediately.
// Remote audio tracks are auto-attached to a hidden <audio> element and played.
async function connectToLiveKitRoom(identity, livekitRoomName, { canPublish, canSubscribe }) {
  const { token, url } = await fetchLiveKitToken(identity, livekitRoomName, canPublish, canSubscribe);

  const room = new window.LivekitClient.Room();

  room.on(window.LivekitClient.RoomEvent.TrackSubscribed, (track) => {
    if (track.kind === "audio") {
      const el = track.attach();
      el.style.display = "none";
      document.body.appendChild(el);
    }
  });

  await room.connect(url, token);

  if (canPublish) {
    await room.localParticipant.setMicrophoneEnabled(true);
  }

  return room;
}

async function disconnectLiveKitRoom(room) {
  if (room) {
    await room.disconnect();
  }
}

// --- Call log (Postgres table, gives the admin a history of pages sent) ---

async function logCallStart(callType, target, initiatedBy, livekitRoomName) {
  const { data, error } = await supabaseClient
    .from("call_log")
    .insert({ call_type: callType, target: String(target), initiated_by: initiatedBy, livekit_room: livekitRoomName })
    .select()
    .single();
  if (error) {
    console.error("logCallStart failed", error);
    return null;
  }
  return data.id;
}

async function logCallEnd(callLogId) {
  if (!callLogId) return;
  await supabaseClient.from("call_log").update({ ended_at: new Date().toISOString() }).eq("id", callLogId);
}
