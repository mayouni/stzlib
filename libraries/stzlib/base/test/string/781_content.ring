# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #781.

load "../../stzBase.ring"

pr()

o1 = new stzString("Oooooh TunisiammMmmM")

o1.ReplaceLeadingChars(:With = "O")
? o1.Content()
#--> Oooooh TunisiammmmM

o1.ReplaceTrailingChars(:With = "!")
? o1.Content()
#--> Aaaaah TunisiammmmM

o1 = new stzString("Oooooh TunisiammMmmM")
o1.ReplaceLeadingCharsCS(:With = "O", :CaseSensitive = FALSE)
? o1.Content()
#--> Oh TunisiammmmM

o1.ReplaceTrailingCharsCS(:With = "!", :CaseSensitive = FALSE)
? o1.Content()
#--> Oh Tunisia!

pf()
# Executed in 0.02 second(s).
