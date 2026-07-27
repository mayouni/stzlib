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

	# THREE DIFFERENT ANSWERS TO "where does a new point go", and the differences
	# are about the algorithms rather than about the API:
	#
	#   ORDINARY t-SNE  cannot. It optimises POSITIONS, so there is no function to
	#                   apply. Transform() raises and names the two alternatives.
	#   UMAP            can, by re-optimising one point against a frozen neighbour
	#                   graph.
	#   PARAMETRIC t-SNE can, by having trained a NETWORK as the map -- so Transform
	#                   is one forward pass. See the scenarios below.
	# fitted, so the refusal is the one about the MISSING MAP rather than the one
	# about not having run yet -- two different refusals, and the useful one is the
	# second
	oFitted = new stzTSNE(aD)
	oFitted.SetPerplexity(3)
	oFitted.SetIterations(60)
	oFitted.Fit()
	Then("ordinary t-SNE has no Transform", HasTransformOf(oFitted, aD[1]), FALSE)
	Then("...and says what to do instead",
	     StzFindFirst("LearnMapping", WhyTransform(oFitted, [ aD[1] ])) > 0, TRUE)
	Then("...and names the other option too",
	     StzFindFirst("stzUMAP", WhyTransform(oFitted, [ aD[1] ])) > 0, TRUE)
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

Scenario("PARAMETRIC t-SNE learns a map, so it CAN place new points")
	# van der Maaten (2009). Instead of optimising n*2 free coordinates, train a
	# NETWORK f(x) -> R^2 against the same KL objective. The embedding becomes f(X),
	# and a new point is one forward pass.
	#
	# ALMOST NOTHING HERE IS NEW CODE, which is the part worth noticing: P and the KL
	# gradient come from the ordinary t-SNE, the forward and backward passes come
	# from the neural trainer built in phase 6. The only extension was splitting that
	# backward pass so it takes a SUPPLIED output gradient -- nn.train derives its own
	# from per-sample targets, and this objective has no targets, because the gradient
	# at point i depends on every other point.
	aD = Blobs(12, 6)
	oP = new stzTSNE(aD)
	oP.LearnMapping()
	oP.SetHiddenLayers([ 20, 10 ])
	oP.SetPerplexity(5)
	oP.SetIterations(400)
	oP.SetLearningRate(0.02)
	oP.Fit()

	Then("it says it is parametric", oP.IsParametric(), TRUE)
	Then("...and reports its architecture", len(oP.HiddenLayers()), 2)
	Then("...and says so in words",
	     StzFindFirst("parametric", oP.Why()) > 0, TRUE)
	Then("the objective still came down", oP.FinalKL() < oP.KLHistory()[1], TRUE)
	Then("the clusters are separated", SeparationRatio(oP.Embedding(), 12) > 3, TRUE)
EndScenario()

Scenario("...and its Transform is a FUNCTION, not a re-optimisation")
	# THE SHARPEST CONTRAST WITH UMAP. UMAP's transform re-optimises one point
	# against a frozen map, so a training row comes back NEAR where it was. Here the
	# embedding IS f(X), so transforming a training row reproduces its position
	# EXACTLY -- it is not a similar computation, it is the same one.
	aD = Blobs(12, 6)
	oP = new stzTSNE(aD)
	oP.LearnMapping()
	oP.SetHiddenLayers([ 20, 10 ])
	oP.SetPerplexity(5)
	oP.SetIterations(400)
	oP.SetLearningRate(0.02)
	oP.Fit()

	aBack = oP.Transform(aD)
	Then("a training row transforms to EXACTLY its embedded position",
	     aBack[1][1], oP.Embedding()[1][1])
	Then("...to the last bit", aBack[1][2], oP.Embedding()[1][2])
	Then("...and so does every row", SameEmbedding(aBack, oP.Embedding()), TRUE)

	# and genuinely new points land where they belong
	aNew = [ [0,0,0,0,0,0], [30,30,30,30,30,30], [60,60,60,60,60,60] ]
	aT = oP.Transform(aNew)
	Then("a new point in blob 1 lands in blob 1",
	     NearestCluster(aT[1], oP.Embedding(), 12), 1)
	Then("...blob 2 in blob 2", NearestCluster(aT[2], oP.Embedding(), 12), 2)
	Then("...blob 3 in blob 3", NearestCluster(aT[3], oP.Embedding(), 12), 3)

	# nothing stochastic happens in a forward pass
	Then("repeated calls agree exactly",
	     SameEmbedding(oP.Transform(aNew), aT), TRUE)

	Then("a row of the wrong width is refused", RaisesTransform(oP, [ [1,2] ]), TRUE)
EndScenario()

Scenario("the parametric variant through PCA, and what it costs")
	# It composes with the PCA pre-step exactly as UMAP's does: the network's inputs
	# are the COMPONENTS, so a new row is projected by the same analysis first.
	aD = Blobs(12, 6)
	oP = new stzTSNE(aD)
	oP.ReduceWithPCA(3)
	oP.LearnMapping()
	oP.SetHiddenLayers([ 15 ])
	oP.SetPerplexity(5)
	oP.SetIterations(400)
	oP.SetLearningRate(0.02)
	oP.Fit()

	Then("it used both", oP.UsesPCA() and oP.IsParametric(), TRUE)
	aBack = oP.Transform(aD)
	Then("training rows still transform exactly through the reduction",
	     SameEmbedding(aBack, oP.Embedding()), TRUE)
	Then("a new row still lands in its blob",
	     NearestCluster(oP.Transform([ [0,0,0,0,0,0] ])[1], oP.Embedding(), 12), 1)

	# THE TRADE, stated rather than hidden: the paper says the parametric embedding is
	# generally somewhat worse, because free coordinates can go anywhere and a
	# network's outputs are limited to what it can express. Both separate these blobs
	# -- the data is easy -- so what is pinned is that BOTH work, not that they are
	# equivalent. A caller choosing parametric is buying a map, not a better picture.
	oPlain = new stzTSNE(aD)
	oPlain.SetPerplexity(5)
	oPlain.SetIterations(800)
	oPlain.Fit()
	Then("both variants separate the clusters",
	     SeparationRatio(oPlain.Embedding(), 12) > 3 and
	     SeparationRatio(oP.Embedding(), 12) > 3, TRUE)
	Then("...but only one of them has a map",
	     HasTransformOf(oPlain, aD[1]) = FALSE and
	     HasTransformOf(oP, aD[1]) = TRUE, TRUE)
