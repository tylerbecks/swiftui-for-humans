// The topic corpus and the lookups behind the three tools. Pure functions over
// data/corpus.json, which scripts/agent-build.py generates from the app's pages.
import { readFileSync } from "node:fs";

export type Platform = "ios" | "macos";
export type ResponseFormat = "concise" | "full";
type ViewKey = "all" | Platform;

export interface Topic {
  id: string;
  title: string;
  summary: string;
  skills: string[];
  category: string;
  platforms: string[];
  aliases: string[];
  apis: string[];
  related: string[];
  url: string;
  full: Partial<Record<ViewKey, string>> & { all: string };
  concise: Partial<Record<ViewKey, string>> & { all: string };
}

export interface CorpusData {
  name: string;
  site: string;
  repo: string;
  editions: Record<string, number>;
  topics: Topic[];
  checklist: Partial<Record<ViewKey, string>> & { all: string };
}

export interface SearchHit {
  id: string;
  title: string;
  summary: string;
  platforms: string[];
  score: number;
}

const STOPWORDS = new Set(
  "a an and are as at be by can do does for from how i in into is it its make me my of on or should the to use using what when which with you your swiftui swift apple app".split(" "),
);

/** Lowercase words, with plurals folded ("sheets" → "sheet"). */
export function words(text: string): string[] {
  return (text.toLowerCase().match(/[a-z0-9]+/g) ?? []).map(stem);
}

function stem(word: string): string {
  if (word.length > 4 && word.endsWith("ies")) return word.slice(0, -3) + "y";
  if (word.length > 3 && word.endsWith("s") && !word.endsWith("ss")) return word.slice(0, -1);
  return word;
}

/** "NavigationStack", "navigation-stack", and "Navigation Stack" all become "navigationstack". */
export function squash(text: string): string {
  return text.toLowerCase().replace(/[^a-z0-9]/g, "");
}

function platformName(p: Platform): string {
  return p === "ios" ? "iOS" : "macOS";
}

export function onPlatform(topic: Topic, platform?: Platform): boolean {
  if (!platform) return true;
  return platform === "ios" ? topic.platforms.includes("iOS") : topic.platforms.includes("macOS");
}

function levenshtein(a: string, b: string): number {
  const row = Array.from({ length: b.length + 1 }, (_, i) => i);
  for (let i = 1; i <= a.length; i++) {
    let prev = row[0];
    row[0] = i;
    for (let j = 1; j <= b.length; j++) {
      const cur = row[j];
      row[j] = Math.min(row[j] + 1, row[j - 1] + 1, prev + (a[i - 1] === b[j - 1] ? 0 : 1));
      prev = cur;
    }
  }
  return row[b.length];
}

function trigrams(s: string): Set<string> {
  const out = new Set<string>();
  for (let i = 0; i + 3 <= s.length; i++) out.add(s.slice(i, i + 3));
  return out;
}

/** Share of the input's three-letter pieces that the name also has. */
function trigramSimilarity(input: string, name: string): number {
  const a = trigrams(input);
  if (a.size === 0) return 0;
  const b = trigrams(name);
  let shared = 0;
  for (const g of a) if (b.has(g)) shared++;
  return shared / (a.size + 0.25 * Math.max(0, b.size - a.size));
}

interface Indexed {
  topic: Topic;
  names: Set<string>; // squashed id, title, and aliases: an exact hit on one of these is a strong match
  fields: { weight: number; words: Map<string, number> }[];
}

function counts(list: string[]): Map<string, number> {
  const m = new Map<string, number>();
  for (const w of list) m.set(w, (m.get(w) ?? 0) + 1);
  return m;
}

export class Corpus {
  readonly data: CorpusData;
  private byId = new Map<string, Topic>();
  private byName = new Map<string, Topic>();
  private index: Indexed[] = [];
  private df = new Map<string, number>();

