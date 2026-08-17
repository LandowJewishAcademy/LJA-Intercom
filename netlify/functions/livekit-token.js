const { AccessToken } = require("livekit-server-sdk");

exports.handler = async (event) => {
  if (event.httpMethod !== "POST") {
    return { statusCode: 405, body: "Method not allowed" };
  }

  let body;
  try {
    body = JSON.parse(event.body || "{}");
  } catch (e) {
    return { statusCode: 400, body: JSON.stringify({ error: "Invalid JSON body" }) };
  }

  const { identity, room, canPublish = true, canSubscribe = true } = body;

  if (!identity || !room) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "identity and room are required" }),
    };
  }

  const apiKey = process.env.LIVEKIT_API_KEY;
  const apiSecret = process.env.LIVEKIT_API_SECRET;
  const url = process.env.LIVEKIT_URL;

  if (!apiKey || !apiSecret || !url) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "LiveKit environment variables are not configured in Netlify" }),
    };
  }

  const at = new AccessToken(apiKey, apiSecret, { identity, ttl: "10m" });
  at.addGrant({
    room,
    roomJoin: true,
    canPublish,
    canSubscribe,
  });

  const token = await at.toJwt();

  return {
    statusCode: 200,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ token, url }),
  };
};
