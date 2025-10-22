Number Patterns Made Simple: A Guide to stzNumberex
Validating numbers can be a chore. Take RGB colors—three integers from 0 to 255. Usually, you'd write lots of code: check the list length, loop through each number, confirm it's an integer, not negative, and not over 255. It’s long and repetitive.
# Old way to check RGB
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

Now imagine doing this for HTTP codes, test scores, or bank transactions. The code piles up, and it’s hard to see the pattern.
That’s where stzNumberex (or Nx) comes in. It’s like regex, but for numbers. You write what you want, not how to check it.
? Nx("[@I(0..255)3]").Match([128, 64, 192])
#--> true

One line says it all: three integers (@I), each 0 to 255. Clear and simple.
Basic Number Types
Let’s start easy. Want three integers?
? Nx("[@I3]").Match([1, 2, 3])
#--> true

If a float sneaks in, it fails:
? Nx("[@I3]").Match([1.5, 2, 3])
#--> false

Need two floats instead?
? Nx("[@F2]").Match([3.14, 2.71])
#--> true

? Nx("[@F2]").Match([3, 2.71])
#--> false

Want any numbers—integers, floats, positive, negative? Use @$:
? Nx("[@$5]").Match([1, 2.5, -3, 0, 100])
#--> true

Signs and Patterns
You can check for positive (@P) or negative (@N) numbers:
? Nx("[@P+]").Match([1, 5, 10, 99])
#--> true

? Nx("[@P+]").Match([1, -5, 10])
#--> false

Negatives only:
? Nx("[@N+]").Match([-1, -5, -10])
#--> true

? Nx("[@N+]").Match([-1, 0, -10])
#--> false

Mix them up, like two positives then two negatives:
? Nx("[@P2, @N2]").Match([5, 10, -3, -7])
#--> true

? Nx("[@P2, @N2]").Match([5, -10, -3, 7])
#--> false

Even (@E) and odd (@O) numbers work too:
? Nx("[@E+]").Match([2, 4, 6, 8])
#--> true

? Nx("[@E+]").Match([2, 4, 5, 8])
#--> false

Alternate them:
? Nx("[@E, @O, @E, @O]").Match([2, 3, 4, 5])
#--> true

Quantifiers: Flexible Counts
You can control how many numbers you want. Use + for one or more:
? Nx("[@E+]").Match([2, 4, 6])
#--> true

? Nx("[@E+]").Match([2])
#--> true

But an empty list fails:
? Nx("[@E+]").Match([])
#--> false

Use * for zero or more:
? Nx("[@O*]").Match([1, 3, 5])
#--> true

? Nx("[@O*]").Match([])
#--> true

Use ? for zero or one:
? Nx("[@P?, @N+]").Match([-5, -10])
#--> true

? Nx("[@P?, @N+]").Match([5, -10, -20])
#--> true

Too many positives? Fail:
? Nx("[@P?, @N+]").Match([5, 10, -20])
#--> false

For a range, like 2 to 4 integers:
? Nx("[@I2-4]").Match([1, 2, 3])
#--> true

? Nx("[@I2-4]").Match([1])
#--> false

? Nx("[@I2-4]").Match([1, 2, 3, 4, 5])
#--> false

For sensor data, five positives with an optional negative:
? Nx("[@P5, @N?]").Match([10, 20, 30, 40, 50])
#--> true

? Nx("[@P5, @N?]").Match([10, 20, 30, 40, 50, -5])
#--> true

Constraints: Setting Limits
Ranges limit values:
? Nx("[@$(1..10)+]").Match([5, 7, 3, 9])
#--> true

? Nx("[@$(1..10)+]").Match([5, 15, 3])
#--> false

Combine with types:
? Nx("[@E(10..50)3]").Match([12, 24, 36])
#--> true

? Nx("[@E(10..50)3]").Match([12, 24, 60])
#--> false

Sets { } limit to specific values:
? Nx("[@${1;3;5;7}+]").Match([1, 5, 3, 7])
#--> true

