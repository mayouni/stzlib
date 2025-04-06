# Flexible Parameter Design in stzMatrix

## Overview

The stzMatrix class implements a versatile parameter positioning system that accommodates multiple programming styles while maintaining consistent behavior. This technical note documents the parameter options for the Multiply() and Add() methods.

## Parameter Positioning Patterns

### Universal Operation

The simplest form applies operations to all matrix elements uniformly.

```ring
o1 = new stzMatrix([
  [1, 5, 3],
  [4, 5, 6],
  [7, 5, 9]
])

o1.Multiply(2)    // Multiplies all elements by 2
o1.Show()
#-->
# ┌ ┐
# │ 2 10 6 │
# │ 8 10 12 │
# │ 14 10 18 │
# └ ┘
```

The Add method follows the same pattern, providing a uniform operation on all elements.

```ring
o1 = new stzMatrix([
  [1, 5, 3],
  [4, 5, 6],
  [7, 5, 9]
])

o1.Add(2)         // Adds 2 to all elements
o1.Show()
#-->
# ┌ ┐
# │ 3 7 5 │
# │ 6 7 8 │
# │ 9 7 11 │
# └ ┘
```

### Implicit Row-First Positioning

Following matrix convention, the class interprets array parameters in row-first order.

```ring
o1 = new stzMatrix([
  [1, 5, 3],
  [4, 5, 6],
  [7, 5, 9]
])

o1.Multiply([2, 3])    // Multiplies row 2 by 3
o1.Show()
#-->
# ┌ ┐
# │ 1 5 3 │
# │ 12 15 18 │
# │ 7 5 9 │
# └ ┘
```

This convention applies consistently across matrix operations.

```ring
o1 = new stzMatrix([
  [1, 5, 3],
  [4, 5, 6],
  [7, 5, 9]
])

o1.Add([2, 3])         // Adds 3 to row 2
o1.Show()
#-->
# ┌ ┐
# │ 1 5 3 │
# │ 7 8 9 │
# │ 7 5 9 │
# └ ┘
```

### Named Parameters

For explicit clarity, named parameters specify exact intent regardless of position.

```ring
o1 = new stzMatrix([
  [1, 5, 3],
  [4, 5, 6],
  [7, 5, 9]
])

o1.Multiply([:Col = 2, :By = 3])    // Multiplies column 2 by 3
o1.Show()
#-->
# ┌ ┐
# │ 1 15 3 │
# │ 4 15 6 │
# │ 7 15 9 │
# └ ┘
```

Named parameters adapt to different operation contexts while maintaining readable code.

```ring
o1 = new stzMatrix([
  [1, 5, 3],
  [4, 5, 6],
  [7, 5, 9]
])

o1.Add([3, :InRow = 1])             // Adds 3 to row 1
o1.Show()
#-->
# ┌ ┐
# │ 4 8 6 │
# │ 4 5 6 │
# │ 7 5 9 │
# └ ┘
```

Column operations can be specified with similar clarity.

```ring
o1 = new stzMatrix([
  [1, 5, 3],
  [4, 5, 6],
  [7, 5, 9]
])

o1.Add([3, :InCol = 3])             // Adds 3 to column 3
o1.Show()
#-->
# ┌ ┐
# │ 1 5 6 │
# │ 4 5 9 │
# │ 7 5 12 │
# └ ┘
```

### Parameter Order Encoding

Method name suffixes enforce specific parameter ordering for consistent code patterns. The suffix "CV" indicates that the first parameter is Column and the second is Value, allowing programmers to maintain their preferred parameter ordering style.

```ring
o1 = new stzMatrix([
  [1, 5, 3],
  [4, 5, 6],
  [7, 5, 9]
])

o1.MultiplyCV(1, 3)    // Column 1, Value 3
o1.Show()
#-->
# ┌ ┐
# │ 3 5 3 │
# │ 12 5 6 │
# │ 21 5 9 │
# └ ┘
```

Reversed parameter order is also supported through the "VC" suffix, which indicates Value then Column. This flexibility allows each programmer to use the style that best fits their habits and mental model.

```ring
o1 = new stzMatrix([
  [1, 5, 3],
  [4, 5, 6],
  [7, 5, 9]
])

o1.MultiplyVC(3, 1)    // Value 3, Column 1
o1.Show()
#-->
# ┌ ┐
# │ 3 5 3 │
# │ 12 5 6 │
# │ 21 5 9 │
# └ ┘
```

The same pattern applies to the Add operations with identical suffix conventions.

```ring
o1 = new stzMatrix([
  [1, 5, 3],
  [4, 5, 6],
  [7, 5, 9]
])

o1.AddCV(1, 3)         // Column 1, Value 3
o1.Show()
#-->
# ┌ ┐
# │ 4 5 3 │
# │ 7 5 6 │
# │ 10 5 9 │
# └ ┘
```

This parameter encoding system maintains consistency across the API while allowing developers to choose the parameter order that feels most natural to them, whether they come from mathematical backgrounds, traditional programming disciplines, or prefer a more natural language orientation.