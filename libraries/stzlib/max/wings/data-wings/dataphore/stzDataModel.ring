#----------------------#
#  stzDataModel class  #
#----------------------#


class stzDataModel from stzObject

	@cSchemaName
	@cSchemaVersion
	@aTables           
	@aRelationships
	@aConstraints
	@aPerfHints
	@aValidationErrors
	@cForeignKeyMode # Can be "smart", "strict", or "permissive"
	@cActivePerfPlan

	@oPerfEngine 
	@cActivePerfPlan  
	
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
		@aRelationships = []
		@aConstraints = []
		@aPerfHints = []
		@aValidationErrors = []
		@cForeignKeyMode = "smart"
		@cActivePerfPlan = "default"

		@oPerfEngine = new stzDataPerfEngine()
		@cActivePerfPlan = "default"

	# Configuration methods
	def SetForeignKeyInferenceMode(cMode)
		@cForeignKeyMode = cMode
		return This

	def FKMode()
		return @cForeignKeyMode

	# Core getters - return pure data
	def SchemaName()
		return @cSchemaName

	def SchemaVersion()
		return @cSchemaVersion

	def Tables()
		return @aTables

	def Relations()
		return @aRelationships

	def Constraints()
		return @aConstraints

	def ValidationErrors()
		This.Validate()
		return @aValidationErrors

	#===================================#
	#  Table management with hashlists  #
	#===================================#

    # Add a table with field definitions (can be names or [name, type] pairs)
    def AddTable(cTableName, aFields)

        aProcessedFields = []
		nLen = len(aFields)

		for i = 1 to nLen

            if isList(aFields[i]) and len(aFields[i]) >= 2

                # Handle [fieldname, type] format
                aProcessedFields + [ :name = aFields[i][1], :type = aFields[i][2], :constraints = [] ]

                # Auto-add constraints based on type
                if aFields[i][2] = :primary_key
                    This.AddConstraint(cTableName, aFields[i][1], "PRIMARY KEY")

                but aFields[i][2] = :required
                    This.AddConstraint(cTableName, aFields[i][1], "NOT NULL")

                but aFields[i][2] = :email
                    This.AddConstraint(cTableName, aFields[i][1], "CHECK (email LIKE '%@%')")

                but isString(aFields[i][2]) and substr(upper(aFields[i][2]), "VARCHAR") > 0
                    # VARCHAR constraint already embedded in type

                ok

            else

                # Handle simple field name
                cFieldName = aFields[i]

                if isList(aFields[i])
                    cFieldName = aFields[i][1]
                ok

                aProcessedFields + [ :name = cFieldName, :type = "text", :constraints = [] ]

            ok

        next
        
        aTable = [ :name = cTableName, :fields = aProcessedFields ]
        @aTables + aTable
        
        # Auto-infer relationships for this table
        This.InferRelationshipsForTable(aTable)
        return This



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


    def Link(cFromTable, cToTable, cType, aOptions)

        if aOptions = NULL
            aOptions = []
        ok
        
        aRelationship = [
            :from = cFromTable,
            :to = cToTable,
            :type = cType,
            :inferred = FALSE,
            :options = aOptions
        ]

        @aRelationships + aRelationship
        return This

    def Hierarchy(cTable, aOptions)

        if aOptions = NULL
            aOptions = [:parent_field = "parent_id"]
        ok
        
        # Hierarchy is a self-referencing relationship
        aRelationship = [
            :from = cTable,
            :to = cTable,
            :type = "hierarchy",
            :inferred = FALSE,
            :options = aOptions,
            :semantic_meaning = "Each " + SingularOf(cTable) + " can have a parent and multiple children, forming a tree structure"
        ]

        @aRelationships + aRelationship
        return This


    def Network(cTable, cRelationName, aOptions)

        if aOptions = NULL
            aOptions = [:bidirectional = TRUE]
        ok
        
        aRelationship = [
            :from = cTable,
            :to = cTable,
            :type = "network",
            :name = cRelationName,
            :inferred = FALSE,
            :options = aOptions
        ]

        @aRelationships + aRelationship

        return This

	# Field management with hashlists

	def AddField(cTableName, cFieldName, cFieldType, aOptions)

		if aOptions = NULL
			aOptions = []
		ok

		aTable = This.Table(cTableName)
		if aTable = NULL
			stzraise("Table '" + cTableName + "' not found")
		ok

		# Check if field already exists
		if This.FieldExists(aTable, cFieldName)
			stzraise("Field '" + cFieldName + "' already exists in table '" + cTableName + "'")
		ok

		# Create field hashlist
		aFieldHashlist = [
			:name = cFieldName,
			:type = This.ProcessFieldType(cFieldType),
			:options = aOptions,
			:is_primary_key = (cFieldType = :primary_key),
			:is_required = (cFieldType = :required or cFieldType = :primary_key),
			:is_unique = (cFieldType = :unique or cFieldType = :primary_key)
		]

		# Add to table's fields
		aTable[:fields] + aFieldHashlist

		# Handle foreign key inference - this will add relationships
		if cFieldType = :foreign_key or right(cFieldName, 3) = "_id"
			This.InferRelationsFromFK(cTableName, cFieldName)
		ok

		return This.AnalyzeFieldAdditionImpact(cTableName, cFieldName, cFieldType, aOptions)


	def RemoveField(cTableName, cFieldName)

		aTable = This.Table(cTableName)
		
		# Analyze impact before removal

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

		# Remove field from table
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

		# Remove related relationships
		This.RemoveRelationshipsForField(cTableName, cFieldName)
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


	def InferRelationshipsForTable(aTable)

		aFields = aTable[:fields]
		nLen = len(aFields)

		for i = 1 to nLen

			aField = aFields[i]
			cFieldName = aField[:name]

			# Check if it's a foreign key field

			if right(cFieldName, 3) = "_id" and cFieldName != "id"

				cRelatedTableSingular = left(cFieldName, len(cFieldName) - 3)
				cRelatedTable = PluralOf(cRelatedTableSingular)
				
				# Only add relationship if target table exists

				if This.TableExists(cRelatedTable)

					# Add belongs_to relationship

					@aRelationships + [

						:type = "belongs_to",
						:from = aTable[:name],
						:to = cRelatedTable,
						:field = cFieldName,
						:inferred = TRUE
					]
					
					# Add corresponding has_many relationship

					@aRelationships + [
						:type = "has_many",
						:from = cRelatedTable,
						:to = aTable[:name],
						:field = cFieldName,
						:inferred = TRUE
					]

				ok
			ok
		next


	def InferRelationsFromFK(cFromTable, cForeignKeyField)

		cReferencedTableSingular = This.TableNameFromFK(cForeignKeyField)
		cReferencedTable = PluralOf(cReferencedTableSingular)
		
		if cReferencedTable != "" and This.TableExists(cReferencedTable)

			@aRelationships + [
				:from = cFromTable,
				:to = cReferencedTable,
				:type = "belongs_to",
				:inferred = TRUE,
				:field = cForeignKeyField
			]

			@aRelationships + [
				:from = cReferencedTable,
				:to = cFromTable,
				:type = "has_many",
				:inferred = TRUE,
				:field = cForeignKeyField
			]
		ok


	def RemoveRelationshipsForField(cTableName, cFieldName)

		aNewRelationships = []
		nLen = len(@aRelationships)

		for i = 1 to nLen

			aRel = @aRelationships[i]
			bKeep = TRUE

			if HasKey(aRel, :field) and aRel[:field] = cFieldName and aRel[:from] = cTableName
				bKeep = FALSE
			ok

			if bKeep
				aNewRelationships + aRel
			ok

		next

		@aRelationships = aNewRelationships


	def AnalyzeFieldAdditionImpact(cTableName, cFieldName, cFieldType, aOptions)

		aRecommendations = []
		cPerfImpact = "minimal"
		
		# Analyze based on field type
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
			:affected_relationships = [],
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
			:affected_relationships = [],
			:migration_complexity = "simple",
			:breaking_reasons = []
		]
		
		aTable = This.Table(cTableName)
		aField = This.FieldFromTable(aTable, cFieldName)
		
		if aField = NULL
			return aImpact
		ok
		
		# Check if it's a primary key
		if HasKey(aField, :is_primary_key) and aField[:is_primary_key]

			aImpact[:breaking_changes]++
			aImpact[:breaking_reasons] + "field is primary key"
			aImpact[:migration_complexity] = "complex"
		ok
		
		# Check relationships

		nLen = len(@aRelationships)

		for i = 1 to nLen

			aRel = @aRelationships[i]

			if HasKey(aRel, :field) and aRel[:field] = cFieldName and aRel[:from] = cTableName
				aImpact[:breaking_changes]++
				aImpact[:breaking_reasons] + "breaks relationship with " + aRel[:to]
				aImpact[:affected_relationships] + aRel
				aImpact[:migration_complexity] = "complex"
			ok

		next
		
		return aImpact

	# Summary and reporting methods

	def SummaryXT()

		aTables = []
		nLen = len(@aTables)

		for i = 1 to nLen

			aTable = @aTables[i]

			aTableData = [
				:name = aTable[:name],
				:field_count = len(aTable[:fields]),
				:relationship_count = This.CountRelationshipsForTable(aTable[:name]),
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
			:relationships = @aRelationships,

			:stats = [
				:table_count = len(@aTables),
				:total_fields = This.CountFields(),
				:relationship_count = len(@aRelationships)
			]
		]


	def Summary()

		aTablesInfo = []
		nLen = len(@aTables)

        for i = 1 to nLen

			aTable = @aTables[i]
            cTableName = aTable[:name]
            nFields = len(aTable[:fields])

            nRelations = This.CountRelationshipsForTable(cTableName)
            aTableInfo = [ cTableName, [ [ "fieldscount", nFields ], [ "relationscount", nRelations ] ] ]
            aTablesInfo + aTableInfo

        next

        return [
            [ "name", This.SchemaName() ],
            [ "version", This.SchemaVersion() ],
            [ "tablescount", This.CountTables() ],
            [ "tables", aTablesInfo ]
        ]


	def Explain()

		nLen = len(@aTables)
		cText = "This model contains " + nLen + " tables:" + nl
		
        for i = 1 to nLen

			aTable = @aTables[i]

            cTableName = aTable[:name]
            nFields = len(aTable[:fields])
            nRelations = This.CountRelationshipsForTable(cTableName)

            cText += "• " + cTableName + ": " + nFields + " fields, " + nRelations + " relationships" + nl

        next

        cText += NL + "Key relationships:" + nl

		nLen = len(@aRelationships)

        for i = 1 to nLen
			aRel = @aRelationships[i]
            cText += "• " + aRel[:from] + " " + aRel[:type] + " " + aRel[:to] + nl
        next

        return cText

	def Name()
		return @cSchemaName

	def Version()
		return @cSchemaVersion

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
		return This.TableFields(cTableName)  # Already returns hashlists

	def CountRelationshipsForTable(cTableName)

		nCount = 0
		nLen = len(@aRelationships)

		for i = 1 to nLen
			if @aRelationships[i][:from] = cTableName or @aRelationships[i][:to] = cTableName
				nCount++
			ok
		next

		return nCount

	# Return relationships as expected format

	def Relationships()
		return @aRelationships

	# Utility methods

	def TableExists(cTableName)

		nLen = len(@aTables)

		for i = 1 to nLen
			if @aTables[i][:name] = cTableName
				return TRUE
			ok
		next

		return FALSE

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

	def TableNameFromFK(cForeignKeyField)

		if cForeignKeyField = "parent_id"
			return ""
		ok

		if right(cForeignKeyField, 3) = "_id"
			cBaseName = left(cForeignKeyField, len(cForeignKeyField) - 3)
			return cBaseName  # Return singular form
		ok

		return ""

	#===========================#
	#  CONSTRAINTS ENFORCEMENT  #
	#===========================#

    # Add a constraint to a table's field

    def AddConstraint(cTableName, cFieldName, cConstraint)

        aConstraintDef = [
            :table = cTableName,
            :field = cFieldName,
            :constraint = cConstraint,
            :type = This.ConstraintType(cConstraint)
        ]

        @aConstraints + aConstraintDef
        
        # Track relationships for foreign keys
        if aConstraintDef[:type] = "foreign_key"

            aRefInfo = This.ParseForeignKey(cConstraint)

            if aRefInfo != NULL

                @aRelationships + [
                    :from_table = cTableName,
                    :from_field = cFieldName,
                    :to_table = aRefInfo[:table],
                    :to_field = aRefInfo[:field]
                ]

            ok
        ok

    # Enhanced constraint type detection
    def ConstraintType(cConstraint)

        cUpper = upper(cConstraint)

        if substr(cUpper, "PRIMARY KEY") > 0
            return "primary_key"

        but substr(cUpper, "FOREIGN KEY") > 0 or substr(cUpper, "REFERENCES") > 0
            return "foreign_key"

        but substr(cUpper, "UNIQUE") > 0
            return "unique"

        but substr(cUpper, "NOT NULL") > 0
            return "not_null"

        but substr(cUpper, "CHECK") > 0
            return "check"

        but substr(cUpper, "DEFAULT") > 0
            return "default"

        else
            return "custom"
        ok

    # Improved foreign key parsing
    def ParseForeignKey(cConstraint)
        cUpper = upper(cConstraint)
        nRefPos = substr(cUpper, "REFERENCES ")
        if nRefPos > 0
            cAfterRef = @substr(cConstraint, nRefPos + 11)
            # Find table name (up to opening parenthesis or space)
            nParenPos = substr(cAfterRef, "(")
            nSpacePos = substr(cAfterRef, " ")
            
            nEndPos = nParenPos
            if nSpacePos > 0 and (nSpacePos < nParenPos or nParenPos = 0)
                nEndPos = nSpacePos
            ok
            
            if nEndPos > 0
                cRefTable = trim(substr(cAfterRef, 1, nEndPos - 1))
                
                # Extract field name from parentheses
                nOpenParen = substr(cAfterRef, "(")
                nCloseParen = substr(cAfterRef, ")")
                if nOpenParen > 0 and nCloseParen > nOpenParen
                    cRefField = trim(@substr(cAfterRef, nOpenParen + 1, nCloseParen - nOpenParen - 1))
                    return [ :table = cRefTable, :field = cRefField ]
                ok
            ok
        ok
        return NULL

	#=================================#
	#   VALIDATION OF THE DATA MODEL  #
	#=================================#

    # Enhanced validation with detailed reporting

    def Validate()

        @aValidationErrors = []
        nTablesValidated = 0
        nConstraintsValidated = 0
        nRelationshipsValidated = 0
        
        # Table validation

		nLen = len(@aTables)

        for i = 1 to nLen

			aTable = @aTables[i]
            nTablesValidated++

            if aTable[:name] = "" or aTable[:name] = NULL

                @aValidationErrors + [ :type = "table", :severity = "error", 
                                     :message = "Table has no name", :table = "" ]
                loop
            ok
            
			aFields = aTable[:fields]
			nLenF = len(aFields)

            if nLenF = 0

                @aValidationErrors + [ :type = "table", :severity = "error",
                                     :message = "Table '" + aTable[:name] + "' has no fields", 
                                     :table = aTable[:name] ]
            ok
            
            # Check for duplicate field names

            aFieldNames = []
			for j = 1 to nLenF

				aField = aFields[j]
                cFieldName = aField[:name]

                if find(aFieldNames, cFieldName) > 0

                    @aValidationErrors + [ :type = "table", :severity = "error",
                                         :message = "Duplicate field '" + cFieldName + "' in table '" + aTable[:name] + "'",
                                         :table = aTable[:name], :field = cFieldName ]
                else
                    aFieldNames + cFieldName
                ok
            next
        next
        
        # Constraint validation

		nLenC = len(@aConstraints)

		for i = 1 to nLenC

			aConstraint = @aConstraints[i]
            nConstraintsValidated++
            cTableName = aConstraint[:table]
            cFieldName = aConstraint[:field]
            cType = aConstraint[:type]

            aTable = This.FindTable(cTableName)
            
            if aTable = NULL
                @aValidationErrors + [ :type = "constraint", :severity = "error",
                                     :message = "Table '" + cTableName + "' does not exist for constraint",
                                     :table = cTableName, :constraint_type = cType ]
                loop
            ok
            
            if not This.FieldExists(aTable, cFieldName)
                @aValidationErrors + [ :type = "constraint", :severity = "error",
                                     :message = "Field '" + cFieldName + "' does not exist in table '" + cTableName + "'",
                                     :table = cTableName, :field = cFieldName, :constraint_type = cType ]
                loop
            ok
            
            # Foreign key validation

            if cType = "foreign_key"

                nRelationshipsValidated++

                aRefInfo = This.ParseForeignKey(aConstraint[:constraint])

                if aRefInfo != NULL
                    aRefTable = This.FindTable(aRefInfo[:table])

                    if aRefTable = NULL

                        @aValidationErrors + [ :type = "constraint", :severity = "error",
                                             :message = "Referenced table '" + aRefInfo[:table] + "' does not exist",
                                             :table = cTableName, :field = cFieldName, 
                                             :referenced_table = aRefInfo[:table] ]

                    else

                        if not This.FieldExists(aRefTable, aRefInfo[:field])

                            @aValidationErrors + [ :type = "constraint", :severity = "error",
                                                 :message = "Referenced field '" + aRefInfo[:field] + 
                                                           "' does not exist in table '" + aRefInfo[:table] + "'",
                                                 :table = cTableName, :field = cFieldName,
                                                 :referenced_table = aRefInfo[:table], 
                                                 :referenced_field = aRefInfo[:field] ]
                        ok
                    ok

                else

                    @aValidationErrors + [ :type = "constraint", :severity = "warning",
                                         :message = "Could not parse foreign key constraint: " + aConstraint[:constraint],
                                         :table = cTableName, :field = cFieldName ]
                ok

            ok
            
            # Check constraint syntax validation

            if cType = "check"

                if not This.ValidateCheckConstraint(aConstraint[:constraint])

                    @aValidationErrors + [ :type = "constraint", :severity = "warning",
                                         :message = "Potentially invalid CHECK constraint syntax",
                                         :table = cTableName, :field = cFieldName,
                                         :constraint = aConstraint[:constraint] ]
                ok
            ok

        next
   
        return [
            :valid = (len(@aValidationErrors) = 0),
            :errors = @aValidationErrors,
            :error_count = len(@aValidationErrors),
            :tables_validated = nTablesValidated,
            :constraints_validated = nConstraintsValidated,
            :relationships_validated = nRelationshipsValidated,
            :summary = This.ValidationSummary()
        ]

    # Basic check constraint validation
    def ValidateCheckConstraint(cConstraint)
        cUpper = upper(cConstraint)
        # Basic syntax checks
        if substr(cUpper, "CHECK") = 0
            return FALSE
        ok
        
        # Check for balanced parentheses
        nOpenParens = 0
        nCloseParens = 0
        for i = 1 to len(cConstraint)
            if cConstraint[i] = "("
                nOpenParens++
            but cConstraint[i] = ")"
                nCloseParens++
            ok
        next
        
        return (nOpenParens = nCloseParens)



    # Generate validation summary
    def ValidationSummary()
        nErrors = 0
        nWarnings = 0
        
        for aError in @aValidationErrors
            if aError[:severity] = "error"
                nErrors++
            but aError[:severity] = "warning"
                nWarnings++
            ok
        next
        
        cSummary = "Validation completed: "
        if nErrors = 0 and nWarnings = 0
            cSummary += "All checks passed"
        else
            if nErrors > 0
                cSummary += "" + nErrors + " error(s)"
            ok
            if nWarnings > 0
                if nErrors > 0
                    cSummary += ", "
                ok
                cSummary += "" + nWarnings + " warning(s)"
            ok
        ok
        
        return cSummary

