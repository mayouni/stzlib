load "../../stzBase.ring"
load "../_narrated.ring"

# t-SNE AND UMAP, ON TOP OF PCA.
#
# PCA answers "which directions carry the most variance" with a map that is LINEAR,
# DETERMINISTIC and REVERSIBLE. t-SNE and UMAP answer a different question -- "which
# points are NEAR each other" -- and pay for it with a map that is nonlinear,
# stochastic and one-way. They exist to make a PICTURE, and a picture is exactly the
# kind of output that invites over-reading, so most of the care here is about saying
# what it does and does not mean.
#
# WHY PCA FIRST. The standard pipeline is PCA to 30-50 dimensions, then the nonlinear
# step to 2. It helps twice and costs once:
#
#   + SPEED. Both algorithms work from pairwise distances, and a distance costs time
#     linear in the dimension. 784 features down to 30 is 25x off that term.
#   + NOISE. In high dimensions distance is dominated by the accumulated noise of
#     hundreds of weak features -- everything drifts equidistant and the
#     neighbourhoods the embedding is built from stop meaning anything.
#   - LINEARITY. PCA is linear, so structure living entirely in the discarded
#     components is gone before the nonlinear step sees it. The guard is to keep
#     enough components, and PCAQ() below reports how much variance survived.
#
# HOW TO READ THE OUTPUT, which is where people go wrong:
#
#   * DISTANCES ARE NOT MEANINGFUL. Clusters drawn far apart are not "more different"
#     than clusters drawn close. Both algorithms optimise a neighbourhood
#     probability, not a distance.
#   * CLUSTER SIZES ARE NOT MEANINGFUL. A tight group and a diffuse one can come out
#     the same size; the kernels deliberately expand dense regions.
#   * THE PARAMETERS ARE THE QUESTION. Perplexity and n_neighbors dial between local
#     detail and global shape, and there is no correct value.
#   * IT IS STOCHASTIC, so the seed is an input.
#
# WHAT IS ACTUALLY TESTABLE about a stochastic embedding, since "does it look right"
# is not:
#
#     the OBJECTIVE goes down                       (t-SNE reports its KL per step)
#     well-separated clusters STAY separated        (a property, not a picture)
#     the same seed gives the same answer           (reproducibility is a law here)
#     the internal identities hold                  (perplexity search, local metric)
#     the fitted curve matches its published values (UMAP's a and b)

Scenario("t-SNE keeps clusters that were already separate -- GIVEN ENOUGH ITERATIONS")
	# Three tight blobs 30 units apart in 6 dimensions. Whether they are clusters is
	# not in question, so the embedding can be held to preserving them: the mean
	# distance WITHIN a group must be far below the mean distance BETWEEN groups.
	#
	# AND THE ITERATION COUNT IS NOT A DETAIL. Measured on this data, the separation
	# ratio is 1.11 after 300 iterations, 1.88 after 500 and 5.20 after 800. At 300
	# the groups are still overlapping -- the picture would look like one cloud, and
	# nothing about it would say "not finished yet". A caller reading a t-SNE plot is
	# reading an OPTIMISATION IN PROGRESS unless it has been run long enough, which
	# is what KLHistory() is for.
	aD = Blobs(12, 6)
	oT = new stzTSNE(aD)
	oT.SetPerplexity(5)
	oT.SetIterations(800)
	oT.Fit()

	Then("it produced one row per sample", len(oT.Embedding()), 36)
	Then("...of two coordinates", len(oT.Embedding()[1]), 2)
	Then("every coordinate is a real number", AllFinite(oT.Embedding()), TRUE)
	Then("the three groups stay apart", SeparationRatio(oT.Embedding(), 12) > 3, TRUE)

	# and the progression itself, pinned, because it is the thing that surprises
	oShort = new stzTSNE(aD)
	oShort.SetPerplexity(5)
	oShort.SetIterations(300)
	oShort.Fit()
	Then("...where 300 iterations had NOT yet separated them",
	     SeparationRatio(oShort.Embedding(), 12) < 2, TRUE)
	Then("...so more iterations means more separation here",
	     SeparationRatio(oT.Embedding(), 12) >
	     SeparationRatio(oShort.Embedding(), 12), TRUE)
EndScenario()

