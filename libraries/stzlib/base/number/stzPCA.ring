# stzPCA -- principal component analysis, on the SVD.
#
#   oP = new stzPCA(aData)          # rows are SAMPLES, columns are FEATURES
#   oP.Standardize()                # or .Center() -- you must choose
#   oP.Fit()
#   ? oP.ExplainedVarianceRatio()   #--> [ 0.96, 0.04 ]
#   ? oP.Components()               # the directions
#   ? oP.Scores()                   # the data in those coordinates
#   ? oP.NumberOfComponentsFor(0.95)
#   ? oP.Transform(aNewRows)        # project data it has not seen
#
# WHAT PCA IS. Along which directions does this data vary most? The answer is the
# singular value decomposition of the CENTERED data: the right singular vectors are
# the directions, the singular values say how much variance each accounts for, and
# U*S puts every sample into those coordinates. So there is almost no new arithmetic
# here -- what there is, is three decisions, each of which changes the answer.
#
# 1. CENTERING IS NOT OPTIONAL, and it is done for you. PCA on uncentered data does
#    not find the direction of greatest VARIANCE; it finds the direction of greatest
#    second moment, which for data far from the origin is roughly the direction of
#    the mean. The first component comes back pointing at the centroid, appearing to
#    explain almost everything, and explaining nothing. It is the most common way to
#    get a wrong PCA, so it is not left to the caller.
#
# 2. STANDARDISING IS A REAL CHOICE, AND YOU MUST MAKE IT. Centering alone gives
#    COVARIANCE PCA: every feature contributes in proportion to its own variance, in
#    its own units. Measure height in metres and mass in grams and the mass axis has
#    a million times the variance -- the first component will be "mass", which is a
#    fact about the unit and not about the data. Dividing each column by its standard
#    deviation gives CORRELATION PCA, where every feature counts equally.
#
#    Same units and comparable scales -> Center(). Different units -> Standardize(),
#    nearly always. Neither is safe as a default, so Fit() refuses until you have
#    said which.
#
#    THE NAME FORMS ARE THE SOFTANZA ONES and they mean what they say: Standardize()
#    and Center() are ACTIVE -- they do it, and return nothing. Standardized() and
#    Centered() are PASSIVE -- they hand back the prepared DATA and leave the
#    analysis alone. StandardizeQ() and CenterQ() do it and return the object so
#    calls chain.
#
# 3. THE VARIANCE CONVENTION IS NOT PCA's TO INVENT. The variance a component
#    explains is a variance, and this library settled what that means in phase 0
#    after finding two modules disagreeing: there is ONE divisor authority in the
#    engine. This asks it. UseSampleVariance() (n-1, the default) and
#    UsePopulationVariance() (n) select the convention -- active verbs, because they
#    change the analysis -- and it is the same convention stzDataSet uses, so the two
#    can never drift apart.
#
# WHAT THE NUMBERS MEAN, briefly, because a proportion of variance is easy to
# over-read: a component explaining 96% of the variance explains 96% of the SPREAD,
# not 96% of anything causal, and a component is a weighted blend of your features
# rather than one of them. PCA finds directions, not explanations.

