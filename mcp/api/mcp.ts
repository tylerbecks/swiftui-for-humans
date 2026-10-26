// Vercel Function: the MCP endpoint, at /api/mcp and (through vercel.json) /mcp.
import { createHandler } from "../src/server.js";

const handler = createHandler();

export { handler as GET, handler as POST, handler as DELETE, handler as OPTIONS };
