# Narrative
# --------
# Named formats
#
# Extracted from stzdatetimetest.ring, block #49.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")
oDateTime {


	? ToStringXT(:Simple) # 12h by default	; can be written ToSimple()
	#--> 15/03/2024 2:30 PM

	? ToStringXT(:Simple12h) # Or ToSimple12h()
	#--> 15/03/2024 2:30 PM

	? ToStringXT(:Simple24h) + NL	# Or ToSimple24h()
	#--> 15/03/2024 14:30

	#---

	? ToLong()
	#--> Friday, March 15, 2024 2:30:45 PM

	? ToLong12h()
	#--> Friday, March 15, 2024 2:30:45 PM

	? ToLong24h() + NL
	#--> Friday, March 15, 2024 14:30

	#---

	? ToShort()
	#--> 15/03 2:30 PM

	? ToShort12h()
	#--> 15/03 2:30 PM

	? ToShort24h() + NL
	#--> 15/03 14:30 + NL

	#---

	? ToMedium()
	#--> Fri., March 15 2:30 PM

	? ToMedium12h()
	#--> Fri., March 15 2:30 PM

	? ToMedium24h()
	#--> Fri., March 15 14:30

}

pf()
# Executed in 0.02 second(s) in Ring 1.24
