# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #463.

load "../../../stzBase.ring"


? @Contains(" Q(@char).IsNumberInString() ", "@char")
#--> TRUE

? @Contains(" Q(@char).IsNumberInString() ", "@substring")
#--> FALSE

? @ContainsCS(" Q(@char).IsNumberInString() ", "@CHAR", FALSE)
#--> TRUE

? @ContainsCS(" Q(@char).IsNumberInString() ", "@substring", TRUE)
#--> FALSE

? @ContainsCS(" Q(@char).IsNumberInString() ", "@substring", FALSE)
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.22