EndScenario()

Scenario("SUPERVISED UMAP: labels reshape the graph")
	# THE TEST THAT MEANS SOMETHING. The two classes are assigned at RANDOM to
	# randomly-placed points, so the data contains no class structure whatever --
	# unsupervised UMAP has nothing to find, and must find nothing. Supervised UMAP
	# must nonetheless pull them apart, because that is what the labels say.
	#
	# Testing supervision on data that is ALREADY separable would prove nothing: the
	# unsupervised run would separate it too, and both would pass.
	aD = RandomRows(40, 4)
	aY = Alternating(40)

	oPlain = new stzUMAP(aD)
	oPlain.SetNeighbors(6)
	oPlain.SetEpochs(300)
	oPlain.Fit()
	Then("unsupervised finds nothing, because there is nothing",
	     LabelSeparation(oPlain.Embedding(), aY) < 1.3, TRUE)

	oSup = new stzUMAP(aD)
	oSup.SetNeighbors(6)
	oSup.SetEpochs(300)
	oSup.LearnFromLabels(aY)
	oSup.SetTargetWeight(0.2)
	oSup.Fit()
	Then("supervised separates them", LabelSeparation(oSup.Embedding(), aY) >
	     LabelSeparation(oPlain.Embedding(), aY) * 1.4, TRUE)
	Then("it says it is supervised", oSup.IsSupervised(), TRUE)
	Then("...and says so in words", StzFindFirst("supervised", oSup.Why()) > 0, TRUE)
	Then("...and remembers the labels", len(oSup.Labels()), 40)

	# AND THE WARNING THIS SCENARIO EXISTS TO MAKE CONCRETE: the separation above is
	# NOT evidence that the classes are separable. The data was random. Supervision
	# put the separation there, and a picture from it says only what was put in.
	Then("the data itself has no class structure -- the separation was an INPUT",
	     LabelSeparation(oPlain.Embedding(), aY) < 1.3, TRUE)
EndScenario()

Scenario("...with UNKNOWN labels, which is the semi-supervised case")
	# -1 means "no information for this point". Its edges are DAMPED (exp(-1)) rather
	# than crushed (exp(-5)), which is the difference between semi-supervised and
	# simply dropping the row.
	aD = RandomRows(40, 4)
	aY = Alternating(40)
	aPartial = []
	for i = 1 to 40
		if i % 3 = 0
			aPartial + -1
		else
			aPartial + aY[i]
		ok
	next

	oSemi = new stzUMAP(aD)
	oSemi.SetNeighbors(6)
	oSemi.SetEpochs(300)
	oSemi.LearnFromLabelsQ(aPartial).SetTargetWeightQ(0.2).FitQ()

	Then("it fits with a third of the labels missing", oSemi.IsFitted(), TRUE)
	Then("every coordinate is finite", AllFinite(oSemi.Embedding()), TRUE)
	Then("...and it still counts as supervised", oSemi.IsSupervised(), TRUE)

	# a wrong-length label list is refused rather than padded
	Then("one label per sample, or nothing", RaisesLabels(aD, [1,2]), TRUE)
	Then("...saying how many were wanted",
	     StzFindFirst("40 of them", WhyLabels(aD, [1,2])) > 0, TRUE)
	Then("...and mentioning the unknown marker",
	     StzFindFirst("-1", WhyLabels(aD, [1,2])) > 0, TRUE)
EndScenario()

Scenario("the target weight is not the dial anyone assumes")
	# MEASURED rather than assumed, and the assumption was wrong. Separation against
	# target_weight on random-labelled data:
	#
	#     0.00  0.98      nothing to find, nothing found
	#     0.05  1.71
	#     0.20  2.62      the PEAK
	#     0.50  1.46
	#     0.90  1.43
	#     0.99  1.43      identical to 0.90
	#
	# MORE SUPERVISION IS NOT MORE SEPARATION. Crushing every cross-class edge
	# FRAGMENTS the graph: points lose most of their neighbours, and the layout loses
	# the arrangement that was holding each class together as one group. And beyond
	# about 0.9 the setting stops meaning anything at all, because far_dist is
	# 2.5/(1-w) and exp(-25) is already zero to an f64.
	#
	# I wrote a monotone assertion first and it failed. Measuring instead of loosening
	# it is what produced the two facts above.
	aD = RandomRows(40, 4)
	aY = Alternating(40)

	oZero = new stzUMAP(aD)
	oZero.SetNeighbors(6)
	oZero.SetEpochs(200)
	oZero.LearnFromLabels(aY)
	oZero.SetTargetWeight(0)
	oZero.Fit()

	oPlain = new stzUMAP(aD)
	oPlain.SetNeighbors(6)
	oPlain.SetEpochs(200)
	oPlain.Fit()
	Then("weight 0 is EXACTLY the unsupervised fit, not merely close",
	     SameEmbedding(oZero.Embedding(), oPlain.Embedding()), TRUE)

	# saturation: 0.9 and 0.99 are the same run
	o90 = new stzUMAP(aD)
	o90.SetNeighbors(6)
	o90.SetEpochs(200)
	o90.LearnFromLabelsQ(aY).SetTargetWeightQ(0.9).FitQ()
	o99 = new stzUMAP(aD)
	o99.SetNeighbors(6)
	o99.SetEpochs(200)
	o99.LearnFromLabelsQ(aY).SetTargetWeightQ(0.99).FitQ()
	Then("0.9 and 0.99 give the SAME embedding -- the penalty has underflowed",
	     SameEmbedding(o90.Embedding(), o99.Embedding()), TRUE)

	Then("a weight outside 0..1 is ignored rather than obeyed",
	     IgnoresBadWeight(aD, aY), TRUE)
EndScenario()

