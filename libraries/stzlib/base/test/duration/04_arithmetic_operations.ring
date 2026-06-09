# Narrative
# --------
# Arithmetic operations
#
# Extracted from stzdurationtest.ring, block #4.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

# Addition with numbers (seconds)
oDur1 = DurationQ("1 hour")
oDur2 = oDur1 + 1800  # Add 1800 seconds (30 minutes)
? oDur2.ToHuman()
#--> 1 hour and 30 minutes

# Addition with strings
oDur3 = oDur1 + "45 minutes"
? oDur3.ToHuman()
#--> 1 hour and 45 minutes

# Addition with duration objects
oDur4 = DurationQ("30 minutes")
oDur5 = oDur1 + oDur4
? oDur5.ToHuman()
#--> 1 hour and 30 minutes

# Subtraction
oDur6 = DurationQ("3 hours")
oDur7 = oDur6 - "1 hour 15 minutes"
? oDur7.ToHuman()
#--> 1 hour and 45 minutes

# Multiplication
oDur8 = DurationQ("45 minutes")
oDur9 = oDur8 * 3
? oDur9.ToHuman()
#--> 2 hours and 15 minutes

# Division
oDur10 = DurationQ("2 hours")
oDur11 = oDur10 / 4
? oDur11.ToHuman()
#--> 30 minutes

pf()
# Executed in 0.12 second(s) in Ring 1.24
