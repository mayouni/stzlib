# Softanza Security
### Security as one governed vocabulary — with a home in `base/security/`

> Status: reflection + first consolidation. `base/security/` now homes the
> credential layer (`stzSecret` + kinds, `stzSecretStore`, `stzAuth`). The
> broader security surface (actors, sandbox, governance, agentic guardrails,
> crypto, transport) is mapped here with a roadmap for what consolidates next.
> Guards: `secret_narrated` (47), `secretstore_narrated` (19).

---

## The thesis

Softanza does not bolt security on as a feature. It treats security as **governance** — one principle running through the whole library:

> **Expression is free; admission is governed.** Anyone (any actor, human or agent) may *compose*, *rehearse*, and *propose* anything. Only an actor entitled to cause effects may *commit* — touch a file, launch a deploy, read a key.

That principle is carried by **one vocabulary**, shared verbatim across the system, the agent graph, governance, and secrets:

- **A capability lattice** — `effectful · sensing · compute · inference`. Every operation is coloured with the kind it requires; every actor holds a set of the kinds it may exercise.
- **Three trust postures** — `trusted · external · sandboxed`.

The strength of the model is that these are the *same* four kinds and *same* three postures whether you are gating a file write, a production deploy, or the reveal of an API key. Security is not N mechanisms; it is one mechanism applied N places.

## The load-bearing rule (why agents cannot hurt you)

The factory actors (`stzSystemActor`) encode the doctrine directly:

| Actor | Capability kinds | Posture |
|---|---|---|
| `HumanActor`, `PIActor` | effectful, compute, sensing | trusted |
| `GuardianActor` | compute, sensing | external |
| **`LLMActor`** | **inference only** | **sandboxed** |
| `ToolActor` | compute | external |

An `LLMActor`'s **effect set is empty**. `IsEffectful()` is false. So an LLM (or any agent driven by one) can design a whole rollout, rehearse a hundred file changes, and reference every secret in a plan — and **commit none of it, and read none of the keys**. This is enforced, not advised, at six checkpoints today:

- **File/system commit** — `stzUpdatePlan.Execute()` refuses any operation whose required kind the executor lacks (`base/system/stzVirtualSystem.ring`).
- **Secret reveal** — `stzSecret.IsRevealableBy(actor)` = `actor.IsEffectful() and posture != sandboxed`; `Reveal()` raises otherwise (`base/security/stzSecret.ring`).
- **Central secret store** — `stzSecretStore.Reveal(name, actor)` applies the same gate and *audits* the attempt (`base/security/stzSecretStore.ring`).
- **Deployment** — `stzDeployment.ResolveAuth(actor)` and `MayCommit()` (`base/system/stzDeployment.ring`).
- **Platform deploy** — `stzPlatform._DeployWith` refuses a non-effectful actor.
- **Agentic guardrail** — `StzCheckNoLLMEffectful` flags, as an *error*, any agent-graph node that is both `llm_actor` and `effectful` (`base/meta/stzGovernanceChecks.ring`).

The companion narrative doc is *"Softanza and Agents That Cannot Hurt You."* This is Softanza's answer to **agentic-development security**: the same gate that keeps a compromised script from touching production keeps an autonomous coding agent from doing so — because "autonomous agent" is spelled `LLMActor`, and its effect set is empty.

## The security surface (what exists, and where it lives)

Security is *conceptually* unified but was *physically* scattered across nine directories. The map:

| Concern | Where | Key classes |
|---|---|---|
| **Credentials & secrets** | **`base/security/`** ← consolidated | `stzSecret` (+ `stzApiKey`/`stzPassword`/`stzDeployKey`/`stzToken`), `stzSecretStore`, `stzAuth` |
| Authority (the lattice) | `base/system/` | `stzSystemActor`, `stzSystemCapabilities` |
| Effect isolation (sandbox) | `base/system/` | `stzVirtualSystem` / `stzVirtualFileSystem` / `stzVirtualEnvironment` (rehearse → plan → commit, one bridge to reality) |
| Governance contract | `base/governance/` | `stzGovernance` (risk tiers, CAN vs SHOULD, lineage, decommission) |
| Agentic safety | `base/agentic/`, `base/meta/` | `stzAgentGraph` (lattice + 4 guardrails), `stzPIAgent`, `stzGovernanceChecks` |
| Crypto primitives | `base/platform/`, `base/string/`, engine | `StzHashSecret`/`StzVerifySecret`/`StzRandomToken` (PBKDF2 + CSPRNG), `stzStringCrypto` (SHA/MD5/HMAC), engine `crypto.zig` |
| Transport security | `base/common/`, `base/cluster/`, `base/reactive/` | `stzRequestSigner` (HMAC + replay window), `stzComputeFederation` (mTLS), `stzReactor` (TLS/mTLS listener) |

