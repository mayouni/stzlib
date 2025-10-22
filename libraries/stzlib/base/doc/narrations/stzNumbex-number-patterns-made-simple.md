# stzNumbrex: A Pattern Language for Numbers


Validating numbers can be a chore. Take RGB colors—three integers from 0 to 255. Usually, you'd write lots of code: check the list length, loop through each number, confirm it’s an integer, not negative, and not over 255. It’s long, repetitive, and error-prone.

### Old way to check RGB

```ring
func ValidateRGB(aColors)
    if len(aColors) != 3
        return false
    ok
    for i = 1 to 3
        n = aColors[i]
        if not isNumber(n) or n != floor(n)
            return false
        ok
        if n < 0 or n > 255
            return false
        ok
    next
    return true
end
```

Now imagine repeating this kind of validation for HTTP codes, test scores, or bank transactions.
Each case has its own logic, yet the code looks almost the same.

That’s where **stzNumbrex** (or simply **Nx**) comes in. It’s like *regular expressions*—but for numbers.
Instead of telling the computer *how* to check values, you describe *what you expect*.

```ring
? Nx("[@I(0..255)3]").Match([128, 64, 192])
#--> true
```

One short line captures the entire rule: “three integers, each between 0 and 255.”
Readable, declarative, and instantly verifiable.


## Understanding Number Patterns

Nx gives you a compact way to describe numeric sequences. Each token defines a *type* of number—integer, real, positive, even, etc.—and optional *quantifiers* tell how many such numbers to expect.

Want three integers?

```ring
? Nx("[@I3]").Match([1, 2, 3])
#--> true
```

If one of them is a real number, the pattern rejects it:

```ring
? Nx("[@I3]").Match([1.5, 2, 3])
#--> false
```

Need two real numbers instead?

```ring
? Nx("[@R2]").Match([3.14, 2.71])
#--> true

? Nx("[@R2]").Match([3, 2.71])
#--> false
```

You can even accept any kind of number—integer or real, positive or negative—with `@$`:

```ring
? Nx("[@$5]").Match([1, 2.5, -3, 0, 100])
#--> true
```

Patterns become your own shorthand for numeric expectations.


## Signs and Parity: Describing the Mood of Numbers

Numbers often carry a *sign* or a *nature*—positive or negative, even or odd. Nx makes these qualities expressible and enforceable.

Want only positive values?

```ring
? Nx("[@P+]").Match([1, 5, 10, 99])
#--> true
```

Only negatives?

```ring
? Nx("[@N+]").Match([-1, -5, -10])
#--> true
```

Or a specific mix—say, two positives followed by two negatives:

```ring
? Nx("[@P2, @N2]").Match([5, 10, -3, -7])
#--> true
```

Even (`@E`) and odd (`@O`) numbers are just as easy:

```ring
? Nx("[@E+]").Match([2, 4, 6, 8])
#--> true
```

You can even alternate them to enforce patterns like `[even, odd, even, odd]`:

```ring
? Nx("[@E, @O, @E, @O]").Match([2, 3, 4, 5])
#--> true
```


## Quantifiers: Controlling the Rhythm

Not all data have fixed lengths. Sometimes you need one or more numbers, sometimes none, sometimes a range.
Quantifiers in Nx give you that flexibility.

Use `+` for *one or more*:

```ring
? Nx("[@E+]").Match([2, 4, 6])
#--> true
```

Use `*` for *zero or more*:

```ring
? Nx("[@O*]").Match([1, 3, 5])
#--> true
```

Use `?` for *zero or one* (optional):

```ring
? Nx("[@P?, @N+]").Match([-5, -10])
#--> true
```

And if you want a precise range, specify it directly:

```ring
? Nx("[@I2-4]").Match([1, 2, 3])
#--> true
```

With quantifiers, your rules become flexible templates that adapt to data.


## Constraints: Setting Boundaries with Logic

In real data, values must often stay within certain limits—like percentages (0–100), sensor readings, or ages.
**Constraints** let you express those limits naturally.

For example, to accept only numbers in section 1–10:

```ring
? Nx("[@S(1..10)+]").Match([5, 7, 3, 9])
#--> true
```

You can also combine constraints with types.
For instance, even integers within section 10–50:

```ring
? Nx("[@E(10..50)3]").Match([12, 24, 36])
#--> true
```

Or restrict values to a specific set:

