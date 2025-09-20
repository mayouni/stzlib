load "../stzbase.ring"

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
# Executed in 0.01 second(s) in Ring 1.23

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
# Executed in 0.03 second(s) in Ring 1.23

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
# Executed in 0.01 second(s) in Ring 1.23

/*--- REVERSE OPERATIONS

pr()

Naturally() {
    Create a stzString with "stressed"
    Reverse it
    Show the result
}
#--> desserts

pf()

/*--- CASE TRANSFORMATIONS

pr()

Naturally() {
    Make a stzString with "MiXeD cAsE"
    Lowercase it
    Show it
}
#--> mixed case

pf()

/*---

pr()

Naturally() {
    Create a stzString object with "Softanza" inside
    Append it with the substring " Semantics"
    Uppercase it andu then @box it a box@ that is rounded
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

/*---

pr()

Naturally() {
    Make a stzString with "Softanza ♥ Ring"

    Uppercase this_
    Spacify that
    @Box this_
    The box@ is rounded
    Show the final result
}
#-->
'
╭───────────────────────────────╮
│ S O F T A N Z A   ♥   R I N G │
╰───────────────────────────────╯
'

pf()
# Executed in 0.01 second(s) in Ring 1.23

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
# Executed in 0.01 second(s) in Ring 1.23

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
# Executed in 0.01 second(s) in Ring 1.23

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
# Executed in 0.02 second(s) in Ring 1.23

/*--- FRAME ALTERNATIVE

pr()

Naturally() {
    Make a stzString with "natural"
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
# Executed in 0.04 second(s) in Ring 1.23

/*--- PRINT ALTERNATIVE

pr()

Naturally() {
    Create a stzString with "print test"
    Uppercase it
    Print the result
}
#--> PRINT TEST

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*--- COMPLEX CHAINING

pr()

Naturally() {
    Create a stzString with "complex example"
    Uppercase it and_ spacify it
    Then box@ it with rounded corners
    Also show the final result
}
#--> ╭───────────────────────────────╮
#    │ C O M P L E X   E X A M P L E │
#    ╰───────────────────────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.23

