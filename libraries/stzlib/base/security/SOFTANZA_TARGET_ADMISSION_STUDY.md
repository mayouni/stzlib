# Target admission: can Softanza's agent governance check where a side effect's target came from?

LOOKOUT-W45-SPILLWAY-01 · stzlib-security · 2026-11-13 20:36 · read at stzlib f939470a5 (GitHub main)

Source: Radar entry `2026-11-08-spillway-target-admission`; the paper, Woosang Lim et al., *SPILLWAY: Separating
Target Admission from Sanitization to Defend Tool-Using Agents against Prompt Injection*, arXiv 2611.07222, read in
its HTML full text on 2026-11-13. Every claim about this library below cites the line that holds it.

## 1. The rule in the paper

A tool call with side effects is admitted when every **target** value it names (an argument whose name the setting
lists as a target: recipient, channel, payee, participant...) either appears in the user's own request, or was
returned by a **read-only** tool in a **typed identity field** (an e-mail, URI, UUID, host or IP field, or a field
whose role is recipient, sender, participant or channel), and is not repeated in untrusted free text. Bodies,
subjects and descriptions never index. Values are casefolded and compared as whole tokens, by set membership. A
rule-based sanitizer removes forged chat turns and text addressing the agent; a local model, fail-closed, reviews
only the calls the rule refused, never one whose target sits inside a removed span. The authors report no in-scope
attack success on twelve AgentDojo settings.

Their own edges: the guarantee covers where an effect goes, not what it carries; an effect steered to a target that
already exists (a known contact) is outside it; an attacker who writes a typed field (sends the email) puts its own
address in the index; and the role vocabulary is written once per setting.

## 2. What Softanza holds today

**The governance gate sees names, never arguments.**

- `stzGovernance.MayProceed(pcActor, pcAction)` -- `base/governance/stzGovernance.ring:327` -- takes two strings and
  composes the action's risk tier, the actor's permission and its authority. No argument of the action reaches it,
  and `RecordDecisionAt` (528) stores no argument either.
- `stzPIAgent.Cycle` -- `base/agentic/stzPIAgent.ring:222-232` -- calls `MayProceed(@tName, _cAction_)` and then
  `_oSk_.Apply(@oMem)`. The target of the effect is computed INSIDE `Apply`, after the gate.
- `stzDeclaredSkill._Act` (`stzAgentDeclaration.ring:1511-1522`) runs `learn` / `forget` with the file's literal
  triple, or `ring:<F>` with the agent's memory as its only argument. A `ring:` function's target is invisible to
  everything outside it. `StzAllowAgentFunction` (137) decides by function name and posture, at load.

**A language model never acts.** There is no tool calling, function calling or MCP client in the library.
`stzLLMAgent.HoldsEffectful()` answers 0 (`stzLLMAgent.ring:94`); `stzAgentGraph.Grant` refuses an effectful
capability to an llm actor (`stzAgentGraph.ring:382-408`); a declared llm agent writes its proposal into its OWN
memory and stops (`stzAgentDeclaration.ring:1745-1748`). An `mcp:` block in a .pia file is refused as an unknown key.

So the paper's attack -- a model reads injected text and picks the target of a send -- has no direct path here. The
path that exists is **through memory and code**: a `ring:` function in a `when:` slot reads the world (an inbox, a
feed, a file) into the agent's memory, and a `ring:` function in a `does:` slot sends, pays or writes to a value it
recalls. Each agent's memory is its own (`stzPIAgent.ring:78`); values cross between agents only through
application code or the event bus (`stzAgentHost.SuperviseOnEvent`, 248).

**Memory already carries a source, and nothing reads it at a gate.**

- `stzAgentMemory.LearnXT` (`stzAgentMemory.ring:62-82`) records `:source` (default `agent:<name>`) and `:learnedat`;
  `ProvenanceOf(s, p, o)` (94) answers it; a strict knowledge graph can require it and it survives `.zknw` save/load.
- Every library write uses the plain `Learn`, so every fact reads `agent:<name>`: a seed fact from the declaration
  (`stzAgentDeclaration.ring:1299`, `1356`), a model's proposed field (1748) and whatever a `ring:` function learns are
  indistinguishable by source.
- No gate -- `MayProceed`, `Cycle`, `Apply`, the commit gate -- calls `ProvenanceOf`.

**One gate already sees concrete targets.** `stzUpdatePlan.Execute` (`base/system/stzVirtualSystem.ring:616-699`)
checks each rehearsed operation's executor posture, the reviewer, then `stzCommitScope.Reason(op)` against
`op.Impact()` -- the path, the from/to pair, the environment name or the spawn command -- and only then executes
(687). It covers file, environment and spawn operations made in the workbench. An operation carries its actor and
intent (52-57) and no origin for its parameters.

**The other sinks have no gate.** `StzFileWrite` (`stzFile.ring:62`), `stzSystemCall.Run` (`stzSystemCall.ring:305`),
`stzReactorHttpClient.Request` (`stzHttpPort.ring:499`), a mail port's `Send(to, ...)` (`stzMailPort.ring:97`) and
`StzBrokerRequest` are called directly. The credential broker binds a credential to its one host in the engine
(`cred_broker.zig` 336-345): a check on WHICH host, by grant, not on where the URL came from. The payout desk judges
amounts and visas, not the recipient (`stzPayouts.ring:418-440`).

