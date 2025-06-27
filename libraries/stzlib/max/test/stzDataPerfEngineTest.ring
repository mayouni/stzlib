load "../stzmax.ring"


#=====================#
#  Perf OPTIMIZATION  #
#=====================#

/*--- Basic Data Model with Default Perf Plan

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
    # Set the default Perf plan (already set by init)
    SetPerfPlan("default")
    
    # Analyze Perf
    Perf_hints = AnalyzePerf()
    ? BoxRound("Perf Hints - Default Plan")
    ? @@NL( Perf_hints ) + NL
}
#-->
'
╭───────────────────────────╮
│ Perf Hints - Default Plan │
╰───────────────────────────╯
[
	[
		[ "rule_id", "basic_fk_index" ],
		[ "type", "index_optimization" ],
		[ "priority", "medium" ],
		[ "Perf_plan", "default" ],
		[
			"message",
			"Consider adding index on foreign key field"
		],
		[ "action", "" ],
		[ "Perf_impact", "medium" ],
		[ "applies_to", "all_foreign_keys" ],
		[
			"Description_data",
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
		[ "Perf_plan", "default" ],
		[
			"message",
			"Be aware of potential N+1 query issues"
		],
		[ "action", "" ],
		[ "Perf_impact", "medium" ],
		[ "applies_to", "has_many_relationships" ],
		[
			"Description_data",
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

/*--- Web Application Perf Plan

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
    
    # Set web Perf plan for critical FK indexing and N+1 prevention
    SetPerfPlan("web")
    
    ? BoxRound("Perf Hints - Web Plan")
    ? @@NL( PerfHints() ) + NL

	 ? BoxRound("Perf Hints - Web Plan - Extended")
	? @@NL( PerfHintsXT() )
}
#--> #TODO See why it returns no optimisations! fix the engine or change the example
'
╭───────────────────────╮
│ Perf Hints - Web Plan │
╰───────────────────────╯
[
	"Foreign key fields must have indexes for web performance",
	"N+1 queries will severely impact web response times"
]

╭──────────────────────────────────╮
│ Perf Hints - Web Plan - Extended │
╰──────────────────────────────────╯
[
	[
		[ "rule_id", "fk_index_mandatory" ],
		[ "type", "index_optimization" ],
		[ "priority", "high" ],
		[ "performance_plan", "web" ],
		[
			"message",
			"Foreign key fields must have indexes for web performance"
		],
		[ "action", "" ],
		[ "performance_impact", "high" ],
		[ "applies_to", "all_foreign_keys" ],
		[
			"description_data",
			[
				[ "table", "orders" ],
				[ "field", "customer_id" ],
				[ "related_table", "customers" ],
				[ "relationship_type", "belongs_to" ]
			]
		]
	],
	[
		[ "rule_id", "fk_index_mandatory" ],
		[ "type", "index_optimization" ],
		[ "priority", "high" ],
		[ "performance_plan", "web" ],
		[
			"message",
			"Foreign key fields must have indexes for web performance"
		],
		[ "action", "" ],
		[ "performance_impact", "high" ],
		[ "applies_to", "all_foreign_keys" ],
		[
			"description_data",
			[
				[ "table", "order_items" ],
				[ "field", "order_id" ],
				[ "related_table", "orders" ],
				[ "relationship_type", "belongs_to" ]
			]
		]
	],
	[
		[ "rule_id", "fk_index_mandatory" ],
		[ "type", "index_optimization" ],
		[ "priority", "high" ],
		[ "performance_plan", "web" ],
		[
			"message",
			"Foreign key fields must have indexes for web performance"
		],
		[ "action", "" ],
		[ "performance_impact", "high" ],
		[ "applies_to", "all_foreign_keys" ],
		[
			"description_data",
			[
				[ "table", "order_items" ],
				[ "field", "product_id" ],
				[ "related_table", "products" ],
				[ "relationship_type", "belongs_to" ]
			]
		]
	],
	[
		[ "rule_id", "n_plus_one_prevention" ],
		[ "type", "query_optimization" ],
		[ "priority", "critical" ],
		[ "performance_plan", "web" ],
		[
			"message",
			"N+1 queries will severely impact web response times"
		],
		[ "action", "" ],
		[ "performance_impact", "critical" ],
		[ "applies_to", "has_many_relationships" ],
		[
			"description_data",
			[
				[ "from_table", "customers" ],
				[ "to_table", "orders" ],
				[ "relationship_type", "has_many" ]
			]
		]
	],
	[
		[ "rule_id", "n_plus_one_prevention" ],
		[ "type", "query_optimization" ],
		[ "priority", "critical" ],
		[ "performance_plan", "web" ],
		[
			"message",
			"N+1 queries will severely impact web response times"
		],
		[ "action", "" ],
		[ "performance_impact", "critical" ],
		[ "applies_to", "has_many_relationships" ],
		[
			"description_data",
			[
				[ "from_table", "orders" ],
				[ "to_table", "order_items" ],
				[ "relationship_type", "has_many" ]
			]
		]
	],
	[
		[ "rule_id", "n_plus_one_prevention" ],
		[ "type", "query_optimization" ],
		[ "priority", "critical" ],
		[ "performance_plan", "web" ],
		[
			"message",
			"N+1 queries will severely impact web response times"
		],
		[ "action", "" ],
		[ "performance_impact", "critical" ],
		[ "applies_to", "has_many_relationships" ],
		[
			"description_data",
			[
				[ "from_table", "products" ],
				[ "to_table", "order_items" ],
				[ "relationship_type", "has_many" ]
			]
		]
	]
]
'

pf()
# Executed in 1.01 second(s) in Ring 1.22

/*--- Analytics/Reporting Perf Plan

pr()

o1 = new stzDataModel("sales_analytics")
o1 {
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
    SetPerfPlan("analytics")
    
    ? BoxRound("Perf Hints - Analytics Plan")
    ? @@NL( PerfHints() ) + NL

	? BoxRound("Perf Hints - Analytics Plan - Extended")
    ? @@NL( PerfHintsXT() )

}
#-->
'
╭─────────────────────────────╮
│ Perf Hints - Analytics Plan │
╰─────────────────────────────╯
[
	"Consider denormalization for frequently joined data"
]

╭────────────────────────────────────────╮
│ Perf Hints - Analytics Plan - Extended │
╰────────────────────────────────────────╯
[
	[
		[ "rule_id", "denormalization_consideration" ],
		[ "type", "schema_optimization" ],
		[ "priority", "medium" ],
		[ "performance_plan", "analytics" ],
		[
			"message",
			"Consider denormalization for frequently joined data"
		],
		[ "action", "" ],
		[ "performance_impact", "medium" ],
		[ "applies_to", "complex_relationship_chains" ],
		[
			"description_data",
			[
				[ "table", "sales_data" ],
				[ "relationship_count", 6 ],
				[ "complexity", "high" ]
			]
		]
	]
]
'

pf()
# Executed in 1.06 second(s) in Ring 1.22

/*---
*/
pr()

