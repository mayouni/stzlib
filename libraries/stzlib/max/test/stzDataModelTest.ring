
load "../stzmax.ring"

/*--- Test 1: Manual Relation Addition and Validation

pr()

oModel = new stzDataModel("test_model")
oModel {
    ? RelationInference()
	# --> FALSE

    AddTable("users", [
        [ "id", "identifier" ],
        [ "name", "string" ]
    ])
    AddTable("posts", [
        [ "id", "identifier" ],
        [ "user_id", "reference" ],
        [ "title", "string" ]
    ])

    AddRelation("one-to-many", "users", "posts", [ :field = "user_id" ])

    ? @@NL(Relations()) + NL
	#--> [
	# 	[
	# 		["type", "one-to-many"],
	# 		["from", "users"],
	# 		["to", "posts"],
	# 		["field", "user_id"],
	# 		["inferred", 0]
	# 	]
	# ]

    ? @@NL(Validate())
	#--> [
	# 	:errors_count = 0,
	# 	:warnings_count = 0,
	# 	:fixes_applied = 0,
	# 	:tables_validated = 2,
	# 	:active_plans = ["default"]
	# ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 2: Automatic Relation Inference

pr()

oModel = new stzDataModel("test_model")
oModel {

    UseRelationInference()

    ? RelationInference()  # --> TRUE
    AddTable("users", [
        [ "id", "identifier" ],
        [ "name", "string" ]
    ])

    AddTable("posts", [
        [ "id", "identifier" ],
        [ "user_id", "reference" ],
        [ "title", "string" ]
    ])

    ? @@NL(Relations())
	#--> [
	# 	[
	# 		["type", "one-to-many"],
	# 		["from", "users"],
	# 		["to", "posts"],
	# 		["field", "user_id"], 
	# 		["inferred", 1]
	# 	]
	# ]

    AddRelation("one-to-many", "users", "posts", [ :field = "user_id" ])
	#--> ERROR: Can't define relations when inference is active!
}

pf()

/*--- Test 3: Validation with Autofixing in Permissive Mode

pr()

oModel = new stzDataModel("test_model")
oModel {

    SetValidationMode("permissive")

    AddTable("", [  # Invalid: empty table name
        [ "id", "identifier" ],
        [ "name", "string" ],
        [ "name", "string" ]  # Invalid: duplicate field
    ])

    ? @@NL( Validate() ) + NL
	#--> [
	# 	[ "errors_count", 2 ],
	# 	[ "warnings_count", 0 ],
	# 	[ "fixes_applied", 2 ],
	# 	[ "tables_validated", 1 ],
	# 	[ "active_plans", [ "default" ] ]
	# ]

    ? @@( TableNames() ) + NL
	#--> [ "unnamed_table_1" ]

    ? @@NL( TableFields("unnamed_table_1") )
	#--> [
	# 	[
	# 		[ "name", "id" ],
	# 		[ "type", "identifier" ]
	# 	],
	# 	[
	# 		[ "name", "name" ],
	# 		[ "type", "string" ]
	# 	],
	# 	[
	# 		[ "name", "name_1" ],
	# 		[ "type", "string" ]
	# 	]
	# ]

}

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 4: Data Validation and Serialization
*/
pr()

oModel = new stzDataModel("test_model")
oModel {

    AddTable("users", [
        [ "id", "identifier" ],
        [ "name", "string" ],
        [ "active", "boolean" ]
    ])

    try
        validateData("users", [ "id" = "1", "name" = "Alice", "active" = TRUE ])
        ? "Validation passed"
    catch
        ? "Validation failed"
    done  # --> "Validation passed"

    try
        validateData("users", [ "id" = "1", "name" = 123, "active" = "yes" ])
    catch
        ? "Validation failed: Invalid types"
    done  # --> "Validation failed: Invalid types"

    cJSON = ToJSON()
    oNewModel = new stzDataModel("new_model")
    oNewModel.FromJSON(cJSON)
    ? oNewModel.TableExists("users")
	#--> TRUE
}

pf()
