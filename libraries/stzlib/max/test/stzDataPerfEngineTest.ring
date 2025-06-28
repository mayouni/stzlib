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
    UsePerfPlan("default")
    
    # Analyze Perf

    ? BoxRound("Perf Hints - Default Plan")
    ? @@NL( PerfHints() )
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
		[
			"message",
			"Consider adding index on articles.author_id"
		],
		[
			"action",
			"CREATE INDEX idx_articles_author_id ON articles(author_id)"
		],
		[ "impact", "medium" ],
		[
			"data",
			[
				[ "table", "articles" ],
				[ "field", "author_id" ],
				[ "related_table", "authors" ]
			]
		]
	],
	[
		[ "rule_id", "query_awareness" ],
		[ "type", "query_optimization" ],
		[ "priority", "low" ],
		[
			"message",
			"Monitor N+1 queries for authors -> articles"
		],
		[
			"action",
			"Use eager loading for authors -> articles"
		],
		[ "impact", "medium" ],
		[
			"data",
			[
				[ "from_table", "authors" ],
				[ "to_table", "articles" ]
			]
		]
	]
]
'

pf()
# Executed in 0.03 second(s) in Ring 1.22

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

	? BoxRound("Relationships (inferred automatically)")
	? @@NL(Relationships()) + NL

    # Set web Perf plan for critical FK indexing and N+1 prevention
    UsePerfPlan("web")
    
    ? BoxRound("Perf Hints - Web Plan")
    ? @@NL( PerfHints() ) + NL

    ? BoxRound("Perf Hints - Web Plan - Extended")
    ? @@NL( PerfHintsXT() ) + NL

}
#-->
'
╭────────────────────────────────────────╮
│ Relationships (inferred automatically) │
╰────────────────────────────────────────╯
[
	[
		[ "type", "belongs_to" ],
		[ "from", "orders" ],
		[ "to", "customers" ],
		[ "field", "customer_id" ]
	],
	[
		[ "type", "has_many" ],
		[ "from", "customers" ],
		[ "to", "orders" ]
	],
	[
		[ "type", "belongs_to" ],
		[ "from", "order_items" ],
		[ "to", "orders" ],
		[ "field", "order_id" ]
	],
	[
		[ "type", "has_many" ],
		[ "from", "orders" ],
		[ "to", "order_items" ]
	],
	[
		[ "type", "belongs_to" ],
		[ "from", "order_items" ],
		[ "to", "products" ],
		[ "field", "product_id" ]
	],
	[
		[ "type", "has_many" ],
		[ "from", "products" ],
		[ "to", "order_items" ]
	]
]

╭───────────────────────╮
│ Perf Hints - Web Plan │
╰───────────────────────╯
[
	"Foreign key orders.customer_id must have index for web performance",
	"Foreign key order_items.order_id must have index for web performance",
	"Foreign key order_items.product_id must have index for web performance",
	"N+1 queries will impact customers -> orders performance",
	"N+1 queries will impact orders -> order_items performance",
	"N+1 queries will impact products -> order_items performance",
	"Table orders needs pagination strategy",
	"Table order_items needs pagination strategy"
]

