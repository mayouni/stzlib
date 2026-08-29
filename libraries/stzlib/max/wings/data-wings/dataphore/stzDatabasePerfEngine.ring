# Global performance plans for easy extension
$aPerfPlans = [
    :default = [
        :description = "General purpose application",
        :rules = [
            [
                :id = "basic_fk_index",
                :type = "index_optimization",
                :priority = "medium",
                :condition = "foreign_key_without_index",
                :message = "Consider adding index on {table}.{field}",
                :action = "CREATE INDEX idx_{table}_{field} ON {table}({field})",
                :impact = "medium"
            ],
            [
                :id = "query_awareness",
                :type = "query_optimization",
                :priority = "low",
                :condition = "has_many_relationship",
                :message = "Monitor N+1 queries for {from_table} -> {to_table}",
                :action = "Use eager loading for {from_table} -> {to_table}",
                :impact = "medium"
            ]
        ]
    ],
    :web = [
        :description = "Web application with OLTP workload",
        :rules = [
            [
                :id = "fk_index_mandatory",
                :type = "index_optimization",
                :priority = "high",
                :condition = "foreign_key_without_index",
                :message = "Foreign key {table}.{field} must have index for web performance",
                :action = "CREATE INDEX idx_{table}_{field} ON {table}({field})",
                :impact = "high"
            ],
            [
                :id = "n_plus_one_prevention",
                :type = "query_optimization",
                :priority = "critical",
                :condition = "has_many_relationship",
                :message = "N+1 queries will impact {from_table} -> {to_table} performance",
                :action = "Implement eager loading for {from_table} -> {to_table}",
                :impact = "critical"
            ],
            [
                :id = "pagination_requirement",
                :type = "data_access",
                :priority = "high",
                :condition = "large_result_sets",
                :message = "Table {table} needs pagination strategy",
                :action = "Implement pagination for {table}",
                :impact = "high"
            ]
        ]
    ],
    :analytics = [
        :description = "Analytics and reporting workload",
        :rules = [
            [
                :id = "complex_join_optimization",
                :type = "schema_optimization",
                :priority = "medium",
                :condition = "complex_joins",
                :message = "Table {table} involved in complex joins",
                :action = "Consider denormalization for {table}",
                :impact = "medium"
            ],
            [
                :id = "text_field_optimization",
                :type = "data_transfer",
                :priority = "medium",
                :condition = "large_text_fields",
                :message = "Large text field {table}.{field} impacts performance",
                :action = "Consider lazy loading for {table}.{field}",
                :impact = "medium"
            ]
        ]
    ]
]


