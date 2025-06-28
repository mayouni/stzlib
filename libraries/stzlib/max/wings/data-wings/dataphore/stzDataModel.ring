# Enhanced stzDataModel Implementation - Hashlist-Based Data Interchange
# Performance optimized with pure Ring data types

func IsDataTableHashlist(paTable)
	if NOT isList(paTable)
		return FALSE
	ok
	
	aRequiredKeys = [:name, :fields]
	for cKey in aRequiredKeys
		if NOT HasKey(paTable, cKey)
			return FALSE
		ok
	next
	
	return TRUE

func IsFieldHashlist(paField)
	if NOT isList(paField)
		return FALSE
	ok
	
	aRequiredKeys = [:name, :type]
	for cKey in aRequiredKeys
		if NOT HasKey(paField, cKey)
			return FALSE
		ok
	next
	
	return TRUE

func IsListOfFieldHashlists(paList)
	if NOT isList(paList)
		return FALSE
	ok
	
	for paField in paList
		if NOT IsFieldHashlist(paField)
			return FALSE
		ok
	next
	
	return TRUE

class stzDataModel from stzObject
	@cSchemaName
	@cSchemaVersion
	@aTables           # Changed from @aDataTables - now pure hashlists
	@aRelationships
	@aConstraints
	@aPerfHints
	@aValidationErrors
	@cForeignKeyMode # Can be "smart", "strict", or "permissive"
	@cActivePerfPlan

	@oPerfEngine # Hosts an instance of stzDataPerfEngine class
	@cActivePerfPlan  # Rreferences active performance plan (default, web, mobile, analytics...)
	
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

