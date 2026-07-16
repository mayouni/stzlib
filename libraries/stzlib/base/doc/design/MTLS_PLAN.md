# Wire mTLS between nodes -- implementation plan (R8 rung #6)

Status: IN PROGRESS (slice 1). Chosen 2026-07-15.

## Goal

True mutual-TLS between Softanza nodes: both ends terminate TLS and present +
validate X.509 certificates. This adds what request signing (rung #4) does
NOT: **confidentiality in transit** (encryption) and a **certificate-based
mutual identity** over the actual transport channel -- not just an app-layer
signature.

## The gap it closes

Today: outbound is real HTTPS (curl/Schannel, one-way TLS -- the client
validates the server). The reactor's SERVER side (accept/read loop in
reactor.zig) speaks PLAIN HTTP/1.1 over TCP -- no TLS termination. So
node-to-node traffic is unencrypted and the server cannot authenticate the
client by certificate. Request signing gives per-request auth+integrity but
NOT encryption. mTLS closes both server-side halves.

## Backend decision: vendored mbedTLS (not Schannel)

- The engine already links Schannel (curl uses `-DUSE_SCHANNEL`; secur32/
  crypt32/bcrypt are linked), so Schannel server TLS needs no vendoring --
  BUT SSPI server-side TLS (AcquireCredentialsHandle/AcceptSecurityContext
  token loop) is arcane, poorly documented, Windows-only, and slow to
  iterate.
- mbedTLS is a self-contained C library (3.6.2 LTS: crypto + TLS + x509 all
  in `library/`, 108 .c files, no external deps) that vendors + builds with
  zig exactly like sqlite/pcre2/utf8proc/libuv (no cmake). Its **buffer BIO
  model** (`mbedtls_ssl_set_bio` with custom send/recv callbacks) maps
  perfectly onto libuv's read/write: feed it received bytes, it hands back
  bytes to write. Cross-platform, cleaner API, standard.
- Decision: **vendor mbedTLS 3.6.2 LTS.** Matches the whole-engine "vendor
  and build with zig" doctrine and keeps the TLS layer transport-agnostic.

## Slices

- **Slice 1 (DONE 2026-07-15): vendor + build + handshake smoke.**
  - Vendored mbedTLS 3.6.2 LTS `include/` + `library/` (108 .c, self-
    contained) under `engine/vendor/mbedtls/`. Default config auto-picked.
  - `build.zig`: `addMbedtls()` globs `library/*.c` (Windows: links bcrypt/
    advapi32/crypt32/ws2_32 for the CryptoAPI entropy source); a
    `zig build mtls-smoke` step builds + runs a standalone Zig program.
  - Smoke (`src/mtls_smoke.zig`): an IN-MEMORY TLS handshake -- server ctx +
    client ctx handshaking through two paired byte pipes (the SAME buffer-BIO
    model the reactor server loop will feed in slice 2), with a self-signed
    EC test cert (`src/mtls_certs/`, throwaway). VERIFIED: full TLS 1.3
    handshake (CHACHA20-POLY1305), an encrypted app-data record round-trips
    and decrypts, and the cleartext is confirmed ABSENT from the transported
    bytes (real encryption). NO reactor changes. Build clean in ~12s.

- **Slice 2 (DONE 2026-07-15): server-side TLS termination in the reactor.**
  - Per-connection TLS on the server `Conn`: an `mbedtls_ssl_context` with
    byte BIOs (`net_in` = received ciphertext, `net_out` = ciphertext to
    send). `onSrvRead` feeds ciphertext to `tlsProcess` (pump handshake, then
    `ssl_read` -> plaintext -> the SAME `feedPlaintext` framing a plain conn
    uses); `startWrite` runs the plaintext response through `ssl_write` ->
    ciphertext -> `enqueueRawWrite`. So TLS is transparent: the Ring
    router/handlers see only decrypted requests + write plaintext.
  - `reactor_listen_tls(host, port, http_mode, cert, key, ca, require_client)`
    loads the server cert/key (and optional CA) from files; a non-empty CA
    turns on client-cert verification, `require_client` makes it MANDATORY
    (`MBEDTLS_SSL_VERIFY_REQUIRED`) = the mutual half. Bridge
    `stzenginereactorlistentls`; Ring `stzReactor.ListenHttpTls` /
    `ListenHttpsServer`, `stzAppServer.StartTls` / `StartHttps`.
  - VERIFIED end-to-end: a real external `curl` client GETs
    `https://localhost:44300/health` -> `ok:tls:GET` (server terminated TLS,
    decrypted, routed, re-encrypted); WITHOUT the CA it is correctly rejected
    (curl exit 60); plain HTTP to the TLS port fails. Plain-HTTP path
    unregressed (reactor + cluster fleet suites green).

