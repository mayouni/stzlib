# Narrative
# --------
# #TODO
#
# Extracted from stzlocaletest.ring, block #37.

load "../../../stzBase.ring"


pr()

#TODO Add native name methods using the engine
//DayNativeName()
//DayNativeShortAbbreviation()
//DayNativeNarrowAbbreviation()
//MonthNativeName()
//MonthNativeShortAbbreviation()
//MonthNativeNarrowAbbreviation()

? o1.dayname(1,1)
#--> lun.

? o1.dayname(1,2)
#--> L

// This type is used when you need to enumerate months or weekdays.
// Usually standalone names are represented in singular forms with capitalized first letter.

? o1.monthname(1,0) #--> janvier
? o1.monthname(1,2) #--> J

pf()
# Executed in almost 0 second(s) in Ring 1.23
