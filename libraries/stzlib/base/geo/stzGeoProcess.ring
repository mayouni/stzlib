#----------------------------------------------------------------------#
#  GE7d -- A POINT PROCESS IS A THING, AND A NULL MODEL NEED NOT BE CSR  #
#----------------------------------------------------------------------#

# A POINT PROCESS IS A MECHANISM FOR PUTTING POINTS DOWN, and naming which
# one you mean is the whole of this class.
#
# GE7a can already ask whether a pattern is clustered. It asks by simulating
# COMPLETE SPATIAL RANDOMNESS -- points scattered uniformly, with no regard
# for each other -- and seeing whether the observed statistic escapes the
# band. That is the least interesting question in the subject.
#
# Almost nothing real is completely random. Trees are clustered because
# seeds fall near their parent. Clinics are clustered because people are.
# Earthquakes are clustered because one triggers the next. Rejecting CSR
# tells you the world is not a uniform scatter, which nobody thought it was,
# and a reader who is told "significantly clustered, p < 0.01" has learned
# nothing they could not have seen by looking.
#
# THE QUESTION WORTH ASKING IS AGAINST A MODEL THAT ALREADY EXPLAINS
# SOMETHING:
#
#   "Is this more clustered than seed dispersal alone would make it?"
#   "Is this clustered beyond where the people already are?"
#   "Are these trees spaced further apart than competition for light
#    would space them?"
#
# Each of those needs a null model that is NOT uniform, which is why a
# process has to be a thing you can name, parameterise, generate from and
# hand to the envelope. That is what this class is.
#
# THE SEVEN, and each is a MECHANISM rather than a shape:
#
#   :Poisson         no interaction at all. The count is RANDOM -- that is
#                    what makes it Poisson rather than what follows.
#   :Binomial        the same with the count FIXED. It is what GE7a has
#                    been simulating all along without saying so, and it
#                    has strictly less variance, so its envelope is
#                    narrower than the one a reader assumes.
#   :Inhomogeneous   no interaction, varying intensity. The null model that
#                    says "the pattern follows the population".
#   :MaternCluster   parents you never see, children uniform in a DISC.
#   :Thomas          the same with children scattered by a GAUSSIAN, so a
#                    cluster has a scale but no edge.
#   :MaternII        inhibition by DELETION -- propose, then remove anyone
#                    with an older neighbour too close.
#   :SSI             inhibition by REFUSAL -- propose one at a time and keep
#                    only those landing clear.
#
# MATERN II AND SSI LOOK THE SAME AND ARE NOT. Matern II thins a pattern
# that already exists, so it has a CEILING: past a point every extra
# proposed point deletes as many as it adds. Measured on a one-degree
# square with a 4 km core, raising the proposal rate a thousandfold moved
# the survivors from 157 to 258 and no further, while sequential inhibition
# packed 544 into the same window. Reporting "a hard-core model" without
# saying which mechanism made it is reporting a number without its units.
#
# WHERE THE WORK RUNS. In the engine, geo_process.zig inside stz_geo.dll.

func StzGeoProcess(pcKind)
	return new stzGeoProcess(pcKind)

func StzGeoProcessQ(pcKind)
	return new stzGeoProcess(pcKind)

# the kinds this library knows, asked of the engine rather than kept here
func StzGeoProcesses()
	_a_ = []
	for _i_ = 1 to StzEngineGeoProcessCount()
		_a_ + StzEngineGeoProcessName(_i_)
	next
	return _a_

# COMPLETE SPATIAL RANDOMNESS, named as the thing it is. A caller who wants
# the weak null should have to write its name.
func StzGeoCSR(pnPerKm2)
	_p_ = new stzGeoProcess(:Poisson)
	_p_.SetIntensity(pnPerKm2)
	return _p_

# A POISSON COUNT, exposed because it is the one random draw in this plane
# that a caller may want for themselves -- how many events in an interval,
# given a rate.
func StzPoissonCount(pnLambda, pnSeed)
	return StzEngineGeoPoissonCount(pnLambda, pnSeed)

