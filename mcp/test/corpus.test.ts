import { describe, expect, it } from "vitest";
import { Corpus, formatSearch, formatTopic, squash, words } from "../src/corpus.js";

const corpus = Corpus.load();
const ids = (query: string, platform?: "ios" | "macos", limit = 5) => corpus.search(query, platform, limit).map((h) => h.id);
const tokens = (text: string) => Math.ceil(text.length / 4);

describe("the generated corpus", () => {
  it("has every topic, with unique ids and the three tool views", () => {
    expect(corpus.topics.length).toBeGreaterThan(150);
    expect(new Set(corpus.topics.map((t) => t.id)).size).toBe(corpus.topics.length);
    for (const t of corpus.topics) {
      expect(t.full.all.length, t.id).toBeGreaterThan(0);
      expect(t.concise.all.length, t.id).toBeGreaterThan(0);
      expect(t.url).toBe(`https://www.swiftuiforhumans.com/agents/${t.id}.md`);
    }
  });

  it("keeps concise views under ~800 tokens and full views under ~5,000", () => {
    for (const t of corpus.topics) {
      for (const text of Object.values(t.concise)) expect(tokens(text!), t.id).toBeLessThanOrEqual(800);
      for (const text of Object.values(t.full)) expect(tokens(text!), t.id).toBeLessThanOrEqual(5000);
    }
  });

  it("only relates topics that exist", () => {
    for (const t of corpus.topics) for (const r of t.related) expect(corpus.resolve(r)?.id, `${t.id} → ${r}`).toBe(r);
  });
});

describe("words and squash", () => {
  it("folds plurals and punctuation", () => {
    expect(words("Sheets, Lists & Categories")).toEqual(["sheet", "list", "category"]);
    expect(squash("NavigationStack")).toBe(squash("navigation-stack"));
  });
});

describe("search", () => {
  it("finds topics by id, title, and API name", () => {
    expect(ids("NavigationStack")[0]).toBe("navigation-stack");
    expect(ids("liquid glass")[0]).toBe("liquid-glass");
    expect(ids("glassEffect")).toContain("liquid-glass");
  });

  it("finds topics by the words people coming from the web use", () => {
    expect(ids("dropdown")).toEqual(expect.arrayContaining(["picker"]));
    expect(ids("modal")).toEqual(expect.arrayContaining(["sheet"]));
  });

  it("finds design and shipping topics", () => {
    expect(ids("deprecated APIs")[0]).toBe("deprecated-apis");
    expect(ids("TestFlight", undefined, 8).some((id) => id.includes("testflight"))).toBe(true);
  });

  it("filters by platform and respects the limit", () => {
    const mac = corpus.search("window", "macos", 10);
    expect(mac.length).toBeGreaterThan(0);
    expect(mac.every((h) => h.platforms.includes("macOS"))).toBe(true);
    const ios = corpus.search("window", "ios", 10);
    expect(ios.every((h) => h.platforms.includes("iOS"))).toBe(true);
    expect(corpus.search("button", undefined, 2)).toHaveLength(2);
  });

  it("explains an empty search", () => {
    const { text, isError } = formatSearch(corpus, "zzqqxx", undefined, 5);
    expect(isError).toBe(false);
    expect(text).toMatch(/No topics match/);
  });

  it("lists ids with one-line summaries", () => {
    const { text } = formatSearch(corpus, "toggle", undefined, 3);
    expect(text).toMatch(/^3 topics for "toggle":/);
    expect(text).toMatch(/- `toggle`: Toggle \(/);
  });
});

describe("get topic", () => {
  it("returns the concise view by default and the full view on request", () => {
    const concise = formatTopic(corpus, "button", undefined, "concise");
    const full = formatTopic(corpus, "button", undefined, "full");
    expect(concise.isError).toBe(false);
    expect(concise.text).toMatch(/^# Button/);
    expect(concise.text).toMatch(/response_format "full"/);
    expect(full.text.length).toBeGreaterThan(concise.text.length);
    expect(full.text).toMatch(/## On macOS/);
  });

  it("gives each platform its own view of a shared page", () => {
    const mac = formatTopic(corpus, "button", "macos", "full").text;
    const ios = formatTopic(corpus, "button", "ios", "full").text;
    expect(mac).toMatch(/platforms: \[macOS\]/);
    expect(ios).toMatch(/platforms: \[iOS, iPadOS\]/);
    expect(ios).not.toMatch(/## On macOS/);
  });

  it("resolves titles and aliases, and says so", () => {
    const { text, isError } = formatTopic(corpus, "NavigationStack", undefined, "concise");
    expect(isError).toBe(false);
    expect(text).toMatch(/^Showing `navigation-stack`/);
    expect(formatTopic(corpus, "button.md", undefined, "concise").text).toMatch(/# Button/);
  });

  it("suggests close ids for an unknown one", () => {
    const { text, isError } = formatTopic(corpus, "buton", undefined, "concise");
    expect(isError).toBe(true);
    expect(text).toMatch(/No topic has the id "buton"/);
    expect(text).toMatch(/`button`/);
  });

  it("notes when a topic doesn't cover the requested platform", () => {
    const macOnly = corpus.topics.find((t) => !t.platforms.includes("iOS"))!;
    const { text, isError } = formatTopic(corpus, macOnly.id, "ios", "concise");
    expect(isError).toBe(false);
    expect(text).toMatch(/^Note: `.+` covers macOS, not iOS/);
  });
});

describe("review checklist", () => {
  it("drops Mac-only items on iOS and keeps them on macOS", () => {
    expect(corpus.checklist("ios")).not.toMatch(/\[ \] Mac:/);
    expect(corpus.checklist("macos")).toMatch(/\[ \] Mac:/);
    expect(corpus.checklist()).toMatch(/## Top corrections/);
  });
});
