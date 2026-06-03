# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #75.

load "../../stzBase.ring"

pr()

? @@( CountriesforWhichDefaultLanguageIs(:russian) )
# Gives [ :antarctica, :antarctica, :kyrgyzstan, :russia ]

? @@( ScriptsforWhichDefaultLanguageIs(:aramaic) )
# Gives [ :samaritan, :nabataean, :palmyrene ]

pf()
# Executed in 0.02 second(s) in Ring 1.23
