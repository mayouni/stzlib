# stzDataModel Test Suite - Educational Samples
# Demonstrating practical usage patterns and design workflows

load "../stzmax.ring"


#=========================#
# BASIC SCHEMA DEFINITION #
#=========================#

/*---

# Problem: You need to quickly model a basic e-commerce system without boilerplate
# Solution: Use stzDataModel's convention-over-configuration approach

pr()

o1 = new stzDataModel("ecommerce_basic")
o1 {
    # Define customers table with smart field types
    DefineTable("customers", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "email", :email ],
        [ "created_at", :timestamp ]
    ])
    
    # Define orders table - foreign keys auto-inferred
    DefineTable("orders", [
        [ "id", :primary_key ],
        [ "customer_id", :foreign_key ],  # Automatically links to customers.id
        [ "total", :decimal ],
        [ "status", "varchar(50)" ],
        [ "created_at", :timestamp]
    ])
    
    # Schema created with automatic relationship inference
    ? @@NL( Relationships() )

}
#-->
'
[
	[
		[ "from", "orders" ],
		[ "to", "customers" ],
		[ "type", "belongs_to" ],
		[ "inferred", 1 ],
		[ "field", "customer_id" ],
		[
			"semantic_meaning",
			"Each order belongs to one customer"
		]
	],
	[
		[ "from", "customers" ],
		[ "to", "orders" ],
		[ "type", "has_many" ],
		[ "inferred", 1 ],
		[ "field", "customer_id" ],
		[
			"semantic_meaning",
			"Each customer can have many orders"
		]
	]
]

'

pf()
# Executed in 0.36 second(s) in Ring 1.22

#==================================#
#  EXPLICIT RELATIONSHIP MODELING  #
#==================================#

/*---

# Problem: Complex relationships that can't be inferred from naming
# Solution: Use explicit Link() method for precise control

pr()

o1 = new stzDataModel("inventory_system")
o1 {
    # Define product categories (self-referencing hierarchy)
    DefineTable("categories", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "parent_id", :foreign_key ], 	# Inferred a "parents" table that does not exist!
										# What's the impact on the model consistency:
										# should we go forward and define the table or
										# be conservative and generate a warning?
										# Or may be we can be flexible and allow both
										# options through a smart default and explicit config?

										#ANSWER
										# When category_id is found:
										# 1. Extract "category" from "category_id" 
										# 2. Pluralize to "categories"
										# 3. Create belongs_to: products → categories
										# 4. Create has_many: categories → products

# SetForeignKeyInferenceMode("strict") - Fail if target table doesn't exist
# SetForeignKeyInferenceMode("smart") - Warn but continue (default)
# SetForeignKeyInferenceMode("permissive") - Auto-create placeholder tables

        [ "slug", :unique ]
    ])
    
    # Define products
    DefineTable("products", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "category_id", :foreign_key ], # Inferred a link to "categories"
										 # I need to undersdans how the fellowing
										 # link has been inferred:
										 # :from products :to categories :belongs_to
										 # ~> I mean how this semantic relationship has
										 # been programmatically inferred?
        [ "price", :decimal ],
        [ "active", :boolean]
    ])
    
    # Define tags for flexible categorization
    DefineTable("tags", [
        [ "id", :primary_key ],
        [ "name", :unique]
    ])
    
    # Explicit many-to-many relationship
    Link("products", "tags", "many_to_many", [ :via = "product_tags" ])
    
    # Self-referencing hierarchy
    Hierarchy("categories", [ :parent_field = "parent_id"] )

	# Further explaining this hierarchy modeling concept:
    # Hierarchy Modeling: Self-referencing relationships where records in
	# the same table can be parents/children of each other, forming tree
	# structures like organizational charts or category hierarchies.

    # Explicit relationships defined
    ? @@NL( Relationships() )

}
#-->
'
[
	[
		[ "from", "products" ],
		[ "to", "categories" ],
		[ "type", "belongs_to" ],
		[ "inferred", 1 ],
		[ "field", "category_id" ],
		[
			"semantic_meaning",
			"Each product belongs to one category"
		]
	],
	[
		[ "from", "categories" ],
		[ "to", "products" ],
		[ "type", "has_many" ],
		[ "inferred", 1 ],
		[ "field", "category_id" ],
		[
			"semantic_meaning",
			"Each category can have many products"
		]
	],
	[
		[ "from", "products" ],
		[ "to", "tags" ],
		[ "type", "many_to_many" ],
		[ "inferred", 0 ],
		[
			"options",
			[
				[ "via", "product_tags" ]
			]
		]
	],
	[
		[ "from", "categories" ],
		[ "to", "categories" ],
		[ "type", "hierarchy" ],
		[ "inferred", 0 ],
		[
			"options",
			[
				[ "parent_field", "parent_id" ]
			]
		],
		[
			"semantic_meaning",
			"Each category can have a parent and multiple children, forming a tree structure"
		]
	]
]
'

pf()
# Executed in 0.15 second(s) in Ring 1.22

/*---

# Problem: Social network with users, posts, follows, and likes
# Solution: Combine different relationship types for comprehensive modeling

pr()

o1 = new stzDataModel("social_network")
o1 {
    # Core entities
    DefineTable("users", [
        [ "id", :primary_key ],
        [ "username", :unique ],
        [ "email", :email ],
        [ "profile_image", :url ]
    ])

    DefineTable("posts", [
        [ "id", :primary_key ],
        [ "user_id", :foreign_key ],
        [ "content", :text ],
        [ "created_at", :timestamp ]
    ])

    DefineTable("likes", [
        [ "id", :primary_key ],
        [ "user_id", :foreign_key ],
        [ "post_id", :foreign_key ],
        [ "created_at", :timestamp ]
    ])
    
    # Network relationship for following
    Network("users", "follows", [ :bidirectional = false ]) # Explain this modling concept
    
    # Many-to-many via likes table
    Link("users", "posts", "many_to_many", [:via = "likes", :as = "liked_posts"]) # Further explain the syntax
    
    # Social network model relationships
    ? @@NL( Relationships() )
}
#-->
'
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
		[ "from", "likes" ],
		[ "to", "users" ],
		[ "type", "belongs_to" ],
		[ "inferred", 1 ],
		[ "field", "user_id" ],
		[
			"semantic_meaning",
			"Each like belongs to one user"
		]
	],
	[
		[ "from", "users" ],
		[ "to", "likes" ],
		[ "type", "has_many" ],
		[ "inferred", 1 ],
		[ "field", "user_id" ],
		[
			"semantic_meaning",
			"Each user can have many likes"
		]
	],
	[
		[ "from", "likes" ],
		[ "to", "posts" ],
		[ "type", "belongs_to" ],
		[ "inferred", 1 ],
		[ "field", "post_id" ],
		[
			"semantic_meaning",
			"Each like belongs to one post"
		]
	],
	[
		[ "from", "posts" ],
		[ "to", "likes" ],
		[ "type", "has_many" ],
		[ "inferred", 1 ],
		[ "field", "post_id" ],
		[
			"semantic_meaning",
			"Each post can have many likes"
		]
	],
	[
		[ "from", "users" ],
		[ "to", "users" ],
		[ "type", "network" ],
		[ "name", "follows" ],
		[ "inferred", 0 ],
		[
			"options",
			[
				[ "bidirectional", 0 ]
			]
		]
	],
	[
		[ "from", "users" ],
		[ "to", "posts" ],
		[ "type", "many_to_many" ],
		[ "inferred", 0 ],
		[
			"options",
			[
				[ "via", "likes" ],
				[ "as", "liked_posts" ]
			]
		]
	]
]
'

pf()
# Executed in 1.08 second(s) in Ring 1.22

#================================#
#  SCHEMA EVOLUTION & MIGRATION  #
#================================#

/*--- Security: Prevent breaking changes via validation

pr()

o1 = new stzDataModel("inventory_system")
o1 {
    DefineTable("categories", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "parent_id", :foreign_key ],
        [ "ref", :unique ]
    ])

    DefineTable("products", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "category_id", :foreign_key ],
        [ "price", :decimal ],
        [ "active", :boolean ]
    ])

    DefineTable("tags", [
        [ "id", :primary_key ],
        [ "name", :unique ]
    ])
    
    Link("products", "tags", "many_to_many", [ :via = "product_tags" ])
    Hierarchy("categories", [ :parent_field = "parent_id" ])
    
    # Analyze impact of adding a new field
    impact = AddField("products", "description", :text, [:nullable = true])
    ? "Impact analysis for adding 'description' field:"
    ? @@NL( impact ) + NL
    
    # Try to remove a critical field (this should warn us)
    try
        impact = RemoveField("products", "category_id")
        ? "Field removal impact:"
        ? @@NL( impact )
    catch
        ? "Breaking change prevented: Cannot remove field 'category_id' - breaks relationships"
    done
}
#--> ERROR: Unexpected result
'
Impact analysis for adding 'description' field:
[
	[ "breaking_changes", 0 ],
	[ "performance_impact", "low" ],
	[ "migration_complexity", "simple" ],
	[
		"affected_relationships",
		[ ]
	],
	[
		"recommendations",
		[
			"Large text fields may impact query performance"
		]
	]
]

Breaking change prevented: Cannot remove field 'category_id' - breaks relationships
'

pf()
# Executed in 0.43 second(s) in Ring 1.22

/*--- Version control for schema evolution

pr()

o1 = new stzDataModel([ "blog_platform", "2.1"])
o1 {
    DefineTable("authors", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "email", :email ],
        [ "bio", :text ]
    ])
    
    DefineTable("articles", [
        [ "id", :primary_key ],
        [ "author_id", :foreign_key ],
        [ "title", :required ],
        [ "content", :text ],
        [ "published_at", :timestamp ],
        [ "view_count", "integer" ]  # Added in v2.1
    ])
    
    ? "Schema: " + SchemaName() + " v" + SchemaVersion()
    ? @@NL( Explain() )
}
#--> Other then adding the version, the sample does not show how versioning
# of the data model is used (and useful) in practice:
'
Schema: blog_platform v2.1
"Data Model: blog_platform (v2.1)

This model contains 2 tables:
- authors: 4 fields, 2 relationships
- articles: 6 fields, 2 relationships

Key relationships:
- articles belongs_to authors
- authors has_many articles
'

pf()
# Executed in 0.68 second(s) in Ring 1.22

#============================#
#  PERFORMANCE OPTIMIZATION  #
#============================#

/*--- Basic Data Model with Default Performance Plan
*/
pr()

