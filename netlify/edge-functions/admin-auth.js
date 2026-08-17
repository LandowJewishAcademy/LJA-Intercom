// Password-protects /admin/* only — /room/* is completely untouched,
// so classroom tablets never see a prompt.
//
// Set ADMIN_USER and ADMIN_PASSWORD as environment variables in
// Netlify (same place as the LIVEKIT_* ones). ADMIN_USER defaults to
// "admin" if you don't set it.

export default async (request, context) => {
  const expectedUser = Netlify.env.get("ADMIN_USER") || "admin";
  const expectedPass = Netlify.env.get("ADMIN_PASSWORD");

  if (!expectedPass) {
    return new Response(
      "ADMIN_PASSWORD is not set in Netlify environment variables — admin console is locked until it is.",
      { status: 500 }
    );
  }

  const auth = request.headers.get("authorization");

  if (auth && auth.startsWith("Basic ")) {
    const decoded = atob(auth.slice(6));
    const sep = decoded.indexOf(":");
    const user = decoded.slice(0, sep);
    const pass = decoded.slice(sep + 1);
    if (user === expectedUser && pass === expectedPass) {
      return context.next();
    }
  }

  return new Response("Authentication required", {
    status: 401,
    headers: { "WWW-Authenticate": 'Basic realm="Landow Intercom Admin"' },
  });
};

export const config = { path: "/admin/*" };
