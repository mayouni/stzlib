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

/*--- MULTIPLE REPLACEMENTS

pr()

Naturally() {

    Create a stzString with "abracadabra"
    Replace the first "a" with "A"
    Replace the second 'a' with 'B' 
    Replace the fourth 'a' with 'C'
    Replace the fifth 'a' with 'D'

    Show it
    #--> AbracBdCbrD

    # You can debug the internal code generated using
    ? Code()
    # oStr = StzStringQ("abracadabra")
    # oStr.ReplaceNth(1, "a", "A")
    # oStr.ReplaceNth(2, "a", "B")
    # oStr.ReplaceNth(4, "a", "C")
    # oStr.ReplaceNth(5, "a", "D")
    # ? oStr.Content()

}

pf()
# Executed in 0.03 second(s) in Ring 1.23

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
# Executed in 0.01 second(s) in Ring 1.23

/*--- INSERTION OPERATIONS #ERR

pr()

Naturally() {
    Create a stzString with "hello world"
    Insert " beautiful" at position 6
    Show it
}
#--> should show "hello beautiful world"

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- TRIMMING OPERATIONS

pr()

Naturally() {
    Make a stzString with "  spaced text  "
    Trim it and_ uppercase it
    Display the result
}
#--> SPACED TEXT

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

/*--- EMPTY OBJECT HANDLING

pr()

Naturally() {
    Create a stzString object with nothing inside
    Append it with the substring "added content"
    Uppercase it
    Display the result
}
#--> should show "ADDED CONTENT"

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

/*---

pr()

Naturally() {
    Make a stzString with "reference test"

    Uppercase this_
    Spacify that
    @Box this_
    The box@ is rounded

    Show the final result
}
#--> ╭─────────────────────────────╮
#    │ R E F E R E N C E   T E S T │
#    ╰─────────────────────────────╯

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

/*--- LAST POSITION REFERENCE

pr()

Naturally() {
    Make a stzString with "first middle last"
    Replace the last "s" with "S"
    Display it
}
#--> first middle laSt

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- MULTIPLE MODIFIERS

pr()

Naturally() {
    Create a stzString with "softanza is great"
    Uppercase it using spacify and_ also @box it
    The box@ must be rounded
    Show the final result
}
#--> ╭───────────────────────────────────╮
#    │ S O F T A N Z A   I S   G R E A T │
#    ╰───────────────────────────────────╯

pf()
# Executed in 0.01 second(s) in Ring 1.23

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
# Executed in 0.01 second(s) in Ring 1.23

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
# Executed in 0.01 second(s) in Ring 1.23

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
    Uppercase it and_ spacify it  
    Then @box it
    The box@ should be rounded
    Display the final result
}
#--> ╭─────────────────────────────────────╮
#    │ C O M P L E T E   T E S T   C A S E │
#    ╰─────────────────────────────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.23

#==================================#
#  SEMANTIC PRE-PROCESSING TESTS   #
#==================================#

/*--- MIXED OPERATIONS WITH SEMANTIC PREPROCESSING

pr()

Naturally() {
    Make a stzString with "test case test"
    Replace the first "test" with "first"
    Uppercase it
    Replace the second "TEST" with "SECOND"  # Note: after uppercase
    Spacify it
    Display the result
}
#--> F I R S T   C A S E   T E S T

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- LAST POSITION HANDLING

pr()

Naturally() {
    Create a stzString with "one two three one four one"
    Replace the first "one" with "1st"
    Replace the last "one" with "LAST"
    Replace the second "one" with "2nd" 
    Show it
}
#--> "1st two three 2nd four LAST"

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- MULTIPLE TARGET STRINGS

pr()

Naturally() {
    Make a stzString with "cat dog cat bird cat dog"
    Replace the first "cat" with "CAT1"
    Replace the first "dog" with "DOG1" 
    Replace the second "cat" with "CAT2"
    Replace the second "dog" with "DOG2"
    Replace the third "cat" with "CAT3"
    Display the result
}
#--> "CAT1 DOG1 CAT2 bird CAT3 DOG2"

pf()
# Executed in 0.02 second(s) in Ring 1.23

/*--- EDGE CASE: Non-existent positions

pr()

Naturally() {
    Create a stzString with "only one occurrence"
    Replace the first "occurrence" with "FIRST"
    Replace the second "occurrence" with "SECOND"  # Should be ignored
    Replace the third "occurrence" with "THIRD"    # Should be ignored
    Show it
}
#--> "only one FIRST" (only valid replacements applied)

pf()

/*--- MIXED GLOBAL AND POSITIONAL

pr()

Naturally() {
    Make a stzString with "apple banana apple cherry apple"
    Replace "banana" with "BANANA"              # Global replace
    Replace the first "apple" with "APPLE1"     # Positional  
    Replace the second "apple" with "APPLE2"    # Positional
    Show the result
}
#--> "APPLE1 BANANA APPLE2 cherry apple"

pf()
# Executed in 0.01 second(s) in Ring 1.23
