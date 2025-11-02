load "../stzbase.ring"

/*---
*/
pr()

Naturally("
    Create number with 100
    Increment it
    Show it
")
#--> 101

pf()

/*---

pr()

$acFruits = ["banana", "apple", "cherry"]

Naturally("
    Create a list with $acFruits
    Sort it
    Uppercase it
    Show it
")
#-->
# APPLE
# BANANA
# CHERRY

pf()

/*---
*/
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

/*--- BOXING WITH MODIFIERS

pr()

Naturally("
    Create a fantastic string with 'Softanza ♥ Ring'
    @Box it
    The box@ should be rounded
    Display the result
")
#-->
# ╭─────────────────╮
# │ Softanza ♥ Ring │
# ╰─────────────────╯

pf()

/*--- GETTING RESULT WITHOUT DISPLAY

pr()

Nt = Naturally("
    Create a stzString with 'test.data'
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

/*--- OBJECT CREATION VARIATIONS

pr()

Naturally("
    Make a string containing 'world'
    Display it
")
#--> world

pf()

/*--- BASIC TRANSFORMATIONS

pr()

Naturally("
    Create a string with 'softanza'
    Uppercase it
    Display the result
")
#--> SOFTANZA

pf()

/*--- MULTIPLE OPERATIONS

pr()

Naturally("
    Create a string with 'ring language'
    Uppercase it and spacify it
    Show it
")
#--> R I N G   L A N G U A G E

pf()

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

/*--- REVERSE OPERATIONS

pr()

Naturally("
    Create a string with 'STRESSED'
    Reverse it
    Show the result
")
#--> DESSERTS

pf()

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

/*--- SUBSTITUTE OPERATION

pr()

Naturally("
    Make a string with 'old text old'
    Substitute 'old' with 'new'
    Display it
")
#--> new text new

pf()

/*--- CHANGE OPERATION

pr()

Naturally("
    Create a string with 'change me'
    Change 'me' to 'this'
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

/*--- PRINT ALTERNATIVE

pr()

Naturally("
    Create a string with 'print test'
    Uppercase it
    Print the result
")
#--> PRINT TEST

pf()

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

/*--- CLEARING DEBUG LOG

pr()

Nt = Naturally("")
Nt.EnableDebug()
Nt.Execute("Create string with 'test'")

? "Before clear: " + len(Nt.DebugLog())
Nt.ClearDebugLog()
? "After clear: " + len(Nt.DebugLog())

pf()

/*--- MULTIPLE BOXING

pr()

Naturally("
    Make a string with 'i ♥ niamey'
    @box it ~ Spacify it ~ and Uppercase it
    the box@ must be rounded
    @box it again
    yet this second box@ should be rounded as well
    Display the result
")
#-->
# ╭─────────────────────────╮
# │ ╭─────────────────────╮ │
# │ │ I   ♥   N I A M E Y │ │
# │ ╰─────────────────────╯ │
# ╰─────────────────────────╯

pf()

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
")
#-->
# ╭───────────────────────╮
# │ H E L L O   N I G E R │
# ╰───────────────────────╯

pf()

/*--- NATURAL CODE IN HAUSA LATIN SCRIPT (BOKO)
*/
pr()

o1 = NaturallyIn("hausa", "
    Yi rubutu da dauke 'hello niger' a ciki 
    Raba shi kuma maida shi
    @Akwati shi kuma wannan akwati@ dole zagaye
    Nuna shi a kan allo
    Na gode susai
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

/*--- NATURAL CODE IN HAUSA ARABIC SCRIPT (AJAMI)

pr()

o1 = NaturallyIn("hausa-ajami", "
    يي رُوْبُتُ دا ɗوكي 'hello niger' ا چِكِ
    رَبَ شي كُومَا مَيْدَ شي
    @أَكْوَتُ شي كُومَا وَنَنْ أَكْوَتُن@ دُولُ زَغَيَ
    نُوْنَ شي اَ كَنْ أَلْوُ
")

? o1.Code()
#-->
# oStr = StzStringQ("hello niger")
# oStr.Spacify()
# oStr.Uppercase()
# oStr.BoxXT([:Rounded = 1])
# ? oStr.Content()

# Vocabulary:
#   Make     --> "يي"
#   String   --> "رُوْبُتُ"
#   With     --> "ɗوكي"
#   Spacify  --> "رَبَ"
#   Uppercase--> "مَيْدَ"
#   Box      --> "أَكْوَتُن"
#   Rounded  --> "زَغَيَ"

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

# Execute from file
Naturally(read("test.natural"))
#--> FROM FILE

pf()

/*--- MULTILINE WITH PROPER FORMATTING

pr()

Naturally("
    Create a string with 'softanza'
    
    Uppercase it
    Spacify it
    
    @Box it rounded
    Display the result
")
#-->
# ╭─────────────────╮
# │ S O F T A N Z A │
# ╰─────────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.24
