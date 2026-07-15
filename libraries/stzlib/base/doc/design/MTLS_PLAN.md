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

- **Slice 2: server-side TLS termination in the reactor.**
  - A per-connection TLS state on the server `Conn`: `mbedtls_ssl_context`
    with BIO callbacks reading from / writing to the connection's libuv
    buffers. On accept, run the handshake as bytes arrive; once complete,
    the existing HTTP/1.1 framing runs over the DECRYPTED stream and writes
    go through `mbedtls_ssl_write`. Server cert/key loaded from files (a new
    `reactor_listen_tls(port, cert_path, key_path, ca_path, require_client)`).
  - Request a CLIENT cert (`MBEDTLS_SSL_VERIFY_REQUIRED` + a CA) = the mutual
    half. `require_client` toggles mTLS vs one-way server TLS.

- **Slice 3: client-cert presentation on outbound + Ring surface.**
  - curl already does one-way HTTPS; add client-cert options
    (`CURLOPT_SSLCERT/SSLKEY/CAINFO`) to the curl bridge so an outbound call
    presents this node's cert -> the peer's slice-2 server validates it.
  - Ring: `stzReactor.ListenTls(...)`, `stzAppServer.StartTls(...)`, and
    `stzAppCluster`/`stzComputeFederation` options to run the fleet + the
    federation transport over mTLS (cert paths per node, a shared CA).

- **Slice 4: identity + trust wiring + tests.**
  - Node identity = its cert; trust = the shared CA (or a pinned peer-cert
    set). Federation `FederatedCall` over https:// with mutual certs; the
    peer identity from the validated cert feeds governance (the caller name
    is then cryptographically bound, not asserted). End-to-end narrated
    tests: handshake success, wrong-CA rejection, missing-client-cert
    rejection, cert-expiry rejection.

## Honesty note

Until slice 2 lands, node-to-node traffic is NOT encrypted; request signing
(7.4) remains the operative node-auth mechanism. This doc + the code will not
claim wire encryption before the reactor actually terminates TLS.
