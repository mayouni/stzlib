# =============================================================================
# stzDataWRangler - Intelligent Data Wrangling Class for Softanza Library
# =============================================================================
# Purpose: Clean, validate, and transform datasets with configurable plans
# Author: Softanza Team
# Philosophy: Simple, practical, and pedagogical data wrangling

# GLOBAL CONFIGURATION
# ===================
# Define global settings for data wrangling operations

$aWRANGLE_MISSING_VALUES = [ "", "NA", "NULL", "n/a", "NaN", "nil", "-", "?" ]
$aWRANGLE_TRUE_VALUES = [ "true", "True", "TRUE", "yes", "Yes", "YES", "1", "y", "Y" ]
$aWRANGLE_FALSE_VALUES = [ "false", "False", "FALSE", "no", "No", "NO", "0", "n", "N" ]

$nWRANGLE_OUTLIER_THRESHOLD = 2.5  # Z-score threshold for outlier detection
$nWRANGLE_MIN_SAMPLE_SIZE = 5      # Minimum sample size for statistical operations

# WRANGLING PLAN TEMPLATES
# ========================
# Pre-defined plans for common data wrangling scenarios

$aWranglingPlanTemplates = [
    :BASIC_CLEANUP = [
        :name = "basic_cleanup",
        :title = "Basic Data Cleanup",
        :description = "Remove duplicates, handle missing values, normalize formats",
        :steps = [
            [ :function = "RemoveDuplicates", :description = "Remove duplicate rows" ],
            [ :function = "HandleMissingValues", :description = "Fill or remove missing values" ],
            [ :function = "TrimWhitespace", :description = "Clean whitespace from text" ],
            [ :function = "NormalizeCase", :description = "Standardize text case" ]
        ]
    ],
    
    :DATA_VALIDATION = [
        :name = "data_validation",
        :title = "Data Quality Validation",
        :description = "Validate data types, formats, and constraints",
        :steps = [
            [ :function = "ValidateDataTypes", :description = "Check data type consistency" ],
            [ :function = "ValidateRanges", :description = "Check numeric ranges" ],
            [ :function = "ValidateFormats", :description = "Validate text formats" ],
            [ :function = "DetectOutliers", :description = "Identify potential outliers" ]
        ]
    ],
    
    :PREPARE_FOR_ANALYSIS = [
        :name = "prepare_analysis",
        :title = "Prepare for Statistical Analysis",
        :description = "Transform data for statistical processing",
        :steps = [
            [ :function = "HandleMissingValues", :description = "Fill missing values" ],
            [ :function = "ConvertDataTypes", :description = "Convert to appropriate types" ],
            [ :function = "NormalizeNumeric", :description = "Normalize numeric columns" ],
            [ :function = "EncodeCategories", :description = "Encode categorical variables" ]
        ]
    ],
    
    :EXPORT_READY = [
        :name = "export_ready",
        :title = "Prepare for Export",
        :description = "Format data for external systems",
        :steps = [
            [ :function = "StandardizeHeaders", :description = "Clean column names" ],
            [ :function = "HandleMissingValues", :description = "Replace with export-friendly values" ],
            [ :function = "FormatDates", :description = "Standardize date formats" ],
            [ :function = "ValidateExport", :description = "Final validation check" ]
        ]
    ]
]

# WRANGLING GOALS TO PLANS MAPPING
# ================================
$aWranglingGoals = [
    :clean = :BASIC_CLEANUP,
    :validate = :DATA_VALIDATION,
    :analyze = :PREPARE_FOR_ANALYSIS,
    :export = :EXPORT_READY
]

# =============================================================================
# stzDataRangler Class Definition
# =============================================================================

