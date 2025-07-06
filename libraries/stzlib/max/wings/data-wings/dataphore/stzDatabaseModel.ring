#--------------------------#
#  stzDatabaseModel class  #
#--------------------------#

class stzDatabaseModel from stzDataModel

    @aConstraints
    @aPerfHints
    @cForeignKeyMode # Can be "smart", "strict", or "permissive"
    @cActivePerfPlan
    @oPerfEngine
	@aRelations

    def init(p)
        super.init(p)
        @aConstraints = []
        @aPerfHints = []
        @cForeignKeyMode = "smart"
        @cActivePerfPlan = "default"
        @oPerfEngine = new stzDatabasePerfEngine()
        @aRelations = []

    # Configuration methods
    def SetForeignKeyInferenceMode(cMode)
        @cForeignKeyMode = cMode
        

    def ForeignKeyMode()
        return @cForeignKeyMode

    def FKMode()
        return @cForeignKeyMode

    # Database-specific getters
    def Constraints()
        return @aConstraints

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
        return U(acResult)

    def PerfHintsXT()
        aModelData = This.ModelSummary()
        return @oPerfEngine.AnalyzeModel(aModelData)

    # Foreign key management
    def InferRelationsFromFK(cFromTable, cForeignKeyField)
        cReferencedTableSingular = This.TableNameFromFK(cForeignKeyField)
        cReferencedTable = PluralOf(cReferencedTableSingular)
        if cReferencedTable != "" and This.TableExists(cReferencedTable)
            @aRelations + [
                :type = "belongs_to",
                :from = cFromTable,
                :to = cReferencedTable,
                :inferred = TRUE,
                :field = cForeignKeyField
            ]
            @aRelations + [
                :type = "has_many",
                :from = cReferencedTable,
                :to = cFromTable,
                :inferred = TRUE,
                :field = cForeignKeyField
            ]
        ok

    def TableNameFromFK(cForeignKeyField)
        if cForeignKeyField = "parent_id"
            return ""
        ok
        if right(cForeignKeyField, 3) = "_id"
            cBaseName = left(cForeignKeyField, len(cForeignKeyField) - 3)
            return cBaseName
        ok
        return ""

    def GuessFK(cTableName)
        cSingular = SingularOf(cTableName)
        return cSingular + "_id"

    # Constraints enforcement
    def AddConstraint(cTableName, cFieldName, cConstraint)
        aConstraintDef = [
            :table = cTableName,
            :field = cFieldName,
            :constraint = cConstraint,
            :type = This.ConstraintType(cConstraint)
        ]
        @aConstraints + aConstraintDef
        if aConstraintDef[:type] = "foreign_key"
            aRefInfo = This.ParseForeignKey(cConstraint)
            if aRefInfo != NULL
                @aRelations + [
                    :from_table = cTableName,
                    :from_field = cFieldName,
                    :to_table = aRefInfo[:table],
                    :to_field = aRefInfo[:field]
                ]
            ok
        ok

    def ConstraintType(cConstraint)
        cUpper = upper(cConstraint)
        if @substr(cUpper, "PRIMARY KEY", []) > 0
            return "primary_key"
        but @substr(cUpper, "FOREIGN KEY", []) > 0 or substr(cUpper, "REFERENCES") > 0
            return "foreign_key"
        but @substr(cUpper, "UNIQUE", []) > 0
            return "unique"
        but @substr(cUpper, "NOT NULL", []) > 0
            return "not_null"
        but @substr(cUpper, "CHECK", []) > 0
            return "check"
        but @substr(cUpper, "DEFAULT", []) > 0
            return "default"
        else
            return "custom"
        ok

    def ParseForeignKey(cConstraint)
        cUpper = upper(cConstraint)
        nRefPos = @substr(cUpper, "REFERENCES ", [])
        if nRefPos > 0
            cAfterRef = @substr(cConstraint, nRefPos + 11, [])
            nParenPos = @substr(cAfterRef, "(", [])
            nSpacePos = @substr(cAfterRef, " ", [])
            nEndPos = nParenPos
            if nSpacePos > 0 and (nSpacePos < nParenPos or nParenPos = 0)
                nEndPos = nSpacePos
            ok
            if nEndPos > 0
                cRefTable = @trim(@substr(cAfterRef, 1, nEndPos - 1, []))
                nOpenParen = @substr(cAfterRef, "(", [])
                nCloseParen = @substr(cAfterRef, ")", [])
                if nOpenParen > 0 and nCloseParen > nOpenParen
                    cRefField = @trim(@substr(cAfterRef, nOpenParen + 1, nCloseParen - nOpenParen - 1))
                    return [ :table = cRefTable, :field = cRefField ]
                ok
            ok
        ok
        return NULL

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
                    cUpper = upper(aConstraint[:constraint])
                    nPos = @substr(cUpper, "DEFAULT ", [])
                    if nPos > 0
                        cDefaultValue = @trim(@substr(aConstraint[:constraint], nPos + 8, []))
                        aInlineConstraints + "DEFAULT " + cDefaultValue
                    ok
                ok
            ok
        next
        return aInlineConstraints

    def ValidateCheckConstraint(cConstraint)
        cUpper = upper(cConstraint)
        if @substr(cUpper, "CHECK", []) = 0
            return FALSE
        ok
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

    # Performance plan management
    def UsePerfPlan(cPlanName)
        @oPerfEngine.SetActivePlan(cPlanName)
        

    def PerfEngine()
        return @oPerfEngine

    def PerfPlan()
        return @oPerfEngine.Plan()

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
            :critical_actions = This.PerfCriticalActions(aHints)
        ]

    def SetPerfThreshold(cName, nValue)
        @oPerfEngine.SetThreshold(cName, nValue)
        

    def PerfThreshold(cName)
        return @oPerfEngine.Threshold(cName)

    def Thresholds()
        return @oPerfEngine.Thresholds()

    def ModelSummary()
        # Enhanced to provide relationship data with correct field names
        aRelationships = []
        
        # Add relationships from @aRelations with correct structure
        for aRel in @aRelations
            aRelationships + [
                :type = aRel[:type],
                :from = aRel[:from],
                :to = aRel[:to],
                :field = aRel[:field]
            ]
        next
        
        # Add enhanced table data with relationship counts
        aEnhancedTables = []
        for aTable in @aTables
            nRelCount = 0
            for aRel in @aRelations
                if aRel[:from] = aTable[:name] or aRel[:to] = aTable[:name]
                    nRelCount++
                ok
            next
            
            aEnhancedTables + [
                :name = aTable[:name],
                :fields = aTable[:fields],
                :relationship_count = nRelCount
            ]
        next
        
        return [
            :tables = aEnhancedTables,
            :relationships = aRelationships  # Changed from :relations to :relationships
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
        for aHint in aHints
            if find(aTypes, aHint[:type]) = 0
                aTypes + aHint[:type]
            ok
        next
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
        aAppliesMap = [
            "basic_fk_index" = "foreign_keys",
            "fk_index_mandatory" = "foreign_keys", 
            "covering_indexes" = "multi_column_queries",
            "denormalization_consideration" = "complex_joins",
            "n_plus_one_prevention" = "has_many_relations"
        ]
        if HasKey(aAppliesMap, cRuleId)
            return aAppliesMap[cRuleId]
        ok
        return "general"

    # Database export methods
    def ToPlantUMLERD()
        cPlantUML = "@startuml" + nl
        cPlantUML += "!define ENTITY class" + nl + nl
        aDiagramData = This.DiagramData()
        aEntities = aDiagramData[:entities]
        nLen = len(aEntities)
        for i = 1 to nLen
            aEntity = aEntities[i]
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
        aRels = aDiagramData[:relations]
        nLen = len(aRels)
        for i = 1 to nLen
            aRel = aRels[i]
            if aRel[:from_entity] != aRel[:to_entity]
                cPlantUML += aRel[:from_entity] + " ||--o{ " + aRel[:to_entity] + nl
            ok
        next
        cPlantUML += "@enduml"
        return cPlantUML

    def ToDBML()
        cDBML = "Project " + @cSchemaName + " {" + nl
        cDBML += "  database_type: 'Generic'" + nl
        cDBML += "  Note: 'Generated from stzDataModel'" + nl
        cDBML += "}" + nl + nl
        for aTable in @aTables
            cDBML += "Table " + aTable[:name] + " {" + nl
            for aField in aTable[:fields]
                cLine = "  " + aField[:name] + " " + This.MapTypeToDBML(aField[:type])
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
        for aRel in @aRelations
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

    def ToDDL()
        cDDL = ""
        nLen = len(@aTables)
        for i = 1 to nLen
            aTable = @aTables[i]
            cDDL += "CREATE TABLE " + aTable[:name] + " (" + nl
            acInlineConstraints = []
            aFields = aTable[:fields]
            nLenF = len(aFields)
            for j = 1 to nLenF
                aField = aFields[j]
                acFieldConstraints = This.GetFieldInlineConstraints(aTable[:name], aField[:name])
                acInlineConstraints + acFieldConstraints
            next
            for j = 1 to nLenF
                aField = aTable[:fields][j]
                cFieldDef = "    " + aField[:name] + " " + This.MapFieldType(aField[:type])
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

    def ToSQL()
        return This.ToDDL()

    # Database import methods
    def FromDDL(cDDL)
        This.ClearModel()
        acStatements = This.SplitDDLStatements(cDDL)
        for cStatement in acStatements
            cStatement = trim(cStatement)
            if cStatement = ""
                loop
            ok
            cUpper = upper(cStatement)
            if left(cUpper, 12) = "CREATE TABLE"
                This.ParseCreateTable(cStatement)
            but left(cUpper, 11) = "ALTER TABLE"
                This.ParseAlterTable(cStatement)
            ok
        next
        

    def FromSQL(cSQL)
        return This.FromDDL(cSQL)

    # DDL/SQL parsing methods
    def ParseCreateTable(cStatement)
        cUpper = upper(cStatement)
        nTablePos = This.FindSubstring(cUpper, "CREATE TABLE ") + 13
        nParenPos = This.FindSubstringFrom(cStatement, "(", nTablePos)
        if nParenPos > 0
            cTableName = trim(This.ExtractSection(cStatement, nTablePos, nParenPos - 1))
            if This.FindSubstring(cTableName, " ") > 0
                cTableName = trim(left(cTableName, This.FindSubstring(cTableName, " ") - 1))
            ok
            This.AddTable(cTableName, [])
            cFieldsPart = This.ExtractSection(cStatement, nParenPos + 1, len(cStatement))
            nLastParen = This.FindLastChar(cFieldsPart, ")")
            if nLastParen > 0
                cFieldsPart = left(cFieldsPart, nLastParen - 1)
            ok
            acFields = split(cFieldsPart, ",")
            aAddedFields = []
            for cFieldDef in acFields
                cFieldDef = trim(cFieldDef)
                if cFieldDef = ""
                    loop
                ok
                acParts = split(cFieldDef, " ")
                if len(acParts) >= 2
                    cFieldName = acParts[1]
                    cFieldType = acParts[2]
                    if This.FindInList(aAddedFields, cFieldName) = 0
                        This.AddField(cTableName, cFieldName, This.MapSQLTypeToInternal(cFieldType), [])
                        aAddedFields + cFieldName
                        cDefUpper = upper(cFieldDef)
                        if This.FindSubstring(cDefUpper, "PRIMARY KEY") > 0
                            This.AddConstraint(cTableName, cFieldName, "PRIMARY KEY")
                        ok
                        if This.FindSubstring(cDefUpper, "NOT NULL") > 0
                            This.AddConstraint(cTableName, cFieldName, "NOT NULL")
                        ok
                    ok
                ok
            next
        ok
        

    def ParseAlterTable(cStatement)
        cUpper = upper(cStatement)
        nTablePos = This.FindSubstring(cUpper, "ALTER TABLE ") + 12
        nAddPos = This.FindSubstringFrom(cUpper, " ADD ", nTablePos)
        if nAddPos > 0
            cTableName = trim(This.ExtractSection(cStatement, nTablePos, nAddPos - 1))
            cConstraintPart = trim(This.ExtractSection(cStatement, nAddPos + 5, len(cStatement)))
            if left(upper(cConstraintPart), 10) = "CONSTRAINT"
                acParts = split(cConstraintPart, " ")
                if len(acParts) >= 3
                    cConstraintName = acParts[2]
                    acNameParts = split(cConstraintName, "_")
                    if len(acNameParts) >= 3
                        cFieldName = acNameParts[2]
                        This.AddConstraint(cTableName, cFieldName, cConstraintPart)
                    ok
                ok
            ok
        ok

    def SplitDDLStatements(cDDL)
        aStatements = []
        cCurrentStatement = ""
        bInString = FALSE
        acChars = Chars(cDDL)
        for i = 1 to len(acChars)
            cChar = acChars[i]
            if cChar = "'" and (i = 1 or acChars[i-1] != "\")
                bInString = !bInString
            ok
            if cChar = ";" and !bInString
                if cCurrentStatement != ""
                    aStatements + trim(cCurrentStatement)
                    cCurrentStatement = ""
                ok
            else
                cCurrentStatement += cChar
            ok
        next
        if cCurrentStatement != ""
            aStatements + trim(cCurrentStatement)
        ok
        return aStatements

    # Database type mapping
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
            if This.FindSubstring(cUpper, "VARCHAR") > 0
                return lower(cSQLType)
            else
                return "text"
            ok
        off

    def MapTypeToDBML(cType)
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
        but isString(cType) and @substr(upper(cType), "VARCHAR", []) > 0
            return upper(cType)
        else
            return "TEXT"
        ok

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

    # Database validation
    def ValidateDatabase()
        aBasicValidation = super.Validate()
        This.ValidateConstraints()
        return [
            :valid = (len(@aValidationErrors) = 0),
            :errors = @aValidationErrors,
            :error_count = len(@aValidationErrors),
            :tables_validated = aBasicValidation[:tables_validated],
            :constraints_validated = len(@aConstraints)
        ]

    def ValidateForeignKeys()
        nLen = len(@aConstraints)
        for i = 1 to nLen
            aConstraint = @aConstraints[i]
            cTableName = aConstraint[:table]
            cFieldName = aConstraint[:field]
            cType = aConstraint[:type]
            if cType = "foreign_key"
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
        next

    def ValidateConstraints()
        nLen = len(@aConstraints)
        for i = 1 to nLen
            aConstraint = @aConstraints[i]
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
            if cType = "foreign_key"
                This.ValidateForeignKeys()
            ok
            if cType = "check"
                if not This.ValidateCheckConstraint(aConstraint[:constraint])
                    @aValidationErrors + [ :type = "constraint", :severity = "warning",
                                         :message = "Potentially invalid CHECK constraint syntax",
                                         :table = cTableName, :field = cFieldName,
                                         :constraint = aConstraint[:constraint] ]
                ok
            ok
        next

    # Database utility methods
    def FindLastChar(cStr, cChar)
        acChars = Chars(cStr)
        nLen = len(acChars)
        for i = nLen to 1 step -1
            if acChars[i] = cChar
                return i
            ok
        next
        return 0

    def FindSubstring(cStr, cSubstr)
        return substr(cStr, cSubstr)

    def FindSubstringFrom(cStr, cSubstr, nStartPos)
        for i = nStartPos to len(cStr) - len(cSubstr) + 1
            if substr(cStr, i, len(cSubstr)) = cSubstr
                return i
            ok
        next
        return 0

    def ExtractSection(cStr, nStart, nEnd)
        if nEnd > len(cStr)
            nEnd = len(cStr)
        ok
        return substr(cStr, nStart, nEnd - nStart + 1)

    def ReplaceSubstring(cStr, cOld, cNew)
        return strreplace(cStr, cOld, cNew)

    def RemoveJSONWhitespace(cJSON)
        cResult = ""
        bInString = FALSE
        acChars = Chars(cJSON)
        for i = 1 to len(acChars)
            cChar = acChars[i]
            if cChar = '"' and (i = 1 or acChars[i-1] != "\")
                bInString = !bInString
            ok
            if bInString or (cChar != " " and cChar != Tab() and cChar != NL())
                cResult += cChar
            ok
        next
        return cResult

    # Override AddTable to include constraints
    def AddTable(cTableName, aFields)
        super.AddTable(cTableName, aFields)
        aTable = This.Table(cTableName)
        for field in aTable[:fields]
            cFieldName = field[:name]
            cFieldType = field[:type]
            if cFieldType = :primary_key
                This.AddConstraint(cTableName, cFieldName, "PRIMARY KEY")
            but cFieldType = :required
                This.AddConstraint(cTableName, cFieldName, "NOT NULL")
            but cFieldType = :email
                This.AddConstraint(cTableName, cFieldName, "CHECK (email LIKE '%@%')")
            but isString(cFieldType) and @substr(upper(cFieldType), "VARCHAR", []) > 0
                # VARCHAR constraint already embedded in type
            ok

            if @bUseRelInfere and (cFieldType = :foreign_key or right(cFieldName, 3) = "_id")
                This.InferRelationsFromFK(cTableName, cFieldName)
            ok

        next
        

    # Import from Mermaid ERD format
    def FromMermaid(cMermaidERD)
        This.ClearModel()
        acLines = split(cMermaidERD, NL())
        cCurrentEntity = ""
        bInEntity = FALSE
        for cLine in acLines
            cLine = trim(cLine)
            if cLine = "erDiagram"
                loop
            ok
            if right(cLine, 1) = "{" and !bInEntity
                cCurrentEntity = trim(left(cLine, len(cLine) - 1))
                bInEntity = TRUE
                This.AddTable(cCurrentEntity, [])
                loop
            ok
            if cLine = "}" and bInEntity
                bInEntity = FALSE
                cCurrentEntity = ""
                loop
            ok
            if bInEntity and cLine != ""
                aFieldParts = split(cLine, " ")
                if len(aFieldParts) >= 2
                    cFieldName = aFieldParts[1]
                    cFieldType = aFieldParts[2]
                    This.AddField(cCurrentEntity, cFieldName, cFieldType, [])
                    if cFieldType = "primary_key"
                        This.AddConstraint(cCurrentEntity, cFieldName, "PRIMARY KEY")
                    ok
                    if cFieldType = "required"
                        This.AddConstraint(cCurrentEntity, cFieldName, "NOT NULL")
                    ok
                ok
            ok
            if This.FindSubstring(cLine, "||--") > 0 or This.FindSubstring(cLine, "--o{") > 0
                acParts = split(cLine, " ")
                if len(acParts) >= 3
                    cFromEntity = acParts[1]
                    cToEntity = acParts[3]
                    This.AddRelation(cFromEntity, cToEntity, "has_many", [])
                ok
            ok
        next
        
