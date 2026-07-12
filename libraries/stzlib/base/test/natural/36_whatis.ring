load "../../stzBase.ring"

pr()

? @@NL( WhatIs(:Apple) )
#--> []

StzKnow(:Apple, :Company)
? @@NL( WhatIs(:Apple) )
#--> [ "company" ]

StzKnow(:Apple, :Fruit)
? @@NL( WhatIs(:Apple) )
#--> [ "company", "fruit" ]

pf()
# Executed in 3.52 second(s) in Ring 1.27 (Not yet engine-ified)

/*

pr()

? Box("LOWERCASE")

? WhatIs(:Lowercase)
#--> the method Lowercased (on stzStringList): case operations (engine-backed)

? Box("REMOVE")

? WhatIs(:Remove)

pf()

*/