class stzDataRangler
    # ATTRIBUTES
    # ==========
    @aData = []              # The dataset (list or 2D list)
    @aHeaders = []           # Column headers (if 2D table)
    @cDataStructure = ""     # "list", "table", "empty"
    @aIssues = []            # Detected data quality issues
    @aTransformLog = []      # Log of applied transformations
    @aValidationRules = []   # Custom validation rules
    @aFillRules = []         # Rules for filling missing values
    @bVerbose = TRUE         # Show detailed operation messages

    # INITIALIZATION
    # ==============
    
    def init(paData, paHeaders)
        """
        Initialize the data rangler with your dataset
        
        Usage:
            oRangler = new stzDataRangler(myData)           # For simple list
            oRangler = new stzDataRangler(myTable, headers) # For 2D table
        """
        @aData = paData
        @aHeaders = paHeaders
        This._DetectDataStructure()
        This._InitializeDefaults()
        This._LogTransformation("Data loaded", "Structure: " + @cDataStructure)

    def _DetectDataStructure()
        """Automatically detect if data is a simple list or 2D table"""
        if len(@aData) = 0
            @cDataStructure = "empty"
            return
        ok
        
        if isList(@aData[1])
            @cDataStructure = "table"
            if len(@aHeaders) = 0 and len(@aData) > 0
                # Generate default headers
				for i = 1 to len(@aData[1])
                	@aHeaders + ("Col" + i)
				next
            ok
        else
            @cDataStructure = "list"
        ok

    def _InitializeDefaults()
        """Set up default rules and configurations"""
        @aIssues = []
        @aTransformLog = []
        @aValidationRules = []
        @aFillRules = [
            [ :type = "numeric", :method = "mean" ],
            [ :type = "categorical", :method = "mode" ],
            [ :type = "date", :method = "interpolate" ]
        ]

    # PILLAR 1: DATA CLEANING
    # ======================
    
    def RemoveDuplicates()
        """
        Remove duplicate rows from the dataset
        Returns: Number of duplicates removed
        """
        nOriginalSize = This._GetRowCount()
        aCleanData = []
        
        if @cDataStructure = "list"
            aCleanData = unique(@aData)
        else
            # For tables, compare entire rows
            for row in @aData
                if This._FindRowIndex(aCleanData, row) = 0
                    aCleanData + row
                ok
            next
        ok
        
        @aData = aCleanData
        nRemoved = nOriginalSize - This._GetRowCount()
        This._LogTransformation("RemoveDuplicates", nRemoved + " duplicates removed")
        return nRemoved

    def HandleMissingValues(cStrategy)
        """
        Handle missing values using specified strategy
        
        Strategies:
            "auto" - Use intelligent defaults based on data type
            "remove" - Remove rows/items with missing values
            "fill_mean" - Fill with mean (numeric) or mode (categorical)
            "fill_zero" - Fill with zero or empty string
            "interpolate" - Linear interpolation for numeric sequences
        """

		if cStrategy = ""
			cStrategy = "auto"
		ok

        nFilled = 0
        
        if @cDataStructure = "list"
            nFilled = This._HandleMissingInList(cStrategy)
        else
            nFilled = This._HandleMissingInTable(cStrategy)
        ok
        
        This._LogTransformation("HandleMissingValues", nFilled + " values processed with strategy: " + cStrategy)
        return nFilled

    def _HandleMissingInList(cStrategy)
        nFilled = 0
        aCleanData = []
        
        for item in @aData
            if This._IsMissing(item)
                if cStrategy = "remove"
                    # Skip missing items
                    loop
                elseif cStrategy = "fill_zero"
                    aCleanData + 0
                    nFilled++
                else
                    # Auto or other strategies
                    fillValue = This._GetFillValue(@aData, cStrategy)
                    aCleanData + fillValue
                    nFilled++
                ok
            else
                aCleanData + item
            ok
        next
        
        @aData = aCleanData
        return nFilled

    def _HandleMissingInTable(cStrategy)
        nFilled = 0
        
        for i = 1 to len(@aData)
            for j = 1 to len(@aData[i])
                if This._IsMissing(@aData[i][j])
                    if cStrategy = "remove"
                        # Mark row for removal (handled separately)
                        This._AddIssue("missing_value", "Row " + i + ", Col " + j)
                    else
                        # Get column data for context
						aColumnData = []
						for k = 1 to len(@aData)
                        	aColumnData + @aData[k][j]
						next

                        fillValue = This._GetFillValue(aColumnData, cStrategy)
                        @aData[i][j] = fillValue
                        nFilled++
                    ok
                ok
            next
        next
        
        return nFilled

    def TrimWhitespace()
        """Remove leading and trailing whitespace from text data"""
        nCleaned = 0
        
        if @cDataStructure = "list"
            for i = 1 to len(@aData)
                if isString(@aData[i])
                    original = @aData[i]
                    @aData[i] = trim(@aData[i])
                    if original != @aData[i] nCleaned++ ok
                ok
            next
        else
            for i = 1 to len(@aData)
                for j = 1 to len(@aData[i])
                    if isString(@aData[i][j])
                        original = @aData[i][j]
                        @aData[i][j] = trim(@aData[i][j])
                        if original != @aData[i][j] nCleaned++ ok
                    ok
                next
            next
        ok
        
        This._LogTransformation("TrimWhitespace", nCleaned + " values cleaned")
        return nCleaned

    def NormalizeCase(cMode)
        """
        Normalize text case
        Modes: "lower", "upper", "title", "sentence"
        """

		if @trim(cMode) = ""
			cMode = "lower"
		ok

        nNormalized = 0
        
        if @cDataStructure = "list"
            for i = 1 to len(@aData)
                if isString(@aData[i])
                    @aData[i] = This._ApplyCaseNormalization(@aData[i], cMode)
                    nNormalized++
                ok
            next
        else
            for i = 1 to len(@aData)
                for j = 1 to len(@aData[i])
                    if isString(@aData[i][j])
                        @aData[i][j] = This._ApplyCaseNormalization(@aData[i][j], cMode)
                        nNormalized++
                    ok
                next
            next
        ok
        
        This._LogTransformation("NormalizeCase", nNormalized + " values normalized to " + cMode)
        return nNormalized

    # PILLAR 2: DATA VALIDATION
    # =========================
    
    def ValidateDataTypes()
        """
        Validate data type consistency within columns
        Returns: List of validation issues found
        """
        aIssues = []
        
        if @cDataStructure = "table"
            for j = 1 to len(@aHeaders)
                aColumnTypes = []
                for i = 1 to len(@aData)
                    if NOT This._IsMissing(@aData[i][j])
                        cType = This._GetDataType(@aData[i][j])
                        if ring_find(aColumnTypes, cType) = 0
                            aColumnTypes + cType
                        ok
                    ok
                next
                
                if len(aColumnTypes) > 1
                    cIssue = "Column " + @aHeaders[j] + " has mixed types: " + This._JoinList(aColumnTypes, ", ")
                    aIssues + cIssue
                    This._AddIssue("mixed_types", cIssue)
                ok
            next
        ok
        
        This._LogTransformation("ValidateDataTypes", len(aIssues) + " type issues found")
        return aIssues

    def ValidateRanges(aRangeRules)
        """
        Validate numeric values against specified ranges
        
        Range rules format:
        [ ["column_name", min_value, max_value], ... ]
        """
        aIssues = []
        
        if @cDataStructure = "table"
            for rule in aRangeRules
                cColumn = rule[1]
                nMin = rule[2]
                nMax = rule[3]
                nColIndex = ring_find(@aHeaders, cColumn)
                
                if nColIndex > 0
                    for i = 1 to len(@aData)
                        value = @aData[i][nColIndex]
                        if isNumber(value) and (value < nMin or value > nMax)
                            cIssue = "Row " + i + ", " + cColumn + ": " + value + " outside range [" + nMin + ", " + nMax + "]"
                            aIssues + cIssue
                            This._AddIssue("range_violation", cIssue)
                        ok
                    next
                ok
            next
        ok
        
        This._LogTransformation("ValidateRanges", len(aIssues) + " range violations found")
        return aIssues

    def DetectOutliers(nThreshold)
        """
        Detect statistical outliers using Z-score method
        Returns: List of outlier positions
        """

		if IsNull(nThreshold) or nThreshold = 0
			nThreshold = $nWRANGLE_OUTLIER_THRESHOLD
		ok

        aOutliers = []
        
        if @cDataStructure = "table"
            for j = 1 to len(@aHeaders)
                aColumnData = This._GetNumericColumnData(j)
                if len(aColumnData) >= $nWRANGLE_MIN_SAMPLE_SIZE
                    nMean = This._CalculateMean(aColumnData)
                    nStdDev = This._CalculateStdDev(aColumnData)
                    
                    if nStdDev > 0
                        for i = 1 to len(@aData)
                            value = @aData[i][j]
                            if isNumber(value)
                                nZScore = abs((value - nMean) / nStdDev)
                                if nZScore > nThreshold
                                    aOutliers + [i, j, value, nZScore]
                                    This._AddIssue("outlier", "Row " + i + ", " + @aHeaders[j] + ": " + value + " (Z-score: " + nZScore + ")")
                                ok
                            ok
                        next
                    ok
                ok
            next
        ok
        
        This._LogTransformation("DetectOutliers", len(aOutliers) + " outliers detected")
        return aOutliers

    # PILLAR 3: DATA TRANSFORMATION
    # =============================
    
    def ConvertDataTypes(aConversionRules)
        """
        Convert data types based on rules or auto-detection
        
        Conversion rules format:
        [ ["column_name", "target_type"], ... ]
        Target types: "numeric", "string", "boolean", "date"
        """
        nConverted = 0
        
        if @cDataStructure = "table"
            for rule in aConversionRules
                cColumn = rule[1]
                cTargetType = rule[2]
                nColIndex = ring_find(@aHeaders, cColumn)
                
                if nColIndex > 0
                    for i = 1 to len(@aData)
                        if NOT This._IsMissing(@aData[i][nColIndex])
                            convertedValue = This._ConvertValue(@aData[i][nColIndex], cTargetType)
                            if convertedValue != NULL
                                @aData[i][nColIndex] = convertedValue
                                nConverted++
                            ok
                        ok
                    next
                ok
            next
        ok
        
        This._LogTransformation("ConvertDataTypes", nConverted + " values converted")
        return nConverted

    def NormalizeNumeric(cMethod)
        """
        Normalize numeric columns
        Methods: "minmax" (0-1), "zscore" (mean=0, std=1), "robust" (median-based)
        """

		if IsNull(cMethod)
			cMethod = "minmax"
		ok

        nNormalized = 0
        
        if @cDataStructure = "table"
            for j = 1 to len(@aHeaders)
                aColumnData = This._GetNumericColumnData(j)
                if len(aColumnData) > 0
                    aNormalizedData = This._NormalizeArray(aColumnData, cMethod)
                    nDataIndex = 1
                    
                    # Apply normalized values back to original positions
                    for i = 1 to len(@aData)
                        if isNumber(@aData[i][j]) and NOT This._IsMissing(@aData[i][j])
                            @aData[i][j] = aNormalizedData[nDataIndex]
                            nDataIndex++
                            nNormalized++
                        ok
                    next
                ok
            next
        ok
        
        This._LogTransformation("NormalizeNumeric", nNormalized + " values normalized using " + cMethod)
        return nNormalized

    def EncodeCategories(cMethod)
        """
        Encode categorical variables for analysis
        Methods: "label" (0,1,2...), "onehot" (binary columns), "ordinal" (custom order)
        """

		if IsNull(cMethod)
			cMethod = "label"
		ok

        nEncoded = 0
        
        if @cDataStructure = "table"
            for j = 1 to len(@aHeaders)
                if This._IsColumnCategorical(j)
                    aUniqueValues = This._GetUniqueColumnValues(j)
                    if cMethod = "label"
                        nEncoded += This._ApplyLabelEncoding(j, aUniqueValues)
                    ok
                ok
            next
        ok
        
        This._LogTransformation("EncodeCategories", nEncoded + " categorical values encoded")
        return nEncoded

    # PILLAR 4: PLAN EXECUTION SYSTEM
    # ===============================
    
    def GeneratePlan(cGoalOrTemplate)
        """
        Generate a wrangling plan based on goal or template name
        
        Goals: "clean", "validate", "analyze", "export"
        Templates: "basic_cleanup", "data_validation", etc.
        """
        cTemplate = This._ResolvePlanTemplate(cGoalOrTemplate)
        if cTemplate = NULL
            This._LogTransformation("GeneratePlan", "Unknown goal/template: " + cGoalOrTemplate)
            return NULL
        ok
        
        # Find template definition
        for template in $aWranglingPlanTemplates
            if template[2][:name] = cTemplate
                return [
                    :name = template[2][:name],
                    :title = template[2][:title],
                    :description = template[2][:description],
                    :steps = template[2][:steps],
                    :estimated_time = This._EstimatePlanTime(template[2][:steps])
                ]
            ok
        next
        
        return NULL

    def ExecutePlan(cGoalOrTemplate, bVerbose)
        """
        Execute a complete wrangling plan
        Returns: Execution summary with results and any errors
        """

        @bVerbose = bVerbose
        aPlan = This.GeneratePlan(cGoalOrTemplate)
        if aPlan = NULL return NULL ok
        
        if @bVerbose
            ? "🔧 Executing Plan: " + aPlan[:title]
            ? "📝 " + aPlan[:description]
            ? "⏱️  Estimated time: " + aPlan[:estimated_time] + " seconds"
            ? ""
        ok
        
        aResults = []
        nStartTime = clock()
        
        for stepp in aPlan[:steps]
            if @bVerbose
                ? "▶️  " + stepp[:description] + "..."
            ok
            
            try
                result = This._ExecutePlanStep(stepp)
                aResults + [
                    :function = stepp[:function],
                    :description = stepp[:description],
                    :result = result,
                    :status = "success"
                ]
                
                if @bVerbose
                    ? "   ✅ " + result
                ok
                
            catch
                aResults + [
                    :function = stepp[:function],
                    :description = stepp[:description],
                    :error = cCatchError,
                    :status = "error"
                ]
                
                if @bVerbose
                    ? "   ❌ Error: " + cCatchError
                ok
            done
        next
        
        nEndTime = clock()
        nActualTime = (nEndTime - nStartTime)
        
        if @bVerbose
            ? ""
            ? "🎉 Plan execution completed in " + nActualTime + " seconds"
            ? "📊 " + This._GetExecutionSummary(aResults)
        ok
        
        return [
            :plan = aPlan,
            :results = aResults,
            :execution_time = nActualTime,
            :summary = This._GetExecutionSummary(aResults)
        ]

    # PILLAR 5: EXPORT AND INTEGRATION
    # ================================
    
    def ExportForStzDataSet()
        """
        Export cleaned data in format suitable for stzDataSet
        Returns: Clean list or 2D array ready for statistical analysis
        """
        if @cDataStructure = "list"
            return @aData
        else
            # For tables, might want to return specific columns or flattened data
            return @aData
        ok

    def ExportForStzTable()
        """
        Export as structured table data for stzTable class
        Returns: [headers, data] format
        """
        if @cDataStructure = "table"
            return [ @aHeaders, @aData ]
        else
			aItems = []
			for i = 1 to len(@aData)
				aItems + @aData[i]
			next
            return [ ["Value"], [ aItems ] ]
        ok

    def ExportForStzMatrix()
        """
        Export numeric data suitable for stzMatrix operations
        Returns: 2D numeric array
        """
        if @cDataStructure = "table"
            # Extract only numeric columns
            aNumericData = []
            for row in @aData
                aNumericRow = []
                for item in row
                    if isNumber(item)
                        aNumericRow + item
                    else
                        aNumericRow + 0  # Default for non-numeric
                    ok
                next
                aNumericData + aNumericRow
            next
            return aNumericData
        else
            # Convert list to single column matrix
			aItems = []
			for i = 1 to len(@aData)
				if isNumber(@aData[i])
					aItems + @aData[i]
				ok
			next
            return [ aItems ]
        ok

    # REPORTING AND DIAGNOSTICS
    # =========================
    
    def GetDataProfile()
        """Generate comprehensive data profile report"""
        aProfile = [
            :structure = @cDataStructure,
            :rows = This._GetRowCount(),
            :columns = len(@aHeaders),
            :issues_found = len(@aIssues),
            :transformations_applied = len(@aTransformLog),
            :data_types = This._GetDataTypesSummary(),
            :missing_values = This._CountMissingValues(),
            :duplicates = This._CountDuplicates()
        ]
        
        return aProfile

    def GetTransformationLog()
        """Return complete log of all transformations applied"""
        return @aTransformLog

    def GetIssues()
        """Return all detected data quality issues"""
        return @aIssues

    def ShowReport()
        """Display formatted data quality report"""
        aProfile = This.GetDataProfile()
        
        ? "📋 DATA WRANGLING REPORT"
        ? "========================"
        ? "Structure: " + aProfile[:structure]
        ? "Dimensions: " + aProfile[:rows] + " rows × " + aProfile[:columns] + " columns"
        ? "Issues Found: " + aProfile[:issues_found]
        ? "Transformations: " + aProfile[:transformations_applied]
        ? ""
        
        if len(@aIssues) > 0
            ? "🚨 ISSUES DETECTED:"
            for issue in @aIssues
                ? "  • " + issue[:type] + ": " + issue[:description]
            next
            ? ""
        ok
        
        if len(@aTransformLog) > 0
            ? "🔄 TRANSFORMATIONS APPLIED:"
            for transform in @aTransformLog
                ? "  • " + transform[:operation] + ": " + transform[:details]
            next
        ok

    # HELPER METHODS
    # ==============
    
    def _IsMissing(value)
        return isNull(value) or ring_find($aWRANGLE_MISSING_VALUES, "" + value) > 0

    def _GetFillValue(aData, cStrategy)
        # Determine best fill value based on data and strategy
        if cStrategy = "fill_zero" return 0 ok
        if cStrategy = "fill_mean" return This._CalculateMean(This._GetNumericValues(aData)) ok
        
        # Auto strategy - intelligent selection
        aNumericValues = This._GetNumericValues(aData)
        if len(aNumericValues) > 0
            return This._CalculateMean(aNumericValues)  # Use mean for numeric
        else
            return This._GetMostFrequent(aData)  # Use mode for categorical
        ok


    def _GetNumericValues(aData)
		nLen = len(aData)
		anResult = []
		for i = 1 to nLen
			if isNumber(aData[i]) and NOT This._IsMissing(aData[i])
				anResult + aData[i]
			ok
		next

        return anResult

    def _CalculateMean(aNumbers)
        if len(aNumbers) = 0 return 0 ok
        return sum(aNumbers) / len(aNumbers)

    def _CalculateStdDev(aNumbers)
        if len(aNumbers) < 2 return 0 ok
        nMean = This._CalculateMean(aNumbers)

		nSum = 0
		nLen = len(aNumbers)
		for i = 1 to nLen
			x = aNumbers[i]
			nSum += (x - nMean) * (x - nMean)
		next
		nVariance = nSum / (nLen - 1)

        return sqrt(nVariance)

    def _GetMostFrequent(aData)
        # Find mode (most frequent value)
        aFreq = []
        for item in aData
            if NOT This._IsMissing(item)
                nIndex = This._FindInFreqArray(aFreq, item)
                if nIndex = 0
                    aFreq + [item, 1]
                else
                    aFreq[nIndex][2]++
                ok
            ok
        next
        
        if len(aFreq) = 0 return "" ok
        
        # Find item with highest frequency
        nMaxFreq = 0
        mostFrequent = aFreq[1][1]
        for freq in aFreq
            if freq[2] > nMaxFreq
                nMaxFreq = freq[2]
                mostFrequent = freq[1]
            ok
        next
        
        return mostFrequent

    def _ApplyCaseNormalization(cText, cMode)
        switch cMode
        on "lower"   return lower(cText)
        on "upper"   return upper(cText)
        on "title"   return This._ToTitleCase(cText)
        on "sentence" return This._ToSentenceCase(cText)
        other        return cText
        off

    def _ToTitleCase(cText)
        # Simple title case implementation
        aWords = split(cText, " ")
        for i = 1 to len(aWords)
            if len(aWords[i]) > 0
                aWords[i] = upper(left(aWords[i], 1)) + lower(substr(aWords[i], 2))
            ok
        next
        return This._JoinList(aWords, " ")

    def _ToSentenceCase(cText)
        if len(cText) > 0
            return upper(left(cText, 1)) + lower(substr(cText, 2))
        ok
        return cText

    def _GetDataType(value)
        if isNumber(value) return "numeric" ok
        if isString(value) 
            if This._IsBoolean(value) return "boolean" ok
            if This._IsDate(value) return "date" ok
            return "string"
        ok
        return "unknown"

    def _IsBoolean(cValue)
        return ring_find($aWRANGLE_TRUE_VALUES + $aWRANGLE_FALSE_VALUES, lower(trim("" + cValue))) > 0

    def _IsDate(cValue)
        # Simple date detection - could be enhanced
        cValue = "" + cValue
        return (find(cValue, "/") > 0 or find(cValue, "-") > 0) and len(cValue) >= 8

    def _ConvertValue(value, cTargetType)
        switch cTargetType
        on "numeric"
            if isNumber(value) return value ok
            if isString(value)
                try
                    return 0 + value  # Ring's implicit conversion
                catch
                    return NULL
                done
            ok
            
        on "string"
            return "" + value
            
        on "boolean"
            if This._IsBoolean(value)
                return ring_find($aWRANGLE_TRUE_VALUES, lower(trim("" + value))) > 0
            ok
            
        on "date"
            # Date conversion would need more sophisticated logic
            return value
        off
        
        return NULL

    def _LogTransformation(cOperation, cDetails)
        @aTransformLog + [
            :timestamp = date() + " " + time(),
            :operation = cOperation,
            :details = cDetails
        ]

    def _AddIssue(cType, cDescription)
        @aIssues + [
            :type = cType,
            :description = cDescription,
            :detected_at = date() + " " + time()
        ]

    def _GetRowCount()
        if @cDataStructure = "list"
            return len(@aData)
        else
            return len(@aData)
        ok

    def _ResolvePlanTemplate(cInput)
        cInput = lower(trim(cInput))
        
        # Check if it's a direct template name
        for template in $aWranglingPlanTemplates
            if template[2][:name] = cInput
                return cInput
            ok
