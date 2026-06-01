# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #655.

load "../../../stzBase.ring"


# This sample shows a locale-specific casing edge case:

? Q("ı").UppercasedInLocale("tr-TR")	#ERROR: --> I but must be İ
? Q("İ").Lowercased()	# i
? Q("İ").LowercasedInLocale("tr-TR")	#ERROR: --> i but must be ı

# In fact, this is a known Unicode special-casing issue:

oLocale = StzLocaleQ("tr-TR")
? oLocale.Uppercase("ı") #ERROR: --> I but must be İ

#TODO // solve this by implementing the specialCasing of unicode as
# described in this file:
# http://unicode.org/Public/UNIDATA/SpecialCasing.txt

pf()
# Executed in 0.03 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.18
