# Narrative
# --------
# Ring dir() and Softanza @dir()
#
# Extracted from stzfoldertest.ring, block #23.
# Portable: runs against the local testarea fixture (built with MIXED-CASE
# folder names: Docs, Images, Music, Videos).

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t23"
BuildTestArea(cTA)

# Ring's dir() returns entries in their on-disk case

? @@NL( ring_dir(cTA) )
#--> entries with their real case, e.g. [ "Docs", 1 ], [ "Images", 1 ],
#    [ "test.txt", 0 ], [ "Videos", 1 ], ...

# Softanza's @dir() lowercases the entry names (the listing convention)

? @@NL( @dir(cTA) )
#--> the same entries, names lowercased: [ "docs", 1 ], [ "images", 1 ],
#    [ "test.txt", 0 ], [ "videos", 1 ], ...

# NOTE: 1 means the entry is a folder, 0 means it is a file.

RemoveTestArea(cTA)

pf()
# Executed in almost 0 second(s) in Ring 1.23