Scenario("UMAP reaches the same separation in far less work")
	# The comparison worth having, and one of UMAP's genuine claims. On the same
	# data: t-SNE needs 800 iterations to reach a ratio above 3; UMAP is near 10
	# after 300 epochs. Not a statement that UMAP is better -- they answer slightly
	# different questions -- but the effort is not comparable.
	aD = Blobs(12, 6)
	oU = new stzUMAP(aD)
	oU.SetNeighbors(5)
	oU.SetEpochs(300)
	oU.Fit()
	Then("UMAP separates them well at 300 epochs",
	     SeparationRatio(oU.Embedding(), 12) > 3, TRUE)

	oT = new stzTSNE(aD)
	oT.SetPerplexity(5)
	oT.SetIterations(300)
	oT.Fit()
	Then("...where t-SNE at 300 iterations has not",
	     SeparationRatio(oT.Embedding(), 12) < 2, TRUE)
EndScenario()

Scenario("...and its objective goes DOWN, which is the only proof it optimised")
	aD = Blobs(12, 6)
	oT = new stzTSNE(aD)
	oT.SetPerplexity(5)
	oT.SetIterations(500)
	oT.Fit()

	aKL = oT.KLHistory()
	Then("one KL per iteration", len(aKL), 500)
	# compare AFTER early exaggeration ends at iteration 250 -- while P is being
	# multiplied by 12 the objective is a different one, so a drop across that
	# boundary would prove nothing
	Then("the KL falls over the second half", aKL[500] < aKL[300], TRUE)
	Then("...and a KL divergence is never negative", aKL[500] >= 0, TRUE)
	Then("FinalKL is the last of them", oT.FinalKL(), aKL[500])
EndScenario()

Scenario("UMAP keeps them apart too, and fits its own curve")
	aD = Blobs(12, 6)
	oU = new stzUMAP(aD)
	oU.SetNeighbors(5)
	oU.SetEpochs(300)
	oU.Fit()

	Then("one row per sample", len(oU.Embedding()), 36)
	Then("every coordinate is finite", AllFinite(oU.Embedding()), TRUE)
	Then("the three groups stay apart", SeparationRatio(oU.Embedding(), 12) > 2, TRUE)

	# THE CURVE PARAMETERS ARE FITTED, NOT TABULATED. UMAP's low-dimensional
	# similarity is 1/(1 + a*d^(2b)), and a and b are found by least squares so the
	# curve matches the shape implied by min_dist -- a job handed to the L-BFGS built
	# in phase 6. The published reference values for min_dist 0.1 and spread 1.0 are
	# a = 1.577, b = 0.895, and an independent fit landing there is a real check on
	# both the fit and the optimiser.
	aC = oU.CurveParameters()
	Then("the fitted a matches the published 1.577", Rnd2(aC[:a]), 1.58)
	Then("...and b the published 0.895", Rnd2(aC[:b]), 0.9)
EndScenario()

Scenario("the PCA pre-step, which is what 'on top of PCA' means")
	aD = Blobs(12, 6)

	oT = new stzTSNE(aD)
	oT.ReduceWithPCA(3)
	oT.SetPerplexity(5)
	oT.SetIterations(800)
	oT.Fit()

	Then("it says it used PCA", oT.UsesPCA(), TRUE)
	Then("...and the inner analysis is there to inspect",
	     oT.PCAQ().NumberOfComponents() >= 3, TRUE)
	# THE POINT OF INSPECTING IT: PCA is linear, so anything living entirely in the
	# discarded components is gone before t-SNE sees it. The retained variance is how
	# you know whether that mattered.
	Then("...reporting how much variance survived",
	     oT.PCAQ().CumulativeVarianceRatio()[3] > 0.9, TRUE)
	Then("the clusters survive the reduction too",
	     SeparationRatio(oT.Embedding(), 12) > 3, TRUE)

	# and skipping it is equally explicit
	oS = new stzTSNE(aD)
	oS.SkipPCA()
	Then("SkipPCA turns it off", oS.UsesPCA(), FALSE)

	# asking for more components than there are features passes the data through
	# rather than inventing dimensions
	oM = new stzUMAP(aD)
	oM.ReduceWithPCA(99)
	oM.SetNeighbors(4)
	oM.SetEpochs(100)
	oM.Fit()
	Then("more components than features is not an error", oM.IsFitted(), TRUE)
EndScenario()

