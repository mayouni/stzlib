# Narrative
# --------
# VISUAL FINDING
#
# Extracted from stzfoldertest.ring, block #29.

load "../../../stzBase.ring"

pr()

o1 = new stzFolder("C:\TestArea")

# VizSearching images in png format
o1.SetDisplayOrder(:FileFirstAscending)
? o1.VizSearchFiles("*.png") + NL
#-->
"
📁 TestArea (🔍 0 file matches for '*.png')
├─📁 Docs
├─🔍📁 Images
│  ╰─🎯📄 image.png
├─📁 Music
├─📁 NewlyAdded
├─📁 Videos
╰─📄 test.txt
"

# VizSearching folders with an 'i' letter in their name

? o1.VizSearchFolders("*i*")

pf()

#===================#
#  UTILITY METHODS  #
#===================#
