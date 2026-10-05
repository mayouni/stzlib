# Wave 6 (security desk classes) -- defects found by calling the methods (code, not comments; none fixed)

Probed 2026-10-05 in the worktree D:\GitHub\_wtd, Ring 1.27. Every claim below was shown by a second call on different data.
Lines marked SECURITY are for the security desk to route; the others are for the owner of the class.

## stzSecurityLedger and its sealed-file functions

- **SECURITY** SealAttestedTo: the attestor and time header lines are not authenticated. A sealed file whose `# attestor=` line is edited after sealing still verifies with the key (StzVerifySealedLedger answers ok 1 and reports the new attestor). Cause: the seal is HMAC(key, head digest and count) only, and SealAttestedTo prepends the two custody lines after it was computed. Fix shape: put attestor and at inside the sealed text.
- **SECURITY** SealTo / StzVerifySealedLedger: the keyed seal can be stripped. Cut the tail of a sealed file, fix the `# count=` line and delete the `# seal=` line: StzVerifySealedLedger(path, key) answers ok 1, "chain intact over 3 entries". Cause: `if pcKey != "" and _cSeal_ != ""` skips the seal check when the seal line is absent, even when the caller supplied a key. With the old seal kept the cut IS caught. Fix shape: a key given and no seal found is ok 0.
- **SECURITY** ToOcsfNdJson, ToOcsfJson: the export is rebuilt from the stored record through `_EventOf`, which does not carry the severity and folds every outcome that is not granted or failed into refused. Shown: an event of kind auth.login.failed made AsError is stored as severity error and exported with severity_id 3 (the catalog's warning); an observed event (a session expiry) is exported with message REFUSED and status_id 2. A SIEM therefore reads a different story than the ledger holds. ToOtelLogsJson reads the stored fields and is right.
- **SECURITY** SetRefusalBudget: no validation. SetRefusalBudget(-1, -5) is stored as max 0 and a 1 ms window, and max 0 means the budget is OFF, so a negative argument silently removes the flood protection (SECURITY-LEDGERFLOOD-01). Nothing is raised.
- **SECURITY (low)** Anchor / VerifyAgainstAnchor: the anchor of an EMPTY ledger (count 0, 64 zeros) is answered malformed when passed as the list, because StzLedgerAnchorParse requires count >= 1 in the list form, while its :line form is parsed with count 0 and answers not-durable. Two forms of one anchor, two answers.
- Environment, not code: the worktree's `engine/zig-out/bin/stz_seclog.dll` (built 2026-10-04) predates the anchor and the refusal budget, so in this worktree VerifyAgainstAnchor, SetRefusalBudget, RefusalBudget, Suppressed and FlushRefusalCounts raise R3 "Calling Function without definition: stzengineseclogverifyanchor" (and its siblings) until the engine is rebuilt. The probes loaded a COPY of a newer build (sibling worktree _wtt, read only) over it; ledger_anchor_narrated and ledger_flood_narrated cannot pass in this worktree without it.

## stzSecurityEvent

- **SECURITY (low)** OcsfStatusId: 1 for granted and 2 for everything else, so an OBSERVED event (a fact with no verdict) reaches a SIEM as status Failure. Cause: `if @cOutcome = "granted" return 1 ok return 2`.
- Trap, not a defect: ByActor given a text sets the name only; a posture and kinds set by an earlier call stay (the new actor inherits them).

## stzSecretStore

- **SECURITY** RotateToFresh, SaveSealedTo, SaveSealedToVia: with an actor that is not an object (a text, say) they fail closed but with `Error (R13) : Object is required`, raised while the refusal record is built (`"" + poActor.Name()` runs before the isObject test). The refusal is therefore not written to the ledger and no access-log entry is made, where Reveal handles the same actor correctly (outcome refused, actor "?").
- **SECURITY (gap)** Register over an existing name, Rotate, RotateQ and Revoke leave no access-log entry and no ledger event; only RotateToFresh audits (rotated, secret.rotated). Replacing or deleting a credential is invisible to the record that exists to show misuse.
- Not a defect, documented: Rotate returns nothing while RotateQ returns the store; Secret() and Register() work on copies.

## stzSecurityPosture

- **SECURITY** SetStore, AddSite, AddActor keep a COPY of what they are given (Ring assigns objects by value). The refused-accesses invariant misses a reveal refused AFTER SetStore (store refused 1, posture warnings 0), and no-sandboxed-effectful misses an actor whose posture or capabilities change after AddActor. Cause: no shared engine handle behind the objects. Documented in the blocks; a posture asked after the surface changed answers from the old picture.
- Inconsistency: Findings carries [ :invariant, :severity, :where, :message ] with the severity symbol error or warn, while stzDetection and the house contract use [ :rule, :subject, :where, :severity, :message ] and the word warning; NumberOf("warning") answers 0.

## stzDetection / stzDetectionSet

- **SECURITY (silent miss)** WhenKind does not check the kind against the catalog: a misspelled kind watches nothing and CheckAgainst answers [ ] forever (not.a.kind accepted). The same for ThenKind.
- Trap: Repeats without Within has a window of 0 ms, so a burst only counts events stamped with the same millisecond (3 events 10 ms apart: no finding; with Within(20): one).
- stzDetectionSet.Add stores a copy of the detection: AsInfo called on the original after Add does not reach the set (the copy stays error); DetectionQ returns the stored one, and a change through it persists.

## stzAgentHost

- UseEngineLoop (and UseEngineLoopQ): when the engine refuses an agent it raises, but `@bEngineLoop = 1` was already set, so the host stays in engine mode with the agent unscheduled (EngineSlotOf -1) and RunFor never ticks it (0 ticks in 40 ms) until UseRingLoop is called. Cause: the flag is set before the registration loop.
- **SECURITY (low)** Release on an agent that is not quarantined (merely cancelled) resumes it and writes agent.released to the ledger, though nothing was quarantined; the effectful-actor gate is the only check.
- Resume on a retired agent sets IsActive back to 1 although the agent never ticks again (retired stays 1). Cause: Resume writes the active flag and never reads the retired flag.
- RunToQuiet: an agent that fires on every cycle never goes quiet; the loop stops at its 200-round cap and Why still reads "ran 200 round(s) to quiet".
- Two agents registered under one name are both kept; every lookup (TicksOf, Cancel ...) reaches the first only.