# Simplified stzDataPerfEngine with cleaner design
class stzDatabasePerfEngine from stzObject
    @cActivePlan
    @aThresholds
    
    def init()
        @cActivePlan = "default"
        @aThresholds = [
            :high_field_count = 20,
            :moderate_field_count = 6,
            :high_relationship_count = 5,
            :moderate_relationship_count = 2
        ]
    
    # Core interface methods
    def SetActivePlan(cPlanName)
        @cActivePlan = cPlanName
        return This
    
    # Main analysis method - called by stzDataModel
    def AnalyzeModel(aModelData)
        aHints = []
        
        if not HasKey($aPerfPlans, @cActivePlan)
            return []
        ok
        
        aPlan = $aPerfPlans[@cActivePlan]
        
        _aARule245_ = aPlan[:rules]
        _nARule245_ = len(_aARule245_)
        for _iARule245_ = 1 to _nARule245_
        	aRule = _aARule245_[_iARule245_]
            aMatches = This.EvaluateRule(aRule, aModelData)
            _aAMatch246_ = aMatches
            _nAMatch246_ = len(_aAMatch246_)
            for _iAMatch246_ = 1 to _nAMatch246_
            	aMatch = _aAMatch246_[_iAMatch246_]
                aHints + This.CreateHint(aRule, aMatch)
            next
        next
        
        return aHints
    
    # Rule evaluation - simplified
    def EvaluateRule(aRule, aModelData)
        cCondition = aRule[:condition]
        
        switch cCondition
        on "foreign_key_without_index"
            return This.FindForeignKeys(aModelData)

        on "has_many_relationship"
            return This.FindHasManyRelations(aModelData)

        on "large_result_sets"
            return This.FindLargeTables(aModelData)

        on "large_text_fields"
            return This.FindTextFields(aModelData)

        on "complex_joins"
            return This.FindComplexJoins(aModelData)

        other
            return []
        off
    
    # Helper methods for rule evaluation
    def FindForeignKeys(aModelData)

        aResults = []
        if HasKey(aModelData, :relationships)

            _aARel247_ = aModelData[:relationships]
            _nARel247_ = len(_aARel247_)
            for _iARel247_ = 1 to _nARel247_
            	aRel = _aARel247_[_iARel247_]
                if aRel[:type] = "belongs_to"
                    aResults + [
                        :table = aRel[:from],
                        :field = aRel[:field],
                        :related_table = aRel[:to]
                    ]
                ok
            next

        ok
        return aResults
    
    def FindHasManyRelations(aModelData)
        aResults = []

        if HasKey(aModelData, :relationships)

            _aARel248_ = aModelData[:relationships]
            _nARel248_ = len(_aARel248_)
            for _iARel248_ = 1 to _nARel248_
            	aRel = _aARel248_[_iARel248_]
                if aRel[:type] = "has_many"
                    aResults + [
                        :from_table = aRel[:from],
                        :to_table = aRel[:to]
                    ]
                ok
            next

        ok
        return aResults
    
    def FindLargeTables(aModelData)
        aResults = []

        if HasKey(aModelData, :tables)
            _aATable249_ = aModelData[:tables]
            _nATable249_ = len(_aATable249_)
            for _iATable249_ = 1 to _nATable249_
            	aTable = _aATable249_[_iATable249_]
                if aTable[:relationship_count] > @aThresholds[:moderate_relationship_count]
                    aResults + [
                        :table = aTable[:name],
                        :relationship_count = aTable[:relationship_count]
                    ]
                ok
            next
        ok

        return aResults
    
    def FindTextFields(aModelData)

        aResults = []

        if HasKey(aModelData, :tables)

            _aATable250_ = aModelData[:tables]
            _nATable250_ = len(_aATable250_)
            for _iATable250_ = 1 to _nATable250_
            	aTable = _aATable250_[_iATable250_]

                if HasKey(aTable, :fields)

                    _aAField251_ = aTable[:fields]
                    _nAField251_ = len(_aAField251_)
                    for _iAField251_ = 1 to _nAField251_
                    	aField = _aAField251_[_iAField251_]
                        if aField[:type] = "text" or aField[:type] = "longtext"
                            aResults + [
                                :table = aTable[:name],
                                :field = aField[:name],
                                :type = aField[:type]
                            ]
                        ok
                    next

                ok
            next
        ok
        return aResults
    
    def FindComplexJoins(aModelData)
        aResults = []

        if HasKey(aModelData, :tables)

            _aATable252_ = aModelData[:tables]
            _nATable252_ = len(_aATable252_)
            for _iATable252_ = 1 to _nATable252_
            	aTable = _aATable252_[_iATable252_]

                if aTable[:relationship_count] >= @aThresholds[:high_relationship_count]
                    aResults + [
                        :table = aTable[:name],
                        :relationship_count = aTable[:relationship_count]
                    ]
                ok

            next
        ok

        return aResults
    
    # Create hint from rule and match data
    def CreateHint(aRule, aMatchData)

        cMessage = This.ProcessMessageTemplate(aRule[:message], aMatchData)
        cAction = This.ProcessActionTemplate(aRule[:action], aMatchData)
        
        return [
            :rule_id = aRule[:id],
            :type = aRule[:type],
            :priority = aRule[:priority],
            :message = cMessage,
            :action = cAction,
            :impact = aRule[:impact],
            :data = aMatchData
        ]
    
    def ProcessMessageTemplate(cTemplate, aData)
        cResult = cTemplate
        if HasKey(aData, :table)
            cResult = ring_substr2(cResult, "{table}", aData[:table])
        ok
        if HasKey(aData, :field)
            cResult = ring_substr2(cResult, "{field}", aData[:field])
        ok
        if HasKey(aData, :from_table)
            cResult = ring_substr2(cResult, "{from_table}", aData[:from_table])
        ok
        if HasKey(aData, :to_table)
            cResult = ring_substr2(cResult, "{to_table}", aData[:to_table])
        ok
        return cResult
    
    def ProcessActionTemplate(cAction, aData)

        if isString(cAction)
            return This.ProcessMessageTemplate(cAction, aData)
        ok

        if isList(cAction) and HasKey(cAction, :Ring)
            return This.ProcessMessageTemplate(cAction[:Ring], aData)
        ok
        return "No action specified"
    
    def ActivePlan()
		return @cActivePlan


    # Threshold management
    def SetThreshold(cName, nValue)
        @aThresholds[cName] = nValue
        return This
    
    def Threshold(cName)
        if HasKey(@aThresholds, cName)
            return @aThresholds[cName]
        ok
        return 0
    
    def Thresholds()
        return @aThresholds
