# Narrative
# --------
# Ring dir() and Softanza @dir()
#
# Extracted from stzfoldertest.ring, block #23.

load "../../../stzBase.ring"


pr()

# In Ring, the dir() functions returns the folders
# in the same case they have in the file system

? @@NL( ring_dir("c:/testarea") )
#-->
'
[
	[ "Docs", 1 ],
	[ "Images", 1 ],
	[ "more", 1 ],
	[ "Music", 1 ],
	[ "notes", 1 ],
	[ "tempo", 1 ],
	[ "test.txt", 0 ],
	[ "Videos", 1 ]
]
'

# While in Softanza, the same function is tuned to return
# all the folders in lowercase by using @dir() instead

? @@NL( @dir("c:/testarea") )
#-->
'
[
	[ "docs", 1 ],
	[ "images", 1 ],
	[ "more", 1 ],
	[ "music", 1 ],
	[ "notes", 1 ],
	[ "tempo", 1 ],
	[ "test.txt", 0 ],
	[ "videos", 1 ]
]
'

# NOTE: 1 means the entry is a folder and 0 means it is a file.

pf()
# Executed in almost 0 second(s) in Ring 1.22
