#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const args = new Set(process.argv.slice(2));
const dryRun = args.has("--dry-run") || !args.has("--apply");
const root = process.cwd();
const envPath = path.join(root, ".env.local");

function parseEnvFile(filePath) {
  if (!fs.existsSync(filePath)) return {};
  const out = {};
  const lines = fs.readFileSync(filePath, "utf8").split(/\r?\n/);
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const idx = trimmed.indexOf("=");
    if (idx === -1) continue;
    const key = trimmed.slice(0, idx).trim();
    const value = trimmed.slice(idx + 1).trim();
    out[key] = value;
  }
  return out;
}

const env = { ...process.env, ...parseEnvFile(envPath) };
const required = [
  "NEXT_PUBLIC_SUPABASE_URL",
  "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY",
  "SUPABASE_SERVICE_ROLE_KEY",
];

const missing = required.filter((k) => !env[k] || String(env[k]).trim() === "");

console.log("AYAD Supabase fresh-start check");
console.log(`Mode: ${dryRun ? "dry-run (read-only)" : "apply (no writes performed by this script)"}`);
console.log(`Project root: ${root}`);
console.log("");
console.log("Required env vars:");
for (const key of required) {
  const ok = !missing.includes(key);
  console.log(`- ${key}: ${ok ? "present" : "MISSING"}`);
}

console.log("");
console.log("Fresh-start notes:");
console.log("- No legacy MongoDB migration (N/A). ");
console.log("- No legacy image migration (N/A). ");
console.log("- Use Supabase migrations in supabase/migrations and seed in supabase/seed.sql.");

if (missing.length > 0) {
  console.error("\nResult: FAILED (missing required env vars).");
  process.exit(1);
}

console.log("\nResult: OK (fresh-start prerequisites satisfied for Supabase configuration checks).");
process.exit(0);
