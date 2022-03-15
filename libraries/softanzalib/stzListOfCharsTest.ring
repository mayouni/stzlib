load "stzlib.ring"

/*

o1 = new stzListOfChars([ "a", "b", "c" ])
? o1.Unicodes()

? CharsUnicodes([ "a", "b", "c" ])

/*-------- TODO: CHECK ERROR -> See same problem in stzListTest.ring file
*/
SetHilightChar("♥")

? StzListOfCharsQ("TEXT").BoxedXT([
	:Line = :Thin,	# or :Dashed
		
	:AllCorners = :Round # can also be :Rectangualr

	# Or you can specify evey corner like this:
	# :Corners = [ :Round, :Rectangular, :Round, :Rectangular ],

	# :Hilighted = [ 3 ] # The 3rd char is hilighted
		
])

/*
? StzListOfCharsQ("A":"E").BoxedXT([
	:AllCorners = :Round,
	:Hilighted = [0, 2, 5, 3, 7],
	:Numbered = TRUE

])

/*
? StzListOfCharsQ("ا":"ج").BoxedXT([ :Line = :Dashed, :AllCorners = :Round ])

? stzListOfCharsQ("منصوريات").Boxed()
*/
