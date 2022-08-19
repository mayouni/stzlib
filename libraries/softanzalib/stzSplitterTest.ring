load "stzlib.ring"

o1 = new stzSplitter(1:10)

/*====================

? @@S( o1.Split( :at = 5) )
#--> [ [1, 4], [6, 10] ]

? @@S( o1.Split( :at = [3, 7] ) )
#--> [ [ 1, 2 ], [ 4, 6 ], [ 8, 10 ] ]

? @@S( o1.Split( :before = 5 ) )
#--> [ [ 1, 4 ], [ 5, 10 ] ]

? @@S( o1.Split( :before = [3, 7] ) )
#--> [ [ 1, 2 ], [ 3, 6 ], [ 7, 10 ] ]

? @@S( o1.Split( :after = 5 ) )
#--> [ [ 1, 5 ], [ 6, 10 ] ]

? @@S( o1.Split( :after = [3, 7] ) )
#--> [ [ 1, 3 ], [ 4, 7 ], [ 8, 10 ] ]

? @@S( o1.Split( :ToPartsOfNItems = 3 ) )
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ], [ 10, 10 ] ]

? @@S( o1.Split( :ToPartsOfExactlyNItems = 3 ) )
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ] ]

? @@S( o1.Split( :ToNParts = 4 ) )
# --> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 10 ] ]

/*==================

? @@S( o1.SplitAt(5) )
#--> [ [ 1, 4 ], [ 6, 10 ] ]

? @@S( o1.SplitAt([ 3, 7 ]) )
#--> [ [ 1, 2 ], [ 4, 6 ], [ 8, 10 ] ]

/*------------------

? @@S( o1.SplitBefore(5) )
#--> [ [ 1, 4 ], [ 5, 10 ] ]

? @@S( o1.SplitBefore([ 3, 6, 8]) )
#--> [ [ 1, 2 ], [ 3, 5 ], [ 6, 7 ], [ 8, 10 ] ]

/*------------------

? @@S( o1.SplitAfter(5) )
#--> [ [ 1, 5 ], [ 6, 10 ] ]

? @@S( o1.SplitAfter([ 3, 6, 8]) )
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 8 ], [ 9, 10 ] ]

/*==================

? @@S( o1.SplitToNParts(2) )
#--> [ [ 1, 5 ], [ 6, 10 ] ]

/*
? @@S( o1.SplitToPartsOfNPositions(2) )
# --> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ], [ 9, 10 ] ]

? @@S( o1.SplitToPartsOfNPositions(3) )
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ], [ 10, 10 ] ]

? @@S( o1.SplitToPartsOfExactlyNPositions(3) )
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ] ]

o1 = new stzSplitter(12)
? @@S( o1.SplitToPartsOfNPositions(5) )
#--> [ [ 1, 5 ], [ 6, 10 ], [ 11, 12 ] ]

? @@S( o1.SplitToPartsOfExactlyNPositions(5) )
#--> [ [ 1, 5 ], [ 6, 10 ] ]

/*==================
*/
# Softanza is designed with Programmer Experience in mind.

# We all forget a function syntax and how parameters should
# be organized. We could make a trial or two before that
# hopefully works. Or we interrup the programming process
# and turn to documentation to get help...

# To avoid that, Softanza usually incorporates many alternatives
# of the same function. This allows it to be flexible and permissive:
# Whatever comes to your mind expressing your intent, the library
# will do its best to understood it and execute it!

# All the following formlations lead to the same result:
# splitting at a some positions given by a conditional expression...

? @@S( o1.SplitW( 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

? @@S( o1.SplitW( :Where = 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

? @@S( o1.SplitW( :At = 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

? @@S( o1.SplitAtW( :Where = 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

? @@S( o1.SplitAtW( 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

/*------------------

? @@S( o1.SplitW( :Before = 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 3, 5 ], [ 6, 8 ], [ 9, 10 ] ]

? @@S( o1.SplitBeforeW( 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 3, 5 ], [ 6, 8 ], [ 9, 10 ] ]

? @@S( o1.SplitBeforeW( :Where = 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 3, 5 ], [ 6, 8 ], [ 9, 10 ] ]

/*------------------

? @@S( o1.SplitW( :After = 'Q(@position).IsMultipleOf(3)' ) )
#--> 

? @@S( o1.SplitAfterW( 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ], [ 10, 10 ] ]

? @@S( o1.SplitAfterW( :Where = 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ], [ 10, 10 ] ]

/*==================

? @@S( o1.SplitToNParts(4) )
# --> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 10 ] ]

/*==================

? @@S( o1.GetPairsFromPositions([3, 6, 8]) )
# --> [ [ 1, 3 ], [ 3, 6 ], [ 6, 8 ], [ 8, 10 ] ]


