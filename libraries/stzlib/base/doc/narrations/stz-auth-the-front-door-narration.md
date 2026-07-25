# The Front Door
### A guided tour of authentication in Softanza — for programmers, not security specialists

Every application eventually needs to answer "who is this?" And almost every
application answers it badly the first time, not through carelessness but because
the field is full of details that look optional and are not.

This narration walks Softanza's answer from the beginning, explaining each idea
before using it. You do not need to know what a nonce, a canonicalization or a
capability lattice is — that is the narration's job. Every code block is real, and
every output block is its actual output.

If you take one idea away, take this: **a login should not set a flag. It should
produce a subject the rest of your program already understands.**

---

## Where it started

Softanza's `stzAuth` began small and correct: a username, a securely hashed
password, a session token. Nothing wrong with any of it.

But an application in production needs more than the happy path. What happens when
the process restarts — do people stay logged in? Can a user see the four devices
they are signed in on, and kick out the one they lost? Can someone guess passwords
all afternoon? And the big one: once you know *who* someone is, how does the rest
of your code learn what they are *allowed to do*?

That last question is where most auth libraries stop and hand you a `user.role`
string. It is where this one gets interesting.

---

## First idea: a login hands you an actor

Start with roles. A role in Softanza is not a label — it is a **bundle of
capabilities** at a **trust level**.

```ring
a = new stzAuth()
a.Register("dana", "pw")
a.GrantRole("dana", "admin")
tok = a.LoginAt("dana", "pw", NOW)

act = a.ActorOfAt(tok, NOW)
? "user        : " + act.Name()
? "capabilities: " + @@(act.Kinds())
? "posture     : " + act.Posture()
```

```
user        : dana
capabilities: [ "effectful", "compute", "sensing" ]
posture     : trusted
```

Read those capability names, because they are the vocabulary the whole library
speaks:

| Capability | Means |
|---|---|
| `effectful` | may *change* things — write a file, deploy, send money |
| `sensing` | may *observe* — read state, list, inspect |
| `compute` | may *calculate* — transform data, decide |
| `inference` | may *reason* — ask a model, propose |

And the posture — `trusted`, `external`, `sandboxed` — says how much the system
leans on that actor's judgement.

Here is the part that matters: **this object is not an auth invention.** It is a
`stzSystemActor`, the same thing Softanza's governance rules, org charts and
security graphs already reason about. `stzAuth` does not implement authorization.
It produces the subject that the authorization you already have was written for.

That is why the same string flows straight through:

```ring
oGov = new stzGovernance("acme")
oGov.DeclareRisk("delete-account", 2)
oGov.GrantPermission("dana", "delete-account")     # keyed by the same name

? a.SessionMayProceedAt(tok, "delete-account", oGov, NOW)
# --> 1
```

No adapter, no mapping table. The identity your login produced *is* the identity
your rules were written against.

### The example that shows why this is worth it

Now grant a different role — `assistant`, meant for an account an AI agent uses:

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

Read that carefully. The bot is **genuinely logged in**. It holds a real session.
And it is **structurally incapable of changing anything** — not because a policy
says no, but because "may change things" is not in its capability set.

A user with *no* roles behaves the same way: authenticated, permitted nothing.
Least privilege is what you get by default, not something you remember to
configure.

---

## Second idea: the boring hardening is the important hardening

Three fixes that no one demos, and that mattered most.

**A timing leak.** The original `Authenticate` returned `FALSE` immediately for an
unknown username, but ran a full (deliberately slow) password hash when the user
existed. That difference is measurable from outside — so an attacker learns *which
usernames are registered* by timing failures. This is called an **enumeration
oracle**, and knowing valid usernames is most of the work in a credential-stuffing
attack.

The fix is four lines: when the user is unknown, verify the password against a
throwaway hash anyway, so both paths cost the same. Measured afterwards at 0.97×.

**An unbounded guessing service.** A login endpoint that always answers is a
password cracker with your database behind it. Softanza counts failures per
username and locks out after a threshold. Two details are deliberate: a locked
account refuses even the *correct* password, and a wrong password and a lockout
return the *same* empty result — so the refusal itself leaks nothing.

