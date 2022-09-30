load "stzlib.ring"

/*===============

# A table can be created in 4 different ways:

# WAY 1 : Creating an empty table with just a column and a row
o1 = new stzTable([])

? @@S( o1.Content() )
#--> [ [ "COL1", [ "" ] ] ]

/*--------------

# WAY 2 : Creating an empty table with 3 columns and 3 rows
o1 = new stzTable([3, 2])
? @@S( o1.Content() )

#--> [
#	[ "COL1", [ "", "" ] ],
#	[ "COL2", [ "", "" ] ],
#	[ "COL3", [ "", "" ] ]
#    ]

/*--------------

# WAY 3: Creating a table bu prividing a hash table
# NOTE: This is how the table is stored internally

o1 = new stzTable([
	:ID	  = [ 10, 20, 30, 40 ],
	:EMPLOYEE = [ "Ali Sandy", "Dan Mikovitch Mo", "Ali Sa", "Ali Aziza" ],
	:SALARY   = [ 35000, 28900, 25982, 49540 ]
])

? @@S( o1.Content() )

#--> [
# 	:ID	  = [ 10, 20, 30, 40 ],
#	:EMPLOYEE = [ "Ali Sandy", "Dan Mikovitch Mo", "Ali Sa", "Ali Aziza" ],
# 	:SALARY   = [ 35000, 28900, 25982, 49540 ]
# ])

/*---------------

# WAY 4: Creating a table by provding a list of list, formatted as you
# would find it in the real world

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

? o1.Cols()		#--> [ "id", "employee", "salary" ]
? o1.Col(:EMPLOYEE)	#--> [ "Ali", "Dania", "Han", "Ali" ]

/*==============

? @@S( o1.SectionAsPositions([2, 2], [3, 3]) )
#--> [ [ 2, 2 ], [ 3, 2 ], [ 2, 3 ], [ 3, 3 ] ]

/*--------------

? @@S(o1.Section([2, 2], [3, 3])) + NL
#--> [ "Dan Mikovitch Mo", 28900, "Ali Sa", 25982 ]

/*--------------

? @@S(o1.SectionXT([2, 2], [3, 3]))
#--> [
#	[ [ 2, 2 ], "Dan Mikovitch Mo" ],
#	[ [ 3, 2 ], 28900 ],
#	[ [ 2, 3 ], "Ali Sa"],
#	[ [ 3, 3 ], 25982 ]
# ]

/*--------------

? @@S( o1.Section(:FirstCell, :LastCell) )
#--> [
#	10, "Ali Sandy", 35000,
#	20, "Dan Mikovitch Mo", 28900,
#	30, "Ali Sa", 25982,
#	40, "Ali Aziza", 49540
# ]

/*==============

? @@S( o1.Cells() ) + NL
#--> [
#	10, "Ali Sandy", 35000,
#	20, "Dan Mikovitch Mo", 28900,
#	30, "Ali Sa", 25982,
#	40, "Ali Aziza", 49540
# ]

? @@S( o1.CellsXT() ) + NL # Same as CellsAndPositions()
#--> [
#	[ 10, 			[ 1, 1 ] ],
#	[ "Ali Sandy", 		[ 2, 1 ] ],
#	[ 35000, 		[ 3, 1 ] ],
#	[ 20, 			[ 1, 2 ] ],
#	[ "Dan Mikovitch Mo", 	[ 2, 2 ] ],
#	[ 28900, 		[ 3, 2 ] ],
#	[ 30, 			[ 1, 3 ] ],
#	[ "Ali Sa", 		[ 2, 3 ] ],
#	[ 25982, 		[ 3, 3 ] ],
#	[ 40, 			[ 1, 4 ] ],
#	[ "Ali Aziza", 		[ 2, 4 ] ],
#	[ 49540, 		[ 3, 4 ] ]
# ]

? @@S( o1.PositionsAndCells() ) + NL
#--> [
#	[ [ 1, 1 ], 10	 ],
#	[ [ 2, 1 ], "Ali Sandy" ],
#	[ [ 3, 1 ], 35000 ],
#	[ [ 1, 2 ], 20 ],
#	[ [ 2, 2 ], "Dan Mikovitch Mo" ],
#	[ [ 3, 2 ], 28900 ],
#	[ [ 1, 3 ], 30 ],
#	[ [ 2, 3 ], "Ali Sa" ],
#	[ [ 3, 3 ], 25982 ],
#	[ [ 1, 4 ], 40 ],
#	[ [ 2, 4 ], "Ali Aziza" ],
#	[ [ 3, 4 ], 49540 ]
# ]

? @@S( o1.CellsToHashList() ) + NL
#--> [
#	[ "[ 1, 1 ]", 10	 ],
#	[ "[ 2, 1 ]", "Ali Sandy" ],
#	[ "[ 3, 1 ]", 35000 ],
#	[ "[ 1, 2 ]", 20 ],
#	[ "[ 2, 2 ]", "Dan Mikovitch Mo" ],
#	[ "[ 3, 2 ]", 28900 ],
#	[ "[ 1, 3 ]", 30 ],
#	[ "[ 2, 3 ]", "Ali Sa" ],
#	[ "[ 3, 3 ]", 25982 ],
#	[ "[ 1, 4 ]", 40 ],
#	[ "[ 2, 4 ]", "Ali Aziza" ],
#	[ "[ 3, 4 ]", 49540 ]
# ]

? @@S( o1.SectionToHashList([2, 2], [3, 3]) )
#--> [
#	[ "[ 2, 2 ]", "Dan Mikovitch Mo" ],
#	[ "[ 3, 2 ]", 28900 ],
#	[ "[ 2, 3 ]", "Ali Sa" ],
#	[ "[ 3, 3 ]", 25982 ]
# ]

/*==============

? o1.NumberOfColumns() #--> 3

/*--------------

? o1.HasCol(:EMPLOYEE) #--> TRUE

/*--------------

? o1.ColNames() #--> [ "id", "employee", "salary" ]

/*--------------

? o1.ColName(2) #--> "employee"

/*==============

? @@S( o1.Cell(2, 2) )	#--> "Dan Mikovitch Mo"

? o1.Cell(:EMPLOYEE, 2)	#--> "Dan Mikovitch Mo"

? @@S( o1.Cell(5, 7) )	#--> ERR: Array Access (Index out of range) ! 

/*==============

? o1.NumberOfRows()	#--> 4
? o1.NumberOfCols()	#--> 3
? o1.NumberOfCells()	#--> 12

/*==============

? @@S( o1.Header() ) + NL
#--> [ "id", "employee", "salary" ]

/*==============

o1.AddCol(:AGE = [ 55, 35, 28, 65 ])
? @@S( o1.Content() )
#--> [
#	[ "id", [ 10, 20, 30, 40 ] ],
#	[ "employee", [ "Ali Sandy", "Dan Mikovitch Mo", "Ali Sa", "Ali Aziza" ] ],
#	[ "salary", [ 35000, 28900, 25982, 49540 ] ],
#	[ "age", [ 55, 35, 28, 65 ] ]
# ]


/*==============

// A table is empty when all its cells are NULL
? o1.IsEmpty() #--> FALSE

/*==============

? @@S( o1.NthCol(0) )   #--> [ 1, 2, 3, 4 ]
? @@S( o1.NthColXT(0) ) #--> [ "#", 1, 2, 3, 4 ]

/*--------------

? @@S( o1.NthCol(3) )
#--> [ 35000, 28900, 25982, 49540 ]

? @@S( o1.NthColXT(3) )
#--> [ "salary", 35000, 28900, 25982, 49540 ]

/*--------------

? @@S( o1.FirstColXT() )
#--> [ "id", 10, 20, 30, 40 ]

? @@S( o1.LastColXT() )
#--> [ "salary", 35000, 28900, 25982, 49540 ]

/*==============

? @@S( o1.Row(2) )
#--> [ 20, "Dan Mikovitch Mo", 28900 ]

/*--------------

? @@S( o1.Rows() )
#-->
# [
#	[ 10, "Ali Sandy",        35000 ],
#	[ 20, "Dan Mikovitch Mo", 28900 ],
#	[ 30, "Ali Sa",           25982 ],
#	[ 40, "Ali Aziza",        49540 ]
# ]

/*==============

o1.AddCol( :THING = [ "Thing1", "Thing2", "Thing3", "Thing4" ] )
? @@S( o1.Content() ) + NL
#--> [
#	[ "id", [ 10, 20, 30, 40 ] ],
#	[ "employee", [ "Ali Sandy", "Dan Mikovitch Mo", "Ali Sa", "Ali Aziza" ] ],
#	[ "salary", [ 35000, 28900, 25982, 49540 ] ],
#	[ "thing", [ "Thing1", "Thing2", "Thing3", "Thing4" ] ]
# 
]


o1.RemoveCol(:THING)
? @@S( o1.Content() ) + NL
#--> [
#	[ "id", [ 10, 20, 30, 40 ] ],
#	[ "employee", [ "Ali Sandy", "Dan Mikovitch Mo", "Ali Sa", "Ali Aziza" ] ],
#	[ "salary", [ 35000, 28900, 25982, 49540 ] ]
# ]

/*--------------

o1.RemoveCol([ :ID, :EMPLOYEE ])
? @@S( o1.Content() )
#--> [ [ "salary", [ 35000, 28900, 25982, 49540 ] ] ]

/*==============

? @@S( o1.Cols() )
/*--> [ "id", "employee", "salary" ]
 
/*==============

? @@S( o1.MaxSizeInEachCol() )
#--> [ 2, 16, 5 ]

? @@S( o1.MaxSizeInEachColXT() )
#--> [ 1, 2, 16, 5 ]

?  @@S( o1.MaxSizeInEachRow() )
#--> [ 9, 16, 6, 9 ]

? o1.HeaderToString()
#--> "#   id           employee   salary"

/*--------------

? o1.MaxSizeInCol("EMPLOYEE") #--> 16
? o1.MaxSizeInRow(3) #--> 6

/*==============

? @@S( o1.Col(3) ) # Same as  o1.ColData(3), o1.Col(:SALARY), and o1.ColData(:SALARY)
#--> [ 35000, 28900, 25982, 49540 ]

/*--------------

? o1.ColName(3) #--> salary

/*==============

? @@S( o1.SubTable([ :ID, :SALARY ]) ) // Same as o1.TheseColumnsXT([1, 2])
#--> [
#	[ "id", 	[ 10, 20, 30, 40 ] 		],
#	[ "salary", 	[ 35000, 28900, 25982, 49540 ] 	]
# ]

/*--------------

? o1.ColNumbersToNames([1, 3])
#--> [ "id", "salary" ]

/*--------------

? @@S( o1.TheseColumns([1, 2]) ) + NL 	// Same as o1.TheseColumns([:ID, :EMPLOYEE])
					// and o1.TheseColData([:ID, :EMPLOYEE])
#--> [
#	[ 10, 20, 30, 40 ],
#	[ "Ali Sandy", "Dan Mikovitch Mo", "Ali Sa", "Ali Aziza" ]
# ]

? @@S( o1.TheseColumnsXT([1, 2]) )
#--> [
#	[ "id", [ 10, 20, 30, 40 ] ],
#	[ "employee", [ "Ali Sandy", "Dan Mikovitch Mo", "Ali Sa", "Ali Aziza" ] ]
# ]

/*--------------

? o1.TheseColNames([1, 2]) #--> [ "id", "employee" ]

/*==============

? Q(["", "", ""]).AllItemsAreNull() #--> TRUE

/*--------------

? o1.IsEmpty() #--> FALSE
o1.Erase()
? o1.IsEmpty() #--> TRUE
? @@S( o1.Content() )

#--> [
#	[ "id", 	[ NULL, NULL, NULL, NULL ] ],
#	[ "employee", 	[ NULL, NULL, NULL, NULL ] ],
#	[ "salary", 	[ NULL, NULL, NULL, NULL ] ]
# ]

/*--------------

? o1.Cell(:EMPLOYEE, 3)	#--> "Ali Sa"
o1.EraseCell(2, 3)
? @@( o1.Cell(2, 3) )	#--> NULL

/*==============

? o1.Cell(:EMPLOYEE, :LastRow)	#--> "Ali Aziza"

/*--------------

? o1.Cell(:FirsCol, :LastRow)
#--> ERR: Syntax error in (firscol)! Allowed values are
#	  :First or :Last (or :FirstCol or :LastCol).

/*--------------

? o1.FirstColName() #--> "id"
? o1.LastColName()  #--> "salary"

/*--------------

? o1.Col(:First) #--> [ 10, "Ali Sandy", 35000 ]
? o1.Col(:Last)  #--> [ 40, "Ali Aziza", 49540 ]

/*--------------

? o1.Row(:First) #--> [ 10, "Ali Sandy", 35000 ]
? o1.Row(:Last)  #--> [ 40, "Ali Aziza", 49540 ]

/*==============

? o1.FindCol(:SALARY) #--> 3
? o1.FindRow([ 20, "Dan Mikovitch Mo", 28900 ]) #--> 2

/*--------------

# Finding cells, in column :EMPLOYEE, made of the string "Ali Sa":
//? @@S( o1.FindInCol(:EMPLOYEE, "Ali Sa") ) #--> [ [2, 3] ]

# And we can be extremely expressive and say:
? o1.FindCellsInColumn(:EMPLOYEE, :MadeOf = "Ali Sa")

/*--------------
*/
//? @@S( o1.VerticalSectionAsPositions(:EMPLOYEE, 2, :LastRow) )
#--> [ [ 2, 2 ], [ 2, 3 ], [ 2, 4 ] ]

