#====================================================================#
#  SOFTANZA STATISTICS LAYER - Enhanced Analytics Framework          #
#  Four Pillars: Comparison | Composition | Distribution | Relation  #
#====================================================================#

# Global configuration for missing values
$aSTAT_MISSING_VALUES = [ "", "NA", "NULL", "n/a", "#N/A" ]
$nSTAT_PRECISION = 4  # Decimal places for numeric outputs

func MissingValues()
    return $aSTAT_MISSING_VALUES

func StatPrecision()
    return $nSTAT_PRECISION

class stzStats

    @anData = []
    @cDataType = "numeric"  # numeric, categorical, mixed, empty
    @bSorted = FALSE
    @anSortedData = []
    @aCache = []  # Standard Ring hash list as [ [:key, value], ... ]
    @aInsightRules = []  # Custom insight rules
    @nMinSampleSize = 3  # Minimum for advanced statistics

    def init(paData)
        if CheckParams()
            if NOT isList(paData)
                StzRaise("stzStats requires a list of data")
            ok
        ok

        @anData = This._CleanData(paData)
        This._DetectDataType()
        This._InitializeCache()

    def _CleanData(paData)
        # Remove missing values and prepare data
        aCleanData = []
        
        for item in paData
            if NOT This._IsMissing(item)
                aCleanData + item
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
        
        for item in @anData
            if IsNumber(item)
                nNumeric++
            else
                nCategorical++
            ok
        next

        if nNumeric = len(@anData)
            @cDataType = "numeric"
        but nCategorical = len(@anData)
            @cDataType = "categorical"
        else
            @cDataType = "mixed"
        ok

    def _InitializeCache()
        @aCache = []

    def _GetCached(cKey)
        for pair in @aCache
            if pair[1] = cKey
                return pair[2]
            ok
        next
        return NULL

    def _SetCache(cKey, value)
        # Remove existing key if present to avoid duplicates
        for i = 1 to len(@aCache)
            if @aCache[i][1] = cKey
                del(@aCache, i)
                exit
            ok
        next
        @aCache + [cKey, value]

    def _SortIfNeeded()
        if @cDataType = "numeric" and NOT @bSorted
            @anSortedData = sort(@anData)
            @bSorted = TRUE
        ok

    def _Round(nValue)
        nMultiplier = pow(10, $nSTAT_PRECISION)
        return floor(nValue * nMultiplier + 0.5) / nMultiplier

    #===================================================================#
    #  PILLAR 1: COMPARISON - Descriptive Statistics                   #
    #===================================================================#

    def Mean()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        
        cKey = "mean"
        nCached = This._GetCached(cKey)
        if nCached != NULL
            return nCached
        ok
        
        nSum = 0.0
        nLen = len(@anData)
        
        for i = 1 to nLen
            nSum += @anData[i]
        next
        
        nMean = This._Round(nSum / nLen)
        This._SetCache(cKey, nMean)
        return nMean

    def Median()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        
        cKey = "median"
        nCached = This._GetCached(cKey)
        if nCached != NULL
            return nCached
        ok
        
        This._SortIfNeeded()
        nLen = len(@anSortedData)
        
        nMedian = 0
        if nLen % 2 = 1
            nMedian = @anSortedData[ceil(nLen/2.0)]
        else
            nMid1 = @anSortedData[nLen/2] 
            nMid2 = @anSortedData[nLen/2 + 1]
            nMedian = (nMid1 + nMid2) / 2.0
        ok
        
        nMedian = This._Round(nMedian)
        This._SetCache(cKey, nMedian)
        return nMedian

    def Mode()
        if len(@anData) = 0
            return NULL
        ok

        cKey = "mode"
        cached = This._GetCached(cKey)
        if cached != NULL
            return cached
        ok

        oFreq = new stzHashList([])

        for item in @anData
            cItemKey = "" + item
            if oFreq.ContainsKey(cItemKey)
                oFreq.@aContent[cItemKey]++
            else
                oFreq.AddPair([cItemKey, 1])
            ok
        next

        nMaxFreq = 0
        cModeKey = ""
        
        for pair in oFreq.HashList()
            if pair[2] > nMaxFreq
                nMaxFreq = pair[2]
                cModeKey = pair[1]
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
        if nCached != NULL
            return nCached
        ok
        
        nMean = This.Mean()
        nSumSquares = 0.0
        nLen = len(@anData)
        
        for i = 1 to nLen
            nDiff = @anData[i] - nMean
            nSumSquares += (nDiff * nDiff)
        next
        
        nVariance = nSumSquares / (nLen - 1)
        nStdDev = This._Round(sqrt(nVariance))
        This._SetCache(cKey, nStdDev)
        return nStdDev

    def Variance()
        nStdDev = This.StandardDeviation()
        return This._Round(nStdDev * nStdDev)

    def Range()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        return This._Round(This.Max() - This.Min())

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
        
        nSum = 0.0
        for item in @anData
            nSum += item
        next
        
        return This._Round(nSum)

    def Count()
        return len(@anData)

    def GeometricMean()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        
        # Check for non-positive values
        for item in @anData
            if item <= 0
                return 0  # Geometric mean undefined for non-positive values
            ok
        next
        
        nProduct = 1.0
        nLen = len(@anData)
        
        for item in @anData
            nProduct *= item
        next
        
        return This._Round(pow(nProduct, 1.0/nLen))

    def HarmonicMean()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        
        nSum = 0.0
        nLen = len(@anData)
        
        for item in @anData
            if item = 0
                return 0  # Harmonic mean undefined for zero values
            ok
            nSum += (1.0 / item)
        next
        
        return This._Round(nLen / nSum)

    def CoefficientOfVariation()
        if @cDataType != "numeric" or This.Mean() = 0
            return 0
        ok
        
        return This._Round((This.StandardDeviation() / abs(This.Mean())) * 100)

    #============================================================#
    #  PILLAR 2: COMPOSITION - Frequency & Categorical Analysis  #
    #============================================================#

    def FrequencyTable()
        cKey = "freq_table"
        cached = This._GetCached(cKey)
        if cached != NULL
            return cached
        ok

        oFreq = new stzHashList([])
        
        for item in @anData
            cItemKey = "" + item
            if oFreq.ContainsKey(cItemKey)
                oFreq.@aContent[cItemKey]++
            else
                oFreq.AddPair([cItemKey, 1])
            ok
        next

        aResult = oFreq.HashList()
        This._SetCache(cKey, aResult)
        return aResult

    def RelativeFrequency()
        aFreqTable = This.FrequencyTable()
        nTotal = This.Count()
        aRelFreq = []
        
        for pair in aFreqTable
            nRelativeFreq = This._Round((pair[2] * 1.0) / nTotal)
            aRelFreq + [pair[1], nRelativeFreq]
        next
        
        return aRelFreq

    def PercentageFrequency()
        aRelFreq = This.RelativeFrequency()
        aPercFreq = []
        
        for pair in aRelFreq
            nPercentage = This._Round(pair[2] * 100.0)
            aPercFreq + [pair[1], nPercentage]
        next
        
        return aPercFreq

    def UniqueCount()
        return len(This.UniqueValues())

    def UniqueValues()
        cKey = "unique_values"
        cached = This._GetCached(cKey)
        if cached != NULL
            return cached
        ok

        aUnique = []
        for item in @anData
            if ring_find(aUnique, item) = 0
                aUnique + item
            ok
        next
        
        This._SetCache(cKey, aUnique)
        return aUnique

    def Diversity()
        # Unique values / Total values
        nTotal = This.Count()
        if nTotal = 0
            return 0
        ok
        return This._Round((This.UniqueCount() * 1.0) / nTotal)

    def EntropyIndex()
        # Shannon entropy for diversity measurement
        if len(@anData) = 0
            return 0
        ok
        
        aFreqTable = This.FrequencyTable()
        nTotal = This.Count()
        nEntropy = 0.0
        
        for pair in aFreqTable
            nProbability = (pair[2] * 1.0) / nTotal
            if nProbability > 0
                nEntropy -= nProbability * log(nProbability) / log(2)
            ok
        next
        
        return This._Round(nEntropy)

    #====================================================#
    #  PILLAR 3: DISTRIBUTION - Shape & Spread Analysis  #
    #====================================================#

    def Percentile(nPercent)
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        
        This._SortIfNeeded()
        nLen = len(@anSortedData)
        nPosition = (nLen * nPercent) / 100.0
        
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
        return This._Round(nLowerVal + (nFraction * (nUpperVal - nLowerVal)))

    def Q1()
        return This.Percentile(25)

    def Q2()
        return This.Median()

    def Q3()
        return This.Percentile(75)

    def IQR()
        return This._Round(This.Q3() - This.Q1())

    def Quartiles()
        return [This.Q1(), This.Q2(), This.Q3()]

    def Skewness()
        if @cDataType != "numeric" or len(@anData) < @nMinSampleSize
            return 0
        ok
        
        cKey = "skewness"
        nCached = This._GetCached(cKey)
        if nCached != NULL
            return nCached
        ok
        
        nMean = This.Mean()
        nStdDev = This.StandardDeviation()
        
        if nStdDev = 0
            return 0
        ok
        
        nLen = len(@anData)
        nSum = 0.0
        
        for i = 1 to nLen
            nStandardized = (@anData[i] - nMean) / nStdDev
            nSum += (nStandardized * nStandardized * nStandardized)
        next
        
        nSkew = This._Round((nSum / nLen) * (nLen / ((nLen - 1) * (nLen - 2))))
        This._SetCache(cKey, nSkew)
        return nSkew

    def Kurtosis()
        if @cDataType != "numeric" or len(@anData) < 4
            return 0
        ok
        
        cKey = "kurtosis"
        nCached = This._GetCached(cKey)
        if nCached != NULL
            return nCached
        ok
        
        nMean = This.Mean()
        nStdDev = This.StandardDeviation()
        
        if nStdDev = 0
            return 0
        ok
        
        nLen = len(@anData)
        nSum = 0.0
        
        for i = 1 to nLen
            nStandardized = (@anData[i] - nMean) / nStdDev
            nSum += (nStandardized * nStandardized * nStandardized * nStandardized)
        next
        
        nKurt = (nSum / nLen) * (nLen * (nLen + 1)) / ((nLen - 1) * (nLen - 2) * (nLen - 3))
        nAdjustment = (3 * (nLen - 1) * (nLen - 1)) / ((nLen - 2) * (nLen - 3))
        
        nResult = This._Round(nKurt - nAdjustment)
        This._SetCache(cKey, nResult)
        return nResult

    def FindOutliers()
        if @cDataType != "numeric"
            return []
        ok
        
        cKey = "outliers"
        cached = This._GetCached(cKey)
        if cached != NULL
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
        aOutliers = This.FindOutliers()
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
        for item in @anData
            nZScore = This._Round((item - nMean) / nStdDev)
            aZScores + nZScore
        next
        
        return aZScores

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
        nSumProduct = 0.0
        nSumSq1 = 0.0
        nSumSq2 = 0.0
        
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
        
        return This._Round(nSumProduct / sqrt(nSumSq1 * nSumSq2))

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
        nSum = 0.0
        
        for i = 1 to nLen
            nSum += (@anData[i] - nMean1) * (aOtherData[i] - nMean2)
        next
        
        return This._Round(nSum / (nLen - 1))

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
        oRank1 = new stzStats(aRanks1)
        oRank2 = new stzStats(aRanks2)
        
        return oRank1.CorrelationWith(oRank2)

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
	    if nCached != NULL
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
	    nChiSquare = 0.0
	    for i = 1 to nRows
	        for j = 1 to nCols
	            nObserved = aContingency[i][j]
	            nExpected = (aRowTotals[i] * aColTotals[j]) / (1.0 * nGrandTotal)
	            if nExpected > 0
	                nChiSquare += ((nObserved - nExpected) * (nObserved - nExpected)) / nExpected
	            ok
	        next
	    next
	    
	    nResult = This._Round(nChiSquare)
	    This._SetCache(cKey, nResult)
	    return nResult

    #=========================================#
    #  DATA TRANSFORMATION & NORMALIZATION    #
    #=========================================#

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
        for item in @anData
            nNormalized = This._Round((item - nMin) / nRange)
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
        for item in @anData
            nStandardized = This._Round((item - nMean) / nStdDev)
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
        for item in @anData
            nScaled = This._Round((item - nMedian) / nIQR)
            aScaled + nScaled
        next
        
        return aScaled

    #=======================================#
    #  ENHANCED INSIGHT GENERATION SYSTEM   #
    #=======================================#

    def Insight()
        return This.GenerateInsight()

    def GenerateInsight()
        switch @cDataType
        on "empty"
            return "Dataset is empty. No analysis possible without data."
        
        on "numeric"
            return This._GenerateNumericInsight()
            
        on "categorical"
            return This._GenerateCategoricalInsight()
            
        on "mixed"
            return This._GenerateMixedInsight()
        off

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
        aOutliers = This.FindOutliers()
        if len(aOutliers) > 0
            nOutlierPercent = This._Round((len(aOutliers) * 100.0) / nCount)
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
            aInsights + ( "Low diversity (" + This._Round(nDiversity * 100) + "%) indicates concentration in few categories" )
        but nDiversity < 0.7
            aInsights + ( "Moderate diversity (" + This._Round(nDiversity * 100) + "%) shows balanced distribution" )
        else
            aInsights + ( "High diversity (" + This._Round(nDiversity * 100) + "%) suggests wide variety" )
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
        for pair in aPercFreq
            if pair[1] = ("" + cMode)
                nModeFreq = pair[2]
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
        return aInsights # Return list directly

    def _FormatInsights(aInsights)
        if len(aInsights) = 0
            return "No specific insights available for this dataset."
        ok
        
        return aInsights  # Return the list directly instead of formatting as bullet points

    #--- Utility methods for the Insight section

    def Insights()
        # Return insights as clean list of sentences
        return This.GenerateInsight()
    
    def JoinInsights(cSeparator)
        if cSeparator = NULL
            cSeparator = " "
        ok

        aInsights = This.Insights()
        cResult = ""

        for i = 1 to len(aInsights)
            if i = 1
                cResult = aInsights[i]
            else
                cResult += cSeparator + aInsights[i]
            ok
        next

        return cResult

    #================================#
    #  EXTENSIBLE INSIGHT FRAMEWORK  #
    #================================#
    
    def AddInsightRule(cDomain, cCondition, cInsight)
        # Add custom insight rule to the framework
        
        @aInsightRules + [cDomain, cCondition, cInsight]

    def AddRule(cDomain, cCondition, cInsight)
        This.AddInsightRule(cDomain, cCondition, cInsight)

    def DomainInsights(cDomain)
        # Apply domain-specific insights
        aResults = []

        for rule in @aInsightRules
            if rule[1] = cDomain
                if This._EvaluateCondition(rule[2])
                   aResults + rule[3]
                ok
            ok
        next
        
        if len(aResults) = 0
            return "No domain-specific insights found for '" + cDomain + "'"
        ok
        
        return This._FormatInsights(aResults)


    def _EvaluateCondition(cCondition)
        
		cCode = 'bResult = ' + cCondition
		eval(cCode)
		return bResult       

    #================================#
    #  ADVANCED STATISTICAL METHODS  #
    #================================#

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
        nAlpha = (100 - nConfidence) / 100.0
        nTValue = 1.96  # Approximation for 95% confidence
        
        if nConfidence = 90
            nTValue = 1.645
        but nConfidence = 99
            nTValue = 2.576
        ok
        
        nMarginError = nTValue * (nStdDev / sqrt(nLen))
        
        return [This._Round(nMean - nMarginError), This._Round(nMean + nMarginError)]

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
            aMovingAvg + This._Round(nSum / nWindow)
        next
        
        return aMovingAvg

    def TrendAnalysis()
        # Simple linear trend analysis
        if @cDataType != "numeric" or len(@anData) < 3
            return "insufficient data"
        ok
        
        nLen = len(@anData)
        nSumX = 0
        nSumY = 0
        nSumXY = 0
        nSumX2 = 0
        
        for i = 1 to nLen
            nSumX += i
            nSumY += @anData[i]
            nSumXY += i * @anData[i]
            nSumX2 += i * i
        next
        
        nSlope = (nLen * nSumXY - nSumX * nSumY) / (nLen * nSumX2 - nSumX * nSumX)
        
        if abs(nSlope) < 0.01
            return "stable"
        but nSlope > 0
            return "increasing"
        else
            return "decreasing"
        ok

    #=========================#
    #  COMPARISON UTILITIES   #
    #=========================#

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
            nMeanDiff = This._Round(((nMean1 - nMean2) / nMean2) * 100)
            
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
        
        return This._FormatInsights(aComparison)

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
            
            return This._Round((nMeanSim + nStdSim) / 2)
        else
            # Categorical similarity based on overlap
            aUnique1 = This.UniqueValues()
            aUnique2 = oOtherStats.UniqueValues()
            
            nIntersection = 0
            for item in aUnique1
                if ring_find(aUnique2, item) > 0
                    nIntersection++
                ok
            next
            
            nUnion = len(aUnique1) + len(aUnique2) - nIntersection
            return This._Round(nIntersection / nUnion)
        ok

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

    def ClearCache()
        @aCache = []
        @bSorted = FALSE
        @anSortedData = []

    def SetPrecision(nPrecision)
        if nPrecision >= 0 and nPrecision <= 10
            $nSTAT_PRECISION = nPrecision
        ok

    def Summary()
        # Comprehensive summary of the dataset
        cSummary = ""
        
        cSummary += "=== Dataset Summary ===" + NL
        cSummary += "Type: " + @cDataType + NL
        cSummary += "Count: " + This.Count() + NL
        
        if @cDataType = "numeric"
            cSummary += "Mean: " + This.Mean() + NL
            cSummary += "Median: " + This.Median() + NL
            cSummary += "Standard Deviation: " + This.StandardDeviation() + NL
            cSummary += "Range: " + This.Range() + " (" + This.Min() + " to " + This.Max() + ")" + NL
            
            aQuartiles = This.Quartiles()
            cSummary += "Quartiles: Q1=" + aQuartiles[1] + ", Q2=" + aQuartiles[2] + ", Q3=" + aQuartiles[3] + NL
            
            aOutliers = This.FindOutliers()
            if len(aOutliers) > 0
                cSummary += "Outliers: " + len(aOutliers) + " detected" + NL
            ok
        else
            cSummary += "Unique Values: " + This.UniqueCount() + NL
            cSummary += "Diversity: " + This._Round(This.Diversity() * 100) + "%" + NL
            cSummary += "Most Common: " + This.Mode() + NL
        ok
        
        cSummary += NL + "=== Insights ===" + NL
        aInsights = This.GenerateInsight()
        for insight in aInsights
            cSummary += "• " + insight + NL
        next
        
        return cSummary

    def Export()
        # Export statistical results as structured data
        oExport = new stzHashList([])
        
        oExport.AddPair(["data_type", @cDataType])
        oExport.AddPair(["count", This.Count()])
        oExport.AddPair(["unique_count", This.UniqueCount()])
        
        if @cDataType = "numeric"
            oExport.AddPair(["mean", This.Mean()])
            oExport.AddPair(["median", This.Median()])
            oExport.AddPair(["mode", This.Mode()])
            oExport.AddPair(["standard_deviation", This.StandardDeviation()])
            oExport.AddPair(["variance", This.Variance()])
            oExport.AddPair(["range", This.Range()])
            oExport.AddPair(["min", This.Min()])
            oExport.AddPair(["max", This.Max()])
            oExport.AddPair(["quartiles", This.Quartiles()])
            oExport.AddPair(["skewness", This.Skewness()])
            oExport.AddPair(["kurtosis", This.Kurtosis()])
            oExport.AddPair(["outliers", This.FindOutliers()])
        else
            oExport.AddPair(["mode", This.Mode()])
            oExport.AddPair(["diversity", This.Diversity()])
            oExport.AddPair(["entropy", This.EntropyIndex()])
            oExport.AddPair(["frequency_table", This.FrequencyTable()])
        ok
        
        return oExport.Content()

    #=============================#
    #  QUALITY ASSURANCE METHODS  #
    #=============================#

    def ValidateData()
        # Validate data integrity and quality
        aIssues = []
        
        if len(@anData) = 0
            aIssues + "Dataset is empty"
            return aIssues
        ok
        
        if @cDataType = "numeric"
            # Check for infinite or NaN values
            for item in @anData
                if isNull(item)
                    aIssues + "Contains null values"
                    exit
                ok
            next
            
            # Check for extreme outliers
            aOutliers = This.FindOutliers()
            if len(aOutliers) > (This.Count() * 0.2)
                aIssues + "High proportion of outliers detected"
            ok
            
            # Check for variance
            if This.StandardDeviation() = 0
                aIssues + "No variance in data (all values identical)"
            ok
        ok
        
        if len(aIssues) = 0
            aIssues + "Data quality appears good"
        ok
        
        return aIssues

    def RecommendAnalysis()
        # Suggest appropriate analysis methods based on data characteristics
        aRecommendations = []
        
        nCount = This.Count()
        
        if nCount < 10
            aRecommendations + "Small sample size - interpret results cautiously"
        ok
        
        if @cDataType = "numeric"
            nSkew = This.Skewness()
            if abs(nSkew) > 1
                aRecommendations + "Data is skewed - consider using median instead of mean"
            ok
            
            aOutliers = This.FindOutliers()
            if len(aOutliers) > 0
                aRecommendations + "Outliers detected - consider robust statistics"
            ok
            
            if This.CoefficientOfVariation() > 50
                aRecommendations + "High variability - segment analysis recommended"
            ok
        else
            if This.Diversity() < 0.3
                aRecommendations + "Low diversity - focus on dominant categories"
            ok
            
            if This.UniqueCount() = This.Count()
                aRecommendations + "All values unique - consider grouping or classification"
            ok
        ok
        
        if len(aRecommendations) = 0
            aRecommendations + "Standard statistical analysis appropriate"
        ok
        
        return aRecommendations

    #==========================#
    #  PRIVATE HELPER METHODS  #
    #==========================#

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

    def _JoinInsights(aInsights)
        if len(aInsights) = 0
            return "No insights available."
        ok
        
        if len(aInsights) = 1
            return aInsights[1] + "."
        ok
        
        cResult = ""
        for i = 1 to len(aInsights)
            if i = 1
                cResult = aInsights[i]
            but i = len(aInsights)
                cResult += ", and " + aInsights[i]
            else
                cResult += ", " + aInsights[i]
            ok
        next
        
        return cResult + "."

    #====================================#
    #  FACTORY FUNCTIONS AND UTILITIES   #
    #====================================#
    
    func CreateStats(paData)
        return new stzStats(paData)
    
    func CompareDatasets(paData1, paData2)
        oStats1 = new stzStats(paData1)
        oStats2 = new stzStats(paData2)
        return oStats1.CompareWith(oStats2)
    
    func QuickSummary(paData)
        oStats = new stzStats(paData)
        return oStats.Summary()
    
    func StatInsight(paData)
        oStats = new stzStats(paData)
        return oStats.GenerateInsight()
