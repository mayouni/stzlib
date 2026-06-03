# Narrative
# --------
# pr()
#
# Extracted from stzSsplittertest.ring, block #9.

load "../../stzBase.ring"

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
