# Softanza threat model

Written 2026-09-29 by the stzlib-security plane. It turns the Security
Readiness Compass (2026-09-28) from a rating into an auditable claim:
**every guarantee below names the guard that proves it**, and every guard
named here exists -- `base/test/security/threat_model_narrated.ring`
checks that on each run. A guarantee without a guard is not listed as a
guarantee; it is listed under *Open risks*, with the rung that will close
it.

Norms used as lenses, not as compliance verdicts:

| Short | Norm |
|---|---|
| A01-A10 | OWASP Top 10:2025 |
| ASI01-ASI10 | OWASP Top 10 for Agentic Applications, 2026 |
| LLM01-LLM10 | OWASP Top 10 for LLM Applications |
| GV ID PR DE RS RC | NIST CSF 2.0 functions (Govern, Identify, Protect, Detect, Respond, Recover) |

Assertion counts are from runs on 2026-09-29 against `main`.

---

## 1. What is protected

| Asset | Where it lives |
|---|---|
| The right to act on the world (effects) | the capability lattice: `stzSystemActor`, agent graphs, update plans |
| Identities and sessions | `stzAuth` and its stores |
| Secrets | `stzSecretStore`, `stzSecret` |
| Evidence of what happened | the security ledger (`engine/src/seclog.zig`), its durable log and sealed exports |
| Knowledge and agent memory | `stzKnowledgeGraph`, `stzAgentMemory`, `.zknw` files |
| Models | GGUF files loaded by the neural engine |
| The engine itself | `engine/src/`, and the vendored C code in `engine/vendor/` |

## 2. Who attacks, and how far this model goes

| Attacker | Can | This model's position |
|---|---|---|
| **T1 Network peer** | send any bytes to a listener or a client | in scope |
| **T2 Untrusted text and data** | put words in a prompt, a filename, a form field, a document | in scope |
| **T3 A hijacked LLM** | propose anything, in any words | in scope -- **assumed to happen**; the design removes what it could do |
| **T4 A tampered artefact** | swap a model file, a vendored library, a saved `.zknw` | in scope |
| **T5 Someone with the files** | edit a database or a log on disk | in scope for *detection*, not prevention |
| **T6 Code already running in the process** | anything the process can | **out of scope**: it can wipe the ledger or read a secret. Evidence-grade means *exported* |

The central design claim, and the one this model exists to keep honest:
**an LLM that is fooled still cannot act, because it never holds the
capability.** Softanza does not try to detect every malicious prompt; it
assumes one will get through (T3) and makes it harmless.

---

## 3. Guarantees, each with its proof

### Agents and effects

| ID | Guarantee | Enforced by | Proven by (assertions) | Norms | Honest limit |
|---|---|---|---|---|---|
| G01 | An LLM actor never holds, and so never uses, the `effectful` capability | `stzAgentGraph.Grant` refuses it at construction; `no-llm-effectful` audits it | `base/test/agentic/agentrule_narrated.ring` (21), `base/test/agentic/agentgraph_narrated.ring` (11), `base/test/agentic/safeworld_narrated.ring` (76) | ASI03, ASI01, A01, GV, PR | A raw edit is caught as tampering, and cannot change the gate's decision -- G34 |
| G02 | Every effect passes a guardian and leaves a trace | invariants `effects-guarded`, `effects-traced`, `effects-dominated` | `base/test/agentic/agentrule_narrated.ring` (21), `base/test/governance/governance_narrated.ring` (19) | ASI02, ASI10, A06 | Checked at composition, not at every call |
| G03 | Open LLM text and external data reach an effect only through a guardian or a validated checkpoint | invariants `open-text-contained`, `external-data-contained` (reads the `external_data` taint) | `base/test/security/prompt_boundary_narrated.ring` (17), `base/test/agentic/agentrule_narrated.ring` (21) | ASI01, LLM01, A06 | The graph must declare its nodes' taint truthfully |
| G04 | Untrusted text cannot write a prompt turn | `StzChatSafeText` breaks every `<\|` control-token opener in user text | `base/test/security/prompt_boundary_narrated.ring` (17) | LLM01, ASI01 | Guards the MARKERS; persuasive words still reach the model -- G01 is what makes that harmless |
| G05 | A model's malformed output is refused, never half-used | constrained decoding and schema-checked structured output | `base/test/neural/structuredoutput_narrated.ring` (73), `base/test/neural/constrained_decoding_narrated.ring` (50) | LLM05, ASI02 | Structure kills malformedness, never falsehood |
| G06 | A human reviews a plan, and every ruling keeps its lineage | decision lineage in the governance plane | `base/test/governance/governance_lineage_narrated.ring` (37) | ASI09, GV | The negotiation loop over a rejected plan is design only -- R7 |

