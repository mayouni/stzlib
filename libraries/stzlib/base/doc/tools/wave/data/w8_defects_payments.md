
## Wave 8 -- stzCardPaymentsAdapter, stzPayoutDesk (agent: amount / card / secrets / payouts / QR)

Nothing here was fixed (the payments code belongs to the stzlib-payments desk). Both are low severity: nothing raises, no money is wrong.

1. **stzCardPaymentsAdapter.Refund / RefundAmount -- a misleading refusal reason.**
   Symptom: refunding an authorization that is already fully refunded answers `[ ok 0, status refused, why "an amount must be a positive whole number of minor units" ]`, where `nothing left to refund` is the cause.
   Cause: with pnAmount = 0 the amount defaults to captured - refunded, which is 0 on the second full refund, and the sanity check on that default fires before the "exceeds what was captured" check.
   Evidence: `Authorize(4200)`, `Capture`, `Refund`, `Refund` again (probe on a stzPaymentsSandbox built with parentheses). The ledger is correct, only the text is.
   Documented as a warning on Refund.

2. **stzPayoutDesk.Commit -- the `rehearsal-differs` detail names a cause that cannot occur.**
   Symptom: the detail reads "visas were added after it, or it was edited", but visas added to the plan object after Rehearse never reach the desk: the desk stores a COPY of the plan at Rehearse (Ring copies on assign), so the stored plan and the rehearsed document stay equal and the commit goes ahead with the rehearsed visas (it is still safe: the later visa is simply not counted).
   Only an edit of the document inside the workbench produces `rehearsal-differs` (reproduced). The class comment says the same of visas.
   Documented as a warning on Rehearse ("visas added afterwards are not seen until it is rehearsed again").

Not defects, recorded because a reader trips on them (and documented in the blocks):
- `new stzPaymentsSandbox` / `new stzCardPaymentsAdapter` WITHOUT parentheses skips init, so every object built that way shares one gateway (id 0) and one ledger; with parentheses or StzPaymentsSandboxQ() each has its own. The state is a global table, so a copy (`w = o`) is the same gateway.
- `ApproveUnder`, `DeclineOver`, `DeclineToken`, `FailNext` return nothing; only their Q forms chain.
- After a refund `StatusOf` still reads `captured` (the answer of Refund says `refunded`); the refund shows in RefundedOf, NetCaptured and Movements.

## Wave 8 -- stzPaymentsPort, stzPaymentOrder, stzPaymentRequest, stzPaymentBatch, stzPaymentsProblem, stzWebhook (agent: port and builders)

Every root of the six classes was called with real data against the twin (stzPiSpiSandbox) or, for the transport case, an in-process stub backend. Nothing was fixed (comments only; the code belongs to the stzlib-payments desk). One finding, low severity, documented as a warning on the method:

1. **stzPaymentsPort.RequestPaymentsInBulk -- a transport failure is not remembered, unlike RequestPayment and PayInBulk.**
   Symptom: after the backend raises a `stzPispiHttpAdapter transport` error on the POST, `JournalSize()` stays 0, so the platform's retry sends the whole batch again instead of reading `/demandes-paiements-groupes/<id>` first.
   Cause: RequestPayment and PayInBulk wrap the POST in `try ... This._Lost(kind, key, cCatchError)`, which calls `_Remember` on a transport error; RequestPaymentsInBulk calls `_Call` bare and only remembers after a success.
   Evidence: a stub backend whose first POST raises `stzPispiHttpAdapter transport: connection lost`: RequestPayment then reports `JournalSize() = 1` and its retry is answered by the stub's POST/GET; RequestPaymentsInBulk reports `JournalSize() = 0`. What a real hub does with the repeated batch (a duplicate refusal or a second batch) was not run: no live hub was called.
   Documented as a warning on RequestPaymentsInBulk.

Not defects, recorded because a reader trips on them (and documented in the blocks):
- A re-sent txId answers the CURRENT state of the first payment and ignores the second order: `Pay` of an order with the same txId and a different amount (1000, then 9000) answers the 1000 payment with `replayed` 1. This is the port's stated design (the txId is the idempotency key), and is said in the note of Pay.
- `stzWebhook.AsBody` never raises: an empty webhook gives `[ [ "callbackUrl", "" ] ]`, and only the hub refuses it. Said in the note of AsBody.
- `DeleteWebhook` does not remove the secrets the port holds, and `RenewWebhookSecret` never drops the old key, so keys accumulate (the source comment says so). Said in the notes.
- The extractor's applier turned the section headings written as `  #-- governance: money out is a plan ---` (two dashes, not a box) into stray `#@ aka` lines (six of them, above the first method of each section). Left as the wave rules say; a boxed banner would avoid it.

## Wave 8 -- stzServiceRegistry, stzPiSpiSandbox, stzPispiHttpAdapter, stzPiSpiHttpFront (agent: registry, twin, live adapter, front)

Every root of the four classes was called with real data against the twin (in process, or served by stzPiSpiHttpFront on 127.0.0.1 with invented credentials), the registry against in-memory sandboxes and a store of invented secrets. No live hub was called; the https paths of the adapter and the front (StartTls) were exercised only by payments_live_adapter_narrated (125 assertions) with the engine's throwaway test certificates. No defect found: nothing raises that should not, no money is wrong. Nothing was fixed. Traps a reader meets, all said in the blocks:

- The plain forms `Declare`, `Bind`, `BindSandbox`, `BindLocal`, `BindLive`, `BindConformance`, `BindLiveWithCertificate` and `SetPhase` of stzServiceRegistry return nothing; only their Q forms chain (`Unbind`, `Undeclare` return the registry).
- `stzPispiHttpAdapter.WithCertificateFrom(poStore)` stores into the same field as `WithSecretsFrom`, so a different store passed to it replaces the credentials' store (read from the code, not run).
- An adapter never told `AsLive` or `AsConformance` answers no to `IsConformance` and to `RequiresCertificate`, so a registry binds it as live and does not look for a certificate (run: PostureOf answers live).
- `stzPiSpiHttpFront.EnableControl` opens `/_twin/` routes that ask for no credential; the sample comment says "loopback only", which only the host given to Start decides (read from the code).
- stzPiSpiHttpFront keeps its settings, tokens and counters in process-wide tables: a second front in one process shares them (read from the code).
- Over plain http the adapter sends any method other than GET, POST, PUT and DELETE as GET, and an answer that is not JSON comes back as a problem titled Not JSON (both read from the code, not run).
- The extractor's applier turned the `#-- title ---` section headings into stray `#@ aka` lines: 6 in stzServiceRegistry, 5 in stzPiSpiSandbox, 4 in stzPispiHttpAdapter. Left as the wave rules say.
