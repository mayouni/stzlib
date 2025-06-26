load "../stzmax.ring"

#============================#
#  PERFORMANCE OPTIMIZATION  #
#============================#

/*--- Basic Data Model with Default Performance Plan

pr()

o1 = new stzDataModel("blog_platform")
o1 {
    AddTable("authors", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "email", :email ],
        [ "bio", :text ]
    ])
    
    AddTable("articles", [
        [ "id", :primary_key ],
        [ "author_id", :foreign_key ],
        [ "title", :required ],
        [ "content", :text ],
        [ "published_at", :timestamp ],
        [ "view_count", "integer" ]
    ])
    
    # Relationships are auto-inferred from foreign keys
    # Set the default performance plan (already set by init)
    SetPerformancePlan("default")
    
    # Analyze performance
    performance_hints = AnalyzePerformance()
    ? BoxRound("Performance Hints - Default Plan")
    ? @@NL( performance_hints ) + NL
}
#-->
'
╭──────────────────────────────────╮
│ Performance Hints - Default Plan │
╰──────────────────────────────────╯
[
	[
		[ "rule_id", "basic_fk_index" ],
		[ "type", "index_optimization" ],
		[ "priority", "medium" ],
		[ "performance_plan", "default" ],
		[
			"message",
			"Consider adding index on foreign key field"
		],
		[ "action", "" ],
		[ "performance_impact", "medium" ],
		[ "applies_to", "all_foreign_keys" ],
		[
			"context_data",
			[
				[ "table", "articles" ],
				[ "field", "author_id" ],
				[ "related_table", "authors" ],
				[ "relationship_type", "belongs_to" ]
			]
		]
	],
	[
		[ "rule_id", "query_awareness" ],
		[ "type", "query_optimization" ],
		[ "priority", "low" ],
		[ "performance_plan", "default" ],
		[
			"message",
			"Be aware of potential N+1 query issues"
		],
		[ "action", "" ],
		[ "performance_impact", "medium" ],
		[ "applies_to", "has_many_relationships" ],
		[
			"context_data",
			[
				[ "from_table", "authors" ],
				[ "to_table", "articles" ],
				[ "relationship_type", "has_many" ]
			]
		]
	]
]
'

pf()
# Executed in 0.34 second(s) in Ring 1.22

/*--- Web Application Performance Plan

pr()

o1 = new stzDataModel("ecommerce_web")
o1 {
    AddTable("customers", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "email", :email ],
        [ "phone", :string ],
        [ "address", :text ]
    ])
    
    AddTable("orders", [
        [ "id", :primary_key ],
        [ "customer_id", :foreign_key ],
        [ "total_amount", "decimal" ],
        [ "status", :string ],
        [ "created_at", :timestamp ]
    ])
    
    AddTable("order_items", [
        [ "id", :primary_key ],
        [ "order_id", :foreign_key ],
        [ "product_id", :foreign_key ],
        [ "quantity", "integer" ],
        [ "price", "decimal" ]
    ])
    
    AddTable("products", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "description", :text ],
        [ "price", "decimal" ],
        [ "stock_quantity", "integer" ]
    ])
    
    # Set web performance plan for critical FK indexing and N+1 prevention
    SetPerformancePlan("web")
    
    performance_hints = AnalyzePerformance()
    ? BoxRound("Performance Hints - Web Plan")
    ? @@NL( performance_hints ) + NL
}
#--> #TODO See why it returns no optimisations! fix the engine or change the example
'
╭──────────────────────────────╮
│ Performance Hints - Web Plan │
╰──────────────────────────────╯
[ ]
'

pf()
# Executed in 0.89 second(s) in Ring 1.22

/*--- Analytics/Reporting Performance Plan

pr()

o3 = new stzDataModel("sales_analytics")
o3 {
    AddTable("sales_data", [
        [ "id", :primary_key ],
        [ "transaction_date", :timestamp ],
        [ "customer_id", :foreign_key ],
        [ "product_id", :foreign_key ],
        [ "sales_amount", "decimal" ],
        [ "quantity", "integer" ],
        [ "region", :string ],
        [ "category", :string ],
        [ "salesperson_id", :foreign_key ]
    ])
    
    AddTable("customers", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "segment", :string ],
        [ "registration_date", :timestamp ]
    ])
    
    AddTable("products", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "category", :string ],
        [ "cost", "decimal" ],
        [ "launch_date", :timestamp ]
    ])
    
    AddTable("sales_team", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "region", :string ],
        [ "hire_date", :timestamp ]
    ])
    
    # Set analytics plan for covering indexes and partitioning
    SetPerformancePlan("analytics")
    
    performance_hints = AnalyzePerformance()
    ? BoxRound("Performance Hints - Analytics Plan")
    ? @@NL( performance_hints ) + NL
}

# Idem

pf()

/*--- Mobile Application Performance Plan

pr()

o4 = new stzDataModel("mobile_app")
o4 {
    AddTable("users", [
        [ "id", :primary_key ],
        [ "username", :required ],
        [ "email", :email ],
        [ "profile_image", :text ],  # Large field - triggers mobile optimization
        [ "bio", :text ],            # Another large field
        [ "last_sync", :timestamp ]
    ])
    
    AddTable("messages", [
        [ "id", :primary_key ],
        [ "sender_id", :foreign_key ],
        [ "recipient_id", :foreign_key ],
        [ "content", :text ],
        [ "attachments", :longtext ], # Large field
        [ "sent_at", :timestamp ]
    ])
    
    AddTable("notifications", [
        [ "id", :primary_key ],
        [ "user_id", :foreign_key ],
        [ "type", :string ],
        [ "message", :text ],
        [ "read", :boolean ],
        [ "created_at", :timestamp ]
    ])
    
    # Set mobile plan for data transfer optimization
    SetPerformancePlan("mobile")
    
    performance_hints = AnalyzePerformance()
    ? BoxRound("Performance Hints - Mobile Plan")
    ? @@NL( performance_hints ) + NL
}

# Idem

pf()

/*--- Custom Performance Plan
*/
pr()


