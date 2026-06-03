# Narrative
# --------
# Test dynamic rule addition
#
# Extracted from stzpluraltest.ring, block #7.

load "../../stzBase.ring"


pr()


AddPluralRule("^test$", "tests", "exact", 1, "custom")
? Plural("test")        #--> tests

#TODO The example does not show the importance of adding dynamic rules
# think of a case of a word that is not managed correctly with the
# existant system, but can be fixed with a dynamic rule!

#TODO Also show more examples of rules.

pf()
# Executed in 0.06 second(s) in Ring 1.22