Scenario("reproducible by seed, because a picture nobody can redraw is not evidence")
	aD = Blobs(8, 4)

	o1 = new stzTSNE(aD)
	o1.SetPerplexity(4)
	o1.SetIterations(120)
	o1.SetSeed(7)
	o1.Fit()
	o2 = new stzTSNE(aD)
	o2.SetPerplexity(4)
	o2.SetIterations(120)
	o2.SetSeed(7)
	o2.Fit()
	Then("t-SNE: the same seed gives the same embedding",
	     SameEmbedding(o1.Embedding(), o2.Embedding()), TRUE)

	o3 = new stzTSNE(aD)
	o3.SetPerplexity(4)
	o3.SetIterations(120)
	o3.SetSeed(99)
	o3.Fit()
	Then("...and a different seed a different one",
	     SameEmbedding(o1.Embedding(), o3.Embedding()), FALSE)

	u1 = new stzUMAP(aD)
	u1.SetNeighbors(4)
	u1.SetEpochs(80)
	u1.SetSeed(5)
	u1.Fit()
	u2 = new stzUMAP(aD)
	u2.SetNeighbors(4)
	u2.SetEpochs(80)
	u2.SetSeed(5)
	u2.Fit()
	Then("UMAP: the same seed gives the same embedding",
	     SameEmbedding(u1.Embedding(), u2.Embedding()), TRUE)
EndScenario()

Scenario("the parameters really do change the picture")
	# Worth pinning because it is the thing a caller must understand: these are not
	# tuning knobs with a right setting, they are the question being asked.
	aD = Blobs(10, 5)

	oLow = new stzTSNE(aD)
	oLow.SetPerplexity(3)
	oLow.SetIterations(200)
	oLow.Fit()
	oHigh = new stzTSNE(aD)
	oHigh.SetPerplexity(12)
	oHigh.SetIterations(200)
	oHigh.Fit()
	Then("a different perplexity is a different embedding",
	     SameEmbedding(oLow.Embedding(), oHigh.Embedding()), FALSE)

	uTight = new stzUMAP(aD)
	uTight.SetMinDistance(0.01)
	uTight.SetNeighbors(4)
	uTight.SetEpochs(100)
	uTight.Fit()
	uLoose = new stzUMAP(aD)
	uLoose.SetMinDistance(0.8)
	uLoose.SetNeighbors(4)
	uLoose.SetEpochs(100)
	uLoose.Fit()
	# a smaller min_dist means the similarity falls off sooner, so points must sit
	# closer together to count as near -- which shows up as a LARGER a
	Then("a smaller min distance fits a tighter curve",
	     uTight.CurveParameters()[:a] > uLoose.CurveParameters()[:a], TRUE)
EndScenario()

Scenario("what they refuse, and the one thing they deliberately cannot do")
	aD = Blobs(4, 3)

	# a perplexity is an entropy target and cannot exceed what n-1 neighbours carry
	Then("a perplexity larger than the data is refused", RaisesTsnePerp(aD), TRUE)
	Then("...saying how many points there are",
	     StzFindFirst("there are 12", WhyTsnePerp(aD)) > 0, TRUE)
	Then("too many neighbours is refused", RaisesUmapNb(aD), TRUE)
	Then("ragged samples are refused", RaisesRagged(), TRUE)
	Then("an empty list is refused", RaisesEmpty(), TRUE)

	oT = new stzTSNE(aD)
	Then("results refuse before Fit", RaisesEmbedding(oT), TRUE)

	# t-SNE HAS NO Transform(), AND UMAP DOES -- and an earlier version of this file
	# asserted that NEITHER did, which was wrong about UMAP. It lumped two algorithms
	# together on a property only one of them has.
	#
	# t-SNE optimises the positions of the points it was given and nothing else, so
	# there is no map to apply and a new point has no position. UMAP builds a
	# NEIGHBOUR GRAPH, and a graph extends: the new point's edges to the training
	# points are computable, and the training layout is already a solution to
	# optimise them against. See the Transform scenario below.
	Then("t-SNE has no Transform", HasTransform(oT), FALSE)
	oP = new stzPCA(aD)
	oP.Center()
	oP.Fit()
	Then("...while PCA does, because a linear map extends to new points",
	     len(oP.Transform([ aD[1] ])), 1)
EndScenario()

