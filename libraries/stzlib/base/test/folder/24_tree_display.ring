# Narrative
# --------
# Folder Tree Display
#
# Extracted from stzfoldertest.ring, block #24.
# Portable: runs against the local testarea fixture.
#
# Softanza embraces a visual grammar for folder-tree display that is both
# expressive and practical. The grammar lives in the class's @acDisplayChars
# attribute:
#
#   tree lines : │ (vertical)  ├ (tick)  ╰ (closing)
#   file       :  🗋 (default, leading space)   📄 (when found)
#   root       : 🗀 (Show)     📁 (ShowXT, with a stat label on the right)
#   expanded   : 🗁 (no found files)   📂 (found files inside)
#   closed     : 🗀 (empty)    🖿 (has files)
#   viz search : 🎯 in the root label, 👉 before each found file
#
# NOTE: child names are presented in lowercase regardless of their on-disk
# case (the listing convention); the root keeps its real case.

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t24"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)

# The tree (first-level folders collapsed by default)

? o1.Show()
#--> root + first level; 🗀 = empty folder, 🖿 = non-empty folder

# With meta-statistics

? o1.ShowXT()
#--> 📁 root with the default '@count' stat in parentheses per folder

? o1.DisplayStat() + NL
#--> @count

# Change the stat pattern

o1.SetDisplayStat('@CountFiles files, @CountFolders folders')
? o1.ShowXT()
#--> the stat now reads "<n> files, <m> folders" per folder

# A more granular pattern (surface:deep)

o1.SetDisplayStat('@CountFiles:@DeepCountFiles files, @CountFolders:@DeepCountFolders folders')
? o1.ShowXT()
#--> root reads "1:7 files, 5:7 folders" (7 files / 7 folders in all levels)

# Expand only the images branch

o1.ExpandFolder("/images/")
? o1.ShowXT()
#--> images is expanded (🗁), its children listed; other folders collapsed

# Expand both images and tempo (no stats this time)

o1.ExpandFolders([ "images", "tempo" ])
? o1.Show()

# Showing again keeps the last display options
? o1.Show()

# Expand images and its notes subfolder

o1.Collapse()
o1.ExpandFolders([ "/images/", "/images/notes/" ])
? o1.Show()

# Same effect in one call with DeepExpandFolder

o1.Collapse()
o1.DeepExpandFolder("images")
? o1.Show()

# Expand the whole tree at once

o1.DeepExpandAll()
? o1.ShowXT() # now with statistics

# And collapse everything to return to the starting state

o1.CollapseAll() # Same as Collapse()
? o1.ShowXT()

# Softanza does visual exploration AND visual search:

? o1.VizSearch("*.txt")
#--> 🗀 root (🎯 1 matches ...) with test.txt marked 👉 (surface only)

? o1.VizDeepSearch("*.txt")
#--> 🗀 root (🎯 5 matches ...) with every .txt marked 👉 across the tree

KillTestArea(cTA)

pf()
# Executed in 0.24 second(s) in Ring 1.23