  constructor(data: CorpusData) {
    this.data = data;
    for (const t of data.topics) this.byId.set(t.id, t);
    // Names resolve to a topic for sfh_get_topic; ids and titles win over aliases.
    for (const t of data.topics) for (const a of t.aliases) if (!this.byName.has(squash(a))) this.byName.set(squash(a), t);
    for (const t of data.topics) {
      this.byName.set(squash(t.title), t);
      this.byName.set(squash(t.id), t);
    }
    for (const t of data.topics) {
      const body = t.full.all.replace(/^---[\s\S]*?\n---\n/, "");
      const entry: Indexed = {
        topic: t,
        names: new Set([t.id, t.title, ...t.aliases].map(squash)),
        fields: [
          { weight: 10, words: counts([...words(t.id), ...words(t.title)]) },
          { weight: 7, words: counts(t.aliases.flatMap(words)) },
          { weight: 5, words: counts(t.apis.flatMap((a) => [squash(a.replace(/\(.*$/, "")), ...words(a)])) },
          { weight: 3, words: counts(words(t.summary)) },
          { weight: 1.5, words: counts(words(t.category)) },
          { weight: 1, words: counts(words(body)) },
        ],
      };
      this.index.push(entry);
      const seen = new Set<string>();
      for (const f of entry.fields) for (const w of f.words.keys()) seen.add(w);
      for (const w of seen) this.df.set(w, (this.df.get(w) ?? 0) + 1);
    }
  }

  static load(url: URL = new URL("../data/corpus.json", import.meta.url)): Corpus {
    return new Corpus(JSON.parse(readFileSync(url, "utf8")) as CorpusData);
  }

  get topics(): Topic[] {
    return this.data.topics;
  }

  private idf(word: string): number {
    const n = this.data.topics.length;
    return Math.log(1 + n / (1 + (this.df.get(word) ?? 0)));
  }

  search(query: string, platform?: Platform, limit = 8): SearchHit[] {
    const terms = [...new Set(words(query).filter((w) => !STOPWORDS.has(w)))];
    const whole = squash(query);
    const hits: SearchHit[] = [];
    for (const entry of this.index) {
      if (!onPlatform(entry.topic, platform)) continue;
      let score = entry.names.has(whole) ? 40 : 0;
      for (const term of terms) {
        const idf = this.idf(term);
        for (const f of entry.fields) {
          const tf = f.words.get(term);
          if (tf) score += f.weight * idf * (1 + Math.log(tf));
          else if (term.length >= 4 && f.weight >= 5) {
            // A prefix in a name field ("glass" → "glasseffect") counts for less.
            for (const w of f.words.keys()) {
              if (w.startsWith(term)) {
                score += (f.weight / 3) * idf;
                break;
              }
            }
          }
        }
      }
      if (score > 0) {
        const t = entry.topic;
        hits.push({ id: t.id, title: t.title, summary: t.summary, platforms: t.platforms, score });
      }
    }
    hits.sort((a, b) => b.score - a.score || a.id.localeCompare(b.id));
    return hits.slice(0, limit);
  }

  /** Finds a topic by id, or by a title or alias like "NavigationStack" or "dropdown". */
  resolve(input: string): Topic | undefined {
    const cleaned = input.trim().replace(/^.*\//, "").replace(/\.md$/i, "");
    return this.byId.get(cleaned.toLowerCase()) ?? this.byName.get(squash(cleaned));
  }

  /** Ids that look like a mistyped or shortened one ("buton", "navstack"), then ids a search for it finds. */
  closeIds(input: string, platform?: Platform, max = 6): string[] {
    const target = squash(input);
    const near = this.data.topics
      .filter((t) => onPlatform(t, platform))
      .map((t) => {
        const names = [t.id, t.title].map(squash);
        const typo = Math.min(...names.map((n) => levenshtein(target, n)));
        const shared = Math.max(...names.map((n) => trigramSimilarity(target, n)));
        return { id: t.id, typo, shared };
      })
      .filter((x) => x.typo <= Math.max(2, Math.floor(target.length / 3)) || x.shared >= 0.35)
      .sort((a, b) => a.typo - b.typo || b.shared - a.shared || a.id.localeCompare(b.id))
      .map((x) => x.id);
    const found = this.search(input, platform, max).map((h) => h.id);
    return [...new Set([...near.slice(0, max - 2), ...found, ...near])].slice(0, max);
  }

  checklist(platform?: Platform): string {
    return this.data.checklist[platform ?? "all"] ?? this.data.checklist.all;
  }
}

// ----------------------------------------------------------------------------- tool output

export function formatSearch(corpus: Corpus, query: string, platform: Platform | undefined, limit: number): { text: string; isError: boolean } {
  const hits = corpus.search(query, platform, limit);
  const scope = platform ? ` on ${platformName(platform)}` : "";
  if (hits.length === 0) {
    const close = corpus.closeIds(query, platform);
    const hint = close.length ? ` Close ids: ${close.map((id) => `\`${id}\``).join(", ")}.` : "";
    return {
      text:
        `No topics match "${query}"${scope}.${hint} Try a SwiftUI type (\`List\`), a design idea ("modal", "contrast"), ` +
        `or an App Store step ("TestFlight"). For raw API reference, add .md to a developer.apple.com docs URL.`,
      isError: false,
    };
  }
  const lines = hits.map((h) => `- \`${h.id}\`: ${h.title} (${h.platforms.join(", ")}). ${h.summary}`);
  return {
    text: `${hits.length} topic${hits.length === 1 ? "" : "s"} for "${query}"${scope}:\n\n${lines.join("\n")}\n\nRead one with sfh_get_topic.`,
    isError: false,
  };
}

export function formatTopic(
  corpus: Corpus,
  id: string,
  platform: Platform | undefined,
  format: ResponseFormat,
): { text: string; isError: boolean } {
  const topic = corpus.resolve(id);
  if (!topic) {
    const close = corpus.closeIds(id, platform);
    return {
      text:
        `No topic has the id "${id}".` +
        (close.length ? ` Did you mean ${close.map((c) => `\`${c}\``).join(", ")}?` : "") +
        ` Ids are lowercase with hyphens, like \`navigation-stack\`. Use sfh_search to find one.`,
      isError: true,
    };
  }
  const views = format === "full" ? topic.full : topic.concise;
  let text = (platform && views[platform]) || views.all;
  if (topic.id !== id.trim().toLowerCase()) {
    text = `Showing \`${topic.id}\`, the topic for "${id}".\n\n${text}`;
  }
  if (platform && !onPlatform(topic, platform)) {
    const others = corpus
      .search(topic.title, platform, 4)
      .map((h) => `\`${h.id}\``)
      .join(", ");
    text =
      `Note: \`${topic.id}\` covers ${topic.platforms.join(", ")}, not ${platformName(platform)}.` +
      (others ? ` ${platformName(platform)} topics that may fit: ${others}.` : "") +
      `\n\n${text}`;
  }
  return { text, isError: false };
}