oPerfEngine = new stzDataPerfEngine()
oPerfEngine.SetActivePlan("mobile")

# Simulate the model data that would be generated
aTestModelData = [
    :tables = [
        [
            :name = "users",
            :fields = [
                [:name = "id", :type = "primary_key"],
                [:name = "username", :type = "string"], 
                [:name = "email", :type = "email"],
                [:name = "profile_image", :type = "text"],  # Large field
                [:name = "bio", :type = "text"],           # Large field  
                [:name = "last_sync", :type = "timestamp"]
            ],
            :field_count = 6,
            :relationship_count = 0
        ],
        [
            :name = "messages", 
            :fields = [
                [:name = "id", :type = "primary_key"],
                [:name = "sender_id", :type = "foreign_key"],
                [:name = "recipient_id", :type = "foreign_key"],
                [:name = "content", :type = "text"],        # Large field
                [:name = "attachments", :type = "longtext"], # Large field
                [:name = "sent_at", :type = "timestamp"]
            ],
            :field_count = 6,
            :relationship_count = 2
        ],
        [
            :name = "notifications",
            :fields = [
                [:name = "id", :type = "primary_key"],
                [:name = "user_id", :type = "foreign_key"], 
                [:name = "type", :type = "string"],
                [:name = "message", :type = "text"],        # Large field
                [:name = "read", :type = "boolean"],
                [:name = "created_at", :type = "timestamp"]
            ],
            :field_count = 6,
            :relationship_count = 1
        ]
    ],
    :relationships = [
        [:type = "belongs_to", :from = "messages", :to = "users", :field = "sender_id"],
        [:type = "belongs_to", :from = "messages", :to = "users", :field = "recipient_id"],
        [:type = "belongs_to", :from = "notifications", :to = "users", :field = "user_id"],
        [:type = "has_many", :from = "users", :to = "messages"],
        [:type = "has_many", :from = "users", :to = "notifications"]
    ]
]

