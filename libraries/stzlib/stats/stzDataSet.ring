#====================================================================#
#  SOFTANZA STATISTICS LAYER - Enhanced Analytics Framework          #
#  Four Pillars: Comparison | Composition | Distribution | Relation  #
#====================================================================#

# Global configuration for missing values
$aSTAT_MISSING_VALUES = [ "", "NA", "NULL", "n/a", "#N/A" ]

$aInsightRules = [

    :Finance = [
//        [ "CoVariance() > 50", "High variability ({CoVariance()}) indicates investment risk.", 3 ],
//        [ "Skewness() > 1", "Positive skew ({Skewness()}) suggests potential for extreme gains", 1 ]
    ],

    :Healthcare = [
//       [ "Mean() > 100", "Mean ({Mean()}) exceeds health metric threshold (100).", 3 ]
    ]
]

func StzDataSetQ(paData)
	return new stzDataSet(paData)
    
func CompareDatasets(paData1, paData2)
	oStats1 = new stzDataSet(paData1)
	oStats2 = new stzDataSet(paData2)
	return oStats1.CompareWith(oStats2)

func MissingValues()
    return $aSTAT_MISSING_VALUES

	func @MissingValues()
		return $aSTAT_MISSING_VALUES


class stzDataSet

    @anData = []
    @cDataType = "numeric"  # numeric, categorical, mixed, empty
    @bSorted = FALSE
    @anSortedData = []
    @aCache = []  # Standard Ring hash list as [ [:key, value], ... ]

    @nMinSampleSize = 3  # Minimum for advanced statistics

    def init(paData)
        if CheckParams()
            if NOT isList(paData)
                StzRaise("stzDataSet requires a list of data")
            ok
        ok

        @anData = This._CleanData(paData)
        This._DetectDataType()
        This._InitializeCache()

    def _CleanData(paData)
        # Remove missing values and prepare data
        aCleanData = []
        nLen = len(paData)

        for i = 1 to nLen
            if NOT This._IsMissing(paData[i])
                aCleanData + paData[i]
            ok
        next
        
        return aCleanData

    def _IsMissing(item)
        if isNull(item)
            return TRUE
        ok
        
        cStr = "" + item
        return ring_find($aSTAT_MISSING_VALUES, cStr) > 0

    def _DetectDataType()
        if len(@anData) = 0
            @cDataType = "empty"
            return
        ok

        nNumeric = 0
        nCategorical = 0
        nLen = len(@anData)

        for i = 1 to nLen
            if IsNumber(@anData[i])
                nNumeric++
            else
                nCategorical++
            ok
        next

        if nNumeric = nLen
            @cDataType = "numeric"
        but nCategorical = nLen
            @cDataType = "categorical"
        else
            @cDataType = "mixed"
        ok



    def _SortIfNeeded()
        if @cDataType = "numeric" and NOT @bSorted
            @anSortedData = sort(@anData)
            @bSorted = TRUE
        ok

    #=================================================#
    #  PILLAR 1: COMPARISON - Descriptive Statistics  #
    #=================================================#

    def Mean()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        
        cKey = "mean"
        nCached = This._GetCached(cKey)

        if NOT IsNull(nCached)
            return nCached
        ok
        
        nSum = 0
        nLen = len(@anData)
        
        for i = 1 to nLen
            nSum += @anData[i]
        next
        
        nMean = nSum / nLen
        This._SetCache(cKey, nMean)
        return nMean

		def Average()
			return This.Mean()

		def Avrg()
			return This.Mean()


    def Median()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        
        cKey = "median"
        nCached = This._GetCached(cKey)

        if NOT IsNull(nCached)
            return nCached
        ok
        
        This._SortIfNeeded()
        nLen = len(@anSortedData)
        
        nMedian = 0
        if nLen % 2 = 1
            nMedian = @anSortedData[ceil(nLen/2)]
        else
            nMid1 = @anSortedData[nLen/2] 
            nMid2 = @anSortedData[nLen/2 + 1]
            nMedian = (nMid1 + nMid2) / 2
        ok
        
        This._SetCache(cKey, nMedian)
        return nMedian

	def Mode()
	    if len(@anData) = 0
	        return NULL
	    ok
	
	    cKey = "mode"
	    cached = This._GetCached(cKey)

	    if NOT isNull(cached)
	        return cached
	    ok
	
	    nLen = len(@anData)
	    aFreqHash = []
	
	    for i = 1 to nLen
	        cItemKey = "" + @anData[i]
	        if isNumber(aFreqHash[cItemKey])
	            aFreqHash[cItemKey]++
	        else
	            aFreqHash + [cItemKey, 1]
	        ok
	    next
	
	    nMaxFreq = 0
	    cModeKey = ""
	    nLen = len(aFreqHash)  # Fixed: use aFreqHash length
	
	    for i = 1 to nLen
	        if aFreqHash[i][2] > nMaxFreq  # Fixed: iterate through aFreqHash
	            nMaxFreq = aFreqHash[i][2]
	            cModeKey = aFreqHash[i][1]
	        ok
	    next
	
	    This._SetCache(cKey, cModeKey)
	    return cModeKey

    def StandardDeviation()
        if @cDataType != "numeric" or len(@anData) <= 1
            return 0
        ok
        
        cKey = "stddev"
        nCached = This._GetCached(cKey)

        if NOT IsNull(nCached)
            return nCached
        ok
        
        nMean = This.Mean()
        nSumSquares = 0
        nLen = len(@anData)
        
        for i = 1 to nLen
            nDiff = @anData[i] - nMean
            nSumSquares += (nDiff * nDiff)
        next
        
        nVariance = nSumSquares / (nLen - 1)
        nStdDev = sqrt(nVariance)
        This._SetCache(cKey, nStdDev)
        return nStdDev

		def StdDev()
			return This.StandardDeviation()

	def Variance()
	    if @cDataType != "numeric" or len(@anData) <= 1
	        return 0
	    ok
	    
	    cKey = "variance"
	    nCached = This._GetCached(cKey)

	    if NOT isNull(nCached)
	        return nCached
	    ok
	    
	    nMean = This.Mean()

	    nSumSquares = 0
	    nLen = len(@anData)
	    
	    for i = 1 to nLen
	        nDiff = @anData[i] - nMean
	        nSumSquares += (nDiff * nDiff)
	    next
	    
	    nVariance = nSumSquares / (nLen - 1)
	    This._SetCache(cKey, nVariance)
	    return nVariance

		def Var()
			return This.Variance()

		def V()
			return This.Variance()

    def Range()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        return This.Max() - This.Min()

    def Min()
        if @cDataType != "numeric" or len(@anData) = 0
            return NULL
        ok
        return @min(@anData)

    def Max()
        if @cDataType != "numeric" or len(@anData) = 0
            return NULL
        ok
        return @max(@anData)

    def Sum()
        if @cDataType != "numeric"
            return 0
        ok

		nLen = len(@anData)
        nSum = 0

        for i = 1 to nLen
            nSum += @anData[i]
        next
        
        return nSum

    def Count()
        return len(@anData)

    def GeometricMean()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok

		nLen = len(@anData)

        # Check for non-positive values
        for i = 1 to nLen
            if @anData[i] <= 0
                return 0  # Geometric mean undefined for non-positive values
            ok
        next
        
        nProduct = 1      
        for i = 1 to nLen
            nProduct *= @anData[i]
        next
        
        return pow(nProduct, 1/nLen)

		#< @FunctionAlternativeForms

		def GeoMean()
			return This.GeometricMean()

		def GMean()
			return This.GeometricMean()

		def GeometricAverage()
			return This.GeometricMean()

		def GeoAverage()
			return This.GeometricMean()

		def GAverage()
			return This.GeometricMean()

		def GeoAvrg()
			return This.GeometricMean()

		def GAvrg()
			return This.GeometricMean()

		#>

    def HarmonicMean()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        
        nSum = 0
        nLen = len(@anData)
        
        for i = 1 to nLen
            if @anData[i] = 0
                return 0  # Harmonic mean undefined for zero values
            ok
            nSum += (1 / @anData[i])
        next
        
        return nLen / nSum

		#< @FunctionAlternativeForms

		def HarMean()
			return This.HarmonicMean()

		def HMean()
			return This.HarmonicMean()

		def HarmonicAverage()
			return This.HarmonicMean()

		def HarAverage()
			return This.HarmonicMean()

		def HAverage()
			return This.HarmonicMean()

		def HarAvrg()
			return This.HarmonicMean()

		def HAvrg()
			return This.HarmonicMean()

		#>

    def CoefficientOfVariation()
        if @cDataType != "numeric" or This.Mean() = 0
            return 0
        ok
        
        return This.StandardDeviation() / abs(This.Mean()) * 100

		def CoVar()
			return This.CoefficientOfVariation()

		def CoVariance()
			return This.CoefficientOfVariation()

		def CV()
			return This.CoefficientOfVariation()

	#---

    def CompareWith(oOtherStats)
        # Comprehensive comparison with another dataset
        if oOtherStats.Count() = 0 or This.Count() = 0
            return "Cannot compare with empty dataset"
        ok
        
        aComparison = []
        
        if @cDataType = "numeric" and oOtherStats.DataType() = "numeric"
            # Numeric comparison
            nMean1 = This.Mean()
            nMean2 = oOtherStats.Mean()
            nMeanDiff = ((nMean1 - nMean2) / nMean2) * 100
            
            aComparison + ("Mean difference: " + nMeanDiff + "%")
            
            nStd1 = This.StandardDeviation()
            nStd2 = oOtherStats.StandardDeviation()
            
            if nStd1 > nStd2 * 1.5
                aComparison + "Dataset 1 shows higher variability"
            but nStd2 > nStd1 * 1.5
                aComparison + "Dataset 2 shows higher variability"
            else
                aComparison + "Similar variability patterns"
            ok
            
            # Correlation if same size
            if This.Count() = oOtherStats.Count()
                nCorr = This.CorrelationWith(oOtherStats)
                if abs(nCorr) > 0.7
                    cDirection = iff(nCorr > 0, "positive", "negative")
                    aComparison + ( "Strong " + cDirection + " correlation (" + nCorr + ")" )
                ok
            ok
        else
            # Categorical or mixed comparison
            nDiv1 = This.Diversity()
            nDiv2 = oOtherStats.Diversity()
            
            if abs(nDiv1 - nDiv2) > 0.2
                cHigher = iff(nDiv1 > nDiv2, "Dataset 1", "Dataset 2")
                aComparison + ( cHigher + " shows higher diversity" )
            else
                aComparison + "Similar diversity levels"
            ok
        ok
        
        return aComparison

		def CompareTo(oOtherStats)
			return This.CompareWith(oOtherStats)

		def Compare(oOtherStats)
			if isList(oOtherStats) and StzListQ(oOtherStats).IsWithOrToNamedParam()
				oOtherStats = oOtherStats[2]
			ok

			return This.CompareWith(oOtherStats)

    def SimilarityScore(oOtherStats)
        # Calculate similarity score between datasets (0-1 scale)
        if oOtherStats.Count() = 0 or This.Count() = 0
            return 0
        ok
        
        if @cDataType != oOtherStats.DataType()
            return 0  # Different data types
        ok
        
        if @cDataType = "numeric"
            # Numeric similarity based on statistical properties
            nMeanSim = 1 - abs(This.Mean() - oOtherStats.Mean()) / (abs(This.Mean()) + abs(oOtherStats.Mean()) + 1)
            nStdSim = 1 - abs(This.StandardDeviation() - oOtherStats.StandardDeviation()) / (This.StandardDeviation() + oOtherStats.StandardDeviation() + 1)
            
            return (nMeanSim + nStdSim) / 2
        else
            # Categorical similarity based on overlap
            aUnique1 = This.UniqueValues()
            aUnique2 = oOtherStats.UniqueValues()
            
            nIntersection = 0
			nLen = len(aUnique1)

            for i = 1 to nLen
                if ring_find(aUnique2, aUnique1[i]) > 0
                    nIntersection++
                ok
            next
            
            nUnion = len(aUnique1) + len(aUnique2) - nIntersection
            return nIntersection / nUnion
        ok

		def SimilarityScoreWith(oOtherStats)
			return This.SimilarityScore(oOtherStats)

		def SimScore(oOtherStats)
			return This.SimilarityScore(oOtherStats)

		def SimScoreWith(oOtherStats)
			return SimilarityScore(oOtherStats)


	#---

    def ConfidenceInterval(nConfidence)
        if nConfidence = 0
            nConfidence = 95
        ok

        # Calculate confidence interval for the mean
        if @cDataType != "numeric" or len(@anData) < 2
            return [0, 0]
        ok
        
        nMean = This.Mean()
        nStdDev = This.StandardDeviation()
        nLen = len(@anData)
        
        # Using t-distribution approximation
        nAlpha = (100 - nConfidence) / 100
        nTValue = 1.96  # Approximation for 95% confidence
        
        if nConfidence = 90
            nTValue = 1.645
        but nConfidence = 99
            nTValue = 2.576
        ok
        
        nMarginError = nTValue * (nStdDev / sqrt(nLen))
        
        return [nMean - nMarginError, nMean + nMarginError]

		def ConfInt()
			return This.ConfidentialInterval()


    #============================================================#
    #  PILLAR 2: COMPOSITION - Frequency & Categorical Analysis  #
    #============================================================#

	def FrequencyTable()
	    cKey = "freq_table"
	    cached = This._GetCached(cKey)

	    if NOT isNull(cached)
	        return cached
	    ok
	
	    aFreqHash = []
	    nLen = len(@anData)
	
	    for i = 1 to nLen
	        cItemKey = "" + @anData[i]
	
	        if isNumber(aFreqHash[cItemKey])
	            aFreqHash[cItemKey]++
	        else
	            aFreqHash[cItemKey] = 1
	        ok
	    next
	
	    # Convert hash to array of pairs
	    aFreqTable = []
	    for cKey in keys(aFreqHash)
	        aFreqTable + [cKey, aFreqHash[cKey]]
	    next
	
	    This._SetCache(cKey, aFreqTable)
	    return aFreqTable
	
	def RelativeFrequency()
	    aFreqTable = This.FrequencyTable()
	
	    nTotal = This.Count()
	    aRelFreq = []
	
	    nLen = len(aFreqTable)
	
	    for i = 1 to nLen
	        nRelativeFreq = aFreqTable[i][2] / nTotal
	        aRelFreq + [aFreqTable[i][1], nRelativeFreq]
	    next
	    
	    return aRelFreq
	
	def RelFreq()
	    return This.RelativeFrequency()

    def PercentageFrequency()

        aRelFreq = This.RelativeFrequency()
        aPercFreq = []

        nLen = len(aRelFreq)

        for i = 1 to nLen
            nPercentage = aRelFreq[i][2] * 100
            aPercFreq + [aRelFreq[i][1], nPercentage]
        next
        
        return aPercFreq

		def PercentFreq()
			return This.PercentageFrequency()

    def UniqueCount()
        return len(This.UniqueValues())

		def UCount()
			return len(This.UniqueValues())

    def UniqueValues()
        cKey = "unique_values"
        cached = This._GetCached(cKey)

        if NOT isNull(cached)
            return cached
        ok

		nLen = len(@anData)
        aUnique = []

        for i = 1 to nLen
            if ring_find(aUnique, @anData[i]) = 0
                aUnique + @anData[i]
            ok
        next
        
        This._SetCache(cKey, aUnique)
        return aUnique

		def UVals()
			return This.UniqueValues()

    def Diversity()
        # Unique values / Total values
        nTotal = This.Count()
        if nTotal = 0
            return 0
        ok
        return This.UniqueCount() / nTotal

		def DiversityIndex()
			return This.Diversity()

    def EntropyIndex()
        # Shannon entropy for diversity measurement
        if len(@anData) = 0
            return 0
        ok
        
        aFreqTable = This.FrequencyTable()
        nTotal = This.Count()
        nEntropy = 0
        
		nLen = len(aFreqTable)

        for i = 1 to nLen
            nProbability = aFreqTable[i][2] / nTotal
            if nProbability > 0
                nEntropy -= nProbability * log(nProbability) / log(2)
            ok
        next
        
        return nEntropy

		def Entropy()
			return This.EntropyIndex()


    #====================================================#
    #  PILLAR 3: DISTRIBUTION - Shape & Spread Analysis  #
    #====================================================#

	#NOTE

	# Linear interpolation : Standard in most statistical
	# software (R, Python, Excel). More accurate for continuous
	# distributions and provides smoother results.

	# Nearest-rank: Simpler, always returns actual data values.
	# Preferred in some educational contexts and when you need
	# exact data points.

	def Percentile(nPercent)
		return This.PercentileXT(nPercent, "interpolation")

	def PercentileXT(nPercent, cMethod) # interpolation or nearest
	    if @cDataType != "numeric" or len(@anData) = 0
	        return 0
	    ok
	    
	    # Default to interpolation method
	    if cMethod = NULL
	        cMethod = "interpolation"
	    ok
	    
	    This._SortIfNeeded()
	    nLen = len(@anSortedData)
	    
	    if cMethod = "nearest" or cMethod = "nearestrank"
	        nRank = ceil((nLen * nPercent) / 100)
	        
	        if nRank < 1
	            nRank = 1
	        but nRank > nLen
	            nRank = nLen
	        ok
	        
	        return @anSortedData[nRank]
	    else
	        # Linear interpolation method (default)
	        nPosition = (nLen * nPercent) / 100
	        
	        if nPosition <= 1
	            return @anSortedData[1]
	        but nPosition >= nLen
	            return @anSortedData[nLen]
	        ok
	        
	        # Linear interpolation
	        nLower = floor(nPosition)
	        nUpper = nLower + 1
	        nFraction = nPosition - nLower
	        
	        if nUpper > nLen
	            return @anSortedData[nLower]
	        ok
	        
	        nLowerVal = @anSortedData[nLower]
	        nUpperVal = @anSortedData[nUpper]
	        return nLowerVal + (nFraction * (nUpperVal - nLowerVal))
	    ok


	def Q1()
		return This.Percentile(25)

		def Q1XT(cMethod)
		    return This.PercentileXT(25, cMethod)
	
	def Q2()
		return This.Median()

		def Q2XT(cMethod)
		    # Median is typically the same regardless of method
		    return This.Median()
	
	def Q3()
		return This.Percentile(75)

		def Q3XT(cMethod)
		    return This.PercentileXT(75, cMethod)
	
	def IQR()
		return This.Q3() - This.Q1()

		def IQRXT(cMethod)
		    return This.Q3XT(cMethod) - This.Q1XT(cMethod)
	
	def Quartiles()
		return [This.Q1(), This.Q2(), This.Q3()]

	def QuartilesXT(cMethod)
	    return [This.Q1XT(cMethod), This.Q2XT(cMethod), This.Q3XT(cMethod)]

	#---

    def Skew()
        if @cDataType != "numeric" or len(@anData) < @nMinSampleSize
            return 0
        ok
        
        cKey = "skewness"
        nCached = This._GetCached(cKey)

        if NOT isNull(nCached)
            return nCached
        ok
        
        nMean = This.Mean()
        nStdDev = This.StandardDeviation()
        
        if nStdDev = 0
            return 0
        ok
        
        nLen = len(@anData)
        nSum = 0
        
        for i = 1 to nLen
            nStandardized = (@anData[i] - nMean) / nStdDev
            nSum += (nStandardized * nStandardized * nStandardized)
        next
        
        nSkew = (nSum / nLen) * (nLen / ((nLen - 1) * (nLen - 2)))
        This._SetCache(cKey, nSkew)
        return nSkew

		def Skewness()
			return Skew()

    def Kurtosis()
        if @cDataType != "numeric" or len(@anData) < 4
            return 0
        ok
        
        cKey = "kurtosis"
        nCached = This._GetCached(cKey)

        if NOT isNull(nCached)
            return nCached
        ok
        
        nMean = This.Mean()
        nStdDev = This.StandardDeviation()
        
        if nStdDev = 0
            return 0
        ok
        
        nLen = len(@anData)
        nSum = 0
        
        for i = 1 to nLen
            nStandardized = (@anData[i] - nMean) / nStdDev
            nSum += (nStandardized * nStandardized * nStandardized * nStandardized)
        next
        
        nKurt = (nSum / nLen) * (nLen * (nLen + 1)) / ((nLen - 1) * (nLen - 2) * (nLen - 3))
        nAdjustment = (3 * (nLen - 1) * (nLen - 1)) / ((nLen - 2) * (nLen - 3))
        
        nResult = nKurt - nAdjustment
        This._SetCache(cKey, nResult)
        return nResult

		def Kurtos()
			return Kurtosis()

    def Outliers()
        if @cDataType != "numeric"
            return []
        ok
        
        cKey = "outliers"
        cached = This._GetCached(cKey)

        if IsNull(cached)
            return cached
        ok
        
        nQ1 = This.Q1()
        nQ3 = This.Q3()
        nIQR = This.IQR()
        
        nLowerBound = nQ1 - (1.5 * nIQR)
        nUpperBound = nQ3 + (1.5 * nIQR)
        
        aOutliers = []
        nLen = len(@anData)
        for i = 1 to nLen
            if @anData[i] < nLowerBound or @anData[i] > nUpperBound
                aOutliers + @anData[i]
            ok
        next
        
        This._SetCache(cKey, aOutliers)
        return aOutliers

    def IsOutlier(nValue)
        aOutliers = This.Outliers()
        return ring_find(aOutliers, nValue) > 0

    def ZScores()
        if @cDataType != "numeric"
            return []
        ok
        
        nMean = This.Mean()
        nStdDev = This.StandardDeviation()
        
        if nStdDev = 0
            return @anData  # No variation
        ok
        
        aZScores = []
		nLen = len(@anData)
        for i = 1 to nLen
            nZScore = (@anData[i] - nMean) / nStdDev
            aZScores + nZScore
        next
        
        return aZScores


    def MovingAverage(nWindow)
        if nWindow = 0
            nWindow = 3
        ok
        # Calculate moving average with specified window
        if @cDataType != "numeric" or nWindow <= 0
            return @anData
        ok
        
        if len(@anData) < nWindow
            return @anData
        ok
        
        aMovingAvg = []
        nLen = len(@anData)
        
        for i = 1 to (nLen - nWindow + 1)
            nSum = 0
            for j = i to (i + nWindow - 1)
                nSum += @anData[j]
            next
            aMovingAvg + (nSum / nWindow)
        next
        
        return aMovingAvg

		def MovAvrg()
			return This.MovingAverage()

		def MovingMean()
			return This.MovingAverage()

		def MovMean()
			return This.MovingAverage()

	#--- TREND ANALYSIS SECTION (PART OF PILLAR 3 - DITRIBUTION)

	def TrendAnalysis()
	    # Granular trend analysis detecting segments and inflection points
	    if @cDataType != "numeric" or len(@anData) < 2
	        return [ ["insufficient_data", len(@anData)] ]
	    ok
	    
	    nLen = len(@anData)
	    
	    # For simple cases (2-3 points), use basic trend
	    if nLen <= 3
	        return This._SimpleSeriesTrend()
	    ok
	    
	    # Calculate consecutive differences
	    aDifferences = []
	    for i = 2 to nLen
	        aDifferences + (@anData[i] - @anData[i-1])
	    next
	    
	    # Classify each difference
	    aTrends = []
	    nTolerance = This._CalculateTolerance()
	    for i = 1 to len(aDifferences)
	        aTrends + This._ClassifyDifference(aDifferences[i], nTolerance)
	    next
	    
	    # Build segments - walker visits data positions without overlap
	    aTrendSegments = []
	    cCurrentTrend = aTrends[1]
	    nSegmentStart = 1  # Start at first data position
	    
	    for i = 2 to len(aTrends)
	        if aTrends[i] != cCurrentTrend
	            # Trend change detected at difference i
	            # Previous segment covers from nSegmentStart to position i
	            nSegmentLength = i - nSegmentStart + 1
	            aTrendSegments + [cCurrentTrend, nSegmentLength]
	            cCurrentTrend = aTrends[i]
	            nSegmentStart = i + 1  # Next segment starts AFTER transition point
	        ok
	    next
	    
	    # Add final segment
	    nFinalLength = len(@anData) - nSegmentStart + 1
	    aTrendSegments + [cCurrentTrend, nFinalLength]
	    
	    return aTrendSegments
	
	def _SimpleSeriesTrend()
	    nLen = len(@anData)
	    if nLen = 2
	        nDiff = @anData[2] - @anData[1]
	        nTolerance = This._CalculateTolerance()
	        cTrend = This._ClassifyDifference(nDiff, nTolerance)
	        return [[cTrend, 2]]
	    ok
	    
	    # For 3 points, check if consistent trend
	    nDiff1 = @anData[2] - @anData[1]
	    nDiff2 = @anData[3] - @anData[2]
	    nTolerance = This._CalculateTolerance()
	    
	    cTrend1 = This._ClassifyDifference(nDiff1, nTolerance)
	    cTrend2 = This._ClassifyDifference(nDiff2, nTolerance)
	    
	    if cTrend1 = cTrend2
	        return [[cTrend1, 3]]
	    else
	        return [[cTrend1, 2], [cTrend2, 2]]
	    ok
	
	def _CalculateTolerance()
	    # Calculate tolerance based on data scale and variability
	    nRange = This.Range()
	    nStdDev = This.StandardDeviation()
	    
	    # Use smaller of 1% of range or 10% of standard deviation
	    nRangeTolerance = nRange * 0.01
	    nStdTolerance = nStdDev * 0.1
	    
	    nTolerance = iff(nRangeTolerance < nStdTolerance and nRangeTolerance > 0, 
	                    nRangeTolerance, nStdTolerance)
	    
	    # Ensure minimum tolerance to avoid over-sensitivity
	    if nTolerance < 0.001
	        nTolerance = 0.001
	    ok
	    
	    return nTolerance
	
	def _ClassifyDifference(nDiff, nTolerance)
	    if abs(nDiff) <= nTolerance
	        return "stable"
	    but nDiff > 0
	        return "up"
	    else
	        return "down"
	    ok

    #===========================================================#
    #  PILLAR 4: RELATION - Correlation & Association Analysis  #
    #===========================================================#

    def CorrelationWith(oOtherStats)
        if @cDataType != "numeric" or oOtherStats.DataType() != "numeric"
            return 0
        ok
        
        aOtherData = oOtherStats.Data()
        if len(@anData) != len(aOtherData) or len(@anData) < 2
            return 0
        ok
        
        nMean1 = This.Mean()
        nMean2 = oOtherStats.Mean()
        nLen = len(@anData)
        nSumProduct = 0
        nSumSq1 = 0
        nSumSq2 = 0
        
        for i = 1 to nLen
            nDiff1 = @anData[i] - nMean1
            nDiff2 = aOtherData[i] - nMean2
            nSumProduct += nDiff1 * nDiff2
            nSumSq1 += nDiff1 * nDiff1
            nSumSq2 += nDiff2 * nDiff2
        next
        
        if nSumSq1 = 0 or nSumSq2 = 0
            return 0
        ok
        
        return nSumProduct / sqrt(nSumSq1 * nSumSq2)

		def CorelWith()
			return This.CorrelationWith(oOtherStats)

		def Corel()
			return This.CorrelationWith(oOtherStats)

		def Cor()
			return This.CorrelationWith(oOtherStats)


    def CovarianceWith(oOtherStats)
        if @cDataType != "numeric" or oOtherStats.DataType() != "numeric"
            return 0
        ok
        
        aOtherData = oOtherStats.Data()
        if len(@anData) != len(aOtherData) or len(@anData) < 2
            return 0
        ok
        
        nMean1 = This.Mean()
        nMean2 = oOtherStats.Mean()
        nLen = len(@anData)
        nSum = 0
        
        for i = 1 to nLen
            nSum += (@anData[i] - nMean1) * (aOtherData[i] - nMean2)
        next
        
        return nSum / (nLen - 1)

		def CovarWith(oOtherStats)
			return This.CovarianceWith(oOtherStats)

		def CVWith(oOtherStats)
			return This.CovarianceWith(oOtherStats)

    def RankCorrelationWith(oOtherStats)
        # Spearman's rank correlation coefficient
        if @cDataType != "numeric" or oOtherStats.DataType() != "numeric"
            return 0
        ok
        
        aOtherData = oOtherStats.Data()
        if len(@anData) != len(aOtherData) or len(@anData) < 2
            return 0
        ok
        
        # Create rankings
        aRanks1 = This._GetRanks(@anData)
        aRanks2 = This._GetRanks(aOtherData)
        
        # Calculate correlation of ranks
        oRank1 = new stzDataSet(aRanks1)
        oRank2 = new stzDataSet(aRanks2)
        
        return oRank1.CorrelationWith(oRank2)

		def RankCorelWith(oOtherStats)
			return This.RankCorrelationWith(oOtherStats)

		def NonParametricCorrelation()
			return This.RankCorrelationWith(oOtherStats)


    def _GetRanks(aData)
        aIndexed = []
        nLen = len(aData)
        
        # Create value-index pairs
        for i = 1 to nLen
            aIndexed + [aData[i], i]
        next
        
        # Sort by value

        aIndexed = @SortOn(1, aIndexed)
        
        # Assign ranks
        aRanks = []
        for i = 1 to nLen
            aRanks + 0  # Initialize
        next
        
        for i = 1 to nLen
            nOriginalIndex = aIndexed[i][2]
            aRanks[nOriginalIndex] = i
        next
        
        return aRanks

	def ChiSquareWith(oOtherStats)
	    # Chi-square test for independence (categorical data)
	    if @cDataType != "categorical" or oOtherStats.DataType() != "categorical"
	        return 0
	    ok
	    
	    aOtherData = oOtherStats.Data()
	    if len(@anData) != len(aOtherData) or len(@anData) < 2
	        return 0
	    ok
	    
	    # Create cache key using stringified list
	    cKey = "chi_square_" + @@(oOtherStats.Data())
	    nCached = This._GetCached(cKey)

	    if NOT isNull(nCached)
	        return nCached
	    ok
	    
	    # Get unique categories for both datasets
	    aUnique1 = This.UniqueValues()
	    aUnique2 = oOtherStats.UniqueValues()
	    
	    if len(aUnique1) = 0 or len(aUnique2) = 0
	        return 0
	    ok
	    
	    # Initialize contingency table
	    nRows = len(aUnique1)
	    nCols = len(aUnique2)
	    aContingency = []
	    for i = 1 to nRows
	        aRow = []
	        for j = 1 to nCols
	            aRow + 0
	        next
	        aContingency + aRow
	    next
	    
	    # Populate contingency table with observed frequencies
	    nLen = len(@anData)
	    for i = 1 to nLen
	        nRow = ring_find(aUnique1, @anData[i])
	        nCol = ring_find(aUnique2, aOtherData[i])
	        if nRow > 0 and nCol > 0
	            aContingency[nRow][nCol]++
	        ok
	    next
	    
	    # Calculate row and column totals
	    aRowTotals = []
	    aColTotals = []
	    nGrandTotal = 0
	    
	    for i = 1 to nRows
	        nRowTotal = 0
	        for j = 1 to nCols
	            nRowTotal += aContingency[i][j]
	        next
	        aRowTotals + nRowTotal
	        nGrandTotal += nRowTotal
	    next
	    
	    for j = 1 to nCols
	        nColTotal = 0
	        for i = 1 to nRows
	            nColTotal += aContingency[i][j]
	        next
	        aColTotals + nColTotal
	    next
	    
	    # Check for zero totals
	    if nGrandTotal = 0
	        return 0
	    ok
	    
	    # Calculate chi-square statistic
	    nChiSquare = 0
	    for i = 1 to nRows
	        for j = 1 to nCols
	            nObserved = aContingency[i][j]
	            nExpected = (aRowTotals[i] * aColTotals[j]) / nGrandTotal
	            if nExpected > 0
	                nChiSquare += ((nObserved - nExpected) * (nObserved - nExpected)) / nExpected
	            ok
	        next
	    next
	    
	    nResult = nChiSquare
	    This._SetCache(cKey, nResult)
	    return nResult

		def CategoricalAssociationWith(oOtherStats)
			return This.ChiSquareWith(oOtherStats)


    #=====================#
    #  DATA PROCESSING    #
    #=====================#

    def Normalize()
        # Min-Max normalization (0-1 scale)
        if @cDataType != "numeric"
            return @anData
        ok
        
        nMin = This.Min()
        nMax = This.Max()
        nRange = nMax - nMin
        
        if nRange = 0
            return @anData  # All values are the same
        ok
        
        aNormalized = []
		nLen = len(@anData)

        for i = 1 to nLen
            nNormalized = (@anData[i] - nMin) / nRange
            aNormalized + nNormalized
        next
        
        return aNormalized

    def Standardize()
        # Z-score standardization
        if @cDataType != "numeric"
            return @anData
        ok
        
        nMean = This.Mean()
        nStdDev = This.StandardDeviation()
        
        if nStdDev = 0
            return @anData  # No variation
        ok
        
        aStandardized = []
		nLen = len(@anData)

        for i = 1 to nLen
            nStandardized = (@anData[i] - nMean) / nStdDev
            aStandardized + nStandardized
        next
        
        return aStandardized
 
    def RobustScale()
        # Scale using median and IQR (robust to outliers)
        if @cDataType != "numeric"
            return @anData
        ok
        
        nMedian = This.Median()
        nIQR = This.IQR()
        
        if nIQR = 0
            return @anData
        ok
        
        aScaled = []
		nLen = len(@anData)

        for i = 1 to nLen
            nScaled = (@anData[i] - nMedian) / nIQR
            aScaled + nScaled
        next
        
        return aScaled


    #=============================#
    #  DATA QUALITY AND GUIDANCE  #
    #=============================#

    def ValidateData()
        # Validate data integrity and quality
        acIssues = []

        if len(@anData) = 0
            acIssues + "Dataset is empty"
            return acIssues
        ok
        
        if @cDataType = "numeric"
            # Check for infinite or NaN values
			nLen = len(@anData)
            for i = 1 to nLen
                if isNull(@anData[i])
                    aIssues + "Contains null values"
                    exit
                ok
            next

            # Check for extreme outliers
            aOutliers = This.Outliers()
            if len(aOutliers) > (This.Count() * 0.2)
                acIssues + "High proportion of outliers detected"
            ok
            
            # Check for variance
            if This.StandardDeviation() = 0
                acIssues + "No variance in data (all values identical)"
            ok
        ok
        
        if len(acIssues) = 0
            acIssues + "Data quality appears good"
        ok
        
        return acIssues

		def Validate()
			return This.ValidateData()

		def Issues()
			return This.ValidateData()

    def RecommendAnalysis()
        # Suggest appropriate analysis methods based on data characteristics
        acRecommendations = []
        
        nCount = This.Count()
        if nCount < 10
            acRecommendations + "Small sample size - interpret results cautiously"
        ok
        
        if @cDataType = "numeric"

            nSkew = This.Skewness()
            if abs(nSkew) > 1
                acRecommendations + "Data is skewed - consider using median instead of mean"
            ok
            
            aOutliers = This.Outliers()
            if len(aOutliers) > 0
                acRecommendations + "Outliers detected - consider robust statistics"
            ok
            
            if This.CoefficientOfVariation() > 50
                acRecommendations + "High variability - segment analysis recommended"
            ok

        else
            if This.Diversity() < 0.3
                acRecommendations + "Low diversity - focus on dominant categories"
            ok
            
            if This.UniqueCount() = This.Count()
                acRecommendations + "All values unique - consider grouping or classification"
            ok
        ok
        
        if len(acRecommendations) = 0
            acRecommendations + "Standard statistical analysis appropriate"
        ok
        
        return acRecommendations

		#< @AlternativeFunctionForms

		def Recommendations()
			return This.RecommendAnalysis()

		def Advises()
			return This.RecommendAnalysis()

		def Advizes()
			return This.RecommendAnalysis()

		def Recommend()
			return This.RecommendAnalysis()

		def Advize()
			return This.RecommendAnalysis()

		#>

    #===============================================#
    #  STATISTICS NATIVE INSIGHT GENERATION SYSTEM  #
    #===============================================#

    def Insight()
        return This.GenerateInsight()

	def GenerateInsight()
	    aAllInsights = []
	    
	    # Get base insights
	    switch @cDataType
	    on "numeric"
	        aAllInsights = This._GenerateNumericInsight()

	    on "categorical" 
	        aAllInsights = This._GenerateCategoricalInsight()

	    on "mixed"
	    	aAllInsights = This._GenerateMixedInsight()

		on "empty"
			aAllInsights = ["Dataset is empty. No analysis possible without data."]
		other
			StzRaise("Unknowan data type! Supported types are :Numberic, :Categorical, :Mixed, and :Empty.")

	    off
	    
	    # Add Statistics domain rules
	    aStatInsights = This.InsightsOfDomain(:Statistics)
		nLen = len(aStatInsights)
	    for i = 1 to nLen
	        aAllInsights + aStatInsights[i]
	    next
	    
	    return aAllInsights

    def _GenerateNumericInsight()
        aInsights = [] # Keep as list of complete sentences
        
        # Basic descriptive insights
        nMean = This.Mean()
        nMedian = This.Median()
        nStdDev = This.StandardDeviation()
        nCount = This.Count()
        nCV = This.CoefficientOfVariation()
        
        # Distribution shape
        nSkew = This.Skewness()
        nKurt = This.Kurtosis()
        
        # Central tendency
        nMeanMedianDiff = abs(nMean - nMedian)
        nMeanMedianRatio = iff(nMedian != 0, nMeanMedianDiff / abs(nMedian), 0)
        
        if nMeanMedianRatio < 0.05
            aInsights + ( "The data is symmetrically distributed with mean " + nMean + " and median " + nMedian + "." )
        but nMean > nMedian
            aInsights + ( "Data shows positive skew (mean " + nMean + " > median " + nMedian + ")" )
        else
            aInsights + ( "Data shows negative skew (mean " + nMean + " < median " + nMedian + ")" )
        ok
        
        # Variability assessment
        if nCV < 15
            aInsights + ( "The data shows low variability with a coefficient of variation of " + nCV + "%, indicating consistent values." )
        but nCV < 30
            aInsights + ( "Moderate variability (CV = " + nCV + "%) shows normal spread" )
        else
            aInsights + ( "High variability (CV = " + nCV + "%) indicates diverse data points" )
        ok
        
        # Distribution shape insights
        if abs(nSkew) > 1
            cSkewDirection = iff(nSkew > 0, "right", "left")
            aInsights + ( "Strong " + cSkewDirection + "-skew (skewness = " + nSkew + ") affects central tendency interpretation" )
        ok
        
        if nKurt > 1
            aInsights + ( "Heavy-tailed distribution (kurtosis = " + nKurt + ") suggests potential extreme values" )
        but nKurt < -1
            aInsights + ( "Light-tailed distribution (kurtosis = " + nKurt + ") indicates fewer extreme values" )
        ok
        
        # Outlier analysis
        aOutliers = This.Outliers()
        if len(aOutliers) > 0
            nOutlierPercent = (len(aOutliers) * 100) / nCount
            aInsights + ( "Contains " + len(aOutliers) + " outlier(s) (" + nOutlierPercent + "% of data)" )
            
            if nOutlierPercent > 10
                aInsights + ( "High outlier proportion may distort mean-based statistics" )
            ok
        ok
        
        # Sample size assessment
        if nCount < 10
            aInsights + ( "Small sample size (n = " + nCount + ") limits statistical reliability" )
        but nCount > 100
            aInsights + ( "Large sample size (n = " + nCount + ") provides robust statistical foundation" )
        ok
        
        return aInsights # Return list directly

    def _GenerateCategoricalInsight()
        aInsights = []
        
        nCount = This.Count()
        nUnique = This.UniqueCount()
        nDiversity = This.Diversity()
        cMode = This.Mode()
        aPercFreq = This.PercentageFrequency()
        nEntropy = This.EntropyIndex()
        
        # Diversity insights
        if nDiversity < 0.3
            aInsights + ( "Low diversity (" + nDiversity * 100 + "%) indicates concentration in few categories" )
        but nDiversity < 0.7
            aInsights + ( "Moderate diversity (" + nDiversity * 100 + "%) shows balanced distribution" )
        else
            aInsights + ( "High diversity (" + nDiversity * 100 + "%) suggests wide variety" )
        ok
        
        # Entropy analysis
        nMaxEntropy = log(nUnique) / log(2)
        nEntropyRatio = iff(nMaxEntropy > 0, nEntropy / nMaxEntropy, 0)
        
        if nEntropyRatio > 0.8
            aInsights + ( "Information entropy (" + nEntropy + ") indicates balanced category distribution" )
        but nEntropyRatio < 0.5
            aInsights + ( "Low entropy (" + nEntropy + ") suggests strong category concentration" )
        ok
        
        # Modal analysis
        nModeFreq = 0
		nLen = len(aPercFreq)

		for i = 1 to nLen
            if aPercFreq[i][1] = ("" + cMode)
                nModeFreq = aPercFreq[i][2]
                exit
            ok
        next
        
        if nModeFreq > 50
            aInsights + ( "'" + cMode + "' dominates (" + nModeFreq + "%) indicating strong preference" )
        but nModeFreq > 30
            aInsights + ( "'" + cMode + "' is most common (" + nModeFreq + "%) but distribution remains balanced" )
        else
            aInsights + ( "No dominant category - '" + cMode + "' leads at " + nModeFreq + "%" )
        ok
        
        # Category count assessment
        if nUnique <= 3
            aInsights + ( "Limited categories (n = " + nUnique + ") suggest focused classification" )
        but nUnique = nCount
            aInsights + ( "All values unique - resembles identifier data rather than categories" )
        ok
        
        return aInsights # Return list directly

    def _GenerateMixedInsight()
        nCount = This.Count()
        nUnique = This.UniqueCount()
        
        aInsights = []
        aInsights + ( "Mixed dataset containing both numeric and categorical data (" + nUnique + " unique values from " + nCount + " total)" )
        aInsights + ( "Consider separating data types for specialized analysis. Numeric methods apply only to numeric subset" )
        return aInsights # Return list directl

    def Insights() # Native statistic-insights
        # Return insights as clean list of sentences
        return This.GenerateInsight()
 
		def StatInsights()
			 return This.GenerateInsight()

		def StatsInsights()
			 return This.GenerateInsight()

		def NativeInsights()
			 return This.GenerateInsight()

	def InsightsXT() # stats and other domains insights

		acResults = This.Insights()

		nLen = len($aInsightRules)

		for i = 1 to nLen

			aDomain = $aInsightRules[i][2]
			nLenDomain = len(aDomain)

			for j = 1 to nLenDomain
				if This._EvaluateCondition(aDomain[j][1])
					acResults + aDomain[j][2]
				ok
			next

		next

	    return acResults

		def StatAndDomainInsights()
			 return This.InsightsXT()

		def StatsAndDomainsInsights()
			 return This.InsightsXT()

		def NativeAndDomainInsights()
			 return This.InsightsXT()
		
	def InsightsOfDomain(cDomain)

	    acResults = []

	    if HasKey($aInsightRules, cDomain)

			nLen = len($aInsightRules[cDomain])

			for i = 1 to nLen
	            if This._EvaluateCondition($aInsightRules[cDomain][i][1])
	                acResults + _EvaluateRule($aInsightRules[cDomain][i][2])
	            ok
	        next

	    ok

	    return acResults

		def InsightsForDomain(cDomain)
			return This.InsightsOfDomain(cDomain)


    #====================================================================#
    #  DOMAIN-SPECIFIC, RULE-BASED, WEIGTENED INSIGHT GENERATION SYSTEM  #
    #====================================================================#
    
	def AddInsightRule(cDomain, cCondition, cInsight)
	    if NOT HasKey($aInsightRules, cDomain)
	        $aInsightRules[cDomain] = []
	    ok
	    $aInsightRules[cDomain] + [cCondition, cInsight]

    def AddRule(cDomain, cCondition, cInsight)
        This.AddInsightRule(cDomain, cCondition, cInsight)

	def _EvaluateCondition(cCondition)
	    # Replace method calls with actual values before eval


		cCode = 'bResult = ' + cCondition
		eval(cCode)

		return bResult       

	def _Interpolate(cInsight)
		# Transforms a dynamic insight string like this:
		# "High mean ({Mean()}) for investment."
		# to a concrete final string like this
		# "High mean (10) for investment."	

		oTempStr = new stzString(cInsight)
		aSections = oTempStr.FindSubStringsBoundedByZZ([ "{", "}" ])
		acMethods = oTempStr.Sections(aSections)
		nLen = len(aSections)
		
		aValues = []
		for i = 1 to nLen
			cCode = 'value = ' + acMethods[i]
			eval(cCode)
			aValues + Stringify(value)
		next

		for i = 1 to nLen
			aSections[i][1]--
			aSections[i][2]++
		next

		oTempStr.ReplaceSectionsByMany(aSections, aValues)
		
		cResult = oTempStr.Content()

		return cResult

	def AddWeightedRule(cDomain, cCondition, cInsight, nWeight)
	    if nWeight = NULL nWeight = 1 ok
	    if NOT HasKey($aInsightRules, cDomain)
	        $aInsightRules[cDomain] = []
	    ok

	    # Don't interpolate here - do it when evaluating
	    $aInsightRules[cDomain] + [cCondition, cInsight, nWeight]
	
	def PrioritizedInsights(cDomain)
	    aResults = []
	
	    if HasKey($aInsightRules, cDomain)
	        aRules = $aInsightRules[cDomain]
			nLen = len(aRules)	

	        for i = 1 to nLen
	            aRule = aRules[i]  # Get the rule array
	            cCondition = aRule[1]  # Get condition
	            
	            if This._EvaluateCondition(cCondition)
    				cInsight = This._Interpolate(aRule[2])
    				nWeight = 1
	
    				if len(aRule) > 2
        				nWeight = aRule[3]
    				ok

    				aResults + [cInsight, nWeight]
	            ok
	        next
	
	        # Sort by weight descending  
	        aResults = SortOnXT(2, aResults, :Descending)
	    ok
	    
	    return aResults
	
	def _EvaluateRule(cInsight)
	    # This method should interpolate dynamic content
	    return This._Interpolate(cInsight)


	#=======================#
	#  SIMPLE CACHE SYSTEM  #
	#=======================#

	def _InitializeCache()
	    @aCache = []
	
	def _GetCached(cKey)
	    return @aCache[cKey]

	def _CacheKeys()
		nLen = len(@aCache)
		acKeys = []

		for i = 1 to nLen
			acKeys = @aCache[i]
		next

		return acKeys

	def _KeyIsCached(cKey)

		if NOT (isString(cKey) and @trim(cKey) != "")
			StzRaise("Incorrect param type! cKey must be a non empty string.")
		ok

		if ring_find( This._CacheKeys(), lower(cKey))
			return TRUE
		else
			return FALSE
		ok

	def _RemoveFromCache(cKey)
		if NOT (isString(cKey) and @trim(cKey) != "")
			StzRaise("Incorrect param type! cKey must be a non empty string.")
		ok

		n = ring_find(This._CacheKeys(), lower(cKey))
		if n > 0
			del(@aCache, n)
		ok

	def _SetCache(cKey, value)
	    
	    # Remove existing key if present
		_RemoveFromCache(cKey)
	    
	    # Add new cache entry
	    @aCache + [cKey, value]
	
	def ClearCache()
	    @aCache = []
        @bSorted = FALSE
        @anSortedData = []

	def Cache()
	    return @aCache

    #================================#
    #  UTILITY AND ACCESSOR METHODS  #
    #================================#

    def Data()
        return @anData

    def DataType()
        return @cDataType

    def SortedData()
        if @cDataType = "numeric"
            This._SortIfNeeded()
            return @anSortedData
        ok
        return @anData

    def Summary()
        # Comprehensive summary of the dataset
        cSummary = BoxifyRound("Dataset Content") + NL
		cSummary += @@(This.Content()) + NL + NL
      
        cSummary += BoxifyRound("Dataset Summary") + NL
        cSummary += "• Type: " + @cDataType + NL
        cSummary += "• Count: " + This.Count() + NL
        
        if @cDataType = "numeric"
            cSummary += "• Mean: " + This.Mean() + NL
            cSummary += "• Median: " + This.Median() + NL
            cSummary += "• Standard Deviation: " + This.StandardDeviation() + NL
            cSummary += "• Range: " + This.Range() + " (" + This.Min() + " to " + This.Max() + ")" + NL
            
            aQuartiles = This.Quartiles()
            cSummary += "• Quartiles: Q1=" + aQuartiles[1] + ", Q2=" + aQuartiles[2] + ", Q3=" + aQuartiles[3] + NL
            
            aOutliers = This.Outliers()
            if len(aOutliers) > 0
                cSummary += "• Outliers: " + len(aOutliers) + " detected" + NL
            ok

        else
            cSummary += "• Unique Values: " + This.UniqueCount() + NL
            cSummary += "• Diversity: " + This.Diversity() * 100 + "%" + NL
            cSummary += "• Most Common: " + This.Mode() + NL
        ok
        
        cSummary += NL + BoxifyRound("Dataset Insights") + NL
        aInsights = This.GenerateInsight()
		nLen = len(aInsights)
        for i = 1 to nLen
            cSummary += "• " + aInsights[i] + NL
        next
        
        return cSummary

    def Export()
        # Export statistical results as structured data
        oExport = new stzHashList([])
        aExport = []

        aExport + ["data_type", @cDataType]
        aExport + ["count", This.Count()]
        aExport + ["unique_count", This.UniqueCount()]
        
        if @cDataType = "numeric"
            aExport + ["mean", This.Mean()]
            aExport + ["median", This.Median()]
            aExport + ["mode", This.Mode()]
            aExport + ["standard_deviation", This.StandardDeviation()]
            aExport + ["variance", This.Variance()]
            aExport + ["range", This.Range()]
            aExport + ["min", This.Min()]
            aExport + ["max", This.Max()]
            aExport + ["quartiles", This.Quartiles()]
            aExport + ["skewness", This.Skewness()]
            aExport + ["kurtosis", This.Kurtosis()]
            aExport + ["outliers", This.Outliers()]

        else
            aExport + ["mode", This.Mode()]
            aExport + ["diversity", This.Diversity()]
            aExport + ["entropy", This.EntropyIndex()]
            aExport + ["frequency_table", This.FrequencyTable()]

        ok
        
        return aExport


	def Values()
		return @anData

		def Content()
			return @anData

	def Copy()
		return new stzDataSet(This.Content())

	def Rules()
		return $aInsightRules



    #==========================#
    #  PRIVATE HELPER METHODS  #
    #==========================#

	PRIVATE

    def _IsVarDefined(cVarName)
        # Check if instance variable is defined
        try
            eval("This." + cVarName)
            return TRUE
        catch
            return FALSE
        done

    def _SafeDivision(nNumerator, nDenominator)
        if nDenominator = 0
            return 0
        ok
        return nNumerator / nDenominator