o5 = new stzDataModel("custom_optimized")
o5 {

	AddPerfPlan("gaming", "Real-time gaming application", [

		# Rule 1
		[
			:id = "realtime_index",
			:type = "index_optimization",
			:priority = "critical",
			:condition = "foreign_key_without_index",
			:message = "Gaming requires immediate index creation on all foreign keys",
			:action = [
				:SQL = "CREATE INDEX CONCURRENTLY idx_{table}_{field} ON {table}({field})",
				:Ring = 'This.AddRealtimeIndex("{table}", "{field}")'
			],
			:performance_impact = "critical",
			:applies_to = "all_foreign_keys"
		],

		# Rule 2
		[
			:id = "cache_strategy",
			:type = "caching",
			:priority = "high",
			:condition = "has_many_relationship",
			:message = "Implement aggressive caching for gaming relationships",
			:action = [
				:SQL = "SET UP REDIS CACHE FOR {from_table} -> {to_table}",
				:Ring = 'This.SetupRedisCache("{from_table}", "{to_table}")'
			],
			:performance_impact = "high",
			:applies_to = "has_many_relationships"
		]

	])

    AddTable("players", [
        [ "id", :primary_key ],
        [ "username", :required ],
        [ "level", "integer" ],
        [ "experience", "integer" ]
    ])
    
    AddTable("game_sessions", [
        [ "id", :primary_key ],
        [ "player_id", :foreign_key ],
        [ "start_time", :timestamp ],
        [ "end_time", :timestamp ],
        [ "score", "integer" ]
    ])
    
    SetPerformancePlan("gaming")
    
    performance_hints = AnalyzePerformance()
    ? BoxRound("Performance Hints - Custom Gaming Plan")
    ? @@NL( performance_hints ) + NL
}

pf()

