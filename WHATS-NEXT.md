# What is next here

**Generated 2026-08-16 19:33 by Central** (`D:\GitHub\softanza\dashboard\central.ps1`).
Do not edit -- it is rewritten. Regenerate it any time:

```
powershell -ExecutionPolicy Bypass -File D:\GitHub\softanza\dashboard\central.ps1 -Install -Only stzlib
```

**If you are asked what is next, answer from this file** -- and if it looks old,
regenerate it first. The full cross-repository picture is in
`D:\GitHub\softanza\prompts\QUEUE.md`; the discipline is in `softanza\protocol\README.md`.

## Facts, read when this was written

- Reference design: **v1.5** (from `REFERENCE_DESIGN.md`)
- The UI law: **v3.11, 122 rules** (from `stzzui/constitution/rules.json`)
- The placement contract: **v1.0** (from `contracts/placement.md`)

**Where a prompt disagrees with this repository, this repository is right.**

## Do these one at a time, in order

### 1. Commit the sound residue -- 5 files, minutes of work

*Session: Sound and Voice session*

The smallest holding, which is the only reason it goes first -- the order runs smallest to largest, and the graphics row says why that matters.

<details><summary>the prompt</summary>

```text
Commit what you are holding in this repository, and only your own plane.

Which paths are yours is in the ownership map in D:\GitHub\softanza\protocol\SCOPES.md, and the current counts are on the board -- but you know your own tree better than either. Where they disagree with what you see, you are right. base/test/ and base/doc/ are shared with three other sessions: stage the files you wrote, never the directory.

Never git add -A, git add ., or git commit -a. Before writing any file you did not create in this session, re-read it from disk first: a stale copy written back over a newer version is how an edit was silently lost here on 2026-08-15.

Then tell me which paths you committed and what you are still holding.

Last, append one line to D:\GitHub\softanza\dashboard\SESSION-LOG.md in the format that file documents -- when, who, what happened, what remains. Append only; never rewrite a line that is already there. Central reads it to learn what you concluded, which no amount of reading your commits can tell it.
```

</details>

### 2. Commit the GUI residue -- 8 files

*Session: GUI implementation session*

This was the dangerous row while the vendored tree was uncommitted. That landed, so it is now among the cheapest.

<details><summary>the prompt</summary>

```text
Commit what you are holding in this repository, and only your own plane.

Which paths are yours is in the ownership map in D:\GitHub\softanza\protocol\SCOPES.md, and the current counts are on the board -- but you know your own tree better than either. Where they disagree with what you see, you are right. base/test/ and base/doc/ are shared with three other sessions: stage the files you wrote, never the directory.

Never git add -A, git add ., or git commit -a. Read git diff --cached --name-only before you commit and check every path on it is yours. Before writing any file you did not create in this session, re-read it from disk first: a stale copy written back over a newer version is how an edit was silently lost here on 2026-08-15.

Then tell me which paths you committed and what you are still holding.

Last, append one line to D:\GitHub\softanza\dashboard\SESSION-LOG.md in the format that file documents -- when, who, what happened, what remains. Append only; never rewrite a line that is already there. Central reads it to learn what you concluded, which no amount of reading your commits can tell it.
```

</details>

### 3. Commit the list and language work -- about 65 files

*Session: general tasks session*

Its folders touch no other plane, so the only shared surface it meets is base/test.

<details><summary>the prompt</summary>

```text
Commit what you are holding in this repository, and only your own plane.

Which paths are yours is in the ownership map in D:\GitHub\softanza\protocol\SCOPES.md, and the current counts are on the board -- but you know your own tree better than either. Where they disagree with what you see, you are right. base/test/ and base/doc/ are shared with three other sessions: stage the files you wrote, never the directory.

Never git add -A, git add ., or git commit -a. Before writing any file you did not create in this session, re-read it from disk first: a stale copy written back over a newer version is how an edit was silently lost here on 2026-08-15.

Then tell me which paths you committed and what you are still holding.

Last, append one line to D:\GitHub\softanza\dashboard\SESSION-LOG.md in the format that file documents -- when, who, what happened, what remains. Append only; never rewrite a line that is already there. Central reads it to learn what you concluded, which no amount of reading your commits can tell it.
```

</details>

### 4. Commit the graphics residue -- about 126 files, the largest holding

*Session: Graphics engine session*

The largest holding, which is the only reason it goes last: base/test is shared by four sessions, and the biggest stage is the one most likely to sweep in files belonging to somebody else. Running it last means the other three are already committed, so a mistake here is recoverable rather than a loss. Live counts are in the folder table below.

<details><summary>the prompt</summary>

```text
Commit what you are holding in this repository, and only your own plane.

Which paths are yours is in the ownership map in D:\GitHub\softanza\protocol\SCOPES.md, and the current counts are on the board -- but you know your own tree better than either. Where they disagree with what you see, you are right. base/test/ and base/doc/ are shared with three other sessions: stage the files you wrote, never the directory.

Never git add -A, git add ., or git commit -a. Before writing any file you did not create in this session, re-read it from disk first: a stale copy written back over a newer version is how an edit was silently lost here on 2026-08-15.

Then tell me which paths you committed and what you are still holding.

Last, append one line to D:\GitHub\softanza\dashboard\SESSION-LOG.md in the format that file documents -- when, who, what happened, what remains. Append only; never rewrite a line that is already there. Central reads it to learn what you concluded, which no amount of reading your commits can tell it.
```

