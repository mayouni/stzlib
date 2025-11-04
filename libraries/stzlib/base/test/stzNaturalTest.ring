load "../stzbase.ring"

/*---
*/
pr()

NaturallyXT([], "
    Create number with '100'
    Increment it
    Show it
")
#--> 101

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*---

pr()

Naturally('
    Create a list with [ "banana", "apple", "cherry" ]
    Sort it
    Uppercase it
    Show it
')
#-->
# APPLE
# BANANA
# CHERRY

pf()
# Executed in 0.07 second(s) in Ring 1.24

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

pr()

Nt = Naturally("
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

#ERR returns empty if = "this"

Naturally("
    Create a string with 'change me'
    change 'me' to 'thisd'
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

? len(Nt.DebugLog()) #--> 19

Nt.ClearDebugLog()
? len(Nt.DebugLog()) #--> 0

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- MULTIPLE BOXING (WITH FREE PUNCTUATION)

pr()

Naturally("
    Make a string with 'i ♥ niamey'
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

/*---

pr()

Naturally('{

    Make a string with "i ♥ niamey".

    @box it, spacify it, and Uppercase it.
    the box@ must be rounded..

    Box everything again!

    Then add an other third and final @box
    That outer box@ should be rounded ;

    Display the result..

}')
#-->
'
╭─────────────────────────────╮
│ ┌─────────────────────────┐ │
│ │ ╭─────────────────────╮ │ │
│ │ │ I   ♥   N I A M E Y │ │ │
│ │ ╰─────────────────────╯ │ │
│ └─────────────────────────┘ │
╰─────────────────────────────╯
'

pf()
# Executed in 0.05 second(s) in Ring 1.24

#-----------------------------#
#  MULTILINGUAL NATURAL CODE  #
#-----------------------------#

/*--- NATURAL CODE IN ENGLISH

pr()

Naturally("

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
write("test.stzn", cCode)

# Execute from file
Naturally(read("test.stzn"))
#--> FROM FILE

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- MULTILINE WITH PROPER FORMATTING

pr()

o1 = Naturally("
    1. Create a string with 'softanza'.
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

? o1.Code() + NL
#-->
'
oStr = StzStringQ("softanza")
oStr.Uppercase()
oStr.Spacify()
oStr.BoxXT([:Rounded = 1])
? oStr.Content()
@result = oStr.Content()
'

? o1.NaturalCode()
#-->
"
    1. Create a string with 'softanza'
    2. Uppercase it
    3. Spacify it
    4. @Box it
    5. The box@ should be rounded
    6. Display the result
    7. Thanks!
"

pf()
# Executed in 0.12 second(s) in Ring 1.24

///////////////////////////////////////////////////////////////

#-----------------------#
#  BASIC CONTEXT TESTS  #
#-----------------------#

/*--- Simple String Context

pr()

aContext = [:UserName = "Ahmad"]
NaturallyXT(aContext, '
    Create string with {UserName}
    Uppercase it
    Show it
')
#--> AHMAD

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Multiple Context Values

pr()

aContext = [
    :FirstName = "Ahmad",
    :LastName = "Bello"
]

NaturallyXT(aContext, "
    Create string with {FirstName}
    Uppercase it
    Show it
")
#--> AHMAD

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Context with Capitalize

pr()

aContext = [:name = "mansour"]

NaturallyXT(aContext, "
    Create string with {name}
    Capitalize it
    Show it
")
#--> Mansour

pf()

#-------------------------#
#  NESTED CONTEXT ACCESS  #
#-------------------------#

#--- Nested Object Path

pr()

aContext = [
    :User = [
        :Profile = [
            :Name = "Mansour",
            :City = "Niamey"
        ]
    ]
]

NaturallyXT(aContext, "
    Create string with {User.Profile.Name}
    Capitalize it
    Show it
")
#--> Mansour

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Deep Nesting

pr()

aContext = [
    :app = [
        :config = [
            :database = [
                :name = "softanza"
            ]
        ]
    ]
]

NaturallyXT(aContext, "
    Create string with {app.config.database.name}
    Uppercase it
    Show it
")
#--> SOFTANZA

pf()
# Executed in 0.01 second(s) in Ring 1.24

#---------------------------#
#  CONTEXT WITH OPERATIONS  #
#---------------------------#

/*--- Context with Trim

pr()

aContext = [:input = "  hello  "]

NaturallyXT(aContext, "
    Create string with {input}
    Trim it
    Capitalize it
    Show it
")
#--> Hello

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Context with Spacify and Box

pr()

aContext = [:greeting = "hello niger"]

NaturallyXT(aContext, "
    Create string with {greeting}
    Uppercase it
    Spacify it
    Box it
    Show it
")
#-->
# ┌───────────────────────┐
# │ H E L L O   N I G E R │
# └───────────────────────┘

pf()

/*--- Context with Rounded Box

pr()

aContext = [:message = "welcome"]

o1 = NaturallyXT(aContext, "
    Create string with {message}
    Uppercase it
    Spacify it
    @Box it but the box@ must be rounded
    Show it
")
#-->
# ╭─────────────────╮
# │ W E L C O M E   │
# ╰─────────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.24

#------------------------#
#  CONTEXT WITH REPLACE  #
#------------------------#

/*--- Replace Using Context Values

pr()

aContext = [
    :old = "world",
    :new = "niger"
]

NaturallyXT(aContext, "
    Create string with 'hello world'
    Replace {old} with {new}
    Uppercase it
    Show it
")
#--> HELLO NIGER

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*-- Mixed Context and Literal

pr()

aContext = [:target = "Ring"]

NaturallyXT(aContext, "
    Create string with 'I love programming'
    Replace programming with {target}
    Show it
")
#--> I love Ring

pf()
# Executed in 0.01 second(s) in Ring 1.24

#------------------#
#  NUMBER CONTEXT  #
#------------------#

#--- Context with Number

pr()

aContext = [:count = 100]

NaturallyXT(aContext, "
    Create number with {count}
    Increment it
    Show it
")
#--> 101

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*-- Number with Multiple Operations
*/
#ERR
pr()

aContext = [:value = 50]

o1 = NaturallyXT(aContext, "
    Create number with {value}
    Multiply it by 2
    Show it
")
#--> 100 #ERR the result is computed but not displayed

? o1.Code()
? o1.Result()


pf()
# Executed in 0.02 second(s) in Ring 1.24

#----------------#
#  LIST CONTEXT  #
#----------------#

#--- Context with List

pr()
#ERROR

aContext = [:items = ["apple", "banana", "cherry"]]

NaturallyXT(aContext, "
    Create list with {items}
    Sort it
    Show it
")
#-->
# apple
# banana
# cherry

pf()

/*--- List with Reverse

pr()
#ERROR

aContext = [:numbers = [3, 1, 4, 1, 5]]
NaturallyXT(aContext, "
    Create list with {numbers}
    Sort it
    Reverse it
    Show it
")
#-->
# 5
# 4
# 3
# 1
# 1

pf()

#-----------------------------#
#  MULTILINGUAL WITH CONTEXT  #
#-----------------------------#

/*--- Hausa with Context
*/
pr()

aContext = [:rubutu = "sauki"]
o1 = NaturallyInXT("hausa", aContext, "
    Yi rubutu dauke {rubutu}
    Maida shi
    Nuna shi
")
#--> SAUKI

? @@(o1.Context()) + NL
#--> [ [ "rubutu", "sauki" ] ]

pf()

/*--- Hausa with Nested Context

aContext = [
    :data = [
        :rubutu = "niamey"
    ]
]
NaturallyInXT("hausa", aContext, "
    Yi rubutu dauke {data.rubutu}
    Maida shi
    Nuna shi
")
#--> NIAMEY

? NL

/*==============================
   ORIGINAL VS NATURAL CODE
==========

? "=== CODE PRESERVATION ===" + NL

#--- Verify Original Code Preservation
aContext = [:name = "Ring"]
o1 = NaturallyXT(aContext, "
Create string with {name}
Uppercase it
")

? "Original Code:"
? o1.OriginalCode()
#-->
# Create string with {name}
# Uppercase it

? NL + "Natural Code (interpolated):"
? o1.NaturalCode()
#-->
# Create string with Ring
# Uppercase it

? NL + "Result: " + o1.Result()
#--> RING

? NL

/*====================
   EDGE CASES


? "=== EDGE CASES ===" + NL

#--- Empty Context
NaturallyXT([], "
    Create string with 'test'
    Uppercase it
    Show it
")
#--> TEST

? NL

#--- Missing Context Key (stays as placeholder)
aContext = [:existing = "value"]
NaturallyXT(aContext, "
    Create string with {missing}
    Show it
")
#--> {missing}

? NL

#--- Mixed Case Keys (normalized)
aContext = [:username = "Ali"]
NaturallyXT(aContext, "
    Create string with {UserName}
    Show it
")
#--> Ali

? NL

#--- Context with Special Characters
aContext = [:message = "Hello, World!"]
NaturallyXT(aContext, "
    Create string with {message}
    Uppercase it
    Show it
")
#--> HELLO, WORLD!

? NL

/*===========================
   COMPLEX NESTED SCENARIOS
=======

? "=== COMPLEX SCENARIOS ===" + NL

#--- Application Config Context
aContext = [
    :app = [
        :name = "Softanza",
        :version = "1.0",
        :author = [
            :name = "Mansour",
            :location = "Niger"
        ]
    ]
]

NaturallyXT(aContext, "
    Create string with {app.name}
    Uppercase it
    Box it
    Show it
")
#-->
# ┌──────────┐
# │ SOFTANZA │
# └──────────┘

? NL

#--- Multiple Context Interpolations
aContext = [
    :greeting = "Welcome",
    :name = "Ahmad"
]

NaturallyXT(aContext, "
    Create string with {greeting}
    Show it
")
#--> Welcome

? NL

/*============================
   CONTEXT WITH ALL FEATURES
========

? "=== COMPREHENSIVE TEST ===" + NL

#--- Full Feature Test
aContext = [
    :project = [
        :name = "natural programming",
        :team = [
            :lead = "Mansour"
        ]
    ]
]

o1 = NaturallyXT(aContext, "
    Create string with {project.name}
    Capitalize it
    @Box it but the box@ must be rounded
    Show it
")

#-->
# ╭──────────────────────╮
# │ Natural Programming  │
# ╰──────────────────────╯

? "Language: " + o1.Language()
? "Context depth: " + len(o1.Context())
? NL

/*==========================
   PRACTICAL USE CASES
======

? "=== PRACTICAL EXAMPLES ===" + NL

#--- Email Template
aContext = [
    :recipient = "Ahmad",
    :sender = "Mansour"
]

NaturallyXT(aContext, "
    Create string with {recipient}
    Capitalize it
    Show it
")
#--> Ahmad

? NL

#--- Report Header
aContext = [
    :report = [
        :title = "monthly sales",
        :date = "2025-11"
    ]
]

NaturallyXT(aContext, "
    Create string with {report.title}
    Uppercase it
    Spacify it
    Box it
    Show it
")
#-->
# ┌───────────────────────┐
# │ M O N T H L Y   S A L E S │
# └───────────────────────┘

? NL

#--- User Profile Display
aContext = [
    :user = [
        :profile = [
            :displayName = "mansour ayouba",
            :role = "developer"
        ]
    ]
]

NaturallyXT(aContext, "
    Create string with {user.profile.displayName}
    Capitalize it
    Show it
")
#--> Mansour Ayouba

? NL

? "=== ALL TESTS COMPLETED ===" + NL

#================================#
#  ADVANCEDED - TODO             #
#================================#

/*=== #TODO support stzGraph

pr()

NaturallyIn("french", "
  Bonjour Softanza Pi !  
  J’aimerais optimiser la logistique suivante :  

  - Créer un circuit d’Agadez vers Niamey,  
  - en regroupant 50 envois de producteurs locaux,  
  - tout en réduisant les frais de transport.  

  Affiche le résultat.
")
#-->
╭───────────────────────────────────╮
│     NITA AGRICOLE - Circuit       │
├───────────────────────────────────┤
│  Agadez ──────> Niamey            │
│                                   │
│  50 envois groupés                │
│  Frais optimisés : 15% économie   │
│  Total économisé : 75 000 FCFA    │
╰───────────────────────────────────╯
# Executed in 0.02 second(s) by Softanza Pi


NaturallyIn("hausa", "
	Sannu Softanza Pi!  
	Ina so in inganta harkar sufuri kamar haka:  
	
	- Ƙirƙiri hanya daga Agadez zuwa Niamey,  
	- ta haɗa jigilar kaya 50 na manoma na gida,  
	- tare da rage kuɗin sufuri.  
	
	Nuna sakamakon.
")
#-->
╭────────────────────────────────────╮
│      NITA AIKIN GONA - Hanya       │
├────────────────────────────────────┤
│  Agadez ──────> Niamey             │
│                                    │
│  Aikawa 50 an tattara              │
│  Rage kuɗi: 15% tsadar kudi        │
│  Jimlar da aka adana: 75 000 FCFA  │
╰────────────────────────────────────╯
# Executed in 0.02 second(s) by Softanza Pi

pf()

#--

pr()

NaturallyIn("french", "
    Créer circuit transfert Niamey vers Agadez
    Analyser 1000 transactions du mois
    Optimiser routes et frais corridors
    Afficher résultat
")
#--> Résultat en français :
╭───────────────────────────────────────╮
│ OPTIMISATION CORRIDORS - Mars 2025    │
├───────────────────────────────────────┤
│ Corridor : Niamey → Agadez            │
│                                       │
│ 1000 transactions analysées           │
│ Route actuelle : 3 intermédiaires     │
│ Route optimisée : 1 intermédiaire     │
│                                       │
│ Économies réalisées :                 │
│   • Frais opérationnels : -18%        │
│   • Délai moyen : -2 jours            │
│   • Gain mensuel : 2 450 000 FCFA     │
╰───────────────────────────────────────╯
# Executed in 0.02 second(s) by Softanza Pi


# VERSION HAUSA (corrigée)

NaturallyIn("hausa", "
    Ƙirƙiri hanyar jigilar kuɗi daga Niamey zuwa Agadez
    Bincika ma'amaloli 1000 na watan
    Inganta hanyoyi da kuɗin hanya
    Nuna sakamako
")
#--> Sakamakon cikin Hausa :
╭───────────────────────────────────────╮
│ INGANTA HANYOYI - Maris 2025          │
├───────────────────────────────────────┤
│ Hanya : Niamey → Agadez               │
│                                       │
│ Ma'amaloli 1000 an bincika            │
│ Hanya ta yanzu : masu shiga 3         │
│ Hanya ingantacce : mai shiga 1        │
│                                       │
│ Kuɗin da aka adana :                  │
│   • Kuɗin aiki : -18%                 │
│   • Matsakaicin lokaci : -kwana 2     │
│   • Ribar wata-wata : 2 450 000 FCFA  │
╰───────────────────────────────────────╯
# Executed in 0.02 second(s) by Softanza Pi

# CODE RING GÉNÉRÉ EN INTERNE

oCircuit = new stzGraph("NiameyAgadez")
oCircuit {
    # Créer les nœuds (villes)
    AddNodeXT(:@niamey, "Niamey")
    AddNodeXT(:@agence1, "Agence Dosso")
    AddNodeXT(:@agence2, "Agence Tahoua")
    AddNodeXT(:@agence3, "Agence Arlit")
    AddNodeXT(:@agadez, "Agadez")
    
    # Routes actuelles (multiples intermédiaires)
    AddEdgeXTT(:@niamey, :@agence1, "route", [:frais = 5000, :delai = 1])
    AddEdgeXTT(:@agence1, :@agence2, "route", [:frais = 4500, :delai = 1])
    AddEdgeXTT(:@agence2, :@agence3, "route", [:frais = 3500, :delai = 1])
    AddEdgeXTT(:@agence3, :@agadez, "route", [:frais = 4000, :delai = 1])
    
    # Route directe optimisée (1 seul intermédiaire)
    AddEdgeXTT(:@niamey, :@agence2, "route_directe", [:frais = 8000, :delai = 1])
    AddEdgeXTT(:@agence2, :@agadez, "route_directe", [:frais = 6000, :delai = 1])
    
    # Analyser 1000 transactions
    oTransactions = new stzList()
    oTransactions.AddItems(ListOfRange(1, 1000))
    
    # Optimiser avec stzLinearSolver
    oSolver = new stzLinearSolver()
    oSolver {
        AddVariable("route_actuelle", 0, 1000)
        AddVariable("route_optimisee", 0, 1000)
        
        # Contrainte : traiter toutes les transactions
        AddConstraint("route_actuelle + route_optimisee", "=", 1000)
        
        # Coût route actuelle : 17000 FCFA, délai 4 jours
        # Coût route optimisée : 14000 FCFA, délai 2 jours
        AddConstraint("cout_total", "=", 
                     "17000 * route_actuelle + 14000 * route_optimisee")
        
        # Minimiser coût total
        Minimize("cout_total")
        Solve("simplex")
        
        nEconomie = 18  # % économie
        nGainMensuel = (17000 - 14000) * 1000  # 3M FCFA
        nDelaiReduit = 2  # jours économisés
    }
    
    # Afficher résultat bilingue
    Show()
}

pf()
