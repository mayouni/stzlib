# Narrative
# --------
# DIGITS FROM SPECIFIC SET
#
# Extracted from stznumbrextest.ring, block #9.

load "../../../stzBase.ring"


pr()

Nx = Nx("{@Digit({1;3;5;7})+}")
? Nx.Match(1357)  #--> TRUE
? Nx.Match(135)   #--> TRUE
? Nx.Match(1358)  #--> FALSE

pf()
