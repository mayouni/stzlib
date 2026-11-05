# Testoor -- NODE COUNTERS. Phase P3.4 of SOFTANZA_TESTOOR_ROADMAP.md, TESTOOR_PROTOCOL_2.md section 3.
#
# The NUMERATOR of graph coverage: how many times a tour reached each node of its program. A tour (or a
# hook acting for it) says so as it reaches a node, and at the end the counts are printed as
# `[testoor node ID N]` lines, which the verdict reads into the tour's nodes record (observed evidence).
#
#   TestoorNodeSlot(id)        register a node ONCE and answer its slot (1, 2, 3 ...), 0 for an id that holds
#                              a space or a control byte and so could not be read back from a line
#   TestoorNodeHit(slot)       one hit on that slot: the hot call, a number in and a number out
#   TestoorNodeHitN(slot, n)   n hits at once
#   TestoorNode(id)            one hit by id: a hash lookup more than a hit by slot
#   TestoorNodeN(id, n)        n hits by id
#   TestoorNodeCount(id)       the hits so far
#   TestoorNodesReport()       PRINT `[testoor node ID N]` for every node reached, in registration order,
#                              and answer how many lines it printed
#   TestoorNodesReset()        every count to zero; the slots stay valid (TestoorReset() does this too)
#
# WHY NOT A TRACE HOOK. The first design was Ring's per-line trace hook, which counts without the program
# asking. It costs 11.5 us an event on Ring 1.27 and does not exist on Ring++ (`ringvm_settrace` is R3 on
# rnxc, measured 2026-11-06). A counter called directly costs 0.15 us an event through Ring++: an empty
# Ring function call is 0.05 us and an engine call that takes and returns numbers is 0.15 us. So a hit by
# slot takes numbers only, nothing is allocated, and nothing is returned as a string. The rare calls
# (the report) return text.
#
# WHO KEEPS THE COUNTS. The Zig core does (engine/src/testoor_counters.zig), per thread, in the engine and
# never in a Ring object: Ring copies an object it stores and a copy would fork the counts. When the core
# is not loaded, or TestoorCore("ring") says so, two parallel Ring lists do it -- the REFERENCE, slow by
# comparison (a find in a list) and the same in every answer. Choose the core BEFORE a tour registers a
# node: a slot belongs to the implementation that gave it, and choosing again zeroes the counts.
#
# Locals are _underscored_; the globals below are read and written with the `$` prefix (Rule A).

# the reference's counts: ids and hits are parallel lists, slot k is the k-th of each
$aTestoorNodeIds = []
$aTestoorNodeHits = []

# -1 not decided, 1 the engine counts, 0 the reference does; decided once, and again after a reset
$nTestoorNodesEngine = -1

# the largest count a `[testoor node ID N]` line carries
$nTestoorNodeCap = 999999999999999

func _TestoorNodesDecide()
	$nTestoorNodesEngine = 0
	if TestoorCoreIs() = "engine"
		try
			StzEngineTestoorNodes("registered", "")
			$nTestoorNodesEngine = 1
		catch
			$nTestoorNodesEngine = 0
		done
	ok
	return $nTestoorNodesEngine

# forget what was counted and decide again who counts: called by TestoorReset() and TestoorCore()
func _TestoorNodesForget()
	$nTestoorNodesEngine = -1
	_n_ = len($aTestoorNodeHits)
	for _i_ = 1 to _n_
		$aTestoorNodeHits[_i_] = 0
	next
	if $bStzTestoorCore
		try
			StzEngineTestoorNodes("reset", "")
		catch
			_n_ = 0
		done
	ok
	return 1

#--- the hot calls ----------------------------------------------------------

func TestoorNodeSlot(pcId)
	if $nTestoorNodesEngine < 0  _TestoorNodesDecide()  ok
	if $nTestoorNodesEngine = 1  return StzEngineTestoorNodeSlot("" + pcId)  ok
	return _TestoorNodeSlotRing("" + pcId)

func TestoorNodeHit(pnSlot)
	if $nTestoorNodesEngine = 1  return StzEngineTestoorNodeHit(pnSlot)  ok
	if $nTestoorNodesEngine < 0  _TestoorNodesDecide()  return TestoorNodeHit(pnSlot)  ok
	return _TestoorNodeHitRing(pnSlot, 1)

