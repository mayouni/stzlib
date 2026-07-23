# Governing a Project's Security
### The central keyring, the vault seam, expiring sessions, and a posture you can run

The [secrets narration](stz-guarding-secrets-and-credentials-narration.md) showed a
single `stzSecret` — a value that redacts itself and reveals only to an effectful
actor. A real project has *many* secrets, several sites, and more than one actor,
and the risk isn't one leaked key — it's the scatter: keys created at call sites,
passed around, impossible to enumerate or audit. This narration walks the rest of
`base/security/` — the machinery that governs the whole surface. Every code block is
real, and every output block is its actual output.

---

## One place for every secret — the keyring

A `stzSecretStore` is a project's single registry. You register a secret once; from
then on the whole credential surface is enumerable and self-redacting.

```ring
oStore = new stzSecretStore("restolean")

oKey = new stzDeployKey("deploy-key")
oKey.FromLiteralQ("ssh-ed25519-AAAAlive")
oStore.Register(oKey)

oApi = new stzApiKey("stripe")
oApi.FromEnvQ("STRIPE_KEY")
oStore.Register(oApi)

? oStore.Names()
```

```
[ "deploy-key", "stripe" ]
```

Reveal is the **one governed door** — the same effectful-actor gate a `stzSecret`
enforces, and every attempt is *audited*:

```ring
? oStore.Reveal("deploy-key", HumanActor("ops"))     # allowed
oStore.Reveal("deploy-key", LLMActor("planner"))     # refused (raises)
```

```
ssh-ed25519-AAAAlive
```

The refusal isn't a silent failure — it's an event. `Show()` summarises the store,
and the access log names who read (or was refused) what:

```ring
oStore.Show()
```

```
Secret store 'restolean': 2 secret(s), 2 access(es), 1 refused
  <secret 'deploy-key' (deploykey) from literal>
  <secret 'stripe' (apikey) from env:STRIPE_KEY>
```

```
#1 ops     -> deploy-key [granted]
#2 planner -> deploy-key [refused]
```

The value never appears — only the redacted descriptor. `RotateQ(newSecret)`
replaces a key under its name; `Revoke(name)` removes it. One place, one gate, one
record.

## A site reveals *through* the store — so the audit is complete

A deployment site can hold a secret inline, but then its reveals bypass the store's
log. Instead, reference the secret **by name** from the store:

```ring
oSite = new stzDeploymentSite("prod-api")
oSite.SetKindQ(:Server).SetAuthFromStoreQ(oStore, "deploy-key")

oSite.ResolveAuthVia(oStore, HumanActor("ops"))   # the live key -- gated AND audited by the store
oSite.ResolveAuth(HumanActor("ops"))              # RAISES -- directs you to ResolveAuthVia
```

The site holds *no key and no store object* — only the name. The reveal passes the
shared store by reference at the moment of use, so the store's gate applies and the
access lands in the *same* audit trail as every other reveal. (Why by-reference and
not held? Ring copies objects on assignment; a held store would be a private copy
whose log no one sees — so `ResolveAuth` on a store-backed site refuses, forcing the
audited path.)

## The vault seam — bind to no backend

`FromLiteralQ` / `FromEnvQ` / `FromFileQ` cover secrets that live locally. For a real
secret manager (HashiCorp Vault, AWS Secrets Manager, a KMS), a `:vault` secret is
fetched through a **resolver** you supply:

```ring
oVault = new stzVaultResolver("dev")                        # dev/test reference impl
oVault.Register("secret/prod/db#password", "hunter2-from-vault")

oKey = new stzSecret("db")
oKey.FromVaultQ("secret/prod/db#password")

? oKey.Descriptor()
? oKey.RevealVia(oVault, HumanActor("ops"))                # gated, then fetched via the vault
oKey.RevealVia(oVault, LLMActor("planner"))                # REFUSED before it ever reaches the vault
```

