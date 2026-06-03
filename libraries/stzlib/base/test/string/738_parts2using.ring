# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #738.
#ERR Error (R14) : Calling Method without definition: parts2using

load "../../stzBase.ring"

pr()

o1 = new stzString("Abc285XY&من")

? @@( o1.Parts2Using( 'CharQ(@i).IsLetter()' ) ) + NL
#--> Gives:
# [ "Abc" = TRUE, "285" = FALSE, "XY" = TRUE, "&" = FALSE, "من" = TRUE ]

? @@( o1.Parts2Using("CharQ(@i).Orientation()") ) + NL
#--> Gives:
# [ "Abc285XY&" = :LeftToRight, "من" = :RightToLeft ]

? @@( o1.Parts2Using("CharQ(@i).IsUppercase()") ) + NL
#--> Gives:
# [ "A" = TRUE, "bc285" = FALSE, "XY" = TRUE, "&من" = FALSE ]

? @@( o1.Parts2Using("CharQ(@i).CharCase()") )
#--> Gives:
# [ "A" = :Uppercase, "bc" = :Lowercase, "285" = NULL, "XY" = :Uppercase, "&من" = NULL ]

pf()
# Executed in 0.35 second(s).
