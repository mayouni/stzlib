load "stzlib.ring"

/*------------

aMyTable = 
[
	[    :ID,	:EMPLOYEE ,       :SALARY ],

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
*/

aMyTable = 
[
	[    :ID,	:EMPLOYEE ,       :SALARY  ],

	[    101,	"Ali Sandy",      35000	   ],
	[    294,	"Dan Mikov",      12890    ],
	[    287,	"Ali Sandy",      1069     ],
	[    307,	"Ali Aziza",      5200	   ]
]

o1 = new stzTable(aMyTable)

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
*/
? o1.FindInColumn(:EMPLOYEE, "Ali Sandy")

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
