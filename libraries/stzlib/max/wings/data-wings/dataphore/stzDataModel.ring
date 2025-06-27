# Enhanced stzDataModel Implementation
# Fixes: missing methods, improved foreign key inference, constraint support

class stzDataModel from stzObject
    @cSchemaName
    @cSchemaVersion
    @aoTables
    @aRelationships
    @aConstraints
    @aPerfHints
    @aValidationErrors
    @cForeignKeyMode  # New: controls foreign key inference behavior
						# Can be "smart", "strict", or "permissive"

	@oPerfEngine = new stzDataPerfEngine()
	@cActivePerfPlan  # Rreferences active performance plan (default, web, mobile, analytics...)

    def init(p)
        if isString(p)
            @cSchemaName = p
            @cSchemaVersion = "1.0"
        but isList(p) and stzlen(p) = 2
            @cSchemaName = p[1]
            @cSchemaVersion = p[2]
        else
            @cSchemaName = "default"
            @cSchemaVersion = "1.0"
        ok
        
        @aoTables = []
        @aRelationships = []
        @aConstraints = []
        @aPerfHints = []
        @aValidationErrors = []
        @cForeignKeyMode = "smart"  # Options: "strict", "smart", "permissive"
		@cActivePerfPlan = "default"

    # Configuration methods
    def SetForeignKeyInferenceMode(cMode)
        # "strict" - only infer if tar table exists
        # "smart" - warn but proceed (default)
        # "permissive" - create placeholder tables
        @cForeignKeyMode = cMode
        return This

    def FKMode()
        return @cForeignKeyMode

		def ForeignKeyInferenceMode()
			return @cForeignKeyMode

    # ting the content of the class data containers
    def SchemaName()
        return @cSchemaName

    def SchemaVersion()
        return @cSchemaVersion

    def Tables()
        return @aoTables

    def Relations()
        return @aRelationships

    	def Rels()
       	 return @aRelationships

    	def Relationships()
       	 return @aRelationships

    def Constraints()
        return @aConstraints

    def PerfHintsXT()
		This.AnalyzePerformance()
        return @aPerfHints

	    def PerformanceHintsXT()
	        return This.PerfHintsXT()

		def PerfRecommendationsXT()
			return This.PerfHintsXT()

		def PerformanceRecommendationsXT()
			return This.PerfHintsXT()


    def ValidationErrors()
		This.Validate()
        return @aValidationErrors

    # Designing the data model
    def AddTable(cTableName, aFields)
        if not isString(cTableName) or cTableName = ""
            raise("Table name must be a non-empty string")
        ok
        
        if not isList(aFields) or stzlen(aFields) = 0
            raise("Fields must be a non-empty list")
        ok
        
        # Create table definition
        oTable = new stzDataTable()
        oTable.SetName(cTableName)
        
        # Process each field
        nLen = len(aFields)

        for i = 1 to nLen
            if not isList(aFields[i]) or stzlen(aFields[i]) < 2
                raise("Each field must be [name, type] or [name, type, options]")
            ok
            
            cFieldName = aFields[i][1]
            cFieldType = aFields[i][2]
            aOptions = []
            if stzlen(aFields[i]) > 2
                aOptions = aFields[i][3]
            ok
            
            # Create field with proper name and type
            oField = new stzField(cFieldName, cFieldType, aOptions)
            oTable.AddField(oField)
            
            # Enhanced foreign key inference with mode awareness
            if cFieldType = :foreign_key
                This.InferRelationsFromFK(cTableName, cFieldName)
            ok
        next
        
        @aoTables + oTable
        return This

    # NEW METHOD: AddField - Add a field to an existing table
    def AddField(cTableName, cFieldName, cFieldType, aOptions)
        if aOptions = NULL
            aOptions = []
        ok
        
        # Find the table
        oTable = This.Table(cTableName)
        if oTable = NULL
            raise("Table '" + cTableName + "' not found")
        ok
        
        # Check if field already exists
        if This.FieldExists(oTable, cFieldName)
            raise("Field '" + cFieldName + "' already exists in table '" + cTableName + "'")
        ok
        
        # Create and add the field
        oField = new stzField(cFieldName, cFieldType, aOptions)
        oTable.AddField(oField)
        
        # Handle foreign key inference
        if cFieldType = :foreign_key
            This.InferRelationsFromFK(cTableName, cFieldName)
        ok
        
        # Return impact analysis
        return This.AnalyzeFieldAdditionImpact(cTableName, cFieldName, cFieldType, aOptions)

    # NEW METHOD: RemoveField - Remove a field from an existing table
    def RemoveField(cTableName, cFieldName)
        # Find the table
        oTable = This.Table(cTableName)
        if oTable = NULL
            raise("Table '" + cTableName + "' not found")
        ok
        
        # Check if field exists
        if not This.FieldExists(oTable, cFieldName)
            raise("Field '" + cFieldName + "' not found in table '" + cTableName + "'")
        ok
        
        # Analyze impact before removal
        aImpact = This.AnalyzeFieldRemovalImpact(cTableName, cFieldName)
        
        # Check for breaking changes
        if aImpact[:breaking_changes] > 0
            aBreakingReasons = aImpact[:breaking_reasons]
            cReasons = ""
            nLen = len(aBreakingReasons)
            for i = 1 to nLen
                cReasons += aBreakingReasons[i]
                if i < nLen
                    cReasons += ", "
                ok
            next
            raise("Breaking change prevented: Cannot remove field '" + cFieldName + "' - " + cReasons)
        ok
        
        # Remove the field
        oTable.RemoveField(cFieldName)
        
        # Remove related relationships
        This.RemoveRelationshipsForField(cTableName, cFieldName)
        
        return aImpact

    # NEW METHOD: Check if field exists in table
    def FieldExists(oTable, cFieldName)
        nLen = oTable.FieldCount()
        for i = 1 to nLen
            oField = oTable.Field(i)
            if oField.Name() = cFieldName
                return true
            ok
        next
        return false

    # NEW METHOD: Analyze impact of adding a field
    def FieldAdditionImpact(cTableName, cFieldName, cFieldType, aOptions)
        aImpact = [
            :breaking_changes = 0,
            :performance_impact = "minimal",
            :migration_complexity = "simple",
            :affected_relationships = [],
            :recommendations = []
        ]
        
        # Check if it's a required field without default
        bRequired = (cFieldType = :required or (isList(aOptions) and find(aOptions, :required) > 0))
        bHasDefault = (isList(aOptions) and find(aOptions, :default) > 0)
        
        if bRequired and not bHasDefault
            aImpact[:breaking_changes] = 1
            aImpact[:migration_complexity] = "moderate"
            aImpact[:recommendations] + "Consider adding a default value for required field"
        ok
        
        # Check for foreign key relationships
        if cFieldType = :foreign_key
            cReferencedTable = This.TableNameFromFK(cFieldName)
            if cReferencedTable != "" and This.TableExists(cReferencedTable)
                aImpact[:affected_relationships] + [
                    :type = "new_foreign_key",
                    :from = cTableName,
                    :to = cReferencedTable,
                    :field = cFieldName
                ]
                aImpact[:recommendations] + "New relationship created with " + cReferencedTable
            ok
        ok
        
        # Performance considerations
        if cFieldType = :text or cFieldType = "text"
            aImpact[:performance_impact] = "low"
            aImpact[:recommendations] + "Large text fields may impact query performance"
        ok
        
        return aImpact

		def AnalyzeFieldAdditionImpact(cTableName, cFieldName, cFieldType, aOptions)
			return This.FieldAdditionImpact(cTableName, cFieldName, cFieldType, aOptions)

    # NEW METHOD: Analyze impact of removing a field
    def FieldRemovalImpact(cTableName, cFieldName)
        aImpact = [
            :breaking_changes = 0,
            :affected_relationships = [],
            :migration_complexity = "simple",
            :breaking_reasons = []
        ]
        
        # Find the field
        oTable = This.Table(cTableName)
        oField = This.FieldFromTable(oTable, cFieldName)
        
        if oField = NULL
            return aImpact
        ok
        
        # Check if it's a primary key
        if oField.IsPrimaryKey()
            aImpact[:breaking_changes]++
            aImpact[:breaking_reasons] + "field is primary key"
            aImpact[:migration_complexity] = "complex"
        ok
        
        # Check if it's used in relationships
        nLen = len(@aRelationships)
        for i = 1 to nLen
            aRel = @aRelationships[i]
            if find(aRel, :field) > 0 and aRel[:field] = cFieldName and aRel[:from] = cTableName
                aImpact[:breaking_changes]++
                aImpact[:breaking_reasons] + "breaks relationship with " + aRel[:to]
                aImpact[:affected_relationships] + aRel
                aImpact[:migration_complexity] = "complex"
            ok
        next
        
        # Check if it's a foreign key
        if right(cFieldName, 3) = "_id" and not oField.IsPrimaryKey()
            # This might be a foreign key
            nLen = len(@aRelationships)
            for i = 1 to nLen
                aRel = @aRelationships[i]
                if aRel[:from] = cTableName and find(aRel, :field) > 0 and aRel[:field] = cFieldName
                    aImpact[:breaking_changes]++
                    aImpact[:breaking_reasons] + "breaks foreign key relationship"
                    aImpact[:affected_relationships] + aRel
                ok
            next
        ok
        
        return aImpact

		def AnalyzeFieldRemovalImpact(cTableName, cFieldName)
			return This.FieldRemovalImpact(cTableName, cFieldName)

    # NEW METHOD:  field from table by name
    def FieldFromTable(oTable, cFieldName)
        nLen = oTable.FieldCount()
        for i = 1 to nLen
            oField = oTable.Field(i)
            if oField.Name() = cFieldName
                return oField
            ok
        next
        return NULL

    # NEW METHOD: Remove relationships that depend on a field
    def RemoveRelationsForField(cTableName, cFieldName)
        aNewRelationships = []
        nLen = len(@aRelationships)
        for i = 1 to nLen
            aRel = @aRelationships[i]
            bKeep = true
            
            # Remove if this field is the foreign key
            if find(aRel, :field) > 0 and aRel[:field] = cFieldName and aRel[:from] = cTableName
                bKeep = false
            ok
            
            if bKeep
                aNewRelationships + aRel
            ok
        next
        @aRelationships = aNewRelationships

		def RemoveRelationshipsForField(cTableName, cFieldName)
			This.RemoveRelationsForField(cTableName, cFieldName)

		def RemoveRelForField(cTableName, cFieldName)
			This.RemoveRelationsForField(cTableName, cFieldName)

    def InferRelationsFromFK(cFromTable, cForeignKeyField)
        # Extract referenced table name from foreign key field
        cReferencedTable = This.TableNameFromFK(cForeignKeyField)
        
        if cReferencedTable != ""
            # Check inference mode behavior
            switch @cForeignKeyMode
            on "strict"
                if not This.TableExists(cReferencedTable)
                    raise("Foreign key '" + cForeignKeyField + "' references non-existent table '" + cReferencedTable + "'")
                ok
            on "smart"
                if not This.TableExists(cReferencedTable)
                    # Add warning but continue
                    @aValidationErrors + [
                        :type = "foreign_key_inference",
                        :severity = "warning",
                        :message = "Foreign key references table that doesn't exist yet",
                        :table = cFromTable,
                        :field = cForeignKeyField,
                        :referenced_table = cReferencedTable,
                        :suggestions = [
                            "Add table '" + cReferencedTable + "' before using this foreign key",
                            "Or use SetForeignKeyInferenceMode('permissive') to auto-create placeholder tables"
                        ]
                    ]
                ok
            on "permissive"
                if not This.TableExists(cReferencedTable)
                    # Auto-create placeholder table
                    This.AddPlaceholderTable(cReferencedTable)
                ok
            off
            
            # Create belongs_to relationship
            aRelationship = [
                :from = cFromTable,
                :to = cReferencedTable, 
                :type = "belongs_to",
                :inferred = true,
                :field = cForeignKeyField,
                :semantic_meaning = "Each " + Singular(cFromTable) + " belongs to one " + Singular(cReferencedTable)
            ]
            @aRelationships + aRelationship
            
            # Create inverse has_many relationship
            aInverseRelationship = [
                :from = cReferencedTable,
                :to = cFromTable,
                :type = "has_many", 
                :inferred = true,
                :field = cForeignKeyField,
                :semantic_meaning = "Each " + SingularOf(cReferencedTable) + " can have many " + cFromTable
            ]
            @aRelationships + aInverseRelationship
        ok

		def InferRelationshipsFromForeignKey(cFromTable, cForeignKeyField)
			This.InferRelationsFromFK(cFromTable, cForeignKeyField)


    def AddPlaceholderTable(cTableName)
        # Create minimal table structure
        oTable = new stzDataTable()
        oTable.SetName(cTableName)
        
        # Add minimal primary key
        oField = new stzField("id", :primary_key, [])
        oTable.AddField(oField)
        
        @aoTables + oTable
        
        # Log the auto-creation
        @aValidationErrors + [
            :type = "auto_creation",
            :severity = "info",
            :message = "Auto-created placeholder table",
            :table = cTableName,
            :suggestions = ["Complete the table definition with proper fields"]
        ]

    def TableNameFromFK(cForeignKeyField)
        # Handle special cases for self-referencing
        if cForeignKeyField = "parent_id"
            return ""  # Self-referencing, no external table
        ok
        
        # Remove _id suffix and pluralize
        if right(cForeignKeyField, 3) = "_id"
            cBaseName = left(cForeignKeyField, stzlen(cForeignKeyField) - 3)
            return PluralOf(cBaseName)
        ok
        return ""

		def ExtractTableNameFromForeignKey(cForeignKeyField)
			return This.TableNameFromFK(cForeignKeyField)

    # Missing method: AddConstraint
    def AddConstraint(cTableName, cFieldName, cConstraint)
        aConstraintDef = [
            :table = cTableName,
            :field = cFieldName,
            :constraint = cConstraint,
            :type = This.ConstraintType(cConstraint)
        ]
        @aConstraints + aConstraintDef
        return This

    def ConstraintType(cConstraint)
        cUpper = upper(cConstraint)
        if substr(cUpper, "CHECK") > 0
            return "check"
        but substr(cUpper, "UNIQUE") > 0
            return "unique"
        but substr(cUpper, "FOREIGN KEY") > 0
            return "foreign_key"
        but substr(cUpper, "PRIMARY KEY") > 0
            return "primary_key"
        else
            return "custom"
        ok

    # Missing method: TableAnalysis
    def TableAnalysis()
        aAnalysis = []
        
        nLen = len(@aoTables)

        for i = 1 to nLen
            cTableName = @aoTables[i].Name()
            nFieldCount = @aoTables[i].FieldCount()
            nRelationshipCount = This.NumberOfRelationsInTable(cTableName)
            
            # Analyze table complexity
            cComplexity = "simple"
            if nFieldCount > 10 or nRelationshipCount > 5
                cComplexity = "moderate"
            ok
            if nFieldCount > 20 or nRelationshipCount > 10
                cComplexity = "complex"
            ok
            
            # Check for potential issues
            aIssues = []
            if nFieldCount = 1  # Only primary key
                aIssues + "Table has minimal fields - may need more attributes"
            ok
            if nRelationshipCount = 0
                aIssues + "Table is isolated - consider relationships with other tables"
            ok
            if nRelationshipCount > 8
                aIssues + "Table has many relationships - consider normalization"
            ok
            
            aTableAnalysis = [
                :table = cTableName,
                :field_count = nFieldCount,
                :relationship_count = nRelationshipCount,
                :complexity = cComplexity,
                :issues = aIssues,
                :primary_keys = This.NumberOfPrimaryKeysInTable(@aoTables[i]),
                :foreign_keys = This.NumberOftForeignKeysInTable(@aoTables[i])
            ]
            aAnalysis + aTableAnalysis
        next
        
        return aAnalysis

	def TablesNames()
		acResult = []
		nLen = len(@aoTables)
		for i = 1 to nLen
			acResult + @aoTables[i].Name()
		next
		return acResult

    def NumberOfPrimaryKeysInTable(oTable)
        nCount = 0
        for i = 1 to oTable.FieldCount()
            oField = oTable.Field(i)
            if oField.IsPrimaryKey()
                nCount++
            ok
        next
        return nCount

		def NumberOfPKInTable(oTable)
			return This.NumberOfPrimaryKeysInTable(oTable)

		def CountPrimaryKeysInTable(oTable)
			return This.NumberOfPrimaryKeysInTable(oTable)

		def CountPKInTable(oTable)
			return This.NumberOfPrimaryKeysInTable(oTable)


    def NumberOfFKInTable(oTable)
        nCount = 0
        for i = 1 to oTable.FieldCount()
            oField = oTable.Field(i)
            if right(oField.Name(), 3) = "_id" and not oField.IsPrimaryKey()
                nCount++
            ok
        next
        return nCount

		def NumberOfForeignKeysInTable(oTable)
			return This.NumberOfFKInTable(oTable)

		def CountFKInTable(oTable)
			return This.NumberOfFKInTable(oTable)

		def CountForeignKeysInTable(oTable)
			return This.NumberOfFKInTable(oTable)

    # Enhanced Explain method with better naming
	def Summary()
	    aModelData = [
	        :tables = [],
	        :relationships = @aRelationships  # This should exist in your class
	    ]
	    
	    # Add table analysis
	    aTablesNames = This.TablesNames()  # Assuming @aoTables is a hash/object
	    nLen = len(aTablesNames)

	    for i = 1 to nLen

	        oTable = @aoTables[i]
	        cTableName = oTable.Name()

	        aTableData = [
	            :name = cTableName,
	            :field_count = len(oTable.Fields()),  # Adjust based on your table structure
	            :relationship_count = This.CountRelationsForTable(cTableName),
	            :fields = This.TablesFieldsForAnalysis(cTableName)
	        ]

	        aModelData[:tables] + aTableData
	    next
	    
	    return aModelData

    # New method: Generate narrative explanation
    def Explain()
        cExplanation = "Data Model: " + @cSchemaName + " (v" + @cSchemaVersion + ")" + NL + NL
        
        # Tables overview
        cExplanation += "This model contains " + stzlen(@aoTables) + " tables:" + NL
        nLen = len(@aoTables)

        for i = 1 to nLen
            cTableName = @aoTables[i].Name()
            nFields = @aoTables[i].FieldCount()
            nRels = This.NumberOfRelationsInTable(cTableName)
            
            cExplanation += "- " + cTableName + ": " + nFields + " fields, " + nRels + " relationships" + NL
        next
        
        # Relationships overview
        if stzlen(@aRelationships) > 0
            cExplanation += NL + "Key relationships:" + NL

            nLen = len(@aRelationships)
            for i = 1 to nLen
                if find(@aRelationships[i], :semantic_meaning) > 0
                    cExplanation += "- " + @aRelationships[i][:semantic_meaning] + NL
                else
                    cExplanation += "- " + @aRelationships[i][:from] + " " + @aRelationships[i][:type] + " " + @aRelationships[i][:to] + NL
                ok
            next
        ok
        
        # Issues and recommendations
        if stzlen(@aValidationErrors) > 0
            cExplanation += NL + "Recommendations:" + NL
            nLen = len(@aValidationErrors)

            for i = 1 to nLen
                if @aValidationErrors[i][:severity] = "warning" or @aValidationErrors[i][:severity] = "info"
                    cExplanation += "- " + @aValidationErrors[i][:message] + NL
                ok
            next
        ok
        
        return cExplanation

    def RelationsSummary()
        aResult = []
        nLen = len(@aRelationships)

        for i = 1 to nLen
            aResult + [
                :from = @aRelationships[i][:from],
                :to = @aRelationships[i][:to],
                :type = @aRelationships[i][:type],
                :inferred = @aRelationships[i][:inferred]
            ]
        next
        return aResult

		def RelsSummary()
			return This.RelationsSummary()

		def RelationshipsSummary()
			return This.RelationsSummary()


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

    # Continue with validation and other methods...
    def Validate()
        @aValidationErrors = []
        
        # Validate tables exist
        if stzlen(@aoTables) = 0
            @aValidationErrors + [
                :type = "schema",
                :severity = "error", 
                :message = "Model has no tables Addd",
                :table = "",
                :suggestions = ["Add at least one table using AddTable()"]
            ]
        ok
        
        # Validate each table
        nLen = len(@aoTables)

        for i = 1 to nLen
            This.ValidateTable(@aoTables[i])
        next
        
        # Validate relationships
        nLen = len(@aRelationships)
        for i = 1 to nLen
            This.ValidateRelationship(@aRelationships[i])
        next
        
        return [
            :valid = (stzlen(@aValidationErrors) = 0),
            :errors = @aValidationErrors,
            :error_count = stzlen(@aValidationErrors),
            :tables_validated = stzlen(@aoTables),
            :relationships_validated = stzlen(@aRelationships)
        ]

    def ValidateTable(oTable)
        cTableName = oTable.Name()
        
        if cTableName = ""
            @aValidationErrors + [
                :type = "table",
                :severity = "error",
                :message = "Table has no name",
                :table = "",
                :suggestions = ["Use SetName() to assign a table name"]
            ]
        ok
        
        if oTable.FieldCount() = 0
            @aValidationErrors + [
                :type = "table",
                :severity = "error", 
                :message = "Table has no fields",
                :table = cTableName,
                :suggestions = ["Add fields using AddField() or AddTable()"]
            ]
        ok
        
        # Check for primary key
        nPrimaryKeys = 0
        for i = 1 to oTable.FieldCount()
            oField = oTable.Field(i)
            if oField.IsPrimaryKey()
                nPrimaryKeys++
            ok
        next
        
        if nPrimaryKeys = 0
            @aValidationErrors + [
                :type = "table",
                :severity = "warning",
                :message = "Table has no primary key",
                :table = cTableName,
                :suggestions = ["Add a primary key field for better performance and data integrity"]
            ]
        but nPrimaryKeys > 1
            @aValidationErrors + [
                :type = "table",
                :severity = "error",
                :message = "Table has multiple primary keys",
                :table = cTableName,
                :suggestions = ["Use composite primary key or designate single primary key"]
            ]
        ok

    def ValidateRelation(aRel)
        cFromTable = aRel[:from]
        cToTable = aRel[:to]
        
        # Check if referenced tables exist
        if not This.TableExists(cFromTable)
            @aValidationErrors + [
                :type = "relationship",
                :severity = "error",
                :message = "Relationship references non-existent table",
                :table = cFromTable,
                :related_table = cToTable,
                :suggestions = ["Create table '" + cFromTable + "' or fix relationship definition"]
            ]
        ok
        
        if not This.TableExists(cToTable)
            @aValidationErrors + [
                :type = "relationship", 
                :severity = "error",
                :message = "Relationship references non-existent table",
                :table = cToTable,
                :related_table = cFromTable,
                :suggestions = ["Create table '" + cToTable + "' or fix relationship definition"]
            ]
        ok

		def ValidateRelationship(aRel)
			This.ValidateRelation(aRel)

    def TableExists(cTableName)
        nLen = len(@aoTables)
        for i = 1 to nLen
            if @aoTables[i].Name() = cTableName
                return true
            ok
        next
        return false

    def Table(cTableName)
        nLen = len(@aoTables)
        for i = 1 to nLen
            if @aoTables[i].Name() = cTableName
                return @aoTables[i]
            ok
        next
        return NULL

    def CountTableConnections(cTableName)
        nCount = 0
        nLen = len(@aRelationships)
        for i = 1 to nLen
            if @aRelationships[i][:from] = cTableName or @aRelationships[i][:to] = cTableName
                nCount++
            ok
        next
        return nCount

		def NumberOfTableConnections(cTableName)
			return This.CountTableConnections(cTableName)

    def TableFieldsInfo(oTable)
        aFields = []
        nLen = oTable.FieldCount()
        for i = 1 to nLen
            oField = oTable.Field(i)
            aFieldInfo = [
                :name = oField.Name(),
                :type = oField.Type(),
                :is_primary_key = oField.IsPrimaryKey(),
                :is_required = oField.IsRequired(),
                :is_unique = oField.IsUnique()
            ]
            aFields + aFieldInfo
        next
        return aFields

    def NumberOfRelationsInTable(cTableName)
        nCount = 0
        nLen = len(@aRelationships)
        for i = 1 to nLen
            if @aRelationships[i][:from] = cTableName or @aRelationships[i][:to] = cTableName
                nCount++
            ok
        next
        return nCount

		def NumberOfRelationshipsInTable(cTableName)
			return This.NumberOfRelationsInTable(cTableName)

		def NumberOfRelsInTable(cTableName)
			return This.NumberOfRelationsInTable(cTableName)

		def CountRelationshipsInTable(cTableName)
			return This.NumberOfRelationsInTable(cTableName)

		def CountRelationsInTable(cTableName)
			return This.NumberOfRelationsInTable(cTableName)

		def CountRelsInTable(cTableName)
			return This.NumberOfRelationsInTable(cTableName)


	def NumberOfRelationsForTable(cTableName)
	    nCount = 0
	    nLen = len(@aRelationships)
	    for i = 1 to nLen
	        aRel = @aRelationships[i]
	        if aRel[:from] = cTableName or aRel[:to] = cTableName
	            nCount++
	        ok
	    next
	    return nCount
	
		def CountRelationshipsForTable(cTableName)
			return This.NumberOfRelationsForTable(cTableName)
	
		def CountRelationsForTable(cTableName)
			return This.NumberOfRelationsForTable(cTableName)
	
		def CountRelsForTable(cTableName)
			return This.NumberOfRelationsForTable(cTableName)
	
		def NumberOfRelsForTable(cTableName)
			return This.NumberOfRelationsForTable(cTableName)
	

	def TablesFieldsForAnalysis(cTableName)
	    # Return field structure that matches what the perf engine expects

		nLen = len(@aoTables)
	    aFields = []
	    
	    for i = 1 to nLen

	        oTable = @aoTables[i]
	        
	        # Get the raw field definitions from the table
	        aTableFields = oTable.Fields()  # Assuming this returns the field array
	        nLenTable = len(aTableFields)

	        for j = 1 to nLenTable

	            aFieldDef = aTableFields[j].Content()
	            
	            # Convert from stzDataModel format to perf engine format
	            # Input format: [ "field_name", :field_type ] or [ "field_name", "field_type" ]
	            cFieldName = aFieldDef[1]  # First element is field name
	            cFieldType = aFieldDef[2]  # Second element is field type
	            
	            # Convert symbolic types to string types for perf engine
	            if isString(cFieldType)
	                cTypeString = cFieldType
	            else
	                # Handle symbolic field types like :primary_key, :foreign_key, etc.

	                switch cFieldType

	                on :primary_key
	                    cTypeString = "integer"

	                on :foreign_key  
	                    cTypeString = "integer"

	                on :required
	                    cTypeString = "string"

	                on :email
	                    cTypeString = "string"

	                on :text
	                    cTypeString = "text"

	                on :longtext
	                    cTypeString = "longtext"

	                on :timestamp
	                    cTypeString = "timestamp"

	                on :datetime
	                    cTypeString = "datetime"

	                on :boolean
	                    cTypeString = "boolean"

	                on :unique
	                    cTypeString = "string"

	                other
	                    cTypeString = "string"  # Default fallback
	                off

	            ok
	            
	            # Add field in format expected by perf engine
	            aFields + [
	                :name = cFieldName,
	                :type = cTypeString
	            ]

	        next
	    next
	    
	    return aFields
	
		def TablesFieldsXT()
			return This.TablesFieldsForAnalysis()

		def TablesFields()
			return This.TablesFieldsForAnalysis()


    def DiagramData()
        aEntities = []
        aConnections = []
        
        # Create entities from tables
		nLen = len(@aoTables)
        for i = 1 to nLen
            aEntity = [
                :name = @aoTables[i].Name(),
                :field_count = @aoTables[i].FieldCount(),
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

    def SelfReferencingTables()
        aSelfRef = []
		nLen = len(@aRelationships)
        for i = 1 to nLen
            if @aRelationships[i][:from] = @aRelationships[i][:to]
                aSelfRef + [
                    :table = @aRelationships[i][:from],
                    :type = @aRelationships[i][:type]
                ]
            ok
        next
        return aSelfRef


    def TableSummary()
        aResult = []
		nLen = len(@aoTables)
        for i = 1 to nLen
            aTableInfo = [
                :name = @aoTables[i].Name(),
                :field_count = @aoTables[i].FieldCount(),
                :relationships = []
            ]
            
            # Add relationships for this table
			nLenRel = len(@aRelationships)
			for j = 1 to nLenRel
                if aRel[:from] = @aRelationships[j].Name() or @aRelationships[j][:to] = @aoTables[i].Name()
                    aTableInfo[:relationships] + @aRelationships[j]
                ok
            next
            
            aResult + aTableInfo
        next
        return aResult


    # Performance Plan Configuration
    def SetPerfPlan(cPlanName)
        @cActivePerfPlan = cPlanName
        @oPerfEngine.SetActivePlan(cPlanName)
        return This
    
		def SetPerformancePlan(cPlanName)
			return This.SetPerfPlan(cPlanName)

    def PerfPlan()
        return @cActivePerfPlan
    
		def PerformancePlan()
			 return @cActivePerfPlan

    def PerfPlans()
        aPlans = []
        aRuleSets = @oPerfEngine.rule_sets
        nLen = len(aRuleSets)
        for i = 1 to nLen
            aPlans + [
                :name = aRuleSets[i][:name],
                :Description = @oPerfEngine.PlanDescription(aRuleSets[i][:name])
            ]
        next
        return aPlans
    
		def PerfmancePlans()
			return This.PerfPlans()


    def AddPerfPlan(cPlanName, cDescription, aRules)
        aRulePlan = [
            :Description = cDescription,
            :priority_focus = ["custom"],
            :rules = aRules
        ]
        @oPerfEngine.AddPlan(cPlanName, aRulePlan)
        return This

		def AddPerformancePlan(cPlanName, cDescription, aRules)
			This.AddPerfPlan(cPlanName, cDescription, aRules)


	def SetPerfThreshold(cName, nValue)
		@oPerfEngine.SetThreshold(cName, nValue)

		def SetPerformanceThreshold(cName, nValue)
			This.SetPerfThreshold(cName, nValue)

	def PerfThreshold(cName)
		return @oPerfEngine.Threshold(cName)

		def PerformanceThreshold(cName)
			return This.PerfThreshold(cName)

	def PerfThresholds()
		return @oPerfEngine.Thresholds()

		def PerformanceThresholds()
			return This.PerfThresholds()

	def PerfPlanDescription(cPlanName)
		return @oPerfEngine.PlanDescription(cPlanName)

		def PerformancePlanDescription(cPlanName)
			return This.PerfPlanDescription(cPlanName)


    # Enhanced Performance Analysis with Rule Engine
    def AnalyzePerformance()
        @aPerfHints = []
        
        #  model data for rule evaluation
        aModelData = This.Summary()
   
        #  active rules from rule engine
        aActiveRules = @oPerfEngine.ActiveRules()

        # Evaluate each rule
        nLen = len(aActiveRules)
        for i = 1 to nLen
            aRule = aActiveRules[i]
            aRuleMatches = @oPerfEngine.EvaluateRule(aRule, aModelData)
            
            # Generate hints for each match
            nMatchLen = len(aRuleMatches)
            for j = 1 to nMatchLen
                aMatch = aRuleMatches[j]

				cAction = ""  # Initialize empty since action_template doesn't exist in the rule structure
				if HasKey(aRule, :action) and HasKey(aRule[:action], :Ring)
                	cAction = @oPerfEngine.GenerateActionFromTemplate(aRule[:action_template], aMatch)
                ok

                aHint = [
                    :rule_id = aRule[:id],
                    :type = aRule[:type],
                    :priority = aRule[:priority],
                    :performance_plan = @cActivePerfPlan,
                    :message = aRule[:message],
                    :action = cAction,
                    :performance_impact = aRule[:performance_impact],
                    :applies_to = aRule[:applies_to],
                    :Description_data = aMatch
                ]
                
                # Add table/field specific information
                if find(aMatch, :table) > 0
                    aHint[:table] = aMatch[:table]
                ok
                if find(aMatch, :field) > 0
                    aHint[:field] = aMatch[:field]
                ok
                if find(aMatch, :from_table) > 0
                    aHint[:from_table] = aMatch[:from_table]
                ok
                if find(aMatch, :to_table) > 0
                    aHint[:to_table] = aMatch[:to_table]
                ok
                
                @aPerfHints + aHint
            next
        next
        
        return @aPerfHints
    
		def AnalyzePerf()
			return This.AnalyzePerformance()

		def PerformanceAnalysis()
			return This.AnalyzePerformance()

		def PerfAnalysis()
			return This.AnalyzePerformance()

    def PerfReport()
        This.AnalyzePerformance()
        
        aReport = [
            :performance_plan = [
                :name = @cActivePerfPlan,
                :Description = @oPerfEngine.PlanDescription(@cActivePerfPlan)
            ],
            :summary = [
                :total_hints = stzlen(@aPerfHints),
                :critical_issues = This.CountHintsByPriority("critical"),
                :high_priority = This.CountHintsByPriority("high"),
                :medium_priority = This.CountHintsByPriority("medium"),
                :low_priority = This.CountHintsByPriority("low")
            ],
            :hints_by_category = This.GroupHintsByType(),
            :detailed_hints = @aPerfHints,
            :recommendations = This.TopRecommendations()
        ]
        
        return aReport

		def PerformanceReport()
			return This.PerfReport()
 
/*   
	def PerfHints()
		This.AnalyzePerformance()
		nLen = len(@aPerfHints)
		acResult = []
		for i = 1 to nLen
			acResult + @aPerfHints[i][:message]
		next
		return U(acResult)

		def PerformanceRecommendations()
			return This.PerfHints()

		def PerformanceHints()
			return This.PerfHints()

		def PerfRecommendations()
			return This.PerfHints()
*/

def PerfEngine()
	return @oPerfEngine

def PerfHints()
    # Get the performance engine
    oPerfEngine = This.PerfEngine()
    
    # Build model data structure that the perf engine expects
    aModelData = [
        :tables = This.BuildTablesData(),
        :relationships = This.BuildRelationshipsData()
    ]
    
    # Get active rules from the performance engine
    aActiveRules = oPerfEngine.ActiveRules()
    
    # Evaluate each rule and collect hints
    aHints = []
    
    nLen = len(aActiveRules)
    for i = 1 to nLen
        aRule = aActiveRules[i]
        
        # Evaluate the rule against our model data
        aRuleResults = oPerfEngine.EvalRule(aRule, aModelData)
        
        # If rule found issues, generate hints
        nResultLen = len(aRuleResults)
        for j = 1 to nResultLen
            aResult = aRuleResults[j]
            
            # Generate the hint message
            cHint = aRule[:message]
            
            # Generate SQL and Ring actions
            cSQLAction = ""
            cRingAction = ""
            
            if HasKey(aRule, :action) > 0
                if HasKey(aRule[:action], :SQL) > 0
                    cSQLAction = oPerfEngine.GenerateActionFromTemplate(aRule[:action][:SQL], aResult)
                ok
                
                if HasKey(aRule[:action], :Ring) > 0
                    cRingAction = oPerfEngine.GenerateActionFromTemplate(aRule[:action][:Ring], aResult)
                ok
            ok
            
            # Add complete hint
            aHints + [
                :rule_id = aRule[:id],
                :priority = aRule[:priority],
                :message = cHint,
                :table = iff(HasKey(aResult, :table), aResult[:table], ""),
                :field = iff(HasKey(aResult, :field), aResult[:field], ""),
                :sql_action = cSQLAction,
                :ring_action = cRingAction,
                :performance_impact = aRule[:performance_impact],
                :details = aResult
            ]
        next
    next
    
    return aHints

def TableFields(pcTableName)
	return This.Table(pcTableName).Fields()

# Helper method to build tables data for performance engine
def BuildTablesData()
    aTables = []
    
    # Get all tables from the model
    aTablesNames = This.TablesNames()
    
    nLen = len(aTablesNames)
    for i = 1 to nLen
        cTableName = aTablesNames[i]
        
        # Get table fields
        aTableFields = This.TableFields(cTableName)
        aFields = []
        
        # Convert fields to performance engine format
        nFieldLen = len(aTableFields)
        for j = 1 to nFieldLen
            aField = aTableFields[j].Content()
            aFields + [
                :name = aField[1],  # Field name
                :type = aField[2]   # Field type
            ]
        next
        
        # Count relationships for this table
        nRelCount = This.CountRelationshipsForTable(cTableName)
        
        aTables + [
            :name = cTableName,
            :fields = aFields,
            :field_count = len(aFields),
            :relationship_count = nRelCount
        ]
    next
    
    return aTables

# Helper method to build relationships data for performance engine  
def BuildRelationshipsData()
    aRelationships = []
    
    # This would extract relationship data from the model
    # For now, we'll build it based on foreign key fields
    
    aTablesNames = This.TablesNames()
    nLen = len(aTablesNames)
    
    for i = 1 to nLen
        cTableName = aTablesNames[i]
        aTableFields = This.TableFields(cTableName)
        
        nFieldLen = len(aTableFields)
        for j = 1 to nFieldLen
            aField = aTableFields[j].Content()
            
            # If field is foreign key, create belongs_to relationship
            if aField[2] = :foreign_key
                cFieldName = aField[1]
                
                # Extract related table name from field name (convention: table_id -> table)
                cRelatedTable = ""
                if substr(cFieldName, len(cFieldName)-2, 3) = "_id"
                    cRelatedTable = substr(cFieldName, 1, len(cFieldName)-3)
                ok
                
                if cRelatedTable != ""
                    aRelationships + [
                        :type = "belongs_to",
                        :from = cTableName,
                        :to = cRelatedTable,
                        :field = cFieldName
                    ]
                    
                    # Also add the inverse has_many relationship
                    aRelationships + [
                        :type = "has_many", 
                        :from = cRelatedTable,
                        :to = cTableName
                    ]
                ok
            ok
        next
    next
    
    return aRelationships

    def CountHintsByPriority(cPriority)
        nCount = 0
        nLen = len(@aPerfHints)
        for i = 1 to nLen
            if @aPerfHints[i][:priority] = cPriority
                nCount++
            ok
        next
        return nCount
    
		def NumberOfHintsByPriority(cPriority)
			return This.CountHintsByPriority(cPriority)


    def GroupHintsByType()
        aGrouped = []
        aTypes = []
        
        # Collect unique types
        nLen = len(@aPerfHints)
        for i = 1 to nLen
            cType = @aPerfHints[i][:type]
            if find(aTypes, cType) = 0
                aTypes + cType
            ok
        next
        
        # Group hints by type
        nTypeLen = len(aTypes)
        for i = 1 to nTypeLen
            cType = aTypes[i]
            aHintsForType = []
            
            for j = 1 to nLen
                if @aPerfHints[j][:type] = cType
                    aHintsForType + @aPerfHints[j]
                ok
            next
            
            aGrouped + [
                :type = cType,
                :count = stzlen(aHintsForType),
                :hints = aHintsForType
            ]
        next
        
        return aGrouped
    
    def TopRecommendations()
        aRecommendations = []
        
        #  critical and high priority hints
        nLen = len(@aPerfHints)
        for i = 1 to nLen
            aHint = @aPerfHints[i]
            if aHint[:priority] = "critical" or aHint[:priority] = "high"
                aRecommendations + [
                    :priority = aHint[:priority],
                    :impact = aHint[:performance_impact],
                    :recommendation = aHint[:message],
                    :action = aHint[:action]
                ]
            ok
        next
        
        return aRecommendations

		def GenerateTopRecommendations()
			return This.TopRecommendations()


# Supporting classes remain the same
class stzDataTable from stzObject
    @cName
    @aFields
    
    def init()
        @cName = ""
        @aFields = []
    
    def SetName(cName)
        @cName = cName
    
    def Name()
        return @cName
    
    def AddField(oField)
        @aFields + oField
    
    def FieldCount()
        return stzlen(@aFields)
    
    def Field(nIndex)
        if nIndex >= 1 and nIndex <= stzlen(@aFields)
            return @aFields[nIndex]
        ok
        return NULL
    
    def Fields()
        return @aFields

class stzField from stzObject
    @cName
    @cType
    @aOptions
    @bIsPrimaryKey
    @is_required
    @is_unique
    
    def init(cName, cType, aOptions)
        @cName = cName
        @cType = This.ProcessFieldType(cType)
        
        if aOptions = NULL
            aOptions = []
        ok
        @aOptions = aOptions
        
        # Set flags based on type and options
        @bIsPrimaryKey = (cType = :primary_key)
        @is_required = (cType = :required or @bIsPrimaryKey)
        @is_unique = (cType = :unique or @bIsPrimaryKey)
    
    def ProcessFieldType(cType)
        # Convert symbols to appropriate SQL types
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
    
    def Name()
        return @cName
    
    def Type()
        return @cType
    
    def IsPrimaryKey()
        return @bIsPrimaryKey
    
    def IsRequired()
        return @is_required
    
    def IsUnique()
        return @is_unique
