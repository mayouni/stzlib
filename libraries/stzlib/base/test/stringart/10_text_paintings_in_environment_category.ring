# Narrative
# --------
# # Text paintings in ENVIRONMENT category
#
# Extracted from stzstringarttest.ring, block #10.
#ERR Error (R3) : Calling Function without definition: stringart

load "../../stzBase.ring"

pr()

? StringArt("#{Tree}") + NL
#-->
#     🍃
#    🍃🍃
#  🍃🍃🍃
#  🍃🍃🍃🍃
# 🍃🍃🍃🍃🍃
#     ┃━┃
#     ┃━┃
#  ▔▔▔▔▔▔▔

? StringArt("#{Cloud}") + NL
#-->
#          .-~~~-.
#  .- ~ ~-(       )_ _
# /                     ~ -.
# |                           \
#  \                         .'
#    ~- . _____________ . -~

? StringArt("#{Platform}")
#-->
# ┏━━━━━━━━━━━━━━━┓
# ┗━━━━━━━━━━━━━━━┛

pf()
# Executed in 0 seconds.