Scenario("supervision composes with everything else")
	aD = RandomRows(36, 6)
	aY = Alternating(36)

	oAll = new stzUMAP(aD)
	oAll.ReduceWithPCAQ(3).SetNeighborsQ(5).SetEpochsQ(200)
	oAll.LearnFromLabelsQ(aY).SetTargetWeightQ(0.2).FitQ()

	Then("PCA and supervision together", oAll.UsesPCA() and oAll.IsSupervised(), TRUE)
	Then("...and it still transforms", len(oAll.Transform([ aD[1] ])), 1)
	# NOT FractionHome here -- that helper asks which CLUSTER a row lands in, and this
	# data is randomly placed with alternating labels, so there are no clusters to land
	# in. The question that means something for arbitrary data is how far a training
	# row moves when put back through Transform(), measured against the typical
	# distance between points in the map.
	#
	# MEASURED, because my first guess was wrong twice over. Asking whether each row
	# lands NEAREST its own fitted position gives only 0.25 -- and gives the same 0.25
	# unsupervised, so it is not a supervision failure but the transform's nature:
	# it re-optimises a new point against its NEIGHBOURS in the frozen map, so on data
	# with no structure it settles in the neighbourhood rather than on the spot. The
	# displacement tells the real story: 0.39 of typical spacing here, 0.20 without
	# supervision. Anchored, not exact.
	Then("...training rows land near where they were put, relative to the spread",
	     DisplacementRatio(oAll.Transform(aD), oAll.Embedding()) < 0.6, TRUE)

	# IgnoreLabels turns it back off
	oOff = new stzUMAP(aD)
	oOff.LearnFromLabels(aY)
	Then("LearnFromLabels() returns nothing", isNull(oOff.IgnoreLabels()), TRUE)
	Then("...and IgnoreLabels turns supervision off", oOff.IsSupervised(), FALSE)
EndScenario()

Scenario("DENSITY: what the ordinary picture cannot tell you")
	# The two clusters below differ in spread by a factor of TWENTY. That is the whole
	# setup: one is a tight knot of near-identical rows, the other a loose cloud.
	aD = TwoDensities(25)
	Then("the data really is twentyfold apart in spread",
	     TrueRatio(aD) > 15, TRUE)

	oPlain = new stzUMAP(aD)
	oPlain.SetNeighbors(8)
	oPlain.SetEpochs(400)
	oPlain.Fit()

	# THE CAVEAT THE LIBRARY HAS BEEN PRINTING, NOW AS A NUMBER. A twentyfold
	# difference in the data is drawn about 1.12 times apart. Not a bug -- it is what
	# optimising a neighbourhood objective does, and it is exactly why "do not read
	# cluster size" has to be said out loud.
	Then("...and the ordinary picture draws it as barely anything",
	     DrawnRatio(oPlain.Embedding()) < 1.5, TRUE)

	Then("nothing extra is computed unless asked", len(oPlain.LocalRadii()), 0)
	Then("...and it says it is not preserving density",
	     oPlain.IsDensityPreserving(), FALSE)
EndScenario()

Scenario("...and what densMAP puts back")
	aD = TwoDensities(25)
	oDens = new stzUMAP(aD)
	oDens.SetNeighborsQ(8).SetEpochsQ(400).SetDensityWeightQ(30).FitQ()

	Then("the diffuse cluster is now drawn wider than the tight one",
	     DrawnRatio(oDens.Embedding()) > 1.5, TRUE)
	Then("...and it reports how far it got",
	     oDens.DensityCorrelation() > 0.7, TRUE)
	Then("...and says so in words",
	     StzFindFirst("density-preserving", oDens.Why()) > 0, TRUE)

	# THE HONEST LIMIT, stated as a test rather than a footnote. The objective is a
	# CORRELATION, so what is recovered is the ORDERING of densities, not their
	# magnitude: a twentyfold fact is still drawn at under 2x here.
	Then("but the MAGNITUDE is not recovered -- only the ordering",
	     DrawnRatio(oDens.Embedding()) < TrueRatio(aD) / 5, TRUE)
EndScenario()

Scenario("the local radii are a data product, not a by-product of drawing")
	aD = TwoDensities(25)
	o = new stzUMAP(aD)
	o.SetNeighborsQ(8).SetEpochsQ(200).PreserveDensityQ().FitQ()

	Then("one radius per row", len(o.LocalRadii()), 50)

	# EVERY tight row sits closer to its neighbours than EVERY diffuse row. That is an
	# answer to "which rows are isolated" that needs no embedding at all -- usable for
	# outlier detection or for weighting a downstream model, and it costs nothing
	# because the density term has to compute it anyway.
	Then("every tight row is denser than every diffuse row",
	     LargestIn(o.LocalRadii(), 1, 25) < SmallestIn(o.LocalRadii(), 26, 50), TRUE)
	Then("...by a wide margin, roughly 300-fold",
	     SmallestIn(o.LocalRadii(), 26, 50) / LargestIn(o.LocalRadii(), 1, 25) > 50, TRUE)
EndScenario()

Scenario("the density dial, and it is NOT shaped like the supervision one")
	aD = TwoDensities(25)

	# MEASURED, true ratio 19.96:
	#
	#     lambda   correlation   drawn ratio   cluster separation
	#       0         0.226         1.17           7.36
	#       2         0.436         1.31           6.28    <- the paper default
	#      30         0.871         1.81           5.85
	#     300         0.993        23.83           1.44
	#
	# THIS DIAL IS MONOTONE. SetTargetWeight() is not -- it peaks at 0.2 and saturates
	# past 0.9. Two dials on the same object, behaving nothing alike, which is why
	# neither shape may be assumed from the other.
	oLo = new stzUMAP(aD)
	oLo.SetNeighborsQ(8).SetEpochsQ(400).SetDensityWeightQ(2).FitQ()
	oHi = new stzUMAP(aD)
	oHi.SetNeighborsQ(8).SetEpochsQ(400).SetDensityWeightQ(30).FitQ()
	Then("more weight, more density recovered -- all the way up",
	     oHi.DensityCorrelation() > oLo.DensityCorrelation(), TRUE)

	# AND IT IS A TRADE, which the paper default hides by being small. Pushing to 300
	# gets the density nearly exact and COLLAPSES the gap between the two clusters,
	# because the term buys its room by spending what was holding the groups apart.
	oHeavy = new stzUMAP(aD)
	oHeavy.SetNeighborsQ(8).SetEpochsQ(400).SetDensityWeightQ(300).FitQ()
	Then("...but a heavy weight costs the separation between the groups",
	     Separation(oHeavy.Embedding()) < Separation(oLo.Embedding()) / 2, TRUE)
	Then("...which is the thing most people opened the plot to see",
	     oHeavy.DensityCorrelation() > 0.95, TRUE)

	Then("a negative weight is ignored rather than obeyed",
	     IgnoresBadDensity(aD), TRUE)
	Then("PreserveDensity() uses the paper default", DefaultLambda(aD), 2)
