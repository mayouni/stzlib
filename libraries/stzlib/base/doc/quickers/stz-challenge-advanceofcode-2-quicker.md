# Tackling Advent of Code 2024 with Softanza - Day 2

The *Advent of Code 2024 - Day 2 Challenge* emphasizes maintaining stability in systems like machinery or data monitoring, ensuring gradual changes within safe boundaries. Engineers track fluctuations to prevent malfunctions, making this concept essential for diagnostics and risk mitigation. Read the full statement [here](https://adventofcode.com/2024/day/2).

---
 
The task is then to check if a list of numbers is "safe" based on two conditions:
1. The numbers must be **all increasing** or **all decreasing**.
2. The difference between adjacent numbers must be **between 1 and 3**.

## The Solution

Softanza solves this elegantly with the `CheckThat()` method:

```ring
QQ([1, 2, 7, 8, 9]).CheckThatXT('{
    Q(@List).IsSorted() and
    Q(@NextNumber - @CurrentNumber).IsBetweenXT(1, :And = 3)
}')
```

Here, `QQ([1, 2, 7, 8, 9])` elevates the list to a `stzListOfNumbers`, and `CheckThat()` ensures it is sorted and the differences between adjacent numbers are within the specified range.

This code solution directly mirrors the challenge requirements, written in a concise, human-readable way.

>**NOTE**: The `XT()` suffix is typically used to indicate an e**XT**ended feature of a function. For example, in `CheckThatXT()`, it enables the use of natural expressions with keywords like `@NextNumber` and `@CurrentNumber`. In `IsBetweenXT()`, it ensures that the bounds (1 and 3 in the example) are included.