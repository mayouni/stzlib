# When code meets cells

*Elementary Introduction · Chapter 10 · Skill PA-04: "Which cells answer my question?"*

A restaurant's menu is a table: one row per dish, one column per fact about it. `stzTable` holds it, draws
it, and answers questions by column, by row and by cell. And a column is a list, so everything you asked a
list in the first chapters can be asked of a column.

## 1. Build the table, and look at it

The first row names the columns. Run the cell to see the table drawn.

```ring
oT = new stzTable([
	[ :DISH, :PRICE, :ORDERS ],
	[ "tea",  200, 6 ],
	[ "rice", 500, 3 ],
	[ "fish", 900, 2 ]
])
oT.Show()
```

## 2. Its shape

```ring
? oT.NumberOfRows()
#--> 3
? oT.NumberOfCols()
#--> 3
? @@( oT.ColNames() )
#--> [ "dish", "price", "orders" ]
```

## 3. A column, a row

```ring
? @@( oT.Col(:PRICE) )
#--> [ 200, 500, 900 ]
? @@( oT.Row(2) )
#--> [ "rice", 500, 3 ]
```

## 4. A cell, and where a value is

```ring
? oT.Cell(:PRICE, 3)
#--> 900
? @@( oT.FindInCol(:DISH, "fish") )
#--> [ 3 ]
```

## 5. A column is a list: ask it the list questions

```ring
? StzListQ(oT.Col(:ORDERS)).Sum()
#--> 11
? @@( StzListQ(oT.Col(:PRICE)).FindW("{ @item > 400 }") )
#--> [ 2, 3 ]
```

{{exercise:ex-10-01}}

## Recap

- **Achieved:** you built a table from rows, read its shape, took a column, a row and a cell, found a value
  in a column, and asked a column the questions of chapter 7.
- **Why it matters:** most of the world's data arrives as tables. Knowing that a column is a list means you
  already know how to question it.
- **Coming next:** some answers are better drawn than printed.