? Nx("[@${1;3;5;7}+]").Match([1, 2, 3])
#--> false

Even numbers from a set:
? Nx("[@E{2;4;6;8}+]").Match([2, 4, 6])
#--> true

? Nx("[@E{2;4;6;8}+]").Match([2, 4, 10])
#--> false

Duplicates are okay:
? Nx("[@${10;20;30}3]").Match([10, 20, 20])
#--> true

Primes and Divisibility
Check for prime numbers (@PR):
? Nx("[@PR+]").Match([2, 3, 5, 7, 11])
#--> true

? Nx("[@PR+]").Match([2, 3, 4, 5])
#--> false

Three primes, then any number:
? Nx("[@PR3, @$]").Match([2, 3, 5, 100])
#--> true

Non-primes (composites):
? Nx("[@!PR+]").Match([4, 6, 8, 9, 10])
#--> true

Divisibility (@DIV) checks multiples:
? Nx("[@DIV(5)+]").Match([5, 10, 15, 20])
#--> true

? Nx("[@DIV(5)+]").Match([5, 10, 12])
#--> false

Four multiples of 3:
? Nx("[@DIV(3)4]").Match([3, 6, 9, 12])
#--> true

Two multiples of 5, then two of 3:
? Nx("[@DIV(5)2, @DIV(3)2]").Match([10, 25, 6, 9])
#--> true

Negate divisibility for odds:
? Nx("[@!DIV(2)+]").Match([1, 3, 5, 7])
#--> true

Digit Counts
Check how many digits with @D. Single-digit numbers:
? Nx("[@D(1)+]").Match([5, 7, 2, 9])
#--> true

? Nx("[@D(1)+]").Match([5, 12, 2])
#--> false

Two-digit numbers:
? Nx("[@D(2)+]").Match([10, 25, 99])
#--> true

? Nx("[@D(2)+]").Match([10, 5, 99])
#--> false

Two single-digit, then two two-digit:
? Nx("[@D(1)2, @D(2)2]").Match([5, 7, 10, 25])
#--> true

For crypto, two-digit numbers with primes:
? Nx("[@D(2), @PR+]").Match([11, 13, 17, 19, 23])
#--> true

? Nx("[@PR, @D(2)+]").Match([2, 11, 13, 17, 19])
#--> false

Negation: Flipping the Rules
Negation (@!) reverses checks. Not even means odd:
? Nx("[@!E+]").Match([1, 3, 5, 7])
#--> true

Not positive means zero or negative:
? Nx("[@!P+]").Match([0, -5, -10])
#--> true

? Nx("[@!P+]").Match([0, 5, -10])
#--> false

Not in a range finds outliers:
? Nx("[@!$(50..100)+]").Match([10, 20, 110, 120])
#--> true

? Nx("[@!$(50..100)+]").Match([5, 50, 95])
#--> false

Real-World Uses
Nx shines in real tasks. HTTP success codes (200-299):
? Nx("[@I(200..299)+]").Match([200, 201, 204])
#--> true

Error codes (400-599):
? Nx("[@I(400..599)+]").Match([404, 500, 503])
#--> true

Bank deposits (positive):
? Nx("[@P+]").Match([100.50, 250.00, 75.25])
#--> true

Withdrawals (negative):
? Nx("[@N+]").Match([-50.00, -100.00, -25.50])
#--> true

Test scores (0-100, positive):
? Nx("[@P(0..100)+]").Match([85, 92, 78, 95])
#--> true

? Nx("[@P(0..100)+]").Match([85, 105, 78])
#--> false

Ages (18-120, integers):
? Nx("[@I(18..120)+]").Match([25, 45, 67])
#--> true

? Nx("[@I(18..120)+]").Match([25, 15, 67])
#--> false

Dice rolls (1-6):
? Nx("[@I{1;2;3;4;5;6}+]").Match([3, 5, 1, 6, 2])
#--> true

? Nx("[@I{1;2;3;4;5;6}+]").Match([3, 7, 1])
#--> false

Star ratings (1-5):
? Nx("[@I{1;2;3;4;5}+]").Match([5, 4, 5, 3, 4])
#--> true

