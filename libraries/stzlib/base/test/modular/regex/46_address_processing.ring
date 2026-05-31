# Narrative
# --------
# #  Address Processing  #
#
# Extracted from stzRegexTest.ring, block #46.

load "../../../stzBase.ring"

#----------------------#

pr()

addressText = "John Doe
123 Main St, Apt 4B
New York, NY 10001
USA"

o1 = new stzRegex("")

# Match ZIP code

o1.SetPattern("\d{5}(-\d{4})?")

? o1.MatchLinesIn(addressText) + NL
#--> TRUE

# Parse address components

o1.SetPattern("(?<street>\d+[^,]+),\s*(?<unit>[^,\n]+)\n(?<city>[^,]+),\s*(?<state>[A-Z]{2})\s*(?<zip>\d{5})")

if o1.Match(addressText) and o1.HasNames()
    ? @@NL(o1.CaptureXT())
ok
#--> [
#	[ "street", "123 Main St" ],
#	[ "unit", "Apt 4B" ],
#	[ "city", "New York" ],
#	[ "state", "NY" ],
#	[ "zip", "10001" ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