class stzPCA from stzObject

	@aData = []
	@nRows = 0
	@nCols = 0
	@bStandardize = 0
	@bChosen = 0
	@bSample = 1
	@bFitted = 0

	@nK = 0
	@nTotalVariance = 0
	@anMeans = []
	@anScales = []
	@aLoadings = []
	@anSingularValues = []
	@anVariance = []
	@aScores = []

	def init(paData)
		if NOT isList(paData) or len(paData) = 0
			stzraise("Give me a list of samples, each a list of feature values.")
		ok
		if NOT isList(paData[1]) or len(paData[1]) = 0
			stzraise("Each sample must be a list of at least one feature value.")
		ok

		@nRows = len(paData)
		@nCols = len(paData[1])
		for _i_ = 1 to @nRows
			if NOT isList(paData[_i_]) or len(paData[_i_]) != @nCols
				stzraise("Sample " + _i_ + " has " + len(paData[_i_]) +
					" value(s) but the first has " + @nCols + ". " +
					"Every sample must describe the same features.")
			ok
		next
		@aData = paData

	def NumberOfSamples()
		return @nRows

	def NumberOfFeatures()
		return @nCols

	# ── the choice you must make ──
	#
	# THE NAME FORM CARRIES THE SEMANTICS, which is a Softanza law rather than a
	# style: an ACTIVE verb -- Standardize(), Center() -- DOES the thing and returns
	# nothing; the PASSIVE form -- Standardized(), Centered() -- returns the
	# transformed DATA and leaves the object alone; and the Q twin does the thing and
	# returns the object so calls chain. The first version of this class had
	# Standardized() mutating the analysis and returning This, which got both halves
	# wrong at once: a passive name for an active act, and a plain method returning
	# an object where plain methods return data.

	# CENTER each feature on its mean and leave the units alone -- covariance PCA.
	# The features that vary most, in their own units, dominate.
	def Center()
		@bStandardize = 0
		@bChosen = 1

		def CenterQ()
			This.Center()
			return This

	# CENTER and then divide each feature by its standard deviation -- correlation
	# PCA. Every feature counts equally, whatever it was measured in.
	def Standardize()
		@bStandardize = 1
		@bChosen = 1

		def StandardizeQ()
			This.Standardize()
			return This

	# ── and the passive forms, which return the prepared DATA ──

	# The data centered on the column means, original untouched. This is what a
	# covariance PCA actually decomposes, so it is worth being able to look at.
	def Centered()
		return This._Prepared(0)

	# The data centered AND divided by the column standard deviations. What a
	# correlation PCA decomposes.
	def Standardized()
		return This._Prepared(1)

	def IsStandardized()
		return @bStandardize

	# ── the variance convention, from the library's one authority ──

	def UseSampleVariance()
		@bSample = 1

		def UseSampleVarianceQ()
			This.UseSampleVariance()
			return This

	def UsePopulationVariance()
		@bSample = 0

		def UsePopulationVarianceQ()
			This.UsePopulationVariance()
			return This

	def UsesSampleVariance()
		return @bSample

	# the preparation the two passive forms above return -- done here rather than in
	# the engine because it is a couple of passes and the point is to SEE it
	def _Prepared(bScale)
		_anMu_ = []
		for _j_ = 1 to @nCols
			_n_ = 0
			for _i_ = 1 to @nRows
				_n_ += @aData[_i_][_j_]
			next
			_anMu_ + (_n_ / @nRows)
		next

		_anSd_ = []
		for _j_ = 1 to @nCols
			_anSd_ + 1
		next
		if bScale
			_nDiv_ = @nRows - 1
			if NOT @bSample
				_nDiv_ = @nRows
			ok
			for _j_ = 1 to @nCols
				_nSs_ = 0
				for _i_ = 1 to @nRows
					_nD_ = @aData[_i_][_j_] - _anMu_[_j_]
					_nSs_ += _nD_ * _nD_
				next
				_nS_ = sqrt(_nSs_ / _nDiv_)
				# a constant column has no spread to normalise, and dividing by its
				# zero standard deviation would NaN the whole matrix
				if _nS_ > 0
					_anSd_[_j_] = _nS_
				ok
			next
		ok

		_aOut_ = []
		for _i_ = 1 to @nRows
			_aRow_ = []
			for _j_ = 1 to @nCols
				_aRow_ + ((@aData[_i_][_j_] - _anMu_[_j_]) / _anSd_[_j_])
			next
			_aOut_ + _aRow_
		next
		return _aOut_

	def Fit()
		if NOT @bChosen
			stzraise("Say how to prepare the data first -- Standardize() when the " +
				"features are in different units, Center() when they are " +
				"comparable. There is no safe default: the choice changes which " +
				"component comes first.")
		ok
		if @nRows < 2
			stzraise("PCA needs at least two samples -- one sample has no spread " +
				"to decompose.")
		ok

		_aFlat_ = []
		for _i_ = 1 to @nRows
			for _j_ = 1 to @nCols
				_aFlat_ + @aData[_i_][_j_]
			next
		next

		_nStd_ = 0
		if @bStandardize
			_nStd_ = 1
		ok
		_nSmp_ = 0
		if @bSample
			_nSmp_ = 1
		ok

		_aRes_ = StzEnginePcaFit(_aFlat_, @nRows, @nCols, _nStd_, _nSmp_)
		if NOT isList(_aRes_) or len(_aRes_) < 2
			stzraise("The engine refused the fit (" + @nRows + " x " + @nCols + ").")
		ok

		@nK = _aRes_[1]
		@nTotalVariance = _aRes_[2]
		_nAt_ = 2

		@anMeans = []
		for _i_ = 1 to @nCols
			_nAt_++
			@anMeans + _aRes_[_nAt_]
		next
		@anScales = []
		for _i_ = 1 to @nCols
			_nAt_++
			@anScales + _aRes_[_nAt_]
		next
		@aLoadings = []
		for _i_ = 1 to @nCols
			_aRow_ = []
			for _j_ = 1 to @nK
				_nAt_++
				_aRow_ + _aRes_[_nAt_]
			next
			@aLoadings + _aRow_
		next
		@anSingularValues = []
		for _i_ = 1 to @nK
			_nAt_++
			@anSingularValues + _aRes_[_nAt_]
		next
		@anVariance = []
		for _i_ = 1 to @nK
			_nAt_++
			@anVariance + _aRes_[_nAt_]
		next
		@aScores = []
		for _i_ = 1 to @nRows
			_aRow_ = []
			for _j_ = 1 to @nK
				_nAt_++
				_aRow_ + _aRes_[_nAt_]
			next
			@aScores + _aRow_
		next

		@bFitted = 1

		# the act returns nothing; the Q twin chains, which is what Q is FOR
		def FitQ()
			This.Fit()
			return This

	def IsFitted()
		return @bFitted

	def NumberOfComponents()
		This._MustBeFitted()
		return @nK

	# The DIRECTIONS: row i, column j is how much feature i contributes to component
	# j. A component is a weighted blend of your features, not one of them.
	#
	# The sign is fixed by convention (the largest loading of each component is made
	# positive) because a direction has no preferred sign -- v and -v are the same
	# axis explaining the same variance -- and without a convention two runs can look
	# like they disagree.
	def Components()
		This._MustBeFitted()
		return @aLoadings

		def Loadings()
			return This.Components()

	# The data in component coordinates: row i is sample i, column j its position
	# along component j. Centered by construction, so each column averages zero.
	def Scores()
		This._MustBeFitted()
		return @aScores

	def SingularValues()
		This._MustBeFitted()
		return @anSingularValues

	# How much variance each component accounts for, in the units of the prepared
	# data. These SUM to TotalVariance() -- the decomposition redistributes the
	# variance and cannot create or destroy any.
	def ExplainedVariance()
		This._MustBeFitted()
		return @anVariance

	def TotalVariance()
		This._MustBeFitted()
		return @nTotalVariance

	# The same, as fractions of the total. This is the number people quote.
	def ExplainedVarianceRatio()
		This._MustBeFitted()
		_a_ = []
		for _i_ = 1 to @nK
			if @nTotalVariance > 0
				_a_ + (@anVariance[_i_] / @nTotalVariance)
			else
				_a_ + 0
			ok
		next
		return _a_

	def CumulativeVarianceRatio()
		_aR_ = This.ExplainedVarianceRatio()
		_a_ = []
		_n_ = 0
		for _i_ = 1 to len(_aR_)
			_n_ += _aR_[_i_]
			_a_ + _n_
		next
		return _a_

	# How many components to keep to retain a given fraction of the variance --
	# the usual way the number of components is chosen.
	def NumberOfComponentsFor(nWanted)
		This._MustBeFitted()
		if nWanted <= 0 or nWanted > 1
			stzraise("Give me a fraction between 0 and 1 -- 0.95 for 95% of the " +
				"variance.")
		ok
		_aC_ = This.CumulativeVarianceRatio()
		for _i_ = 1 to len(_aC_)
			if _aC_[_i_] >= nWanted
				return _i_
			ok
		next
		return @nK

	# The centering that was applied, kept because projecting NEW data needs exactly
	# the same one. Data centered on its own mean lands in a different space.
	def Mean()
		This._MustBeFitted()
		return @anMeans

	def Scale()
		This._MustBeFitted()
		return @anScales

	# Project rows the fit has not seen into the component space, using the FIT's
	# centering and scaling.
	# -- THE INVERSE, AND IT IS THE TRANSPOSE --
	#
	# This is where PCA differs in KIND from the rest of the embedding family, not
	# merely in quality. The forward map is a ROTATION onto an orthonormal basis, so
	# undoing it needs no second model, no training and no lookup: multiply by the same
	# loadings the other way round, put the scale back, put the mean back.
	#
	# t-SNE and UMAP have no analytic inverse at all. They must fit a DECODER to
	# (position, row) pairs, and what comes back is a plausible row rather than a
	# recovered one. Here the arithmetic was already sitting in the fit.
	#
	# -- AND THE ERROR IS NOT MYSTERIOUS EITHER --
	#
	# It is exactly the variance living in the components you dropped. Not
	# approximately: the residual IS the projection onto the discarded eigenvectors, so
	# the mean squared reconstruction error over the training rows EQUALS the sum of
	# their eigenvalues -- the numbers ExplainedVariance() already reports. Keep every
	# component and the reconstruction is the data back, to rounding.
	#
	# That identity is checked in the guard, and it is a far stronger statement than any
	# reconstruction number the learned inverses can offer. It says the arithmetic is
	# RIGHT, where they can only say the result looked plausible.
	def Inverse(paScores)
		This._MustBeFitted()
		if NOT isList(paScores) or len(paScores) = 0
			stzraise("Give me a list of score rows to send back.")
		ok
		_nM_ = len(paScores)
		_nK_ = len(paScores[1])
		if _nK_ < 1 or _nK_ > @nK
			stzraise("A score row has " + _nK_ + " value(s); this analysis kept " +
				@nK + " component(s). Fewer is allowed -- reconstructing from the " +
				"leading components is the usual question -- but more is not.")
		ok
		_aFlat_ = []
		for _i_ = 1 to _nM_
			if NOT isList(paScores[_i_]) or len(paScores[_i_]) != _nK_
				stzraise("Score row " + _i_ + " has " + len(paScores[_i_]) +
					" value(s); row 1 had " + _nK_ + ".")
			ok
			for _j_ = 1 to _nK_
				_aFlat_ + paScores[_i_][_j_]
			next
		next

		# the loadings, truncated to the components the caller actually supplied
		_aLoadFlat_ = []
		for _i_ = 1 to @nCols
			for _j_ = 1 to _nK_
				_aLoadFlat_ + @aLoadings[_i_][_j_]
			next
		next

		_aOut_ = StzEnginePcaInverse(_aFlat_, _nM_, @nCols, _nK_,
			@anMeans, @anScales, _aLoadFlat_)
		if NOT isList(_aOut_) or len(_aOut_) != _nM_ * @nCols
			stzraise("The engine refused the reconstruction.")
		ok

		_aRes_ = []
		_nAt2_ = 0
		for _i_ = 1 to _nM_
			_aRow_ = []
			for _j_ = 1 to @nCols
				_nAt2_++
				_aRow_ + _aOut_[_nAt2_]
			next
			_aRes_ + _aRow_
		next
		return _aRes_

	# the training rows put through Transform() and back again -- what the analysis
	# retained of the data it was given, which is the picture worth looking at when
	# deciding how many components are enough
	def Reconstructed()
		This._MustBeFitted()
		return This.Inverse(This.Scores())

	def Transform(paRows)
		This._MustBeFitted()
		if NOT isList(paRows) or len(paRows) = 0
			stzraise("Give me a list of rows to project.")
		ok
		_nM_ = len(paRows)
		_aFlat_ = []
		for _i_ = 1 to _nM_
			if NOT isList(paRows[_i_]) or len(paRows[_i_]) != @nCols
				stzraise("Row " + _i_ + " has " + len(paRows[_i_]) +
					" value(s); this analysis was fitted on " + @nCols + ".")
			ok
			for _j_ = 1 to @nCols
				_aFlat_ + paRows[_i_][_j_]
			next
		next

		_aLoadFlat_ = []
		for _i_ = 1 to @nCols
			for _j_ = 1 to @nK
				_aLoadFlat_ + @aLoadings[_i_][_j_]
			next
		next

		_aOut_ = StzEnginePcaTransform(_aFlat_, _nM_, @nCols, @nK,
			@anMeans, @anScales, _aLoadFlat_)
		if NOT isList(_aOut_) or len(_aOut_) != _nM_ * @nK
			stzraise("The engine refused the projection.")
		ok

		_aRes_ = []
		_nAt_ = 0
		for _i_ = 1 to _nM_
			_aRow_ = []
			for _j_ = 1 to @nK
				_nAt_++
				_aRow_ + _aOut_[_nAt_]
			next
			_aRes_ + _aRow_
		next
		return _aRes_

	def Why()
		This._MustBeFitted()
		_aR_ = This.ExplainedVarianceRatio()
		_c_ = "fitted "
		if @bStandardize
			_c_ += "correlation"
		else
			_c_ += "covariance"
		ok
		_c_ += " PCA on " + @nRows + " sample(s) x " + @nCols + " feature(s): " +
			@nK + " component(s), the first explaining " +
			ceil(_aR_[1] * 1000 - 0.5) / 10 + "% of the variance"
		return _c_

	def _MustBeFitted()
		if NOT @bFitted
			stzraise("Fit() me first.")
		ok
