# Solving AdventOfCode with Softanza  

The **AdventOfCode 2024 - Day 1 Challenge** invites us to compute the total "distance" between two lists of numbers. This involves sorting, pairing, calculating absolute differences, and summing them to get the result. The full problem statement is available [here](https://adventofcode.com/2024/day/1).  

While simple in concept, such tasks are crucial in real-world domains like logistics and data reconciliation. Softanza, a foundation library for the Ring language, offers tools that streamline the solution elegantly. Key functions like `Pairify()` and `AbsDiff()` encapsulate common operations, making the implementation both concise and expressive.  

---

## The Code  

```ring
load "stzlib.ring"
profon()

aList1 = [ 3, 4, 2, 1, 3, 3 ]
aList2 = [ 4, 3, 5, 3, 9, 3 ]

# Step 1: Sort the lists
aSorted1 = @Sort(aList1)
aSorted2 = @Sort(aList2)

# Step 2: Pair corresponding elements
aPairs = Pairify([aSorted1, aSorted2])

# Step 3: Calculate absolute differences
differences = AbsDiff(aPairs)

# Step 4: Sum the differences
totalDistance = Sum(differences)

? "Total Distance: ", totalDistance  # Output: 11
proff()
```


## Key Insights  

1. **Pairify()**: Automatically pairs elements from two sorted lists. This abstraction avoids repetitive iteration logic, directly producing the pairs needed for further calculations.  
   Output: `[[1, 3], [2, 3], [3, 3], [3, 4], [3, 5], [4, 9]]`.  

2. **AbsDiff()**: Computes absolute differences for each pair in one step, ensuring correctness while keeping the code concise.  
   Output: `[2, 1, 0, 1, 2, 5]`.  

3. **Sum()**: Aggregates the differences into a single value, providing the total distance efficiently.  
   Output: `11`.  


## Conclusion  

Softanza demonstrates its practicality by abstracting routine yet error-prone operations into reusable functions. This challenge highlights how its tools like `Pairify()` and `AbsDiff()` simplify tasks that might otherwise require complex code. With a clean and efficient solution in just a few lines, Softanza proves itself as a powerful companion for computational challenges and real-world applications alike.