**Sessions that know things.** A session grew from "user + expiry" into a record
with when it was created, from what IP, what browser, and when it was last seen.
That is what makes a "your devices" screen possible, lets you sign out *one* device
without touching the others, and enables an idle timeout that slides while you
work.

It also enables one non-obvious defence. Whenever a session gains privilege — the
user completes two-factor, changes their password, elevates — Softanza issues a
**new** token and voids the old one:

```ring
tNew = a.RotateSession(tOld)     # tOld can never be replayed
```

Why bother? Because of an attack called **session fixation**: if an attacker can
get *their* session token into your browser before you log in, then after you log
in that same token is now an authenticated session — theirs. Changing the token at
the moment privilege changes breaks it.

---

## Third idea: a second factor, and a port that sends nothing

You know the six-digit code from an authenticator app. Here is what it actually
is: your phone and the server share a secret, both look at the clock, and both
compute a hash of (secret + current 30-second window). Same inputs, same code. No
network involved — which is why it works on a plane.

Enrollment is deliberately **two steps**:

```ring
a.Register("erin", "pw")
dev   = StzTotpFromSecretQ( a.EnableTotp("erin", "Softanza")[:secret] )
codes = a.ConfirmTotpAt("erin", dev.CodeAt(NOW), NOW)

? "recovery codes issued : " + len(codes)
? "plain password login  : [" + a.LoginAt("erin", "pw", NOW) + "]"
? "with the app code     : " + (a.LoginTwoFactorAt("erin", "pw", dev.CodeAt(NOW), NOW) != "")
```

```
recovery codes issued : 10
plain password login  : []
with the app code     : 1
```

Two steps, because a one-step version is a trap: if enrolling immediately enforced
the factor, a user who mis-scanned the QR code would be locked out of their own
account. `EnableTotp` stores the secret *unconfirmed* and changes nothing.
`ConfirmTotp` requires a working code as proof, and only then does the password
stop being a door on its own.

Notice the ten recovery codes. Phones get lost. Those are shown once; only their
hashes are stored.

### Sending things without sending things

Magic links and emailed codes need something the library did not have: a way to
send mail. Rather than hard-wiring an SMTP client, Softanza took a **port** — a
one-method contract — and in development binds a sandbox that *captures* instead
of delivering:

```ring
mail = new stzMailSandbox()
a.SetMailPort(mail)
a.RequestMagicLinkAt("dana", NOW)

? "captured : " + mail.Count()
? "body     : " + mail.LastBody()
```

```
captured : 1
body     : Click to sign in: softanza://magiclink?token=ac24b503af2df1188399a837775ca968991253ed10151a3a2b1481c2b6238f8e
This link expires in 15 minutes.
```

Your test can read the very link that would have gone out. At deploy you bind a
real sender behind the same contract — same code, no fees, nothing mocked away.

Two touches worth noticing. The token is 256 bits and only its **hash** is stored,
so stealing the database yields no usable link. And asking for a link for an
address that does not exist gives the *identical* answer:

```
unknown address : same answer, nothing sent
  captured      : 0
```

Otherwise "we sent you a link" versus "no such user" is a free tool for checking
whether someone has an account with you.

---

## Fourth idea: believing someone else's token

"Sign in with Google" is the most common auth feature and the least understood.
Here is the whole shape.

The provider hands your app an **id-token**: a small JSON document, signed. You
verify the signature with a **public** key the provider publishes — public-key
cryptography means you can *check* a signature without being able to *make* one.
So no shared secret ever travels.

That is the easy half. Here is what a valid signature does **not** tell you:

