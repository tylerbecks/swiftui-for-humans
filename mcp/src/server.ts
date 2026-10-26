// The MCP server: three read-only tools over the corpus, served statelessly.
import type { McpServer } from "@modelcontextprotocol/server";
import { createMcpHandler } from "mcp-handler";
import { z } from "zod";
import { Corpus, formatSearch, formatTopic } from "./corpus.js";

export const SERVER_NAME = "swiftui-for-humans";
export const SERVER_VERSION = "1.0.0";

const INSTRUCTIONS =
  "SwiftUI for Humans: current SwiftUI for iOS, iPadOS, and macOS 26–27, Apple's Human Interface Guidelines as " +
  "decision rules, and App Review rules. Models often write deprecated SwiftUI and don't know Liquid Glass, so before " +
  "writing or reviewing SwiftUI, find the topic with sfh_search and read it with sfh_get_topic. Before finishing, run " +
  "through sfh_review_checklist. Topics name related topics by id in backticks.";

// Every tool only reads the bundled corpus: no side effects, no outside calls.
const readOnly = { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: false } as const;
const platform = z
  .enum(["ios", "macos"])
  .optional()
  .describe("ios (iPhone and iPad) or macos. Leave out for both.");

export function registerTools(server: McpServer, corpus: Corpus): void {
  server.registerTool(
    "sfh_search",
    {
      title: "Search SwiftUI for Humans",
      description:
        "Find SwiftUI, Apple design (HIG), and App Store topics. Matches ids, titles, web terms (\"dropdown\", " +
        "\"modal\"), API names, and text. Returns topic ids with one-line summaries; read one with sfh_get_topic.",
      inputSchema: z.object({
        query: z.string().trim().min(1).max(200).describe('What you need, like "confirm delete" or "glassEffect".'),
        platform,
        limit: z.number().int().min(1).max(25).default(8).describe("How many results, 1–25."),
      }),
      annotations: { title: "Search SwiftUI for Humans", ...readOnly },
    },
    async ({ query, platform, limit }) => {
      const { text, isError } = formatSearch(corpus, query, platform, limit);
      return { content: [{ type: "text", text }], isError };
    },
  );

  server.registerTool(
    "sfh_get_topic",
    {
      title: "Read a SwiftUI for Humans topic",
      description:
        "Read one topic: when to use it, default code, rules with reasons, pitfalls, key APIs, and links to Apple's " +
        "docs. concise (the default) is under about 800 tokens; full adds every variant and the Mac differences.",
      inputSchema: z.object({
        id: z.string().trim().min(1).max(100).describe('A topic id from sfh_search, like "navigation-stack".'),
        platform: platform.describe("ios or macos picks that platform's code and rules. Leave out for both."),
        response_format: z.enum(["concise", "full"]).default("concise").describe("concise (default) or full."),
      }),
      annotations: { title: "Read a SwiftUI for Humans topic", ...readOnly },
    },
    async ({ id, platform, response_format }) => {
      const { text, isError } = formatTopic(corpus, id, platform, response_format);
      return { content: [{ type: "text", text }], isError };
    },
  );

  server.registerTool(
    "sfh_review_checklist",
    {
      title: "SwiftUI review checklist",
      description:
        "The checklist to run before calling SwiftUI work done: deprecated APIs, availability, accessibility, " +
        "Dynamic Type, previews, and HIG decisions, plus the top old → new corrections.",
      inputSchema: z.object({ platform }),
      annotations: { title: "SwiftUI review checklist", ...readOnly },
    },
    async ({ platform }) => ({ content: [{ type: "text", text: corpus.checklist(platform) }] }),
  );
}

let shared: Corpus | undefined;

/** The corpus, loaded once per instance. */
export function getCorpus(): Corpus {
  shared ??= Corpus.load();
  return shared;
}

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Accept, Authorization, Mcp-Session-Id, Mcp-Protocol-Version, Last-Event-ID",
  "Access-Control-Expose-Headers": "Mcp-Session-Id, Mcp-Protocol-Version",
};

/**
 * The web-standard request handler. Stateless: every request builds a fresh server
 * from the shared corpus. Nothing is logged (verboseLogs is off and there's no onEvent).
 */
export function createHandler(corpus: Corpus = getCorpus()): (request: Request) => Promise<Response> {
  const mcp = createMcpHandler((server) => registerTools(server, corpus), {
    serverInfo: { name: SERVER_NAME, version: SERVER_VERSION },
    instructions: INSTRUCTIONS,
    verboseLogs: false,
  });
  return async (request) => {
    if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: CORS });
    const response = await mcp(request);
    const headers = new Headers(response.headers);
    for (const [k, v] of Object.entries(CORS)) headers.set(k, v);
    return new Response(response.body, { status: response.status, statusText: response.statusText, headers });
  };
}
