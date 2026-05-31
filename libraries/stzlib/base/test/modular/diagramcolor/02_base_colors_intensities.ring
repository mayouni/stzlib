# Narrative
# --------
# Base colors Intensities
#
# Extracted from stzdiagramcolortest.ring, block #2.

load "../../../stzBase.ring"


pr()

# Grayscale
? "--- GRAYSCALE ---"
? "white--    : " + ResolveColor("white--")
? "white-     : " + ResolveColor("white-")
? "white      : " + ResolveColor("white")
? "white+     : " + ResolveColor("white+")
? "white++    : " + ResolveColor("white++")
? ""

? "black--    : " + ResolveColor("black--")
? "black-     : " + ResolveColor("black-")
? "black      : " + ResolveColor("black")
? "black+     : " + ResolveColor("black+")
? "black++    : " + ResolveColor("black++")
? ""

? "gray--     : " + ResolveColor("gray--")
? "gray-      : " + ResolveColor("gray-")
? "gray       : " + ResolveColor("gray")
? "gray+      : " + ResolveColor("gray+")
? "gray++     : " + ResolveColor("gray++")
? NL

# Primary Colors
? "--- PRIMARY COLORS ---"
? "red--      : " + ResolveColor("red--")
? "red-       : " + ResolveColor("red-")
? "red        : " + ResolveColor("red")
? "red+       : " + ResolveColor("red+")
? "red++      : " + ResolveColor("red++")
? ""

? "green--    : " + ResolveColor("green--")
? "green-     : " + ResolveColor("green-")
? "green      : " + ResolveColor("green")
? "green+     : " + ResolveColor("green+")
? "green++    : " + ResolveColor("green++")
? ""

? "blue--     : " + ResolveColor("blue--")
? "blue-      : " + ResolveColor("blue-")
? "blue       : " + ResolveColor("blue")
? "blue+      : " + ResolveColor("blue+")
? "blue++     : " + ResolveColor("blue++")
? ""

? "yellow--   : " + ResolveColor("yellow--")
? "yellow-    : " + ResolveColor("yellow-")
? "yellow     : " + ResolveColor("yellow")
? "yellow+    : " + ResolveColor("yellow+")
? "yellow++   : " + ResolveColor("yellow++")
? NL

# Secondary Colors
? "--- SECONDARY COLORS ---"

? "orange--   : " + ResolveColor("orange--")
? "orange-    : " + ResolveColor("orange-")
? "orange     : " + ResolveColor("orange")
? "orange+    : " + ResolveColor("orange+")
? "orange++   : " + ResolveColor("orange++")
? ""

? "purple--   : " + ResolveColor("purple--")
? "purple-    : " + ResolveColor("purple-")
? "purple     : " + ResolveColor("purple")
? "purple+    : " + ResolveColor("purple+")
? "purple++   : " + ResolveColor("purple++")
? ""

? "cyan--     : " + ResolveColor("cyan--")
? "cyan-      : " + ResolveColor("cyan-")
? "cyan       : " + ResolveColor("cyan")
? "cyan+      : " + ResolveColor("cyan+")
? "cyan++     : " + ResolveColor("cyan++")
? ""

? "magenta--  : " + ResolveColor("magenta--")
? "magenta-   : " + ResolveColor("magenta-")
? "magenta    : " + ResolveColor("magenta")
? "magenta+   : " + ResolveColor("magenta+")
? "magenta++  : " + ResolveColor("magenta++")
? NL

# Extended Palette
? "--- EXTENDED PALETTE ---"

? "brown--    : " + ResolveColor("brown--")
? "brown-     : " + ResolveColor("brown-")
? "brown      : " + ResolveColor("brown")
? "brown+     : " + ResolveColor("brown+")
? "brown++    : " + ResolveColor("brown++")
? ""

? "pink--     : " + ResolveColor("pink--")
? "pink-      : " + ResolveColor("pink-")
? "pink       : " + ResolveColor("pink")
? "pink+      : " + ResolveColor("pink+")
? "pink++     : " + ResolveColor("pink++")
? ""

? "coral--    : " + ResolveColor("coral--")
? "coral-     : " + ResolveColor("coral-")
? "coral      : " + ResolveColor("coral")
? "coral+     : " + ResolveColor("coral+")
? "coral++    : " + ResolveColor("coral++")
? ""

? "teal--     : " + ResolveColor("teal--")
? "teal-      : " + ResolveColor("teal-")
? "teal       : " + ResolveColor("teal")
? "teal+      : " + ResolveColor("teal+")
? "teal++     : " + ResolveColor("teal++")
? ""

? "lavender-- : " + ResolveColor("lavender--")
? "lavender-  : " + ResolveColor("lavender-")
? "lavender   : " + ResolveColor("lavender")
? "lavender+  : " + ResolveColor("lavender+")
? "lavender++ : " + ResolveColor("lavender++")

#-->
'
--- GRAYSCALE ---
white--      : #FFFFFF
white-       : #FFFFFF
white        : #FFFFFF
white+       : #333333
white++      : #0C0C0C

black--      : #E0E0E0
black-       : #A3A3A3
black        : #000000
black+       : #000000
black++      : #000000

gray--       : #EFEFEF
gray-        : #D1D1D1
gray         : #808080
gray+        : #656565
gray++       : #333333


--- PRIMARY COLORS ---
red--       : #FFE0E0
red-        : #FFA3A3
red         : #FF0000
red+        : #C94D4D
red++       : #660000

green--     : #E0EFE0
green-      : #A3D1A3
green       : #008000
green+      : #4D654D
green++     : #003300

blue--      : #E0E0FF
blue-       : #A3A3FF
blue        : #0000FF
blue+       : #4D4DC9
blue++      : #000066

yellow--    : #FFFFE0
yellow-     : #FFFFA3
yellow      : #FFFF00
yellow+     : #333300
yellow++    : #0C0C00


--- SECONDARY COLORS ---
orange--    : #FFF4E0
orange-     : #FFDEA3
orange      : #FFA500
orange+     : #332100
orange++    : #0C0800

purple--    : #EFE0EF
purple-     : #D1A3D1
purple      : #800080
purple+     : #654D65
purple++    : #330033

cyan--      : #E0FFFF
cyan-       : #A3FFFF
cyan        : #00FFFF
cyan+       : #003333
cyan++      : #000C0C

magenta--   : #FFE0FF
magenta-    : #FFA3FF
magenta     : #FF00FF
magenta+    : #C94DC9
magenta++   : #660066


--- EXTENDED PALETTE ---
brown--    : #F4E5E5
brown-     : #DEB2B2
brown      : #A52A2A
brown+     : #822121
brown++    : #421010

pink--     : #FFF7F8
pink-      : #FFE8EC
pink       : #FFC0CB
pink+      : #332628
pink++     : #0C090A

coral--    : #FFEFEA
coral-     : #FFD0C0
coral      : #FF7F50
coral+     : #331910
coral++    : #0C0604

teal--     : #E0EFEF
teal-      : #A3D1D1
teal       : #008080
teal+      : #4D6565
teal++     : #003333

lavender-- : #FCFCFE
lavender-  : #F6F6FD
lavender   : #E6E6FA
lavender+  : #2E2E32
lavender++ : #0B0B0C
'

pf()
# Executed in 0.13 second(s) in Ring 1.25
