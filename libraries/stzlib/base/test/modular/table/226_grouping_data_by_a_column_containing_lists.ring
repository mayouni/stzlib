# Narrative
# --------
# Grouping data by a column containing lists
#
# Extracted from stztabletest.ring, block #226.

load "../../../stzBase.ring"


pr()

o1 = new stzTable([
	[
		"name",
		[ "Hela", "John  ", "Ali", "Foued" ]
	],
	[
		"age",
		[ 24, 32, 22, 43 ]
	],
	[
		"hobbies",
		[
			[ "Sport", "Music" ],
			[ "Games", "Travel", "Sport" ],
			[ "Painting", "Dansing" ],
			[ "Music", "Travel" ]
		]
	]
])

o1.ShowXT([ :RowNumber = TRUE ])
#-->
# ╭───┬─────────────────┬─────┬────────────────────────────────╮
# │ # │      Name       │ Age │            Hobbies             │
# ├───┼─────────────────┼─────┼────────────────────────────────┤
# │ 1 │ Hela            │  24 │ [ "Sport", "Music" ]           │
# │ 2 │ John            │  32 │ [ "Games", "Travel", "Sport" ] │
# │ 3 │ Ali             │  22 │ [ "Painting", "Dansing" ]      │
# │ 4 │ Foued           │  43 │ [ "Music", "Travel" ]          │
# ╰───┴─────────────────┴─────┴────────────────────────────────╯

o1.GroupBy(:Hobbies)
o1.Show()
#-->
# ╭──────────┬────────┬─────╮
# │ Hobbies  │  Name  │ Age │
# ├──────────┼────────┼─────┤
# │ Sport    │ Hela   │  24 │
# │ Sport    │ John   │  32 │
# │ Music    │ Hela   │  24 │
# │ Music    │ Foued  │  43 │
# │ Games    │ John   │  32 │
# │ Travel   │ John   │  32 │
# │ Travel   │ Foued  │  43 │
# │ Painting │ Ali    │  22 │
# │ Dansing  │ Ali    │  22 │
# ╰──────────┴────────┴─────╯

pf()
# Executed in 0.21 second(s) in Ring 1.22