### Transport and input

| ID | Guarantee | Enforced by | Proven by (assertions) | Norms | Honest limit |
|---|---|---|---|---|---|
| G07 | TLS clients verify the peer by default -- given CA, else the OS trust store -- and skip it only under the named `:InsecureNoVerify` | `applyClientVerify` in `engine/src/reactor.zig` | `base/test/security/tls_fail_closed_narrated.ring` (12), `base/test/cluster/mtls_narrated.ring` (15), `base/test/cluster/d5_security_narrated.ring` (21) | A04, A02, ASI07, PR | The POSIX trust-bundle paths are unverified from this machine -- R14 |
| G08 | Node-to-node requests are signed, fresh and not replayable | `stzRequestSigner`: HMAC, freshness window, nonce cache | `base/test/cluster/request_signing_narrated.ring` (29), `base/test/system/security_seams_narrated.ring` (37) | ASI07, A07, A08 | Shared-secret signing; no key distribution protocol |
| G09 | No shell parses data: a list of arguments spawns as argv, file permissions are engine calls | `stz_system_run_argv`, `stz_file_set_readonly` | `base/test/security/spawn_no_shell_narrated.ring` (10) | A05, ASI05 | A whole command STRING is still a shell call, by design; three other planes still build shell strings -- R11 |
| G10 | No SQL value is spliced into a statement, and a failed statement raises instead of returning partial rows | `db.zig` statement verbs, `stzDatabase.ExecWith/RowsWith` | `base/test/security/sql_bound_narrated.ring` (26), `base/test/system/auth_store_narrated.ring` (37) | A05, A10 | Plain `Exec(sql)` still takes whole statements; values belong in `ExecWith` |
| G11 | Parsers of untrusted bytes survive fuzzing without memory errors or UB | five harnesses under UBSan: HTTP framing, TLS cert/record, PCRE2, utf8proc, SQLite | `zig build fuzz` (2.1 M inputs), run by `engine/tools/security_gate.py --full` | A03, A05, A10 | Seeded, not coverage-guided; not run on a schedule -- R12 |

### Identity and secrets

| ID | Guarantee | Enforced by | Proven by (assertions) | Norms | Honest limit |
|---|---|---|---|---|---|
| G12 | Authentication is complete and tested: sessions with TTL and idle timeout, lockout, TOTP, passkeys, passwordless, OIDC and SAML on both sides, authorization | `stzAuth` and its providers | `base/test/system/auth_sessions_narrated.ring` (25), `base/test/system/auth_totp_narrated.ring` (40), `base/test/system/auth_passkey_narrated.ring` (29), `base/test/system/auth_passwordless_narrated.ring` (23), `base/test/system/auth_oidc_narrated.ring` (43), `base/test/system/auth_oidc_provider_narrated.ring` (67), `base/test/system/auth_saml_narrated.ring` (77), `base/test/system/auth_router_narrated.ring` (45), `base/test/system/auth_authz_narrated.ring` (31), `base/test/system/auth_store_narrated.ring` (37) | A07, PR | -- |
| G13 | An account can be locked; the lock closes every login path AND every live session, and is kept in the store | `stzAuth.LockAccount` | `base/test/security/containment_drill_narrated.ring` (27) | A07, RS | -- |
| G14 | A secret is revealed only to an effectful, non-sandboxed actor, and every reveal or refusal is recorded | `stzSecretStore`, `stzSecret` | `base/test/system/secretstore_narrated.ring` (26), `base/test/system/secret_narrated.ring` (53), `base/test/system/security_seams2_narrated.ring` (41) | ASI03, A01, PR | An in-memory store holds plaintext while the process runs; at rest it can be sealed (G28); it can come from a vault (G29) |
| G15 | Production refuses fakes: a sandboxed or in-memory service raises at the production phase | the service-virtualization plane | `base/test/system/deployment_narrated.ring` (63) | A02 | -- |
| G27 | A password is stored as Argon2id (19 MiB, 2 passes, 1 lane; PHC string), and an older PBKDF2 hash upgrades itself on the next successful login | `StzHashPassword`, `StzVerifyPassword`, `stzAuth.Authenticate` | `base/test/security/at_rest_crypto_narrated.ring` (31) | A04, A07, PR | High-entropy values (recovery codes, client secrets, one-time codes) stay on PBKDF2 on purpose: memory-hardness buys nothing there, and their stored form must be comma-free; about 25-44 ms per password hash here |
| G28 | Data at rest can be sealed with authenticated encryption, and a secret store can be written as one sealed file: a wrong key, an altered byte or another store's label opens NOTHING | XChaCha20-Poly1305 in `engine/src/crypto.zig`; `StzSeal`/`StzOpen`; `stzSecretStore.SaveSealedTo`, `StzSecretStoreFromSealedFile` | `base/test/security/at_rest_crypto_narrated.ring` (31) | A04, A08, ASI03, PR | The key is a secret with its own source (env, file, vault via G29) |
| G29 | Secrets can come from a real secret manager: the Vault HTTP API (HashiCorp Vault, OpenBao), KV v1 and v2; the token is itself a secret, revealed per request and never held; plain http only to loopback; a refusal, a missing secret or a missing field RAISES | `stzVaultHttpResolver` | `base/test/security/vault_http_narrated.ring` (19) | A04, ASI03, PR | Tested against a stand-in Vault over real HTTP, not a real Vault; token renewal and AppRole login are not implemented; the engine HTTP pool ejects a host after failed connections, so a Vault that was down is retried only after the pool recovers |

