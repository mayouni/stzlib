# mTLS smoke test certificates -- THROWAWAY, TEST-ONLY

`server.crt.pem` / `server.key.pem` are a **self-signed EC (P-256)** cert +
key generated solely for the in-memory handshake smoke (`../mtls_smoke.zig`,
run via `zig build mtls-smoke`). CN = `softanza-test-node`.

They protect NOTHING: no service presents them, they are not a CA, and the
key never leaves this repo's test build. They exist only so the smoke can
prove a real TLS handshake completes. Do NOT use them for anything real.

Regenerate:

    openssl ecparam -name prime256v1 -genkey -noout -out server.key.pem
    MSYS_NO_PATHCONV=1 openssl req -new -x509 -key server.key.pem \
        -out server.crt.pem -days 3650 -subj "/CN=softanza-test-node"

Slice 2 (real server-side TLS in the reactor) loads operator-supplied cert +
key paths at runtime -- never these.
