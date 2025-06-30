$acDataModelValidationModes = ["strict", "warning", "permissive"]

func DataModelValidationModes()
	return $acDataModelValidationModes

class stzDataModel from stzObject

    #================================#
    #  INSTANCE VARIABLES            #
    #================================#

    @cSchemaName
    @cSchemaVersion
    @aTables           
    @aRelationships
    @aValidationErrors
    @cRelationInferenceMode # Can be "smart", "strict", or "permissive"
    @cValidationMode # Can be "warning", "strict", "permissive" (~> with autofixing)
    @aValidationErrors

    #================================#
    #  INITIALIZATION                #
    #================================#

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
        @aValidationErrors = []
        @cRelationInferenceMode = "smart"
        @cValidationMode = "warning"  # Default validation mode

    #================================#
    #  CONFIGURATION METHODS         #
    #================================#

    def SetRelationInferenceMode(cMode)
        @cRelationInferenceMode = cMode
        return This

    def SetValidationMode(cMode)
        if find( DataModelValidationModes(), cMode) > 0
            @cValidationMode = cMode
        else
            stzraise("Invalid validation mode: " + cMode)
        ok
        return This

    def ValidationMode()
        return @cValidationMode

    def RelationMode()
        return @cRelationInferenceMode

    #================================#
    #  SCHEMA INFORMATION           #
    #================================#

    def SchemaName()
        return @cSchemaName

    def SchemaVersion()
        return @cSchemaVersion

    def Tables()
        return @aTables

    def Relations()
        return @aRelationships

    def Name()
        return @cSchemaName

    def Version()
        return @cSchemaVersion

    #================================#
    #  VALIDATION MANAGEMENT        #
    #================================#

    def ErrorsXT()
        This.Validate()
        return @aValidationErrors

    def ValidationErrorsXT()
        return This.ErrorsXT()

    def Errors()
        aErrorsXT = This.ErrorsXT()
        nLen = len(aErrorsXT)

        aResult = []
        for i = 1 to nLen
            if aErrorsXT[i][:severity] = "error"
                aResult + aErrorsXT[i]
            ok
        next
        return aResult

    def ValidationErrors()
        return This.Errors()

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

    def ValidateXT()
        @aValidationErrors = []

        for table in @aTables
            if table[:name] = "" or table[:name] = NULL
                if @cValidationMode = "strict"
                    @aValidationErrors + [ :type = "table", :severity = "error", :message = "Table has no name" ]
                but @cValidationMode = "warning"
                    @aValidationErrors + [ :type = "table", :severity = "warning", :message = "Table has no name" ]
                but @cValidationMode = "permissive"
                    table[:name] = "unnamed_table_" + len(@aTables)  # Auto-fix
                ok
            ok

            aFieldNames = []

            for field in table[:fields]
                if find(aFieldNames, field[:name]) > 0
                    if @cValidationMode = "strict" or @cValidationMode = "warning"
                        @aValidationErrors + [ :type = "field", :severity = "error", :message = "Duplicate field: " + field[:name] ]
                    ok
                else
                    aFieldNames + field[:name]
                ok
            next
        next

        return @aValidationErrors

    def Validate()
        This.ValidateXT()

        nErrors = 0
        nWarnings = 0
        for error in @aValidationErrors
            if error[:severity] = "error"
                nErrors++
            but error[:severity] = "warning"
                nWarnings++
            ok
        next
        
        return [
            :errors_count = nErrors,
            :warnings_count = nWarnings
        ]

    #================================#
    #  TABLE MANAGEMENT             #
    #================================#

    def AddTable(cTableName, aFields)
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

    def TableExists(cTableName)
        nLen = len(@aTables)
        for i = 1 to nLen
            if @aTables[i][:name] = cTableName
                return TRUE
            ok
        next
        return FALSE

    def FindTable(cTableName)
        for aTable in @aTables
            if aTable[:name] = cTableName
                return aTable
            ok
        next
        return stzraise("Inexistant table name!")

    #================================#
    #  FIELD MANAGEMENT             #
    #================================#

    def AddField(cTableName, cFieldName, cFieldType, aOptions)
        if aOptions = NULL
            aOptions = []
        ok

        nTableIndex = 0
        for i = 1 to len(@aTables)
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

    #================================#
    #  RELATIONSHIP MANAGEMENT      #
    #================================#

    def Link(cFromTable, cToTable, cType, aOptions)
        if aOptions = NULL
            aOptions = []
        ok
        aRelationship = [
            :from = cFromTable,
            :to = cToTable,
            :type = cType,
            :inferred = FALSE,
            :options = aOptions # Supports metadata like :via, :semantic, :business_rule
        ]
        @aRelationships + aRelationship
        return This

    def AddRelationship(cFromTable, cToTable, cType, aOptions)
        This.Link(cFromTable, cToTable, cType, aOptions)

    def Hierarchy(cTable, aOptions)
        if aOptions = NULL
            aOptions = [:parent_field = "parent_id"]
        ok
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

    def InferRelationshipsForTable(aTable)
        aFields = aTable[:fields]
        nLen = len(aFields)
        for i = 1 to nLen
            aField = aFields[i]
            cFieldName = aField[:name]
            if right(cFieldName, 3) = "_id" and cFieldName != "id"
                cRelatedTableSingular = left(cFieldName, len(cFieldName) - 3)
                cRelatedTable = PluralOf(cRelatedTableSingular)
                if This.TableExists(cRelatedTable)
                    @aRelationships + [
                        :type = "belongs_to",
                        :from = aTable[:name],
                        :to = cRelatedTable,
                        :field = cFieldName,
                        :inferred = TRUE
                    ]
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

    def CountRelationshipsForTable(cTableName)
        nCount = 0
        nLen = len(@aRelationships)
        for i = 1 to nLen
            if @aRelationships[i][:from] = cTableName or @aRelationships[i][:to] = cTableName
                nCount++
            ok
        next
        return nCount

    def Relationships()
        return @aRelationships

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

    #================================#
    #  IMPACT ANALYSIS              #
    #================================#

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
        if HasKey(aField, :is_primary_key) and aField[:is_primary_key]
            aImpact[:breaking_changes]++
            aImpact[:breaking_reasons] + "field is primary key"
            aImpact[:migration_complexity] = "complex"
        ok
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

    #================================#
    #  REPORTING AND EXPORT         #
    #================================#

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
        aSummary = [
            [ "name", @cSchemaName ],
            [ "version", "1.0" ],
            [ "tablescount", len(@aTables) ],
            [ "tables", [] ]
        ]
        for aTable in @aTables
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

    def DiagramData()
        aEntities = []
        aRelationships = []

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

        aProcessedRels = []

        for aRel in @aRelationships
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

        aRels = aDiagramData[:relationships]
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
        cJSON += TAB + '"relationships": [' + nl
        nLenR = len(@aRelationships)
        for i = 1 to nLenR
            aRel = @aRelationships[i]
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

    #================================#
    #  TEMPLATE SYSTEM              #
    #================================#

    def UseTemplate(cTemplateName)
        switch cTemplateName
        on "ecommerce_basic"
            This.AddTable("customers", [ ["id", "integer"], ["name", "text"] ])
            This.AddTable("orders", [ ["id", "integer"], ["customer_id", "integer"] ])
            This.AddTable("products", [ ["id", "integer"], ["name", "text"] ])
            This.Link("orders", "customers", "belongs_to", [])
            This.Link("orders", "products", "has_many", [])

        on "social_network"
            This.AddTable("users", [ ["id", "integer"], ["username", "text"] ])
            This.AddTable("posts", [ ["id", "integer"], ["user_id", "integer"] ])
            This.AddTable("follows", [ ["follower_id", "integer"], ["followed_id", "integer"] ])
            This.Link("posts", "users", "belongs_to", [])
            This.Link("users", "follows", "many_to_many", [ :via = "follows" ])

        on "blog_platform"
            This.AddTable("authors", [ ["id", "integer"], ["name", "text"] ])
            This.AddTable("articles", [ ["id", "integer"], ["author_id", "integer"] ])
            This.AddTable("categories", [ ["id", "integer"], ["name", "text"] ])
            This.Link("articles", "authors", "belongs_to", [])
            This.Link("articles", "categories", "has_many", [])

        other
            stzraise("Unknown template: " + cTemplateName)
        off
        return This

    #================================#
    #  UTILITY METHODS              #
    #================================#

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
        for i = 1 to len(aList)
            if aList[i] = cItem
                return i
            ok
        next
        return 0

    def CountRelationsForTable(cTableName)
        nCount = 0
        for aRel in @aRelationships
            if aRel[:from] = cTableName or aRel[:to] = cTableName
                nCount++
            ok
        next
        return nCount

    def ClearModel()
        @aTables = []
        @aRelationships = []
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
