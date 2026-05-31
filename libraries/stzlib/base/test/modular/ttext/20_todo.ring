# Narrative
# --------
# TODO
#
# Extracted from stzTtexttest.ring, block #20.

load "../../../stzBase.ring"


# Besides this, and for total control on how Softanza does its job,
# other useful instructions are provided to fine-tune the inherent
# words identification process (see examples below).

# Like their StopWordsMustBeRemoved() and StopWordsMustNotBeRemoved()
# sister instructions, they are defined at the global level, to make
# them easy to use, and will affect any function related to words,
# like NumberOfWords(), FindWords(), Words(), ReplaceWord(), etc.

? CharsAllowedInStartOfWord()
? CharsNotAllowedInStartOfWord()
? SubstringsAllowedInStartOfWord()
? SubstringsNotAllowedInStartOfWord()
? "---"
? CharsAllowedInsideWord()
? CharsNotAllowedInsideWord()
? SubstringsAllowedInsideWord()
? SubstringsNotAllowedInsideWord()
? "---"
? CharsAllowedInEndOfWord()
? CharsNotAllowedInEndOfWord()
? SubstringsAllowedInEndOfWord()
? SubstringsNotAllowedInEndOfWord()

# Hence, those instructions define what king of chars,
# in plus of letters themselves, should be considered
# by softanza in identifying words...
