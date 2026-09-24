# Draw the answer

*Elementary Introduction · Chapter 11 · Skills SE-01 "Would a picture answer this faster than a number?" and SE-02 "Where, and how much?"*

`[ 3, 9, 15 ]` is a correct answer to "where is ring?". It is not a quick one. A picture puts the answer
where the eye already is. Softanza draws answers in text, so a drawing is something a program can print,
a page can hold and a guard can check, line by line.

## 1. Show where, not only which position

```ring
o1 = new stzString("fjringljringdjringg")
? @@( o1.FindAll("ring") )
#--> [ 3, 9, 15 ]
? o1.vizFind("ring")
#--> fjringljringdjringg
#--> --^-----^-----^----
```

## 2. With the numbers under the marks

```ring
? o1.vizFindXT("ring", [ :Numbered = TRUE ])
#--> fjringljringdjringg
#--> --^-----^-----^----
#--> 3     9     15
```

## 3. A graph is a picture of relations

An order reaches the kitchen, and the kitchen reaches the table. The graph answers questions, and then
draws itself.

```ring
oG = new stzGraph("kitchen")
oG {
	AddNodeXT("order", "Order")
	AddNodeXT("kitchen", "Kitchen")
	AddNodeXT("table", "Table")
	Connect("order", "kitchen")
	Connect("kitchen", "table")
}
? oG.PathExists("order", "table")
#--> TRUE
? @@( oG.Neighbors("kitchen") )
#--> [ "table" ]
oG.Show()
#--> │ Order │
#--> │ Table │
```

## 4. How much: a bar for each dish

```ring
oP = new stzHBarPlot([ :tea = 6, :rice = 3, :fish = 2 ])
oP.Show()
#--> Tea │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
#--> Fish │ ▇▇▇▇▇▇
```

## 5. The same bars, standing up

```ring
oP2 = new stzVBarPlot([ :tea = 6, :rice = 3, :fish = 2 ])
oP2.SetHeight(4)
oP2.Show()
#--> Tea Rice Fish
```

Maps belong here too: Softanza draws data on a map of a real place, and picks the projection that does not
lie about it. That is the practitioner level of this skill, and a later course.

{{exercise:ex-11-01}}

{{exercise:ex-11-02}}

## Recap

- **Achieved:** you drew where a word is, drew a graph of three relations and asked it a question, and
  drew the orders of three dishes as bars, lying down and standing up.
- **Why it matters:** the render is the instrument. A number can be right and still unread; a picture is
  read at once, and a picture made of text can still be checked by a guard.
- **Coming next:** teaching Softanza what your workplace knows, so it can reason over it.
