# GS6d -- the UMAP graph outlives the fit (SOFTANZA_GPU_PLAN.md GS6d; after
# Nolet et al. 2021: of 9.5 min at 3M points, all that was not the k-NN graph
# took 9.3 s, so they let the graph be kept and tuned the layout in seconds).
#
# stzUMAP.Fit() builds the neighbour graph -- the k-NN, the local metric, the
# fuzzy union, supervision -- ONCE, in the engine, under a handle the object
# keeps; every later Fit() with a new min_dist, spread, epochs, seed, dims or
# density setting is the layout alone. Anything that reshapes the graph (the
# neighbour count, the labels, the target weight, the PCA width) drops it and
# the next Fit() rebuilds. ReleaseGraph() gives it back by hand.
#
# What this guard asserts, mechanism first, negative sibling beside each:
#   - the first Fit() builds one graph (the engine's build counter moves once)
#     and the object holds it; a second Fit() with a new min_dist builds NONE
#     and answers a different embedding; a third with the first settings
#     answers the FIRST embedding bit for bit; a fresh object answers it too
#     (a resident graph changes nothing about the fit)
#   - SetNeighbors drops the graph and the next Fit() builds; ReleaseGraph too
#   - a refit is faster than a fit at 16,384 x 8 by the graph's whole cost
#   - the density term composes with a resident graph

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

decimals(4)

nD = 8
nN = 4000
aData = blobs(nN, nD)

? "-- Scene 1: one graph, many layouts --"
nB0 = StzEngineUmapGraphBuilds()
oU = new stzUMAP(aData)
oU.SetEpochs(100)
oU.SetSeed(7)
chk("before any fit the object holds no graph", NOT oU.HasGraph() and len(oU.GraphInfo()) = 0)
oU.Fit()
aE1 = oU.Embedding()
chk("the first Fit() built ONE graph and the object holds it", StzEngineUmapGraphBuilds() = nB0 + 1 and oU.HasGraph())
aInfo = oU.GraphInfo()
? "  graph: " + aInfo[1] + " points x " + aInfo[2] + ", " + aInfo[3] + " neighbours, " + aInfo[4] + " edges"
chk("GraphInfo names the data and the neighbour count", aInfo[1] = nN and aInfo[2] = nD and aInfo[3] = 15 and aInfo[4] > nN)
oU.SetMinDistance(0.8)
oU.Fit()
aE2 = oU.Embedding()
chk("a second Fit() with a new min_dist built NO graph", StzEngineUmapGraphBuilds() = nB0 + 1)
chk("...and its embedding differs (min_dist is live on the resident graph)", aE2[1][1] != aE1[1][1] or aE2[2][2] != aE1[2][2])
oU.SetMinDistance(0.1)
oU.Fit()
aE3 = oU.Embedding()
chk("a third Fit() with the first settings built no graph either", StzEngineUmapGraphBuilds() = nB0 + 1)
chk("...and answers the FIRST embedding bit for bit", sameEmbedding(aE1, aE3))
oFresh = new stzUMAP(aData)
oFresh.SetEpochs(100)
oFresh.SetSeed(7)
oFresh.Fit()
chk("a fresh object (its own graph) answers the same embedding: residency changes nothing", sameEmbedding(aE1, oFresh.Embedding()))
chk("...and that cost one more graph", StzEngineUmapGraphBuilds() = nB0 + 2)

? ""
? "-- Scene 2: what reshapes the graph drops it --"
oU.SetNeighbors(10)
chk("SetNeighbors drops the graph", NOT oU.HasGraph())
oU.Fit()
chk("...and the next Fit() builds it again, with 10 neighbours", StzEngineUmapGraphBuilds() = nB0 + 3 and oU.GraphInfo()[3] = 10)
oU.ReleaseGraph()
chk("ReleaseGraph() gives it back", NOT oU.HasGraph())
oU.SetSeed(8)
oU.Fit()
chk("...and a Fit() after it builds (a seed alone would not have)", StzEngineUmapGraphBuilds() = nB0 + 4)
oU.SetSeed(9)
oU.Fit()
chk("the seed alone: no build", StzEngineUmapGraphBuilds() = nB0 + 4)

? ""
? "-- Scene 3: the density term composes with a resident graph --"
oD = new stzUMAP(aData)
oD.SetEpochs(100)
oD.SetSeed(7)
oD.Fit()
nBd = StzEngineUmapGraphBuilds()
oD.PreserveDensity()
oD.Fit()
chk("PreserveDensity() then Fit(): no new graph (the density target is built from the resident one)", StzEngineUmapGraphBuilds() = nBd)
chk("...and the fit is density-preserving: a correlation, and a radius per point", isNumber(oD.DensityCorrelation()) and len(oD.LocalRadii()) = nN)

? ""
? "-- Scene 4: a refit costs the layout, not the graph -- 16,384 x 8 --"
nBig = 16384
aBig = blobs(nBig, nD)
oB = new stzUMAP(aBig)
oB.SetEpochs(200)
oB.SetSeed(7)
nT0 = StzEngineWatchTimestampNs()
oB.Fit()
nFit = (StzEngineWatchTimestampNs() - nT0) / 1000000
oB.SetMinDistance(0.5)
nT0 = StzEngineWatchTimestampNs()
oB.Fit()
nRefit = (StzEngineWatchTimestampNs() - nT0) / 1000000
? "  first fit (graph + layout) " + nFit + " ms   refit (layout) " + nRefit + " ms   = " + (nFit / nRefit) + "x"
chk("the refit is at least 2x cheaper than the fit", nFit / nRefit >= 2)
chk("...with the graph still resident", oB.HasGraph() and oB.GraphInfo()[1] = nBig)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func sameEmbedding aA, aB
	if len(aA) != len(aB) return FALSE ok
	_n_ = len(aA)
	for _i_ = 1 to _n_
		if aA[_i_][1] != aB[_i_][1] or aA[_i_][2] != aB[_i_][2] return FALSE ok
	next
	return TRUE

# four blobs in nDim dims, deterministic
func blobs nN_, nDim
	_a_ = []
	for _i_ = 1 to nN_
		_b_ = (_i_ - 1) % 4
		_r_ = []
		for _k_ = 1 to nDim
			_r_ + (_b_ * 4 * ((_k_ + _b_) % 2) + sin(_i_ * 0.731 + _k_ * 1.37) * 0.5)
		next
		_a_ + _r_
	next
	return _a_
