# Narrative
# --------
# Nested Array of Mixed Types
#
# Extracted from stzextercodetest.ring, block #23.

load "../../../stzBase.ring"


pr()

xc = new stzExterCode("c")
xc.SetCode('
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Create the main array
Value* res = create_array_value(4);
if (res) {
    // First element: integer
    res->data.array_val.items[0].type = TYPE_INT;
    res->data.array_val.items[0].data.int_val = 42;
    
    // Second element: string
    res->data.array_val.items[1].type = TYPE_STRING;
    res->data.array_val.items[1].data.string_val = strdup("hello");
    
    // Third element: float
    res->data.array_val.items[2].type = TYPE_FLOAT;
    res->data.array_val.items[2].data.float_val = 3.14159;
    
    // Fourth element: nested array
    res->data.array_val.items[3].type = TYPE_ARRAY;
    res->data.array_val.items[3].data.array_val.size = 2;
    res->data.array_val.items[3].data.array_val.items = (Value*)calloc(2, sizeof(Value));
    
    // Add values to nested array
    res->data.array_val.items[3].data.array_val.items[0].type = TYPE_BOOL;
    res->data.array_val.items[3].data.array_val.items[0].data.bool_val = true;
    
    res->data.array_val.items[3].data.array_val.items[1].type = TYPE_INT;
    res->data.array_val.items[3].data.array_val.items[1].data.int_val = 99;
    
    printf("Mixed type array created\n");
} else {
    printf("Failed to create array\n");
    res = NULL;
}
')

xc.Execute()
? @@( xc.Result() )
#--> [ 42, "hello", 3.14, [ 1, 99 ] ]

pf()
# Executed in 0.62 second(s) in Ring 1.23
