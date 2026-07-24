# Industrial-Strength Authentication
### What Better Auth teaches, and how Softanza should answer it — through governance, not just feature-parity

> Status: **ALL SIX PHASES BUILT (f91c12b0c, 7ca8a978b, 764c7839b, 0ca7e4b97, 6fc94800d, + this commit); external-identity deferred.** Written 2026-07-24 in answer to
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
   pluggable method (L2), proving the strategy seam. **DONE.** The engine grew a
   real RFC 6238 primitive (`StzEngineCryptoTotp` in `crypto.zig` — HMAC-SHA1
   *and* SHA256 + RFC 4226 truncation, verified against the published RFC
   vectors; the HMAC stays engine-side, a hex key in and decimal digits out, so
   no raw key bytes cross the Ring↔engine boundary). New `stzTotp` owns the
   base32 secret, the `otpauth://` provisioning URI an authenticator app scans,
   and skew-window verification (SHA1 / 6-digit / 30s — Google Authenticator /
   Authy / 1Password compatible). `stzAuth` gained the enrollment + enforced
   login flow: `EnableTotp` (issues a secret, stored **unconfirmed** so a
   mis-scan never locks anyone out) → `ConfirmTotp` (proves a first code, enables
   the factor, returns ten one-time **recovery codes** — only their hashes are
   stored) → a plain `Login` is then **refused** for that user and
   `LoginTwoFactor` (password + TOTP-or-recovery) is the door;
   `RequiresTwoFactor`, `VerifyTotp`, `DisableTotp`, `RegenerateRecoveryCodes`,
   `RecoveryCodesRemaining`. 2FA state persists through the auth store
   (`auth2fa` table; a second `stzAuth` on the same DB sees the enforced factor
   and consumed recovery codes). Guard `auth_totp_narrated` (40); regressions
   `secret` 53 / `auth_store` 31 / `auth_sessions` 25 all green. A bad second
   factor counts toward the phase-1 lockout.
4. **Passwordless via the mail port (L4)** — magic-link / email-OTP over the
   service-virtualization mail sink (dev) → real sender (deploy). **DONE.** This
   also stands up the **service-virtualization plane's first piece**: a
   duck-typed **mail port** (`Send(to, subject, body)`) in new `base/service/`,
   with `stzMailSandbox` — the fee-free capture sink that records instead of
   sending, so a test reads the very link/code out of an inspectable inbox (a
   real SMTP adapter binds behind the same contract at deploy; it is infra-gated,
   the reactor speaks HTTP/TLS not SMTP). `stzAuth` gained `SetMailPort`,
   `RequestMagicLink` → `RedeemMagicLink` and `RequestEmailOtp` →
   `VerifyEmailOtp` (both `…With`/`…At` device+time variants), plus
   `RegisterPasswordless` (an account with no usable password). The emailed
   magic-link token is 256-bit; only its **sha256** is stored (a store leak
   yields no usable link); email-OTP codes are salted-hashed. Every flow is
   **enumeration-safe** (identical response whether or not the account exists,
   sends only for a real user), **one-time**, **expiring** (`SetPasswordlessTTL`,
   15 min default), counts a wrong OTP toward the phase-1 lockout, and **never
   bypasses a confirmed 2FA**. Durable in both stores (`authchallenges` table).
   Guard `auth_passwordless_narrated` (23); regressions secret 53 / auth_store 31
   / auth_sessions 25 / auth_totp 40 green. (Ring note: the sandbox shares its
   captured-mail sink through a handle table so a stored *copy* — Ring copies
   objects on `=` — still writes the sink the caller inspects.)
5. **authn → authz bridge (L5)** — `Login` yields an actor; roles via governance;
   the org-chart / separation-of-duties tie-in. The differentiator. **DONE.** A
   user carries **roles** (durable grants in the store, `authroles`); each role is
   a **capability bundle** — kinds from the lattice (effectful / sensing / compute
   / inference) at a posture (trusted / external / sandboxed) — defined as app
   config (`DefineRole`; four ship by default: `admin`, `member`, `viewer`,
   `assistant`). `ActorForUser` / `ActorOf(session)` resolve a user into a
   **`stzSystemActor`** named for them, holding the **union** of their roles'
   kinds at the **most restrictive** posture — the very subject the whole
   governance system reasons about. `SessionCan`, `SessionIsEffectful`,
   `SessionActor` read authz off the live session; a no-role user is authenticated
   yet permitted nothing (least privilege), and an **`assistant` (LLM-backed)
   session is authenticated yet effect-less** — the agentic-safety invariant,
   extended to identity. The bridge is real but uncoupled: `SessionPerson(session)`
   is the **same string** the governance actor and the org-chart person key on, so
   `SessionMayProceed(session, action, governance)` gates the *existing*
   `stzGovernance.MayProceed` on session validity (governance passed by reference,
   never held), and placing `SessionPerson` into an `stzOrgChart` lets the
   existing separation-of-duties / org rules reason about the authenticated user
   with no glue. `RegisterPasswordless` + roles compose. Guard `auth_authz_narrated`
   (31); regressions secret 53 / auth_store 31 / auth_sessions 25 / auth_totp 40 /
   auth_passwordless 23 green.
6. **Mount as an appserver auth router** — `/login`, `/logout`, `/session`,
   `/2fa/verify` on `stzAppServer`, with signed requests (`stzRequestSigner`) and
   `HttpOnly`/`SameSite`/`Secure` session cookies + CSRF. **DONE.**
   `oSrv.MountAuth(oAuth)` (or `MountAuthAt(oAuth, prefix)`) exposes every earlier
   phase over HTTP: `POST /auth/login` (and `/auth/2fa/verify`),
   `POST /auth/logout`, `GET /auth/session`, `POST /auth/magic-link` +
   `GET /auth/magic-link/redeem?token=`, `POST /auth/otp` + `/auth/otp/verify`.
   It is **data-registered and dispatched internally** — the `Expose(db, table)`
   pattern, not a closure — so it slots into the existing chain *behind* the
   transport gate: `RequireSignedRequests` still runs first, and the MBaaS floor,
   ordinary routes and `/health` are untouched. The session token travels as an
   **`HttpOnly` + `SameSite=Strict`** cookie (`Secure` via `SetSecureCookies`
   behind TLS) alongside a **readable csrf cookie**; a cookie-authenticated
   `POST /auth/logout` must echo it in `X-CSRF-Token` (403 otherwise) — because a
   cookie is *ambient* authority, while a caller passing the token explicitly in
   the body is not, and needs no such proof. `GET /auth/session` returns the
   **phase-5 authz surface** (user, capabilities, posture, effectful, roles). 2FA
   is enforced at the door: password-only gets 401 with a `"twofactor":1` hint
   (the check is on the *account*, so it leaks nothing about the password).
   Passwordless stays enumeration-safe over HTTP too (identical 202 either way).
   Form values are percent-decoded. **Ring copy note:** `=` and list insertion
   both copy, so the server holds its own `stzAuth` — configure before mounting,
   or give it a `stzAuthDbStore` and both sides share one sqlite (proven
   bidirectional: a user registered *after* the mount signs in, and the caller
   sees the session HTTP created). Guard `auth_router_narrated` (45, including a
   real-socket round-trip); regressions — auth secret 53 / store 31 / sessions 25
   / totp 40 / passwordless 23 / authz 31, and appserver 16 / 26 / 6 / 28 / 35 —
   all green.

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
