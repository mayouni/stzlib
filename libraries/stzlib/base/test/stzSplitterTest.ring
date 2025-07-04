load "../stzbase.ring"

/*-----------

pr()

? Q(1:5).IsEqualTo(5:1)
#--> TRUE

? Q(1:5).IsIdenticalTo(5:1)
#--> FALSE

? Q("A":"E").IsSortedInAscending()
#--> TRUE

? Q("E":"A").IsSortedInDescending()
#--> TRUE

? Q("A":"E").IsContiguous()
#--> TRUE

? Q("E":"A").IsCOntiguous()
#--> TRUE

pf()
# Executed in 0.11 second(s) in Ring 1.22
# Executed in 0.24 second(s) in Ring 1.19

/*-----------

pr()

o1 = new stzSplitter(10)
? @@( o1.SplitAtSection(3, 5) )
# [ [ 1, 2 ], [ 6, 10 ] ]

? @@( o1.SplitXT( :AtSections = [ [3,5], [8,9] ] ) )
#--> [ [ 1, 2 ], [ 6, 7 ], [ 10, 10 ] ]

pf()
# Executed in 0.25 second(s) in Ring 1.21

/*====================

pr()

o1 = new stzSplitter(10)

? @@( o1.SplitAt( :Position = 5) )
#--> [ [1, 4], [6, 10] ]

? @@( o1.SplitAt([3, 7]) )
#--> [ [ 1, 2 ], [ 4, 6 ], [ 8, 10 ] ]

? @@( o1.SplitAtSection(4, 7) )
#--> [ [ 1, 3 ], [ 8, 10 ] ]

? @@( o1.SplitAtSection(1, 9) )
#--> [ [ 10, 10 ] ]

? @@( o1.SplitAtSections([ [3,5], [7, 8] ]) )
#--> [ [1, 2], [6, 6], [9, 10] ]

? @@( o1.SplitAt( :Sections = [ [3,5], [7, 8] ] ) )
#--> [ [1, 2], [6, 6], [9, 10] ]

? @@( o1.SplitAt( :Section = [ 4, 6 ] ) )
#--> [ [ 1, 3 ], [ 7, 10 ] ]

? @@( o1.SplitAt( :Sections = [ [ 4, 6 ] ] ) )
#--> [ [ 1, 3 ], [ 7, 10 ] ]

pf()
# Executed in 0.16 second(s) in Ring 1.21
# Executed in 0.23 second(s) in Ring 1.20

/*====================

pr()

o1 = new stzSplitter(10)

? @@( o1.SplitBefore( :Position = 10) )
#--> [ [ 1, 9 ], [ 10, 10 ] ]

? @@( o1.SplitBefore( :Position = 5) )
#--> [ [1, 4], [5, 10] ]

? @@( o1.SplitBefore([3, 7]) )
#--> [ [ 1, 2 ], [ 3, 6 ], [ 7, 10 ] ]

? @@( o1.SplitBeforeSection(4, 7) )
#--> [ [ 1, 3 ], [ 4, 10 ] ]

? @@( o1.SplitBeforeSection(1, 9) )
#--> [ [ 1, 10 ] ]

? @@( o1.SplitBeforeSections([ [3,5], [7, 8] ]) )
#--> [ [ 1, 2 ], [ 3, 6 ], [ 7, 10 ] ]

? @@( o1.SplitBefore( :Sections = [ [3,5], [7, 8] ] ) )
#--> [ [ 1, 2 ], [ 3, 6 ], [ 7, 10 ] ]

? @@( o1.SplitBefore( :Section = [ 4, 6 ] ) )
#--> [ [ 1, 3 ], [ 4, 10 ] ]

? @@( o1.SplitBefore( :Sections = [ [ 4, 6 ] ] ) )
#--> [ [ 1, 3 ], [ 4, 10 ] ]

pf()
# Executed in 0.20 second(s) in Ring 1.21

/*====================

pr()

o1 = new stzSplitter(10)

? @@( o1.SplitAfter( :Position = 9) )
#--> [ [ 1, 9 ], [ 10, 10 ] ]

? @@( o1.SplitAfter( :Position = 5) )
#--> [ [ 1, 5 ], [ 6, 10 ] ]

? @@( o1.SplitAfter([3, 7]) )
#--> [ [ 1, 3 ], [ 4, 7 ], [ 8, 10 ] ]

? @@( o1.SplitAfterSection(4, 7) )
#--> [ [ 1, 7 ], [ 8, 10 ] ]

? @@( o1.SplitAfterSection(2, 9) )
#--> [ [1, 9], [10, 10] ]

? @@( o1.SplitAfterSections([ [3,5], [7, 8] ]) )
#--> [ [ 1, 5 ], [ 6, 8 ], [ 9, 10 ] ]

? @@( o1.SplitAfter( :Sections = [ [3,5], [7, 8] ] ) )
#--> [ [ 1, 5 ], [ 6, 8 ], [ 9, 10 ] ]

? @@( o1.SplitAfter( :Section = [ 4, 6 ] ) )
#--> [ [ 1, 6 ], [ 7, 10 ] ]

? @@( o1.SplitAfter( :Sections = [ [ 4, 6 ] ] ) )
#--> [ [ 1, 6 ], [ 7, 10 ] ]

pf()
# Executed in 0.18 second(s) in Ring 1.21
# Executed in 0.19 second(s) in Ring 1.20

/*====================

pr()

o1 = new stzSplitter(10)

? @@( o1.Split( :ToPartsOfNItems = 3 ) ) # Or :ToPartsOfExactlyNItems
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ] ]


? @@( o1.Split( :ToPartsOfNItemsXT = 3 ) ) # XT ~> Adds the remaining part
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ], [ 10, 10 ] ]

? @@( o1.Split( :ToNParts = 4 ) )
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 8 ], [ 9, 10 ] ]

pf()
# Executed in 0.14 second(s) in Ring 1.21
# Executed in 0.16 second(s) in Ringh 1.20

/*=============

pr()

o1 = new stzSplitter(10)

? @@( o1.SplitToNParts(2) )
#--> [ [ 1, 5 ], [ 6, 10 ] ]

? @@( o1.SplitToPartsOfNPositions(2) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ], [ 9, 10 ] ]

#--

? @@( o1.SplitToPartsOfNPositions(3) ) # Same as SplitToPartsOfExactlyNPositions
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ], [ 10, 10 ] ]

? @@( o1.SplitToPartsOfNPositionsXT(3) ) + NL # XT ~> adds the remaining part
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ], [ 10, 10 ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.21

/*---

pr()

o1 = new stzSplitter(12)
? @@( o1.SplitToPartsOfNPositions(5) )
#--> [ [ 1, 5 ], [ 6, 10 ], [ 11, 12 ] ]

? @@( o1.SplitToPartsOfExactlyNPositions(5) )
#--> [ [ 1, 5 ], [ 6, 10 ] ]

pf()
# Executed in 0.09 second(s)

/*==================

pr()

# Softanza is designed with Programmer Experience in mind.

# We all forget a function syntax and how parameters should
# be organized. We could make a trial or two before that
# hopefully works. Or we interrup the programming process
# and turn to documentation to get help...

# To avoid that, Softanza usually incorporates many alternatives
# of the same function. This allows it to be flexible and permissive:
# Whatever comes to your mind expressing your intent, the library
# will do its best to understand it and execute it!

# All the following formulations lead to the same result:
# splitting at a some positions given by a conditional expression...

o1 = new stzList( 1:10 )

? @@( o1.SplittedWXT( 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

? @@( o1.SplittedWXT( :Where = 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

? @@( o1.SplittedWXT( :At = 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

? @@( o1.SplittedAtWXT( :Where = 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

? @@( o1.SplittedAtWXT( 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

? @@( o1.SplittedWXT( :Before = 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 3, 5 ], [ 6, 8 ], [ 9, 10 ] ]

? @@( o1.SplittedBeforeWXT( 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 3, 5 ], [ 6, 8 ], [ 9, 10 ] ]

? @@( o1.SplittedBeforeWXT( :Where = 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2 ], [ 3, 5 ], [ 6, 8 ], [ 9, 10 ] ]

? @@( o1.SplittedWXT( :After = 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ], [ 10 ] ]

? @@( o1.SplittedAfterWXT( 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ], [ 10 ] ]

? @@( o1.SplittedAfterWXT( :Where = 'Q(@position).IsMultipleOf(3)' ) )
#--> [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ], [ 10 ] ]

pf()
# Executed in 0.82 second(s) in Ring 1.22

/*==================
*/
pr()

# Used internally by Softanza, but could be useful...

o1 = new stzSplitter(10)
? @@( o1.GetPairsFromPositions([3, 6, 8]) )
#--> [ [ 1, 3 ], [ 3, 6 ], [ 6, 8 ], [ 8, 10 ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
