-- Cross-user denial tests (pgTAP). NOT RUN: there is no database yet.
-- Run with `supabase test db` (or pg_prove) after applying 0001 and 0002 to a local stack.
-- Fixtures: three users A, B, C with profiles; A and B matched with a conversation; C unrelated.
begin;
select plan(9);

-- As C: nothing private about A or B.
set local role authenticated;
set local request.jwt.claims = '{"sub": "00000000-0000-0000-0000-00000000000c"}';

select is_empty($$ select * from users_private where user_id <> auth.uid() $$,
  'phone, birth date and coordinates are private');
select is_empty($$ select * from messages $$,
  'non-members cannot read messages');
select is_empty($$ select * from credit_ledger where user_id <> auth.uid() $$,
  'credit ledgers are private');
select is_empty($$ select * from likes where sender <> auth.uid() $$,
  'incoming likes are not readable directly (Premium function only)');
select is_empty($$ select reporter from reports where reporter <> auth.uid() $$,
  'reporters are never revealed');
select throws_ok($$ insert into credit_ledger (user_id, idempotency_key, kind, bucket, amount, source)
                    values (auth.uid(), 'x', 'grant', 'purchased', 100, 'client') $$,
  'clients cannot write balances');
select throws_ok($$ update matches set state = 'active' $$,
  'clients cannot change match state');

-- As A after blocking B: B's profile and the conversation's messages disappear.
set local request.jwt.claims = '{"sub": "00000000-0000-0000-0000-00000000000a"}';
select ok((select count(*) from messages) > 0, 'a member can read the conversation');
-- (insert block via service role in fixture step, then:)
select is_empty($$ select * from profiles where user_id = '00000000-0000-0000-0000-00000000000b'
                   and exists (select 1 from blocks where blocker = auth.uid()) $$,
  'blocked profiles are hidden');

select * from finish();
rollback;
