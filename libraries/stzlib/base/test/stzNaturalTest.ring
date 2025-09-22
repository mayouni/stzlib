load "../stzbase.ring"

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
		╰───┴───┴─•─┴───╯	
'

pf()

/*--- BASIC OBJECT CREATION

pr()

Naturally() {
    Create a stzString with "hello"
    Show it
}
#--> hello

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- OBJECT CREATION VARIATIONS

pr()

Naturally() {
    Make a stzString containing "world"
    Display it
}
#--> world

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- BASIC TRANSFORMATIONS

pr()

Naturally() {
    Create a stzString with "softanza"
    Uppercase it
    Display the result
}
#--> SOFTANZA

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- CHAINED OPERATIONS

pr()

Naturally() {
    Create a stzString with "ring language"
    Uppercase it and_ spacify it
    Show it
}
#--> R I N G   L A N G U A G E

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*--- BOXING WITH OPTIONS

pr()

Naturally() {
    Create a stzString with "boxed text"
    Uppercase it spacify it and_ @box it
    The box@ should be rounded
    Display the final result
}
#--> ╭─────────────────────╮
#    │ B O X E D   T E X T │
#    ╰─────────────────────╯

pf()
# Executed in 0.04 second(s) in Ring 1.23

/*--- PREPEND OPERATIONS

pr()

Naturally() {
    Create a stzString with "world"
    Prepend it with "hello "
    Show it
}
#--> "hello world"


pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- APPEND OPERATIONS

pr()

Naturally() {
    Make a stzString with "hello"
    Append " beautiful world" to_ it
    Display the result
}
#--> "hello beautiful world"

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- TRIMMING OPERATIONS

pr()

o1 = Naturally() {
    Make a stzString with "  spaced text  "
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
# Executed in 0.02 second(s) in Ring 1.23

/*--- REVERSE OPERATIONS

pr()

Naturally() {
    Create a stzString with "stressed"
    Reverse it
    Show the result
}
#--> desserts

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- CASE TRANSFORMATIONS

pr()

Naturally() {
    Make a stzString with "MiXeD cAsE"
    Lowercase it
    Show it
}
#--> mixed case

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---

pr()

Naturally() {
    Create a stzString object with "Softanza" inside
    Append it with the substring " Semantics"
    Uppercase it and_ then @box it a box@ that is rounded
    Display the result
}
#-->
'
╭────────────────────╮
│ SOFTANZA SEMANTICS │
╰────────────────────╯
'

pf()
# Executed in 0.04 second(s) in Ring 1.23

/*--- REFERENCE VARIATIONS

pr()

Naturally() {
    Make a stzString with "reference test"

    Uppercase this_
    Spacify that
    Box this_

    Show the final result
}
#--> ┌─────────────────────────────┐
#    │ R E F E R E N C E   T E S T │
#    └─────────────────────────────┘

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*--- #todo #Narration

pr()

Nt = Naturally() {
    Make a stzString with "Softanza ♥ Ring" inside '.'

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
# Executed in 0.03 second(s) in Ring 1.23

/*--- CONNECTOR VARIATIONS

pr()

Naturally() {
    Make a stzString with "test"
    Uppercase it then_ spacify it then_ box it
    Display the result
}
#--> ┌─────────┐
#    │ T E S T │
#    └─────────┘

pf()
# Executed in 0.03 second(s) in Ring 1.23

/*--- ALTERNATIVE CONNECTORS

pr()

Naturally() {
    Create a stzString containing "connectors"
    Uppercase it plus spacify it plus box it
    Show the result
}
#--> ┌─────────────────────┐
#    │ C O N N E C T O R S │
#    └─────────────────────┘

pf()
# Executed in 0.03 second(s) in Ring 1.23

/*--- SUBSTITUTE OPERATION

pr()

Naturally() {
    Make a stzString with "old text old"
    Substitute "old" with "new"
    Display it
}
#--> new text new

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- CHANGE OPERATION

pr()

Naturally() {
    Create a stzString with "change me"
    Change "me" to_ "this"
    Show the result
}
#--> change this

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- MULTIPLE MODIFIERS

pr()

Naturally() {
    Create a stzString with "softanza is great"
    Uppercase it using spacify and_ also @box it # @ to reference the box later
    The box@ must be rounded # @ to recall the box reference before
    Show the final result
}
#--> ╭───────────────────────────────────╮
#    │ S O F T A N Z A   I S   G R E A T │
#    ╰───────────────────────────────────╯

pf()
# Executed in 0.04 second(s) in Ring 1.23

/*--- FRAME ALTERNATIVE

pr()

Naturally() {
    Make a stzString containing "natural"
    Uppercase it and_ spacify it
    Frame it with rounded corners
    Display the result
}
#-->
'
╭───────────────╮
│ N A T U R A L │
╰───────────────╯
'

pf()
# Executed in 0.03 second(s) in Ring 1.23

/*--- PRINT ALTERNATIVE

pr()

Naturally() {
    Create a stzString with "print test"
    Uppercase it
    Print the result
}
#--> PRINT TEST

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- COMPLEX CHAINING

pr()

Naturally() {
    Create a stzString with "train of thoughts"
    Uppercase it and_ spacify it
    Then box it with rounded corners
    Also show the final result
}
#--> ╭───────────────────────────────────╮
#    │ T R A I N   O F   T H O U G H T S │
#    ╰───────────────────────────────────╯

pf()
# Executed in 0.03 second(s) in Ring 1.23

/*--- COMMAND CHAINING

pr()

Naturally() {
    Create a stzString with "hello world"
    Replace "hello" with "goodbye"
    Uppercase it
    Show it
}
#--> GOODBYE WORLD

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*--- MULTIPLE PARAMETER CONSUMPTION

pr()

Naturally() {
    Create a stzString with "one two three"
    Replace "two" with "TWO"
    Replace "three" with "THREE" 
    Show it
}
#--> one TWO THREE

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*--- DEFINE/RECALL STATE CLEANUP

pr()

Naturally() {
    Create a stzString with "test"
    @box
    Uppercase it
    box@
    Show it
}
#--> ┌──────┐
#    │ TEST │
#    └──────┘

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*--- MULTIPLE DEFINE/RECALL CYCLES

pr()

Naturally() {
    Create a stzString with "hello"
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
# Executed in 0.02 second(s) in Ring 1.23

/*---

pr()

# You can't use "it" as a value for object creation
# or any other ignore keyword (in @aWordsToIgnore)
# and if you don you will get it replace by "":

o1 = Naturally() {
    Create a stzString with "it"
    Box it rounded
    Show it
}
#--> ╭──╮
#    │  │
#    ╰──╯

? o1.Code()
pf()
# Executed in 0.02 second(s) in Ring 1.23

/*--- MODIFIERS WITH CHAINING

pr()

Naturally() {
    Create a stzString with "hello"
    Uppercase it
    Box it rounded
    Show it  
}
#--> ╭───────╮
#    │ HELLO │
#    ╰───────╯

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- METHOD ALIAS RESOLUTION

pr()

Naturally() {
    Create a stzString with "test"
    Caps it
    Show it
}
#--> TEST

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- MIXED ALIASES

pr()

o1 = Naturally() {
    Create a stzString with "Hello World"
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
# Executed in 0.02 second(s) in Ring 1.23

/*--- EMPTY VALUE PROTECTION

pr()

o1 = Naturally() {
    Create a stzString with ""
    Uppercase it
    Show it
}
#--> ""

? o1.Code()
# oStr = StzStringQ("")
# ? oStr.Content()

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- NULL VALUE HANDLING #ERR #Idem

pr()

Naturally() {
    Create a stzString with nothing
    Spacify it
	Box it
    Show it
}
#--> 
# ┌──┐
# │  │
# └──┘

pf()
# Executed in 0.012 second(s) in Ring 1.23

/*--- DEBUG MODE TESTING

pr()

Nt = Naturally()
Nt.EnableDebug()
Nt {
    Create a stzString with "test"
    NonExistentMethod it
    Show it
}


? @@( Nt.Errors() )

#--> Errors:
#--> [ "Method 'nonexistentmethod' not found for object 'stzstring'" ]

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- ERROR CLEARING

pr()

Nt = Naturally()
Nt.EnableDebug()
Nt {
    BadMethod it
}
? "Before clear: " + len(Nt.Errors())
Nt.ClearErrors()
? "After clear: " + len(Nt.Errors())

#--> Before clear: 1
#--> After clear: 0

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- TYPE VALIDATION ENHANCEMENT

pr()

Nt = Naturally()
Nt.EnableDebug()

Nt {
    Create a stzString with "hello world test"
    Replace "invalid_position" with "X"
    Show it
}
#--> hello world test

? @@NL( Nt.Errors() )
#--> []

pf()
# Executed in 0.01 second(s) in Ring 1.23

#------------------------#
#  REAL-WORLD USE CASES  #
#------------------------#

/*-- 1. Data Sanitization for User Input

# Clean and validate user registration data

Naturally() {
    Create a stzString with "  John@EXAMPLE.com  "
    
    Trim it
    Lowercase it
    Replace "@" with " at "
    Capitalize it
    
    Show the final result
}
#--> John At Example.com

pf()
# Executed in 2.09 second(s) in Ring 1.23

/*-- 2. Report Header Generation

pr()

# Generate formatted headers for business reports
ReportFormatter = Naturally() {
    Make a stzString with "QUARTERLY SALES REPORT 2024"
    
    Lowercase it
    Capitalize it
    Spacify it
    Box it with rounded corners
    The box@ should be displayed
}
#-->
'
╭─────────────────────────────────────────────────────────╮
│ Q u a r t e r l y   S a l e s   R e p o r t   2 0 2 4 │
╰─────────────────────────────────────────────────────────╯
'
pf()
# Executed in 0.06 second(s) in Ring 1.23

```

/*-- 3. API Response Processing
*/
pr()

