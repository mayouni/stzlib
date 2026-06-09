# Narrative
# --------
# Complex Nested Structure with Arrays and Structs
#
# Extracted from stzextercodetest.ring, block #24.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

xc = new stzExterCode("c")
xc.SetCode('
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Create a person record with nested data
Value* res = create_struct_value(3);
if (res) {
    // Person basic info
    res->data.struct_val.pairs[0].key = strdup("person");
    res->data.struct_val.pairs[0].value.type = TYPE_STRUCT;
    res->data.struct_val.pairs[0].value.data.struct_val.size = 2;
    res->data.struct_val.pairs[0].value.data.struct_val.pairs = (KeyValue*)calloc(2, sizeof(KeyValue));
    
    // Add name
    res->data.struct_val.pairs[0].value.data.struct_val.pairs[0].key = strdup("name");
    res->data.struct_val.pairs[0].value.data.struct_val.pairs[0].value.type = TYPE_STRING;
    res->data.struct_val.pairs[0].value.data.struct_val.pairs[0].value.data.string_val = strdup("Alice");
    
    // Add age
    res->data.struct_val.pairs[0].value.data.struct_val.pairs[1].key = strdup("age");
    res->data.struct_val.pairs[0].value.data.struct_val.pairs[1].value.type = TYPE_INT;
    res->data.struct_val.pairs[0].value.data.struct_val.pairs[1].value.data.int_val = 28;
    
    // Skills array
    res->data.struct_val.pairs[1].key = strdup("skills");
    res->data.struct_val.pairs[1].value.type = TYPE_ARRAY;
    res->data.struct_val.pairs[1].value.data.array_val.size = 3;
    res->data.struct_val.pairs[1].value.data.array_val.items = (Value*)calloc(3, sizeof(Value));
    
    // Add skills
    res->data.struct_val.pairs[1].value.data.array_val.items[0].type = TYPE_STRING;
    res->data.struct_val.pairs[1].value.data.array_val.items[0].data.string_val = strdup("programming");
    
    res->data.struct_val.pairs[1].value.data.array_val.items[1].type = TYPE_STRING;
    res->data.struct_val.pairs[1].value.data.array_val.items[1].data.string_val = strdup("design");
    
    res->data.struct_val.pairs[1].value.data.array_val.items[2].type = TYPE_STRING;
    res->data.struct_val.pairs[1].value.data.array_val.items[2].data.string_val = strdup("management");
    
    // Metadata with mixed types
    res->data.struct_val.pairs[2].key = strdup("metadata");
    res->data.struct_val.pairs[2].value.type = TYPE_STRUCT;
    res->data.struct_val.pairs[2].value.data.struct_val.size = 3;
    res->data.struct_val.pairs[2].value.data.struct_val.pairs = (KeyValue*)calloc(3, sizeof(KeyValue));
    
    // Add metadata fields
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[0].key = strdup("active");
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[0].value.type = TYPE_BOOL;
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[0].value.data.bool_val = true;
    
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[1].key = strdup("score");
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[1].value.type = TYPE_FLOAT;
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[1].value.data.float_val = 95.5;
    
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[2].key = strdup("id");
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[2].value.type = TYPE_STRING;
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[2].value.data.string_val = strdup("USR-123");
    
    printf("Complex nested structure created\n");
} else {
    printf("Failed to create structure\n");
    res = NULL;
}
')
xc.Execute()
? @@( xc.Result() )
#--> [
#	[
#		"person",
#		[ [ "name", "Alice" ], [ "age", 28 ] ]
#	],
#	[ "skills", [ "programming", "design", "management" ] ],
#	[
#		"metadata",
#		[ [ "active", 1 ], [ "score", 95.50 ], [ "id", "USR-123" ] ]
#	]
# ]

pf()
# Executed in 0.60 second(s) in Ring 1.23
