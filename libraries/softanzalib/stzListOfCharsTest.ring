load "stzlib.ring"

? StzListOfCharsQ("A":"E").IsContinuous() # --> TRUE
? StzListOfCharsQ("1":"5").IsContinuous() # --> TRUE
? StzListOfCharsQ("ا":"ي").IsContinuous() # --> TRUE

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