# Test the performance evaluation
? "=== Testing Mobile Plan Performance Hints ==="
? "Active Plan: " + oPerfEngine.ActivePlan()
? "Plan Description: " + oPerfEngine.PlanDescription("mobile")
? ""

aActiveRules = oPerfEngine.ActiveRules()
? "Number of active rules: " + len(aActiveRules)

for i = 1 to len(aActiveRules)
    aRule = aActiveRules[i]
    ? "Rule " + i + ": " + aRule[:id] + " - " + aRule[:condition]
    
    aResults = oPerfEngine.EvalRule(aRule, aTestModelData)
    ? "  Results found: " + len(aResults)
    
    for j = 1 to len(aResults)
        ? "    " + @@(aResults[j])
    next
    ? ""
next

pf()

/*--- Mobile Application Perf Plan
*/
pr()

o1 = new stzDataModel("mobile_app")
o1 {
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
    SetPerfPlan("mobile")
    
    Perf_hints = PerfHints()
    ? BoxRound("Perf Hints - Mobile Plan")
    ? @@NL( Perf_hints )
}

# Idem

pf()

/*--- Custom Perf Plan

pr()


o1 = new stzDataModel("custom_optimized")
o1 {

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
			:Perf_impact = "critical",
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
			:Perf_impact = "high",
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
    
    SetPerfPlan("gaming")
    
    Perf_hints = AnalyzePerf()
    ? BoxRound("Perf Hints - Custom Gaming Plan")
    ? @@NL( Perf_hints ) + NL
}
#-->
'
[
	[
		[ "rule_id", "realtime_index" ],
		[ "type", "index_optimization" ],
		[ "priority", "critical" ],
		[ "Perf_plan", "gaming" ],
		[
			"message",
			"Gaming requires immediate index creation on all foreign keys"
		],
		[ "action", "" ],
		[ "Perf_impact", "critical" ],
		[ "applies_to", "all_foreign_keys" ],
		[
			"description_data",
			[
				[ "table", "game_sessions" ],
				[ "field", "player_id" ],
				[ "related_table", "players" ],
				[ "relationship_type", "belongs_to" ]
			]
		]
	],
	[
		[ "rule_id", "cache_strategy" ],
		[ "type", "caching" ],
		[ "priority", "high" ],
		[ "Perf_plan", "gaming" ],
		[
			"message",
			"Implement aggressive caching for gaming relationships"
		],
		[ "action", "" ],
		[ "Perf_impact", "high" ],
		[ "applies_to", "has_many_relationships" ],
		[
			"description_data",
			[
				[ "from_table", "players" ],
				[ "to_table", "game_sessions" ],
				[ "relationship_type", "has_many" ]
			]
		]
	]
]
'

pf()
# Executed in 0.34 second(s) in Ring 1.22

/*--- Explicit Many-to-Many with Perf Analysis

pr()

o1 = new stzDataModel("social_platform")
o1 {
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
    
    SetPerfPlan("web")
    
    Perf_hints = AnalyzePerf()
    ? BoxRound("Perf Hints - Many-to-Many Relationships")
    ? @@NL( Perf_hints ) + NL
    
    # Show inferred relationships
    ? BoxRound("Inferred Relationships")
    ? @@NL( Relationships() )
}

#--> #TODO see why no optimisations are returned
'
╭────────────────────────────────────────────────╮
│ Perf Hints - Many-to-Many Relationships │
╰────────────────────────────────────────────────╯
[ ]

╭────────────────────────╮
│ Inferred Relationships │
╰────────────────────────╯
[
	[
		[ "from", "posts" ],
		[ "to", "users" ],
		[ "type", "belongs_to" ],
		[ "inferred", 1 ],
		[ "field", "user_id" ],
		[
			"semantic_meaning",
			"Each post belongs to one user"
		]
	],
	[
		[ "from", "users" ],
		[ "to", "posts" ],
		[ "type", "has_many" ],
		[ "inferred", 1 ],
		[ "field", "user_id" ],
		[
			"semantic_meaning",
			"Each user can have many posts"
		]
	],
	[
		[ "from", "posts" ],
		[ "to", "tags" ],
		[ "type", "many_to_many" ],
		[ "inferred", 0 ],
		[
			"options",
			[
				[ "via", "post_tags" ]
			]
		]
	]
]
'

pf()
# Executed in 0.36 second(s) in Ring 1.22

/*--- Hierarchical Data with Perf Considerations

pr()

o1 = new stzDataModel("content_hierarchy")
o1 {
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
    
    SetPerfPlan("analytics")
    
    Perf_hints = AnalyzePerf()
    ? BoxRound("Perf Hints - Hierarchical Data")
    ? @@NL( Perf_hints ) + NL
}
#--> TODO see why no perf optimisations are returned

pf()
# Executed in 0.64 second(s) in Ring 1.22

/*--- Perf Threshold Customization

pr()

o1 = new stzDataModel("threshold_testing")
o1 {
    # Customize Perf thresholds
    SetPerfThreshold("table_field_count_high", 15)
    SetPerfThreshold("table_relationship_count_high", 8)
    
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
    
    SetPerfPlan("analytics")
    
    Perf_hints = AnalyzePerf()
    ? BoxRound("Perf Hints - Custom Thresholds")
    ? @@NL( Perf_hints ) + NL
    
    # Show current thresholds
    ? "Perf Thresholds:"
    ? "  Field Count High: " + PerfThreshold("table_field_count_high")
    ? "  Relationship Count High: " + PerfThreshold("table_relationship_count_high")
}
#--> TODO see why no perf optimisations are returned
'
╭────────────────────────────────╮
│ Perf Hints - Custom Thresholds │
╰────────────────────────────────╯
[ ]

Perf Thresholds:
  Field Count High: 15
  Relationship Count High: 8
'

pf()
# Executed in 0.31 second(s) in Ring 1.22

/*--- Perf Plan Comparison

pr()

o1 = new stzDataModel("plan_comparison")
o1 {
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
        SetPerfPlan(plan)
        hints = AnalyzePerf()
        ? BoxRound("Plan: " + plan + " (" + len(hints) + " recommendations)")
        ? "Description: " + PerfPlanDescription(plan)
        ? ""
    next
}
#--> TODO: chech why 3 last plans return no optimisation recommendations
'
╭───────────────────────────────────╮
│ Plan: default (2 recommendations) │
╰───────────────────────────────────╯
Description: General purpose application

╭───────────────────────────────╮
│ Plan: web (0 recommendations) │
╰───────────────────────────────╯
Description: Unknown Description

╭─────────────────────────────────────╮
│ Plan: analytics (0 recommendations) │
╰─────────────────────────────────────╯
Description: Unknown Description

╭──────────────────────────────────╮
│ Plan: mobile (0 recommendations) │
╰──────────────────────────────────╯
Description: Unknown Description
'

pf()
# Executed in 0.37 second(s) in Ring 1.22

/*--- Generated Actions and SQL

pr()

o1 = new stzDataModel("action_generation")
o1 {
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
    
    SetPerfPlan("web")

    Perf_hints = PerfHints()
    ? BoxRound("Generated Actions")
   	? @@NL(perf_hints)

}
#--> Idem (nothing returned)
'
╭───────────────────╮
│ Generated Actions │
╰───────────────────╯
[
	[
		[ "rule_id", "fk_index_mandatory" ],
		[ "type", "index_optimization" ],
		[ "priority", "high" ],
		[ "performance_plan", "web" ],
		[
			"message",
			"Foreign key fields must have indexes for web performance"
		],
		[ "action", "" ],
		[ "performance_impact", "high" ],
		[ "applies_to", "all_foreign_keys" ],
		[
			"description_data",
			[
				[ "table", "inventory" ],
				[ "field", "product_id" ],
				[ "related_table", "products" ],
				[ "relationship_type", "belongs_to" ]
			]
		]
	],
	[
		[ "rule_id", "fk_index_mandatory" ],
		[ "type", "index_optimization" ],
		[ "priority", "high" ],
		[ "performance_plan", "web" ],
		[
			"message",
			"Foreign key fields must have indexes for web performance"
		],
		[ "action", "" ],
		[ "performance_impact", "high" ],
		[ "applies_to", "all_foreign_keys" ],
		[
			"description_data",
			[
				[ "table", "inventory" ],
				[ "field", "warehouse_id" ],
				[ "related_table", "warehouses" ],
				[ "relationship_type", "belongs_to" ]
			]
		]
	],
	[
		[ "rule_id", "n_plus_one_prevention" ],
		[ "type", "query_optimization" ],
		[ "priority", "critical" ],
		[ "performance_plan", "web" ],
		[
			"message",
			"N+1 queries will severely impact web response times"
		],
		[ "action", "" ],
		[ "performance_impact", "critical" ],
		[ "applies_to", "has_many_relationships" ],
		[
			"description_data",
			[
				[ "from_table", "products" ],
				[ "to_table", "inventory" ],
				[ "relationship_type", "has_many" ]
			]
		]
	],
	[
		[ "rule_id", "n_plus_one_prevention" ],
		[ "type", "query_optimization" ],
		[ "priority", "critical" ],
		[ "performance_plan", "web" ],
		[
			"message",
			"N+1 queries will severely impact web response times"
		],
		[ "action", "" ],
		[ "performance_impact", "critical" ],
		[ "applies_to", "has_many_relationships" ],
		[
			"description_data",
			[
				[ "from_table", "warehouses" ],
				[ "to_table", "inventory" ],
				[ "relationship_type", "has_many" ]
			]
		]
	]
]
'

pf()
# Executed in 0.57 second(s) in Ring 1.22

/*--- Perf Engine Direct Usage

pr()

# Test Perf engine directly
oEngine = new stzDataPerfEngine()

# Load preAddd plans
oEngine.AddPlan("web", $aPerfs[:web])
oEngine.AddPlan("analytics", $aPerfs[:analytics])
oEngine.AddPlan("mobile", $aPerfs[:mobile])

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
    ? "Description: " + oEngine.PlanDescription(plan)
    
    aRules = oEngine.ActiveRules()
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
#-->
"
╭─────────────────────╮
│ Direct Engine Usage │
╰─────────────────────╯
Plan: default
Description: General purpose application
Rules: 2
Rule 'basic_fk_index' triggered
Rule 'query_awareness' triggered
---
Plan: web
Description: Web application with OLTP workload
Rules: 3
Rule 'fk_index_mandatory' triggered
Rule 'n_plus_one_prevention' triggered
---
Plan: mobile
Description: Mobile application with limited bandwidth/resources
Rules: 2
Rule 'minimal_payload' triggered
---
"

pf()
# Executed in 0.02 second(s) in Ring 1.22
