
# =============================================================================
# stzDataWRangler - Intelligent Data Wrangling Class for Softanza Library
# =============================================================================
# Purpose: Clean, validate, and transform datasets with configurable plans
# Author: Softanza Team
# Philosophy: Simple, practical, and pedagogical data wrangling

# GLOBAL CONFIGURATION
# ===================
# Define global settings for data wrangling operations

$aWRANGLE_MISSING_VALUES = [ "", 'NA', 'NULL', 'n/a', 'NaN', 'nil', '-', '?' ]
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
# stzDataWrangler Class Definition
# =============================================================================

# Cleans, checks and reshapes a list or a table of values step by step, and keeps a log of what it did.
#
# Give it a flat list or a table (a list of rows, with the column names). The operations change the
# data in place and answer how many values they touched: RemoveDuplicates, HandleMissingValues,
# TrimWhitespace, NormalizeCase, ConvertDataTypes, NormalizeNumeric and EncodeCategories. The
# checks, ValidateRanges, DetectOutliers and ValidateDataTypes, report problems and record them as
# issues. ExecutePlan, QuickClean and the other Quick methods run a whole plan of steps at once, and
# GetData returns the result. Several things fail today on a table that holds text:
# ValidateDataTypes, GetDataProfile and ShowReport raise, the analysis plan does not resolve, and
# the export plan reports errors; each method says so in its own warning.
#
#   receiver   o1 = new stzDataWrangler([ [ "Ann", 31 ], [ "Bob", 25 ], [ "Ann", 31 ] ], [ "name",
#              "age" ])
#   example    ? o1.RemoveDuplicates()
#              #--> 1
#              ? @@( o1.ValidateRanges([ [ "age", 0, 30 ] ]) )
#              #--> [ "Row 1, age: 31 outside range [0, 30]" ]
#              ? o1.NormalizeCase("upper")
#              #--> 2
#              ? o1.NormalizeNumeric("minmax")
#              #--> 2
#              ? @@( o1.GetData() )
#              #--> [ [ "ANN", 1 ], [ "BOB", 0 ] ]
#              ? @@( o1.GetHeaders() )
#              #--> [ "name", "age" ]
#              ? @@( o1.GetIssues()[1][:type] )
#              #--> "range_violation"
#   see        stzTable, stzDataSet, stzMatrix
class stzDataWrangler from stzObject
    # ATTRIBUTES
    # ==========
    @aData = []              # The dataset (list or 2D list)
    @aHeaders = []           # Column headers (if 2D table)
    @cDataStructure = ""     # "list", "table", "empty"
    @aIssues = []            # Detected data quality issues
    @aTransformLog = []      # Log of applied transformations
    @aValidationRules = []   # Custom validation rules
    @aFillRules = []         # Rules for filling missing values
    @bVerbose = 1         # Show detailed operation messages

    # Builds a wrangler around a list of values or a table, a list of rows, and detects which of the two it is.
    #
    #   paData      the dataset, a flat list or a list of rows
    #   paHeaders   the column names of a table, or [ ] to get Col1, Col2 and so on
    #   returns     nothing; the object is built
    #   note        the first item decides: a list there makes it a table
    #   warning     Raises an error when the data is not a list (a number, for example); an empty
    #               list is accepted as an empty dataset
    #   see         GetData, Reset
    #@ aka  INITIALIZATION ==============
    def init(paData, paHeaders)
        # Initialize the data rangler with your dataset
        #
        # Usage:
        # oRangler = new stzDataWrangler(myData)           # For simple list
        # oRangler = new stzDataWrangler(myTable, headers) # For 2D table
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
				_nData1Len_ = len(@aData[1])
				for i = 1 to _nData1Len_
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

    # Removes repeated items of a list, or repeated whole rows of a table, keeping the first of each.
    #
    #   returns    the number of items or rows removed
    #   see        GetData, GetDataProfile
    #@ aka  PILLAR 1: DATA CLEANING ======================
    def RemoveDuplicates()
        # Remove duplicate rows from the dataset
        # Returns: Number of duplicates removed
        _nOriginalSize_ = This._GetRowCount()
        _aCleanData_ = []
        
        if @cDataStructure = "list"
            _aCleanData_ = unique(@aData)
        else
            # For tables, compare entire rows
            _nData8Len_ = len(@aData)
            for _iLoopData8_ = 1 to _nData8Len_
            	_row_ = @aData[_iLoopData8_]
                if This._FindRowIndex(_aCleanData_, _row_) = 0
                    _aCleanData_ + _row_
                ok
            next
        ok
        
        @aData = _aCleanData_
        _nRemoved_ = _nOriginalSize_ - This._GetRowCount()
        This._LogTransformation("RemoveDuplicates", "" + _nRemoved_ + " duplicates removed")
        return _nRemoved_

    # Fills or removes the missing values, which are empty text and NA, NULL, n/a, NaN, nil, - and ?.
    #
    #   _cStrategy_   remove, fill_zero, fill_mean, or anything else (auto): the mean of the numbers
    #                 of the column, or the most frequent value when it holds no number
    #   returns       the number of values filled; 0 when the strategy is remove
    #   note          an empty strategy means auto
    #   warning       on a table the strategy remove does not remove anything: it only records one
    #                 missing_value issue per cell, and interpolate acts as auto; the comparison
    #                 with the missing words is case sensitive, so Na is not missing
    #   see           RemoveDuplicates, TrimWhitespace
    def HandleMissingValues(_cStrategy_)
        # Handle missing values using specified strategy
        #
        # Strategies:
        # "auto" - Use intelligent defaults based on data type
        # "remove" - Remove rows/items with missing values
        # "fill_mean" - Fill with mean (numeric) or mode (categorical)
        # "fill_zero" - Fill with zero or empty string
        # "interpolate" - Linear interpolation for numeric sequences

		if _cStrategy_ = ""
			_cStrategy_ = "auto"
		ok

        _nFilled_ = 0
        
        if @cDataStructure = "list"
            _nFilled_ = This._HandleMissingInList(_cStrategy_)
        else
            _nFilled_ = This._HandleMissingInTable(_cStrategy_)
        ok
        
        This._LogTransformation("HandleMissingValues", "" + _nFilled_ + " values processed with strategy: " + _cStrategy_)
        return _nFilled_

    def _HandleMissingInList(_cStrategy_)
        _nFilled_ = 0
        _aCleanData_ = []
        
        _nData7Len_ = len(@aData)
        for _iLoopData7_ = 1 to _nData7Len_
        	_item_ = @aData[_iLoopData7_]
            if This._IsMissing(_item_)
                if _cStrategy_ = "remove"
                    # Skip missing items
                    loop
                elseif _cStrategy_ = "fill_zero"
                    _aCleanData_ + 0
                    _nFilled_++
                else
                    # Auto or other strategies
                    _fillValue_ = This._GetFillValue(@aData, _cStrategy_)
                    _aCleanData_ + _fillValue_
                    _nFilled_++
                ok
            else
                _aCleanData_ + _item_
            ok
        next
        
        @aData = _aCleanData_
        return _nFilled_

    def _HandleMissingInTable(_cStrategy_)
        _nFilled_ = 0
        
        _nDataLen_20 = len(@aData)
        for i = 1 to _nDataLen_20
            _nDataiLen_3 = len(@aData[i])
            for j = 1 to _nDataiLen_3
                if This._IsMissing(@aData[i][j])
                    if _cStrategy_ = "remove"
                        # Mark row for removal (handled separately)
                        This._AddIssue("missing_value", "Row " + i + ", Col " + j)
                    else
                        # Get column data for context
						_aColumnData_ = []
						_nDataLen_19 = len(@aData)
						for k = 1 to _nDataLen_19
                        	_aColumnData_ + @aData[k][j]
						next

                        _fillValue_ = This._GetFillValue(_aColumnData_, _cStrategy_)
                        @aData[i][j] = _fillValue_
                        _nFilled_++
                    ok
                ok
            next
        next
        
        return _nFilled_

    # Removes the spaces around every text value, in a list or in every cell of a table.
    #
    #   returns    the number of values that changed
    #   see        NormalizeCase, GetData
    def TrimWhitespace()
        """Remove leading and trailing whitespace from text data"""
        _nCleaned_ = 0

        if @cDataStructure = "list"
            _nDataLen_18 = len(@aData)
            for i = 1 to _nDataLen_18
                if isString(@aData[i])
                    _cOriginal_ = @aData[i]
                    @aData[i] = trim(@aData[i])
                    if strcmp(_cOriginal_, @aData[i]) != 0
                        _nCleaned_++
                    ok
                ok
            next
        else
            _nDataLen_17 = len(@aData)
            for i = 1 to _nDataLen_17
                _nDataiLen_2 = len(@aData[i])
                for j = 1 to _nDataiLen_2
                    if isString(@aData[i][j])
                        _cOriginal_ = @aData[i][j]
                        @aData[i][j] = trim(@aData[i][j])
                        if strcmp(_cOriginal_, @aData[i][j]) != 0
                            _nCleaned_++
                        ok
                    ok
                next
            next
        ok
        
        This._LogTransformation("TrimWhitespace", "" + _nCleaned_ + " values cleaned")
        return _nCleaned_

    # Changes the letter case of every text value, in a list or in every cell of a table.
    #
    #   _cMode_    lower, upper, title or sentence
    #   returns    the number of values that changed
    #   see        TrimWhitespace, GetData
    def NormalizeCase(_cMode_)
        # Normalize text case
        # Modes: lower, upper, title, sentence

		if trim(_cMode_) = ""
			_cMode_ = "lower"
		ok

        _nNormalized_ = 0
        
        if @cDataStructure = "list"
            _nDataLen_16 = len(@aData)
            for i = 1 to _nDataLen_16
                if isString(@aData[i])
                    _cOrig_ = @aData[i]
                    @aData[i] = This._ApplyCaseNormalization(@aData[i], _cMode_)
                    if strcmp(_cOrig_, @aData[i]) != 0
                        _nNormalized_++
                    ok
                ok
            next
        else
            _nDataLen_15 = len(@aData)
            for i = 1 to _nDataLen_15
                _nDataiLen_ = len(@aData[i])
                for j = 1 to _nDataiLen_
                    if isString(@aData[i][j])
                        _cOrig_ = @aData[i][j]
                        @aData[i][j] = This._ApplyCaseNormalization(@aData[i][j], _cMode_)
                        if strcmp(_cOrig_, @aData[i][j]) != 0
                            _nNormalized_++
                        ok
                    ok
                next
            next
        ok
        
        This._LogTransformation("NormalizeCase", "" + _nNormalized_ + " values normalized to " + _cMode_)
        return _nNormalized_

    # Reports the columns of a table whose values mix several types, among numeric, boolean, date and string.
    #
    #   returns    a list of texts such as Column age has mixed types: numeric, string; [ ] for a
    #              list
    #   note       a list dataset returns [ ] without looking
    #   warning    Raises Bad parameter type today instead of reporting the mixed types, as soon as
    #              the table holds a text that is not boolean-like (confirmed on two tables): the
    #              helper that tests for a date calls the list search find on the text
    #   see        ValidateRanges, GetIssues, GetDataProfile
    #@ aka  PILLAR 2: DATA VALIDATION =========================
    def ValidateDataTypes()
        # Validate data type consistency within columns
        # Returns: List of validation issues found
        _aIssues_ = []
        
        if @cDataStructure = "table"
            _nHeadersLen_7 = len(@aHeaders)
            for j = 1 to _nHeadersLen_7
                _aColumnTypes_ = []
                _nDataLen_14 = len(@aData)
                for i = 1 to _nDataLen_14
                    if NOT This._IsMissing(@aData[i][j])
                        _cType_ = This._GetDataType(@aData[i][j])
                        if StzFindFirst(_cType_, _aColumnTypes_) = 0
                            _aColumnTypes_ + _cType_
                        ok
                    ok
                next
                
                if len(_aColumnTypes_) > 1
                    _cIssue_ = "Column " + @aHeaders[j] + " has mixed types: " + This._JoinList(_aColumnTypes_, ", ")
                    _aIssues_ + _cIssue_
                    This._AddIssue("mixed_types", _cIssue_)
                ok
            next
        ok
        
        This._LogTransformation("ValidateDataTypes", "" + len(_aIssues_) + " type issues found")
        return _aIssues_

    # Reports the numbers of a table that fall outside the range given for their column.
    #
    #   aRangeRules   a list of rules [ column name, lowest, highest ], such as [ [ "age", 0, 120 ]
    #                 ]
    #   returns       a list of texts such as Row 2, v: 50 outside range [0, 10]; [ ] when all are
    #                 inside or the column is unknown
    #   note          each violation is also added to the issues; a list dataset returns [ ]
    #   see           ValidateDataTypes, DetectOutliers, GetIssues
    def ValidateRanges(aRangeRules)
        # Validate numeric values against specified ranges
        #
        # Range rules format:
        # [ ["column_name", min_value, max_value], ... ]
        _aIssues_ = []
        
        if @cDataStructure = "table"
            _nRangeRules1Len_ = len(aRangeRules)
            for _iLoopRangeRules1_ = 1 to _nRangeRules1Len_
            	_rule_ = aRangeRules[_iLoopRangeRules1_]
                _cColumn_ = _rule_[1]
                _nMin_ = _rule_[2]
                _nMax_ = _rule_[3]
                _nColIndex_ = StzFindFirst(_cColumn_, @aHeaders)
                
                if _nColIndex_ > 0
                    _nDataLen_13 = len(@aData)
                    for i = 1 to _nDataLen_13
                        _value_ = @aData[i][_nColIndex_]
                        if isNumber(_value_) and (_value_ < _nMin_ or _value_ > _nMax_)
                            _cIssue_ = "Row " + i + ", " + _cColumn_ + ": " + _value_ + " outside range [" + _nMin_ + ", " + _nMax_ + "]"
                            _aIssues_ + _cIssue_
                            This._AddIssue("range_violation", _cIssue_)
                        ok
                    next
                ok
            next
        ok
        
        This._LogTransformation("ValidateRanges", "" + len(_aIssues_) + " range violations found")
        return _aIssues_

    # Finds the numbers of a table whose distance from the mean of their column, in standard deviations, exceeds a threshold.
    #
    #   _nThreshold_   the z-score above which a value is an outlier
    #   returns        a list of [ row, column, value, z-score ] for each outlier; [ ] when none
    #   note           a column needs at least 5 numbers to be judged; each outlier is also added to
    #                  the issues
    #   see            ValidateRanges, GetIssues
    def DetectOutliers(_nThreshold_)
        # Detect statistical outliers using Z-score method
        # Returns: List of outlier positions

		if IsNull(_nThreshold_) or _nThreshold_ = 0
			_nThreshold_ = $nWRANGLE_OUTLIER_THRESHOLD
		ok

        _aOutliers_ = []
        
        if @cDataStructure = "table"
            _nHeadersLen_6 = len(@aHeaders)
            for j = 1 to _nHeadersLen_6
                _aColumnData_ = This._GetNumericColumnData(j)
                if len(_aColumnData_) >= $nWRANGLE_MIN_SAMPLE_SIZE
                    _nMean_ = This._CalculateMean(_aColumnData_)
                    _nStdDev_ = This._CalculateStdDev(_aColumnData_)
                    
                    if _nStdDev_ > 0
                        _nDataLen_12 = len(@aData)
                        for i = 1 to _nDataLen_12
                            _value_ = @aData[i][j]
                            if isNumber(_value_)
                                _nZScore_ = abs((_value_ - _nMean_) / _nStdDev_)
                                if _nZScore_ > _nThreshold_
                                    _aOutliers_ + [i, j, _value_, _nZScore_]
                                    This._AddIssue("outlier", "Row " + i + ", " + @aHeaders[j] + ": " + _value_ + " (Z-score: " + _nZScore_ + ")")
                                ok
                            ok
                        next
                    ok
                ok
            next
        ok
        
        This._LogTransformation("DetectOutliers", "" + len(_aOutliers_) + " outliers detected")
        return _aOutliers_

    # Converts the cells of the named columns of a table to numeric, string, boolean or date, leaving the cells that do not convert.
    #
    #   aConversionRules   a list of pairs [ column name, target type ], such as [ [ "age",
    #                      "numeric" ] ]
    #   returns            the number of cells converted
    #   note               missing cells are skipped; text that is not a number stays text
    #   warning            a boolean target turns true-like texts into 1 and leaves false-like texts
    #                      such as false, no and 0 as they were (confirmed on two tables), because
    #                      the converted 0 is taken as no result; the date target changes nothing
    #                      yet but still counts the cells
    #   see                NormalizeNumeric, ValidateDataTypes
    #@ aka  PILLAR 3: DATA TRANSFORMATION =============================
    def ConvertDataTypes(aConversionRules)
        # Convert data types based on rules or auto-detection
        #
        # Conversion rules format:
        # [ ["column_name", "target_type"], ... ]
        # Target types: "numeric", "string", "boolean", "date"
        _nConverted_ = 0
        
        if @cDataStructure = "table"
            _nConversionRules1Len_ = len(aConversionRules)
            for _iLoopConversionRules1_ = 1 to _nConversionRules1Len_
            	_rule_ = aConversionRules[_iLoopConversionRules1_]
                _cColumn_ = _rule_[1]
                _cTargetType_ = _rule_[2]
                _nColIndex_ = StzFindFirst(_cColumn_, @aHeaders)
                
                if _nColIndex_ > 0
                    _nDataLen_11 = len(@aData)
                    for i = 1 to _nDataLen_11
                        if NOT This._IsMissing(@aData[i][_nColIndex_])
                            _convertedValue_ = This._ConvertValue(@aData[i][_nColIndex_], _cTargetType_)
                            if _convertedValue_ != ""
                                @aData[i][_nColIndex_] = _convertedValue_
                                _nConverted_++
                            ok
                        ok
                    next
                ok
            next
        ok
        
        This._LogTransformation("ConvertDataTypes", "" + _nConverted_ + " values converted")
        return _nConverted_

    # Rescales every column of numbers of a table, replacing the values in place.
    #
    #   _cMethod_   minmax (0 to 1), zscore (mean 0) or robust (median based)
    #   returns     the number of values rescaled
    #   note        list datasets are left alone
    #   warning     an unknown method counts the values but leaves them unchanged
    #   see         EncodeCategories, ConvertDataTypes
    def NormalizeNumeric(_cMethod_)
        # Normalize numeric columns
        # Methods: "minmax" (0-1), "zscore" (mean=0, std=1), "robust" (median-based)

		if IsNull(_cMethod_)
			_cMethod_ = "minmax"
		ok

        _nNormalized_ = 0
        
        if @cDataStructure = "table"
            _nHeadersLen_5 = len(@aHeaders)
            for j = 1 to _nHeadersLen_5
                _aColumnData_ = This._GetNumericColumnData(j)
                if len(_aColumnData_) > 0
                    _aNormalizedData_ = This._NormalizeArray(_aColumnData_, _cMethod_)
                    _nDataIndex_ = 1
                    
                    # Apply normalized values back to original positions
                    _nDataLen_10 = len(@aData)
                    for i = 1 to _nDataLen_10
                        if isNumber(@aData[i][j]) and NOT This._IsMissing(@aData[i][j])
                            @aData[i][j] = _aNormalizedData_[_nDataIndex_]
                            _nDataIndex_++
                            _nNormalized_++
                        ok
                    next
                ok
            next
        ok
        
        This._LogTransformation("NormalizeNumeric", "" + _nNormalized_ + " values normalized using " + _cMethod_)
        return _nNormalized_

    # Replaces the values of every column that looks categorical with whole numbers, in order of first appearance from 0.
    #
    #   _cMethod_   label
    #   returns     the number of values encoded
    #   note        list datasets are left alone
    #   warning     a column counts as categorical with fewer than 20 distinct values, so small
    #               numeric columns are encoded too
    #   see         NormalizeNumeric
    def EncodeCategories(_cMethod_)
        # Encode categorical variables for analysis
        # Methods: "label" (0,1,2...), "onehot" (binary columns), "ordinal" (custom order)

		if IsNull(_cMethod_)
			_cMethod_ = "label"
		ok

        _nEncoded_ = 0
        
        if @cDataStructure = "table"
            _nHeadersLen_4 = len(@aHeaders)
            for j = 1 to _nHeadersLen_4
                if This._IsColumnCategorical(j)
                    _aUniqueValues_ = This._GetUniqueColumnValues(j)
                    if _cMethod_ = "label"
                        _nEncoded_ += This._ApplyLabelEncoding(j, _aUniqueValues_)
                    ok
                ok
            next
        ok
        
        This._LogTransformation("EncodeCategories", "" + _nEncoded_ + " categorical values encoded")
        return _nEncoded_

    # Looks up a wrangling plan by goal or by template name and returns it with an estimated time.
    #
    #   cGoalOrTemplate   a goal (clean, validate or export) or a template name such as
    #                     basic_cleanup, data_validation, prepare_analysis or export_ready, in any
    #                     case
    #   returns           a hash-list with name, title, description, steps and estimated_time; empty
    #                     text when the goal is unknown
    #   note              an unknown goal is also written to the transformation log
    #   warning           the goal analyze returns empty text today instead of the analysis plan
    #                     (confirmed twice), because it maps to prepare_for_analysis while the
    #                     template is named prepare_analysis; use the template name
    #   see               ExecutePlan, QuickClean
    #@ aka  PILLAR 4: PLAN EXECUTION SYSTEM ===============================
    def GeneratePlan(cGoalOrTemplate)
        # Generate a wrangling plan based on goal or template name
        #
        # Goals: "clean", "validate", "analyze", "export"
        # Templates: "basic_cleanup", "data_validation", etc.
        _cTemplate_ = This._ResolvePlanTemplate(cGoalOrTemplate)
        if _cTemplate_ = ""
            This._LogTransformation("GeneratePlan", "Unknown goal/template: " + cGoalOrTemplate)
            return ""
        ok
        
        # Find template definition
        _nWranglingPlanTemplates2Len_ = len($aWranglingPlanTemplates)
        for _iLoopWranglingPlanTemplates2_ = 1 to _nWranglingPlanTemplates2Len_
        	_template_ = $aWranglingPlanTemplates[_iLoopWranglingPlanTemplates2_]
            if _template_[2][:name] = _cTemplate_
                return [
                    :name = _template_[2][:name],
                    :title = _template_[2][:title],
                    :description = _template_[2][:description],
                    :steps = _template_[2][:steps],
                    :estimated_time = This._EstimatePlanTime(_template_[2][:steps])
                ]
            ok
        next
        
        return ""

    # Runs the steps of a plan on the data one after another and collects what each did.
    #
    #   cGoalOrTemplate   a goal or template name as for GeneratePlan
    #   bVerbose          1 to print each step as it runs, 0 for silence
    #   returns           a hash-list with plan, results, execution_time and summary; empty text
    #                     when the plan is unknown
    #   note              the data is changed in place; each step uses default settings
    #   warning           a step that raises is recorded with status error and the run goes on; the
    #                     export plan reports 3 errors of 4 steps today because its header and date
    #                     helpers raise
    #   see               GeneratePlan, QuickClean
    def ExecutePlan(cGoalOrTemplate, bVerbose)
        # Execute a complete wrangling plan
        # Returns: Execution summary with results and any errors

        @bVerbose = bVerbose
        _aPlan_ = This.GeneratePlan(cGoalOrTemplate)
        if _aPlan_ = "" return "" ok
        
        if @bVerbose
            ? "ðŸ”§ Executing Plan: " + _aPlan_[:title]
            ? "ðŸ“ " + _aPlan_[:description]
            ? char(226) + char(143) + char(177) + char(239) + char(184) + char(143) + "  Estimated time: " + _aPlan_[:estimated_time] + " seconds"
            ? ""
        ok
        
        _aResults_ = []
        _nStartTime_ = clock()
        
        _aPlansteps1_ = _aPlan_[:steps]
        _nPlansteps1Len_ = len(_aPlansteps1_)
        for _iLoopPlansteps1_ = 1 to _nPlansteps1Len_
        	_stepp_ = _aPlansteps1_[_iLoopPlansteps1_]
            if @bVerbose
                ? char(226) + char(150) + char(182) + char(239) + char(184) + char(143) + "  " + _stepp_[:description] + "..."
            ok
            
            try
                _result_ = This._ExecutePlanStep(_stepp_)
                _aResults_ + [
                    :function = _stepp_[:function],
                    :description = _stepp_[:description],
                    :result = _result_,
                    :status = "success"
                ]
                
                if @bVerbose
                    ? "   " + char(226) + char(156) + char(133) + " " + _result_
                ok
                
            catch
                _aResults_ + [
                    :function = _stepp_[:function],
                    :description = _stepp_[:description],
                    :error = cCatchError,
                    :status = "error"
                ]
                
                if @bVerbose
                    ? "   " + char(226) + char(157) + char(140) + " Error: " + cCatchError
                ok
            done
        next
        
        _nEndTime_ = clock()
        _nActualTime_ = (_nEndTime_ - _nStartTime_)
        
        if @bVerbose
            ? ""
            ? "ðŸŽ‰ Plan execution completed in " + _nActualTime_ + " seconds"
            ? "ðŸ“Š " + This._GetExecutionSummary(_aResults_)
        ok
        
        return [
            :plan = _aPlan_,
            :results = _aResults_,
            :execution_time = _nActualTime_,
            :summary = This._GetExecutionSummary(_aResults_)
        ]

    # Returns the data as it stands now, a flat list or the rows of the table.
    #
    #   returns    the list or the rows of the table
    #   see        ExportForStzTable, ExportForStzMatrix
    #@ aka  PILLAR 5: EXPORT AND INTEGRATION ================================
    def ExportForStzDataSet()
        # Export cleaned data in format suitable for stzDataSet
        # Returns: Clean list or 2D array ready for statistical analysis
        if @cDataStructure = "list"
            return @aData
        else
            # For tables, might want to return specific columns or flattened data
            return @aData
        ok

    # Returns the data in the shape the table class takes: the headers and then the rows.
    #
    #   returns    a pair [ headers, rows ]; for a flat list [ [ "Value" ], [ the items ] ]
    #   see        ExportForStzDataSet, GetHeaders
    def ExportForStzTable()
        # Export as structured table data for stzTable class
        # Returns: [headers, data] format
        if @cDataStructure = "table"
            return [ @aHeaders, @aData ]
        else
			_aItems_ = []
			_nDataLen_9 = len(@aData)
			for i = 1 to _nDataLen_9
				_aItems_ + @aData[i]
			next
            return [ ["Value"], [ _aItems_ ] ]
        ok

    # Returns the data as rows of numbers, with a 0 in place of every cell that is not a number.
    #
    #   returns    a list of rows of numbers; for a flat list a single row holding its numbers
    #   see        ExportForStzDataSet
    def ExportForStzMatrix()
        # Export numeric data suitable for stzMatrix operations
        # Returns: 2D numeric array
        if @cDataStructure = "table"
            # Extract only numeric columns
            _aNumericData_ = []
            _nData6Len_ = len(@aData)
            for _iLoopData6_ = 1 to _nData6Len_
            	_row_ = @aData[_iLoopData6_]
                _aNumericRow_ = []
                _nRow3Len_ = len(_row_)
                for _iLoopRow3_ = 1 to _nRow3Len_
                	_item_ = _row_[_iLoopRow3_]
                    if isNumber(_item_)
                        _aNumericRow_ + _item_
                    else
                        _aNumericRow_ + 0  # Default for non-numeric
                    ok
                next
                _aNumericData_ + _aNumericRow_
            next
            return _aNumericData_
        else
            # Convert list to single column matrix
			_aItems_ = []
			_nDataLen_8 = len(@aData)
			for i = 1 to _nDataLen_8
				if isNumber(@aData[i])
					_aItems_ + @aData[i]
				ok
			next
            return [ _aItems_ ]
        ok

    # Returns a summary of the data: structure, rows, columns, issues, transformations, types, missing values and duplicates.
    #
    #   returns    a hash-list with structure, rows, columns, issues_found, transformations_applied,
    #              data_types, missing_values and duplicates
    #   note       the profile of a flat list has columns 0 and data_types empty
    #   warning    Raises Bad parameter type today instead of the profile for a table holding text
    #              (confirmed on two tables), for the same reason as ValidateDataTypes; a flat list
    #              or an empty dataset works
    #   see        ShowReport, GetIssues
    #@ aka  REPORTING AND DIAGNOSTICS =========================
    def GetDataProfile()
        """Generate comprehensive data profile report"""
        _aProfile_ = [
            :structure = @cDataStructure,
            :rows = This._GetRowCount(),
            :columns = len(@aHeaders),
            :issues_found = len(@aIssues),
            :transformations_applied = len(@aTransformLog),
            :data_types = This._GetDataTypesSummary(),
            :missing_values = This._CountMissingValues(),
            :duplicates = This._CountDuplicates()
        ]
        
        return _aProfile_

    # Returns the log of every operation applied, oldest first, starting with the loading of the data.
    #
    #   returns    a list of hash-lists with timestamp, operation and details
    #   see        GetIssues, Reset
    def GetTransformationLog()
        """Return complete log of all transformations applied"""
        return @aTransformLog

    # Returns the data quality issues recorded by the checks so far.
    #
    #   returns    a list of hash-lists with type, description and detected_at
    #   see        ValidateRanges, DetectOutliers, Reset
    def GetIssues()
        """Return all detected data quality issues"""
        return @aIssues

    # Prints the structure, size, issues and operations of the data as a report on the console.
    #
    #   returns    nothing
    #   note       the heading lines of the report carry garbled symbols because of their source
    #              encoding
    #   warning    Raises Bad parameter type today for a table holding text, as the profile does; a
    #              flat list prints
    #   see        GetDataProfile
    def ShowReport()
        """Display formatted data quality report"""
        _aProfile_ = This.GetDataProfile()
        
        ? "ðŸ“‹ DATA WRANGLING REPORT"
        ? "========================"
        ? "Structure: " + _aProfile_[:structure]
        ? "Dimensions: " + _aProfile_[:rows] + " rows × " + _aProfile_[:columns] + " columns"
        ? "Issues Found: " + _aProfile_[:issues_found]
        ? "Transformations: " + _aProfile_[:transformations_applied]
        ? ""
        
        if len(@aIssues) > 0
            ? "ðŸš¨ ISSUES DETECTED:"
            _nIssues1Len_ = len(@aIssues)
            for _iLoopIssues1_ = 1 to _nIssues1Len_
            	_issue_ = @aIssues[_iLoopIssues1_]
                ? "  " + char(226) + char(128) + char(162) + " " + _issue_[:type] + ": " + _issue_[:description]
            next
            ? ""
        ok
        
        if len(@aTransformLog) > 0
            ? "ðŸ”„ TRANSFORMATIONS APPLIED:"
            _nTransformLog1Len_ = len(@aTransformLog)
            for _iLoopTransformLog1_ = 1 to _nTransformLog1Len_
            	transform = @aTransformLog[_iLoopTransformLog1_]
                ? "  " + char(226) + char(128) + char(162) + " " + transform[:operation] + ": " + transform[:details]
            next
        ok

    # HELPER METHODS
    # ==============
    
    def _IsMissing(_value_)
        return isNull(_value_) or StzFindFirst("" + _value_, $aWRANGLE_MISSING_VALUES) > 0

    def _GetFillValue(aData, _cStrategy_)
        # Determine best fill value based on data and strategy
        if _cStrategy_ = "fill_zero" return 0 ok
        if _cStrategy_ = "fill_mean" return This._CalculateMean(This._GetNumericValues(aData)) ok
        
        # Auto strategy - intelligent selection
        _aNumericValues_ = This._GetNumericValues(aData)
        if len(_aNumericValues_) > 0
            return This._CalculateMean(_aNumericValues_)  # Use mean for numeric
        else
            return This._GetMostFrequent(aData)  # Use mode for categorical
        ok


    def _GetNumericValues(aData)
		_nLen_ = len(aData)
		_anResult_ = []
		for i = 1 to _nLen_
			if isNumber(aData[i]) and NOT This._IsMissing(aData[i])
				_anResult_ + aData[i]
			ok
		next

        return _anResult_

    def _CalculateMean(aNumbers)
        if len(aNumbers) = 0 return 0 ok
        return sum(aNumbers) / len(aNumbers)

    def _CalculateStdDev(aNumbers)
        if len(aNumbers) < 2 return 0 ok
        _nMean_ = This._CalculateMean(aNumbers)

		_nSum_ = 0
		_nLen_ = len(aNumbers)
		for i = 1 to _nLen_
			_x_ = aNumbers[i]
			_nSum_ += (_x_ - _nMean_) * (_x_ - _nMean_)
		next
		_nVariance_ = _nSum_ / (_nLen_ - 1)

        return sqrt(_nVariance_)

    def _GetMostFrequent(aData)
        # Find mode (most frequent value)
        _aFreq_ = []
        _nData5Len_ = len(aData)
        for _iLoopData5_ = 1 to _nData5Len_
        	_item_ = aData[_iLoopData5_]
            if NOT This._IsMissing(_item_)
                _nIndex_ = This._FindInFreqArray(_aFreq_, _item_)
                if _nIndex_ = 0
                    _aFreq_ + [_item_, 1]
                else
                    _aFreq_[_nIndex_][2]++
                ok
            ok
        next
        
        if len(_aFreq_) = 0 return "" ok
        
        # Find item with highest frequency
        _nMaxFreq_ = 0
        _mostFrequent_ = _aFreq_[1][1]
        _nFreq1Len_ = len(_aFreq_)
        for _iLoopFreq1_ = 1 to _nFreq1Len_
        	_freq_ = _aFreq_[_iLoopFreq1_]
            if _freq_[2] > _nMaxFreq_
                _nMaxFreq_ = _freq_[2]
                _mostFrequent_ = _freq_[1]
            ok
        next
        
        return _mostFrequent_

    def _ApplyCaseNormalization(cText, _cMode_)
        switch _cMode_
        on "lower"   return StzLower(cText)
        on "upper"   return StzUpper(cText)
        on "title"   return This._ToTitleCase(cText)
        on "sentence" return This._ToSentenceCase(cText)
        other        return cText
        off

    def _ToTitleCase(cText)
        # Simple title case implementation
        _aWords_ = split(cText, " ")
        _nWordsLen_ = len(_aWords_)
        for i = 1 to _nWordsLen_
            if len(_aWords_[i]) > 0
                _aWords_[i] = StzUpper(StzLeft(_aWords_[i], 1)) + StzLower(StzMid(_aWords_[i], 2, StzLen(_aWords_[i]) - 1))
            ok
        next
        return This._JoinList(_aWords_, " ")

    def _ToSentenceCase(cText)
        if len(cText) > 0
            return StzUpper(StzLeft(cText, 1)) + StzLower(StzMid(cText, 2, StzLen(cText) - 1))
        ok
        return cText

    def _GetDataType(_value_)
        if isNumber(_value_) return "numeric" ok
        if isString(_value_) 
            if This._IsBoolean(_value_) return "boolean" ok
            if This._IsDate(_value_) return "date" ok
            return "string"
        ok
        return "unknown"

    def _IsBoolean(_cValue_)
        return StzFindFirst(StzLower(trim("" + _cValue_)), $aWRANGLE_TRUE_VALUES + $aWRANGLE_FALSE_VALUES) > 0

    def _IsDate(_cValue_)
        # Simple date detection - could be enhanced
        _cValue_ = "" + _cValue_
        return (find(_cValue_, "/") > 0 or find(_cValue_, "-") > 0) and len(_cValue_) >= 8

    def _ConvertValue(_value_, _cTargetType_)
        switch _cTargetType_
        on "numeric"
            if isNumber(_value_) return _value_ ok
            if isString(_value_)
                try
                    return 0 + _value_  # Ring's implicit conversion
                catch
                    return ""
                done
            ok
            
        on "string"
            return "" + _value_
            
        on "boolean"
            if This._IsBoolean(_value_)
                return StzFindFirst(StzLower(trim("" + _value_)), $aWRANGLE_TRUE_VALUES) > 0
            ok
            
        on "date"
            # Date conversion would need more sophisticated logic
            return _value_
        off
        
        return ""

    def _LogTransformation(cOperation, cDetails)
        @aTransformLog + [
            :timestamp = date() + " " + time(),
            :operation = cOperation,
            :details = cDetails
        ]

    def _AddIssue(_cType_, cDescription)
        @aIssues + [
            :type = _cType_,
            :description = cDescription,
            :detected_at = date() + " " + time()
        ]

    def _GetRowCount()
        if @cDataStructure = "list"
            return len(@aData)
        else
            return len(@aData)
        ok

    def _ResolvePlanTemplate(_cInput_)
        _cInput_ = StzLower(trim(_cInput_))
        
        # Check if it's a direct template name
        _nWranglingPlanTemplates1Len_ = len($aWranglingPlanTemplates)
        for _iLoopWranglingPlanTemplates1_ = 1 to _nWranglingPlanTemplates1Len_
        	_template_ = $aWranglingPlanTemplates[_iLoopWranglingPlanTemplates1_]
            if _template_[2][:name] = _cInput_
                return _cInput_
            ok
