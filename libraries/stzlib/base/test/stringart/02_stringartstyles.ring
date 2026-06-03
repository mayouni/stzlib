# Narrative
# --------
# ? StringArtStyles()
#
# Extracted from stzstringarttest.ring, block #2.
#ERR Error (R3) : Calling Function without definition: setstringartstyle

load "../../stzBase.ring"

pr()

#--> [ "retro", "neon", "geo", "flower" ]

SetStringArtStyle(:flower)
? StringArt("Ring") + NL
? "IS MORE BEAUTIFUL, YET POWERFUL WITH SOFTANZA!"

#-->
# .-------.     .-./`)  ,---.   .--.   .-_'''-.   
# |  _ _   \    \ .-.') |    \  |  |  '_( )_   \  
# | ( ' )  |    / `-' \ |  ,  \ |  | |(_ o _)|  ' 
# |(_ o _) /     `-'`'` |  |\_ \|  | . (_,_)/___| 
# | (_,_).' __   .---.  |  _( )_\  | |  |  .-----.
# |  |\ \  |  |  |   |  | (_ o _)  | '  \  '-   .'
# |  | \ `'   /  |   |  |  (_,_)\  |  \  `-'`   | 
# |  |  \    /   |   |  |  |    |  |   \        / 
# ''-'   `'-'    '---'  '--'    '--'    `'-...-'  
# 
# IS MORE BEAUTIFUL, YET POWERFUL WITH SOFTANZA!

pf()