Scenario("UMAP places points the fit never saw")
	# THE CHECK THAT MATTERS FIRST: a point the model has already seen must come back
	# to essentially where the fit put it. If Transform used a different local metric,
	# or projected through the wrong space, this is where it shows.
	aD = Blobs(12, 6)
	oU = new stzUMAP(aD)
	oU.SetNeighbors(5)
	oU.SetEpochs(300)
	oU.Fit()

	aBack = oU.Transform(aD)
	Then("one row out per row in", len(aBack), 36)
	Then("...of the embedding's width", len(aBack[1]), 2)
	Then("a training point returns to its own cluster",
	     NearestCluster(aBack[1], oU.Embedding(), 12), 1)
	Then("...and one from the middle group to that group",
	     NearestCluster(aBack[20], oU.Embedding(), 12), 2)
	Then("...and one from the last", NearestCluster(aBack[30], oU.Embedding(), 12), 3)
	Then("nearly all of them do", FractionHome(aBack, oU.Embedding(), 12) > 0.9, TRUE)

	# a GENUINELY new point, sitting inside each blob, must land beside that blob
	aNew = [ [0,0,0,0,0,0], [30,30,30,30,30,30], [60,60,60,60,60,60] ]
	aT = oU.Transform(aNew)
	Then("a new point in blob 1 lands in blob 1",
	     NearestCluster(aT[1], oU.Embedding(), 12), 1)
	Then("...blob 2 in blob 2", NearestCluster(aT[2], oU.Embedding(), 12), 2)
	Then("...blob 3 in blob 3", NearestCluster(aT[3], oU.Embedding(), 12), 3)

	# THE MAP DOES NOT MOVE. A map that shifted under every lookup would not be one,
	# and every coordinate a caller recorded before would silently become stale.
	aBefore = oU.Embedding()
	v = oU.Transform(aNew)
	Then("the training layout is untouched by a lookup",
	     SameEmbedding(aBefore, oU.Embedding()), TRUE)

	Then("a row of the wrong width is refused", RaisesTransform(oU, [ [1,2] ]), TRUE)
	Then("...naming the width it wanted",
	     StzFindFirst("fitted on 6", WhyTransform(oU, [ [1,2] ])) > 0, TRUE)
EndScenario()

Scenario("...and it goes through the SAME PCA the fit used")
	# The subtle one. When the fit reduced with PCA, the model measures distances in
	# COMPONENT space -- so a new row must be projected by that same analysis before
	# its neighbours mean anything. Projecting it with its own centering, or not at
	# all, would compare it against the training data in a different space and every
	# neighbour would be wrong.
	aD = Blobs(12, 6)
	oU = new stzUMAP(aD)
	oU.ReduceWithPCA(3)
	oU.SetNeighbors(5)
	oU.SetEpochs(300)
	oU.Fit()

	aBack = oU.Transform(aD)
	Then("training points still return home through the reduction",
	     FractionHome(aBack, oU.Embedding(), 12) > 0.9, TRUE)

	aNew = [ [0,0,0,0,0,0], [30,30,30,30,30,30], [60,60,60,60,60,60] ]
	aT = oU.Transform(aNew)
	Then("a new point still lands in its blob",
	     NearestCluster(aT[1], oU.Embedding(), 12), 1)
	Then("...and the third in the third",
	     NearestCluster(aT[3], oU.Embedding(), 12), 3)

	# and Transform takes RAW rows -- the same shape Fit took -- rather than making
	# the caller do the projection themselves
	Then("Transform accepts raw feature rows, not component scores",
	     len(aT[1]), 2)
EndScenario()

Scenario("Transform is deterministic, which a lookup had better be")
	aD = Blobs(10, 5)
	oU = new stzUMAP(aD)
	oU.SetNeighbors(4)
	oU.SetEpochs(200)
	oU.SetSeed(11)
	oU.Fit()

	aNew = [ [1,1,1,1,1], [31,31,31,31,31] ]
	a1 = oU.Transform(aNew)
	a2 = oU.Transform(aNew)
	Then("the same rows give the same coordinates", SameEmbedding(a1, a2), TRUE)
EndScenario()

Scenario("the name forms hold here too")
	aD = Blobs(6, 3)

	# mutators return nothing; the Q twins chain
	oT = new stzTSNE(aD)
	Then("SetPerplexity() returns nothing", isNull(oT.SetPerplexity(4)), TRUE)
	Then("...and took effect", oT.Perplexity(), 4)
	oC = new stzTSNE(aD)
	oC.SetPerplexityQ(3).SetIterationsQ(50).SetSeedQ(2).FitQ()
	Then("the Q forms chain", oC.IsFitted(), TRUE)
	Then("...and did the things", oC.Perplexity(), 3)

	oU = new stzUMAP(aD)
	Then("SetNeighbors() returns nothing", isNull(oU.SetNeighbors(4)), TRUE)
	Then("...and took effect", oU.Neighbors(), 4)
	oV = new stzUMAP(aD)
	oV.SetNeighborsQ(4).SetEpochsQ(50).ReduceWithPCAQ(2).FitQ()
	Then("UMAP's Q forms chain too", oV.IsFitted(), TRUE)
	Then("...including the PCA step", oV.UsesPCA(), TRUE)

	# an object accessor stays Q-only
	Then("PCAQ() hands back the analysis", oV.PCAQ().IsFitted(), TRUE)
