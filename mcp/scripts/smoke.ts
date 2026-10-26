// Raw JSON-RPC smoke test against a running endpoint (local or deployed):
//   npm run smoke                                  http://localhost:3333/mcp
//   npm run smoke -- https://mcp.example.com/mcp
// Exits 1 if initialize, tools/list, or a tools/call fails.
const endpoint = process.argv[2] ?? "http://localhost:3333/mcp";

async function rpc(id: number, method: string, params: unknown): Promise<any> {
  const res = await fetch(endpoint, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json, text/event-stream",
      "MCP-Protocol-Version": "2025-06-18",
    },
    body: JSON.stringify({ jsonrpc: "2.0", id, method, params }),
  });
  const text = await res.text();
  if (!res.ok) throw new Error(`${method}: HTTP ${res.status} ${text.slice(0, 300)}`);
  // A JSON body, or an SSE stream whose data lines carry the JSON-RPC message.
  const json = res.headers.get("content-type")?.includes("text/event-stream")
    ? JSON.parse(
        text
          .split("\n")
          .filter((l) => l.startsWith("data:"))
          .map((l) => l.slice(5).trim())
          .filter(Boolean)
          .pop() ?? "{}",
      )
    : JSON.parse(text);
  if (json.error) throw new Error(`${method}: ${JSON.stringify(json.error)}`);
  return json.result;
}

const init = await rpc(1, "initialize", {
  protocolVersion: "2025-06-18",
  capabilities: {},
  clientInfo: { name: "sfh-smoke", version: "1.0.0" },
});
console.log(`initialize: ${init.serverInfo.name} ${init.serverInfo.version}, protocol ${init.protocolVersion}`);

const list = await rpc(2, "tools/list", {});
console.log(`tools/list: ${list.tools.map((t: any) => `${t.name} (readOnly ${t.annotations?.readOnlyHint})`).join(", ")}`);

const search = await rpc(3, "tools/call", { name: "sfh_search", arguments: { query: "dropdown", limit: 3 } });
console.log(`tools/call sfh_search "dropdown":\n${search.content[0].text}`);

const topic = await rpc(4, "tools/call", { name: "sfh_get_topic", arguments: { id: "button", platform: "macos" } });
const text: string = topic.content[0].text;
console.log(`tools/call sfh_get_topic button (macos, concise): ${text.length} chars, ~${Math.ceil(text.length / 4)} tokens`);
console.log(text.split("\n").slice(0, 4).join("\n"));

const missing = await rpc(5, "tools/call", { name: "sfh_get_topic", arguments: { id: "buton" } });
console.log(`tools/call sfh_get_topic "buton": isError ${missing.isError}: ${missing.content[0].text}`);

const checklist = await rpc(6, "tools/call", { name: "sfh_review_checklist", arguments: { platform: "ios" } });
console.log(`tools/call sfh_review_checklist (ios): ${checklist.content[0].text.length} chars`);
console.log("smoke test passed");
