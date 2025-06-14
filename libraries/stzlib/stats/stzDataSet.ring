#====================================================================#
#  SOFTANZA STATISTICS LAYER - Enhanced Analytics Framework          #
#  Four Pillars: Comparison | Composition | Distribution | Relation  #
#====================================================================#

# Thresholds and Constants (used in conditions and templates)
$nSmallSampleSizeThreshold = 10
$nSkewnessThreshold = 1
$nDiversityThreshold = 0.3
$nEntropyThreshold = 1.5
$nMeanDifferenceThreshold = 0.05
$nVarThreshold = 50
$nMovingAverageWindow = 3
$nFinanceMeanThreshold = 100
$nFinanceVolatilityThreshold = 20
$nHealthcareStdDevThreshold = 50

# Insight Templates

$aEmptyInsightTemplates = [
	[ :condition = "nothing", :template = "Dataset is empty. No analysis possible without data." ]
]

$aMixedInsightTemplates = [ 

	[
		:condition = "nothing",
		:template = "Mixed dataset containing both numeric and categorical data ({UniqueCount()} unique values from {Count()} total)"
	],

	[
		:condition = "nothing",
		:template = "Consider separating data types for specialized analysis. Numeric methods apply only to numeric subset"
	]
]


$aNumericInsightTemplates = [
    [
        :condition = "abs(Mean() - Median()) / abs(Median()) < $nMeanDifferenceThreshold",
        :template  = "The data is symmetrically distributed with mean {Mean()} and median {Median()}."
    ],
    [
        :condition = "Mean() > Median()",
        :template = "Data shows positive skew (mean {Mean()} > median {Median()})."
    ],
    [
        :condition = "CoefficientOfVariation() > $nVarThreshold",
        :template = "High variability (CV = {CoefficientOfVariation()}%) indicates diverse data points."
    ]
]

$aCategoricalInsightTemplates = [
    [
        :condition = "Diversity() < $nDiversityThreshold",
        :template = "Low diversity ({Diversity() * 100}%) indicates concentration in few categories."
    ],
    [
        :condition = "Entropy() > $nEntropyThreshold",
        :template = "Information entropy ({Entropy()}) indicates balanced category distribution."
    ]
]

# General Recommendation Templates
$aRecommendationActions = [
    [
        :condition = "Count() < $nSmallSampleSizeThreshold",
        :recommendation = "Small sample size - interpret results cautiously.",
        :action = "Consider using This.MovingAverage($nMovingAverageWindow) to smooth trends: {This.MovingAverage($nMovingAverageWindow)}",
        :narration = "The dataset has few values ({Count()}). Smoothing with MovingAverage($nMovingAverageWindow) helps stabilize trends."
    ],
    [
        :condition = "abs(Skewness()) > $nSkewnessThreshold",
        :recommendation = "Data is skewed - consider using median instead of mean.",
        :action = "Use This.Median() for central tendency: {This.Median()}",
        :narration = "Skewness ({Skewness()}) indicates imbalance. Median ({This.Median()}) is a stable measure."
    ],
    [
        :condition = "ContainsOutliers()",
        :recommendation = "Outliers detected - consider robust statistics.",
        :action = "Apply This.TrimmedMean(10) to reduce outlier impact: {This.TrimmedMean(10)}",
        :narration = "Outliers distort results. TrimmedMean({This.TrimmedMean(10)}) excludes extremes for clarity."
    ]
]

# Domain-Specific Insight Rules
$aDomainInsightRules = [

    :Finance = [
        [
            :condition = "Mean() > $nFinanceMeanThreshold",
            :template = "Mean ({Mean()}) exceeds financial threshold."
        ],
        [
            :condition = "CoefficientOfVariation() > $nFinanceVolatilityThreshold",
            :template = "High volatility ({CoefficientOfVariation()}%) in financial data."
        ]
    ],

    :Healthcare = [
        [
            :condition = "StandardDeviation() > $nHealthcareStdDevThreshold",
            :template = "High variability ({StandardDeviation()}) in health metrics."
        ]
    ],

    :Education = [
        [
            :condition = "Median() < 50",
            :template = "Median score ({Median()}) below passing threshold."
        ],
        [
            :condition = "Diversity() > 0.5",
            :template = "High diversity in responses indicates varied student performance."
        ]
    ]
]

