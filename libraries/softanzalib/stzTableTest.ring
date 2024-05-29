load "stzlib.ring"

/*------- #ring

pron()

? @@( ring_trim("    ") )
#--> ""
	
proff()
# Executed in 0.02 second(s)

/*=============== #narration 5 ways to create a stzTable

pron()

# A table can be created in 6 different ways:

# WAY 1 : Creating an empty table with just a column and a row with just an empty cell
o1 = new stzTable([])

? @@( o1.Content() ) + NL
#--> [ [ "COL1", [ "" ] ] ]

o1.Show()
#--> COL1
#    ----
#     ""  

proff()
# Executed in 0.07 second(s)

/*--------------

pron()

# WAY 2 : Creating an empty table with 3 columns and 3 rows

o1 = new stzTable([3, 2])
o1.Show()
#-->
#   COL1   COL2   COL3
#     ""     ''     "'    
#     ""     ''     "'  

proff()
# Executed in 0.08 second(s)

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
#   ID   EMPLOYEE   SALARY
#   --- ---------- -------
#   10        Ali    35000
#   20      Dania    28900
#   30        Han    25982
#   40        Ali    12870

proff()
# Executed in 0.08 second(s) in Ring 1.20
# Executed in 0.61 second(s) in Ring 1.17

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
#   COL1    COL2    COL3
#   ----- ------- ------
#     10     Ali   35000
#     20   Dania   28900
#     30     Han   25982
#     40     Ali   12870

proff()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.61 second(s) in Ring 1.17

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
#-->  NAME          JOB   SALARY
#    ------ ------------ -------
#      Ali   Programmer    35000
#    Dania      Manager    50000
#      Han       Doctor    62500

proff()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.47 second(s) in Ring 1.17

/*---------

# WAY 6: Creating a table from an external text file (EXPERIMENTAL)

#NOTE
# This example uses two files that exist in the default
# director: "myTable.csv" and "myHybridTable.txt"
# check them before you test the code.

pron()

# You can crate a table from an external data file.
# The file can be in CSV format or any other text file.
# Tha data inside the file must be separated by lines,
# and the lines must be separated by semicolons.

o1 = new stzTable(:FromFile = "mytable.csv")

? o1.Show()

#--> NATION   LANGUAGE   CAPITAL   CONTINENT
#   -------- ---------- --------- ----------
#   Tunisia     Arabic     Tunis      Africa
#    France     French     Paris      Europe
#     Egypt    English     Cairo      Africa

o2 = new stzTable(:FromFile = "myHybridTable.txt")

o2.Show()

#--> NAME  AGE                         HOBBIES
#   ----- ----- -------------------------------
#   Hela    24             [ "Sport", "Music" ]
#    Jon    32   [ "Games", "Travel", "Sport" ]
#    Ali    22        [ "Painting", "Dansing" ]
#  Foued    43            [ "Music", "Travel" ]

#~> #NOTE that numbers and lists are evaluated and retutned as native types
#~> #NOTE lists in the text file must be take the form ['str1','str2','str3']

proff()
# Executed in 0.49 second(s)

/*----------

pron()

#NOTE
# This example uses two files that exist in the default
# director: "mytable_emptyline.txt" and "mytable_line1_number"
# check them before you test the code.

# If the file begins with an empty line, then Softanza adds
# the names of columns automaticallys as :COL1, :COL2, etc

o1 = new stzTable(:FromFile = "mytable_emptyline.txt")

? o1.Show()

#-->    COL1      COL2      COL3     COL4
#    -------- --------- --------- -------
#    Tunisia    Arabic     Tunis   Africa
#     France    French     Paris   Europe
#      Egypt   English     Cairo   Africa
#    Belgium    French   Brussel   Europe
#      Yemen    Arabic     Sanaa     Asia

# Also, the first line is not empty but contains cells
# that are not strings (numbers or lists), then Softanza
# does the same (adds columns names)

o1 = new stzTable(:FromFile = "mytable_line1_number.txt")

? o1.Show()

#-->    COL1       COL2      COL3      COL4
#    -------- ---------- --------- --------
#     NATION   LANGUAGE       125   COUNTRY
#    Tunisia     Arabic     Tunis    Africa
#     France     French     Paris    Europe
#      Egypt    English     Cairo    Africa
#    Belgium     French   Brussel    Europe
#      Yemen     Arabic     Sanaa      Asia

proff()
# Executed in 0.46 second(s)

/*=================

pron()

StzTableQ([
	[ :M, :FUNCTION 	, :OBJECT ],

	[ ' ', 'Q'		, 'stzList' ],
	[ ' ', 'AreBothQ' 	, 'stzListOfStrings' ],
	[ '•', 'HavingQ'	, 'stzListOfStrings' ],
	[ ' ', 'AllTheirQ'	, 'stzListOfStrings' ]

# When we specify just the intersection char, Softanza
# add the values by default for the separator ("|")
# and the underline char ("-")

]).ShowXT([ :IntersectionChar = "+" ])

#-->
#  M |  FUNCTION |           OBJECT
#  --+-----------+-----------------
#    |         Q |          stzList
#    |  AreBothQ | stzListOfStrings
#  • |   HavingQ | stzListOfStrings
#    | AllTheirQ | stzListOfStrings

proff()
# Executed in 0.10 second(s)

/*--------------------

pron()

o1 = new stzTable([
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])
		
? o1.ColNames()
#--> [ "col1", "col2", "col3" ]

? o1.Row(2)
#--> [ 20, "Hatem", 46 ]

proff()
# Executed in 0.02 second(s)

/*--------------------

pron()

o1 = new stzTable([
	:COL1 = [ "I", 1 ],
	:COL2 = [ AHeart(), 2 ],
	:COL3 = [ "Ring", 3 ],
	:COL4 = [ "Language", 4 ]
])

? o1.ShowXT([
	:Separator 	  = "   ",
	:Alignment 	  = :Right,
		
	:UnderLineHeader  = TRUE,
	:UnderLineChar 	  = "-",
	:IntersectionChar = " ",
		
	:ShowRowNumbers   = FALSE
])

#--> COL1   COL2   COL3       COL4
#    ----- ------ ------ ---------
#       I      ♥   Ring   Language
#       1      2      3          4

proff()
# Executed in 0.10 second(s)

/*-------------------- @narration

pron()

o1 = new stzTable([
	:COL1 = [ "I", 1 ],
	:COL2 = [ AHeart(), 2 ],
	:COL3 = [ "Ring", 3 ],
	:COL4 = [ "Language", 4 ]
])

# By default, the colnames are underline using "-",
# with a separator, cells are adjusted to the right,
# and the row numbers are not showen

? o1.Show()

#--> COL1   COL2   COL3       COL4
#    ----- ------ ------ ---------
#       I      ♥   Ring   Language
#       1      2      3          4

# If you need a more sophisticated presentation,
# than you can use the extended form the the
# function, without speciying any options.

# In this case, Softanza uses in the backgound,
# the default values the options like this:
# - the colanmes are underlined using "-"
# - the cells are adjusted to the right
# - the colnames and the cells are separated by "|"
# - and the rows numbers are showen

? o1.ShowXT([])

#--> # | COL1 | COL2 | COL3 |     COL4
#    --+------+------+------+---------
#    1 |    I |    ♥ | Ring | Language
#    2 |    1 |    2 |    3 |        4

# If you deactivate the underlining of the header,
# and you do not specify any other option, all
# those options are deactivated

? o1.ShowXT([ :UnderlineHeader = FALSE ])
#--> COL1   COL2   COL3       COL4
#       I      ♥   Ring   Language
#       1      2      3          4

# And when you activate the underlining of
# the header, and don't set any other option,
# only the header is underlined using the
# default char "-"

? o1.ShowXT([ :UnderLineHeader = TRUE ])
#--> COL1   COL2   COL3       COL4
#    -----------------------------
#       I      ♥   Ring   Language
#       1      2      3          4

# But when you specify an intersection char,
# without specifying any other option, all
# the default options are used

o1.ShowXT([ :IntersectionChar = "+" ])
#--> COL1 | COL2 | COL3 |     COL4
#    -----+------+------+---------
#       I |    ♥ | Ring | Language
#       1 |    2 |    3 |        4

proff()
# Executed in 0.24 second(s)

/*--------------------

pron()

o1 = new stzTable([
	[ "I", 		1, 	11, 	111 ],
	[ AHeart(), 	2, 	22, 	222 ],
	[ "Ring", 	3, 	33, 	333 ],
	[ "Language", 	4, 	44, 	444 ]
])

o1.ShowXT([ :UnderLineHeader = TRUE, :InterSectionChar = "+" ])

#-->     COL1 | COL2 | COL3 | COL4
#    ---------+------+------+-----
#           I |    1 |   11 |  111
#           ♥ |    2 |   22 |  222
#        Ring |    3 |   33 |  333
#    Language |    4 |   44 |  444

proff()
# Executed in 0.12 second(s)

/*--------------------

pron()

o1 = new stzTable([
	:col1 = [ "I", 1 ],
	:col2 = [ AHeart(), 2 ],
	:Col3 = [ "Ring", 3 ],
	:Col4 = [ "Language", 4 ]
])

? o1.Show()
#-->
#	COL1   COL2   COL3       COL4
#	----- ------ ------ ---------
#	  I      ♥   Ring   Language
#	  1      2      3          4

proff()
# Executed in 0.12 second(s)

/*--------------------

pron()

o1 = new stzTable([ [ 10, "ten" ], [ 20, "twenty" ] ])
o1.Show()
#-->
#	COL1     COL2
#	----- -------
#	  10      ten
#	  20   twenty

proff()
# Executed in 0.07 second(s)

/*--------------------

pron()

o1 = new stzTable([
	[ "I", 1 ],
	[ AHeart(), 2 ],
	[ "Ring", 3 ],
	[ "Language", 4 ]
])

o1.ShowXT([ :UnderlineHeader = FALSE ])
#-->
# I   ♥   RING   LANGUAGE
# 1   2      3          4

proff()
# Executed in 0.08 second(s)

/*--------------------

pron()

o1 = new stzTable([
	[ "I", 1 ],
	[ AHeart(), 2 ],
	[ "Ring", 3 ],
	[ "Language", 4 ]
])

? o1.Rows()
#--> [ 1, 2, 3, 4 ]

proff()
# Executed in 0.02 second(s)

/*------

pron()

o1 = new stzList([ "A", "B", "C", "D", "E" ])
? @@( o1.FindMany([ "A", "B", "A", "B", "B" ]) )
#--> [ 1, 2 ]

o1.ReplaceManyByManyXT([ "A", "B", "A", "D", "E" ], :With = [ "1", "2"])
? @@( o1.Content() )
#--> [ "1", "2", "C", "1", "2" ]

proff()
# Executed in 0.02 second(s)

/*=============

pron()

o1 = new stzTable([
	[ :NAME, :AGE, :SCORE ],
	[ "sam", 24,   10     ],
	[ "dan", 36,   20     ],
	[ "tom", 43,   30     ]
])

o1.Show()
#-->
#	NAME   AGE   SCORE
#	----- ----- ------
#	 sam    24      10
#	 dan    36      20
#	 tom    43      30

? ""

? @@( o1.FindColsExcept([ :NAME, :SCORE ]) )
#--> [ 2 ]

? ""

o1.RemoveCol(2)
o1.Show()
#--> :NAME   :SCORE
#    ------ -------
#    sam       10
#    dan       20
#    tom       30

? ""

o1.RemoveCols([ 1, 2 ])
o1.Show() + NL

#--> COL1
#    ----
#      ""

proff()
# Executed in 0.13 second(s)

/*-------------

pron()

o1 = new stzTable([
	[ :NAME, :AGE, :SCORE ],
	[ "sam", 24,   10     ],
	[ "dan", 36,   20     ],
	[ "tom", 43,   30     ]
])

o1.RemoveCols([1, 2])
o1.Show()

#--> SCORE
#    -----
#       10
#       20
#       30

proff()
# Executed in 0.07 second(s)

/*-------------

pron()

o1 = new stzTable([
	[ :NAME, :AGE, :SCORE ],
	[ "sam", 24,   10     ],
	[ "dan", 36,   20     ],
	[ "tom", 43,   30     ]
])

o1.RemoveAll()
o1.Show()

#--> COL1
#    ----
#      ""

proff()
# Executed in 0.08 second(s)

/*=============

pron()

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3,	:COL4 ],
	#-------------------------------------#
	[ 10,	    "*",      100,	"*"   ],
	[ 20,	    "*",      200,	"*"   ],
	[ 30,	    "*",      300,	"*"   ]
])

? o1.FindColByName(:COL3) + NL
#--> 3

? o1.FindColsByName([ :COL2, :COL4 ])
#--> [ 2, 4 ]

? o1.FindColsByName([ :FirstCol, :LastCol ])
#--> [ 1, 4 ]

? o1.FindColsByName([ :FirstCol, :LastCol, :LastCol ])
#--> [ 1, 4 ]

#--

? o1.FindColByValue([ 100, 200, 300 ])
#--> [ 3 ]

? o1.FindColByValue([ "*", "*", "*" ])
#--> [ 2, 4 ]

? o1.FindColsByValue([
	[ 100, 200, 300 ],
	[ "*", "*", "*" ]
])
#--> [ 2, 3, 4 ]

? @@( o1.FindColsByValueExcept([
	[ "*", "*", "*" ],
	[ 10, 20, 30 ]
]) )
#--> [ 3 ]

proff()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.17 second(s) in Ring 1.17

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
# Executed in 0.03 second(s)

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
#-->   COL1   COL2   COL3
#    ------ ------ ------
#       10     100   1000
#       20     200   2000
#       30     300   3000

proff()
# Executed in 0.09 second(s)

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

? o1.FindRow([ "*", "*", "*" ])
#--> [ 3 ]

o1.RemoveRow([ "*", "*", "*" ])

o1.Show()
#-->   COL1   COL2   COL3
#    ------ ------ ------
#       10     100   1000
#       20     200   2000
#       30     300   3000

proff()
# Executed in 0.12 second(s)

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

#-->   COL1    COL2   COL3
#    ------ ------- ------
#       10     100    1000
#       20     200    2000
#       30     300    3000

proff()
# Executed in 0.08 second(s)

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

? o1.FindRowsExceptAt([ 1, 2, 4 ])
#--> [ 3, 5, 6 ]

? o1.FindRowsExcept([
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ 30,	    300,      3000  ]
])
#--> [ 3, 5, 6 ]

#--

o1.RemoveAllRowsExcept([
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ 30,	    300,      3000  ]
]) # Or RemoveRowsOtherThan()

o1.Show()
#-->  COL1    COL2   COL3
#    ------ ------- ------
#       10     100    1000
#       20     200    2000
#       30     300    3000

proff()
# # Executed in 0.10 second(s)

/*============ A Softanza #narration showing one of the uses of the XT()

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

#-->  COL1    COL2   COL3
#    ------ ------- ------
#       10     100    1000
#       20     200    2000
#        *       *       *
#       30     300    3000

# That's fine! But you may want a more elaborated formatting!
# Use the XT() extension:

? o1.ShowXT([]) + NL

#--> # | COL1 | COL2 | COL3
#    --+------+------+-----
#    1 |   10 |  100 | 1000
#    2 |   20 |  200 | 2000
#    3 |    * |    * |    *
#    4 |   30 |  300 | 3000

# You can even even set the options at your will...

? o1.ShowXT([
	:Separator 	  = " | ",
	:Alignment 	  = :Center,

	:UnderLineHeader  = TRUE,
	:UnderLineChar 	  = "-",
	:IntersectionChar = "+",

	:ShowRowNumbers   = TRUE
])

#--> # | COL1 | COL2 | COL3
#    --+------+------+-----
#    1 |  10  | 100  | 1000
#    2 |  20  | 200  | 2000
#    3 |  *   |  *   |  *  
#    4 |  30  | 300  | 3000

proff()
# Executed in 0.20 seconds(s) in Ring 1.20
# Executed in 1.09 second(s) in Ring 1.17

/*--------------

pron()

o1 = new stzTable([3, 4])
? o1.Show()
#-->  COL1   COL2   COL3
#     ----- ------ -----
#       ""     ""    '"
#       ""     ""    '"
#       ""     ""    '"
#       ""     ""    '"

proff()
# Executed in 0.12 second(s)

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
#--> 	COL2   COL3
#	----- -----
#	  ""     ''   

proff()
# Executed in 0.08 second(s)

/*--------------

StartProfiler()

o1 = new stzList([ "ONE", "two", "THREE", 1, 2 ])
? o1.ContainsCS("TwO", :CS=FALSE)
#--> TRUE

StopProfiler()
#--> Executed in 0.02 second(s)

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

	? o1.Show()
	#--> ID   EMPLOYEE   SALARY
	#    --- ---------- -------
	#    10        Ali    35000
	#    20      Dania    28900
	#    30        Han    25982
	#    40        Ali    12870

	? o1.NthColName(:LastCol) + NL
	#--> :SALARY

	? @@( o1.CellsInColsAsPositions([ :EMPLOYEE, :SALARY ]) ) + NL
	#--> [
	# 	[ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 2, 4 ],
	# 	[ 3, 1 ], [ 3, 2 ], [ 3, 3 ], [ 3, 4 ]
	# ]

	? o1.CellsToHashList()["[ 3, 4 ]"] + NL
	#--> 12870

	? @@( o1.SectionAsPositions([2,2], [3, 4]) )
	#--> [ [ 2, 2 ], [ 3, 2 ], [ 2, 3 ], [ 3, 3 ], [ 2, 4 ], [ 3, 4 ] ]

StopProfiler()
# Executed in 0.11 second(s) in Ring 1.20
# Executed in 1.56 second(s) in Ring 1.17

/*--------------

pron()

o1 = new stzTable([
	[ "NAME", "AGE", "RANGE" ],
	[ "Sam",    42,      2   ],
	[ "Dan",    24,    "_"   ],
	[ "Alex",   34,      3   ]
])

? o1.Cell(3, 2) + NL
#--> "_"

o1.ReplaceCell(3, 2, 1)

o1.Show()
#--> NAME   AGE   RANGE
#    ----- ----- ------
#     Sam    42       2
#     Dan    24       1
#    Alex    34       3

proff()
# Executed in 0.09 second(s)

/*--------------

StartProfiler()

o1 = new stzTable([3, 3])

o1.Fill( :With = "." )
? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       .      .      .
#       .      .      .

o1.ReplaceRow(2, :With = [ "+", "+" ])
? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       +      +      .
#       .      .      .

o1.ReplaceRow(2, :With = [ "+", "+", "+" ])
? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       +      +      +
#       .      .      .

o1.ReplaceRow(2, :With = [ "+", "+", "+", "+", "+" ])
o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       +      +      +
#       .      .      .

StopProfiler()
# Executed in 0.22 second(s) in Ring 1.20
# Executed in 1.89 second(s) in Ring 1.17

/*--------------

pron()

o1 = new stzTable([3, 3])

o1.Fill( :With = "." )

? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       .      .      .
#       .      .      .

o1.ReplaceAllRows(:With = [ "+", "+", "+" ])

o1.Show()
#--> COL1   COL2   COL3
#   ----- ------ -----
#      +      +      +
#      +      +      +
#      +      +      +

proff()
# Executed in 0.13 second(s) in Ring 1.20
# Executed in 0.98 second(s) in Ring 1.17

/*--------------

pron()

o1 = new stzTable([2, 3])

o1.Fill( :With = "." )

? o1.Show()
#--> COL1   COL2
#    ----- -----
#      .      .
#      .      .
#      .      .

o1.ReplaceCol(:COL2, :With = [ "+", "+" ])
? o1.Show()
#--> COL1   COL2
#    ----- -----
#       .      +
#       .      +
#       .      .

o1.ReplaceCol(:COL2, :With = [ "+", "+", "+" ]) + NL
? o1.Show()
#--> COL1   COL2
#    ----- -----
#       .      +
#       .      +
#       .      +

o1.ReplaceCol(:COL2, :With = [ "+", "+", "+", "+", "+" ])
? o1.Show()
#--> COL1   COL2
#    ----- -----
#       .      +
#       .      +
#       .      +

proff()
# Executed in 0.18 second(s) in Ring 1.20
# Executed in 1.31 second(s) in Ring 1.17

/*--------------

pron()

o1 = new stzTable([3, 3])

o1.Fill( :With = "." )

? o1.Show() + NL
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       .      .      .
#       .      .      .

o1.ReplaceAllCols(:With = [ "A", "B", "C" ])
o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       A      A      A
#       B      B      B
#       C      C      C

proff()
# Executed in 0.14 second(s) in Ring 1.20
# Executed in 1.02 second(s) in Ring 1.1è

/*----------------

pron()

o1 = new stzTable([3, 3])

o1.Fill( :With = "." )
? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       .      .      .
#       .      .      .

o1.Fill( :WithRow = [ "A", "B" ] )
o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       A      B      .
#       A      B      .
#       A      B      .

proff()
# Executed in 0.14 second(s) in Ring 1.20
# Executed in 1.09 second(s) in Ring 1.17

/*----------------

pron()

? Q([
	[ "COL1", [ "A", "B", "C" ] ],
	[ "COL2", [ "a", "b", "c" ] ],
	[ "COL3", [ "1", "2", "3" ] ]
]).IsHashList()
#--> TRUE

proff()
# Executed in 0.02 second(s)

/*----------------

pron()

o1 = new stzTable([
	[ "COL1", [ "A", "B", "C" ] ],
	[ "COL2", [ "a", "b", "c" ] ],
	[ "COL3", [ "1", "2", "3" ] ]
])

o1.Show()
#-->
#   COL1   COL2   COL3
#   ----- ------ -----
#      A      a      1
#      B      b      2
#      C      c      3

proff()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.54 second(s) in Ring 1.17

/*----------------

pron()

? @@NL( StzTableQ([ 3, 3 ]).Filled(:With = "A") )
#--> [
#	[ "COL1", [ "A", "A", "A" ] ],
#	[ "COL2", [ "A", "A", "A" ] ],
#	[ "COL3", [ "A", "A", "A" ] ]
# ]

proff()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.09 second(s) in Ring 1.17

/*----------------

pron()

o1 = StzTableQ([ 3, 3 ]) { Fill(:With = "A") }
o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       A      A      A
#       A      A      A
#       A      A      A

proff()
# Executed in 0.10 second(s) in Ring 1.20
# Executed in 0.48 second(s) in Ring 1.17

/*----------------

pron()

o1 = new stzTable([3, 3])

o1.Fill( :With = "." )

? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       .      .      .
#       .      .      .

o1.Fill( :WithCol = [ "A", "B" ] )

? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       A      A      A
#       B      B      B
#       .      .      .

o1.Fill( :WithCol = [ "A", "B", "C" ] )

o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       A      A      A
#       B      B      B
#       C      C      C

proff()
# Executed in 0.29 second(s) in Ring 1.20
# Executed in 1.58 second(s) in Ring 1.19

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
# Executed in 0.04 second(s) in Ring 1.19
# Executed in 0.15 second(s) in Ring 1.17

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

? o1.ColName(:NAME) + NL
#--> :NAME

o1.ReplaceColName(:NAME, :EMPLOYEE)

o1.Show()
#-->
#    ID    EMPLOYEE  AGE
#    --- ---------- ----
#    10     Karim     52
#    20     Hatem     46
#    30   Abraham     48

proff()
# Executed in 0.10 second(s) in Ring 1.20
# Executed in 0.48 second(s) in Ring 1.17

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

? o1.ColNumber(:NONE)
#--> Error message:
# 	Incorrect param value! p must be a number or string.
# 	Allowed strings are :First, :FirstCol, :Last,
# 	:LastCol and any valid column name.

? o1.ColNumber(22)
#--> Error message:
# 	Incorrect value! n must be a number between 1 and 3.

proff()
# Executed in 0.02 second(s)

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
#   ID      NAME   AGE
#   --- --------- ----
#   30   Abraham    48
#   20     Hatem    46
#   10     Karim    52

proff()
# Executed in 0.14 second(s)

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

? o1.Show()
#-->
#   ID      NAME   AGE
#   --- --------- ----
#   10     Karim    52
#   30   Abraham    48
#   20     Hatem    46

o1.SwapColumns( :BetweenPosition = 2, :And = 3 )

o1.Show()
#-->
#  ID   AGE      NAME
#  --- ----- --------
#  10    52     Karim
#  30    48   Abraham
#  20    46     Hatem

proff()
# Executed in 0.30 second(s)
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

o1.Show()
#-->
#  AGE      NAME   ID
#  ---- --------- ---
#   52     Karim   10
#   46     Hatem   20
#   48   Abraham   30

proff()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.48 second(s) in Ring 1.17

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
# 	Can't add the column! The name your provided already exists.

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
#   ID   AGE      NAME
#   --- ----- --------
#   10    52     Karim
#   20    46     Hatem
#   30    48   Abraham

proff()
# Executed in 0.13 second(s) in Ring 1.20
# Executed in 0.71 second(s) in Ring 1.17

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
# Executed in 0.02 second(s)

/*=============== #narration #flexibility

pron()

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

proff()
# Executed in 0.15 second(s)

/*==============

StartProfiler()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.SortDown()

? o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    30   Abraham    48
#    20     Hatem    46
#    10     Karim    52

o1.Sort()

? o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    10     Karim    52
#    20     Hatem    46
#    30   Abraham    48

o1.SortOn(:AGE)

? o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    20     Hatem    46
#    30   Abraham    48
#    10     Karim    52

o1.SortOnDown(:AGE)

o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    10     Karim    52
#    30   Abraham    48
#    20     Hatem    46

StopProfiler()
# Executed in 0.41 second(s)

/*--------

pron()

o1 = new stzListOfLists([
	[ 10, "Abdelkarim", 52 ],
	[ 20, "Hatem", 46 ],
	[ 30, "Abraham", 48 ]
])

o1.SortOnBy(2, "len(@item)")

? @@NL( o1.Content() )
#--> [
#	[ 20, "Hatem", 46 ],
#	[ 30, "Abraham", 48 ],
#	[ 10, "Abdelkarim", 52 ]
# ]

proff()
# Executed in 0.04 second(s)

/*---------

StartProfiler()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Abdelkarim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.SortOnBy(:NAME, 'len(@cell)')

? o1.Show()
#--> ID         NAME   AGE
#    --- ------------ ----
#    20        Hatem    46
#    30      Abraham    48
#    10   Abdelkarim    52

o1.SortOnByDown(:NAME, 'len(@cell)')
? o1.Show()
#--> ID         NAME   AGE
#    --- ------------ ----
#    10   Abdelkarim    52
#    30      Abraham    48
#    20        Hatem    46

o1.SortOn(:AGE)
? o1.Show()
#--> ID         NAME   AGE
#    --- ------------ ----
#    20        Hatem    46
#    30      Abraham    48
#    10   Abdelkarim    52

o1.SortOnDown(:AGE)
o1.Show()
#--> ID         NAME   AGE
#    --- ------------ ----
#    10   Abdelkarim    52
#    30      Abraham    48
#    20        Hatem    46

StopProfiler()
# Executed in 0.40 second(s)

/*-------------

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

o1.SortOn(:COL2)

? o1.Show() + NL
#--> COL1   COL2
#   ------ -----
#       a     R1
#       b     R1
#      ab     R2
#     abc     R3
#    abcd     R4
#   abcde     R5

o1.SortOnDown(:COL2)

o1.Show()
#--> COL1   COL2
#   ------ -----
#   abcde     R5
#    abcd     R4
#     abc     R3
#      ab     R2
#       b     R1
#       a     R1

proff()
# Executed in 0.29 second(s)

/*===========

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
#--> [ [ 1, 3 ], [ 2, 3 ], [ 3, 3 ] ]

? @@( o1.RowsAsPositions([2, 3]) ) + NL
#--> [ [ 1, 2 ], [ 2, 2 ], [ 3, 2 ], [ 1, 3 ], [ 2, 3 ], [ 3, 3 ] ]

proff()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.13 second(s) in Ring 1.17

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
#--> [
#	"a", "abcde", "abc", "ab", "b", "abcd",
#	"R1", "R5", "R3", "R2", "R1", "R4"
# ]

? @@( o1.CellsInRows([1, 3, 5]) )
#--> [ "a", "R1", "abc", "R3", "b", "R1" ]

proff()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.21 second(s) in Ring 1.17

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
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.33 second(s) in Ring 1.17

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.SectionAsPositions([2, 2], [3, 3]) ) + NL # Or FindSections()
#--> [ [ 2, 2 ], [ 2, 3 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ] ]

? @@(o1.Section([2, 2], [3, 3])) + NL
#--> [ "Hatem", "Karim", 52, 46, 48 ]

? @@NL(o1.SectionZ([2, 2], [3, 3])) + NL # or SectionAndPosiition()
#--> [
#	[ [ 2, 2 ], "Hatem" ],
#	[ [ 2, 3 ], "Karim" ],
#	[ [ 3, 1 ], 52 ],
#	[ [ 3, 2 ], 46 ],
#	[ [ 3, 3 ], 48 ]
# ]

? @@( o1.Section(:FirstCell, :LastCell) )
#--> [ 10, 20, 30, "Imed", "Hatem", "Karim", 52, 46, 48 ]

proff()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.15 second(s) in Ring 1.17

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.Cells() ) + NL
#--> [ 10, 20, 30, "Imed", "Hatem", "Karim", 52, 46, 48 ]

? @@NL( o1.CellsAndPositions() ) + NL # Same as CellsZ()
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

? @@NL( o1.PositionsAndCells() ) + NL
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

? @@( o1.CellsToHashList() ) + NL # (used internally by Softanza)
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

? @@( o1.SectionToHashList([2, 2], [3, 3]) ) # (idem)
#--> [
#	[ "[ 2, 2 ]", "Hatem" ],
#	[ "[ 3, 2 ]", 46 ],
#	[ "[ 2, 3 ]", "Karim" ],
#	[ "[ 3, 3 ]", 48 ]
# ]

proff()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.36 second(s) in Ring 1.17

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

? o1.HasCol(:NAME) + NL
#--> TRUE

? o1.ColNames()
#--> [ "id", "name", "age" ]

? o1.ColName(2)
#--> "name"

proff()
# Executed in 0.02 second(s)

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
#   Syntax error in (employee)! This column name is inexistant.

? o1.Cell(5, 7 )
#--> Error message:
#    Incorrect value! n must correspond to a valid number of column. 

proff()
# Executed in 0.02 second(s)

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
# Executed in 0.02 second(s)

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
# Executed in 0.02 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME 	],
	[ 10,	"Imed" 	],
	[ 20,	"Hatem" ],
	[ 30,	"Karim" ]
])

o1.AddCol(:AGE = [ 55, 35, 28 ])
? @@NL( o1.Content() )
#--> [
#	[ "id", 	[ 10, 20, 30 ] 			],
#	[ "name", 	[ "Imed", "Hatem", "Karim" ] 	],
#	[ "age", 	[ 55, 35, 28 ] 			]
# ]

proff()
# Executed in 0.02 second(s)

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
# Executed in 0.02 second(s)

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
# Executed in 0.02 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.FirstColXT() ) + NL
#--> [ "id", 10, 20, 30 ]

? @@( o1.LastColXT() )
#-->[ "age", 52, 46, 48 ]

proff()
# Executed in 0.02 second(s)

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

? @@NL( o1.Rows() )
#-->
# [
#	[ 10, "Imed",	52 ],
#	[ 20, "Hatem", 	46 ],
#	[ 30, "Karim",	48 ]
# ]

proff()
# Executed in 0.02 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

o1.AddCol( :JOB = [ "Pilot", "Designer", "Author" ] )
? o1.Show()

#--> ID    NAME   AGE        JOB
#    --- ------- ----- ---------
#    10    Imed    52      Pilot
#    20   Hatem    46   Designer
#    30   Karim    48     Author

o1.RemoveCol(:JOB)
o1.Show()
#--> ID    NAME   AGE
#    --- ------- ----
#    10    Imed    52
#    20   Hatem    46
#    30   Karim    48

proff()
# Executed in 0.13 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

o1.AddCol( :JOB = [ "Pilot", "Designer", "Author", "thing", "bye" ] )
? o1.Shwo() # NOTE this is misspelled!

#--> ID    NAME   AGE        JOB
#    --- ------- ----- ---------
#    10    Imed    52      Pilot
#    20   Hatem    46   Designer
#    30   Karim    48     Author

o1.AddCol( :NATION = [ "Tunisia", "Egypt" ] )
o1.Show()
#--> ID    NAME   AGE        JOB    NATION
#    --- ------- ----- ---------- --------
#    10    Imed    52      Pilot   Tunisia
#    20   Hatem    46   Designer     Egypt
#    30   Karim    48     Author        ""

proff()
# Executed in 0.18 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

o1.RemoveCols([ :ID, :AGE ])

? @@( o1.Content() )
#--> [ [ "name", [ "Imed", "Hatem", "Karim" ] ] ]

proff()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.16 second(s) in Ring 1.17

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.ColNames() ) + NL
#--> [ "id", "name", "age" ]

? @@NL( o1.Cols() ) # Or ColsData()
#--> [
#	[ 10, 20, 30 ],
#	[ "Imed", "Hatem", "Karim" ],
#	[ 52, 46, 48 ]
# ]
 
proff()
# Executed in 0.02 second(s)

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
# Executed in 0.02 second(s)

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])


? @@NL( o1.TheseColumnsXT([ :ID, :NAME ]) ) // Same as o1.TheseColumnsXT([1, 2])
#--> [
#	[ "id", 	[ 10, 20, 30 ] 			],
#	[ "name", 	[ "Imed", "Hatem", "Karim" ] 	]
# ]

proff()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.14 second(s) in Ring 1.17

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@NL( o1.ColZ(2) )
#--> [
#	[ "Imed", [ 2, 1 ] ],
#	[ "Hatem", [ 2, 2 ] ],
#	[ "Karim", [ 2, 3 ] ]
# ]

proff()
# Executed in 0.02 second(s)

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
# Executed in 0.03 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@NL( o1.AllCols() ) + NL
#--> [
#	[ 10, 20, 30 ],
#	[ "Imed", "Hatem", "Karim" ],
#	[ 52, 46, 48 ]
# ]

? @@NL( o1.TheseCols([ 1, 3 ]) ) + NL
#--> [
#	[ 10, 20, 30 ],
#	[ 52, 46, 48 ]
# ]

? @@NL( o1.ColsXT() ) + NL
#--> [
#	[ "id",   [ 10, 20, 30 ] ],
#	[ "name", [ "Imed", "Hatem", "Karim" ] ],
#	[ "age",  [ 52, 46, 48 ] ]
# ]


? @@NL( o1.TheseColsXT([ 1, 3 ]) ) + NL
#--> [
#	[ "id", [ 10, 20, 30 ] ],
#	[ "age", [ 52, 46, 48 ] ]
# ]

? @@( o1.CellsInCols([ :name, :age ]) )
#--> [ "Imed", "Hatem", "Karim", 52, 46, 48 ]

proff()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.31 second(s) in Ring 1.17

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
# Executed in 0.03 second(s)

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
# Executed in 0.02 second(s)

/*==============

pron()

? Q(["", "", ""]).AllItemsAreNull()
#--> TRUE

proff()
# Executed in 0.02 second(s)

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

o1.Show()
#-->
#  ID    EMPLOYEE  SALARY
#  --- ---------- -------
#  NULL  NULL	     NULL
#  NULL  NULL	     NULL
#  NULL  NULL	     NULL

proff()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.57 second(s) in Ring 1.17

/*-------------- #ring #bug?

pron()

aList = [ "Aaa", "Bbb", "Ccc" ]
? @@( aList["emm"] )
#--> ""

aList = [ :name = "Maiga", :job = "programmer" ]
? @@( aList[2]["emm"] )
#--> #--> ""

proff()
# Executed in 0.02 second(s)

/*-------------- #ring

pron()

str = "ring"
str[1] = "R"
? str
#--> Ring

str[3] = "nnn"
#--> Ring error message:
# Error (R7) : Can't assign to a string letter more than one character

proff()
# Executed in 0.02 second(s)

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
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.09 second(s) in Ring 1.17

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
#--> Error message:
#  Syntax error in (firscol)! Allowed values are
#  :First or :Last (or :FirstCol or :LastCol).

proff()
# Executed in 0.02 second(s)

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
# Executed in 0.02 second(s)

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
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.06 second(s) in Ring 1.17

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
# Executed in 0.02 second(s)

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
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.20 second(s) in Ring 1.17

/*-------------- #todo write a #narration

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

? @@( o1.FindInCol(:EMPLOYEE, "---") ) + NL
#--> [ ]

? @@( o1.FindInCol(:EMPLOYEE, "So") ) + NL
#--> [ [ 2, 3 ] ]

? @@( o1.FindInColCS(:EMPLOYEE, "So", :CS = FALSE) ) + NL
#--> [ [ 2, 3 ], [ 2, 6 ] ]

? @@NL( o1.FindInCol(:EMPLOYEE, :SubValue = "So") ) + NL
#--> [
#	[ [ 2, 2 ], [ 1 ] 	],
#	[ [ 2, 3 ], [ 1 ] 	],
#	[ [ 2, 4 ], [ 4, 7 ] 	]
# ]

? @@NL( o1.FindInColCS(:EMPLOYEE, :SubValue = "So", :CS = FALSE) )
#--> [
# 	[ [ 2, 2 ], [ 1 ] 	],
#	[ [ 2, 3 ], [ 1 ] 	],
#	[ [ 2, 4 ], [ 4, 7 ] 	],
#	[ [ 2, 5 ], [ 4 ] 	],
#	[ [ 2, 6 ], [ 1 ] 	]
# ]

proff()
# Executed in 0.10 second(s) in Ring 1.20
# Executed in 0.55 second(s) in Ring 1.17

/*===================

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? @@( o1.ColSection(:EMPLOYEE, :FromCellAt = 2, :To = :LastRow) ) + NL
#--> [ "Henri", "Sonia" ]

? @@( o1.FindCellsInColSection(:EMPLOYEE, 2, :LastRow) ) + NL # Or ColSectionAsPositions()
#--> [ [ 2, 2 ], [ 2, 3 ] ]

? @@NL( o1.CellsInColSectionZ(:EMPLOYEE, 2, :LastRow) )
#--> [
#	[ "Henri", [ 2, 2 ] ],
#	[ "Sonia", [ 2, 3 ] ]
# ]

proff()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.12 second(s) in Ring 1.17

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? @@( o1.RowSection(2, :FromCell = 2, :To = :LastCol) ) + NL
#--> [ "Henri", 10890.10 ]

? @@( o1.FindCellsInRowSection(2, 2, :LastCol) ) + NL # Or RowSectionAsPositions()
#--> [ [ 2, 2 ], [ 3, 2 ] ]

? @@NL( o1.CellsInRowSectionZ(2, 2, 3) )
#--> [
#	[ "Henri", [ 2, 2 ] ],
#	[ 10890.10, [ 3, 2 ] ]
# ]

proff()
# Executed in 0.03 second(s)

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
# Executed in 0.02 second(s)

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

? @@NL( o1.ColZ(:EMPLOYEE) ) // Same as o1.CellsAndPositionsInCol(:EMPLOYEE)
			     // and o1.CellsInColZ(:EMPLOYEE)
#--> [
#	[ "Salem", [ 2, 1 ] ],
#	[ "Henri", [ 2, 2 ] ],
#	[ "Sonia", [ 2, 3 ] ]
# ]

proff()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.15 second(s) in Ring 1.17

/*--------------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? @@( o1.CellsInCol(:EMPLOYEE) ) + NL // same as Col(:EMPLOYEE)
#--> [ "Salem", "Henri", "Sonia" ]

? @@( o1.CellsInColAsPositions(:EMPLOYEE) ) + NL // same as ColAsPositions(:EMPLOYEE)
#--> [ [2, 1], [2, 2], [2, 3] ]

? @@NL( o1.CellsInColZ(:EMPLOYEE) )
#--> [
#	[ "Salem", [ 2, 1 ] ],
#	[ "Henri", [ 2, 2 ] ],
#	[ "Sonia", [ 2, 3 ] ]
# ]

proff()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.18 second(s) in Ring 1.17

/*==============

pron()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@NL( o1.RowZ(2) ) // Same as o1.CellsAndPositionsInRow(2)
#--> [
#	[ 20, 	   [ 1, 2 ] ],
#	[ "Hatem", [ 2, 2 ] ],
#	[ 46, 	   [ 3, 2 ] ]
#    ]

proff()
# Executed in 0.02 second(s)

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

? @@NL( o1.CellsInRowZ(2) )
#--> [
#	[ 20, 		[ 1, 2 ] ],
#	[ "Hatem", 	[ 2, 2 ] ],
#	[ 46, 		[ 3, 2 ] ]
#    ]

proff()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.08 second(s) in Ring 1.17

/*==============

pron()

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

? @@NL( o1.FindInColCS( :LASTNAME, :SubValue = "a", :CS = FALSE ) )
#--> [
#	[ [ 2, 1 ], [ 2 ]      ],
#	[ [ 2, 2 ], [ 1, 4, 6] ],
#	[ [ 2, 3 ], [ 1 ]      ]
# ]

proff()
# Executed in 0.07 second(s) in Ring 1.20
# Executed in 4.48 second(s) in Ring 1.17

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
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.18 second(s) in Ring 1.17

/*--------------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],

	[ "Andy", 	"Maestro" ],
	[ "Alibaba", 	"Abraham" ],
	[ "Alibaba",	"AliAli"  ]
])

? @@( o1.ColCellsAsPositions(:FIRSTNAME) )
#--> [ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ] ]

? @@( o1.ColCellsAsPositions(:ANY) )
#--> Error message:
#    Incorrect param value! "any" is not a valid column identifier.

proff()
# Executed in 0.02 second(s)

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

? @@NL( o1.FindInCells( [ [1, 1], [1, 2], [1, 3] ], :SubValue = "Ali" ) ) + NL
#NOTE: In place of :SubValue = ... you can say :CellPart or :SubPart = ...

#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1, 4 ] ]
# ]

? @@NL( o1.FindInCells( [ [1, 1], [1, 2], [1, 3] ], "Ali" ) )
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1, 4 ] ]
# ]

proff()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.45 second(s) in Ring 1.17

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

? @@NL( o1.FindInCol( :FIRSTNAME, :SubValue = "Ali" ) ) + NL
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1, 4 ] ],
#	[ [ 1, 4 ], [ 1 ] ]
# ]

? @@NL( o1.FindInColCS( :LASTNAME, :SubValue = "A", :CS = FALSE ) )
#-->[
#	[ [ 2, 1 ], [ 2 ] ],
#	[ [ 2, 2 ], [ 1, 4, 6 ] ],
#	[ [ 2, 3 ], [ 1 ] ],
#	[ [ 2, 4 ], [ 5 ] ]
# ]

proff()
# Executed in 0.07 second(s) in Ring 1.20
# Executed in 0.12 second(s) in Ring 1.17

/*--------------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Alibaba",	"AliAli"  ]
])

? @@NL( o1.FindInRow(3, :CellPart = "Ali") )
#--> [
# 	[ [ 1, 3 ], [ 1 ] ],
# 	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

proff()
# Executed in 0.03 second(s)

/*--------------

pron()

o1 = new stzTable([
	[ :NAME,	:AGE ],
	[ "Ali",	24   ],
	[ "Lio",	25   ],
	[ "Dan",	42   ]
])

? o1.CellQ(:NAME, 2).Conttains("io") // #NOTE: A misspelled form of Contains()
#--> TRUE

proff()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.08 second(s) in Ring 1.17

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
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.16 second(s) in Ring 1.17

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
# Executed in 0.16 second(s) in Ring 1.20
# Executed in 0.32 second(s) in Ring 1.17

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

? @@NL( o1.FindInCols([ :FIRSTNAME, :LASTNAME ], :SubValue = "Ali") )
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

proff()
# Executed in 0.20 second(s) in Ring 1.20
# Executed in 0.35 second(s) in Ring 1.17

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

? @@NL( o1.FindInCols( [ :FIRSTNAME, :LASTNAME ], :SubValue = "Ali" ) )
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

proff()
# Executed in 0.06 second(s) in Ring 1.20
# Executed in 0.28 second(s) in Ring 1.17

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

? @@( o1.FindInCols( [ 1, 2 ], "Ali" ) )
#--> [ [ 1, 2 ] ]

proff()
# Executed in 0.04 second(s)

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
# Executed in 0.14 second(s) in Ring 1.20
# Executed in 0.40 second(s) in Ring 1.17

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
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.26 second(s) in Ring 1.17

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

? @@NL( o1.FindInRows([ 1, 3 ], :SubValue = "Ali") )
#--> [
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

proff()
# Executed in 0.12 second(s)

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
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.20 second(s) in Ring 1.17

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
# Executed in 0.06 second(s) in Ring 1.20
# Executed in 0.20 second(s) in Ring 1.17

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
#--> [ "Blue", "Blue", "White", "Red", "Green", "Gray", "Yellow", "Red" ]

? @@Nl( o1.SectionZ([1,2], [3,2]) ) + NL
#--> [
#	[ [ 1, 2 ], "Blue" ],
#	[ [ 1, 3 ], "Blue" ],
#	[ [ 1, 4 ], "White" ],
#	[ [ 2, 2 ], "Red" ],
#	[ [ 2, 3 ], "Green" ],
#	[ [ 2, 4 ], "Gray" ],
#	[ [ 3, 1 ], "Yellow" ],
#	[ [ 3, 2 ], "Red" ]
# ]

? @@( o1.SectionAsPositions([1,2], [3,2]) )
#--> [
#	[ 1, 2 ], [ 1, 3 ], [ 1, 4 ],
#	[ 2, 2 ], [ 2, 3 ], [ 2, 4 ],
#	[ 3, 1 ], [ 3, 2 ]
# ]

proff()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.12 second(s) in Ring 1.17

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
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@NL( o1.SectionZ(:From = :FirstCell, :To = [3,2]) )
#--> [
#	[ [ 1, 1 ], "Red" ],
#	[ [ 1, 2 ], "Blue" ],
#	[ [ 1, 3 ], "Blue" ],
#	[ [ 1, 4 ], "White" ],
#	[ [ 2, 1 ], "White" ],
#	[ [ 2, 2 ], "Red" ],
#	[ [ 2, 3 ], "Green" ],
#	[ [ 2, 4 ], "Gray" ],
#	[ [ 3, 1 ], "Yellow" ],
#	[ [ 3, 2 ], "Red" ]
# ]

proff()
# Executed in 0.02 second(s)

/*-----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.FindInSectionCS([1, 1], [3, 2], "red", TRUE) )
#--> [ ]

? @@( o1.FindInSectionCS([1, 1], [3, 2], "Red", TRUE) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

? @@( o1.FindInSectionCS([1, 1], [3, 2], "red", :CS = FALSE) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

proff()
# Executed in 0.03 second(s)

/*-----------

pron()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? @@NL( o1.FindInSection( :From = [1, 2], :To = [2, 3], :CellPart = "Ali" ) )
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

proff()
# Executed in 0.03 second(s)

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
# Executed in 0.03 second(s) in Ring 1.17
# Executed in 0.22 second(s) in Ring 1.20

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
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.24 second(s) in Ring 1.17

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
# Executed in 0.04 second(s)

/*==============

pron()

o1 = new stzListOfStrings([ "Red", "PALETTE" ])
? o1.AdjustedToRight()
#--> [
#	"    Red",
#	"PALETTE"
# ]

proff()
# Executed in 0.08 second(s)

/*----------------

pron()

o1 = new stzListOfStrings([ ":PALETTE1", "Red", "Blue", "Blue", "White" ])
? o1.AlignedToRight()
#--> [
# 	":PALETTE1",
# 	"      Red",
# 	"     Blue",
# 	"     Blue",
# 	"    White"
# ]

proff()
# Executed in 0.06 second(s)

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
	:IntersectionChar = "+",
	:Alignment = :Left,
	:UnderLineHeader,
	:ShowRowNumbers
])
#-->
#  # | PALETTE1 | PALETTE2 | PALETTE3
# ---+----------+----------+----------
#  1 | Red      | White    | Yellow   
#  2 | Blue     | Red      | Red      
#  3 | Blue     | Green    | Magenta  
#  4 | White    | Gray     | Black    
#  5 | Red      | White    | Yellow   
#  6 | Blue     | Red      | Red      
#  7 | Blue     | Green    | Magenta  
#  8 | White    | Gray     | Black    
#  9 | Red      | White    | Yellow   
# 10 | Blue     | Red      | Red      
# 11 | Blue     | Green    | Magenta  
# 12 | White    | Gray     | Black    

proff()
# Executed in 0.16 second(s) in Ring 1.20
# Executed in 0.74 second(s) in Ring 1.17

/*==============

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ShowXT([ :ShowRowNumbers, :IntersectionChar = " " ])
#--> # | PALETTE1 | PALETTE2 | PALETTE3
#    -- ---------- ---------- ---------
#    1 |      Red |    White |   Yellow
#    2 |     Blue |      Red |      Red
#    3 |     Blue |    Green |  Magenta
#    4 |    White |     Gray |    Black

? @@NL( o1.SectionZ(:From = [1,2], :To = [3,2]) ) + NL
#--> [
#	[ [ 1, 2 ], "Blue" ],
#	[ [ 1, 3 ], "Blue" ],
#	[ [ 1, 4 ], "White" ],
#	[ [ 2, 2 ], "Red" ],
#	[ [ 2, 3 ], "Green" ],
#	[ [ 2, 4 ], "Gray" ],
#	[ [ 3, 1 ], "Yellow" ],
#	[ [ 3, 2 ], "Red" ]
# ]

? @@NL( o1.FindInSection(:From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [
#	[ [ 1, 2 ], [ 4 ] ],
#	[ [ 1, 3 ], [ 4 ] ],
#	[ [ 1, 4 ], [ 5 ] ],
#	[ [ 2, 2 ], [ 2 ] ],
#	[ [ 2, 3 ], [ 3, 4 ] ],
#	[ [ 3, 1 ], [ 2 ] ],
#	[ [ 3, 2 ], [ 2 ] ]
# ]

? @@( o1.FindNthInSection(:First, :From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [ [ 1, 2 ], 4 ]

? @@( o1.FindNthInSection(:Last, :From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [ [ 3, 2 ], 2 ]

? @@( o1.FindLastInSection(:From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [ [ 3, 2 ], 2 ]

proff()
# Executed in 0.20 second(s) in Ring 1.20
# Executed in 0.51 second(s) in Ring 1.17

/*=============

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.FindCell( "Red" ) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

# Same as:
? @@( o1.FindAllOccurrences( :Of = "Red") )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

? @@( o1.FindCells([ "Red", "White" ]) ) # Colors of the Tunisian flag :D
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ], [ 1, 4 ], [ 2, 1 ] ]

proff()
# Executed in 0.06 second(s)

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
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.38 second(s) in Ring 1.17

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

? @@NL( o1.FindAllOccurrences( :OfSubValue = "Ali" ) ) + NL
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

? @@( o1.FindNthOccurrence( 2, :OfSubValue = "Ali" ) ) + NL
#--> [ [ 1, 3 ], 1 ]

? @@( o1.FindNth(2, :SubValue = "Ali") ) + NL
#--> [ [ 1, 3 ], 1 ]

? @@( o1.FindFirst(:SubValue = "Ali") ) + NL
#--> [ [ 1, 2 ], 1 ]

? @@( o1.FindLast(:SubValue = "Ali" ) )
#--> [ [ 2, 3 ], 4 ]

proff()
# Executed in 0.15 second(s) in Ring 1.20
# Executed in 0.69 second(s) in Ring 1.17

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
# Executed in 0.12 second(s) in Ring 1.20
# Executed in 0.38 second(s) in Ring 1.17

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

? @@NL( o1.FindInRow( 3, :SubValue = "Ali" ) ) + NL
#-->[
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

? @@( o1.FindNthInRow( 2, 3, :SubValue = "Ali" ) )
#--> [ [ 2, 3 ], 1 ]

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

? @@( o1.Col(2) )
#--> [ "White", "Red", "Green", "Gray" ]

? @@( o1.HasColName(:PALETTE2) )
#--> TRUE

? o1.HasColNames([ :PALETTE1, :PALETTE3 ]) #--> TRUE
#--> TRUE

? @@( o1.ColNames() )
#--> [ "palette1", "palette2", "palette3" ]

proff()
# Executed in 0.02 second(s)

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
# Executed in 0.02 second(s)

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
# Executed in 0.04 second(s)

/*----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ColToColName(2)
#--> "palette2"

? o1.ColToColName(:PALETTE2) + NL
#--> "palette2"

? o1.TheseColsToColNames([3, :PALETTE1, 2])
#--> [ "palette3", "palette1", "palette2" ]

proff()
# Executed in 0.04 second(s)

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

? o1.ColToColNumber(:PALETTE2) + NL
#--> 2

? o1.TheseColsToColsNumbers([:PALETTE3, :PALETTE1, 2])
#--> [ 3, 1, 2 ]

proff()
# Executed in 0.03 second(s)

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
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#        Red      White     Yellow
#       Blue        Red        Red
#       Blue      Green    Magenta
#      White       Gray      Black


o1.EraseCol(2)
? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#         Red               Yellow
#        Blue                  Red
#        Blue              Magenta
#       White                Black

o1.EraseCols([3 , 1])
? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#                            
#                               
#                               
#                               
#    

proff()
# Executed in 0.20 second(s)

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
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#         Red      White     Yellow
#        Blue        Red        Red
#        Blue      Green    Magenta
#       White       Gray      Black

o1.EraseRow(2)
? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#         Red      White     Yellow
#                               
#        Blue      Green    Magenta
#       White       Gray      Black

o1.EraseRows([3, 1])
? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#                               
#                               
#                               
#       White       Gray      Black

proff()
# Executed in 0.18 second(s)

/*----------

pron()

o1 = new stzTable([
	:COL1 = [ "to", "be", "removed" ]
])
? o1.Show()
#-->   COL1
#   -------
#        to
#        be
#   removed

o1.RemoveCol(1)

? @@( o1.Content() )
#--> [ [ "col1", [ "" ] ] ]

? @@( o1.Cell(1, 1) )
#--> ""

? o1.NumberOfCells()
#--> 1

? @@( o1.Cells() )
#--> [ "" ]

? o1.IsEmpty()
#--> TRUE

o1.Show()
#--> COL1
#    ----
#    ""

proff()
# Executed in 0.10 second(s)

/*----------

pron()

o1 = new stzTable([])
o1.Show()
#--> COL1
#    ----
#    ""

? @@( o1.Col(1) )
#--> [ "" ]

? @@( o1.Cell(1, 1) )
#--> ""

proff()
# Executed in 0.09 second(s)

/*----------

pron()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.Cell(3, 2)
#--> "Red"

? o1.Cell(1, 1)
#--> "Red"

? o1.Cell(0, 2)
#--> Error message: Array Access (Index out of range) 

proff()
# Executed in 0.02 second(s)

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
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#         Red      White     Yellow
#        Blue        Red        Red
#        Blue      Green    Magenta
#       White       Gray      Black

o1.RemoveCol(1)
o1.RemoveCol(1)

? o1.Show()
#--> PALETTE3
#    --------
#      Yellow
#         Red
#     Magenta
#       Black

o1.RemoveCol(1)

o1.Show()
#--> COL1
#    ----
#    ""

o1.RemoveCol(2)
#--> Error message:
#    Incorrect value! n must correspond to a valid number of column.

proff()
# Executed in 0.12 second(s)

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
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#         Red      White     Yellow
#        Blue        Red        Red
#        Blue      Green    Magenta
#       White       Gray      Black

o1.RemoveCols([1, 2])
? o1.Show()
#--> PALETTE3
#    --------
#      Yellow
#         Red
#     Magenta
#       Black

o1.RemoveCol(:PALETTE3)
? o1.Show()
#--> COL1
#    ----
#    ""
      
proff()
#--> Executed in 0.15 second(s) in Ring 1.20
#--> Executed in 0.50 second(s) in Ring 1.17

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
# Executed in 0.02 second(s)

/*==========

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

o1.AddCol( :TEMPO = [ "any", "any", "any", "any" ])

? @@( o1.Col(:TEMPO) )
#--> [ "any", "any", "any" ]

proff()
#--> Executed in 0.02 second(s)

/*---------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

o1.AddCol( :TEMPO = [ "any", "any" ])

? @@( o1.Col(:TEMPO) )
#--> [ "any", "any", "" ]

proff()
# Executed in 0.02 second(s)

/*---------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

o1.AddCol( :TEMPO = [ ])

? @@( o1.Col(:TEMPO) )
#--> [ "", "", "" ]

proff()
# Executed in 0.02 second(s)

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
# Executed in 0.02 second(s)

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

? @@NL( o1.Cols() ) + NL
#--> [
#	[ 10, 20, 30 ],
#	[ "Ali", "Dan", "Ben" ],
#	[ 35000, 28900, 25982 ],
#	[ 1, 1, 1 ],
#	[ 2, 2, 2 ]
# ]

? @@( o1.TheseColumns([ :ONES, :TWOS ]) ) + NL
#--> [ [ 1, 1, 1 ], [ 2, 2, 2 ] ]

? @@NL( o1.TheseColumnsXT([ :ONES, :TWOS ]) )
#--> [
#	[ "ones", [ 1, 1, 1 ] ],
#	[ "twos", [ 2, 2, 2 ] ]
# ]

proff()
# Executed in 0.05 second(s) in Ring 1.17
# Executed in 0.30 second(s) in Ring 1.20

/*==========

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY,	:JOB 	],
	[ 10,	"Ali",		35000,		"job1"	],
	[ 20,	"Dan",		28900,		"job2"	],
	[ 30,	"Ben",		25982,		"job3"	]
])

? o1.ShowXT([])

#--> # | ID | EMPLOYEE | SALARY |  JOB
#    --+----+----------+--------+-----
#    1 | 10 |      Ali |  35000 | job1
#    2 | 20 |      Dan |  28900 | job2
#    3 | 30 |      Ben |  25982 | job3

? @@NL( o1.SubTable([ :EMPLOYEE, :SALARY ]) ) + NL
#--> [
#	[ "employee", [ "Ali", "Dan", "Ben" ] ],
#	[ "salary"  , [ 35000, 28900, 25982 ] ]
#    ]

o1.SubTableQR([ :EMPLOYEE, :SALARY ], :stzTable).Show()

#--> EMPLOYEE   SALARY
#    --------- -------
#         Ali    35000
#         Dan    28900
#         Ben    25982

proff()
# Executed in 0.14 second(s) in Ring 1.20
# Executed in 0.57 second(s) in Ring 1.17

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
# Executed in 0.02 second(s)

/*================

pron()

o1 = new stzListOfLists([
	[ 10,	"Ali",		35000	],
	[ 20,	"Dania",	28900	],
	[ 30,	"Ben",		25982	],
	[ 40,	"ali",		"Ali"	]
])

? @@( o1.FindInLists("Ali") )
#--> [ [ 1, 2 ], [ 4, 3 ] ]

? @@( o1.FindInListsCS("ali", :CS = FALSE) )
#--> [ [ 1, 2 ], [ 4, 2 ], [ 4, 3 ] ]

proff()
# Executed in 0.03 second(s)

/*---------

pron()

o1 = new stzListOfLists([
	[ 10, 20, 30, 40 ],
	[ "Ali", "Dania", "Ben", "ali" ],
	[ 35000, 28900, 25982, "Ali" ]
])

? @@( o1.FindInLists("Ali") )
#--> [ [ 2, 1 ], [ 3, 4 ] ]

? @@( o1.FindInListsCS("ali", :CS = FALSE) )
#--> [ [ 2, 1 ], [ 2, 4 ], [ 3, 4 ] ]

proff()
# Executed in 0.03 second(s)

/*---------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],

	[ 10,	"Ali",		35000	],
	[ 20,	"Dania",	28900	],
	[ 30,	"Ben",		25982	],
	[ 40,	"ali",		"Ali"	]
])

? o1.Contains( :Cell = "Ali" ) # same as ? o1.ContainsCell("Ali")
#--> TRUE

? o1.Contains( :SubValue = "a" ) # same as ? o1.ContainsSubValue("a")
#--> TRUE

? @@( o1.FindCellCS("Ali", FALSE) ) + NL
#--> [ [ 2, 1 ], [ 2, 4 ], [ 3, 4 ] ]
#--> One occurrence of "Ali" in the cell [2, 1]

? @@NL( o1.FindSubValueCS("a", :CaseSensitive = FALSE) )
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 4 ], [ 1 ] ],
#	[ [ 3, 4 ], [ 1 ] ]
# ]
#--> 5 occurrences of "a" (or "A"):
#	- 1 occurrence in cell [2, 1] ("Ali"), in position 1,
#	- 2 occurrences in cell [2, 2] ("Dania"), in positions 2 and 5
#	- 1 occurrence in cell [2, 4] ("ali"), in position 1, and finally
#	- 1 occurrence in cell [3, 4], ("Ali"), also in position 1

proff()
# Executed in 0.06 second(s)

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
# Executed in 0.07 second(s) in Ring 1.20
# Executed in 0.65 second(s) in Ring 1.17

/*-------------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],

	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	],
	[ 40,	"ali",		"ALI"	]
])

? o1.Count( :Value = "Ali" )
#--> 1

# Other alternatives of the same function:

? o1.Count( :Cell = "Ali" )
#--> 1

? o1.NumberOfOccurrence( :OfCell = "Ali" )
#--> 1

? o1.CountOfCell( "Ali" )
#--> 1

? o1.CountOfValue("Ali")
#--> 1

? o1.HowMany("Ali")
#--> 1

? o1.HowManyOccurrences( :Of = "Ali" )
#--> 1

proff()
# Executed in 0.07 second(s)

/*-------------

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Hania",	25982	]
])

? o1.Count( :SubValue = "a" )
#--> 3

? o1.CountCS( :SubValue = "A", :CaseSensitive = FALSE )
#--> 4

proff()
# Executed in 0.04 second(s)

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

? o1.Count( :Cells = "Ali" )
#--> 2
	# Same as NumberOfOccurrence( :OfCell = "Ali" )
	# Or you can say: ? o1.CountOfCell( "Ali" )
	# Or: HowMany( :Cells = "Ali" )

? @@( o1.FindCell("Ali") ) + NL
#--> [ [ 2, 1 ], [2, 4] ]
#--> One occurrence of "Ali" in the cell [2, 1], and
#    one in the cell [ 2, 4 ]

? @@NL( o1.FindSubValue("a") ) + NL
#--> [
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 3 ], [ 2 ] ]
#    ]
#--> There are 3 occurrences of of "a" in the table:
#	--> 2 occurrences in cell [2, 2] ("Dania"), in the 2nd and 5th chars.
#	--> 1 occurrence in cell [2, 3] ("Han"), in position 2.

? @@NL( o1.FindSubValueCS("a", :CaseSensitive = FALSE) ) + NL
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
# Executed in 0.08 second(s) in Ring 1.20
# Executed in 1.54 second(s) in Ring 1.17

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
# Executed in 0.02 second(s)

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

? @@NL( o1.FindInCells( [ [1,2], [2,2], [2,3] ], :SubValue = "a" ) )
#--> [
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 3 ], [ 2 ]    ]
#    ]
#--> There are 3 occurrences of "a" in the specified cells:
#	- 2 occurrences in the cell [2, 2] ("Dania"), in positions 2 and 5, and
#	- 1 occurrence in cell [2, 3] ("Han"), in position 2.

proff()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.17 second(s) in Ring 1.17

/*-------------

// Finding nth occurrence of a value, or subvalue, in a given list of cells

pron()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dania",	28900	],
	[ 30,	"Han",		25982	],
	[ 40,	"ali",		"ALI"	]
])

? @@( o1.FindNthInCells( 1, [ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [2, 2]

? @@( o1.FindNthInCells( 1, [ [1,2], [2,2], [2,3] ], :Value = "blabla" ) )
#--> [ ]

? @@( o1.FindNthInCells( 2, [ [1,2], [2,2], [2,3] ], :SubValue = "a" ) ) 
#--> [ [ 2, 2 ], 5 ]
// Same as:  @@( o1.FindNthSubValueInCells( 2, [ [1,2], [2,2], [2,3] ], "a" ) )

? @@( o1.FindFirstInCells([ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [ 2, 2 ]

? @@( o1.FindLastInCells([ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [ 2, 2 ]

proff()
# Executed in 0.06 second(s) in Ring 1.20
# Executed in 0.52 second(s) in Ring 1.17

/*-------------

pron()
o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dania",	28900	],
	[ 30,	"Han",		25982	],
	[ 40,	"ali",		"ALI"	]
])

? @@( o1.FindNthInCells( 3, [ [2,1], [2,4], [3,4] ], :Value = "ali" ) )
#--> []	// In fact, there is no a 3rd occurrence of 'ali" (in lowercase) in the table!

? @@( o1.FindNthInCellsCS( 3, [ [2,1], [2,4], [3,4] ], :Value = "ali", :CS = FALSE ) )
#--> [2, 4]

proff()
# Executed in 0.10 second(s)

/*------------- @narration

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

? @@NL( o1.TheseCellsZ( aMyCells ) ) + NL
#--> [
#	[ "Ali", [ 2, 1 ] ],
#	[ "Han", [ 2, 3 ] ],
#	[ "Ali", [ 2, 4 ] ]
# ]

# How many cell made of the value "Ali" does exist in those cells?

? o1.CountInCells( aMyCells, :Value = "Ali" )
#--> 2

# Where do they exist exactly?

? @@( o1.FindInCells( aMyCells, :Value = "Ali" ) )
#--> [ [ 2, 1 ], [ 2, 4 ] ]

# How many subvalue "A" exists in the same list of cells?

? o1.CountInCells( aMyCells, :SubValue = "A" )
#--> 2

# How many subvalue "A" whatever case it has?

? o1.CountInCellsCS( aMyCells, :SubValue = "A", :CS = FALSE )
#--> 3

# And where do they exist exactly?

? @@NL( o1.FindInCellsCS( aMyCells, :SubValue = "A", :CS = FALSE ) )
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 2 ] ],
#	[ [ 2, 4 ], [ 1 ] ]
#    ]

proff()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.46 second(s) in Ring 1.17

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
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.13 second(s) in Ring 1.17

/*------------- @narration

pron()

# Softanza can find the values of a cell in a stzTable object,
# but also it can find parts of those values.

# In other terms, it can dig inside the cells and tell you if
# the cells contain a sub-value you provide

# It's like your are performing a full-text search of the table!

# Let's see this feature in action...

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Alia Dania",	"12870"	]
])

? @@NL( o1.FindSubValueInCells( [ [2,1], [2,2], [2, 4] ], "ia" ) ) + NL
#--> [
#	[ [ 2, 2 ], [ 4 ] ],	// "ia" exists in cell "Dania" starting at position 4
#	[ [ 2, 4 ], [ 3, 9 ] ]  // "ia" exists in cell "Alia Dania" at positions 3 and 8
# ]

# When the subvalue is a number and the cell is a number-in-string or viceversa,
# Softanza perfprmas the finding operation as if both where numbers-in-strings

? @@NL( o1.FindSubValueInCells( [ [3,1], [3,2], [3,4] ], "0" ) ) + NL
#--> [
#	[ [ 3, 1 ], [ 3, 4, 5 ] ],
#	[ [ 3, 2 ], [ 4, 5 ] ],
#	[ [ 3, 4 ], [ 5 ] ]
# ]

? @@NL( o1.FindSubValueInCells( [ [3,1], [3,2], [3,4] ], 0 ) )
#--> [
#	[ [ 3, 1 ], [ 3, 4, 5 ] ],
#	[ [ 3, 2 ], [ 4, 5 ] ],
#	[ [ 3, 4 ], [ 5 ] ]
# ]

proff()
# Executed in 0.03 second(s)

/*#================= ROW: FindInRow(), CountInRow(), ContainsInRow()

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
# Executed in 0.16 second(s)

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
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.14 second(s) in Ring 1.17

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
# Executed in 0.05 second(s)

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
# Executed in 0.04 second(s)

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
# Executed in 0.04 second(s)

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

? @@NL( o1.FindInCol(:LASTNAME, :SubValue = "a" ) ) + NL
#--> [
#	[ [ 2, 1 ], [ 2 ] ],
#	[ [ 2, 2 ], [ 4, 6 ] ]
#    ]

? @@NL( o1.FindInColCS(:LASTNAME, :SubValue = "a", :CS = FALSE ) )
#--> [
#	[ [ 2, 1 ], [ 2 ] 	],
#	[ [ 2, 2 ], [ 1, 4, 6 ] ],
#	[ [ 2, 3 ], [ 1 ] 	]
#   ]

proff()
# Executed in 0.21 second(s) in Ring 1.20
# Executed in 0.35 second(s) in Ring 1.17

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
# Executed in 0.19 second(s) in Ring 1.19
# Executed in 0.43 second(s) in Ring 1.17

/*-----------

pron()

// Finding nth occurrence of a subvalue in a Col

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@NL( o1.FindInCol(:LASTNAME, :SubValue = "a") ) + NL
#--> [
#	[ [ 2, 1 ], [ 2 ] 	],
#	[ [ 2, 2 ], [ 4, 6 ] 	]
#    ]

? @@( o1.FindNthInCol(:Nth = 2, :InCol = 2, :OfSubValue = "a") ) + NL
#--> [ [ 2, 2 ], 4 ]

? @@( o1.FindFirstInCol(:LASTNAME, :SubValue = "a") )
#--> [ [ 2, 1 ], 2 ]

proff()
# Executed in 0.08 second(s) in Ring 1.20
# Executed in 0.28 second(s) in Ring 1.17

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
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.14 second(s) in Ring 1.17

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
# Executed in 0.04 second(s)

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

? o1.Cell(:FIRSTNAME, 3)
#--> "Saber"

proff()
# Executed in 0.04 second(s)

/*-----------------

pron()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE ],
	[ "___",	"Arabic"  ],
	[ "France",	"___"     ],
	[ "USA",	"___"     ]
])

? o1.Cell(2, 3) + NL
#--> "___"

o1.ReplaceCell(2, 3, :With = "English")

? o1.Cell(2, 3)
#--> "English"

proff()
# Executed in 0.02 second(s)

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
#-->  NATION   LANGUAGE
#    -------- ---------
#    Tunisia     Arabic
#     France     French
#        USA    English

proff()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.19 second(s) in Ring 1.17

/*-----------------

pron()

o1 = new stzList([ "A", "B", "C" ])

o1.ExtendXT(:To = 10, :ByRepeatingItems)
? @@( o1.Content() )
#--> [ "A", "B", "C", "A", "B", "C", "A", "B", "C", "A" ]

proff()
# Executed in 0.02 second(s)

/*-----------------

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
#--> NATION   LANGUAGE
#    ------- ---------
#    France         01
#       USA         02
#     Niger         03
#     Egypt         01
#    Kuwait         02

proff()
# Executed in 0.10 second(s)

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
#--> NATION   LANGUAGE
#    ------- ---------
#     .....     Arabic
#    France      .....
#       USA      .....

proff()
# Executed in 0.13 second(s) in Ring 1.20
# Executed in 0.72 second(s) in Ring 1.17

/*============= #TODO write a #narration

pron()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE   ],
	[ "Tunisia",	"Arabic"    ],
	[ "France",	"French"    ],
	[ "Egypt",	"English"   ],
	[ "Belgium",	"French"    ],
	[ "Yemen",	"Arabic"    ]
])

o1.ReplaceNthCol(2, [ "___", "___" ])
? o1.Show()
#-->  NATION   LANGUAGE
#     -------- ---------
#     Tunisia        ___
#      France        ___
#       Egypt    English 
#     Belgium     Frencg
#       Yemen     Arabic

o1.ReplaceCellsInCol(:LANGUAGE, :By = ".....")
? o1.Show()
#--> NATION   LANGUAGE
#    -------- ---------
#    Tunisia      .....
#     France      .....
#      Egypt      .....
#    Belgium      .....
#      Yemen      .....

o1.ReplaceCol(:LANGUAGE, [ "Arabic", "French" ])
? o1.Show()
#-->  NATION   LANGUAGE
#     -------- ---------
#     Tunisia     Arabic
#      France     French
#       Egypt      .....
#     Belgium      .....
#       Yemen      .....

o1.ReplaceColXT(:LANGUAGE, [ "Arabic", "French" ])
? o1.Show()
#-->  NATION   LANGUAGE
#     -------- ---------
#     Tunisia     Arabic
#      France     French
#       Egypt     Arabic
#     Belgium     French
#       Yemen     Arabic

o1.ReplaceColNameAndData(:LANGUAGE, :CONTINENT, [ "Africa", "Europe", "Africa", "Europe", "Asia" ])
o1.Show()
#-->  NATION   CONTINENT
#     -------- ----------
#     Tunisia      Africa
#      France      Europe
#       Egypt      Africa
#     Belgium      Europe
#       Yemen        Asia

proff()
# Executed in 0.28 second(s)

/*---------

pron()

o1 = new stzTable([
	[ :NATION,	:CONTINENT   ],
	[ "Tunisia",	"Africa"    ],
	[ "France",	"Europe"    ],
	[ "Egypt",	"___"       ],
	[ "Belgium",	"___"       ],
	[ "Yemen",	"___"       ]
])

o1.ReplaceColNameAndDataXT( :CONTINENT, :LANGUAGE, [ "Arabic", "French" ] )
o1.Show()

#-->  NATION   LANGUAGE
#    -------- ---------
#    Tunisia     Arabic
#     France     French
#      Egypt     Arabic
#    Belgium     French
#      Yemen     Arabic

proff()
# Executed in 0.09 second(s)

/*----------------- #TODO write a #narration

pron()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE,	:CAPITAL,	:CONTINENT   ],

	[ "Tunisia",	"Arabic",	"Tunis",	"Africa"    ],
	[ "France",	"French",	"Paris",	"Europe"    ],
	[ "Egypt",	"English",	"Cairo",	"Africa"    ],
	[ "Belgium",	"French",	"Brussel",	"Europe"    ],
	[ "Yemen",	"Arabic",	"Sanaa",	"Asia"	    ]
])

o1.ReplaceRow(2, [ "___", "___" ]) # Or ReplaceNthRow()
? o1.Show()

#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#         ___        ___     Paris      Europe
#       Egypt    English     Cairo      Africa
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia

o1.ReplaceCellsInRow(2, :By = ".....")
? o1.Show()
#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#       .....      .....     .....       .....
#       Egypt    English     Cairo      Africa
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia

o1.ReplaceRowXT(2, [ "____", "~~~~" ])
? o1.Show()
#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#       ____      ~~~~     ____           ~~~~
#       Egypt    English     Cairo      Africa
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia


proff()
# Executed in 0.35 second(s)

/*---------

pron()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE,	:CAPITAL,	:CONTINENT   ],

	[ "Tunisia",	"Arabic",	"Tunis",	"Africa"    ],
	[ "France",	"French",	"Paris",	"Europe"    ],
	[ "Egypt",	"English",	"Cairo",	"Africa"    ],
	[ "Belgium",	"French",	"Brussel",	"Europe"    ],
	[ "Yemen",	"Arabic",	"Sanaa",	"Asia"	    ]
])

o1.ReplaceRows([ "___", "___", "___" ])
? o1.Show()

#--> NATION   LANGUAGE   CAPITAL   CONTINENT
#    ------- ---------- --------- ----------
#       ___        ___       ___      Africa
#       ___        ___       ___      Europe
#       ___        ___       ___      Africa
#       ___        ___       ___      Europe
#       ___        ___       ___        Asia

o1.ReplaceRowsXT([ "___", "~~~" ])
o1.Show()

#--> NATION   LANGUAGE   CAPITAL   CONTINENT
#    ------- ---------- --------- ----------
#       ___        ~~~       ___         ~~~
#       ___        ~~~       ___         ~~~
#       ___        ~~~       ___         ~~~
#       ___        ~~~       ___         ~~~
#       ___        ~~~       ___         ~~~

proff()
# Executed in 0.22 second(s)

/*---------

pron()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE,	:CAPITAL,	:CONTINENT   ],

	[ "Tunisia",	"Arabic",	"Tunis",	"Africa"    ],
	[ "France",	"French",	"Paris",	"Europe"    ],
	[ "Egypt",	"English",	"Cairo",	"Africa"    ],
	[ "Belgium",	"French",	"Brussel",	"Europe"    ],
	[ "Yemen",	"Arabic",	"Sanaa",	"Asia"	    ]
])

o1.ReplaceCols([ "___", "___", "___" ])
? o1.Show()
#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#         ___        ___       ___         ___
#         ___        ___       ___         ___
#         ___        ___       ___         ___
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia

o1.ReplaceColsXT([ "___", "~~~" ])
o1.Show()
#--> NATION   LANGUAGE   CAPITAL   CONTINENT
#     ------- ---------- --------- ----------
#        ___        ___       ___         ___
#        ~~~        ~~~       ~~~         ~~~
#        ___        ___       ___         ___
#        ~~~        ~~~       ~~~         ~~~
#        ___        ___       ___         ___

proff()
# Executed in 0.20 second(s)

/*---------

pron()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE,	:CAPITAL,	:CONTINENT   ],

	[ "Tunisia",	"Arabic",	"Tunis",	"Africa"    ],
	[ "France",	"French",	"Paris",	"Europe"    ],
	[ "Egypt",	"English",	"Cairo",	"Africa"    ],
	[ "Belgium",	"French",	"Brussel",	"Europe"    ],
	[ "Yemen",	"Arabic",	"Sanaa",	"Asia"	    ]
])

o1.ReplaceTheseCols( [ :LANGUAGE, :CONTINENT ], [ "___", "___", "___" ] )
? o1.Show()
#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia        ___     Tunis         ___
#      France        ___     Paris         ___
#       Egypt        ___     Cairo         ___
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia

o1.ReplaceTheseColsXT( [ :LANGUAGE, :CONTINENT ], [ "___", "~~~" ] )
o1.Show()
#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia        ___     Tunis         ___
#      France        ~~~     Paris         ~~~
#       Egypt        ___     Cairo         ___
#     Belgium        ~~~   Brussel         ~~~
#       Yemen        ___     Sanaa         ___

proff()
# Executed in 0.22 second(s)

/*---------

pron()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE,	:CAPITAL,	:CONTINENT   ],

	[ "Tunisia",	"Arabic",	"Tunis",	"Africa"    ],
	[ "France",	"French",	"Paris",	"Europe"    ],
	[ "Egypt",	"English",	"Cairo",	"Africa"    ],
	[ "Belgium",	"French",	"Brussel",	"Europe"    ],
	[ "Yemen",	"Arabic",	"Sanaa",	"Asia"	    ]
])

o1.ReplaceTheseRows( [ 3, 5 ], [ "___", "___", "___" ] )
? o1.Show()
#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#      France     French     Paris      Europe
#         ___        ___       ___      Africa
#     Belgium     French   Brussel      Europe
#         ___        ___       ___        Asia

o1.ReplaceTheseRowsXT( [ 3, 5 ], [ "___", "~~~" ] )
o1.Show()
#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#      France     French     Paris      Europe
#         ___        ~~~       ___         ~~~
#     Belgium     French   Brussel      Europe
#         ___        ~~~       ___         ~~~

proff()
# Executed in 0.26 second(s)

/*---------

pron()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE,	:CAPITAL,	:CONTINENT   ],

	[ "Tunisia",	"Arabic",	"Tunis",	"Africa"    ],
	[ "France",	"French",	"Paris",	"Europe"    ],
	[ "Egypt",	"English",	"Cairo",	"Africa"    ],
	[ "Belgium",	"French",	"Brussel",	"Europe"    ],
	[ "Yemen",	"Arabic",	"Sanaa",	"Asia"	    ]
])

o1.ReplaceCells(
	[ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 3 ], [ 4, 3 ] ],
	:By = "___"
)
? o1.Show()
#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#      France     French     Paris      Europe
#         ___        ___       ___      Africa
#     Belgium     French   Brussel      Europe
#         ___        ___       ___        Asia

o1.ReplaceCellsByMany( 
	[ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 3 ], [ 4, 3 ] ],
	:By = [ "~~~", "~~~", "~~~" ]
)
? o1.Show()
#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia        ~~~     Tunis      Africa
#      France        ~~~     Paris      Europe
#       Egypt        ~~~       ___         ___
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia

o1.ReplaceCellsByManyXT( 
	[ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 3 ], [ 4, 3 ] ],
	:By = [ "^^v^^", "~~^~~" ]
)
o1.Show()
#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#    -------- ---------- --------- ----------
#    Tunisia      ^^v^^     Tunis      Africa
#     France      ~~^~~     Paris      Europe
#      Egypt      ^^v^^     ~~^~~       ^^v^^
#    Belgium     French   Brussel      Europe
#      Yemen     Arabic     Sanaa        Asia

proff()
# Executed in 0.21 second(s)

/*=========

pron()

o1 = new stzTable([
	[ "NATION", "LANGUAGE", "CAPITAL", "CONTINENT" ],

	[ "Tunisia", "Arabic", "Tunis", "Africa" ],
	[ "France", "French", "Paris", "Europe" ],
	[ "Egypt", "English", "Cairo", "Africa" ]
])

o1.Show()

#--> NATION   LANGUAGE   CAPITAL   CONTINENT
#   -------- ---------- --------- ----------
#   Tunisia     Arabic     Tunis      Africa
#    France     French     Paris      Europe
#     Egypt    English     Cairo      Africa

proff()
# Executed in 0.10 second(s)

/*---------

pron()

? Q(:FromFile = "mytable.csv").IsFromFileNamedParam()

proff()
# Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzTable([
	[ :NAME, :HOBBIES		],
	[ "kim", [ "Sport", "Music" ]	],
	[ "Dan", [ "Gaming" ]		],
	[ "Sam", [ "Music", "Travel" ]	]
])

o1.Show()
#--> NAME                HOBBIES
#   ----- ----------------------
#    kim    [ "Sport", "Music" ]
#    Dan            [ "Gaming" ]
#    Sam   [ "Music", "Travel" ]

proff()
# Executed in 0.11 second(s)

#============

pron()

o1 = new stzTable([

	[ "COUNTRY",	"INCOME",	"POPULATION" 	],
	#-----------------------------------------------#
	[ "USA",	   25450,	        340.1	],
	[ "China",	   18150,	       1430.1	],
	[ "Japan",	    5310,		123.2	],
	[ "Germany",	    4490,	         83.3	],
	[ "India",	    3370,	       1430.2	]

])

o1.InsertRow(3, [ "Niger", 3616, 26.21 ])
o1.Show()

#--> COUNTRY   INCOME   POPULATION
#    -------- -------- -----------
#        USA    25450       340.10
#      China    18150      1430.10
#      Niger     3616        26.21
#      Japan     5310       123.20
#    Germany     4490        83.30
#      India     3370      1430.20

proff()
# Executed in 0.02 second(s) without the Show() function
# Executed in 0.10 second(s) with the Show() function

/*-----------

pron()

o1 = new stzTable([

	[ "COUNTRY",	"INCOME",	"POPULATION" 	],
	#-----------------------------------------------#
	[ "USA",	   25450,	        340.1	],
	[ "China",	   18150,	       1430.1	],
	[ "Japan",	    5310,		123.2	],
	[ "Germany",	    4490,	         83.3	],
	[ "India",	    3370,	       1430.2	]

])

o1.InsertRowAt([ 2, 4, 5 ] , [ "~~~~~~~~", "~~~~~~~~", "~~~~~~~~" ])
# Or InsertRowAtPositions() or InsertRow() or InsertRowAt() or
# InsertRow( :At = ...) or InsertRow( :AtPositions = ...)

o1.Show()
#-->  COUNTRY     INCOME   POPULATION
#    --------- ---------- -----------
#         USA      25450       340.10
#    ~~~~~~~~   ~~~~~~~~     ~~~~~~~~
#       China      18150      1430.10
#       Japan       5310       123.20
#    ~~~~~~~~   ~~~~~~~~     ~~~~~~~~
#     Germany       4490        83.30
#    ~~~~~~~~   ~~~~~~~~     ~~~~~~~~
#       India       3370      1430.20

proff()
# Executed in 0.13 second(s)

/*-----------

pron()

# Income in million dollars per year
# Population in million people
# Percapiat (calculated) in thousand dollars per year
# Source: WolframAlpha

o1 = new stzTable([

	[ "COUNTRY",	"INCOME",	"POPULATION" 	],
	#-----------------------------------------------#
	[ "USA",	   25450,	        340.1	],
	[ "China",	   18150,	       1430.1	],
	[ "Japan",	    5310,		123.2	],
	[ "Germany",	    4490,	         83.3	],
	[ "India",	    3370,	       1430.2	]

])

o1.AddCalculatedCol(:PERCAPITA, '@(:INCOME) / @(:POPULATION)')
? o1.Show()

#--> COUNTRY   INCOME   POPULATION   PERCAPITA
#    -------- -------- ------------ ----------
#        USA    25450          340       74.85
#      China    18150         1430       12.69
#      Japan     5310          123       43.17
#    Germany     4490        83.30       53.90
#      India     3370         1430        2.36

o1.InsertCalculatedCol(2, :CURRENCY, 'StzCountryQ(@(:COUNTRY)).CurrencyAbbreviation()')
? o1.Show()

? @@( o1.FindCalculatedCols() ) + NL
#--> [ 2, 4 ]

? o1.CalculatedColNames()
#--> [ "currency", "population" ]

? @@NL( o1.CalculatedCols() ) + NL
#--> [
#	[ "USD", "CNY", "JPY", "EUR", "INR" ],
#	[ 340.10, 1430.10, 123.20, 83.30, 1430.20 ]
# ]

#--

o1.AddCalculatedRow([
'', '', '@Sum( @(:INCOME) )', '@Sum( @(:POPULATION) )', '@Average( @(:PERCAPITA) )'
])

? o1.Show()

#--> COUNTRY   INCOME   POPULATION   PERCAPITA
#    -------- -------- ------------ ----------
#        USA    25450       340.10       74.83
#      China    18150      1430.10       12.69
#      Japan     5310       123.20       43.10
#    Germany     4490        83.30       53.90
#      India     3370      1430.20        2.36
#               56770      3406.90       37.38

? @@( o1.FindCalculatedRows() ) + NL
#--> [ 6 ]

? @@( o1.CalculatedRows() ) + NL
#--> [ [ " ", " ", 56770, 3406.90, 37.38 ] ]

proff()
# Executed in 0.52 second(s)

/*---------

pron()

o1 = new stzTable([
	[ :NAME,	:AGE,	:JOB ],
	[ "Folla",	22,	"Singer" ],
	[ "Warda",	28,	"Painter"],
	[ "Yasmine",	24,	"Danser" ]
])
? o1.Show()

#-->     NAME   AGE       JOB
#     -------- ----- --------
#       Folla    22    Singer
#       Warda    28   Painter
#     Yasmine    24    Danser

o1.InsertCol(3, [ :HOBBY, [ "Music", "Painting" ] ])
? o1.Show()

#-->    NAME   AGE       JOB      HOBBY
#    -------- ----- --------- ---------
#      Folla    22    Singer      Music
#      Warda    28   Painter   Painting
#    Yasmine    24    Danser         ""  

proff()
# Executed in 0.15 second(s)

#=================

pron()

o1 = new stzTable([])

? o1.IsEmpty()
#--> TRUE

? o1.NumberOfCols()
#--> 1

? o1.NumberOfRows()
#--> 1

? o1.Show()

#--> COL1
#    ----
#      ""

o1.FromFile("mytable.txt")
o1.Show()

#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#    -------- ---------- --------- ----------
#    Tunisia     Arabic     Tunis      Africa
#     France     French     Paris      Europe
#      Egypt    English     Cairo      Africa
#    Belgium     French   Brussel      Europe
#      Yemen     Arabic     Sanaa        Asia

proff()
# Executed in 0.23 second(s) without the Show() functions
# Executed in 0.33 second(s) with the Show() functions

/*==============

pron()

? @@( @SortListsOn(1, [ [ 2, 2 ], [ 2, 4 ] ] ) ) # You can put the list before and it worlks!
#--> [ [ 2, 2 ], [ 2, 4 ] ]

? @@( @SortLists([ [ 2, 4 ], [ 2, 2 ] ]) )
#--> [ [ 2, 2 ], [ 2, 4 ] ]

? @@( @SortLists([ [ 2, 2 ], [ 2, 4 ] ]) ) # Uses SortOn(1, )
#--> [ [ 2, 2 ], [ 2, 4 ] ]

? @@( StzListOfPairsQ([ [ 2, 2 ], [ 2, 4 ] ]).Sorted() ) + NL
#--> [ [ 2, 2 ], [ 2, 4 ] ]

# If the column of sort is the last column in the list, and
# if it is made of the same item, then sort is performed
# on the column just before

? @@NL( SortListsOn( 3, [

	[ 2, 3, 1 ],
	[ 4, 2, 1 ],
	[ 7, 4, 1 ]

]) ) + NL
#--> [
#	[ 4, 2, 1 ],
#	[ 2, 3, 1 ],
#	[ 7, 4, 1 ]
# ]

? @@NL( SortListsOn( 2, [

	[ 3, 1, 5 ],
	[ 7, 1, 3 ],
	[ 2, 1, 3 ]

]) ) + NL
#--> [
#	[ 2, 1, 3 ],
#	[ 3, 1, 5 ],
#	[ 7, 1, 3 ]
# ]

proff()
# Executed in 0.11 second(s)

/*---------- #narration
*/
pron()

