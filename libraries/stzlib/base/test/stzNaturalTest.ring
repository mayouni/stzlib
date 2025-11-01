load "../stzbase.ring"

/*---
*/
pr()

o1 = Naturally()
o1 {
  Create a fantastic string with "Softanza ♥ Ring"
  @Box it
  The box@ should be rounded
  Display the result
}
#-->
'
╭─────────────────╮
│ Softanza ♥ Ring │
╰─────────────────╯
'

? @@Nl( o1.Tokens() )

pf()
# Executed in 0.12 second(s) in Ring 1.24

/*--- Getting the result of computation without display
*/
pr()

Nt = Naturally()

Nt {
    Create a stzString with "test.data"
    
    Replace "." with "_"
    Uppercase it

}
#--> TEST_DATA

# You can dissmiss "Show it" and get the result
# of the computation and do whatever you want with

? Nt.Result()
#--> TEST_DATA

? Nt.Code() + NL
#-->
'
oStr = StzStringQ("test.data")
oStr.Replace(".", "_")
oStr.Uppercase()
@result = oStr.Content()
'

pf()
# Executed in 0.12 second(s) in Ring 1.24

/*---

pr()

Naturally() {
    Create a string with "hello niger" inside
    Uppercase it spacify it and_ @box it
    The box@ should be rounded
    Display the final result
}
#•-->
'
╭───────────────────────╮
│ H E L L O   N I G E R │
╰───────────────────────╯
'

pf()
#--> Executed in 0.10 second(s) in Ring 1.24

/*---

pr()

o1 = new stzString("__Ri__ng__")
? o1.@("__").
    @RemoveItQ().
    AndThenQ().
    UppercaseQ().TheString()

    #--> RING

pf()
# Executed in 0.04 second(s) in Ring 1.23

/*---

pr()

? Box("SOFTANZA")
'
┌──────────┐
│ SOFTANZA │
└──────────┘
'

? BoxRound("SOFTANZA")
'
╭──────────╮
│ SOFTANZA │
╰──────────╯
'
? Box(Box("SOFTANZA"))
'
┌──────────────┐
│ ┌──────────┐ │
│ │ SOFTANZA │ │
│ └──────────┘ │
└──────────────┘
'

? BoxDash("SOFTANZA")
'
┌╌╌╌╌╌╌╌╌╌╌┐
┊ SOFTANZA ┊
└╌╌╌╌╌╌╌╌╌╌┘
'

? BoxDashRound("SOFTANZA")
'
╭╌╌╌╌╌╌╌╌╌╌╮
┊ SOFTANZA ┊
╰╌╌╌╌╌╌╌╌╌╌╯
'

? BoxChars("SOFTANZA")
'
╭───┬───┬───┬───┬───┬───┬───┬───╮
│ S │ O │ F │ T │ A │ N │ Z │ A │
╰───┴───┴───┴───┴───┴───┴───┴───╯
'

? BoxRoundChars("SOFTANZA")
'
╭───┬───┬───┬───┬───┬───┬───┬───╮
│ S │ O │ F │ T │ A │ N │ Z │ A │
╰───┴───┴───┴───┴───┴───┴───┴───╯
'

? BoxDashChars("SOFTANZA")
'
┌╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┐
┊ S ┊ O ┊ F ┊ T ┊ A ┊ N ┊ Z ┊ A ┊
└╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┘
'
? BoxRoundDashChars("SOFTANZA")
'
╭╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌╮
┊ S ┊ O ┊ F ┊ T ┊ A ┊ N ┊ Z ┊ A ┊
╰╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌╯
'

? StzListOfCharsQ("TEXT").BoxXT([
	:Line = :Solid,	# or :Dashed

	:AllCorners = :Round, # can also be :Rectangualr

	# Or you can specify evey corner like this:
	# :Corners = [ :Round, :Rectangular, :Round, :Rectangular ],

	:Hilighted = [ 1, 3 ] # The 3rd char is hilighted

])

'
╭───┬───┬───┬───╮
│ T │ E │ X │ T │
╰─•─┴───┴─•─┴───╯	
'

pf()
# Executed in 0.22 second(s) in Ring 1.23

/*--- OBJECT CREATION VARIATIONS

pr()
Nt = Naturally()

Nt {
    Make a string containing "world"
    Display it
}
#--> world

pf()
# Executed in 0.07 second(s) in Ring 1.23

/*--- BASIC TRANSFORMATIONS

pr()

Nt = Naturally()

Nt {
    Create a string with "softanza"
    Uppercase it
    Display the result
}
#--> SOFTANZA

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- CHAINED OPERATIONS

pr()

Naturally() {
    Create a string with "ring language"
    Uppercase it and_ spacify it
    Show it
}
#--> R I N G   L A N G U A G E

pf()
# Executed in 0.07 second(s) in Ring 1.24

/*--- BOXING WITH OPTIONS

pr()

Naturally() {
    Create a string with "boxed text"
    Uppercase it spacify it and_ @box it
    The box@ should be rounded
    Display the final result
}
#--> ╭─────────────────────╮
#    │ B O X E D   T E X T │
#    ╰─────────────────────╯

pf()
# Executed in 0.10 second(s) in Ring 1.24

/*--- TRIMMING OPERATIONS

pr()

o1 = Naturally() {
    Make a string with "  spaced text  "
    Trim it and_ uppercase it
    Display the result
}
#--> SPACED TEXT

? ""
? o1.Code()
#-->
'
oStr = StzStringQ("  spaced text  ")
oStr.Trim()
oStr.Uppercase()
? oStr.Content()
'

pf()
# Executed in 0.10 second(s) in Ring 1.24

/*--- REVERSE OPERATIONS

pr()

Naturally() {
    Create a string with "STRESSED"
    Reverse it
    Show the result
}
#--> DESSERTS

pf()
# Executed in 0.08 second(s) in Ring 1.24

/*--- CASE TRANSFORMATIONS

pr()

Naturally() {
    Make a string with "MiXeD cAsE"
    Lowercase it
    Replace "mixed" with "lower"
    Show it
}
#--> lower case

pf()
# Executed in 0.08 second(s) in Ring 1.24

/*--- REFERENCE VARIATIONS

pr()

Naturally() {
    Make a string with "reference test"

    Uppercase this_
    Spacify that
    Box this_

    Show the final result
}
#--> ┌─────────────────────────────┐
#    │ R E F E R E N C E   T E S T │
#    └─────────────────────────────┘

pf()
# Executed in 0.10 second(s) in Ring 1.24

/*--- #todo #Narration

pr()

# To simulate realworld writing style, add punctuations between ''

Nt = Naturally() {
    Make a string with "Softanza ♥ Ring" inside '.'

    Uppercase it ',' spacify it ',' and then @box it '.'
    The box@ must be rounded '!'

    You knwow what ':' @Box it again_ '!'
    Yes ',' this_ second box@ must also be rounded '.'

    Show the final result '...'
}
#-->
'
╭───────────────────────────────────╮
│ ╭───────────────────────────────╮ │
│ │ S O F T A N Z A   ♥   R I N G │ │
│ ╰───────────────────────────────╯ │
╰───────────────────────────────────╯
'

? NL + Nt.Code()
#-->
'
oStr = StzStringQ("Softanza ♥ Ring")
oStr.Uppercase()
oStr.Spacify()
oStr.BoxXT([:Rounded = 1])
oStr.BoxXT([:Rounded = 1])
? oStr.Content()
'

pf()
# Executed in 0.09 second(s) in Ring 1.24

/*--- CONNECTOR VARIATIONS

pr()

Naturally() {
    Make a string with "test"
    Uppercase it then_ spacify it then_ box it
    Display the result
}
#--> ┌─────────┐
#    │ T E S T │
#    └─────────┘

pf()
# Executed in 0.09 second(s) in Ring 1.24

/*--- ALTERNATIVE CONNECTORS

pr()

Naturally() {
    Create a string containing "softanza"
    Uppercase it plus spacify it plus box it
    Show the result
}
#--> ┌─────────────────────┐
#    │ C O N N E C T O R S │
#    └─────────────────────┘

pf()
# Executed in 0.09 second(s) in Ring 1.24

/*--- SUBSTITUTE OPERATION

pr()

o1 = Naturally()
//o1.EnableDebug()

o1 {
    Make a string with "old text old"
    Substitute "old" with "new"
    Display it
}
#--> new text new

pf()
# Executed in 0.08 second(s) in Ring 1.23

/*--- CHANGE OPERATION

pr()

Naturally() {
    Create a string with "change me"
    Change "me" to_ "this"
    Show the result
}
#--> change this

pf()
# Executed in 0.10 second(s) in Ring 1.23

/*--- MULTIPLE MODIFIERS

pr()

Naturally() {
    Create a string with "softanza is great"
    Uppercase it using spacify and_ also @box it # @ to reference the box later
    The box@ must be rounded # @ to recall the box reference before
    Show the final result
}
#--> ╭───────────────────────────────────╮
#    │ S O F T A N Z A   I S   G R E A T │
#    ╰───────────────────────────────────╯

pf()
# Executed in 0.09 second(s) in Ring 1.23

/*--- FRAME ALTERNATIVE

pr()

Naturally() {
    Make a string containing "natural"
    Uppercase it and_ spacify it
    @Frame it then_ the frame@ should have rounded corners
    Display the result
}
#-->
'
╭───────────────╮
│ N A T U R A L │
╰───────────────╯
'

pf()
# Executed in 0.10 second(s) in Ring 1.23

/*--- PRINT ALTERNATIVE

pr()

Naturally() {
    Create a string with "print test"
    Uppercase it
    Print the result
}
#--> PRINT TEST

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- COMPLEX CHAINING

pr()

Naturally() {
    Create a string with "train of thoughts"
    Uppercase it and_ spacify it
    Then @box it with box@ having rounded corners
    Also show the final result
}
#--> ╭───────────────────────────────────╮
#    │ T R A I N   O F   T H O U G H T S │
#    ╰───────────────────────────────────╯

pf()
# Executed in 0.10 second(s) in Ring 1.23

/*--- COMMAND CHAINING

pr()

Naturally() {
    Create a string with "goodbye world"
    Replace "goodbye" with "hello"
    Uppercase it
    Show it
}
#--> HELLO WORLD

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*--- MULTIPLE PARAMETER CONSUMPTION

pr()

Naturally() {
    Create a string with "ONE two three"
    Replace "two" with "TWO"
    Replace "three" with "THREE" 
    Show it
}
#--> ONE TWO THREE

pf()
# Executed in 0.08 second(s) in Ring 1.23

/*--- DEFINE/RECALL STATE CLEANUP (technical test)

pr()

Naturally() {
    Create a string with "test"
    @box
    Uppercase it
    box@
    Show it
}
#--> ┌──────┐
#    │ TEST │
#    └──────┘

pf()
# Executed in 0.08 second(s) in Ring 1.23

/*--- MULTIPLE DEFINE/RECALL CYCLES (technical test)

pr()

Naturally() {
    Create a string with "hello"
    @box
    box@
    @uppercase
    uppercase@
    Show it
}
#--> ┌───────┐
#    │ HELLO │
#    └───────┘

pf()
# Executed in 0.08 second(s) in Ring 1.23

/*---

pr()

# You can't use "it" as a value for object creation
# or any other ignored keyword (in @aWordsToIgnore)
# and if you do you will get it replaced by "":

o1 = Naturally() {
    Create a string with "it" # NO! Don't use any ignored keyword as a value! 
    Box it rounded
    Show it
}
#--> ╭──╮
#    │  │
#    ╰──╯

? o1.Code()
#-->
'
oStr = StzStringQ("")
oStr.Box()
? oStr.Content()
'

pf()
# Executed in 0.08 second(s) in Ring 1.23

/*--- METHOD ALIAS RESOLUTION

pr()

Naturally() {
    Create a string with "test"
    Caps it
    Show it
}
#--> TEST

pf()
# Executed in 0.07 second(s) in Ring 1.23

/*---

pr()

o1 = Naturally() {
    Create a string with "Hello World"
    Lowercase it
    Capitalize it
    Display it

}
#--> Hello World

? ""
? o1.Code()
#-->
# oStr = StzStringQ("Hello World")
# oStr.Lowercase()
# oStr.Capitalize()
# ? oStr.Content()

pf()
# Executed in 0.08 second(s) in Ring 1.23

/*--- EMPTY VALUE PROTECTION

pr()

o1 = Naturally() {
    Create a string with ""
    Uppercase it
    Show it
}
#--> ""

? o1.Code()
# oStr = StzStringQ("")
# ? oStr.Content()

pf()
# Executed in 0.08 second(s) in Ring 1.23

/*--- NULL VALUE HANDLING #ERR #Idem

pr()

Naturally() {
    Create a string with nothing
    Spacify it
    Box it
    Show it
}
#--> 
# ┌──┐
# │  │
# └──┘

pf()
# Executed in 0.08 second(s) in Ring 1.23

/*--- DEBUG MODE TESTING

pr()

Nt = Naturally()
Nt.EnableDebug()
Nt {
    Create a string with "test"
    NonExistentMethod it
    Show it
}

? @@NL( Nt.DebugLog() )
#-->
# [
# 	[
# 		[ "timestamp", 3307 ],
# 		[ "message", "Method: BraceEnd()" ]
# 	],
# 	[
# 		[ "timestamp", 3307 ],
# 		[ "message", "Starting processing" ]
# 	],
# 	[
# 		[ "timestamp", 3307 ],
# 		[ "message", "Raw values received: 5 items" ]
# 	],
# 	[
# 		[ "timestamp", 3308 ],
# 		[ "message", "Method: ConvertToSemanticTokens()" ]
# 	],
# 	[
# 		[ "timestamp", 3308 ],
# 		[ "message", "Converting to semantic tokens" ]
# 	],
# 	[
# 		[ "timestamp", 3308 ],
# 		[
# 			"message",
# 			"Semantic: 'create' -> CREATE_OBJECT"
# 		]
# 	],
# 	[
# 		[ "timestamp", 3308 ],
# 		[
# 			"message",
# 			"Semantic: 'string' -> OBJECT_STRING"
# 		]
# 	],
# 	[
# 		[ "timestamp", 3308 ],
# 		[ "message", "Literal: 'test'" ]
# 	],
# 	[
# 		[ "timestamp", 3308 ],
# 		[ "message", "Literal: 'nonexistentmethod'" ]
# 	],
# 	[
# 		[ "timestamp", 3308 ],
# 		[
# 			"message",
# 			"Semantic: 'show' -> OUTPUT_DISPLAY"
# 		]
# 	],
# 	[
# 		[ "timestamp", 3308 ],
# 		[ "message", "Method: Process()" ]
# 	],
# 	[
# 		[ "timestamp", 3308 ],
# 		[ "message", "Semantic tokens created: 5 tokens" ]
# 	],
# 	[
# 		[ "timestamp", 3309 ],
# 		[ "message", "Generated Ring code:" ]
# 	],
# 	[
# 		[ "timestamp", 3309 ],
# 		[
# 			"message",
# 			'oStr = StzStringQ("test")
# ? oStr.Content()'
# 		]
# 	]
# ]

pf()
# Executed in 0.08 second(s) in Ring 1.23

/*--- CLEARING DEBUG LOG

pr()

Nt = Naturally()
Nt.EnableDebug()
Nt {
    BadMethod it
}

# Before clear
? len(Nt.DebugLog())
#--> 10

Nt.ClearDebugLog()

# After clear
? len(Nt.DebugLog())
#◙--> 0

pf()
# Executed in 0.07 second(s) in Ring 1.24

/*--- Multiple boxing of a string

/*---

pr()

o1 = Naturally()
o1 {
    Make a string with "i ♥ niamey"
    @box it ~ Spacify it ~ and_ Uppercase it

    the box@ must be rounded

    @box it again_ 
    yet this_ second box@ should be rounded as well
 
    Display the result
}

#-->
'
╭─────────────────────────╮
│ ╭─────────────────────╮ │
│ │ I   ♥   N I A M E Y │ │
│ ╰─────────────────────╯ │
╰─────────────────────────╯
'

pf()
# Executed in 0.12 second(s) in Ring 1.24

#-----------------------------#
#  MULTILINGUAL NUTURAL CODE  #
#-----------------------------#

/*--- NATURAL CODE IN ENGLISH

pr()

Naturally() {

	Make a string with "hello niger" inside
	Spacify it and_ uppercase it
	@Box it while_ the box@ is rounded
	Display it on_ the screen
	Thank you very mutch

}
#-->
'
╭───────────────────────╮
│ H E L L O   N I G E R │
╰───────────────────────╯
'

pf()
# Executed in 0.10 second(s) in Ring 1.24

/*--- NATURAL CODE IN HAUSA LATIN SCRIPT (BOKO)

pr()

o1 = NaturallyIn("hausa")
o1 {

	Yi rubutu da dauke "hello niger" a ciki 
	Raba shi kuma maida shi
	@Akwati shi kuma wannan akwati@ dole zagaye
	Nuna shi a kan allo
	Na gode susai
}
#-->
'
╭───────────────────────╮
│ H E L L O   N I G E R │
╰───────────────────────╯
'

# For your information:
#	Make 	--> Yi
#	String 	--> Rubuti
#	With 	--> Dauke
#	Raba 	--> Spacify
#	Maida 	--> Uppercase
#	Box 	--> Akwati
#	Rounded --> Zagaye

# To inspect the internal Ring code generated by Softanza
? o1.Code()
#-->
'
oStr = StzStringQ("hello niger")
oStr.Spacify()
oStr.Uppercase()
oStr.BoxXT([:Rounded = 1])
? oStr.Content()
'

pf()
# Executed in 0.06 second(s) in Ring 1.24

/*---  NATURAL CODE IN HAUSA ARABIC SCRIPT (AJAMI)

pr()

o1 = NaturallyIn("hausa-ajami")

o1 {

    يي روْبُتُ دا ɗوكي "hello niger" ا چِكِ		
  رب شي كوما ميّرد شي	     
  @اَكْوَتِ شي كوما وَنَّن اَكْوَتِن@ دُولِ زَغَيِ	    
    نُوْنَ شي اَ كَنْ اَلّو	    

}

? o1.Code()
#-->
'
╭───────────────────────╮
│ H E L L O   N I G E R │
╰───────────────────────╯
oStr = StzStringQ("hello niger")
oStr.Spacify()
oStr.Uppercase()
oStr.BoxXT([:Rounded = 1])
? oStr.Content()
'

pf()
# Executed in 0.06 second(s) in Ring 1.24

# For your information:
#	Make --> "يي"
#	String --> "روْبُتُ"
#	With --> "ɗوكي"
#	Raba --> "رب"
#	Maida --> "ميّرد"
#	Box --> "اَكْوَتِن"
#	Rounded --> "زَغَيِ"

pf()
# Executed in 0.06 second(s) in Ring 1.24
