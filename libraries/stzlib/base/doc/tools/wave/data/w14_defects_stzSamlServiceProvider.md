# Wave 14 (agent w14e) -- defects found while documenting the SAML, sentinel, responder, DLM, LLM port and agent-graph classes

Found by calling the methods with invented data (invented identities, a key generated in-process, an in-memory ledger, no network). Nothing was fixed; each is recorded as a warning in the doc block. Defects 1, 3 and 4 were confirmed by a second call with different data; the others were reproduced from one scenario each (stated in Evidence) and read against the code.

## stzSamlServiceProvider (security/stzSaml.ring)

1. **AuthnRequest / AuthnRequestAt: IssueInstant is not a date and ignores pnNow.**
   Symptom: `AuthnRequestAt("_a1", 1795555555)` and `AuthnRequestAt("_abc", 1790000000)` both write `IssueInstant="1792011..."` (the current clock in milliseconds), never an ISO date, never the moment given.
   Cause: the private `_Iso(pnEpoch)` of the service provider returns `"" + StzEngineTimeNowMs()` and drops its argument (the identity provider class has the correct civil-from-days `_Iso`).
   Evidence: two calls above, the attribute differs from pnNow and has 13 digits. A real identity provider rejects an xs:dateTime that is not one.

2. **AuthnRequest / AuthnRequestAt: values written into attributes without XML escaping.**
   Symptom: `AuthnRequestAt('_a"b<c', ...)` yields `ID="_a"b<c"` (the attribute is closed early and a `<` sits inside it); a second call with `_a1` is well formed.
   Cause: pcRequestId, the destination (IdpSsoUrl), the consumer URL and the entity id are concatenated raw.
   Evidence: output of the call above. The id normally comes from NewRequestId (hex), so it is reachable only when a caller passes its own id, but the URLs are configuration that may hold `&` (a query string) and would produce invalid XML.

3. **ConsumeXml / ConsumeXmlAt / ConsumeResponse: the nameid is returned still XML-escaped.**
   Symptom: an assertion issued for the subject `x&y` is consumed as `x&amp;y`; `a"b<c>&d@x.test` comes back as `a"b&lt;c&gt;&amp;d@x.test`.
   Cause: the engine's `StzEngineSamlVerify` returns the element text without decoding entities (raw record: `1||https://idp.invented.test|x&amp;y|...`).
   Evidence: both subjects above. A service that uses the nameid as a user key will see a different name from the one the identity provider vouched for whenever it holds `&`, `<` or `>`.

## stzSamlIdentityProvider (security/stzSamlProvider.ring) -- checked for the OIDC-style injection, none found

Subject and audience go through `_Esc` (`&`, `<`, `>`): the subject `a"b<c>&d@x.test` is written as `a"b&lt;c&gt;&amp;d@x.test` in `<saml:NameID>`, the assertion signs and verifies, and a signature over a changed subject fails ("the digest does not match"). A quote needs no escape in element content and is left alone. A subject built to shift the engine's pipe-separated verdict (`mallory|https://sp...|<dates>`) comes back from the engine with the bars turned into underscores, so the audience seen by the service provider stays the real one (it refused: audience mismatch). The issuer entity id (operator configuration) is written without escaping; not request-reachable.

## stzDLM (learning/stzDLM.ring)

4. **LearnEntity / LearnFact keep names as written, Ask and Complete lower-case what they receive.**
   Symptom: `LearnEntity("Pizza","dish")` then `Ask("what is pizza")` refuses ("outside the 'c' domain, I know 1 entities"); `LearnEntity("Sushi","dish")` + `LearnFact("Sushi","contains","rice")` then `Ask("sushi contains?")` refuses and `Complete("sushi")` and `Complete("Sushi")` both answer `[ ]`.
   Cause: ForgeFrom lower-cases every name before learning, the hand-built path does not; the matching compares lower-cased input with stored names.
   Evidence: the two cases above. A model built by hand with capitals is silently unreachable.

5. **LearnLaw: laws are stored and saved, never applied.**
   Symptom: with `a contains b`, `b contains c` and `LearnLaw("contains","transitive")`, `Ask("a contains")` answers `A contains b.` only.
   Cause: no method reads `@aLaws` except Save; the comment above Ask promises "direct, then lawful chain".
   Evidence: the call above.

6. **Save / LoadFrom: a name containing a vertical bar is dropped silently on reload.**
   Symptom: `LearnEntity("x|y","t")`, Save, LoadFrom into a fresh model: the entity is absent, no error.
   Cause: the bundle line `x|y | t` splits into three parts and LoadFrom keeps only two-part lines.

## stzDlmSource (service/stzLlmPort.ring)

7. **Complete reports ok 1 for a refusal.** `Complete("what is the weather")` answers `[ ok 1, text "That is outside the 'restaurant' domain ...", from dlm ]`. Cause: Ask always returns a sentence, so the `_a_ = ""` branch (ok 0) is unreachable. The caller cannot tell an answer from a refusal without asking the model's `Why` or `AskXT`.
8. **The source keeps a copy of the model.** `LearnEntity("pasta","dish")` on the original after construction is not seen by `Complete("what is pasta")` (refusal). Ring copies an object on assignment (`@oDlm = poDlm`).

## stzLlmSandbox (service/stzLlmPort.ring)

9. **RecordFrom records a failed reply.** With a client in non-strict mode that answers `ok 0, text ""`, `RecordFrom` seeds an empty answer: `HasAnswerFor` becomes TRUE and `Complete` then answers `ok 1, text "", from replay`. Cause: `This.SeedAnswerQ(pcPrompt, _r_[:text])` runs whatever `_r_[:ok]` says.

## stzAgentHostResponder (security/stzResponsePlan.ring)

10. **QuarantinePart matches the agent name with case, IsQuarantined without.** An agent supervised as `Rogue-Bot`: `QuarantinePart("rogue-bot")` raises `not supervising 'rogue-bot'`, `QuarantinePart("AGENT:Rogue-Bot")` succeeds, and `IsQuarantined("rogue-bot")` then answers 1. Cause: `stzAgentHost.Quarantine` uses an exact `_IndexOf` while the quarantine record is stored lower-cased. A plan naming the agent in another case fails.

## Observations (not called defects)

- stzAuthResponder.LockAccount on an unknown user name locks that name and raises nothing; RevokeSession on an unknown name does nothing.
- stzAgentGraph.Grant refuses effectful for an llm actor only; a hybrid actor can be granted it and the graph stays sound if a guardian is on the path. Declaring an existing id again (AddLLMActor then AddPIActor on `x`) replaces the node and re-seals it, so MayGrant(`x`, effectful) then answers 1.
- stzLlmSandbox.SetStrict, SetFallback and the other non-Q setters return nothing (the Q form chains).
- stzSamlServiceProvider.ConsumeXml, unlike ConsumeResponse, does not raise when no identity provider is trusted; it answers a refusal ("expected exactly one Signature").