next
        
        # Check if it's a goal that maps to a template
        for goal in $aWranglingGoals
            if goal[1] = cInput
                return goal[2]
            ok
        next
        
        return NULL

    def _EstimatePlanTime(aSteps)
        # Simple time estimation based on number of steps
        nBaseTime = len(aSteps) * 0.5  # 0.5 seconds per step
        nDataSizeFactor = This._GetRowCount() / 1000.0  # Additional time for larger datasets
        return nBaseTime + nDataSizeFactor

    def _ExecutePlanStep(aStep)
        cFunction = aStep[:function]
        
        switch cFunction
        on "RemoveDuplicates"
            nRemoved = This.RemoveDuplicates()
            return "Removed " + nRemoved + " duplicate rows"
            
        on "HandleMissingValues"
            nFilled = This.HandleMissingValues()
            return "Processed " + nFilled + " missing values"
            
        on "TrimWhitespace"
            nCleaned = This.TrimWhitespace()
            return "Cleaned " + nCleaned + " text values"
            
        on "NormalizeCase"
            nNormalized = This.NormalizeCase()
            return "Normalized " + nNormalized + " text values"
            
        on "ValidateDataTypes"
            aIssues = This.ValidateDataTypes()
            return "Found " + len(aIssues) + " type inconsistencies"
            
        on "ValidateRanges"
            aIssues = This.ValidateRanges()
            return "Validated ranges - " + len(aIssues) + " violations found"
            
        on "ValidateFormats"
            return "Format validation completed"
            
        on "DetectOutliers"
            aOutliers = This.DetectOutliers()
            return "Detected " + len(aOutliers) + " potential outliers"
            
        on "ConvertDataTypes"
            nConverted = This.ConvertDataTypes()
            return "Converted " + nConverted + " values"
            
        on "NormalizeNumeric"
            nNormalized = This.NormalizeNumeric()
            return "Normalized " + nNormalized + " numeric values"
            
        on "EncodeCategories"
            nEncoded = This.EncodeCategories()
            return "Encoded " + nEncoded + " categorical values"
            
        on "StandardizeHeaders"
            nStandardized = This._StandardizeHeaders()
            return "Standardized " + nStandardized + " column headers"
            
        on "FormatDates"
            nFormatted = This._FormatDates()
            return "Formatted " + nFormatted + " date values"
            
        on "ValidateExport"
            aIssues = This._ValidateForExport()
            return "Export validation - " + len(aIssues) + " issues found"
            
        other
            return "Unknown function: " + cFunction
        off

    def _GetExecutionSummary(aResults)
        nSuccessful = 0
        nErrors = 0
        
        for result in aResults
            if result[:status] = "success"
                nSuccessful++
            else
                nErrors++
            ok
        next
        
        return nSuccessful + " successful, " + nErrors + " errors"

    def _GetDataTypesSummary()
        if @cDataStructure != "table" return [] ok
        
        aTypeSummary = []
        for j = 1 to len(@aHeaders)
            aTypes = []
            for i = 1 to len(@aData)
                if NOT This._IsMissing(@aData[i][j])
                    cType = This._GetDataType(@aData[i][j])
                    if ring_find(aTypes, cType) = 0
                        aTypes + cType
                    ok
                ok
            next
            aTypeSummary + [@aHeaders[j], aTypes]
        next
        
        return aTypeSummary

    def _CountMissingValues()
        nMissing = 0
        
        if @cDataStructure = "list"
            for item in @aData
                if This._IsMissing(item) nMissing++ ok
            next
        else
            for row in @aData
                for item in row
                    if This._IsMissing(item) nMissing++ ok
                next
            next
        ok
        
        return nMissing

    def _CountDuplicates()
        if @cDataStructure = "list"
            return len(@aData) - len(unique(@aData))
        else
            nOriginal = len(@aData)
            aUnique = []
            for row in @aData
                if This._FindRowIndex(aUnique, row) = 0
                    aUnique + row
                ok
            next
            return nOriginal - len(aUnique)
        ok

    def _FindRowIndex(aRows, aTargetRow)
        for i = 1 to len(aRows)
            if This._RowsEqual(aRows[i], aTargetRow)
                return i
            ok
        next
        return 0

    def _RowsEqual(aRow1, aRow2)
        if len(aRow1) != len(aRow2) return FALSE ok
        for i = 1 to len(aRow1)
            if aRow1[i] != aRow2[i] return FALSE ok
        next
        return TRUE

    def _GetNumericColumnData(nColIndex)
        aNumericData = []
        for i = 1 to len(@aData)
            if isNumber(@aData[i][nColIndex]) and NOT This._IsMissing(@aData[i][nColIndex])
                aNumericData + @aData[i][nColIndex]
            ok
        next
        return aNumericData

    def _NormalizeArray(aData, cMethod)
        switch cMethod
        on "minmax"
			aResult = []
            nMin = min(aData)
            nMax = max(aData)
            if nMax = nMin return aData ok

			nLen = len(aData)
			for i = 1 to nLen
				x = aData[i]
				aResult + ( (x - nMin) / (nMax - nMin) )
			next

            return aResult
            
        on "zscore"
            nMean = This._CalculateMean(aData)
            nStdDev = This._CalculateStdDev(aData)
            if nStdDev = 0 return aData ok

			aResult = []
			nLen = len(aData)
			for i = 1 to nLen
				x = aData[i]
				aResult + ( (x - nMean) / nStdDev )
			next

            return aResult
            
        on "robust"
            # Median-based normalization
            nMedian = This._CalculateMedian(aData) 
            nMAD = This._CalculateMAD(aData, nMedian)  # Median Absolute Deviation
            if nMAD = 0 return aData ok

			aResult = []
			nLen = len(aData)
			for i = 1 to nLen
				x = aData[i]
				aResult + ( (x - nMedian) / nMAD )
			next

            return aResult
            
        other
            return aData
        off

    def _CalculateMedian(aData)
        aSorted = sort(aData)
        nLen = len(aSorted)
        if nLen % 2 = 1
            return aSorted[(nLen + 1) / 2]
        else
            return (aSorted[nLen / 2] + aSorted[nLen / 2 + 1]) / 2
        ok

    def _CalculateMAD(aData, nMedian)
		aDeviations = []
		nLen = len(aData)
		for i = 1 to nLen
			x = aData[i]
			aDeviations + abs(x - nMedian)
		next
        return This._CalculateMedian(aDeviations)

    def _IsColumnCategorical(nColIndex)
        aUniqueValues = This._GetUniqueColumnValues(nColIndex)
        nUniqueCount = len(aUniqueValues)
        nTotalCount = This._GetNonMissingCount(nColIndex)
        
        # Consider categorical if:
        # 1. Less than 20 unique values, OR
        # 2. Unique values are less than 50% of total values, OR
        # 3. Contains non-numeric data
        return (nUniqueCount < 20) or 
               (nUniqueCount < nTotalCount * 0.5) or
               This._ContainsNonNumeric(nColIndex)

    def _GetUniqueColumnValues(nColIndex)
        aUnique = []
        for i = 1 to len(@aData)
            value = @aData[i][nColIndex]
            if NOT This._IsMissing(value) and ring_find(aUnique, value) = 0
                aUnique + value
            ok
        next
        return aUnique

    def _GetNonMissingCount(nColIndex)
        nCount = 0
        for i = 1 to len(@aData)
            if NOT This._IsMissing(@aData[i][nColIndex])
                nCount++
            ok
        next
        return nCount

    def _ContainsNonNumeric(nColIndex)
        for i = 1 to len(@aData)
            value = @aData[i][nColIndex]
            if NOT This._IsMissing(value) and NOT isNumber(value)
                return TRUE
            ok
        next
        return FALSE

    def _ApplyLabelEncoding(nColIndex, aUniqueValues)
        nEncoded = 0
        for i = 1 to len(@aData)
            value = @aData[i][nColIndex]
            if NOT This._IsMissing(value)
                nLabelIndex = ring_find(aUniqueValues, value)
                if nLabelIndex > 0
                    @aData[i][nColIndex] = nLabelIndex - 1  # 0-based encoding
                    nEncoded++
                ok
            ok
        next
        return nEncoded

    def _FindInFreqArray(aFreq, item)
        for i = 1 to len(aFreq)
            if aFreq[i][1] = item
                return i
            ok
        next
        return 0

    def _JoinList(aList, cSeparator)
        if len(aList) = 0 return "" ok
        cResult = "" + aList[1]
        for i = 2 to len(aList)
            cResult += cSeparator + aList[i]
        next
        return cResult

    def _StandardizeHeaders()
        """Standardize column headers for export compatibility"""
        nStandardized = 0
        
        for i = 1 to len(@aHeaders)
            cOriginal = @aHeaders[i]
            cStandardized = This._CleanHeaderName(cOriginal)
            if cOriginal != cStandardized
                @aHeaders[i] = cStandardized
                nStandardized++
            ok
        next
        
        return nStandardized

    def _CleanHeaderName(cHeader)
        # Remove special characters, normalize spacing
        cCleaned = ""
        for i = 1 to len(cHeader)
            cChar = cHeader[i]
            if isalnum(cChar) or cChar = "_"
                cCleaned += cChar
            elseif cChar = " "
                cCleaned += "_"
            ok
        next
        
        # Remove double underscores and trim
        while find(cCleaned, "__") > 0
            cCleaned = substr(cCleaned, "__", "_")
        end
        
        return trim(cCleaned)

    def _FormatDates()
        """Standardize date formats across the dataset"""
        nFormatted = 0
        
        if @cDataStructure = "table"
            for j = 1 to len(@aHeaders)
                for i = 1 to len(@aData)
                    if This._IsDate(@aData[i][j])
                        cFormatted = This._StandardizeDateFormat(@aData[i][j])
                        if cFormatted != @aData[i][j]
                            @aData[i][j] = cFormatted
                            nFormatted++
                        ok
                    ok
                next
            next
        ok
        
        return nFormatted

    def _StandardizeDateFormat(cDate)
        # Simple date standardization - could be enhanced with proper date parsing
        cDate = "" + cDate
        
        # Convert common formats to ISO format (YYYY-MM-DD)
        if find(cDate, "/") > 0
            # Handle MM/DD/YYYY or DD/MM/YYYY formats
            aParts = split(cDate, "/")
            if len(aParts) = 3
                # Assume MM/DD/YYYY for now
                return aParts[3] + "-" + This._PadZero(aParts[1]) + "-" + This._PadZero(aParts[2])
            ok
        ok
        
        return cDate

    def _PadZero(cNumber)
        cNumber = "" + cNumber
        if len(cNumber) = 1
            return "0" + cNumber
        ok
        return cNumber

    def _ValidateForExport()
        """Final validation before export"""
        aIssues = []
        
        # Check for remaining missing values
        nMissing = This._CountMissingValues()
        if nMissing > 0
            aIssues + "Missing values detected: " + nMissing
        ok
        
        # Check for problematic characters in headers
        if @cDataStructure = "table"
            for header in @aHeaders
                if find(header, " ") > 0 or find(header, "-") > 0
                    aIssues + "Header contains spaces/hyphens: " + header
                ok
            next
        ok
        
        return aIssues

    # CONVENIENCE METHODS FOR QUICK OPERATIONS
    # =======================================
    
    def QuickClean()
        """Perform basic cleaning operations quickly"""
        return This.ExecutePlan("clean", FALSE)

    def QuickValidate()
        """Perform validation checks quickly"""  
        return This.ExecutePlan("validate", FALSE)

    def QuickPrepareForAnalysis()
        """Prepare data for statistical analysis quickly"""
        return This.ExecutePlan("analyze", FALSE)

    def QuickPrepareForExport()
        """Prepare data for export quickly"""
        return This.ExecutePlan("export", FALSE)

    # CHAINABLE OPERATIONS
    # ===================
    
    def Clean()
        This.ExecutePlan("clean", FALSE)
        return This

    def Validate()
        This.ExecutePlan("validate", FALSE)
        return This

    def Transform()
        This.ExecutePlan("analyze", FALSE)
        return This

    def Export()
        This.ExecutePlan("export", FALSE)
        return This

    # DATA ACCESS METHODS
    # ==================
    
    def GetData()
        """Return the current dataset"""
        return @aData

    def GetHeaders()
        """Return column headers"""
        return @aHeaders

    def GetCleanData()
        """Return data with basic cleaning applied"""
        oTempRangler = new stzDataRangler(@aData, @aHeaders)
        oTempRangler.QuickClean()
        return oTempRangler.GetData()

    def SetVerbose(bVerbose)
        """Enable/disable verbose output"""
        @bVerbose = bVerbose
        return This

    def Reset()
        """Reset to original data state"""
        This._InitializeDefaults()
        return This
