load "stzlib.ring"

pron()

o1 = new stzList([ "A", "B", "C", "D", "E" ])
? @@( o1.FindMany([ "A", "B", "A", "B", "B" ]) )
#--> [ 1, 2 ]

o1.ReplaceManyByMany([ "A", "B", "A", "D", "E" ], :With = [ "1", "2"])
? @@( o1.Content() )
#--> [ "A", "*", "C", "*", "*" ]

proff()
# Executed in 0.05 second(s)

/*=============
*/
pron()

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3,	:COL4 ],
	#-------------------------------------#
	[ 10,	    "*",      100,	"*"   ],
	[ 20,	    "*",      200,	"*"   ],
	[ 30,	    "*",      300,	"*"   ]
])

? o1.FindColByValue([ 100, 200, 300 ])
#--> [ 3 ]

? o1.FindColByValue([ "*", "*", "*" ])
#--> [ 2, 4 ]

? o1.FindColByName(:COL3)
#--> 3

? o1.FindColsByName([ :COL2, :COL4 ])
#--> [ 2, 4 ]

/*
? o1.FindManyColsByValue([
	[ 100, 200, 300 ],
	[ "*", "*", "*" ]
])
#--> [ 3, 4, 5, 6 ]

/*
? o1.FindRowsExcept([
	[ 30, 300, 3000 ],
	[ "*", "*", "*" ]
])
#--> [1, 2]
*/
proff()

/*=============

pron()

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3 ],
	#----------------------------#
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ "*",	    "*",      "*"   ],
	[ 30,	    300,      3000  ],
	[ "*",	    "*",      "*"   ],
	[ "*",	    "*",      "*"   ]
])

? o1.FindRow([ 30, 300, 3000 ])
#--> [ 4 ]

? o1.FindRow([ "*", "*", "*" ])
#--> [ 3, 5, 6 ]

? o1.FindManyRows([
	[ 30, 300, 3000 ],
	[ "*", "*", "*" ]
])
#--> [ 3, 4, 5, 6 ]

? o1.FindRowsExcept([
	[ 30, 300, 3000 ],
	[ "*", "*", "*" ]
])
#--> [1, 2]

proff()
# Executed in 0.39 second(s)

/*-------------

pron()

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3 ],
	#----------------------------#
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ "*",	    "*",      "*"   ],
	[ 30,	    300,      3000  ]
])

o1.RemoveRow(3)

o1.Show()
#--> :COL1   :COL2   :COL3
#    ------ ------- ------
#       10     100    1000
#       20     200    2000
#       30     300    3000

proff()
# Executed in 0.31 second(s)

/*-------------

pron()

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3 ],
	#----------------------------#
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ "*",	    "*",      "*"   ],
	[ 30,	    300,      3000  ],
	[ "*",	    "*",      "*"   ],
	[ "*",	    "*",      "*"   ]
])

o1.RemoveRows([3, 5, 6])

o1.Show()
#--> :COL1   :COL2   :COL3
#    ------ ------- ------
#       10     100    1000
#       20     200    2000
#       30     300    3000

proff()
# Executed in 0.31 second(s)

/*-------------
*/
pron()

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3 ],
	#----------------------------#
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ "*",	    "*",      "*"   ],
	[ 30,	    300,      3000  ],
	[ "*",	    "*",      "*"   ],
	[ "*",	    "*",      "*"   ]
])

o1.RemoveAllRowsExcept([1, 2, 4]) # Or RemoveRowsOtherThan()

o1.Show()
#--> :COL1   :COL2   :COL3
#    ------ ------- ------
#       10     100    1000
#       20     200    2000
#       30     300    3000

proff()
# # Executed in 0.31 second(s)

