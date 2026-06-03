# Narrative
# --------
# #  Log File Analysis  #
#
# Extracted from stzRegexTest.ring, block #42.

load "../../stzBase.ring"

#---------------------#

pr()

logText = "
2024-01-12 10:15:30 [ERROR] Failed to connect: timeout
2024-01-12 10:15:35 [INFO] Retry attempt 1
2024-01-12 10:15:40 [ERROR] Connection refused"

o1 = new stzRegex("")

# Match error lines
o1.SetPattern("^.*\[ERROR\].*$")
? o1.MatchLinesIn(logText)
#--> TRUE

# Parse log entries with named groups

o1.SetPattern("(?<date>\d{4}-\d{2}-\d{2})\s+(?<time>\d{2}:\d{2}:\d{2})\s+\[(?<level>\w+)\]\s+(?<message>.+)")

if o1.MatchLinesIn(logText) and o1.HasNames()
    ? @@NL(o1.CaptureXT())
ok
#--> [
#	[ "date", "2024-01-12" ],
#	[ "time", "10:15:30" ],
#	[ "level", "ERROR" ],
#
#	[ "message", "Failed to connect: timeout
# 2024-01-12 10:15:35 [INFO] Retry attempt 1
# 2024-01-12 10:15:40 [ERROR] Connection refused" ]
#
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
