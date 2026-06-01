# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #793.

load "../../../stzBase.ring"


StzStringQ("Tunisia is back! People united.") {

	ReplaceAll("People", "Tunisians")
	? Content() + NL
	#--> Tunisia is back! Tunisians united.

	? Section(3, 7)
	#--> nisia

	? Section(7, 3) + NL
	#--> nisia

	? Section(:From = 3, :To = :EndOfWord)
	#--> nisia

	? Section(:From = 12, :To = :EndOfWord) + NL
	#--> back!

	? Section(:From = 9, :To = :EndOfSentence) + NL
	#--> is back! Tunisians united.

	? Section(:From = :FirstChar, :To = :EndOfString) + NL
	#--> Tunisia is back! Tunisians united.

	ReplaceFirst("Tunisia", :With = "Egypt") 
	Replace( "Tunisians", :With = "Egyptians")
	? Content()
	#--> Egypt is back! Egyptians united.

}

pf()
# Executed in 0.06 second(s).
