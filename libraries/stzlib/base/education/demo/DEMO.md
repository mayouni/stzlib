# The 15-minute demo: presenter's guide

This demo is for education decision makers: ministries, faculty boards and training directors. It runs on one
laptop, offline. Everything it shows is computed while it is shown.

## Before the meeting

```
cd libraries/stzlib/base/education/demo
ring demo.ring rehearsal
```

The last line must read `DEMO: 20 proved, 0 not proved`. If any line reads `NOT PROVED`, do not present. The
demo is telling you something is broken, and it would say so in front of the audience too.

## In the meeting

```
ring demo.ring meeting --pause
```

The demo stops after each scene. Press Enter to go on. Open `meeting/elementary-introduction.html` in a
browser at minute 2, and switch it to العربية to show the right-to-left layout.

| Minute | Scene | The sentence to say |
|---|---|---|
| 0–2 | Zero install | "One folder of plain text. Softanza is the only thing this laptop runs." |
| 2–4 | Their language | "The same chapter, run live in English, French, Arabic and Hausa. The Hausa learner writes Hausa." |
| 4–6 | Their world | "One file from your institution, and the chapter reasons about your bank, not a restaurant." |
| 6–8 | Nothing faked | "A wrong answer fails and a right answer passes, because the program was run, not read." |
| 8–10 | The tutor | "It will not give the answer. It asks the one question the learner is missing." |
| 10–12 | Safe AI | "A student's agent tried to delete the whole course. It could only propose; nothing was deleted." |
| 12–14 | All levels | "A nine-year-old's mission in Hausa, and a bank analyst's governance exercise, on the same engine." |
| 14–15 | Ownership | "Progress is a text file the institution keeps forever, and a pass cannot be forged." |

## What to say if asked

- **"Does it run in the browser?"** The page opens in any browser. Its cells run on the desktop today, and the
  page says so on every cell. Running them in the browser is the next step (E1b), and it depends on the
  Softanza browser engine.
- **"Is the Hausa, Arabic and French reviewed?"** Not yet. Every page says it is a draft awaiting a native
  reviewer, and the demo does not hide that.
- **"Does it need an AI model or the internet?"** No. The tutor uses Softanza's own reasoning. A model may be
  added later as an option, never as a requirement.

The demo's guard, `base/test/education/demo_narrated.ring`, runs it twice from a clean folder and checks that
the two runs say the same thing word for word.