func TestoorNodeHitN(pnSlot, pnHits)
	if $nTestoorNodesEngine < 0  _TestoorNodesDecide()  ok
	if $nTestoorNodesEngine = 1  return StzEngineTestoorNodeHit(pnSlot, pnHits)  ok
	return _TestoorNodeHitRing(pnSlot, pnHits)

func TestoorNode(pcId)
	if $nTestoorNodesEngine < 0  _TestoorNodesDecide()  ok
	if $nTestoorNodesEngine = 1  return StzEngineTestoorNodeHitId("" + pcId)  ok
	return _TestoorNodeHitRing(_TestoorNodeSlotRing("" + pcId), 1)

func TestoorNodeN(pcId, pnHits)
	if $nTestoorNodesEngine < 0  _TestoorNodesDecide()  ok
	if $nTestoorNodesEngine = 1  return StzEngineTestoorNodeHitId("" + pcId, pnHits)  ok
	return _TestoorNodeHitRing(_TestoorNodeSlotRing("" + pcId), pnHits)

#--- reading the counts -----------------------------------------------------

func TestoorNodeCount(pcId)
	if $nTestoorNodesEngine < 0  _TestoorNodesDecide()  ok
	if $nTestoorNodesEngine = 1  return 0 + StzEngineTestoorNodes("get", "" + pcId)  ok
	_n_ = ring_find($aTestoorNodeIds, "" + pcId)
	if _n_ = 0  return 0  ok
	return $aTestoorNodeHits[_n_]

# the lines of every node reached, in registration order, as one text; "" when none was reached
func TestoorNodesLines()
	if $nTestoorNodesEngine < 0  _TestoorNodesDecide()  ok
	if $nTestoorNodesEngine = 1  return StzEngineTestoorNodes("report", "")  ok
	_c_ = ""
	_n_ = len($aTestoorNodeIds)
	for _i_ = 1 to _n_
		if $aTestoorNodeHits[_i_] > 0
			if _c_ != ""  _c_ += char(10)  ok
			_c_ += "[testoor node " + $aTestoorNodeIds[_i_] + " " + $aTestoorNodeHits[_i_] + "]"
		ok
	next
	return _c_

# print them, so the runner reads them from the tour's output; answers how many lines were printed
func TestoorNodesReport()
	_c_ = TestoorNodesLines()
	if _c_ = ""  return 0  ok
	_acL_ = str2list(_c_)
	_n_ = len(_acL_)
	for _i_ = 1 to _n_
		? _acL_[_i_]
	next
	return _n_

func TestoorNodesReset()
	return _TestoorNodesForget()

#--- the reference ----------------------------------------------------------

# an id a `[testoor node ID N]` line can carry: not empty, no space, no control byte
func _TestoorNodeValidId(pcId)
	_n_ = len(pcId)
	if _n_ = 0  return 0  ok
	for _i_ = 1 to _n_
		if ascii(pcId[_i_]) <= 32  return 0  ok
	next
	return 1

func _TestoorNodeSlotRing(pcId)
	if NOT _TestoorNodeValidId(pcId)  return 0  ok
	_n_ = ring_find($aTestoorNodeIds, pcId)
	if _n_ > 0  return _n_  ok
	$aTestoorNodeIds + pcId
	$aTestoorNodeHits + 0
	return len($aTestoorNodeIds)

func _TestoorNodeHitRing(pnSlot, pnHits)
	if NOT isNumber(pnSlot)  return 0  ok
	if pnSlot < 1 or pnSlot > len($aTestoorNodeHits)  return 0  ok
	_nBy_ = pnHits
	if NOT isNumber(_nBy_) or _nBy_ < 0  _nBy_ = 0  ok
	_nNew_ = $aTestoorNodeHits[pnSlot] + _nBy_
	if _nNew_ > $nTestoorNodeCap  _nNew_ = $nTestoorNodeCap  ok
	$aTestoorNodeHits[pnSlot] = _nNew_
	return _nNew_
