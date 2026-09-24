# Patterns in structure

*Elementary Introduction · Chapter 9 · Skill PA-02: "What is the shape of this list or these numbers?"*

A list has a shape: a number, then a text. A number has a shape: four digits, or prime, or a multiple of
five. Softanza writes those shapes as patterns too, with `Lx()` for lists and `stzNumbrex` for numbers, and
tests data against them the way chapter 8 tested text.

## 1. The shape of a list

`@N` is a number, `@S` is a text. An order line is a number of portions, then a dish.

```ring
? Lx("[@N, @S]").Match([ 42, "hello" ])
#--> TRUE
? Lx("[@N, @S]").Match([ "hello", 42 ])
#--> FALSE
```

## 2. How many of each

`@N1-3` means one to three numbers.

```ring
? Lx("[@N1-3, @S]").Match([ 1, 2, "end" ])
#--> TRUE
? Lx("[@N1-3, @S]").Match([ 4, 5, 6, 7, "extra" ])
#--> FALSE
```

## 3. A shape inside a shape

```ring
? Lx("[@N, [@N2], @N]").Match([ 1, [ 2, 3 ], 4 ])
#--> TRUE
```

## 4. The shape of a number

A number pattern names a property. `Prime` is one; 17 has it and 18 does not.

```ring
oNx = new stzNumbrex("{@Property(Prime)}")
? oNx.Match(17)
#--> TRUE
? oNx.Match(18)
#--> FALSE
```

## 5. Multiples, and digit counts

```ring
oNx5 = new stzNumbrex("{@Relation(Mod:5=0)}")
? oNx5.Match(10)
#--> TRUE
? oNx5.Match(13)
#--> FALSE
oNx4 = new stzNumbrex("{@Digit4}")
? oNx4.Match(1234)
#--> TRUE
? oNx4.Match(123)
#--> FALSE
```

{{exercise:ex-09-01}}

## Recap

- **Achieved:** you tested lists against a shape of kinds and counts, nested a shape inside another, and
  tested numbers for a property, a multiple and a digit count.
- **Why it matters:** bad data is data with the wrong shape. A shape written down once rejects every bad
  row that will ever arrive, and says why.
- **Coming next:** when data has rows and columns, it is a table, and a table has questions of its own.