//? @@S( o1.VerticalSectionAsPositions(:EMPLOYEE, 2, :LastRow) )

/*--------------

? o1.CellAtPosition(2, 3) #--> "Ali Sa"

? o1.TheseCells([ [ 2, 2 ], [ 2, 3 ], [ 2, 4 ] ]) // Same as o1.CellsAt() and
					          // CellsAtPositions()
#--> [ "Dan Mikovitch Mo", "Ali Sa", "Ali Aziza" ]

/*==============

? @@S( o1.Col(:EMPLOYEE) )
#--> [ "Ali Sandy", "Dan Mikovitch Mo", "Ali Sa", "Ali Aziza" ]

/*--------------

? @@S( o1.ColXT(:EMPLOYEE) ) // Same as o1.CellsAndPositionsInCol(:EMPLOYEE)
			     // and o1.CellsInColXT(:EMPLOYEE)
#--> [
#	["Ali Sandy", 		[2, 1] ],
#	["Dan Mikovitch Mo", 	[2, 2] ],
#	["Ali Sa", 		[2, 3] ],
#	["Ali Aziza", 		[2, 4] ]
#    ]


/*--------------

? @@S( o1.CellsInCol(:EMPLOYEE) ) // same as Col(:EMPLOYEE)
#--> [ "Ali Sandy", "Dan Mikovitch Mo", "Ali Sa", "Ali Aziza" ]

? @@S( o1.CellsInColAsPositions(:EMPLOYEE) ) // same as ColAsPositions(:EMPLOYEE)
#--> [ [2, 1], [2, 2], [2, 3], [2, 4] ]

? @@S( o1.CellsInColXT(:EMPLOYEE) )
#--> [
#	[ "Ali Sandy", 		[2, 1] ],
#	[ "Dan Mikovitch Mo", 	[2, 2] ],
#	[ "Ali Sa", 		[2, 3] ],
#	[ "Ali Aziza", 		[2, 4] ]
#    ]

/*==============

? @@S( o1.Row(2) )
#--> [ 20, "Dan Mikovitch Mo", 28900 ]

/*--------------

? @@S( o1.RowXT(2) ) // Same as o1.CellsAndPositionsInRow(2)
		     // and o1.CellsInRowXT(2)
#--> [
#	[ 20, 			[ 1, 2 ] ],
#	[ "Dan Mikovitch Mo", 	[ 2, 2 ] ],
#	[ 28900, 		[ 3, 2 ] ]
#    ]

/*--------------

? @@S( o1.CellsInRow(2) ) + NL // same as Row(2)
#--> [ 20, "Dan Mikovitch Mo", 28900 ]

//? @@S( o1.CellsInRowAsPositions(2) ) + NL // same as RowAsPositions(2)
#--> [ [ 1, 2 ], [ 2, 2 ], [ 3, 2 ] ]

? @@S( o1.CellsInRowXT(2) )
#--> [
#	[ 20, 			[ 1, 2 ] ],
#	[ "Dan Mikovitch Mo", 	[ 2, 2 ] ],
#	[ 28900, 		[ 3, 2 ] ]
#    ]

/*==============

# Finding the cells, in column :EMPLOYEE, CONTAINING the substring "Ali":
? @@S( o1.FindInCellsInCol(:EMPLOYEE, "Ali") ) + NL
#--> [ [ 1 ], [ ], [ 1 ], [ 1 ] ]

? @@S( o1.FindInCellsInColXT(:EMPLOYEE, "Ali") )
#--> [
#	[ [ 1 ], [ 2, 1 ] ],
#	[ [ 1 ], [ 2, 3 ] ],
#	[ [ 1 ], [ 2, 4 ] ]
#    ]

/*==============

? o1.Cell(:EMPLOYEE, 2) #--> Dan Mikovitch Mo
? @@S( o1.FindInCell(:EMPLOYEE, 2, "Ali") ) #--> []
? @@S( o1.FindInCell(:EMPLOYEE, 2, "Mo") )  #--> [ 15 ]

/*--------------

// Finding a subvalue in a number of cells
? @@S( o1.FindInCells([ [2, 1], [1, 2], [2, 2], [2, 3] ], "Ali") )
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1 ] ]
#    ]

// Finding a subvalue inside the cells of a given column
? @@S( o1.FindInCells( o1.ColCellsAsPositions(:EMPLOYEE), "Ali" ) )
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1 ] ],
#	[ [ 2, 4 ], [ 1 ] ]
#    ]

// Same as above:
? @@S( o1.FindInCellsInColumn(:EMPLOYEE, "Ali") )

// Finding a suvalue inside the cells of a given row
? @@S( o1.FindInCells( o1.RowCellsAsPositions(3), "Ali" ) )
#--> [ [ [ 2, 3 ], [ 1 ] ] ]

// Same as above
? @@S( o1.FindInCellsInRow(3, "Ali") )

/*--------------

? o1.NumberOfOccurrenceInCellsInCol(:EMPLOYEE, "Ali") #--> 3
? o1.NumberOfOccurrenceInCellsInRow(3, "Ali") #--> 1

/*==============

? o1.FindCol(:SALARY) #--> 3

/*--------------

? @@S( o1.FindCell("Dan Mikovitch Mo") )
#--> [ [ 2, 2 ] ]

? @@S( o1.FindCell("Ali Sandy") )
#--> [ [ 2, 1 ] ]

/*--------------

o1 = new stzTable([
	:PALETTE1 = [ "Red",   "Blue",    "Blue", "White"  ],
	:PALETTE2 = [ "White",  "Red",   "Green",  "Gray"  ],
	:PALETTE3 = [ "Yellow", "Red", "Magenta",  "Black" ]
])

/*------------

? @@S( o1.FindAll("Red") )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

? @@S( o1.FindInCol(:PALETTE1, "Blue") )
#--> [ [ 1, 2 ], [ 1, 3 ] ]

? @@S( o1.FindInRow(2, "Red") ) 
#--> [ [ 2, 2 ], [ 2, 3 ] ]

/*------------

? @@S( o1.Section([1,2], [3,2]) )
#--> [ "Blue", "Red", "Red" ]

//? @@S( o1.SectionXT([1,2], [3,2]) )
#--> [
#	[ [ 1, 2 ], "Blue" ],
#	[ [ 2, 2 ], "Red"  ],
#	[ [ 3, 2 ], "Red"  ]
#    ]

? @@S( o1.SectionAsPositions([1,2], [3,2]) )
#--> [ [ 1, 2 ], [ 2, 2 ], [ 3, 2 ] ]

/*==========

? @@S( o1.FindInSection([1,2], [3,2], "Red") )
#--> [ [ 2, 2 ], [ 3, 2 ] ]

/*----------

? @@S( o1.SectionXT(:From = :FirstCell, :To = [3,2]) )
#--> [
#	[ [ 1, 1 ], "Red" 	],
#	[ [ 2, 1 ], "White" 	],
#	[ [ 3, 1 ], "Yellow" 	],
#	[ [ 1, 2 ], "Blue" 	],
#	[ [ 2, 2 ], "Red" 	],
#	[ [ 3, 2 ], "Red" 	]
#    ]

/*-----------

? @@S( o1.FindAllInSectionCS([1, 1], [3, 2], "red", :CS = TRUE) ) #--> []

? @@S( o1.FindAllInSectionCS([1, 1], [3, 2], "Red", :CS = TRUE) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

? @@S( o1.FindAllInSectionCS([1, 1], [3, 2], "red", :CS = FALSE) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

/*-----------

? o1.FindNthInSectionCS(2, :From = :FirstCell, :To = [3, 3], "red", :CS = FALSE) #--> [2, 2]
? o1.FindFirstInSection(:From = :FirstCell, :To = [3, 3], "Red") #--> [1, 1]
? o1.FindLastInSection(:From = :FirstCell, :To = [3, 3], "Red") #--> [3, 2]

/*==============

# REMINDER:
? @@S( o1.SectionXT(:From = [1,2], :To = [3,2]) )
#--> [
#	[ [ 1, 2 ], "Blue" 	],
#	[ [ 2, 2 ], "Red" 	],
#	[ [ 3, 2 ], "Red" 	]
#    ]

? @@S( o1.FindInCellsInSection([1,2], [3,2], "e") )
#--> [
#	[ [ 1, 2 ], [ 4 ] ],
#	[ [ 2, 2 ], [ 2 ] ],
#	[ [ 3, 2 ], [ 2 ] ]
#    ]

? @@S( o1.FindLastInCellsInSection([1,2], [3,2], "e") )
#--> [ [ 3, 2 ], [ 2 ] ]

/*=============

? @@S( o1.FindCells( "Red" ) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

# Same as:
? @@S( o1.FindAllOccurrences( :Of = "Red") )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

/*-----------

? o1.FindNthCell(1, "Red") #--> [ 1, 1 ]
? o1.FindNthCell(2, "Red") #--> [ 2, 2 ]
? o1.FindLastCell( "Red" ) #--> [ 3, 2 ]

/*-----------

? o1.NumberOfOccurrence( :Of = "Red" ) #--> 3
? o1.NumberOfOccurrenceInCol( :PALETTE2, :Of = "Red" ) #--> 1
? o1.NumberOfOccurrenceInRow( 2, :Of = "Red" ) #--> 2

/*-----------

? @@S( o1.Col(2) ) #--> [ "White", "Red", "Green", "Gray" ]

/*-----------

? o1.HasColName("PALETTE2") #--> TRUE
//? o1.HasColNames([ "PALETTE1", "PALETTE3" ]) #--> TRUE

/*-----------

? @@S( o1.Cols() )
#--> [ "palette1", "palette2", "palette3" ]

/*==========

o1.AddCol( :PALETTE4 = [ "Magenta", "Blue", "White", "Red" ])

? @@S( o1.Cols() )
#--> [ "palette1", "palette2", "palette3", "palette4" ]

? o1.HasColName(:PALETTE4) #--> TRUE

? @@S( o1.Col(:PALETTE4) )
#--> [ "Magenta", "Blue", "White", "Red" ]

o1.RemoveCol(:PALETTE4)
? @@S( o1.Cols() )
#--> [ "palette1", "palette2", "palette3" ]

/*----------

? o1.ColToColName(2) 	 #--> "palette2"
? o1.ColToColName(:PALETTE2) #--> "palette2"

? o1.TheseColsToColNames([3, :PALETTE1, 2])
#--> [ "palette3", "palette1", "palette2" ]

/*----------

? o1.ColToColNumber(2) 	 #--> 2
? o1.ColToColNumber(:PALETTE2) #--> 2

? o1.TheseColsToColsNumbers([:PALETTE3, :PALETTE1, 2])
#--> [ 3, 1, 2 ]

/*----------

? o1.Show()
#-->
#	#   PALETTE1   PALETTE2   PALETTE3
#	1        Red      White     Yellow
#	2       Blue        Red        Red
#	3       Blue      Green    Magenta
#	4      White       Gray      Black


o1.EraseCol(2)
? o1.Show()
#-->
#	#   PALETTE1   PALETTE2   PALETTE3
#	1        Red                Yellow
#	2       Blue                   Red
#	3       Blue               Magenta
#	4      White                 Black


o1.EraseCols([3 ,1])
? o1.Show()
#	#   PALETTE1   PALETTE2   PALETTE3
#	1                                 
#	2                                 
#	3                                 
#	4                                 

/*----------

? o1.Show()
#-->
#	#   PALETTE1   PALETTE2   PALETTE3
#	1        Red      White     Yellow
#	2       Blue        Red        Red
#	3       Blue      Green    Magenta
#	4      White       Gray      Black

o1.EraseRow(2)
? o1.Show()
#-->
#	#   PALETTE1   PALETTE2   PALETTE3
#	1        Red      White     Yellow
#	2                                 
#	3       Blue      Green    Magenta
#	4      White       Gray      Black

o1.EraseRows([3, 1])
? o1.Show()
#-->
#	#   PALETTE1   PALETTE2   PALETTE3
#	1                                 
#	2                                 
#	3                                 
#	4      White       Gray      Black

/*----------

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

? o1.Show()
#-->
#	#   PALETTE1   PALETTE2   PALETTE3
#	1                                 
#	2                                 
#	3                                 
#	4      White       Gray      Black

/*----------

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
? o1.Show()
#-->
#	#   COL1
#	1       
#	2       
#	3       
#	4       

/*==========

o1 = new stzTable([
	:ID	  = [ 10, 	20, 	30 	],
	:EMPLOYEE = [ "Ali", 	"Dan",	"Ben"	],
	:SALARY   = [ 35000, 	28900, 	25982	]
])

? @@S( o1.Rows() ) + NL
#--> [
#	[ 10, "Ali", 35000 ],
#	[ 20, "Dan", 28900 ],
#	[ 30, "Ben", 25982 ]
#    ]

o1.AddRow( [ 40, "Mo", 12800 ] )

? @@S( o1.Rows() )
#--> [
#	[ 10, "Ali", 35000 ],
#	[ 20, "Dan", 28900 ],
#	[ 30, "Ben", 25982 ],
#	[ 40, "Mo" , 12800 ]
#    ]

/*==========

o1 = new stzTable([
	:ID	  = [ 10, 	20, 	30 	],
	:EMPLOYEE = [ "Ali", 	"Dan",	"Ben"	],
	:SALARY   = [ 35000, 	28900, 	25982	]
])

/*----------

? o1.Show()
/*
#   ID   EMPLOYEE   SALARY
1   10        Ali    35000
2   20        Dan    28900
3   30        Ben    25982
*/

