# Narrative
# --------
# ? StzTextQ("Kırşehir").DiacriticsRemoved() #--> "Kirsehir" / Turkish
#
# Extracted from stzTtexttest.ring, block #32.
#ERR Error (E9) : Can't open file 32_stztextqkirsehirdiacriticsremoved_--_kirsehir_turk.ring

load "../../stzBase.ring"

pr()

? StzTextQ("Þingvellir").DiacriticsRemoved() #--> "Pingvellir" / Iceland
? stzTextQ("Malmö").DiacriticsRemoved() #--> "Malmo"	/ Swidesh

pf()
