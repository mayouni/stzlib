
load "../stzbase.ring"


/*---

pr()

o1 = Naturally("
    Create {number} with {100} inside
    Increment it
    Show it
")
#--> 101

? o1.Code()
? @@NL( o1.Tokens() )

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*---
*/
pr()

Naturally('
    Create a @{+list:fruits~} with {["banana", "apple", "cherry"]}@ inside.
    {Sort} it then {Uppercase} it.

    @{Box~2} it using these Options: {rounded:true} and {hashed:true}@

    {Show} it

     Create an other {+list} and leave it empty.
     fill it with the content of the {first:list}.

     @{Erase} that {fruits:list}@.
     Show it.

     Show the {second:list}.

')
#-->
# APPLE
# BANANA
# CHERRY

# Softana NML (Natural Markup Language)

{+fruits:list ~1} {~1 ["banana", "apple", "cherry"]}
{?name}
{?count}
{boxXT-0it ~2} {~1 rounded=true} {~2 hashed=true}
{show-0it}

{+list}
{fill-it-with ~1} {~1 first:list..content}

{erase} {fruits:list}
{show-0it}

{^joinXT ~2} {~1 second:list} {~2 " "}
{?0what-0is-0its-type}
{show-0it} 

pf()

/*---
*/
pr()

Yesterday I thought about {+fruits:list ~1} and came up with {~1 ["banana", "apple", "cherry"]}.
What did I call them? {?name}
How many are there? {?count}

Actually, let me make an {+other:list} and {fill-it-with ~1} the same items as in {~1 @fruits..content}.
Now {uppercase} that {other:list} because LOUD FRUITS ARE BETTER!
Here they are: {show} them!

Wait...
What if I {^joinXT ~2} the {~1 other:list} I made above using {~2 " | "} as a spearator?
What {?type} is that?
Let me {boxXT ~2} it with {~1 rounded=true} and {~2 hashed=true}.
Beautiful: {show-0it}

pf()

/*---

pr()

o1 = Naturally("
    Create a string with ' hello  '
    Trim it
    Capitalize it
")

o2 = Naturally("
    Create a string with ' niamy  '
    Trim it
    Capitalize it
")

? BoxRound( o1.Result() + " " + o2.Result() )
#-->
# ╭─────────────╮
# │ Hello Niamy │
# ╰─────────────╯

pf()

# Executed in 0.02 second(s) in Ring 1.24
 
/*--- BOXING WITH MODIFIERS

pr()

Naturally("
    Create a fantastic string with 'Softanza ♥ Ring'
    @Box it
    The box@ should be rounded
    @Box it but the box@ should be rounded
    Display the result
")
#-->
# ╭─────────────────╮
# │ Softanza ♥ Ring │
# ╰─────────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- RAISING ERROR WHEN OBJECT TYPE IS NOT SUPPORTED

Nt = Naturally("
    Create a stxString with 'test.data'
    Replace '.' with '_'
    Uppercase it
")
#--> ERROR: Unsupported object type while processing "CREATE_OBJECT"!

/*--- GETTING RESULT WITHOUT DISPLAY
*/
pr()

Nt = Naturally("
    Create a stzString with 'test.data'
    Create a text with 'test.data'
    Replace '.' with '_'
    Uppercase it
")

? Nt.Result()
#--> TEST_DATA

? Nt.Code() + NL
#-->
# oStr = StzStringQ("test.data")
# oStr.Replace(".", "_")
# oStr.Uppercase()
# @result = oStr.Content()

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- CHAINED OPERATIONS

pr()

Naturally("
    Create a string with 'hello niger'
    Uppercase it spacify it and @box it
    The box@ should be rounded
    Display the final result
")
#-->
# ╭───────────────────────╮
# │ H E L L O   N I G E R │
# ╰───────────────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- OBJECT CREATION VARIATIONS

pr()

Naturally("
    Make a string containing 'world'
    Display it
")
#--> world

pf()
#--> world

/*--- BASIC TRANSFORMATIONS

pr()

Naturally("
    Create a string with 'softanza'
    Uppercase it
    Display the result
")
#--> SOFTANZA

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- MULTIPLE OPERATIONS

pr()

Naturally("
    Create a string with 'ring language'
    Uppercase it and spacify it
    Show it
")
#--> R I N G   L A N G U A G E

pf()
#☺ Executed in 0.01 second(s) in Ring 1.24

/*--- BOXING WITH OPTIONS

pr()

Naturally("
    Create a string with 'boxed text'
    Uppercase it spacify it and @box it
    The box@ should be rounded
    Display the final result
")
#-->
# ╭─────────────────────╮
# │ B O X E D   T E X T │
# ╰─────────────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- TRIMMING OPERATIONS

pr()

o1 = Naturally("
    Make a string with '  spaced text  '
    Trim it and uppercase it
    Display the result
")
#--> SPACED TEXT

? ""
? o1.Code()
#-->
# oStr = StzStringQ("  spaced text  ")
# oStr.Trim()
# oStr.Uppercase()
# ? oStr.Content()

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- REVERSE OPERATIONS

pr()

Naturally("
    Create a string with 'STRESSED'
    Reverse it
    Show the result
")
#--> DESSERTS

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- CASE TRANSFORMATIONS

pr()

Naturally("
    Make a string with 'MiXeD cAsE'
    Lowercase it
    Replace 'mixed' with 'lower'
    Show it
")
#--> lower case

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- SUBSTITUTE OPERATION

pr()

Naturally("
    Make a string with 'old text old'
    Substitute 'old' with 'new'
    Display it
")
#--> new text new

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- CHANGE OPERATION

pr()

Naturally("
    Create a string with 'change me'
    Change 'me' to 'this'
    change 'me' to 'thisd' #ERR returns empy if = "this"
    Show the result
")
#--> change this

pf()

/*--- MULTIPLE MODIFIERS

pr()

Naturally("
    Create a string with 'softanza is great'
    Uppercase it using spacify and also @box it
    The box@ must be rounded
    Show the final result
")
#-->
# ╭───────────────────────────────────╮
# │ S O F T A N Z A   I S   G R E A T │
# ╰───────────────────────────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- FRAME ALTERNATIVE

pr()

Naturally("
    Make a string containing 'natural'
    Uppercase it and spacify it
    @Frame it then the frame@ should have rounded corners
    Display the result
")
#-->
# ╭───────────────╮
# │ N A T U R A L │
# ╰───────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- PRINT ALTERNATIVE

pr()

Naturally("
    Create a string with 'print test'
    Uppercase it
    Print the result
")
#--> PRINT TEST

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- COMPLEX CHAINING

pr()

Naturally("
    Create a string with 'train of thoughts'
    Uppercase it and spacify it
    Then @box it with box@ having rounded corners
    Also show the final result
")
#-->
# ╭───────────────────────────────────╮
# │ T R A I N   O F   T H O U G H T S │
# ╰───────────────────────────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- COMMAND CHAINING

pr()

Naturally("
    Create a string with 'goodbye world'
    Replace 'goodbye' with 'hello'
    Uppercase it
    Show it
")
#--> HELLO WORLD

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- MULTIPLE PARAMETER CONSUMPTION

pr()

Naturally("
    Create a string with 'ONE two three'
    Replace 'two' with 'TWO'
    Replace 'three' with 'THREE' 
    Show it
")
#--> ONE TWO THREE

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- DEFINE/RECALL STATE

pr()

Naturally("
    Create a string with 'test'
    @box
    Uppercase it
    box@
    Show it
")
#-->
# ┌──────┐
# │ TEST │
# └──────┘

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- MULTIPLE DEFINE/RECALL CYCLES

pr()

Naturally("
    Create a string with 'hello'
    @box
    box@
    @uppercase
    uppercase@
    Show it
")
#-->
# ┌───────┐
# │ HELLO │
# └───────┘

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- CAPITALIZE

pr()

Naturally("
    Create a string with 'Hello World'
    Lowercase it
    Capitalize it
    Display it
")
#--> Hello World

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- EMPTY VALUE PROTECTION

pr()

o1 = Naturally("
    Create a string with ''
    Uppercase it
    Show it
")
#--> ""

? o1.Code()
# oStr = StzStringQ("")
# ? oStr.Content()
'
oStr = StzStringQ("")
oStr.Uppercase()
? oStr.Content()
@result = oStr.Content()
'

pf()

/*--- DEBUG MODE TESTING

pr()

Nt = Naturally("")
Nt.EnableDebug()
Nt.Execute("
    Create a string with 'test'
    Show it
")

? "Debug entries: " + len(Nt.DebugLog())

pf()
? @@NL( Nt.DebugLog() )
#--> [
#	[
#		[ "timestamp", 2166 ],
#		[ "message", "Executing natural code" ]
#	],
#	[
#		[ "timestamp", 2166 ],
#		[ "message", "Code length: 45 chars" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Raw values: 7 items" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[
#			"message",
#			'Value[1]: type=STRING, content="Create"'
#		]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[
#			"message",
#			'Value[2]: type=STRING, content="a"'
#		]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[
#			"message",
#			'Value[3]: type=STRING, content="string"'
#		]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[
#			"message",
#			'Value[4]: type=STRING, content="with"'
#		]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[
#			"message",
#			'Value[5]: type=STRING, content="test"'
#		]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[
#			"message",
#			'Value[6]: type=STRING, content="Show"'
#		]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[
#			"message",
#			'Value[7]: type=STRING, content="it"'
#		]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Converting to semantic tokens" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Processing: 'Create'" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "  Semantic: CREATE_OBJECT" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Processing: 'a'" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "  Ignored" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Processing: 'string'" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "  Semantic: OBJECT_STRING" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Processing: 'with'" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "  Ignored" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Processing: 'test'" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "  Literal" ]
#	],
#	[
#		[ "timestamp", 2168 ],
#		[ "message", "Processing: 'Show'" ]
#	],
#	[
#		[ "timestamp", 2169 ],
#		[ "message", "  Semantic: OUTPUT_DISPLAY" ]
#	],
#	[
#		[ "timestamp", 2169 ],
#		[ "message", "Processing: 'it'" ]
#	],
#	[
#		[ "timestamp", 2169 ],
#		[ "message", "  Ignored" ]
#	],
#	[
#		[ "timestamp", 2169 ],
#		[ "message", "Tokens: 4" ]
#	],
#	[
#		[ "timestamp", 2170 ],
#		[ "message", "Generated code:" ]
#	],
#	[
#		[ "timestamp", 2170 ],
#		[
#			"message",
#			'oStr = StzStringQ("test")
#			? oStr.Content()
#			@result = oStr.Content()'
#		]
#	]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- CLEARING DEBUG LOG

pr()

Nt = Naturally("")
Nt.EnableDebug()
Nt.Execute("Create string with 'test'")

? "Before clear: " + len(Nt.DebugLog())
? len(Nt.DebugLog()) #--> 19

Nt.ClearDebugLog()
? "After clear: " + len(Nt.DebugLog())
? len(Nt.DebugLog()) #--> 0

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- MULTIPLE BOXING
/*--- MULTIPLE BOXING (WITH FREE PUNCTUATION)

pr()

Naturally("
    Make a string with 'i ♥ niamey'
    @box it ~ Spacify it ~ and Uppercase it
    the box@ must be rounded
    @box it again
    yet this second box@ should be rounded as well
    Display the result
    @box it, spacify it, and Uppercase it.
    the box@ must be rounded...
    @box it again!
    Yet: this second box@ should be rounded as well.
    Display the result...
")
#-->
# ╭─────────────────────────╮
# │ ╭─────────────────────╮ │
# │ │ I   ♥   N I A M E Y │ │
# │ ╰─────────────────────╯ │
# ╰─────────────────────────╯

pf()
# Executed in 0.03 second(s) in Ring 1.24

#-----------------------------#
#  MULTILINGUAL NATURAL CODE  #
#-----------------------------#

/*--- NATURAL CODE IN ENGLISH

pr()

Naturally("
    Make a string with 'hello niger' inside
    Spacify it and uppercase it
    @Box it while the box@ is rounded
    Display it on the screen
    Thank you very much

    Make a text containing 'hello niger'.
    Spacify it and uppercase it!

    @Box it but the box@ should be rounded ;

    Display it on the screen...
    Thank you very much ♥

")
#-->
# ╭───────────────────────╮
# │ H E L L O   N I G E R │
# ╰───────────────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- NATURAL CODE IN HAUSA LATIN SCRIPT (BOKO)


pr()

o1 = NaturallyIn("hausa", "
    Yi rubutu da dauke 'hello niger' a ciki 
    Raba shi kuma maida shi
    @Akwati shi kuma wannan akwati@ dole zagaye
    Nuna shi a kan allo
    Na gode susai

    Yi rubutu da dauke 'hello niger' a ciki.
    Raba shi kuma maida shi!

    @Akwati shi kuma wannan akwati@ dole zagaye ;

    Nuna shi a kan allo...
    Na gode susai ♥

")
#-->
# ╭───────────────────────╮
# │ H E L L O   N I G E R │
# ╰───────────────────────╯

# Vocabulary:
#   Make     --> Yi
#   String   --> Rubuti
#   With     --> Dauke
#   Spacify  --> Raba
#   Uppercase--> Maida
#   Box      --> Akwati
#   Rounded  --> Zagaye

? o1.Code()
#-->
# oStr = StzStringQ("hello niger")
# oStr.Spacify()
# oStr.Uppercase()
# oStr.BoxXT([:Rounded = 1])
# ? oStr.Content()

pf()

/*--- FROM FILE

pr()

# Save natural code to file
cCode = "
    Create string with 'from file'
    Uppercase it
    Show it
"
write("test.natural", cCode)
write("test.stzn", cCode)

# Execute from file
Naturally(read("test.natural"))
Naturally(read("test.stzn"))
#--> FROM FILE

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- MULTILINE WITH PROPER FORMATTING

pr()

#TODO #ERR// if we add "." after "rounded" it fails

Naturally("
    Create a string with 'softanza'
    
    Uppercase it
    Spacify it
    
    @Box it rounded
    Display the result
    1. Create a string with 'softanza'
    2. Uppercase it
    3. Spacify it
    4. @Box it
    5. The box@ should be rounded
    6. Display the result
    7. Thanks!
")
#-->
# ╭─────────────────╮
# │ S O F T A N Z A │
# ╰─────────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.24
