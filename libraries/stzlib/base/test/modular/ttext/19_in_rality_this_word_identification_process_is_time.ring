# Narrative
# --------
# # In rality, this word identification process is time-consuming for
#
# Extracted from stzTtexttest.ring, block #19.

load "../../../stzBase.ring"

# large texts. This will be enhanced in the future, but for now,
# you can instruct Softanza to adopt a quicker route, with less
# constraints, by using one of these two nstructions:

IdentifiyWordsInQuickMode()

str = StzStringQ('').FromURL("https://ring-lang.github.io/doc1.16/qt.html")
? StzTextQ(str).Words() #--> [ ... ]

# Quiet quick, isn't it? But if we say:

IdentifyWordsInStrictMode()
? StzTextQ(str).Words() #--> [ ... ]

# Then you will get a more accurate result but takes mutch more time!

# The idea is that library lets you make your own choice and think of
# the acceptable balance, for you actual needs, between accuracy
# and performance!