**What the sanitizer half already has.** `StzChatSafeText` breaks every chat-template control token and tool-call
tag in untrusted text so that no special token can be written by it, keeping the words readable
(`base/neural/stzNeuralModel.ring:567-590`); PIACHECK refuses role-override phrases and hidden
text in a .pia file at load (`base/security/stzPiaCheck.haro`, threat-model G55). Neither marks what it removed.

## 3. What it would take

Three parts. Each stands alone; together they are the paper's floor, deterministic, with no model.

### Part A -- record where a fact came from (small; no new mechanism)

Give the three library writes their true source, with the `LearnXT` that already exists:

| write | today | proposed `:source` |
|---|---|---|
| a declaration's seed fact (`stzAgentDeclaration.ring:1299`, `1356`) | `agent:<name>` | `declared:<file>` -- trusted: the governance wrote it |
| a model's proposed field (1748) | `agent:<name>` | `model:<agent>` -- untrusted free text |
| a `ring:` function's write | `agent:<name>` | the function's own `LearnXT`; a read-only function that parses a typed identity field writes `read:<function>:<field-kind>` |

Cost: three call sites, one helper for the read-only case, a guard scene proving the three sources differ. It
changes no verdict -- it makes Part B possible.

### Part B -- name the target before the gate (the format grows: `pia: 3`)

The paper's per-setting list of target argument names becomes a declared clause. A governed skill says where its
target is:

    skills:
      - name: notify
        when: fact order status shipped
        does: ring:SendShippingMail
        effect: send-mail
        target: recall customer email

`stzPIAgent.Cycle` resolves `target:` from memory BEFORE `MayProceed`, and passes it to a new
`MayProceedTo(actor, action, target, source)`. The function then receives the target as a second argument and may
act only on it: a `ring:` function that ignores its target and reads another value defeats the check, so the
allow-list entry gains a flag saying the function honours its target (`StzAllowAgentFunction(name, posture, :targeted)`).

The admission rule, as the paper's, is a set lookup: the target is admitted when its fact's source is `declared:` or
`read:<...>:<identity kind>`, and refused when it is `model:` or `agent:`, or when the same value also sits in a fact
whose source is untrusted free text. The refusal joins the trace in the shape `Cycle` already writes, with the rule
named `target-admission`.

Cost: a format version (the vocabulary grows, so the version grows -- the ruling of `pia: 2`), the clause in the
judge and in `_ToPiAgent`, `MayProceedTo` in `stzGovernance` with the target in the decision record, the allow-list
flag, a guard. Medium: the largest part, and the part that makes the rule hold at the gate every agent already passes.

### Part C -- admit the target again at the sinks (the backstop)

For code that acts outside a declared skill, one function the sinks call while an agent cycle runs (`$cStzCaller` is
set, `stzPIAgent.ring:200-207`):

    StzAdmitTarget(tKind, tValue)   # "host", "path", "mail", "phone", "payee"

answering admitted or refused by the same rule, against the acting agent's memory. One line at each sink: the
broker (host), `stzUpdatePlan.Execute` beside `stzCommitScope.Reason` (path), a mail and SMS port wrapper (recipient),
the payout policy step (payee), `stzSystemCall.Run` (the command is not a target the rule can judge; it stays with
the spawn scope). Outside an agent cycle the function admits, so application code is unchanged.

Cost: a module and five call sites; the sinks are in the retired syntax and move with their modules, so each line
lands when its module is ported, or is the nine-line kind of wiring PIACHECK used.

### What not to build

- **The model judge.** Softanza refuses deterministically and writes the refusal into the trace; an agent whose
  target is refused tries again on its next tick with a better-sourced value, or a person releases it. A model asked
  to second-guess a refusal is a new surface the paper itself names as what an adaptive attacker would target.
- **A sanitizer that rewrites memory.** Part A marks model text as untrusted at the moment it is learned; the rule
  refuses on the mark. Rewriting the text would lose the evidence the paper keeps as a span set.

## 4. What it would and would not stop

It stops: a value read from free text (an email body, a feed item, a model's proposal) becoming the recipient,
host, path or payee of an effect.

It does not stop, exactly as in the paper: an effect sent to a legitimate target carrying injected content; an
injection that steers an effect to a target the agent already trusts; an attacker who writes a typed field the
reading function indexes (the sender of the email); and a `ring:` function that does not honour its declared target
(Part B's flag is the function author's claim, which code review checks). It reads what an agent did, not what a
person meant.

## 5. Recommendation

Do A, then B, then C. A is three call sites and a helper, and changes no verdict; B is where the rule meets the gate every governed skill
already passes, and it needs a format version the Principal's desk should see named before it ships; C is the
backstop for code outside declared skills and follows the module ports. Measure each with a narrated guard that
reproduces the path of section 2 -- a `when:` function reading an injected inbox into memory, a `does:` function
sending to the recalled value -- shown passing today and refused after.
