// End to end over HTTP: JSON-RPC requests through the same handler Vercel runs.
import { describe, expect, it } from "vitest";
import { createHandler } from "../src/server.js";

const handler = createHandler();

async function rpc(method: string, params: unknown = {}, id = 1): Promise<any> {
  const response = await handler(
    new Request("http://localhost/mcp", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json, text/event-stream",
        "MCP-Protocol-Version": "2025-06-18",
      },
      body: JSON.stringify({ jsonrpc: "2.0", id, method, params }),
    }),
  );
  expect(response.headers.get("access-control-allow-origin")).toBe("*");
  const text = await response.text();
  expect(response.status, text).toBe(200);
  const payload = response.headers.get("content-type")?.includes("text/event-stream")
    ? text
        .split("\n")
        .filter((l) => l.startsWith("data:"))
        .map((l) => l.slice(5).trim())
        .filter(Boolean)
        .pop()!
    : text;
  return JSON.parse(payload);
}

describe("MCP over HTTP", () => {
  it("initializes", async () => {
    const { result } = await rpc("initialize", {
      protocolVersion: "2025-06-18",
      capabilities: {},
      clientInfo: { name: "test", version: "1.0.0" },
    });
    expect(result.serverInfo.name).toBe("swiftui-for-humans");
    expect(result.capabilities.tools).toBeDefined();
    expect(result.instructions).toMatch(/sfh_search/);
  });

  it("lists three read-only tools with titles", async () => {
    const { result } = await rpc("tools/list");
    const names = result.tools.map((t: any) => t.name).sort();
    expect(names).toEqual(["sfh_get_topic", "sfh_review_checklist", "sfh_search"]);
    for (const tool of result.tools) {
      expect(tool.title, tool.name).toBeTruthy();
      expect(tool.annotations.readOnlyHint, tool.name).toBe(true);
      expect(tool.annotations.destructiveHint, tool.name).toBe(false);
      expect(tool.annotations.openWorldHint, tool.name).toBe(false);
    }
    const getTopic = result.tools.find((t: any) => t.name === "sfh_get_topic");
    expect(getTopic.inputSchema.properties.response_format.enum).toEqual(["concise", "full"]);
    expect(getTopic.inputSchema.required).toEqual(["id"]);
  });

  it("calls sfh_search", async () => {
    const { result } = await rpc("tools/call", { name: "sfh_search", arguments: { query: "liquid glass", limit: 3 } });
    expect(result.isError).toBeFalsy();
    expect(result.content[0].text).toMatch(/`liquid-glass`/);
  });

  it("calls sfh_get_topic, concise by default", async () => {
    const { result } = await rpc("tools/call", { name: "sfh_get_topic", arguments: { id: "sheet" } });
    expect(result.content[0].text).toMatch(/^# /);
    expect(result.content[0].text.length / 4).toBeLessThanOrEqual(800);
  });

  it("returns a tool error, with suggestions, for an unknown id", async () => {
    const { result } = await rpc("tools/call", { name: "sfh_get_topic", arguments: { id: "navstack" } });
    expect(result.isError).toBe(true);
    expect(result.content[0].text).toMatch(/Did you mean/);
  });

  it("rejects bad arguments", async () => {
    const { result, error } = await rpc("tools/call", { name: "sfh_search", arguments: { query: "x", limit: 99 } });
    // Depending on the SDK, invalid input is a JSON-RPC error or a tool error.
    expect(error ?? result.isError).toBeTruthy();
  });

  it("calls sfh_review_checklist", async () => {
    const { result } = await rpc("tools/call", { name: "sfh_review_checklist", arguments: { platform: "macos" } });
    expect(result.content[0].text).toMatch(/Run the linter/);
  });

  it("answers CORS preflight", async () => {
    const response = await handler(new Request("http://localhost/mcp", { method: "OPTIONS" }));
    expect(response.status).toBe(204);
    expect(response.headers.get("access-control-allow-methods")).toMatch(/POST/);
  });
});
