# Narrative
# --------
# Custom format strings
#
# Extracted from stzdatetimetest.ring, block #48.

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToStringXT("yyyy.MM.dd HH:mm")
#--> 2024.03.15 14:30

? oDateTime.ToStringXT("dd-MM-yy hh:mm AP") # h and H both use 12-hour format here
#--> 15-03-24 02:30 PM

# Named format access
? oDateTime.ToStringXT(:RFC2822)
#--> 15 Mar 2024 14:30:45

? oDateTime.ToStringXT(:UnixLog)
#--> Mar 15 14:30:45

pf()
# Executed in 0.01 second(s) in Ring 1.23

#================================================#
# NORMALIZATION STRATEGY #TODO Write a narration #
#================================================#

/*
FOR SAFE DATA STORAGE AND INTERCHANGE:
Always use ISO formats:
- :ISO ~> Standard normalized format
- :ISO8601 ~> T-separated ISO format
- :ISOWithMs ~> When precision matters

These formats are:
1. Timezone-independent (always state clearly if UTC or local)
2. Unambiguous (YYYY-MM-DD is universal)
3. Sortable as strings
4. Parseable across systems

FOR DISPLAY TO USERS:
Use Standard, Verbose, or region-specific formats:
- :Standard ~> Common readable
- :European ~> DD/MM/YYYY format
- :American ~> MM/DD/YYYY format
- :Verbose ~> Full text for reports

Add 12h suffix for 12-hour display:
- :Standard12h
- :European12h
- :American12h
- :Verbose12h
