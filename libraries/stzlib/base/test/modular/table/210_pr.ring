# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #210.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :NAME,	:AGE,	:JOB ],
	[ "Folla",	22,	"Singer" ],
	[ "Warda",	28,	"Painter"],
	[ "Yasmine",	24,	"Danser" ]
])
? o1.Show()

#-->     NAME   AGE       JOB
#     -------- ----- --------
#       Folla    22    Singer
#       Warda    28   Painter
#     Yasmine    24    Danser

o1.InsertCol(3, [ :HOBBY, [ "Music", "Painting" ] ])
? o1.Show()

#-->    NAME   AGE       JOB      HOBBY
#    -------- ----- --------- ---------
#      Folla    22    Singer      Music
#      Warda    28   Painter   Painting
#    Yasmine    24    Danser         ""  

pf()
# Executed in 0.15 second(s)

#=================

pr()

o1 = new stzTable([])

? o1.IsEmpty()
#--> TRUE

? o1.NumberOfCols()
#--> 1

? o1.NumberOfRows()
#--> 1

? o1.Show()

#-->
# ╭──────╮
# │ Col1 │
# ├──────┤
# │      │
# ╰──────╯

cCSV = 'NATION;LANGUAGE;CAPITAL;CONTINENT
Tunisia;Arabic;Tunis;Africa
France;French;Paris;Europe
Egypt;English;Cairo;Africa
Belgium;French;Brussel;Europe
Yemen;Arabic;Sanaa;Asia'

o1.FromCSV(cCSV)
o1.Show()

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

? o1.ToCSV()
#-->
'nation;language;capital;continent
Tunisia;Arabic;Tunis;Africa
France;French;Paris;Europe
Egypt;English;Cairo;Africa
Belgium;French;Brussel;Europe
Yemen;Arabic;Sanaa;Asia'

pf()
# Executed in 0.23 second(s) without the Show() functions
# Executed in 0.33 second(s) with the Show() functions
