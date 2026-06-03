# Narrative
# --------
# #  Date/Time Processing  #
#
# Extracted from stzRegexTest.ring, block #45.

load "../../stzBase.ring"

#------------------------#

pr()

dateText = "Important dates: 2024-01-12, 01/12/2024, Jan 12, 2024"

o1 = new stzRegex("")

# Match various date formats

o1.SetPattern("\d{4}-\d{2}-\d{2}|\d{2}/\d{2}/\d{4}|[A-Z][a-z]{2}\s+\d{1,2},\s+\d{4}")

? o1.Match(dateText)
#--> TRUE

# Parse specific date format

o1.SetPattern("(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})")

if o1.Match(dateText) and o1.HasNames()
    ? @@NL( o1.CaptureXT() )
ok
#--> [
#	[ "year", "2024" ],
#	[ "month", "01" ],
#	[ "day", "12" ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

pf()
