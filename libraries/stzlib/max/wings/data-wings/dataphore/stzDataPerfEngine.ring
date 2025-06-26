# Global performance rules abstracted into configurable containers
$aPerfs = [

        # Default balanced plan
        :default = [

            :Description = "General purpose application",
            :priority_focus = [ "balance", "maintainability", "performance" ],

            :rules = [
                [
                    :id = "basic_fk_index",
                    :type = "index_optimization",
                    :priority = "medium",
                    :condition = "foreign_key_without_index",
                    :message = "Consider adding index on foreign key field",
                    :action = [
                        :SQL = "CREATE INDEX idx_{table}_{field} ON {table}({field})",
                        :Ring = 'This.AddIndex("{table}", "{field}", [:type = "btree", :reason = "Basic foreign key optimization"])'
                    ],
                    :performance_impact = "medium",
                    :applies_to = "all_foreign_keys"
                ],
                [
                    :id = "query_awareness",
                    :type = "query_optimization",
                    :priority = "low",
                    :condition = "has_many_relationship",
                    :message = "Be aware of potential N+1 query issues",
                    :action = [
                        :SQL = "Monitor and optimize {from_table} -> {to_table} queries as needed",
                        :Ring = 'This.SetQueryMonitoring("{from_table}", "{to_table}", [:alert_threshold = 100])'
                    ],
                    :performance_impact = "medium",
                    :applies_to = "has_many_relationships"
                ]
            ]
        ],

    # Web Application Optimization Plan
	:web = [

		:Description = "Web application with OLTP workload",
		:priority_focus = [ "query_speed", "concurrent_access", "scalability" ],
	
		:rules = [
			[
				:id = "fk_index_mandatory",
				:type = "index_optimization",
				:priority = "high",
				:condition = "foreign_key_without_index",
				:message = "Foreign key fields must have indexes for web performance",
				:action = [
					:SQL = "CREATE INDEX idx_{table}_{field} ON {table}({field})",
					:Ring = 'This.AddIndex("{table}", "{field}", [:type = "btree", :reason = "Foreign key optimization"])'
				],
				:performance_impact = "high",
				:applies_to = "all_foreign_keys"
			],
			[
				:id = "n_plus_one_prevention",
				:type = "query_optimization", 
				:priority = "critical",
				:condition = "has_many_relationship",
				:message = "N+1 queries will severely impact web response times",
				:action = [
					:SQL = "Use eager loading or batch queries for {from_table} -> {to_table}",
					:Ring = 'This.SetEagerLoading("{from_table}", "{to_table}", [:strategy = "batch_queries"])'
				],
				:performance_impact = "critical",
				:applies_to = "has_many_relationships"
			],
			[
				:id = "pagination_requirement",
				:type = "data_access_pattern",
				:priority = "high", 
				:condition = "large_result_sets",
				:message = "Large tables require pagination to prevent memory issues",
				:action = [
					:SQL = "Implement pagination for {table} with LIMIT/OFFSET or cursor-based pagination",
					:Ring = 'This.SetPaginationStrategy("{table}", [:type = "cursor_based", :page_size = 50])'
				],
				:performance_impact = "high",
				:applies_to = "tables_with_many_records"
			]
		]

	],
      
	# Analytics/Reporting Optimization Plan
	:analytics = [

            :Description = "Analytics and reporting workload (OLAP)",
            :priority_focus = [ "aggregation_speed", "data_warehouse_patterns", "read_optimization" ],

            :rules = [
                [
                    :id = "covering_indexes",
                    :type = "index_optimization",
                    :priority = "high",
                    :condition = "frequent_column_combinations",
                    :message = "Create covering indexes for common query patterns",
                    :action = [
                        :SQL = "CREATE INDEX idx_{table}_covering ON {table}({key_columns}) INCLUDE ({data_columns})",
                        :Ring = 'This.AddCoveringIndex("{table}", [:key_columns = "{key_columns}", :include_columns = "{data_columns}"])'
                    ],
                    :performance_impact = "high",
                    :applies_to = "frequently_queried_combinations"
                ],
                [
                    :id = "denormalization_consideration",
                    :type = "schema_optimization",
                    :priority = "medium",
                    :condition = "complex_joins_frequent",
                    :message = "Consider denormalization for frequently joined data",
                    :action = [
                        :SQL = "Evaluate creating materialized view or denormalized table for {join_pattern}",
                        :Ring = 'This.CreateMaterializedView("{join_pattern}_view", [:refresh_strategy = "on_demand"])'
                    ],
                    :performance_impact = "medium",
                    :applies_to = "complex_relationship_chains"
                ],
                [
                    :id = "partitioning_strategy",
                    :type = "data_organization",
                    :priority = "high",
                    :condition = "large_time_series_data",
                    :message = "Large tables benefit from partitioning strategy",
                    :action = [
                        :SQL = "Implement table partitioning on {table} by {partition_key}",
                        :Ring = 'This.AddPartitioning("{table}", [:strategy = "range", :partition_key = "{partition_key}"])'
                    ],
                    :performance_impact = "high",
                    :applies_to = "large_tables_with_time_dimension"
                ]
            ]
        ],
       
        # Mobile/Edge Optimization Plan
        :mobile = [

            :Description = "Mobile application with limited bandwidth/resources",
            :priority_focus = [ "data_transfer_minimization", "offline_capability", "battery_optimization" ],

            :rules = [
                [
                    :id = "minimal_payload",
                    :type = "data_transfer",
                    :priority = "high",
                    :condition = "large_text_fields",
                    :message = "Large text fields impact mobile data transfer",
                    :action = [
                        :SQL = "Consider separate endpoint for {table}.{large_field} or implement field selection",
                        :Ring = 'This.SetFieldSelectionStrategy("{table}", [:lazy_load_fields = ["{large_field}"]])'
                    ],
                    :performance_impact = "high",
                    :applies_to = "text_blob_fields"
                ],
                [
                    :id = "sync_friendly_design",
                    :type = "data_synchronization",
                    :priority = "medium",
                    :condition = "frequent_updates",
                    :message = "Tables with frequent updates need sync-friendly design",
                    :action = [
                        :SQL = "Add timestamp fields and soft delete for {table}",
                        :Ring = 'This.AddSyncFields("{table}", [:timestamp_field = "updated_at", :soft_delete = true])'
                    ],
                    :performance_impact = "medium",
                    :applies_to = "frequently_modified_tables"
                ]
            ]
        ]
]