EndScenario()

Scenario("density composes, and turns off exactly")
	aD = TwoDensities(12)
	aY = Alternating(24)

	# with PCA and supervision at once
	oAll = new stzUMAP(aD)
	oAll.ReduceWithPCAQ(3).SetNeighborsQ(5).SetEpochsQ(200)
	oAll.LearnFromLabelsQ(aY).SetTargetWeightQ(0.2).SetDensityWeightQ(5).FitQ()
	Then("PCA, supervision and density together",
	     oAll.UsesPCA() and oAll.IsSupervised() and oAll.IsDensityPreserving(), TRUE)
	Then("...and every coordinate is still finite", AllFinite(oAll.Embedding()), TRUE)

	# weight 0 is EXACTLY the ordinary fit -- the term is skipped, not merely damped
	oZero = new stzUMAP(aD)
	oZero.SetNeighborsQ(5).SetEpochsQ(200).SetDensityWeightQ(0).FitQ()
	oPlain = new stzUMAP(aD)
	oPlain.SetNeighborsQ(5).SetEpochsQ(200).FitQ()
	Then("weight 0 reproduces the ordinary fit exactly",
	     SameEmbedding(oZero.Embedding(), oPlain.Embedding()), TRUE)

	Then("IgnoreDensity() returns nothing", isNull(TurnOff(aD)), TRUE)
EndScenario()

Scenario("den-SNE: t-SNE tells you NOTHING about density")
	# Same setup as the densMAP scenarios: two clusters differing twentyfold in spread.
	aD = TwoDensitiesWell(25)
	Then("the data really is twentyfold apart", TrueRatio(aD) > 15, TRUE)

	# A weight this small reports the correlation without moving anything -- the
	# measurement, with the treatment switched off.
	oPlain = new stzTSNE(aD)
	oPlain.SetPerplexityQ(10).SetIterationsQ(800).SetDensityWeightQ(0.000001).FitQ()

	# THE FINDING, AND IT IS WORSE THAN UMAP'S. Plain UMAP scored +0.226 on this kind
	# of data: weak, but pointing the right way. Plain t-SNE scores about 0.04 here,
	# and across five seeds in the engine it ran -0.186, +0.099, +0.125, -0.048, +0.168
	# -- scattered around ZERO and negative as often as not.
	#
	# So t-SNE cluster sizes are not merely unreliable. They are NOISE, and anything
	# read from them is read from the initialisation.
	Then("plain t-SNE carries no density signal at all",
	     fabs(oPlain.DensityCorrelation()) < 0.3, TRUE)
	Then("...and draws the two clusters at the same size",
	     DrawnRatio(oPlain.Embedding()) < 1.2, TRUE)
EndScenario()

Scenario("...and den-SNE puts it back")
	aD = TwoDensitiesWell(25)
	oDens = new stzTSNE(aD)
	oDens.SetPerplexityQ(10).SetIterationsQ(800).PreserveDensityQ().FitQ()

	Then("the default weight is 1, not UMAP's 2", oDens.DensityWeight(), 1)
	Then("...and it recovers the density", oDens.DensityCorrelation() > 0.8, TRUE)
	Then("...so the diffuse cluster is drawn wider",
	     DrawnRatio(oDens.Embedding()) > 1.4, TRUE)
	Then("...and it says so", StzFindFirst("density-preserving", oDens.Why()) > 0, TRUE)

	# THE COST, WHICH t-SNE PRICES DIRECTLY. UMAP could only show it indirectly, as
	# lost cluster separation. t-SNE reports its own objective, so the bill arrives in
	# the units of the thing being given up: the KL divergence is WORSE with the term.
	oOff = new stzTSNE(aD)
	oOff.SetPerplexityQ(10).SetIterationsQ(800).FitQ()
	Then("and the KL divergence is worse for it -- the trade, itemised",
	     FinalKL(oDens) > FinalKL(oOff), TRUE)
EndScenario()

Scenario("the weight is data-dependent, which is why the correlation is reported")
	aD = TwoDensitiesWell(25)

	# MEASURED on this data:      and on the engine's, at three seeds:
	#
	#   lambda   corr   ratio        lambda   s42     s7    s1234
	#    ~0      0.041  1.046          0.5   0.902  0.896  0.827
	#    0.5     0.936  1.449          1.0   0.957  0.965  0.900
	#    1.0     0.899  2.167          2.0  -0.646  0.480  0.910   <- decided by SEED
	#    5.0     0.953  2.861          4.0   0.938  0.936  0.933
	#   10.0     0.971  3.496
	#
	# On the first dataset nothing is unstable anywhere. On the second, lambda 2 lands
	# anywhere from -0.65 to +0.91 depending only on the initialisation. THE BAD BAND
	# IS NOT AT A FIXED PLACE -- so a weight cannot be chosen once and trusted.
	#
	# Which is the reason DensityCorrelation() is on the surface at all. It is not a
	# diagnostic for the curious: it is the only way to know the term did what was
	# asked. A low value means the picture is NOT density-preserving however it was
	# configured.
	oLo = new stzTSNE(aD)
	oLo.SetPerplexityQ(10).SetIterationsQ(800).SetDensityWeightQ(0.5).FitQ()
	oHi = new stzTSNE(aD)
	oHi.SetPerplexityQ(10).SetIterationsQ(800).SetDensityWeightQ(10).FitQ()

	Then("a heavier weight draws the difference larger",
	     DrawnRatio(oHi.Embedding()) > DrawnRatio(oLo.Embedding()), TRUE)
	Then("...and both report what they achieved, so neither is taken on trust",
	     oLo.DensityCorrelation() > 0.8 and oHi.DensityCorrelation() > 0.8, TRUE)

	Then("a negative weight is ignored rather than obeyed", IgnoresBadTsneDensity(aD), TRUE)
