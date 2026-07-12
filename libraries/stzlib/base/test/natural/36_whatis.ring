load "../../stzBase.ring"

pr()


? @@NL( WhatIs(:Apple) ) #--> []

StzKnow(:Apple, :Company)
? @@NL( WhatIs(:Apple) ) #--> []

StzKnow(:Apple, :Company)
? @@NL( WhatIs(:Apple) ) #--> []

pf()

/*---

pr()

? Box("LOWERCASE")

? WhatIs(:Lowercase)
#--> the method Lowercased (on stzStringList): case operations (engine-backed)

? Box("REMOVE")

? WhatIs(:Remove)

pf()
