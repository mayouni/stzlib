# Narrative
# --------
# # Is this arabic word diacriticized?
#
# Extracted from stzTtexttest.ring, block #8.
#ERR exit 1: 1

load "../../stzBase.ring"

pr()

? StzStringQ("سَلَامُُ").ContainsDiacritics() # 1

# The word contains some letters and diacritics
# Let's see what is the script of one letter

? StzStringQ("س").Script() #--> :Arabic

# And what is the script of a diacritic, the Fat7ah
# for example (the small line above the letter سَـ
? StzStringQ(ArabicFat7ah()).Script() #--> :Inherited

# In fact, Unicode considers it as an inherited script
# because it inherits is script from a previous char.

# Now, if we ask for the script of the hole word, that
# contains both arabic letters (arabic script) and
# inherited scripts (the arabic diacritics), Softanza
# makes no mistaks (and corrects Unicode in this regard)
# and says it is an arabic script

? StzStringQ("سَلَامُُ").Script() #--> :Arabic

# And even if you include some chars belonging to
# :Common script, like space for example, the result
# is as expected, an :Arabic script
? StzStringQ("السَّلَامُ عَلَيْكُمْ").Script() #--> :Arabic
? StzStringQ("السلام عليكم").Script() #--> :Arabic

pf()
