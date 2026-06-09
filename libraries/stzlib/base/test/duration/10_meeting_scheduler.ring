# Narrative
# --------
# Meeting Scheduler
#
# Extracted from stzdurationtest.ring, block #10.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

nMeetings = 3
oMeetingDuration = DurationQ("1 hour 30 minutes")
oBreakTime = DurationQ("15 minutes")


oTotalTime = (oMeetingDuration * nMeetings) + (oBreakTime * (nMeetings - 1))

# Meeting length
? oMeetingDuration.ToHuman()
#--> 1 hour and 30 minutes

# Break between meetings
? oBreakTime.ToHuman()
#--> 15 minutes

# Total time needed
? oTotalTime.ToHuman()
#--> 5 hours

# End time format
? oTotalTime.ToCompact()
#--> 5h

pf()
# Executed in 0.03 second(s) in Ring 1.24
