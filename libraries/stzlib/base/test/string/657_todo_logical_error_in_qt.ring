# Narrative
# --------
# TODO: LOGICAL ERROR IN QT??
#
# Extracted from stzStringTest.ring, block #657.

load "../../stzBase.ring"


pr()

# Let's take the example of the german letter ß that
# should be uppercased to SS

? Q("ß").CharCase()
#--> lowercase

? Q("ß").Uppercased()
#--> SS

# Which is nice, and we can check it for a hole word
? upper("der fluß")
#--> DER FLUSS

# Now, if we check the other way around :
? Q("SS").Lowercased()
#--> ss

# we don't get "ß", which is expected, because Softanza is running
# at the default locale ("C" locale) and not the german locale.

# Therefore, we need to tune the previous expression by sepecifying
# the german locale ("ge-GE")

? Q("SS").LowercasedInLocale("ge-GE")
#--> ss (ERROR in QT: it should be ß)

pf()
# Executed in 0.08 second(s)
