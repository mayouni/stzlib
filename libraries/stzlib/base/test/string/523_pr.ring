# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #523.

load "../../stzBase.ring"


? Q("SOFTANZA").Section(1, 4)
#--> "SOFT"

? Q("SOFTANZA").Section(:From = 1, :To = 4)
#--> "SOFT"

? Q("SOFTANZA").Section(4, 1)
#--> "SOFT"

? Q("SOFTANZA").Section(:From = :LastChar, :To = :FirstChar)
#--> "SOFTANZA"

? Q("SOFTANZA").Section(:From = "F", :To = "A")
#--> "FTANZA"

? Q("SOFTANZA").Section( :From = "A", :To = :EndOfString )
#--> "ANZA"

? Q("Programming By Heart!
     This is Softanza motto.").
	Section( :From = "By", :To = :EndOfLine) + NL
#--> "By Heart!"

? Q("SOFTANZA").Section(4, :@)
#--> "T"

? Q("SOFTANZA").Section(:NthToLast = 3, :@)
#--> "A"

? Q("SOFTANZA").Section(:@, :@)
#--> "SOFTANZA"

pf()
# Executed in 0.12 second(s) in Ring 1.22