o1 = new stzDataModel("blog_platform")
o1 {
    DefineTable("authors", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "email", :email ],
        [ "bio", :text ]
    ])
    
    DefineTable("articles", [
        [ "id", :primary_key ],
        [ "author_id", :foreign_key ],
        [ "title", :required ],
        [ "content", :text ],
        [ "published_at", :timestamp ],
        [ "view_count", "integer" ]
    ])
    
    # Set the default performance plan (already set by init)
    SetPerformancePlan("default")
    
    # Analyze performance
    performance_hints = AnalyzePerformance()
    ? BoxRound("Performance optimization hints (Default Plan)")
    ? @@NL( performance_hints ) + NL
}

pf()

/*---


#=============================#
#  DEBUGGING & VISUALIZATION  #
#=============================#

/*--- Understanding your model structure

pr()

o1 = new stzDataModel("blog_platform")
o1 {
    DefineTable("authors", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "email", :email ],
        [ "bio", :text]
    ])
    
    DefineTable("articles", [
        [ "id", :primary_key ],
        [ "author_id", :foreign_key ],
        [ "title", :required ],
        [ "content", :text ],
        [ "published_at", :timestamp ],
        [ "view_count", "integer"]
    ])
    
    # Get comprehensive model explanation
    ? Explain()

}
'
Data Model: blog_platform (v1.0)

This model contains 2 tables:
- authors: 4 fields, 2 relationships
- articles: 6 fields, 2 relationships

Key relationships:
- articles belongs_to authors
- authors has_many articles
'
pf()
# Executed in 0.35 second(s) in Ring 1.22

/*---

pr()

? stzlen("softanza")
#--> 8

? stzleft("softanza", 4)
#--> soft

? stzright("softanza", 4)
#--> anza

pf()

/*--- Diagram generation

pr()

o1 = new stzDataModel("blog_platform")
o1 {
    DefineTable("authors", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "email", :email ],
        [ "bio", :text]
    ])
    
    DefineTable("articles", [
        [ "id", :primary_key ],
        [ "author_id", :foreign_key ],
        [ "title", :required ],
        [ "content", :text ],
        [ "published_at", :timestamp ],
        [ "view_count", "integer"]
    ])

    # Generate entity-relationship diagram data
    erd_data = DiagramData()
	? @@NL( erd_data )
	#-->
'
[
	[
		"entities",
		[
			[
				[ "name", "authors" ],
				[ "field_count", 4 ],
				[ "type", "table" ]
			],
			[
				[ "name", "articles" ],
				[ "field_count", 6 ],
				[ "type", "table" ]
			]
		]
	],
	[
		"connections",
		[
			[
				[ "from", "articles" ],
				[ "to", "authors" ],
				[ "type", "belongs_to" ],
				[ "inferred", 1 ]
			],
			[
				[ "from", "authors" ],
				[ "to", "articles" ],
				[ "type", "has_many" ],
				[ "inferred", 1 ]
			]
		]
	],
	[ "complexity", "simple" ],
	[
		"self_referencing",
		[ ]
	]
]
'
}

pf()
# Executed in 0.38 second(s) in Ring 1.22

#=============================#
#  ADVANCED PATTERN MATCHING  #
#=============================#

/*--- Dynamic table access for flexible querying

pr()

o1 = new stzDataModel("ecommerce_basic")
o1 {
    DefineTable("customers", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "email", :email ],
        [ "created_at", :timestamp]
    ])
    
    DefineTable("orders", [
        [ "id", :primary_key ],
        [ "customer_id", :foreign_key ],
        [ "total", :decimal ],
        [ "status", "varchar(50)" ],
        [ "created_at", :timestamp]
    ])
    
    # Access tables dynamically

    customers_table = GetTable("customers")

    # Dynamic table access

    ? @@([ :name = customers_table.Name(), :fields = customers_table.FieldCount() ])
    #--> [ [ "name", "customers" ], [ "fields", 4 ] ]

    # Try accessing non-existent table

    try
        invalid_table = GetTable("nonexistent")
		? invalid_table.Name()

    catch
        ? "Invalid table access prevented"
    done
	#--> Invalid table access prevented

}

pf()
# Executed in 0.37 second(s) in Ring 1.22

/*--- Field-level validation and constraints

pr()

o1 = new stzDataModel("user_management")
o1 {
    DefineTable("users", [
        [ "id", :primary_key ],
        [ "username", :required ],
        [ "email", :email ],
        [ "age", "integer" ],
        [ "status", "varchar(20)"]
    ])
    
    # Add custom constraints
    AddConstraint("users", "age", "CHECK (age >= 18 AND age <= 120)")
    AddConstraint("users", "status", "CHECK (status IN ('active', 'inactive', 'suspended'))")
    
    # Validate the enhanced model
    validation = Validate()
    ? "Validation result:"
    ? @@NL( validation )
}
#-->
'
Validation result:
[
	[ "valid", 1 ],
	[
		"errors",
		[ ]
	],
	[ "error_count", 0 ],
	[ "tables_validated", 1 ],
	[ "relationships_validated", 0 ]
]
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

#================================#
#  REAL-WORLD WORKFLOW PATTERNS  #
#================================#

/*--- Complete e-commerce system with all relationship types

pr()

o1 = new stzDataModel([ "ecommerce_complete", "3.0"])
o1 {
    # Customer management with hierarchy
    DefineTable("customers", [
        [ "id", :primary_key ],
        [ "parent_id", :foreign_key ],      # For B2B hierarchies
        [ "name", :required ],
        [ "email", :email ],
        [ "type", "varchar(20)"]           	# individual, business
    ])
    
    # Product catalog with categories
    DefineTable("categories", [
        [ "id", :primary_key ],
        [ "parent_id", :foreign_key ],
        [ "name", :required ],
        [ "path", "varchar(500)"]
    ])
    
    DefineTable("products", [
        [ "id", :primary_key ],
        [ "category_id", :foreign_key ],
        [ "name", :required ],
        [ "price", :decimal ],
        [ "inventory_count", "integer"]
    ])
    
    # Order processing
    DefineTable("orders", [
        [ "id", :primary_key ],
        [ "customer_id", :foreign_key ],
        [ "status", "varchar(50)" ],
        [ "total", :decimal ],
        [ "created_at", :timestamp]
    ])
    
    DefineTable("order_items", [
        [ "id", :primary_key ],
        [ "order_id", :foreign_key ],
        [ "product_id", :foreign_key ],
        [ "quantity", "integer" ],
        [ "unit_price", :decimal]
    ])
    
    # Define explicit relationships
    Hierarchy("customers", [:parent_field = "parent_id"])     # B2B customer hierarchies
    Hierarchy("categories", [:parent_field = "parent_id"])    # Product categories
    Link("orders", "products", "many_to_many", [:via = "order_items"])
    
    # Comprehensive analysis
    explanation = Explain()
    ? "Complete e-commerce model:"
    ? @@NL( explanation )
    
    validation = Validate()
    ? "Validation result:"
    ? @@NL( validation )

}
#-->
'
Complete e-commerce model:
"Data Model: ecommerce_complete (v3.0)

This model contains 5 tables:
- customers: 5 fields, 3 relationships
- categories: 4 fields, 3 relationships
- products: 5 fields, 5 relationships
- orders: 5 fields, 5 relationships
- order_items: 5 fields, 4 relationships

Key relationships:
- products belongs_to categories
- categories has_many products
- orders belongs_to customers
- customers has_many orders
- order_items belongs_to orders
- orders has_many order_items
- order_items belongs_to products
- products has_many order_items
- customers hierarchy customers
- categories hierarchy categories
- orders many_to_many products
"
Validation result:
[
	[ "valid", 1 ],
	[
		"errors",
		[ ]
	],
	[ "error_count", 0 ],
	[ "tables_validated", 5 ],
	[ "relationships_validated", 11 ]
]
'
pf()
# Executed in 1.45 second(s) in Ring 1.22

/*--- Migration workflow for production systems

pr()

o1 = new stzDataModel([ "ecommerce_complete", "3.0"])
o1 {
    DefineTable("customers", [
        [ "id", :primary_key ],
        [ "parent_id", :foreign_key ],
        [ "name", :required ],
        [ "email", :email ],
        [ "type", "varchar(20)"]
    ])
    
    DefineTable("categories", [
        [ "id", :primary_key ],
        [ "parent_id", :foreign_key ],
        [ "name", :required ],
        [ "path", "varchar(500)"]
    ])
    
    DefineTable("products", [
        [ "id", :primary_key ],
        [ "category_id", :foreign_key ],
        [ "name", :required ],
        [ "price", :decimal ],
        [ "inventory_count", "integer"]
    ])
    
    DefineTable("orders", [
        [ "id", :primary_key ],
        [ "customer_id", :foreign_key ],
        [ "status", "varchar(50)" ],
        [ "total", :decimal ],
        [ "created_at", :timestamp]
    ])
    
    DefineTable("order_items", [
        [ "id", :primary_key ],
        [ "order_id", :foreign_key ],
        [ "product_id", :foreign_key ],
        [ "quantity", "integer" ],
        [ "unit_price", :decimal]
    ])
    
    Hierarchy("customers", [:parent_field = "parent_id"])
    Hierarchy("categories", [:parent_field = "parent_id"])
    Link("orders", "products", "many_to_many", [:via = "order_items"])
    
    # Stage 1: Current state analysis
    current_state = Explain()
    ? BoxRound("Current state")
    ? @@NL( current_state ) + nl
    
    # Stage 2: Impact analysis for new field
    impact = AddField("customers", "preferences", :text, [:nullable = true])
    ? BoxRound("Migration impact analysis")
    ? @@NL( impact ) + NL
    
    # Stage 3: Performance analysis
    performance_hints = AnalyzePerformance()
    ? BoxRound("Performance analysis")
    ? @@NL( performance_hints ) + NL
    
    # Stage 4: Final validation
    final_validation = Validate()
    ? BoxRound("Final validation")
    ? @@NL( final_validation )
}
#-->
'
╭───────────────╮
│ Current state │
╰───────────────╯
"Data Model: ecommerce_complete (v3.0)

This model contains 5 tables:
- customers: 5 fields, 3 relationships
- categories: 4 fields, 3 relationships
- products: 5 fields, 5 relationships
- orders: 5 fields, 5 relationships
- order_items: 5 fields, 4 relationships

Key relationships:
- products belongs_to categories
- categories has_many products
- orders belongs_to customers
- customers has_many orders
- order_items belongs_to orders
- orders has_many order_items
- order_items belongs_to products
- products has_many order_items
- customers hierarchy customers
- categories hierarchy categories
- orders many_to_many products
"

╭───────────────────────────╮
│ Migration impact analysis │
╰───────────────────────────╯
[
	[ "breaking_changes", 0 ],
	[ "performance_impact", "low" ],
	[ "migration_complexity", "simple" ],
	[
		"affected_relationships",
		[ ]
	],
	[
		"recommendations",
		[
			"Large text fields may impact query performance"
		]
	]
]

╭──────────────────────╮
│ Performance analysis │
╰──────────────────────╯
[
	[
		[ "type", "query_optimization" ],
		[ "priority", "high" ],
		[
			"message",
			"Potential N+1 query problem detected"
		],
		[ "table", "categories" ],
		[ "related_table", "products" ],
		[ "relationship", "has_many" ],
		[
			"reason",
			"Loading categories records may trigger multiple queries for products"
		],
		[
			"action",
			"Use eager loading or joins when querying categories with products"
		]
	],
	[
		[ "type", "query_optimization" ],
		[ "priority", "high" ],
		[
			"message",
			"Potential N+1 query problem detected"
		],
		[ "table", "customers" ],
		[ "related_table", "orders" ],
		[ "relationship", "has_many" ],
		[
			"reason",
			"Loading customers records may trigger multiple queries for orders"
		],
		[
			"action",
			"Use eager loading or joins when querying customers with orders"
		]
	],
	[
		[ "type", "query_optimization" ],
		[ "priority", "high" ],
		[
			"message",
			"Potential N+1 query problem detected"
		],
		[ "table", "orders" ],
		[ "related_table", "order_items" ],
		[ "relationship", "has_many" ],
		[
			"reason",
			"Loading orders records may trigger multiple queries for order_items"
		],
		[
			"action",
			"Use eager loading or joins when querying orders with order_items"
		]
	],
	[
		[ "type", "query_optimization" ],
		[ "priority", "high" ],
		[
			"message",
			"Potential N+1 query problem detected"
		],
		[ "table", "products" ],
		[ "related_table", "order_items" ],
		[ "relationship", "has_many" ],
		[
			"reason",
			"Loading products records may trigger multiple queries for order_items"
		],
		[
			"action",
			"Use eager loading or joins when querying products with order_items"
		]
	]
]

╭──────────────────╮
│ Final validation │
╰──────────────────╯
[
	[ "valid", 1 ],
	[
		"errors",
		[ ]
	],
	[ "error_count", 0 ],
	[ "tables_validated", 5 ],
	[ "relationships_validated", 11 ]
]
'

pf()
# Executed in 1.47 second(s) in Ring 1.22

#=======================#
#  EDUCATIONAL SUMMARY  #
#=======================#

# KEY LEARNING POINTS:
#
# 1. START SIMPLE: Use naming conventions for automatic relationship inference
# 2. BE EXPLICIT: Use Link(), Hierarchy(), Network() for complex relationships  
# 3. VALIDATE EARLY: Always run Validate() before production deployment
# 4. EVOLVE SAFELY: Use impact analysis for schema changes
# 5. OPTIMIZE SMART: Follow performance hints to prevent slow queries
# 6. DEBUG VISUALLY: Use Explain() and GetERDData() for model understanding
# 7. PLAN MIGRATIONS: Use staged approach for production schema changes

# WHEN TO USE EACH FEATURE:
#
# • DefineTable(): Basic schema definition with smart defaults
# • Link(): Complex relationships that can't be auto-inferred  
# • Hierarchy(): Parent-child trees (categories, org charts)
# • Network(): Peer-to-peer connections (social networks, graphs)
# • Validate(): Before any production deployment or major change
# • AnalyzePerformance(): When queries become slow
# • Explain(): When debugging complex models or onboarding new developers
# • GetERDData(): When generating documentation or visual diagrams