# Class Capabilities Catalog
$aStatFunctions = [
    [
        "method": "Mean",
        "parameters": [],
        "constraints": "DataType() = 'numeric'",
        "output": "number",
        "description": "Calculates the arithmetic mean of the dataset."
    ],
    [
        "method": "Median",
        "parameters": [],
        "constraints": "DataType() = 'numeric'",
        "output": "number",
        "description": "Calculates the median of the dataset."
    ],
    [
        "method": "TrimmedMean",
        "parameters": ["nTrimPercent"],
        "constraints": "DataType() = 'numeric' and nTrimPercent >= 0 and nTrimPercent < 50",
        "output": "number",
        "description": "Calculates the trimmed mean by removing a percentage of extreme values."
    ],
    [
        "method": "MovingAverage",
        "parameters": ["nWindow"],
        "constraints": "DataType() = 'numeric' and nWindow > 0",
        "output": "list",
        "description": "Calculates the moving average over a specified window."
    ],
    [
        "method": "CoefficientOfVariation",
        "parameters": [],
        "constraints": "DataType() = 'numeric'",
        "output": "number",
        "description": "Calculates the coefficient of variation as a percentage."
    ],
    [
        "method": "Skewness",
        "parameters": [],
        "constraints": "DataType() = 'numeric'",
        "output": "number",
        "description": "Calculates the skewness of the dataset."
    ],
    [
        "method": "Diversity",
        "parameters": [],
        "constraints": "DataType() = 'categorical'",
        "output": "number",
        "description": "Calculates the diversity index of categorical data."
    ],
    [
        "method": "Entropy",
        "parameters": [],
        "constraints": "DataType() = 'categorical'",
        "output": "number",
        "description": "Calculates the information entropy of categorical data."
    ],
    [
        "method": "ContainsOutliers",
        "parameters": [],
        "constraints": "DataType() = 'numeric'",
        "output": "bool",
        "description": "Checks if the dataset contains outliers."
    ]

	#TODO // Add all the other statistical methods of the class
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

func DataSetTemplates()
	return Flatten([
		$aEmptyInsightTemplates,
		$aNumericInsightTemplates,
		$aCategoricalInsightTemplates,
		$aMixedInsightTemplates
	])

func DataSetTemplatesXT(cType)
	if CheckParams() and NOT isString(cType)
		SteRaise("Incorrect param type! cType must be a string.")
	ok

	switch cType
	on "empty"
		return $aEmptyInsightTemplates

	on "numeric"
		return $aNumericInsightTemplates

	on "categorical"
		return $aCategoricalInsightTemplates

	on "mixed"
		return $aMixedInsightTemplates

	other
		return []
	off


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
	        bFound = FALSE
	        
	        # Search for existing key in frequency list
	        for j = 1 to len(aFreqHash)
	            if aFreqHash[j][1] = cItemKey
	                aFreqHash[j][2]++
	                bFound = TRUE
	                exit
	            ok
	        next
	        
	        # Add new key if not found
	        if NOT bFound
	            aFreqHash + [cItemKey, 1]
	        ok
	    next
	
	    nMaxFreq = 0
	    cModeKey = ""
	    nFreqLen = len(aFreqHash)
	
	    for i = 1 to nFreqLen
	        if aFreqHash[i][2] > nMaxFreq
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


	#---

	def WeightedMean(aWeights)
	    if @cDataType != "numeric" or len(@anData) = 0
	        return 0
	    ok
	    
	    if NOT isList(aWeights) or len(aWeights) != len(@anData)
	        StzRaise("Weights must be a list with same length as data")
	    ok
	    
	    cKey = "weightedmean_" + This._HashList(aWeights)
	    nCached = This._GetCached(cKey)
	    
	    if NOT IsNull(nCached)
	        return nCached
	    ok
	    
	    nWeightedSum = 0
	    nWeightSum = 0
	    nLen = len(@anData)
	    
	    for i = 1 to nLen
	        nWeightedSum += @anData[i] * aWeights[i]
	        nWeightSum += aWeights[i]
	    next
	    
	    if nWeightSum = 0
	        return 0
	    ok
	    
	    nResult = nWeightedSum / nWeightSum
	    This._SetCache(cKey, nResult)
	    return nResult

		def WMean(aWeights)
			return This.WMean(aWeights)


	def TrimmedMean(nTrimPercent)
	    if @cDataType != "numeric" or len(@anData) = 0
	        return 0
	    ok
	    
	    if nTrimPercent < 0 or nTrimPercent >= 50
	        StzRaise("Trim percentage must be between 0 and 50")
	    ok
	    
	    cKey = "trimmedmean_" + nTrimPercent
	    nCached = This._GetCached(cKey)
	    
	    if NOT IsNull(nCached)
	        return nCached
	    ok
	    
	    This._SortIfNeeded()
	    nLen = len(@anSortedData)
	    nTrimCount = floor((nLen * nTrimPercent) / 100)
	    
	    if nTrimCount * 2 >= nLen
	        return This.Median()
	    ok
	    
	    nSum = 0
	    nStart = nTrimCount + 1
	    nEnd = nLen - nTrimCount
	    
	    for i = nStart to nEnd
	        nSum += @anSortedData[i]
	    next
	    
	    nResult = nSum / (nEnd - nStart + 1)
	    This._SetCache(cKey, nResult)
	    return nResult
	
		def TMean(nTrimPercent)
			return This.TrimmedMean(nTrimPercent)


	def PercentileRank(nValue)
	    if @cDataType != "numeric" or len(@anData) = 0
	        return 0
	    ok
	    
	    This._SortIfNeeded()
	    nLen = len(@anSortedData)
	    nBelow = 0
	    nEqual = 0
	    
	    for i = 1 to nLen
	        if @anSortedData[i] < nValue
	            nBelow++
	        but @anSortedData[i] = nValue
	            nEqual++
	        ok
	    next
	    
	    return ((nBelow + (nEqual / 2)) / nLen) * 100

		def PRank(nValue)
			return This.PercentileRank(nValue)


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
	
		def FreqTable()
			return This.FrequencyTable()


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

		def UValues()
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


	#---

	def ContingencyTable(oOtherDataSet)
	    if NOT isObject(oOtherDataSet)
	        StzRaise("ContingencyTable requires another stzDataSet object")
	    ok
	    
	    aData1 = @anData
	    aData2 = oOtherDataSet.Data()
	    
	    if len(aData1) != len(aData2)
	        StzRaise("Both datasets must have same length")
	    ok
	    
	    aUniqueX = This.UniqueValues()
	    aUniqueY = oOtherDataSet.UniqueValues()
	    aTable = []
	    
	    # Initialize table
		nLenX = len(aUniqueX)
		nLenY = len(aUniqueY)

	    for i = 1 to nLenX
	        aRow = []
	        for j = 1 to nLenY
	            aRow + 0
	        next
	        aTable + [aUniqueX[i], aRow]
	    next
	    
	    # Count occurrences
	    nLen = len(aData1)
	    for k = 1 to nLen
	        nXIndex = ring_find(aUniqueX, aData1[k])
	        nYIndex = ring_find(aUniqueY, aData2[k])
	        if nXIndex > 0 and nYIndex > 0
	            aTable[nXIndex][2][nYIndex]++
	        ok
	    next
	    
	    return [aUniqueY, aTable]
	
		def ContingTable()
			return This.ContingencyTable()



	def ModeCount()
	    if len(@anData) = 0
	        return 0
	    ok
	    
	    cKey = "modecount"
	    nCached = This._GetCached(cKey)
	    
	    if NOT IsNull(nCached)
	        return nCached
	    ok
	    
	    aFreqTable = This.FrequencyTable()
	    if len(aFreqTable) = 0
	        return 0
	    ok
	    
	    nMaxFreq = 0
	    nLen = len(aFreqTable)
	    
	    for i = 1 to nLen
	        if aFreqTable[i][2] > nMaxFreq
	            nMaxFreq = aFreqTable[i][2]
	        ok
	    next
	    
	    This._SetCache(cKey, nMaxFreq)
	    return nMaxFreq


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
	        nPosition = ((nLen - 1) * nPercent) / 100 + 1
	        
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
        
        nSkew = nSum / ((nLen - 1) * (nLen - 2))
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


	def ContainsOutliers()
		return len(This.Outliers()) > 0

    def Outliers()
        if @cDataType != "numeric"
            return []
        ok
        
        cKey = "outliers"
        cached = This._GetCached(cKey)

        if NOT IsNull(cached)
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
	    
	    nLenData = len(@anData)
	    
	    # For simple cases (2-3 points), use basic trend
	    if nLenData <= 3
	        return This._SimpleSeriesTrend()
	    ok
	    
	    # Calculate consecutive differences
	    aDifferences = []
	    for i = 2 to nLenData
	        aDifferences + (@anData[i] - @anData[i-1])
	    next
	    
	    # Classify each difference
	    aTrends = []
	    nTolerance = This._CalculateTolerance()
		nLenDiff = len(aDifferences)
	    for i = 1 to nLenDiff
	        aTrends + This._ClassifyDifference(aDifferences[i], nTolerance)
	    next
	    
	    # Build segments - walker visits data positions without overlap
	    aTrendSegments = []
	    cCurrentTrend = aTrends[1]
	    nSegmentStart = 1  # Start at first data position
	    nLenTrends = len(aTrends)

	    for i = 2 to nLenTrends
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
	    nFinalLength = nLenData - nSegmentStart + 1
	    aTrendSegments + [cCurrentTrend, nFinalLength]
	    
	    return aTrendSegments

		def Trend()
			return This.TrendAnalysis()


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


	#---

	def Deciles()
	    if @cDataType != "numeric" or len(@anData) = 0
	        return []
	    ok
	    
	    cKey = "deciles"
	    aCached = This._GetCached(cKey)
	    
	    if NOT IsNull(aCached)
	        return aCached
	    ok
	    
	    aDeciles = []
	    for i = 10 to 90 step 10
	        aDeciles + This.Percentile(i)
	    next
	    
	    This._SetCache(cKey, aDeciles)
	    return aDeciles
	

	def BoxPlotStats() # Prepare data series for stzBoxPlot

	    if @cDataType != "numeric" or len(@anData) = 0
	        return []
	    ok
	    
	    cKey = "boxplotstats"
	    aCached = This._GetCached(cKey)
	    
	    if NOT IsNull(aCached)
	        return aCached
	    ok
	    
	    nQ1 = This.Q1()
	    nQ2 = This.Q2()
	    nQ3 = This.Q3()
	    nIQR = This.IQR()
	    
	    nLowerFence = nQ1 - (1.5 * nIQR)
	    nUpperFence = nQ3 + (1.5 * nIQR)
	    
	    This._SortIfNeeded()
	    nWhiskerLow = @anSortedData[1]
	    nWhiskerHigh = @anSortedData[len(@anSortedData)]
	    
	    # Find actual whisker values within fences
	    nLen = len(@anSortedData)
	    for i = 1 to nLen
	        if @anSortedData[i] >= nLowerFence
	            nWhiskerLow = @anSortedData[i]
	            exit
	        ok
	    next
	    
	    for i = nLen to 1 step -1
	        if @anSortedData[i] <= nUpperFence
	            nWhiskerHigh = @anSortedData[i]
	            exit
	        ok
	    next
	    
	    aResult = [
	        [:min, This.Min()],
	        [:q1, nQ1],
	        [:median, nQ2],
	        [:q3, nQ3],
	        [:max, This.Max()],
	        [:whisker_low, nWhiskerLow],
	        [:whisker_high, nWhiskerHigh],
	        [:iqr, nIQR]
	    ]
	    
	    This._SetCache(cKey, aResult)
	    return aResult
	
		def BoxPlotData()
			return This.BoxPlot()


	def NormalityTest()
	    # Simplified normality test based on skewness and kurtosis
	    if @cDataType != "numeric" or len(@anData) < 4
	        return [["test", "insufficient_data"], ["p_value", 0], ["is_normal", 0]]
	    ok
	    
	    cKey = "normalitytest"
	    aCached = This._GetCached(cKey)
	    
	    if NOT IsNull(aCached)
	        return aCached
	    ok
	    
	    nSkew = This.Skewness()
	    nKurt = This.Kurtosis()  # Already excess kurtosis (normal = 0)
	    
	    # Normal distribution: skewness ≈ 0, excess kurtosis ≈ 0
	    # Use stricter thresholds since your data shows high deviations
	    bIsNormal = (abs(nSkew) < 1) and (abs(nKurt) < 1)
	    
	    # Calculate p-value based on combined deviation
	    nSkewDev = abs(nSkew)
	    nKurtDev = abs(nKurt) 
	    nCombinedDev = sqrt(nSkewDev * nSkewDev + nKurtDev * nKurtDev)
	    
	    # Exponential decay for p-value
	    nPValue = exp(-nCombinedDev)
	    
	    if nPValue > 1
	        nPValue = 1
	    ok
	    
	    nIsNormalFlag = 0
	    if bIsNormal
	        nIsNormalFlag = 1
	    ok
	    
	    aResult = [
	        ["test", "heuristic"],
	        ["skewness", nSkew],
	        ["kurtosis", nKurt],
	        ["p_value", nPValue],
	        ["is_normal", nIsNormalFlag]
	    ]
	    
	    This._SetCache(cKey, aResult)
	    return aResult

		def Normality()
			return This.NormalityTest()


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

		def CorelWith(oOtherStats)
			return This.CorrelationWith(oOtherStats)

		def Corel(oOtherStats)
			return This.CorrelationWith(oOtherStats)

		def Cor(oOtherStats)
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

	#---

	def RegressionCoefficients(oOtherDataSet)
	    if @cDataType != "numeric" or oOtherDataSet.DataType() != "numeric"
	        return [[:slope, 0], [:intercept, 0], [:r_squared, 0]]
	    ok
	    
	    aOtherData = oOtherDataSet.Data()
	    if len(@anData) != len(aOtherData) or len(@anData) < 2
	        return [[:slope, 0], [:intercept, 0], [:r_squared, 0]]
	    ok
	    
	    nMeanX = This.Mean()
	    nMeanY = oOtherDataSet.Mean()
	    nLen = len(@anData)
	    nSumXY = 0
	    nSumXX = 0
	    
	    for i = 1 to nLen
	        nDiffX = @anData[i] - nMeanX
	        nDiffY = aOtherData[i] - nMeanY
	        nSumXY += nDiffX * nDiffY
	        nSumXX += nDiffX * nDiffX
	    next
	    
	    if nSumXX = 0
	        return [[:slope, 0], [:intercept, nMeanY], [:r_squared, 0]]
	    ok
	    
	    nSlope = nSumXY / nSumXX
	    nIntercept = nMeanY - (nSlope * nMeanX)
	    nCorr = This.CorrelationWith(oOtherDataSet)
	    nRSquared = nCorr * nCorr
	    
	    return [[:slope, nSlope], [:intercept, nIntercept], [:r_squared, nRSquared]]
	
		def RCoefficients(oOtherDataSet)
			return This.RegressionCoefficients(oOtherDataSet)


	def PartialCorrelation(oDataSetY, oDataSetZ)
	    # Partial correlation between X and Y controlling for Z
	    if @cDataType != "numeric" or oDataSetY.DataType() != "numeric" or oDataSetZ.DataType() != "numeric"
	        return 0
	    ok
	    
	    nRxy = This.CorrelationWith(oDataSetY)
	    nRxz = This.CorrelationWith(oDataSetZ)
	    nRyz = oDataSetY.CorrelationWith(oDataSetZ)
	    
	    nDenom = sqrt((1 - nRxz * nRxz) * (1 - nRyz * nRyz))
	    
	    if nDenom = 0
	        return 0
	    ok
	    
	    return (nRxy - nRxz * nRyz) / nDenom
	
		def PCorrelation(oDataSetY, oDataSetZ)
			return This.PartialCorrelation(oDataSetY, oDataSetZ)

		def PartCorrelation(oDataSetY, oDataSetZ)
			return This.PartialCorrelation(oDataSetY, oDataSetZ)

		def PartCorel(oDataSetY, oDataSetZ)
			return This.PartialCorrelation(oDataSetY, oDataSetZ)


	def MutualInformation(oOtherDataSet)
	    # Simplified mutual information for categorical data
	    aData1 = @anData
	    aData2 = oOtherDataSet.Data()
	    
	    if len(aData1) != len(aData2) or len(aData1) = 0
	        return 0
	    ok
	    
	    # Create joint frequency table
	    aJointFreq = []
	    nTotal = len(aData1)
	    
	    for i = 1 to nTotal
	        cPair = "" + aData1[i] + "_" + aData2[i]
	        nIndex = This._FindInFreqList(aJointFreq, cPair)
	        if nIndex = 0
	            aJointFreq + [cPair, 1]
	        else
	            aJointFreq[nIndex][2]++
	        ok
	    next
	    
	    # Calculate marginal frequencies
	    aFreq1 = This.FrequencyTable()
	    aFreq2 = oOtherDataSet.FrequencyTable()
	    
	    # Calculate mutual information
	    nMI = 0
	    nJointLen = len(aJointFreq)
	    
	    for i = 1 to nJointLen
	        nJointProb = aJointFreq[i][2] / nTotal
	        
	        # Extract individual values from pair
	        aPair = split(aJointFreq[i][1], "_")
	        cVal1 = aPair[1]
	        cVal2 = aPair[2]
	        
	        nMarg1 = This._GetFreqValue(aFreq1, cVal1) / nTotal
	        nMarg2 = This._GetFreqValue(aFreq2, cVal2) / nTotal
	        
	        if nJointProb > 0 and nMarg1 > 0 and nMarg2 > 0
	            nMI += nJointProb * log(nJointProb / (nMarg1 * nMarg2)) / log(2)
	        ok
	    next
	    
	    return nMI
	
		def MutualInfo(oOtherDataSet)
			return This.MutualInformation(oOtherDataSet)


	# Helper methods for new functionality
	
	def _HashList(aList)
	    cHash = ""
	    nLen = len(aList)
	    for i = 1 to nLen
	        cHash += "" + aList[i] + "_"
	    next
	    return cHash
	
	def _FindInFreqList(aFreqList, cValue)
	    nLen = len(aFreqList)
	    for i = 1 to nLen
	        if aFreqList[i][1] = cValue
	            return i
	        ok
	    next
	    return 0
	
	def _GetFreqValue(aFreqTable, cValue)
	    nLen = len(aFreqTable)
	    for i = 1 to nLen
	        if aFreqTable[i][1] = cValue
	            return aFreqTable[i][2]
	        ok
	    next
	    return 0
	

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
 
		def Standardise()
			return This.Standardize()


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


		def RScale()
			return This.RobustScale()

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

	def _GenerateInsightXT(cType) # numeric, categorical, mixed, empty

		aTemplates = DataSetTemplatesXT(cType)
		nLen = len(aTemplates)

		acInsights = []

		for i = 1 to nLen
	        if This._EvaluateCondition(aTemplates[:condition])
	            acInsights + This._Interpolate(aTemplates[:template])
	        ok
	    next

	    return acInsights



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

		nLen = len($aDomainInsightRules)

		for i = 1 to nLen

			cDomain = $aDomainInsightRules[i][1]
			aDomain = $aDomainInsightRules[i][2]
			nLenDomain = len(aDomain)

			for j = 1 to nLenDomain
				if This._EvaluateCondition(aDomain[j][1])
					acResults + (Capitalize(Adverb(cDomain)) + ", " + This._EvaluateRule(aDomain[j][2]) )

					#WARNING #TODO // Adverb() funtion belong to MAX layer, so we don't have the right to
					# call it here in BASIC layer ~~> Move STATS module to the MAX layer!

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

	    if HasKey($aDomainInsightRules, cDomain)

			nLen = len($aDomainInsightRules[cDomain])

			for i = 1 to nLen
	            if This._EvaluateCondition($aDomainInsightRules[cDomain][i][1])
	                acResults + _EvaluateRule($aDomainInsightRules[cDomain][i][2])
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
	    if NOT HasKey($aDomainInsightRules, cDomain)
	        $aDomainInsightRules[cDomain] = []
	    ok
	    $aDomainInsightRules[cDomain] + [cCondition, cInsight]

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
	    if NOT HasKey($aDomainInsightRules, cDomain)
	        $aDomainInsightRules[cDomain] = []
	    ok

	    # Don't interpolate here - do it when evaluating
	    $aDomainInsightRules[cDomain] + [cCondition, cInsight, nWeight]
	
	def PrioritizedInsights(cDomain)
	    aResults = []
	
	    if HasKey($aDomainInsightRules, cDomain)
	        aRules = $aDomainInsightRules[cDomain]
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

		if NOT isString(cKey)
			StzRaise("Incorrect param type! cKey must be a non empty string.")
		ok

		if @trim(cKey) = ""
			return
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

	def SummaryXT() # Adding recommendations

		cResult = This.Summary() + NL +
				  BoxifyRound("Recommendations") + NL

		acRecommendations = This.Recommendations()
		nLen = len(acRecommendations)

		for i = 1 to nLen
			cResult += "• " + acRecommendations[i] + NL
		next

		return cResult


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
		return $aDomainInsightRules



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