# If the column of sort is uniform (made of same item),
# Softanza looks backward to the columns coming before.

# If a column with distinct items is found, the sort
# is made on it.

# Otherwise, it goes forward and checks the columns
# coming after and does the same thing.

# If a column with distinct items is found, the sort
# is made on it.

# Otherwise, all columns are made of same items, and
# no sort is performed.

? @@NL( SortListsOn( 3, [

	[ 1, 1, 1, 3, 1 ],
	[ 1, 1, 1, 7, 1 ],
	[ 1, 1, 1, 2, 1 ]

]) )
#--> [
#	[ 1, 1, 1, 2, 1 ],
#	[ 1, 1, 1, 3, 1 ],
#	[ 1, 1, 1, 7, 1 ]
# ]

proff()
# Executed in 0.04 second(s)

/*---------

pron()

o1 = new stzTable([

	[ "COUNTRY",	"INCOME",	"POPULATION" 	],
	#-----------------------------------------------#
	[ "USA",	   25450,	        340.1	],
	[ "China",	   18150,	       1430.1	],
	[ "Japan",	    5310,		123.2	],
	[ "Germany",	    4490,	         83.3	],
	[ "India",	    3370,	       1430.2	]

])

? @@( o1.FindSection([ :INCOME, 3 ], [ :POPULATION, 3 ]) ) + NL # OR FindCellsInSection()
#--> [ [ 2, 3 ], [ 2, 4 ], [ 2, 5 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ] ]

? @@( o1.FindSection([ :INCOME, 3 ], [ :POPULATION, 1 ]) ) + NL
#--> [ [ 2, 3 ], [ 2, 4 ], [ 2, 5 ], [ 3, 1 ] ]

? @@( o1.FindSection([ :INCOME, 2 ], [ :INCOME, 5 ]) ) + NL
#--> [ [ 2, 2 ], [ 2, 3 ], [ 2, 4 ], [ 2, 5 ] ]

? @@( o1.FindSection([ :POPULATION, 2 ], [ :POPULATION, 4 ]) ) + NL
# [ [ 3, 2 ], [ 3, 3 ], [ 3, 4 ] ]

proff()
# Executed in 0.06 second(s)

/*========= EXCEL-Like functions
*/
pron()

o1 = new stzTable([

	[ "A", "B", "C" ],

	[  12,  10,   8 ],
	[  10,  14,  24 ],
	[   7,   4,   8 ]

])

? o1.KOUNT([ :A, 1 ], [ :C, 3 ])
#--> 9

? o1.SUM([ :A, 1 ], [ :C, 3 ])
#--> 97

? o1.AVERAGE([ :A, 1 ], [ :C, 3 ])
#--> 10.78

? o1.PRODUCT([ :A, 1 ], [ :C, 3 ])
#--> 722_534_400

? o1.MAX([ :A, 1 ], [ :C, 3 ])
#--> 24

? o1.MIN([ :A, 1 ], [ :C, 3 ])
#--> 4

proff()
# Executed in 0.08 second(s)
