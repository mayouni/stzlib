# Narrative
# --------
# What you learned with these examples:
#
# Extracted from stzreactivetimertest.ring, block #1.

load "../../stzBase.ring"


1. **RunAfter**: One-time execution after delay
   - RunAfter(function, milliseconds)
   - Perfect for delayed actions

2. **RunEvery**: Repeated execution at intervals  
   - RunEvery(function_name, milliseconds)
   - Perfect for periodic tasks
   - Always remember to StopTimer() to stop it!

3. **Scope Management**: Variables must be accessible to callbacks
   - Use global-level variables, or
   - Use object properties with Method() calls

4. **Timer Coordination**: Multiple timers can work together
   - Each timer runs independently
   - Use RunAfter to stop intervals after a certain time

5. **Reactive Streams + Timers**: Powerful combination
   - Timers generate data
   - Streams distribute data to subscribers
   - Creates real-time data processing pipelines

6. **Always Clean Up**: Prevent infinite loops
   - StopTimer() to stop repeating timers
   - reactive.Stop() to shut down the engine
   - Proper cleanup prevents resource leaks

7. Never use Ring sleep() function inside the Reactive System

Other timer-based applications can be:
- A digital clock display
- A countdown timer
- A simple animation system
- A data polling system for APIs

