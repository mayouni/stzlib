load "../stzbase.ring"

# === MODERNIZED TEST RUNNER ===
# Each original block now runs in its own try/catch.
# Failures are caught and counted; the harness reports
# overall pass/fail at the end.

_nMtBlocksTotal = 0
_nMtBlocksPass  = 0
_nMtBlocksFail  = 0
_aMtFails       = []

# --- Block 1 ---
_nMtBlocksTotal++
try
	o1 = new stzCounter([
		:StartAt = 1,
		:AfterYouSkip = 9,	# or :WhenYouReach = 10
		:RestartAt = 0,
		:Step = 1
	])
	
	? @@( o1.Counting( :To = 13 ) ) + NL
	#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3 ]
	
	? o1.CountingXT( :To = 13, :AndReturning = :Last)
	#--> 3
	
	? o1.CountXT( :To = 13, :AndReturnNth = 12)
	#--> 2
	_nMtBlocksPass++
catch
	_nMtBlocksFail++
	_aMtFails + [ 1, cCatchError ]
done

# --- Block 2 ---
_nMtBlocksTotal++
try
	o1 = new stzCounter([
		:StartAt = 1,
		:WhenYouReach = 5,
		:RestartAt = 1
	])
	
	? @@( o1.CountTo(9) )
	#--> [ 1, 2, 3, 4, 1, 2, 3, 4, 1 ]
	
	? o1.CountToXT(9, :ReturnNth = 7)
	#--> 3
	_nMtBlocksPass++
catch
	_nMtBlocksFail++
	_aMtFails + [ 2, cCatchError ]
done

# --- Block 3 ---
_nMtBlocksTotal++
try
	o1 = new stzCounter([
		:StartAt = 1,
		:WhenYouReach = 5,
		:RestartAt = 2
	])
	
	? @@( o1.CountTo(9) )
	#--> [ 1, 2, 3, 4, 2, 3, 4, 2, 3 ]
	
	? o1.CountToXT(9, :ReturnNth = 7)
	#--> 4
	_nMtBlocksPass++
catch
	_nMtBlocksFail++
	_aMtFails + [ 3, cCatchError ]
done

# --- Block 4 ---
_nMtBlocksTotal++
try
	# Raw Ring loops (more performant)
	
	
	anResults = []
	for i = 1 to 1000000
	    nValue = ((i-1) % 4) + 1  # Cycle 1-4
	    anResults + nValue
	next
	_nMtBlocksPass++
catch
	_nMtBlocksFail++
	_aMtFails + [ 4, cCatchError ]
done

# --- Block 5 ---
_nMtBlocksTotal++
try
	# Softanza stzCount
	
	
	# stzCounter generating complete sequence
	
	oCounter = new stzCounter([
	    :StartAt = 1,
	    :WhenYouReach = 4,
	    :RestartAt = 1
	])
	anCounterResults = oCounter.CountTo(1000000)
	_nMtBlocksPass++
catch
	_nMtBlocksFail++
	_aMtFails + [ 5, cCatchError ]
done

? "============================="
? "Blocks total : " + _nMtBlocksTotal
? "Blocks pass  : " + _nMtBlocksPass
? "Blocks fail  : " + _nMtBlocksFail
if _nMtBlocksFail > 0
	? ""
	? "FAILURES:"
	for _aMtF in _aMtFails
		? "  Block " + _aMtF[1] + ": " + _aMtF[2]
	next
ok