# THE MOST POINTS PER KM2 A MATERN II PROCESS CAN REACH at a given
# hard-core distance, however hard it is pushed: (1 - exp(-t))/(pi r2) with
# t the proposed rate times the disc. A caller choosing between the two
# inhibition mechanisms needs this number, because asking Matern II for a
# density above it is asking for something that does not exist.
func StzGeoMaternIICeiling(pnProposedPerKm2, pnRadiusKm)
	return StzEngineGeoMaternIICeiling(pnProposedPerKm2, pnRadiusKm)

# THESE TWO SIT ABOVE THE CLASS BECAUSE RING PUTS EVERYTHING AFTER `class`
# INSIDE IT: a func written below is a method, invisible to a method that
# calls it by name, and the failure arrives as "calling function without
# definition" for a function plainly in the file.

func _GeoProcessNames()
	_o_ = ""
	_a_ = StzGeoProcesses()
	for _i_ = 1 to len(_a_)
		if _i_ > 1  _o_ += ", "  ok
		_o_ += _a_[_i_]
	next
	return _o_

# the scales a verdict holds at, written the way a reader says them
func _GeoKmList(paKm)
	_o_ = ""
	for _i_ = 1 to len(paKm)
		if _i_ > 1
			if _i_ = len(paKm)  _o_ += " and "  else  _o_ += ", "  ok
		ok
		_o_ += "" + paKm[_i_]
	next
	if len(paKm) = 1  return _o_ + " km"  ok
	return _o_ + " km"

