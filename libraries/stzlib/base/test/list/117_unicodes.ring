# Narrative
# --------
# Unicodes() over a list: a recursive, structure-preserving codepoint map.
#
# Each item is mapped by kind: a number is echoed as-is (Q(1:3).Unicodes()
# -> [ 1, 2, 3 ]); a single-character string becomes its scalar codepoint
# ("a" -> 97); a MULTI-character string expands into the sublist of its
# per-character codepoints ("How" -> [ 72, 111, 119 ]); and a nested list is
# walked recursively, so the original nesting depth is mirrored in the result
# ([ "a", [ 1, [ "b", [ "ring" ] ], 2 ], "d" ] keeps its shape). The string
# decomposition rides the engine-backed, codepoint-correct stzString path.
#
# Extracted from stzlisttest.ring, block #117.

load "../../stzBase.ring"

pr()

? Q(1:3).Unicodes()
#--> [1, 2, 3]

? Unicodes([2, 3])
#--> [2, 3]

? Unicodes([ "a", "b", "c" ])
#--> [97, 98, 99]

? @@( Unicodes([ "How", "are", "you?" ]) )
#--> [ [ 72, 111, 119 ], [ 97, 114, 101 ], [ 121, 111, 117, 63 ] ]

? @@( Unicodes([ "A", "HI", [ 1, 2 ] ]) )
#--> [ 65, [ 72, 73 ], [ 1, 2 ] ]

? @@( Unicodes([ "a", [ 1, ["b","c"], 2], "d" ]) )
#--> [ 97, [ 1, [ 98, 99 ], 2 ], 100 ]

? @@( Unicodes([ "a", [ 1, ["b", [ "ring" ] ], 2 ], "d" ]) )
#--> [ 97, [ 1, [ 98, [ [ 114, 105, 110, 103 ] ] ], 2 ], 100 ]

pf()
# Executed in 0.05 second(s) in Ring 1.21
