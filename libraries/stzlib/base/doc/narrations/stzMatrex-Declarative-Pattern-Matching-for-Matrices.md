# stzMatrex: Declarative Pattern Matching for Matrices in Softanza

## Introduction

Matrices are not just collections of numbers — they embody structure, geometry, and mathematical meaning. Recognizing whether a matrix is *square*, *symmetric*, *diagonal*, or *identity* is often more significant than performing arithmetic operations on it.

**stzMatrex** brings this recognition ability into Softanza as a **pattern language for matrices**.
Instead of writing conditional checks or nested loops, you can now express a matrix condition semantically:

```ring
oMx = new stzMatrex("{shape(square) & property(symmetric)}")

? oMx.Match([
    [1, 2, 3],
    [2, 4, 5],
    [3, 5, 6]
])
#--> TRUE
```

In one expression, you’ve defined a concept — “a square symmetric matrix” — and tested it instantly.
Let’s explore how this pattern engine turns matrix semantics into readable, declarative logic.

---

## 1. Matching Matrix Size

The simplest patterns describe the **size** of a matrix.
A `{Size(rxc)}` pattern specifies an exact shape, while `{Size(mxn)}` accepts any matrix.

```ring
oMx = new stzMatrex("{Size(3x3)}")

aMatrix = [
    [1,2,3],
    [4,5,6],
    [7,8,9]
]

? oMx.Match(aMatrix)
#--> TRUE
```

If we test a wrong size, the match fails:

```ring
oMx = new stzMatrex("{size(2x2)}")

aMatrix = [
    [1,2,3],
    [4,5,6],
    [7,8,9]
]

? oMx.Match(aMatrix)
#--> FALSE
```

When you need a generic matcher for any dimension, the notation `mxn` works elegantly:

```ring
oMx = new stzMatrex("{size(mxn)}")

aMatrix1 = [[1,2],[3,4]]
aMatrix2 = [[1,2,3],[4,5,6],[7,8,9]]
aMatrix3 = [[1,2,3,4]]

? oMx.Match(aMatrix1)
#--> TRUE
? oMx.Match(aMatrix2)
#--> TRUE
? oMx.Match(aMatrix3)
#--> TRUE
```

These size patterns provide the foundation for structural reasoning in numerical workflows.



## 2. Recognizing Matrix Shape

Shape patterns let you distinguish between geometric configurations — square, rectangular, tall, wide, or vector-like.

```ring
oMx = new stzMatrex("{shape(square)}")

aSquare = [[1, 2], [3, 4]]
aRect = [[1, 2, 3], [4, 5, 6]]

? oMx.Match(aSquare)
#--> TRUE
? oMx.Match(aRect)
#--> FALSE
```

The same idea extends naturally to other shapes:

```ring
oMxTall = new stzMatrex("{shape(tall)}")
oMxWide = new stzMatrex("{shape(wide)}")

aTall = [[1], [2], [3], [4]]
aWide = [[1, 2, 3, 4]]

? oMxTall.Match(aTall)
#--> TRUE
? oMxWide.Match(aWide)
#--> TRUE
```

For directional structures, you can match row and column vectors explicitly:

```ring
oMxRow = new stzMatrex("{shape(row)}")
oMxCol = new stzMatrex("{shape(column)}")

aRow = [[1,2,3,4,5]]
aCol = [[1],[2],[3]]

? oMxRow.Match(aRow)
#--> TRUE
? oMxCol.Match(aCol)
#--> TRUE
```

These shape-based expressions clarify algorithms that depend on the matrix’s orientation.



## 3. Detecting Matrix Properties

Beyond shape, `stzMatrex` can detect *mathematical properties* directly — such as whether a matrix is identity, diagonal, symmetric, or triangular.

```ring
oMx = new stzMatrex("{property(identity)}")

aIdentity = [
    [1,0,0],
    [0,1,0],
    [0,0,1]
]

aNotIdentity = [
    [1,0,0],
    [0,2,0],
    [0,0,1]
]

? oMx.Match(aIdentity)
#--> TRUE
? oMx.Match(aNotIdentity)
#--> FALSE
```

Other intrinsic properties follow the same syntax:

```ring
oMx = new stzMatrex("{property(symmetric)}")

aSymmetric = [
    [1,2,3],
    [2,4,5],
    [3,5,6]
]

aAsymmetric = [
    [1,2,3],
    [4,5,6],
    [7,8,9]
]

? oMx.Match(aSymmetric)
#--> TRUE
? oMx.Match(aAsymmetric)
#--> FALSE
```

