
# A data file loaded before stzDataModeld is used
# Contains a reference database of data model templates, and
# help strings to use with Help() global functions

#===============================================================#
#   DATAPHORE TEMPLATE SYSTEM REFERENCE ($aDataModelTemplates)  #
#===============================================================#

# This container provides pre-built data model templates for common
# business domains. Templates follow a structured format with tables
# and relations arrays for rapid prototyping.

# USAGE:
#   oModel.UseTemplate("ecommerce_basic")
#
# STRUCTURE:
#   Each template contains:
#   - "tables": [ [name, [columns]], ... ]
#   - "relations": [ [from_table, [to_table, type, options]], ... ]
#
# AVAILABLE THEMES:
#   • E-commerce (basic, advanced)			• Healthcare (medical records)
#   • Social Networks (basic, extended)		• Real Estate (property mgmt)
#   • Blogs & CMS (platform, cms)			• Restaurant (POS systems)
#   • Project Management					• Event Management
#   • Learning Management (LMS)				• HR Management
#   • Financial (accounting, expense)		• Logistics & Shipping
#   • Data Analytics (6 specialized types)	• Sports Management
#											• Hotel Booking

# EXTENDING:
#   - Add new templates by following the existing structure pattern.
#   - Use consistent naming: domain_variant (e.g., "retail_basic", "retail_advanced")
#   - Include realistic field types and proper foreign key relationships.

