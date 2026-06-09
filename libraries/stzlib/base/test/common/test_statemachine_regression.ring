# Integration regression suite for stzStateMachine.
# Engine-backed finite-state machine. Covers init, AddState/Add States,
# AddTransition/AddTransitions, SetState/CurrentState, Send/Trigger,
# counts, edges.
#
# Run from base/common/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzStateMachine integration regression ==="

# ------------------------------------------------------------
# Construction
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oSm = new stzStateMachine("door")
chk("Name = 'door'",                oSm.Name() = "door")
chk("NumberOfStates initially 0",   oSm.NumberOfStates() = 0)
chk("NumberOfTransitions initially 0", oSm.NumberOfTransitions() = 0)

# Bad ctor input raises
bRaised = 0
try
	oBad = new stzStateMachine("")
catch
	bRaised = 1
done
chk("Empty name raises",            bRaised = 1)

# ------------------------------------------------------------
# AddState / AddStates
# ------------------------------------------------------------
? ""
? "--- States ---"

oSm.AddState("closed")
chk("After 1 AddState: 1 state",    oSm.NumberOfStates() = 1)

oSm.AddState("open")
chk("After 2 AddState: 2 states",   oSm.NumberOfStates() = 2)

# Bulk
oSm.AddStates([ "locked", "broken" ])
chk("After AddStates: 4 states",    oSm.NumberOfStates() = 4)

# ------------------------------------------------------------
# AddTransition / AddTransitions
# ------------------------------------------------------------
? ""
? "--- Transitions ---"

oSm.AddTransition("closed", "open_event", "open")
chk("After 1 transition: count=1",  oSm.NumberOfTransitions() = 1)

oSm.AddTransitions([
	[ "open",   "close_event", "closed" ],
	[ "closed", "lock_event",  "locked" ],
	[ "locked", "unlock_event", "closed" ]
])
chk("After AddTransitions: count=4", oSm.NumberOfTransitions() = 4)

# ------------------------------------------------------------
# SetState / CurrentState / Send
# ------------------------------------------------------------
? ""
? "--- State machine driving ---"

oSm.SetState("closed")
chk("CurrentState = closed",        oSm.CurrentState() = "closed")

oSm.Send("open_event")
chk("After open_event: open",       oSm.CurrentState() = "open")

oSm.Send("close_event")
chk("After close_event: closed",    oSm.CurrentState() = "closed")

oSm.Send("lock_event")
chk("After lock_event: locked",     oSm.CurrentState() = "locked")

# Trigger alias
oSm.Trigger("unlock_event")
chk("Trigger alias works",          oSm.CurrentState() = "closed")

# ------------------------------------------------------------
# Aliases for counts
# ------------------------------------------------------------
? ""
? "--- Count aliases ---"

chk("StateCount alias = 4",         oSm.StateCount() = 4)
chk("CountStates alias = 4",        oSm.CountStates() = 4)
chk("TransitionCount = 4",          oSm.TransitionCount() = 4)
chk("CountTransitions = 4",         oSm.CountTransitions() = 4)

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# State with no transitions
oNo = new stzStateMachine("idle_only")
oNo.AddState("idle")
oNo.SetState("idle")
chk("State without transitions",    oNo.CurrentState() = "idle")
chk("0 transitions count",          oNo.NumberOfTransitions() = 0)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzStateMachine CHECKS PASSED!"
else
	? "SOME stzStateMachine CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