class stzDataPerfEngine from stzObject
    @aRuleSets
    @cActivePlan
    @aDescriptionRules
    @aThresholds
    
    def init()
        @aRuleSets = []
        @cActivePlan = "default"
        @aDescriptionRules = []
        @aThresholds = [
            :table_field_count_high = 20,
            :table_field_count_moderate = 10,
            :table_relationship_count_high = 10,
            :table_relationship_count_moderate = 5,
            :query_depth_warning = 3,
            :index_cardinality_threshold = 1000
        ]
        This.InitRules()
    
    def InitRules()
        # Web Application Optimization Plan
         @aRuleSets = [
            [
                :name = "default",
                :plan = $aPerfs[:default]
            ]
        ]
    
    def AddRulePlan(cPlanName, aRulePlan)
        @aRuleSets + [
            :name = cPlanName,
            :plan = aRulePlan
        ]
    
    def SetActivePlan(cPlanName)
        @cActivePlan = cPlanName
        return This
    
    def ActivePlan()
        return @cActivePlan
    
    def RulesForPlan(cPlanName)
        nLen = len(@aRuleSets)
        for i = 1 to nLen
            if @aRuleSets[i][:name] = cPlanName
                return @aRuleSets[i][:plan][:rules]
            ok
        next
        return []
    
    def ActiveRules()
        return This.RulesForPlan(@cActivePlan)
    
    def PlanDescription(cPlanName)
        nLen = len(@aRuleSets)
        for i = 1 to nLen
            if @aRuleSets[i][:name] = cPlanName
                return @aRuleSets[i][:plan][:Description]
            ok
        next
        return "Unknown Description"
    
		def PlanXT(cPlanName)
			return This.PlanDescription(cPlanName)


    def EvalRule(aRule, aModelData)
        # Evaluate if rule condition is met given model data
        cCondition = aRule[:condition]
        
        switch cCondition

        on "foreign_key_without_index"
            return This.CheckForeignKeysWithoutIndexes(aModelData)

        on "has_many_relationship"
            return This.CheckHasManyRelationships(aModelData)

        on "large_result_sets"
            return This.CheckLargeResultSets(aModelData)

        on "large_text_fields"
            return This.CheckLarextFields(aModelData)

        on "frequent_updates"
            return This.CheckFrequentUpdates(aModelData)

        on "complex_joins_frequent"
            return This.CheckComplexJoins(aModelData)

        on "large_time_series_data"
            return This.CheckTimeSeriesData(aModelData)

        other
            return []  # No matches found
        off

		def EvaluateRule(aRule, aModelData)
			return This.EvalRule(aRule, aModelData)
    
    def CheckForeignKeysWithoutIndexes(aModelData)
        aResults = []

        if HasKey(aModelData, :relationships) > 0
            aRelationships = aModelData[:relationships]
            nLen = len(aRelationships)

            for i = 1 to nLen

                aRel = aRelationships[i]

                if aRel[:type] = "belongs_to" and HasKey(aRel, :field) > 0

                    aResults + [
                        :table = aRel[:from],
                        :field = aRel[:field],
                        :related_table = aRel[:to],
                        :relationship_type = aRel[:type]
                    ]

                ok

            next

        ok

        return aResults
    
    def CheckHasManyRelationships(aModelData)
        aResults = []

        if HasKey(aModelData, :relationships) > 0

            aRelationships = aModelData[:relationships]

            nLen = len(aRelationships)

            for i = 1 to nLen

                aRel = aRelationships[i]

                if aRel[:type] = "has_many"

                    aResults + [
                        :from_table = aRel[:from],
                        :to_table = aRel[:to],
                        :relationship_type = aRel[:type]
                    ]

                ok

            next

        ok

        return aResults
    
    def CheckLargeResultSets(aModelData)
        aResults = []

        if HasKey(aModelData, :tables) > 0

            aTables = aModelData[:tables]
            nLen = len(aTables)

            for i = 1 to nLen

                aTable = aTables[i]

                # Heuristic: tables with many relationships likely have many records

                if HasKey(aTable, :relationship_count) > 0 and aTable[:relationship_count] > @aThresholds[:table_relationship_count_moderate]
                    aResults + [
                        :table = aTable[:name],
                        :reason = "high_relationship_count",
                        :relationship_count = aTable[:relationship_count]
                    ]
                ok

            next
        ok

        return aResults
    
    def CheckLarextFields(aModelData)

        aResults = []

        if HasKey(aModelData, :tables) > 0

            aTables = aModelData[:tables]
            nLen = len(aTables)

            for i = 1 to nLen

                aTable = aTables[i]

                if HasKey(aTable, :fields) > 0

                    aFields = aTable[:fields]
                    nFieldLen = len(aFields)

                    for j = 1 to nFieldLen

                        aField = aFields[j]

                        if HasKey(aField, :type) > 0 and (aField[:type] = "text" or aField[:type] = "longtext")

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
    
    def CheckFrequentUpdates(aModelData) #TODO
        # Placeholder - in real implementation, this would analyze usage patterns
        return []
 
    def CheckComplexJoins(aModelData)
        aResults = []

        # Look for tables involved in multiple relationships

        if HasKey(aModelData, :tables) > 0

            aTables = aModelData[:tables]
            nLen = len(aTables)

            for i = 1 to nLen

                aTable = aTables[i]

                if HasKey(aTable, :relationship_count) > 0 and aTable[:relationship_count] >= @aThresholds[:table_relationship_count_high]

                    aResults + [
                        :table = aTable[:name],
                        :relationship_count = aTable[:relationship_count],
                        :complexity = "high"
                    ]

                ok

            next

        ok

        return aResults
    
    def CheckTimeSeriesData(aModelData)
        aResults = []

        # Look for tables with timestamp fields and high complexity

        if HasKey(aModelData, :tables) > 0

            aTables = aModelData[:tables]
            nLen = len(aTables)

            for i = 1 to nLen

                aTable = aTables[i]
                bHasTimestamp = false
                
                if HasKey(aTable, :fields) > 0

                    aFields = aTable[:fields]
                    nFieldLen = len(aFields)

                    for j = 1 to nFieldLen

                        aField = aFields[j]

                        if HasKey(aField, :type) > 0 and (aField[:type] = "timestamp" or aField[:type] = "datetime")
                            bHasTimestamp = true
                            exit
                        ok
                    next

                ok
                
                if bHasTimestamp and HasKey(aTable, :field_count) > 0 and aTable[:field_count] > @aThresholds[:table_field_count_moderate]

                    aResults + [
                        :table = aTable[:name],
                        :field_count = aTable[:field_count],
                        :has_timestamp = bHasTimestamp
                    ]

                ok
            next

        ok

        return aResults
    
    def GenerateActionFromTemplate(cTemplate, aData)
        cAction = cTemplate
        
        # Replace template variables
        if HasKey(aData, :table) > 0
            cAction = substr(cAction, "{table}", aData[:table])
        ok

        if HasKey(aData, :field) > 0
            cAction = substr(cAction, "{field}", aData[:field])
        ok

        if HasKey(aData, :from_table) > 0
            cAction = substr(cAction, "{from_table}", aData[:from_table])
        ok

        if HasKey(aData, :to_table) > 0
            cAction = substr(cAction, "{to_table}", aData[:to_table])
        ok
        
        return cAction
    
    def SetThreshold(cThresholdName, nValue)
        @aThresholds[cThresholdName] = nValue
        return This
    
    def Threshold(cThresholdName)
        if HasKey(@aThresholds, cThresholdName) > 0
            return @aThresholds[cThresholdName]
        ok
        return 0
