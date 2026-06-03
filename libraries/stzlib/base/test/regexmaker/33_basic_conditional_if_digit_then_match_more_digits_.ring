# Narrative
# --------
# Basic conditional: if digit then match more digits else match letters
#
# Extracted from stzregexmakertest.ring, block #33.

load "../../stzBase.ring"


pr()

o1 = new stzConditionalRegexMaker

o1.IfMatch("\d").
   ThenMatch("\d+").
   ElseMatch("[a-z]+")

? o1.Pattern()
#--> (?(?=\d)\d+|[a-z]+)

# Checking content
? @@NL( o1.Info() )
#--> [
#     :condition = "(?(?=^\d)",
#     :then = "\d+",
#     :else = "[a-z]+",
#     :pattern = "(?(?=^\d)\d+|[a-z]+)"
#    ]


pf()
# Executed in almost 0 second(s) in Ring 1.22