/*----------

o1.AddCol( :TEMPO = [ NULL, NULL, NULL, NULL ])
#--> ERROR: Incorrect number of cells! paColNameAndData must contain extactly 3 cells.

/*----------

o1.AddCol( :TEMPO = [ NULL, NULL, NULL ])
? o1.LastColName()  #--> "tempo"
? @@S(o1.LastCol()) #--> [ "", "", "" ]

/*----------

o1.AddCols([
	:ONES = [ 1, 1, 1 ],
	:TWOS = [ 2, 2, 2 ]
])

? @@S( o1.Cols() )
#--> [ "id", "employee", "salary", "ones", "twos" ]

? @@S( o1.TheseColumns([ :ONES, :TWOS ]) )
#--> [ [ "ones", [ 1, 1, 1 ] ], [ "twos", [ 2, 2, 2 ] ] ]

/*==========

o1.Show()
#-->
#	#   ID   EMPLOYEE   SALARY
#	1   10        Ali    35000
#	2   20        Dan    28900
#	3   30        Ben    25982

? @@S( o1.SubTable([ :EMPLOYEE, :SALARY ]) ) + NL
#--> [
#	[ "employee", [ "Ali", "Dan", "Ben" ] ],
#	[ "salary"  , [ 35000, 28900, 25982 ] ]
#    ]

? o1.SubTableQR([ :EMPLOYEE, :SALARY ], :stzTable).Show()
#-->
#	#   EMPLOYEE   SALARY
#	1        Ali    35000
#	2        Dan    28900
#	3        Ben    25982

/*-----------

? @@S(o1.CellsAsPositions())
#--> [
#	[ 1, 1 ], [ 2, 1 ], [ 3, 1 ],
#	[ 1, 2 ], [ 2, 2 ], [ 3, 2 ],
#	[ 1, 3 ], [ 2, 3 ], [ 3, 3 ]
# ]

/*-----------

o1 = new stzTable([
	:ID	  = [ 10, 	20, 	   30 	 ],
	:EMPLOYEE = [ "Ali", 	"Dania",   "Han" ],
	:SALARY   = [ 35000, 	28900, 	   25982 ]
])

//o1.Show()
#-->
#	#   ID   EMPLOYEE   SALARY
#	1   10        Ali    35000
#	2   20      Dania    28900
#	3   30        Ben    25982

/*====================================================================================

? o1.Contains( :Cell = "Ali" )	 #--> TRUE	(same as ? o1.ContainsCell("Ali"))
? o1.Contains( :SubValue = "a" ) #--> TRUE	(same as ? o1.ContainsSubValue("a"))
	
/*-------------

? @@S( o1.FindCell("Ali") )
#--> [ [ 2, 1 ] ]
#--> One occurrence of "Ali" in the cell [2, 1]

? @@S( o1.FindSubValue("a") )
#--> [
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 3 ], [ 2 ]    ]
#    ]
#--> 3 occurrences of "a":
#	- 2 occurrences in cell [2, 2] ("Dania"), in positions 2 and 5, and
#	- 1 occurrence in cell [2, 3] ("Han"), in position 2

/*-------------

? @@S( o1.FindNth(1, :Cell = "Ali") ) #--> [2, 1]
# Same as ? @@S( o1.FindFirst( :Cell = "Ali" ) )

? @@S( o1.FindNthCS(3, :SubValue = "A", :CS = FALSE) )
#--> [ [ 2, 2 ], 5 ]
#--> 2nd occurrence of "A" (or "a") found in the cell [2, 2] ("Dania") in position 5

? @@S( o1.FindFirstCS(:SubValue = "A", :CS = FALSE) ) #--> [ [ 2, 1 ], 1 ]

? @@S( o1.FindLastCS(:SubValue = "A", :CS = FALSE) ) #--> [ [ 2, 3 ], 2 ]

/*-------------

? o1.Count( :Values = "Ali" ) #--> 1
	# Same as o1.Count( :Cells = "Ali" )
	# or: ? o1.NumberOfOccurrence( :OfCell = "Ali" )
	# or: ? o1.CountOfCell( "Ali" )
	# or: ? o1.CountOfValue("Ali")

/*-------------

? o1.Count( :SubValues = "a" ) #--> 3
? o1.CountCS( :SubValues = "A", :CaseSensitive = FALSE ) #--> 4

/*-------------

? Q(:Cells = "Ali").IsOneOfTheseNamedParams([ :OfCell, :Cells ]) #--> TRUE

/*=============

? @@S( o1.TheseCellsAndTheirPositions([ [1,2], [2,2], [2,3] ]) )
#--> [ [ 20, [ 1, 2 ] ], [ "Dania", [ 2, 2 ] ], [ "Han", [ 2, 3 ] ] ]

/*-------------

? @@S( o1.TheseCells([ [1,2], [2,2], [2,3] ]) )
#--> [ 20, "Dania", "Ben" ]

? @@S( o1.FindInCells( [ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [ [2, 2] ]

? @@S( o1.FindInCells( [ [1,2], [2,2], [2,3] ], :SubValue = "a" ) )
#--> [
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 3 ], [ 2 ]    ]
#    ]
#--> There are 3 occurrences of "a" in the specified cells:
#	- 2 occurrences in the cell [2, 2] ("Dania"), in positions 2 and 5, and
#	- 1 occurrence in cell [2, 3] ("Han"), in position 2.

/*-------------

o1 = new stzTable([
	:ID	  = [ 10, 	20, 	   30 	 ],
	:EMPLOYEE = [ "Ali", 	"Dania",   "Han" ],
	:SALARY   = [ 35000, 	28900, 	   25982 ]
])

? @@S( o1.FindNthInCells( 1, [ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [2, 2]

? @@S( o1.FindNthInCells( 1, [ [1,2], [2,2], [2,3] ], :Value = "blabla" ) )
#--> []

? @@S( o1.FindNthInCells( 2, [ [1,2], [2,2], [2,3] ], :SubValue = "a" ) )
#--> [ [ 2, 2 ], 5 ]
// Sames as: ? o1.FindNthSubValueInCells( 2, [ [1,2], [2,2], [2,3] ], "a" ) )

? @@S( o1.FindFirstInCells([ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [ 2, 2 ]

? @@S( o1.FindLastInCells([ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [ 2, 2 ]

/*-------------

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

# Let's take this selection of cells
aMyCells = [ [2,1], [2,3], [2,4] ]
# And get them along with their positions:
? @@S( o1.TheseCellsXT( aMyCells ) )
#--> [ [ "Ali", [ 2, 1 ] ], [ "Han", [ 2, 3 ] ], [ "Ali", [ 2, 4 ] ] ]

# How many cell made of the value "Ali" does exist in those cells?
? o1.CountInCells( aMyCells, :Value = "Ali" )  #--> 2
# Where do they exist exactly:
? @@S( o1.FindInCells( aMyCells, :Value = "Ali" ) )
#--> [ [ 2, 1 ], [ 2, 4 ] ]

# How many subvalue "A" does exist in the same list of cells?
? o1.CountInCells( aMyCells, :SubValue = "A" ) #--> 2
# How many subvalue "A" whatever case it has?
? o1.CountInCellsCS( aMyCells, :SubValue = "A", :CS = FALSE ) #--> 3
# And where do they exist exactly?
? @@S( o1.FindInCellsCS( aMyCells, :SubValue = "A", :CS = FALSE ) )
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 2 ] ],
#	[ [ 2, 4 ], [ 1 ] ]
#    ]

/*-------------

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

? o1.CellsContain( [ [2,1], [2,3], [2,4] ], :Cell = "Ali" )
#--> TRUE	(same as ? o1.CellsContain("Ali"))

? o1.CellsContain( [ [2,1], [2,3], [2,4] ], :SubValue = "a" )
#--> TRUE	(same as ? o1.CellsContainSubValue("a"))

? o1.CountInCells( [ [2,1], [2,3], [2,4] ], :Cell = "Ali" ) #--> 2

? o1.CountInCellsCS( [ [2,1], [2,3], [2,4] ], :SubValue = "a", :CS = FALSE ) #--> 3

/*-------------
*/
o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

