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

# Holds one of seven point processes, a mechanism for putting points down, with its parameters, and generates patterns from it and judges a pattern against it.
#
# The seven are Poisson (no interaction, random count), Binomial (the same with a fixed count),
# Inhomogeneous (no interaction, varying intensity from a surface), MaternCluster (parents you never
# see, children in a disc), Thomas (children scattered by a Gaussian, so a cluster has a scale but
# no edge), MaternII (inhibition by deletion, which has a ceiling) and SSI (inhibition by refusal,
# which keeps packing). Asking whether a pattern is more clustered than a model that already
# explains something, not than complete spatial randomness, is the point. The setters write three
# shared slots, shown by Content: a (intensity, count or parent intensity), b (mean children) and c
# (radius, sigma or hard-core distance). GenerateIn throws one pattern in the window of a
# stzGeoPoints; EnvelopeOf, EscapesOf and VerdictOn judge an observed pattern against the band the
# process makes: 39 simulations being the classic count, and the band widens with the count. Counts
# of the cluster processes vary widely between seeds (a standard deviation of about 90 on a mean of
# 190). PatternIn throws the same pattern as a stzGeoPoints in the same window; ExpectedCountIn
# answers the expected count of any kind in a window, which for Inhomogeneous is the integral of the
# surface over the window (ExpectedCount takes only areas, so it refuses that kind). Pictures, each
# looked at by 'stzlib-docs visual pass (a model reading the PNG)' on 2026-10-05:
# doc/gallery/stzGeoProcess/seven_processes.png, one pattern from
# each process, RIGHT (clusters compact, inhibited processes evenly spaced, the inhomogeneous one
# follows its field); null_models.png, one pattern against three nulls, RIGHT (it escapes Poisson
# and Binomial everywhere and never the MaternCluster that made it); matern_ii_ceiling.png,
# survivors against proposal rate, RIGHT (MaternII levels off near the ceiling, SSI packs about
# twice as many). Index: doc/gallery/INDEX_geo.md.
#
#   receiver   o1 = new stzGeoProcess(:MaternCluster)
#   example    ? o1.Kind()
#              #--> MaternCluster
#              ? o1.IsClustering()
#              #--> 1
#   see        stzGeoPoints, stzGeoField, stzGeoFeatures
class stzGeoProcess from stzObject

	@cKind = "Poisson"
	@nKind = 0
	@nA = 0          # intensity per km2, or a count, or the PARENT intensity
	@nB = 0          # the mean number of children per parent
	@nC = 0          # a length in km: cluster radius, sigma, hard-core distance
	@aGrid = []      # an intensity SURFACE, for :Inhomogeneous
	@aLambda = []

	# Builds the point process called pcKind (case ignored); an empty text gives Poisson and an unknown name raises an error listing the seven.
	#
	#   pcKind     the process: Poisson, Binomial, Inhomogeneous, MaternCluster, Thomas, MaternII or
	#              SSI
	#   returns    nothing; the object is built
	#   note       A misspelt name is never quietly Poisson
	#   see        StzGeoProcess, StzGeoProcesses
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

	# Returns the name of the process, as the engine spells it.
	#
	#   returns    text, for example "MaternCluster"
	#   see        Content, StzGeoProcesses
	#@ aka  -- what it IS ----------------------------------------------------------
	def Kind()
		return @cKind

	# Returns the kind and the three parameter slots the setters write.
	#
	#   returns    a hash list [ :kind, :a, :b, :c ]; a is the intensity, count or parent intensity,
	#              b the mean children, c the radius, sigma or hard-core distance in km
	#   note       The slots are shared: SetIntensity, SetCount and SetParentIntensity all write a,
	#              SetRadiusKm, SetSigmaKm and SetHardCoreKm all write c
	#   see        Kind, SetIntensity
	def Content()
		return [ :kind = @cKind, :a = @nA, :b = @nB, :c = @nC ]

	# TRUE if the process makes points depend on one another: any kind but Poisson, Binomial and Inhomogeneous.
	#
	#   returns    TRUE or FALSE
	#   note       The three that answer FALSE are the honest null models
	#   see        IsClustering, IsInhibiting
	#@ aka  DOES THIS PROCESS PLACE POINTS WITHOUT REGARD TO ONE ANOTHER? The three that do are the honest null models -- whatever a statistic sees in their output is chance. The four that do not have an interaction built in, and are what a caller tests FOR.
	def HasInteraction()
		return NOT (@cKind = "Poisson" or @cKind = "Binomial" or @cKind = "Inhomogeneous")

	# TRUE if the process groups points around hidden parents: MaternCluster or Thomas.
	#
	#   returns    TRUE or FALSE
	#   see        IsInhibiting, HasInteraction
	def IsClustering()
		return @cKind = "MaternCluster" or @cKind = "Thomas"

	# TRUE if the process keeps points apart by a hard-core distance: MaternII or SSI.
	#
	#   returns    TRUE or FALSE
	#   see        IsClustering, HasInteraction
	def IsInhibiting()
		return @cKind = "MaternII" or @cKind = "SSI"

	# Sets the points per square kilometre of a Poisson or MaternII process.
	#
	#   pn         points per km2
	#   returns    nothing; the number is stored
	#   note       Writes the same slot as SetCount and SetParentIntensity
	#   see        Intensity, SetCount
	#@ aka  -- the parameters, under the names they have in the subject -------------
	def SetIntensity(pn)
		@nA = pn

		def SetIntensityQ(pn)
			This.SetIntensity(pn)
			return This

	# Returns the number the intensity, count and parent-intensity setters share.
	#
	#   returns    a number
	#   note       After SetCount it answers the count
	#   see        SetIntensity
	def Intensity()
		return @nA

	# Sets the exact number of points of a Binomial or SSI process.
	#
	#   pn         how many points
	#   returns    nothing; the number is stored
	#   note       Writes the same slot as SetIntensity
	#   see        SetIntensity
	#@ aka  how many points exactly -- :Binomial, :SSI
	def SetCount(pn)
		@nA = pn

		def SetCountQ(pn)
			This.SetCount(pn)
			return This

	# Sets the clusters per square kilometre of a MaternCluster or Thomas process; the parents are never drawn.
	#
	#   pn         clusters per km2
	#   returns    nothing; the number is stored
	#   note       Writes the same slot as SetIntensity
	#   see        SetMeanChildren
	#@ aka  clusters per square kilometre -- :MaternCluster, :Thomas. The parents are NEVER DRAWN: they are where the clusters are, not points of the pattern, and a reader who saw them would be looking at a mechanism rather than at data.
	def SetParentIntensity(pn)
		@nA = pn

		def SetParentIntensityQ(pn)
			This.SetParentIntensity(pn)
			return This

	# Sets the mean number of children per parent of a cluster process.
	#
	#   pn         the mean number of children
	#   returns    nothing; the number is stored
	#   note       The number of children is random with this mean, so counts vary a lot between
	#              patterns: 25 to 426 for the same settings
	#   see        MeanChildren, SetParentIntensity
	def SetMeanChildren(pn)
		@nB = pn

		def SetMeanChildrenQ(pn)
			This.SetMeanChildren(pn)
			return This

	# Returns the mean number of children per parent.
	#
	#   returns    a number
	#   see        SetMeanChildren
	def MeanChildren()
		return @nB

	# Sets the radius of a MaternCluster's disc, in kilometres.
	#
	#   pn         the radius in km
	#   returns    nothing; the number is stored
	#   note       Writes the same slot as SetSigmaKm and SetHardCoreKm
	#   see        SetSigmaKm
	#@ aka  the radius of a Matern cluster's disc, km
	def SetRadiusKm(pn)
		@nC = pn

		def SetRadiusKmQ(pn)
			This.SetRadiusKm(pn)
			return This

	# Sets the scale of a Thomas cluster's Gaussian, in kilometres.
	#
	#   pn         the scale in km
	#   returns    nothing; the number is stored
	#   note       Writes the same slot as SetRadiusKm
	#   see        SetRadiusKm
	#@ aka  the scale of a Thomas cluster's Gaussian, km. It is NOT a radius: about a third of the children land beyond it and a few land far out, which is the whole difference from Matern and is a claim about the mechanism.
	def SetSigmaKm(pn)
		@nC = pn

		def SetSigmaKmQ(pn)
			This.SetSigmaKm(pn)
			return This

	# Sets the distance in km that no two points of a MaternII or SSI process may come within.
	#
	#   pn         the hard-core distance in km
	#   returns    nothing; the number is stored
	#   note       Writes the same slot as SetRadiusKm
	#   see        HardCoreKm
	#@ aka  the distance no two points may come within -- :MaternII, :SSI
	def SetHardCoreKm(pn)
		@nC = pn

		def SetHardCoreKmQ(pn)
			This.SetHardCoreKm(pn)
			return This

	# Returns the number the radius, sigma and hard-core setters share, in kilometres.
	#
	#   returns    a number of km
	#   see        SetHardCoreKm
	def HardCoreKm()
		return @nC

	# Takes a stzGeoField as the intensity surface of an Inhomogeneous process.
	#
	#   poField    the stzGeoField whose values are the intensity in points per km2
	#   returns    nothing; the grid and the values are copied
	#   note       A kernel density of one pattern is such a field, so "clustered beyond the
	#              population" is two calls
	#   see        SetIntensityGrid, HasIntensityField
	#@ aka  THE INTENSITY SURFACE of an inhomogeneous process, as a GE7b field. That is not a workaround for the engine taking no callbacks: a kernel density estimated from one pattern IS such a field, so the natural workflow -- read a population surface, then ask whether the cases are clustered beyond it -- is two calls with nothing in between.
	def SetIntensityField(poField)
		@aGrid = poField.Grid()
		@aLambda = poField.Values()

		def SetIntensityFieldQ(poField)
			This.SetIntensityField(poField)
			return This

	# Sets the intensity surface of an Inhomogeneous process from a grid description and its values.
	#
	#   paGridParams   the grid as [ lon0, lat0, dlon, dlat, nx, ny ]
	#   paValues       nx times ny intensities in points per km2, the south row first
	#   returns        nothing; the grid and the values are stored
	#   note           The same shape a stzGeoField takes
	#   see            SetIntensityField
	def SetIntensityGrid(paGridParams, paValues)
		@aGrid = paGridParams
		@aLambda = paValues

		def SetIntensityGridQ(paGridParams, paValues)
			This.SetIntensityGrid(paGridParams, paValues)
			return This

	# TRUE if an intensity surface has been set.
	#
	#   returns    TRUE or FALSE
	#   see        SetIntensityField
	def HasIntensityField()
		return len(@aLambda) > 0

	# Returns how many points the process puts down on average in a window of the given area.
	#
	#   pnAreaKm2      the area of the window in km2
	#   pnBoxAreaKm2   the area of the window's bounding box in km2
	#   returns        a number; 177.5 for Poisson at 0.00015 per km2 over Niger
	#   note           Right on average for Poisson, Binomial, MaternCluster and Thomas (60 seeds:
	#                  190 against 189). An Inhomogeneous process raises an error here, because its
	#                  count is the integral of the intensity surface over the window and two areas
	#                  cannot name a window: ask ExpectedCountIn. This used to answer the mean of all
	#                  the grid values times the window area, 191.9 where 149.4 were drawn on average
	#                  and 144.3 integrated, and that call now raises instead of answering wrongly
	#   see            ExpectedCountIn, GenerateIn, stzGeoPoints.BoxAreaKm2
	#@ aka  -- generating ----------------------------------------------------------
	def ExpectedCount(pnAreaKm2, pnBoxAreaKm2)
		if @cKind = "Inhomogeneous"
			raise("Softanza: ExpectedCount takes two areas, and the expected count of an " +
				"Inhomogeneous process is the integral of its intensity surface over a WINDOW, " +
				"which two areas cannot name. Use ExpectedCountIn(poPoints) with the " +
				"stzGeoPoints whose window you mean.")
		ok
		return StzEngineGeoProcessExpected(@nKind, @nA, @nB, @nC, @aLambda,
			pnAreaKm2, pnBoxAreaKm2)

	# Returns how many points the process puts down on average in the window of a pattern, for every kind.
	#
	#   poPoints   a stzGeoPoints whose window is the one the pattern would be thrown in
	#   returns    a number of points; 177.5 for Poisson at 0.00015 per km2 over Niger
	#   note       For every kind but Inhomogeneous it is ExpectedCount of the window's area and of its
	#              box's area. For Inhomogeneous it is the integral of the intensity surface over the
	#              window, which is what GenerateIn draws on average: the window's area times the
	#              mean of the surface over the window, where the surface is read as GenerateIn
	#              reads it (bilinear between the four nodes around a place, nothing outside the
	#              grid, an unknown node taken as 0). The integral is a sum over a lattice of 160
	#              places along the longer side of the window's box, kept where the window holds
	#              them and weighted by the ground they stand for on the sphere, so it is within a
	#              fraction of a percent of the true integral. It raises an error for a window
	#              that is not a stzGeoPoints or for a surface with fewer values than its grid has
	#              nodes. A window that crosses the antimeridian is not supported
	#   see        ExpectedCount, GenerateIn, PatternIn
	def ExpectedCountIn(poPoints)
		This._CheckWindowArg(poPoints)
		if @cKind != "Inhomogeneous"
			return This.ExpectedCount(poPoints.AreaKm2(), poPoints.BoxAreaKm2())
		ok
		return This.ExpectedCountInXT(poPoints, 160)

	# ...with the lattice size as a dial: pnNodes places along the longer side of the window's box, from 4 to 2000.
	def ExpectedCountInXT(poPoints, pnNodes)
		This._CheckWindowArg(poPoints)
		if NOT isNumber(pnNodes) or pnNodes < 4 or pnNodes > 2000
			raise("Softanza: ExpectedCountInXT: the nodes are how many places run along the " +
				"longer side of the window's box, a number from 4 to 2000.")
		ok
		if @cKind != "Inhomogeneous"
			return This.ExpectedCount(poPoints.AreaKm2(), poPoints.BoxAreaKm2())
		ok
		_nArea_ = poPoints.AreaKm2()
		if len(@aGrid) < 6 or len(@aLambda) = 0 or _nArea_ <= 0  return 0  ok
		_nNx_ = floor(@aGrid[5])
		_nNy_ = floor(@aGrid[6])
		if _nNx_ < 2 or _nNy_ < 2 or @aGrid[3] = 0 or @aGrid[4] = 0  return 0  ok
		if len(@aLambda) < _nNx_ * _nNy_
			raise("Softanza: the intensity surface holds " + len(@aLambda) + " values and its grid " +
				"has " + (_nNx_ * _nNy_) + " nodes.")
		ok
		_aBox_ = poPoints.WindowBox()
		_nW_ = _aBox_[3] - _aBox_[1]
		_nH_ = _aBox_[4] - _aBox_[2]
		if _nW_ <= 0 or _nH_ <= 0  return 0  ok
		# the lattice: square-ish on the ground, pnNodes along the longer side, a place at the
		# middle of each lattice cell, asked of the engine in ONE call which of them the window holds
		_nRad_ = 3.14159265358979 / 180
		_nWk_ = _nW_ * cos(((_aBox_[2] + _aBox_[4]) / 2) * _nRad_)
		_nMx_ = pnNodes
		_nMy_ = ceil(pnNodes * _nH_ / _nWk_)
		if _nWk_ < _nH_
			_nMy_ = pnNodes
			_nMx_ = ceil(pnNodes * _nWk_ / _nH_)
		ok
		if _nMx_ < 2  _nMx_ = 2  ok
		if _nMy_ < 2  _nMy_ = 2  ok
		_nDx_ = _nW_ / _nMx_
		_nDy_ = _nH_ / _nMy_
		_aMask_ = StzEngineGeoGridMask([ _aBox_[1] + _nDx_ / 2, _aBox_[2] + _nDy_ / 2,
			_nDx_, _nDy_, _nMx_, _nMy_ ], poPoints.WindowRings(), _aBox_)
		_nNum_ = 0
		_nDen_ = 0
		for _j_ = 0 to _nMy_ - 1
			# equal-area on the sphere: a row stands for the difference of the sines of its edges
			_nWj_ = sin((_aBox_[2] + (_j_ + 1) * _nDy_) * _nRad_) - sin((_aBox_[2] + _j_ * _nDy_) * _nRad_)
			_nLat_ = _aBox_[2] + (_j_ + 0.5) * _nDy_
			for _i_ = 0 to _nMx_ - 1
				if _aMask_[_j_ * _nMx_ + _i_ + 1] = 1
					_nDen_ += _nWj_
					_nNum_ += _nWj_ * This._IntensityAt(_aBox_[1] + (_i_ + 0.5) * _nDx_, _nLat_)
				ok
			next
		next
		if _nDen_ <= 0  return 0  ok
		return _nArea_ * _nNum_ / _nDen_

	# the surface at a place as GenerateIn reads it: bilinear between the four nodes around it, 0 outside
	# the grid (and on its last row and column), an unknown node taken as 0, nothing below 0
	def _IntensityAt(pnLon, pnLat)
		_fx_ = (pnLon - @aGrid[1]) / @aGrid[3]
		_fy_ = (pnLat - @aGrid[2]) / @aGrid[4]
		if _fx_ < 0 or _fy_ < 0  return 0  ok
		_ix_ = floor(_fx_)
		_jy_ = floor(_fy_)
		_nx_ = floor(@aGrid[5])
		if _ix_ + 1 >= _nx_ or _jy_ + 1 >= floor(@aGrid[6])  return 0  ok
		_tx_ = _fx_ - _ix_
		_ty_ = _fy_ - _jy_
		_k_ = _jy_ * _nx_ + _ix_ + 1
		_a_ = 0  _b_ = 0  _c_ = 0  _d_ = 0
		if isNumber(@aLambda[_k_])  _a_ = @aLambda[_k_]  ok
		if isNumber(@aLambda[_k_ + 1])  _b_ = @aLambda[_k_ + 1]  ok
		if isNumber(@aLambda[_k_ + _nx_])  _c_ = @aLambda[_k_ + _nx_]  ok
		if isNumber(@aLambda[_k_ + _nx_ + 1])  _d_ = @aLambda[_k_ + _nx_ + 1]  ok
		_v_ = _a_ * (1 - _tx_) * (1 - _ty_) + _b_ * _tx_ * (1 - _ty_) + _c_ * (1 - _tx_) * _ty_ + _d_ * _tx_ * _ty_
		if _v_ < 0  return 0  ok
		return _v_

	# the window argument of the methods that take a pattern: an object that answers like a stzGeoPoints
	def _CheckWindowArg(poPoints)
		if NOT isObject(poPoints) or NOT ismethod(poPoints, "WindowRings") or NOT ismethod(poPoints, "AreaKm2")
			raise("Softanza: the window is a stzGeoPoints -- the pattern whose window the process works in.")
		ok

	# Returns one pattern of the process inside a window, as a flat list of places.
	#
	#   poPoints   a stzGeoPoints whose window the pattern is thrown in
	#   pnSeed     the seed of the random draw
	#   returns    a flat list lon, lat, lon, lat, ...
	#   note       The same seed gives the same pattern
	#   see        PatternIn, EnvelopeOf
	#@ aka  ONE PATTERN FROM THIS PROCESS, inside a window, as a flat lon/lat list.
	def GenerateIn(poPoints, pnSeed)
		return This.GenerateInXT(poPoints, pnSeed, 200000)

	def GenerateInXT(poPoints, pnSeed, pnCap)
		return StzEngineGeoProcessGenerate(@nKind, @nA, @nB, @nC,
			poPoints.WindowRings(), poPoints.WindowBox(),
			poPoints.AreaKm2(), poPoints.BoxAreaKm2(),
			@aGrid, @aLambda, pnSeed, pnCap)

	# Returns one pattern of the process inside a window as a stzGeoPoints, ready to measure.
	#
	#   poPoints   a stzGeoPoints whose window the pattern is thrown in
	#   pnSeed     the seed of the random draw
	#   returns    a stzGeoPoints with the window of poPoints that holds the places GenerateIn draws
	#              for the same seed
	#   note       The same seed gives the same pattern. Count, ClarkEvans, RipleyK and Envelope can
	#              be asked of the result at once
	#   see        GenerateIn, stzGeoPoints.With
	#@ aka  ...and the same as a stzGeoPoints, ready to be measured
	def PatternIn(poPoints, pnSeed)
		This._CheckWindowArg(poPoints)
		_aPlaces_ = This.GenerateIn(poPoints, pnSeed)
		return poPoints.With(_aPlaces_)

	# Returns the band of L the process produces, by simulation: the lowest, highest and mean over pnSims patterns at each radius.
	#
	#   poPoints    a stzGeoPoints that gives the window
	#   paRadiiKm   the distances in km, ascending
	#   pnSims      how many simulated patterns, 39 being the classic count
	#   pnSeed      the seed of the random draw
	#   returns     a list of hash lists [ :radius, :lo, :hi, :mean ]
	#   note        The band widens with pnSims, so two counts are not comparable: report the count.
	#               A cluster process makes a very wide band
	#   see         EscapesOf, VerdictOn
	#@ aka  -- the envelope, which is why any of this exists ------------------------
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

	# Returns, for each radius, whether the observed pattern lies below, inside or above the process's band.
	#
	#   poPoints    a stzGeoPoints holding the observed pattern
	#   paRadiiKm   the distances in km, ascending
	#   pnSims      how many simulated patterns, 39 being the classic count
	#   pnSeed      the seed of the random draw
	#   pcStat      the statistic: :K, :L or :G
	#   returns     a list of -1, 0 or +1 per radius: -1 below the band, 0 inside, +1 above
	#   note        Any text other than K and G means L
	#   see         VerdictOn, EnvelopeOf
	#@ aka  WHERE AN OBSERVED PATTERN ESCAPES THIS PROCESS'S BAND, and which way: -1 below, 0 inside, +1 above. A reader wants the RANGE OF SCALES at which a pattern is unusual, not one verdict -- a wood can be clustered at ten metres and regular at fifty, and a single p-value cannot say that.
	def EscapesOf(poPoints, paRadiiKm, pnSims, pnSeed, pcStat)
		_s_ = This._StatCode(pcStat)
		_env_ = StzEngineGeoProcessEnvelope(@nKind, @nA, @nB, @nC,
			poPoints.WindowRings(), poPoints.WindowBox(),
			poPoints.AreaKm2(), poPoints.BoxAreaKm2(),
			@aGrid, @aLambda, paRadiiKm, pnSims, pnSeed, _s_)
		_obs_ = This._ObservedStat(poPoints, paRadiiKm, pcStat)
		return StzEngineGeoProcessEscapes(_obs_, _env_)

	# Returns the verdict in words with the radii at which the observed pattern escapes the process's band.
	#
	#   poPoints    a stzGeoPoints holding the observed pattern
	#   paRadiiKm   the distances in km, ascending
	#   pnSims      how many simulated patterns, 39 being the classic count
	#   pnSeed      the seed of the random draw
	#   pcStat      the statistic: :K, :L or :G
	#   returns     a hash list [ :verdict, :above, :below, :sims, :null, :statistic ]; the verdict
	#               reads for example "more clustered than Poisson at 20, 50 and 100 km"
	#   note        A clustered pattern is clustered against Poisson and Binomial at every radius
	#               and consistent with the MaternCluster that made it
	#   see         EscapesOf, EnvelopeOf
	#@ aka  THE VERDICT IN WORDS, with the scales it holds at -- which is the only honest summary, because "clustered" without a range is not a finding.
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