$aDataModelTemplates = [
    # E-COMMERCE TEMPLATES
    [
        "ecommerce_basic",
        [
            [ "tables", [
                [ "customers", [ ["id", "integer"], ["name", "text"], ["email", "text"] ] ],
                [ "orders", [ ["id", "integer"], ["customer_id", "integer"], ["total", "decimal"] ] ],
                [ "products", [ ["id", "integer"], ["name", "text"], ["price", "decimal"] ] ]
            ]],
            [ "relations", [
                [ "orders", [ "customers", "belongs_to", [] ] ],
                [ "orders", [ "products", "has_many", [] ] ]
            ]]
        ]
    ],

    [
        "ecommerce_advanced",
        [
            [ "tables", [
                [ "customers", [ ["id", "integer"], ["name", "text"], ["email", "text"], ["address", "text"] ] ],
                [ "orders", [ ["id", "integer"], ["customer_id", "integer"], ["status", "text"], ["total", "decimal"] ] ],
                [ "products", [ ["id", "integer"], ["name", "text"], ["price", "decimal"], ["category_id", "integer"] ] ],
                [ "categories", [ ["id", "integer"], ["name", "text"], ["description", "text"] ] ],
                [ "order_items", [ ["id", "integer"], ["order_id", "integer"], ["product_id", "integer"], ["quantity", "integer"] ] ]
            ]],
            [ "relations", [
                [ "orders", [ "customers", "belongs_to", [] ] ],
                [ "order_items", [ "orders", "belongs_to", [] ] ],
                [ "order_items", [ "products", "belongs_to", [] ] ],
                [ "products", [ "categories", "belongs_to", [] ] ]
            ]]
        ]
    ],

    # SOCIAL NETWORK TEMPLATES
    [
        "social_network",
        [
            [ "tables", [
                [ "users", [ ["id", "integer"], ["username", "text"], ["email", "text"] ] ],
                [ "posts", [ ["id", "integer"], ["user_id", "integer"], ["content", "text"] ] ],
                [ "follows", [ ["follower_id", "integer"], ["followed_id", "integer"] ] ]
            ]],
            [ "relations", [
                [ "posts", [ "users", "belongs_to", [] ] ],
                [ "users", [ "follows", "many_to_many", [ :via = "follows" ] ] ]
            ]]
        ]
    ],

    [
        "social_network_extended",
        [
            [ "tables", [
                [ "users", [ ["id", "integer"], ["username", "text"], ["email", "text"], ["bio", "text"] ] ],
                [ "posts", [ ["id", "integer"], ["user_id", "integer"], ["content", "text"], ["created_at", "datetime"] ] ],
                [ "follows", [ ["follower_id", "integer"], ["followed_id", "integer"], ["created_at", "datetime"] ] ],
                [ "likes", [ ["id", "integer"], ["user_id", "integer"], ["post_id", "integer"] ] ],
                [ "comments", [ ["id", "integer"], ["user_id", "integer"], ["post_id", "integer"], ["content", "text"] ] ]
            ]],
            [ "relations", [
                [ "posts", [ "users", "belongs_to", [] ] ],
                [ "likes", [ "users", "belongs_to", [] ] ],
                [ "likes", [ "posts", "belongs_to", [] ] ],
                [ "comments", [ "users", "belongs_to", [] ] ],
                [ "comments", [ "posts", "belongs_to", [] ] ],
                [ "users", [ "follows", "many_to_many", [ :via = "follows" ] ] ]
            ]]
        ]
    ],

    # BLOG TEMPLATES
    [
        "blog_platform",
        [
            [ "tables", [
                [ "authors", [ ["id", "integer"], ["name", "text"], ["email", "text"] ] ],
                [ "articles", [ ["id", "integer"], ["author_id", "integer"], ["title", "text"], ["content", "text"] ] ],
                [ "categories", [ ["id", "integer"], ["name", "text"], ["description", "text"] ] ]
            ]],
            [ "relations", [
                [ "articles", [ "authors", "belongs_to", [] ] ],
                [ "articles", [ "categories", "has_many", [] ] ]
            ]]
        ]
    ],

    [
        "blog_cms",
        [
            [ "tables", [
                [ "authors", [ ["id", "integer"], ["name", "text"], ["email", "text"], ["role", "text"] ] ],
                [ "articles", [ ["id", "integer"], ["author_id", "integer"], ["title", "text"], ["content", "text"], ["status", "text"] ] ],
                [ "categories", [ ["id", "integer"], ["name", "text"], ["description", "text"] ] ],
                [ "tags", [ ["id", "integer"], ["name", "text"] ] ],
                [ "article_tags", [ ["article_id", "integer"], ["tag_id", "integer"] ] ]
            ]],
            [ "relations", [
                [ "articles", [ "authors", "belongs_to", [] ] ],
                [ "articles", [ "categories", "belongs_to", [] ] ],
                [ "article_tags", [ "articles", "belongs_to", [] ] ],
                [ "article_tags", [ "tags", "belongs_to", [] ] ]
            ]]
        ]
    ],

    # PROJECT MANAGEMENT TEMPLATES
    [
        "project_management",
        [
            [ "tables", [
                [ "projects", [ ["id", "integer"], ["name", "text"], ["description", "text"], ["status", "text"] ] ],
                [ "tasks", [ ["id", "integer"], ["project_id", "integer"], ["title", "text"], ["status", "text"] ] ],
                [ "users", [ ["id", "integer"], ["name", "text"], ["email", "text"], ["role", "text"] ] ],
                [ "assignments", [ ["task_id", "integer"], ["user_id", "integer"], ["assigned_at", "datetime"] ] ]
            ]],
            [ "relations", [
                [ "tasks", [ "projects", "belongs_to", [] ] ],
                [ "assignments", [ "tasks", "belongs_to", [] ] ],
                [ "assignments", [ "users", "belongs_to", [] ] ]
            ]]
        ]
    ],

    # LEARNING MANAGEMENT TEMPLATES
    [
        "lms_basic",
        [
            [ "tables", [
                [ "students", [ ["id", "integer"], ["name", "text"], ["email", "text"] ] ],
                [ "courses", [ ["id", "integer"], ["title", "text"], ["description", "text"] ] ],
                [ "enrollments", [ ["student_id", "integer"], ["course_id", "integer"], ["enrolled_at", "datetime"] ] ],
                [ "lessons", [ ["id", "integer"], ["course_id", "integer"], ["title", "text"], ["content", "text"] ] ]
            ]],
            [ "relations", [
                [ "enrollments", [ "students", "belongs_to", [] ] ],
                [ "enrollments", [ "courses", "belongs_to", [] ] ],
                [ "lessons", [ "courses", "belongs_to", [] ] ]
            ]]
        ]
    ],

    # INVENTORY MANAGEMENT TEMPLATES
    [
        "inventory_basic",
        [
            [ "tables", [
                [ "products", [ ["id", "integer"], ["name", "text"], ["sku", "text"], ["quantity", "integer"] ] ],
                [ "suppliers", [ ["id", "integer"], ["name", "text"], ["contact", "text"] ] ],
                [ "warehouses", [ ["id", "integer"], ["name", "text"], ["location", "text"] ] ],
                [ "stock_movements", [ ["id", "integer"], ["product_id", "integer"], ["warehouse_id", "integer"], ["quantity", "integer"] ] ]
            ]],
            [ "relations", [
                [ "products", [ "suppliers", "belongs_to", [] ] ],
                [ "stock_movements", [ "products", "belongs_to", [] ] ],
                [ "stock_movements", [ "warehouses", "belongs_to", [] ] ]
            ]]
        ]
    ],

    # FINANCIAL MANAGEMENT TEMPLATES
    [
        "accounting_basic",
        [
            [ "tables", [
                [ "accounts", [ ["id", "integer"], ["name", "text"], ["type", "text"], ["balance", "decimal"] ] ],
                [ "transactions", [ ["id", "integer"], ["date", "date"], ["amount", "decimal"], ["description", "text"] ] ],
                [ "journal_entries", [ ["id", "integer"], ["transaction_id", "integer"], ["account_id", "integer"], ["debit", "decimal"], ["credit", "decimal"] ] ]
            ]],
            [ "relations", [
                [ "journal_entries", [ "transactions", "belongs_to", [] ] ],
                [ "journal_entries", [ "accounts", "belongs_to", [] ] ]
            ]]
        ]
    ],

    [
        "expense_tracker",
        [
            [ "tables", [
                [ "users", [ ["id", "integer"], ["name", "text"], ["email", "text"] ] ],
                [ "categories", [ ["id", "integer"], ["name", "text"], ["type", "text"] ] ],
                [ "expenses", [ ["id", "integer"], ["user_id", "integer"], ["category_id", "integer"], ["amount", "decimal"], ["date", "date"] ] ],
                [ "budgets", [ ["id", "integer"], ["user_id", "integer"], ["category_id", "integer"], ["limit", "decimal"], ["period", "text"] ] ]
            ]],
            [ "relations", [
                [ "expenses", [ "users", "belongs_to", [] ] ],
                [ "expenses", [ "categories", "belongs_to", [] ] ],
                [ "budgets", [ "users", "belongs_to", [] ] ],
                [ "budgets", [ "categories", "belongs_to", [] ] ]
            ]]
        ]
    ],

    # HEALTHCARE TEMPLATES
    [
        "medical_records",
        [
            [ "tables", [
                [ "patients", [ ["id", "integer"], ["name", "text"], ["dob", "date"], ["phone", "text"] ] ],
                [ "doctors", [ ["id", "integer"], ["name", "text"], ["specialty", "text"], ["license", "text"] ] ],
                [ "appointments", [ ["id", "integer"], ["patient_id", "integer"], ["doctor_id", "integer"], ["date", "datetime"], ["status", "text"] ] ],
                [ "medical_records", [ ["id", "integer"], ["patient_id", "integer"], ["doctor_id", "integer"], ["diagnosis", "text"], ["treatment", "text"] ] ]
            ]],
            [ "relations", [
                [ "appointments", [ "patients", "belongs_to", [] ] ],
                [ "appointments", [ "doctors", "belongs_to", [] ] ],
                [ "medical_records", [ "patients", "belongs_to", [] ] ],
                [ "medical_records", [ "doctors", "belongs_to", [] ] ]
            ]]
        ]
    ],

    # REAL ESTATE TEMPLATES
    [
        "property_management",
        [
            [ "tables", [
                [ "properties", [ ["id", "integer"], ["address", "text"], ["type", "text"], ["price", "decimal"], ["status", "text"] ] ],
                [ "owners", [ ["id", "integer"], ["name", "text"], ["contact", "text"] ] ],
                [ "tenants", [ ["id", "integer"], ["name", "text"], ["contact", "text"] ] ],
                [ "leases", [ ["id", "integer"], ["property_id", "integer"], ["tenant_id", "integer"], ["start_date", "date"], ["end_date", "date"] ] ],
                [ "maintenance_requests", [ ["id", "integer"], ["property_id", "integer"], ["description", "text"], ["status", "text"] ] ]
            ]],
            [ "relations", [
                [ "properties", [ "owners", "belongs_to", [] ] ],
                [ "leases", [ "properties", "belongs_to", [] ] ],
                [ "leases", [ "tenants", "belongs_to", [] ] ],
                [ "maintenance_requests", [ "properties", "belongs_to", [] ] ]
            ]]
        ]
    ],

    # RESTAURANT MANAGEMENT TEMPLATES
    [
        "restaurant_pos",
        [
            [ "tables", [
                [ "menu_items", [ ["id", "integer"], ["name", "text"], ["price", "decimal"], ["category", "text"] ] ],
                [ "tables", [ ["id", "integer"], ["number", "integer"], ["capacity", "integer"], ["status", "text"] ] ],
                [ "orders", [ ["id", "integer"], ["table_id", "integer"], ["total", "decimal"], ["status", "text"] ] ],
                [ "order_items", [ ["id", "integer"], ["order_id", "integer"], ["menu_item_id", "integer"], ["quantity", "integer"] ] ],
                [ "staff", [ ["id", "integer"], ["name", "text"], ["role", "text"], ["shift", "text"] ] ]
            ]],
            [ "relations", [
                [ "orders", [ "tables", "belongs_to", [] ] ],
                [ "order_items", [ "orders", "belongs_to", [] ] ],
                [ "order_items", [ "menu_items", "belongs_to", [] ] ]
            ]]
        ]
    ],

    # EVENT MANAGEMENT TEMPLATES
    [
        "event_planning",
        [
            [ "tables", [
                [ "events", [ ["id", "integer"], ["name", "text"], ["date", "datetime"], ["venue", "text"], ["capacity", "integer"] ] ],
                [ "attendees", [ ["id", "integer"], ["name", "text"], ["email", "text"], ["phone", "text"] ] ],
                [ "registrations", [ ["id", "integer"], ["event_id", "integer"], ["attendee_id", "integer"], ["status", "text"] ] ],
                [ "vendors", [ ["id", "integer"], ["name", "text"], ["service_type", "text"], ["contact", "text"] ] ],
                [ "bookings", [ ["id", "integer"], ["event_id", "integer"], ["vendor_id", "integer"], ["cost", "decimal"] ] ]
            ]],
            [ "relations", [
                [ "registrations", [ "events", "belongs_to", [] ] ],
                [ "registrations", [ "attendees", "belongs_to", [] ] ],
                [ "bookings", [ "events", "belongs_to", [] ] ],
                [ "bookings", [ "vendors", "belongs_to", [] ] ]
            ]]
        ]
    ],

    # LIBRARY MANAGEMENT TEMPLATES
    [
        "library_system",
        [
            [ "tables", [
                [ "books", [ ["id", "integer"], ["title", "text"], ["author", "text"], ["isbn", "text"], ["status", "text"] ] ],
                [ "members", [ ["id", "integer"], ["name", "text"], ["email", "text"], ["membership_date", "date"] ] ],
                [ "borrowings", [ ["id", "integer"], ["book_id", "integer"], ["member_id", "integer"], ["borrow_date", "date"], ["return_date", "date"] ] ],
                [ "reservations", [ ["id", "integer"], ["book_id", "integer"], ["member_id", "integer"], ["reserved_date", "date"] ] ]
            ]],
            [ "relations", [
                [ "borrowings", [ "books", "belongs_to", [] ] ],
                [ "borrowings", [ "members", "belongs_to", [] ] ],
                [ "reservations", [ "books", "belongs_to", [] ] ],
                [ "reservations", [ "members", "belongs_to", [] ] ]
            ]]
        ]
    ],

    # HR MANAGEMENT TEMPLATES
    [
        "hr_management",
        [
            [ "tables", [
                [ "employees", [ ["id", "integer"], ["name", "text"], ["email", "text"], ["department", "text"], ["salary", "decimal"] ] ],
                [ "departments", [ ["id", "integer"], ["name", "text"], ["manager_id", "integer"] ] ],
                [ "positions", [ ["id", "integer"], ["title", "text"], ["department_id", "integer"], ["salary_range", "text"] ] ],
                [ "attendance", [ ["id", "integer"], ["employee_id", "integer"], ["date", "date"], ["hours", "decimal"] ] ],
                [ "leave_requests", [ ["id", "integer"], ["employee_id", "integer"], ["start_date", "date"], ["end_date", "date"], ["status", "text"] ] ]
            ]],
            [ "relations", [
                [ "employees", [ "departments", "belongs_to", [] ] ],
                [ "employees", [ "positions", "belongs_to", [] ] ],
                [ "departments", [ "employees", "belongs_to", [ :foreign_key = "manager_id" ] ] ],
                [ "attendance", [ "employees", "belongs_to", [] ] ],
                [ "leave_requests", [ "employees", "belongs_to", [] ] ]
            ]]
        ]
    ],

    # LOGISTICS TEMPLATES
    [
        "shipping_logistics",
        [
            [ "tables", [
                [ "shipments", [ ["id", "integer"], ["tracking_number", "text"], ["origin", "text"], ["destination", "text"], ["status", "text"] ] ],
                [ "carriers", [ ["id", "integer"], ["name", "text"], ["contact", "text"] ] ],
                [ "packages", [ ["id", "integer"], ["shipment_id", "integer"], ["weight", "decimal"], ["dimensions", "text"] ] ],
                [ "delivery_routes", [ ["id", "integer"], ["carrier_id", "integer"], ["route_name", "text"] ] ],
                [ "tracking_events", [ ["id", "integer"], ["shipment_id", "integer"], ["event", "text"], ["timestamp", "datetime"] ] ]
            ]],
            [ "relations", [
                [ "shipments", [ "carriers", "belongs_to", [] ] ],
                [ "packages", [ "shipments", "belongs_to", [] ] ],
                [ "delivery_routes", [ "carriers", "belongs_to", [] ] ],
                [ "tracking_events", [ "shipments", "belongs_to", [] ] ]
            ]]
        ]
    ],

    # SPORTS MANAGEMENT TEMPLATES
    [
        "sports_league",
        [
            [ "tables", [
                [ "teams", [ ["id", "integer"], ["name", "text"], ["city", "text"], ["founded", "date"] ] ],
                [ "players", [ ["id", "integer"], ["name", "text"], ["team_id", "integer"], ["position", "text"] ] ],
                [ "matches", [ ["id", "integer"], ["home_team_id", "integer"], ["away_team_id", "integer"], ["date", "datetime"], ["score", "text"] ] ],
                [ "seasons", [ ["id", "integer"], ["year", "integer"], ["start_date", "date"], ["end_date", "date"] ] ],
                [ "statistics", [ ["id", "integer"], ["player_id", "integer"], ["match_id", "integer"], ["goals", "integer"], ["assists", "integer"] ] ]
            ]],
            [ "relations", [
                [ "players", [ "teams", "belongs_to", [] ] ],
                [ "matches", [ "teams", "belongs_to", [ :foreign_key = "home_team_id" ] ] ],
                [ "matches", [ "teams", "belongs_to", [ :foreign_key = "away_team_id" ] ] ],
                [ "statistics", [ "players", "belongs_to", [] ] ],
                [ "statistics", [ "matches", "belongs_to", [] ] ]
            ]]
        ]
    ],

    # BOOKING SYSTEM TEMPLATES
    [
        "hotel_booking",
        [
            [ "tables", [
                [ "hotels", [ ["id", "integer"], ["name", "text"], ["address", "text"], ["rating", "integer"] ] ],
                [ "rooms", [ ["id", "integer"], ["hotel_id", "integer"], ["room_number", "text"], ["type", "text"], ["price", "decimal"] ] ],
                [ "guests", [ ["id", "integer"], ["name", "text"], ["email", "text"], ["phone", "text"] ] ],
                [ "bookings", [ ["id", "integer"], ["room_id", "integer"], ["guest_id", "integer"], ["check_in", "date"], ["check_out", "date"] ] ],
                [ "payments", [ ["id", "integer"], ["booking_id", "integer"], ["amount", "decimal"], ["method", "text"], ["status", "text"] ] ]
            ]],
            [ "relations", [
                [ "rooms", [ "hotels", "belongs_to", [] ] ],
                [ "bookings", [ "rooms", "belongs_to", [] ] ],
                [ "bookings", [ "guests", "belongs_to", [] ] ],
                [ "payments", [ "bookings", "belongs_to", [] ] ]
            ]]
        ]
    ],

    # DATA ANALYTICS & CROSS-DOMAIN TEMPLATES
    [
        "customer_analytics",
        [
            [ "tables", [
                [ "customers", [ ["id", "integer"], ["segment", "text"], ["acquisition_channel", "text"], ["lifetime_value", "decimal"] ] ],
                [ "interactions", [ ["id", "integer"], ["customer_id", "integer"], ["touchpoint", "text"], ["timestamp", "datetime"], ["value", "decimal"] ] ],
                [ "campaigns", [ ["id", "integer"], ["name", "text"], ["channel", "text"], ["budget", "decimal"], ["start_date", "date"] ] ],
                [ "campaign_responses", [ ["customer_id", "integer"], ["campaign_id", "integer"], ["response_type", "text"], ["timestamp", "datetime"] ] ],
                [ "cohorts", [ ["id", "integer"], ["name", "text"], ["period", "text"], ["retention_rate", "decimal"] ] ]
            ]],
            [ "relations", [
                [ "interactions", [ "customers", "belongs_to", [] ] ],
                [ "campaign_responses", [ "customers", "belongs_to", [] ] ],
                [ "campaign_responses", [ "campaigns", "belongs_to", [] ] ]
            ]]
        ]
    ],

    [
        "business_intelligence",
        [
            [ "tables", [
                [ "fact_sales", [ ["id", "integer"], ["product_id", "integer"], ["customer_id", "integer"], ["date_id", "integer"], ["revenue", "decimal"], ["quantity", "integer"] ] ],
                [ "dim_products", [ ["id", "integer"], ["name", "text"], ["category", "text"], ["brand", "text"], ["cost", "decimal"] ] ],
                [ "dim_customers", [ ["id", "integer"], ["name", "text"], ["segment", "text"], ["region", "text"] ] ],
                [ "dim_dates", [ ["id", "integer"], ["date", "date"], ["year", "integer"], ["quarter", "integer"], ["month", "integer"] ] ],
                [ "dim_geography", [ ["id", "integer"], ["country", "text"], ["state", "text"], ["city", "text"] ] ]
            ]],
            [ "relations", [
                [ "fact_sales", [ "dim_products", "belongs_to", [ :foreign_key = "product_id" ] ] ],
                [ "fact_sales", [ "dim_customers", "belongs_to", [ :foreign_key = "customer_id" ] ] ],
                [ "fact_sales", [ "dim_dates", "belongs_to", [ :foreign_key = "date_id" ] ] ]
            ]]
        ]
    ],

    [
        "web_analytics",
        [
            [ "tables", [
                [ "sessions", [ ["id", "integer"], ["user_id", "integer"], ["start_time", "datetime"], ["end_time", "datetime"], ["device", "text"] ] ],
                [ "page_views", [ ["id", "integer"], ["session_id", "integer"], ["page_url", "text"], ["timestamp", "datetime"], ["duration", "integer"] ] ],
                [ "events", [ ["id", "integer"], ["session_id", "integer"], ["event_type", "text"], ["element", "text"], ["timestamp", "datetime"] ] ],
                [ "conversions", [ ["id", "integer"], ["session_id", "integer"], ["goal_type", "text"], ["value", "decimal"], ["timestamp", "datetime"] ] ],
                [ "traffic_sources", [ ["id", "integer"], ["source", "text"], ["medium", "text"], ["campaign", "text"] ] ]
            ]],
            [ "relations", [
                [ "page_views", [ "sessions", "belongs_to", [] ] ],
                [ "events", [ "sessions", "belongs_to", [] ] ],
                [ "conversions", [ "sessions", "belongs_to", [] ] ]
            ]]
        ]
    ],

    [
        "financial_analytics",
        [
            [ "tables", [
                [ "fact_transactions", [ ["id", "integer"], ["account_id", "integer"], ["amount", "decimal"], ["transaction_date", "date"], ["type", "text"] ] ],
                [ "dim_accounts", [ ["id", "integer"], ["account_number", "text"], ["account_type", "text"], ["customer_id", "integer"] ] ],
                [ "dim_time", [ ["date_key", "integer"], ["date", "date"], ["fiscal_year", "integer"], ["fiscal_quarter", "integer"] ] ],
                [ "kpi_metrics", [ ["id", "integer"], ["metric_name", "text"], ["value", "decimal"], ["period", "date"], ["dimension", "text"] ] ],
                [ "risk_scores", [ ["id", "integer"], ["account_id", "integer"], ["score", "decimal"], ["calculated_date", "date"] ] ]
            ]],
            [ "relations", [
                [ "fact_transactions", [ "dim_accounts", "belongs_to", [ :foreign_key = "account_id" ] ] ],
                [ "risk_scores", [ "dim_accounts", "belongs_to", [ :foreign_key = "account_id" ] ] ]
            ]]
        ]
    ],

    [
        "operational_analytics",
        [
            [ "tables", [
                [ "processes", [ ["id", "integer"], ["name", "text"], ["department", "text"], ["sla_hours", "integer"] ] ],
                [ "process_instances", [ ["id", "integer"], ["process_id", "integer"], ["start_time", "datetime"], ["end_time", "datetime"], ["status", "text"] ] ],
                [ "resource_utilization", [ ["id", "integer"], ["resource_type", "text"], ["utilization_rate", "decimal"], ["timestamp", "datetime"] ] ],
                [ "quality_metrics", [ ["id", "integer"], ["process_id", "integer"], ["defect_rate", "decimal"], ["cycle_time", "integer"], ["date", "date"] ] ],
                [ "cost_centers", [ ["id", "integer"], ["name", "text"], ["budget", "decimal"], ["actual_spend", "decimal"] ] ]
            ]],
            [ "relations", [
                [ "process_instances", [ "processes", "belongs_to", [] ] ],
                [ "quality_metrics", [ "processes", "belongs_to", [] ] ]
            ]]
        ]
    ],

    [
        "predictive_analytics",
        [
            [ "tables", [
                [ "models", [ ["id", "integer"], ["name", "text"], ["algorithm", "text"], ["accuracy", "decimal"], ["created_date", "date"] ] ],
                [ "features", [ ["id", "integer"], ["name", "text"], ["data_type", "text"], ["importance", "decimal"] ] ],
                [ "predictions", [ ["id", "integer"], ["model_id", "integer"], ["input_data", "text"], ["prediction", "text"], ["confidence", "decimal"] ] ],
                [ "training_data", [ ["id", "integer"], ["model_id", "integer"], ["features", "text"], ["target", "text"], ["split_type", "text"] ] ],
                [ "model_performance", [ ["id", "integer"], ["model_id", "integer"], ["metric_name", "text"], ["value", "decimal"], ["test_date", "date"] ] ]
            ]],
            [ "relations", [
                [ "predictions", [ "models", "belongs_to", [] ] ],
                [ "training_data", [ "models", "belongs_to", [] ] ],
                [ "model_performance", [ "models", "belongs_to", [] ] ]
            ]]
        ]
    ],

    [
        "cross_domain_unified",
        [
            [ "tables", [
                [ "entities", [ ["id", "integer"], ["type", "text"], ["name", "text"], ["domain", "text"] ] ],
                [ "relationships", [ ["id", "integer"], ["from_entity_id", "integer"], ["to_entity_id", "integer"], ["relationship_type", "text"] ] ],
                [ "metrics", [ ["id", "integer"], ["entity_id", "integer"], ["metric_name", "text"], ["value", "decimal"], ["timestamp", "datetime"] ] ],
                [ "events", [ ["id", "integer"], ["entity_id", "integer"], ["event_type", "text"], ["payload", "text"], ["timestamp", "datetime"] ] ],
                [ "dimensions", [ ["id", "integer"], ["name", "text"], ["hierarchy_level", "integer"], ["parent_id", "integer"] ] ]
            ]],
            [ "relations", [
                [ "relationships", [ "entities", "belongs_to", [ :foreign_key = "from_entity_id" ] ] ],
                [ "relationships", [ "entities", "belongs_to", [ :foreign_key = "to_entity_id" ] ] ],
                [ "metrics", [ "entities", "belongs_to", [] ] ],
                [ "events", [ "entities", "belongs_to", [] ] ],
                [ "dimensions", [ "dimensions", "belongs_to", [ :foreign_key = "parent_id" ] ] ]
            ]]
        ]
    ]
]