? o1.Count( :Cells = "Ali" ) #--> 2
	# Same as NumberOfOccurrence( :OfCell = "Ali" )
	# Or you can say: ? o1.CountOfCell( "Ali" )

? @@S( o1.FindCell("Ali") ) + NL
#--> [ [ 2, 1 ], [2, 4] ]
#--> One occurrence of "Ali" in the cell [2, 1]

? @@S( o1.FindSubValue("a") ) + NL
#--> [
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 3 ], [ 2 ] ]
#    ]
#--> There are 3 occurrences of of "a" in the table:
#	--> 2 occurrences in cell [2, 2] ("Dania"), in the 2nd and 5th chars.
#	--> 1 occurrence in cell [2, 3] ("Han"), in position 2.

? @@S( o1.FindSubValueCS("a", :CaseSensitive = FALSE) ) + NL
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 3 ], [ 2 ] ],
#	[ [ 2, 4 ], [ 1 ] ]
#    ]

? o1.CountCS( :SubValue = "a", :CS= FALSE ) #--> 5

#--> five occurrences of "A" (or "a"):
#	- one occurrence in the cell [2, 1] ("Ali") at the 1st char
#	- two occurrences in the cell [2, 2] ("Dania") at the 2nd and 5th chars
#	- one occurrence in the cell [2, 3] ("Han") at the 2nd char
#	- one occurrence in the cell [2, 4] ("Ali") at the 1st char


