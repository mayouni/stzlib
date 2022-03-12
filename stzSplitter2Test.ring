load "stzlib.ring"

o1 = new stzSplitter2(1:10)

? ListToCode( o1.GetPairsFromPositions([3, 6, 8]) )
# --> [ [ 1, 3 ], [ 3, 6 ], [ 6, 8 ], [ 8, 10 ] ]

? ListToCode( o1.SplitAtPositions([3, 6, 8]) )
# --> [ [ 1, 2 ], [ 4, 5 ], [ 7, 7 ], [ 9, 10 ] ]

? ListToCode( o1.SplitBeforePositions([3, 6, 8]) )
# --> [ [ 1, 2 ], [ 3, 5 ], [ 6, 7 ], [ 8, 10 ] ]

? ListToCode( o1.SplitAfterPositions([3, 6, 8]) )
# --> [ [ 1, 3 ], [ 4, 6 ], [ 7, 8 ], [ 9, 10 ] ]

? ListToCode( o1.SplitToPartsOfNItems(2))
# --> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ], [ 9, 10 ] ]

? ListToCode( o1.SplitToNParts(4) )
# --> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 10 ] ]

