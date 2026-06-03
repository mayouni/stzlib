# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #85.

load "../../stzBase.ring"

pr()

// Testing time formats
o1 = new stzLocale("en-Latn-US")
? o1.Abbreviation() #--> en_US
? o1.TimeShortFormat() #--> h:mm AP
? o1.TimeLongFormat() #--> h:mm:ss AP t
? o1.TimeNarrowFormat() #--> h:mm AP

pf()
# Executed in 0.02 second(s) in Ring 1.23
