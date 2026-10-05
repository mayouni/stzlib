# defects found by probing, stzStringChar / stzChar / stzStringList (code, not comments; none fixed)

stzStringChar (method: symptom: cause)
- HexUnicode: U+F600 for U+1F600: keeps four hex digits only
- Update(number): leaves content "" and Unicode 0: StzEngineCharToUtf8 called with a buffer that is never filled (init with a number works); UpdateWith/By/Using share it; Update("ab") stores two chars, no one-char check
- CanRetrieveName: raises for an unnamed code (U+0378), never FALSE: asks Name(), which raises
- AsciiCode (non-ASCII): R3 stzcharerror: the catch branch calls an undefined function
- IsLeftToRightIsolate, IsRightToLeftIsolate: always "": body is a comment
- IsEuropean: R14: calls IsEuropeanNumber, defined nowhere
- IsUnicodeNumber: TRUE for Lo/Lt/Lm letters (Arabic, Hebrew, CJK), FALSE for 7: tests category codes 3,4,5 (letters) where digits are 9-11
- IsArabicNumber: FALSE for 0-9, R41 for any non-ASCII digit: ring_find of a number in a list of digit texts; 0+Content
- Mirrored: R3: CharFromUnicode defined nowhere
- IsBasicLatin, IsBasicArabic: R24: _anBasicLatinUnicodes / _anBasicArabicUnicodes not defined (data has _anLatinBasicUnicodes)
- IsCircledLatinSmallLetter, IsCircledLatinCapitalLetter: R24: variables _aCircledLatin*Unicodes read directly, not defined
- IsOtherCircledChar: R3: OtherCircledCharUnicodes defined nowhere
- IsPrintable / IsNonPrintable: FALSE for digits, hyphen, Roman numerals; TRUE for control chars: rejects category codes 9-13 instead of 26-29
- IsLocaleSeparator: returns 1 for -, 2 for _ (a find position), not TRUE
- IntroducedInUnicodeVersion: "0.9" for nearly all, "3.2" for emoji: coarse block table, #TODO in stzCharData.ring
- DefaultLanguage: raises "Can not create char object!" for Inherited/Unknown script chars (combining marks, unassigned, private use)
- TaiThamScript: R14: calls ScriptCode(), retired
- Orientation: rtl for the shaddah and U+FEFF while UnicodeDirection says nonspacingmark / boundaryneutral (two judgments, not a bug as such)
stzStringList
- ConcatXT(:Using = x): R14 isusingnamedparam: stzList.IsUsingNamedParam does not exist (ConcatXT is not a root: noted only)
- SortBy: @item raises R24; a text key raises R41: only numeric keys work, @string is the only variable
- Matches: answers one TRUE/FALSE for the whole list (all strings match as a whole), the old comment said it returns the matching strings
- SimilarTo / SimilarToCS: the case flag is ignored (not read in the body)
- DuplicatedStringsCS(0): returns the case-folded spelling of the duplicates, not the original
- RemoveAt / RemoveStringAtPosition: the first raises for a bad position, the second ignores it silently (inconsistent)
