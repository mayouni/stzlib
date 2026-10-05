# Money that must not lose a centime

*Mathematics · Chapter 11 · Skill CR-02: "What would break if I were wrong?"*

Money is arithmetic with a rule attached: two places, always, and every rounding accounted for. The machine's
number has no such rule, so a thousand dimes added on it are not a hundred, and nobody is told. Softanza's
money number carries the rule with it: it rounds the way banks round, it says when a division did not end,
and when three shares do not add back to the whole, the difference is a centime you can see. This chapter
adds, shares, rounds and taxes an amount, and reads the centime each time.

## 1. A thousand dimes on the machine

Add a tenth a thousand times. The machine prints a hundred and says it is not a hundred.

```ring
n = 0
for i = 1 to 1000
	n += 0.1
next
? n
#--> 100.00
? n = 100
#--> 0
```

## 2. A thousand dimes as money

The money number keeps two places at every step. A thousand of them make a hundred, exactly, and the number
knows it is money.

```ring
oT = StzMoneyQ("0")
for i = 1 to 1000
	oT.Add("0.10")
next
? oT.Content()
#--> 100.00
? oT.Same(100)
#--> 1
? oT.IsMoney()
#--> 1
```

## 3. Share an amount three ways

A hundred and ten centimes shared three ways does not end. The money number stops at two places, says it is
not exact, and says why.

```ring
oP = StzMoneyQ("100.10")
oP.Divide("3")
? oP.Content()
#--> 33.37
? oP.IsExact()
#--> 0
? oP.WhyNotExact()
#--> the division does not terminate in 8 decimal place(s)
```

## 4. The shares do not add back

Three shares of 33.37 make 100.11: a centime appeared from nowhere. The number says the two amounts are not
the same, which is the sentence a ledger needs.

```ring
oS = StzMoneyQ("33.37")
oS.MultiplyBy("3")
? oS.Content()
#--> 100.11
? oS.Same("100.10")
#--> 0
```

## 5. The bookkeeper's rule: the last share takes the remainder

Give two people 33.37 and the third what is left. The three shares add back to the whole, and the centime is
accounted for instead of invented.

```ring
oZ = StzMoneyQ("100.10")
oZ.Subtract("33.37")
oZ.Subtract("33.37")
? oZ.Content()
#--> 33.36
? 33.37 + 33.37 + 33.36
#--> 100.10
```

## 6. Rounding the way banks round

A half rounds to the even neighbour: 2.675 goes up to 2.68 and 2.665 goes down to 2.66. Over a million
roundings, up and down cancel, and the total does not drift.

```ring
? StzMoneyQ("2.675").Content()
#--> 2.68
? StzMoneyQ("2.665").Content()
#--> 2.66
```

## 7. A tax, to the centime

A tax of 19.25 per cent on 100.10 is 19.269 and a quarter; as money it is 19.27, and the number keeps it as
an amount rather than a fraction of one.

```ring
oV = StzMoneyQ("100.10")
oV.MultiplyBy("0.1925")
? oV.Content()
#--> 19.27
? oV.IsMoney()
#--> 1
```

## 8. The regime that refuses

An exact number by regime will not become approximate: divide one by three and it refuses, by name, rather
than hand you a rounded third.

```ring
oX = StzExactQ("1")
try
	oX.Divide("3")
catch
	? "refused"
done
#--> refused
```

## 9. On your world

A fee of 2.50 on each request your school received this week, as money. What it prints depends on the world
this course runs over, so the page shows no result: run it.

```ring
aReq = EduWorldObjects("requested")
oFee = StzMoneyQ("2.50")
oFee.MultiplyBy("" + len(aReq))
? EduWorldName()
? oFee.Content()
```

{{exercise:math-11-01}}

## Recap

- **Achieved:** you added a thousand dimes on the machine and as money, shared an amount three ways and read
  why the division did not end, saw three shares make a centime from nowhere and gave the last share the
  remainder instead, rounded halves the way banks round, taxed an amount to the centime, and met the regime
  that refuses to approximate.
- **Why it matters:** a centime lost silently is a ledger that does not balance and nobody knows why. A
  number that carries the rule and says what it rounded is a ledger that explains itself.
- **Coming next:** a decision as a model. The next chapter says what to maximise and what to keep under, and
  lets the engine find the best plan and name the engine that found it.
