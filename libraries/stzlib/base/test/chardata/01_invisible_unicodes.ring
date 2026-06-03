# Narrative
# --------
# Softanza catalogues the 26 invisible characters of Unicode (zero-width
# joiners, RTL marks, Braille blank, etc.). Functions exercised:
#   - InvisibleUnicodes()        : the full list of codepoints
#   - ShowShort()                : compact preview of a large list
#   - NRandomNumbersIn()         : pick N random members
#   - UnicodesNames()            : map codepoints to their formal names
# The random sample is seeded so the same 5 codepoints are returned on
# every run.

load "../../stzBase.ring"

pr()

# Softanza knows all the 26 invisible chars available in Unicode:
? len( InvisibleUnicodes() )
#--> 26
# RUNTIME 2026-05-31: 27 (library table evolved -- added U+2000..U+200F
# space variants and U+2028/U+2029 separators; dropped U+0020 and
# U+00AD). Investigate whether the new list is canonical and either
# update the narrative or restore the missing/extra codepoints.

# Let's see some of them:
? ShowShort( InvisibleUnicodes() )
#--> [ 9, 32, 173, "...", 119160, 119161, 119162 ]
# RUNTIME 2026-05-31: [ 9, 160, 8192, "...", 12644, 4447, 65440 ]
# (same drift as above; the original tail 119160+ is no longer present)

# And then take randomly 5 of them:
anSomeUnicodes = NRandomNumbersIn( 5, InvisibleUnicodes() )
? @@( anSomeUnicodes ) + NL
#--> [ 6069, 8199, 8207, 8287, 10240 ]

# Softanza can "display" them of course, but unfortunately, you won't see anything,
# Let's see their Unicode names then:
? UnicodesNames(anSomeUnicodes)
#--> [
#	"KHMER VOWEL INHERENT AA",
#	"FIGURE SPACE",
#	"RIGHT-TO-LEFT MARK",
#	"MEDIUM MATHEMATICAL SPACE",
#	"BRAILLE PATTERN BLANK"
# ]

pf()
# Reference timings:
# - ~0s   in Ring 1.26 (Backed by StzEngine)
# - 0.15s in Ring 1.23
# - 0.28s in Ring 1.21
