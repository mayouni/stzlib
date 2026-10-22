# escape_sinks_rendered.html -- perceived

| when | who | how | what they said |
|---|---|---|---|
| 2026-10-22 20:47 | the Principal (Mansour Ayouni) | Chrome, opened as a file from the worktree | "I opened the page, every row reads as plain text" |

What the screenshot shows beside the words, read by the render plane:

- every corpus row renders as its own characters: the script row shows the angle brackets,
  the onerror row shows its quote and its tag, the closing-tag row shows both tags
- the last row, written through SetMarkup, is bold: the one declared door is visibly a door
- the bidi row reads **cba**: the override control (U+202E) passed through as text and reversed
  the reading order of the three letters. The oracle is right that it is text and not markup,
  and the eye is right that a reader was steered. A policy for the bidirectional controls in
  text sinks is an open question, recorded in SOFTANZA_RENDER_PLAN.md
- the NUL row reads **ab** and the controls row **a b**: both carried, both invisible

*Unperceived* became *perceived* here; the guard that writes the page stays the instrument.

## Second look owed

| when | who | what changed | verdict |
|---|---|---|---|
| 2026-10-22 | the Principal ruled "bidi: yes" | the bidi row now reads `[U+202E]abc[U+202C]`: the two controls are visible markers and no longer steer the text | **not yet perceived**: the page was regenerated after the policy was built; a person opens it and says what they see |
