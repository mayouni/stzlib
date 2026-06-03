# Narrative
# --------
# Creating structs with key pairs
#
# Extracted from stzextercodetest.ring, block #22.

load "../../stzBase.ring"


pr()

xc = new stzExterCode("c")
xc.SetCode('
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Create a struct using the Value system
Value* res = create_struct_value(3);
if (res) {
    // First key-value pair: name -> "John"
    res->data.struct_val.pairs[0].key = strdup("name");
    res->data.struct_val.pairs[0].value.type = TYPE_STRING;
    res->data.struct_val.pairs[0].value.data.string_val = strdup("John");
    
    // Second key-value pair: age -> 30
    res->data.struct_val.pairs[1].key = strdup("age");
    res->data.struct_val.pairs[1].value.type = TYPE_INT;
    res->data.struct_val.pairs[1].value.data.int_val = 30;
    
    // Third key-value pair: isActive -> true
    res->data.struct_val.pairs[2].key = strdup("isActive");
    res->data.struct_val.pairs[2].value.type = TYPE_BOOL;
    res->data.struct_val.pairs[2].value.data.bool_val = true;
    
    printf("Struct created with 3 key-value pairs\n");
} else {
    printf("Failed to create struct\n");
    res = NULL;
}
')

xc.Execute()
? @@( xc.Result() )
#--> [ [ "name", "John" ], [ "age", 30 ], [ "isActive", 1 ] ]

pf()

# Executed in 0.64 second(s) in Ring 1.23
