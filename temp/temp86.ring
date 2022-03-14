load "stzlib.ring"

o1 = new stzList([ 100, 200, 300, 400, 500, 600, 700 ] )
? o1.SplitToNParts(3)

//? o1.DistributeOver([ :arem, :mohsen, :hamma ], :Using = [ 2, 3, 2 ] )
//? o1.DistributeOver([ :arem, :mohsen, :hamma ], :SameShare )

/*------------

o1 = new stzString("TUNIS1250XT")
//? o1.Structure(:IsNumber)

//? o1.StructureAsSubstrings(:IsNumber)
//? o1.StructureAsSections(:IsNumber)

/*-------------

o1 = new stzString("111222000")
? o1 / [ "me", "you", "others" ]

//? o1.Structure(:ByCharCase)


