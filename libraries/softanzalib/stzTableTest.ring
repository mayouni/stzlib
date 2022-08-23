load "stzlib.ring"

aMyTable = 
[
	[    :ID,	:EMPLOYEE ,        :SALARY ],

	[    101,	"Ali Sandy" ,      35000   ],
	[    294,	"Dan Mikov" ,      12890   ],
	[    307,	"Aziza Ali" ,      5200    ]
]

o1 = new stzTable(aMyTable)

/*------------
*/
o1.Show()
#-->
# #	ID	EMPLOYEE	SALARY
# 1	101	Ali Sandy	35000
# 2	294	Dan Mikov	12890
# 3	307	Aziza Pen	5200

/*------------

? o1.NumberOfCol() 	#--> 3
? o1.NumberOfLines()	#--> 3
? o1.NumberOfCells()	#--> 9

/*------------

? o1.Cell(2, 3) #--> "Aziza Ali"

/*============

? o1.Col(3) # only data, without header
#--> [ 35000, 12890, 5200 ]

? o1.ColXT(3) # with the header
#--> [ "SALARY", 35000, 12890, 5200 ]

/*------------

? o1.Col("EMPLOYEE")
#--> [ "Ali Sandy", "Dan Mikov", "Aziza Pen" ]

? o1.ColXT("EMPLOYEE")
#--> [ "EMPLOYEE", "Ali Sandy", "Dan Mikov", "Aziza Pen" ]

/*=============

? o1.Line(3) # only data, without header
#--> [ 307, "Aziza Ali", 5200 ]

? o1.Line([ 307, "Aziza Ali", 5200 ])
#--> 3

/*=============
*/
? o1.FindInCol(2, "Ali")
#--> [ [2, 1], [2, 3] ]

? o1.FindInCol(:EMPLOYEE, "Ali")
#--> [ [2, 1], [2, 3] ]

? @@S(o1.FindIn("Ali")) # !--> [ [2, 1], [2, 3] ]


/*
? o1.FindCell("Dan Mikov") # !--> [2, 2]
? o1.FindInCell( [2, 2], "Mikov" ) #--> 5

? o1.FindCol(:EMPLOYEE) #--> 2
? o1.FindInCol(:EMPLOYEE, "Mikov") # !--> [2, 2]

? o1.FindLine([ 307, "Aziza Pen", 5200 ]) #--> 3
? o1.FindInLine(3, "Aziza") # !--> [ 2, 3]
