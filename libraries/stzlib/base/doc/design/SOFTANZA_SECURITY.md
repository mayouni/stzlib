# Softanza Security
### Security as one governed vocabulary — with a home in `base/security/`

> Status: consolidated. `base/security/` homes the credential + crypto layer
> (`stzSecret` + kinds, `stzSecretStore`, `stzVaultResolver`, `stzAuth`,
> `stzCryptoFuncs`, `stzRequestSigner`, `stzSecurityPosture`). The broader surface
> (actors, sandbox, governance, agentic guardrails, transport) is mapped here.
> Guards: `secret_narrated` (53), `secretstore_narrated` (26), `vault_narrated`
> (15), `security_posture_narrated` (19).
> Tutorials: [guarding secrets & credentials](../narrations/stz-guarding-secrets-and-credentials-narration.md)
> (a single secret) and [governing a project's security](../narrations/stz-governing-project-security-narration.md)
> (the keyring, vault seam, sessions, posture).

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
| **Credentials, secrets, crypto** | **`base/security/`** ← consolidated | `stzSecret` (+ `stzApiKey`/`stzPassword`/`stzDeployKey`/`stzToken`), `stzSecretStore`, `stzVaultResolver`, `stzAuth`, `stzCryptoFuncs` (KDF helpers), `stzRequestSigner` (HMAC signing), `stzSecurityPosture` (runnable invariants) |
| Authority (the lattice) | `base/system/` | `stzSystemActor`, `stzSystemCapabilities` |
| Effect isolation (sandbox) | `base/system/` | `stzVirtualSystem` / `stzVirtualFileSystem` / `stzVirtualEnvironment` (rehearse → plan → commit, one bridge to reality) |
| Governance contract | `base/governance/` | `stzGovernance` (risk tiers, CAN vs SHOULD, lineage, decommission) |
| Agentic safety | `base/agentic/`, `base/meta/` | `stzAgentGraph` (lattice + 4 guardrails), `stzPIAgent`, `stzGovernanceChecks` |
| Crypto primitives | **`base/security/`** (KDF), `base/string/`, engine | `StzHashSecret`/`StzVerifySecret`/`StzRandomToken` (PBKDF2 + CSPRNG, now in `security/`), `stzStringCrypto` (SHA/MD5/HMAC, string-domain), engine `crypto.zig` |
| Transport security | **`base/security/`** (signing), `base/cluster/`, `base/reactive/` | `stzRequestSigner` (HMAC + replay window, now in `security/`), `stzComputeFederation` (mTLS), `stzReactor` (TLS/mTLS listener) |

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
| **Vault backends** | ✅ pluggable seam — `RevealVia(resolver, actor)` + `stzVaultResolver` reference; a specific manager's adapter is the only infra-gated piece. Env/file/literal live. |

## Roadmap — consolidating the rest

1. ~~Route governed reveals through the store's audit~~ — **done.** A site
   references a store secret by *name* (`SetAuthFromStoreQ(store, name)`) and holds
   no key and no store object; the reveal goes through the shared store, passed by
   reference at reveal time (`ResolveAuthVia(store, actor)`), so the store's gate
   applies *and* it audits the access — the project's one trail stays complete.
   (Ring copies objects on `=`, so a *held* store would be a private copy whose
   audit no one sees; passing it by reference at reveal time is the correct shape.
   Plain `ResolveAuth` on a store-backed site raises, to force the audited path.)
2. ~~Move the crypto helpers + request signer into `base/security/`~~ — **done.**
   `StzHashSecret`/`StzHashSecretXT`/`StzVerifySecret`/`StzVerifySecretXT`/
   `StzRandomToken` extracted from `platform/` into `security/stzCryptoFuncs.ring`;
   `stzRequestSigner` moved from `common/` into `security/`. Loaded in the security
   block (the helpers *before* `stzSecret`/`stzAuth`, fixing a latent use-before-
   define — they were previously defined late in `stzPlatform` and resolved only at
   runtime). Verified: platform KDF (14), request-signing (29), platform (31), all
   security + delivery guards.
3. ~~A security posture check~~ — **done.** `stzSecurityPosture` runs invariants
   over a project's security surface (its store + sites + actors) and returns
   findings shaped exactly like `stzGovernanceChecks`
   (`[ :invariant, :severity, :where, :message ]`): **no-sandboxed-effectful**
   (ERROR — an actor sandboxed yet holding `effectful`), **inline-key** (WARN — a
   site holding a secret outside the store, so uncaudited), **no-central-store**
   (WARN — secret-bearing sites but no store), **refused-accesses** (WARN — the
   store logged refused reveals). `IsSound()` = no errors; `Report()` prints;
   CI entry points `StzCheckSecurityPosture` / `StzSecurityPostureIsSound` /
   `StzSecurityInvariantNames` mirror `StzCheckAgentGraph`. Guard
   `security_posture_narrated` (19).
4. **`stzAuth` sessions as `stzToken`s** — **done.** `Login` now issues a session
   that IS a `stzToken` (a bearer credential carrying its expiry). Sessions
   **expire** on the wall clock (`SetSessionTTL(seconds)`, `SetSessionTTLQ` to chain; default 3600; `0` = no
   expiry); `UserOfSession`/`IsValidSession` check expiry, with deterministic
   `…At(token, nowSecs)` variants, plus `SessionToken`/`SessionExpiresAt`/
   `PurgeExpired`. Guard `secret_narrated` (+6, now 53). *Remaining:* password
   reset flowing through the store.
5. **Vault seam** — **done (the pluggable seam).** A `:vault`-sourced secret is
   fetched through a *resolver* passed by reference at reveal time:
   `secret.RevealVia(resolver, actor)` (gated) and `store.RevealVia(name, resolver,
   actor)` (gated + audited). The contract is duck-typed — any object with
   `Resolve(locator)` is a resolver — so Softanza binds to no backend. `stzVaultResolver`
   is the in-memory reference (dev/test); production supplies a client for
   HashiCorp Vault / AWS Secrets Manager / a KMS. Guard `vault_narrated` (15).
   *Remaining (infra-gated):* a shipped adapter for a specific manager.

---

*Security in Softanza is not a wall around the program; it is a property of how the program is expressed. One vocabulary — four capability kinds, three postures — decides, everywhere, who may cause which effect. `base/security/` gives the things you protect a home; the rest of the library already speaks the language.*
