Load "softanzalib.ring"

# The samples in this file have beed added to stzListTest.ring
# --> We can securly remove the current file from the project

/*---------------------

o1 = new stzList(1:5)
o1.AddItemAt(7, -1)
? o1.Content() # --> [ 1, 2, 3, 4, 5, 0, 0, -1 ]

/*---------------------

o1 = new stzList("A":"E")
o1.AddItemAt(7,"X")
? o1.Content() # --> [ "A", "B", "C", "D", "E", NULL, NULL, "X" ]

/*---------------------

# finding positions where current item is equal or bigger than 8

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])
? o1.ItemsWhere( '{ @item >= 8 }' ) # --> [ 8, 11, 11, 10, 8, 8 ]

/*---------------------

# Finding positions where current item is one of these [ 2, 4, 6 ]

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])
? o1.FindWhere( '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }' )  # --> [ 1, 3, 5, 8, 9, 12, 16 ]
? o1.ItemsWhere( '{ Q(@item).IsOneOfThese([ 2, 4, 6]) }' ) # --> [ 2, 2, 2, 4, 2,  2, 6  ]

/*---------------------

# Finding positions where next itrem is double of precedent item
o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])
? o1.FindW( '{ Q( This[@i+1] ).IsDoubleOf( This[@i-1] ) }' ) # --> [ 8, 11 ]

/*---------------------

# Finding positions where current item is equal to next item
o1 = new stzList([ 2, 8, 2, 2, 11, 2, 11, 7, 7, 4, 2, 1, 3, 2, 10, 8, 3, 3, 3, 6, 8 ])
? o1.FindW( '{ @item = This[@i+1] }' ) # --> [ 3, 0, 17, 18 ]

/*---------------------

# Finding positions where current item is equal to next item

o1 = new stzList([ "A", "B", "B", "C", "D", "D", "D", "E" ])
? o1.FindWhere('{ This[@i] = This[@i+1] }') # --> [ 2, 5, 6 ]

/*---------------------

# Finding positions where previous 3rd item is equal to next 3rd item

o1 = new stzList( [ 0, 8, 0, 0, 1, 8, 0, 0 ] )
? o1.FindW('{ This[ @i - 3 ] = This[ @i + 3 ] }') # --> 4
