load "stzlib.ring"


/*-----------------
*/
o1 = new stzListOfChars([ "1", "2", "♥", "4", "5", "♥", "7", "8", "♥" ])

? o1.FindAll("♥")
#--> [3, 6, 9]

# Note: the following functions work the same for stzString, 
# stzList, and stzListOfStrings, because they are abstracted in stzObject

? o1.NFirstOccurrences(2, :Of = "♥") 
#--> [3, 6]

? o1.NFirstOccurrencesXT(2, :Of = "♥", :StartingAt = 1)
#--> [3, 6]

? o1.NLastOccurrences(2, :Of = "♥")
#--> [6, 9]

? o1.NLastOccurrencesXT(2, "♥", :StartingAt = 1)
#--> [6, 9]

? o1.NFirstOccurrencesXT(2, :Of = "♥", :StartingAt = 6)
#--> [6, 9]

? o1.LastNOccurrencesXT(2, :Of = "♥", :StartingAt = 10)
#--> [6, 9]

/*----------------

? StzListOfCharsQ("A":"E").IsContiguous() # --> TRUE
? StzListOfCharsQ("1":"5").IsContiguous() # --> TRUE
? StzListOfCharsQ('"ا":"ج"').IsContiguous() #--> TRUE	TODO: ERROR!

/*-------------

o1 = new stzListOfChars([ "a", "b", "c" ])
? o1.Unicodes()

? CharsUnicodes([ "a", "b", "c" ])

/*-------------

SetHilightChar("♥")

? StzListOfCharsQ("TEXT").BoxedXT([
	:Line = :Thin,	# or :Dashed
		
	:AllCorners = :Round, # can also be :Rectangualr

	# Or you can specify evey corner like this:
	:Corners = [ :Round, :Rectangular, :Round, :Rectangular ],

	:Hilighted = [ 3 ] # The 3rd char is hilighted
		
])

#-->
# ╭───┬───┬───┬───┐
# │ T │ E │ X │ T │
# └───┴───┴─♥─┴───╯

/*-------------

? StzListOfCharsQ("A":"E").BoxedXT([
	:AllCorners = :Round,
	:Hilighted = [0, 2, 5, 3, 7],
	:Numbered = TRUE

])

#-->
# ╭───┬───┬───┬───┬───╮
# │ A │ B │ C │ D │ E │
# ╰───┴─♥─┴─♥─┴───┴─♥─╯
#   1   2   3   4   5 

/*-------------

? StzListOfCharsQ("A":"E").BoxedXT([ :Line = :Dashed, :AllCorners = :Round ])

# -->
# ╭╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌╮
# ┊ A ┊ B ┊ C ┊ D ┊ E ┊
# ╰╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌╯

/*-------------

? StzListOfCharsQ("SOFTANZA").Boxed()
# -->
# ┌───┬───┬───┬───┬───┬───┬───┬───┐
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# └───┴───┴───┴───┴───┴───┴───┴───┘

/*-------------

? StzListOfCharsQ(@('"ا":"ج"')).BoxedXT([ :Line = :Dashed, :AllCorners = :Round ])

/*-------------

? StzListOfCharsQ("منصوريات").Boxed()
#-->
# ┌───┬───┬───┬───┬───┬───┬───┬───┐
 # │ م │ ن │ ص │ و │ ر │ ي │ ا │ ت │  
# └───┴───┴───┴───┴───┴───┴───┴───┘