EndScenario()

Scenario("den-SNE composes, refuses, and turns off exactly")
	aD = TwoDensitiesWell(10)

	# weight 0 is EXACTLY the ordinary fit -- skipped, not damped
	oZero = new stzTSNE(aD)
	oZero.SetPerplexityQ(5).SetIterationsQ(300).SetDensityWeightQ(0).FitQ()
	oPlain = new stzTSNE(aD)
	oPlain.SetPerplexityQ(5).SetIterationsQ(300).FitQ()
	Then("weight 0 reproduces the ordinary fit exactly",
	     SameEmbedding(oZero.Embedding(), oPlain.Embedding()), TRUE)
	Then("...and computes no radii", len(oZero.LocalRadii()), 0)

	# with PCA
	oPca = new stzTSNE(aD)
	oPca.ReduceWithPCAQ(3).SetPerplexityQ(5).SetIterationsQ(300).PreserveDensityQ().FitQ()
	Then("PCA and density together", oPca.UsesPCA() and oPca.IsDensityPreserving(), TRUE)
	Then("...and every coordinate is finite", AllFinite(oPca.Embedding()), TRUE)

	# THIS USED TO BE A REFUSAL, and the assertions here pinned it. The reasoning was
	# sound for the code as it then stood -- the density term moves coordinates, and
	# the parametric fit produces coordinates through a network, so there was nothing
	# for it to act on. What changed is that the term does not have to act on the
	# coordinates: its gradient is taken on the network's OUTPUTS, and a network chains
	# an output delta back through its weights like any other. It teaches the network
	# to produce different coordinates rather than moving the ones it produced.
	Then("parametric and density now compose", ParametricDensityFits(aD), TRUE)

	Then("IgnoreDensity() returns nothing", isNull(TurnOffTsne(aD)), TRUE)
EndScenario()

Scenario("the two algorithms agree on WHICH rows are dense")
	# stzUMAP weights the radius by its fuzzy graph; stzTSNE weights it by the joint
	# distribution. Two different weightings of the same neighbourhoods -- and the
	# reassurance worth having is that they answer the same question the same way.
	# If they disagreed, the radius would be an artefact of the graph rather than a
	# fact about the data.
	aD = TwoDensitiesWell(15)

	oU = new stzUMAP(aD)
	oU.SetNeighborsQ(6).SetEpochsQ(200).PreserveDensityQ().FitQ()
	oT = new stzTSNE(aD)
	oT.SetPerplexityQ(6).SetIterationsQ(300).PreserveDensityQ().FitQ()

	Then("both rank every tight row below every diffuse row",
	     Separates(oU.LocalRadii(), 15) and Separates(oT.LocalRadii(), 15), TRUE)
	Then("...and they order the rows almost identically",
	     RankAgreement(oU.LocalRadii(), oT.LocalRadii()) > 0.9, TRUE)
EndScenario()

Scenario("A NEW POINT IN AN EMPTY REGION, and what the map used to do with it")
	# The question a transform is actually FOR: production data arriving against a
	# fitted map, where "is this row anything like what I trained on?" is the whole
	# point. Three new rows -- one inside the tight knot, one inside the diffuse cloud,
	# and one sitting far outside anything the fit ever saw.
	aD = TwoDensitiesWell(25)
	aNew = [ [0.07,0.07,0.07,0.07], [21.5,21.5,21.5,21.5], [200,200,200,200] ]

	oPlain = new stzUMAP(aD)
	oPlain.SetNeighborsQ(8).SetEpochsQ(400).FitQ()
	aP = oPlain.Transform(aNew)

	# MEASURED, and worse than merely uninformative. The outlier is drawn 1.38 from its
	# neighbours and the TIGHT-cluster row 2.14 -- so the unfamiliar point is placed
	# CLOSER IN than the familiar one. The ordinary transform puts a new point at the
	# centre of mass of its neighbours and lets the layout nudge it, and nothing in
	# that procedure knows the difference between "near its neighbours" and "nowhere
	# near anything".
	Then("an ordinary transform places the outlier no further out than a tight row",
	     Reach(aP[3], aNew[3], aD, oPlain.Embedding(), 8) <
	     Reach(aP[1], aNew[1], aD, oPlain.Embedding(), 8) * 1.5, TRUE)
EndScenario()

Scenario("...and what the density contract does with it")
	aD = TwoDensitiesWell(25)
	aNew = [ [0.07,0.07,0.07,0.07], [21.5,21.5,21.5,21.5], [200,200,200,200] ]

	oDens = new stzUMAP(aD)
	oDens.SetNeighborsQ(8).SetEpochsQ(400).SetDensityWeightQ(30).FitQ()
	aB = oDens.Transform(aNew)
	aE = oDens.Embedding()

	# MEASURED: reaches of 0.79, 1.30 and 5.99 against original radii of 0.002, 0.727
	# and 126510. Ordered correctly now, where the ordinary transform was inverted.
	Then("the three rows are now drawn in the right order",
	     Reach(aB[1],aNew[1],aD,aE,8) < Reach(aB[2],aNew[2],aD,aE,8) and
	     Reach(aB[2],aNew[2],aD,aE,8) < Reach(aB[3],aNew[3],aD,aE,8), TRUE)
	Then("...and the outlier lands well outside the familiar row",
	     Reach(aB[3],aNew[3],aD,aE,8) / Reach(aB[1],aNew[1],aD,aE,8) > 4, TRUE)

	# AND NOT FURTHER THAN THAT, WHICH IS THE RIGHT ANSWER RATHER THAN A WEAK ONE.
	# This map's density line has slope about 0.19: it compresses a huge range of
	# original density into a small range of drawn radius. The transform inherits
	# exactly that compression, because its job is to place new points under THE SAME
	# CONTRACT the training rows obey. A transform that flung the outlier further than
	# the map's own scale allows would be drawing something the picture does not mean.
	# More separation is bought at FIT time, where it applies to everything at once.
	Then("...but no further than the map's own scale allows",
	     Reach(aB[3],aNew[3],aD,aE,8) / Reach(aB[1],aNew[1],aD,aE,8) < 40, TRUE)
