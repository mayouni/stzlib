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
    Show the result
}
#--> SOFTANZA

pf()

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

/*--- MULTIPLE REPLACEMENTS

pr()

Naturally() {

    Create a stzString with "abracadabra"
    Replace the first 'a' with 'A'
    Replace the second 'a' with 'B' 
    Replace the fourth 'a' with 'C'
    Replace the fifth 'a' with 'D'
    Show it
? Code() + NL

}
#--> AbracBdCbrD

pf()

/*--- COMPLEX REPLACEMENTS

pr()

Naturally() {
    Make a stzString with "hello world hello"
    Replace the first "hello" with "Hi"
    Replace the second "hello" with "Bye"
    Display the result
}
#--> Hi world Bye

pf()

/*--- PREPEND OPERATIONS

pr()

Naturally() {
    Create a stzString with "world"
    Prepend it with "hello "
    Show it
}
#--> hello world

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- APPEND OPERATIONS  

pr()

Naturally() {
    Make a stzString with "hello"
    Append " beautiful world" to_ it
    Display the result
}
#--> hello beautiful world

pf()

/*--- INSERTION OPERATIONS

pr()

Naturally() {
    Create a stzString with "hello world"
    Insert " beautiful" at position 6
    Show it
}
#--> hello beautiful world

pf()

/*--- TRIMMING OPERATIONS

pr()

Naturally() {
    Make a stzString with "  spaced text  "
    Trim it and_ uppercase it
    Display the result
}
#--> SPACED TEXT

pf()

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

/*--- EMPTY OBJECT HANDLING

pr()

Naturally() {
    Create a stzString object with nothing inside
    Append it with the substring "added content"
    Uppercase it
    Display the result
}
#--> ADDED CONTENT

pf()
# Executed in 0.01 second(s) in Ring 1.23

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
# Executed in 0.01 second(s) in Ring 1.23

/*--- POSITIONAL REPLACEMENTS

pr()

Naturally() {
    Create a stzString with "one two one three one"
    Replace the first "one" with "ONE"
    Replace the second "one" with "UNO" 
    Replace the third "one" with "EIN"
    Show it
}
#--> ONE two UNO three EIN

pf()

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
    Create a stzString with "connectors"
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

/*--- CHANGE OPERATION

pr()

Naturally() {
    Create a stzString with "change me"
    Change "me" to_ "this"
    Show the result
}
#--> change this

pf()

/*--- LAST POSITION REFERENCE

pr()

Naturally() {
    Make a stzString with "first middle last"
    Replace the last "s" with "S"
    Display it
}
#--> first middle laSt

pf()

/*--- MULTIPLE MODIFIERS

pr()

Naturally() {
    Create a stzString with "modifiers test"
    Uppercase it using spacify and_ also @box it
    The box@ must be rounded
    Show the final result
}
#--> ╭─────────────────────────────╮
#    │ M O D I F I E R S   T E S T │
#    ╰─────────────────────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*--- FRAME ALTERNATIVE

pr()

Naturally() {
    Make a stzString with "framed"
    Uppercase it and_ spacify it
    Frame@ it with rounded corners
    Display the result
}
#--> ╭─────────────╮
#    │ F R A M E D │
#    ╰─────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.23

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

/*--- EDGE CASE: NULL VALUES

pr()

Naturally() {
    Make a stzString with nothing
    Append "from nothing" to_ it
    Show it
}
#--> from nothing

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- COMPREHENSIVE TEST

pr()

Naturally() {
    Create a stzString with "comprehensive test case"
    Replace "comprehensive" with "complete"
    Uppercase it and spacify it  
    Then box it
    The box should be rounded
    Display the final result
}
#--> ╭─────────────────────────────────────╮
#    │ C O M P L E T E   T E S T   C A S E │
#    ╰─────────────────────────────────────╯

pf()