class stzGeoProcess from stzObject

	@cKind = "Poisson"
	@nKind = 0
	@nA = 0          # intensity per km2, or a count, or the PARENT intensity
	@nB = 0          # the mean number of children per parent
	@nC = 0          # a length in km: cluster radius, sigma, hard-core distance
	@aGrid = []      # an intensity SURFACE, for :Inhomogeneous
	@aLambda = []

	def init(pcKind)
		_c_ = "Poisson"
		if isString(pcKind) and pcKind != ""  _c_ = pcKind  ok
		_i_ = 0
		for _k_ = 1 to StzEngineGeoProcessCount()
			if StzLower(StzEngineGeoProcessName(_k_)) = StzLower("" + _c_)
				_i_ = _k_
				exit
			ok
		next
		if _i_ = 0
			# A MECHANISM NOBODY NAMED IS NOT QUIETLY POISSON. Silently
			# substituting the weak null for a misspelt strong one would
			# turn a careful test into the useless one, and say nothing.
			raise("Softanza: no point process is named '" + _c_ +
				"'. The ones this library knows are: " + _GeoProcessNames() + ".")
		ok
		@cKind = StzEngineGeoProcessName(_i_)
		@nKind = _i_ - 1

	#-- what it IS ----------------------------------------------------------

	def Kind()
		return @cKind

	def Content()
		return [ :kind = @cKind, :a = @nA, :b = @nB, :c = @nC ]

	# DOES THIS PROCESS PLACE POINTS WITHOUT REGARD TO ONE ANOTHER? The three
	# that do are the honest null models -- whatever a statistic sees in
	# their output is chance. The four that do not have an interaction built
	# in, and are what a caller tests FOR.
	def HasInteraction()
		return NOT (@cKind = "Poisson" or @cKind = "Binomial" or @cKind = "Inhomogeneous")

	def IsClustering()
		return @cKind = "MaternCluster" or @cKind = "Thomas"

	def IsInhibiting()
		return @cKind = "MaternII" or @cKind = "SSI"

	#-- the parameters, under the names they have in the subject -------------

	# points per square kilometre -- :Poisson, :MaternII
	def SetIntensity(pn)
		@nA = pn

		def SetIntensityQ(pn)
			This.SetIntensity(pn)
			return This

	def Intensity()
		return @nA

	# how many points exactly -- :Binomial, :SSI
	def SetCount(pn)
		@nA = pn

		def SetCountQ(pn)
			This.SetCount(pn)
			return This

	# clusters per square kilometre -- :MaternCluster, :Thomas. The parents
	# are NEVER DRAWN: they are where the clusters are, not points of the
	# pattern, and a reader who saw them would be looking at a mechanism
	# rather than at data.
	def SetParentIntensity(pn)
		@nA = pn

		def SetParentIntensityQ(pn)
			This.SetParentIntensity(pn)
			return This

	def SetMeanChildren(pn)
		@nB = pn

		def SetMeanChildrenQ(pn)
			This.SetMeanChildren(pn)
			return This

	def MeanChildren()
		return @nB

	# the radius of a Matern cluster's disc, km
	def SetRadiusKm(pn)
		@nC = pn

		def SetRadiusKmQ(pn)
			This.SetRadiusKm(pn)
			return This

	# the scale of a Thomas cluster's Gaussian, km. It is NOT a radius: about
	# a third of the children land beyond it and a few land far out, which is
	# the whole difference from Matern and is a claim about the mechanism.
	def SetSigmaKm(pn)
		@nC = pn

		def SetSigmaKmQ(pn)
			This.SetSigmaKm(pn)
			return This

	# the distance no two points may come within -- :MaternII, :SSI
	def SetHardCoreKm(pn)
		@nC = pn

		def SetHardCoreKmQ(pn)
			This.SetHardCoreKm(pn)
			return This

	def HardCoreKm()
		return @nC

	# THE INTENSITY SURFACE of an inhomogeneous process, as a GE7b field.
	# That is not a workaround for the engine taking no callbacks: a kernel
	# density estimated from one pattern IS such a field, so the natural
	# workflow -- read a population surface, then ask whether the cases are
	# clustered beyond it -- is two calls with nothing in between.
	def SetIntensityField(poField)
		@aGrid = poField.Grid()
		@aLambda = poField.Values()

		def SetIntensityFieldQ(poField)
			This.SetIntensityField(poField)
			return This

	def SetIntensityGrid(paGridParams, paValues)
		@aGrid = paGridParams
		@aLambda = paValues

		def SetIntensityGridQ(paGridParams, paValues)
			This.SetIntensityGrid(paGridParams, paValues)
			return This

	def HasIntensityField()
		return len(@aLambda) > 0

	#-- generating ----------------------------------------------------------

	# HOW MANY POINTS THIS PROCESS PUTS DOWN ON AVERAGE in a window of this
	# area. A caller needs it before simulating at all: an envelope built at
	# the wrong intensity is an envelope of the wrong question.
	#
	# For the two CLUSTER processes this is the count BEFORE the window
	# clips it. Children thrown outside are lost, and how many depends on
	# how far the mechanism scatters them -- measured on a one-degree
	# square, a Matern cluster of radius 8 km loses 6 per cent and a Thomas
	# of sigma 4 km loses 17, because a Gaussian has no edge. The loss is
	# real and it is the window's, not the process's.
	def ExpectedCount(pnAreaKm2, pnBoxAreaKm2)
		return StzEngineGeoProcessExpected(@nKind, @nA, @nB, @nC, @aLambda,
			pnAreaKm2, pnBoxAreaKm2)

	# ONE PATTERN FROM THIS PROCESS, inside a window, as a flat lon/lat list.
	def GenerateIn(poPoints, pnSeed)
		return This.GenerateInXT(poPoints, pnSeed, 200000)

	def GenerateInXT(poPoints, pnSeed, pnCap)
		return StzEngineGeoProcessGenerate(@nKind, @nA, @nB, @nC,
			poPoints.WindowRings(), poPoints.WindowBox(),
			poPoints.AreaKm2(), poPoints.BoxAreaKm2(),
			@aGrid, @aLambda, pnSeed, pnCap)

	# ...and the same as a stzGeoPoints, ready to be measured
	def PatternIn(poPoints, pnSeed)
		return StzGeoPoints(This.GenerateIn(poPoints, pnSeed), poPoints.WindowRings())

	#-- the envelope, which is why any of this exists ------------------------

	# THE BAND THIS PROCESS PRODUCES, per radius: the lowest, the highest and
	# the mean of the statistic over `sims` simulated patterns. Answers a
	# list of [ :radius, :lo, :hi, :mean ].
	#
	# THIRTY-NINE IS THE CLASSIC COUNT, and it is not a floor to be raised
	# for free precision: the band WIDENS with the number of simulations, so
	# an envelope of 999 is a stricter test than an envelope of 39 and the
	# two are not comparable. Being the most extreme of forty is a
	# one-in-forty event under the null -- 2.5 per cent on each side. The
	# count belongs in whatever gets reported.
	def EnvelopeOf(poPoints, paRadiiKm, pnSims, pnSeed)
		return This.EnvelopeOfXT(poPoints, paRadiiKm, pnSims, pnSeed, :L)

	# ...for K, L or G. K grows like the area of a disc and is hard to read;
	# L is its square root, straight under randomness, and is what anybody
	# plots; G is the distribution of nearest-neighbour distances, which
	# answers a DIFFERENT question -- K is about how many neighbours, G
	# about how close the closest one is.
	def EnvelopeOfXT(poPoints, paRadiiKm, pnSims, pnSeed, pcStat)
		_s_ = This._StatCode(pcStat)
		_flat_ = StzEngineGeoProcessEnvelope(@nKind, @nA, @nB, @nC,
			poPoints.WindowRings(), poPoints.WindowBox(),
			poPoints.AreaKm2(), poPoints.BoxAreaKm2(),
			@aGrid, @aLambda, paRadiiKm, pnSims, pnSeed, _s_)
		_o_ = []
		for _i_ = 1 to len(paRadiiKm)
			if _i_ * 3 > len(_flat_)  exit  ok
			_o_ + [ :radius = paRadiiKm[_i_], :lo = _flat_[_i_ * 3 - 2],
			        :hi = _flat_[_i_ * 3 - 1], :mean = _flat_[_i_ * 3] ]
		next
		return _o_

	# WHERE AN OBSERVED PATTERN ESCAPES THIS PROCESS'S BAND, and which way:
	# -1 below, 0 inside, +1 above. A reader wants the RANGE OF SCALES at
	# which a pattern is unusual, not one verdict -- a wood can be clustered
	# at ten metres and regular at fifty, and a single p-value cannot say
	# that.
	def EscapesOf(poPoints, paRadiiKm, pnSims, pnSeed, pcStat)
		_s_ = This._StatCode(pcStat)
		_env_ = StzEngineGeoProcessEnvelope(@nKind, @nA, @nB, @nC,
			poPoints.WindowRings(), poPoints.WindowBox(),
			poPoints.AreaKm2(), poPoints.BoxAreaKm2(),
			@aGrid, @aLambda, paRadiiKm, pnSims, pnSeed, _s_)
		_obs_ = This._ObservedStat(poPoints, paRadiiKm, pcStat)
		return StzEngineGeoProcessEscapes(_obs_, _env_)

	# THE VERDICT IN WORDS, with the scales it holds at -- which is the only
	# honest summary, because "clustered" without a range is not a finding.
	def VerdictOn(poPoints, paRadiiKm, pnSims, pnSeed, pcStat)
		_e_ = This.EscapesOf(poPoints, paRadiiKm, pnSims, pnSeed, pcStat)
		_hi_ = []
		_lo_ = []
		for _i_ = 1 to len(_e_)
			if _e_[_i_] > 0  _hi_ + paRadiiKm[_i_]  ok
			if _e_[_i_] < 0  _lo_ + paRadiiKm[_i_]  ok
		next
		_c_ = "consistent with " + @cKind + " at every scale tested"
		if len(_hi_) > 0 and len(_lo_) > 0
			_c_ = "more clustered than " + @cKind + " at " + _GeoKmList(_hi_) +
			      " and more regular at " + _GeoKmList(_lo_)
		but len(_hi_) > 0
			_c_ = "more clustered than " + @cKind + " at " + _GeoKmList(_hi_)
		but len(_lo_) > 0
			_c_ = "more regular than " + @cKind + " at " + _GeoKmList(_lo_)
		ok
		return [ :verdict = _c_, :above = _hi_, :below = _lo_,
		         :sims = pnSims, :null = @cKind, :statistic = pcStat ]

	def _StatCode(pcStat)
		_c_ = StzLower("" + pcStat)
		if _c_ = "k"  return 0  ok
		if _c_ = "g"  return 2  ok
		return 1

	def _ObservedStat(poPoints, paRadiiKm, pcStat)
		_c_ = StzLower("" + pcStat)
		if _c_ = "k"  return poPoints.RipleyK(paRadiiKm)  ok
		if _c_ = "g"  return poPoints.G(paRadiiKm)  ok
		return poPoints.L(paRadiiKm)
