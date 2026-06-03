# Narrative
# --------
# TESTING CSV TABLES IN STZSTRING
#
# Extracted from stztabletest.ring, block #14.

load "../../stzBase.ring"


pr()

cCSV = 'NATION;LANGUAGE;CAPITAL;CONTINENT
Tunisia;Arabic;Tunis;Africa
France;French;Paris;Europe
Egypt;English;Cairo;Africa
Belgium;French;Brussel;Europe
Yemen;Arabic;Sanaa;Asia'

o1 = new stzString(cCSV)

? o1.IsCSVTable()
#--> TRUE

o1.CSVToDataTableQRT(:stzTable).Show()
#-->
# ╭─────────┬──────────┬─────────┬───────────╮
# │ Nation  │ Language │ Capital │ Continent │
# ├─────────┼──────────┼─────────┼───────────┤
# │ Tunisia │ Arabic   │ Tunis   │ Africa    │
# │ France  │ French   │ Paris   │ Europe    │
# │ Egypt   │ English  │ Cairo   │ Africa    │
# │ Belgium │ French   │ Brussel │ Europe    │
# │ Yemen   │ Arabic   │ Sanaa   │ Asia      │
# ╰─────────┴──────────┴─────────┴───────────╯

pf()
# Executed in 0.32 second(s) in Ring 1.22
