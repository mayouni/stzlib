# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #17.

load "../../stzBase.ring"


o1 = new stzHashList([
	:one 	= :red,
	:two 	= :white,
	:three 	= :white,
	:four 	= :green,
	:five 	= :red,
	:six 	= :green,
	:seven 	= :white,
	:eight	= :yellow
])

# Info about all classes available in the hash list

? o1.NumberOfKlasses()
#--> 4

? @@( o1.Klasses() ) + NL
#--> [ :red, :white, :green, :yellow ]

? @@( o1.KlassesSizes() )
#--> [ 2, 3, 2, 1 ]

? @@( o1.KlassesSizesXT() )
#--> [ [ "red", 2 ], [ "white", 3 ], [ "green", 2 ], [ "yellow", 1 ] ]

? @@( o1.KlassesFreqs() ) + NL
#--> [ 0.25, 0.38, 0.25, 0.13 ]

? @@( o1.KlassesFreqsXT() ) + NL
#--> [ [ "red", 0.25 ], [ "white", 0.38 ], [ "green", 0.25 ], [ "yellow", 0.13 ] ]

? @@( reverse( sort( o1.KlassesFreqsXT(), 2 ) ) ) + NL
#--> [ [ "white", 0.38 ], [ "red", 0.25 ], [ "green", 0.25 ], [ "yellow", 0.12 ] ]

# Info about one class

? o1.ContainsKlass(:white)
#--> TRUE

? o1.KlassSize(:white)
#--> 3

? @@( o1.Klass(:white) )
#--> [ "two", "three", "seven" ]

? o1.KlassFreq(:white)
#--> 0.38

? @@( o1.KlassFreqXT(:white) ) + NL
#--> [ "white", 0.38 ]

# Info about some classes

? o1.ContainsTheseKlasses([ :white, :green ])
#--> TRUE

? @@( o1.TheseKlassesSizes([ :white, :green ]) )
#--> [ 3, 2 ]

? @@( o1.TheseKlassesSizesXT([ :white, :green ]) )
#--> [ [ "white", 3 ], [ "green", 2 ] ]

? @@( o1.TheseKlassesFreqs([ :white, :green ]) )
#--> [ 0.38, 0.25 ]

? @@( o1.TheseKlassesFreqsXT([ :white, :green ]) ) + NL
#--> [ [ "white", 0.38 ], [ "green", 0.25 ] ]

# Strongest and weakest classes

? o1.StrongestKlass() + NL
#--> :white

? o1.StrongestKlassXT()
#--> [ :white, 0.38 ]

? o1.WeakestKlass() + NL
#--> :yellow

? o1.WeakestKlassXT()
#--> [ :yellow, 0.12 ]


? o1.TopNClasses(2)
#--> [ :white, :red ])

? o1.Top3Classes()
#--> [ :white, :red, :green ]

? o1.Top3ClassesXT()
#--> [ :white = 0.38, :red = 0.25, :green = 0.25 ]

? o1.StrongestNClasses(3)
#--> [ :red, :white, :green ])

? o1.WeakestNCLasses(3)
#--> [ :red, :green, :yellow ])

pf()
# Executed in 0.88 second(s)
