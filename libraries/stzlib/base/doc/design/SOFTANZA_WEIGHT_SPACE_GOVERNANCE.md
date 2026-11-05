# Weight-space governance: the pattern ladder applied to a model's weights

*stzlib-intelligence, 2026-11-05. Written at the author's request after "Sparks of Weight-Space Programming"
(Takehi, Teoh, Zhang, Khattab, 2026-11-02) and before the spike WSP-SPIKE-01. Every number below was
measured on this machine on 2026-11-05; the scripts are named where the number is.*

---

## 0. The claim, in one paragraph

The paper showed that a frontier model can read a small network's weights and say what it was trained on,
and can edit a real model (Qwen3.5-0.8B, 131,072 weights of 0.8B) so that it stops looping. What it did
NOT show, and says it is still building, is the court such an edit needs: a harness that proves the edit
is what it says it is and that it helps. Softanza already owns that court -- the model-flow law (a rule
written before the judging set, strictly-beats-the-floor, judged once, both verdicts on record), the
ledger, the digests. And it owns something the paper's authors do not have: a **pattern family that names
shapes in numbers, lists, matrices and graphs** (`stzNumbrex`, `stzListex`, `stzMatrex`, `stzGraphex`,
`stzTablex`), bound to reactions by the **xuters** (`stzRegexuter`, `stzListexuter`) and, by the
architecture's rung 2, cascaded to a fixpoint by the **Softanzuter**. The thesis of this note: **a weight
is a number, a head is a vector, a layer is a matrix, a model is a graph of tensors -- so the ladder that
was built to recognise and react to patterns in data recognises and reacts to patterns in weights without
new machinery.** What it adds to the paper is not reading or writing (an LLM can do both); it is NAMING
the condition a model is in, NAMING the change made to it, and putting both before a court. That is what
"governance" means here, and it is the same word the agent doctrine uses: an LLM proposes, a governed
actor commits.

---

## 1. The ladder, rung by rung, with the measured example

The architecture defines the ladder (`SOFTANZA_INTELLIGENCE_ARCHITECTURE.md` 5.6): rung 0 the pattern
(pure recognition, "this matches, and here is how"); rung 1 the xuter (patterns over one medium bound to
code: a reflex arc, with provenance); rung 2 the Softanzuter (many xuters sharing a dependency-tracked
state, cascading to a fixpoint; a thought is a state entry with its provenance); rung 3 the agent (a
Softanzuter with a goal, a memory, tools and accountability). Applied to a model's weights:

| rung | over data (today) | over weights (this note) | the measured example (section 2) |
|---|---|---|---|
| 0 pattern | `Nx("{@Property(Prime)}")`, `Lx("[@N+, @S]")`, `Mx("{shape(square) & property(symmetric)}")` | a numbrex over one weight, a listex over a head's output across patches, a matrex over a layer, a graphex over the tensor graph | `Lx` over the 576 shift values of a picture: "the field is warm" (mean >= -0.60) |
| 1 xuter | `Lxu()`: a list pattern fires code and logs state | a pattern over a weight-derived vector fires a reaction: raise the threshold, refuse to answer with confidence, mark the answer "warm picture" | warm field -> the find threshold moves up for THIS picture; the ledger says why |
| 2 Softanzuter | planned (`stz_softanzuter`) | one xuter reads the heads, writes "warm"; another matches the thought history ("warm three pictures in a row from this camera"); a third proposes a patch; the fixpoint is the verdict with its Why | not built; the spike runs rungs 0 and 1 by hand and records what a rung 2 would cascade |
| 3 agent | `stzPIAgent` (programmatic mind), `stzLLMAgent` (neural faculties swapped in) | Aïcha: the neural faculty PROPOSES a weight edit (a direction, columns, a tensor); the governed actor commits it only after the court | the spike's court: three implementations, one rule, one judging run |

