# Write a narration

*Elementary Introduction · Chapter 15 · Skills CR-01 "Does every example in my document still run?", CR-02 "What would break if I were wrong?" and CR-03 "Why did it say no?"*

Every chapter you have read was checked by running it, cell by cell, before it reached you. This last
chapter hands you the same instruments: a narration whose every cell runs, a guard with a positive and a
negative case, and a verdict that explains itself.

## 1. A narration is a text file with promises

A cell promises what it prints. The chapter runner runs every cell in a fresh process and compares.

```ring
cDoc = "# Mini" + char(10) + "```ring" + char(10) + "? 1 + 1" + char(10) + "#--> 2" + char(10) + "```" + char(10)
cMini = "t_mini_" + ProcessId() + ".en.md"
write(cMini, cDoc)
oCh = StzChapterQ(cMini, "en")
oCh.Run("")
? oCh.NumberOfCells()
#--> 1
? oCh.AllPromisesKept()
#--> TRUE
```

## 2. A broken promise is caught, not hidden

The same document with a wrong promise. The document does not become right by being written.

```ring
cBroken = "# Mini" + char(10) + "```ring" + char(10) + "? 1 + 1" + char(10) + "#--> 3" + char(10) + "```" + char(10)
cMini2 = "t_mini2_" + ProcessId() + ".en.md"
write(cMini2, cBroken)
oCh2 = StzChapterQ(cMini2, "en")
oCh2.Run("")
? oCh2.AllPromisesKept()
#--> FALSE
? oCh2.CellKept(1)
#--> FALSE
```

## 3. A guard has a positive case and a negative case

A check that can only pass proves nothing. The guard below would be red if the runner ever accepted the
broken document, and red if it ever refused the good one.

```ring
? oCh.AllPromisesKept() = 1 and oCh2.AllPromisesKept() = 0
#--> TRUE
remove(cMini)
remove(cMini2)
```

## 4. A verdict explains itself

The exercise checker of this course is one object. Hand it a promise and a program, and it says what
happened in the learner's own terms, never the expected value.

```ring
oNo = new stzExerciseCheck("demo", [ "3" ], "? 42", [])
? oNo.Passed()
#--> FALSE
? oNo.Why()
#--> Your program ran, but what it printed is not yet what the task asks. It printed: 42
oYes = new stzExerciseCheck("demo", [ "3" ], "? 1 + 2", [])
? oYes.Why()
#--> Every promise of the exercise was kept when your program ran.
```

{{exercise:ex-15-01}}

{{exercise:ex-15-02}}

{{exercise:ex-15-03}}

## Recap

- **Achieved:** you wrote a narration and ran it, watched a wrong promise get caught, wrote a guard with
  both a positive and a negative case, and read a verdict that names what was printed and not what was
  expected.
- **Why it matters:** a document that runs cannot drift from the code it describes. That is the law every
  page of this course obeyed, and now it is yours.
- **Coming next:** the level projects. A level is earned when a project of your own passes its guards.
