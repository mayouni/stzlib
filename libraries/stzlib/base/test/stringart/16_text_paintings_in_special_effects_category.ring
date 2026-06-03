# Narrative
# --------
# # Text paintings in SPECIAL EFFECTS category
#
# Extracted from stzstringarttest.ring, block #16.
#ERR Error (R3) : Calling Function without definition: stringart

load "../../stzBase.ring"

pr()

? StringArt("#{SunRise}") + NL
#-->
#    \   🌞  /
#   \  \│/  /
# ─ ─ ─ ☀ ─ ─ ─
#   /  /│\  \
#     /    \  \

? StringArt("#{Explosion}") + NL
#-->
#     \   /
#   *  .  *
# *  * 💥 *  *
#   *  ..  *
#     /   \

? StringArt("#{Sparkle}") + NL
#-->
#     .  ✦
#   * ✧  .
# ✦   ✨  ✧
#   . ✦  *
#     ✧  .

? StringArt("#{Rain}") + NL
#-->
#  ╱ ╲ ╱ ╲ ╱ ╲
#    ‖ ‖ ‖ ‖
#  ╲ ╱ ╲ ╱ ╲ ╱
#    ‖ ‖ ‖ ‖

? StringArt("#{Snow}") + NL
#-->
#   ❄   ❅
#     ❆
#  ❅   ❄   ❆
#    ❆   ❅
#  ❄   ❅

? StringArt("#{Fire}") + NL
#-->
#   )\
#  (  )
# (    )
#  )  )
# ( 🔥 (
#  ) 🔥 )

? StringArt("#{Bubble}") + NL
#-->
#   .--.
#  /    \
# (      )
#  \    /
#   '--'

? StringArt("#{Teleport}") + NL
#-->
#    ↑↑
# ┌──┴┴──┐
# │ ◊◊◊◊ │
# │ ◊◊◊◊ │
# └──↑↑──┘
#    ↑↑

? StringArt("#{Shield}")
#-->
#  .─────.
# / ┌───┐ \
# │ │ ▓ │ │
# │ │▓▓▓│ │
# \ └───┘ /
#  `─────'

pf()
# Executed in 0.003 seconds.
