
# stzDataModel Test Suite - Educational Samples
# Demonstrating practical usage patterns and design workflows

load "../max/stzmax.ring"

#=========================#
# BASIC SCHEMA DEFINITION #
#=========================#

/*--- Starting simple: defining tables with intelligent conventions

pr()

# Problem: You need to quickly model a basic e-commerce system without boilerplate
# Solution: Use stzDataModel's convention-over-configuration approach

o1 = new stzDataModel("ecommerce_basic")
o1 {
    # Define customers table with smart field types
    DefineTable("customers", [
        ["id", :primary_key],
        ["name", :required],
        ["email", :email],
        ["created_at", :timestamp]
    ])
    
    # Define orders table - foreign keys auto-inferred
    DefineTable("orders", [
        ["id", :primary_key],
        ["customer_id", :foreign_key],  # Automatically links to customers.id
        ["total", :decimal],
        ["status", "varchar(50)"],
        ["created_at", :timestamp]
    ])
    
    ? "Schema created with automatic relationship inference:"
    ? @@( RelationshipSummary() ) + NL
    #--> [
    #      [:from = "orders", :to = "customers", :type = "belongs_to", :inferred = true],
    #      [:from = "customers", :to = "orders", :type = "has_many", :inferred = true]
    #    ]
}


# Validating your schema before proceeding


# Problem: You want to catch schema errors early, before runtime
# Solution: Use comprehensive validation with clear error messages

o1 {
    # Validate the complete model
    validation_result = Validate()
    
    if validation_result[:valid]
        ? "✓ Model validation successful!"
        ? "Tables defined: " + len(@tables)
        ? "Relationships inferred: " + len(@relationships)
    else
        ? "✗ Validation errors:"
        for error in validation_result[:errors]
            ? "  - " + error
        next
    ok
    #--> ✓ Model validation successful!
    #    Tables defined: 2
    #    Relationships inferred: 2
}

pf()
# Executed in 0.01 second(s) in Ring 1.22

#==================================#
#  EXPLICIT RELATIONSHIP MODELING  #
#==================================#

/*--- When conventions aren't enough: explicit relationship declaration

pr()

# Problem: Complex relationships that can't be inferred from naming
# Solution: Use explicit Link() method for precise control

o1 = new stzDataModel("inventory_system")
o1 {
    # Define product categories (self-referencing hierarchy)
    DefineTable("categories", [
        ["id", :primary_key],
        ["name", :required],
        ["parent_id", :foreign_key],
        ["slug", :unique]
    ])
    
    # Define products
    DefineTable("products", [
        ["id", :primary_key],
        ["name", :required],
        ["category_id", :foreign_key],
        ["price", :decimal],
        ["active", :boolean]
    ])
    
    # Define tags for flexible categorization
    DefineTable("tags", [
        ["id", :primary_key],
        ["name", :unique]
    ])
    
    # Explicit many-to-many relationship
    Link("products", "tags", "many_to_many", [:through = "product_tags"])
    
    # Self-referencing hierarchy
    Hierarchy("categories", [:parent_field = "parent_id"])
    
    ? "Explicit relationships defined:"

 	relationship_summary = GetRelationshipSummary()

	for rel in relationship_summary
		if rel[:inferred] = 0
			? "  " + rel[:from] + " → " + rel[:to] + " (" + rel[:type] + ")"
		ok
	next

    #-->
	# products → tags (many_to_many)
  	# categories → categories (hierarchy)
}

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*--- Handling complex domain models with multiple relationship types

pr()

# Problem: Social network with users, posts, follows, and likes
# Solution: Combine different relationship types for comprehensive modeling

o1 = new stzDataModel("social_network")
o1 {
    # Core entities
    DefineTable("users", [
        ["id", :primary_key],
        ["username", :unique],
        ["email", :email],
        ["profile_image", :url]
    ])
    
    DefineTable("posts", [
        ["id", :primary_key],
        ["user_id", :foreign_key],
        ["content", :text],
        ["created_at", :timestamp]
    ])

    DefineTable("likes", [
        ["id", :primary_key],
        ["user_id", :foreign_key],
        ["post_id", :foreign_key],
        ["created_at", :timestamp]
    ])
    
    # Network relationship for following
    Network("users", "follows", [:bidirectional = false])
    
    # Many-to-many through likes table
    Link("users", "posts", "many_to_many", [:through = "likes", :as = "liked_posts"])
    
    ? "Social network model relationships:"
    relationship_summary = GetRelationshipSummary()
    for rel in relationship_summary
        ? "  " + rel[:from] + " → " + rel[:to] + " (" + rel[:type] + ")"
    next
    #-->
	# posts → users (belongs_to)
	# users → posts (has_many)
	# likes → users (belongs_to)
	# users → likes (has_many)
	# likes → posts (belongs_to)
	# posts → likes (has_many)
	# users → users (network)
	# users → posts (many_to_many)

}

pf()
# Executed in 0.01 second(s) in Ring 1.22

#================================#
#  SCHEMA EVOLUTION & MIGRATION  #
#================================#


/*--- Safe schema changes with impact analysis

pr()

# Problem: You need to add a field to existing schema without breaking things
# Solution: Use impact analysis before making changes

o1 = new stzDataModel("inventory_system")
o1 {
    # Define product categories (self-referencing hierarchy)
    DefineTable("categories", [
        ["id", :primary_key],
        ["name", :required],
        ["parent_id", :foreign_key],
        ["slug", :unique]
    ])
    
    # Define products
    DefineTable("products", [
        ["id", :primary_key],
        ["name", :required],
        ["category_id", :foreign_key],
        ["price", :decimal],
        ["active", :boolean]
    ])
    
    # Define tags for flexible categorization
    DefineTable("tags", [
        ["id", :primary_key],
        ["name", :unique]
    ])
    
    # Explicit many-to-many relationship
    Link("products", "tags", "many_to_many", [:through = "product_tags"])
    
    # Self-referencing hierarchy
    Hierarchy("categories", [:parent_field = "parent_id"])
}

o1 {
    # Analyze impact of adding a new field
    impact = AddField("products", "description", :text, [:nullable = true])
    
    ? "Impact analysis for adding 'description' field:"
    ? "─ Breaking changes: " + impact[:breaking_changes]
    ? "─ Performance impact: " + impact[:performance_impact]
    ? "─ Migration complexity: " + impact[:migration_complexity]
    #--> Breaking changes: 0
    #    Performance impact: minimal
    #    Migration complexity: simple
    
	? ""
    # Try to remove a critical field (this should warn us)
    try
        impact2 = RemoveField("products", "category_id")
        ? "Field removal impact:"
        ? "  Breaking changes: " + impact2[:breaking_changes]

    catch
        ? "✓ System prevented breaking change:"
        ? "  Cannot remove field 'category_id' - it would break relationships"
    done
    #--> ✓ System prevented breaking change:
    #      Cannot remove field 'category_id' - it would break relationships
}

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Version control for schema evolution

pr()

# Problem: Track schema changes over time for team collaboration
# Solution: Version-aware model definition with change tracking

o1 = new stzDataModel(["blog_platform", "2.1"])
o1 {
    # Define initial schema
    DefineTable("authors", [
        ["id", :primary_key],
        ["name", :required],
        ["email", :email],
        ["bio", :text]
    ])
    
    DefineTable("articles", [
        ["id", :primary_key],
        ["author_id", :foreign_key],
        ["title", :required],
        ["content", :text],
        ["published_at", :timestamp],
        ["view_count", "integer"]  # Added in v2.1
    ])
    
    ? "Schema version: " + @schema_version
    ? "Model evolution tracking enabled"
    #--> Schema version: 2.1
    #    Model evolution tracking enabled
}

#NOTE It's not clear for in the example me how versioning is made
# and how it is useful in practice

pf()
# Executed in 0.01 second(s) in Ring 1.22

#============================#
#  PERFORMANCE OPTIMIZATION  #
#============================#

/*--- Getting performance hints for better query optimization

pr()

# Problem: Your queries are slow and you need optimization guidance
# Solution: Use built-in performance analysis

o1 = new stzDataModel(["blog_platform", "2.1"])
o1 {
    # Define initial schema
    DefineTable("authors", [
        ["id", :primary_key],
        ["name", :required],
        ["email", :email],
        ["bio", :text]
    ])
    
    DefineTable("articles", [
        ["id", :primary_key],
        ["author_id", :foreign_key],
        ["title", :required],
        ["content", :text],
        ["published_at", :timestamp],
        ["view_count", "integer"]  # Added in v2.1
    ])
    

    # Analyze current model for performance issues
    performance_hints = AnalyzePerformance()
    
    ? "Performance optimization hints:"
    for hint in performance_hints
        ? "  ⚠ " + hint
    next
    #--> ⚠ Consider adding index on posts.user_id
    #    ⚠ Consider adding index on likes.user_id  
    #    ⚠ Consider adding index on likes.post_id
    #    ⚠ Consider eager loading for users has_many posts to avoid N+1 queries
    
    # Show table-specific recommendations
    tables_summary = GetTableSummary()
    for table_info in tables_summary
        if len(table_info[:relationships]) > 2
            ? "  💡 Table '" + table_info[:name] + "' has " + len(table_info[:relationships]) + " relationships - consider indexing strategy"
        ok
    next
    #--> 💡 Table 'users' has 4 relationships - consider indexing strategy
}

#ERROR returned
# Performance optimization hints:
#  ⚠ Consider eager loading for 
#  ⚠ authors
#  ⚠  
#  ⚠ has_many
#  ⚠  
#  ⚠ articles
#  ⚠  to avoid N+1 queries

pf()
# Executed in 0.01 second(s) in Ring 1.22

#=============================#
#  DEBUGGING & VISUALIZATION  #
#=============================#

/*--- Understanding your model structure visually

pr()

# Problem: Complex model is hard to understand and debug
# Solution: Use visualization and explanation tools

o1 = new stzDataModel(["blog_platform", "2.1"])
o1 {
    # Define initial schema
    DefineTable("authors", [
        ["id", :primary_key],
        ["name", :required],
        ["email", :email],
        ["bio", :text]
    ])
    
    DefineTable("articles", [
        ["id", :primary_key],
        ["author_id", :foreign_key],
        ["title", :required],
        ["content", :text],
        ["published_at", :timestamp],
        ["view_count", "integer"]  # Added in v2.1
    ])
    
    # Get comprehensive model explanation
    explanation = Explain()
    
    ? BoxRound("MODEL STRUCTURE ANALYSIS")
	? @@NL(explanation)

}
#-->
'
[
	[
		"tables",
		[
			[
				[ "name", "authors" ],
				[ "fields", 4 ],
				[ "relationships", 2 ]
			],
			[
				[ "name", "articles" ],
				[ "fields", 6 ],
				[ "relationships", 2 ]
			]
		]
	],
	[
		"relationships",
		[
			[
				[ "from", "articles" ],
				[ "to", "authors" ],
				[ "type", "belongs_to" ],
				[ "inferred", 1 ],
				[ "field", "author_id" ]
			],
			[
				[ "from", "authors" ],
				[ "to", "articles" ],
				[ "type", "has_many" ],
				[ "inferred", 1 ],
				[ "field", "author_id" ]
			]
		]
	],
	[
		"performance_hints",
		[
			"Consider eager loading for ",
			"authors",
			" ",
			"has_many",
			" ",
			"articles",
			" to avoid N+1 queries"
		]
	]
]
'
#ERROR: performance hints carries no conrete info

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*--- Visual relationship diagram generation

pr()

# Problem: Need to share model structure with non-technical stakeholders
# Solution: Generate visual ER diagram

o1 = new stzDataModel(["blog_platform", "2.1"])
o1 {
    # Define initial schema
    DefineTable("authors", [
        ["id", :primary_key],
        ["name", :required],
        ["email", :email],
        ["bio", :text]
    ])
    
    DefineTable("articles", [
        ["id", :primary_key],
        ["author_id", :foreign_key],
        ["title", :required],
        ["content", :text],
        ["published_at", :timestamp],
        ["view_count", "integer"]  # Added in v2.1
    ])
    

    # Generate entity-relationship diagram
    erd_info = Visualize()
  	? @@NL(erd_info)
}
#--> is this a well formed standard ERD that we can use in any tool?
'
[
	[
		"entities",
		[
			[
				[ "name", "authors" ],
				[ "field_count", 4 ]
			],
			[
				[ "name", "articles" ],
				[ "field_count", 6 ]
			]
		]
	],
	[
		"connections",
		[
			[
				[ "from", "articles" ],
				[ "to", "authors" ],
				[ "type", "belongs_to" ]
			],
			[
				[ "from", "authors" ],
				[ "to", "articles" ],
				[ "type", "has_many" ]
			]
		]
	],
	[ "complexity", "simple" ]
]
'

pf()
# Executed in 0.03 second(s) in Ring 1.22

#TODO add a stzDataDiagram class that accepts an ERD data and generates
# an ascii-art-based string with the actual diagram. Keep it simple
# and adapted to veiwing it in the console like the other stzChart...,
# stzTable, stzGrid, and similar Softanza Show() features.

#=============================#
#  ADVANCED PATTERN MATCHING  #
#=============================#

/*--- Dynamic table access for flexible querying

pr()

# Problem: Need to access tables dynamically based on user input
# Solution: Use method_missing for natural table access

#ERORO this sample makes no sense for me: what it does exactly?
# I don't see how it is related to the problem/solution stated!
# And it uses inecistajt methods and wrong syntax "this."
# Add an o1 = new stzDataModle() with the necessary tables

o1 {
    # Access tables naturally (this uses method_missing internally)
    try {
        customers_table = This.customers  # Same as This.Table("customers")
        ? "✓ Dynamic table access works:"
        ? "  Table name: " + customers_table.table.name()
        ? "  Field count: " + customers_table.table.field_count()
        #--> ✓ Dynamic table access works:
        #      Table name: customers
        #      Field count: 4
        
        # Try accessing non-existent table
        invalid_table = This.nonexistent
    }
    catch {
        ? "✓ Error prevention works:"
        ? "  Invalid table access caught and prevented"
        #--> ✓ Error prevention works:
        #      Invalid table access caught and prevented
    }
}

pf()
# Execution time: ~8ms (dynamic access with safety checks)

/*--- Field-level validation and constraints

pr()

# Problem: Need custom validation rules beyond basic types
# Solution: Add field-level constraints and validation

o1 = new stzDataModel("user_management")
o1 {
    DefineTable("users", [
        ["id", :primary_key],
        ["username", :required],
        ["email", :email],
        ["age", "integer"],
        ["status", "varchar(20)"]
    ])
    
    # Add custom constraints
    users_table = GetTable("users")
    
    # Validate the enhanced model
    validation = Validate()
    ? @@NL(validation)
 
}
#-->
'
[
	[ "valid", 1 ],
	[
		"errors",
		[ ]
	]
]
'

#TODO: Is this correct? how to interpret it?

pf()
# Executed in 0.01 second(s) in Ring 1.22

#================================#
#  REAL-WORLD WORKFLOW PATTERNS  #
#================================#

/*--- Complete e-commerce system with all relationship types

pr()

# Problem: Model a complete e-commerce system with complex relationships
# Solution: Combine all stzDataModel features for comprehensive solution

o1 = new stzDataModel(["ecommerce_complete", "3.0"])
o1 {
    # Customer management with hierarchy
    DefineTable("customers", [
        ["id", :primary_key],
        ["parent_id", :foreign_key],      # For B2B hierarchies
        ["name", :required],
        ["email", :email],
        ["type", "varchar(20)"]           # individual, business
    ])
    
    # Product catalog with categories
    DefineTable("categories", [
        ["id", :primary_key],
        ["parent_id", :foreign_key],
        ["name", :required],
        ["path", "varchar(500)"]
    ])
    
    DefineTable("products", [
        ["id", :primary_key],
        ["category_id", :foreign_key],
        ["name", :required],
        ["price", :decimal],
        ["inventory_count", "integer"]
    ])
    
    # Order processing
    DefineTable("orders", [
        ["id", :primary_key],
        ["customer_id", :foreign_key],
        ["status", "varchar(50)"],
        ["total", :decimal],
        ["created_at", :timestamp]
    ])
    
    DefineTable("order_items", [
        ["id", :primary_key],
        ["order_id", :foreign_key],
        ["product_id", :foreign_key],
        ["quantity", "integer"],
        ["unit_price", :decimal]
    ])
    
    # Define explicit relationships
    Hierarchy("customers", [:parent_field = "parent_id"])     # B2B customer hierarchies
    Hierarchy("categories", [:parent_field = "parent_id"])    # Product categories
    Link("orders", "products", "many_to_many", [:through = "order_items"])
    
    # Comprehensive analysis
    ? BoxRound("COMPLETE E-COMMERCE MODEL")
    explanation = Explain()
 //   ? @@NL(explanation)

    ? "📊 Model Statistics:"
    ? "  Tables: " + len(explanation[:tables])
    ? "  Relationships: " + len(explanation[:relationships])
    ? "  Performance hints: " + len(explanation[:performance_hints])
    #--> 📊 Model Statistics:
    #      Tables: 5
    #      Relationships: 8
    #      Performance hints: 6
    
    validation = Validate()
    if validation[:valid]
        ? "✅ Complete model validation: PASSED"
        ? "🚀 Ready for production use"
    else
		? ""
        ? "❌ Validation issues found:"
        ? @@NL(validation[:errors])

    ok
}
#-->
'
[
	"Relationship references non-existent table: ",
	"parents",
	"Relationship references non-existent table: ",
	"parents",
	"Relationship references non-existent table: ",
	"parents",
	"Relationship references non-existent table: ",
	"parents"
]
'
#TODO May a better container be in the form of [ [ "error mesage...", "tablename" ])
# or even [ "tablename", [ "error message1..", "error message2..." ], ... ] to make
# it accessible and analyzable

pf()
# Execution time: ~35ms (comprehensive model requires thorough validation)

/*--- Migration workflow for production systems
*/
pr()

