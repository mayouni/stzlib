# Tackling Advent of Code 2024 with Softanza - Day 3

The *Advent of Code 2024 - Day 3 Challenge* involves extracting valid multiplication instructions (`mul(X,Y)`) from corrupted memory, calculating their products, and summing the results. This challenge emphasizes cleaning and processing noisy data, which is a key skill in data handling. Check the complete problem description [here](https://adventofcode.com/2024/day/3).

---

Given a corrupted string, extract the valid `mul(X,Y)` instructions, compute their products, and return their sum.

For example, in the corrupted string:

```
xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
```

The valid instructions are:

- `mul(2,4)`
- `mul(5,5)`
- `mul(32,64)`
- `mul(11,8)`
- `mul(8,5)`

The task is to calculate and sum their products.

## The Solution

```ring

# Step 1: Host the corrupted text in a stzString object

o1 = new stzString("xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))")

# Step 2: Clean the input by replacing square brackets with parentheses to match the
format of valid mul() function

o1.Replace([ "[", "]"], :By = [ "(", ")" ])
#--> "xmul(2,4)%&mul(3,7)!@^do_not_mul(5,5)+mul(32,64)then(mul(11,8)mul(8,5))"

# Step 3: Extract valid mul(X,Y) instructions using bounds

aList = o1.BoundedByIB([ "mul(", ")" ])
#--> [
#	"mul(2,4)",
#	"mul(3,7)",
#	"mul(5,5)",
#	"mul(32,64)",
#	"mul(11,8)",
#	"mul(8,5)"
# ]

# Step 4: Sum the products of the extracted instructions

sum = Q(aList).YieldXT('{ eval(@item) }') 
#--> 12123
```

The code is self-explanatory, but we can add these details:

1. The `Replace` method can work on more than one substring at once.

2. In the `BoundedByIB()` function, the `IB` suffix ensures that the bounds are included in the result, giving us the exact multiplication expressions needed for evaluation.

3. The `YieldXT()` method evaluates each item in the list (in this case, the multiplication expressions), transforms each string into its native Ring form (for example, the string "mul(2,4)" is transformed to the function call `mul(2,4)`), and computes the product. The `XT` suffix indicates that the results should be accumulated, returning the total sum of all products.
