# Industrial-Strength Authentication
### What Better Auth teaches, and how Softanza should answer it — through governance, not just feature-parity

> Status: **phases 1–2 BUILT (f91c12b0c, 7ca8a978b); phases 3–6 planned, external-identity deferred.** Written 2026-07-24 in answer to
> the user's request to analyse [better-auth](https://github.com/better-auth/better-auth)
> and extract what would make Softanza's `stzAuth` industrial-strength. Grounded
> in a read of the live `base/security/stzAuth.ring` and a survey of Better
> Auth's documented feature and plugin surface.

---

## 1. The honest starting point

`stzAuth` today is a **clean, correct, minimal core** — not a toy, but not
industrial. It has:

- a user store `username → PBKDF2 hash` (engine `StzHashSecret`, constant-time
  `StzVerifySecret`), never plaintext;
- opaque 256-bit session tokens that **are** `stzToken`s carrying their own
  expiry (`SetSessionTTL`, `PurgeExpired`, deterministic `…At(now)` variants);
- `Register` / `Authenticate` / `Login` / `Logout` / `ChangePassword` /
  `Unregister`.

What it lacks is everything an app in production needs beyond the happy path:
persistence, a second factor, passwordless flows, brute-force defense,
per-device session control, and any connection between *who you are* (authn) and
*what you may do* (authz).

## 2. What Better Auth actually is (the load-bearing ideas, not the feature dump)

Better Auth calls TypeScript auth "a half-solved problem" and answers it with
three architectural commitments, and a large surface built on them:

1. **A small framework-agnostic core + adapter-based persistence.** The core
   knows nothing about your database or web framework; a **database adapter**
   interface plus **automatic schema management / migrations** lets it run on
   any store. This is the load-bearing decision — everything else plugs into it.
2. **A plugin ecosystem.** The core is deliberately small; each plugin adds auth
   *methods*, HTTP *endpoints*, and its own *schema*. Rapid feature growth with
   minimal core change.
3. **authn AND authz in one place** — it is an "authentication *and
   authorization*" framework.

On those three sit the surface: **email/password**, **social / OAuth**
(many providers) + **generic OAuth**, **magic link**, **email-OTP**,
**phone-OTP**, **username**, **anonymous**, **passkey / WebAuthn**;
**2FA** (TOTP + OTP); **account & session management**, **multi-session**,
**bearer** tokens; a **built-in rate limiter** with custom rules; **API keys**;
**JWT** (with key rotation); **organizations / teams / access control**;
**admin**; **SSO / SAML**; an **OIDC provider**; **CSRF / cookie** handling.

## 3. The five lessons — each mapped to a pattern Softanza already has

The point is **not** to clone the plugin list. It is to take the architecture
lessons and answer them the Softanza way — and in two places, to *exceed* Better
Auth because the governance substrate already exists.

### L1 — Persist through an adapter seam (the biggest gap, and Softanza already owns the pattern)

`stzAuth` keeps `@aUsers` / `@aSessions` in memory — they vanish when the process
ends. Better Auth's #1 idea is the **database adapter**. Softanza already has
this exact seam in three places: `stzVaultResolver` (a duck-typed
`Resolve(locator)` swapped dev→prod), `stzDatabase` (real sqlite), and the
service-virtualization plan's port contract.