```ring
idp = new stzOidcSandbox("https://idp.local", "my-app")
rp  = new stzOidcClient("https://idp.local", "my-app")
rp.SetJwks( idp.JwksJson() )        # the provider's public keys

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

A signature only proves the provider signed *something*. The claims decide it was
signed **for you**, **recently**, and **in answer to this login**:

- **`iss`** — is this the provider I configured? A perfectly valid signature from
  a *different* provider is somebody else's user.
- **`aud`** — was this minted for *my* application? A token issued for another app
  is not a login here.
- **`exp`** — is it still current?
- **`nonce`** — a random value *your* app generated for *this* login and included
  in the request. The provider echoes it back. Without it, a token captured
  earlier could be replayed later; with it, a stolen token answers a question
  nobody asked.

One more decision, invisible but load-bearing. A JWT's header *states* which
algorithm signed it. Softanza ignores that field and uses the algorithm of **its
own key**. Trusting the header enables a family of forgeries — most famously
`alg: none`, where an attacker strips the signature and declares that none was
required.

And note that every refusal names a **reason**. That is not politeness: in
practice, the failures that eat a whole afternoon are a clock five minutes out or
a mistyped audience, not attackers.

### Doubles that are real

`stzOidcSandbox` above is not a stub returning `true`. It holds a real key and
really signs. That mattered enough to add signing to the engine, because
verification alone cannot be tested without something to verify.

More importantly, it produces *deliberately bad* tokens on request — expired,
wrong audience, foreign issuer, signed by another key. No real provider will do
that for you, which is exactly why the "must be rejected" half of a security
contract so often ships untested.

---

## Fifth idea: passkeys, and the one check that does the work

A passkey replaces the password with a key pair your *device* holds. The private
half never leaves the phone or laptop, so there is nothing to phish, nothing to
reuse across sites, and nothing to steal in a breach. Logging in means signing a
fresh challenge.

Softanza's engine had to learn to read the binary formats involved (a credential's
public key arrives as CBOR — a compact binary cousin of JSON — inside an
attestation object). But the security is not in the parsing:

```ring
# a relying party (your site) and an enrolled device
c = new stzAuth()
c.SetPasskeyRelyingParty("example.com", "https://example.com")
c.Register("dana", "pw")
pk = new stzPasskeySandbox("example.com")
ch = c.NewPasskeyChallenge()
reg = pk.CreateCredential(ch, "https://example.com")
c.RegisterPasskey("dana", reg[:attestationObject], reg[:clientData], ch)

# a genuine login from the enrolled device
ch2 = c.NewPasskeyChallenge()
asr = pk.Assert(ch2, "https://example.com")
? "genuine login   : " + (c.LoginWithPasskeyAt(asr[:credentialId], asr[:authenticatorData],
                              asr[:clientData], asr[:signature], ch2, NOW) != "")

# the SAME device, tricked into signing for a look-alike site
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

**The signature in that phishing attempt is perfectly valid.** It is refused on
the *origin*. The browser writes the true site into the signed data, and a
look-alike domain cannot forge a match.

Sit with that difference: a stolen password works anywhere. A passkey physically
cannot leave the site it was made for. That is not a better password — it is a
different shape of thing.

Two more checks come free from the same data: the challenge must be the one you
issued (so a captured response cannot be replayed), and a counter in the device
must keep increasing — a counter that stalls is the documented sign of a **cloned**
authenticator.

---

## Sixth idea: being the provider

Consuming identity is half the job. Softanza can also *be* the thing other
applications trust — an internal SSO portal, effectively:

```ring
op = new stzOidcProvider("https://id.acme.com")
op.RegisterClient("shop", "s3cret", [ "https://shop.acme.com/cb" ])

r = op.AuthorizeAt([ :clientId = "shop", :redirectUri = "https://shop.acme.com/cb",
                     :state = "st", :nonce = "n1" ], "dana", NOW)
? r[:redirectTo]

t = op.ExchangeCodeAt("shop", "s3cret", r[:code], "https://shop.acme.com/cb", "", NOW)
? "tokens issued   : " + t[:ok] + " for " + t[:subject]

rp2 = new stzOidcClient("https://id.acme.com", "shop")
rp2.SetJwks( op.JwksJson() )
? "our RP verifies : " + rp2.VerifyIdTokenAt(t[:idToken], "n1", NOW+5)[:ok]
```

```
https://shop.acme.com/cb?code=027923c765d2f03de7f39b6a9c89a23ff35e573e354fb5526b4a0b364eb2f6a1&state=st
tokens issued   : 1 for dana
our RP verifies : 1
```

That last line closes a loop worth pausing on: Softanza's *client* believes
Softanza's *provider*. The two were written against the specification rather than
against each other, so their agreement is evidence rather than circular.

The rules the provider enforces each answer a real attack:

```
evil redirect   : refused (invalid_request) -- redirect_uri 'https://evil.example/cb' is not registered for this client
code reuse      : refused (invalid_grant)
```