/*============ A Softanza narration showing one of the uses of the XT()

pron()

# You create a table with this structure:

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3 ],
	#----------------------------#
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ "*",	    "*",      "*"   ],
	[ 30,	    300,      3000  ]
])

# And you want to show it on screen:

? o1.Show() + NL
#--> :COL1   :COL2   :COL3
#    ------ ------- ------
#       10     100    1000
#       20     200    2000
#        *       *       *
#       30     300    3000

# That's fine! But you may want a more elaborated formatting!
# Use the XT() extension:

? o1.ShowXT([]) + NL
#--> :COL1 | :COL2 | :COL3
#    ------+-------+------
#       10 |   100 |  1000
#       20 |   200 |  2000
#        * |     * |     *
#       30 |   300 |  3000

# Satisfied? No? You can change the default options at your will...

? o1.ShowXT([

	:Separator 	  = " | ",
	:Alignment 	  = :Center,

	:UnderLineHeader  = TRUE,
	:UnderLineChar 	  = "-",
	:IntersectionChar = "+",

	:ShowRowNumbers   = TRUE

])
#--> # | :COL1 | :COL2 | :COL3
#    --+-------+-------+------
#    1 |  10   |  100  | 1000 
#    2 |  20   |  200  | 2000 
#    3 |   *   |   *   |   *  
#    4 |  30   |  300  | 3000 

proff()
# Executed in 1.09 second(s)

/*--------------

pron()

o1 = new stzTable([3, 4])
? o1.Show()
#--> 	:COL1  	:COL2  	:COL3
#	NULL	NULL	NULL
#	NULL	NULL	NULL
#	NULL	NULL	NULL
#	NULL	NULL	NULL

proff()
# Executed in 0.35 second(s)

/*==========

pron()

# Special syntax to enable the SQL syntax in Ring

o1 = new stzTable([])
? IsStzObject(o1)
#--> TRUE

o1.@([
	:COL2 = :INT,
	:COL3 = VARCHAR(30)
])

o1.Show()
#--> :COL1  :COL2  :COL3
#    NULL   NULL   NULL

proff()

/*--------------

StartProfiler()

o1 = new stzList([ "ONE", "two", "THREE", 1, 2 ])
? o1.ContainsCS("TwO", :CS=FALSE)

StopProfiler()
#--> Executed in 0.02 second(s)

/*
cTable = This.HeaderToString() + NL + This.RowsToStringXT(paOptions)

/*--------------

StartProfiler()

	o1 = new stzTable([
		[ :ID,	 :EMPLOYEE,    	:SALARY	],
		#-------------------------------#
		[ 10,	 "Ali",		35000	],
		[ 20,	 "Dania",	28900	],
		[ 30,	 "Han",		25982	],
		[ 40,	 "Ali",		12870	]
	])

	o1.Show()

	? o1.MaxWidthInEachCol()
	#--> [ 2, 5, 5 ]

	? o1.MaxWidthInCol(:EMPLOYEE)
	#--> 5

	? o1.NthColName(:LastCol)
	#--> :SALARY

	? o1.RowToString(2)
	#--> 20   Dania   28900

	? o1.RowsToString()
	#--> 1   10     Ali   35000
	#    2   20   Dania   28900
	#    3   30     Han   25982
	#    4   40     Ali   12870

	? @@( o1.CellsInColsAsPositions([ :EMPLOYEE, :SALARY ]) )
	#--> [
	# 	[ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 2, 4 ],
	# 	[ 3, 1 ], [ 3, 2 ], [ 3, 3 ], [ 3, 4 ]
	# ]

	? o1.CellsToHashList()["[ 3, 4 ]"]
	#--> 12870

	? @@( o1.SectionAsPositions([2,2], [3, 4]) )
	#--> [ [ 2, 2 ], [ 3, 2 ], [ 2, 3 ], [ 3, 3 ], [ 2, 4 ], [ 3, 4 ] ]

StopProfiler()
# Executed in 1.56 second(s)

/*--------------

StartProfiler()

o1 = new stzTable([3, 3])

o1.Fill( :With = "." )
o1.Show() + NL
#--> #   COL1   COL2   COL3
#    1      .      .      .
#    2      .      .      .
#    3      .      .      .

o1.ReplaceRow(2, :With = [ "+", "+" ])
o1.Show() + NL
#--> #   COL1   COL2   COL3
#    1      .      .      .
#    2      +      +      .
#    3      .      .      .

o1.ReplaceRow(2, :With = [ "+", "+", "+" ])
o1.Show() + NL
#--> #   COL1   COL2   COL3
#    1      .      .      .
#    2      +      +      +
#    3      .      .      .

o1.ReplaceRow(2, :With = [ "+", "+", "+", "+", "+" ])
o1.Show()
#--> #   COL1   COL2   COL3
#    1      .      .      .
#    2      +      +      +
#    3      .      .      .

StopProfiler()
# Executed in 1.89 second(s)

/*--------------

pron()

o1 = new stzTable([3, 3])
o1.Fill( :With = "." )
o1.Show() + NL
#--> #   COL1   COL2   COL3
#    1      .      .      .
#    2      .      .      .
#    3      .      .      .

o1.ReplaceAllRows(:With = [ "+", "+", "+" ])
o1.Show()
#--> #   COL1   COL2   COL3
#    1      +      +      +
#    2      +      +      +
#    3      +      +      +

proff()
# Executed in 0.98 second(s)

/*--------------

pron()

o1 = new stzTable([2, 3])
o1.Fill( :With = "." )
o1.Show() + NL
#--> #   COL1   COL2
#    1      .      .
#    2      .      .
#    3      .      .

o1.ReplaceCol(:COL2, :With = [ "+", "+" ])
o1.Show()
#--> #   COL1   COL2
#    1      .      +
#    2      .      +
#    3      .      .

o1.ReplaceCol(:COL2, :With = [ "+", "+", "+" ]) + NL
o1.Show()
#--> #   COL1   COL2
#    1      .      +
#    2      .      +
#    3      .      +

o1.ReplaceCol(:COL2, :With = [ "+", "+", "+", "+", "+" ])
o1.Show()
#--> #   COL1   COL2
#    1      .      +
#    2      .      +
#    3      .      +

proff()
# Executed in 1.31 second(s)

/*--------------

pron()

o1 = new stzTable([3, 3])
o1.Fill( :With = "." )
o1.Show() + NL
#--> #   COL1   COL2   COL3
#    1      .      .      .
#    2      .      .      .
#    3      .      .      .

o1.ReplaceAllCols(:With = [ "A", "B", "C" ])
o1.Show()
#--> #   COL1   COL2   COL3
#    1      A      A      A
#    2      B      B      B
#    3      C      C      C

proff()
# Executed in 1.02 second(s)

/*----------------

pron()

o1 = new stzTable([3, 3])
o1.Fill( :With = "." )
o1.Show()
#--> #   COL1   COL2   COL3
#    1      .      .      .
#    2      .      .      .
#    3      .      .      .

o1.Fill( :WithRow = [ "A", "B" ] )
o1.Show()
#--> #   COL1   COL2   COL3
#    1      A      B      .
#    2      A      B      .
#    3      A      B      .

proff()
# Executed in 1.09 second(s)

/*----------------

pron()

? Q([
	[ "COL1", [ "A", "B", "C" ] ],
	[ "COL2", [ "a", "b", "c" ] ],
	[ "COL3", [ "1", "2", "3" ] ]
]).IsHashList()
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*----------------

pron()

o1 = new stzTable([
	[ "COL1", [ "A", "B", "C" ] ],
	[ "COL2", [ "a", "b", "c" ] ],
	[ "COL3", [ "1", "2", "3" ] ]
])

o1.Show()
#-->
# #   COL1   COL2   COL3
# 1      A      a      1
# 2      B      b      2
# 3      C      c      3

proff()
# Executed in 0.54 second(s)

/*----------------

pron()

? @@( StzTableQ([ 3, 3 ]).Filled(:With = "A") )
#--> [
# 	[ "col1", [ "A", "A", "A" ] ],
# 	[ "col2", [ "A", "A", "A" ] ],
# 	[ "col3", [ "A", "A", "A" ] ]
# ]

proff()
# Executed in 0.09 second(s)

/*----------------

pron()

o1 = StzTableQ([ 3, 3 ]) { Fill(:With = "A") }
o1.Show()
#--> #   COL1   COL2   COL3
#    1      A      A      A
#    2      A      A      A
#    3      A      A      A

proff()
# Executed in 0.48 second(s)

/*----------------

pron()

o1 = new stzTable([3, 3])
o1.Fill( :With = "." )
o1.Show()
#--> #   COL1   COL2   COL3
#    1      .      .      .
#    2      .      .      .
#    3      .      .      .

o1.Fill( :WithCol = [ "A", "B" ] ) + NL
o1.Show()
#--> #   COL1   COL2   COL3
#    1      A      A      A
#    2      B      B      B
#    3      .      .      .

o1.Fill( :WithCol = [ "A", "B", "C" ] )
o1.Show()
#--> #   COL1   COL2   COL3
#    1      A      A      A
#    2      B      B      B
#    3      C      C      C

proff()
# Executed in 1.58 second(s)

/*===============

pron()

# A table can be created in 5 different ways:

# WAY 1 : Creating an empty table with just a column and a row with just an empty cell
o1 = new stzTable([])

? @@( o1.Content() ) + NL
#--> [ [ "COL1", [ "" ] ] ]

o1.ShowXT([ :ReplaceEmptyCellsWith = "NULL" ])
#-->
# #   COL1
# 1   NULL

proff()
# Executed in 0.08 second(s)

/*--------------

pron()

# WAY 2 : Creating an empty table with 3 columns and 3 rows
o1 = new stzTable([3, 2])
o1.Show()
#-->
# #   COL1   COL2   COL3
# 1                     
# 2     

o1.ShowXT([ :ReplaceEmptyCellsWith = "NULL" ])
#-->
# #   COL1   COL2   COL3
# 1   NULL   NULL   NULL
# 2   NULL   NULL   NULL

proff()
# Executed in 0.53 second(s)

/*---------------

pron()

# WAY 3: Creating a table by provding a list of lists, formatted as you
# would find it in the real world (the first line is for column names!)

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

o1.Show()
#-->
# #   ID   EMPLOYEE   SALARY
# 1   10        Ali    35000
# 2   20      Dania    28900
# 3   30        Han    25982
# 4   40        Ali    12870

proff()
# Executed in 0.61 second(s)

/*---------------

pron()

# WAY 4: Creating a table by provding just the rows, without
# column names (they are added automatically by softanza):

o1 = new stzTable([
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

o1.Show()
#-->
# #   COL1    COL2    COL3
# 1     10     Ali   35000
# 2     20   Dania   28900
# 3     30     Han   25982
# 4     40     Ali   12870

proff()
# Executed in 0.61 second(s)

/*-----------------

pron()

# WAY 5: Creating a table by providing a hashtable where
# the column names are keys and rows are values
# (internally, stzTable content is hosted in this hashlist)

o1 = new stzTable([
 	:NAME   = [ "Ali", 	  "Dania", 	"Han" 	 ],
 	:JOB    = [ "Programmer", "Manager", 	"Doctor" ],
	:SALARY = [ 35000, 	  50000, 	62500    ]
])

o1.Show()
#--> 	#    NAME          JOB   SALARY
#	1     Ali   Programmer    35000
#	2   Dania      Manager    50000
#	3     Han       Doctor    62500

proff()
# Executed in 0.47 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.ReplaceRow(3, :With = [ 50, "NONE", 99 ])
? o1.Row(3)
#--> [ 50, "NONE", 99 ]

o1.ReplaceCol(:AGE, :With = [ "_", "_", "_" ])
? o1.Col(:AGE)
#--> [ "_", "_", "_" ]

proff()
# Executed in 0.15 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

? o1.ColName(3)
#--> :AGE

? o1.ColName(:NAME)
#--> :NAME

o1.ReplaceColName(:NAME, :EMPLOYEE)
o1.Show() + NL
#-->
# #   ID    EMPLOYEE   AGE
# 1   10     Karim    52
# 2   20     Hatem    46
# 3   30   Abraham    48

proff()
# Executed in 0.48 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

? o1.ColNumber(:AGE) 
#--> 3

? o1.ColNumber(2)
#--> 2

//? o1.ColNumber(:NONE)
#--> Error message:
# Incorrect param value! p must be a number or string.
# Allowed strings are :First, :FirstCol, :Last,
# :LastCol and any valid column name.

//? o1.ColNumber(22)
#--> Error message:
# Incorrect value! n must be a number between 1 and 3.

proff()
# Executed in 0.05 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.MoveRow( :From = 3, :To = 1 )
o1.Show()
#-->
# #   ID      NAME   AGE
# 1   30   Abraham    48
# 2   20     Hatem    46
# 3   10     Karim    52

proff()
# Executed in 0.51 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.SwapRows( :BetweenPositions = 2, :And = 3 )
o1.Show() + NL
#-->
# #   ID      NAME   AGE
# 1   10     Karim    52
# 2   30   Abraham    48
# 3   20     Hatem    46

o1.SwapColumns( :BetweenPosition = 2, :And = 3)
o1.Show()
#-->
# #   ID   AGE      NAME
# 1   10   52     Karim
# 2   30   48   Abraham
# 3   20   46     Hatem

proff()
# Executed in 1.05 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.MoveCol( :ID, :ToPosition = 3 )
# or alternatively: o1.MoveCol( :FromPosition = 1, :To = 3 )

o1.Show() // TODO: fix formatting
#-->
# #   AGE      NAME   ID
# 1    52     Karim   10
# 2    46     Hatem   20
# 3    48   Abraham   30

proff()
# Executed in 0.48 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.AddCol( :AGE = [ 1, 2, 3 ] )
#--> Error message:
# Can't add the column! The name your provided already exists.

proff()

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.SwapColums( :AGE, :And = :NAME )
o1.Show()
#-->
# #   ID   AGE      NAME
# 1   10    52     Karim
# 2   20    46     Hatem
# 3   30    48   Abraham

proff()
# Executed in 0.71 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.ReplaceColName( :NAME, :FRIEND )
? o1.ColName(2)
#--> :FRIEND

proff()
# Executed in 0.06 second(s)

/*===============

pron()

# Softanza is so flexible! Let's see it in action, for example,
# in using ReplaceCol(). So, you have a table like this:

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

# And you want to replace the column :AGE and make them all young:
o1.ReplaceCol( :AGE, :By = [ 22, 20, 21 ] )
# The column is changed:
? o1.Col(:AGE) #--> [ 22, 20, 21 ]

# Now, if you want to change just the name of the column, then
# pass the name instead of the list of values, like this:
o1.ReplaceCol( :AGE, :By = :LENGTH )
# then the name is changed:
? o1.ColName(3) #--> :LENGTH

# Of course, you could use this specific function:
o1.ReplaceColName( :LENGTH, :BY = :AGE )
# and the age turns back to its original name
? o1.ColName(3) #--> AGE

proff()
# Executed in 0.21 second(s)

/*==============

StartProfiler()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.Sort(:By = :NAME)

o1.Show() + NL
#-->
# #	ID	NAME		AGE
# 1	30	Abraham		48
# 2	20	Hatem		46
# 3	10	Karim		52

o1.Sort(:By = :ID)
o1.Show() + NL
#-->
# #   ID      NAME   AGE
# 1   10     Karim    52
# 2   20     Hatem    46
# 3   30   Abraham    48

o1.Sort(:By = :AGE)
o1.Show()
#-->
# #   ID      NAME   AGE
# 1   20     Hatem    46
# 2   30   Abraham    48
# 3   10     Karim    52

StopProfiler()
# Executed in 1.93 second(s)

# NOTE/TODO: Show() function takes time! Optimise it...

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.SortInDescending(:By = :ID)	# Or if you want: o1.SortXT(:By = :ID, :InDescending)
o1.Show()
#-->
# #   ID      NAME   AGE
# 1   30   Abraham    48
# 2   20     Hatem    46
# 3   10     Karim    52

proff()
# Executed in 0.65 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

? @@( o1.ColAsPositions(:NAME) ) + NL
#--> [ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ] ]

? @@( o1.ColsAsPositions([ :NAME, :AGE ]) ) + NL
#--> [ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ] ]

? @@( o1.RowAsPositions(3) ) + NL
#--> [ [ 1, 2 ], [ 2, 2 ], [ 3, 2 ] ]

? @@( o1.RowsAsPositions([2, 3]) ) + NL
#--> [ [ 1, 2 ], [ 2, 2 ], [ 3, 2 ], [ 1, 3 ], [ 2, 3 ], [ 3, 3 ] ]

proff()
# Executed in 0.13 second(s)

/*--------------

pron()

o1 = new stzTable([
	[  "COL1",   "COL2" ],
	#-------------------#
	[     "a",    "R1"  ],
	[ "abcde",    "R5"  ],
	[   "abc",    "R3"  ],
	[    "ab",    "R2"  ],
	[     "b",    "R1"  ],
	[   "abcd",   "R4"  ]
])

? @@( o1.CellsInCols([:COL1, :COL2]) ) + NL
#--> [ "a", "abcde", "abc", "ab", "b", "abcd", "R1", "R5", "R3", "R2", "R1", "R4" ]

? @@( o1.CellsInRows([1, 3, 5]) ) + NL
#--> [ "a", "R1", "abc", "R3", "b", "R1" ]

proff()
# Executed in 0.21 second(s)

/*===============

pron()

o1 = new stzTable([
	[  "COL1",   "COL2" ],
	#-------------------#
	[     "a",    "R1"  ],
	[ "abcde",    "R5"  ],
	[   "abc",    "R3"  ],
	[    "ab",    "R2"  ],
	[     "b",    "R1"  ],
	[   "abcd",   "R4"  ]
])

o1.Sort(:By = :COL2)
# or o1.SortInAscending(:By = :COL2)
# or o1.SortXT(:By = :COL2, :InAscending)
# o1.SortXT(:By = :COL2, :In = :Ascending)

o1.Show() + NL
#-->
# #    COL1   COL2
# 1       a     R1
# 2       b     R1
# 3      ab     R2
# 4     abc     R3
# 5    abcd     R4
# 6   abcde     R5

o1.SortInDescending(:By = :Col2)
# or o1.SortXT(:By = :Col2, :InDescending)
# or o1.SortXT(:By = :Col2, :In = :Descending)

o1.Show()
#-->
# #    COL1   COL2
# 1   abcde     R5
# 2    abcd     R4
# 3     abc     R3
# 4      ab     R2
# 5       b     R1
# 6       a     R1

proff()
# Executed in 2.22 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? o1.ContainsCol( :NAME = [ "Imed", "Hatem", "Karim" ] )
#--> TRUE

? o1.ContainsCols([
	:NAME = [ "Imed", "Hatem", "Karim" ],
	:AGE  = [ 52, 46, 48 ]
])
#--> TRUE

? o1.ContainsRow([ 20, "Hatem", 46 ])
#--> TRUE

? o1.ContainsRows([
	[ 20, "Hatem", 46 ],
	[ 30, "Karim", 48 ]
])
#--> TRUE

proff()
# Executed in 0.33 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.SectionAsPositions([2, 2], [3, 3]) )
#--> [ [ 2, 2 ], [ 3, 2 ], [ 2, 3 ], [ 3, 3 ] ]

? @@(o1.Section([2, 2], [3, 3])) + NL
#--> [ "Hatem", 46, "Karim", 48 ]

? @@(o1.SectionZ([2, 2], [3, 3])) + NL # or SectionAndPosiition()
#--> [
#	[ [ 2, 2 ], "Hatem" ],
#	[ [ 3, 2 ], 46 ],
#	[ [ 2, 3 ], "Karim"],
#	[ [ 3, 3 ], 48 ]
# ]

? @@( o1.Section(:FirstCell, :LastCell) )
#--> [ 10, "Imed", 52, 20, "Hatem", 46, 30, "Karim", 48 ]

proff()
# Executed in 0.15 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.Cells() ) + NL
#--> [ 10, "Imed", 52, 20, "Hatem", 46, 30, "Karim", 48 ]

? @@( o1.CellsXT() ) + NL # Same as CellsAndPositions() and CellsZ()
#--> [
#	[ 10, 		[ 1, 1 ] ],
#	[ "Imed", 	[ 2, 1 ] ],
#	[ 52, 		[ 3, 1 ] ],
#	[ 20, 		[ 1, 2 ] ],
#	[ "Hatem", 	[ 2, 2 ] ],
#	[ 46, 		[ 3, 2 ] ],
#	[ 30, 		[ 1, 3 ] ],
#	[ "Karim", 	[ 2, 3 ] ],
#	[ 48, 		[ 3, 3 ] ]
# ]

? @@( o1.PositionsAndCells() ) + NL
#--> [
#	[ [ 1, 1 ],	10	 ],
#	[ [ 2, 1 ],	"Imed"	 ],
#	[ [ 3, 1 ],	52	 ],
#	[ [ 1, 2 ],	20	 ],
#	[ [ 2, 2 ],	"Hatem"	 ],
#	[ [ 3, 2 ],	46	 ],
#	[ [ 1, 3 ],	30	 ],
#	[ [ 2, 3 ],	"Karim"	 ],
#	[ [ 3, 3 ],	48	 ]
# ]

? @@( o1.CellsToHashList() ) + NL
#--> [
#	"[ 1, 1 ]" = 10,
#	"[ 2, 1 ]" = "Imed",
#	"[ 3, 1 ]" = 52,
#	"[ 1, 2 ]" = 20,
#	"[ 2, 2 ]" = "Hatem",
#	"[ 3, 2 ]" = 46,
#	"[ 1, 3 ]" = 30,
#	"[ 2, 3 ]" = "Karim",
#	"[ 3, 3 ]" = 48
# ]

? @@( o1.SectionToHashList([2, 2], [3, 3]) )
#--> [
#	[ "[ 2, 2 ]", "Hatem" ],
#	[ "[ 3, 2 ]", 46 ],
#	[ "[ 2, 3 ]", "Karim" ],
#	[ "[ 3, 3 ]", 48 ]
# ]

proff()
# Executed in 0.36 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? o1.NumberOfColumns()
#--> 3

? o1.HasCol(:NAME)
#--> TRUE

? o1.ColNames()
#--> [ "id", "name", "age" ]

? o1.ColName(2)
#--> "name"

proff()
# Executed in 0.05 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.Cell(2, 2) )
#--> "Hatem"

? o1.Cell(:EMPLOYEE, 2)
#--> Error message:
# Syntax error in (employee)! This column name is inexistant.

? o1.Cell(5, 7) )
#--> Error message:
# Array Access (Index out of range) ! 

proff()

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? o1.NumberOfRows()
#--> 3

? o1.NumberOfCols()
#--> 3

? o1.NumberOfCells()
#--> 12

proff()
# Executed in 0.03 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.Header() ) + NL
#--> [ "id", "name", "age" ]

proff()
# Executed in 0.03 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME 	],
	[ 10,	"Imed" 	],
	[ 20,	"Hatem" ],
	[ 30,	"Karim" ]
])

o1.AddCol(:AGE = [ 55, 35, 28 ])
? @@( o1.Content() )
#--> [
#	[ "id", 	[ 10, 20, 30 ] 			],
#	[ "name", 	[ "Imed", "Hatem", "Karim" ] 	],
#	[ "age", 	[ 55, 35, 28 ] 			]
# ]

proff()
# Executed in 0.05 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME 	],
	#---------------#
	[ NULL,	NULL 	],
	[ NULL,	NULL 	],
	[ NULL,	NULL 	]
])

// A table is empty when all its cells are NULL
? o1.IsEmpty()
#--> TRUE

proff()
# Executed in 0.10 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.NthCol(3) )
#--> [ 52, 46, 48 ]

proff()
# Executed in 0.04 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.FirstColXT() )
#--> [ "id", 10, 20, 30 ]

? @@( o1.LastColXT() )
#-->[ "age", 52, 46, 48 ]

proff()
# Executed in 0.06 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.Row(2) ) + NL
#--> [ 20, "Hatem", 46 ]

? @@( o1.Rows() )
#-->
# [
#	[ 10, "Imed",	52 ],
#	[ 20, "Hatem", 	46 ],
#	[ 30, "Karim",	48 ]
# ]

proff()
# Executed in 0.08 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

//o1.AddCol( :JOB = [ "Pilot", "Designer", "Author", "thing" ] )
#--> Error message:
# Incorrect number of cells! paColNameAndData must contain extactly 3 cells.

o1.AddCol( :JOB = [ "Pilot", "Designer", "Author" ] )
? o1.Show()
#-->
# #   ID    NAME   AGE        JOB
# 1   10    Imed   52      Pilot
# 2   20   Hatem   46   Designer
# 3   30   Karim   48     Author

o1.RemoveCol(:JOB)
o1.Show()
#-->
# #   ID    NAME   AGE
# 1   10    Imed   52
# 2   20   Hatem   46
# 3   30   Karim   48

proff()
# Executed in 0.04 second(s) without Show() function
# Executed in 1.05 second(s) with Show function
# TODO: Show() function should be optimised!

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

o1.RemoveCol([ :ID, :AGE ])
? @@( o1.Content() )
#--> [ [ "name", [ "Imed", "Hatem", "Karim" ] ] ]

proff()
# Executed in 0.16 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.Cols() )
#--> [ "id", "name", "age" ]
 
proff()
# Executed in 0.04 second(s)

/*==============

# Functions used internallu to generate the output of Show()

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.MaxWidthInEachCol() )
#--> [ 2, 5, 2 ]

? @@( o1.MaxWidthInEachColXT() )
#--> [ 1, 2, 5, 2 ]

?  @@( o1.MaxWidthInEachRow() )
#--> [ 4, 5, 5 ]

? o1.HeaderToString()
#--> "#   ID    NAME   AGE"

proff()
# Executed in 0.51 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? o1.MaxWidthInCol("NAME")
#--> 5

? o1.MaxWidthInRow(3)
#--> 5

proff()
# Executed in 0.12 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])


? @@( o1.Col(3) ) # Same as  o1.ColData(3), o1.Col(:AGE), and o1.ColData(:AGE)
#--> [ 52, 46, 48 ]

? o1.ColName(3)
#--> age

proff()
# Executed in 0.05 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])


? @@( o1.TheseColumnsXT([ :ID, :NAME ]) ) // Same as o1.TheseColumnsXT([1, 2])
#--> [
#	[ "id", 	[ 10, 20, 30 ] 			],
#	[ "name", 	[ "Imed", "Hatem", "Karim" ] 	]
# ]

proff()
# Executed in 0.14 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.ColZ(2) )
#--> [ [ "Imed", [ 2, 1 ] ], [ "Hatem", [ 2, 2 ] ], [ "Karim", [ 2, 3 ] ] ]

proff()
# Executed in 0.06 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? o1.ColNames()
#--> [ "id", "name", "age" ]

? o1.IsColName(:name)
#--> TRUE

? o1.IsColNumber(3)
#--> TRUE

? o1.IsColNameOrNumber(:age)
#--> TRUE

? o1.AreColNamesOrNumbers([ :name, :age ])
#--> TRUE

? o1.AreColID([ :name, :age ])
#--> TRUE

proff()

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.AllCols() )
#--> [
#	[ 10, 20, 30 ],
#	[ "Imed", "Hatem", "Karim" ],
#	[ 52, 46, 48 ]
# ]

? @@( o1.TheseCols([ 1, 3 ]) ) + NL
#--> [
#	[ 10, 20, 30 ],
#	[ 52, 46, 48 ]
# ]

? @@( o1.ColsXT() )
#--> [
#	:ID 	= [ 10, 20, 30 ],
#	:NAMED 	= [ "Imed", "Hatem", "Karim" ],
#	:AGE 	= [ 52, 46, 48 ]
# ]


? @@( o1.TheseColsXT([ 1, 3 ]) )
#--> [
#	[ "id", [ 10, 20, 30 ] ],
#	[ "age", [ 52, 46, 48 ] ]
# ]

? @@( o1.CellsInCols([ :name, :age ]) )
#--> [ "Imed", "Hatem", "Karim", 52, 46, 48 ]

proff()
# Executed in 0.31 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])


? o1.ColNumbersToNames([3, 1])
#--> [ "age", "id" ]

? @@( o1.ColNamesToNumbers([ :AGE, :ID ]) )
#--> [ 3, 1 ]


proff()
# Executed in 0.07 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])


? o1.TheseColNames([1, 2]) #--> [ "id", "employee" ]
#--> [ "id", "name" ]

proff()
# Executed in 0.04 second(s)

/*==============

? Q(["", "", ""]).AllItemsAreNull()
#--> TRUE

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.IsEmpty()
#--> FALSE

o1.Erase()

? o1.IsEmpty()
#--> TRUE

? o1.Show()
#-->
# #   ID    EMPLOYEE   	SALARY
# 1   NULL  NULL	NULL
# 2   NULL  NULL	NULL
# 3   NULL  NULL	NULL

proff()
# Executed in 0.57 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.Cell(:EMPLOYEE, 3)
#--> "Sonia"

o1.EraseCell(2, 3)

? @@( o1.Cell(2, 3) )
#--> NULL

proff()
# Executed in 0.09 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.Cell(:EMPLOYEE, :LastRow)
#--> "Sonia"


? o1.Cell(:FirsCol, :LastRow)
#--> ERR: Syntax error in (firscol)! Allowed values are
#	  :First or :Last (or :FirstCol or :LastCol).

proff()
# Executed in 0.09 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.FirstColName()
#--> "id"

? o1.LastColName()
#--> "salary"

proff()
# Executed in 0.04 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])


? o1.Col(:First)
#--> [ "001", "002", "003" ]

? o1.Col(:Last) # Works when CheckParams() = TRUE, otherwise use LastCol()
#--> [ 12499.20, 10890.10, 12740.30 ]

proff()
# Executed in 0.06 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.Row(:First)
#--> [ "001", "Salem", 12499.20 ]

? o1.Row(:Last) # Works when CheckParams() = TRUE, otherwise use LAstRow()
#--> [ "003", "Sonia", 12740.30 ]

proff()
# Executed in 0.06 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "*****", 10000.10 ],
	[ "003", "Sonia", 12740.30 ],
	[ "002", "*****", 10000.10 ]
])

? @@( o1.FindCol(:SALARY) )
#--> 3

? @@( o1.FindRow([ "002", "*****", 10000.10 ]) )
#--> [ 2, 4 ]

proff()
# Executed in 0.20 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	   :EMPLOYEE, 	:SALARY   ],
	#---------------------------------#
	[ "001",   "Salima", 	12499.20  ],
	[ "002",   "Sonia", 	10000.10  ],
	[ "003",   "So",	12780.45  ],
	[ "004",   "GonSonSo", 	12740.30  ],
	[ "005",   "Mansour", 	10000.10  ],
	[ "006",   "so", 	14800.10  ]
])

? @@( o1.FindInCol(:EMPLOYEE, "---") )
#--> [ ]

? @@( o1.FindInCol(:EMPLOYEE, "So") )
#--> [ [ 2, 3 ] ]

? @@( o1.FindInColCS(:EMPLOYEE, "So", :CS = FALSE) )
#--> [ [ 2, 3 ], [ 2, 6 ] ]


? @@( o1.FindInCol(:EMPLOYEE, :SubValue = "So") )
#--> [
#	[ [ 2, 2 ], [ 1 ] 	],
#	[ [ 2, 3 ], [ 1 ] 	],
#	[ [ 2, 4 ], [ 4, 7 ] 	]
# ]

? @@( o1.FindInColCS(:EMPLOYEE, :SubValue = "So", :CS = FALSE) )
#--> [
# 	[ [ 2, 2 ], [ 1 ] 	],
#	[ [ 2, 3 ], [ 1 ] 	],
#	[ [ 2, 4 ], [ 4, 7 ] 	],
#	[ [ 2, 5 ], [ 4 ] 	],
#	[ [ 2, 6 ], [ 1 ] 	]
# ]

proff()
# Executed in 0.62 second(s)

/*===================

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? @@( o1.VerticalSection(:EMPLOYEE, :From = 2, :To = :LastRow) )
#--> [ "Henri", "Sonia" ]

? @@( o1.VerticalSectionAsPositions(:EMPLOYEE, 2, :LastRow) )
#--> [ [ 2, 2 ], [ 2, 3 ] ]

proff()
# Executed in 0.10 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.CellAtPosition(2, 3) + NL
#--> "Sonia"

? o1.TheseCells([ [ 2, 1 ], [ 2, 3 ] ])
#--> [ "Salem", "Sonia" ]

proff()
# Executed in 0.04 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? @@( o1.Col(:EMPLOYEE) )
#--> [ "Salem", "Henri", "Sonia" ]

? @@( o1.ColZ(:EMPLOYEE) ) // Same as o1.CellsAndPositionsInCol(:EMPLOYEE)
			   // and o1.CellsInColZ(:EMPLOYEE)
#--> [
#	[ "Salem", [ 2, 1 ] ],
#	[ "Henri", [ 2, 2 ] ],
#	[ "Sonia", [ 2, 3 ] ]
# ]

proff()
# Executed in 0.15 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? @@( o1.CellsInCol(:EMPLOYEE) ) // same as Col(:EMPLOYEE)
#--> [ "Salem", "Henri", "Sonia" ]

? @@( o1.CellsInColAsPositions(:EMPLOYEE) ) // same as ColAsPositions(:EMPLOYEE)
#--> [ [2, 1], [2, 2], [2, 3] ]

? @@( o1.CellsInColZ(:EMPLOYEE) )
#--> [
#	[ "Salem", [ 2, 1 ] ],
#	[ "Henri", [ 2, 2 ] ],
#	[ "Sonia", [ 2, 3 ] ]
# ]

proff()
# Executed in 0.18 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])


? @@( o1.RowZ(2) ) // Same as o1.CellsAndPositionsInRow(2)
#--> [
#	[ 20, 	   [ 1, 2 ] ],
#	[ "Hatem", [ 2, 2 ] ],
#	[ 46, 	   [ 3, 2 ] ]
#    ]

proff()
# Executed in 0.05 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.CellsInRow(2) ) + NL // same as Row(2)
#--> [ 20, "Hatem", 46 ]

? @@( o1.CellsInRowAsPositions(2) ) + NL // same as RowAsPositions(2)
#--> [ [ 1, 2 ], [ 2, 2 ], [ 3, 2 ] ]

? @@( o1.CellsInRowZ(2) )
#--> [
#	[ 20, 		[ 1, 2 ] ],
#	[ "Hatem", 	[ 2, 2 ] ],
#	[ 46, 		[ 3, 2 ] ]
#    ]

proff()
# Executed in 0.08 second(s)

/*==============

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindInCol( :FIRSTNAME, :Value = "Ali" ) ) + NL
#--> [ [ 1, 2 ], [ 1, 3 ] ]

? @@( o1.FindInCol( :FIRSTNAME, :SubValue = "a" ) ) + NL
#--> [ ]

? @@( o1.FindInColCS( :LASTNAME, :SubValue = "a", :CS = FALSE ) )
#--> [
#	[ [ 2, 1 ], [ 2 ]      ],
#	[ [ 2, 2 ], [ 1, 4, 6] ],
#	[ [ 2, 3 ], [ 1 ]      ]
# ]

proff()
# Executed in 4.48 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Alibaba", 	"Abraham" ],
	[ "Alibaba",	"AliAli"  ]
])

? o1.Cell(:FIRSTNAME, 2)
#--> Alibaba

? @@( o1.FindInCell(:FIRSTNAME, 2, "ba") )
#--> [ 4, 6 ]

? @@( o1.FindInCell(:LASTNAME, 3, "Ali") )
#--> [ 1, 4 ]

proff()
# Executed in 0.18 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Alibaba", 	"Abraham" ],
	[ "Alibaba",	"AliAli"  ]
])

? @@( o1.ColCellsAsPositions(:ANY) )
#--> Error message:
# Incorrect param value! pCol is not a valid column identifier.

? @@( o1.ColCellsAsPositions(:FIRSTNAME) )
#--> [ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ] ]

proff()

/*--------------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],

	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "AliAli",	"Ali"     ]
])

? @@( o1.FindInCells( [ [1, 1], [1, 2], [1, 3] ], :Value = "Ali" ) ) + NL
#--> [ [ 1, 2 ] ]

? @@( o1.FindInCells( [ [1, 1], [1, 2], [1, 3] ], :SubValue = "Ali" ) ) + NL
# NOTE: In place of :SubValue = ... you can say :CellPart or :SubPart = ...

#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1, 4 ] ]
# ]

? @@( o1.FindInCells( [ [1, 1], [1, 2], [1, 3] ], "Ali" ) )
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1, 4 ] ]
# ]

proff()

/*--------------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],

	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "AliAli",	"Ali"     ],
	[ "Ali",	"Ben Ali" ]
])

? @@( o1.FindInCol( :FIRSTNAME, :Value = "Ali" ) ) + NL
#--> [ [ 1, 2 ], [ 1, 4 ] ]

? @@( o1.FindInCol( :FIRSTNAME, :SubValue = "Ali" ) ) + NL
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1, 4 ] ],
#	[ [ 1, 4 ], [ 1 ] ]
# ]

? @@( o1.FindInColCS( :LASTNAME, :SubValue = "A", :CS = FALSE ) )
#-->[
#	[ [ 2, 1 ], [ 2 ] ],
#	[ [ 2, 2 ], [ 1, 4, 6 ] ],
#	[ [ 2, 3 ], [ 1 ] ],
#	[ [ 2, 4 ], [ 5 ] ]
# ]

proff()
# Executed in 0.33 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Alibaba",	"AliAli"  ]
])

? @@( o1.FindInRow(3, :CellPart = "Ali") )
#--> [
# 	[ [ 1, 3 ], [ 1 ] ],
# 	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

proff()
# Executed in 0.06 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :NAME,	:AGE ],
	[ "Ali",	24   ],
	[ "Lio",	25   ],
	[ "Dan",	42   ]
])

? o1.CellQ(:NAME, 2).Conttains("io") # NOTE: A misspelled form of Contains()
#--> TRUE

proff()
# Executed in 0.08 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :NAME,	:AGE ],
	[ "Ali",	24   ],
	[ "Lio",	25   ],
	[ "Dan",	42   ]
])


? o1.CellContainsSubValue(:NAME, 2, "io")
#--> TRUE

? o1.CellXT(:NAME, 2, :ContainsSubValue, "io")
#--> TRUE

proff()
# Executed in 0.14 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],

	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "AliAli",	"Ali"     ],
	[ "Ali",	"Ben Ali" ]
])

? o1.NumberOfOccurrenceInCol(:FIRSTNAME, "Ali")
#--> 2

? o1.NumberOfOccurrenceInCol(:FIRSTNAME, :OfValue = "Ali")
#--> 2

? o1.NumberOfOccurrenceInCol(:FIRSTNAME, :OfSubValue = "Ali")
#--> 4

? o1.NumberOfOccurrenceXT(:InCol = :FIRSTNAME, :OfSubValue = "Ali")
#--> 4

? o1.NumberOfOccurrenceXT(:InRow = 3, :OfSubValue = "Ali")
#--> 3

? o1.NumberOfOccurrenceInRow(3, "Ali")
#--> 1

? o1.NumberOfOccurrenceInCell(2, 3, :OfSubValue = "Ali")
#--> 1

? o1.NumberOfOccurrenceXT(:InCell = [ 2, 3], :OfSubValue = "Ali")
#--> 1

proff()
# Executed in 0.32 second(s)

/*=====================

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.NumberOfOccurrenceInCols([ :FIRSTNAME, :LASTNAME ], "Ali") + NL
#--> 1

? @@( o1.FindInCols([ :FIRSTNAME, :LASTNAME ], "Ali") ) + NL
#--> [ [ 1, 2 ] ]

? o1.NumberOfOccurrenceInCols([ :FIRSTNAME, :LASTNAME ], :OfSubValue = "Ali") + NL
#--> 4

? @@( o1.FindInCols([ :FIRSTNAME, :LASTNAME ], :SubValue = "Ali") )
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

proff()
# Executed in 0.35 second(s)

/*----------------------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? @@( o1.FindInCols( [ :FIRSTNAME, :LASTNAME ], "Ali" ) ) + NL
#--> [ [ 1, 2 ] ]

# Same as:
? @@( o1.FindInCols( [ :FIRSTNAME, :LASTNAME ], :Value = "Ali" ) ) + NL # Added the :Value named param
#--> [ [ 1, 2 ] ]

? @@( o1.FindInCols( [ :FIRSTNAME, :LASTNAME ], :SubValue = "Ali" ) )
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]


proff()
# Executed in 0.28

/*--------------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? @@( o1.FindInCols( [ :FIRSTNAME, :LASTNAME ], "Ali" ) ) + NL
#--> [ [ 1, 2 ] ]
# Executed in 0.11 second(s)

# If you need a better performance then use column numbers instead
# of column names:

? @@( o1.FindInCols( [ 1, 2 ], "Ali" ) )
#--> [ [ 1, 2 ] ]
# Executed in 0.06 second(s)

proff()
# Executed in 0.14 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.ColContains(2, "Ali")
#--> FALSE

? o1.ColContains(2, :SubValue = "Ali")
#--> TRUE

? o1.ColsContain([ :FIRSTNAME, :JOB ], "Ali")
#--> TRUE

? o1.ColsContain([ :LASTNAME, :JOB ], "Ali")
#--> FALSE

? o1.ColsContain([ :LASTNAME, :JOB ], :SubValue = "Ali")
#--> TRUE

? @@( o1.FindInCols([ :LASTNAME, :JOB ], :SubValue = "Ali") )
# [ [ [ 2, 3 ], [ 1, 4 ] ] ]

proff()
# Executed in 0.40 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? @@( o1.RowAsPositions(2) ) + NL
#--> [ [ 1, 2 ], [ 2, 2 ], [ 3, 2 ] ]

? @@( o1.RowsAsPositions([ 1 , 3 ]) ) + NL
#--> [
#	[ 1, 1 ], [ 2, 1 ], [ 3, 1 ],
#	[ 1, 3 ], [ 2, 3 ], [ 3, 3 ]
# ]

? o1.NumberOfOccurrenceInRows([ 2, 3 ], "Ali") + NL
#--> 1

? @@( o1.FindInRows([ 2, 3 ], "Ali") ) + NL
#--> [ [ 1, 2 ] ]

? o1.NumberOfOccurrenceInRows([ 2, 3 ], :OfSubValue = "Ali") + NL
#--> 4

? @@( o1.FindInRows([ 2, 3 ], :SubValue = "Ali") ) + NL
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

proff()
# Executed in 0.26 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.RowContains(3, "Ali")
#--> FALSE

? o1.RowContains(3, :SubValue = "Ali")
#--> TRUE

? o1.RowsContain([ 1, 3 ], "Ali")
#--> FALSE

? o1.RowsContain([ 1, 2 ], "Ali")
#--> TRUE

? o1.RowsContain([ 1, 3 ], :SubValue = "Ali") + NL
#--> TRUE

? @@( o1.FindInRows([ 1, 3 ], :SubValue = "Ali") )
#--> [
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

proff()
# Executed in 0.20 second(s)

/*===================

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.FindCol(:JOB)
#--> 3

? @@( o1.FindCell("Abraham") )
#--> [ [ 2, 2 ] ]

? @@( o1.FindCell("Programmer") )
#--> [ [ 3, 1 ] ]

? @@( o1.FindCell("Ali") )
#--> [ [ 1, 2 ] ]

proff()
# Executed in 0.20 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	#-------------------------------------#
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.Find("Red") ) + NL
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

? @@( o1.FindInCol(:PALETTE1, "Blue") ) + NL
#--> [ [ 1, 2 ], [ 1, 3 ] ]

? @@( o1.FindInRow(2, "Red") ) 
#--> [ [ 2, 2 ], [ 2, 3 ] ]

proff()
# Executed in 0.20 second(s)

/*===============

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	#-------------------------------------#
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.Section([1,2], [3,2]) ) + NL
#--> [ "Blue", "Red", "Red" ]

? @@( o1.SectionZ([1,2], [3,2]) ) + NL
#--> [
#	[ [ 1, 2 ], "Blue" ],
#	[ [ 2, 2 ], "Red"  ],
#	[ [ 3, 2 ], "Red"  ]
#    ]

? @@( o1.SectionAsPositions([1,2], [3,2]) )
#--> [ [ 1, 2 ], [ 2, 2 ], [ 3, 2 ] ]

proff()
# Executed in 0.12 second(s)

/*==========

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.FindInSection([1,2], [3,2], "Red") )
#--> [ [ 2, 2 ], [ 3, 2 ] ]

proff()
# Executed in 0.05 second(s)

/*----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.SectionZ(:From = :FirstCell, :To = [3,2]) )
#--> [
#	[ [ 1, 1 ], "Red" 	],
#	[ [ 2, 1 ], "White" 	],
#	[ [ 3, 1 ], "Yellow" 	],
#	[ [ 1, 2 ], "Blue" 	],
#	[ [ 2, 2 ], "Red" 	],
#	[ [ 3, 2 ], "Red" 	]
#    ]

proff()
# Executed in 0.09 second(s)

/*-----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.FindInSectionCS([1, 1], [3, 2], "red", :CS = TRUE) )
#--> []

? @@( o1.FindInSectionCS([1, 1], [3, 2], "Red", :CS = TRUE) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

? @@( o1.FindInSectionCS([1, 1], [3, 2], "red", :CS = FALSE) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

proff()
# Executed in 0.14 second(s)

/*-----------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? @@( o1.FindInSection( :From = [1, 2], :To = [2, 3], :CellPart = "Ali" ) )
#--> [ [ [ 1, 2 ], [ 1 ] ], [ [ 1, 3 ], [ 1 ] ], [ [ 2, 3 ], [ 1, 4 ] ] ]

proff()
# Executed in 0.08 second(s)

/*-----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	#-------------------------------------#
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.FindNthInSectionCS(2, :From = :FirstCell, :To = [3, 3], "red", :CS = FALSE) )
#--> [2, 2]

? @@( o1.FindFirstInSection(:From = :FirstCell, :To = [3, 3], "Red") )
#--> [1, 1]

? @@( o1.FindLastInSection(:From = :FirstCell, :To = [3, 3], "Red") )
#--> [3, 2]

proff()
# Executed in 0.22 second(s)

/*-----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.Count("Red")
#--> 3

? o1.Count(:SubValue = "e")
#--> 11

? o1.CountInCol(:PALETTE1, "Blue")
#--> 2

? o1.CountInRow(2, "Red")
#--> 2

? o1.CountInCells( [ [1, 1], [2,1], [2, 2] ], "Red" )
#--> 2

? o1.CountInCells( [ [1, 1], [2,1], [2, 2] ], :SubValue = "e" )
#--> 3

proff()
# Executed in 0.33 second(s)

/*-----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.SectionContains( [1, 2], [3, 2], "Red" )
#--> TRUE

? o1.SectionContains( [1, 2], [3, 2], :SubValue = "ed" )
#--> TRUE

proff()
# Executed in 0.08 second(s)

/*==============

pron()

o1 = new stzString("Red")
? o1.AdjustToRightWith("PALETTE1")
#    "PALETTE1"
#--> "     Red"

proff()

/*----------------

pron()

o1 = new stzListOfStrings([ ":PALETTE1", "Red", "Blue", "Blue", "White" ])
? o1.AlignedToRight()
#-->
# :PALETTE1
#       Red
#      Blue
#      Blue
#     White

proff()
# Executed in 0.09 second(s)

/*===============

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ShowXT([
	:Separator = " | ",
	:Alignment = :Left,
	:UnderLineHeader,
	:ShowRowNumbers
])
#-->
#  # | :PALETTE1 | :PALETTE2 | :PALETTE3
# ---+-----------+-----------+----------
#  1 | Red       | White     | Yellow   
#  2 | Blue      | Red       | Red      
#  3 | Blue      | Green     | Magenta  
#  4 | White     | Gray      | Black    
#  5 | Red       | White     | Yellow   
#  6 | Blue      | Red       | Red      
#  7 | Blue      | Green     | Magenta  
#  8 | White     | Gray      | Black    
#  9 | Red       | White     | Yellow   
# 10 | Blue      | Red       | Red      
# 11 | Blue      | Green     | Magenta  
# 12 | White     | Gray      | Black    

proff()
# Executed in 0.74 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ShowXT([ :ShowRowNumbers ])
#-->
#	#   PALETTE1   PALETTE2   PALETTE3
#	1        Red      White     Yellow
#	2       Blue        Red        Red
#	3       Blue      Green    Magenta
#	4      White       Gray      Black

? @@( o1.SectionZ(:From = [1,2], :To = [3,2]) ) + NL
#--> [
#	[ [ 1, 2 ], "Blue" 	],
#	[ [ 2, 2 ], "Red" 	],
#	[ [ 3, 2 ], "Red" 	]
#    ]

? @@( o1.FindInSection(:From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [
#	[ [ 1, 2 ], [ 4 ] ],
#	[ [ 2, 2 ], [ 2 ] ],
#	[ [ 3, 2 ], [ 2 ] ]
#    ]

? @@( o1.FindNthInSection(:First, :From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [ [ 1, 2 ], 4 ]

? @@( o1.FindNthInSection(:Last, :From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [ [ 3, 2 ], 2 ]

? @@( o1.FindLastInSection(:From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [ [ 3, 2 ], 2 ]

proff()
# Executed in 0.51 second(s)

/*=============

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.FindCells( "Red" ) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

# Same as:
? @@( o1.FindAllOccurrences( :Of = "Red") )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

proff()
# Executed in 0.18 second(s)

/*-----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.NumberOfOccurrence( :Of = "Red" )
#--> 3

? @@( o1.FindNthCell(1, "Red") )
#--> [ 1, 1 ]

? @@( o1.FindNthCell(2, "Red") )
#--> [ 2, 2 ]

? @@( o1.FindLastCell( "Red" ) )
#--> [ 3, 2 ]

proff()
# Executed in 0.38 second(s)

/*-----------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.NumberOfOccurrence( :OfSubValue = "Ali" )
#--> 4

? @@( o1.FindAllOccurrences( :OfSubValue = "Ali" ) ) + NL
#--> [ [ [ 1, 2 ], [ 1 ] ], [ [ 1, 3 ], [ 1 ] ], [ [ 2, 3 ], [ 1, 4 ] ] ]

? @@( o1.FindNthOccurrence( 2, :OfSubValue = "Ali" ) ) + NL
#--> [ [ 1, 3 ], 1 ]

? @@( o1.FindNth(2, :SubValue = "Ali") )
#--> [ [ 1, 3 ], 1 ]

? @@( o1.FindFirst(:SubValue = "Ali") )
#--> [ [ 1, 2 ], 1 ]

? @@( o1.FindLast(:SubValue = "Ali" ) )
#--> [ [ 2, 3 ], 4 ]

proff()
# Executed in 0.39 second(s)

/*-----------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.NumberOfOccurrence( :OfSubValue = "Ali" )
#--> 4

? o1.NumberOfOccurrenceInCol( :LASTNAME, :OfSubValue = "Ali" )
#--> 2

? @@( o1.FindInCol( :LASTNAME, :SubValue = "Ali" ) )
#--> [ [ [ 2, 3 ], [ 1, 4 ] ] ]

? @@( o1.FindNthInCol( 2, :LASTNAME, :SubValue = "Ali" ) )
#--> [ [ 2, 3 ], 4 ]


proff()
# Executed in 0.38 second(s)

/*-----------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.NumberOfOccurrence( :OfSubValue = "Ali" )
#--> 4

? o1.NumberOfOccurrenceInRow( 3, :OfSubValue = "Ali" )
#--> 3

? @@( o1.FindInRow( 3, :SubValue = "Ali" ) ) + NL
#-->[ [ [ 1, 3 ], [ 1 ] ], [ [ 2, 3 ], [ 1, 4 ] ] ]

? @@( o1.FindNthInRow( 2, 3, :SubValue = "Ali" ) )
#--> [ [ 2, 3 ], 1 ]

proff()
# Executed in 0.16 second(s)

/*-----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.Col(2) )
#--> [ "White", "Red", "Green", "Gray" ]

? @@( o1.HasColName(:PALETTE2) )
#--> TRUE

? o1.HasColNames([ :PALETTE1, :PALETTE3 ]) #--> TRUE
#--> TRUE

? @@( o1.ColNames() )
#--> [ "palette1", "palette2", "palette3" ]

proff()
# Executed in 0.08 second(s)

/*==========

pron()

o1 = new stzTable([
	:ID 	  = [ 10,	20,		30	],
	:EMPLOYEE = [ "Ali",	"Sam",		"Ben"	],
	:SALARY	  = [ 14500,	17630,		20345	]
])

o1.AddRow([ 40, "Peter", 12500 ])
? o1.Row(4)
#--> [ 40, "Peter", 12500 ]

proff()
# Executed in 0.04 second(s)

/*==========

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

o1.AddCol( :PALETTE4 = [ "Magenta", "Blue", "White", "Red" ])

? @@( o1.ColNames() )
#--> [ "palette1", "palette2", "palette3", "palette4" ]

? o1.HasColName(:PALETTE4)
#--> TRUE

? @@( o1.Col(:PALETTE4) )
#--> [ "Magenta", "Blue", "White", "Red" ]

o1.RemoveCol(:PALETTE4)

? @@( o1.ColNames() )
#--> [ "palette1", "palette2", "palette3" ]

proff()
# Executed in 0.13 second(s)

/*----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ColToColName(2) 	 #--> "palette2"
? o1.ColToColName(:PALETTE2) #--> "palette2"

? o1.TheseColsToColNames([3, :PALETTE1, 2])
#--> [ "palette3", "palette1", "palette2" ]

proff()
# Executed in 0.11 second(s)

/*----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ColToColNumber(2)
#--> 2

? o1.ColToColNumber(:PALETTE2)
#--> 2

? o1.TheseColsToColsNumbers([:PALETTE3, :PALETTE1, 2])
#--> [ 3, 1, 2 ]

proff()
# Executed in 0.10 second(s)

/*----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ShowXT([ :ShowRowNumbers ])
#-->
#	#   PALETTE1   PALETTE2   PALETTE3
#	1        Red      White     Yellow
#	2       Blue        Red        Red
#	3       Blue      Green    Magenta
#	4      White       Gray      Black


o1.EraseCol(2)
? o1.ShowXT([ :ShowRowNumbers ])
#-->
#	#   PALETTE1   PALETTE2   PALETTE3
#	1        Red                Yellow
#	2       Blue                   Red
#	3       Blue               Magenta
#	4      White                 Black


o1.EraseCols([3 ,1])
? o1.ShowXT([ :ShowRowNumbers ])
#	#   PALETTE1   PALETTE2   PALETTE3
#	1                                 
#	2                                 
#	3                                 
#	4                                 

proff()
# Executed in 0.78 second(s)

/*----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ShowXT([ :ShowRowNumbers ])
#-->
#	#   PALETTE1   PALETTE2   PALETTE3
#	1        Red      White     Yellow
#	2       Blue        Red        Red
#	3       Blue      Green    Magenta
#	4      White       Gray      Black

o1.EraseRow(2)
? o1.ShowXT([ :ShowRowNumbers ])
#-->
#	#   PALETTE1   PALETTE2   PALETTE3
#	1        Red      White     Yellow
#	2                                 
#	3       Blue      Green    Magenta
#	4      White       Gray      Black

o1.EraseRows([3, 1])
? o1.ShowXT([ :ShowRowNumbers ])
#-->
#	#   PALETTE1   PALETTE2   PALETTE3
#	1                                 
#	2                                 
#	3                                 
#	4      White       Gray      Black

proff()
# Executed in 0.78 second(s)

/*----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.Show()
#-->
#	#   PALETTE1   PALETTE2   PALETTE3
#	1        Red      White     Yellow
#	2                                 
#	3       Blue      Green    Magenta
#	4      White       Gray      Black

o1.RemoveCol(1)
o1.RemoveCol(1)
o1.RemoveCol(1)

? o1.ShowXT([ :ShowRowNumbers ])
#-->
#	#   PALETTE1   PALETTE2   PALETTE3
#	1                                 
#	2                                 
#	3                                 
#	4      White       Gray      Black

proff()
# Executed in 0.40 second(s)

/*----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.Show()
#-->
#   PALETTE1   PALETTE2   PALETTE3
#	1        Red      White     Yellow
#	2       Blue        Red        Red
#	3       Blue      Green    Magenta
#	4      White       Gray      Black

o1.RemoveCols([1, 2])
? o1.Show()
#-->
#	#   PALETTE3
#	1     Yellow
#	2        Red
#	3    Magenta
#	4      Black

o1.RemoveCol(:PALETTE3)
? o1.ShowXT([ :ShowRowNumbers ])
#-->
#	#   COL1
#	1       
#	2       
#	3       
#	4 
      
proff()
#--> Executed in 0.50 second(s)

/*==========

pron()

o1 = new stzTable([
	:ID 	  = [ 10,	20,		30	],
	:EMPLOYEE = [ "Ali",	"Sam",		"Ben"	],
	:SALARY	  = [ 14500,	17630,		20345	]
])

o1.AddRow([ 40, "Peter", 12500 ])
? o1.Row(4) #--> [ 40, "Peter", 12500 ]

proff()
# Executed in 0.04 second(s)

/*==========

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

o1.AddCol( :TEMPO = [ NULL, NULL, NULL, NULL ])
#--> Error message:
# Incorrect number of cells! paColNameAndData must contain extactly 3 cells.

/*----------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

o1.AddCol( :TEMPO = [ NULL, NULL, NULL ])

? o1.LastColName()
#--> "tempo"

? @@(o1.LastCol())
#--> [ "", "", "" ]

proff()
# Executed in 0.07 second(s)

/*----------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

o1.AddCols([
	:ONES = [ 1, 1, 1 ],
	:TWOS = [ 2, 2, 2 ]
])

? @@( o1.Cols() )
#--> [
#	[ 10, 20, 30 ],
#	[ "Ali", "Dan", "Ben" ],
#	[ 35000, 28900, 25982 ],
#	[ 1, 1, 1 ], [ 2, 2, 2 ]
# ]

? @@( o1.TheseColumns([ :ONES, :TWOS ]) )
#--> [ [ 1, 1, 1 ], [ 2, 2, 2 ] ]

? @@( o1.TheseColumnsXT([ :ONES, :TWOS ]) )
#--> [ [ "ones", [ 1, 1, 1 ] ], [ "twos", [ 2, 2, 2 ] ] ]

proff()
# Executed in 0.30 second(s)

/*==========

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

? o1.ShowXT([])
#-->
#	#   ID   EMPLOYEE   SALARY
#	1   10        Ali    35000
#	2   20        Dan    28900
#	3   30        Ben    25982

? @@( o1.SubTable([ :EMPLOYEE, :SALARY ]) ) + NL
#--> [
#	[ "employee", [ "Ali", "Dan", "Ben" ] ],
#	[ "salary"  , [ 35000, 28900, 25982 ] ]
#    ]

o1.SubTableQR([ :EMPLOYEE, :SALARY ], :stzTable).Show()
#-->
#	#   EMPLOYEE   SALARY
#	1        Ali    35000
#	2        Dan    28900
#	3        Ben    25982

proff()
# Executed in 0.57 second(s)

/*-----------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

? @@( o1.CellsAsPositions() )
#--> [
#	[ 1, 1 ], [ 2, 1 ], [ 3, 1 ],
#	[ 1, 2 ], [ 2, 2 ], [ 3, 2 ],
#	[ 1, 3 ], [ 2, 3 ], [ 3, 3 ]
# ]

proff()
# Executed in 0.04 second(s)

/*================

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dania",	28900	],
	[ 30,	"Ben",		25982	]
])

? o1.Contains( :Cell = "Ali" ) # same as ? o1.ContainsCell("Ali")
#--> TRUE

? o1.Contains( :SubValue = "a" ) # same as ? o1.ContainsSubValue("a")
#--> TRUE

? @@( o1.FindCell("Ali") )
#--> [ [ 2, 1 ] ]
#--> One occurrence of "Ali" in the cell [2, 1]

? @@( o1.FindSubValueCS("a", :CaseSensitive = FALSE) )
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 2 ], [ 2, 5 ] ]
#    ]
#--> 3 occurrences of "a" (or "A"):
#	- 1 occurrence in cell [2, 1] ("Ali"), in position 1, and
#	- 2 occurrences in cell [2, 2] ("Dania"), in positions 2 and 5

proff()
# Executed in 1.02 second(s)

/*-------------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Hania",	25982	]
])

? @@( o1.FindNth(1, :Cell = "Ali") ) # Same as ? @@( o1.FindFirst( :Cell = "Ali" ) )
#--> [2, 1]

? @@( o1.FindNthCS(3, :SubValue = "A", :CS = FALSE) )
#--> [ [ 2, 3 ], 2 ]
#--> 3rd occurrence of "A" (or "a") found in the cell [2, 3] ("Hania") in position 2

? @@( o1.FindFirstCS(:SubValue = "A", :CS = FALSE) )
#--> [ [ 2, 1 ], 1 ]

? @@( o1.FindLastCS(:SubValue = "A", :CS = FALSE) )
#--> [ [ 2, 3 ], 5 ]

proff()
# Executed in 0.65 second(s)

/*-------------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

? o1.Count( :Value = "Ali" )
#--> 1
	# Same as o1.Count( :Cell = "Ali" )
	# or: ? o1.NumberOfOccurrence( :OfCell = "Ali" )
	# or: ? o1.CountOfCell( "Ali" )
	# or: ? o1.CountOfValue("Ali")

proff()
# Executed in 0.49 second(s)

/*-------------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Hania",	25982	]
])

? o1.Count( :SubValue = "a" )
#--> 1

? o1.CountCS( :SubValue = "A", :CaseSensitive = FALSE )
#--> 4

proff()

/*-------------

pron()

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

? o1.Cell(:EMPLOYEE, 3)
#--> "Han"

? @@( o1.CellZ(:EMPLOYEE, 3) ) + NL
#--> [ "Han", [2, 3] ]

? o1.Count( :Cells = "Ali" ) #--> 2
	# Same as NumberOfOccurrence( :OfCell = "Ali" )
	# Or you can say: ? o1.CountOfCell( "Ali" )

? @@( o1.FindCell("Ali") ) + NL
#--> [ [ 2, 1 ], [2, 4] ]
#--> One occurrence of "Ali" in the cell [2, 1]

? @@( o1.FindSubValue("a") ) + NL
#--> [
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 3 ], [ 2 ] ]
#    ]
#--> There are 3 occurrences of of "a" in the table:
#	--> 2 occurrences in cell [2, 2] ("Dania"), in the 2nd and 5th chars.
#	--> 1 occurrence in cell [2, 3] ("Han"), in position 2.

? @@( o1.FindSubValueCS("a", :CaseSensitive = FALSE) ) + NL
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 3 ], [ 2 ] ],
#	[ [ 2, 4 ], [ 1 ] ]
#    ]

? o1.CountCS( :SubValue = "a", :CS= FALSE )
#--> 5
	#--> five occurrences of "A" (or "a"):
	# 	- one occurrence in the cell [2, 1] ("Ali") at the 1st char
	# 	- two occurrences in the cell [2, 2] ("Dania") at the 2nd and 5th chars
	# 	- one occurrence in the cell [2, 3] ("Han") at the 2nd char
	# 	- one occurrence in the cell [2, 4] ("Ali") at the 1st char

proff()
# Executed in 1.54 second(s)

/*=============

pron()

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

? @@( o1.TheseCells([ [1,2], [2,2], [2,3] ]) )
#--> [ 20, "Dania", "Ben" ]

? @@( o1.TheseCellsZ([ [1,2], [2,2], [2,3] ]) )
#--> [ [ 20, [ 1, 2 ] ], [ "Dania", [ 2, 2 ] ], [ "Han", [ 2, 3 ] ] ]

proff()
# Executed in 0.07 second(s)

/*===============

// Finding all occurrence of a value, or subvalue, in a given list of cells
pron()

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

? @@( o1.FindInCells( [ [1,2], [2,2], [2,3] ], :Value = "Dania" ) ) + NL
#--> [ [2, 2] ]

? @@( o1.FindInCells( [ [1,2], [2,2], [2,3] ], :SubValue = "a" ) )
#--> [
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 3 ], [ 2 ]    ]
#    ]
#--> There are 3 occurrences of "a" in the specified cells:
#	- 2 occurrences in the cell [2, 2] ("Dania"), in positions 2 and 5, and
#	- 1 occurrence in cell [2, 3] ("Han"), in position 2.

proff()
# Executed in 0.17 second(s)

/*-------------
// Finding nth occurrence of a value, or subvalue, in a given list of cells

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dania",	28900	],
	[ 30,	"Han",		25982	]
])

? @@( o1.FindNthInCells( 1, [ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [2, 2]

? @@( o1.FindNthInCells( 1, [ [1,2], [2,2], [2,3] ], :Value = "blabla" ) )
#--> [ ]

? @@( o1.FindNthInCells( 2, [ [1,2], [2,2], [2,3] ], :SubValue = "a" ) ) 
#--> [ [ 2, 2 ], 5 ]
// Sames as: ? o1.FindNthSubValueInCells( 2, [ [1,2], [2,2], [2,3] ], "a" ) )

? @@( o1.FindFirstInCells([ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [ 2, 2 ]

? @@( o1.FindLastInCells([ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [ 2, 2 ]

proff()
# Executed in 0.52 second(s)

/*-------------

pron()

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

# Let's take this list of cells
aMyCells = [ [2,1], [2,3], [2,4] ]

# And get them along with their positions:

? @@( o1.TheseCellsZ( aMyCells ) ) + NL
#--> [ [ "Ali", [ 2, 1 ] ], [ "Han", [ 2, 3 ] ], [ "Ali", [ 2, 4 ] ] ]

# How many cell made of the value "Ali" does exist in those cells?

? o1.CountInCells( aMyCells, :Value = "Ali" )
#--> 2

# Where do they exist exactly?

? @@( o1.FindInCells( aMyCells, :Value = "Ali" ) )
#--> [ [ 2, 1 ], [ 2, 4 ] ]

# How many subvalue "A" does exist in the same list of cells?

? o1.CountInCells( aMyCells, :SubValue = "A" )
#--> 2

# How many subvalue "A" whatever case it has?

? o1.CountInCellsCS( aMyCells, :SubValue = "A", :CS = FALSE )
#--> 3

# And where do they exist exactly?

? @@( o1.FindInCellsCS( aMyCells, :SubValue = "A", :CS = FALSE ) )
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 2 ] ],
#	[ [ 2, 4 ], [ 1 ] ]
#    ]

proff()
# Executed in 0.21 second(s)

/*-------------

pron()

// Checking if a given value, or subvalue, exists in a given list of cells

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

? o1.CellsContain( [ [2,1], [2,3], [2,4] ], :Cell = "Ali" ) 
#--> TRUE

? o1.CellsContain( [ [2,1], [2,3], [2,4] ], :SubValue = "a" ) // Same as ? o1.CellsContainSubValue("a")
#--> TRUE

? o1.CountInCells( [ [2,1], [2,3], [2,4] ], :Cell = "Ali" )
#--> 2

? o1.CountInCellsCS( [ [2,1], [2,3], [2,4] ], :SubValue = "a", :CS = FALSE )
#--> 3

proff()
# Executed in 0.13 second(s)

#================= ROW: FindInRow(), CountInRow(), ContainsInRow()

pron()

// Finding all occurrences of a value, or subvalue, in a row

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindInRow(2, :Value = "Ali") ) + NL
#--> [ [ 1, 2 ] ]

? @@( o1.FindInRow(3, :Value = "Ali" ) ) + NL
#--> [ [1, 3], [2, 3] ]

? @@( o1.FindInRow( 2, :SubValue = "a" ) ) + NL
#--> [ 
#	[ [2, 2], [4, 6] ]
#    ]

? @@( o1.FindInRowCS( 2, :SubValue = "a", :CS = FALSE ) )
#--> [
#	[ [1, 2], [1]    ],
#	[ [2, 2], [1, 4, 6] ],
#   ]

proff()
# Executed in 0.11 second(s)

/*------------

// Finding nth occurrence of a value in a row
pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindNthInRow(:Nth = 1, :InRow = 2, :OfValue = "Abraham") )
#--> [2, 2]

# Or you can use this short form:
? @@( o1.FindNthInRow(1, 2, "Abraham") )
#--> [2, 2]

? @@( o1.FindNthInRow(:N = 2, :Row = 3, :Value = "Ali") )
#--> [2, 3]

? @@( o1.FindFirstInRow(3, :Value = "Ali") )
#--> [1, 3]

? @@( o1.FindLastInRow(3, :Value = "Ali") )
#--> [2, 3]

proff()
# Executed in 0.14 second(s)

#-----------

pron()

// Finding nth occurrence of a subvalue in a row

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindInRow(2, :SubValue = "a") ) + NL
#--> [
#	[ [ 2, 2 ], [ 4, 6 ] ]
#    ]

? @@( o1.FindNthInRow(:Nth = 2, :InRow = 2, :OfSubValue = "a") )
#--> [ [ 2, 2 ], 6 ]

proff()
# Executed in 0.08 second(s)

#-----------

pron()

// Counting the number of occurrences of a value, or subvalue, in a row

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? o1.CountInRow(3, :Value = "Ali")
#--> 2

? o1.CountInRow(2, :SubValue = "A")
#--> 2

proff()
# Executed in 0.07 second(s)

#-----------

pron()

// Checking if a given value, or subvalue, exists in a row

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])


? o1.ContainsInRow(2, "Abraham")
#--> TRUE

? o1.RowContains(2, "Abraham")
#--> TRUE

? o1.ContainsInRow(2, :SubValue = "AL")
#--> FALSE

? o1.ContainsInRowCS(2, :SubValue = "AL", :CS = FALSE)
#--> TRUE

proff()
# Executed in 0.10 second(s)

#================= COL: FindInCol(), CountInCol(), ContainsInCol()

pron()

// Finding all occurrences of a value, or subvalue, in a column

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindInCol(:FIRSTNAME, "Ali") ) + NL
#--> [ [ 1, 2 ], [ 1, 3 ] ]

? @@( o1.FindInCol(2, :Value = "Ali") ) + NL
#--> [ [ 2, 3 ] ]

? @@( o1.FindInCol(:LASTNAME, :SubValue = "a" ) ) + NL
#--> [
#	[ [ 2, 1 ], [ 2 ] ],
#	[ [ 2, 2 ], [ 4, 6 ] ]
#    ]

? @@( o1.FindInColCS(:LASTNAME, :SubValue = "a", :CS = FALSE ) )
#--> [
#	[ [ 2, 1 ], [ 2 ] 	],
#	[ [ 2, 2 ], [ 1, 4, 6 ] ],
#	[ [ 2, 3 ], [ 1 ] 	]
#   ]

proff()
# Executed in 0.35 second(s)

/*------------

pron()
// Finding nth occurrence of a value in a Col

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindNthInCol(:Occurrence = 1, :InCol = :LASTNAME, :OfValue = "Abraham") )
#--> [2, 2]

# Or you can use this short form:
? @@( o1.FindNthInCol(1, 2, "Abraham") )
#--> [2, 2]

? @@( o1.FindNthInCol(2, :FIRSTNAME, "Ali") )
#--> [1, 3]

? @@( o1.FindFirstInCol(:FIRSTNAME, "Ali") )
#--> [1, 2]

? @@( o1.FindLastInCol(:FIRSTNAME, "Ali") )
#--> [1, 3]

proff()
# Executed in 0.43 second(s)

/*-----------

pron()

// Finding nth occurrence of a subvalue in a Col

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindInCol(:LASTNAME, :SubValue = "a") ) + NL
#--> [
#	[ [ 2, 1 ], [ 2 ] 	],
#	[ [ 2, 2 ], [ 4, 6 ] 	]
#    ]

? @@( o1.FindNthInCol(:Nth = 2, :InCol = 2, :OfSubValue = "a") ) + NL
#--> [ [ 2, 2 ], 4 ]

? @@( o1.FindFirstInCol(:LASTNAME, :SubValue = "a") )
#--> [ [ 2, 1 ], 2 ]

proff()
# Executed in 0.28 second(s)

/*-----------

pron()
// Counting the number of occurrences of a value, or subvalue, in a Col

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? o1.CountInCol(:FIRSTNAME, :Value = "Ali")
#--> 2

? o1.CountInCol(:LASTNAME, :SubValue = "A")
#--> 2

proff()
# Executed in 0.14 second(s)

/*-----------

pron()

// Checking if a given value, or subvalue, exists in a Col

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? o1.ContainsInCol(2, "Abraham")
#--> TRUE

? o1.ColContains(2, "Abraham")
#--> TRUE

? o1.ContainsInCol(2, :SubValue = "AL")
#--> FALSE

? o1.ContainsInColCS(2, :SubValue = "AL", :CS = FALSE)
#--> TRUE

proff()
# Executed in 0.11 second(s)

/*=================

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? o1.Cell(:FIRSTNAME, 3)
#--> "Ali"

o1.ReplaceCell(:FIRSTNAME, 3, :With = "Saber")

? @@( o1.Cell(:FIRSTNAME, 3) )
#--> "Saber"

proff()
# Executed in 0.16 second(s)

/*-----------------

pron()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE ],
	[ "___",	"Arabic"  ],
	[ "France",	"___"     ],
	[ "USA",	"___"     ]
])

? o1.Cell(2, 3)
#--> "___"

o1.ReplaceCell(2, 3, :With = "English")

? o1.Cell(2, 3)
#--> "English"

proff()
# Executed in 0.05 second(s)

/*-----------------

pron()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE ],
	[ "___",	"Arabic"  ],
	[ "France",	"___"     ],
	[ "USA",	"___"     ]
])

o1.ReplaceCellsByMany(
	[     [1, 1],   [2, 2],    [2, 3] ],
	[  "Tunisia", "French", "English" ]
)

o1.Show()
#-->
# #    NATION   LANGUAGE
# 1   Tunisia     Arabic
# 2    France     French
# 3       USA    English

proff()
# Executed in 0.19 second(s)

/*-----------------
*/
pron()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE ],
	#-------------------------#
	[ "France",	"___"     ],
	[ "USA",	"___"     ],
	[ "Niger",	"___"	  ],
	[ "Egypt",	"___"	  ],
	[ "Kuwait",	"___"     ]
])

o1.ReplaceCellsByManyXT(
	[ [2, 1], [2, 2], [2, 3], [2, 4], [2, 5] ],
	[   "01",   "02",   "03" ]
)

o1.Show()
#-->
# #    NATION   LANGUAGE
# 1   Tunisia     Arabic
# 2    France     French
# 3       USA        ___

proff()

/*-----------------

pron()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE ],
	[ "___",	"Arabic"  ],
	[ "France",	"___"     ],
	[ "USA",	"___"     ]
])

o1.ReplaceAll("___", :By = ".....")

o1.Show()
#-->
#	:NATION  :LANGUAGE
#	  .....     Arabic
#	 France      .....
#	   USA      .....

proff()
# Executed in 0.21 second(s)

/*-----------------

pron()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE ],
	[ "Tunisia",	"Arabic"  ],
	[ "France",	"French"  ],
	[ "USA",	"english" ]
])

o1.ReplaceCellsInCol(:LANGUAGE, :By = ".....")

o1.Show()
#-->
# :NATION  :LANGUAGE
# Tunisia      .....
# France      .....
#    USA      .....

proff()
# Executed in 0.33 second(s)