Priorities (1-3):
? Nx("[@I{1;2;3}+]").Match([1, 2, 1, 3, 2])
#--> true

Fibonacci numbers:
? Nx("[@${1;1;2;3;5;8;13;21;34;55}+]").Match([1, 1, 2, 3, 5])
#--> true

Port numbers (0-1023):
? Nx("[@I(0..1023)+]").Match([80, 443, 22, 21])
#--> true

Percentages (0-100):
? Nx("[@$(0..100)+]").Match([75.5, 85, 92.3])
#--> true

? Nx("[@$(0..100)+]").Match([75.5, 105])
#--> false

Prime factors:
? Nx("[@PR+]").Match([2, 3, 5, 7])
#--> true

Lottery (six primes, 1-50):
? Nx("[@PR(1..50)6]").Match([7, 11, 13, 19, 23, 29])
#--> true

Pagination (multiples of 10, 10-100):
? Nx("[@DIV(10)(10..100)+]").Match([10, 20, 50, 100])
#--> true

Advanced Patterns
Mix complex rules. Even prime (2), then odd primes:
? Nx("[@E, @PR1, @O, @PR+]").Match([2, 2, 3, 5, 7])
#--> true

Negatives, optional zeros, positives:
? Nx("[@N+, @${0}*, @P+]").Match([-5, -3, 0, 0, 5, 10])
#--> true

? Nx("[@N+, @${0}*, @P+]").Match([-5, -3, 5, 10])
#--> true

Alternate even and divisible by 3:
? Nx("[@E, @DIV(3), @E, @DIV(3)]").Match([2, 9, 4, 12])
#--> true

Flexible counts:
? Nx("[@P1-3, @N2-4, @$*]").Match([5, 10, -2, -5, -8, 100, 200])
#--> true

Game scores (3-5 integers, 1-1000):
? Nx("[@I(1..1000)3-5]").Match([100, 250, 500])
#--> true

? Nx("[@I(1..1000)3-5]").Match([100, 250, 500, 750, 900])
#--> true

? Nx("[@I(1..1000)3-5]").Match([100, 250])
#--> false

Time series (alternating positive, negative):
? Nx("[@P, @N, @P, @N]").Match([5, -2, 8, -3])
#--> true

Temperatures (optional negatives, then positives):
? Nx("[@N*, @P+]").Match([10, 20, 30])
#--> true

? Nx("[@N*, @P+]").Match([-5, -10, 5, 10])
#--> true

Debugging and Checking Patterns
See how Nx works with debug mode:
Nx = Nx("[@I2-4]")
Nx.EnableDebug()
? Nx.Match([1, 2, 3])
#--> true
# Shows: Trying matches from 2 to 3, Matched 3 number(s)

Turn it off:
Nx.DisableDebug()

Check the pattern’s parts:
oNx = Nx("[@E2, @O+, @P(1..10)]")
? @@( oNx.Tokens() ) + NL
#--> [ "@E", "@O", "@P" ]

Get detailed info:
? @@NL( oNx.TokensXT() ) + NL
#--> Shows tokens with type, min, max, constraints

? oNx.TokensInfo()
#--> Token #1: @E2
#    Token #2: @O (1-999999999)
#    Token #3: @P [constraints: 1]

Retrieve the pattern:
oNx = Nx("[@PR+, @DIV(3)2]")
? oNx.Pattern()
#--> "[@PR+, @DIV(3)2]"

Why It Matters
Nx makes validation clear. Compare the old 15-line RGB check to:
? Nx("[@I(0..255)3]").Match([128, 64, 192])
#--> true

? Nx("[@I(0..255)3]").Match([128, 64])
#--> false

? Nx("[@I(0..255)3]").Match([128, 64, 300])
#--> false

It’s short, readable, and reusable. Nx turns rules into patterns, so you focus on what matters. It’s part of Softanza’s bigger idea: regex for numbers, lists, graphs, and soon, time with stzTimex. Your code becomes a clear story of what you need.