#================#
#  HELP STRING   #
#================#

# HELP SYSTEM:
#   Access via: Help("stzdatamodel") or model.Help()
#   Two-tier system: Core guidelines + detailed feature usage
#   You can adapt the tow components here if you want.

$acDataModelValidationModes = ["strict", "warning", "permissive"]

$cDataModelHelp = "
1. START SIMPLE: Use naming conventions for automatic relationship inference
   - Example: 'customer_id' in 'orders' auto-links to 'customers.id'

2. BE EXPLICIT: Use Link(), Hierarchy(), Network() for complex relationships  
   - Example: Many-to-many via Link(), hierarchies via Hierarchy()

3. VALIDATE EARLY: Always run Validate() before production deployment
   - Example: Catch errors like duplicate fields or invalid constraints

4. EVOLVE SAFELY: Use impact analysis for schema changes
   - Example: Check impact before adding/removing fields

5. OPTIMIZE SMART: Follow performance hints to prevent slow queries
   - Example: Add indexes, use eager loading based on PerfHints()

6. DEBUG VISUALLY: Use Explain() and GetERDData() for model understanding
   - Example: Generate summaries and ERD scripts for visualization

7. PLAN MIGRATIONS: Use staged approach for production schema changes
   - Example: Analyze, assess impact, check performance, validate