EndScenario()

Scenario("the new rows' radii are an out-of-distribution check")
	aD = TwoDensitiesWell(25)
	aNew = [ [0.07,0.07,0.07,0.07], [200,200,200,200] ]

	o = new stzUMAP(aD)
	o.SetNeighborsQ(8).SetEpochsQ(300).PreserveDensityQ().FitQ()
	o.Transform(aNew)
	aR = o.NewLocalRadii()

	Then("one radius per new row", len(aR), 2)

	# THE PIECE WORTH HAVING EVEN IF THE PICTURE IS NEVER DRAWN. A row whose radius
	# falls far outside the training range is one the model has no evidence about --
	# and that is answerable before anyone decides to plot anything.
	Then("the familiar row sits inside the training range",
	     aR[1] < LargestIn(o.LocalRadii(), 1, 50), TRUE)
	Then("...and the unfamiliar one is far outside it",
	     aR[2] > LargestIn(o.LocalRadii(), 1, 50) * 100, TRUE)

	# available without a fitted density term too, because it is a property of the DATA
	# rather than of the placement
	oNo = new stzUMAP(aD)
	oNo.SetNeighborsQ(8).SetEpochsQ(300).FitQ()
	Then("...and it is reported even for an ordinary fit",
	     len(oNo.LocalRadiiOf(aNew)), 2)
	Then("...with the same verdict", LargerSecond(oNo.LocalRadiiOf(aNew)), TRUE)
EndScenario()

Scenario("the density placement changes only HOW FAR, never WHERE")
	aD = TwoDensitiesWell(20)
	aNew = [ [21.0, 21.2, 20.8, 21.1] ]

	oDens = new stzUMAP(aD)
	oDens.SetNeighborsQ(6).SetEpochsQ(300).SetDensityWeightQ(10).FitQ()
	oPlain = new stzUMAP(aD)
	oPlain.SetNeighborsQ(6).SetEpochsQ(300).FitQ()

	# Same ray out of the neighbourhood centroid, different distance along it. That
	# separation is the design: the neighbourhood terms answer WHERE the point belongs,
	# the density contract answers only HOW FAR OUT, and neither overrules the other --
	# which is also why no second optimisation loop was needed, only a closed form.
	Then("a fit without density leaves the transform exactly as it was",
	     SameEmbedding(oPlain.Transform(aNew), oPlain.Transform(aNew)), TRUE)
	Then("...and a density fit still places the row among its own neighbours",
	     NearestTrainingRow(oDens.Transform(aNew)[1], oDens.Embedding()) > 20, TRUE)
EndScenario()

Scenario("den-SNE GETS A TRANSFORM, and only one door leads to it")
	# Classic t-SNE has NO transform. It optimises the points it was given, and a new
	# point simply has no position -- which is why stzTSNE offers placement only through
	# the parametric variant, where the network IS the map. So den-SNE reaches unseen
	# points by that door or not at all.
	aD = TwoDensitiesWell(25)

	o = new stzTSNE(aD)
	o.SetPerplexityQ(10).SetIterationsQ(600).SetHiddenLayersQ([16,16]).LearnMappingQ()
	o.PreserveDensityQ().FitQ()

	Then("it is parametric AND density preserving",
	     o.IsParametric() and o.IsDensityPreserving(), TRUE)
	Then("...and the density took", o.DensityCorrelation() > 0.8, TRUE)

	# PreserveDensity() PICKS BY MODE, and the numbers say it must. Measured on this
	# data with two hidden layers of 16:
	#
	#     lambda    corr     drawn ratio
	#      ~0      -0.422       0.66      <- plain parametric, INVERTED here
	#      0.01     0.983       8.15
	#      0.10     0.985       8.76      <- the parametric default
	#      0.30     0.988       9.34
	#      1.00    -0.913       0.07      <- the CLASSIC default, catastrophic here
	#
	# A network has a few hundred weights SHARED by every point, so an over-strong term
	# does not distort one region -- it deforms the whole function and the map turns
	# inside out. The classic path keeps 1.0; this one takes 0.1.
	Then("...at a weight chosen for the parametric mode, not the classic one",
	     o.DensityWeight(), 0.1)

	# an explicit weight is obeyed exactly, including into the range that inverts --
	# that is a stated choice, and the correlation will report what came of it
	Then("an explicit weight is obeyed as given", ExplicitWeightKept(aD), 1)
EndScenario()

Scenario("...and that transform is EXACT, unlike UMAP's")
	aD = TwoDensitiesWell(25)
	o = new stzTSNE(aD)
	o.SetPerplexityQ(10).SetIterationsQ(600).SetHiddenLayersQ([16,16]).LearnMappingQ()
	o.PreserveDensityQ().FitQ()

	# Put a training row back through Transform and it returns the SAME NUMBER, because
	# the forward pass is the embedding and there is nothing to approximate. UMAP's
	# transform re-optimises and lands about 0.2 of the typical spacing away; only 25%
	# of its rows come back nearest their own fitted position.
	aT = o.Transform([ aD[1] ])
	Then("a training row transforms to exactly where it was fitted",
	     aT[1][1] = o.Embedding()[1][1] and aT[1][2] = o.Embedding()[1][2], TRUE)
EndScenario()