</details>

### 5. Decide who owns base/doc/ -- 153 files nobody has claimed

*Session: whichever session the author names*

The largest single holding left, and the only one with no owner: narrations 98, quickers 22, misc 8, deepdives 8, design 8, internals 4, references 3. Four sessions write documentation and none of them has claimed this. Until somebody does, it is the residue that keeps the tree dirty.

<details><summary>the prompt</summary>

```text
Before committing anything under base/doc/, tell me what is in there and who wrote it: git status --short on that path, grouped by subdirectory, with your reading of which plane each group belongs to.

Do not commit it yet. base/doc/ holds 153 uncommitted files across narrations, quickers, misc, deepdives, design, internals and references, and no session has claimed ownership. If it is all yours, say so and commit it by explicit path. If it is not, say which parts are not, so the right session takes them.

Then append one line to D:\GitHub\softanza\dashboard\SESSION-LOG.md recording what you found and what you committed.
```

</details>

## After the sequential list, these may run together

### Fix six verified defects in locale and regex

*Session: general tasks session*

Already verified and written up. The two areas are independent of each other and of everything else running.

<details><summary>the prompt</summary>

```text
Read D:\GitHub\softanza\prompts\23-stzlib-locale-and-regex-defects.md and carry it out.

Commit only your own plane, staging by explicit path as before. Where the prompt and this repository disagree, the repository is right: report the divergence rather than forcing the prompt.

Last, append one line to D:\GitHub\softanza\dashboard\SESSION-LOG.md in the format that file documents -- when, who, what happened, what remains. Append only; never rewrite a line that is already there. Central reads it to learn what you concluded, which no amount of reading your commits can tell it.
```

</details>

### Build the semantic colour seam

*Session: Graphics engine session*

The sound plane shipped all five of the laws semantic values; the colour plane implements four and has no muted. The law is now at v3.11, which moved chrome to Rule 3 and left Rule 118 owning only what a colour says about a record.

<details><summary>the prompt</summary>

```text
Read D:\GitHub\softanza\prompts\22-stzlib-graphics-semantic-colour.md and carry it out.

Commit only your own plane, staging by explicit path as before. Where the prompt and this repository disagree, the repository is right: report the divergence rather than forcing the prompt.

Last, append one line to D:\GitHub\softanza\dashboard\SESSION-LOG.md in the format that file documents -- when, who, what happened, what remains. Append only; never rewrite a line that is already there. Central reads it to learn what you concluded, which no amount of reading your commits can tell it.
```

</details>

### Act on the .stzui finding that StzZui raised

*Session: GUI implementation session*

This session built .stzui and StzZui has now answered it. Confined to one plane, so it cannot collide with the other two.

<details><summary>the prompt</summary>

```text
Read D:\GitHub\softanza\prompts\21-stzlib-gui-stzui-finding.md and carry it out.

Commit only your own plane, staging by explicit path as before. Where the prompt and this repository disagree, the repository is right: report the divergence rather than forcing the prompt.

Last, append one line to D:\GitHub\softanza\dashboard\SESSION-LOG.md in the format that file documents -- when, who, what happened, what remains. Append only; never rewrite a line that is already there. Central reads it to learn what you concluded, which no amount of reading your commits can tell it.
```

</details>

## Ready now, independent of everything else

### Settle what a renderer owes the file it writes

*Session: Graphics engine session*

Filed as evidence rather than design, so it is cheap and it has no precondition.

<details><summary>the prompt</summary>

```text
Read D:\GitHub\softanza\prompts\29-stzlib-graphics-raster-encoding.md and carry it out. Commit by explicit path; append a SESSION-LOG line with what you concluded.
```

</details>

### Run the decode-physics gate that everything commercial waits on

*Session: binary plane session*

RINGBOL is ratified but its charter cannot open until this plane reaches BN2, and BN0 has not been run. It is the only gate in the programme with a commercial offering behind it. BN1 also carries a real defect: silent 4KB truncation in the bytes bridge.

<details><summary>the prompt</summary>

```text
Continue the binary plane: run the BN0 decode-physics gate as specified in SOFTANZA_BINARY_PLAN.md section 5, then BN1 including the silent 4KB truncation in the bytes bridge.

Context you may not have: the author ratified RINGBOL on 2026-08-16 as the second commercial offering, and its charter is gated on BN2 closing green. This plane is now the critical path for that, which is a reason to be careful rather than fast.

Commit by explicit path. base/test/ and base/doc/ are shared with three other sessions. Append a SESSION-LOG line when BN0 closes, stating green or not and what it cost.
```

</details>

## Talking back

Your mailbox is `D:\GitHub\softanza\mailbox\stzlib-<your plane>.md`. Open it now and keep it open --
that is what makes Central's appends arrive as messages.

Disagree by appending a `COUNTER` block **with the local fact Central cannot see**;
a preference is not a counter. Central answers with `ACCEPT` or `INSIST`; you then
`CLOSE`. Three messages, never a fourth, and you never counter twice. **If Central
does not answer, proceed and record what you did.**

Report conclusions -- not activity -- as one line in `softanza\dashboard\SESSION-LOG.md`.
