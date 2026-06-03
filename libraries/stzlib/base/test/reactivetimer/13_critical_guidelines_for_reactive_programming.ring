# Narrative
# --------
# Critical guidelines for reactive programming:
#
# Extracted from stzreactivetimertest.ring, block #13.

load "../../stzBase.ring"

pr()

✅ DO USE:
- RunAfter() for delays
- RunEvery() for repeated actions  
- Non-blocking operations
- Event-driven patterns

❌ NEVER USE:
- Sleep() - blocks event loop
- Blocking I/O operations
- Busy wait loops (while true)
- Any synchronous delays

💡 REMEMBER:
- Reactive systems are event-driven
- Everything happens through timers and callbacks
- The event loop must stay free to process events
- Use Start() to begin processing, Stop() to end

pf()
