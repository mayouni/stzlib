# A number that says why it is not exact

*Mathematics · Chapter 7 · Skill CR-03: "Why did it say no?"*

A machine's number is a box of fixed size, and a value that does not fit is rounded to fit, silently. One
tenth does not fit. Softanza's number is different in one way that changes everything: it knows whether it
is exact, and when it is not, it can say what was lost and where. This chapter meets the machine's number
first, then the exact one, and lets the exact one explain itself.

## 1. The machine's number, caught

Add one tenth and two tenths on the machine and ask whether the result is three tenths. The machine says no,
and prints a value that looks like yes. Both answers come from the same rounding.

```ring
? 0.1 + 0.2 = 0.3
#--> 0
? 0.1 + 0.2
#--> 0.30
```

## 2. The exact number

Give the numbers as text and the library keeps them as decimals. The sum is three tenths, exact, and the
number says which representation it carries.

```ring
oS = StzNumberQ("0.1")
oS.Add("0.2")
? oS.Content()
#--> 0.3
? oS.IsExact()
#--> 1
? oS.Representation()
#--> decimal
```

## 3. Equal as numbers, not as text

Three tenths and thirty hundredths are the same number and different text. The exact number compares as a
number; Ring's equals sign compares the text.

```ring
? oS.Same("0.30")
#--> 1
? "0.3" = "0.30"
#--> 0
```

## 4. A division that cannot end

One divided by three never ends. The number stops at six places, says it is not exact, and says why.

```ring
oT = StzNumberQ("1")
oT.Divide("3")
? oT.Content()
#--> 0.333333
? oT.IsExact()
#--> 0
? oT.WhyNotExact()
#--> the division does not terminate in 6 decimal place(s)
```

## 5. Keep it as a fraction, and nothing is lost

Written as one over three, the number is rational and exact. Add two thirds and the result is one, and the
number says it is the same as one.

```ring
oQ = StzNumberQ("1/3")
? oQ.Representation()
#--> rational
? oQ.IsExact()
#--> 1
oQ.Add("2/3")
? oQ.Content()
#--> 1
? oQ.Same(1)
#--> 1
```

## 6. Past the machine's largest odd number

The machine's number cannot hold every integer above nine million billion: add one to an odd number there and
it lands on an even one. The library's big integer holds it.

```ring
oB = StzNumberQ("9007199254740993")
? oB.Representation()
#--> biginteger
oB.Add(1)
? oB.Content()
#--> 9007199254740994
? 9007199254740993 + 1
#--> 9007199254740992.00
```

## 7. Three tenths, three ways

One tenth times three is three tenths for the exact number, and not for the machine.

```ring
oM = StzNumberQ("0.1")
oM.MultiplyBy("3")
? oM.Content()
#--> 0.3
? oM.IsExact()
#--> 1
? 0.1 * 3 = 0.3
#--> 0
```

## 8. On your world

The share of transcripts among your school's requests, as an exact division: the number says whether the
share terminates, and why not when it does not. What it prints depends on the world this course runs over,
so the page shows no result: run it.

```ring
aReq = EduWorldObjects("requested")
nT = StzListQ(aReq).NumberOfOccurrence("transcript")
oW = StzNumberQ("" + nT)
oW.Divide("" + len(aReq))
? EduWorldName()
? oW.Content()
? oW.IsExact()
? oW.WhyNotExact()
```

{{exercise:math-07-01}}

## Recap

- **Achieved:** you caught the machine's number rounding one tenth, added the same tenths exactly, compared
  numbers as numbers, divided one by three and read why the result is not exact, kept a third as a fraction
  and lost nothing, and stepped past the machine's largest odd number.
- **Why it matters:** a number that says why it is not exact turns a silent rounding into a sentence you can
  read. Money, the next chapter, is where that sentence costs a centime when it is missing.
- **Coming next:** matrices as pictures. The next chapter draws a product as three grids and checks one cell
  of it by hand.
