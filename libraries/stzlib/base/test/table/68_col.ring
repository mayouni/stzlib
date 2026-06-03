# Narrative
# --------
# #narration #flexibility
#
# Extracted from stztabletest.ring, block #68.
#ERR Error (R14) : Calling Method without definition: colname

load "../../stzBase.ring"


pr()

# Softanza is so flexible! Let's see it in action, for example,
# in using ReplaceCol(). Suppose you have a table like this:

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

# And you want to replace the column :AGE like this:

o1.ReplaceCol( :AGE, :By = [ 22, 20, 21 ] )

# The column is changed:

? o1.Col(:AGE)
#--> [ 22, 20, 21 ]

# Now, if you want to change just the name of the column, then
# pass the name instead of the list of values, like this:

o1.ReplaceCol( :AGE, :By = :LENGTH )

# then the name is changed:

? o1.ColName(3)
#--> :LENGTH

# Of course, you could use this specific function:

o1.ReplaceColName( :LENGTH, :By = :AGE )

# and the age turns back to its original name

? o1.ColName(3) + NL
#--> :AGE

? o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    10     Karim    22
#    20     Hatem    20
#    30   Abraham    21

# You can even use a number of column as a second parameter:

o1.ReplaceCol( :AGE, :ByColNumber = 1 )

o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    10     Karim    10
#    20     Hatem    20
#    30   Abraham    30

pf()
# Executed in 0.15 second(s)