╭──────────────────────────────────╮
│ Perf Hints - Web Plan - Extended │
╰──────────────────────────────────╯
[
	[
		[ "rule_id", "fk_index_mandatory" ],
		[ "type", "index_optimization" ],
		[ "priority", "high" ],
		[
			"message",
			"Foreign key orders.customer_id must have index for web performance"
		],
		[
			"action",
			"CREATE INDEX idx_orders_customer_id ON orders(customer_id)"
		],
		[ "impact", "high" ],
		[
			"data",
			[
				[ "table", "orders" ],
				[ "field", "customer_id" ],
				[ "related_table", "customers" ]
			]
		]
	],
	[
		[ "rule_id", "fk_index_mandatory" ],
		[ "type", "index_optimization" ],
		[ "priority", "high" ],
		[
			"message",
			"Foreign key order_items.order_id must have index for web performance"
		],
		[
			"action",
			"CREATE INDEX idx_order_items_order_id ON order_items(order_id)"
		],
		[ "impact", "high" ],
		[
			"data",
			[
				[ "table", "order_items" ],
				[ "field", "order_id" ],
				[ "related_table", "orders" ]
			]
		]
	],
	[
		[ "rule_id", "fk_index_mandatory" ],
		[ "type", "index_optimization" ],
		[ "priority", "high" ],
		[
			"message",
			"Foreign key order_items.product_id must have index for web performance"
		],
		[
			"action",
			"CREATE INDEX idx_order_items_product_id ON order_items(product_id)"
		],
		[ "impact", "high" ],
		[
			"data",
			[
				[ "table", "order_items" ],
				[ "field", "product_id" ],
				[ "related_table", "products" ]
			]
		]
	],
	[
		[ "rule_id", "n_plus_one_prevention" ],
		[ "type", "query_optimization" ],
		[ "priority", "critical" ],
		[
			"message",
			"N+1 queries will impact customers -> orders performance"
		],
		[
			"action",
			"Implement eager loading for customers -> orders"
		],
		[ "impact", "critical" ],
		[
			"data",
			[
				[ "from_table", "customers" ],
				[ "to_table", "orders" ]
			]
		]
	],
	[
		[ "rule_id", "n_plus_one_prevention" ],
		[ "type", "query_optimization" ],
		[ "priority", "critical" ],
		[
			"message",
			"N+1 queries will impact orders -> order_items performance"
		],
		[
			"action",
			"Implement eager loading for orders -> order_items"
		],
		[ "impact", "critical" ],
		[
			"data",
			[
				[ "from_table", "orders" ],
				[ "to_table", "order_items" ]
			]
		]
	],
	[
		[ "rule_id", "n_plus_one_prevention" ],
		[ "type", "query_optimization" ],
		[ "priority", "critical" ],
		[
			"message",
			"N+1 queries will impact products -> order_items performance"
		],
		[
			"action",
			"Implement eager loading for products -> order_items"
		],
		[ "impact", "critical" ],
		[
			"data",
			[
				[ "from_table", "products" ],
				[ "to_table", "order_items" ]
			]
		]
	],
	[
		[ "rule_id", "pagination_requirement" ],
		[ "type", "data_access" ],
		[ "priority", "high" ],
		[
			"message",
			"Table orders needs pagination strategy"
		],
		[ "action", "Implement pagination for orders" ],
		[ "impact", "high" ],
		[
			"data",
			[
				[ "table", "orders" ],
				[ "relationship_count", 4 ]
			]
		]
	],
	[
		[ "rule_id", "pagination_requirement" ],
		[ "type", "data_access" ],
		[ "priority", "high" ],
		[
			"message",
			"Table order_items needs pagination strategy"
		],
		[
			"action",
			"Implement pagination for order_items"
		],
		[ "impact", "high" ],
		[
			"data",
			[
				[ "table", "order_items" ],
				[ "relationship_count", 4 ]
			]
		]
	]
]
'

pf()
# Executed in 0.10 second(s) in Ring 1.22

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
    UsePerfPlan("analytics")
    
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
	[
		[
			"message",
			"Table sales_data involved in complex joins"
		],
		[
			"action",
			"Consider denormalization for sales_data"
		]
	]
]

╭────────────────────────────────────────╮
│ Perf Hints - Analytics Plan - Extended │
╰────────────────────────────────────────╯
[
	[
		[ "rule_id", "complex_join_optimization" ],
		[ "type", "schema_optimization" ],
		[ "priority", "medium" ],
		[
			"message",
			"Table sales_data involved in complex joins"
		],
		[
			"action",
			"Consider denormalization for sales_data"
		],
		[ "impact", "medium" ],
		[
			"data",
			[
				[ "table", "sales_data" ],
				[ "relationship_count", 6 ]
			]
		]
	]
]
'

pf()
# Executed in 0.05 second(s) in Ring 1.22


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
    
    UsePerfPlan("web")
    
    ? BoxRound("Perf Hints - Many-to-Many Relationships")
    ? @@NL( PerfHints() ) + NL
    
    # Show inferred relationships
    ? BoxRound("Inferred Relationships")
    ? @@NL( Relationships() )
}

