# The Front Door
### How Softanza's authentication became industrial — and why it ends up governed, not bolted on

Softanza's `stzAuth` began as a small, correct thing: a username, a PBKDF2 hash,
an opaque session token. Nothing wrong with it. Also nothing an application in
production could stand on — no persistence, no second factor, no passwordless, no
brute-force defense, no per-device control, and no connection whatsoever between
*who you are* and *what you may do*.

This narration walks how that changed, and what the changes taught. Every code
block below is real, and every output block is its actual output.

The short version: authentication in Softanza is not a login widget. It is the
**front door to the governance model**. A login does not merely set a flag — it
produces the **actor** the whole library already reasons about.

---

## What Better Auth actually taught

The work started by reading [better-auth](https://github.com/better-auth/better-auth),
a TypeScript framework that calls auth "a half-solved problem." The temptation
with any such survey is to copy the feature list. That would have been the wrong
lesson. Its plugin catalogue is long, but three *architectural* decisions carry
it:

1. a small core with **adapter-based persistence** — the core knows nothing about
   your database;
2. a **plugin model**, so methods attach rather than accrete in the core;
3. **authn and authz in one place**.

Softanza already owned the first two patterns under different names — the vault
resolver's duck-typed seam, and the port/attach shape the graph-rules work had
just established. And on the third it was *ahead*: the capability lattice,
`stzGovernance`, the org chart, separation-of-duties rules. All of it existed. None
of it was connected to `stzAuth`'s users.

So the plan was mostly **wiring what was already there**, plus real hardening.
Six phases, then external identity.

---

## A login yields an actor

This is the payoff, so it goes first. A user carries **roles**; each role is a
capability bundle over the lattice — `effectful` / `sensing` / `compute` /
`inference` — at a trust posture.

```ring
a = new stzAuth()
a.Register("dana", "pw")
a.GrantRole("dana", "admin")
tok = a.LoginAt("dana", "pw", NOW)

act = a.ActorOfAt(tok, NOW)
? "user        : " + act.Name()
? "capabilities: " + @@(act.Kinds())
? "posture     : " + act.Posture()
? "effectful   : " + a.SessionIsEffectfulAt(tok, NOW)
```

```
user        : dana
capabilities: [ "effectful", "compute", "sensing" ]
posture     : trusted
effectful   : 1
```

That object is not an auth-specific invention. It is a `stzSystemActor` — the same
subject `stzGovernance` gates decisions for, the same one the security graph walks
for privilege escalation. `SessionPerson(token)` returns the **same string** the
governance actor and the org-chart person key on, so
`SessionMayProceed(session, action, governance)` gates the *existing* engine, and
dropping that identity into an org chart lets the *existing* separation-of-duties
rules reason about a signed-in user with no glue at all.

`stzAuth` does not reimplement authorization. It produces the subject.

### The property that makes this worth it

Give an account the `assistant` role — an LLM-backed identity — and watch what
comes out:

```ring
a.Register("bot", "pw")
a.GrantRole("bot", "assistant")
bt = a.LoginAt("bot", "pw", NOW)

? "authenticated : " + a.IsValidSessionAt(bt, NOW)
? "capabilities  : " + @@(a.ActorOfAt(bt, NOW).Kinds())
? "effectful     : " + a.SessionIsEffectfulAt(bt, NOW)
```

```
authenticated : 1
capabilities  : [ "inference" ]
effectful     : 0
```

Genuinely authenticated. Holding a real session. **Structurally incapable of
causing an effect** — not by policy, by capability set. That is the library's
agentic-safety invariant (*an LLM actor's effect set is empty*) extended to
identity itself. A bot can hold an account without holding the ability to act.

A user with *no* roles comes out the same way: authenticated, permitted nothing.
Least privilege is the default, not a configuration.

---

## The hardening nobody demos

Three of the six phases were unglamorous and mattered most.

**Timing.** `Authenticate` used to return `FALSE` immediately for an unknown user
but run a full PBKDF2 verify for a known one. That difference is a *username
oracle*: an attacker learns who is registered by timing the failures. The fix is
four lines — verify the unknown user against a dummy hash so both paths cost the
same work. Measured afterwards at 0.97×.

**Lockout.** A login endpoint that answers forever is a password-guessing service.
Per-username failure counting with a lockout window, and — deliberately — a
*locked* account refuses even the **correct** password, and `Login` returns `""`
for a wrong password and a lockout alike. Indistinguishable, so the refusal leaks
nothing either.

**Sessions.** A session grew from `[user, expires]` into a record with
`created`, `ip`, `user-agent` and `lastseen`. That is what makes a "your devices"
list possible, `RevokeSession` (this device) distinct from `RevokeAllSessions`
(everywhere), and an optional idle timeout that slides on use. Plus
`RotateSession` — a new token on any privilege change, so a pre-elevation token
cannot be replayed. Session fixation, closed.

---

## The second factor, and a port that sends nothing

TOTP was the first *pluggable method*, and it went where such things belong: the
engine. RFC 6238 is HMAC over a time counter, so the whole computation — HMAC,
RFC 4226 truncation — stays engine-side, with a hex key in and decimal digits out.
No raw key ever crosses the Ring↔engine boundary, which validates UTF-8 and would
mangle it.

Enrollment is two steps on purpose. `EnableTotp` issues a secret that is stored
**unconfirmed** — nothing is enforced yet, so a mis-scanned QR code cannot lock
anyone out. `ConfirmTotp` proves the app is in sync, enforces the factor, and
hands back one-time recovery codes:

```ring
a.Register("erin", "pw")
dev   = StzTotpFromSecretQ( a.EnableTotp("erin", "Softanza")[:secret] )
codes = a.ConfirmTotpAt("erin", dev.CodeAt(NOW), NOW)

? "recovery codes issued : " + len(codes)
? "plain password login  : [" + a.LoginAt("erin", "pw", NOW) + "]"
? "with the app code     : opens a session = " +
  (a.LoginTwoFactorAt("erin", "pw", dev.CodeAt(NOW), NOW) != "")
```

```
recovery codes issued : 10
plain password login  : []
with the app code     : opens a session = 1
```

Once confirmed, the password alone is simply not a door any more.

**Passwordless** needed something new: a way to *send*. That opened
`base/service/` and the service-virtualization plane's first port — a mail port,
one method wide. In development you bind a sandbox that **captures** instead of
delivering, so a test can read the very link that would have gone out:

```ring
mail = new stzMailSandbox()
a.SetMailPort(mail)
a.RequestMagicLinkAt("dana", NOW)

? "captured messages : " + mail.Count()
? "body              : " + mail.LastBody()
```

```
captured messages : 1
body              : Click to sign in: softanza://magiclink?token=ac24b503af2df1188399a837775ca968991253ed10151a3a2b1481c2b6238f8e
This link expires in 15 minutes.
```

The emailed token is 256-bit and only its **sha256** is stored, so a stolen
database yields no usable link. And the flow is enumeration-safe — an unknown
address gets an identical answer and no mail:

```
unknown address   : same answer, nothing sent
  captured        : 0
```

At deploy you bind a real sender behind the same one-method contract. Same code.

---

## The primitive everything external waited on

Four things sat deferred behind one gap: OAuth/OIDC, SSO, passkeys, and being a
provider. All of them reduce to *"is this signature valid for this message under
this public key?"* — and the engine could not answer it.

So the engine grew **ES256** (ECDSA P-256) and **RS256** (RSASSA-PKCS1-v1_5)
verification. Two decisions shaped it.

Everything crosses as **base64url**. That is both the safe ASCII form for a
boundary that validates UTF-8 *and* precisely the JWS/JWKS wire format — so a
provider's `n`, `e`, `x`, `y` and its signature need no conversion on either side.

And it returns **1 / 0 / −1**: valid, invalid, *malformed*. A bad key is never
silently read as a failed signature, and never as a passing one.

For test vectors I did not hand-copy RFC values. I generated genuine **OpenSSL**
signatures — including the DER→raw `r‖s` conversion JWS needs for ES256 — so the
engine is checked against an independent signer, with a tampered payload caught
for each algorithm.

---

## Believing a token is mostly not cryptography

With verification in hand, OIDC login followed. The interesting discovery is that
the signature is the *easy* half. A valid signature only proves the provider
signed **something**. The claims decide it was signed **for us, recently, and in
answer to this login**.

```ring
idp = new stzOidcSandbox("https://idp.local", "my-app")
rp  = new stzOidcClient("https://idp.local", "my-app")
rp.SetJwks( idp.JwksJson() )

b = new stzAuth()
b.SetOidcClient(rp)
sess = b.LoginWithOidcAt( idp.IssueIdTokenAt("dana", "n-1", NOW), "n-1", NOW )
? "session for    : " + b.UserOfSessionAt(sess, NOW)
? "forged token   : [" + b.LoginWithOidcAt(idp.IssueForgedIdTokenAt("dana","n-1",NOW), "n-1", NOW) + "]"
? "  why          : " + b.OidcWhy()
? "replayed nonce : [" + b.LoginWithOidcAt(idp.IssueIdTokenAt("dana","n-A",NOW), "n-B", NOW) + "]"
? "  why          : " + b.OidcWhy()
```

```
session for    : dana@idp.local
forged token   : []
  why          : the signature does not verify against the provider's key
replayed nonce : []
  why          : nonce mismatch -- this token does not answer this login
```

Two things there are load-bearing. The verification algorithm comes from **our**
key, never from the token's own header — that is what defeats `alg:none` and
algorithm-confusion forgeries. And the `nonce` must equal the one *this* login
generated, which is what makes a stolen id-token useless.

Note also that every refusal names a **reason**. "Login failed" is unactionable
when the truth is a clock skew or a misconfigured audience.

### Doubles that are not fakes

`stzOidcSandbox` is why the negative cases above are testable at all. It is not a
stub returning `true`: it holds an ES256 keypair, **really signs** every token,
and serves a real JWKS. That required adding ES256 *signing* to the engine —
verification alone could not have tested this.

Crucially, it also mints **deliberately bad** tokens: expired, wrong audience,
foreign issuer, signed by another key. No real provider will issue you a broken
token on request, which is exactly why the negative half of a security contract so
often ships untested.

---

## Passkeys, and the one check that matters

A passkey replaces the password with a key pair the user's device holds. The
private half never leaves the authenticator, so there is nothing to phish, reuse,
or steal in a breach.

The signature check already existed. What was missing was **binary parsing** —
CBOR/COSE keys, attestation objects, packed authenticator data — all of which had
to live engine-side. One detail bites everyone: a WebAuthn ES256 signature is
ASN.1 **DER**, not the raw `r‖s` that JWS uses.

But the security is not in the parsing. It is here:

```ring
# a genuine assertion from the enrolled device
ch2 = c.NewPasskeyChallenge()
asr = pk.Assert(ch2, "https://example.com")
? "genuine login   : " + (c.LoginWithPasskeyAt(asr[:credentialId], asr[:authenticatorData],
                              asr[:clientData], asr[:signature], ch2, NOW) != "")

# the SAME device, signing for a look-alike site
ch3 = c.NewPasskeyChallenge()
ph  = pk.AssertForOrigin(ch3, "https://evi1-example.com")
? "phishing origin : [" + c.LoginWithPasskeyAt(ph[:credentialId], ph[:authenticatorData],
                              ph[:clientData], ph[:signature], ch3, NOW) + "]"
? "  why           : " + c.PasskeyWhy()
```

```
genuine login   : 1
phishing origin : []
  why           : origin mismatch: 'https://evi1-example.com' is not 'https://example.com' (this is what makes a passkey unphishable)
```

The signature in that phishing attempt is **perfectly valid**. It is refused on
the *origin*, because the browser puts the true origin into `clientDataJSON` and a
look-alike site cannot forge a match. A stolen password works anywhere; a passkey
cannot leave the site it was made for.

Two more checks come from the same place: the challenge must be the one we issued
(replay), and the signature **counter must advance** — a stalled counter is the
documented signal of a *cloned* authenticator. Credentials are stored per device,
so a user can enroll a laptop and a phone and un-enroll either without losing the
account.

---

## Being the provider

Consuming identity is half the story. `stzOidcProvider` makes a Softanza app the
thing other apps trust:

```ring
op = new stzOidcProvider("https://id.acme.com")
op.RegisterClient("shop", "s3cret", [ "https://shop.acme.com/cb" ])

r = op.AuthorizeAt([ :clientId = "shop", :redirectUri = "https://shop.acme.com/cb",
                     :state = "st", :nonce = "n1" ], "dana", NOW)
? "redirect        : " + r[:redirectTo]

t = op.ExchangeCodeAt("shop", "s3cret", r[:code], "https://shop.acme.com/cb", "", NOW)
? "tokens issued   : " + t[:ok] + " for " + t[:subject]

rp2 = new stzOidcClient("https://id.acme.com", "shop")
rp2.SetJwks( op.JwksJson() )
? "our RP verifies : " + rp2.VerifyIdTokenAt(t[:idToken], "n1", NOW+5)[:ok]
```

```
redirect        : https://shop.acme.com/cb?code=027923c765d2f03de7f39b6a9c89a23ff35e573e354fb5526b4a0b364eb2f6a1&state=st
tokens issued   : 1 for dana
our RP verifies : 1
```

That last line is the loop closing: our relying party believes our provider. Both
were written against the spec, not against each other, so their agreement is
evidence rather than circularity.

Each rule the provider enforces answers a real attack:

```
evil redirect   : refused (invalid_request) -- redirect_uri 'https://evil.example/cb' is not registered for this client
code reuse      : refused (invalid_grant)
```

`redirect_uri` matches **exactly**, never a prefix — a loose match is the most
abused hole in OAuth, because it delivers the authorization code to the attacker's
own site. A code is **single-use**, consumed *before* any other check so a replay
finds nothing, and bound to its client, redirect, nonce and PKCE challenge. And
mounted on the app server, `/authorize` takes the user from the **session cookie
the auth router already issues** — this server's own login becomes the login for
every app that trusts it.

---

## SAML, where the danger is not the crypto

SAML is what enterprises actually run, and it is the one place where I stopped to
say so plainly before starting: its security does not rest on cryptography. It
rests on answering *"which bytes were signed, and is the element I am about to
trust the same one the signature covers?"* Nearly every serious SAML CVE is a
wrong answer.

So the whole XML stack went engine-side and **strict** — a parser that refuses
`DOCTYPE` and `ENTITY` outright (XXE closed by construction, not "handled"), and
exclusive canonicalization written to the spec rather than to convenience.

Canonicalization is where this kind of code quietly breaks, so it was checked
against **libxml2** — byte-for-byte, across ten vectors. That caught two real bugs
in mine: a prefix declared on an ancestor must be re-declared on the element that
first *uses* it, and entity references must be **decoded then re-escaped**
(escaping the raw source turns `&amp;` into `&amp;amp;` and every digest is
wrong). Then a real assertion, canonicalized by lxml and signed by OpenSSL, had to
verify.

### The wrapping test, and why "did it verify" is the wrong question

Signature wrapping injects a forged assertion beside a genuine one. The test that
matters proves the signature **still verifies** on such a document — over the
original. So verification cannot be the defense.

The defense is structural: verification returns the **byte range** the signature
covered, and the SAML layer then **re-parses only that range** and reads every
claim from the second document. The forged assertion is not ignored; it is not in
the bytes we parse, so it cannot be reached.

Then the ordinary judgement, which no engine can make for you because it depends
on your deployment: the issuer must be the IdP you trust — *a perfectly valid
signature from the wrong IdP is someone else's user* — the audience must be you,
the window must contain now, and an assertion may not be replayed.

The issuing side came last, and was small because the canonicalizer already
existed:

```ring
sidp = new stzSamlIdentityProvider("https://idp.local")
sidp.RegisterServiceProvider("https://sp.example.com", "https://sp.example.com/acs")

ssp = new stzSamlServiceProvider("https://sp.example.com", "https://sp.example.com/acs")
sidp.TrustMeOn(ssp)                      # only the PUBLIC x,y ever leave

xml = sidp.IssueAssertionAt("dana@acme.com", "https://sp.example.com", NOW)
sr  = ssp.ConsumeXmlAt(xml, NOW + 10)
? "accepted          : " + sr[:ok] + "  subject=" + sr[:nameID]
? "window            : " + sr[:notBefore] + " .. " + sr[:notOnOrAfter]

bad = StzReplace(xml, "dana@acme.com", "evil@acme.com")
br  = ssp2.ConsumeXmlAt(bad, NOW + 10)
? "edited afterwards : " + br[:ok] + " -- " + br[:why]
```

```
accepted          : 1  subject=dana@acme.com
window            : 2026-07-24T12:00:00Z .. 2026-07-24T12:05:00Z
edited afterwards : 0 -- the digest does not match -- the signed content was altered
```

The IdP signs with the **same canonicalizer** its verifier uses — deliberately.
An IdP that signs with a different C14N than its verifier is the classic source of
"works with vendor A, fails with vendor B." And it refuses an **unregistered
audience at issue time**, because an IdP that vouches for a user to any service
that asks is an open redirect for identity.

---

## What the work actually taught

**The interesting part of auth is rarely the cryptography.** The engine work was
real but bounded. The long tail was judgement: which bytes are covered, whether a
token was minted for *us*, whether an origin matches, whether a counter advanced.
Every one of those is a question about *scope*, not about math.

**A refusal must carry a reason.** Half of this surface returns `[:ok, …, :why]`
rather than a bare false, because the failures that waste real days are
misconfigured audiences and clock skew, not attacks.

**Doubles have to be real to be useful.** The sandboxes here hold genuine keys and
produce genuine signatures — and, more importantly, they produce genuinely *bad*
artifacts on request: an expired token, a phishing-origin assertion, a stalled
counter, a wrapped document. No real provider or security key will do that for
you, which is precisely why the negative half of a security contract so often goes
untested. Making the attacker's side easy to express is what let every "must be
refused" claim here be *shown* rather than asserted.

**And the destination was never a login screen.** Every path — password, TOTP,
magic link, email-OTP, passkey, OIDC, SAML — converges on the same object: an
actor with a capability set, at a posture, that the governance model already
understands. Which means an employee arriving through corporate SSO and a bot
holding an API session are the same *kind* of citizen, differing only in what
their capabilities permit.

Auth is not a bolt-on. It is the front door.

---

*Verified end to end: fifteen narrated guards over the security surface (secret
53, store 31, sessions 25, TOTP 40, passwordless 23, authz 31, router 45, OIDC 43,
OIDC-provider 54, passkeys 29, SAML 53, public-key 16, plus secret-store, vault
and posture), and 32 engine tests — with canonicalization checked against
libxml2 and signatures against OpenSSL.*
