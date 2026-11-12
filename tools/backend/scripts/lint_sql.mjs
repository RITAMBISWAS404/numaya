// Offline syntax check of every migration with the real PostgreSQL parser (libpg-query, the
// Postgres 17 parser compiled to WebAssembly): top-level SQL and every PL/pgSQL function body.
// This proves syntax only; semantics (names, types, permissions) are proven by applying the
// migrations to the development project and running tests/.
import { readdirSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { loadModule, parse, parsePlPgSQL } from 'libpg-query';
import { repoRoot } from '../lib/env.mjs';

await loadModule();
const dir = resolve(repoRoot, 'supabase', 'migrations');
let failures = 0;
for (const f of readdirSync(dir).filter((x) => x.endsWith('.sql')).sort()) {
  const sql = readFileSync(resolve(dir, f), 'utf8');
  try {
    const tree = await parse(sql);
    let fns = 0;
    try {
      await parsePlPgSQL(sql);
      fns = tree.stmts.filter((s) => s.stmt.CreateFunctionStmt).length;
    } catch (e) {
      failures++;
      console.log(`FAIL plpgsql ${f}: ${e.message}`);
      continue;
    }
    console.log(`ok   ${f}: ${tree.stmts.length} statements, ${fns} functions`);
  } catch (e) {
    failures++;
    console.log(`FAIL sql ${f}: ${e.message}${e.sqlDetails ? ` at ${e.sqlDetails.cursorPosition}` : ''}`);
  }
}
process.exit(failures ? 1 : 0);
