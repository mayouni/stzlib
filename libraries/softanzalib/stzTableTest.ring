load "stzlib.ring"
/*
aMyTable = 
[
	[    "ID",	"EMPLOYEE" ,     	"SALARY" ],

	[    10,	"Ali Sandy",      	35000   ],
	[    20,	"Dan Mikovitch Mo",  	28900   ],
	[    30,	"Ali Sa",         	25982   ],
	[    40,	"Ali Aziza",      	49540   ]
]
*/

o1 = new stzTable([
	:ID	  = [ 10, 20, 30, 40 ],
	:EMPLOYEE = [ "Ali Sandy", "Dan Mikovitch Mo", "Ali Sa", "Ali Aziza" ],
	:SALARY   = [ 35000, 28900, 25982, 49540 ]
])

/*--------------

? @@S( o1.SectionAsPositions([2, 2], [3, 3]) ) + NL
#--> [ [ 2, 2 ], [ 3, 2 ], [ 2, 3 ], [ 3, 3 ] ]

/*--------------

@@S(o1.Section([2, 2], [3, 3])) + NL
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

/*--------------

? o1.NumberOfColumns() #--> 3

/*--------------

? o1.HasCol(:EMPLOYEE) #--> TRUE

/*--------------

? o1.ColNames() #--> [ "id", "employee", "salary" ]

/*--------------

? o1.ColName(2) #--> "employee"

/*--------------

? @@S( o1.Cell(2, 2) )	#--> "Dan Mikovitch Mo"

? o1.Cell(:EMPLOYEE, 2)	#--> "Dan Mikovitch Mo"

? @@S( o1.Cell(5, 7) )	#--> ERR: Array Access (Index out of range) ! 

/*--------------

? o1.NumberOfRows()	#--> 4
? o1.NumberOfCols()	#--> 3
? o1.NumberOfCells()	#--> 12

/*--------------

? @@S( o1.Header() ) + NL
#--> [ "id", "employee", "salary" ]

o1.AddCol(:AGE = [ 55, 35, 28, 65 ])
? @@S( o1.Content() )
#--> [
#	[ "id", [ 10, 20, 30, 40 ] ],
#	[ "employee", [ "Ali Sandy", "Dan Mikovitch Mo", "Ali Sa", "Ali Aziza" ] ],
#	[ "salary", [ 35000, 28900, 25982, 49540 ] ],
#	[ "age", [ 55, 35, 28, 65 ] ]
# ]


/*--------------

? o1.IsEmpty() #--> FALSE


/*--------------

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

/*--------------

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

/*--------------

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

/*--------------

? @@S( o1.Cols() )
/*--> [ "id", "employee", "salary" ]

/*-----------

? o1.FindCol(:SALARY) #--> 3
? o1.FindRow([ 20, "Dan Mikovitch Mo", 28900 ]) #--> 2
 
/*-----------

? @@S( o1.MaxSizeInEachCol() )
#--> [ 2, 16, 5 ]

? @@S( o1.MaxSizeInEachColXT() )
#--> [ 1, 2, 16, 5 ]

?  @@S( o1.MaxSizeInEachRow() )
#--> [ 9, 16, 6, 9 ]

? o1.HeaderToString()
#--> "#   id           employee   salary"

/*-----------

? o1.MaxSizeInCol("EMPLOYEE") #--> 16
? o1.MaxSizeInRow(3) #--> 6

/*-----------

? @@S( o1.Col(3) ) # Same as  o1.ColData(3), o1.Col(:SALARY), and o1.ColData(:SALARY)
#--> [ 35000, 28900, 25982, 49540 ]

/*-----------

? o1.ColName(3) #--> salary

/*------

? @@S( o1.SubTable([ :ID, :SALARY ]) ) // Same as o1.TheseColumnsXT([1, 2])
#--> [
#	[ "id", 	[ 10, 20, 30, 40 ] 		],
#	[ "salary", 	[ 35000, 28900, 25982, 49540 ] 	]
# ]
/*-----------

? o1.ColNumbersToNames([1, 3])
#--> [ "id", "salary" ]

/*-----------

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

/*-----------

? o1.TheseColNames([1, 2]) #--> [ "id", "employee" ]

/*-----------

? Q(["", "", ""]).AllItemsAreNull() #--> TRUE

/*-----------

? o1.IsEmpty() #--> FALSE
o1.Erase()
? @@S( o1.Content() )

#--> [
#	[ "id", 	[ NULL, NULL, NULL, NULL ] ],
#	[ "employee", 	[ NULL, NULL, NULL, NULL ] ],
#	[ "salary", 	[ NULL, NULL, NULL, NULL ] ]
# ]

? o1.IsEmpty() #--> TRUE

/*-----------
*/
? o1.Cell(:EMPLOYEE,3)	#--> "Ali Sa"
o1.EraseCell(2, 3)
? @@( o1.Cell(2, 3) )	#--> NULL



















