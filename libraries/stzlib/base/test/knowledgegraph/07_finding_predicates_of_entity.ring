# Narrative
# --------
# Finding predicates of entity
#
# Extracted from stzknowledgegraphtest.ring, block #7.

load "../../stzBase.ring"


pr()

oKG = new stzKnowledgeGraph("Person")
oKG {
	AddFact("Alice", :WorksAt, "Company")
	AddFact("Alice", :LivesIn, "City")
	AddFact("Alice", :Knows, "Bob")
	
	# What predicates does Alice have?

	? @@( Predicates("Alice") )
	#--> [:WorksAt, :LivesIn, :Knows]
}

pf()
