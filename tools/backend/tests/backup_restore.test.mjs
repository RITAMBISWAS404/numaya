// Backup, isolated restore drill and deletion replay against the real development project.
import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { basename } from 'node:path';
import { member, rpc, cleanup, env } from '../lib/harness.mjs';
import { backup } from '../scripts/backup.mjs';
import { restoreDrill } from '../scripts/restore_drill.mjs';
import { processDeletions } from '../scripts/privacy_worker.mjs';

after(cleanup);

test('encrypted backup restores with matching counts and checksums; deletions are replayed',
  { skip: env.NUMAYA_BACKUP_KEY ? false : 'NUMAYA_BACKUP_KEY not set in supabase/.env.local', timeout: 600_000 },
  async () => {
    const keep = await member('bkKeep', { gender: 'woman', openTo: ['man'] });
    const gone = await member('bkGone', { gender: 'man', openTo: ['woman'] });
    // Back up while both exist, then delete one for good.
    const { dir } = await backup({ log: () => {} });
    await rpc(gone, 'request_account_deletion');
    await rpc(gone, 'purge_account');
    assert.equal((await processDeletions({ only: [gone.id] })).completed, 1);

    const report = await restoreDrill(basename(dir), { log: () => {} });
    assert.deepEqual(report.mismatches, []);
    assert.ok(report.tables > 10 && report.rows > 0);
    assert.ok(report.objectsVerified >= 4, 'photo objects decrypt to their recorded hashes');
    assert.ok(report.tombstonesReplayed >= 1);
    assert.equal(report.leftoverAfterReplay, 0, 'a deleted member never returns through a restore');
    assert.ok(keep.id);
  });
