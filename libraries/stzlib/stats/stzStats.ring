#==============================================================================
#  SOFTANZA STATISTICS LAYER - Core Data Analytics for Visualization
#==============================================================================

#-----------------#
#  CORE STATS     #
#-----------------#

# You must put only string or numbers here
$aSTAT_MISSING_VALUES = [ "" ] # You can add 0 if you want

func MissingValues()
	return $aSTAT_MISSING_VALUES

class stzStats

    @anData = []
    @cDataType = "numeric"  # numeric, categorical, mixed
    @bSorted = FALSE
    @anSortedData = []

    def init(paData)
        
        if CheckParams()
            if NOT isList(paData)
                StzRaise("stzStats requires a list of data")
            ok
        ok

        @anData = paData
        _detectDataType()
        _sortIfNeeded()

    def _detectDataType()
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

    def _sortIfNeeded()
        if @cDataType = "numeric" and NOT @bSorted
            @anSortedData = sort(@anData)
            @bSorted = TRUE
        ok

    #--- DESCRIPTIVE STATISTICS (Foundation for all 4 pillars)

    def Mean()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        
        nSum = 0.0
        nLen = len(@anData)
        
        for i = 1 to nLen
            nSum = nSum + @anData[i]
        next
        
        return nSum / nLen

    def Median()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        
        nLen = len(@anSortedData)
        
        if nLen % 2 = 1
            return @anSortedData[ceil(nLen/2.0)]
        else
            nMid1 = @anSortedData[nLen/2] 
            nMid2 = @anSortedData[nLen/2 + 1]
            return (nMid1 + nMid2) / 2.0
        ok

    def Mode()
        if len(@anData) = 0
            return NULL
        ok

        oFreq = new stzHashList([])
		aFreq = []

        for item in @anData
            cKey = "" + item

            if oFreq.ContainsKey(cKey)
               oFreq.@aContent[cKey] = oFreq.@aContent[cKey] + 1
            else
                oFreq.AddPair([cKey, 1])
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

        if @cDataType = "numeric"
            return 0+ cModeKey
        else
            return cModeKey
        ok

    def StandardDeviation()
        if @cDataType != "numeric" or len(@anData) <= 1
            return 0
        ok
        
        nMean = This.Mean()
        nSumSquares = 0.0
        nLen = len(@anData)
        
        for i = 1 to nLen
            nDiff = @anData[i] - nMean
            nSumSquares = nSumSquares + (nDiff * nDiff)
        next
        
        nVariance = nSumSquares / (nLen - 1)
        return sqrt(nVariance)

    def Variance()
        if @cDataType != "numeric" or len(@anData) <= 1
            return 0
        ok
        
        nStdDev = This.StandardDeviation()
        return nStdDev * nStdDev

    def Range()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        
        return @max(@anData) - @min(@anData)

    def Min()
        return iff(@cDataType = "numeric", @min(@anData), NULL)

    def Max()
        return iff(@cDataType = "numeric", @max(@anData), NULL)

    def Sum()
        if @cDataType != "numeric"
            return 0
        ok
        
        nSum = 0.0
        for item in @anData
            nSum = nSum + item
        next
        
        return nSum

    def Count()
        return len(@anData)

    #--- PERCENTILES & QUARTILES (For Distribution Analysis)

    def Percentile(nPercent)
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        
        nLen = len(@anSortedData)
        nPosition = (nLen * nPercent) / 100.0
        
        if nPosition <= 1
            return @anSortedData[1]
        but nPosition >= nLen
            return @anSortedData[nLen]
        ok
        
        # Linear interpolation for more accurate percentiles
        nLower = floor(nPosition)
        nUpper = nLower + 1
        nFraction = nPosition - nLower
        
        if nUpper > nLen
            return @anSortedData[nLower]
        ok
        
        nLowerVal = @anSortedData[nLower]
        nUpperVal = @anSortedData[nUpper]
        return nLowerVal + (nFraction * (nUpperVal - nLowerVal))

    def Q1()
        return This.Percentile(25)

    def Q2()
        return This.Median()

    def Q3()
        return This.Percentile(75)

    def IQR()
        return This.Q3() - This.Q1()

    def Quartiles()
        return [This.Q1(), This.Q2(), This.Q3()]

    #--- FREQUENCY ANALYSIS (For Categorical & Composition)

    def FrequencyTable()
        oFreq = new stzHashList([])
        
        for item in @anData
            cKey = "" + item
            if oFreq.ContainsKey(cKey)
                oFreq.@aContent[cKey] = oFreq.@aContent[cKey] + 1
            else
                oFreq.AddPair([cKey, 1])
            ok
        next

        return oFreq.HashList()

    def RelativeFrequency()
        aFreqTable = This.FrequencyTable()
        nTotal = This.Count()
        aRelFreq = []
        
        for pair in aFreqTable
            nRelativeFreq = (pair[2] * 1.0) / nTotal
            aRelFreq + [pair[1], nRelativeFreq]
        next
        
        return aRelFreq

    def PercentageFrequency()
        aRelFreq = This.RelativeFrequency()
        aPercFreq = []
        
        for pair in aRelFreq
            nPercentage = pair[2] * 100.0
            aPercFreq + [pair[1], nPercentage]
        next
        
        return aPercFreq

    #--- NORMALIZATION & STANDARDIZATION (For Comparison)

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
            nNormalized = (item - nMin) / nRange
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
            nStandardized = (item - nMean) / nStdDev
            aStandardized + nStandardized
        next
        
        return aStandardized

    #--- OUTLIER DETECTION

    def FindOutliers()
        if @cDataType != "numeric"
            return []
        ok
        
        nQ1 = This.Q1()
        nQ3 = This.Q3()
        nIQR = This.IQR()
        
        nLowerBound = nQ1 - (1.5 * nIQR)
        nUpperBound = nQ3 + (1.5 * nIQR)
        
        aOutliers = []
        for item in @anData
            if item < nLowerBound or item > nUpperBound
                aOutliers + item
            ok
        next
        
        return aOutliers

    def IsOutlier(nValue)
        aOutliers = This.FindOutliers()
        return ring_find(aOutliers, nValue) > 0

    #--- DATA QUALITY METRICS

    def MissingCount()
        # Count NULL (empty string) values (0 is not considered a missing value by default)
		# but you can activate it in $aSTAT_MISSING_VALUES
        nMissing = 0
		nLen = len(@anData)

        for i = 1 to nLen
            if ring_find($aSTAT_MISSING_VALUES, @anData[i]) > 0
                nMissing++
            ok
        next
        return nMissing

    def Completeness()
        nTotal = This.Count()
        if nTotal = 0
            return 0
        ok
        nComplete = nTotal - This.MissingCount()
        return (nComplete * 100.0) / nTotal

	def NonMissingValues()
		return U( StzListQ(@anData).ManyRemoved($aSTAT_MISSING_VALUES) )

    def UniqueCount()
        return len( U( StzListQ(@anData).ManyRemoved($aSTAT_MISSING_VALUES) ) )

    def Diversity()
        # Unique values / Total values
        nTotal = This.Count()
        if nTotal = 0
            return 0
        ok
        return (This.UniqueCount() * 1.0) / nTotal

    #==============================================================================
    #  AUTOMATED INSIGHTS ENGINE - Rule-Based Intelligence
    #==============================================================================

    def Insight()
        return This.GenerateInsight()

    def GenerateInsight()
        switch @cDataType
        on "empty"
            return "Empty dataset provides no actionable information. Data collection is required before meaningful analysis can be performed."
        
        on "numeric"
            return This._NumericInsight()
            
        on "categorical"
            return This._CategoricalInsight()
            
        on "mixed"
            return This._MixedInsight()
        off

    def _NumericInsight()
        # Calculate key metrics
        nMean = This.Mean()
        nMedian = This.Median()
        nStdDev = This.StandardDeviation()
        nRange = This.Range()
        nCount = This.Count()
        aOutliers = This.FindOutliers()
        
        # Build insight components
        aInsights = []
        
        # Distribution symmetry analysis
        nSkewness = abs(nMean - nMedian)
        nMeanMedianRatio = iff(nMedian != 0, nSkewness / abs(nMedian), 0)
        
        if nMeanMedianRatio < 0.05
            aInsights + "The data is symmetrically distributed (mean ≈ median = " + nMean + ")"
        but nMean > nMedian
            aInsights + "The data is right-skewed with mean (" + nMean + ") > median (" + nMedian + ")"
        else
            aInsights + "The data is left-skewed with mean (" + nMean + ") < median (" + nMedian + ")"
        ok
        
        # Variability assessment
        nCV = iff(nMean != 0, (nStdDev / abs(nMean)) * 100, 0)  # Coefficient of variation
        
        if nCV < 15
            aInsights + "showing low variability (CV=" + nCV + "%) indicating consistent values"
        but nCV < 30
            aInsights + "with moderate variability (cv=" + nCV + "%) suggesting normal spread"
        else
            aInsights + "exhibiting high variability (cv=" + nCV + "%) indicating diverse data points"
        ok
        
        # Outlier impact
        if len(aOutliers) > 0
            nOutlierRatio = (len(aOutliers) * 100.0) / nCount
            if nOutlierRatio > 10
                aInsights + "Significant outliers (" + len(aOutliers) + " values, " + nOutlierRatio + "%) heavily influence the mean"
            else
                aInsights + "Contains " + len(aOutliers) + " outlier(s) that may distort analysis"
            ok
            aInsights + "Consider using median for central tendency due to outlier presence"
        ok
        
        # Data size assessment
        if nCount < 10
            aInsights + "Small sample size (n=" + nCount + ") limits statistical reliability"
        but nCount > 100
            aInsights + "Large sample size (n=" + nCount + ") provides robust statistical foundation"
        ok
        
        # Single value case
        if nCount = 1
            return "Single-value dataset offers no variability for meaningful statistical analysis."
        ok
        
        # Join insights with logical connectors
        return This._JoinInsights(aInsights)

    def _CategoricalInsight()
        nCount = This.Count()
        nUnique = This.UniqueCount()
        nDiversity = This.Diversity()
        cMode = This.Mode()
        aFreqTable = This.FrequencyTable()
        aPercFreq = This.PercentageFrequency()
        
        aInsights = []
        
        # Diversity analysis
        if nDiversity < 0.3
            aInsights + "Low diversity (" + (nDiversity*100) + "%) indicates strong concentration in few categories"
        but nDiversity < 0.7
            aInsights + "Moderate diversity (" + (nDiversity*100) + "%) shows balanced category distribution"
        else
            aInsights + "High diversity (" + (nDiversity*100) + "%) suggests wide variety with minimal repetition"
        ok
        
        # Dominance analysis
        nModeFreq = 0
        for pair in aPercFreq
            if pair[1] = ("" + cMode)
                nModeFreq = pair[2]
                exit
            ok
        next
        
        if nModeFreq > 50
            aInsights + "'" + cMode + "' dominates the dataset (" + nModeFreq + "%) indicating strong preference or concentration"
        but nModeFreq > 30
            aInsights + "'" + cMode + "' is the most common (" + nModeFreq + "%) but distribution remains fairly balanced"
        else
            aInsights + "No single category dominates, with '" + cMode + "' being most frequent at " + nModeFreq + "%"
        ok
        
        # Distribution evenness
        if nUnique <= 3
            aInsights + "Limited categories (n=" + nUnique + ") suggest focused classification system"
        but nUnique = nCount
            aInsights + "All values are unique, indicating identifier-like data rather than categories"
        ok
        
        return This._JoinInsights(aInsights)

    def _MixedInsight()
        nCount = This.Count()
        nUnique = This.UniqueCount()
        
        return "Mixed dataset (numeric and categorical) with " + nUnique + " unique values out of " + nCount + " total. " +
               "Numeric analysis is limited due to mixed data types. Consider separating numeric and categorical components for meaningful analysis."


    def _JoinInsights(aInsights)

        if len(aInsights) = 0
            return "No specific insights available for this dataset."
        ok
        
        if len(aInsights) = 1
            return aInsights[1] + "."
        ok
        
        cResult = aInsights[1]
        for i = 2 to len(aInsights)
            if i = len(aInsights)
                cResult = cResult + ", and " + aInsights[i]
            else
                cResult = cResult + ", " + aInsights[i]
            ok
        next
        
		# A hack for better formatting
		#TODO // Solve it radically

		cResult = ring_substr2(cResult, " , ", "")
		cResult = ring_substr2(cResult, ", )", ")")
		cResult = ring_substr2(cResult, "=, ", "= ")
		cResult = ring_substr2(cResult, "= ", "=")
		cResult = ring_substr2(cResult, "=", " = ")
		cResult = ring_substr2(cResult, "  =", " =")
		cResult = ring_substr2(cResult, ", %", "%")
		cResult = ring_substr2(cResult, ", and )", ")")

		oTempStr = new stzString(cResult)
		anPos = oTempStr.FinduppercaseChars()

		nLen = len(anPos)
		for i = 1 to nLen
			anPos[i] -= 2
		next

		oTempStr.ReplaceCharsAt(anPos, ".")
		cResult = oTempStr.Content()

		return cResult
		

    #==============================================================================
    #  EXTENSIBLE INSIGHT FRAMEWORK
    #==============================================================================
    
    def AddInsightRule(cDomain, cCondition, cInsight)
        # Future extension point for domain-specific insights
        # Example: AddInsightRule("Finance", "CV > 0.5", "High volatility suggests risk")
        # This would allow extending insights to finance, marketing, science, etc.
        
        # For now, store in a simple structure
        if NOT @IsVarDefined("@aCustomRules")
            @aCustomRules = []
        ok
        
        @aCustomRules + [cDomain, cCondition, cInsight]

    def ApplyDomainInsights(cDomain)
        # Apply domain-specific insight rules
        # This is the extension mechanism for specialized domains
        
        if NOT @IsVarDefined("@aCustomRules")
            return ""
        ok
        
        for rule in @aCustomRules
            if rule[1] = cDomain
                # Evaluate condition and apply insight
                # Implementation would include condition parser
                # For now, return the insight template
                return rule[3]
            ok
        next
        
        return ""
