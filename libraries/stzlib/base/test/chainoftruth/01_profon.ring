# Narrative
# --------
# profon()
#
# Extracted from stzchainoftruthtest.ring, block #1.

load "../../stzBase.ring"

pr()

	Q("Apple").IsA(:Fruit)
		? WhatIs(:Apple) #--> :Fruit
		? WhatIs(:Fruit) #--> :Undefined

Q(:Fruit).Is("the means by which flowering plants disseminate their seeds")
		? WhatIs(:Fruit) #--> the means by which flowering plants disseminate their seeds

	Q("Apple").IsA(:Company)
		? WhatIs(:Apple) #--> [ :Fruit, :Company ]

	Q("Steve Jobs").IsThe(:Owner).Of(:Apple)
		? WhoIs("Steve Jobs") #--> _('Steve Jobs").IsThe(:Owner).Of(:Apple)
		? WhatIs("Steve Jobs") #--> :Undefined

	Q(:Owner).IsA(:Person)
		? WhatIs("Steve Jobs") #--> :Person

 Q(:Person).AndQ(:Fruit).CanBeRelatedByQ(:Eats).AndAskedUsing(:What)
	Q(:Person).AndQ(:Company).CanBeRelatedByQ(:WorksAt).AndAskedUsingQ(:Where)_
	Q("Steve Jobs").Eats(:Apple)
	Q("Steve Jobs").WorksAt(:Apple)
		? What("Steve Jobs").Eats() 	#--> :Apple
		? Where("Steve Jobs").WorksAt() #--> :Apple

proff()

pf()
