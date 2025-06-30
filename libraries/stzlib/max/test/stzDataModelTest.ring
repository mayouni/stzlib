# stzDataModel Test Suite - Educational Samples
# Demonstrating practical usage patterns and design workflows

load "../stzmax.ring"

/*---

pr()

? @@( Lines(str) ) # Or use str2list() from Ring StdLib
#--> [ "ring", "programming", "language" ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

#=========================#
# BASIC SCHEMA DEFINITION #
#=========================#

/*---

# Problem: You need to quickly model a basic e-commerce system without boilerplate
# Solution: Use stzDataModel's convention-over-configuration approach

pr()

o1 = new stzDataModel("ecommerce_basic")
o1 {
    # Add customers table with smart field types
    AddTable("customers", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "email", :email ],
        [ "created_at", :timestamp ]
    ])
    
    # Add orders table - foreign keys auto-inferred
    AddTable("orders", [
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
		[ "type", "belongs_to" ],
		[ "from", "orders" ],
		[ "to", "customers" ],
		[ "field", "customer_id" ],
		[ "inferred", 1 ]
	],
	[
		[ "type", "has_many" ],
		[ "from", "customers" ],
		[ "to", "orders" ],
		[ "field", "customer_id" ],
		[ "inferred", 1 ]
	]
]
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

#==================================#
#  EXPLICIT RELATIONSHIP MODELING  #
#==================================#

/*---

# Problem: Complex relationships that can't be inferred from naming
# Solution: Use explicit Link() method for precise control

pr()

o1 = new stzDataModel("inventory_system")
o1 {
    # Add product categories (self-referencing hierarchy)
    AddTable("categories", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "parent_id", :foreign_key ],	# Inferred a "parents" table that does not exist!
								# What's the impact on the model consistency:
								# should we go forward and Add the table or
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
    
    # Add products
    AddTable("products", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "category_id", :foreign_key ], 	# Inferred a link to "categories"
									# I need to undersdans how the fellowing
									# link has been inferred:
									# :from products :to categories :belongs_to
									# ~> I mean how this semantic relationship has
									# been programmatically inferred?
        [ "price", :decimal ],
        [ "active", :boolean]
    ])
    
    # Add tags for flexible categorization
    AddTable("tags", [
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

    # Explicit relationships Addd
    ? @@NL( Relationships() )

}
#-->
'
[
	[
		[ "type", "belongs_to" ],
		[ "from", "products" ],
		[ "to", "categories" ],
		[ "field", "category_id" ],
		[ "inferred", 1 ]
	],
	[
		[ "type", "has_many" ],
		[ "from", "categories" ],
		[ "to", "products" ],
		[ "field", "category_id" ],
		[ "inferred", 1 ]
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
# Executed in 0.16 second(s) in Ring 1.22

/*---

# Problem: Social network with users, posts, follows, and likes
# Solution: Combine different relationship types for comprehensive modeling

pr()

o1 = new stzDataModel("social_network")
o1 {
    # Core entities
    AddTable("users", [
        [ "id", :primary_key ],
        [ "username", :unique ],
        [ "email", :email ],
        [ "profile_image", :url ]
    ])

    AddTable("posts", [
        [ "id", :primary_key ],
        [ "user_id", :foreign_key ],
        [ "content", :text ],
        [ "created_at", :timestamp ]
    ])

    AddTable("likes", [
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
		[ "type", "belongs_to" ],
		[ "from", "posts" ],
		[ "to", "users" ],
		[ "field", "user_id" ],
		[ "inferred", 1 ]
	],
	[
		[ "type", "has_many" ],
		[ "from", "users" ],
		[ "to", "posts" ],
		[ "field", "user_id" ],
		[ "inferred", 1 ]
	],
	[
		[ "type", "belongs_to" ],
		[ "from", "likes" ],
		[ "to", "users" ],
		[ "field", "user_id" ],
		[ "inferred", 1 ]
	],
	[
		[ "type", "has_many" ],
		[ "from", "users" ],
		[ "to", "likes" ],
		[ "field", "user_id" ],
		[ "inferred", 1 ]
	],
	[
		[ "type", "belongs_to" ],
		[ "from", "likes" ],
		[ "to", "posts" ],
		[ "field", "post_id" ],
		[ "inferred", 1 ]
	],
	[
		[ "type", "has_many" ],
		[ "from", "posts" ],
		[ "to", "likes" ],
		[ "field", "post_id" ],
		[ "inferred", 1 ]
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
# Executed in 0.15 second(s) in Ring 1.22

#================================#
#  SCHEMA EVOLUTION & MIGRATION  #
#================================#

/*--- Security: Prevent breaking changes via validation

pr()

o1 = new stzDataModel("inventory_system")
o1 {
    AddTable("categories", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "parent_id", :foreign_key ],
        [ "ref", :unique ]
    ])

    AddTable("products", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "category_id", :foreign_key ],
        [ "price", :decimal ],
        [ "active", :boolean ]
    ])

    AddTable("tags", [
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
#-->
'
Impact analysis for adding "description" field:
[
	[ "breaking_changes", 0 ],
	[ "perf_impact", "low" ],
	[ "migration_complexity", "simple" ],
	[ "affected_relationships", [  ] ],
	[
		"recommendations",
		[
			"Large text fields may impact query performance"
		]
	],
	[
		"field_info",
		[
			[ "table", "products" ],
			[ "field", "description" ],
			[ "type", "text" ]
		]
	]
]

Breaking change prevented: Cannot remove field "category_id" - breaks relationships
'

pf()
# Executed in 0.16 second(s) in Ring 1.22

/*--- Version control for schema evolution

pr()

o1 = new stzDataModel([ "blog_platform", "2.1"])
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
        [ "view_count", "integer" ]  # Added in v2.1
    ])

    ? "Schema: " + SchemaName() + " v" + SchemaVersion() + nl

    ? Explain()
}
#--> #TODO Other then adding the version, the sample does not show how versioning
# of the data model is used (and useful) in practice:
'
Schema: blog_platform v2.1

This model contains 2 tables:
- authors: 4 fields, 2 relationships
- articles: 6 fields, 2 relationships

Key relationships:
- articles belongs_to authors
- authors has_many articles
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

#============================#
#  PERFORMANCE OPTIMIZATION  #
#============================#

/*--- Basic Data Model with Default Performance Plan

pr()

o1 = new stzDatabaseModel("blog_platform")
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

    # Set the default performance plan (already set by init)
    UsePerfPlan("default") # other plans include "web", "mobile", and "data_analytics"
    
    # Analyze performance

    ? BoxRound("Performance optimization hints (Default Plan)")
    ? @@NL( PerfHints() ) + NL
}
#-->
'
╭───────────────────────────────────────────────╮
│ Performance optimization hints (Default Plan) │
╰───────────────────────────────────────────────╯
[
	[
		[
			"message",
			"Consider adding index on articles.author_id"
		],
		[
			"action",
			"CREATE INDEX idx_articles_author_id ON articles(author_id)"
		]
	],
	[
		[
			"message",
			"Monitor N+1 queries for authors -> articles"
		],
		[
			"action",
			"Use eager loading for authors -> articles"
		]
	]
]
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

#=============================#
#  DEBUGGING & VISUALIZATION  #
#=============================#

/*--- Understanding your model structure

pr()

o1 = new stzDataModel("blog_platform")
o1 {
    AddTable("authors", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "email", :email ],
        [ "bio", :text]
    ])
    
    AddTable("articles", [
        [ "id", :primary_key ],
        [ "author_id", :foreign_key ],
        [ "title", :required ],
        [ "content", :text ],
        [ "published_at", :timestamp ],
        [ "view_count", "integer"]
    ])
    
    # Get comprehensive model explanation
	? BoxRound("Data Model : " + Name() + " (v" + Version() + ")")
    ? Explain()

}
'
╭───────────────────────────────────╮
│ Data Model : blog_platform (v1.0) │
╰───────────────────────────────────╯
This model contains 2 tables:
• authors: 4 fields, 2 relationships
• articles: 6 fields, 2 relationships

Key relationships:
• articles belongs_to authors
• authors has_many articles
'
pf()
# Executed in 0.06 second(s) in Ring 1.22


/*--- Diagram generation: for use wit hexternal tool to visualize the diagram

pr()

o1 = new stzDatabaseModel("blog_platform")
o1 {
    AddTable("authors", [
        [ "id", :primary_key ],
        [ "name", :required ],
        [ "email", :email ],
        [ "bio", :text]
    ])
    
    AddTable("articles", [
        [ "id", :primary_key ],
        [ "author_id", :foreign_key ],
        [ "title", :required ],
        [ "content", :text ],
        [ "published_at", :timestamp ],
        [ "view_count", "integer"]
    ])

    # Generate entity-relationship diagram script for the Mermaid online tool
	? BoxRound("DDL SCRIPT")
    ? ToDDL() + NL
	#-->
"
╭────────────╮
│ DDL SCRIPT │
╰────────────╯
CREATE TABLE authors (
    id INTEGER PRIMARY KEY,
    id INTEGER PRIMARY KEY NOT NULL,
    id INTEGER PRIMARY KEY,
    id INTEGER PRIMARY KEY
);

CREATE TABLE articles (
    author_id TEXT,
    author_id TEXT,
    author_id TEXT NOT NULL,
    author_id TEXT,
    author_id TEXT,
    author_id TEXT
);

ALTER TABLE authors ADD CONSTRAINT authors_email_check CHECK (email LIKE '%@%');
"

	? BoxRound("MermaidERD Tool Script")
	? ToMermaidERD() + NL
#-->
'
╭────────────────────────╮
│ MermaidERD Tool Script │
╰────────────────────────╯
erDiagram
    authors {
        primary_key id
        required name
        email email
        text bio
    }

    articles {
        primary_key id
        foreign_key author_id FK
        required title
        text content
        timestamp published_at
        integer view_count
    }

    articles ||--o{ authors : "belongs to"
    authors ||--o{ articles : "has"
'
	? BoxRound("PlantUmlERD Tool Script")
	? ToPlantUmlERD() + NL
#-->
'
╭─────────────────────────╮
│ PlantUmlERD Tool Script │
╰─────────────────────────╯
@startuml
!define ENTITY class

ENTITY authors {
  id : primary_key
  name : required
  email : email
  bio : text
}

ENTITY articles {
  id : primary_key
  author_id : foreign_key <<FK>>
  title : required
  content : text
  published_at : timestamp
  view_count : integer
}

articles ||--o{ authors
authors ||--o{ articles
@enduml
'
	? BoxRound("JSON Diagram Data (other tools)")
	? ToJsonERD()
#-->
'
╭─────────────────────────────────╮
│ JSON Diagram Data (other tools) │
╰─────────────────────────────────╯
{
	"tables": [
		{
			"name": "authors",
			"fields": [
				{
					"name": "id",
					"type": "primary_key"
				},
				{
					"name": "name",
					"type": "required"
				},
				{
					"name": "email",
					"type": "email"
				},
				{
					"name": "bio",
					"type": "text"
				}
			],
			"constraints": [
				{
					"field": "id",
					"type": "primary_key",
					"constraint": "PRIMARY KEY"
				},
				{
					"field": "name",
					"type": "not_null",
					"constraint": "NOT NULL"
				},
				{
					"field": "email",
					"type": "check",
					"constraint": "CHECK (email LIKE `%@%`)"
				}
			]
		},
		{
			"name": "articles",
			"fields": [
				{
					"name": "id",
					"type": "primary_key"
				},
				{
					"name": "author_id",
					"type": "foreign_key"
				},
				{
					"name": "title",
					"type": "required"
				},
				{
					"name": "content",
					"type": "text"
				},
				{
					"name": "published_at",
					"type": "timestamp"
				},
				{
					"name": "view_count",
					"type": "integer"
				}
			],
			"constraints": [
			]
		}
	],
	"relationships": [
		{
			"from_table": "",
			"from_field": "",
			"to_table": "",
			"to_field": ""
		},
		{
			"from_table": "",
			"from_field": "",
			"to_table": "",
			"to_field": ""
		}
	]
}
'

    # Generate entity-relationship diagram script for the Mermaid online tool
	? BoxRound("DBML SCRIPT")
    ? ToDBML()
	#-->
"
Project blog_platform {
  database_type: 'Generic'
  Note: 'Generated from stzDataModel'
}

Table authors {
  id primary_key
  name required
  email email
  bio text
}

Table articles {
  id primary_key
  author_id foreign_key
  title required
  content text
  published_at timestamp
  view_count int
}

Ref: articles.author_id > authors.id
"

}

#NOTE Go to https://www.mermaidchart.com/ and paste the script in the editor to see the diagram
# Do the same with the other formats

pf()
# Executed in 0.32 second(s) in Ring 1.22

/*=== Importing a DDL definition script
*/
pr()