/*------------

aMyTable = 
[
	[    "ID",	"EMPLOYEE" ,       "SALARY" ],

	[    101,	"Ali Sandy",      35000	   ],
	[    294,	"Dan Mikov",      12890    ],
	[    307,	"Ali Aziza",      [ 5200 ] ],
	[    598,	"Dan Mikov",      18923    ],
	[    600,	[ "A", 1:3 ],	  [ 1, 2, 3 ]]
]

o1 = new stzTable(aMyTable)

/*------------

o1.Show()

#-->
# #	ID	EMPLOYEE	SALARY
# 1	101	Ali Sandy	35000
# 2	294	Dan Mikov	12890
# 3	307	Aziza Pen	5200

/*------------

? o1.NumberOfCol() 	#--> 3
? o1.NumberOfLines()	#--> 5
? o1.NumberOfCells()	#--> 15

/*------------

? @@S( o1.Cells() )
#--> [
#	101, "Ali Sandy", 35000,
#	294, "Dan Mikov", 12890,
#	307, "Aziza Ali", 5200,
#	598, "Dan Mikov", 18923
# ]

/*------------

? @@S( o1.CellsXT() )
#--> [
#	[ 101, 		[ 1, 1 ] ],
#	[ "Ali Sandy", 	[ 2, 1 ] ],
#	[ 35000, 	[ 3, 1 ] ],
#	[ 294, 		[ 1, 2 ] ],
#	[ "Dan Mikov", 	[ 2, 2 ] ],
#	[ 12890, 	[ 3, 2 ] ],
#	[ 307, 		[ 1, 3 ] ],
#	[ "Aziza Ali", 	[ 2, 3 ] ],
#	[ 5200, 	[ 3, 3 ] ],
#	[ 598, 		[ 1, 4 ] ],
#	[ "Dan Mikov", 	[ 2, 4 ] ],
#	[ 18923, 	[ 3, 4 ] ]
# ]

/*------------

? @@S( o1.CellsToHashList() )
#--> [
#	[ "[ 1, 1 ]", 101 ],
#	[ "[ 2, 1 ]", "Ali Sandy" ],
#	[ "[ 3, 1 ]", 35000 ],
#	[ "[ 1, 2 ]", 294 ],
#	[ "[ 2, 2 ]", "Dan Mikov" ],
#	[ "[ 3, 2 ]", 12890 ],
#	[ "[ 1, 3 ]", 307 ],
#	[ "[ 2, 3 ]", "Aziza Ali" ],
#	[ "[ 3, 3 ]", 5200 ],
#	[ "[ 1, 4 ]", 598 ]
#	[ "[ 2, 4 ]", "Dan Mikov" ],
#	[ "[ 3, 4 ]", 18923 ]
# ]

/*------------

? o1.CellsToHashList()[ '[ 2, 2 ]' ] #--> "Dan Mikov"
? o1.CellsToHashList()[ '[ 2, 3 ]' ] #--> "Aziza Ali"

/*------------

? o1.Cell(2, 3) #--> "Aziza Ali"

/*============

? o1.Col(3) # only data, without header
#--> [ 35000, 12890, 5200, 18923 ]

? o1.ColXT(3) # with the header
#--> [ "SALARY", 35000, 12890, 5200, 18923 ]

/*------------

? o1.Col("EMPLOYEE")
#--> [ "Ali Sandy", "Dan Mikov", "Aziza Ali", "Dan Mikov" ]

? o1.ColXT("EMPLOYEE")
#--> [ "EMPLOYEE", "Ali Sandy", "Dan Mikov", "Aziza Ali", "Dan Mikov" ]

/*=============

? o1.Line(3) # only data, without header
#--> [ 307, "Aziza Ali", 5200 ]

? o1.Line([ 307, "Ali Aziza", [ 5200 ] ]) #--> 3

/*=============

? o1.FindCellsInCol(2, "Dan Mikov") #--> [ [2, 2], [2, 4] ]
? o1.FindCellsInCol(:EMPLOYEE, [ "A", [ 1, 2, 3 ] ]) #--> [ [2, 5] ]

/*-----------

? o1.FindCol(:SALARY) #--> 3
? o1.FindLine([598, "Dan Mikov", 18923]) #--> 4

/*------------

? @@S( o1.FindCellsInLine(2, "Dan Mikov" ) ) #--> [ [ 2, 2 ] ]
? @@S( o1.FindCellsInLine(3, [ 5200 ]) ) #--> [ [ 3, 3 ] ]

/*-----------

? o1.FindCells("Dan Mikov")  #--> [ [2, 2], [2, 4] ]

/*-----------

? o1.FindNthCell(1, "Dan Mikov") #--> [2, 2]
? o1.FindNthCell(2, "Dan Mikov") #--> [2, 4]

? o1.FindCell("Dan Mikov") 	 #--> [2, 2]
? o1.FindFirstCell("Dan Mikov")  #--> [2, 2]
? o1.FindLastCell("Dan Mikov") #--> [2, 4]

/*-----------

? o1.NumberOfOccurrence( :Of = "Dan Mikov" ) #--> 2
? o1.NumberOfOccurrenceInCol( :EMPLOYEE, :Of = "Dan Mikov" ) #--> 2
? o1.NumberOfOccurrenceInLine( 2, :Of = "Dan Mikov" ) #--> 1

/*-----------


aMyTable = 
[
	[    "ID",	"EMPLOYEE" ,     "SALARY"  ],

	[    101,	"Ali Sandy",      350008   ],
	[    294,	"Dan Mikov",      128900   ],
	[    287,	"Ali Sandy",      106902   ],
	[    307,	"Ali Aziza",      520054   ]
]

o1 = new stzTable(aMyTable)
? o1.Col(2)
/*-----------

? o1.HasColName("EMPLOYEE") #--> TRUE
? o1.HasColNames([ "EMPLOYEE", "SALARY" ]) #--> TRUE

/*-----------

? @@S( o1.Cols() )
#--> [ "ID", "EMPLOYEE", "SALARY" ]

/*-----------

o1.AddCol( "JOB", [ "Programmer", "Author", "Painter", "Doctor" ])
? @@S( o1.Cols() )
? @@S( o1.Col("JOB") )
#--> [ "Programmer", "Author", "Painter", "Doctor" ]

o1.Show()
#-->
# #	ID	EMPLOYEE	SALARY	JOB
# 1	101	Ali Sandy	350008	Programmer
# 2	294	Dan Mikov	128900	Author
# 3	287	Ali Sandy	106902	Painter
# 4	307	Ali Aziza	520054	Doctor

/*-----------

? o1.SubTable([ :EMPLOYEE, :SALARY ])

STOP()
/*-----------

? @@S(o1.CellsAsPositions())
#--> [
#	[ 1, 1 ], [ 2, 1 ], [ 3, 1 ],
#	[ 1, 2 ], [ 2, 2 ], [ 3, 2 ],
#	[ 1, 3 ], [ 2, 3 ], [ 3, 3 ],
#	[ 1, 4 ], [ 2, 4 ], [ 3, 4 ] 
# ]

/*-----------

? @@S( o1.FindInCell(2, 1, "Ali") ) #--> [ 1 ]

/*-----------

? @@S( o1.FindInCellsXT([ [2,1], [2,4] ], "Ali") )
#--> [ [ 1 ], [ 1 ] ]

? @@S( o1.FindInCellsXT([ [2,1], [2,4] ], "Ali") )
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 4 ], [ 1 ] ]
#]

/*-----------

? @@S( o1.FindInCellsInSection([2,1], [2,4], "Ali") )
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1 ] ],
#	[ [ 2, 4 ], [ 1 ] ]
#    ]

/*-----------

? @@S( o1.FindInCellsInSectionXT([2,1], [2,4], "Ali") )
#--> [
#	[ "[ 2, 1 ]", [ 1 ] ],
#	[ "[ 2, 3 ]", [ 1 ] ],
#	[ "[ 2, 4 ]", [ 1 ] ]
#    ]

/*-----------

? o1.FindInColumn("EMPLOYEE", "Ali Sandy")

/*-----------

? o1.FindInCellsInColumn(:EMPLOYEE, "Ali")

/*-----------

? @@S(o1.Cells()) + NL
#--> [
#	101, "Ali Sandy", 35000,
#	294, "Dan Mikov", 12890,
#	287, "Ali Sandy", 1069,
#	307, "Ali Aziza", 5200
# ]

/*-----------

? @@S(o1.Section([2, 2], [3, 4]))
#--> [ "Dan Mikov", 12890, "Ali Sandy", 1069, "Ali Aziza", 5200 ]

? @@S( o1.SectionXT([2, 2], [3, 4]) )
#--> [
#	[ [ 2, 2 ], "Dan Mikov" ],
#	[ [ 3, 2 ], 12890 ],
#	[ [ 2, 3 ], "Ali Sandy" ],
#	[ [ 3, 3 ], 1069 ],
#	[ [ 2, 4 ], "Ali Aziza" ],
#	[ [ 3, 4 ], 5200 ]
# ]

? @@S( o1.SectionAsPositions([2, 2], [3, 4]))
#--> [ [ 2, 2 ], [ 3, 2 ], [ 2, 3 ], [ 3, 3 ], [ 2, 4 ], [ 3, 4 ] ]

/*-----------

o2 = new stzGrid( o1.SectionToHashList([2, 2], [3, 4]) )
? o2.Show()
#--> [
#	[ "[ 2, 2 ]", "Dan Mikov" ],
#	[ "[ 3, 2 ]", 12890 ],
#	[ "[ 2, 3 ]", "Ali Sandy" ],
#	[ "[ 3, 3 ]", 1069 ],
#	[ "[ 2, 4 ]", "Ali Aziza" ],
#	[ "[ 3, 4 ]", 5200 ]
# ]

? @@S( o2.VLine(1) )
#--> [ "[ 2, 2 ]", "[ 3, 2 ]", "[ 2, 3 ]", "[ 3, 3 ]", "[ 2, 4 ]", "[ 3, 4 ]" ]

/*-----------

? o1.FindInSection([2, 1], [3, 4], "Ali Sandy") #--> [ [2, 1], [2, 3] ]
# Same as FindCellsInSection()

/*-----------

? o1.CellContains(2, 4, "Aziza") #--> TRUE
? o1.FindInCell(2, 4, "Aziza") #--> [ 5 ]

/*-----------

? @@S( o1.FindInCellsInSection([2, 1], [3, 4], "Ali") )
