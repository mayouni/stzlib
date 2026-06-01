# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #40.

load "../../../stzBase.ring"


o1 = new stzString( "ALLAH" )
? o1.HowManySubStrings()
#--> 15

? @@( o1.SubStringsOccurringOnlyNTimes(1) ) + NL
#--> [ "AL", "ALL", "ALLA", "ALLAH", "LL", "LLA", "LLAH", "LA", "LAH", "AH", "H" ]

? @@( o1.SubStringsOccurringNTimes(2) )
#--> [ "A", "L" ]

? HwoMany( o1.SubStringsOccurringNTimes(7) ) #NOTE //that "HwoMany" is misspelled
#--> 0

? HowMany( o1.SubStringsOccurringLessThanNTimes(3) )
#--> 13

? @@( Some( o1.SubStringsOccurringLessThanNTimes(3) ) )
#--> [ "ALLA", "L", "LLA", "LA" ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.19

#=====

# #narration: function active and passive forms (discussion with Mahmoud)

pr()

# The RemoveBounds() function exists and it acts on the object
# on place and changes its value, like this:

o1 = new stzString("<<Go!>>")
o1.RemoveBounds()
? o1.Content()
#--> "Go!"

# This is called the @FunctionActiveForm , while BoundsRemoved()
# is called the @FunctionPassiveForm.

# Typically, the first active form is used to sculpture the object
# at your will, action after action, like for example:

StzStringQ( "<<Go!>>") {
        RemoveBounds()
        Uppercase()
        AddBounds([ "~", "~" ])
        # and so on...
        ? Content()
        #--> "~GO!~"
}

# While the passive form is used to return the final result of the
# function WITHOUT altering the object value. Hence when we say:

o1 = new stzString("<<Go!>>")
? o1.BoundsRemoved()
#--> "Go!"
? o1.Content()
#--> <<Go!>>

# The value of the object won't be changed after BoundsRemoved() is used.

pf()
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.29 second(s) in Ring 1.19