#-->
'
╭─────────────────────────────────────────╮
│ Perf Hints - Many-to-Many Relationships │
╰─────────────────────────────────────────╯
[
	[
		[
			"message",
			"Foreign key posts.user_id must have index for web performance"
		],
		[
			"action",
			"CREATE INDEX idx_posts_user_id ON posts(user_id)"
		]
	],
	[
		[
			"message",
			"N+1 queries will impact users -> posts performance"
		],
		[
			"action",
			"Implement eager loading for users -> posts"
		]
	],
	[
		[
			"message",
			"Table posts needs pagination strategy"
		],
		[ "action", "Implement pagination for posts" ]
	]
]

╭────────────────────────╮
│ Inferred Relationships │
╰────────────────────────╯
[
	[
		[ "type", "belongs_to" ],
		[ "from", "posts" ],
		[ "to", "users" ],
		[ "field", "user_id" ]
	],
	[
		[ "type", "has_many" ],
		[ "from", "users" ],
		[ "to", "posts" ]
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
# Executed in 0.04 second(s) in Ring 1.22

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
    
    UsePerfPlan("analytics")
    
    ? BoxRound("Perf Hints - Hierarchical Data")
    ? @@NL( PerfHints() )
}
#-->
'
╭────────────────────────────────╮
│ Perf Hints - Hierarchical Data │
╰────────────────────────────────╯
[
	[
		[
			"message",
			"Large text field categories.description impacts performance"
		],
		[
			"action",
			"Consider lazy loading for categories.description"
		]
	],
	[
		[
			"message",
			"Large text field articles.content impacts performance"
		],
		[
			"action",
			"Consider lazy loading for articles.content"
		]
	],
	[
		[
			"message",
			"Large text field authors.bio impacts performance"
		],
		[
			"action",
			"Consider lazy loading for authors.bio"
		]
	]
]
'

pf()
# Executed in 0.12 second(s) in Ring 1.22

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
    
    UsePerfPlan("analytics")
    
    ? BoxRound("Perf Hints - Custom Thresholds")
    ? @@NL( PerfHints() ) + NL
    
    # Show current thresholds
    ? "Perf Thresholds:"
    ? "~> Field Count High: " + PerfThreshold("table_field_count_high")
    ? "~> Relationship Count High: " + PerfThreshold("table_relationship_count_high")
}
#--> TODO see why no perf optimisations are returned
'
╭────────────────────────────────╮
│ Perf Hints - Custom Thresholds │
╰────────────────────────────────╯
[
	[
		[
			"message",
			"Large text field related_entity.data impacts performance"
		],
		[
			"action",
			"Consider lazy loading for related_entity.data"
		]
	]
]

Perf Thresholds:
~> Field Count High: 15
~> Relationship Count High: 8
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

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
        UsePerfPlan(plan)
        hints = PerfHints()
        ? ("- Plan " + plan + ": " + len(hints) + " recommendations")
    next
}
#-->
'
- Plan default: 2 recommendations
- Plan web: 2 recommendations
- Plan analytics: 2 recommendations
- Plan mobile: 0 recommendations
'

pf()
# Executed in 0.03 second(s) in Ring 1.22

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
    
    UsePerfPlan("web")

    ? BoxRound("Generated Actions")
   	? @@NL(PerfHints())

}
#-->
'
╭───────────────────╮
│ Generated Actions │
╰───────────────────╯
[
	[
		[
			"message",
			"Foreign key inventory.product_id must have index for web performance"
		],
		[
			"action",
			"CREATE INDEX idx_inventory_product_id ON inventory(product_id)"
		]
	],
	[
		[
			"message",
			"Foreign key inventory.warehouse_id must have index for web performance"
		],
		[
			"action",
			"CREATE INDEX idx_inventory_warehouse_id ON inventory(warehouse_id)"
		]
	],
	[
		[
			"message",
			"N+1 queries will impact products -> inventory performance"
		],
		[
			"action",
			"Implement eager loading for products -> inventory"
		]
	],
	[
		[
			"message",
			"N+1 queries will impact warehouses -> inventory performance"
		],
		[
			"action",
			"Implement eager loading for warehouses -> inventory"
		]
	],
	[
		[
			"message",
			"Table inventory needs pagination strategy"
		],
		[ "action", "Implement pagination for inventory" ]
	]
]
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