cMyDDL = "
CREATE TABLE authors (
    id INTEGER PRIMARY KEY,
	name TEXT REQUIRED,
	email EMAIL,
	bio TEXT
);

CREATE TABLE articles (
    author_id TEXT FOREIGN KEY,
	title TEXT REQUIRED,
    content TEXT NOT NULL,
    published_at TIMESTAMP,
    view_count INTEGER
);

ALTER TABLE authors ADD CONSTRAINT authors_email_check CHECK (email LIKE " + SingleQuote() + "%@%" + SingleQuote() + ");
"

o1 = new stzDatabaseModel("imported_schema")
o1.FromDDL(cMyDDL)
? @@NL( o1.Summary() )
#-->
'
[
	[ "name", "imported_schema" ],
	[ "version", "1.0" ],
	[ "tablescount", 2 ],
	[
		"tables",
		[
			[
				[
					"authors",
					[
						[ "fieldscount", 4 ],
						[ "relationscount", 2 ]
					]
				]
			],
			[
				[
					"articles",
					[
						[ "fieldscount", 5 ],
						[ "relationscount", 2 ]
					]
				]
			]
		]
	]
]
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Importing a MermaidERD diagram

pr()

cMyMermaid = '
erDiagram
    authors {
        primary_key id
        required name
        email email
        text bio
    }

    articles {
        primary_key id
        foreign_key author_id FK
        required title
        text content
        timestamp published_at
        integer view_count
    }

    articles ||--o{ authors : "belongs to"
    authors ||--o{ articles : "has"
'

o1 = new stzDatabaseModel("imported_schema")
o1.FromMermaid(cMyMermaid)

? @@NL( o1.Summary() )
#-->
'
[
	[ "name", "imported_schema" ],
	[ "version", "1.0" ],
	[ "tablescount", 2 ],
	[
		"tables",
		[
			[
				[
					"authors",
					[
						[ "fieldscount", 4 ],
						[ "relationscount", 2 ]
					]
				]
			],
			[
				[
					"articles",
					[
						[ "fieldscount", 6 ],
						[ "relationscount", 2 ]
					]
				]
			]
		]
	]
]
'

pf()
# Executed in 0.03 second(s) in Ring 1.22


#==================================#
#  ADVANCED VALIDATION AND EXPORY  #
#==================================#

/*--- Field-level validation and constraints

pr()

o1 = new stzDatabaseModel("user_management")
o1 {
    AddTable("users", [
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
    ? BoxRound("Validation result")
    ? @@NL( validation ) + NL

	? BoxRound("DDL script")
	? ToDDL()

	#NOTE //Data definition language (DDL) describes the portion
	# of SQL that creates, alters, and deletes database objects.

}
#-->
'
╭───────────────────╮
│ Validation result │
╰───────────────────╯
[
	[ "valid", 1 ],
	[ "errors", [  ] ],
	[ "error_count", 0 ],
	[ "tables_validated", 1 ]
]
'
"
╭────────────╮
│ DDL script │
╰────────────╯
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username VARCHAR(255) NOT NULL NOT NULL,
    email VARCHAR(255),
    age INTEGER,
    status VARCHAR(20)
);

ALTER TABLE users ADD CONSTRAINT users_email_check CHECK (email LIKE '%@%');
ALTER TABLE users ADD CONSTRAINT users_age_check CHECK (age >= 18 AND age <= 120);
ALTER TABLE users ADD CONSTRAINT users_status_check CHECK (status IN ('active', 'inactive', 'suspended'));
"

pf()
# Executed in 0.02 second(s) in Ring 1.22

#================================#
#  REAL-WORLD WORKFLOW PATTERNS  #
#================================#

/*--- Complete e-commerce system with all relationship types

pr()

o1 = new stzDataModel([ "ecommerce_complete", "3.0"])
o1 {
    # Customer management with hierarchy
    AddTable("customers", [
        [ "id", :primary_key ],
        [ "parent_id", :foreign_key ],      # For B2B hierarchies
        [ "name", :required ],
        [ "email", :email ],
        [ "type", "varchar(20)"]           	# individual, business
    ])
    
    # Product catalog with categories
    AddTable("categories", [
        [ "id", :primary_key ],
        [ "parent_id", :foreign_key ],
        [ "name", :required ],
        [ "path", "varchar(500)"]
    ])
    
    AddTable("products", [
        [ "id", :primary_key ],
        [ "category_id", :foreign_key ],
        [ "name", :required ],
        [ "price", :decimal ],
        [ "inventory_count", "integer"]
    ])
    
    # Order processing
    AddTable("orders", [
        [ "id", :primary_key ],
        [ "customer_id", :foreign_key ],
        [ "status", "varchar(50)" ],
        [ "total", :decimal ],
        [ "created_at", :timestamp]
    ])
    
    AddTable("order_items", [
        [ "id", :primary_key ],
        [ "order_id", :foreign_key ],
        [ "product_id", :foreign_key ],
        [ "quantity", "integer" ],
        [ "unit_price", :decimal]
    ])
    
    # Add explicit relationships
    Hierarchy("customers", [:parent_field = "parent_id"])     # B2B customer hierarchies
    Hierarchy("categories", [:parent_field = "parent_id"])    # Product categories
    Link("orders", "products", "many_to_many", [:via = "order_items"])
    
    # Comprehensive explanation

    ? BoxRound("Complete e-commerce model")
    ? Explain() + NL
    
	# Detailed validation

    ? BoxRound("Validation result:")
    ? @@NL( Validate() )

}
#-->
'
╭───────────────────────────╮
│ Complete e-commerce model │
╰───────────────────────────╯
This model contains 5 tables:
• customers: 5 fields, 3 relationships
• categories: 4 fields, 3 relationships
• products: 5 fields, 5 relationships
• orders: 5 fields, 5 relationships
• order_items: 5 fields, 4 relationships

Key relationships:
• products belongs_to categories
• categories has_many products
• orders belongs_to customers
• customers has_many orders
• order_items belongs_to orders
• orders has_many order_items
• order_items belongs_to products
• products has_many order_items
• customers hierarchy customers
• categories hierarchy categories
• orders many_to_many products


╭────────────────────╮
│ Validation result: │
╰────────────────────╯
[
	[ "valid", 1 ],
	[ "errors", [  ] ],
	[ "error_count", 0 ],
	[ "tables_validated", 5 ]
]
'
pf()
# Executed in 0.41 second(s) in Ring 1.22

/*--- Migration workflow for production systems

pr()

o1 = new stzDatabaseModel([ "ecommerce_complete", "3.0"])
o1 {
    AddTable("customers", [
        [ "id", :primary_key ],
        [ "parent_id", :foreign_key ],
        [ "name", :required ],
        [ "email", :email ],
        [ "type", "varchar(20)"]
    ])
    
    AddTable("categories", [
        [ "id", :primary_key ],
        [ "parent_id", :foreign_key ],
        [ "name", :required ],
        [ "path", "varchar(500)"]
    ])
    
    AddTable("products", [
        [ "id", :primary_key ],
        [ "category_id", :foreign_key ],
        [ "name", :required ],
        [ "price", :decimal ],
        [ "inventory_count", "integer"]
    ])
    
    AddTable("orders", [
        [ "id", :primary_key ],
        [ "customer_id", :foreign_key ],
        [ "status", "varchar(50)" ],
        [ "total", :decimal ],
        [ "created_at", :timestamp]
    ])
    
    AddTable("order_items", [
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

    ? BoxRound("Current state")
    ? Explain() + nl
    
    # Stage 2: Impact analysis for new field
    impact = AddField("customers", "preferences", :text, [:nullable = true])
    ? BoxRound("Migration impact analysis")
    ? @@NL( impact ) + NL
    
    # Stage 3: Performance analysis

    ? BoxRound("Performance analysis")
    ? @@NL( PerfHints() ) + NL
    
    # Stage 4: Final validation

    ? BoxRound("Final validation")
    ? @@NL( Validate() )
}
#-->
'
╭───────────────╮
│ Current state │
╰───────────────╯
This model contains 5 tables:
• customers: 5 fields, 5 relationships
• categories: 4 fields, 5 relationships
• products: 5 fields, 9 relationships
• orders: 5 fields, 9 relationships
• order_items: 5 fields, 8 relationships

Key relationships:
• products belongs_to categories
• categories has_many products
• products belongs_to categories
• categories has_many products
• orders belongs_to customers
• customers has_many orders
• orders belongs_to customers
• customers has_many orders
• order_items belongs_to orders
• orders has_many order_items
• order_items belongs_to products
• products has_many order_items
• order_items belongs_to orders
• orders has_many order_items
• order_items belongs_to products
• products has_many order_items
• customers hierarchy customers
• categories hierarchy categories
• orders many_to_many products


╭───────────────────────────╮
│ Migration impact analysis │
╰───────────────────────────╯
[
	[ "breaking_changes", 0 ],
	[ "perf_impact", "low" ],
	[ "migration_complexity", "simple" ],
	[ "affected_relationships", [  ] ],
	[
		"recommendations",
		[
			"Large text fields may impact query performance"
		]
	],
	[
		"field_info",
		[
			[ "table", "customers" ],
			[ "field", "preferences" ],
			[ "type", "text" ]
		]
	]
]

╭──────────────────────╮
│ Performance analysis │
╰──────────────────────╯
[
	[
		[
			"message",
			"Consider adding index on products.category_id"
		],
		[
			"action",
			"CREATE INDEX idx_products_category_id ON products(category_id)"
		]
	],
	[
		[
			"message",
			"Consider adding index on orders.customer_id"
		],
		[
			"action",
			"CREATE INDEX idx_orders_customer_id ON orders(customer_id)"
		]
	],
	[
		[
			"message",
			"Consider adding index on order_items.order_id"
		],
		[
			"action",
			"CREATE INDEX idx_order_items_order_id ON order_items(order_id)"
		]
	],
	[
		[
			"message",
			"Consider adding index on order_items.product_id"
		],
		[
			"action",
			"CREATE INDEX idx_order_items_product_id ON order_items(product_id)"
		]
	],
	[
		[
			"message",
			"Monitor N+1 queries for categories -> products"
		],
		[
			"action",
			"Use eager loading for categories -> products"
		]
	],
	[
		[
			"message",
			"Monitor N+1 queries for customers -> orders"
		],
		[
			"action",
			"Use eager loading for customers -> orders"
		]
	],
	[
		[
			"message",
			"Monitor N+1 queries for orders -> order_items"
		],
		[
			"action",
			"Use eager loading for orders -> order_items"
		]
	],
	[
		[
			"message",
			"Monitor N+1 queries for products -> order_items"
		],
		[
			"action",
			"Use eager loading for products -> order_items"
		]
	]
]

╭──────────────────╮
│ Final validation │
╰──────────────────╯
[
	[ "valid", 1 ],
	[ "errors", [  ] ],
	[ "error_count", 0 ],
	[ "tables_validated", 5 ]
]
'

pf()
# Executed in 0.70 second(s) in Ring 1.22

#=== #TODO

//Test AnalyzeFieldAdditionImpact and other untesed methods

#=============================================#
#  AUTOMATIC DATA MODEL VALIDATION (3 MODES)  #
#=============================================#


/*--- Validation the data model with STRICT mode

pr()

# Create model with strict validation
o1 = new stzDataModel("StrictModel")
o1 {
	SetValidationMode("strict")

	# Add problematic data to test validation
	o1.AddTable("", [['id', 'integer']])  # Empty table name
	o1.AddTable("users", [["name", "text"], ["name", "text"]])  # Duplicate field
	
	# Validate the model in the strict mode
	? BoxRound("Active Validation Mode")
	? ValidationMode() + NL

	# A summary of the validation
	? BoxRound("How Many Errors and Warnings")
	? @@NL( Validate() ) + NL

	# Detailed info about the validation
	? BoxRound("Detailed Errors and Warnings")
	? @@NL( ValidateXT() ) + NL

	? BoxRound("Only Errors")
	? @@NL( Errors() ) + NL

	? BoxRound("Only Warnings")
	? @@NL( Warnings() )
}
#-->
'
╭────────────────────────╮
│ Active Validation Mode │
╰────────────────────────╯
strict

╭──────────────────────────────╮
│ How Many Errors and Warnings │
╰──────────────────────────────╯
[
	[ "errors_count", 2 ],
	[ "warnings_count", 0 ]
]

╭──────────────────────────────╮
│ Detailed Errors and Warnings │
╰──────────────────────────────╯
[
	[
		[ "type", "table" ],
		[ "severity", "error" ],
		[ "message", "Table has no name" ]
	],
	[
		[ "type", "field" ],
		[ "severity", "error" ],
		[ "message", "Duplicate field: name" ]
	]
]

╭─────────────╮
│ Only Errors │
╰─────────────╯
[
	[
		[ "type", "table" ],
		[ "severity", "error" ],
		[ "message", "Table has no name" ]
	],
	[
		[ "type", "field" ],
		[ "severity", "error" ],
		[ "message", "Duplicate field: name" ]
	]
]

╭───────────────╮
│ Only Warnings │
╰───────────────╯
[ ]
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Validation the data model with WARNING mode

pr()

o1 = new stzDataModel("WarningModel")
o1 {
	SetValidationMode("warning")

	# Adding a table with an invalid empty name
	AddTable('', [["id", "integer"]])

	# Adding a table with a dublicated field
	AddTable("users", [["name", "text"], ["name", "text"]])

	# Validate the model in the Warning mode
	? BoxRound("Active Validation Mode")
	? ValidationMode() + NL

	# A summary of the validation
	? BoxRound("How Many Errors and Warnings")
	? @@NL( Validate() ) + NL

	# Detailed info about the validation
	? BoxRound("Detailed Errors and Warnings")
	? @@NL( ValidateXT() ) + NL

	? BoxRound("Only Errors")
	? @@NL( Errors() ) + NL

	? BoxRound("Only Warnings")
	? @@NL( Warnings() )

}
#-->
'
╭────────────────────────╮
│ Active Validation Mode │
╰────────────────────────╯
warning

╭──────────────────────────────╮
│ How Many Errors and Warnings │
╰──────────────────────────────╯
[
	[ "errors_count", 1 ],
	[ "warnings_count", 1 ]
]

╭──────────────────────────────╮
│ Detailed Errors and Warnings │
╰──────────────────────────────╯
[
	[
		[ "type", "table" ],
		[ "severity", "warning" ],
		[ "message", "Table has no name" ]
	],
	[
		[ "type", "field" ],
		[ "severity", "error" ],
		[ "message", "Duplicate field: name" ]
	]
]

╭─────────────╮
│ Only Errors │
╰─────────────╯
[
	[
		[ "type", "field" ],
		[ "severity", "error" ],
		[ "message", "Duplicate field: name" ]
	]
]

╭───────────────╮
│ Only Warnings │
╰───────────────╯
[
	[
		[ "type", "table" ],
		[ "severity", "warning" ],
		[ "message", "Table has no name" ]
	]
]
'

pf()
# Executed in 0.04 second(s) in Ring 1.22


/*--- Validation the data model with PERMISSIVE mode
*/
pr()

o1 = new stzDataModel("PermissiveModel")
o1 {
	SetValidationMode("permissive")

	AddTable("", [["id", "integer"]])  # Will be auto-fixed
	AddTable("users", [["email", "text"]])

	# Setting the model validation on the PERMISSIVE mode
	? ValidationMode()
	#--> permissive

	# Tables names before validation
	? @@( TablesNames() ) + NL
	#--> [ "", "users" ]

	# Performing the validation (no errors nor warnings are raised)
	? @@( Validate() ) + NL
	#--> [ [ "errors_count", 0 ], [ "warnings_count", 0 ] ]

	# Tables names after validation (autofixed due to PERMISSIVE mode)

	? @@( TablesNames() )
	#--> [ "unnamed_table_2", "users" ]

}

#TODO Add more interesting configurable autofixes plans

pf()
# Executed in almost 0 second(s) in Ring 1.22


# ===========================================
# 2. RELATIONSHIP METADATA EXAMPLE
# ===========================================

? "\n=== RELATIONSHIP METADATA DEMO ==="

# Create a social media model with rich metadata
social = new stzDataModel("SocialMediaPlatform")
social.SetValidationMode("warning")

# Add tables
social.AddTable("users", [
    ["id", "integer"],
    ["username", "text"],
    ["email", "text"],
    ["created_at", "datetime"]
])

social.AddTable("posts", [
    ["id", "integer"],
    ["user_id", "integer"],
    ["content", "text"],
    ["created_at", "datetime"]
])

social.AddTable("likes", [
    ["id", "integer"],
    ["user_id", "integer"],
    ["post_id", "integer"],
    ["created_at", "datetime"]
])

social.AddTable("follows", [
    ["id", "integer"],
    ["follower_id", "integer"],
    ["followed_id", "integer"],
    ["created_at", "datetime"]
])

# Add relationships with rich metadata
social.Link("posts", "users", "belongs_to", [
    :via = "user_id",
    :semantic = "Each post belongs to exactly one user",
    :business_rule = "Posts cannot exist without a valid user"
])

social.Link("users", "posts", "has_many", [
    :via = "user_id",
    :semantic = "Users can create multiple posts",
    :business_rule = "Users can have unlimited posts"
])

social.Link("users", "likes", "many_to_many", [
    :via = "likes",
    :semantic = "Users can like multiple posts, posts can be liked by multiple users",
    :business_rule = "Users cannot like their own posts"
])

social.Link("users", "follows", "many_to_many", [
    :via = "follows",
    :semantic = "Users can follow other users bidirectionally",
    :business_rule = "Users cannot follow themselves"
])

? "Social media model created with rich relationship metadata"
? "Validation: " + social.ValidationSummary()

# ===========================================
# 3. TEMPLATE SYSTEM EXAMPLE
# ===========================================

? "\n=== TEMPLATE SYSTEM DEMO ==="

# E-commerce template
? "Creating e-commerce model from template..."
ecommerce = new stzDataModel("EcommerceStore")
ecommerce.UseTemplate("ecommerce_basic")
ecommerce.SetValidationMode("strict")

? "E-commerce template loaded"
? "Validation: " + ecommerce.ValidationSummary()

# Social network template
? "\nCreating social network model from template..."
social_net = new stzDataModel("SocialNetwork")
social_net.UseTemplate("social_network")
social_net.SetValidationMode("warning")

? "Social network template loaded"
? "Validation: " + social_net.ValidationSummary()

# Blog platform template
? "\nCreating blog platform model from template..."
blog = new stzDataModel("BlogPlatform")
blog.UseTemplate("blog_platform")
blog.SetValidationMode("permissive")

? "Blog platform template loaded"
? "Validation: " + blog.ValidationSummary()

# ===========================================
# 4. ADVANCED COMBINATION EXAMPLE
# ===========================================

? "\n=== ADVANCED COMBINATION DEMO ==="

# Start with template and customize
advanced = new stzDataModel("AdvancedEcommerce")
advanced.SetValidationMode("strict")
advanced.UseTemplate("ecommerce_basic")

# Add custom fields to existing tables
advanced.AddField("customers", "email", "text", [:required = true])
advanced.AddField("customers", "phone", "text", [:optional = true])
advanced.AddField("products", "price", "decimal", [:required = true, :min = 0])
advanced.AddField("products", "category_id", "integer", [:foreign_key = "categories"])

# Add new tables
advanced.AddTable("categories", [
    ["id", "integer"],
    ["name", "text"],
    ["description", "text"]
])

advanced.AddTable("order_items", [
    ["id", "integer"],
    ["order_id", "integer"],
    ["product_id", "integer"],
    ["quantity", "integer"],
    ["unit_price", "decimal"]
])

# Add relationships with metadata
advanced.Link("products", "categories", "belongs_to", [
    :via = "category_id",
    :semantic = "Products are organized into categories",
    :business_rule = "All products must belong to a category"
])

advanced.Link("orders", "order_items", "has_many", [
    :via = "order_id",
    :semantic = "Orders contain multiple line items",
    :business_rule = "Orders must have at least one item"
])

advanced.Link("order_items", "products", "belongs_to", [
    :via = "product_id",
    :semantic = "Each order item references a specific product",
    :business_rule = "Order items must reference valid products"
])

? "Advanced e-commerce model created"
? "Final validation: " + advanced.ValidationSummary()

# ===========================================
# 5. ERROR HANDLING EXAMPLE
# ===========================================

? "\n=== ERROR HANDLING DEMO ==="

error_model = new stzDataModel("ErrorDemo")

# Try invalid validation mode
try
    error_model.SetValidationMode("invalid_mode")
catch
    ? "✓ Caught invalid validation mode error"
done

# Try unknown template
try
    error_model.UseTemplate("nonexistent_template")
catch
    ? "✓ Caught unknown template error"
done

# Try accessing non-existent table
try
    error_model.Table("nonexistent_table")
catch
    ? "✓ Caught table not found error"
done

? "\nAll examples completed successfully!"

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
# • AddTable(): Basic schema definition with smart defaults
# • Link(): Complex relationships that can't be auto-inferred  
# • Hierarchy(): Parent-child trees (categories, org charts)
# • Network(): Peer-to-peer connections (social networks, graphs)
# • Validate(): Before any production deployment or major change
# • PerfHints(): When queries become slow
# • Explain(): When debugging complex models or onboarding new developers
# • GetERDData(): When generating documentation or visual diagrams
