# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #494.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "R", "I", "N", "G" ])

if o1.IsNotAString() and
   o1.IsNotInLowercase() and
   o1.DoesNotContain("♥") and

   o1.NumberOfChars() < 5 and
   o1.NumberOfCharsQ().IsNotOdd()

    ? "It's ok!"
else  
    ? "Oops!"
ok
#--? "It's ok!"

# Let's see the negative conditions one by one

? o1.IsNotAString()
#--> TRUE

? o1.IsNotInLowercase()
#--> TRUE

? o1.DoesNotContain("♥")
#--> TRUE

? o1.NumberOfChars() < 5
#--> TRUE

? o1.NumberOfCharsQ().IsNotOdd()
#--> TRUE

pf()
# Executed in 0.06 second(s) in Ring 1.22
