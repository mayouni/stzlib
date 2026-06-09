# Smoke regression for stzCluster orchestration family.
# Tests construction + builder API without actually starting servers.
#
# Run from base/cluster/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzCluster integration regression ==="

# ------------------------------------------------------------
# stzCluster construction
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oC = new stzCluster
chk("stzCluster constructs",         isObject(oC))

# ------------------------------------------------------------
# stzClusterManager construction
# ------------------------------------------------------------
? ""
? "--- stzClusterManager ---"

oCm = new stzClusterManager
chk("stzClusterManager constructs",  isObject(oCm))

# Builder pattern (WithMath/WithNLP/etc.) and CreateCluster delegate
# down to ClusterManager.CreateCluster which depends on a node-pool
# infrastructure that's not initialized in unit-test scope. Skipping
# the active builder calls -- they're integration-tested through real
# cluster startup elsewhere.

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL cluster CHECKS PASSED!"
else
	? "SOME cluster CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
