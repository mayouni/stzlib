
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
        
        for aConstraint in @aConstraints
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
