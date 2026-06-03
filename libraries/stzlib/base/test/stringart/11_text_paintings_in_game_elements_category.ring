# Narrative
# --------
# # Text paintings in GAME ELEMENTS category
#
# Extracted from stzstringarttest.ring, block #11.
#ERR Error (R3) : Calling Function without definition: stringart

load "../../stzBase.ring"

pr()

? StringArt("#{Checkpoint}") + NL
#-->
#    ┌┐ 
#   ┌┘└┐
#  ┌┘  └┐
# ┌┘    └┐
# │ ┌──┐ │
# │ │✓│ │
# │ │✓│ │
# └─┴──┴─┘

? StringArt("#{Arrow}") + NL
#-->
#    ▲
#   ▲ ▲
#  ▲   ▲
# ▲─────▲
#    █
#    █
#    █
#    █

? StringArt("#{Exclamation}") + NL
#-->
# ▓▓
# ▓▓
# ▓▓
# ▓▓
# ▓▓
#   
# ▓▓

? StringArt("#{Question}") + NL
#-->
#   ▓▓▓▓▓
# ▓▓   ▓▓
#     ▓▓
#    ▓▓
#   ▓▓
#   
#   ▓▓

? StringArt("#{Spring}") + NL
#-->
# ┌───────────┐
# │▀▀▀▀▀▀▀▀▀▀▀│
# │▄▄▄▄▄▄▄▄▄▄▄│
# │▀▀▀▀▀▀▀▀▀▀▀│
# └───────────┘

? StringArt("#{Goomba}") + NL
#-->
#    ______
#   /      \
#  /  ^  ^  \
# |  (o)(o)  |
#  \   <    /
#   \______/

? StringArt("#{Spike}")
#-->
#     /\
#    /  \
#   /    \
#  /      \
# /        \
# ----------

pf()
# Executed in 0.001 seconds.
