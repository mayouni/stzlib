# Narrative
# --------
# Parsing preserves original hour
#
# Extracted from stzdatetimetest.ring, block #58.

load "../../stzBase.ring"


pr()

oParsed = StzDateTimeQ("2024-03-15 14:30:45")

# Hours (24h)

? oParsed.Hours()
#--> 14

# Display 24h

? oParsed.ToString()
#--> 2024-03-15 14:30:45

# Display 12h

? oParsed.ToString12h()
#--> 2024-03-15 2:30:45 PM

pf() 
# Executed in 0.01 second(s) in Ring 1.24
