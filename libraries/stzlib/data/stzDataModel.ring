# Fixed stzDataModel Implementation
# Addresses field naming, relationship inference, and validation issues

class stzDataModel from stzObject
    @schema_name
    @schema_version
    @tables
    @relationships
    @constraints
    @performance_hints
    @validation_errors

    def init(p)
        if isString(p)
            @schema_name = p
            @schema_version = "1.0"
        but isList(p) and len(p) = 2
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

		def Perfhints()
			return @performance_hints

	def ValidationErrors()
			return @validation_errors

	# Designing the data model

    def DefineTable(cTableName, aFields)
        if not isString(cTableName) or cTableName = ""
            raise("Table name must be a non-empty string")
        ok
        
        if not isList(aFields) or len(aFields) = 0
            raise("Fields must be a non-empty list")
        ok
        
        # Create table definition
        oTable = new stzDataTable()
        oTable.SetName(cTableName)
        
        # Process each field
        for aField in aFields
            if not isList(aField) or len(aField) < 2
                raise("Each field must be [name, type] or [name, type, options]")
            ok
            
            cFieldName = aField[1]
            cFieldType = aField[2]
            aOptions = []
            if len(aField) > 2
                aOptions = aField[3]
            ok
            
            # Create field with proper name and type
            oField = new stzField(cFieldName, cFieldType, aOptions)
            oTable.AddField(oField)
            
            # Auto-infer relationships for foreign keys
            if cFieldType = :foreign_key
                This.InferRelationshipFromForeignKey(cTableName, cFieldName)
            ok
        next
        
        @tables + oTable
        return This

    def InferRelationshipFromForeignKey(cFromTable, cForeignKeyField)
        # Extract referenced table name from foreign key field
        # customer_id -> customers, user_id -> users, etc.
        cReferencedTable = This.ExtractTableNameFromForeignKey(cForeignKeyField)
        
        if cReferencedTable != ""
            # Create belongs_to relationship
            aRelationship = [
                :from = cFromTable,
                :to = cReferencedTable, 
                :type = "belongs_to",
                :inferred = true,
                :field = cForeignKeyField
            ]
            @relationships + aRelationship
            
            # Create inverse has_many relationship
            aInverseRelationship = [
                :from = cReferencedTable,
                :to = cFromTable,
                :type = "has_many", 
                :inferred = true,
                :field = cForeignKeyField
            ]
            @relationships + aInverseRelationship
        ok

    def ExtractTableNameFromForeignKey(cForeignKeyField)
        # Remove _id suffix and pluralize
        if right(cForeignKeyField, 3) = "_id"
            cBaseName = left(cForeignKeyField, len(cForeignKeyField) - 3)
            return Plural(cBaseName) # From the MAX layer
        ok
        return ""

    def RelationshipSummary()
        aResult = []
        for aRel in @relationships
            aResult + [
                :from = aRel[:from],
                :to = aRel[:to],
                :type = aRel[:type],
                :inferred = aRel[:inferred]
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
        
        aRelationship = [
            :from = cTable,
            :to = cTable,
            :type = "hierarchy",
            :inferred = false,
            :options = aOptions
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

    def Validate()
        @validation_errors = []
        
        # Validate tables exist
        if len(@tables) = 0
            @validation_errors + "Model has no tables defined"
        ok
        
        # Validate each table
        for oTable in @tables
            This.ValidateTable(oTable)
        next
        
        # Validate relationships
        for aRel in @relationships
            This.ValidateRelationship(aRel)
        next
        
        return [
            :valid = (len(@validation_errors) = 0),
            :errors = @validation_errors
        ]

    def ValidateTable(oTable)
        if oTable.Name() = ""
            @validation_errors + "Table has no name"
        ok
        
        if oTable.FieldCount() = 0
            @validation_errors + "Table '" + oTable.Name() + "' has no fields"
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
            @validation_errors + "Table '" + oTable.Name() + "' has no primary key"
        but nPrimaryKeys > 1
            @validation_errors + "Table '" + oTable.Name() + "' has multiple primary keys"
        ok

    def ValidateRelationship(aRel)
        # Check if referenced tables exist
        if not This.TableExists(aRel[:from])
            @validation_errors + "Relationship references non-existent table: " + aRel[:from]
        ok
        
        if not This.TableExists(aRel[:to])
            @validation_errors + "Relationship references non-existent table: " + aRel[:to]
        ok

    def TableExists(cTableName)
        for oTable in @tables
            if oTable.Name() = cTableName
                return true
            ok
        next
        return false

    def GetTable(cTableName)
        for oTable in @tables
            if oTable.Name() = cTableName
                return oTable
            ok
        next
        return NULL

    def AnalyzePerformance()
        aHints = []
        
        # Check for missing indexes on foreign keys
        for aRel in @relationships
            if aRel[:type] = "belongs_to" and find(aRel, :field) > 0
                aHints + "Consider adding index on " + aRel[:from] + "." + aRel[:field]
            ok
        next
        
        # Check for N+1 query potential
        for aRel in @relationships
            if aRel[:type] = "has_many"
                aHints + "Consider eager loading for " + aRel[:from] + " " + aRel[:type] + " " + aRel[:to] + " to avoid N+1 queries"
            ok
        next
        
        return aHints

    def Explain()
        aExplanation = [
            :tables = [],
            :relationships = [],
            :performance_hints = This.AnalyzePerformance()
        ]
        
        # Explain tables
        for oTable in @tables
            aTableInfo = [
                :name = oTable.Name(),
                :fields = oTable.FieldCount(),
                :relationships = This.GetTableRelationshipCount(oTable.Name())
            ]
            aExplanation[:tables] + aTableInfo
        next
        
        # Explain relationships
        for aRel in @relationships
            aExplanation[:relationships] + aRel
        next
        
        return aExplanation

    def GetTableRelationshipCount(cTableName)
        nCount = 0
        for aRel in @relationships
            if aRel[:from] = cTableName or aRel[:to] = cTableName
                nCount++
            ok
        next
        return nCount

    def Visualize()
        aEntities = []
        aConnections = []
        
        # Create entities from tables
        for oTable in @tables
            aEntity = [
                :name = oTable.Name(),
                :field_count = oTable.FieldCount()
            ]
            aEntities + aEntity
        next
        
        # Create connections from relationships
        for aRel in @relationships
            if aRel[:from] != aRel[:to]  # Skip self-referencing for simplicity
                aConnection = [
                    :from = aRel[:from],
                    :to = aRel[:to],
                    :type = aRel[:type]
                ]
                aConnections + aConnection
            ok
        next
        
        cComplexity = "simple"
        if len(aConnections) > 5
            cComplexity = "moderate"
        ok
        if len(aConnections) > 10
            cComplexity = "complex"
        ok
        
        return [
            :entities = aEntities,
            :connections = aConnections,
            :complexity = cComplexity
        ]

    def GetRelationshipSummary()
        return This.RelationshipSummary()

    def GetTableSummary()
        aResult = []
        for oTable in @tables
            aTableInfo = [
                :name = oTable.Name(),
                :field_count = oTable.FieldCount(),
                :relationships = []
            ]
            
            # Add relationships for this table
            for aRel in @relationships
                if aRel[:from] = oTable.Name() or aRel[:to] = oTable.Name()
                    aTableInfo[:relationships] + aRel
                ok
            next
            
            aResult + aTableInfo
        next
        return aResult

    def AddField(cTableName, cFieldName, cFieldType, aOptions)
        # Simulate impact analysis
        aImpact = [
            :breaking_changes = 0,
            :performance_impact = "minimal",
            :migration_complexity = "simple"
        ]
        
        # Actually add the field
        oTable = This.GetTable(cTableName)
        if oTable != NULL
            oField = new stzField(cFieldName, cFieldType, aOptions)
            oTable.AddField(oField)
        ok
        
        return aImpact

    def RemoveField(cTableName, cFieldName)
        # Check if field is used in relationships
        for aRel in @relationships
            if find(aRel, :field) > 0 and aRel[:field] = cFieldName
                raise("Cannot remove field '" + cFieldName + "' - it would break relationships")
            ok
            
            # Also check if this is a foreign key field being used
            if aRel[:from] = cTableName and aRel[:type] = "belongs_to"
                # Extract foreign key field name from relationship
                cExpectedFKField = This.GetForeignKeyFieldName(aRel[:to])
                if cExpectedFKField = cFieldName
                    raise("Cannot remove field '" + cFieldName + "' - it would break relationships")
                ok
            ok
        next
        
        return [
            :breaking_changes = 0,
            :migration_complexity = "simple"
        ]

# Supporting classes

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
        return len(@fields)
    
    def Field(nIndex)
        if nIndex >= 1 and nIndex <= len(@fields)
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
