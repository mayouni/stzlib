# Wave 13 (agent w13b) -- defects found while documenting, NOT fixed

Classes: stzIncident, stzOidcProvider, stzSecret/stzToken/stzPassword, stzSecurityGraph,
stzNeuralModel/stzNeuralChat, stzLLMFunction, stzOutputSchema, stzConversation, stzEntity,
stzComputeFederation. Each was called a second time with different data before being written
down. Library root: D:\GitHub\_wtd\libraries\stzlib\base (branch docs/reform). No code was changed.

stzIncident, stzSecurityGraph, stzOutputSchema, stzNeuralModel, stzNeuralChat, stzToken,
stzPassword and stzComputeFederation: no defect found by the calls made.

## stzOidcProvider

### IssueIdToken / IssueIdTokenAt (and so ExchangeCode / ExchangeCodeAt): no JSON escaping
- symptom: the subject, audience and nonce are concatenated into the token payload as raw text.
  `IssueIdTokenAt('al"ice', 'app"1', 'n"1', 100)` signs the payload
  `{"iss":"http://localhost:8099","sub":"al"ice","aud":"app"1","exp":3700,"iat":100,"nonce":"n"1"}`,
  which is not valid JSON. A backslash in the nonce (`n\1`) is written as is.
- worse, the nonce arrives from the authorization request unchecked: with the request nonce
  `x","sub":"evil`, Authorize then ExchangeCodeAt returned an ID token whose payload ends
  `"nonce":"x","sub":"evil"}` -- a second `sub` claim of the requester's choosing. Whether that
  second claim wins depends on the relying party's JSON parser.
- cause: `_pay_ = '{"iss":"' + @cIssuer + '","sub":"' + pcSubject + ...` in IssueIdTokenAt builds the
  JSON by string concatenation; there is no escape step (stzIncident has `_Esc` for the same job).
- evidence: scratch probes p3.ring (two runs, quote and backslash data); both runs on loopback in
  process, invented client `app1`, no key or code value printed.

## stzSecret

### IsResolvableBy raises instead of answering FALSE
- symptom: for a secret from a file that does not exist, and for a secret with no source set,
  `IsResolvableBy(HumanActor("alice"))` raises (`Secret 'kf': file source not found -- ...`,
  `Secret 'u' has no source set ...`). Its brief in the file says it tests whether the secret
  "resolves to a non-empty value".
- cause: it calls `_Resolve()`, which raises on those two sources. An unset environment variable
  does answer FALSE (it resolves to an empty text).
- evidence: p_sec.ring, two different secrets.

## stzLLMFunction

### ReturnsNumber: a reply whose first word is not numeric raises R41 inside Call_
- symptom: with a responder replying `about 42 years`, `3rd`, `none` or `x 3`, `Call_` raises
  `Error (R41) : Invalid numeric string` from `ring_number`, instead of refusing the reply and
  retrying within the budget. `42`, `42 years`, `-7` and `0.5` work; `1,5` reads as 1.
- cause: `_Validate` calls `ring_number(_cW_)` on each word; Ring raises on a non-numeric string, so
  the loop never reaches the later numeric word and never returns `[ 0, 0 ]`. The retry budget is
  skipped and the raw Ring error escapes.
- evidence: p_llm.ring, ten replies, retries set to 0 and responder `MyResp`.

### ReturnsBoolean: substring match makes some replies read as FALSE
- symptom: the reply `unknown` validates as 0 (FALSE), because it contains the letters `no`.
  `Absolutely` is refused. The check order is yes/true first, then no/false, as substrings.
- cause: `_Validate` uses `StzFind("no", _cT_)` on the whole reply, not a word match.
- evidence: p_llm.ring, replies `Yes`, `False`, `unknown`, `Absolutely`.

### minor
- the refusal text says `in N retries` where N+1 attempts were made.
- `RefuseUnknownFields()` does not invalidate the memo, so an answer memoized while the schema was
  open is still served after closing it (p_llm2.ring).

## stzEntity

### IsEmpty is never TRUE
- symptom: `new stzEntity([ :name = "n" ]).IsEmpty()` answers 0; so does every entity.
- cause: `IsEmpty` is `Size() = 2` ("only name and type") but init always adds a third property,
  `created`, so Size is 3 or more.
- evidence: p_en.ring, two entities with only default properties (Size 3 and 4).

### HasName and IsOfType are FALSE for any stored text with a capital letter
- symptom: after `SetName("Ana")`, both `HasName("Ana")` and `HasName("ana")` answer 0; after
  `SetType("Person")`, both `IsOfType("Person")` and `IsOfType("person")` answer 0. With lower-case
  stored values (`ana`, `person`) they answer 1 for any case of the argument.
- cause: `This.Name() = StzLower(pcName)` lower-cases only the argument, while SetName and SetType
  store the text as given.
- evidence: p10.ring, p_en2.ring, p_en3.ring.

### ContainsPropertyOrValue (and its aliases) raise for an argument that is not text
- symptom: `ContainsPropertyOrValue(30)`, `(5)` and `([1])` all raise
  `Incorrect param type! pcProp must be a string.` although 30 is a value of the entity;
  `ContainsValue(30)` answers 1.
- cause: it evaluates `This.ContainsProperty(p) or This.ContainsValue(p)` and ContainsProperty
  raises first; Ring does not short-circuit the call away.
- evidence: p_en.ring.

### observation (not a defect claim): init changes the list you pass
- `new stzEntity(h)` appends `type` and `created` to the caller's `h`, and overwrites a `created`
  you supplied with the current stamp. Copy therefore also resets `created`.

### unconfirmed: a doubled `@([ [ name, value ], [ name, value ] ])` call
- once, in a long probe (p_en.ring), the list-of-pairs form of `@` added `p1`, `p2` twice and a
  later `Copy()` then raised `paEntity mus tbe a hashlist` (duplicate keys). It did not reproduce in
  more than forty smaller variants (p6, p8, p9: sizes 0 to 8, every alias combination), so it is
  NOT written into any block. Recorded so that a later reader can look for the trigger.

## stzConversation (documentation divergence, not behaviour)
- the file header says the format `*.zcnv` is "the persisted transcript + state (Save/Load)", but the
  class has only Save, and Save writes the topic and the transcript lines; the goal state and the
  checkpoints are not written.