```
<secret 'db' (secret) from vault:secret/prod/db#password>
hunter2-from-vault
```

The contract is duck-typed: **any object with `Resolve(locator)`** is a valid
resolver. `stzVaultResolver` is the in-memory reference; in production you swap it
for a client that calls your real vault — the secret, the store, and the actor gate
never change. The descriptor shows the *locator*, never the value; the gate runs
*before* the fetch, so an unauthorized actor never touches the backend.

## Sessions that expire — auth as a bearer token

`stzAuth` authenticates people. A session is now a first-class `stzToken` — a bearer
credential that carries its own expiry, so it dies on the clock:

```ring
oAuth = new stzAuth()
oAuth.Register("mansour", "pw")             # stores a salted hash, never the password
oAuth.SetSessionTTLQ(3600)                  # sessions live one hour (0 = never)

cTok = oAuth.Login("mansour", "pw")
nExp = oAuth.SessionExpiresAt(cTok)

? "the session is a " + oAuth.SessionToken(cTok).Kind()
? "valid before expiry: " + oAuth.IsValidSessionAt(cTok, nExp - 1) +
  " | after: " + oAuth.IsValidSessionAt(cTok, nExp + 1)
```

```
the session is a token
valid before expiry: 1 | after: 0
```

`UserOfSession` / `IsValidSession` check the wall clock; the `…At(token, now)`
variants make expiry deterministic for tests; `PurgeExpired` drops dead sessions.
Passwords are PBKDF2-hashed and verified in constant time — the same engine crypto
the rest of the module uses.

## The doctrine, made runnable — a security posture

All of the above is a *policy*: secrets in the store, no inline keys, no sandboxed
actor holding an effect. `stzSecurityPosture` turns that policy into a **check** —
like `stzGovernanceChecks` runs invariants over an agent graph, this runs them over
a project's security surface and reports findings CI can gate on:

```ring
oInline = new stzDeploymentSite("legacy")
oInline.SetKindQ(:Server).SetAuthRefQ(oKey)               # an inline key, not in the store
oRogue = SystemActor("rogue", [ "effectful", "inference" ])
oRogue.SetPosture("sandboxed")                            # sandboxed YET effectful

oP = new stzSecurityPosture("restolean")
oP.SetStore(oStore).AddSite(oInline).AddActor(oRogue)
oP.Report()
```

```
Security posture of 'restolean': 1 error(s), 2 warning(s)  -> UNSOUND (errors present)
  [ERROR] no-sandboxed-effectful @ rogue -- actor 'rogue' is sandboxed yet holds 'effectful' -- a sandboxed/LLM actor must never be able to commit
  [WARN] inline-key @ legacy -- site 'legacy' holds an inline secret (...) not registered in the central store -- its reveals are not centrally audited; prefer SetAuthFromStoreQ(store, name)
  [WARN] refused-accesses @ restolean -- the central store logged 1 refused reveal(s) -- an actor tried to read a secret it may not; review the access log
```

`IsSound()` is false when there's an ERROR; warnings advise. The findings are shaped
exactly like the agent-graph guardrails (`[ :invariant, :severity, :where,
:message ]`), and CI entry points `StzCheckSecurityPosture` /
`StzSecurityPostureIsSound` mirror `StzCheckAgentGraph`. The **error** here is the
load-bearing one: an actor that is sandboxed yet effectful — an LLM that could
commit. It's exactly what the whole module exists to prevent, now caught by a
line of runnable policy.

---

*A single secret hides itself. A project needs more: one registry, one audit trail,
one gate — extended to sites, to vaults, to sessions — and a check that fails the
build when any of it slips. That is `base/security/`.*

Runnable guards: `secretstore_narrated` (26), `vault_narrated` (15),
`security_posture_narrated` (19), `secret_narrated` (53).
Design: [SOFTANZA_SECURITY.md](../design/SOFTANZA_SECURITY.md).
