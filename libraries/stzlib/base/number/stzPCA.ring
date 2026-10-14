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

# Finds the directions along which a table of samples varies most, by singular value decomposition of the centered data.
#
# It is the PCA engine behind stzEmbedding; build one with new stzPCA over a list of samples, each a
# list of feature values (rows are samples, columns are features). You must choose how to prepare
# the data before Fit: Center keeps the units (covariance PCA, for comparable features) and
# Standardize divides each feature by its standard deviation (correlation PCA, for features in
# different units); Fit refuses until you have said which. The variance convention is the library's
# one authority: the sample one (n-1) by default, UsePopulationVariance for n. After Fit, Components
# are the directions (a column per component), Scores the samples in those coordinates,
# ExplainedVariance and its ratio say how much spread each accounts for, Transform projects new rows
# with the fit's mean and scale, and Inverse sends scores back, with an error equal to the variance
# of the dropped components. Checked by hand on four samples, [[2,0],[-2,0],[0,1],[0,-1]] under
# Center: singular values the square roots of 8 and 2, variances 8/3 and 2/3, ratios 0.8 and 0.2.
#
#   receiver   o1 = new stzPCA([ [ 2, 0 ], [ -2, 0 ], [ 0, 1 ], [ 0, -1 ] ])
#   example    o1.Center()
#              o1.Fit()
#              ? @@( o1.ExplainedVarianceRatio() )
#              #--> [ 0.80, 0.20 ]
#              ? o1.NumberOfComponentsFor(0.9)
#              #--> 2
#              ? o1.Why()
#              #--> fitted covariance PCA on 4 sample(s) x 2 feature(s): 2 component(s), the first explaining 80% of the variance
#   see        stzEmbedding, stzNumBuffer, stzListOfNumbers
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

	# Builds a principal component analysis over a table of samples, each a list of feature values.
	#
	#   paData     the list of samples (rows), each a list of the same number of numbers (columns
	#              are features)
	#   returns    nothing; the object is built
	#   note       nothing is computed yet: choose Center or Standardize, then Fit
	#   see        Center, Standardize, Fit
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

	# Returns how many samples, rows, the data holds.
	#
	#   returns    a number
	#   see        NumberOfFeatures, Fit
	def NumberOfSamples()
		return @nRows

	# Returns how many features, columns, each sample holds.
	#
	#   returns    a number
	#   see        NumberOfSamples, NumberOfComponents
	def NumberOfFeatures()
		return @nCols

	# Chooses to subtract each feature's mean and keep its units, which gives a covariance PCA.
	#
	#   returns    nothing; CenterQ returns the analysis for chaining
	#   note       for features of comparable units; Fit refuses to run until Center or Standardize
	#              has been called
	#   see        Standardize, Centered, Fit
	#@ aka  ── the choice you must make ──
	def Center()
		@bStandardize = 0
		@bChosen = 1

		def CenterQ()
			This.Center()
			return This

	# Chooses to subtract each feature's mean and divide by its standard deviation, which gives a correlation PCA.
	#
	#   returns    nothing; StandardizeQ returns the analysis for chaining
	#   note       for features in different units; a constant column is left as zeros and does not
	#              break the fit
	#   see        Center, Standardized, Fit
	#@ aka  CENTER and then divide each feature by its standard deviation -- correlation PCA. Every feature counts equally, whatever it was measured in.
	def Standardize()
		@bStandardize = 1
		@bChosen = 1

		def StandardizeQ()
			This.Standardize()
			return This

	# Returns the data with every feature's mean subtracted, leaving the analysis unchanged.
	#
	#   returns    a list of rows
	#   note       [[2,0],[-2,0],[0,1],[0,-1]] is already centered and comes back as it is
	#   see        Standardized, Center
	#@ aka  ── and the passive forms, which return the prepared DATA ──
	def Centered()
		return This._Prepared(0)

	# Returns the data centered and divided by each feature's standard deviation, leaving the analysis unchanged.
	#
	#   returns    a list of rows
	#   note       the divisor follows the variance convention chosen: [[2,0],[-2,0],[0,1],[0,-1]]
	#              gives 1.2247 where the entries were 2, with the sample convention; a constant
	#              column becomes zeros
	#   see        Centered, Standardize
	#@ aka  The data centered AND divided by the column standard deviations. What a correlation PCA decomposes.
	def Standardized()
		return This._Prepared(1)

	# TRUE if Standardize was chosen, FALSE after Center or before any choice.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        Standardize, Center
	def IsStandardized()
		return @bStandardize

	# Chooses the sample convention, dividing by n minus 1, which is the default.
	#
	#   returns    nothing; UseSampleVarianceQ returns the analysis for chaining
	#   note       call it before Fit
	#   see        UsePopulationVariance, UsesSampleVariance
	#@ aka  ── the variance convention, from the library's one authority ──
	def UseSampleVariance()
		@bSample = 1

		def UseSampleVarianceQ()
			This.UseSampleVariance()
			return This

	# Chooses the population convention, dividing by n.
	#
	#   returns    nothing; UsePopulationVarianceQ returns the analysis for chaining
	#   note       call it before Fit; it changes the variances, not the ratios
	#   see        UseSampleVariance, UsesSampleVariance
	def UsePopulationVariance()
		@bSample = 0

		def UsePopulationVarianceQ()
			This.UsePopulationVariance()
			return This

	# TRUE if the sample convention, dividing by n minus 1, is in force.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       1 on a new analysis
	#   see        UseSampleVariance, UsePopulationVariance
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

	# Computes the analysis by singular value decomposition of the prepared data.
	#
	#   returns    nothing; FitQ returns the analysis for chaining
	#   note       the other reads (Components, Scores...) raise Fit() me first until it has run
	#   warning    raises an error until Center or Standardize has been called, and another with
	#              fewer than two samples
	#   see        IsFitted, Components, Scores
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

		# THE FLATTENING TAX (2026-09-10): the rows go to the bridge as they
		# are; it walks them (5,120,000 appends at 20,000 x 256 used to stand here)
		_nStd_ = 0
		if @bStandardize
			_nStd_ = 1
		ok
		_nSmp_ = 0
		if @bSample
			_nSmp_ = 1
		ok

		_aRes_ = StzEnginePcaFit(@aData, @nRows, @nCols, _nStd_, _nSmp_)
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

	# TRUE if Fit has run.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        Fit
	def IsFitted()
		return @bFitted

	# Returns how many components the analysis kept, the smaller of the samples and the features.
	#
	#   returns    a number
	#   note       2 for two features
	#   warning    raises Fit() me first before Fit
	#   see        NumberOfComponentsFor, Components
	def NumberOfComponents()
		This._MustBeFitted()
		return @nK

	# Returns the directions, one column per component, one row per feature.
	#
	#   returns    a list of rows: row i, column j is how much feature i contributes to component j
	#   note       Loadings is the same call; the sign is fixed so the largest loading of each
	#              component is positive; two features that move together give 0.71 and 0.71 for the
	#              first component
	#   warning    raises Fit() me first before Fit
	#   see        Scores, SingularValues
	#@ aka  The DIRECTIONS: row i, column j is how much feature i contributes to component j. A component is a weighted blend of your features, not one of them.
	def Components()
		This._MustBeFitted()
		return @aLoadings

		def Loadings()
			return This.Components()

	# Returns the samples in component coordinates, one row per sample.
	#
	#   returns    a list of rows, one column per component
	#   note       each column averages zero; the training rows [[2,0],[-2,0],[0,1],[0,-1]] under
	#              Center give themselves back
	#   warning    raises Fit() me first before Fit
	#   see        Components, Transform
	#@ aka  The data in component coordinates: row i is sample i, column j its position along component j. Centered by construction, so each column averages zero.
	def Scores()
		This._MustBeFitted()
		return @aScores

	# Returns the singular value of each component, largest first.
	#
	#   returns    a list of numbers
	#   note       the square of each, divided by n minus 1, is the explained variance: 2.83 and
	#              1.41 for the sample above, whose hand computation is the square roots of 8 and 2
	#   warning    raises Fit() me first before Fit
	#   see        ExplainedVariance, Components
	def SingularValues()
		This._MustBeFitted()
		return @anSingularValues

	# Returns the variance each component accounts for, largest first.
	#
	#   returns    a list of numbers that add up to TotalVariance
	#   note       for the sample [[2,0],[-2,0],[0,1],[0,-1]] it gives 8/3 and 2/3 (2.67 and 0.67)
	#              with the sample convention and 2 and 0.5 with the population one
	#   warning    raises Fit() me first before Fit
	#   see        TotalVariance, ExplainedVarianceRatio
	#@ aka  How much variance each component accounts for, in the units of the prepared data. These SUM to TotalVariance() -- the decomposition redistributes the variance and cannot create or destroy any.
	def ExplainedVariance()
		This._MustBeFitted()
		return @anVariance

	# Returns the total variance of the prepared data, the sum over the components.
	#
	#   returns    a number
	#   note       10/3 (3.33) for the sample above with the sample convention, and the number of
	#              features when standardized with the sample convention
	#   warning    raises Fit() me first before Fit
	#   see        ExplainedVariance, ExplainedVarianceRatio
	def TotalVariance()
		This._MustBeFitted()
		return @nTotalVariance

	# Returns the fraction of the total variance each component accounts for.
	#
	#   returns    a list of numbers that add up to 1
	#   note       0.8 and 0.2 for the sample above, by hand 8 over 10 and 2 over 10; a fraction of
	#              the spread, not of any cause
	#   warning    raises Fit() me first before Fit
	#   see        CumulativeVarianceRatio, ExplainedVariance
	#@ aka  The same, as fractions of the total. This is the number people quote.
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

	# Returns the running total of the variance ratios, component by component.
	#
	#   returns    a list of numbers ending at 1
	#   note       0.8 then 1 for the sample above
	#   warning    raises Fit() me first before Fit
	#   see        ExplainedVarianceRatio, NumberOfComponentsFor
	def CumulativeVarianceRatio()
		_aR_ = This.ExplainedVarianceRatio()
		_a_ = []
		_n_ = 0
		for _i_ = 1 to len(_aR_)
			_n_ += _aR_[_i_]
			_a_ + _n_
		next
		return _a_

	# Returns how many leading components are needed to keep a given fraction of the variance.
	#
	#   nWanted    the fraction to keep, above 0 and at most 1
	#   returns    a number of components
	#   note       0.8 needs 1 component and 0.9 needs 2 for the sample above
	#   warning    raises Fit() me first before Fit
	#   see        CumulativeVarianceRatio, NumberOfComponents
	#@ aka  How many components to keep to retain a given fraction of the variance -- the usual way the number of components is chosen.
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

	# Returns the mean of each feature that Fit subtracted.
	#
	#   returns    a list of numbers, one per feature
	#   note       new data must be centered with the same means; Transform does it
	#   warning    raises Fit() me first before Fit
	#   see        Scale, Transform
	#@ aka  The centering that was applied, kept because projecting NEW data needs exactly the same one. Data centered on its own mean lands in a different space.
	def Mean()
		This._MustBeFitted()
		return @anMeans

	# Returns the divisor of each feature that Fit applied: the standard deviations when standardized, 1 otherwise.
	#
	#   returns    a list of numbers, one per feature
	#   note       1 and 1 under Center
	#   warning    raises Fit() me first before Fit
	#   see        Mean, Transform
	def Scale()
		This._MustBeFitted()
		return @anScales

	# Returns score rows sent back to feature space, undoing the projection, scale and mean.
	#
	#   paScores   the list of score rows to send back
	#   returns    a list of rows, one column per feature
	#   note       scores 2, 0 come back as 2, 0 and a single score 2 as 2, 0; the error left is the
	#              variance of the dropped components
	#   warning    raises Fit() me first before Fit; a row longer than the kept components raises an
	#              error
	#   see        Reconstructed, Transform
	#@ aka  Project rows the fit has not seen into the component space, using the FIT's centering and scaling. -- THE INVERSE, AND IT IS THE TRANSPOSE --
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
		for _i_ = 1 to _nM_
			if NOT isList(paScores[_i_]) or len(paScores[_i_]) != _nK_
				stzraise("Score row " + _i_ + " has " + len(paScores[_i_]) +
					" value(s); row 1 had " + _nK_ + ".")
			ok
		next

		# the loadings, truncated to the components the caller actually
		# supplied -- cut as rows only when a cut is needed; the scores and the
		# loadings go to the bridge as rows (THE FLATTENING TAX, 2026-09-10)
		_aLoad_ = @aLoadings
		if _nK_ < @nK
			_aLoad_ = []
			for _i_ = 1 to @nCols
				_aRow_ = []
				for _j_ = 1 to _nK_
					_aRow_ + @aLoadings[_i_][_j_]
				next
				_aLoad_ + _aRow_
			next
		ok

		_aOut_ = StzEnginePcaInverse(paScores, _nM_, @nCols, _nK_,
			@anMeans, @anScales, _aLoad_)
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

	# Returns the training samples rebuilt from their scores, which shows what the kept components retain.
	#
	#   returns    a list of rows
	#   note       with every component kept the data comes back, to rounding
	#   warning    raises Fit() me first before Fit
	#   see        Inverse, Scores
	#@ aka  the training rows put through Transform() and back again -- what the analysis retained of the data it was given, which is the picture worth looking at when deciding how many components are enough
	def Reconstructed()
		This._MustBeFitted()
		return This.Inverse(This.Scores())

	# Projects new rows into the component space with the mean and scale of the fit.
	#
	#   paRows     the list of rows to project, each as long as the fitted features
	#   returns    a list of rows, one column per component
	#   note       rows unseen by the fit land in the same space as Scores; [[2,0],[0,1],[1,1]]
	#              gives 2,0 and 0,1 and 1,1 for the sample above
	#   warning    raises Fit() me first before Fit
	#   see        Inverse, Scores
	def Transform(paRows)
		This._MustBeFitted()
		if NOT isList(paRows) or len(paRows) = 0
			stzraise("Give me a list of rows to project.")
		ok
		_nM_ = len(paRows)
		for _i_ = 1 to _nM_
			if NOT isList(paRows[_i_]) or len(paRows[_i_]) != @nCols
				stzraise("Row " + _i_ + " has " + len(paRows[_i_]) +
					" value(s); this analysis was fitted on " + @nCols + ".")
			ok
		next

		# THE FLATTENING TAX (2026-09-10): the rows and the loadings go to the
		# bridge as they are; it walks them
		_aOut_ = StzEnginePcaTransform(paRows, _nM_, @nCols, @nK,
			@anMeans, @anScales, @aLoadings)
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

	# Returns one sentence naming the kind of analysis, its shape and the share the first component explains.
	#
	#   returns    a text
	#   note       fitted covariance PCA on 4 sample(s) x 2 feature(s): 2 component(s), the first
	#              explaining 80% of the variance
	#   warning    raises Fit() me first before Fit
	#   see        ExplainedVarianceRatio, Fit
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
