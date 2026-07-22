# Softanza Secrets & Credentials
### Confidential data that hides itself, resolves lazily, and reveals only under governance

> Status: built. Components: `stzSecret` (+ `stzApiKey` / `stzPassword` /
> `stzDeployKey` / `stzToken`), wired into `stzDeploymentSite`; `stzAuth` (stzApp
> domain). Guard: `secret_narrated` (47/47).
> Part of the [Delivery Plane](SOFTANZA_DELIVERY_PLANE.md); stands on the
> [System Foundation](../narrations/stz-system-dev-to-deploy-narration.md)'s
> governance crossing (`stzSystemActor`).

---

## The problem

A deployment's hardest friction is not the code — it's the **key**. The SSH key that
reaches the server, the API token the backend calls with, the password behind the
database. In most stacks these leak by default: pasted into a YAML, committed to a
repo, printed in a log line, echoed into a crash dump, and — increasingly — handed
wholesale to an automated agent that "just needs it to deploy."

The industry's answer is a pile of external tools (a vault, a secrets manager, a
`.env` file everyone agrees not to commit). None of them is *in the program*. The
value crosses back into your code as a bare string the moment you actually use it,
and from there it can go anywhere.

## The thesis

A secret is not a string. It is a **governed value** with three properties baked in:

1. **It redacts itself — everywhere.** Its `Descriptor()`, its `Show()`, and any
   config it lands in render `<secret 'deploy-key' (deploykey) from env:DEPLOY_KEY>`
   — the *pointer* to where the value lives, never the value. There is no code path
   that accidentally prints it, because the object's own string form is the redaction.

2. **It resolves lazily, from a source.** The value is never *in* the secret; the
   secret knows *where the value is* — a literal (dev only), an environment variable,
   a file, a vault (reserved). Resolution happens at the moment of use, not at
   definition.

3. **Its reveal is governed.** `Reveal(actor)` returns the plaintext **only** to an
   *effectful, non-sandboxed* actor. This is the exact crossing the delivery plane
   already enforces: **expression is free, admission is governed.** An `LLMActor`
   holds only `inference`; `IsEffectful()` is false; so an LLM can *reference* a
   secret in a whole deployment it rehearses — and `Reveal()` **raises** for it. The
   agent designs the rollout; it never sees the key.

```ring
oKey = new stzSecret("deploy-key")
oKey.FromEnvQ("DEPLOY_KEY")            # the value lives in an env var; the secret is a pointer

? oKey.Descriptor()                    # <secret 'deploy-key' (secret) from env:DEPLOY_KEY>
? oKey.Reveal(HumanActor("ops"))       # ssh-ed25519-AAAA...   (an effectful actor: allowed)
? oKey.Reveal(LLMActor("planner"))     # RAISES: an inference-only actor may not reveal a secret
```

## The components

| Object | Role |
|---|---|
| `stzSecret` | the base confidential value — redacts, resolves (`FromLiteralQ` / `FromEnvQ` / `FromFileQ` / `FromVaultQ`), and reveals only under governance (`Reveal(actor)`, `IsRevealableBy(actor)`) |
| `stzApiKey` | an API key — `AuthorizationHeader(actor)` → `"Bearer …"` |
| `stzPassword` | a password — `HashedBy(actor)` (salted PBKDF2) and `Matches(candidate, actor)` |
| `stzDeployKey` | a deploy / SSH private key — `KeyMaterial(actor)` for the backend to write to a private file |
| `stzToken` | a bearer / access token — carries an optional expiry (`IsExpiredAt(now)`) |
| `stzAuth` | the stzApp-domain counterpart for **people** — a credential store + sessions |

## The sources

A secret's value comes from exactly one **source**, set by a Q-fluent builder:

| Builder | Source | Resolves to |
|---|---|---|
| `FromLiteralQ(v)` | `literal` | the inline value — **dev/test only**; still redacted in output |
| `FromEnvQ(name)` | `env` | the environment variable `name` (engine-backed read) |
| `FromFileQ(path)` | `file` | the file's contents, trimmed |
| `FromVaultQ(ref)` | `vault` | reserved — raises until a vault backend is wired |

The **locator** (`SourceLocator()`) — the env var name, the file path — is *safe to
show*: it is a pointer, not the secret. Only the resolved value is confidential.

## Why this belongs in the delivery plane

The payoff is at the deployment site. A site's auth used to be a bare string:

```ring
oSite.SetAuthRefQ("env/DEPLOY_KEY")    # a plain reference (still supported)
```

Now it can *be* a secret — and the site never leaks it:

```ring
oKey = new stzDeployKey("prod-deploy")
oKey.FromEnvQ("DEPLOY_KEY")

oSite = new stzDeploymentSite("prod-api")
oSite.SetKindQ(:Server).SetEndpointQ("deploy@api:/srv/app").SetAuthRefQ(oKey)

? oSite.ConfigJson()          # the "auth" field is the DESCRIPTOR — the key is nowhere
oSite.ResolveAuth(oHuman)     # the live key — GATED on an effectful actor
oSite.ResolveAuth(oLLM)       # RAISES — the rehearsing agent cannot pull the key
```

`ConfigJson()` — the persistent link a site is saved and shared as — now serialises
the redacted descriptor. The key is resolved **only** at store/launch time, **only**
through `ResolveAuth(actor)`, **only** for an actor that may cause effects. The same
governance that decides whether a plan may commit decides whether its secrets may be
read. One vocabulary, one crossing.

`SetAuthRefQ` accepts a secret **or** a plain string, so every existing site config
keeps working unchanged.

## stzAuth — the people side

`stzSecret` guards **machine** credentials. `stzAuth` (in the stzApp domain) answers
the other question: *is this the user they claim to be?*

```ring
oAuth = new stzAuth()
oAuth.Register("mansour", "s3cr3t!")          # stores a salted hash, never the password
oAuth.Authenticate("mansour", "s3cr3t!")      # TRUE  (constant-time verify)
cTok = oAuth.Login("mansour", "s3cr3t!")      # an opaque 256-bit session token
oAuth.UserOfSession(cTok)                      # "mansour"
oAuth.Logout(cTok)
```

The store never holds a plaintext password: `Register` hashes with the engine's
PBKDF2 (`StzHashSecret`) and `Authenticate` verifies in constant time
(`StzVerifySecret`) — the same crypto `stzSecret` and `stzPlatform` use. Sessions are
random hex from `StzEngineCryptoRandomHex`.

## The crypto is the engine's

Nothing here rolls its own cryptography. Password hashing is PBKDF2 with a random
salt and 100 000 rounds; verification is constant-time; randomness is the engine's
CSPRNG — all reused from the platform layer, all backed by the same Zig engine that
powers the rest of Softanza.

## What's proven

`secret_narrated` (47/47) exercises the whole story: redaction (the value never
appears in `Descriptor`/`Show`/`ConfigJson`), the governed reveal (a `HumanActor`
reveals; an `LLMActor` is refused and `Reveal()` raises), all three live sources
(literal, env, file), the four specialisations, the deployment-site wiring with its
back-compat path, and the full `stzAuth` lifecycle. The four existing delivery-plane
guards are unchanged.

---

*A secret you can print is not a secret. Here the value has no plaintext form in your
program until an actor entitled to cause effects asks for it — and the one actor we
most want to keep keys away from, the automated planner, is exactly the one the type
system refuses.*
