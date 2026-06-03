
load "../stzbase.ring"

#===========================================================#
#  TESTING THE COLOR SYSTEM - USED CURRENTLY BU stzDiagram  #
#===========================================================#

/*--- Base Colors

pr()

? ResolveColor(:red)      #--> #FF0000
? ResolveColor(:blue)     #--> #0000FF
? ResolveColor(:green)    #--> #008000
? ResolveColor(:yellow)   #--> #FFFF00
? ResolveColor(:white)    #--> #FFFFFF
? ResolveColor(:black)    #--> #000000
? ResolveColor(:gray)     #--> #808080

pf()
# Executed in 0.03 second(s) in Ring 1.25

/*--- Base colors Intensities

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

/*--- Semantic Colors

pr()

? ResolveColor(:Success)  # Should resolve to green
#--> #008000

? ResolveColor(:Warning)  # Should resolve to yellow
#--> #FFFF00

? ResolveColor(:Danger)   # Should resolve to red
#--> #FF0000

? ResolveColor(:Info)     # Should resolve to blue
#--> #0000FF

? ResolveColor(:Primary)  # Should resolve to blue
#--> #0000FF

? ResolveColor(:Neutral)  # Should resolve to gray
#--> #808080

pf()
# Executed in 0.04 second(s) in Ring 1.25

/*--- Node Type Colors

pr()

? ColorForNodeType(:Start)        # Should be green
#--> #008000

? ColorForNodeType(:Process)      # Should be blue
#--> #0000FF

? ColorForNodeType(:Decision)     # Should be yellow
#--> #FFFF00

? ColorForNodeType(:Endpoint)     # Should be coral
#--> #FF7F50

? ColorForNodeType(:State)        # Should be cyan
#--> #00FFFF

? ColorForNodeType(:Storage)      # Should be gray
#--> #808080

? ColorForNodeType(:Data)         # Should be lavender
#--> #E6E6FA

pf()
# Executed in 0.03 second(s) in Ring 1.25

/*--- Direct Hex Colors

pr()

? ResolveColor("#FF5733")  #--> #FF5733
? ResolveColor("#00AAFF")  #--> #00AAFF
? ResolveColor("#123456")  #--> #123456

pf()
# Executed in 0.02 second(s) in Ring 1.25

/*--- Extended Palette

pr()

? ResolveColor(:brown)     #--> #A52A2A
? ResolveColor(:pink)      #--> #FFC0CB
? ResolveColor(:navy)      #--> #000080
? ResolveColor(:teal)      #--> #008080
? ResolveColor(:coral)     #--> #FF7F50
? ResolveColor(:salmon)    #--> #FA8072
? ResolveColor(:lavender)  #--> #E6E6FA
? ResolveColor(:steelblue) #--> #4682B4

pf()
# Executed in 0.03 second(s) in Ring 1.25

/*--- Full Intensity Chain: Coral

pr()

? ResolveColor("coral--")	#--> #FFEFEA
? ResolveColor("coral-")	#--> #FFD0C0
? ResolveColor("coral")		#--> #FF7F50
? ResolveColor("coral+")	#--> #331910
? ResolveColor("coral++")	#--> #0C0604

pf()
# Executed in 0.02 second(s) in Ring 1.25

/*--- Full Intensity Chain: Teal

pr()

? ResolveColor("teal--")	#--> #E0EFEF
? ResolveColor("teal-")		#--> #A3D1D1
? ResolveColor("teal")		#--> #008080
? ResolveColor("teal+")		#--> #4D6565
? ResolveColor("teal++")	#--> #003333

pf()
# Executed in 0.02 second(s) in Ring 1.25

/*--- Legacy Color Names

pr()

? ResolveColor(:lightblue)   # Should map to blue+
#--> #4D4DC9

? ResolveColor(:lightgreen)  # Should map to green+
#--> #4D654D

? ResolveColor(:lightyellow) # Should map to yellow+
#--> #333300

? ResolveColor(:darkgreen)   # Should map to green-
#--> #A3D1A3

? ResolveColor(:darkblue)    # Should map to blue-
#--> #A3A3FF

? ResolveColor(:darkred)     # Should map to red-
#--> #FFA3A3

pf()
# Executed in 0.04 second(s) in Ring 1.25

/*--- Full Palette Count

pr()

aPalette = BuildColorPalette()
? len(aPalette)
#--> 125

pf()
# Executed in 0.02 second(s) in Ring 1.25
