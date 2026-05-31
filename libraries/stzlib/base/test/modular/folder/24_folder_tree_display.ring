# Narrative
# --------
# Folder Tree Display
#
# Extracted from stzfoldertest.ring, block #24.

load "../../../stzBase.ring"

pr()

# Softanza embraces a visual grammer for folder tree display
# that is both expressive and practical.

# the grammer can be understood from the @aDisplatChars attribute
# you can find in the class and here is its content:
#
#	@acDisplayChars = [
#
#		# The folder tree lines use these chars
#		:VerticlalChar = "│",
#		:VerticalCharTick = "├",
#		:ClosingChar = "╰",
#
#		# File uses one of these two icons
#		:File = " 🗋",		# file icon by default with a space to enforce it's not a folder
#		:FileFound = "📄",	# file icon when a file is found
#
#		# Root folder uses one of these two icons
#		:FolderRoot = "🗀",		# folder icon by default (when Show() is used)
#		:FolderRootXT = "📁",	# folder icon when ShowXT() is used and an info
#								# is added between parenthesis to the right
#
#		# An expanded folder uses one of these two icons
#		:FolderOpened = "🗁",		# when no found files exists inside it
#		:FolderOpenedFound = "📂",	# when files are found inside it
#
#		# A closed folder uses one of these two icons
#		:FolderClosedEmpty = "🗀", 	# when the folder is empty
#		:FolderClosedFull = "🖿",	# when the folder contains files
#
#		# After a VizSearch use this icon in the root stat label
#		:FolderRootSearchSymbol = "",
#
#		# Each found file is proceeded by this icon
#		:FileFoundSymbol = "👉"
#
#	]

#NOTE Softanza enforce the files and folders names to be all in lowercase,
# regardless of the actual case they have on the file system!

# Here is an example:

o1 = new stzFolder("d:/ring124")

# Showing the tree structure (first level folders collapsed by default)

? o1.Show()
#-->
'
🗀 testarea
├─ 🗋 test.txt
├─🗀 docs	# <-- 🗀 means the folder is empty
├─🖿 images # <-- 🖿 means the folder is not empty
├─🗀 music
├─🖿 tempo
╰─🗀 videos
'

# Showing meta-statistics

? o1.ShowXT()
#-->
'
📁 testarea (6) # <-- 📁~> XT mode / contains 6 elements at its root (files + folders)
├─ 🗋 test.txt
├─🗀 Docs
├─🖿 images (4) # This subfolder contains 4 elements at its root
├─🗀 music
├─🖿 tempo (2)
╰─🗀 videos
'

# The (6)n (4) and (2) are actually calucolated base on a default stat pattern

? o1.DisplayStat() + NL
#--> '@count'

# Let's change that stats pattern

o1.SetDisplayStat('@CountFiles files, @CountFolders folders')
? o1.ShowXT()
'
📁 testarea (1 files, 5 folders)	# <-- Your stats added here
├─ 🗋 test.txt
├─🗀 docs
├─🖿 images (2 files, 2 folders)	# <-- and here
├─🗀 music
├─🖿 tempo (2 files)				# <-- and here
╰─🗀 videos
'

# More granular dipaly pattern

