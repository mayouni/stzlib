# Narrative
# --------
# EncounterMonster()
#
# Extracted from stzstringarttest.ring, block #22.

load "../../../stzBase.ring"

#-->
# You encounter a fearsome dragon!
#    /\\__/\\
#   (  @@  )
#  /\\  )\(  /\\
# (__\\/  \\/__)
#    | /\\ |
#    \\(__)/
#     `''`
# 
# What will you do?
# 1. Fight
# 2. Run
# Enter your choice: 2
# 
# You turn and run as fast as you can!
# oooO
# ( )
# \ (
# \_)

func EncounterMonster()
    ? "You encounter a fearsome dragon!"
    ? StringArt("#{Dragon}") + NL
    ? "What will you do?"
    ? "1. Fight"
    ? "2. Run"

    ? "Enter your choice: " give choice

    if choice = "1"
        ? "You draw your sword and prepare for battle!"
        ? StringArt("#{Sword}")
    else
        ? "You turn and run as fast as you can!"
        ? StringArt("#{RightFeet}")
    ok
