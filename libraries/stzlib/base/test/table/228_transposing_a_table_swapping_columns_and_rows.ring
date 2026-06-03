# Narrative
# --------
# Transposing a table (swapping columns and rows)
#
# Extracted from stztabletest.ring, block #228.
#ERR Error (R14) : Calling Method without definition: transposext

load "../../stzBase.ring"

pr()


o1 = new stzTable([
	[ :ID,	 :AGE,    :SALARY	],
	#----------------------------------#
	[ 10,	 32,		35000	],
	[ 20,	 27,		28900	],
	[ 30,	 24,		25982	],
	[ 40,	 22,		12870	]
])

o1.Show()
#-->
'
╭────┬─────┬────────╮
│ Id │ Age │ Salary │
├────┼─────┼────────┤
│ 10 │  32 │  35000 │
│ 20 │  27 │  28900 │
│ 30 │  24 │  25982 │
│ 40 │  22 │  12870 │
╰────┴─────┴────────╯
'

o1.TransposeXT() # XT ~> Colnames are also transposed
o1.Show()
#-->
'
╭────────┬───────┬───────┬───────┬───────╮
│  Col1  │ Col2  │ Col3  │ Col4  │ Col5  │
├────────┼───────┼───────┼───────┼───────┤
│ id     │    10 │    20 │    30 │    40 │
│ age    │    32 │    27 │    24 │    22 │
│ salary │ 35000 │ 28900 │ 25982 │ 12870 │
╰────────┴───────┴───────┴───────┴───────╯
'

o1.TransposeBack()
o1.Show()
#-->
'
╭────┬─────┬────────╮
│ Id │ Age │ Salary │
├────┼─────┼────────┤
│ 10 │  32 │  35000 │
│ 20 │  27 │  28900 │
│ 30 │  24 │  25982 │
│ 40 │  22 │  12870 │
╰────┴─────┴────────╯
'

pf()
# Executed in 0.20 second(s) in Ring 1.22