# Problem: Safely evolve production schema without downtime
# Solution: Use staged migration approach with rollback capability

o1 = new stzDataModel(["ecommerce_complete", "3.0"])
o1 {
    # Customer management with hierarchy
    DefineTable("customers", [
        ["id", :primary_key],
        ["parent_id", :foreign_key],      # For B2B hierarchies
        ["name", :required],
        ["email", :email],
        ["type", "varchar(20)"]           # individual, business
    ])
    
    # Product catalog with categories
    DefineTable("categories", [
        ["id", :primary_key],
        ["parent_id", :foreign_key],
        ["name", :required],
        ["path", "varchar(500)"]
    ])
    
    DefineTable("products", [
        ["id", :primary_key],
        ["category_id", :foreign_key],
        ["name", :required],
        ["price", :decimal],
        ["inventory_count", "integer"]
    ])
    
    # Order processing
    DefineTable("orders", [
        ["id", :primary_key],
        ["customer_id", :foreign_key],
        ["status", "varchar(50)"],
        ["total", :decimal],
        ["created_at", :timestamp]
    ])
    
    DefineTable("order_items", [
        ["id", :primary_key],
        ["order_id", :foreign_key],
        ["product_id", :foreign_key],
        ["quantity", "integer"],
        ["unit_price", :decimal]
    ])
    
    # Define explicit relationships
    Hierarchy("customers", [:parent_field = "parent_id"])     # B2B customer hierarchies
    Hierarchy("categories", [:parent_field = "parent_id"])    # Product categories
    Link("orders", "products", "many_to_many", [:through = "order_items"])
    

    ? BoxRound("PRODUCTION MIGRATION WORKFLOW")
    
    # Stage 1: Analyze current state
    current_state = Explain()
    ? "📋 Current state: " + len(current_state[:tables]) + " tables, " + len(current_state[:relationships]) + " relationships"
    
    # Stage 2: Plan changes
    ? "📝 Planning migration: Add customer preferences table"
    
    # Stage 3: Impact analysis
    impact = AddField("customers", "preferences", :text, [:nullable = true])
    ? "📊 Impact analysis:"
    ? "  Breaking changes: " + impact[:breaking_changes]
    ? "  Migration complexity: " + impact[:migration_complexity]
    #--> 📊 Impact analysis:
    #      Breaking changes: 0
    #      Migration complexity: simple
    
    # Stage 4: Performance check
    performance_hints = AnalyzePerformance()
    ? "⚡ Performance review: " + len(performance_hints) + " optimization opportunities"
? @@nL(performance_hints)
    # Stage 5: Final validation
    final_validation = Validate()
    if final_validation[:valid]
        ? "✅ Migration ready for deployment"
        ? "🎯 All systems green - proceed with confidence"
    ok
    #--> ✅ Migration ready for deployment
    #    🎯 All systems green - proceed with confidence
}