### Evidence, detection, response

| ID | Guarantee | Enforced by | Proven by (assertions) | Norms | Honest limit |
|---|---|---|---|---|---|
| G16 | Security events are typed, redacted at construction, and hash-chained; a retroactive edit names the first broken entry | `engine/src/seclog.zig`, `stzSecurityLedger` | `base/test/system/security_ledger_narrated.ring` (35) | A09, A08, DE | An in-process attacker can wipe the ring -- T6 |
| G17 | The ledger is durable: every event is written through to an insert-only table, and a history with an edited or missing row is refused on load | `engine/src/seclog_durable.zig` | `base/test/security/durable_ledger_narrated.ring` (25) | A09, A08, RC | Tail truncation is undetectable from the file alone -- anchor the head digest (seal, attestation); `synchronous=NORMAL` may lose the newest entries on power loss |
| G18 | Evidence leaves the process sealed and attested; tampered evidence is not believed | `SealAttestedTo`, `StzLedgerFromSealedFile` | `base/test/system/security_attest_narrated.ring` (34), `base/test/system/security_drill_narrated.ring` (21) | A08, RS | The seal key is a shared secret |
| G19 | Known attack shapes are detected, and a sentinel raises them | detections with a corroboration law, an edge-triggered sentinel | `base/test/system/security_detection_narrated.ring` (33), `base/test/system/security_sentinel_narrated.ring` (33) | DE, A09 | Tick-driven; no anomaly detection -- R9 |
| G20 | Escalation paths and blast radius are computed, not guessed | `stzSecurityGraph`, posture reports | `base/test/system/securitygraph_narrated.ring` (22), `base/test/system/security_posture_narrated.ring` (20) | ID, ASI03, A01 | -- |
| G21 | Containment is governed: anyone may propose it, only an effectful actor commits it, and a real responder performs it | `stzResponsePlan`, `stzAuthResponder` | `base/test/system/security_response_narrated.ring` (27), `base/test/security/containment_drill_narrated.ring` (27) | RS, ASI10 | Five real responders cover all six catalogue actions (authentication, secret store, capabilities, rate limiter, agent host) |
| G22 | Responsiveness is MEASURED: in the drill, credential stuffing over real HTTP is detected in 351-357 ms and contained in 53-57 ms (three runs) | `stzSecurityDrill.TimeToDetectMs / TimeToContainMs` | `base/test/security/containment_drill_narrated.ring` (27) | DE, RS | One attack shape, loopback, one machine; detection is run on demand, not continuously |
| G30 | A secret the application owns can be rotated by containment, and a plan spanning several owners is performed by each owner -- or refused WHOLE, before anything happens, when an action has no owner | `stzSecretStore.RotateToFresh`, `stzSecretStoreResponder`, `stzResponderSet`, the ownership preflight in `stzResponsePlan.ExecuteOn` | `base/test/security/rotate_secret_narrated.ring` (18) | RS, RC, A04 | A secret held in env, a file or a vault must be rotated at its source (it refuses, naming it); rotation does not yet propagate to the services using the old value |
| G31 | A compromised actor's capability can be revoked for real: every path by which THAT actor reaches it in the security graph is cut (a direct hold, a granting tool, a delegation), other actors keep theirs, and the live actor object loses the kind the runtime gates ask about | `stzSecurityGraph.CutCapability`, `stzCapabilityResponder` | `base/test/security/revoke_capability_narrated.ring` (16) | RS, ASI03, ASI10, A01 | Live actors must be registered one by one (`AddLiveActor`): Ring copies objects in a list literal, and revoking a copy changes nothing |
| G32 | A flooding source can be shed for real: a blocked key is refused whether or not it has a rate limit, each refusal carries the block's reason, and a timed block lifts by itself | `stzRateLimiter.Block/BlockFor/Unblock`, `stzRateLimiterResponder` | `base/test/security/shed_source_narrated.ring` (16) | RS, A04, DE | The block lives in the limiter object the application admits through -- a COPY of that limiter would not see it; blocks are not persisted across a restart |
| G33 | A rogue agent can be quarantined: the host stops running it, keeps the reason, refuses Resume(), and only an effectful actor can Release it. With it, all six catalogue actions have a real owner, and one plan can use all six at once | `stzAgentHost.Quarantine/Release`, `stzAgentHostResponder`, `stzResponderSet` | `base/test/security/quarantine_part_narrated.ring` (20) | RS, ASI10, ASI08 | Quarantine lives in the host object; it is not persisted across a restart |
| G34 | A property set around a governed door changes no decision and does not go unseen: the properties a gate decides on (an agent node's kind and granted capabilities, an actor's posture) are sealed by the governed doors out of `GraphQ()`'s reach, the gates read the seal, and every mismatch is reported by `Tampering()`, `Violations()`, `CheckRules()` and `IsSound()` | the sealed record in `stzAgentGraph` and `stzSecurityGraph` | `base/test/security/raw_graph_bypass_narrated.ring` (17), `base/test/agentic/agentrule_narrated.ring` (22) | ASI03, A01, GV | Edges are not sealed: a raw edge is visible to every path audit, but it is not attributed as tampering |
| G35 | An agent file may call only the Ring functions CODE allowed, at no more trust than code allowed: a `ring:` clause naming any other loaded function is refused at load, and so is a file claiming a more trusted posture than its allowance | `StzAllowAgentFunction`, the load gate in `stzAgentDeclaration` | `base/test/security/agent_function_allowlist_narrated.ring` (12) | ASI02, ASI05, LLM06 | The allowance names the function, not what it does: allowing a function is a code review of it |
| G36 | A forgotten password can be reset without opening a door: the request never tells which emails have accounts; the link is 256 random bits, stored only as its hash, one-time, 30 minutes, cancelled by a newer request; a reset stores Argon2id, ends every session, signs nobody in, and cannot reopen an account containment locked | `stzAuth.RequestPasswordReset`, `ResetPassword` | `base/test/security/password_reset_narrated.ring` (25) | A07, PR, RC | The link travels by email: whoever reads the mailbox can reset -- the second factor still guards the next login |
| G37 | A runaway agent is contained, not merely slowed: an agent that takes more actions than its budget allows in a window is quarantined, on the timer, the engine loop and in the middle of an event burst alike, and a release starts a fresh window | `stzAgentHost.SetActionBudget`, the accounting in `TickDue` | `base/test/security/action_budget_narrated.ring` (14) | ASI08, ASI10, RS | The budget counts skill firings, not the size of each effect; an agent with no budget set is not limited |
| G38 | Detection learns its threshold: the UNUSUAL shape judges the newest window of an event kind against its own history, leave-one-out, so password spraying (one failure on each of many accounts, invisible to a per-account burst) fires; cold start claims nothing, and a flood that evicted its own baseline is reported as a warning, never silenced | `stzDetection.Unusual`, `password-spraying` in `StzDefaultDetectionSet` | `base/test/security/anomaly_detection_narrated.ring` (21) | DE.AE, A07 | Rates of one kind only -- no model of sequences or of values; the baseline is what the ledger window still holds |
| G39 | A stranger cannot flush the evidence: each refused kind writes at most 64 lines a minute into the ledger; past that the engine counts, marks that the budget was reached, and closes the window with one summary line carrying the count, so a flood of forged webhooks (measured: 1,100 in 1.7 s, which emptied a 1,024-entry window before) cannot evict another kind's evidence; grants are never budgeted | `seclog.zig` refusal budget, `stzSecurityLedger.SetRefusalBudget`, `Suppressed`, `FlushRefusalCounts` | `base/test/security/ledger_flood_narrated.ring` (14) and two `seclog.zig` unit tests | A09, DE.CM | Refusals past the budget are counted, not kept one by one -- in the durable file too; a detection counting more than 64 of one kind a minute sees the cap, not the true number |
| G40 | A sealed secret store stays readable whatever planes are loaded: a kind "<family>-<part>" is rebuilt by the family's own `StzSecretFromKind_<family>` when it is loaded, and otherwise read as a plain secret that keeps its kind -- the store names no plane | `_StzSecretFromRecord`, `_StzSecretKindFactory` | `base/test/security/secret_kind_factory_narrated.ring` (7) | A08 | Without its family loaded, a kind's expiry is not kept on a re-save |
| G41 | A cut or rebuilt durable log is seen: Anchor() gives the count and head digest as one line to send off the machine, and VerifyAgainstAnchor() says whether the stored history still reaches it -- holds, truncated (the tail was cut, though what remains verifies from genesis), diverged (a whole new chain was built), or broken | `seclog_verify_anchor`, `stzSecurityLedger.Anchor`, `VerifyAgainstAnchor` | `base/test/security/ledger_anchor_narrated.ring` (12) | A09, PR.DS | Detects only back to the LAST anchor that left the machine; sending it, and how often, is the deployment's |
| G42 | A path is never handed to a shell to open it or make it: StzOpenInDefaultApp opens an EXISTING file or folder through ShellExecuteW (Windows) or `open` / `xdg-open` with the path as one argument, and launches nothing otherwise; StzMakeDir makes a folder in the engine | `stz_system_open_default`, `StzOpenInDefaultApp`, `StzMakeDir` | `base/test/security/no_shell_open_narrated.ring` (7) | A03, A05 | No guard opens a real viewer (it would put a window on the screen of whoever runs it): the launch itself is unperceived; the POSIX branch is type-checked for Linux and macOS, not run |
| G43 | A key that must exist as a file is readable by its owner alone: StzWritePrivateFile creates it with a protected access list (Windows, checked against the real icacls listing: one entry, the owner) or mode 0600 (elsewhere) from the first byte, replacing any existing file | `stz_file_write_private`, `StzWritePrivateFile` | `base/test/security/private_file_narrated.ring` (13) | A02, PR.DS | The 0600 branch is type-checked, never run; the file is only as short-lived as its caller makes it; an administrator can still take ownership |

