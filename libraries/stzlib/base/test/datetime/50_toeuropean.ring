# Narrative
# --------
# pr()
#
# Extracted from stzdatetimetest.ring, block #50.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

oDateTime {

	? ToEuropean()
	#--> 15/03/2024 2:30:45 PM

	? ToEuropean12h()
	#--> 15/03/2024 2:30:45 PM

	? ToEuropean24h() + NL
	#--> 15/03/2024 14:30:45

	#---

	? ToAmerican()
	#--> 03/15/2024 2:30:45 PM

	? ToAmerican12h()
	#--> 03/15/2024 2:30:45 PM

	? ToAmerican24h() + NL
	#--> 03/15/2024 14:30:45

	#---

	? ToISO()
	#--> 2024-03-15 2:30:45 PM

	#--

	? ToStandard()
	#--> 15/03/2024 2:30:45 PM

	? ToStandard12h()
	#--> 15/03/2024 2:30:45 PM

	? ToStandard24h() + NL
	#--> 15/03/2024 14:30:45

	#--

	? ToVerbose()
	#--> Friday, March 15, 2024 2:30:45 PM

	? ToVerbose12h()
	#--> Friday, March 15, 2024 2:30:45 PM

	? ToVerbose24h()
	#--> Friday, March 15, 2024 14:30:45

}

pf()
# Executed in 0.03 second(s) in Ring 1.24
