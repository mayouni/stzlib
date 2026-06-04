# Narrative
# --------
# # WAY 6: Creating a table from an external text file (EXPERIMENTAL)
#
# Extracted from stztabletest.ring, block #22.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"


#NOTE
# This example uses two files that exist in the default
# director: "myTable.csv" and "myHybridTable.txt"
# check them before you test the code.

pr()

# You can crate a table from an external data file.
# The file can be in CSV format or any other text file.
# Tha data inside the file must be separated by lines,
# and the lines must be separated by semicolons.

o1 = new stzTable(:FromFile = "mytable.csv")
? o1.ShowXT([ :RowNumber = TRUE ])
#-->
# ╭───┬─────────────────┬──────────┬─────────┬───────────╮
# │ # │     Nation      │ Language │ Capital │ Continent │
# ├───┼─────────────────┼──────────┼─────────┼───────────┤
# │ 1 │ Tunisia         │ Arabic   │ Tunis   │ Africa    │
# │ 2 │ France          │ French   │ Paris   │ Europe    │
# │ 3 │ Egypt           │ English  │ Cairo   │ Africa    │
# │ 4 │ Belgium         │ French   │ Brussel │ Europe    │
# │ 5 │ Yemen           │ Arabic   │ Sanaa   │ Asia      │
# ╰───┴─────────────────┴──────────┴─────────┴───────────╯

o2 = new stzTable(:FromFile = "myHybridTable.txt")
o2.ShowXT([ :RowNumber = TRUE ])
#-->
# ╭───┬─────────────────┬─────┬────────────────────────────────╮
# │ # │      Name       │ Age │            Hobbies             │
# ├───┼─────────────────┼─────┼────────────────────────────────┤
# │ 1 │ Hela            │  24 │ [ "Sport", "Music" ]           │
# │ 2 │ John             │  32 │ [ "Games", "Travel", "Sport" ] │
# │ 3 │ Ali             │  22 │ [ "Painting", "Dansing" ]      │
# │ 4 │ Foued           │  43 │ [ "Music", "Travel" ]          │
# ╰───┴─────────────────┴─────┴────────────────────────────────╯

#~> #NOTE that numbers and lists are evaluated and retutned as native types
#~> #NOTE lists in the text file must take the form ['str1','str2','str3']

pf()
# Executed in 0.64 second(s)
