# Narrative
# --------
# # Now, let's see how diacritics can be removed from a french text
#
# Extracted from stzTtexttest.ring, block #9.

load "../../../stzBase.ring"

? StzStringQ("C'était un énoncé accentuée, à vrai-dire, extrâ!").DiacriticsRemoved()
# and than from an arabic text
? StzStringQ("السَّلَامُ عَلَيْكُمْ").DiacriticsRemoved()

# Which is a useful feature when you are building the index of a search
# application, since diacritics corrospond to sound variations of the
# main letters.