o1.SetDisplayStat('
	@CountFiles:@DeepCountFiles files,
	@CountFolders:@DeepCountFolders folders
')

? o1.ShowXT()
#-->
'
📁 testarea (1:7 files, 5:7 folders)
├─ 🗋 test.txt
├─🗀 docs
├─🖿 images (2:4 files, 2:2 folders)
├─🗀 music
├─🖿 tempo (2:2 files)
╰─🗀 videos
'
#~> The maine folder contains 7 files in all levels, 1 of them is in the root.
#~> And it contains 7 sibfolders in all levels, 5 of them are in the root.

# Expanding the Image folder

o1.ExpandFolder("/images/")
? o1.ShowXT()
#-->
'
📁 testarea (1:7 files, 5:7 folders)
├─ 🗋 test.txt
├─🗀 docs
├─🗁 images (2:4 files, 2:2 folders) # Only this folder is expanded
│ ├─ 🗋 image1.png
│ ├─ 🗋 image2.png
│ ├─🗀 more				 # Subfolder "more" is not expanded (empty)
│ ╰─🖿 notes (2:2 files) # Subfolders of Images are not expanded
├─🗀 music
├─🖿 tempo (2:2 files)
╰─🗀 videos
'

# Expanding both "Images" and "Tempo" (without stats this time)

o1.ExpandFolders([ "images", "tempo" ])
? o1.Show()
#-->
'
🗀 testarea
├─ 🗋 test.txt
├─🗀 docs
├─🗁 images
│ ├─ 🗋 image1.png
│ ├─ 🗋 image2.png
│ ├─🗀 more
│ ╰─🖿 notes
├─🗀 music
├─🗁 tempo
│ ├─ 🗋 temp1.txt
│ ╰─ 🗋 temp2.txt
╰─🗀 videos
'

# NOTE: if you you show the tree again it maintaines the last
# display options and displays the same thing

? o1.Show()
'
🗀 testarea
├─ 🗋 test.txt
├─🗀 docs
├─🗁 images
│ ├─ 🗋 image1.png
│ ├─ 🗋 image2.png
│ ├─🗀 more
│ ╰─🖿 notes
├─🗀 music
├─🗁 tempo
│ ├─ 🗋 temp1.txt
│ ╰─ 🗋 temp2.txt
╰─🗀 videos
'

# Expanding "Images" and its "notes" subfolder

o1.Collapse()
o1.ExpandFolders([ "/images/", "/images/notes/" ])
? o1.Show()
#-->
'
🗀 testarea
├─ 🗋 test.txt
├─🗀 docs
├─🗁 images
│ ├─ 🗋 image1.png
│ ├─ 🗋 image2.png
│ ├─🗀 more
│ ╰─🗁 notes
│   ├─ 🗋 howto.txt
│   ╰─ 🗋 sources.txt
├─🗀 music
├─🖿 tempo
╰─🗀 videos
'

# Aternatively we can exapand the folder Imaages and all it's subfolders
# in one call using DeepExpandFolder() method like this:

o1.Collapse()
o1.DeepExpandFolder("Images")
? o1.Show()
#-->
'
🗀 testarea
├─ 🗋 test.txt
├─🗀 Docs
├─🗁 Images
│ ├─ 🗋 image1.png
│ ├─ 🗋 image2.png
│ ├─🗁 more
│ ╰─🗁 notes
│   ├─ 🗋 howto.txt
│   ╰─ 🗋 sources.txt
├─🗀 Music
├─🗀 Videos
╰─🖿 tempo
'

# Let's expand all the folder tree in one shot:

o1.DeepExpandAll()
? o1.ShowXT() # Now with statistics
#-->
'
📁 testarea (1:7 files, 5:7 folders)
├─ 🗋 test.txt
├─🗁 docs
├─🗁 images (2:4 files, 2:2 folders)
│ ├─ 🗋 image1.png
│ ├─ 🗋 image2.png
│ ├─🗁 more
│ ╰─🗁 notes (2:2 files)
│   ├─ 🗋 howto.txt
│   ╰─ 🗋 sources.txt
├─🗁 music
├─🗁 tempo (2:2 files)
│ ├─ 🗋 temp1.txt
│ ╰─ 🗋 temp2.txt
╰─🗁 videos
'

# And collapse everything again to finish with the status we started with

o1.CollapseAll() # Same as collapse()
? o1.ShowXT()
#-->
'
📁 testarea (1:7 files, 5:7 folders)
├─ 🗋 test.txt
├─🗀 docs
├─🖿 images (2:4 files, 2:2 folders)
├─🗀 music
├─🖿 tempo (2:2 files)
╰─🗀 videos
'

# Softanza does visual exploration as well as visual search!

? o1.VizSearch("*.txt")
#-->
"
🗀 testarea (🎯 1 matches for '*.txt')
├─ 🗋👉 test.txt # It's here
├─🗀 docs
├─📂 images (2)
├─🗀 music
├─📂 tempo (2)
╰─🗀 videos
"

# But there are more txt files deeper in the tree!

? o1.VizDeepSearch("*.txt")
#-->
"
🗀 testarea (🎯5 matches for '*.txt')
├─ 🗋👉 test.txt	
├─🗀 docs
├─📂 images (2)
│ ├─ 🗋 image1.png
│ ├─ 🗋 image2.png
│ ├─🗀 more
│ ╰─📂 notes (2)
│   ├─ 🗋👉 howto.txt
│   ╰─ 🗋👉 sources.txt
├─🗀 music
├─📂 tempo (2)
│ ├─ 🗋👉 temp1.txt
│ ╰─ 🗋👉 temp2.txt
╰─🗀 videos
"


pf()
# Executed in 0.24 second(s) in Ring 1.22