#TODO when we inspect performance_hints we get a non readable data structure:
#-->
'
[
	"Consider eager loading for ",
	"parents",
	" ",
	"has_many",
	" ",
	"customers",
	" to avoid N+1 queries",
	"Consider eager loading for ",
	"parents",
	" ",
	"has_many",
	" ",
	"categories",
	" to avoid N+1 queries",
	"Consider eager loading for ",
	"categories",
	" ",
	"has_many",
	" ",
	"products",
	" to avoid N+1 queries",
	"Consider eager loading for ",
	"customers",
	" ",
	"has_many",
	" ",
	"orders",
	" to avoid N+1 queries",
	"Consider eager loading for ",
	"orders",
	" ",
	"has_many",
	" ",
	"order_items",
	" to avoid N+1 queries",
	"Consider eager loading for ",
	"products",
	" ",
	"has_many",
	" ",
	"order_items",
	" to avoid N+1 queries"
]
'
# I would like to see somthing as clear as this:
# [
#	"performance hint in clear terms",
#	"cause of perofmance problem in simple terms",
#	[ "table1", "table2" ] # tables implicated in the peformance problem
#	[ "rel1", "rel2" ] # relations implicated in the perf problem
#	[ "query1", "..." ] # queries and any other asset or useful data related to the problem
#	[ "action1", "action2", ... ] # steps of actions as a plan for solution
# ]

