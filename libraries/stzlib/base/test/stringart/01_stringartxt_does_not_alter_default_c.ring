# Narrative
# --------
# # StringArtXT() does not alter default c
#
# Extracted from stzstringarttest.ring, block #1.

load "../../stzBase.ring"

pr()

? DefaultStringArtStyle()
#--> retro

? "SOFTANZA LOVES"
? StringArtXT("ring", :flower) # Does not change the default gloabl style
#-->
# SOFTANZA LOVES
# .-------.     .-./`)  ,---.   .--.   .-_'''-.   
# |  _ _   \    \ .-.') |    \  |  |  '_( )_   \  
# | ( ' )  |    / `-' \ |  ,  \ |  | |(_ o _)|  ' 
# |(_ o _) /     `-'`'` |  |\_ \|  | . (_,_)/___| 
# | (_,_).' __   .---.  |  _( )_\  | |  |  .-----.
# |  |\ \  |  |  |   |  | (_ o _)  | '  \  '-   .'
# |  | \ `'   /  |   |  |  (_,_)\  |  \  `-'`   | 
# |  |  \    /   |   |  |  |    |  |   \        / 
# ''-'   `'-'    '---'  '--'    '--'    `'-...-'

? DefaultStringArtStyle()
#--> retro

pf()