# Process and format API response data
APIProcessor = Naturally() {
    Create a stzString with "user_profile_data_2024"
    
    Replace "_" with " "
    Capitalize it
    Prepend it with "Processing: "
    Append it with " - Complete"
    
    Show it
}
#--> Processing: User Profile Data 2024 - Complete

pf()


/*-- 4. Configuration Validation with Error Handling
```ring
# Validate system configuration with debug output
ConfigValidator = Naturally()
ConfigValidator.EnableDebug()

ConfigValidator {
    Create a stzString with "database.connection.timeout"
    
    Replace "." with "_"
    Uppercase it
    ValidateConfig it  # This method doesn't exist - will trigger error
    
    Show it
}

? "Generated Code:"
? ConfigValidator.Code()
#-->
oStr = StzStringQ("database.connection.timeout")
oStr.Replace(".", "_")
oStr.Uppercase()
? oStr.Content()

? "Validation Errors:"
? @@( ConfigValidator.Errors() )
#--> [ "Method 'validateconfig' not found for object 'stzstring'" ]
```

/*-- 5. Document Template Processor
```ring
# Process document templates with multiple transformations
DocProcessor = Naturally() {
    Make a stzString with "template_invoice_draft"
    
    Replace "_" with " "
    Capitalize it
    @Frame it as a document header
    
    Append " - Ready for Review"
    The frame@ should be presented with rounded borders
}
#-->
╭─────────────────────────────────────────────╮
│ Template Invoice Draft - Ready for Review │
╰─────────────────────────────────────────────╯

? DocProcessor.Code()
#-->
oStr = StzStringQ("template_invoice_draft")
oStr.Replace("_", " ")
oStr.Capitalize()
oStr.BoxXT([:Rounded = 1])
oStr.Append(" - Ready for Review")
? oStr.Content()
```
