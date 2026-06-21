# Narrative
# --------
# Arabic-script detection on a word -- a FEATURE STUB pending script-predicate
# wiring.
#
# The intent: TQ("واحد").IsArabic() should return TRUE because every letter of
# the Arabic word for "one" is in the Arabic script. As written this currently
# FAILS: the script predicates (IsArabic / IsArabicScript) are defined on a
# different class and are NOT wired onto the stzString that TQ() returns, so the
# call raises R14. Left as a documented stub until the script-predicate cluster
# is wired onto the string class (the same gap blocks 994_ishanscript).
#
# Repositioned from test/list (stzlisttest.ring, block #344): this is a
# stzString/stzChar script test, so it belongs under test/string.
#ERR Error (R14) : Calling Method without definition: isarabic  (pending script-predicate wiring)

load "../../stzBase.ring"

pr()

? TQ("واحد").IsArabic()
#--> TRUE

pf()
# Executed in 0.04 second(s).