The industry version of the paper's method is "an LLM in a loop with a Python kernel and the weights". The
Softanza version is the same loop with the mind made programmatic where it can be (rungs 0-2 are
deterministic and explain themselves) and the LLM a pluggable faculty where it must be (finding the
direction). That is the architecture's own sentence about agents, applied to the model's own weights.

---

## 2. Measured: OWL-ViT's false alarms are a weight-readable condition

IM9f judged `:find` once: owlvit 252 of 320, with **9 false alarms in 151 absent words**. The paper's
first question -- can the weights say why? -- was asked of the two per-patch heads the vision graph
carries: `logit_shift` (768 -> 1) and `logit_scale` (768 -> 1, then elu + 1). A query's logit for a patch
is (e . q + shift) x scale, so shift is the patch's bias toward answering ANY word.

**Hypothesis 1, refuted: a false alarm is a "promiscuous" patch.** `_rig/owl_field_probe.ring` scored every
patch of four pictures against 30 words (the 9 false-alarm words, 11 COCO names, 10 unrelated). No patch
on any picture fires (p >= 0.08) for three or more of the 30. The false alarm is not a patch that says yes
to everything.

**Hypothesis 2, held: a false alarm is a WARM PICTURE.** The same probe, read per picture:

| picture | what LVIS says is in it | patches firing for >= 1 of 30 words | mean p over 576 x 30 | mean shift | mean scale |
|---|---|---|---|---|---|
| 000000012576 (2 false alarms: tinfoil, turtle) | pizza x3, knife, napkin, tablecloth | **53** | **0.00452** | **-0.53** | 12.6 |
| 000000000139 (a room) | cabinet x2, fireplace, television x2 | 34 | 0.00259 | -0.58 | 12.9 |
| 000000013004 (2 false alarms: pancake, tonic) | banana | 2 | 0.00080 | -0.63 | 13.7 |
| 000000001675 (the cat on the laptop) | cat, keyboard, laptop | 1 | 0.00018 | -0.73 | 14.1 |

The field of a picture is 25x warmer on the first than on the last, and the shift head says so BEFORE
any word is asked: the mean shift runs -0.53 to -0.73, and 0.2 of shift times a scale of 13 is 2.6
logits -- the whole distance between a false alarm at p = 0.08 and silence.

**Across the judging set** (`_rig/owl_heads.py`: the shift head on all 115 golden pictures, judging pictures
ranked by mean shift): **the 9 false alarms all fall in the warmer half -- 9 of 84 negatives there, 0 of
76 in the colder half**; the three warmest pictures carry 4 of the 9. Mean shift correlates only weakly
with how many objects LVIS counted (0.27): warmth is the model's own state, not a count of things.

So the paper's "read the weights" is, for this model, one head's output across 576 patches read as a
list -- a rung-0 pattern: `Lx` over the shift field. It is checkable, it explains itself (the mean and
where it falls), and it was found with no LLM in the loop.

**What this does NOT say.** Warmth found on the judging pictures is a FINDING, not a rule: a rule that
uses it is tuned on the DEV pictures only, committed, and judged on the judging pairs once (section 5).
And warmth explains the false alarms, not the misses (51 of 118 kind B positives): those are the
32-pixel patch's reach, which no head can read.

---

## 3. What the x-family can do today, and where it has to move

The honest reading of the code (2026-11-05):

- `stzMatrex` (2,084 lines of Ring) matches `{size(3x3) & property(symmetric) & element(0..10)}` on
  Ring lists of lists; `stzListex` (1,360) matches `[@N{1-10:3}, @S*]` with quantifiers, stepped ranges,
  negation, uniqueness; `stzNumbrex` matches one number's structure; `stzGraphex` (1,291) matches label
  paths with property constraints; `stzTablex` matches tables. All are Ring walking Ring lists.
- The two xuters bind those patterns to code and log a dependency-tracked state. The Softanzuter is
  PLANNED in the engine design (`stz_softanzuter`, trigger / computation / state / dependencies / evolve).
