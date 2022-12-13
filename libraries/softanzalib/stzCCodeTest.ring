load "stzlib.ring"

/*----------
*/
Q('{ This[ @i - 3 ] = This[ @i + 3 ] }') {

	? NumberComingAfter("@i -")
	? NumberComingAfter("@i +")
}

/*----------

o1 = new stzCCode('{ This[ @i - 3 ] = This[ @i + 3 ] }')
? o1.ExecutableSection()
#--> [ 4, nLen - 3 ]


/*----------

o1 = new stzCCode('{ @item = @PreviousItem + 1 }')
o1.UnifyFor(:stzListOfNumbers)
? o1.Content()
#--> '@number = This[ @i-1 ] + 1'

/*----------

o1 = new stzCCode('{ @number = -@number }')
o1.UnifyFor(:stzListOfStrings)
? o1.Content()
#--> '@string = - @string'

/*----------

o1 = new stzCCode('Q(@eachchar).IsUppercase()')
o1.UnifyFor(:stzListOfNumbers)
? o1.Content()
#--> 'Q( @number ).IsUppercase()'

/*----------

o1 = new stzCCode('{ This.ItemAt(@NextPosition) = This.ItemAt(@CurrentPosition) + "O" }')
o1.UnifyFor(:stzList)
? o1.Content()
#--> This[ @i+1 ] = This[ @i ] + "O"

/*----------

o1 = new stzCCode('{ Q(CharAt(@NextPosition)).HasDifferentCaseAs(CharAt(@CurrentPosition) ) }')
o1.UnifyFor(:stzString)
? o1.Content()
#--> Q(This[ @i+1 ]).HasDifferentCaseAs(This[ @i ] )


