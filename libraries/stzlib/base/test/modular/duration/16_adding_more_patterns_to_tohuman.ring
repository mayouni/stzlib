# Narrative
# --------
# Adding more patterns to ToHuman()
#
# Extracted from stzdurationtest.ring, block #16.

load "../../../stzBase.ring"


pr()

# Global pattern container (defined once in your application)

? @@NL($aDurationPatterns) + NL
#--> [
#    [365, 23, 59, 59, "1 year"],
#    [183, 23, 59, 59, "6 months"],
#    [30, 23, 59, 59, "1 month"],
#    [7, 0, 0, 0, "1 week"],
#    [14, 0, 0, 0, "2 weeks"]
# ]

# Now durations matching these patterns display specially
o1 = new stzDuration("365 days 23 hours 59 minutes 59 seconds")
? o1.ToHuman()
#--> 1 year

o1 = new stzDuration("7 days")
? o1.ToHuman() + NL
#--> 1 week

# Non-matching durations fall back to component-based format
o1 = new stzDuration("8 days")
? o1.ToHuman()
#--> 8 days

# Add domain-specific patterns for your application
$aDurationPatterns + [90, 0, 0, 0, "1 quarter"]
$aDurationPatterns + [1, 0, 0, 0, "1 business day"]

o1 = new stzDuration("90 days")
? o1.ToHuman()
#--> 1 quarter

? StzDurationQ("1 day").ToHuman()
#--> 1 business day

pf()
# Executed in 0.17 second(s) in Ring 1.24
