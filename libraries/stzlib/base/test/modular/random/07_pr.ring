# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #7.

load "../../../stzBase.ring"


acTreasureChest = [ "gold", "sword", "potion", "gem", "scroll" ]

acRareItems = Few(acTreasureChest)      # 10% chance items
? @@(acRareItems)
#--> [ "gold" ]

acCommonItems = Most(acTreasureChest)   # 70% chance items
? @@(acCommonItems)
#--> [ "sword", "gem", "gold", "scroll" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