**Exact redirect matching.** The provider sends the authorization code to a URL the
app nominated. If matching is loose — a prefix, a wildcard — an attacker crafts a
URL that passes the check and points at their own site, and the code is *delivered
to them*. This is the most abused hole in OAuth, and the defence is boring: exact
string match against a registered list.

**Single-use codes.** A code is consumed before any other check, so replaying one
finds nothing. It is also bound to the client, the redirect and the nonce it was
issued under — a stolen code is useless to anyone else.

And when mounted on the app server, `/authorize` takes the user from **the session
cookie the login router already issued**. Your own login becomes the login for
every app that trusts you.

---

## Seventh idea: SAML, where the danger is not the cryptography

SAML is what enterprises run — Okta, Entra, ADFS. The provider POSTs back a signed
XML document. This is the one place where the interesting question is not
cryptographic at all:

> Which bytes were signed, and is the element I am about to trust the same one the
> signature covers?

Almost every serious SAML vulnerability is a wrong answer to that. Consider the
attack called **signature wrapping**: an attacker takes a legitimately signed
assertion and *adds their own alongside it*, inside the same response.

Here is the crucial part. When Softanza verifies that document, **the signature
still checks out** — because it genuinely does, over the original assertion. Any
implementation whose defence is "did the signature verify?" now reads the
attacker's assertion and logs them in as whoever they like.

Softanza's defence is structural instead. Verification reports the **byte range**
the signature covered, and the claims are then read by re-parsing *only those
bytes*:

```ring
oSp.TrustIdpFromMetadata(cIdpMetadata)      # one paste: entityID, endpoint, key
aR = oSp.ConsumeXmlAt(cWrappedResponse, nNow)
? aR[:nameID]
# --> dana@acme.com          ... never attacker@evil.com
```

The forged assertion is not ignored — it is *unreachable*, because it is not in the
bytes being read.

On top of that sit the ordinary checks, which no library can make for you because
they depend on your configuration: the issuer must be the provider you trust, the
audience must be you, the validity window must contain now, and an assertion may
not be used twice.

Softanza can also issue assertions, and the IdP signs with **the same
canonicalizer** its verifier uses. (Canonicalization is XML's normal form —
`<r a="1" b="2">` and `<r b="2" a="1">` mean the same thing but are different
bytes, and signatures are over bytes.) An IdP that normalises differently from its
verifier is the classic "works with vendor A, fails with vendor B" bug. One
implementation, used by both sides, cannot disagree with itself.

---

## What the whole thing adds up to

Seven ideas, one destination. Every path — password, authenticator app, magic link,
emailed code, passkey, "sign in with", enterprise SSO — arrives at the same object:
an actor with a capability set, at a trust posture, that your governance rules
already understand.

Which means an employee arriving through corporate SSO and a bot holding an API
session are the **same kind of citizen**. They differ only in what their
capabilities permit — and the bot's capabilities permit nothing that changes the
world.

### Three lessons worth stealing

**The interesting part of auth is rarely the cryptography.** The crypto was
bounded work. The long tail was *judgement*: which bytes are covered, was this
minted for us, does the origin match, did the counter advance. Every one of those
is a question about **scope**, not about mathematics.

**A refusal must carry a reason.** Half this surface returns
`[:ok, …, :why]` rather than a bare false, because the failures that actually cost
days are misconfigured audiences and clock skew.

**Test doubles must be able to misbehave.** Every sandbox here holds real keys and
produces real signatures — *and* produces genuinely broken artifacts on request: an
expired token, a phishing-origin assertion, a stalled counter, a wrapped document.
No real provider or security key will do that for you. Making the attacker's side
easy to express is what let every "must be refused" claim in this narration be
*shown* rather than asserted.

---

*Verified end to end: fifteen narrated guards over the security surface (secret 53,
store 31, sessions 25, TOTP 40, passwordless 23, authz 31, HTTP router 45, OIDC 43,
OIDC-provider 67, passkeys 29, SAML 77, public-key 16, plus secret-store, vault and
posture), and the engine's own tests — with XML canonicalization checked
byte-for-byte against libxml2 and every signature vector produced by OpenSSL.*
