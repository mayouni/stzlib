# A3 measured: what each termination option buys and what it hurts — the K4 twenty tasks, Qwen2.5-Coder-1.5B-Instruct Q8_0

Greedy (temperature 0, seed 0), the Ring++ shape grammar ON, one worked example in the prompt, at most 320 new tokens per task. Port of the Ring++ session's local K4 (`_k4/`: the twenty tasks, their prompts and the grammar, exported as data 2026-10-21; judged on the Ring++ runtime binary, 10 s limit per program). One model, one seed, twenty tasks: **a difference of one or two programs is inside the noise.**

| arm | option | end marker written (of 20) | programs that PASS (shown + hidden data) | tokens generated | wall seconds* |
|---|---|---|---|---|---|
| `base` | none | **12** | **5** (T01 T04 T08 T16 T20) | 2,907 | 24,814 (throttled, contended) |
| `rp11` | `:RepeatPenalty 1.1` | 12 | 3 | 2,931 | 2,200 |
| `rp13` | `:RepeatPenalty 1.3` | **14** | **2** (T04 T16) | 2,717 | 14,506 (throttled) |
| `endbias` | `:EndBias 4` | 12 | 5 | 2,907 | 5,272 |
| `stop4` | `:StopOnRepeat 4` | 12 (6 runs ended early by the rule) | 5 | **1,529** | **1,310** |

\* `base` and `rp13` ran while the laptop's firmware held the CPU at 42–57 % of nominal, other jobs sharing it; `endbias`, `stop4`, `rp11` ran at 142–186 % (unthrottled). **Compare tokens, not seconds, across the first two rows.** `endbias` and `stop4` are the same hardware state, so their ratio is fair: `stop4` took **25 %** of the time.

The `base` arm reproduces the Ring++ session's own local-K4 numbers exactly (12 ended, 5 pass), which is what validates the port.

## What each option does, and what it hurts

- **`:StopOnRepeat 4` is the clear win and costs nothing measured.** It ended six looping programs early, kept all five passes, and generated **47 % fewer tokens** (1,529 against 2,907) in **25 % of the wall time** (1,310 s against 5,272 s on the same unthrottled hardware). *What it hurts*: a program that truly repeats a line four times running would be cut (none of these twenty did). *What it does not do*: it does not raise the end-marker rate — a program that loops never reaches its marker; the rule only stops the waste.
- **`:RepeatPenalty` buys end markers and pays in correctness.** At 1.3 it raised the end-marker count from 12 to 14, and cut the passes from 5 to 2 (T01, T08 and T20 stopped working); at 1.1 it changed nothing in the end-marker rate and cost two passes. *Why it hurts*: code legitimately repeats tokens (indentation, `next`, the loop variable), and a penalty on repeats taxes exactly that. The target of the task — raise the end-marker rate toward 19 of 20 **without losing a pass** — is **not met by any option**: the only option that raised it lost three passes.
- **`:EndBias` did nothing on this task**, identically to `base` on all twenty (same tokens, same results). Its premise — the model has finished and merely fails to stop — does not fit this grammar: the grammar becomes complete only after the model writes its `<<END>>` line, and a model that writes it already stops; a model that loops never gets there. It would help a grammar whose end is reachable without a model-written marker.

## What this says

The loops are the model's, not the decoder's, and a sampler-side nudge cannot give a looping program an ending it never wrote. The cheap, safe lever is **stop early and save the compute** (`:StopOnRepeat`); the lever that would raise the *rate* is upstream — a grammar that closes a program without a model-written marker, or a model that does not loop (the 1–4 B class). Machine: the author's laptop, RTX 3050 6GB Laptop; CPU state per arm is in `arms.log` beside this file's source run.
