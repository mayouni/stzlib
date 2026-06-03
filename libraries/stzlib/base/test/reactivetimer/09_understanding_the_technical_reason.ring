# Narrative
# --------
# Understanding the technical reason
#
# Extracted from stzreactivetimertest.ring, block #9.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

🔍 WHY Sleep() BREAKS REACTIVE CODE
The fundamental problem:

1. Sleep() is BLOCKING
   - Pauses the entire thread
   - No other code can execute
   - Timers cannot fire
   - Event loop cannot process

2. RunAfter() is NON-BLOCKING  
   - Schedules execution for later
   - Event loop continues running
   - Other timers can still fire
   - Auto-conclude timers work properly

3. Auto-conclude relies on timers
   - Uses internal timer to detect data gaps
   - Sleep() prevents this timer from running
   - Result: stream never concludes automatically

pf()