### Supply chain and data integrity

| ID | Guarantee | Enforced by | Proven by (assertions) | Norms | Honest limit |
|---|---|---|---|---|---|
| G23 | A model file is parsed only after its SHA-256 matches a recorded digest | `engine/src/model_digest.zig`, `StzTrustModel` | `base/test/security/model_digest_narrated.ring` (17) | ASI04, LLM03, A08 | Local digests of `models/` are not yet checked against their publishers |
| G24 | Knowledge keeps its provenance and contradictions through a save; agent memory records who learned what, and when | `.zknw` provenance and contradictions sections; `stzAgentMemory.Learn` | `base/test/security/provenance_survives_save_narrated.ring` (23) | ASI06, LLM04 | Provenance says where a fact came from, not whether it is true |
| G25 | No vendored file changes without its record; the SBOM is generated, never hand-written | 19 `VERSION.txt` records with a Tree-Digest; `engine/tools/sbom.py` | `engine/tools/sbom.py --check` (19 records) | A03, GV | -- |
| G26 | Vulnerability reports have a private channel and a response promise | `SECURITY.md`; GitHub private vulnerability reporting, enabled 2026-09-29 | `SECURITY.md`, `base/security/SOFTANZA_CRA_RUNBOOK.md` | GV, RS | The promise and its runbook are documents: one person owns every clock, and submission is by hand |

