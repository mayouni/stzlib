# Number Patterns Made Simple: A Guide to stzNumberex

Imagine validating RGB color values—three integers between 0 and 255. The traditional approach demands ceremonial code: check the length, loop through values, verify each is an integer, confirm it's non-negative, ensure it doesn't exceed 255. Fifteen lines of conditional logic for a simple concept.

```ring
# Traditional validation
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

Now write similar validators for HTTP status codes, test scores, transaction sequences, sensor readings. The code multiplies. The patterns blur into procedural fog.

## Regex Reimagined

Regular expressions revolutionized string matching by making patterns declarative. You write *what* you want, not *how* to find it. Softanza extends this revolution beyond text—first to lists, then to graphs, and now, for the first time in programming history, to numbers themselves.

Meet **stzNumberex**:

```ring
? Nx("[@I(0..255)3]").Match([128, 64, 192])
#--> true
```

One line. The pattern speaks: three integers, each within 0 to 255. The intent is transparent. The implementation vanishes.

## The Language of Number Patterns

Let's start exploring. We need to match exactly three integers:

```ring
? Nx("[@I3]").Match([1, 2, 3])
#--> true
```

The `@I` token means "integer." The `3` is our quantifier—exactly three. But what if our first value is a float?

```ring
? Nx("[@I3]").Match([1.5, 2, 3])
#--> false
```

The pattern catches it immediately. This is the power of declarative matching—your validation logic becomes readable pattern syntax.

Integers aren't enough. Sometimes we need floats specifically:

```ring
? Nx("[@F2]").Match([3.14, 2.71])
#--> true
```

Or perhaps we don't care—any number will do:

```ring
? Nx("[@$5]").Match([1, 2.5, -3, 0, 100])
#--> true
```

The `@$` wildcard accepts anything numeric. Mix integers, floats, negatives, zeros—all pass.

## Composing Patterns

Patterns gain power through composition. Imagine validating a sequence: two positive numbers, then two negative ones.

```ring
? Nx("[@P2, @N2]").Match([5, 10, -3, -7])
#--> true
```

The comma separates pattern segments. Each segment must match in order. Change the sequence, break the pattern:

```ring
? Nx("[@P2, @N2]").Match([5, -10, -3, 7])
#--> false
```

This sequential matching opens possibilities. Consider alternating even and odd numbers:

```ring
? Nx("[@E, @O, @E, @O]").Match([2, 3, 4, 5])
#--> true
```

Four tokens, four positions, perfect alignment. The pattern reads like a specification document.

## Quantifiers: From Rigid to Flexible

Exact counts work for rigid structures. But real data is messier. We need flexible repetition—and here Nx borrows regex wisdom.

The `+` quantifier means "one or more":

```ring
? Nx("[@E+]").Match([2, 4, 6])
#--> true

? Nx("[@E+]").Match([2])
#--> true
```

Both pass—three even numbers, one even number. But zero even numbers fails:

```ring
? Nx("[@E+]").Match([])
#--> false
```

The `+` requires at least one match. For optional sequences, use `*` (zero or more):

```ring
? Nx("[@O*]").Match([1, 3, 5])
#--> true

? Nx("[@O*]").Match([])
#--> true
```

Now both succeed. The empty list is valid—zero matches satisfies the pattern.

Sometimes "optional" means "at most one." The `?` quantifier gives us this:

```ring
? Nx("[@P?, @N+]").Match([-5, -10])
#--> true  # Zero positive, multiple negative

? Nx("[@P?, @N+]").Match([5, -10, -20])
#--> true  # One positive, multiple negative
```

Combine these quantifiers and watch patterns come alive. Here's sensor data validation: five positive readings, then an optional negative anomaly:

```ring
? Nx("[@P5, @N?]").Match([10, 20, 30, 40, 50])
#--> true