#===============================#
#  PERFORMANCE PLAN MANAGEMENT  #
#===============================#

    # Performance Plan Management - simplified API
    def UsePerfPlan(cPlanName)
        @oPerfEngine.SetActivePlan(cPlanName)
        return This

	def PerfEngine()
		return @oPerfEngine

    def PerfPlan()
        return @oPerfEngine.Plan()

    # Core Performance Analysis - single clear method
    def PerfHintsXT()
        aModelData = This.ModelSummary()
        return @oPerfEngine.AnalyzeModel(aModelData)

	def PerfHints()
		acResult = []
		aHints = This.PerfHintsXT()
		nLen = len(aHints)

		for i = 1 to nLen

			acResult + [
				:message = aHints[i][:message],
				:action = aHints[i][:action]
			]

		next

		return acResult

    # Performance report for management - different purpose than hints
    def PerfReport()
        aHints = This.PerfHints()
        
        return [
            :plan = [
                :name = @oPerfEngine.Plan(),
                :description = This.PlanDescription()
            ],
            :summary = [
                :total_hints = len(aHints),
                :by_priority = This.GroupByPriority(aHints),
                :by_type = This.GroupByType(aHints)
            ],
            :critical_actions = This.CriticalActions(aHints)
        ]

    def SetPerfThreshold(cName, nValue)
        @oPerfEngine.SetThreshold(cName, nValue)
        return This
    
    def PerfThreshold(cName)
       return @oPerfEngine.Threshold(cName)
    
    def Thresholds()
        return @oPerfEngine.Thresholds()


    # Helper methods - internal use
    def ModelSummary()
        return [
            :tables = @aTables,
            :relationships = @aRelationships
        ]

    def GroupByPriority(aHints)
        aGrouped = []
        aPriorities = ["critical", "high", "medium", "low"]
        
        for cPriority in aPriorities
            nCount = 0
            for aHint in aHints
                if aHint[:priority] = cPriority
                    nCount++
                ok
            next
            if nCount > 0
                aGrouped + [ :priority = cPriority, :count = nCount ]
            ok
        next
        
        return aGrouped

    def GroupByType(aHints)
        aTypes = []
        aGrouped = []
        
        # Collect unique types
        for aHint in aHints
            if find(aTypes, aHint[:type]) = 0
                aTypes + aHint[:type]
            ok
        next
        
        # Count by type
        for cType in aTypes
            nCount = 0
            for aHint in aHints
                if aHint[:type] = cType
                    nCount++
                ok
            next
            aGrouped + [ :type = cType, :count = nCount ]
        next
        
        return aGrouped

    def PerfCriticalActions(aHints)
        aActions = []
        for aHint in aHints
            if aHint[:priority] = "critical" or aHint[:priority] = "high"
                aActions + [
                    :priority = aHint[:priority],
                    :message = aHint[:message],
                    :action = aHint[:action]
                ]
            ok
        next
        return aActions

    def AppliesTo(cRuleId)
        # Map rule IDs to what they apply to
        aAppliesMap = [
            "basic_fk_index" = "foreign_keys",
            "fk_index_mandatory" = "foreign_keys", 
            "covering_indexes" = "multi_column_queries",
            "denormalization_consideration" = "complex_joins",
            "n_plus_one_prevention" = "has_many_relationships"
        ]
        
        if HasKey(aAppliesMap, cRuleId)
            return aAppliesMap[cRuleId]
        ok
        return "general"

	#=================#
	#  OTHER METHODS  #
	#=================#

    # Find a table by name
    def FindTable(cTableName)
        for aTable in @aTables
            if aTable[:name] = cTableName
                return aTable
            ok
        next
        return stzraise("Inexistant table name!")

    def SelfReferencingTables()
        aResult = []
		nLen = len(@aRelationships)
        for i = 1 to nLen
            if @aRelationships[i][:from] = @aRelationships[i][:to]
                aResult + [
                    :table = @aRelationships[i][:from],
                    :type = @aRelationships[i][:type]
                ]
            ok
        next
        return aResult

	#=========#
	# EXPORT  #
	#=========#

	# Enhanced DiagramData() method for better ERD tool compatibility
	def DiagramData()
	    aEntities = []
	    aRelationships = []
	    
	    # Create detailed entities with field information
	    for aTable in @aTables
	        aFields = []
	        for aField in aTable[:fields]
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
	    
	    # Create standardized relationships
	    aProcessedRels = []
	    for aRel in @aRelationships
	        # Skip duplicate relationships (keep only one direction for ERD)
	        cRelKey = aRel[:from] + "->" + aRel[:to] + ":" + aRel[:type]
	        if find(aProcessedRels, cRelKey) = 0
	            aProcessedRels + cRelKey
	            
	            aRelationship = [
	                :id = "rel_" + len(aRelationships) + 1,
	                :from_entity = aRel[:from],
	                :to_entity = aRel[:to],
	                :relationship_type = aRel[:type],
	                :cardinality = This.GetCardinality(aRel[:type]),
	                :foreign_key = iff(HasKey(aRel, :field), aRel[:field], ""),
	                :is_identifying = (aRel[:type] = "belongs_to"),
	                :label = This.GetRelationshipLabel(aRel[:type])
	            ]
	            aRelationships + aRelationship
	        ok
	    next
	    
	    return [
	        :schema_name = @cSchemaName,
	        :entities = aEntities,
	        :relationships = aRelationships,
	        :metadata = [
	            :entity_count = len(aEntities),
	            :relationship_count = len(aRelationships),
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

	# Helper methods for ERD data generation
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
	
	def GetRelationshipLabel(cRelType)
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

	#--- EXPORT TO MERMAIDERD FORMAT

	def ToMermaidERD()
	
	    cMermaid = "erDiagram" + nl
		aDiagramData = This.DiagramData()
	    aEntities = aDiagramData[:entities]
		nLen = len(aEntities)
	
	    # Add entities with fields
	
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
	    
	    # Add relationships
		aRels = aDiagramData[:relationships]
		nLen = len(aRels)
	
	    for i = 1 to nLen
			aRel = aRels[i] 
	        if aRel[:from_entity] != aRel[:to_entity]  # Skip self-referencing for basic ERD
	            cMermaid += "    " + aRel[:from_entity] + " ||--o{ " + aRel[:to_entity] + ' : "' + aRel[:label] + '"' + nl
	        ok
	    next
	    
	    return cMermaid
	
	#--- EXPORT TO PLANTUML FORMAT

	def ToPlantUMLERD()
	    cPlantUML = "@startuml" + nl
	    cPlantUML += "!define ENTITY class" + nl + nl
	   
	    # Add entities
		aDiagramData = This.DiagramData()
	
		aEntities = aDiagramData[:entities]
		nLen = len(aEntities)
	
	    for i = 1 to nLen
			aEntity = aentities[i] 
	        cPlantUML += "ENTITY " + aEntity[:name] + " {" + nl
	
			aFields = aEntity[:fields]
			nLenF = len(aFields)
	
	        for j = 1 to nLenF
				aField = aFields[j]
	            cLine = "  "
	
	            if aField[:is_primary]
	                cLine += "**" + aField[:name] + "** : " + aField[:type] + " <<PK>>"
	
	            but aField[:is_foreign]
	                cLine += aField[:name] + " : " + aField[:type] + " <<FK>>"
	
	            else
	                cLine += aField[:name] + " : " + aField[:type]
	
	            ok
	
	            cPlantUML += cLine + nl
	        next
	
	        cPlantUML += "}" + nl + nl
	    next
	    
	    # Add relationships
		aRels = aDiagramData[:relationships]
		nLen = len(aRels)
	
	    for i = 1 to nLen
			aRel = aRels[i]
	
	        if aRel[:from_entity] != aRel[:to_entity]
	            cPlantUML += aRel[:from_entity] + " ||--o{ " + aRel[:to_entity] + nl
	        ok
	    next
	    
	    cPlantUML += "@enduml"
	    return cPlantUML
	
	#--- EXPORT TO JSON FORMAT

    # Export model as JSON ERD with proper indentation
    def ToJSONERD()

        cJSON = "{" + nl
        cJSON += TAB + '"tables": [' + nl
        nLen = len(@aTables)
		nLenC = len(@aConstraints)

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
            
            cJSON += TAB + TAB + TAB + "]," + nl
            cJSON += TAB + TAB + TAB + '"constraints": [' + nl
            
            # Add constraints for this table
            aTableConstraints = []

			for j = 1 to nLenC
                if @aConstraints[j][:table] = aTable[:name]
                    aTableConstraints + @aConstraints[j]
                ok
            next
            
			nLenC = len(aTableConstraints)
            for j = 1 to nLenC
                aConstraint = aTableConstraints[j]
                cJSON += TAB + TAB + TAB + TAB + "{" + nl
                cJSON += TAB + TAB + TAB + TAB + TAB + '"field": "' + aConstraint[:field] + '",' + nl
                cJSON += TAB + TAB + TAB + TAB + TAB + '"type": "' + aConstraint[:type] + '",' + nl
                cJSON += TAB + TAB + TAB + TAB + TAB + '"constraint": "' + aConstraint[:constraint] + '"' + nl
                cJSON += TAB + TAB + TAB + TAB + "}"
                if j < nLenC
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
        cJSON += TAB + '"relationships": [' + nl
        nLenR = len(@aRelationships)

        for i = 1 to nLenR
            aRel = @aRelationships[i]
            cJSON += TAB + TAB + "{" + nl
            cJSON += TAB + TAB + TAB + '"from_table": "' + aRel[:from_table] + '",' + nl
            cJSON += TAB + TAB + TAB + '"from_field": "' + aRel[:from_field] + '",' + nl
            cJSON += TAB + TAB + TAB + '"to_table": "' + aRel[:to_table] + '",' + nl
            cJSON += TAB + TAB + TAB + '"to_field": "' + aRel[:to_field] + '"' + nl
            cJSON += TAB + TAB + "}"
            if i < nLenR
                cJSON += ","
            ok
            cJSON += nl
        next
        
        cJSON += TAB + "]" + nl
        cJSON += "}"
        
        return cJSON

	#--- EXPORT RO DBML SCRIPT FORMAT

	def ToDBML()
	    # Database Markup Language format for dbdiagram.io
	    cDBML = "Project " + @cSchemaName + " {" + nl
	    cDBML += "  database_type: 'Generic'" + nl
	    cDBML += "  Note: 'Generated from stzDataModel'" + nl
	    cDBML += "}" + nl + nl
	    
	    # Add tables
	    for aTable in @aTables
	        cDBML += "Table " + aTable[:name] + " {" + nl
	        
	        for aField in aTable[:fields]
	            cLine = "  " + aField[:name] + " " + This.MapTypeToDBML(aField[:type])
	            
	            # Add constraints
	            aConstraints = []
	            if aField[:is_primary]
	                aConstraints + "pk"
	            ok
	            if HasKey(aField, :is_unique) and aField[:is_unique]
	                aConstraints + "unique"
	            ok
	            if HasKey(aField, :is_required) and aField[:is_required]
	                aConstraints + "not null"
	            ok
	            
	            if len(aConstraints) > 0
	                cLine += " ["
	                for i = 1 to len(aConstraints)
	                    cLine += aConstraints[i]
	                    if i < len(aConstraints)
	                        cLine += ", "
	                    ok
	                next
	                cLine += "]"
	            ok
	            
	            cDBML += cLine + nl
	        next
	        
	        cDBML += "}" + nl + nl
	    next
	    
	    # Add relationships
	
	    for aRel in @aRelationships
	        if aRel[:type] = "belongs_to" and aRel[:from] != aRel[:to]
	            cDBML += "Ref: " + aRel[:from] + "."
	            if HasKey(aRel, :foreign_key) and aRel[:foreign_key] != ""
	                cDBML += aRel[:foreign_key]
	            else
	                cDBML += This.GuessFK(aRel[:to])
	            ok
	            cDBML += " > " + aRel[:to] + ".id" + nl
	        ok
	    next
	    
	    return cDBML
	
	def MapTypeToDBML(cType)
	    # Map Ring/SQL types to DBML types
	    switch lower(cType)
	    on "integer"
	        return "int"
	    on "varchar(255)"
	        return "varchar(255)"
	    on "varchar(500)"
	        return "varchar(500)"
	    on "text"
	        return "text"
	    on "timestamp"
	        return "timestamp"
	    on "decimal(10,2)"
	        return "decimal(10,2)"
	    on "boolean"
	        return "boolean"
	    other
	        return cType
	    off
	
	def GuessFK(cTableName)
	    # Convert table name to likely foreign key field name
	    cSingular = SingularOf(cTableName)
	    return cSingular + "_id"

	#--- EXPORT TO DDL SQL SCRIPT FORMAT

    def ToDDL()

        cDDL = ""
        nLen = len(@aTables)

        for i = 1 to nLen

			aTable = @aTables[i]
            cDDL += "CREATE TABLE " + aTable[:name] + " (" + nl
            
            # Collect inline constraints for each field
            acInlineConstraints = []
			aFields = aTable[:fields]
			nLenF = len(aFields)

            for j = 1 to nLenF

				aField = aFields[j]
                acFieldConstraints = This.GetFieldInlineConstraints(aTable[:name], aField[:name])
                acInlineConstraints + acFieldConstraints

            next
            
            for j = 1 to nLenF

                aField = aTable[:fields][i]
                cFieldDef = "    " + aField[:name] + " " + This.MapFieldType(aField[:type])
                
                # Add inline constraints for this field
                acFieldConstraints = acInlineConstraints[j]
				nLenFC = len(acFieldConstraints)

				for q = 1 to nLenFC
                    cFieldDef += " " + acFieldConstraints[q]
                next
                
                if j < nLenF
                    cFieldDef += ","
                ok

                cDDL += cFieldDef + nl

            next
            
            cDDL += ");" + nl + nl
        next
        
        # Add table-level constraints (CHECK, FOREIGN KEY)
		nLen = len(@aConstraints)

		for i = 1 to nLen

			aConstraint = @aConstraints[i]

            cType = aConstraint[:type]

            if cType = "check" or cType = "foreign_key"

                cConstraintName = aConstraint[:table] + "_" + aConstraint[:field] + "_" + cType

                cDDL += "ALTER TABLE " + aConstraint[:table] + 
                       " ADD CONSTRAINT " + cConstraintName + " " + 
                       aConstraint[:constraint] + ";" + nl

            ok

        next
        
        return cDDL

    # Map Softanza field types to SQL types
    def MapFieldType(cType)

        if cType = :primary_key
            return "INTEGER PRIMARY KEY"

        but cType = :required
            return "VARCHAR(255) NOT NULL"

        but cType = :email
            return "VARCHAR(255)"

        but cType = "integer"
            return "INTEGER"

        but cType = "text"
            return "TEXT"

        but cType = "timestamp"
            return "TIMESTAMP"

        but isString(cType) and substr(upper(cType), "VARCHAR") > 0
            return upper(cType)

        else
            return "TEXT"

        ok

    # Get inline constraints for a field (PRIMARY KEY, NOT NULL, etc.)
    def GetFieldInlineConstraints(cTableName, cFieldName)

        aInlineConstraints = []
        nLen = len(@aConstraints)

		for i = 1 to nLen

			aConstraint = @aConstraints[i]

            if aConstraint[:table] = cTableName and aConstraint[:field] = cFieldName
                cType = aConstraint[:type]

                if cType = "primary_key"
                    # Already handled in field type mapping

                but cType = "not_null"
                    aInlineConstraints + "NOT NULL"

                but cType = "unique"
                    aInlineConstraints + "UNIQUE"

                but cType = "default"
                    # Extract default value from constraint
                    cUpper = upper(aConstraint[:constraint])
                    nPos = substr(cUpper, "DEFAULT ")

                    if nPos > 0
                        cDefaultValue = trim(substr(aConstraint[:constraint], nPos + 8))
                        aInlineConstraints + "DEFAULT " + cDefaultValue
                    ok
                ok
            ok

        next
        
        return aInlineConstraints


	#=========#
	# IMPORT  #
	#=========#
	
	# Import from Mermaid ERD format
	def FromMermaidERD(cMermaidERD)
	    This.ClearModel()
	    
	    acLines = str2list(cMermaidERD)
	    cCurrentEntity = ""
	    bInEntity = FALSE
	    
	    for cLine in acLines
	        cLine = trim(cLine)
	        
	        if cLine = "erDiagram"
	            loop
	        ok
	        
	        # Entity definition
	        if right(cLine, 1) = "{" and !bInEntity
	            cCurrentEntity = trim(left(cLine, len(cLine) - 1))
	            bInEntity = TRUE
	            This.AddTable(cCurrentEntity)
	            loop
	        ok
	        
	        # End of entity
	        if cLine = "}" and bInEntity
	            bInEntity = FALSE
	            cCurrentEntity = ""
	            loop
	        ok
	        
	        # Field definition within entity
	        if bInEntity and cLine != ""
	            aFieldParts = str2list(cLine, " ")
	            if len(aFieldParts) >= 2
	                cType = aFieldParts[1]
	                cName = aFieldParts[2]
	                
	                # Handle constraints
	                bIsPK = FALSE
	                bIsFK = FALSE
	                bNotNull = FALSE
	                nLen = len(aFieldParts)

	                for i = 3 to nLen

	                    cPart = upper(aFieldParts[i])

	                    if cPart = "PK"
	                        bIsPK = TRUE
	                    but cPart = "FK"
	                        bIsFK = TRUE
	                    but cPart = "NOT" and i < nLen and upper(aFieldParts[i+1]) = "NULL"
	                        bNotNull = TRUE
	                    ok

	                next
	                
	                This.AddField(cCurrentEntity, cName, cType)
	                
	                if bIsPK
	                    This.AddConstraint(cCurrentEntity, cName, "primary_key", "PRIMARY KEY")
	                ok

	                if bNotNull
	                    This.AddConstraint(cCurrentEntity, cName, "not_null", "NOT NULL")
	                ok

	            ok
	        ok
	        
	        # Relationship definition
	        if substr(cLine, "||--") > 0 or substr(cLine, "--o{") > 0
	            # Parse relationship: EntityA ||--o{ EntityB : "label"

	            acParts = str2list(cLine, " ")

	            if len(acParts) >= 3
	                cFromEntity = acParts[1]
	                cToEntity = acParts[3]
	                
	                # Extract label if present
	                cLabel = ""
	                nQuotePos = substr(cLine, '"')

	                if nQuotePos > 0

	                    cRest = substr(cLine, nQuotePos + 1)
	                    nEndQuote = substr(cRest, '"')

	                    if nEndQuote > 0
	                        cLabel = left(cRest, nEndQuote - 1)
	                    ok
	                ok
	                
	                This.AddRelationship(cFromEntity, cToEntity, "has_many")
	            ok
	        ok
	    next
	
	# Import from PlantUML ERD format

	def FromPlantUMLERD(cPlantUML)
	    This.ClearModel()
	    
	    acLines = str2list(cPlantUML)
	    cCurrentEntity = ""
	    bInEntity = FALSE
	    
		nLen = len(acLines)
		for i = 1 to nLen
			
	        cLine = trim(acLines[i])
	        
	        if left(cLine, 6) = "ENTITY" and right(cLine, 1) = "{"
	            # Extract entity name
	            cEntityDef = trim(substr(cLine, 7, len(cLine) - 7))
	            cCurrentEntity = trim(left(cEntityDef, len(cEntityDef) - 1))
	            bInEntity = TRUE
	            This.AddTable(cCurrentEntity)
	            loop
	        ok
	        
	        if cLine = "}" and bInEntity
	            bInEntity = FALSE
	            cCurrentEntity = ""
	            loop
	        ok
	        
	        # Field definition
	        if bInEntity and cLine != '' and left(cLine, 2) = "  "
	            cFieldDef = trim(cLine)
	            
	            # Parse field: "name : type" or "**name** : type <<PK>>"
	            cName = ""
	            cType = ""
	            bIsPK = FALSE
	            bIsFK = FALSE
	            
	            if substr(cFieldDef, "**") > 0
	                # Primary key field
	                nStart = substr(cFieldDef, "**") + 2
	                nEnd = substr(cFieldDef, "**", nStart)
	                if nEnd > 0
	                    cName = substr(cFieldDef, nStart, nEnd - nStart)
	                    bIsPK = TRUE
	                ok

	            else
	                # Regular field
	                nColonPos = substr(cFieldDef, " : ")
	                if nColonPos > 0
	                    cName = trim(left(cFieldDef, nColonPos - 1))
	                ok
	            ok
	            
	            # Extract type
	            nColonPos = substr(cFieldDef, " : ")

	            if nColonPos > 0
	                cRest = trim(substr(cFieldDef, nColonPos + 3))
	                nSpacePos = substr(cRest, " ")

	                if nSpacePos > 0
	                    cType = trim(left(cRest, nSpacePos - 1))
	                else
	                    cType = cRest
	                ok
	            ok
	            
	            # Check for constraints
	            if substr(cFieldDef, "<<FK>>") > 0
	                bIsFK = TRUE
	            ok
	            
	            if cName != "" and cType != ""
	                This.AddField(cCurrentEntity, cName, cType)
	                
	                if bIsPK
	                    This.AddConstraint(cCurrentEntity, cName, "primary_key", "PRIMARY KEY")
	                ok
	            ok
	        ok
	        
	        # Relationship
	        if substr(cLine, "||--o{") > 0

	            acParts = str2list(cLine, " ")

	            if len(acParts) >= 3
	                cFromEntity = acParts[1]
	                cToEntity = acParts[3]
	                This.AddRelationship(cFromEntity, cToEntity, "has_many")
	            ok

	        ok
	    next
	
	# Import from JSON ERD format

	def FromJSONERD(cJSON)
	    This.ClearModel()
	    
	    try
	        # Parse JSON (simplified parsing for Ring)
	        oJSON = This.ParseSimpleJSON(cJSON)
	        
	        # Import tables
	        if HasKey(oJSON, :tables)
				aTables = oJSON[:tables]
				nLen = len(aTables)

				for i = 1 to nLen
					aTable = aTables[i]
	                cTableName = aTable[:name]
	                This.AddTable(cTableName)
	                
	                # Import fields
					
	                if HasKey(aTable, :fields)
						aFields = aTable[:fields]
						nLenF = len(aFields)

						for j = 1 to nLenF
	                        This.AddField(cTableName, aFields[j][:name], aFields[j][:type])
	                    next
	                ok
	                
	                # Import constraints
	                if HasKey(aTable, :constraints)
						aConstraints = aTable[:constraints]
						nLenC = len(aConstraints)

						for j = 1 to nLenC
							aConstraint = aConstraints[j]
	                        This.AddConstraint(cTableName, aConstraint[:field], 
	                                         aConstraint[:type], aConstraint[:constraint])
	                    next

	                ok

	            next
	        ok
	        
	        # Import relationships
	        if HasKey(oJSON, :relationships)
				aRels = oJSON[:relationships]
				nLenR = len(aRels)

				for i = 1 to nLenR
	                This.AddRelationship(aRels[i][:from_table], aRels[i][:to_table], "has_many", aRels[i][:from_field])
	            next
	        ok
	        
	    catch
	        StzRaise("Invalid JSON format")
	    done
	
	# Import from DBML format
	def FromDBML(cDBML)
	    This.ClearModel()
	    
	    acLines = str2list(cDBML)
	    cCurrentTable = ""
	    bInTable = FALSE

		nLen = len(acLines)

		for i = 1 to nLen
	        cLine = trim(acLines[i])
	        
	        # Skip project definition and comments
	        if left(cLine, 7) = "Project" or left(cLine, 1) = "//"
	            loop
	        ok
	        
	        # Table definition
	        if left(cLine, 5) = "Table" and right(cLine, 1) = "{"
	            cTableDef = trim(substr(cLine, 6, len(cLine) - 6))
	            cCurrentTable = trim(left(cTableDef, len(cTableDef) - 1))
	            bInTable = TRUE
	            This.AddTable(cCurrentTable)
	            loop
	        ok
	        
	        if cLine = "}" and bInTable
	            bInTable = FALSE
	            cCurrentTable = ""
	            loop
	        ok
	        
	        # Field definition in table
	        if bInTable and cLine != "" and left(cLine, 2) = "  "
	            cFieldDef = trim(cLine)
	            
	            # Parse: "field_name type [constraints]"
	            acParts = str2list(cFieldDef, " ")

	            if len(acParts) >= 2
	                cName = acParts[1]
	                cType = acParts[2]
	                
	                This.AddField(cCurrentTable, cName, This.MapDBMLTypeToInternal(cType))
	                
	                # Parse constraints in brackets
	                nBracketPos = substr(cFieldDef, "[")

	                if nBracketPos > 0
	                    nEndBracket = substr(cFieldDef, "]", nBracketPos)

	                    if nEndBracket > 0
	                        cConstraints = substr(cFieldDef, nBracketPos + 1, nEndBracket - nBracketPos - 1)
	                        acConstraints = str2list(cConstraints, ",")
							nLen = len(acConstraints)

							for i = 1 to nLen
	                            cConstraint = trim(acConstraints[i])

	                            if cConstraint = "pk"
	                                This.AddConstraint(cCurrentTable, cName, "primary_key", "PRIMARY KEY")

	                            but cConstraint = "unique"
	                                This.AddConstraint(cCurrentTable, cName, "unique", "UNIQUE")

	                            but cConstraint = "not null"
	                                This.AddConstraint(cCurrentTable, cName, "not_null", "NOT NULL")

	                            ok

	                        next
	                    ok
	                ok
	            ok
	        ok

	        # Relationship definition

	        if left(cLine, 4) = "Ref:"
	            # Parse: "Ref: table1.field > table2.field"
	            cRelDef = trim(substr(cLine, 5))
	            
	            nArrowPos = substr(cRelDef, " > ")

	            if nArrowPos > 0
	                cFromPart = trim(left(cRelDef, nArrowPos - 1))
	                cToPart = trim(substr(cRelDef, nArrowPos + 3))
	                
	                # Extract table names
	                nDotPos1 = substr(cFromPart, ".")
	                nDotPos2 = substr(cToPart, ".")
	                
	                if nDotPos1 > 0 and nDotPos2 > 0
	                    cFromTable = left(cFromPart, nDotPos1 - 1)
	                    cToTable = left(cToPart, nDotPos2 - 1)
	                    cFromField = substr(cFromPart, nDotPos1 + 1)
	                    
	                    This.AddRelationship(cFromTable, cToTable, "belongs_to", cFromField)
	                ok
	            ok
	        ok

	    next
	
	# Import from DDL SQL format

	def FromDDL(cDDL)
	    This.ClearModel()
	    
	    acStatements = str2list(cDDL, ";")
	    nLen = len(acStatements)

		for i = 1 to nLen
	        cStatement = trim(acStatements[i])
	        cUpper = upper(cStatement)
	        
	        # CREATE TABLE statement
	        if left(cUpper, 12) = "CREATE TABLE"
	            This.ParseCreateTable(cStatement)
	        ok
	        
	        # ALTER TABLE statement for constraints
	        if left(cUpper, 11) = "ALTER TABLE"
	            This.ParseAlterTable(cStatement)
	        ok
	    next
	
	# Helper method to parse CREATE TABLE statement
	def ParseCreateTable(cStatement)
	    cUpper = upper(cStatement)
	    
	    # Extract table name
	    nTablePos = substr(cUpper, "CREATE TABLE ") + 13
	    nParenPos = @substr(cStatement, "(", nTablePos)
	    
	    if nParenPos > 0
	        cTableName = trim(@substr(cStatement, nTablePos, nParenPos - nTablePos))
	        This.AddTable(cTableName)
	        
	        # Extract field definitions
	        cFieldsPart = @substr(cStatement, nParenPos + 1)
	        nLastParen = This.FindLastChar(cFieldsPart, ")")
	        if nLastParen > 0
	            cFieldsPart = left(cFieldsPart, nLastParen - 1)
	        ok
	        
	        acFields = str2list(cFieldsPart, ",")
	        nLen = len(acFields)

	        for i = 1 to nLen
	            cFieldDef = trim(acFields[i])
	            acParts = str2list(cFieldDef, " ")
	            
	            if len(acParts) >= 2
	                cFieldName = acParts[1]
	                cFieldType = acParts[2]
	                
	                This.AddField(cTableName, cFieldName, This.MapSQLTypeToInternal(cFieldType))
	                
	                # Parse inline constraints
	                cDefUpper = upper(cFieldDef)
	                if substr(cDefUpper, "PRIMARY KEY") > 0
	                    This.AddConstraint(cTableName, cFieldName, "primary_key", "PRIMARY KEY")
	                ok

	                if substr(cDefUpper, "NOT NULL") > 0
	                    This.AddConstraint(cTableName, cFieldName, "not_null", "NOT NULL")
	                ok

	                if substr(cDefUpper, "UNIQUE") > 0
	                    This.AddConstraint(cTableName, cFieldName, "unique", "UNIQUE")
	                ok

	            ok
	        next
	    ok
	
	# Helper method to parse ALTER TABLE statement
	def ParseAlterTable(cStatement)
	    cUpper = upper(cStatement)
	    
	    # Extract table name
	    nTablePos = substr(cUpper, "ALTER TABLE ") + 12
	    nAddPos = substr(cUpper, " ADD ", nTablePos)
	    
	    if nAddPos > 0
	        cTableName = trim(substr(cStatement, nTablePos, nAddPos - nTablePos))
	        cConstraintPart = trim(substr(cStatement, nAddPos + 5))
	        
	        # Parse constraint
	        if left(upper(cConstraintPart), 10) = "CONSTRAINT"
	            # Named constraint
	            acParts = str2list(cConstraintPart, " ")
	            if len(acParts) >= 3
	                cConstraintName = acParts[2]
	                cConstraintType = acParts[3]
	                
	                # Extract field name from constraint name (table_field_type format)
	                acNameParts = str2list(cConstraintName, "_")
	                if len(acNameParts) >= 3
	                    cFieldName = acNameParts[2]
	                    This.AddConstraint(cTableName, cFieldName, lower(cConstraintType), cConstraintPart)
	                ok
	            ok
	        ok
	    ok
	
	# Helper methods for type mapping
	def MapDBMLTypeToInternal(cDBMLType)
	    switch lower(cDBMLType)
	    on "int"
	        return "integer"
	    on "varchar(255)"
	        return "varchar(255)"
	    on "text"
	        return "text"
	    on "timestamp"
	        return "timestamp"
	    on "boolean"
	        return "boolean"
	    other
	        return cDBMLType
	    off
	
	def MapSQLTypeToInternal(cSQLType)
	    cUpper = upper(cSQLType)
	    switch cUpper
	    on "INTEGER"
	        return "integer"
	    on "TEXT"
	        return "text"
	    on "TIMESTAMP"
	        return "timestamp"
	    on "BOOLEAN"
	        return "boolean"
	    other
	        if substr(cUpper, "VARCHAR") > 0
	            return lower(cSQLType)
	        else
	            return "text"
	        ok
	    off
	
	# Helper method for simple JSON parsing (Ring-specific)
	def ParseSimpleJSON(cJSON)
	    # This is a simplified JSON parser for basic structures
	    # In a real implementation, you'd use a proper JSON library
	    aResult = []
	    
	    # Remove whitespace and split by common patterns
	    cJSON = This.RemoveJSONWhitespace(cJSON)
	    
	    # This is a placeholder - implement proper JSON parsing based on Ring's capabilities
	    # or use an external JSON library if available
	    
	    return aResult
	
	def RemoveJSONWhitespace(cJSON)
	    cResult = ""
	    lInString = FALSE
	    
	    for i = 1 to len(cJSON)
	        cChar = cJSON[i]
	        if cChar = '"' and (i = 1 or cJSON[i-1] != '\')
	            lInString = !lInString
	        ok
	        
	        if lInString or (cChar != " " and cChar != tab and cChar != nl)
	            cResult += cChar
	        ok
	    next
	    
	    return cResult
	
	def FindLastChar(cStr, cChar)
	    for i = len(cStr) to 1 step -1
	        if cStr[i] = cChar
	            return i
	        ok
	    next
	    return 0
	
	# Helper method to clear the model
	def ClearModel()
	    @aTables = []
	    @aRelationships = []
	    @aConstraints = []
	    @aValidationErrors = []
	
	
	def AddRelationship(cFromTable, cToTable, cType, cField)
	    if isNull(cField)
	        cField = ""
	    ok
	    
	    aRelationship = [
	        :from = cFromTable,
	        :to = cToTable,
	        :from_table = cFromTable,
	        :to_table = cToTable,
	        :type = cType,
	        :field = cField,
	        :from_field = cField,
	        :to_field = "id"
	    ]
	    @aRelationships + aRelationship
