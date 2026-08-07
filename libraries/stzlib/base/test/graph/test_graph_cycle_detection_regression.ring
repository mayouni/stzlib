# Regression suite for HasCyclicDependencies() -- BOTH of its paths.
#
# WHY THIS FILE EXISTS
#
# HasCyclicDependencies() has two implementations: StzEngineGraphHasCycle()
# when the graph engine DLL is loaded, and a pure-Ring DFS underneath it
# when it is not. Every previous measurement of this method hit the engine,
# so the fallback carried three defects undisturbed (fixed 2026-08-07):
#
#   1. StzFindFirst(list, item) instead of the needle-first (item, list) --
#      the visited check never matched, so the DFS re-ran from every node.
#   2. The rec-stack pop used stzleft(), a STRING op, on a list -- R21 on
#      the first pop, so the fallback RAISED rather than answering.
#   3. It popped by REBINDING the parameter. Ring passes lists by reference,
#      so the caller's stack never shrank; a diamond would read as cyclic.
#
# The guard therefore runs every shape through BOTH paths and asserts they
# AGREE. A test that only exercised the engine would have passed against all
# three defects -- which is exactly how they survived.
#
# Run from base/test/graph/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== HasCyclicDependencies: engine and pure-Ring fallback ==="

# Each case: label, node ids, edges, expected verdict.
aCases = [
	[ "chain a->b->c",                 ["a","b","c"],         [["a","b"],["b","c"]],                            0 ],
	[ "diamond a->b,a->c,b->d,c->d",   ["a","b","c","d"],     [["a","b"],["a","c"],["b","d"],["c","d"]],        0 ],
	[ "longer reconvergence",          ["a","b","c","d","e"], [["a","b"],["b","d"],["a","c"],["c","e"],["e","d"]], 0 ],
	[ "two roots into one sink",       ["p","q","r"],         [["p","r"],["q","r"]],                            0 ],
	[ "isolated nodes, no edges",      ["a","b","c"],         [],                                               0 ],
	[ "real cycle a->b->c->a",         ["a","b","c"],         [["a","b"],["b","c"],["c","a"]],                  1 ],
	[ "self loop a->a",                ["a"],                 [["a","a"]],                                      1 ],
	[ "two-node loop x<->y",           ["x","y"],             [["x","y"],["y","x"]],                            1 ],
	[ "acyclic island + cyclic island",["p","q","r","s"],     [["p","q"],["r","s"],["s","r"]],                  1 ],
	[ "cycle reachable only via a tail",["a","b","c","d"],    [["a","b"],["b","c"],["c","d"],["d","b"]],        1 ]
]

# ------------------------------------------------------------
# Path 1 -- the engine
# ------------------------------------------------------------
? ""
? "--- Engine path ---"

pSaved = $pStzGraphHandle
chk("engine DLL is loaded (this path is really the engine)", isPointer($pStzGraphHandle))

aEngine = []
nCases = len(aCases)
for i = 1 to nCases
	nGot = CycleOf(aCases[i][2], aCases[i][3])
	aEngine + nGot
	chk("engine: " + aCases[i][1] + " -> " + aCases[i][4], nGot = aCases[i][4])
next

# ------------------------------------------------------------
# Path 2 -- the pure-Ring fallback
#
# _EngineAvailable() reads $pStzGraphHandle, so clearing it is what forces
# the fallback. Assert the switch actually happened before trusting a
# single result below it.
# ------------------------------------------------------------
? ""
? "--- Pure-Ring fallback path ---"

$pStzGraphHandle = NULL
chk("fallback is really engaged (handle cleared)", NOT isPointer($pStzGraphHandle))

for i = 1 to nCases
	nGot = CycleOf(aCases[i][2], aCases[i][3])
	chk("fallback: " + aCases[i][1] + " -> " + aCases[i][4], nGot = aCases[i][4])
	chk("both paths agree on: " + aCases[i][1], nGot = aEngine[i])
next

# ------------------------------------------------------------
# Defect 3, directly: the rec stack must SHRINK on the way out.
#
# A diamond visits d through b, backtracks, and reaches d again through c.
# If the pop does not reach the caller, d is still on the rec stack the
# second time and the graph reports a cycle. Asserting only the verdict of
# the diamond above would catch this; asserting the pop makes it obvious
# WHICH thing broke.
# ------------------------------------------------------------
? ""
? "--- Rec-stack pop reaches the caller ---"

aStack = ["a", "b", "c"]
PopIt(aStack)
chk("ring_del in a callee shrinks the caller's list", len(aStack) = 2)
chk("...and removes the LAST item",                   len(aStack) = 2 and aStack[2] = "b")

$pStzGraphHandle = pSaved

# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL CYCLE-DETECTION CHECKS PASSED!"
else
	? "SOME CYCLE-DETECTION CHECKS FAILED!"
ok

# Returns the verdict, or -1 if the call RAISED. Defect 2 raised rather
# than answering, and an unguarded raise takes the whole suite down before
# it can report -- so the failure would have read as "the harness is
# broken" instead of "the fallback is broken". -1 matches no expectation,
# so a raise lands as an ordinary FAIL on the line that caused it.
func CycleOf(acNodes, aEdges)
	nVerdict = -1
	try
		oG = new stzGraph("cyc")
		nN = len(acNodes)
		for nI = 1 to nN
			oG.AddNode(acNodes[nI])
		next
		nE = len(aEdges)
		for nI = 1 to nE
			oG.AddEdge(aEdges[nI][1], aEdges[nI][2])
		next
		nVerdict = oG.HasCyclicDependencies()
	catch
		nVerdict = -1
	done
	return nVerdict

func PopIt(paList)
	ring_del(paList, len(paList))

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
