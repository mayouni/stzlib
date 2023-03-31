load "stzlib.ring"

/*-----------

pron()

? Min([1, 10])
#--> 1

? Max([1, 10])
#--> 10

proff()
# Executed in 0.04 second(s)

/*-----------
*/
pron()

o1 = new stzString("...<<♥♥♥>>...<<★★>>...<<♥♥♥>>...")
? @@S( o1.FindAnyBetweenAsSectionsD("<<", ">>", :Backward) )
#--> [ [ 25, 27 ], [ 16, 17 ], [ 6, 8 ] ]

? @@S( o1.FindAnyBetweenAsSectionsS("<<", ">>", :StartingAt = 10) )
#--> [ [ 16, 17 ], [ 25, 27 ] ]

? @@S( o1.FindAnyBetweenAsSectionsSD("<<", ">>", :StoppingAt = 10, :Backward) )
#--> [ [ 25, 27 ], [ 16, 17 ] ]
? @@S( o1.FindAnyBetweenAsSectionsSDIB("<<", ">>", :StoppingAt = 10, :Backward) )
#--> [ [ 23, 29 ], [ 14, 19 ] ]

? @@S( o1.FindAnyBetweenAsSectionsSD("<<", ">>", :StoppingAt = 10, :Forward) )
#--> [ [ 6, 8 ] ]
? @@S( o1.FindAnyBetweenAsSectionsSDIB("<<", ">>", :StoppingAt = 10, :Forward) )
#--> [ [ 4, 10 ] ]

? @@S( o1.BetweenSD("<<", ">>", :StoppingAt = 10, :Going = :Backward) )
#--> [ "♥♥♥", "★★" ]
? @@S( o1.BetweenSDIB("<<", ">>", :StoppingAt = 10, :Going = :Backward) )
#--> [ "<<♥♥♥>>", "<<★★>>" ]
Z ZZ U
proff()

/*=============

pron()

o1 = new stzString("...<<♥♥♥>>...<<★★>>...")
/*
? @@S( o1.FindAnyBetweenAsSectionsDIB("<<",">>", :Backward) )
#--> [ [ 14, 19 ], [ 4, 10 ] ]

? @@S( o1.AnyBetweenDIB("<<",">>", :Backward) )

#--> [ "<<★★>>", "<<♥♥♥>>" ]

? o1.BetweenSDIB("<<", ">>", :StartingAt = 10, :Going = :Backward)
#--> [ <<★★>> ]
*/
? @@S( o1.BetweenSDIB("<<", ">>", :StoppingAt = 10, :Going = :Bakward) )
#--> [ <<♥♥♥>>]

//? o1.BetweenSDIB("<<", ">>", :InSection = [4, 20], :Going = :Forward)
#--> [ "<<♥♥♥>>", "<<★★>>" ]

proff()
# Executed in 0.16 second(s)

