# SAML test vectors

Real artefacts, not fixtures we invented:

* `SIGNED.txt` -- a SAML 2.0 assertion **canonicalized by lxml (libxml2)** and
  **signed by OpenSSL 3.5** with the 2048-bit RSA key whose public parts are
  `RSA_N.txt` / `RSA_E.txt` (base64url). Neither tool is ours, so agreement is
  evidence rather than circularity.
* `TAMPERED.txt` -- the same document with one claim altered and the signature
  left untouched: the digest must fail.
* `WRAPPED.txt` -- a **signature-wrapping** attack: a forged assertion is
  injected beside the genuine one inside a Response. The signature still
  verifies over the original, which is exactly why "did it verify" cannot be the
  defense -- only *which bytes it covered* can be.

* `IDP_CERT.pem` / `IDP_CERT_BARE.txt` -- a real X.509 certificate over **the same
  key** that signed `SIGNED.txt`, in both PEM and the bare-base64 form XML
  carries. This is what closes the certificate loop: cert -> key -> verifies a
  genuinely signed assertion.

Regenerate with `scratchpad/gen_saml.py` (needs lxml + openssl).
Valid window: 2026-07-24T09:59:00Z .. 2026-07-24T10:05:00Z.
