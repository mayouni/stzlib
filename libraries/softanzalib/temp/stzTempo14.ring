load "stzlib.ring"

/*----------------------

o1 = new stzList(1:39)
? @@(o1.SplitBeforePositions( [ 1, 3, 8, 10 ] ))
# --> [ [ 1, 2 ], [ 3, 7 ], [ 8, 9 ], [ 10, 39 ] ]

/*----------------------

o1 = new stzList("A":"J")

? o1.SplitBeforePositions([3,7])
# --> [ [ "A", "B" ], [ "C", "D", "E", "F" ], [ "G", "H", "I", "J" ] ]

/*----------------------
*/
o1 = new stzString("NoWomanNoCry")
nPos = o1.FindCharsW('Q(@char).IsUppercase()')
? o1.SplitBeforePositions(nPos)
# --> [ "No", "Woman", "No", "Cry" ]