The same logic identifies diagonal, upper, lower, and zero matrices, allowing you to encode classification rules directly in patterns.



## 4. Applying Element Constraints

Sometimes the structure is less important than what the matrix contains.
Element constraints let you specify acceptable numeric values or ranges.

```ring
oMx = new stzMatrex("{element(0..10)}")

aInRange = [
    [1,2,3],
    [4,5,6],
    [7,8,9]
]

aOutOfRange = [
    [1,2,15],
    [4,5,6],
    [7,8,9]
]

? oMx.Match(aInRange)
#--> TRUE
? oMx.Match(aOutOfRange)
#--> FALSE
```

You can also define discrete sets or single-value matrices:

```ring
oMx = new stzMatrex("{element({0;1})}")

aBinary = [
    [1,0,1],
    [0,1,0],
    [1,1,0]
]

? oMx.Match(aBinary)
#--> TRUE
```

These patterns make it easy to validate numerical domains across large data structures.



## 5. Combining Logical Conditions

Matrix conditions can combine through logical operators `&`, `|`, and `@!`.
This allows composite structural and numeric rules.

```ring
oMx = new stzMatrex("{shape(square) & property(identity)}")

aId = [
    [1,0,0],
    [0,1,0],
    [0,0,1]
]

aSquare = [
    [1,2,3],
    [4,5,6],
    [7,8,9]
]

? oMx.Match(aId)
#--> TRUE
? oMx.Match(aSquare)
#--> FALSE
```

Alternations are equally clear:

```ring
oMx = new stzMatrex("{(size(2x2) | size(3x3)) & property(diagonal)}")

aDiag2x2 = [
    [1,0],
    [0,2]
]

aDiag3x3 = [
    [1,0,0],
    [0,2,0],
    [0,0,3]
]

? oMx.Match(aDiag2x2)
#--> TRUE
? oMx.Match(aDiag3x3)
#--> TRUE
```

This logical composition is a natural way to describe high-level matrix requirements.



## 6. Matching Sets of Matrices

When working with collections, `stzMatrex` can search, count, and extract all matching matrices.

```ring
oMx = new stzMatrex("{property(diagonal)}")

aMatrices = [
    [[1,0],[0,2]],
    [[1,2],[3,4]],
    [[5,0,0],[0,6,0],[0,0,7]],
    [[1,1],[1,1]]
]

? oMx.CountMatchingMatrices(:In = aMatrices)
#--> 2
```

To retrieve them:

```ring
? @@NL(oMx.MatchingMatricesIn(aMatrices))
#-->
'
[
    [[1,0],[0,2]],
    [[5,0,0],[0,6,0],[0,0,7]]
]
'
```

And to analyze a set quantitatively:

```ring
oMx = new stzMatrex("{size(2x2)}")

aMatrices = [
    [[1,2],[3,4]],
    [[5,6],[7,8]],
    [[1,2,3],[4,5,6]],
    [[9,10],[11,12]]
]

? @@NL(oMx.AnalyzeMatches(aMatrices))
#-->
'
[
    ["pattern","{size(2x2)}"],
    ["totalmatrices",4],
    ["matchingcount",3],
    ["nonmatchingcount",1],
    ["matchrate",0.75]
]
'
```

Such analytical feedback transforms `stzMatrex` into a compact matrix quality assessment tool.



## 7. Extracting Matched Components

After a successful match, you can inspect what properties were recognized.

```ring
oMx = new stzMatrex("{size(3x3) & property(symmetric)}")

aMatrix = [
    [1,2,3],
    [2,4,5],
    [3,5,6]
]

oMx.Match(aMatrix)

? @@NL(oMx.MatchedParts())
#-->
'
[
    ["Size",[3,3]],
    ["Matrix",[[1,2,3],[2,4,5],[3,5,6]]],
    ["Properties",["Square","Symmetric"]]
]
'
```

This structured introspection is ideal for automated documentation or for building explainable AI models that interpret numerical patterns.



## 8. Filtering and Selection

When analyzing heterogeneous datasets, you can filter entire lists by pattern match.

```ring
oMx = new stzMatrex("{shape(square)}")

aMatrices = [
    [[1,2],[3,4]],
    [[1,2,3],[4,5,6]],
    [[5,6,7],[8,9,10],[11,12,13]]
]

aFiltered = oMx.FilterMatrices(aMatrices)
? len(aFiltered)
#--> 2
```

