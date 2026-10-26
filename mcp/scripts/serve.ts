// Local server for trying the MCP endpoint without Vercel: `npm run serve`, then
// point a client (or `npm run smoke`) at http://localhost:3333/mcp.
import { createServer } from "node:http";
import { createHandler } from "../src/server.js";

const port = Number(process.env.PORT ?? 3333);
const handler = createHandler();

createServer(async (req, res) => {
  const url = new URL(req.url ?? "/", `http://${req.headers.host ?? `localhost:${port}`}`);
  if (url.pathname !== "/mcp" && url.pathname !== "/api/mcp") {
    res.writeHead(404, { "Content-Type": "text/plain" }).end("The MCP endpoint is /mcp.\n");
    return;
  }
  const chunks: Buffer[] = [];
  for await (const chunk of req) chunks.push(chunk as Buffer);
  const headers = new Headers();
  for (const [k, v] of Object.entries(req.headers)) if (typeof v === "string") headers.set(k, v);
  const body = chunks.length && req.method !== "GET" && req.method !== "HEAD" ? Buffer.concat(chunks) : undefined;
  const response = await handler(new Request(url, { method: req.method, headers, body }));
  res.writeHead(response.status, Object.fromEntries(response.headers));
  if (response.body) {
    for await (const chunk of response.body) res.write(chunk);
  }
  res.end();
}).listen(port, () => {
  process.stdout.write(`SwiftUI for Humans MCP on http://localhost:${port}/mcp\n`);
});
