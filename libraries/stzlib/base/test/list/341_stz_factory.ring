# Narrative
# --------
# Reflects over a Softanza class to list its attribute (instance-variable) names.
#
# Stz(:Text, :Attributes) asks the global Stz() reflector for the
# instance variables defined by the stzText class, returning them as a
# plain list of attribute names (here "@ostring" and "@clanguage").
# This is the introspection idiom Softanza uses to inspect a class's
# shape at runtime without instantiating it; the same call works for
# any Stz class by passing its short name as the first argument.
#
# Extracted from stzlisttest.ring, block #341.

load "../../stzBase.ring"

pr()

? Stz(:Text, :Attributes)
#--> [ "@ostring", "@clanguage" ]

pf()
# Executed in 0.03 second(s).