- The engine reads and writes GGUF (`stzengineneuralggufinspect`, `...modeltensorname`, `...ggufbegin /
  addtensor / write`), computes a file's SHA-256, and refuses to load a decoder whose digest is not the
  recorded one. It does not expose a tensor's VALUES to Ring, and the graph runtime
  (`ocr_graph.zig`) does not tap intermediate activations.

A 768 x 512 class head is 393,216 numbers; a 0.8B model is a thousand times that. **The x-family's
substance over weights therefore lives in the engine or it does not exist** (the standing law: the engine
is the product). The moves, each small and each guardable:

1. **Tensor values to Ring, by name and by slice** -- `StzEngineNeuralTensor(cModel, cName)` giving shape
   and dtype, and a slice `(..., nRow0, nRows)` giving numbers. Read-only; the first rung-0 instrument.
2. **A head's output across the input** -- for a graph model, the tensor at a named program step (the
   `logit_shift` output, a layer's MLP output) returned as a list: the shift field of section 2 without
   ONNX Runtime. This is the activation tap the paper's Qwen diagnosis needed (it found the loop
   direction from contrasting activations).
3. **Matrex and listex evaluated in the engine over f32 buffers** -- the same pattern text, a `stz_matrex`
   evaluator on a tensor handle rather than a Ring list, so `{property(symmetric) & element(-1..1)}` can
   be asked of a layer in milliseconds. The pattern language is the author's; only the walker moves.
4. **A weight PATCH as a named, replayable operation** -- `StzEngineNeuralPatch(cModel, cOut, aOps)` with
   ops of a closed catalogue: `remove-direction(tensor, columns, direction)`, `scale(tensor, factor)`,
   `set(tensor, index, value)`. The engine writes the patched GGUF, its digest, and a patch record; the
   ledger holds the record. The paper's Qwen edit is one `remove-direction` op.
5. **The patch's NEGATIVE SIBLING as a pattern** -- after a patch, `Mx("{property(unchanged)}")` over
   every tensor the patch did not name, and `{changed(rows=all, cols=c)}` over the one it did. A patch
   that touches what it did not declare is refused. This is the house rule "assert the mechanism, and
   give every positive a negative sibling", applied to a weight edit.

Only 1, 2 and 4 are needed for the spike. 3 and 5 are the family's own next rung and are listed so that the
spike does not quietly build a second pattern language in Zig.

---

## 4. Small LLMs: the loop is a listex pattern, and the fix is a named op

The paper's one edit of a real model fixed looping. Softanza ships small decoders in its own runtime
(SmolVLM-256M and -500M's llama decoders, Granite-Docling-258M) and already met the loop: Granite looped
on 3 of its first 31 golden pages to the 3,072-token cap, and the fix was **a stop on an identical line N
times in a row** (`$nStzVisionDocStopRepeat`). That stop IS a rung-0 pattern over the token list --
`Lx("[@A, ... , (@L)3]")` in spirit, "the same run three times" -- bound to a rung-1 reaction (stop, record).
What the paper adds is the rung above it: when the pattern fires often, PROPOSE a weight edit that removes
the cause, and put it before the court. The Softanza shape of that:

- rung 0: the loop pattern over the generated ids (listex) and, with move 2 of section 3, the "loop
  direction" as a pattern over the activation history (the direction written by two MLPs, in the paper);
- rung 1: stop the generation, log the pattern's firing with its Why (which run, which layer's direction);
- rung 2: across a session, "this model loops on page-like inputs" settles as a thought; the Softanzuter
  proposes `remove-direction(mlp15.out, cols, d)` and `remove-direction(mlp19.out, cols, d)` -- a named op,
  not a free-form weight dump;
- the court: the patched decoder enters the registry as `granite-docling-258m+noloop`, judged on the
  doc-vlm golden under the rule already there (`doc-blocks`), and answers only if it strictly beats the
  unpatched one. The Gemma result in the paper (an edit cannot ADD an ability) is the expectation to write
  down beforehand: a loop fix may raise completion without raising correctness, and the rule must say
  which it is judging.

