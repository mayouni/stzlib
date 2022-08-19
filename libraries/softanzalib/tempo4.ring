load "stzlib.ring"

/*====================

o1 = new stzString("1234567890")
? @@S( o1.Split( :at = 5) )
#--> [ "1234", "67890" ]

? @@S( o1.Split( :at = [3, 7] ) )
#--> [ "12", "456", "890" ]

? @@S( o1.Split( :before = 5 ) )
#--> [ "1234", "567890" ]

? @@S( o1.Split( :before = [3, 7] ) )
#--> [ "12", "3456", "7890" ]

? @@S( o1.Split( :after = 5 ) )
#--> [ "12345", "67890" ]

? @@S( o1.Split( :after = [3, 7] ) )
#--> [ "123", "4567", "890" ]

? @@S( o1.Split( :ToPartsOfNItems = 3 ) )
#--> [ "123", "456", "789", "0" ]

? @@S( o1.Split( :ToPartsOfExactlyNItems = 3 ) )
#--> [ "123", "456", "789" ]

? @@S( o1.Split( :ToNParts = 4 ) )
# --> [ "12", "34", "56", "7890" ]

/*================

o1 = new stzString("ONE_TWO")
? @@S( o1.SplitAt(4) )	# or SplitAtPosition(4)
#--> [ "ONE", "TWO" ]

o1 = new stzString("ONE_TWO_THREE")
? @@S( o1.SplitAt([ 4, 8 ]) ) # or SplitAtPositions([4, 8])
#--> [ "ONE", "TWO", "THREE" ]

/*------------------

o1 = new stzString("ONE_TWO")
? @@S( o1.SplitBefore(4) ) # or SplitBeforePosition(4)
#--> [ "ONE", "_TWO" ]

o1 = new stzString("ONE_TWO_THREE")
? @@S( o1.SplitBefore([ 4, 8 ]) ) # or SplitBeforePositions([ 4, 8 ])
#--> [ "ONE", "_TWO", "_THREE" ]

/*------------------

o1 = new stzString("ONE_TWO")
? @@S( o1.SplitAfter(4) ) # or SplitAfterPosition(4)
#--> [ "ONE_", "TWO" ]

o1 = new stzString("ONE_TWO_THREE")
? @@S( o1.SplitAfterPositions([ 4, 8 ]) ) # or SplitAfterPositions([ 4, 8 ])
#--> [ "ONE_", "TWO_", "THREE" ]

/*==================

o1 = new stzString("ABCDE")
? @@S( o1.SplitToNParts(5) )
#--> [ "A", "B", "C", "D", "E" ]

o1 = new stzString("AB12CD34")
? @@S( o1.SplitToPartsOfNChars(2) )
# --> [ "AB", "12", "CD", "34" ]

o1 = new stzString("ABC123DEF456")
? @@S( o1.SplitToPartsOfNChars(3))
#--> [ "ABC", "123", "DEF", "456" ]

o1 = new stzString("ABCD1234EF")
? @@S( o1.SplitToPartsOfNChars(4))
#--> [ "ABCD", "1234", "EF" ]

? @@S( o1.SplitToPartsOfExactlyNChars(4))
#--> [ "ABCD", "1234" ]

/*===================

? Q(0).IsMultipleOf(3) #--> FALSE

/*------------------
*/
o1 = new stzString("123456789012")
? @@S( o1.SplitW( 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "12", "45", "78", "012" ]

? @@S( o1.SplitW( :Where = 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "12", "45", "78", "012" ]

? @@S( o1.SplitW( :At = 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "12", "45", "78", "012" ]

? @@S( o1.SplitAtW( :Where = 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "12", "45", "78", "012" ]

? @@S( o1.SplitAtW( 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "12", "45", "78", "012" ]

/*------------------

o1 = new stzString("__3__6__9__")

? @@S( o1.SplitW( :Before = 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__", "3__", "6__", "9__" ]

? @@S( o1.SplitBeforeW( 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__", "3__", "6__", "9__" ]

? @@S( o1.SplitBeforeW( :Where = 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__", "3__", "6__", "9__" ]

/*------------------

o1 = new stzString("__3__6__9__")

? @@S( o1.SplitW( :After = 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

? @@S( o1.SplitAfterW( 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]

? @@S( o1.SplitAfterW( :Where = 'Q(0+@char).IsMultipleOf(3)' ) )
#--> [ "__3", "__6", "__9", "__" ]