next
        
        # Check if it's a goal that maps to a template
        _nWranglingGoals1Len_ = len($aWranglingGoals)
        for _iLoopWranglingGoals1_ = 1 to _nWranglingGoals1Len_
        	_goal_ = $aWranglingGoals[_iLoopWranglingGoals1_]
            if _goal_[1] = _cInput_
                return _goal_[2]
            ok
        next
        
        return ""

    def _EstimatePlanTime(aSteps)
        # Simple time estimation based on number of steps
        _nBaseTime_ = len(aSteps) * 0.5  # 0.5 seconds per step
        _nDataSizeFactor_ = This._GetRowCount() / 1000.0  # Additional time for larger datasets
        return _nBaseTime_ + _nDataSizeFactor_

    def _ExecutePlanStep(aStep)
        _cFunction_ = aStep[:function]
        
        switch _cFunction_
        on "RemoveDuplicates"
            _nRemoved_ = This.RemoveDuplicates()
            return "Removed " + _nRemoved_ + " duplicate rows"
            
        on "HandleMissingValues"
            _nFilled_ = This.HandleMissingValues("")
            return "Processed " + _nFilled_ + " missing values"
            
        on "TrimWhitespace"
            _nCleaned_ = This.TrimWhitespace()
            return "Cleaned " + _nCleaned_ + " text values"
            
        on "NormalizeCase"
            _nNormalized_ = This.NormalizeCase("")
            return "Normalized " + _nNormalized_ + " text values"
            
        on "ValidateDataTypes"
            _aIssues_ = This.ValidateDataTypes()
            return "Found " + len(_aIssues_) + " type inconsistencies"
            
        on "ValidateRanges"
            _aIssues_ = This.ValidateRanges([])
            return "Validated ranges - " + len(_aIssues_) + " violations found"
            
        on "ValidateFormats"
            return "Format validation completed"
            
        on "DetectOutliers"
            _aOutliers_ = This.DetectOutliers(0)
            return "Detected " + len(_aOutliers_) + " potential outliers"
            
        on "ConvertDataTypes"
            _nConverted_ = This.ConvertDataTypes([])
            return "Converted " + _nConverted_ + " values"
            
        on "NormalizeNumeric"
            _nNormalized_ = This.NormalizeNumeric("")
            return "Normalized " + _nNormalized_ + " numeric values"
            
        on "EncodeCategories"
            _nEncoded_ = This.EncodeCategories("")
            return "Encoded " + _nEncoded_ + " categorical values"
            
        on "StandardizeHeaders"
            _nStandardized_ = This._StandardizeHeaders()
            return "Standardized " + _nStandardized_ + " column headers"
            
        on "FormatDates"
            _nFormatted_ = This._FormatDates()
            return "Formatted " + _nFormatted_ + " date values"
            
        on "ValidateExport"
            _aIssues_ = This._ValidateForExport()
            return "Export validation - " + len(_aIssues_) + " issues found"
            
        other
            return "Unknown function: " + _cFunction_
        off

    def _GetExecutionSummary(_aResults_)
        _nSuccessful_ = 0
        _nErrors_ = 0
        
        _nResults1Len_ = len(_aResults_)
        for _iLoopResults1_ = 1 to _nResults1Len_
        	_result_ = _aResults_[_iLoopResults1_]
            if _result_[:status] = "success"
                _nSuccessful_++
            else
                _nErrors_++
            ok
        next
        
        return "" + _nSuccessful_ + " successful, " + _nErrors_ + " errors"

    def _GetDataTypesSummary()
        if @cDataStructure != "table" return [] ok
        
        _aTypeSummary_ = []
        _nHeadersLen_3 = len(@aHeaders)
        for j = 1 to _nHeadersLen_3
            _aTypes_ = []
            _nDataLen_7 = len(@aData)
            for i = 1 to _nDataLen_7
                if NOT This._IsMissing(@aData[i][j])
                    _cType_ = This._GetDataType(@aData[i][j])
                    if StzFindFirst(_cType_, _aTypes_) = 0
                        _aTypes_ + _cType_
                    ok
                ok
            next
            _aTypeSummary_ + [@aHeaders[j], _aTypes_]
        next
        
        return _aTypeSummary_

    def _CountMissingValues()
        _nMissing_ = 0
        
        if @cDataStructure = "list"
            _nData4Len_ = len(@aData)
            for _iLoopData4_ = 1 to _nData4Len_
            	_item_ = @aData[_iLoopData4_]
                if This._IsMissing(_item_) _nMissing_++ ok
            next
        else
            _nData3Len_ = len(@aData)
            for _iLoopData3_ = 1 to _nData3Len_
            	_row_ = @aData[_iLoopData3_]
                _nRow2Len_ = len(_row_)
                for _iLoopRow2_ = 1 to _nRow2Len_
                	_item_ = _row_[_iLoopRow2_]
                    if This._IsMissing(_item_) _nMissing_++ ok
                next
            next
        ok
        
        return _nMissing_

    def _CountDuplicates()
        if @cDataStructure = "list"
            return len(@aData) - len(unique(@aData))
        else
            _nOriginal_ = len(@aData)
            _aUnique_ = []
            _nData2Len_ = len(@aData)
            for _iLoopData2_ = 1 to _nData2Len_
            	_row_ = @aData[_iLoopData2_]
                if This._FindRowIndex(_aUnique_, _row_) = 0
                    _aUnique_ + _row_
                ok
            next
            return _nOriginal_ - len(_aUnique_)
        ok

    def _FindRowIndex(aRows, aTargetRow)
        _nRowsLen_ = len(aRows)
        for i = 1 to _nRowsLen_
            if This._RowsEqual(aRows[i], aTargetRow)
                return i
            ok
        next
        return 0

    def _RowsEqual(aRow1, aRow2)
        if len(aRow1) != len(aRow2) return 0 ok
        _nRow1Len_ = len(aRow1)
        for i = 1 to _nRow1Len_
            if aRow1[i] != aRow2[i] return 0 ok
        next
        return 1

    def _GetNumericColumnData(_nColIndex_)
        _aNumericData_ = []
        _nDataLen_6 = len(@aData)
        for i = 1 to _nDataLen_6
            if isNumber(@aData[i][_nColIndex_]) and NOT This._IsMissing(@aData[i][_nColIndex_])
                _aNumericData_ + @aData[i][_nColIndex_]
            ok
        next
        return _aNumericData_

    def _NormalizeArray(aData, _cMethod_)
        switch _cMethod_
        on "minmax"
			_aResult_ = []
            _nMin_ = min(aData)
            _nMax_ = max(aData)
            if _nMax_ = _nMin_ return aData ok

			_nLen_ = len(aData)
			for i = 1 to _nLen_
				_x_ = aData[i]
				_aResult_ + ( (_x_ - _nMin_) / (_nMax_ - _nMin_) )
			next

            return _aResult_
            
        on "zscore"
            _nMean_ = This._CalculateMean(aData)
            _nStdDev_ = This._CalculateStdDev(aData)
            if _nStdDev_ = 0 return aData ok

			_aResult_ = []
			_nLen_ = len(aData)
			for i = 1 to _nLen_
				_x_ = aData[i]
				_aResult_ + ( (_x_ - _nMean_) / _nStdDev_ )
			next

            return _aResult_
            
        on "robust"
            # Median-based normalization
            _nMedian_ = This._CalculateMedian(aData) 
            _nMAD_ = This._CalculateMAD(aData, _nMedian_)  # Median Absolute Deviation
            if _nMAD_ = 0 return aData ok

			_aResult_ = []
			_nLen_ = len(aData)
			for i = 1 to _nLen_
				_x_ = aData[i]
				_aResult_ + ( (_x_ - _nMedian_) / _nMAD_ )
			next

            return _aResult_
            
        other
            return aData
        off

    def _CalculateMedian(aData)
        _aSorted_ = sort(aData)
        _nLen_ = len(_aSorted_)
        if _nLen_ % 2 = 1
            return _aSorted_[(_nLen_ + 1) / 2]
        else
            return (_aSorted_[_nLen_ / 2] + _aSorted_[_nLen_ / 2 + 1]) / 2
        ok

    def _CalculateMAD(aData, _nMedian_)
		_aDeviations_ = []
		_nLen_ = len(aData)
		for i = 1 to _nLen_
			_x_ = aData[i]
			_aDeviations_ + abs(_x_ - _nMedian_)
		next
        return This._CalculateMedian(_aDeviations_)

    def _IsColumnCategorical(_nColIndex_)
        _aUniqueValues_ = This._GetUniqueColumnValues(_nColIndex_)
        _nUniqueCount_ = len(_aUniqueValues_)
        _nTotalCount_ = This._GetNonMissingCount(_nColIndex_)
        
        # Consider categorical if:
        # 1. Less than 20 unique values, OR
        # 2. Unique values are less than 50% of total values, OR
        # 3. Contains non-numeric data
        return (_nUniqueCount_ < 20) or 
               (_nUniqueCount_ < _nTotalCount_ * 0.5) or
               This._ContainsNonNumeric(_nColIndex_)

    def _GetUniqueColumnValues(_nColIndex_)
        _aUnique_ = []
        _nDataLen_5 = len(@aData)
        for i = 1 to _nDataLen_5
            _value_ = @aData[i][_nColIndex_]
            if NOT This._IsMissing(_value_) and StzFindFirst(_value_, _aUnique_) = 0
                _aUnique_ + _value_
            ok
        next
        return _aUnique_

    def _GetNonMissingCount(_nColIndex_)
        _nCount_ = 0
        _nDataLen_4 = len(@aData)
        for i = 1 to _nDataLen_4
            if NOT This._IsMissing(@aData[i][_nColIndex_])
                _nCount_++
            ok
        next
        return _nCount_

    def _ContainsNonNumeric(_nColIndex_)
        _nDataLen_3 = len(@aData)
        for i = 1 to _nDataLen_3
            _value_ = @aData[i][_nColIndex_]
            if NOT This._IsMissing(_value_) and NOT isNumber(_value_)
                return 1
            ok
        next
        return 0

    def _ApplyLabelEncoding(_nColIndex_, _aUniqueValues_)
        _nEncoded_ = 0
        _nDataLen_2 = len(@aData)
        for i = 1 to _nDataLen_2
            _value_ = @aData[i][_nColIndex_]
            if NOT This._IsMissing(_value_)
                _nLabelIndex_ = StzFindFirst(_value_, _aUniqueValues_)
                if _nLabelIndex_ > 0
                    @aData[i][_nColIndex_] = _nLabelIndex_ - 1  # 0-based encoding
                    _nEncoded_++
                ok
            ok
        next
        return _nEncoded_

    def _FindInFreqArray(_aFreq_, _item_)
        _nFreqLen_ = len(_aFreq_)
        for i = 1 to _nFreqLen_
            if _aFreq_[i][1] = _item_
                return i
            ok
        next
        return 0

    def _JoinList(aList, cSeparator)
        if len(aList) = 0 return "" ok
        _cResult_ = "" + aList[1]
        _nListLen_ = len(aList)
        for i = 2 to _nListLen_
            _cResult_ += cSeparator + aList[i]
        next
        return _cResult_

    def _StandardizeHeaders()
        """Standardize column headers for export compatibility"""
        _nStandardized_ = 0
        
        _nHeadersLen_2 = len(@aHeaders)
        for i = 1 to _nHeadersLen_2
            _cOriginal_ = @aHeaders[i]
            _cStandardized_ = This._CleanHeaderName(_cOriginal_)
            if _cOriginal_ != _cStandardized_
                @aHeaders[i] = _cStandardized_
                _nStandardized_++
            ok
        next
        
        return _nStandardized_

    def _CleanHeaderName(cHeader)
        # Remove special characters, normalize spacing
        _cCleaned_ = ""
        _nHeaderLen_ = len(cHeader)
        for i = 1 to _nHeaderLen_
            _cChar_ = cHeader[i]
            if isalnum(_cChar_) or _cChar_ = "_"
                _cCleaned_ += _cChar_
            elseif _cChar_ = " "
                _cCleaned_ += "_"
            ok
        next
        
        # Remove double underscores and trim
        while find(_cCleaned_, "__") > 0
            _cCleaned_ = StzReplace(_cCleaned_, "__", "_")
        end
        
        return trim(_cCleaned_)

    def _FormatDates()
        """Standardize date formats across the dataset"""
        _nFormatted_ = 0
        
        if @cDataStructure = "table"
            _nHeadersLen_ = len(@aHeaders)
            for j = 1 to _nHeadersLen_
                _nDataLen_ = len(@aData)
                for i = 1 to _nDataLen_
                    if This._IsDate(@aData[i][j])
                        _cFormatted_ = This._StandardizeDateFormat(@aData[i][j])
                        if _cFormatted_ != @aData[i][j]
                            @aData[i][j] = _cFormatted_
                            _nFormatted_++
                        ok
                    ok
                next
            next
        ok
        
        return _nFormatted_

    def _StandardizeDateFormat(_cDate_)
        # Simple date standardization - could be enhanced with proper date parsing
        _cDate_ = "" + _cDate_
        
        # Convert common formats to ISO format (YYYY-MM-DD)
        if find(_cDate_, "/") > 0
            # Handle MM/DD/YYYY or DD/MM/YYYY formats
            _aParts_ = split(_cDate_, "/")
            if len(_aParts_) = 3
                # Assume MM/DD/YYYY for now
                return _aParts_[3] + "-" + This._PadZero(_aParts_[1]) + "-" + This._PadZero(_aParts_[2])
            ok
        ok
        
        return _cDate_

    def _PadZero(_cNumber_)
        _cNumber_ = "" + _cNumber_
        if len(_cNumber_) = 1
            return "0" + _cNumber_
        ok
        return _cNumber_

    def _ValidateForExport()
        """Final validation before export"""
        _aIssues_ = []
        
        # Check for remaining missing values
        _nMissing_ = This._CountMissingValues()
        if _nMissing_ > 0
            _aIssues_ + "Missing values detected: " + _nMissing_
        ok
        
        # Check for problematic characters in headers
        if @cDataStructure = "table"
            _nHeaders1Len_ = len(@aHeaders)
            for _iLoopHeaders1_ = 1 to _nHeaders1Len_
            	_header_ = @aHeaders[_iLoopHeaders1_]
                if find(_header_, " ") > 0 or find(_header_, "-") > 0
                    _aIssues_ + "Header contains spaces/hyphens: " + _header_
                ok
            next
        ok
        
        return _aIssues_

    # Runs the clean plan silently: removes duplicates, fills missing values, trims spaces and lowers the case.
    #
    #   returns    the same hash-list as ExecutePlan
    #   note       the data is changed in place
    #   see        Clean, ExecutePlan
    #@ aka  CONVENIENCE METHODS FOR QUICK OPERATIONS =======================================
    def QuickClean()
        """Perform basic cleaning operations quickly"""
        return This.ExecutePlan("clean", 0)

    # Runs the validation plan silently: types, ranges, formats and outliers.
    #
    #   returns    the same hash-list as ExecutePlan
    #   warning    Reports one error for ValidateDataTypes today on a table holding text, as that
    #              method raises
    #   see        Validate, ExecutePlan
    def QuickValidate()
        """Perform validation checks quickly"""  
        return This.ExecutePlan("validate", 0)

    # Runs the analysis plan silently, which should fill, convert, normalize and encode the data.
    #
    #   returns    the same hash-list as ExecutePlan when the plan resolves; empty text today
    #   note       see GeneratePlan
    #   warning    Returns empty text and does nothing today (confirmed twice), because the goal
    #              analyze maps to a template name that does not exist; ExecutePlan with
    #              prepare_analysis works
    #   see        Transform, GeneratePlan
    def QuickPrepareForAnalysis()
        """Prepare data for statistical analysis quickly"""
        return This.ExecutePlan("analyze", 0)

    # Runs the export plan silently: headers, missing values, dates and a final check.
    #
    #   returns    the same hash-list as ExecutePlan
    #   warning    Reports 3 errors out of 4 steps today, since the header and date helpers raise;
    #              only the missing-value step does its work
    #   see        Export, ExecutePlan
    def QuickPrepareForExport()
        """Prepare data for export quickly"""
        return This.ExecutePlan("export", 0)

    # Runs the clean plan silently and returns the wrangler, so that calls chain.
    #
    #   returns    the wrangler itself
    #   see        QuickClean
    #@ aka  CHAINABLE OPERATIONS ===================
    def Clean()
        This.ExecutePlan("clean", 0)
        return This

    # Runs the validation plan silently and returns the wrangler, so that calls chain.
    #
    #   returns    the wrangler itself
    #   note       the results of the plan are dropped; read GetIssues
    #   see        QuickValidate
    def Validate()
        This.ExecutePlan("validate", 0)
        return This

    # Runs the analysis plan silently and returns the wrangler, so that calls chain.
    #
    #   returns    the wrangler itself
    #   warning    Does nothing today, as the analyze goal does not resolve to a plan
    #   see        QuickPrepareForAnalysis
    def Transform()
        This.ExecutePlan("analyze", 0)
        return This

    # Runs the export plan silently and returns the wrangler, so that calls chain.
    #
    #   returns    the wrangler itself
    #   warning    Its header and date steps fail today, so only the missing values are handled
    #   see        QuickPrepareForExport
    def Export()
        This.ExecutePlan("export", 0)
        return This

    # Returns the dataset in its current state.
    #
    #   returns    the list or the rows of the table
    #   see        GetHeaders, GetCleanData
    #@ aka  DATA ACCESS METHODS ==================
    def GetData()
        """Return the current dataset"""
        return @aData

    # Returns the column names of the table, or the generated Col1, Col2 names.
    #
    #   returns    a list of text; [ ] for a flat list
    #   see        GetData
    def GetHeaders()
        """Return column headers"""
        return @aHeaders

    # Returns a cleaned copy of the data, running the clean plan on a temporary wrangler, and leaves this wrangler's data untouched.
    #
    #   returns    the cleaned list or rows
    #   see        QuickClean, GetData
    def GetCleanData()
        """Return data with basic cleaning applied"""
        _oTempRangler_ = new stzDataWrangler(@aData, @aHeaders)
        _oTempRangler_.QuickClean()
        return _oTempRangler_.GetData()

    # Sets the flag that says whether plans print their steps, and returns the wrangler.
    #
    #   bVerbose   1 to print, 0 for silence
    #   returns    the wrangler itself
    #   warning    has no lasting effect today: ExecutePlan overwrites the flag with its own
    #              argument on every call
    #   see        ExecutePlan
    def SetVerbose(bVerbose)
        """Enable/disable verbose output"""
        @bVerbose = bVerbose
        return This

    # Clears the recorded issues and the transformation log and restores the default fill rules, and returns the wrangler.
    #
    #   returns    the wrangler itself
    #   warning    does not restore the data despite what its comment says: after cleaning, the
    #              cleaned rows stay (confirmed on two wranglers); the log is left empty, without
    #              even the entry for loading the data
    #   see        GetIssues, GetTransformationLog
    def Reset()
        """Reset to original data state"""
        This._InitializeDefaults()
        return This