```ring
? Nx("[@${1;3;5;7}+]").Match([1, 5, 3, 7])
#--> true
```

Constraints transform vague numeric expectations into *bounded, checkable rules*.


## Primes and Divisibility: Number Theory in Your Patterns

Nx isn’t just about validation—it understands number properties.
You can filter primes, composites, or multiples as easily as words in a sentence.

Primes only:

```ring
? Nx("[@PR+]").Match([2, 3, 5, 7, 11])
#--> true
```

Multiples of five:

```ring
? Nx("[@DIV(5)+]").Match([5, 10, 15, 20])
#--> true
```

Exclude evens (i.e., odd numbers) by negating the rule:

```ring
? Nx("[@!DIV(2)+]").Match([1, 3, 5, 7])
#--> true
```

You’re not writing logic anymore—you’re declaring mathematical intent.


## Digit Counts: Defining the Shape of Numbers

Sometimes, the *number of digits* itself matters—like phone numbers, codes, or PINs.
Nx can check that too, using `@D`.

Single-digit numbers:

```ring
? Nx("[@D(1)+]").Match([5, 7, 2, 9])
#--> true
```

Two-digit numbers:

```ring
? Nx("[@D(2)+]").Match([10, 25, 99])
#--> true
```

Even combinations are easy—like two one-digit and two two-digit numbers:

```ring
? Nx("[@D(1)2, @D(2)2]").Match([5, 7, 10, 25])
#--> true
```


## Negation: Expressing What You Don’t Want

Rules aren’t always about inclusion.
Sometimes you need to say what’s *not* allowed—values outside a section, or anything but even numbers.

Negation (`@!`) flips any condition:

Not even (i.e., odd):

```ring
? Nx("[@!E+]").Match([1, 3, 5, 7])
#--> true
```

Not positive (zero or negative):

```ring
? Nx("[@!P+]").Match([0, -5, -10])
#--> true
```

Values *outside* section 50–100:

```ring
? Nx("[@!S(50..100)+]").Match([10, 20, 110, 120])
#--> true
```

Negation turns validation into fine-grained filtering.


## Real-World Uses

Once you start thinking in patterns, many real-world problems become simpler.
Here are some quick examples:

HTTP success codes (200–299):

```ring
? Nx("[@I(200..299)+]").Match([200, 201, 204])
#--> true
```

Bank deposits (positive numbers):

```ring
? Nx("[@P+]").Match([100.50, 250.00, 75.25])
#--> true
```

Ages between 18 and 120:

```ring
? Nx("[@I(18..120)+]").Match([25, 45, 67])
#--> true
```

Dice rolls (1–6):

```ring
? Nx("[@I{1;2;3;4;5;6}+]").Match([3, 5, 1, 6, 2])
#--> true
```

Each rule reads like a sentence, not a program.


## Debugging: Seeing the Pattern Think

Nx helps you understand what it’s doing internally.
Enable debug mode to trace matches:

```ring
Nx = Nx("[@I2-4]")
Nx.EnableDebug()
? Nx.Match([1, 2, 3])
#--> true
```
Debug output:
```
BacktrackMatch: token 1/1, number 1/3
  Token: @I (min: 2, max: 4)
  Trying matches from 2 to 3
  Matched 2 number(s)
  Matched 3 number(s)
```

Alsi, you can inspect the tokens that make up a pattern:

```ring
oNx = Nx("[@E2, @O+, @P(1..10)]")
? @@(oNx.Tokens()
#--> [ "@E2", "@O+", "@P" ]
```
Or see all their details with this eXTended form:
```
? @@NL( Nx.TokensXT() )
#-->
'
[
	[
		[ "keyword", "@E" ],
		[ "min", 2 ],
		[ "max", 2 ],
		[ "quantifier", 2 ],
		[ "constraints", [  ] ],
		[ "negated", 0 ],
		[ "type", "even" ]
	],
	[
		[ "keyword", "@O" ],
		[ "min", 1 ],
		[ "max", 999999999 ],
		[ "quantifier", 1 ],
		[ "constraints", [  ] ],
		[ "negated", 0 ],
		[ "type", "odd" ]
	],
	[
		[ "keyword", "@P" ],
		[ "min", 1 ],
		[ "max", 1 ],
		[ "quantifier", 1 ],
		[
			"constraints",
			[
				[
					"section",
					[ 1, 10 ]
				]
			]
		],
		[ "negated", 0 ],
		[ "type", "positive" ]
	]
]
'
```