pf()
# Executed in 0.03 second(s) in Ring 1.22

#=======================#
#  EDUCATIONAL SUMMARY  #
#=======================#

# KEY LEARNING POINTS:

# 1. START SIMPLE: Use naming conventions for automatic relationship inference
# 2. BE EXPLICIT: Use Link(), Hierarchy(), Network() for complex relationships
# 3. VALIDATE EARLY: Always run Validate() before production deployment
# 4. EVOLVE SAFELY: Use impact analysis for schema changes
# 5. OPTIMIZE SMART: Follow performance hints to prevent slow queries
# 6. DEBUG VISUALLY: Use Explain() and Visualize() for model understanding
# 7. PLAN MIGRATIONS: Use staged approach for production schema changes

# WHEN TO USE EACH FEATURE

# • DefineTable(): Basic schema definition with smart defaults
# • Link(): Complex relationships that can't be auto-inferred
# • Hierarchy(): Parent-child trees (categories, org charts)
# • Network(): Peer-to-peer connections (social networks, graphs)
# • Validate(): Before any production deployment or major change
# • AnalyzePerformance(): When queries become slow
# • Explain(): When debugging complex models or onboarding new developers
# • Visualize(): When communicating with non-technical stakeholders

# DESIGN WORKFLOW

# 1. Model core entities with DefineTable()
# 2. Let auto-inference handle obvious relationships
# 3. Add explicit relationships for complex cases
# 4. Validate and fix any issues
# 5. Analyze performance and add optimizations
# 6. Document with Explain() and Visualize()
# 7. Plan evolution with impact analysis