**So:** `stzAuth` persists through a duck-typed **auth store** — any object with
`FindUser(name)` / `SaveUser(...)` / `SaveSession(...)` / `DeleteSession(...)`.
Ship an in-memory reference (today's behaviour, the default) and a
`stzDatabase`-backed one (sqlite → any SQL at deploy), exactly as
`stzVaultResolver` ships an in-memory reference and you supply the real client.
Auto-schema falls out of `stzDatabase`. *This is the single highest-value
change, and it is not greenfield.*

### L2 — A small core + pluggable auth *methods* (the port / attach pattern)

Better Auth's plugin model = a small core + methods that attach to it. Softanza's
graph-rules work just established the same shape (a rule **attached** to the
graph becomes part of its logic), and the service-virtualization plan is built on
duck-typed **ports**.

**So:** the credential core (password) stays small; other methods attach as
duck-typed **auth strategies** — `oAuth.AddMethod( new stzTotpFactor() )`,
`oAuth.AddMethod( new stzMagicLink(oMailPort) )`. Each strategy owns its own
verify step and (via L1) its own stored fields. The core does not grow per
method; the scope stays on the `stzAuth` you hold.

### L3 — Harden the primitives (small, real, high-value)

Three hardening gaps, none large:

- **Timing-safe user lookup.** `Authenticate` returns `FALSE` immediately when a
  user is unknown, but runs a full PBKDF2 verify when it exists — a timing oracle
  that leaks *which usernames are registered*. Fix: verify against a dummy hash
  even when the user is absent, equalising the timing. A few lines, a genuine
  hardening.
- **Brute-force lockout / rate limiting.** Better Auth ships a rate limiter;
  Softanza has `stzReactor`'s rate-limit rung (R8) and can track per-user failed
  attempts with a lockout window. Login must not be an unbounded oracle.
- **Session hardening.** Rotate the token on privilege change (fixation
  defense); attach per-session metadata (created-at, ip, user-agent) so a user
  can *list and revoke individual devices*; add "revoke every session for this
  user" (distinct from `Unregister`); absolute vs idle timeout.

### L4 — A real second factor, and passwordless — where the engine and other planes pay off

- **Engine-backed TOTP (2FA).** RFC 6238 TOTP is HMAC over a time counter, and
  the engine already exposes HMAC (`stzRequestSigner._Hmac`, `crypto.zig`). So a
  **real** authenticator-app TOTP factor is buildable engine-side — enroll
  (shared secret + otpauth:// URI), verify with a skew window, one-time recovery
  codes. High value, tractable, no external dependency.
- **Passwordless (magic link / email-OTP / phone-OTP)** needs a way to *send* a
  code. That is exactly the **mail / SMS sink** of the
  [service-virtualization plane](SOFTANZA_SERVICE_VIRTUALIZATION_PLAN.md): a
  magic-link factor takes a mail *port*, uses the sandbox in development (the
  code lands in a capture sink you can assert on) and the real sender at deploy.
  The two planes interlock cleanly.

### L5 — Wire authn → authz (where Softanza should EXCEED Better Auth)

Better Auth bundles authorization because TypeScript had nothing. **Softanza has
more authz than Better Auth already** — it is simply not connected to `stzAuth`'s
users:

- the **actor + capability lattice** (`stzSystemActor`: effectful / sensing /
  compute / inference; trusted / external / sandboxed);
- `stzGovernance` (risk tiers, permissions, authority, decision lineage);
- the **org chart** (positions, roles, reporting) and the new **org-rules**
  (`separation-of-duties`, `no-cyclic-reporting`);
- the graph-rules **security graph** (multi-hop privilege escalation).

**So:** a successful `Login` yields not just a session but an **actor** with a
capability set — authn produces the subject the whole governance system already
reasons about. Roles resolve through `stzGovernance`; org membership through the
org chart; "can this person both approve and execute?" is *already* a
`separation-of-duties` graph rule. This is the Softanza-unique payoff: auth is
not a bolt-on, it is the front door to the governance model.

## 4. The governing frame (the North Star, applied)

Every auth event is a **governed crossing**, exactly as `stzSecretStore` treats
every reveal: `Login` / `Logout` / 2FA-enroll / password-reset are **audited**
(who authenticated, when, from where, refused or granted). A session is the
lease that grants an actor its capabilities; it expires; it can be revoked; and
an `LLMActor`'s session still carries an empty effect set. *Expression is free;
admission is governed* — extended from secrets and deploys to identity itself.

## 5. What to build, and what NOT to rush

Ordered so each phase ships value and the early ones unblock the later.

1. **Adapter-persist the store (L1)** + the timing-safe fix and lockout (L3, the
   cheap hardening). The spine — turns `stzAuth` from in-memory to durable and
   closes the two worst holes. **DONE (f91c12b0c).** `stzAuthStore` seam +
   `stzAuthMemoryStore` (default) / `stzAuthDbStore` (sqlite, durable — a second
   `stzAuth` on the same file sees the users and sessions); `Authenticate` now
   verifies unknown users against a dummy hash (measured 0.97× — no enumeration
   oracle); per-username lockout (`SetMaxAttempts`/`SetLockoutSeconds`,
   `IsLockedOut`); `RevokeAllSessions`. Guard `auth_store_narrated` (31);
   `secret_narrated` still 53.
2. **Session hardening (L3)** — metadata, per-device list/revoke, revoke-all,
   rotation on privilege change. **DONE (7ca8a978b).** Per-session metadata
   (created/ip/user-agent) persisted in both stores; `SessionsOf`/`SessionInfo`
   (the "your devices" surface); `RevokeSession` (one device) vs
   `RevokeAllSessions`; `RotateSession` (fixation defense — new token on
   privilege change, old voided); opt-in idle timeout (`SetIdleTTL`, sliding
   window). `LoginWith(user, pw, ip, ua)`; plain `Login` unchanged. Guard
   `auth_sessions_narrated` (25).
3. **TOTP 2FA (L4)** — engine HMAC; enroll + verify + recovery codes. The first
   pluggable method (L2), proving the strategy seam.
4. **Passwordless via the mail port (L4)** — magic-link / email-OTP over the
   service-virtualization mail sink (dev) → real sender (deploy).
5. **authn → authz bridge (L5)** — `Login` yields an actor; roles via governance;
   the org-chart / separation-of-duties tie-in. The differentiator.
6. **Mount as an appserver auth router** — `/login`, `/logout`, `/session`,
   `/2fa/verify` on `stzAppServer`, with signed requests (`stzRequestSigner`) and
   `HttpOnly`/`SameSite`/`Secure` session cookies + CSRF.

**Deliberately deferred (bigger, external-facing, or lower leverage):**

- **OAuth / social / OIDC / SSO / SAML.** Real work: the OAuth token exchange
  needs the reactor HTTP client, provider config, and — for OIDC — JWKS fetch and
  RS256/ES256 **signature verification** the engine does not yet expose. A
  genuine plane of its own; the mail-port interlock does not help here.
- **Passkeys / WebAuthn.** Needs COSE public-key parsing and ES256/RS256
  assertion verification engine-side — the same missing primitive as OIDC.
  Highest complexity, defer until the engine grows public-key verification.
- **Being an OIDC *provider* / JWT issuer.** Powerful (Better Auth added it) but
  it is a product surface, not a hardening — only after 1–5 land.

Honest caveat: items 1–4 are tractable and mostly reuse existing Softanza
patterns (adapter seam, engine HMAC, the mail port). Item 5 is where the real
originality is. Items in the deferred list wait on **engine public-key
verification**, which is the one primitive the whole external-identity story
(OAuth/OIDC/passkeys) turns on — worth its own engine task before any of them.

---

*Better Auth's lesson is not its plugin list; it is three decisions — persist
through an adapter, keep the core small and let methods plug in, and unify authn
with authz. Softanza already owns the first two patterns (the vault seam, the
port/attach model) and has a richer answer to the third than Better Auth does
(the actor lattice, governance, org-rules). Industrial-strength `stzAuth` is
mostly a matter of wiring what already exists — durable storage, engine TOTP, the
mail port, and the governance front door — not importing a framework.*
