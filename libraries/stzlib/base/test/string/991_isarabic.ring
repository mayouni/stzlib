# Narrative
# --------
# Arabic-script detection on a word.
#
# TQ("واحد").IsArabic() returns TRUE because every letter of the Arabic word
# for "one" is in the Arabic script. IsArabic() is an alias of IsArabicScript();
# both delegate to stzStringText so they're callable on the stzString that TQ()
# returns.
#
# Repositioned from test/list (stzlisttest.ring, block #344): this is a
# stzString/stzChar script test, so it belongs under test/string.

load "../../stzBase.ring"

pr()

? TQ("واحد").IsArabic()
#--> TRUE

pf()
# Executed in 0.04 second(s).