---

## 4. Open risks -- named, not guarded

Each is a gap with no guard yet. The rung is the plane's plan for it.

| ID | Risk | Norms | Rung |
|---|---|---|---|
| R1 | ~~A property set on the raw graph walks around `Grant` and `AttachSecret`~~ | ASI03, A01 | **CLOSED 2026-09-29** -- now G34 (a formal capability TYPE remains the stronger form) |
| R2 | ~~A `ring:` clause could name any function loaded in the process~~ | ASI02, ASI05 | **CLOSED 2026-09-29** -- now G35 |
| R3 | ~~No authenticated encryption for data at rest; PBKDF2 is the only password hash~~ | A04 | **CLOSED 2026-09-29** -- now G27 and G28 |
| R4 | ~~No Vault or KMS adapter~~ | A04, ASI03 | **CLOSED 2026-09-29** -- now G29 (Vault HTTP API); a cloud-KMS adapter (AWS, GCP, Azure) is not done |
| R5 | ~~Truncating the durable log's tail is undetectable~~ (closed 2026-10-05, G41: an anchor detects a cut or a rebuild); an in-process attacker can still wipe the in-memory ring, and an anchor protects only as far as the last one that left the machine | A09, T6 | the anchor's witness is the deployment's |
| R6 | Plugins are not shipped, so foreign code is not yet governed | ASI04 | rung 6 (plugin plane) |
| R7 | ~~No per-agent rate limit~~ (closed 2026-09-30, G37); the negotiation loop over a rejected plan is still design only | ASI09 | rung 6 |
| R8 | ~~No password-reset flow~~ | A07 | **CLOSED 2026-09-30** -- now G36 |
| R9 | ~~No anomaly detection~~ (rates closed 2026-09-30, G38); detection still runs on the sentinel's tick, not on each event, and learns rates only | DE | later |
| R10 | ~~Containment actions without a real owner~~ | RS | **CLOSED 2026-09-29** -- all six are performed for real (G13, G30, G31, G32, G33) |
| R11 | Three other planes still splice paths into shell strings: graphics `stzScene`/`stzCanvas` (open in viewer), math `stzMathClaim` (mkdir), extercode `stzImageToAscii`. The safe forms exist since 2026-10-05 (G42): each call site is a one-line swap to `StzOpenInDefaultApp` or `StzMakeDir` | A05 | routed to those planes, with the swap |
| R12 | No scheduled or coverage-guided fuzzing; no CI; unsigned commits | A03, GV | **deferred by the author** for the development phase -- remind before the first release |
| R13 | ~~No reporting runbook for the CRA's 24 h / 72 h clocks~~ (closed 2026-09-30: `SOFTANZA_CRA_RUNBOOK.md`); a second named owner of the clocks, and counsel on the coordinator CSIRT, remain before the first EU sale | RS, GV | before any EU sale of RINGBOL |
| R14 | POSIX code paths (trust bundles, argv quoting, chmod) are compiled only under a Linux target and unverified here | A02, A05 | when a Linux machine is available |
| R15 | ~~SQLite is at 3.49.1, behind the 3.50 line~~ | A03 | **CLOSED 2026-09-30** -- 3.53.4, SHA3-256 checked against sqlite.org; its record is kept by G25 |

---

## 5. What moved since the compass

The compass (2026-09-28) rated the readiness axis 1 Strong, 0 Solid,
1 Partial, 6 Emerging. Its five confirmed defects are closed (G07, G09,
G10, G04 with G03, G23); the durable log, provenance, the account lock and
the measured drill (G17, G24, G13, G22) close four of its "what is open"
cells; `SECURITY.md`, the SBOM and the vendor moves close three readiness
rows. The ratings themselves belong to the next compass pass -- a plane
does not grade its own work.

## 6. Keeping this honest

- Add a guarantee only together with its guard. The meta-guard fails if a
  guard named in section 3 does not exist.
- When a risk in section 4 closes, move it to section 3 with its guard --
  never delete it.
- Re-run the security gate (`python libraries/stzlib/engine/tools/security_gate.py`)
  before changing a count here.
