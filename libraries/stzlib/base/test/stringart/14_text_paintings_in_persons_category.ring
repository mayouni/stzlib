# Narrative
# --------
# # Text paintings in PERSONS category
#
# Extracted from stzstringarttest.ring, block #14.
#ERR Error (R3) : Calling Function without definition: stringart

load "../../stzBase.ring"

pr()

? StringArt("#{Hero}") + NL
#-->
#   ◯
#  /██\
#  /  \
# /    \

? StringArt("#{Wizard}") + NL
#-->
#   ▲
#  /Θ\
# ╭|⋋|╮
#  ┃Θ┃
#  ┗━┛

? StringArt("#{Knight}") + NL
#-->
#   ⍟
#  /▼\
# ╭|‗|╮
#  ┃ ┃
#  ┗━┛

? StringArt("#{Villager}") + NL
#-->
#  ◯
# /Ω\
# ┃ ┃
# ╰─╯

? StringArt("#{Merchant}") + NL
#-->
#  ◯
# ┌╦╦┐
# ┃$$┃
# ┗━━┛

? StringArt("#{Princess}") + NL
#-->
#   ♔
#  /◠◠\
# ╭|◡◡|╮
#  ┃  ┃
#  ┗━━┛

? StringArt("#{Princess2}")
#-->
#          .....
#          WWWWW
#         ((. .))    
#        ))) - (((	  
#      ((((`...')))       
#       ))))\  /(((   	      
#       /    \/    \
#      / /\      /\ \
#     / /  \    /  \ \
#    @@@@  / \/ \  @@@@
#    (v   /      \   v)  
#        @@@@@@@@@@
#       /          \
#      /            \
#     @@@@@@@@@@@@@@@@
#    /                \
#   /                  \
#  @@@@@@@@@@@@@@@@@@@@@@
#  /                    \
# @@@@@@@@@@@@@@@@@@@@@@@@ 
#           v  v

pf()
# Executed in 0.002 seconds.
