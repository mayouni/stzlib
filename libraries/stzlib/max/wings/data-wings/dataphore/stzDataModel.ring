
# Enhanced stzDataModel Implementation - Fixed Issues
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
        
        # Auto-infer relationships for this table
        This.InferRelationshipsForTable(aTable)
        return This

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

	# Field management with hashlists - FIXED VERSION
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

	# FIXED RemoveField - now properly detects breaking changes
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

	# FIXED relationship inference
	def InferRelationshipsForTable(aTable)
		for aField in aTable[:fields]
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

	# FIXED analysis methods - now provide better impact assessment
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

	# FIXED removal impact analysis - now properly detects relationships
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
		
		# Check relationships - FIXED to properly detect FK relationships
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
		return len(This.TableFields(cTableName))

		def CountFieldsForTable(cTableName)
			return This.CountTableFields(cTableName)

		def CountFieldsInTable(cTableName)
			return This.CountTableFields(cTableName)

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

	# Return relationships as expected format
	def Relationships()
		return @aRelationships

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
        
        return [
            :valid = (len(@aValidationErrors) = 0),
            :errors = @aValidationErrors,
            :error_count = len(@aValidationErrors),
            :tables_validated = nTablesValidated,
            :constraints_validated = nConstraintsValidated,
            :relationships_validated = nRelationshipsValidated,
            :summary = This.ValidationSummary()
        ]

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

	#=========#
	# EXPORT  #
	#=========#

    # Export model as DDL (basic implementation)
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
			return This.DDL()

		def ExportToDDL()
			return This.DDL()

		def ToDDL()
			return This.DDL()


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

# Export methods for different ERD tools
def ToMermaidERD()
    cMermaid = "erDiagram" + nl
    
    # Add entities with fields
    for aEntity in This.DiagramData()[:entities]
        cMermaid += "    " + aEntity[:name] + " {" + nl
        for aField in aEntity[:fields]
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
    for aRel in This.DiagramData()[:relationships]
        if aRel[:from_entity] != aRel[:to_entity]  # Skip self-referencing for basic ERD
            cMermaid += "    " + aRel[:from_entity] + " ||--o{ " + aRel[:to_entity] + ' : "' + aRel[:label] + '"' + nl
        ok
    next
    
    return cMermaid

def ToPlantUMLERD()
    cPlantUML = "@startuml" + nl
    cPlantUML += "!define ENTITY class" + nl + nl
    
    # Add entities
    for aEntity in This.DiagramData()[:entities]
        cPlantUML += "ENTITY " + aEntity[:name] + " {" + nl
        for aField in aEntity[:fields]
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
    for aRel in This.DiagramData()[:relationships]
        if aRel[:from_entity] != aRel[:to_entity]
            cPlantUML += aRel[:from_entity] + " ||--o{ " + aRel[:to_entity] + nl
        ok
    next
    
    cPlantUML += "@enduml"
    return cPlantUML

def ToJSONERD()
    # JSON format for tools like draw.io, Lucidchart APIs
    aERDData = This.DiagramData()
    cJSON = "{"
    cJSON += '"schema": "' + aERDData[:schema_name] + '",'
    cJSON += '"entities": ['
    
    for i = 1 to len(aERDData[:entities])
        aEntity = aERDData[:entities][i]
        cJSON += '{"name": "' + aEntity[:name] + '",'
        cJSON += '"fields": ['
        
        for j = 1 to len(aEntity[:fields])
            aField = aEntity[:fields][j]
            cJSON += '{"name": "' + aField[:name] + '",'
            cJSON += '"type": "' + aField[:type] + '",'
            cJSON += '"primary": ' + iff(aField[:is_primary], "true", "false") + ','
            cJSON += '"foreign": ' + iff(aField[:is_foreign], "true", "false") + '}'
            if j < len(aEntity[:fields])
                cJSON += ","
            ok
        next
        
        cJSON += "]}"
        if i < len(aERDData[:entities])
            cJSON += ","
        ok
    next
    
    cJSON += '],'
    cJSON += '"relationships": ['
    
    for i = 1 to len(aERDData[:relationships])
        aRel = aERDData[:relationships][i]
        cJSON += '{"from": "' + aRel[:from_entity] + '",'
        cJSON += '"to": "' + aRel[:to_entity] + '",'
        cJSON += '"type": "' + aRel[:relationship_type] + '",'
        cJSON += '"cardinality": "' + aRel[:cardinality] + '"}'
        if i < len(aERDData[:relationships])
            cJSON += ","
        ok
    next
    
    cJSON += "]}"
    return cJSON