/*----------------

pron()

o1 = new stzString("...<<***>>...<<***>>...")

? @@S( o1.FindAnyBetweenAsSectionsIB("<<", ">>") )
#--> [ [ 4, 10 ], [ 14, 20 ] ]

? @@S( o1.FindAnyBetweenAsSectionsSIB("<<", ">>", :StartingAt = 10) )
#--> [ [ 14, 20 ] ]

? @@S( o1.FindAnyBetweenAsSectionsSIB("<<", ">>", :StoppingAt = 10) )
#--> [ [ 4, 10 ] ]

? @@S( o1.FindAnyBetweenAsSectionsSIB("<<", ">>", :InSection = [4, 20]) )
#--> [ [ 4, 10 ], [ 14, 20 ] ]

proff()
# Executed in 0.19 second(s)

/*----------------

pron()

o1 = new stzString("...<<***>>...<<***>>...")

? o1.FindAnyBetweenIB("<<", ">>")
#--> [ 4, 14 ]

? o1.FindAnyBetweenSIB("<<", ">>", :StartingAt = 10)
#--> [ 14 ]

? o1.FindAnyBetweenSIB("<<", ">>", :StoppingAt = 10)
#--> [ 4 ]

? o1.FindAnyBetweenSIB("<<", ">>", :InSection = [4, 20])
#--> [ 4, 14 ]

proff()
# Executed in 0.16 second(s)

/*=============

pron()

o1 = new stzString("...<<♥♥♥>>...<<★★>>...")

? o1.BetweenIB("<<", ">>")
#--> [ "<<♥♥♥>>", "<<★★>>" ]

? o1.BetweenSIB("<<", ">>", :StartingAt = 10)
#--> [ <<★★>> ]

? o1.BetweenSIB("<<", ">>", :StoppingAt = 10)
#--> [ <<♥♥♥>>]

? o1.BetweenSIB("<<", ">>", :InSection = [4, 20])
#--> [ "<<♥♥♥>>", "<<★★>>" ]

proff()
# Executed in 0.16 second(s)

/*----------------

pron()

o1 = new stzString("...<<***>>...<<***>>...")

? @@S( o1.FindAnyBetweenAsSectionsIB("<<", ">>") )
#--> [ [ 4, 10 ], [ 14, 20 ] ]

? @@S( o1.FindAnyBetweenAsSectionsSIB("<<", ">>", :StartingAt = 10) )
#--> [ [ 14, 20 ] ]

? @@S( o1.FindAnyBetweenAsSectionsSIB("<<", ">>", :StoppingAt = 10) )
#--> [ [ 4, 10 ] ]

? @@S( o1.FindAnyBetweenAsSectionsSIB("<<", ">>", :InSection = [4, 20]) )
#--> [ [ 4, 10 ], [ 14, 20 ] ]

proff()
# Executed in 0.19 second(s)

/*----------------

pron()

o1 = new stzString("...<<***>>...<<***>>...")

? o1.FindAnyBetweenIB("<<", ">>")
#--> [ 4, 14 ]

? o1.FindAnyBetweenSIB("<<", ">>", :StartingAt = 10)
#--> [ 14 ]

? o1.FindAnyBetweenSIB("<<", ">>", :StoppingAt = 10)
#--> [ 4 ]

? o1.FindAnyBetweenSIB("<<", ">>", :InSection = [4, 20])
#--> [ 4, 14 ]

proff()
# Executed in 0.16 second(s)

/*=============

pron()

o1 = new stzString("...<<♥♥♥>>...<<★★>>...")

? o1.Between("<<", ">>")
#--> [ "♥♥♥", "★★" ]

? o1.BetweenS("<<", ">>", :StartingAt = 10)
#--> [ "★★" ]

? o1.BetweenS("<<", ">>", :StoppingAt = 10)
#--> [ "♥♥♥" ]

? o1.BetweenS("<<", ">>", :InSection = [4, 20])
#--> [ "♥♥♥", "★★" ]

proff()
# Executed in 0.16 second(s)

/*----------------

pron()

o1 = new stzString("...<<***>>...<<***>>...")

? @@S( o1.FindAnyBetweenAsSections("<<", ">>") )
#--> [ [ 6, 8 ], [ 16, 18 ] ]

? @@S( o1.FindAnyBetweenAsSectionsS("<<", ">>", :StartingAt = 10) )
#--> [ [ 16, 18 ] ]

? @@S( o1.FindAnyBetweenAsSectionsS("<<", ">>", :StoppingAt = 10) )
#--> [ [ 6, 8 ] ]

? @@S( o1.FindAnyBetweenAsSectionsS("<<", ">>", :InSection = [4, 20]) )
#--> [ [ 6, 8 ], [ 16, 18 ] ]

proff()
# Executed in 0.19 second(s)

/*----------------

pron()

o1 = new stzString("...<<***>>...<<***>>...")

? o1.FindAnyBetween("<<", ">>")
#--> [ 6, 16 ]

? o1.FindAnyBetweenS("<<", ">>", :StartingAt = 10)
#--> [ 16 ]

? o1.FindAnyBetweenS("<<", ">>", :StoppingAt = 10)
#--> [ 6 ]

? o1.FindAnyBetweenS("<<", ">>", :InSection = [4, 20])
#--> [ 6, 16 ]

proff()
# Executed in 0.16 second(s)


/*==============

StartProfiler()

? Q("^^♥♥♥^^").ContainsSubStringBoundedBy("♥♥♥", ["^^","^^"])
#--> TRUE

StopProfiler()
# Executed in 0.28 second(s)