Nothing here needs a frontier model. Finding the direction needs contrasting activations and a projection,
which is numpy today and the engine tomorrow; an LLM may propose the contrast set and may not commit.

---

## 5. Aïcha: the agent that proposes and never commits

Aïcha (the author's name for the Softanza language model and conversational agent; no shipped product yet)
is, by the ladder, a rung-3 agent whose cognitive core is a Softanzuter and whose neural faculties are
pluggable. Weight-space work gives Aïcha a precise role and a precise limit:

- **Aïcha may read.** Given moves 1 and 2, she can ask a model's weights the questions the paper asked --
  what is this head, which direction loops -- and her answers are HYPOTHESES carrying their provenance.
- **Aïcha may propose.** A proposal is a patch record (section 3, move 4): a closed-catalogue op on named
  tensors, with the pattern that found it and the pattern that will check it.
- **Aïcha may not commit.** The commit is the court's: a rule written before the judging set, a fresh set,
  one run, both verdicts on record, the registry's choice from the measurement alone. This is the
  agent-doctrine ruling (`CENTRAL-AGENTDOCTRINE-01`) word for word: an llm actor holding an effect is
  refused by `stzAgentGraph.Grant`'s own sentence.
- **Aïcha may be the SUBJECT.** A small Aïcha (a house decoder) is a model whose weights the same ladder
  reads; a loop in her, a sycophancy in her, is a pattern her own Softanzuter can fire on. The clinical
  paper's limit stands and is written into the doctrine: the ladder can LOCATE and REPAIR a named flaw; it
  cannot CERTIFY a model correct, and no page of hers may say otherwise.

---

## 6. The spike, re-designed on the finding -- WSP-SPIKE-01

The question the spike answers: **does a weight edit, governed by the court, beat both the model as it is
and a classical reaction to the same reading?** Three implementations of `:find`, one rule, one judging
run on the 320 pairs already on record (they have not been retuned; the thresholds of the two new
implementations are chosen on the 40 DEV pictures only):

| implementation | what it is | rung |
|---|---|---|
| `owlvit` | the model as judged in IM9f: threshold 0.08 (the incumbent, 0.7875) | -- |
| `owlvit+warm-rule` | the same weights; a listex over the shift field fires when the picture is warm and the threshold for that picture moves up by a step chosen on DEV | 0 + 1 |
| `owlvit+shift-patch` | the `logit_shift` head's 768 weights with ONE direction removed -- the direction of the warm pictures' patch features, found on DEV by contrast (warm vs cold pictures), applied by the engine's patch op, digest and record in the ledger | the paper's method, named |

**The rule, written here before any of the two new implementations ran:** share of the 320 judging pairs
that agree under `find-f1` (the checker is unchanged). The incumbent's share is 0.7875 and is the floor
both must STRICTLY beat; the one with the higher share is chosen; the shares by kind and polarity are
recorded beside the verdict whichever way it goes, and the false-alarm count is reported but is not the
bar (a rule that only counts false alarms is met by saying nothing). The patch must pass its negative
sibling: every tensor but `logit_shift.weight` byte-identical, verified by digest of each tensor. A miss is
recorded as a miss; nothing is retuned on the judging pairs.

**The DEV choice, made 2026-11-05 and committed before the judging run** (`image_wsp_dev.ring`, 136 DEV pairs; the incumbent is 0.7647 there):
the warm rule reaches 0.7868 on seven cells of its grid; the tie is broken, by a rule stated here and not before, toward the LEAST intervention --
the smallest step, then the warmer cut, so fewer pictures are touched: **cut -0.60, step 0.02**. The patched head reaches **0.8235 at threshold
0.08** (positives 44 of 68, negatives 68 of 68), the best of its grid and above both others -- on the pictures its direction was found on, so
the number is in-sample and proves nothing yet. The patched file is `models/vision/owlvit_vision_shiftpatch.gguf`, sha256 `45e95652f5d6af249a101eec2ebfd08296ed6e289eac195a1d90fc219b4d2c63`, replayable
from `_golden/owl_shift_direction.txt` by `StzEngineNeuralPatchRemoveDirection(c210, column 0)`; it loads only with that digest. Found on the way,
and fixed: `owl.zig` kept a picture's graph output keyed by the pixels alone, so a patched model was served the original's features (its first
DEV sweep read exactly the incumbent's numbers, which was the tell); the key now holds the model file too.

What is built for it, in order: section 3's move 1 (tensor values to Ring), move 2 for the shift head's
output (the engine already computes it inside `owl.zig`: expose it), move 4 for the one op, the two
implementations in `stzVision.ring`, the guard, the page.

---

**THE VERDICT (2026-11-05, `image_wsp_judge.ring`, the 320 judging pairs, once).** The incumbent 252 (0.7875). **`owlvit+warm-rule` 252 (0.7875):
equal, not strictly above -- REFUSED.** It changed two pairs: one false alarm gone (flowerpot), one COCO positive lost (pizza). **`owlvit+shift-patch`
253 (0.7906): strictly above, BY ONE PAIR -- CHOSEN by the rule as written.** It changed nineteen: ten gained (six of the nine false alarms --
chandelier, flowerpot, bath mat, christmas tree, turtle, tonic -- and four positives: table twice, ladder, tablecloth) and nine lost (ski parka,
truck, pillow, headlight, sheep, painting, bowl, curtain, pizza). By kind: kind A positives 34 / 33 / 30 of 42; kind B positives 67 / 67 / 66 of 118;
kind B negatives 142 / 143 / 148 of 151. Both rows are in `vision.zmdl.txt`; the registry now resolves `:find` to the patched head because the
measurement says so, and the record beside it says what the measurement is worth:

- **a margin of one pair in 320 is noise.** The rule said "strictly more" and was applied as written -- that is the law's point, a rule is not
  re-read after the data -- but a reshuffle of 19 pairs with a net of +1 is not evidence the patch helps. The next rule written for a weight edit
  owes a MARGIN above the judging set's own noise (for 320 balanced pairs, a binomial band of about +-0.02 of share, nine pairs), stated beforehand.
- **DEV's 0.8235 did not transfer (0.7906).** The direction was found on the DEV pictures, so the DEV number was in-sample; the drop is the size of
  that bias, measured. A direction found on pictures the thresholds are not tuned on is the obvious next design.
- **what the patch did is exactly what it was named to do.** Six false alarms on warm pictures are gone; the price was paid in positives, mostly
  the floor's own words (kind A: 34 -> 30). The head stopped reading the warm axis for everything, not only for absent words -- a bias term cannot
  tell a present object from an absent one. That is the limit of editing a 768 -> 1 head, and it says where a real fix lives: in the class head
  (768 -> 512), or in the threshold itself as a function of the field, which is the warm rule, which did not beat the incumbent either.
- **the court worked.** Three implementations, one rule, one run, both verdicts on record, the digest of the patched file bound to its
  implementation, 211 of 212 tensors proven untouched by digest, the direction kept so the patch replays. This is what the paper's authors say
  they are building; it took a day here because the pieces existed.

The guard is `image_wsp_narrated.ring`; the page `_find-out/find_wsp.html` shows the shift field of four pictures as a 24 x 24 heat map over the
photograph, the six false alarms the patch removed and the nine positives it lost.

## 7. Limits, stated

- A pattern over weights proves the edit IS what it says (which tensors, which columns, which direction).
  Only the court proves it HELPS. The clinical paper's "cannot yet certify that a network is correct" is
  this note's law too.
- The x-family in Ring is for Ring-sized data. Over weights it is a language; its walker must be the engine.
- Warmth was found on four pictures and confirmed on 76; the rule that uses it is still tuned on 39 DEV
  pictures. Small numbers; the spike says so.
- No frontier-API key exists on this machine (the capabilities compass). Every direction in the spike is
  found by contrast and projection; what an LLM would add is the choice of contrast set, and that is left
  to a later, governed, Aïcha.
