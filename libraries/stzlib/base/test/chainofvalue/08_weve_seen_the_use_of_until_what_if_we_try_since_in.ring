# Narrative
# --------
# # We've seen the use of Until(), what if we try Since() instead...
#
# Extracted from stzchainofvaluetest.ring, block #8.

load "../../stzBase.ring"


# First thing to note is that Since() requires a StopValue() to stop
? Since(:v).Is("12").RequiresStopValue() #--> TRUE

# Therefore, if we provide a code in DoThis(), it's not executed:
? Since(:v).Is("12").DoThis('{ v += "0" ? v }').CodeStatus() #--> :NotYetExecuted

# And we can ask why it is the case, just after DoThis()...
? Since(:v).Is("12").DoThis('{ v += "0" ? v }').WhyCodeNotYetExecuted()
#-->	Because "Since(:v)" requires "DoThis(:v)" not to execute until
#	it knows where it should stop, using "StopWhen().Becomes()"!

# or we can ask the same question after StopWhen():
? Since(:v).Is("12").DoThis('{ v += "0" ? v }').StopWhen(:v).WhyCodeNotYetExecuted()

# This beeing understood, let's write a complete chain and see what it returns:
Since(:v).Is("12").DoThis('{ v += "0" ? v }').StopWhen(:v).Becomes("1200000")
#-->	[ "120", "1200", "12000", "120000", "1200000" ]
