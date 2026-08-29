#====================#
# stzDataModel class #
#====================#

# Storage-agnostic data modeling foundation

@acDataModelFieldTypes = [ "identifier", "reference", "string", "number", "boolean", "text" ]

class stzDataModel from stzObject

    @cSchemaName
    @aTables = []
    @aRelations = []
    @bUseRelInfere = FALSE
    @cValidationMode = "warning"  # Can be "warning", "strict", "permissive"
    @aValidationResult = []
    @bAutoFix = TRUE
    @aStructureSnapshot = []
    @aAppliedFixes = []
    @aFixHistory = []

    #==================#
    #  INITIALIZATION  #
    #==================#

    def init(cSchemaName)
        if isString(cSchemaName)
            @cSchemaName = cSchemaName
        else
            @cSchemaName = "default"
        ok

    #==========================#
    #  CONFIGURATION METHODS   #
    #==========================#

    def SetValidationMode(cMode)
        if find([ "warning", "strict", "permissive" ], cMode) > 0
            @cValidationMode = cMode
        else
            StzRaise("Invalid validation mode: " + cMode)
        ok

    def ValidationMode()
        return @cValidationMode

    def UseRelationInference()
        @bUseRelInfere = TRUE

    def SetRelInfere(bValue)
        if isBool(bValue)
            @bUseRelInfere = bValue
        else
            StzRaise("Incorrect param type! bValue must be TRUE or FALSE.")
        ok

    def RelationInference()
        return @bUseRelInfere

    #=======================#
    #  SCHEMA INFORMATION   #
    #=======================#

    def SchemaName()
        return @cSchemaName

    def Tables()
        return @aTables

    def Relations()
        return @aRelations

    #====================#
    #  TABLE MANAGEMENT  #
    #====================#

    def AddTable(cTableName, aFields)
        if NOT isString(cTableName)
            StzRaise("Incorrect param type! cTableName must be a string.")
        ok
        if NOT (isList(aFields) and This.IsValidFieldList(aFields))
            StzRaise("Incorrect param type! aFields must be a list of pairs of strings.")
        ok
        aProcessedFields = []
        _aAField253_ = aFields
        _nAField253_ = len(_aAField253_)
        for _iAField253_ = 1 to _nAField253_
        	aField = _aAField253_[_iAField253_]
            aProcessedFields + [ :name = aField[1], :type = This.ProcessFieldType(aField[2]) ]
        next
        aTable = [ :name = cTableName, :fields = aProcessedFields ]
        @aTables + aTable
        if @bUseRelInfere
            This.InferRelationsForTable(aTable)
        ok
        return This

    def TableExists(cTableName)
        _aATable254_ = @aTables
        _nATable254_ = len(_aATable254_)
        for _iATable254_ = 1 to _nATable254_
        	aTable = _aATable254_[_iATable254_]
            if aTable[:name] = cTableName
                return TRUE
            ok
        next
        return FALSE

    def Table(cTableName)
        _aATable255_ = @aTables
        _nATable255_ = len(_aATable255_)
        for _iATable255_ = 1 to _nATable255_
        	aTable = _aATable255_[_iATable255_]
            if aTable[:name] = cTableName
                return aTable
            ok
        next
        StzRaise("Table not found: " + cTableName)

    def TableNames()
        acNames = []
        _aATable256_ = @aTables
        _nATable256_ = len(_aATable256_)
        for _iATable256_ = 1 to _nATable256_
        	aTable = _aATable256_[_iATable256_]
            acNames + aTable[:name]
        next
        return acNames

    def CountTables()
        return len(@aTables)

    #====================#
    #  FIELD MANAGEMENT  #
    #====================#

    def AddField(cTableName, cFieldName, cFieldType)
        aTable = This.Table(cTableName)
        aField = [ :name = cFieldName, :type = This.ProcessFieldType(cFieldType) ]
        aTable[:fields] + aField
        return This

    def FieldExists(aTable, cFieldName)
        _aAField257_ = aTable[:fields]
        _nAField257_ = len(_aAField257_)
        for _iAField257_ = 1 to _nAField257_
        	aField = _aAField257_[_iAField257_]
            if aField[:name] = cFieldName
                return TRUE
            ok
        next
        return FALSE

    def TableFields(cTableName)
        return This.Table(cTableName)[:fields]

    def CountTableFields(cTableName)
        return len(This.TableFields(cTableName))

    #=======================#
    #  RELATION MANAGEMENT  #
    #=======================#

    def AddRelation(cType, cFromTable, cToTable, aOptions)
        if @bUseRelInfere
            StzRaise("Can't define relations when inference is active!")
        ok
        if NOT isString(cType) or NOT isString(cFromTable) or NOT isString(cToTable)
            StzRaise("Incorrect param type! cType, cFromTable, and cToTable must be strings.")
        ok
        if NOT This.TableExists(cFromTable) or NOT This.TableExists(cToTable)
            StzRaise("Invalid table name!")
        ok
        cField = iff(HasKey(aOptions, :field), aOptions[:field], "")
        if not This.RelationExists(cType, cFromTable, cToTable, cField)
            @aRelations + [
                [ "type", cType ],
                [ "from", cFromTable ],
                [ "to", cToTable ],
                [ "field", cField ],
                [ "inferred", 0 ]
            ]
        ok

    def InferRelationsForTable(aTable)
        aFields = aTable[:fields]
        _aAField258_ = aFields
        _nAField258_ = len(_aAField258_)
        for _iAField258_ = 1 to _nAField258_
        	aField = _aAField258_[_iAField258_]
            cFieldName = aField[:name]
            if right(cFieldName, 3) = "_id" and aField[:type] = "reference"
                cRelatedTableSingular = left(cFieldName, len(cFieldName) - 3)
                cRelatedTable = PluralOf(cRelatedTableSingular)
                if This.TableExists(cRelatedTable)
                    if not This.RelationExists("one-to-many", cRelatedTable, aTable[:name], cFieldName)
                        @aRelations + [
                            [ "type", "one-to-many" ],
                            [ "from", cRelatedTable ],
                            [ "to", aTable[:name] ],
                            [ "field", cFieldName ],
                            [ "inferred", 1 ]
                        ]
                    ok
                ok
            ok
        next

    def RelationExists(cType, cFromTable, cToTable, cField)
        _aARel259_ = @aRelations
        _nARel259_ = len(_aARel259_)
        for _iARel259_ = 1 to _nARel259_
        	aRel = _aARel259_[_iARel259_]
            if aRel[:type] = cType and aRel[:from] = cFromTable and aRel[:to] = cToTable and aRel[:field] = cField
                return TRUE
            ok
        next
        return FALSE

    def getRelatedRecords(cFromTable, cIdentifier, cToTable)
        aResult = []
        _aARel260_ = @aRelations
        _nARel260_ = len(_aARel260_)
        for _iARel260_ = 1 to _nARel260_
        	aRel = _aARel260_[_iARel260_]
            if aRel[:from] = cFromTable and aRel[:to] = cToTable
                // Placeholder: Concrete classes implement data retrieval
            ok
        next
        return aResult

    #=========================#
    #  VALIDATION MANAGEMENT  #
    #=========================#

    def validateData(cTableName, aData)
        aTable = This.Table(cTableName)
        _aAField261_ = aTable[:fields]
        _nAField261_ = len(_aAField261_)
        for _iAField261_ = 1 to _nAField261_
        	aField = _aAField261_[_iAField261_]
            cFieldName = aField[:name]
            cFieldType = aField[:type]
            if not HasKey(aData, cFieldName)
                StzRaise("Missing field: " + cFieldName)
            ok
            vValue = aData[cFieldName]
            switch cFieldType
            on "identifier" or "reference"
                if not isString(vValue) or vValue = ""
                    StzRaise("Field " + cFieldName + " must be a non-empty string!")
                ok
            on "string" or "text"
                if not isString(vValue)
                    StzRaise("Field " + cFieldName + " must be a string!")
                ok
            on "number"
                if not isNumber(vValue)
                    StzRaise("Field " + cFieldName + " must be a number!")
                ok
            on "boolean"
                if not isBool(vValue)
                    StzRaise("Field " + cFieldName + " must be a boolean!")
                ok
            off
        next
        return TRUE

    def Validate()
        aResults = []
        nUnnamedCounter = 1
        for i = 1 to len(@aTables)
            aTable = @aTables[i]
            nUnnamedCounter = This._ValidateTableName(aTable, i, aResults, nUnnamedCounter)
            This._ValidateFieldNames(aTable, i, aResults)
        next
        @aValidationResult = aResults
        return This._CountValidationResults(aResults)

    def _ValidateTableName(aTable, nTableIndex, aResults, nUnnamedCounter)
        if aTable[:name] = ""
            nErrorIndex = len(aResults) + 1
            aResults + [
                :type = "error", :severity = "error", :category = "table",
                :message = "Empty table name", :table = "",
                :table_index = nTableIndex, :fixed = FALSE
            ]
            if @cValidationMode = "permissive"
                newName = "unnamed_table_" + nUnnamedCounter
                @aTables[nTableIndex][:name] = newName
                aResults + [
                    :type = "fix", :plan = "default", :condition = "empty_table_name",
                    :description = "Renamed empty table name", :old_value = "",
                    :new_value = newName, :table_index = nTableIndex
                ]
                aResults[nErrorIndex][:fixed] = TRUE
                nUnnamedCounter++
            ok
        ok
        return nUnnamedCounter

    def _ValidateFieldNames(aTable, nTableIndex, aResults)
        aFieldNames = []
        nDuplicateCounter = 1
        for j = 1 to len(aTable[:fields])
            cOriginalName = aTable[:fields][j][:name]
            if find(aFieldNames, cOriginalName) > 0
                nErrorIndex = len(aResults) + 1
                aResults + [
                    :type = "error", :severity = "error", :category = "field",
                    :message = "Duplicate field: " + cOriginalName,
                    :table = aTable[:name], :field = cOriginalName,
                    :field_index = j, :fixed = FALSE
                ]
                if @cValidationMode = "permissive"
                    newName = cOriginalName + "_" + nDuplicateCounter
                    @aTables[nTableIndex][:fields][j][:name] = newName
                    aResults + [
                        :type = "fix", :plan = "default", :condition = "duplicate_field",
                        :description = "Renamed duplicate field", :old_value = cOriginalName,
                        :new_value = newName, :table = aTable[:name], :field_index = j
                    ]
                    aResults[nErrorIndex][:fixed] = TRUE
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
        _aAResul262_ = aResults
        _nAResul262_ = len(_aAResul262_)
        for _iAResul262_ = 1 to _nAResul262_
        	aResult = _aAResul262_[_iAResul262_]
            if aResult[:type] = "error"
                nErrors++
            ok
            if aResult[:type] = "warning"
                nWarnings++
            ok
            if aResult[:type] = "fix"
                nFixes++
            ok
        next
        return [
            :errors_count = nErrors,
            :warnings_count = nWarnings,
            :fixes_applied = nFixes,
            :tables_validated = len(@aTables),
            :active_plans = ["default"]
        ]

    def Errors()
        aErrors = []
        _aAResul263_ = @aValidationResult
        _nAResul263_ = len(_aAResul263_)
        for _iAResul263_ = 1 to _nAResul263_
        	aResult = _aAResul263_[_iAResul263_]
            if aResult[:type] = "error" and aResult[:fixed] = FALSE
                aErrors + aResult
            ok
        next
        return aErrors

    def FixedErrors()
        aErrors = []
        _aAResul264_ = @aValidationResult
        _nAResul264_ = len(_aAResul264_)
        for _iAResul264_ = 1 to _nAResul264_
        	aResult = _aAResul264_[_iAResul264_]
            if aResult[:type] = "error" and aResult[:fixed] = TRUE
                aErrors + aResult
            ok
        next
        return aErrors

    def Warnings()
        aWarnings = []
        _aAResul265_ = @aValidationResult
        _nAResul265_ = len(_aAResul265_)
        for _iAResul265_ = 1 to _nAResul265_
        	aResult = _aAResul265_[_iAResul265_]
            if aResult[:severity] = "warning"
                aWarnings + aResult
            ok
        next
        return aWarnings

    def AppliedFixes()
        aFixes = []
        _aAResul266_ = @aValidationResult
        _nAResul266_ = len(_aAResul266_)
        for _iAResul266_ = 1 to _nAResul266_
        	aResult = _aAResul266_[_iAResul266_]
            if aResult[:type] = "fix"
                aFixes + aResult
            ok
        next
        return aFixes

    def CreateSnapshot()
        @aStructureSnapshot = []
        _aATable267_ = @aTables
        _nATable267_ = len(_aATable267_)
        for _iATable267_ = 1 to _nATable267_
        	aTable = _aATable267_[_iATable267_]
            aTableCopy = [ :name = aTable[:name], :fields = [] ]
            _aAField268_ = aTable[:fields]
            _nAField268_ = len(_aAField268_)
            for _iAField268_ = 1 to _nAField268_
            	aField = _aAField268_[_iAField268_]
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

    def UndoLastFixes(nCount)
        if isNull(nCount)
            nCount = 1
        ok
        nSessions = len(@aFixHistory)
        if nSessions = 0
            ? "No fixes to undo"
            return
        ok
        nToUndo = min(nCount, nSessions)
        for i = 1 to nToUndo
            aSession = @aFixHistory[nSessions - i + 1]
            @aTables = aSession[:snapshot]
            del(@aFixHistory, nSessions - i + 1)
        next
        ? "Undone " + nToUndo + " fix session(s)"

    #===================#
    #  SERIALIZATION    #
    #===================#

    def toJSON()
        oJSON = new stzJSON()
        return oJSON.stringify([ :tables = @aTables, :relations = @aRelations ])

    def fromJSON(cJSON)
        oJSON = new stzJSON()
        aData = oJSON.parse(cJSON)
        @aTables = aData[:tables]
        @aRelations = aData[:relations]

    #===================#
    #  UTILITY METHODS  #
    #===================#

    def ProcessFieldType(cType)
        switch cType
        on "identifier" or "reference"
            return "string"
        on "string" or "text"
            return "string"
        on "number"
            return "number"
        on "boolean"
            return "boolean"
        other
            return cType
        off

    def IsValidFieldList(aList)
        if not isList(aList)
            return FALSE
        ok
        _aAField269_ = aList
        _nAField269_ = len(_aAField269_)
        for _iAField269_ = 1 to _nAField269_
        	aField = _aAField269_[_iAField269_]
            if not (isList(aField) and len(aField) >= 2 and isString(aField[1]) and find(@acDataModelFieldTypes, aField[2]) > 0)
                return FALSE
            ok
        next
        return TRUE