- **Slice 3 (DONE 2026-07-15): TLS client with client-cert presentation.**
  - REVISED backend: NOT curl. The vendored curl uses Schannel, which can't
    present a PEM client cert (it wants a Windows cert-store reference), and
    switching curl's global backend to mbedTLS would risk the existing
    Schannel outbound-HTTPS path. So node-to-node mTLS gets a DEDICATED
    mbedTLS client -- the symmetric counterpart to slice 2's server.
  - `reactor_tls_request(host, port, req, cert, key, ca, verify)`: a
    synchronous mbedTLS request over `mbedtls_net` (blocking socket). It
    PRESENTS this node's client cert (cert/key) for the server's mutual
    check, VALIDATES the peer's server cert against `ca` when verify != 0
    (hostname via SNI/`ssl_set_hostname`), sends the request, and reads the
    Content-Length-framed response. Bridge `stzenginereactortlsrequest` +
    `...tlsclientstatus`; Ring `stzReactor.TlsRequest`/`TlsGet`/
    `TlsClientStatus`.
  - VERIFIED end-to-end vs a mutual slice-2 server (CA + CA-signed leaf):
    GENUINE (present cert + verify) -> served `ok:mtls`; MISSING client cert
    -> server refuses (empty response -- enforced server-side; under TLS 1.3
    the client handshake still completes, so the RESPONSE BODY, not the
    status, is the authoritative "let in?" signal); WRONG CA -> client aborts
    the handshake (status -2). Mutual authentication both directions.

- **Slice 4 (DONE 2026-07-15): federation over mTLS + end-to-end suite.**
  - `stzComputeFederation.SetMutualTls(cert, key, ca)`: `FederatedCall` now
    transports over the mutual mbedTLS channel (`TlsGet`) instead of curl,
    parsing the response with `_SplitHttpResponse` to keep the body/status
    contract. Node identity = its cert; trust = the shared CA. Combined with
    governance (SLA) + request signing (per-request auth), a federated call
    is now ENCRYPTED + MUTUALLY CERT-AUTHENTICATED + SIGNED + GOVERNED.
  - Narrated suite `base/test/cluster/mtls_narrated.ring` (15 assertions,
    green): spawns a REAL mutual-TLS worker process and drives it as a TLS
    client (genuine served; missing client cert refused; wrong-CA aborted),
    then over a governed federation (served 200 over mTLS + signed + Why
    records mTLS; governance still gates a critically-governed facet); plus
    deterministic connect-failure + bad-cert-file edges.
  - RESIDUAL (deliberately not done): feeding the validated peer-cert CN in
    as the governed caller identity. Request signing (7.4) already
    CRYPTOGRAPHICALLY BINDS the caller (HMAC over a per-caller secret), so
    the cert-CN-as-identity is largely redundant; the transport is
    cert-authenticated, the caller is signature-authenticated. Exposing
    `oReq.PeerCommonName()` is a small future add if a deployment wants the
    cert subject itself as the principal.

## Status

mTLS COMPLETE (slices 1-4, 2026-07-15). Node-to-node traffic can run fully
encrypted + mutually authenticated; the federation transport does so under
governance + signing. Honesty note (historical): before slice 2 the reactor
server spoke plain HTTP and request signing (7.4) was the only node-auth
mechanism -- that gap is now closed for TLS-configured paths.