It’s validation that can explain itself.


## Softanza Advantage

`stzNumbrex` brings **pattern thinking to numeric data**, blending mathematical reasoning with textual fluency. It’s the first system where numbers can be matched, filtered, and validated as effortlessly as text with regex.

| Dimension                  | stzNumbrex (Nx)                               | Python + Regex / Validation Libs | JavaScript Validators  | Pandas / NumPy Rules |
| -------------------------- | --------------------------------------------- | -------------------------------- | ---------------------- | -------------------- |
| **Pattern Syntax**         | ✅ Regex-like for numbers (`[@P2, @N1]`)       | 🟠 Regex text only               | ◯ Ad-hoc JS logic      | ◯ Condition-based    |
| **Expressiveness**         | ✅ Sections, sets, signs, primes, divisibility | ◯ Limited by strings             | ◯ Manual checks        | 🟠 Math only         |
| **Declarative Validation** | ✅ One-line patterns                           | ◯ Imperative loops               | ◯ If/else blocks       | 🟠 Formula-based     |
| **Ease of Use**            | ✅ Native Ring fluency, zero setup             | 🟠 Imports & setup               | 🟠 Library boilerplate | 🟠 Data-specific     |
| **Type Awareness**         | ✅ Built-in types: int, real, parity, sign     | ◯ Manual type testing            | ◯ `typeof` checks      | 🟠 Limited metadata  |
| **Composability**          | ✅ Patterns combine naturally                  | ◯ Regex concatenation only       | ◯ Functions only       | 🟠 Sequential ops    |
| **Debugging Support**      | ✅ `.EnableDebug()` visual traces              | ◯ Manual debugging               | ◯ Console logs         | ◯ No pattern trace   |
| **Performance**            | ✅ Lightweight, direct evaluation              | 🟠 Depends on parsing            | 🟠 JS overhead         | ✅ Vectorized ops     |
| **Best For**               | ✅ Declarative data validation                 | ✅ Text matching                  | 🟠 Form checks         | ✅ Data analytics     |

**stzNumbrex** stands out for its clarity, instant feedback, and universal expressiveness.
It turns numeric logic into an elegant, declarative language of its own—fast to write, easy to read, and consistent across domains.


## Final Words

`stzNumbrex` is more than a validator—it’s a way of *thinking about numbers*.
Just as `stzGraph` models relationships and `stzList` structures data, `stzNumbrex` gives numeric logic its own expressive syntax.
Together, they form the foundation of Softanza’s vision: **turning code into clear patterns of meaning**, where structure, value, and logic harmonize naturally.

---

## Syntax Legend

| Token     | Meaning                      | Example                                  |
| --------- | ---------------------------- | ---------------------------------------- |
| `@I`      | Integer numbers              | `[@I3] → three integers`                 |
| `@R`      | Real numbers (with decimals) | `[@R2] → two real numbers`               |
| `@S`      | Section (range constraint)   | `[@S(1..10)+] → numbers in section 1–10` |
| `@P`      | Positive numbers             | `[@P+] → one or more positives`          |
| `@N`      | Negative numbers             | `[@N2] → two negatives`                  |
| `@E`      | Even numbers                 | `[@E+] → one or more evens`              |
| `@O`      | Odd numbers                  | `[@O+] → one or more odds`               |
| `@$`      | Any number (integer or real) | `[@$5] → five arbitrary numbers`         |
| `@D(n)`   | Numbers with `n` digits      | `[@D(2)+] → two-digit numbers`           |
| `@PR`     | Prime numbers                | `[@PR+] → one or more primes`            |
| `@DIV(n)` | Multiples of `n`             | `[@DIV(5)+] → multiples of 5`            |
| `@!`      | Negation (reverses rule)     | `[@!E+] → not even (odd)`                |
| `{a;b;c}` | Set of accepted values       | `[@I{1;2;3}+] → integers 1, 2, or 3`     |
| `(a..b)`  | Section of allowed values    | `[@S(0..100)] → from 0 to 100`           |
| `+`       | One or more                  | `[@I+] → one or more integers`           |
| `*`       | Zero or more                 | `[@O*] → optional odds`                  |
| `?`       | Zero or one (optional)       | `[@P?] → optional positive`              |
| `m-n`     | Range of counts              | `[@I2-4] → 2 to 4 integers`              |

