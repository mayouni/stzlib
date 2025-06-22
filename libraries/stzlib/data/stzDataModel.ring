# Enhanced stzDataModel Implementation
# Fixes: missing methods, improved foreign key inference, constraint support

class stzDataModel from stzObject
    @schema_name
    @schema_version
    @tables
    @relationships
    @constraints
    @performance_hints
    @validation_errors
    @fk_inference_mode  # New: controls foreign key inference behavior

    def init(p)
        if isString(p)
            @schema_name = p
            @schema_version = "1.0"
        but isList(p) and stzlen(p) = 2
            @schema_name = p[1]
            @schema_version = p[2]
        else
            @schema_name = "default"
            @schema_version = "1.0"
        ok
        
        @tables = []
        @relationships = []
        @constraints = []
        @performance_hints = []
        @validation_errors = []
        @fk_inference_mode = "smart"  # Options: "strict", "smart", "permissive"

    # Configuration methods
    def SetForeignKeyInferenceMode(cMode)
        # "strict" - only infer if target table exists
        # "smart" - warn but proceed (default)
        # "permissive" - create placeholder tables
        @fk_inference_mode = cMode
        return This

    def ForeignKeyInferenceMode()
        return @fk_inference_mode

    # Getting the content of the class data containers
    def SchemaName()
        return @schema_name

    def SchemaVersion()
        return @schema_version

    def Tables()
        return @tables

    def Relationships()
        return @relationships

    def Constraints()
        return @constraints

    def PerformanceHints()
        return @performance_hints

    def PerfHints()
        return @performance_hints

    def ValidationErrors()
        return @validation_errors

    # Designing the data model
    def DefineTable(cTableName, aFields)
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
                This.InferRelationshipFromForeignKey(cTableName, cFieldName)
            ok
        next
        
        @tables + oTable
        return This

    # NEW METHOD: AddField - Add a field to an existing table
    def AddField(cTableName, cFieldName, cFieldType, aOptions)
        if aOptions = NULL
            aOptions = []
        ok
        
        # Find the table
        oTable = This.GetTable(cTableName)
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
            This.InferRelationshipFromForeignKey(cTableName, cFieldName)
        ok
        
        # Return impact analysis
        return This.AnalyzeFieldAdditionImpact(cTableName, cFieldName, cFieldType, aOptions)

    # NEW METHOD: RemoveField - Remove a field from an existing table
    def RemoveField(cTableName, cFieldName)
        # Find the table
        oTable = This.GetTable(cTableName)
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
    def AnalyzeFieldAdditionImpact(cTableName, cFieldName, cFieldType, aOptions)
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
            cReferencedTable = This.ExtractTableNameFromForeignKey(cFieldName)
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

    # NEW METHOD: Analyze impact of removing a field
    def AnalyzeFieldRemovalImpact(cTableName, cFieldName)
        aImpact = [
            :breaking_changes = 0,
            :affected_relationships = [],
            :migration_complexity = "simple",
            :breaking_reasons = []
        ]
        
        # Find the field
        oTable = This.GetTable(cTableName)
        oField = This.GetFieldFromTable(oTable, cFieldName)
        
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
        nLen = len(@relationships)
        for i = 1 to nLen
            aRel = @relationships[i]
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
            nLen = len(@relationships)
            for i = 1 to nLen
                aRel = @relationships[i]
                if aRel[:from] = cTableName and find(aRel, :field) > 0 and aRel[:field] = cFieldName
                    aImpact[:breaking_changes]++
                    aImpact[:breaking_reasons] + "breaks foreign key relationship"
                    aImpact[:affected_relationships] + aRel
                ok
            next
        ok
        
        return aImpact

    # NEW METHOD: Get field from table by name
    def GetFieldFromTable(oTable, cFieldName)
        nLen = oTable.FieldCount()
        for i = 1 to nLen
            oField = oTable.Field(i)
            if oField.Name() = cFieldName
                return oField
            ok
        next
        return NULL

    # NEW METHOD: Remove relationships that depend on a field
    def RemoveRelationshipsForField(cTableName, cFieldName)
        aNewRelationships = []
        nLen = len(@relationships)
        for i = 1 to nLen
            aRel = @relationships[i]
            bKeep = true
            
            # Remove if this field is the foreign key
            if find(aRel, :field) > 0 and aRel[:field] = cFieldName and aRel[:from] = cTableName
                bKeep = false
            ok
            
            if bKeep
                aNewRelationships + aRel
            ok
        next
        @relationships = aNewRelationships

    def InferRelationshipFromForeignKey(cFromTable, cForeignKeyField)
        # Extract referenced table name from foreign key field
        cReferencedTable = This.ExtractTableNameFromForeignKey(cForeignKeyField)
        
        if cReferencedTable != ""
            # Check inference mode behavior
            switch @fk_inference_mode
            on "strict"
                if not This.TableExists(cReferencedTable)
                    raise("Foreign key '" + cForeignKeyField + "' references non-existent table '" + cReferencedTable + "'")
                ok
            on "smart"
                if not This.TableExists(cReferencedTable)
                    # Add warning but continue
                    @validation_errors + [
                        :type = "foreign_key_inference",
                        :severity = "warning",
                        :message = "Foreign key references table that doesn't exist yet",
                        :table = cFromTable,
                        :field = cForeignKeyField,
                        :referenced_table = cReferencedTable,
                        :suggestions = [
                            "Define table '" + cReferencedTable + "' before using this foreign key",
                            "Or use SetForeignKeyInferenceMode('permissive') to auto-create placeholder tables"
                        ]
                    ]
                ok
            on "permissive"
                if not This.TableExists(cReferencedTable)
                    # Auto-create placeholder table
                    This.CreatePlaceholderTable(cReferencedTable)
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
            @relationships + aRelationship
            
            # Create inverse has_many relationship
            aInverseRelationship = [
                :from = cReferencedTable,
                :to = cFromTable,
                :type = "has_many", 
                :inferred = true,
                :field = cForeignKeyField,
                :semantic_meaning = "Each " + SingularOf(cReferencedTable) + " can have many " + cFromTable
            ]
            @relationships + aInverseRelationship
        ok

    def CreatePlaceholderTable(cTableName)
        # Create minimal table structure
        oTable = new stzDataTable()
        oTable.SetName(cTableName)
        
        # Add minimal primary key
        oField = new stzField("id", :primary_key, [])
        oTable.AddField(oField)
        
        @tables + oTable
        
        # Log the auto-creation
        @validation_errors + [
            :type = "auto_creation",
            :severity = "info",
            :message = "Auto-created placeholder table",
            :table = cTableName,
            :suggestions = ["Complete the table definition with proper fields"]
        ]

    def ExtractTableNameFromForeignKey(cForeignKeyField)
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

    # Missing method: AddConstraint
    def AddConstraint(cTableName, cFieldName, cConstraint)
        aConstraintDef = [
            :table = cTableName,
            :field = cFieldName,
            :constraint = cConstraint,
            :type = This.DetermineConstraintType(cConstraint)
        ]
        @constraints + aConstraintDef
        return This

    def DetermineConstraintType(cConstraint)
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

    # Missing method: GetTableAnalysis
    def GetTableAnalysis()
        aAnalysis = []
        
        nLen = len(@tables)

        for i = 1 to nLen
            cTableName = @tables[i].Name()
            nFieldCount = @tables[i].FieldCount()
            nRelationshipCount = This.GetTableRelationshipCount(cTableName)
            
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
                :primary_keys = This.GetPrimaryKeyCount(@tables[i]),
                :foreign_keys = This.GetForeignKeyCount(@tables[i])
            ]
            aAnalysis + aTableAnalysis
        next
        
        return aAnalysis

    def GetPrimaryKeyCount(oTable)
        nCount = 0
        for i = 1 to oTable.FieldCount()
            oField = oTable.Field(i)
            if oField.IsPrimaryKey()
                nCount++
            ok
        next
        return nCount

    def GetForeignKeyCount(oTable)
        nCount = 0
        for i = 1 to oTable.FieldCount()
            oField = oTable.Field(i)
            if right(oField.Name(), 3) = "_id" and not oField.IsPrimaryKey()
                nCount++
            ok
        next
        return nCount

    # Enhanced Explain method with better naming
    def GetModelSummary()  # Renamed from Explain()
        aExplanation = [
            :schema = [
                :name = @schema_name,
                :version = @schema_version
            ],
            :tables = [],
            :relationships = [],
            :constraints = @constraints,
            :performance_hints = @performance_hints,
            :statistics = [
                :table_count = stzlen(@tables),
                :relationship_count = stzlen(@relationships),
                :constraint_count = stzlen(@constraints),
                :hint_count = stzlen(@performance_hints)
            ]
        ]
        
        # Explain tables
        nLen = len(@tables)

        for i = 1 to nLen
            aTableInfo = [
                :name = @tables[i].Name(),
                :field_count = @tables[i].FieldCount(),
                :relationship_count = This.GetTableRelationshipCount(@tables[i].Name()),
                :fields = This.GetTableFieldInfo(@tables[i])
            ]
            aExplanation[:tables] + aTableInfo
        next
        
        # Explain relationships
        nLen = len(@relationships)

        for i = 1 to nLen
            aExplanation[:relationships] + @relationships[i]
        next
        
        return aExplanation

    # New method: Generate narrative explanation
    def Explain()
        cExplanation = "Data Model: " + @schema_name + " (v" + @schema_version + ")" + NL + NL
        
        # Tables overview
        cExplanation += "This model contains " + stzlen(@tables) + " tables:" + NL
        nLen = len(@tables)

        for i = 1 to nLen
            cTableName = @tables[i].Name()
            nFields = @tables[i].FieldCount()
            nRels = This.GetTableRelationshipCount(cTableName)
            
            cExplanation += "- " + cTableName + ": " + nFields + " fields, " + nRels + " relationships" + NL
        next
        
        # Relationships overview
        if stzlen(@relationships) > 0
            cExplanation += NL + "Key relationships:" + NL

            nLen = len(@relationships)
            for i = 1 to nLen
                if find(@relationships[i], :semantic_meaning) > 0
                    cExplanation += "- " + @relationships[i][:semantic_meaning] + NL
                else
                    cExplanation += "- " + @relationships[i][:from] + " " + @relationships[i][:type] + " " + @relationships[i][:to] + NL
                ok
            next
        ok
        
        # Issues and recommendations
        if stzlen(@validation_errors) > 0
            cExplanation += NL + "Recommendations:" + NL
            nLen = len(@validation_errors)

            for i = 1 to nLen
                if @validation_errors[i][:severity] = "warning" or @validation_errors[i][:severity] = "info"
                    cExplanation += "- " + @validation_errors[i][:message] + NL
                ok
            next
        ok
        
        return cExplanation

		def ExplainModel()
			return This.Explain()

    # Rest of the original methods remain the same...
    def RelationshipSummary()
        aResult = []
        nLen = len(@relationships)

        for i = 1 to nLen
            aResult + [
                :from = @relationships[i][:from],
                :to = @relationships[i][:to],
                :type = @relationships[i][:type],
                :inferred = @relationships[i][:inferred]
            ]
        next
        return aResult

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
        @relationships + aRelationship
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
        @relationships + aRelationship
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
        @relationships + aRelationship
        return This

    # Continue with validation and other methods...
    def Validate()
        @validation_errors = []
        
        # Validate tables exist
        if stzlen(@tables) = 0
            @validation_errors + [
                :type = "schema",
                :severity = "error", 
                :message = "Model has no tables defined",
                :table = "",
                :suggestions = ["Add at least one table using DefineTable()"]
            ]
        ok
        
        # Validate each table
        nLen = len(@tables)

        for i = 1 to nLen
            This.ValidateTable(@tables[i])
        next
        
        # Validate relationships
        nLen = len(@relationships)
        for i = 1 to nLen
            This.ValidateRelationship(@relationships[i])
        next
        
        return [
            :valid = (stzlen(@validation_errors) = 0),
            :errors = @validation_errors,
            :error_count = stzlen(@validation_errors),
            :tables_validated = stzlen(@tables),
            :relationships_validated = stzlen(@relationships)
        ]

    def ValidateTable(oTable)
        cTableName = oTable.Name()
        
        if cTableName = ""
            @validation_errors + [
                :type = "table",
                :severity = "error",
                :message = "Table has no name",
                :table = "",
                :suggestions = ["Use SetName() to assign a table name"]
            ]
        ok
        
        if oTable.FieldCount() = 0
            @validation_errors + [
                :type = "table",
                :severity = "error", 
                :message = "Table has no fields",
                :table = cTableName,
                :suggestions = ["Add fields using AddField() or DefineTable()"]
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
            @validation_errors + [
                :type = "table",
                :severity = "warning",
                :message = "Table has no primary key",
                :table = cTableName,
                :suggestions = ["Add a primary key field for better performance and data integrity"]
            ]
        but nPrimaryKeys > 1
            @validation_errors + [
                :type = "table",
                :severity = "error",
                :message = "Table has multiple primary keys",
                :table = cTableName,
                :suggestions = ["Use composite primary key or designate single primary key"]
            ]
        ok

    def ValidateRelationship(aRel)
        cFromTable = aRel[:from]
        cToTable = aRel[:to]
        
        # Check if referenced tables exist
        if not This.TableExists(cFromTable)
            @validation_errors + [
                :type = "relationship",
                :severity = "error",
                :message = "Relationship references non-existent table",
                :table = cFromTable,
                :related_table = cToTable,
                :suggestions = ["Create table '" + cFromTable + "' or fix relationship definition"]
            ]
        ok
        
        if not This.TableExists(cToTable)
            @validation_errors + [
                :type = "relationship", 
                :severity = "error",
                :message = "Relationship references non-existent table",
                :table = cToTable,
                :related_table = cFromTable,
                :suggestions = ["Create table '" + cToTable + "' or fix relationship definition"]
            ]
        ok

    def TableExists(cTableName)
        nLen = len(@tables)
        for i = 1 to nLen
            if @tables[i].Name() = cTableName
                return true
            ok
        next
        return false

    def GetTable(cTableName)
        nLen = len(@tables)
        for i = 1 to nLen
            if @tables[i].Name() = cTableName
                return @tables[i]
            ok
        next
        return NULL

    def AnalyzePerformance()
        @performance_hints = []
        
        # Check for missing indexes on foreign keys
        nLen = len(@relationships)
        for i = 1 to nLen
            if @relationships[i][:type] = "belongs_to" and find(@relationships[i], :field) > 0
                cFromTable = @relationships[i][:from]
                cField = @relationships[i][:field]
                cToTable = @relationships[i][:to]
                
                oHint = [
                    :type = "index_suggestion",
                    :priority = "medium",
                    :message = "Consider adding index on foreign key field",
                    :table = cFromTable,
                    :field = cField,
                    :related_table = cToTable,
                    :reason = "Foreign key lookups will be faster with index",
                    :action = "CREATE INDEX idx_" + cFromTable + "_" + cField + " ON " + cFromTable + "(" + cField + ")"
                ]
                @performance_hints + oHint
            ok
        next
        
        # Check for N+1 query potential
        
        for i = 1 to nLen
            if @relationships[i][:type] = "has_many"
                cFromTable = @relationships[i][:from]
                cToTable = @relationships[i][:to]
                
                oHint = [
                    :type = "query_optimization",
                    :priority = "high",
                    :message = "Potential N+1 query problem detected",
                    :table = cFromTable,
                    :related_table = cToTable,
                    :relationship = @relationships[i][:type],
                    :reason = "Loading " + cFromTable + " records may trigger multiple queries for " + cToTable,
                    :action = "Use eager loading or joins when querying " + cFromTable + " with " + cToTable
                ]
                @performance_hints + oHint
            ok
        next
        
        return @performance_hints

    def CountTableConnections(cTableName)
        nCount = 0
        nLen = len(@relationships)
        for i = 1 to nLen
            if @relationships[i][:from] = cTableName or @relationships[i][:to] = cTableName
                nCount++
            ok
        next
        return nCount

    def GetTableFieldInfo(oTable)
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

    def GetTableRelationshipCount(cTableName)
        nCount = 0
        nLen = len(@relationships)
        for i = 1 to nLen
            if @relationships[i][:from] = cTableName or @relationships[i][:to] = cTableName
                nCount++
            ok
        next
        return nCount

    def DiagramData()
        aEntities = []
        aConnections = []
        
        # Create entities from tables
		nLen = len(@tables)
        for i = 1 to nLen
            aEntity = [
                :name = @tables[i].Name(),
                :field_count = @tables[i].FieldCount(),
                :type = "table"
            ]
            aEntities + aEntity
        next
        
        # Create connections from relationships
		nLen = len(@relationships)
        for i = 1 to nLen
            if @relationships[i][:from] != @relationships[i][:to]  # Skip self-referencing for main diagram
                aConnection = [
                    :from = @relationships[i][:from],
                    :to = @relationships[i][:to],
                    :type = @relationships[i][:type],
                    :inferred = @relationships[i][:inferred]
                ]
                aConnections + aConnection
            ok
        next
        
        return [
            :entities = aEntities,
            :connections = aConnections,
            :self_referencing = This.GetSelfReferencingTables()
        ]

    def VizData()
        return this.DiagramData()

    def GetERDData()
        return This.DiagramData()

    def GetSelfReferencingTables()
        aSelfRef = []
		nLen = len(@relationships)
        for i = 1 to nLen
            if @relationships[i][:from] = @relationships[i][:to]
                aSelfRef + [
                    :table = @relationships[i][:from],
                    :type = @relationships[i][:type]
                ]
            ok
        next
        return aSelfRef

    def GetRelationshipSummary()
        return This.RelationshipSummary()

    def GetTableSummary()
        aResult = []
		nLen = len(@tables)
        for i = 1 to nLen
            aTableInfo = [
                :name = @tables[i].Name(),
                :field_count = @tables[i].FieldCount(),
                :relationships = []
            ]
            
            # Add relationships for this table
			nLenRel = len(@relationships)
			for j = 1 to nLenRel
                if aRel[:from] = @relationships[j].Name() or @relationships[j][:to] = @tables[i].Name()
                    aTableInfo[:relationships] + @relationships[j]
                ok
            next
            
            aResult + aTableInfo
        next
        return aResult


# Supporting classes remain the same
class stzDataTable from stzObject
    @name
    @fields
    
    def init()
        @name = ""
        @fields = []
    
    def SetName(cName)
        @name = cName
    
    def Name()
        return @name
    
    def AddField(oField)
        @fields + oField
    
    def FieldCount()
        return stzlen(@fields)
    
    def Field(nIndex)
        if nIndex >= 1 and nIndex <= stzlen(@fields)
            return @fields[nIndex]
        ok
        return NULL
    
    def Fields()
        return @fields

class stzField from stzObject
    @name
    @type
    @options
    @is_primary_key
    @is_required
    @is_unique
    
    def init(cName, cType, aOptions)
        @name = cName
        @type = This.ProcessFieldType(cType)
        
        if aOptions = NULL
            aOptions = []
        ok
        @options = aOptions
        
        # Set flags based on type and options
        @is_primary_key = (cType = :primary_key)
        @is_required = (cType = :required or @is_primary_key)
        @is_unique = (cType = :unique or @is_primary_key)
    
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
        return @name
    
    def Type()
        return @type
    
    def IsPrimaryKey()
        return @is_primary_key
    
    def IsRequired()
        return @is_required
    
    def IsUnique()
        return @is_unique