? Nx("[@P5, @N?]").Match([10, 20, 30, 40, 50, -5])
#--> true
```

Both pass. The negative value is optional—present or absent, the pattern flexes.

## Constraints: Narrowing the Field

Types and quantifiers establish structure. Constraints add precision. We can bound values with range notation:

```ring
? Nx("[@$(1..10)+]").Match([5, 7, 3, 9])
#--> true
```

Every number must fall within 1 to 10. Step outside, fail the pattern:

```ring
? Nx("[@$(1..10)+]").Match([5, 15, 3])
#--> false
```

The 15 breaks the constraint. Constraints combine with types for surgical precision:

```ring
? Nx("[@E(10..50)3]").Match([12, 24, 36])
#--> true
```

Three even numbers, each between 10 and 50. Both conditions must hold. Try a value outside the range:

```ring
? Nx("[@E(10..50)3]").Match([12, 24, 60])
#--> false
```

The 60 satisfies "even" but violates the range. Pattern matching demands *all* conditions.

Sometimes ranges aren't enough—we need exact membership. Set constraints use curly braces:

```ring
? Nx("[@${1;3;5;7}+]").Match([1, 5, 3, 7])
#--> true
```

Only values from the set `{1, 3, 5, 7}` pass. Introduce a foreign value:

```ring
? Nx("[@${1;3;5;7}+]").Match([1, 2, 3])
#--> false
```

The 2 isn't in the set. The pattern rejects it. This makes validation of discrete options trivial—think dice rolls, star ratings, priority levels:

```ring
? Nx("[@I{1;2;3;4;5;6}+]").Match([3, 5, 1, 6, 2])
#--> true  # Valid dice rolls
```

## Prime Numbers and Divisibility

Mathematical properties become first-class pattern elements. Finding primes in a sequence:

```ring
? Nx("[@PR+]").Match([2, 3, 5, 7, 11])
#--> true
```

The `@PR` token checks primality. Slip in a composite:

```ring
? Nx("[@PR+]").Match([2, 3, 4, 5])
#--> false
```

The 4 fails—it's not prime. Patterns can enforce mathematical structure: three primes followed by any number:

```ring
? Nx("[@PR3, @$]").Match([2, 3, 5, 100])
#--> true
```

Divisibility patterns use `@DIV`:

```ring
? Nx("[@DIV(5)+]").Match([5, 10, 15, 20])
#--> true
```

All multiples of 5. Break the pattern with 12:

```ring
? Nx("[@DIV(5)+]").Match([5, 10, 12])
#--> false
```

Compose divisibility constraints for complex rhythms:

```ring
? Nx("[@DIV(5)2, @DIV(3)2]").Match([10, 25, 6, 9])
#--> true
```

Two multiples of 5, then two multiples of 3. The pattern captures mathematical relationships.

## The Power of Negation

Every pattern can invert with `@!`. Want odd numbers? Negate even:

```ring
? Nx("[@!E+]").Match([1, 3, 5, 7])
#--> true
```

Non-positive values? Negate positive:

```ring
? Nx("[@!P+]").Match([0, -5, -10])
#--> true
```

Outlier detection becomes elegant. Find values *outside* a normal range:

```ring
? Nx("[@!$(50..100)+]").Match([10, 20, 110, 120])
#--> true  # All outliers
```

Every number violates the 50-100 range. For statistical analysis, this pattern identifies anomalies instantly.

## Real-World Scenarios

Validation patterns emerge everywhere once you see them. API responses return HTTP codes—success codes cluster in 200-299:

```ring
? Nx("[@I(200..299)+]").Match([200, 201, 204])
#--> true
```

Error codes span 400-599:

```ring
? Nx("[@I(400..599)+]").Match([404, 500, 503])
#--> true
```

Banking transactions segregate by sign—deposits are positive:

```ring
? Nx("[@P+]").Match([100.50, 250.00, 75.25])
#--> true
```

Withdrawals negative:

```ring
? Nx("[@N+]").Match([-50.00, -100.00, -25.50])
#--> true
```

Test scores bound between 0 and 100:

```ring
? Nx("[@P(0..100)+]").Match([85, 92, 78, 95])
#--> true
```

A score of 105 fails validation:

```ring
? Nx("[@P(0..100)+]").Match([85, 105, 78])
#--> false
```

Age verification requires integers in adult range:

```ring
? Nx("[@I(18..120)+]").Match([25, 45, 67])
#--> true

? Nx("[@I(18..120)+]").Match([25, 15, 67])
#--> false
```

Game mechanics validate with set constraints—star ratings from 1 to 5:

```ring
? Nx("[@I{1;2;3;4;5}+]").Match([5, 4, 5, 3, 4])
#--> true
```

Port validation checks well-known range:

```ring
? Nx("[@I(0..1023)+]").Match([80, 443, 22, 21])
#--> true
```

Each scenario reduces to a pattern. The pattern encodes domain rules. The code disappears into declarative syntax.

## Advanced Compositions

Complex validators emerge from simple building blocks. Game scores need 3 to 5 positive integers within 1 to 1000:

```ring
? Nx("[@I(1..1000)3-5]").Match([100, 250, 500])
#--> true

? Nx("[@I(1..1000)3-5]").Match([100, 250, 500, 750, 900])
#--> true
```

Temperature readings allow optional negative values before required positive ones:

```ring
? Nx("[@N*, @P+]").Match([10, 20, 30])
#--> true  # No negatives

? Nx("[@N*, @P+]").Match([-5, -10, 5, 10])
#--> true  # Two negative, two positive
```

Pagination sizes must be multiples of 10 within 10 to 100:

```ring
? Nx("[@DIV(10)(10..100)+]").Match([10, 20, 50, 100])
#--> true
```

The pattern layers type, divisibility, and range—three constraints in one expression.

## The Declarative Revolution

Softanza's insight: patterns aren't just for strings. The regex concept—declarative matching through patterns—applies across all data structures we work with.

`stzRegex` started it, reimagining text patterns. `stzListex` extended patterns to lists—matching sequences, alternations, nested structures. `stzGraphex` brought patterns to graph topology—nodes, edges, paths, cycles. Now `stzNumberex` applies patterns to numeric sequences—types, constraints, mathematical properties. And `stzTimex` is coming—temporal patterns for dates, durations, intervals, and time sequences.

This is regex reimagined for the data structures we actually work with. Want to validate a sequence? Write a pattern. The how dissolves. The what remains.

Compare the RGB validator we started with—fifteen lines of procedural checks—to this:

```ring
? Nx("[@I(0..255)3]").Match([128, 64, 192])
#--> true
```

One line. Self-documenting. Composable. Change the requirement? Edit the pattern. The validation logic flows from the specification.

This is programming where intent meets implementation at the syntax level. Where domain rules become first-class code. Where the pattern *is* the program.

Welcome to number patterns. Welcome to declarative matching. Welcome to the next chapter in Softanza's regex revolution.