# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #110.

load "../../stzBase.ring"

pr()

? Q("ı").Unicode()
#--> 305

? Q("ȷ").Unicode()
#--> 567

? Q("abc").Unicodes()
#--> [ 97, 98, 99 ]

? Q([ "a", "b", "c" ]).Unicodes()
#--> [ 97, 98, 99 ]

? Q("a").HexUnicode()
#--> U+0061

? Q("abc").HexUnicodes()
#--> [ 'U+0061', 'U+0062', 'U+0063' ]

? Q([ "a", "b", "c" ]).HexUnicodes()
#--> [ 'U+0061', 'U+0062', 'U+0063' ]

? @@( Q([ "a", "bcd", "e" ]).Unicodes() )
#--> [ 97, [ 98, 99, 100 ], 101 ]

? @@( Q([ "a", "bcd", "e" ]).HexUnicodes() )
#--> [ "U+0061", [ "U+0062", "U+0063", "U+0064" ], "U+0065" ]

? Unicodes("abc")
#--> #--> [ 97, 98, 99 ]

? HexUnicodes("abc")
#--> [ 'U+0061', 'U+0062', 'U+0063' ]

pf()
# Executed in 0.33 second(s)
