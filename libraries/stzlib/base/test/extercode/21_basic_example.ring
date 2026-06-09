# Narrative
# --------
# Basic example
#
# Extracted from stzextercodetest.ring, block #21.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

xc = new stzExterCode("c")
xc.SetCode('
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Create an array using the Value system
Value* res = create_array_value(5);
if (res) {
    for (int i = 0; i < 5; i++) {
        res->data.array_val.items[i].type = TYPE_INT;
        res->data.array_val.items[i].data.int_val = i + 1;
    }
    printf("Array created with values 1,2,3,4,5\n");
} else {
    printf("Failed to create array\n");
    res = NULL;
}
') # End of C code

xc.Execute()
? @@( xc.Result() )
#--> [1, 2, 3, 4, 5]

pf()
# Executed in 0.60 second(s) in Ring 1.23