/*
	def AddTable(cTableName, aFields)
		# Convert field definitions to hashlists if needed
		aProcessedFields = []
		for aField in aFields
			if isList(aField) and len(aField) >= 2
				# Convert array format [name, type, options] to hashlist
				aOptions = []
				if len(aField) > 2
					aOptions = aField[3]
				ok

				aFieldHashlist = [
					:name = aField[1],
					:type = This.ProcessFieldType(aField[2]),
					:options = aOptions,
					:is_primary_key = (aField[2] = :primary_key),
					:is_required = (aField[2] = :required or aField[2] = :primary_key),
					:is_unique = (aField[2] = :unique or aField[2] = :primary_key)
				]
				aProcessedFields + aFieldHashlist
			but IsFieldHashlist(aField)
				aProcessedFields + aField
			else
				stzraise("Invalid field format in table " + cTableName)
			ok
		next

		# Create table hashlist
		aTableHashlist = [
			:name = cTableName,
			:fields = aProcessedFields,
			:created_at = Timestamp()
		]

		@aTables + aTableHashlist
		This.InferRelationshipsForTable(aTableHashlist)
		return This
*/
    # Add a table with field definitions (can be names or [name, type] pairs)
    def AddTable(cTableName, aFields)
        aProcessedFields = []
        for field in aFields
            if isList(field) and len(field) >= 2
                # Handle [fieldname, type] format
                aProcessedFields + [ :name = field[1], :type = field[2], :constraints = [] ]
                # Auto-add constraints based on type
                if field[2] = :primary_key
                    This.AddConstraint(cTableName, field[1], "PRIMARY KEY")
                but field[2] = :required
                    This.AddConstraint(cTableName, field[1], "NOT NULL")
                but field[2] = :email
                    This.AddConstraint(cTableName, field[1], "CHECK (email LIKE '%@%')")
                but isString(field[2]) and substr(upper(field[2]), "VARCHAR") > 0
                    # VARCHAR constraint already embedded in type
                ok
            else
                # Handle simple field name
                cFieldName = field
                if isList(field)
                    cFieldName = field[1]
                ok
                aProcessedFields + [ :name = cFieldName, :type = "text", :constraints = [] ]
            ok
        next
        
        aTable = [ :name = cTableName, :fields = aProcessedFields ]
        @aTables + aTable


	def Table(cTableName)
		for aTable in @aTables
			if aTable[:name] = cTableName
				return aTable
			ok
		next
		stzraise("Table not found: " + cTableName)

	def TablesNames()
		acNames = []
		for aTable in @aTables
			acNames + aTable[:name]
		next
		return acNames

	def CountTables()
		return len(@aTables)

	def CountFields()
		nResult = 0
		for aTable in @aTables
			nResult += len(aTable[:fields])
		next
		return nResult

    def Link(cFromTable, cToTable, cType, aOptions)
        if aOptions = NULL
            aOptions = []
        ok
        
        aRelationship = [
            :from = cFromTable,
            :to = cToTable,
            :type = cType,
            :inferred = false,
            :options = aOptions
        ]
        @aRelationships + aRelationship
        return This

    def Hierarchy(cTable, aOptions)
        if aOptions = NULL
            aOptions = [:parent_field = "parent_id"]
        ok
        
        # Hierarchy is a self-referencing relationship
        # Each record can have a parent (belongs_to self) and children (has_many self)
        aRelationship = [
            :from = cTable,
            :to = cTable,
            :type = "hierarchy",
            :inferred = false,
            :options = aOptions,
            :semantic_meaning = "Each " + SingularOf(cTable) + " can have a parent and multiple children, forming a tree structure"
        ]
        @aRelationships + aRelationship
        return This

    def Network(cTable, cRelationName, aOptions)
        if aOptions = NULL
            aOptions = [:bidirectional = true]
        ok
        
        aRelationship = [
            :from = cTable,
            :to = cTable,
            :type = "network",
            :name = cRelationName,
            :inferred = false,
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

		# Handle foreign key inference
		if cFieldType = :foreign_key
			This.InferRelationsFromFK(cTableName, cFieldName)
		ok

		return This.AnalyzeFieldAdditionImpact(cTableName, cFieldName, cFieldType, aOptions)

	def RemoveField(cTableName, cFieldName)
		aTable = This.Table(cTableName)
		
		# Analyze impact before removal
		aImpact = This.AnalyzeFieldRemovalImpact(cTableName, cFieldName)
		
		if aImpact[:breaking_changes] > 0
			cReasons = ""
			for i = 1 to len(aImpact[:breaking_reasons])
				cReasons += aImpact[:breaking_reasons][i]
				if i < len(aImpact[:breaking_reasons])
					cReasons += ", "
				ok
			next
			stzraise("Breaking change prevented: Cannot remove field '" + cFieldName + "' - " + cReasons)
		ok

		# Remove field from table
		aNewFields = []
		for aField in aTable[:fields]
			if aField[:name] != cFieldName
				aNewFields + aField
			ok
		next
		aTable[:fields] = aNewFields

		# Remove related relationships
		This.RemoveRelationshipsForField(cTableName, cFieldName)
		return aImpact

	def FieldExists(aTable, cFieldName)
		for aField in aTable[:fields]
			if aField[:name] = cFieldName
				return TRUE
			ok
		next
		return FALSE

	def FieldFromTable(aTable, cFieldName)
		for aField in aTable[:fields]
			if aField[:name] = cFieldName
				return aField
			ok
		next
		return NULL

	# Relationship management with hashlists
	def InferRelationshipsForTable(aTable)
		for aField in aTable[:fields]
			cFieldName = aField[:name]
			if right(cFieldName, 3) = "_id" and cFieldName != "id"
				cRelatedTable = left(cFieldName, len(cFieldName) - 3)
				
				# Add belongs_to relationship
				@aRelationships + [
					:type = "belongs_to",
					:from = aTable[:name],
					:to = PluralOf(cRelatedTable),
					:field = cFieldName,
					:inferred = TRUE
				]
				
				# Add corresponding has_many relationship
				@aRelationships + [
					:type = "has_many",
					:from = PluralOf(cRelatedTable),
					:to = aTable[:name],
					:field = cFieldName,
					:inferred = TRUE
				]
			ok
		next

	def InferRelationsFromFK(cFromTable, cForeignKeyField)
		cReferencedTable = This.TableNameFromFK(cForeignKeyField)
		if cReferencedTable != ""
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
		for aRel in @aRelationships
			bKeep = TRUE
			if HasKey(aRel, :field) and aRel[:field] = cFieldName and aRel[:from] = cTableName
				bKeep = FALSE
			ok
			if bKeep
				aNewRelationships + aRel
			ok
		next
		@aRelationships = aNewRelationships

	# Analysis methods returning hashlists
	def AnalyzeFieldAdditionImpact(cTableName, cFieldName, cFieldType, aOptions)
		return [
			:breaking_changes = 0,
			:perf_impact = "minimal",
			:migration_complexity = "simple",
			:affected_relationships = [],
			:recommendations = [],
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
		if aField[:is_primary_key]
			aImpact[:breaking_changes]++
			aImpact[:breaking_reasons] + "field is primary key"
			aImpact[:migration_complexity] = "complex"
		ok
		
		# Check relationships
		for aRel in @aRelationships
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
		for aTable in @aTables
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

        for aTable in @aTables
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

		# Generate a narration of aSummary like this:
		'
		This model contains 2 tables:
		- authors: 4 fields, 2 relationships
		- articles: 6 fields, 2 relationships
		
		Key relationships:
		- articles belongs_to authors
		- authors has_many articles
		'

	cText = "This model contains " + This.CountTables() + " tables:" + nl
        for aTable in @aTables
            cTableName = aTable[:name]
            nFields = len(aTable[:fields])
            nRelations = This.CountRelationshipsForTable(cTableName)
            cText += "• " + cTableName + ": " + nFields + " fields, " + nRelations + " relationships" + nl
        next
        cText += NL + "Key relationships:" + nl
        for aRel in @aRelationships
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
		return len(TableFields(cTableName))

		def CountFieldsForTable(cTableName)
			return This.TableFields(cTableName)

		def countFieldsInTable(cTableName)
			return This.TableFields(cTableName)

	def TableFieldsXT(cTableName)
		return This.TableFields(cTableName)  # Already returns hashlists

	def CountRelationshipsForTable(cTableName)
		nCount = 0
		for aRel in @aRelationships
			if aRel[:from] = cTableName or aRel[:to] = cTableName
				nCount++
			ok
		next
		return nCount

/*	# Validation with hashlist results
	def Validate()
		@aValidationErrors = []
		
		if len(@aTables) = 0
			@aValidationErrors + [
				:type = "schema",
				:severity = "error",
				:message = "Model has no tables",
				:table = "",
				:suggestions = ["Add at least one table using AddTable()"]
			]
		ok
		
		for aTable in @aTables
			This.ValidateTable(aTable)
		next
		
		for aRel in @aRelationships
			This.ValidateRelationship(aRel)
		next
		
		return [
			:valid = (len(@aValidationErrors) = 0),
			:errors = @aValidationErrors,
			:error_count = len(@aValidationErrors),
			:tables_validated = len(@aTables),
			:relationships_validated = len(@aRelationships)
		]
*/
	def ValidateTable(aTable)
		cTableName = aTable[:name]
		
		if cTableName = ""
			@aValidationErrors + [
				:type = "table",
				:severity = "error",
				:message = "Table has no name",
				:table = "",
				:suggestions = ["Use SetName() to assign a table name"]
			]
		ok
		
		if len(aTable[:fields]) = 0
			@aValidationErrors + [
				:type = "table",
				:severity = "error",
				:message = "Table has no fields",
				:table = cTableName,
				:suggestions = ["Add fields using AddField()"]
			]
		ok
		
		# Check for primary key
		nPrimaryKeys = 0
		for aField in aTable[:fields]
			if aField[:is_primary_key]
				nPrimaryKeys++
			ok
		next
		
		if nPrimaryKeys = 0
			@aValidationErrors + [
				:type = "table",
				:severity = "warning",
				:message = "Table has no primary key",
				:table = cTableName,
				:suggestions = ["Add a primary key field"]
			]
		but nPrimaryKeys > 1
			@aValidationErrors + [
				:type = "table",
				:severity = "error",
				:message = "Table has multiple primary keys",
				:table = cTableName,
				:suggestions = ["Use composite primary key or single primary key"]
			]
		ok

	def ValidateRelationship(aRel)
		cFromTable = aRel[:from]
		cToTable = aRel[:to]
		
		if not This.TableExists(cFromTable)
			@aValidationErrors + [
				:type = "relationship",
				:severity = "error",
				:message = "Relationship references non-existent table",
				:table = cFromTable,
				:related_table = cToTable,
				:suggestions = ["Create table '" + cFromTable + "'"]
			]
		ok
		
		if not This.TableExists(cToTable)
			@aValidationErrors + [
				:type = "relationship",
				:severity = "error",
				:message = "Relationship references non-existent table",
				:table = cToTable,
				:related_table = cFromTable,
				:suggestions = ["Create table '" + cToTable + "'"]
			]
		ok

	# Utility methods
	def TableExists(cTableName)
		for aTable in @aTables
			if aTable[:name] = cTableName
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
			return This.PluralOf(cBaseName)
		ok
		return ""

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
            cAfterRef = substr(cConstraint, nRefPos + 11)
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
                    cRefField = trim(substr(cAfterRef, nOpenParen + 1, nCloseParen - nOpenParen - 1))
                    return [ :table = cRefTable, :field = cRefField ]
                ok
            ok
        ok
        return NULL


	#==========================#
	#   VALIDATION MECHANISM   #
	#==========================#

    # Enhanced validation with detailed reporting
    def Validate()
        @aValidationErrors = []
        nTablesValidated = 0
        nConstraintsValidated = 0
        nRelationshipsValidated = 0
        
        # Table validation
        for aTable in @aTables
            nTablesValidated++
            if aTable[:name] = "" or aTable[:name] = NULL
                @aValidationErrors + [ :type = "table", :severity = "error", 
                                     :message = "Table has no name", :table = "" ]
                loop
            ok
            
            if len(aTable[:fields]) = 0
                @aValidationErrors + [ :type = "table", :severity = "error",
                                     :message = "Table '" + aTable[:name] + "' has no fields", 
                                     :table = aTable[:name] ]
            ok
            
            # Check for duplicate field names
            aFieldNames = []
            for aField in aTable[:fields]
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
        for aConstraint in @aConstraints
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
        return NULL

    # Get table schema information
    def TableSchema(cTableName)
        aTable = This.FindTable(cTableName)
        if aTable = NULL
            return NULL
        ok
        
        aSchema = [
            :name = aTable[:name],
            :fields = aTable[:fields],
            :constraints = [],
            :relationships = []
        ]
        
        # Add constraints for this table
        for aConstraint in @aConstraints
            if aConstraint[:table] = cTableName
                aSchema[:constraints] + aConstraint
            ok
        next
        
        # Add relationships
        for aRel in @aRelationships
            if aRel[:from_table] = cTableName or aRel[:to_table] = cTableName
                aSchema[:relationships] + aRel
            ok
        next
        
        return aSchema

    # Get all relationships in the model
    def Relationships()
        return @aRelationships

	#=========#
	# EXPORT  #
	#=========#

    # Export model as DDL (basic implementation)
	#NOTE //Data definition language (DDL) describes the portion
	# of SQL that creates, alters, and deletes database objects.

    def DDL()
        cDDL = ""
        
        for aTable in @aTables
            cDDL += "CREATE TABLE " + aTable[:name] + " (" + nl
            
            for i = 1 to len(aTable[:fields])
                aField = aTable[:fields][i]
                cDDL += "    " + aField[:name] + " " + aField[:type]
                
                if i < len(aTable[:fields])
                    cDDL += ","
                ok
                cDDL += nl
            next
            
            cDDL += ");" + nl + nl
        next
        
        # Add constraints
        for aConstraint in @aConstraints
            if aConstraint[:type] != "primary_key"  # PKs usually inline
                cDDL += "ALTER TABLE " + aConstraint[:table] + 
                       " ADD CONSTRAINT " + aConstraint[:constraint] + ";" + nl
            ok
        next
        
        return cDDL

		def ExportDDL()
			return This.DDl()

		def ExportToDDL()
			return This.DDl()

		def ToDDL()
			return This.DDl()

	# Exproting the data model as an ERD diagram structure
	# ~> for use with visualization tools

    def DiagramData()
        aEntities = []
        aConnections = []
        
        # Create entities from tables
		nLen = len(@aTables)
        for i = 1 to nLen
            aEntity = [
                :name = @aTables[i][:name],
                :field_count = this.CountFieldsInTable(@aTables[i][:name]),
                :type = "table"
            ]
            aEntities + aEntity
        next
        
        # Create connections from relationships
		nLen = len(@aRelationships)
        for i = 1 to nLen
            if @aRelationships[i][:from] != @aRelationships[i][:to]  # Skip self-referencing for main diagram
                aConnection = [
                    :from = @aRelationships[i][:from],
                    :to = @aRelationships[i][:to],
                    :type = @aRelationships[i][:type],
                    :inferred = @aRelationships[i][:inferred]
                ]
                aConnections + aConnection
            ok
        next
        
        return [
            :entities = aEntities,
            :connections = aConnections,
            :self_referencing = This.SelfReferencingTables()
        ]

	    def VizData()
	        return this.DiagramData()
	
	    def ERDData()
	        return This.DiagramData()

		def ERD()
			return This.DiagramData()

		def ToERD()
			return This.DiagramData()