EndScenario()

Summary()

func Rnd2(n)
	return ceil(n * 100 - 0.5) / 100

# three tight, well-separated groups -- data whose clustering is not in doubt
func Blobs(nPer, nDim)
	aD = []
	for c = 1 to 3
		for k = 1 to nPer
			r = []
			for j = 1 to nDim
				r + ((c-1)*30 + ((k*37 + j*11) % 10)/10)
			next
			aD + r
		next
	next
	return aD

func AllFinite(aE)
	for i = 1 to len(aE)
		for j = 1 to len(aE[i])
			v = aE[i][j]
			if v != v or v = 1/0.0000000000000001
				return FALSE
			ok
		next
	next
	return TRUE

# mean between-group distance over mean within-group distance. A number well above 1
# says the groups came through as groups.
func SeparationRatio(aE, nPer)
	n = len(aE)
	nW = 0  nWc = 0
	nB = 0  nBc = 0
	for i = 1 to n
		for j = i+1 to n
			d = 0
			for t = 1 to len(aE[i])
				dd = aE[i][t] - aE[j][t]
				d += dd*dd
			next
			d = sqrt(d)
			if ceil(i/nPer) = ceil(j/nPer)
				nW += d  nWc++
			else
				nB += d  nBc++
			ok
		next
	next
	if nWc = 0 or nBc = 0 or nW = 0
		return 0
	ok
	return (nB/nBc) / (nW/nWc)

func SameEmbedding(a, b)
	if len(a) != len(b)
		return FALSE
	ok
	for i = 1 to len(a)
		for j = 1 to len(a[i])
			if a[i][j] != b[i][j]
				return FALSE
			ok
		next
	next
	return TRUE

func RaisesTsnePerp(aD)
	b = FALSE
	try
		o = new stzTSNE(aD)
		o.SetPerplexity(500)
		o.Fit()
	catch
		b = TRUE
	done
	return b

func WhyTsnePerp(aD)
	s = ""
	try
		o = new stzTSNE(aD)
		o.SetPerplexity(500)
		o.Fit()
	catch
		s = cCatchError
	done
	return s

func RaisesUmapNb(aD)
	b = FALSE
	try
		o = new stzUMAP(aD)
		o.SetNeighbors(500)
		o.Fit()
	catch
		b = TRUE
	done
	return b

func RaisesRagged()
	b = FALSE
	try
		o = new stzTSNE([ [1,2], [3] ])
	catch
		b = TRUE
	done
	return b

func RaisesEmpty()
	b = FALSE
	try
		o = new stzUMAP([])
	catch
		b = TRUE
	done
	return b

func RaisesEmbedding(o)
	b = FALSE
	try
		v = o.Embedding()
	catch
		b = TRUE
	done
	return b

func HasTransform(o)
	b = TRUE
	try
		v = o.Transform([ [1,2,3] ])
	catch
		b = FALSE
	done
	return b

# which blob's fitted points is this coordinate nearest to? 1-based
func NearestCluster(aPoint, aFitted, nPer)
	nBest = 1
	nBestV = -1
	for j = 1 to len(aFitted)
		d = 0
		for t = 1 to len(aPoint)
			dd = aPoint[t] - aFitted[j][t]
			d += dd*dd
		next
		if nBestV < 0 or d < nBestV
			nBestV = d
			nBest = j
		ok
	next
	return ceil(nBest / nPer)

# what fraction of transformed rows land in the cluster they came from
func FractionHome(aBack, aFitted, nPer)
	nOk = 0
	for i = 1 to len(aBack)
		if NearestCluster(aBack[i], aFitted, nPer) = ceil(i / nPer)
			nOk++
		ok
	next
	return nOk / len(aBack)

func RaisesTransform(o, aR)
	b = FALSE
	try
		v = o.Transform(aR)
	catch
		b = TRUE
	done
	return b

func WhyTransform(o, aR)
	s = ""
	try
		v = o.Transform(aR)
	catch
		s = cCatchError
	done
	return s