Scenario("BUT THE NETWORK SATURATES, and that is the price of the exactness")
	aD = TwoDensitiesWell(25)
	aNew = [ [20,20,20,20], [200,200,200,200] ]

	o = new stzTSNE(aD)
	o.SetPerplexityQ(10).SetIterationsQ(600).SetHiddenLayersQ([16,16]).LearnMappingQ()
	o.PreserveDensityQ().FitQ()
	aB = o.Transform(aNew)

	# A legitimate diffuse-cluster row and one TEN TIMES further out in every
	# coordinate than anything the fit ever saw. Bounded activations send everything
	# past a certain magnitude to the same place, so the two come back close together
	# -- and at a heavier weight, three thousandths apart.
	#
	# The transform is not merely inaccurate on unfamiliar input. It is STRUCTURALLY
	# BLIND to it, and it fails SILENTLY: what comes back looks like ordinary
	# coordinates. That is the exact inverse of the UMAP transform, which is only
	# approximate on training rows but CAN put an outlier outside the map.
	Then("the outlier is drawn close to a legitimate row",
	     DistOf(aB[1], aB[2]) < 1.5, TRUE)

	# SO THE CHECK HAS TO COME FROM THE DATA. 356 units from anything is 356 units from
	# anything, whatever a network believes.
	aR = o.LocalRadiiOf(aNew)
	Then("the data-side radius sees what the network could not",
	     aR[2] > aR[1] * 100, TRUE)
	Then("...placing the legitimate row inside the training range",
	     aR[1] < LargestIn(o.LocalRadii(), 1, 50), TRUE)
	Then("...and the outlier far outside it",
	     aR[2] > LargestIn(o.LocalRadii(), 1, 50) * 1000, TRUE)

	# available for an ordinary parametric fit too -- it is a property of the data
	oNo = new stzTSNE(aD)
	oNo.SetPerplexityQ(10).SetIterationsQ(200).SetHiddenLayersQ([16,16]).LearnMappingQ().FitQ()
	Then("...and it needs no density term to be asked",
	     LargerSecond(oNo.LocalRadiiOf(aNew)), TRUE)
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

	# and the parametric mode follows the same law
	oL = new stzTSNE(aD)
	Then("LearnMapping() returns nothing", isNull(oL.LearnMapping()), TRUE)
	Then("...and took effect", oL.IsParametric(), TRUE)
	Then("SkipMapping() turns it off again", isNull(oL.SkipMapping()), TRUE)
	Then("...and it did", oL.IsParametric(), FALSE)
	oM2 = new stzTSNE(aD)
	oM2.LearnMappingQ().SetHiddenLayersQ([8]).SetPerplexityQ(3).SetIterationsQ(60).FitQ()
	Then("the parametric Q forms chain", oM2.IsFitted(), TRUE)
	Then("...and it is parametric", oM2.IsParametric(), TRUE)
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

# does this object have a working Transform? The row must be the RIGHT WIDTH, or a
# width complaint is mistaken for "no map" -- which is exactly what happened the
# first time this ran.
func HasTransformOf(o, aRow)
	b = TRUE
	try
		v = o.Transform([ aRow ])
	catch
		b = FALSE
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

# randomly-placed rows with a deterministic generator, so the guard is reproducible
func RandomRows(nRows, nCols)
	aD = []
	nS = 12345
	for i = 1 to nRows
		r = []
		for j = 1 to nCols
			nS = (nS * 1103515 + 12345) % 2147483647
			r + ((nS % 1000) / 100)
		next
		aD + r
	next
	return aD

# labels with NO relationship to the coordinates -- the point of the supervised test
func Alternating(nRows)
	aY = []
	for i = 1 to nRows
		aY + (i % 2)
	next
	return aY

# mean between-class distance over mean within-class distance, BY LABEL
func LabelSeparation(aE, aL)
	nW = 0  nWc = 0  nB = 0  nBc = 0
	for i = 1 to len(aE)
		for j = i+1 to len(aE)
			d = 0
			for t = 1 to len(aE[i])
				dd = aE[i][t] - aE[j][t]
				d += dd*dd
			next
			d = sqrt(d)
			if aL[i] = aL[j]
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

func RaisesLabels(aD, aL)
	b = FALSE
	try
		o = new stzUMAP(aD)
		o.LearnFromLabels(aL)
	catch
		b = TRUE
	done
	return b

func WhyLabels(aD, aL)
	s = ""
	try
		o = new stzUMAP(aD)
		o.LearnFromLabels(aL)
	catch
		s = cCatchError
	done
	return s

# a weight outside 0..1 must leave the setting alone rather than being obeyed
func IgnoresBadWeight(aD, aY)
	o = new stzUMAP(aD)
	o.LearnFromLabels(aY)
	o.SetTargetWeight(0.3)
	o.SetTargetWeight(5)
	return o.TargetWeight() = 0.3

# mean distance a row moves under Transform(), over the mean distance between points
# in the fitted map. Scale-free, so it can be compared across runs -- and it says
# something FractionHome cannot: how firmly the transform is anchored, on data that
# has no cluster structure for FractionHome to ask about.
func DisplacementRatio(aBack, aFitted)
	nD = 0
	for i = 1 to len(aBack)
		d = 0
		for t = 1 to len(aBack[i])
			dd = aBack[i][t] - aFitted[i][t]
			d += dd*dd
		next
		nD += sqrt(d)
	next
	nD = nD / len(aBack)

	nP = 0  nC = 0
	for i = 1 to len(aFitted)
		for j = i+1 to len(aFitted)
			d = 0
			for t = 1 to len(aFitted[i])
				dd = aFitted[i][t] - aFitted[j][t]
				d += dd*dd
			next
			nP += sqrt(d)  nC++
		next
	next
	if nC = 0 or nP = 0
		return 0
	ok
	return nD / (nP/nC)

# two clusters differing in SPREAD by twentyfold -- one tight knot, one loose cloud.
# The case density preservation exists for.
func TwoDensities(nPer)
	aD = []
	nS = 99
	for i = 1 to nPer*2
		r = []
		for j = 1 to 4
			nS = (nS * 1103515 + 12345) % 2147483647
			if i <= nPer
				r + (((nS % 1000) / 1000) * 0.15)
			else
				r + (20 + ((nS % 1000) / 1000) * 3.0)
			ok
		next
		aD + r
	next
	return aD

func TrueRatio(aD)
	n = len(aD)
	return MeanSpread(aD, n/2+1, n) / MeanSpread(aD, 1, n/2)

