# Guarding Secrets & Credentials
### How Softanza holds a key without ever letting your program see it in the clear

When you [deployed to the target sites](stz-deploying-to-target-sites-narration.md),
one line carried a promise we hadn't yet kept:

```ring
oProdApi.SetAuthRefQ("env/DEPLOY_KEY")
```

We said this was *a reference, not a key* — a pointer the config could carry safely,
with the real credential resolved "only at the moment of transfer." This narration
makes that real. It introduces `stzSecret` — a value that hides itself, resolves
lazily, and reveals its plaintext **only** to an actor entitled to cause effects.
Every code block is real, and every output block is its actual output.

---

## A secret is a pointer, not a value

You don't put a key into a `stzSecret`. You tell the secret *where the key lives*:

```ring
oKey = new stzSecret("deploy-key")
oKey.FromEnvQ("DEPLOY_KEY")     # the value lives in an environment variable

? oKey.Descriptor()
```

```
<secret 'deploy-key' (secret) from env:DEPLOY_KEY>
```

That descriptor is the secret's **only** public face. It names the secret and points
at its source — `env:DEPLOY_KEY` — but the value is nowhere in it. This is deliberate:
the object's own string form *is* the redaction, so there is no code path — no log
line, no dump, no `Show()` — that can print the key by accident. Even a literal
secret (`FromLiteralQ`, for dev) reads `from literal`, never the value; the inline
marker lives only in `SourceLocator()`.

The sources are a small, honest set:

| Builder | The value comes from |
|---|---|
| `FromLiteralQ(v)` | an inline value — **dev/test only** |
| `FromEnvQ(name)` | the environment variable `name` |
| `FromFileQ(path)` | the file at `path`, trimmed |
| `FromVaultQ(ref)` | a vault (reserved — raises until wired) |

## Revealing is governed — and that is the whole point

To get the plaintext you must ask, and *who asks* decides the answer. The gate is the
same one the delivery plane uses to decide whether a plan may commit:
**an actor may reveal a secret only if it can cause effects.**

```ring
oHuman = HumanActor("ops")       # effectful, trusted
oLLM   = LLMActor("planner")     # inference-only, sandboxed

? oKey.Reveal(oHuman)            # allowed
```

```
ssh-ed25519-AAAAC3NzaC1lZDI1
```

```ring
? oKey.Reveal(oLLM)              # refused
```

```
Refused: actor 'planner' (posture sandboxed) may not reveal secret
'deploy-key'. Only an effectful, non-sandboxed actor can read a secret.
```

Read that second block again, because it is the thesis. An `LLMActor` holds only the
`inference` capability — `IsEffectful()` is false. So an automated planner can
*reference* this secret in an entire deployment it designs and rehearses, and the
moment it tries to pull the actual key, the type system refuses. **Expression is
free; admission is governed** — extended from "which actor may commit a plan" to
"which actor may read a key." The agent you most want to keep credentials away from
is exactly the one the model refuses.

## The specialisations name what the credential *is*

A bare secret is fine, but most credentials have a shape and a use. Softanza ships
four specialisations, each adding the one presentation its kind needs:

```ring
oApi = new stzApiKey("stripe")
oApi.FromLiteralQ("sk_live_abc")
? oApi.AuthorizationHeader(oHuman)          # Bearer sk_live_abc

oPw = new stzPassword("db")
oPw.FromLiteralQ("hunter2")
? oPw.Matches("hunter2", oHuman)            # 1
? oPw.HashedBy(oHuman)                      # a salted PBKDF2 hash (salt:hash), never the plaintext

oTok = new stzToken("session")
oTok.FromLiteralQ("t0k").SetExpiryQ(1000)
? oTok.IsExpiredAt(1500)                    # 1  (you pass the clock; the token holds none)
```

`stzApiKey` presents as a bearer header; `stzPassword` hashes and matches (with the
engine's PBKDF2, so the hash is safe to store); `stzDeployKey` yields key material for
a backend to write to a private file; `stzToken` carries an optional expiry. Each is a
`stzSecret`, so each redacts and reveals under the same governance.

## The payoff: a site that cannot leak its key

Now the promise from the deployment narration comes due. A site's auth can *be* a
secret — and the config the site serialises stays clean:

```ring
oKey = new stzDeployKey("prod-deploy")
oKey.FromEnvQ("DEPLOY_KEY")

oSite = new stzDeploymentSite("prod-api")
oSite.SetKindQ(:Server)
oSite.SetEndpointQ("deploy@api.restolean.app:/srv/restolean")
oSite.SetProtocolQ(:ssh)
oSite.SetAuthRefQ(oKey)                     # a secret, not a string
oSite.SetStoreAtQ("/srv/restolean/api")

? oSite.ConfigJson()
```

```
{
  "name": "prod-api",
  "kind": "server",
  "connection": { "endpoint": "deploy@api.restolean.app:/srv/restolean", "protocol": "ssh", "auth": "<secret 'prod-deploy' (deploykey) from env:DEPLOY_KEY>" },
  "storage": "/srv/restolean/api",
  "control": { "launch": "", "status": "" }
}
```

The `auth` field is the **descriptor**. This is the file you commit, version, and
share to describe how the site is reached — and the key is simply not in it. When a
backend actually needs to transfer, it calls one governed method:

```ring
oSite.ResolveAuth(oHuman)     # "ssh-ed25519-AAAAC3NzaC1lZDI1"  -- the live key, for an effectful actor
oSite.ResolveAuth(oLLM)       # RAISES -- the rehearsing agent cannot pull the key
```

The key is resolved **only** at store/launch time, **only** through
`ResolveAuth(actor)`, **only** for an actor that may cause effects. And because
`SetAuthRefQ` still accepts a plain string, every site config you already wrote keeps
working — the plain `"env/DEPLOY_KEY"` reference is simply an un-typed secret.

## The other side of the door: authenticating people

`stzSecret` guards the credentials your *program* holds. The people *using* an app
raise a different question — *are you who you say you are?* — answered by `stzAuth`,
in the stzApp domain:

```ring
oAuth = new stzAuth()
oAuth.Register("mansour", "s3cr3t!")        # stores a salted hash, never the password

? oAuth.Authenticate("mansour", "s3cr3t!")  # 1
cTok = oAuth.Login("mansour", "s3cr3t!")    # an opaque 256-bit session token
? oAuth.UserOfSession(cTok)                 # mansour
oAuth.Logout(cTok)
```

`Register` hashes with the engine's PBKDF2; `Authenticate` verifies in constant time;
sessions are random hex from the engine's CSPRNG. The store never holds a plaintext
password, and no method prints a hash. It is the same crypto `stzSecret` uses — one
engine, one story, two sides of the same door.

---

*The industry keeps secrets out of code by keeping them in another tool. Softanza
keeps them in the program — as a value with no plaintext form until an actor entitled
to cause effects asks for it. The key is present enough to deploy with, and absent
enough that nothing, and no one un-entitled, can read it.*

Runnable guard: `libraries/stzlib/base/test/system/secret_narrated.ring` (47/47).
Design: [SOFTANZA_SECRETS.md](../design/SOFTANZA_SECRETS.md).