/*--- Explicit Many-to-Many with Performance Analysis
pr()

o6 = new stzDataModel("social_platform")
o6 {
    AddTable("users", [
        [ "id", :primary_key ],
        [ "username", :unique ],
        [ "email", :email ],
        [ "profile_data", :longtext ]
    ])
    
    AddTable("posts", [
        [ "id", :primary_key ],
        [ "user_id", :foreign_key ],
        [ "content", :text ],
        [ "created_at", :timestamp ]
    ])
    
    AddTable("tags", [
        [ "id", :primary_key ],
        [ "name", :unique ]
    ])
    
    # Explicit many-to-many relationship
    Link("posts", "tags", "many_to_many", [ :via = "post_tags" ])
    
    SetPerformancePlan("web")
    
    performance_hints = AnalyzePerformance()
    ? BoxRound("Performance Hints - Many-to-Many Relationships")
    ? @@NL( performance_hints ) + NL
    
    # Show inferred relationships
    ? "Inferred Relationships:"
    ? @@NL( Relationships() )
}

pf()

/*--- Hierarchical Data with Performance Considerations
pr()

o7 = new stzDataModel("content_hierarchy")
o7 {
    AddTable("categories", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "parent_id", :foreign_key ], # Self-referencing
        [ "description", :text ],
        [ "created_at", :timestamp ]
    ])
    
    AddTable("articles", [
        [ "id", :primary_key ],
        [ "category_id", :foreign_key ],
        [ "title", :required ],
        [ "content", :longtext ],
        [ "author_id", :foreign_key ],
        [ "published_at", :timestamp ]
    ])
    
    AddTable("authors", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "bio", :text ]
    ])
    
    # Add hierarchy explicitly
    Hierarchy("categories", [ :parent_field = "parent_id" ])
    
    SetPerformancePlan("analytics")
    
    performance_hints = AnalyzePerformance()
    ? BoxRound("Performance Hints - Hierarchical Data")
    ? @@NL( performance_hints ) + NL
}

pf()

/*--- Performance Threshold Customization
pr()

o8 = new stzDataModel("threshold_testing")
o8 {
    # Customize performance thresholds
    SetPerformanceThreshold("table_field_count_high", 15)
    SetPerformanceThreshold("table_relationship_count_high", 8)
    
    AddTable("complex_entity", [
        [ "id", :primary_key ],
        [ "field1", :string ], [ "field2", :string ], [ "field3", :string ],
        [ "field4", :string ], [ "field5", :string ], [ "field6", :string ],
        [ "field7", :string ], [ "field8", :string ], [ "field9", :string ],
        [ "field10", :string ], [ "field11", :string ], [ "field12", :string ],
        [ "field13", :string ], [ "field14", :string ], [ "field15", :string ],
        [ "field16", :string ], # Triggers high field count threshold
        [ "created_at", :timestamp ],
        [ "updated_at", :timestamp ]
    ])
    
    AddTable("related_entity", [
        [ "id", :primary_key ],
        [ "complex_entity_id", :foreign_key ],
        [ "data", :text ]
    ])
    
    SetPerformancePlan("analytics")
    
    performance_hints = AnalyzePerformance()
    ? BoxRound("Performance Hints - Custom Thresholds")
    ? @@NL( performance_hints ) + NL
    
    # Show current thresholds
    ? "Performance Thresholds:"
    ? "  Field Count High: " + GetPerformanceThreshold("table_field_count_high")
    ? "  Relationship Count High: " + GetPerformanceThreshold("table_relationship_count_high")
}

pf()

/*--- Performance Plan Comparison
pr()

o9 = new stzDataModel("plan_comparison")
o9 {
    AddTable("users", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "email", :email ],
        [ "bio", :text ]
    ])
    
    AddTable("posts", [
        [ "id", :primary_key ],
        [ "user_id", :foreign_key ],
        [ "title", :required ],
        [ "content", :longtext ],
        [ "created_at", :timestamp ]
    ])
    
    # Test different plans
    plans = ["default", "web", "analytics", "mobile"]
    
    for plan in plans
        SetPerformancePlan(plan)
        hints = AnalyzePerformance()
        ? BoxRound("Plan: " + plan + " (" + len(hints) + " recommendations)")
        ? "Context: " + GetPerformancePlanContext(plan)
        ? ""
    next
}

pf()

/*--- Generated Actions and SQL
pr()

o10 = new stzDataModel("action_generation")
o10 {
    AddTable("inventory", [
        [ "id", :primary_key ],
        [ "product_id", :foreign_key ],
        [ "warehouse_id", :foreign_key ],
        [ "quantity", "integer" ],
        [ "last_updated", :timestamp ]
    ])
    
    AddTable("products", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "category", :string ]
    ])
    
    AddTable("warehouses", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "location", :string ]
    ])
    
    SetPerformancePlan("web")
    
    performance_hints = AnalyzePerformance()
    ? BoxRound("Generated Actions")
    
    for hint in performance_hints
        ? "Rule: " + hint[:rule_id]
        ? "Priority: " + hint[:priority] 
        ? "Message: " + hint[:message]
        if HasKey(hint, :sql_action)
            ? "SQL: " + hint[:sql_action]
        ok
        ? "---"
    next
}

pf()

/*--- Performance Engine Direct Usage
pr()

# Test performance engine directly
oEngine = new stzDataPerfEngine()

# Load preAddd plans
oEngine.AddRulePlan("web", $aPerfs[:web])
oEngine.AddRulePlan("analytics", $aPerfs[:analytics])
oEngine.AddRulePlan("mobile", $aPerfs[:mobile])

# Sample model data
aModelData = [
    :tables = [
        [
            :name = "orders",
            :field_count = 8,
            :relationship_count = 3,
            :fields = [
                [ :name = "id", :type = "integer" ],
                [ :name = "customer_id", :type = "integer" ],
                [ :name = "description", :type = "text" ],
                [ :name = "notes", :type = "longtext" ],
                [ :name = "created_at", :type = "timestamp" ]
            ]
        ]
    ],
    :relationships = [
        [ :type = "belongs_to", :from = "orders", :to = "customers", :field = "customer_id" ],
        [ :type = "has_many", :from = "customers", :to = "orders", :field = "customer_id" ]
    ]
]

? BoxRound("Direct Engine Usage")

# Test plans
for plan in ["default", "web", "mobile"]
    oEngine.SetActivePlan(plan)
    ? "Plan: " + plan
    ? "Context: " + oEngine.GetPlanContext(plan)
    
    aRules = oEngine.GetActiveRules()
    ? "Rules: " + len(aRules)
    
    # Evaluate rules
    for rule in aRules
        aMatches = oEngine.EvaluateRule(rule, aModelData)
        if len(aMatches) > 0
            ? "Rule '" + rule[:id] + "' triggered"
        ok
    next
    ? "---"
next

pf()