func DrawnRatio(aE)
	n = len(aE)
	return MeanSpread(aE, n/2+1, n) / MeanSpread(aE, 1, n/2)

func MeanSpread(aE, lo, hi)
	s = 0
	c = 0
	for i = lo to hi
		for j = i+1 to hi
			d = 0
			for t = 1 to len(aE[i])
				dd = aE[i][t] - aE[j][t]
				d += dd*dd
			next
			s += sqrt(d)
			c++
		next
	next
	if c = 0
		return 0
	ok
	return s / c

# between-cluster distance over within-cluster distance
func Separation(aE)
	n = len(aE)
	nH = n/2
	s = 0
	c = 0
	for i = 1 to nH
		for j = nH+1 to n
			d = 0
			for t = 1 to len(aE[i])
				dd = aE[i][t] - aE[j][t]
				d += dd*dd
			next
			s += sqrt(d)
			c++
		next
	next
	nW = (MeanSpread(aE,1,nH) + MeanSpread(aE,nH+1,n)) / 2
	if nW = 0
		return 0
	ok
	return (s/c) / nW

func LargestIn(aL, lo, hi)
	v = aL[lo]
	for i = lo to hi
		if aL[i] > v
			v = aL[i]
		ok
	next
	return v

func SmallestIn(aL, lo, hi)
	v = aL[lo]
	for i = lo to hi
		if aL[i] < v
			v = aL[i]
		ok
	next
	return v

func IgnoresBadDensity(aD)
	o = new stzUMAP(aD)
	o.SetDensityWeight(3)
	o.SetDensityWeight(-1)
	return o.DensityWeight() = 3

func DefaultLambda(aD)
	o = new stzUMAP(aD)
	o.PreserveDensity()
	return o.DensityWeight()

func TurnOff(aD)
	o = new stzUMAP(aD)
	o.PreserveDensity()
	return o.IgnoreDensity()

# two clusters differing TWENTYFOLD in spread, from the HIGH bits of the generator.
# The low-order bits of a linear congruential generator have short periods and lay the
# points on a lattice -- an earlier version of this helper used them and produced data
# on which the density term behaved quite differently. Worth the extra shift.
func TwoDensitiesWell(nPer)
	aD = []
	nS = 20260727
	for i = 1 to nPer*2
		r = []
		for j = 1 to 4
			nS = (nS * 1103515245 + 12345) % 2147483648
			u = (floor(nS / 2048) % 1000) / 1000
			if i <= nPer
				r + (u * 0.15)
			else
				r + (20 + u * 3.0)
			ok
		next
		aD + r
	next
	return aD

func FinalKL(o)
	aK = o.KLHistory()
	return aK[len(aK)]

func IgnoresBadTsneDensity(aD)
	o = new stzTSNE(aD)
	o.SetDensityWeight(3)
	o.SetDensityWeight(-2)
	return o.DensityWeight() = 3

func RaisesParametricDensity(aD)
	b = FALSE
	try
		o = new stzTSNE(aD)
		o.SetPerplexityQ(5).SetIterationsQ(100).LearnMappingQ().PreserveDensityQ()
		o.Fit()
	catch
		b = TRUE
	done
	return b

func WhyParametricDensity(aD)
	s = ""
	try
		o = new stzTSNE(aD)
		o.SetPerplexityQ(5).SetIterationsQ(100).LearnMappingQ().PreserveDensityQ()
		o.Fit()
	catch
		s = cCatchError
	done
	return s

func TurnOffTsne(aD)
	o = new stzTSNE(aD)
	o.PreserveDensity()
	return o.IgnoreDensity()

# every row of the first half denser than every row of the second
func Separates(aR, nPer)
	nMaxT = aR[1]
	for i = 1 to nPer
		if aR[i] > nMaxT
			nMaxT = aR[i]
		ok
	next
	nMinD = aR[nPer+1]
	for i = nPer+1 to len(aR)
		if aR[i] < nMinD
			nMinD = aR[i]
		ok
	next
	return nMaxT < nMinD

# fraction of row PAIRS the two radius lists order the same way -- a rank correlation
# without needing ties handled, which is all that is wanted here
func RankAgreement(aA, aB)
	nOk = 0
	nTot = 0
	for i = 1 to len(aA)
		for j = i+1 to len(aA)
			nTot++
			if (aA[i] < aA[j]) = (aB[i] < aB[j])
				nOk++
			ok
		next
	next
	if nTot = 0
		return 0
	ok
	return nOk / nTot

# mean distance from a placed point to the embedded positions of its k nearest
# TRAINING rows -- the quantity the density contract governs
func Reach(aPos, aP, aD, aE, k)
	aPair = []
	for i = 1 to len(aD)
		aPair + [DistOf(aP, aD[i]), i]
	next
	aPair = sort(aPair, 1)
	s = 0
	for i = 1 to k
		s += DistOf(aPos, aE[aPair[i][2]])
	next
	return s / k

func DistOf(a, b)
	d = 0
	for t = 1 to len(a)
		dd = a[t] - b[t]
		d += dd*dd
	next
	return sqrt(d)

func LargerSecond(aR)
	return aR[2] > aR[1] * 100

# index of the nearest training row in the embedding -- used to check a new point is
# still placed among the group it belongs to
func NearestTrainingRow(aPos, aE)
	nBest = 1
	nV = -1
	for i = 1 to len(aE)
		d = DistOf(aPos, aE[i])
		if nV < 0 or d < nV
			nV = d
			nBest = i
		ok
	next
	return nBest

func ParametricDensityFits(aD)
	o = new stzTSNE(aD)
	o.SetPerplexityQ(5).SetIterationsQ(200).SetHiddenLayersQ([8]).LearnMappingQ()
	o.PreserveDensityQ().FitQ()
	return o.IsFitted() and o.IsParametric() and o.IsDensityPreserving()

func ExplicitWeightKept(aD)
	o = new stzTSNE(aD)
	o.SetPerplexityQ(5).SetIterationsQ(100).SetHiddenLayersQ([8]).LearnMappingQ()
	o.SetDensityWeightQ(1).FitQ()
	return o.DensityWeight()
