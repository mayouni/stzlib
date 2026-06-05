# Narrative
# --------
# o1 = new stzListOfStrings([ "WATCH", "see", "Watch", "Observe", "watch" ])
#
# Extracted from stzlistofstringstest.ring, block #50.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "WATCH", "see", "Watch", "Observe", "watch" ])

? o1.StringsW('{ @string = "watch" }') #--> "watch"

? o1.StringsW('{ Q(@string).IsEqualToCS("watch", :CS = FALSE) }')
#--> [ "WATCH", "Watch", "watch" ]

? o1.Yield('{ Q(@string).IsEqualToCS("watch", :CaseSensitive = FALSE) }')
#--> [ 1, 0, 1, 0, 1 ]

? o1.YieldW('@string', :Where = '{ Q(@string).IsEqualToCS("watch", :CaseSensitive = FALSE) }')
#--> [ "WATCH", "Watch", "watch" ]


? o1.FindW('{ Q(@string).IsEqualToCS("watch", :CS = FALSE) }')
#--> [1, 3, 5]

? o1.StringsPositionsW('{ Q(@string).IsEqualToCS("watch", :CS = FALSE) }')
#--> [1, 3, 5]

pf()
