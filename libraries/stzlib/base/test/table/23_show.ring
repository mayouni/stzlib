# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #23.

load "../../stzBase.ring"

pr()

#NOTE
# This example uses two files that exist in the default
# director: "mytable_emptyline.txt" and "mytable_line1_number"
# check them before you test the code.

# If the file begins with an empty line, then Softanza adds
# the names of columns automaticallys as :COL1, :COL2, etc

o1 = new stzTable(:FromFile = "mytable_emptyline.txt")

? o1.Show()

#-->    COL1      COL2      COL3     COL4
#    -------- --------- --------- -------
#    Tunisia    Arabic     Tunis   Africa
#     France    French     Paris   Europe
#      Egypt   English     Cairo   Africa
#    Belgium    French   Brussel   Europe
#      Yemen    Arabic     Sanaa     Asia

# Also, the first line is not empty but contains cells
# that are not strings (numbers or lists), then Softanza
# does the same (adds columns names)

o1 = new stzTable(:FromFile = "mytable_line1_number.txt")

? o1.Show()

#-->    COL1       COL2      COL3      COL4
#    -------- ---------- --------- --------
#     NATION   LANGUAGE       125   COUNTRY
#    Tunisia     Arabic     Tunis    Africa
#     France     French     Paris    Europe
#      Egypt    English     Cairo    Africa
#    Belgium     French   Brussel    Europe
#      Yemen     Arabic     Sanaa      Asia

pf()
# Executed in 0.46 second(s)
