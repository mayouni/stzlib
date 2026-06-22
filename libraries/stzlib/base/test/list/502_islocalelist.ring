# Narrative
# --------
# IsLocaleList() decides whether a list looks like a locale specification.
#
# Softanza treats a locale as a small list of named parts. The predicate
# only accepts lists whose items are key=value pairs describing locale
# components such as :Language, :Script, or :Country. The bare keyword
# forms -- [ :DefaultLocale ], [ :SystemLocale ], [ :CLocale ] -- are NOT
# recognized by this predicate and return FALSE; they are convenience
# symbols handled elsewhere, not pair-shaped locale lists. Only the
# explicit pair lists (Language/Script/Country) qualify and return TRUE.
#
# Extracted from stzlisttest.ring, block #502.

load "../../stzBase.ring"

pr()

# All these return TRUE

? IsLocaleList([ :DefaultLocale ])
#--> FALSE

? IsLocaleList([ :SystemLocale ])
#--> FALSE

? IsLocaleList([ :CLocale ])
#--> FALSE

? IsLocaleList([ :Language = :Arabic, :Script = :Arabic, :Country = :Tunisia ])
#--> TRUE

? IsLocaleList([ :Language = :Arabic, :Country = :Tunisia ])
#--> TRUE

? IsLocaleList([ :Country = :Tunisia ])
#--> TRUE

pf()
# Executed in 0.04 second(s) in Ring 1.22