**Design decision — what moves to `base/security/`, and what does not.** `base/security/` owns the concern whose *primary identity* is security and that was otherwise homeless: **the things you protect (secrets, credentials) and the acts of authentication and secret-governance**. It deliberately does **not** absorb the actor lattice, the sandbox, the governance contract, or the agentic guardrails — those are the security *expression of their own domains* (the actor is the system's authority; the guardrails are the agent graph's soundness), and they already speak the shared vocabulary. Consolidation means *one home for the credential layer + one map of the whole*, not one directory swallowing every domain's governance.

## The central secrets governance — `stzSecretStore`

The gap the store closes: a `stzSecret` is a governed *value*, but without a registry, secrets are **scattered inline objects** — created at a call site, passed around, impossible to enumerate or audit. A project (an app or a platform) needs **one place** to see and govern them.

`stzSecretStore` is that place:

- **Register once, enumerate always** — `Register(secret)`; `Names()` lists the project's whole credential surface (safe — every entry self-redacts).
- **One governed door** — `Reveal(name, actor)` applies the effectful-actor gate *and records the access*. A value never leaves the store any other way, so the log is complete.
- **Misuse is visible** — `AccessLog()` records who read (or was refused) which secret, in order; `RefusedAccesses()` is a signal to watch. A refusal is an event, not a silent failure.
- **Lifecycle** — `RotateQ(newSecret)` replaces a key under its name; `Revoke(name)` removes it.

So a deployment site references a secret **by the store** (`site.SetAuthRefQ(store.Secret("deploy-key"))`) rather than embedding a key, its config serialises only the redacted descriptor, and one audit trail covers the whole project.

## What modern software development requires — and where Softanza stands

| Requirement | Softanza today |
|---|---|
| **Secrets never in code / logs / config** | ✅ `stzSecret` self-redacts everywhere; resolves lazily from env/file/vault; `stzSecretStore` centralises + audits. |
| **Least privilege** | ✅ the capability lattice — an actor exercises only the kinds it holds. |
| **Auditability** | ✅ store access log; `stzUpdatePlan` audit trail; `stzGovernance` decision lineage. |
| **Strong crypto, not hand-rolled** | ✅ engine PBKDF2 (100k) + CSPRNG + constant-time compare; HMAC; mTLS via mbedTLS. |
| **Supply-chain / release safety** | ✅ the governed deploy crossing (only effectful actors commit; LLM proposes). |
| **Agentic-development safety** | ✅ the empty-effect rule + six enforced checkpoints + agent-graph guardrails. |
| **Rotation / revocation** | ◐ store-level (`RotateQ`/`Revoke`); no scheduled rotation yet. |
| **Vault backends** | ◐ `FromVaultQ` reserved; env/file/literal live. |

## Roadmap — consolidating the rest

1. **Route governed reveals through the store's audit end-to-end** — a deployment site that references a store secret should reveal *via* the store (so store audit is complete), not by holding the object. Add `SetAuthFromStoreQ(store, name)`.
2. **Move the crypto helpers + request signer into `base/security/`** — `StzHashSecret`/`StzVerifySecret`/`StzRandomToken` (today in `platform/`) and `stzRequestSigner` (today in `common/`) are pure security primitives; they belong here. A careful load-order pass (they are runtime-resolved globals) makes this low-risk.
3. **A security posture check** — a runnable `stzGovernanceChecks`-style invariant that scans a project: are all secrets registered in a store? any inline keys? any `llm_actor` holding an effect kind? — reported like the existing agent-graph guardrails.
4. **`stzAuth` ↔ `stzSecret`** — session tokens as `stzToken`s; password reset flows through the store.
5. **Vault backend** — wire `FromVaultQ` to a real secret manager.

---

*Security in Softanza is not a wall around the program; it is a property of how the program is expressed. One vocabulary — four capability kinds, three postures — decides, everywhere, who may cause which effect. `base/security/` gives the things you protect a home; the rest of the library already speaks the language.*