#-------------
/*
? o1.Count( :SubValues = "a" ) #--> 2
? o1.CountCS( :SubValues = "A", :CaseSensitive = FALSE ) #--> 3

	/*============
	
	? o1.ColQ(:EMPLOYEE).Contains( :Cell = "Ali" )
	
	? o1.ColContains(:EMPLOYEE, :Cell = "Ali")
	? o1.ColContains(:EMPLOYEE, :SubValue = "a")
		
		? o1.ColContainsCell( :EMPLOYEE, "Ali")
		? o1.ColContainsSubValue( :EMPLOYEE, "a")
	
	? o1.FindInCol(:EMPLOYEE, :TheCell = "Ali")
	? o1.FindInCol(:EMPLOYEE, :TheSubValue = "Ali")
	
		? o1.FindCellInCol(:EMLOYEE, "Ali")
		? o1.FindSubValueInCol(:EMPLOYEE, "a")
	
	? o1.NumberOfOccurrenceInCol(:EMPLOYEE, :OfCell = "Ali")
	? o1.NumberOfOccurrenceInCOl(:EMPLOYEE, :OfSubValue = "a")
		? o1.NumberOfOccurrenceOfCellInCol(:EMLOYEE, "Ali")
		? o1.NumberOfOccurrenceInCellsInCol(:EMPLOYEE, :Of = "a")
	
	/*--------
	# SAME FOR: COL, ROW, SECTION, and CELLS!
	/*--------


	# As part of the semantics of stzTable, "Contains" is used only when
	# you want to check for subvalues inside cells and NOT for cells values
	# themselves. Keep this in mind to avoid confusion!
	
	# The fellowing wil clarify the point to you.
	
	# When we need to check wether the column cells CONTAIN the subvalue "a",
	# then we sipmply sya:
	? o1.ColContains(:EMPLOYEE, "a") + NL #--> TRUE
	
	# If you wander how to find the positions of the subvalue "a"
	# INSIDE the cells of the column :EMPLOYEE, and you say:
	
	? @@S( o1.FindInCol(:EMPLOYEE, "a") ) + NL	#--> []
	
	# You get nothing! Meaning that the column contains no cells that
	# are EQUAL to "a". In fact, FindInCol() looks for an ENTIRE value
	# of a cell and not for a part of it.
	
	# You can verify this by feeding it with an entire cell value, like
	# "Dania" for example. In this case, you get its position as the 2nd
	# cell in col 2:
	
	? @@S( o1.FindInCol(:EMPLOYEE, "Dania") ) + NL	#--> [2, 2]
	
	# Now, inorder for you to find any occurrences of the substring "a"
	# INSIDE the cells of the column, you should be precise and
	# add the ...InCells...() speciffier to the function like this:
	
	? @@S( o1.FindInCellsInCol(:EMPLOYEE, "a") ) + NL
	#--> [
	#	[ [ 2, 2 ], [ 2, 5 ] ]
	#    ]
	#--> The column contains the substring "a" in two positions
	# inside the cell [2, 2] corresponding the string "Dania":
	# 2nd and 5th position!
	
	# Of course, you could find any letter "A" whatever case it is
	# written in (lowercase or uppercase):
	? @@S( o1.FindInCellsInColCS(:EMPLOYEE, "a", :CaseSensitive = FALSE) )
	#--> [
	#	[ [ 2, 1 ], [ 1    ] ],
	#	[ [ 2, 2 ], [ 2, 5 ] ]
	#    ]
	
/*--------

# Finding the occurrence of a subvalue inside the column cells
? @@S( o1.FindInCellsInCol(:EMPLOYEE, "a") )
#--> [
#	[ [2, 2], [ 2, 5 ] ]
#    ]
#--> In cell [2, 2], there are two "a"s at positions 2 and 5

? @@S( o1.FindInCellsInColCS(:EMPLOYEE, "a", :CS = FALSE) )
#--> [
#	[ [ 2, 1 ], [ 1    ] ],
#	[ [ 2, 2 ], [ 2, 5 ] ]
#    ]
#--> Case sensitity apart, there are 3 "A"s:
#	- one in cell [2, 1] at position 1 (first char in "Ali"), and
#	- two in cell [2, 2] at position 2 and 5 (2nd and 5th chars in "Dania")

/*--------



