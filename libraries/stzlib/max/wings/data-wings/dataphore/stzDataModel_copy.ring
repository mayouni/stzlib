#====================#
# stzDataModel class #
#====================#

# Depends on data loaded in stzDataModelData.ring

@acDataModelFieldTypes = [ "number", "string", "list", "object" ]

class stzDataModel from stzObject

    @cSchemaName
    @cSchemaVersion
    @aTables           
    @aRelations

    @cRelationInferenceMode # Can be "smart", "strict", or "permissive"
    @cValidationMode # Can be "warning", "strict", "permissive" (~> with autofixing)

    @aActiveFixPlans
    @bAutoFix
    @aStructureSnapshot
	@aValidationResult

	@bUseRelInfere

      #==================#
     #  INITIALIZATION  #
    #==================#

    def init(p)

        if isString(p)
            @cSchemaName = p
            @cSchemaVersion = "1.0"

        but isList(p) and len(p) = 2
            @cSchemaName = p[1]
            @cSchemaVersion = p[2]

        else
            @cSchemaName = "default"
            @cSchemaVersion = "1.0"
        ok

        @aTables = []
        @aRelations = []

		@aValidationResult = []
        @cRelationInferenceMode = "smart"
        @cValidationMode = "warning"  # Default validation mode
        @aActiveFixPlans = ["default"]
        @bAutoFix = True
        @aStructureSnapshot = []

		@bUseRelInfere = FALSE

      #==========================#
     #  CONFIGURATION METHODS   #
    #==========================#

    def SetRelationInferenceMode(cMode)
        @cRelationInferenceMode = cMode
        

    def SetValidationMode(cMode)
        if find( DataModelValidationModes(), cMode) > 0
            @cValidationMode = cMode
        else
            stzraise("Invalid validation mode: " + cMode)
        ok
        

    def ValidationMode()
        return @cValidationMode

		def ActiveValidationMode()
			 return @cValidationMode

    def RelationMode()
        return @cRelationInferenceMode

		def ActiveRelationMode()
        	return @cRelationInferenceMode

	def UseRelationInference()
		@bUseRelInfere = TRUE

		def UseRelInfere()
			@bUseRelInfere = TRUE

	def RelationInference()
		return @bUseRelInfere

		def RelInfere()
			return @bUseRelInfere

	def SetRelInfere(bValue)
		if CheckParams() and NOT ISBoolean(bValue)
			StzRaise("Incorrect param type! bValue must be TRUE or FALSE.")
		ok

   		@bUseRelInfere = bValue

      #=======================#
     #  SCHEMA INFORMATION   #
    #=======================#

    def SchemaName()
        return @cSchemaName

    def SchemaVersion()
        return @cSchemaVersion

    def Tables()
        return @aTables

    def Relations()
        return @aRelations

    def Name()
        return @cSchemaName

    def Version()
        return @cSchemaVersion

      #=========================#
     #  VALIDATION MANAGEMENT  #
    #=========================#

    # Get all errors (including fixed ones)

    def ErrorsXT()
        aErrors = []
		nLen = len(@aValidationResult)

		for i = 1 to nLen
            if @aValidationResult[i][:type] = "error"
                aErrors + @aValidationResult[i]
            ok
        next

        return aErrors


		def ValidationErrorsXT()
			return This.ErrorsXT()


    def Errors()
        aErrorsXT = This.ErrorsXT()
        nLen = len(aErrorsXT)

        aResult = []
        for i = 1 to nLen
            if aErrorsXT[i][:fixed] = false
                aResult + aErrorsXT[i]
            ok
        next
        return aResult

	    def ValidationErrors()
	        return This.Errors()


    def FixedErrors()
        aErrorsXT = This.ErrorsXT()
        nLen = len(aErrorsXT)

        aResult = []
        for i = 1 to nLen
            if aErrorsXT[i][:fixed] = true
                aResult + aErrorsXT[i]
            ok
        next
        return aResult


    def Warnings()
        aErrorsXT = This.ErrorsXT()
        nLen = len(aErrorsXT)

        aResult = []
        for i = 1 to nLen
            if aErrorsXT[i][:severity] = "warning"
                aResult + aErrorsXT[i]
            ok
        next
        return aResult

    def ValidationWarnings()
        return This.Warnings()


    def Validate()
        aResults = []
        nUnnamedCounter = 1
        
        nLen = len(@aTables)
        for i = 1 to nLen
            aTable = @aTables[i]
            
            # Validate table name
            nUnnamedCounter = This._ValidateTableName(aTable, i, aResults, nUnnamedCounter)
            
            # Validate field names
            This._ValidateFieldNames(aTable, i, aResults)
        next
        
        @aValidationResult = aResults
        return This._CountValidationResults(aResults)

    # internal validation methods
    def _ValidateTableName(aTable, nTableIndex, aResults, nUnnamedCounter)
        if aTable[:name] = ""
            nErrorIndex = len(aResults) + 1
            aResults + [
                :type = "error", :severity = "error", :category = "table",
                :message = "Empty table name", :table = "",
                :table_index = nTableIndex, :fixed = false
            ]
            
            if @cValidationMode = "permissive"
                newName = "unnamed_table_" + nUnnamedCounter
                @aTables[nTableIndex][:name] = newName
                
                aResults + [
                    :type = "fix", :plan = "default", :condition = "empty_table_name",
                    :description = "Renamed empty table name", :old_value = "",
                    :new_value = newName, :table_index = nTableIndex
                ]
                
                aResults[nErrorIndex][:fixed] = true
                nUnnamedCounter++
            ok
        ok
        return nUnnamedCounter

    def _ValidateFieldNames(aTable, nTableIndex, aResults)
        aFieldNames = []
        nDuplicateCounter = 1
        
        nLenF = len(aTable[:fields])
        for j = 1 to nLenF
            cOriginalName = aTable[:fields][j][:name]
            if find(aFieldNames, cOriginalName) > 0
                nErrorIndex = len(aResults) + 1
                aResults + [
                    :type = "error", :severity = "error", :category = "field",
                    :message = "Duplicate field: " + cOriginalName,
                    :table = aTable[:name], :field = cOriginalName,
                    :field_index = j, :fixed = false
                ]
                
                if @cValidationMode = "permissive"
                    newName = cOriginalName + "_" + nDuplicateCounter
                    @aTables[nTableIndex][:fields][j][:name] = newName
                    
                    aResults + [
                        :type = "fix", :plan = "default", :condition = "duplicate_field",
                        :description = "Renamed duplicate field", :old_value = cOriginalName,
                        :new_value = newName, :table = aTable[:name], :field_index = j
                    ]
                    
                    aResults[nErrorIndex][:fixed] = true
                    nDuplicateCounter++
                    aFieldNames + newName
                else
                    aFieldNames + cOriginalName
                ok
            else
                aFieldNames + cOriginalName
            ok
        next

    def _CountValidationResults(aResults)
        nErrors = 0
        nWarnings = 0
        nFixes = 0
        
        nLenR = len(aResults)
        for i = 1 to nLenR
            if aResults[i][:type] = "error"
                nErrors++
            ok
            if aResults[i][:type] = "warning"
                nWarnings++
            ok
            if aResults[i][:type] = "fix"
                nFixes++
            ok
        next
        
        return [
            :errors_count = nErrors,
            :warnings_count = nWarnings,
            :fixes_applied = nFixes,
			:tables_validated = len(@aTables),
            :active_plans = @aActiveFixPlans
        ]



	def ValidationXT()
		return @aValidationResult

		def ValidationResult()
			return @aValidationResult



    def ApplyFixes()
        if @cValidationMode != "permissive"
            ? "Fixes can only be applied in permissive mode"
            
        ok
        
        This.CreateSnapshot()
        @aAppliedFixes = []
        nLen = len(@aTables)

        for i = 1 to nLen
            aTable = @aTables[i]
            This.ApplyTableFixes(aTable, i)
            
            aFieldNames = []
            nDuplicateCounter = 1
            
			nLenF = len(table[:fields])
            for j = 1 to nLenF
                aField = aTable[:fields][j]
                
                if find(aFieldNames, aField[:name]) > 0
                    This.ApplyFieldFixes(aField, j, [ :duplicate_counter = nDuplicateCounter ])
                    nDuplicateCounter++
                ok
                
                This.ApplyFieldFixes(aField, j, [])
                aFieldNames + aField[:name]
            next
        next
        
        This.RecordFixSession()
        

    def CreateSnapshot()
        @aStructureSnapshot = []
		nLen = len(@aTables)

		for i = 1 to nLen

			aTable = @aTables[i]
            aTableCopy = [ :name = aTable[:name], :fields = [] ]

			aField = aTable[:fields]
			nLenF = len(aField)

			for j = 1 to nLenF
                aTableCopy[:fields] + [ :name = aField[:name], :type = aField[:type] ]
            next

            @aStructureSnapshot + aTableCopy
        next


    def RecordFixSession()
        if len(@aAppliedFixes) > 0
            @aFixHistory + [
                :timestamp = Timestamp(),
                :fixes = @aAppliedFixes,
                :snapshot = @aStructureSnapshot
            ]
        ok

	def FixHistory()
		return @aFixHistory

    def UndoLastFixes(nCount)
        if nCount = NULL
            nCount = 1
        ok
        
        nSessions = len(@aFixHistory)
        if nSessions = 0
            ? "No fixes to undo"
            
        ok
        
        nToUndo = min(nCount, nSessions)
        
        for i = 1 to nToUndo
            aSession = @aFixHistory[nSessions - i + 1]
            @aTables = aSession[:snapshot]
            del(@aFixHistory, nSessions - i + 1)
        next
        
        ? "Undone " + nToUndo + " fix session(s)"
        


    def AppliedFixes()
        aFixes = []
		nLen = len(@aValidationResult)

		for i = 1 to nLen
            if @aValidationResult[i][:type] = "fix"
                aFixes + @aValidationResult[i]
            ok
        next

        return aFixes


      #====================#
     #  TABLE MANAGEMENT  #
    #====================#

    def AddTable(cTableName, aFields)
		if CheckParam()
			if NOT isString(cTableName)
				StzRaise("Incorrect param type! cTableName must be a string.")
			ok

			if NOT ( isList(aFields) and IsListOfPairsOfStrings(aFields) )
				StzRaise("Incorrect param type! aFields must be a list of pairs of strings.")
			ok
		ok

        aProcessedFields = []
        nLen = len(aFields)

        for i = 1 to nLen

            if isList(aFields[i]) and len(aFields[i]) >= 2
                aProcessedFields + [ :name = aFields[i][1], :type = aFields[i][2], :constraints = [] ]

            else
                cFieldName = aFields[i]

                if isList(aFields[i])
                    cFieldName = aFields[i][1]
                ok

                aProcessedFields + [ :name = cFieldName, :type = "text", :constraints = [] ]
            ok

        next

        aTable = [ :name = cTableName, :fields = aProcessedFields ]
        @aTables + aTable

		if @bUseRelInfere
        	This.InferRelationsForTable(aTable)
		ok
        

	def IsValidTableName(cTableName)

		bResult = FALSE
        nLen = len(@aTables)

        for i = 1 to nLen
            if @aTables[i][:name] = cTableName
                bResult = TRUE
				exit
            ok
        next

        return bResult


		def TableNameExists(cTableName)
			return This.IsValidTableName(cTableName)

    def Table(cTableName)

        nLen = len(@aTables)

        for i = 1 to nLen
            if @aTables[i][:name] = cTableName
                return @aTables[i]
            ok
        next

        stzraise("Table not found: " + cTableName)


    def TablesNames()

        acNames = []
        nLen = len(@aTables)

        for i = 1 to nLen
            acNames + @aTables[i][:name]
        next

        return acNames


    def CountTables()
        return len(@aTables)

    def NumberOfTables()
        return len(@aTables)


    def CountFields()

        nResult = 0
        nLen = len(@aTables)

        for i = 1 to nLen
            nResult += len(@aTables[i][:fields])
        next

        return nResult


    def NumberOfFields()
        return This.CountFields()


    def TableExists(cTableName)
        nLen = len(@aTables)

        for i = 1 to nLen
            if @aTables[i][:name] = cTableName
                return TRUE
            ok
        next

        return FALSE


    def FindTable(cTableName)
		nLen = len(@aTables)

		for i = 1 to nLen
            if @aTables[i][:name] = cTableName
                return @aTables[i]
            ok
        next

        return stzraise("Inexistant table name!")


      #====================#
     #  FIELD MANAGEMENT  #
    #====================#

    def AddField(cTableName, cFieldName, cFieldType, aOptions)

        if aOptions = NULL
            aOptions = []
        ok

        nTableIndex = 0
		nLen = len(@aTables)

        for i = 1 to nLen

            if @aTables[i][:name] = cTableName
                nTableIndex = i
                exit
            ok

        next


        if nTableIndex = 0
            stzraise("Table '" + cTableName + "' not found")
        ok


        aFieldHashlist = [
            :name = cFieldName,
            :type = This.ProcessFieldType(cFieldType),
            :options = aOptions,
            :constraints = []
        ]


        @aTables[nTableIndex][:fields] + aFieldHashlist
        return This.AnalyzeFieldAdditionImpact(cTableName, cFieldName, cFieldType, aOptions)


    def RemoveField(cTableName, cFieldName)

        aTable = This.Table(cTableName)
        aImpact = This.AnalyzeFieldRemovalImpact(cTableName, cFieldName)


        if aImpact[:breaking_changes] > 0

            cReasons = ""
            aBreakingReasons = aImpact[:breaking_reasons]
            nLen = len(aBreakingReasons)

            for i = 1 to nLen
                cReasons += aBreakingReasons[i]
                if i < nLen
                    cReasons += ", "
                ok
            next

            stzraise("Breaking change prevented: Cannot remove field '" + cFieldName + "' - " + cReasons)
        ok

        aNewFields = []
        aFields = aTable[:fields]
        nLen = len(aFields)

        for i = 1 to nLen

            aField = aFields[i]

            if aField[:name] != cFieldName
                aNewFields + aField
            ok

        next


        aTable[:fields] = aNewFields
        This.RemoveRelationsForField(cTableName, cFieldName)
        return aImpact


    def FieldExists(aTable, cFieldName)

        aFields = aTable[:fields]
        nLen = len(aFields)

        for i = 1 to nLen

            aField = aFields[i]

            if aField[:name] = cFieldName
                return TRUE
            ok

        next

        return FALSE


    def FieldFromTable(aTable, cFieldName)

        aFields = aTable[:fields]
        nLen = len(aFields)

        for i = 1 to nLen

            aField = aFields[i]

            if aField[:name] = cFieldName
                return aField
            ok

        next

        stzraise("Inexistant field!")


    def TableFields(cTableName)
        aTable = This.Table(cTableName)
        return aTable[:fields]


    def FieldsForTable(cTableName)
        return This.TableFields(cTableName)


    def FieldsInTable(cTableName)
        return This.TableFields(cTableName)


    def CountTableFields(cTableName)
        return len(This.TableFields(cTableName))


    def CountFieldsForTable(cTableName)
        return This.CountTableFields(cTableName)


    def CountFieldsInTable(cTableName)
        return This.CountTableFields(cTableName)


    def TableFieldsXT(cTableName)
        return This.TableFields(cTableName)


      #=======================#
     #  Relation MANAGEMENT  #
    #=======================#

	# Helper method to check if relation exists
	def RelationExists(cType, cFrom, cTo, cField)
	    nLen = len(@aRelations)
	    for i = 1 to nLen
	        aExisting = @aRelations[i]
	        if aExisting[:type] = cType and
	           aExisting[:from] = cFrom and
	           aExisting[:to] = cTo and
	           aExisting[:field] = cField
	            return true
	        ok
	    next
	    return false


	def Link(cType, cFromTable, cToTable, aOptions)

		if @bUseRelInfere
			StzRaise("Can't define relations when automatic inference is activated! Use SetRelationInference(FALSE) and try again.")
		ok

		if CheckParams()

			if NOT isString(cType)
				StzRaise("Incorrect param type! cType must be a string.")
			ok
	
			if isString(aOptions) and aOptions = NULL
				aOptions = []
			ok
	
			if not isList(aOptions)
				StzRaise("Incorrect param type! aOptions must be a list.")
			ok
	
			if len(aOptions) = 2 and isString(aOptions[1]) and
			   (aOptions[1] = "via" or aOptions[1] = "using") and
			   isString(aOptions[2])

				aTemp = []
				aTemp + [ "field", aOptions[2]]
				aOptions = aTemp
			ok
	
			if isList(cFromTable) and StzListQ(cFromTable).IsFromNamedParam()
				cFromTable = cFromTable[2]
			ok
	
			if NOT isString(cFromTable)
				StzRaise("Incorrect param type! cFromTable must be a string.")
			ok
	
			if isList(cToTable) and StzListQ(cToTable).IsToNamedParam()
				cToTable = cToTable[2]
			ok
	
			if NOT isString(cToTable)
				StzRaise("Incorrect param type! cToTable must be a string.")
			ok
		ok

		# Checking tables names

		if NOT This.IsValidTableName(cFromTable)
			StzRaise("Invalid table name (" + cFromTable + ")!")
		ok

		if NOT This.IsValidTableName(cToTable)
			StzRaise("Invalid table name (" + cToTable + ")!")
		ok

		# Doing the job

	    cField = iff(HasKey(aOptions, :field), aOptions[:field], "")
	    if not This.RelationExists(cType, cFromTable, cToTable, cField)
	        aStandardRelation = [
	            [ "type", cType ],
	            [ "from", cFromTable ],
	            [ "to", cToTable ],
	            [ "field", cField ],
	            [ "inferred", 0 ]
	        ]
	        @aRelations + aStandardRelation
	    ok


	def AddRelation(cFromTable, cToTable, cType, aOptions)
	    This.Link(cFromTable, cToTable, cType, aOptions)


	def Hierarchy(cTable, aOptions)
	    if aOptions = NULL
	        aOptions = [:parent_field = "parent_id"]
	    ok
	    cField = iff(HasKey(aOptions, :parent_field), aOptions[:parent_field], "parent_id")
	    if not This.RelationExists("hierarchy", cTable, cTable, cField)
	        aStandardRelation = [
	            [ "type", "hierarchy" ],
	            [ "from", cTable ],
	            [ "to", cTable ],
	            [ "field", cField ],
	            [ "inferred", 0 ]
	        ]
	        @aRelations + aStandardRelation
	    ok
        

	def Network(cTable, cRelationName, aOptions)
	    if aOptions = NULL
	        aOptions = [:bidirectional = TRUE]
	    ok
	    cField = iff(HasKey(aOptions, :field), aOptions[:field], "")
	    if not This.RelationExists("network", cTable, cTable, cField)
	        aStandardRelation = [
	            [ "type", "network" ],
	            [ "from", cTable ],
	            [ "to", cTable ],
	            [ "field", cField ],
	            [ "inferred", 0 ]
	        ]
	        @aRelations + aStandardRelation
	    ok


	def InferRelationsForTable(aTable)
	    aFields = aTable[:fields]
	    nLen = len(aFields)
	    for i = 1 to nLen
	        aField = aFields[i]
	        cFieldName = aField[:name]
	        if right(cFieldName, 3) = "_id" and cFieldName != "id"
	            cRelatedTableSingular = left(cFieldName, len(cFieldName) - 3)
	            cRelatedTable = PluralOf(cRelatedTableSingular)
	            if This.TableExists(cRelatedTable)
	                if not This.RelationExists("belongs_to", aTable[:name], cRelatedTable, cFieldName)
	                    aStandardRelation = [
	                        [ "type", "belongs_to" ],
	                        [ "from", aTable[:name] ],
	                        [ "to", cRelatedTable ],
	                        [ "field", cFieldName ],
	                        [ "inferred", 1 ]
	                    ]
	                    @aRelations + aStandardRelation
	                ok
	                if not This.RelationExists("has_many", cRelatedTable, aTable[:name], cFieldName)
	                    aStandardRelation = [
	                        [ "type", "has_many" ],
	                        [ "from", cRelatedTable ],
	                        [ "to", aTable[:name] ],
	                        [ "field", cFieldName ],
	                        [ "inferred", 1 ]
	                    ]
	                    @aRelations + aStandardRelation
	                ok
	            ok
	        ok
	    next


    def RemoveRelationsForField(cTableName, cFieldName)

        aNewRelations = []
        nLen = len(@aRelations)

        for i = 1 to nLen

            aRel = @aRelations[i]
            bKeep = TRUE

            if HasKey(aRel, :field) and aRel[:field] = cFieldName and aRel[:from] = cTableName
                bKeep = FALSE
            ok

            if bKeep
                aNewRelations + aRel
            ok

        next

        @aRelations = aNewRelations


    def CountRelationsForTable(cTableName)

        nCount = 0
        nLen = len(@aRelations)

        for i = 1 to nLen
            if @aRelations[i][:from] = cTableName or @aRelations[i][:to] = cTableName
                nCount++
            ok
        next

        return nCount


    def SelfReferencingTables()

        aResult = []
        nLen = len(@aRelations)

        for i = 1 to nLen

            if @aRelations[i][:from] = @aRelations[i][:to]
                aResult + [
                    :table = @aRelations[i][:from],
                    :type = @aRelations[i][:type]
                ]
            ok

        next

        return aResult

      #===================#
     #  IMPACT ANALYSIS  #
    #===================#

    def AnalyzeFieldAdditionImpact(cTableName, cFieldName, cFieldType, aOptions)

        aRecommendations = []
        cPerfImpact = "minimal"

        if cFieldType = :text or cFieldType = "text"
            aRecommendations + "Large text fields may impact query performance"
            cPerfImpact = "low"

        but cFieldType = :decimal
            aRecommendations + "Consider indexing decimal fields used in calculations"

        but cFieldType = :foreign_key or right(cFieldName, 3) = "_id"
            aRecommendations + "Foreign key fields should be indexed for performance"
            cPerfImpact = "low"
        ok

        return [

            :breaking_changes = 0,
            :perf_impact = cPerfImpact,
            :migration_complexity = "simple",
            :affected_Relations = [],
            :recommendations = aRecommendations,
            :field_info = [
                :table = cTableName,
                :field = cFieldName,
                :type = cFieldType
            ]

        ]


    def AnalyzeFieldRemovalImpact(cTableName, cFieldName)

        aImpact = [
            :breaking_changes = 0,
            :affected_Relations = [],
            :migration_complexity = "simple",
            :breaking_reasons = []
        ]

        aTable = This.Table(cTableName)
        aField = This.FieldFromTable(aTable, cFieldName)

        if aField = NULL
            return aImpact
        ok

        if HasKey(aField, :is_primary_key) and aField[:is_primary_key]
            aImpact[:breaking_changes]++
            aImpact[:breaking_reasons] + "field is primary key"
            aImpact[:migration_complexity] = "complex"
        ok

        nLen = len(@aRelations)

        for i = 1 to nLen

            aRel = @aRelations[i]

            if HasKey(aRel, :field) and aRel[:field] = cFieldName and aRel[:from] = cTableName
                aImpact[:breaking_changes]++
                aImpact[:breaking_reasons] + "breaks Relation with " + aRel[:to]
                aImpact[:affected_Relations] + aRel
                aImpact[:migration_complexity] = "complex"
            ok

        next

        return aImpact


      #========================#
     #  REPORTING AND EXPORT  #
    #========================#

    def SummaryXT()

        aTables = []
        nLen = len(@aTables)

        for i = 1 to nLen

            aTable = @aTables[i]

            aTableData = [
                :name = aTable[:name],
                :field_count = len(aTable[:fields]),
                :Relation_count = This.CountRelationsForTable(aTable[:name]),
                :fields = aTable[:fields]
            ]

            aTables + aTableData

        next

        return [

            :schema = [
                :name = @cSchemaName,
                :version = @cSchemaVersion
            ],

            :tables = aTables,
            :Relations = @aRelations,

            :stats = [
                :table_count = len(@aTables),
                :total_fields = This.CountFields(),
                :Relation_count = len(@aRelations)
            ]

        ]


    def Summary()

        aSummary = [
            [ "name", @cSchemaName ],
            [ "version", "1.0" ],
            [ "tablescount", len(@aTables) ],
            [ "tables", [] ]
        ]

		nLen = len(@aTables)
		for i = 1 to nLen
        	aTable = @aTables[i]

            cTableName = aTable[:name]
            nFieldsCount = len(aTable[:fields])
            nRelationsCount = This.CountRelationsForTable(cTableName)

            aSummary[4][2] + [
                [
                    cTableName,
                    [
                        [ "fieldscount", nFieldsCount ],
                        [ "relationscount", nRelationsCount ]
                    ]
                ]
            ]

        next

        return aSummary


    def TextSummary()

        nLen = len(@aTables)
		if nLen = 0
			return "The model contains no tables at all!"
		ok

        cText = "This model contains " + nLen + " table(s):" + nl

        for i = 1 to nLen

            aTable = @aTables[i]
            cTableName = aTable[:name]
            nFields = len(aTable[:fields])
            nRelations = This.CountRelationsForTable(cTableName)
            cText += "• " + cTableName + ": " + nFields + " field(s), " + nRelations + " Relation(s)"
			if i < nLen
				cText += NL
			ok

        next

        nLen = len(@aRelations)

		if nLen > 0
			cText += NL + NL + "Key Relations:" + nl
	        for i = 1 to nLen
	            aRel = @aRelations[i]
	            cText += "• " + aRel[:from] + " " + aRel[:type] + " " + aRel[:to]
				if i < nLen
					cText += NL
				ok
	        next
		ok

        return cText


    def DiagramData()

        aEntities = []
        aRelations = []
		nLen = len(@aTables)

		for i = 1 to nLen
        	aTable = @aTables[i]
            aFields = []

			nLenF = len(aTable[:fields])

			for j = 1 to nLenF
            	aField = aTable[:fields][j]

                aFieldInfo = [
                    :name = aField[:name],
                    :type = aField[:type],
                    :is_primary = (aField[:type] = "integer" and aField[:name] = "id"),
                    :is_foreign = (right(aField[:name], 3) = "_id" and aField[:name] != "id"),
                    :nullable = !(HasKey(aField, :is_required) and aField[:is_required]),
                    :unique = (HasKey(aField, :is_unique) and aField[:is_unique])
                ]
                aFields + aFieldInfo
            next

            aEntity = [
                :name = aTable[:name],
                :display_name = Capitalize(aTable[:name]),
                :fields = aFields,
                :field_count = len(aFields),
                :type = "entity"
            ]
            aEntities + aEntity

        next

        aProcessedRels = []
		nLenR = len(@aRelations)

		for i = 1 to nLenR
        	aRel = @aRelations[i]

            cRelKey = aRel[:from] + "->" + aRel[:to] + ":" + aRel[:type]

            if find(aProcessedRels, cRelKey) = 0

                aProcessedRels + cRelKey

                aRelation = [
                    :id = "rel_" + len(aRelations) + 1,
                    :from_entity = aRel[:from],
                    :to_entity = aRel[:to],
                    :Relation_type = aRel[:type],
                    :cardinality = This.GetCardinality(aRel[:type]),
                    :foreign_key = iff(HasKey(aRel, :field), aRel[:field], ""),
                    :is_identifying = (aRel[:type] = "belongs_to"),
                    :label = This.GetRelationLabel(aRel[:type])
                ]

                aRelations + aRelation
            ok

        next

        return [
            :schema_name = @cSchemaName,
            :entities = aEntities,
            :Relations = aRelations,
            :metadata = [
                :entity_count = len(aEntities),
                :Relation_count = len(aRelations),
                :generated_at = date() + " " + time(),
                :format_version = "1.0"
            ]
        ]


    def ERDData()
        return This.DiagramData()

    def ERD()
        return This.DiagramData()

    def ToERD()
        return This.DiagramData()

    def ToMermaidERD()

        cMermaid = "erDiagram" + nl
        aDiagramData = This.DiagramData()
        aEntities = aDiagramData[:entities]
        nLen = len(aEntities)

        for i = 1 to nLen

            aEntity = aEntities[i]
            cMermaid += "    " + aEntity[:name] + " {" + nl
            aFields = aEntity[:fields]
            nLenF = len(aFields)

            for j = 1 to nLenF

                aField = aFields[j]
                cFieldDef = "        " + aField[:type] + " " + aField[:name]

                if aField[:is_primary]
                    cFieldDef += " PK"

                but aField[:is_foreign]
                    cFieldDef += " FK"
                ok

                if !aField[:nullable]
                    cFieldDef += " NOT NULL"
                ok

                cMermaid += cFieldDef + nl

            next

            cMermaid += "    }" + nl + nl

        next

        aRels = aDiagramData[:Relations]
        nLen = len(aRels)

        for i = 1 to nLen

            aRel = aRels[i]

            if aRel[:from_entity] != aRel[:to_entity]
                cMermaid += "    " + aRel[:from_entity] + " ||--o{ " + aRel[:to_entity] + ' : "' + aRel[:label] + '"' + nl
            ok

        next

        return cMermaid


    def ToJSONERD()

        cJSON = "{" + nl
        cJSON += TAB + '"tables": [' + nl
        nLen = len(@aTables)

        for i = 1 to nLen

            aTable = @aTables[i]
            cJSON += TAB + TAB + "{" + nl
            cJSON += TAB + TAB + TAB + '"name": "' + aTable[:name] + '",' + nl
            cJSON += TAB + TAB + TAB + '"fields": [' + nl

            aFields = aTable[:fields]
            nLenF = len(aFields)

            for j = 1 to nLenF

                aField = aTable[:fields][j]
                cJSON += TAB + TAB + TAB + TAB + "{" + nl
                cJSON += TAB + TAB + TAB + TAB + TAB + '"name": "' + aField[:name] + '",' + nl
                cJSON += TAB + TAB + TAB + TAB + TAB + '"type": "' + aField[:type] + '"' + nl
                cJSON += TAB + TAB + TAB + TAB + "}"

                if j < nLenF
                    cJSON += ","
                ok

                cJSON += nl

            next

            cJSON += TAB + TAB + TAB + "]" + nl
            cJSON += TAB + TAB + "}"

            if i < nLen
                cJSON += ","
            ok

            cJSON += nl

        next

        cJSON += TAB + "]," + nl
        cJSON += TAB + '"Relations": [' + nl
        nLenR = len(@aRelations)

        for i = 1 to nLenR

            aRel = @aRelations[i]
            cJSON += TAB + TAB + "{" + nl
            cJSON += TAB + TAB + TAB + '"from_table": "' + aRel[:from] + '",' + nl
            cJSON += TAB + TAB + TAB + '"to_table": "' + aRel[:to] + '"' + nl
            cJSON += TAB + TAB + "}"

            if i < nLenR
                cJSON += ","
            ok

            cJSON += nl

        next

        cJSON += TAB + "]" + nl
        cJSON += "}"

        return cJSON


      #===================#
     #  TEMPLATE SYSTEM  #
    #===================#

    def UseTemplate(cTemplateName)

	    aTemplate = FindTemplateByName(cTemplateName)
	    if aTemplate = NULL
	        stzraise("Unknown template: " + cTemplateName)
	    ok
	
	    # Apply tables
	    aTables = aTemplate[2][1][2]  # Get tables array
		nLen = len(aTables)

		for i = 1 to nLen
	        cTableName = aTables[i][1]
	        aColumns = aTables[i][2]
	        This.AddTable(cTableName, aColumns)
	    next
	
	    # Apply relations
	    aRelations = aTemplate[2][2][2]  # Get relations array
		nLen = len(aRelations)

		for i = 1 to nLen
	        cFromTable = aRelations[i][1]
	        cToTable = aRelations[i][2][1]
	        cRelationType = aRelations[i][2][2]
	        aOptions = aRelations[i][2][3]
	        This.Link(cFromTable, cToTable, cRelationType, aOptions)
	    next


      #===================#
     #  UTILITY METHODS  #
    #===================#

    def ProcessFieldType(cType)
        switch cType

        on :primary_key
            return "integer"

        on :required
            return "varchar(255)"

        on :email
            return "varchar(255)"

        on :timestamp
            return "timestamp"

        on :decimal
            return "decimal(10,2)"

        on :text
            return "text"

        on :boolean
            return "boolean"

        on :url
            return "varchar(500)"

        on :foreign_key
            return "integer"

        on :unique
            return "varchar(255)"

        other
            return cType
        off


    def TableNameFromReference(cReferenceField)

        if cReferenceField = "parent_id"
            return ""
        ok

        if right(cReferenceField, 3) = "_id"
            cBaseName = left(cReferenceField, len(cReferenceField) - 3)
            return cBaseName
        ok

        return ""


    def FindInList(aList, cItem)
		nLen = len(aList)

        for i = 1 to nLen

            if aList[i] = cItem
                return i
            ok

        next

        return 0


    def ClearModel()

        @aTables = []
        @aRelations = []
        @aValidationErrors = []


    def GetCardinality(cRelType)

        switch cRelType
        on "has_many"
            return "1:N"

        on "belongs_to"
            return "N:1"

        on "has_one"
            return "1:1"

        on "many_to_many"
            return "M:N"

        other
            return "1:N"
        off


    def GetRelationLabel(cRelType)

        switch cRelType
        on "has_many"
            return "has"

        on "belongs_to"
            return "belongs to"

        on "has_one"
            return "has one"

        on "many_to_many"
            return "associated with"

        other
            return cRelType
        off


	def Help()
		return $cDataModelHelp


	def HelpXT()
		return $cDataModelHelp + NL + $cDataModelHelpXT


      #================================================#
     #  FIX MANAGEMENT IN PERMISSIVE VALIDATION MODE  #
	#================================================#

    def SetAutoFix(lEnabled)
        @bAutoFix = lEnabled
        


    def LoadFixPlan(cPlan)
        if find(@aActiveFixPlans, cPlan) = 0
            @aActiveFixPlans + cPlan
        ok
        


    def LoadFixPlans(aPlans)
        @aActiveFixPlans = aPlans
        


    def GetActiveFixPlans()
        return @aActiveFixPlans


    def DetectRequiredFixPlans()
        aRequired = ["default"]
        
        # Analyze structure to suggest fix plans
		nLen = len(@aTables)

		for i = 1 to nLen
        	aTable = @aTables[i]

            if This.HasReservedKeywords(aTable)
                if find(aRequired, "database") = 0
                    aRequired + "database"
                ok
            ok
            
            if This.HasSnakeCaseNames(aTable)
                if find(aRequired, "api") = 0
                    aRequired + "api"
                ok
            ok
            
            if This.HasWhitespaceNames(aTable)
                if find(aRequired, "import") = 0
                    aRequired + "import"
                ok
            ok

        next
        
        return aRequired


    def AutoLoadFixPlans()
        aRequired = This.DetectRequiredFixPlans()
        @aActiveFixPlans = aRequired
        

  	  #---------------------------#
     #  Analysis helper methods  #
	#---------------------------#

    def HasReservedKeywords(aTable)

        aKeywords = [ "select", "from", "where", "table", "index" ]

        if find(aKeywords, lower(aTable[:name])) > 0
            return True
        ok

		nLen = len(aTable[:fields])

		for i = 1 to nLen
        	aField = aTable[:fields][i]

            if find(aKeywords, lower(aField[:name])) > 0
                return True
            ok

        next

        return False


    def HasSnakeCaseNames(aTable)

        if This.IsSnakeCase(aTable[:name])
            return True
        ok

		nLen = len(aTable[:fields])

		for i = 1 to nLen
        	Field = aTable[:fields][i]

            if This.IsSnakeCase(aField[:name])
                return True
            ok

        next

        return False


    def HasWhitespaceNames(aTable)

        if This.HasWhitespace(aTable[:name])
            return True
        ok

		nLen = len(aTable[:fields])

		for i = 1 to nLen
        	aField = aTable[:fields][i]
            if This.HasWhitespace(aField[:name])
                return True
            ok
        next

        return False

	  #------------------------------#
	 #  Validation utility methods  #
	#------------------------------#

    def SanitizeTableName(cName)
        return "tbl_" + cName


    def IsReservedKeyword(cName)
        aKeywords = ["select", "from", "where", "table", "index"]
        return find(aKeywords, lower(cName)) > 0


    def IsValidFieldName(cName)
        return len(cName) > 0 and not This.HasSpecialChars(cName)

	def IsValidFieldList(aList)
		# Example
		# [
		#   [ "id", "integer" ],
		#   [ "name", "string" ],
		#   [ "age", "integer" ]
		# ]

		if not isList(aList)
			return false
		ok

		if not IsHashListOfStrings(aList)
			return false
		ok

		acValues = StzHashListQ(aList).Values()
		nLen = len(acValues)

		acTypes = This.FieldsTypes()
		bResult = TRUE

		for i = 1 to nLen
			if find(acTypes, acValues[i]) = 0
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def IsFieldList(aList)
			return This.IsValidFieldList(aList)

	def FieldsTypes()
		return @acDataModelFieldTypes

    def SanitizeFieldName(cName)
        return This.RemoveSpecialChars(cName)


    def IsSnakeCase(cName)
        return substr(cName, "_") > 0 and cName = lower(cName)


    def ToCamelCase(cName)
        if substr(cName, "_") > 0

            aParts = @split(cName, "_")
            cResult = aParts[1]
			nLen = len(aParts)

            for i = 2 to nLen
                cResult += upper(aParts[i][1]) + @substr(aParts[i], 2, len(aParts[i]))
            next

            return cResult

        else
            return lower(cName[1]) + @substr(cName, 2, len(cName))
        ok


    def HasSpecialChars(cName)
        return substr(cName, " ") > 0 or substr(cName, "-") > 0 or substr(cName, ".") > 0


    def RemoveSpecialChars(cName)
        cResult = cName
        cResult = substr(cResult, " ", "_")
        cResult = substr(cResult, "-", "_")
        cResult = substr(cResult, ".", "_")
        return cResult


    def HasWhitespace(cName)
        return substr(cName, " ") > 0 or substr(cName, "\t") > 0


    def ReplaceWhitespace(cName, cReplacement)
        cResult = substr(cName, " ", cReplacement)
        cResult = substr(cResult, "\t", cReplacement)
        return cResult