"

$cDataModelHelpXT = "
WHEN TO USE EACH FEATURE:
~~~~~~~~~~~~~~~~~~~~~~~~~

• AddTable(): Basic schema definition with smart defaults
  - Use for initial table creation with inferred relationships

• Link(): Complex relationships that can't be auto-inferred  
  - Use for many-to-many or custom relationships

• Hierarchy(): Parent-child trees (categories, org charts)
  - Use for self-referencing hierarchical structures

• Network(): Peer-to-peer connections (social networks, graphs)
  - Use for complex, non-hierarchical relationships

• Validate(): Before any production deployment or major change
  - Use to ensure model integrity and catch errors

• PerfHints(): When queries become slow
  - Use to get optimization recommendations

• Explain(): When debugging complex models or onboarding new developers
  - Use for quick model summaries and understanding

• GetERDData(): When generating documentation or visual diagrams
  - Use to create ERD scripts for external visualization tools
"

$aGlobalHelp + [ "stzdatamodel", [ @trim($cDataModelHelp), @trim($cDataModelHelpXT) ] ]


func DataModelValidationModes()
	return $acDataModelValidationModes

# Helper function to find template by name
func FindTemplateByName(cTemplateName)
    for aTemplate in $aDataModelTemplates
        if aTemplate[1] = cTemplateName
            return aTemplate
        ok
    next
    return stzraise("Inexistant template with name " + cTemplateName)
