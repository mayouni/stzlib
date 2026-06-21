# Narrative
# --------
# Demonstrates InfereType(), which maps a plural Softanza type
# keyword to its underlying scalar Ring type name.
#
# Softanza often labels collections by their element family
# (:Numbers, :Strings, ...). InfereType(:Numbers) collapses that
# plural family label down to the singular primitive type that the
# elements are made of -- here, "number". This is the small bridge
# the library uses to reason about a list's intended element type
# from a human-friendly keyword.
#
# Extracted from stzlisttest.ring, block #352.

load "../../stzBase.ring"

pr()

? InfereType(:Numbers)
#--> number

pf()