Filtering based on structural rules reduces preprocessing complexity in multi-matrix computations.



## 9. Analytical Operations on Similarity and Constraints

Pattern analysis often extends beyond exact matches.
`stzMatrex` can measure similarity and adjust constraints dynamically.

```ring
oMx = new stzMatrex("")

aMatrix1 = [[1,2],[3,4]]
aMatrix2 = [[1,2],[3,4]]
aMatrix3 = [[1,0],[0,4]]

? oMx.SimilarityScore(aMatrix1, aMatrix2)
#--> 1.0
? oMx.SimilarityScore(aMatrix1, aMatrix3)
#--> 0.5
```

It can also find the most similar matrix among candidates:

```ring
oMx = new stzMatrex("")

aTarget = [[1,2],[3,4]]

aCandidates = [
    [[1,2],[3,0]],
    [[5,6],[7,8]],
    [[1,2],[3,4]]
]

? @@(oMx.MostSimilarMatrix(:To = aTarget, :In = aCandidates))
#--> [[1,2],[3,4]]
```

And patterns can evolve interactively:

```ring
oMx = new stzMatrex("{size(3x3)}")

aMatrix = [
    [1,2,3],
    [4,5,6],
    [7,8,9]
]

? oMx.Match(aMatrix)
#--> TRUE

oMx.AddConstraint("property(symmetric)")

? oMx.Match(aMatrix)
#--> FALSE
```

This adaptability makes `stzMatrex` well-suited for progressive data validation and iterative model checking.



## 10. Debugging and Pattern Inspection

For deeper insight, `stzMatrex` offers verbose introspection tools.

```ring
oMx = new stzMatrex("{Size(3x3)}")

aMatrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
]

oMx.EnableDebug()
? oMx.Match(aMatrix)
#--> TRUE
```

The debug trace shows how each token of the pattern is parsed and evaluated.
You can also query the current pattern or inspect its internal tokens:

```ring
? oMx.Pattern()
#--> {size(3x3) & property(identity)}

? @@NL(oMx.Tokens())
```

These features make `stzMatrex` as transparent as it is expressive.



## 11. Comparative Advantages

While other frameworks provide mathematical functions, `stzMatrex` provides **semantic intelligence** — the ability to *describe and recognize* matrix patterns directly.

| Feature                             | **Softanza stzMatrex**                        | NumPy / SciPy            | MATLAB              | Mathematica              |
| ----------------------------------- | --------------------------------------------- | ------------------------ | ------------------- | ------------------------ |
| Declarative pattern syntax          | ✅ `{shape(square) & property(symmetric)}`     | ❌ Procedural checks      | ⚠️ Manual scripting | ✅ Rule-based but verbose |
| Automatic shape detection           | ✅ Built-in                                    | ⚠️ Partial               | ✅ Functions         | ✅                        |
| Matrix property recognition         | ✅ identity, diagonal, upper, lower, symmetric | ⚠️ Requires manual tests | ✅                   | ✅                        |
| Element value constraints           | ✅ `{element(0..10)}` syntax                   | ❌                        | ⚠️                  | ✅                        |
| Logical combination (AND/OR/NOT)    | ✅ Native operators                            | ⚠️                       | ⚠️                  | ✅                        |
| Multi-matrix analysis               | ✅ Count, filter, explain                      | ❌                        | ⚠️                  | ✅                        |
| Similarity scoring                  | ✅ Integrated                                  | ⚠️ External libs         | ❌                   | ⚠️                       |
| Dynamic constraints                 | ✅ Add/Remove live                             | ❌                        | ❌                   | ⚠️                       |
| Debug and explain features          | ✅ Readable structured output                  | ❌                        | ❌                   | ⚠️                       |
| Integration with Softanza ecosystem | ✅ Native                                      | ❌                        | ❌                   | ❌                        |

---

## Conclusion

`stzMatrex` redefines how matrices are *understood* in code.
Where `stzMatrix` performs computations, `stzMatrex` **interprets** structures.
Together, they unify the computational and semantic dimensions of matrix work in Softanza.

By writing clear, human-readable expressions such as:

```ring
{size(3x3)}
{shape(square) & property(symmetric)}
{element(0..10) & @!property(diagonal)}
```

you bring the expressive clarity of pattern languages into the numeric world.
`stzMatrex` turns structural logic into a readable art — bridging mathematics and meaning in one line of code.