#-------------------------------------------------------------------------#
# 		   SOFTANZA LIBRARY (V1.0) - STZUNICODEDATA	          #
# 	An accelerative library for Ring applications, and more!	  #
#-------------------------------------------------------------------------#
#									  #
# 	Description : The class for managing Unicode data in Softanza     #
#	Version	    : V1.0 (2020-2024)				          #
#	Author	    : Mansour Ayouni (kalidianow@gmail.com)		  #
#								          #
#-------------------------------------------------------------------------#

load "stzUnicodeDataInString.ring"
#NOTE I turned back to putting uncide data in a string not a text file
# because the path in load "../data/stzUnicodeData.txt" made me a
# a headake when I refactored the library architecture into 3 layers
# TODO: fix that!

/* GENERAL NOTES

	RATIONALE : Why this class and related large file are necessary
	---------------------------------------------------------------

	The Unicode database is a large file provided by the Unicode foundation here:
	https://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt

	Programming languages and frameworkks supporting Unicode have different
	strategies in including this data. Hence, some of them prefer not including
	it and relying on its presence on the hosting OS where the application runs.

	Qt, includes it internallay, which enables us to have most of the data
	we need (via RingQt). This is really helpful, and it's done, of course, with
	a good performance.

	Unfortunately, some features provided by Softanza are not supported in Qt,
	like for example the fact of getting chars names, or finding chars by their
	names (and not their Unicode codes).

	That's why Softanza included its own copy of the Unicode database.

	In practice, Softanza will use RingQt for any available Unicode feature,
	otherwise its own text file is used (called stzUnicodeData.txt).

	The current file contains a class (stzUnicodeData) with the functions
	added specifically by Softanza. The others can be found in stzChar.ring class.

	DATA STRUCTURE OF THE UNICODE TEXT FILE
	---------------------------------------

	Fields separated by (details here http://www.unicode.org/L2/L1999/UnicodeData.html):

	01. Code value
	02. Character name
	03. General category
	04. Canonical combining classes
	05. Bidirectional category
	06. Character decomposition mapping
	07. Decimal digit value
	08. Digit value
	09. Numeric value
	10. Mirrored
	11. Unicode 1.0 Name
	12. 10646 comment field()
	13. Uppercase mapping
	14. Lowercase mapping
	15. Titlecase mapping

	TODO (futute)
	-------------

	TODO: understand and include this resource (if necessary):
	https://www.unicode.org/Public/UCD/latest/ucd/NameAliases.txt

*/

_nNumberOfUnicodeChars = 149_186

_nMaxUnicode = 1_114_112

_nNumberOfLinesInUnicodeDataFile = 34_931

_cUnicodeData = UnicodeDataInString()

_anMathUnicodes = [
	172, 176, 177, 188, 189, 190, 215, 247, 915, 916, 920, 923,
	926, 928, 931, 933, 934, 936, 937, 945, 946, 947, 948, 949,
	950, 951, 952, 953, 954, 955, 956, 957, 958, 959, 960, 961,
	963, 964, 965, 966, 967, 968, 969, 8531, 8532, 8704, 8706,
	8707, 8709, 8711, 8712, 8713, 8719, 8721, 8730, 8733, 8734,
	8736, 8743, 8744, 8747, 8754, 8756, 8776, 8800, 8801, 8804, 8805
]


_aUnicodeBlocksXT = [
	[ "Basic Latin", [0, 127] ],
	[ "Latin-1 Supplement", [128, 255] ],
	[ "Latin Extended-A", [256, 383] ],
	[ "Latin Extended-B", [384, 591] ],
	[ "IPA Extensions", [592, 687] ],
	[ "Spacing Modifier Letters", [688, 767] ],
	[ "Combining Diacritical Marks", [768, 879] ],
	[ "Greek and Coptic", [880, 1023] ],
	[ "Cyrillic", [1024, 1279] ],
	[ "Cyrillic Supplement", [1280, 1327] ],
	[ "Armenian", [1328, 1423] ],
	[ "Hebrew", [1424, 1535] ],
	[ "Arabic", [1536, 1791] ],
	[ "Syriac", [1792, 1919] ],
	[ "Arabic Supplement", [1920, 1983] ],
	[ "Thaana", [1984, 2047] ],
	[ "NKo", [2048, 2303] ],
	[ "Samaritan", [2304, 2431] ],
	
	[ "Mandaic", [2112, 2143] ],
	[ "Syriac Supplement", [2144, 2159] ],
	[ "Arabic Extended-B", [2176, 2207] ],
	[ "Arabic Extended-A", [2208, 2303] ],
	[ "Devanagari", [2304, 2431] ],
	[ "Bengali", [2432, 2559] ],
	[ "Gurmukhi", [2560, 2687] ],
	[ "Gujarati", [2688, 2815] ],
	[ "Oriya", [2816, 2943] ],
	[ "Tamil", [2944, 3071] ],
	[ "Telugu", [3072, 3199] ],
	[ "Kannada", [3200, 3327] ],
	[ "Malayalam", [3328, 3455] ],
	[ "Sinhala", [3456, 3583] ],
	
	[ "Thai", [3584, 3839] ],
	[ "Lao", [3840, 4095] ],
	[ "Tibetan", [4096, 4351] ],
	[ "Myanmar", [4352, 4383] ],
	[ "Georgian", [4384, 4479] ],
	[ "Hangul Jamo", [4480, 4991] ],
	[ "Ethiopic", [4992, 5119] ],
	[ "Ethiopic Supplement", [5120, 5759] ],
	[ "Cherokee", [5760, 5887] ],
	[ "Unified Canadian Aboriginal Syllabics", [5888, 6143] ],
	[ "Ogham", [6144, 6175] ],
	[ "Runic", [6176, 6269] ],
	[ "Tagalog", [6272, 6319] ],
	[ "Hanunoo", [6320, 6399] ],
	[ "Buhid", [6400, 6479] ],
	[ "Tagbanwa", [6480, 6527] ],
	[ "Khmer", [6528, 6623] ],
	[ "Mongolian", [6624, 6911] ],
	
	[ "Unified Canadian Aboriginal Syllabics Extended", [6320, 6399] ],
	[ "Limbu", [6400, 6479] ],
	[ "Tai Le", [6480, 6527] ],
	[ "New Tai Lue", [6528, 6623] ],
	[ "Khmer Symbols", [6624, 6655] ],
	[ "Buginese", [6656, 6687] ],
	[ "Tai Tham", [6688, 6751] ],
	[ "Combining Diacritical Marks Extended", [6752, 6783] ],
	[ "Balinese", [6912, 7039] ],
	[ "Sundanese", [7040, 7103] ],
	[ "Batak", [7104, 7167] ],
	[ "Lepcha", [7168, 7247] ],
	[ "Ol Chiki", [7248, 7295] ],
	[ "Cyrillic Extended-C", [7296, 7311] ],
	[ "Georgian Extended", [7312, 7359] ],
	[ "Sundanese Supplement", [7360, 7375] ],
	
	[ "Vedic Extensions", [7392, 7423] ],
	[ "Phonetic Extensions", [7424, 7551] ],
	[ "Phonetic Extensions Supplement", [7552, 7615] ],
	[ "Combining Diacritical Marks Supplement", [7616, 7679] ],
	[ "Latin Extended Additional", [7680, 7935] ],
	[ "Greek Extended", [7936, 8191] ],
	[ "General Punctuation", [8192, 8303] ],
	[ "Superscripts and Subscripts", [8304, 8351] ],
	[ "Currency Symbols", [8352, 8399] ],
	[ "Combining Diacritical Marks for Symbols", [8400, 8447] ],
	[ "Letterlike Symbols", [8448, 8527] ],
	[ "Number Forms", [8528, 8591] ],
	[ "Arrows", [8592, 8703] ],
	[ "Mathematical Operators", [8704, 8959] ],
	[ "Miscellaneous Technical", [8960, 9215] ],
	[ "Control Pictures", [9216, 9279] ],
	[ "Optical Character Recognition", [9280, 9311] ],
	
	[ "Enclosed Alphanumerics", [9312, 9471] ],
	[ "Box Drawing", [9472, 9599] ],
	[ "Block Elements", [9600, 9631] ],
	[ "Geometric Shapes", [9632, 9727] ],
	[ "Miscellaneous Symbols", [9728, 9983] ],
	[ "Dingbats", [9984, 10175] ],
	[ "Miscellaneous Mathematical Symbols-A", [10176, 10223] ],
	[ "Supplemental Arrows-A", [10224, 10239] ],
	[ "Braille Patterns", [10240, 10495] ],
	[ "Supplemental Arrows-B", [10496, 10623] ],
	[ "Miscellaneous Mathematical Symbols-B", [10624, 10751] ],
	[ "Supplemental Mathematical Operators", [10752, 11007] ],
	[ "Miscellaneous Symbols and Arrows", [11008, 11263] ],
	[ "Glagolitic", [11264, 11359] ],
	[ "Latin Extended-C", [11360, 11391] ],
	
	[ "Coptic", [11392, 11519] ],
	[ "Georgian Supplement", [11520, 11567] ],
	[ "Tifinagh", [11568, 11647] ],
	[ "Ethiopic Extended", [11648, 11743] ],
	[ "Cyrillic Extended-A", [11744, 11775] ],
	[ "Supplemental Punctuation", [11776, 11839] ],
	[ "CJK Radicals Supplement", [11840, 11903] ],
	[ "Kangxi Radicals", [12032, 12255] ],
	[ "Ideographic Description Characters", [12272, 12287] ],
	[ "CJK Symbols and Punctuation", [12288, 12351] ],
	[ "Hiragana", [12352, 12447] ],
	[ "Katakana", [12448, 12543] ],
	[ "Bopomofo", [12544, 12591] ],
	[ "Hangul Compatibility Jamo", [12592, 12687] ],
	[ "Kanbun", [12688, 12703] ],
	[ "Bopomofo Extended", [12704, 12735] ],
	[ "CJK Strokes", [12736, 12783] ],
	[ "Katakana Phonetic Extensions", [12784, 12799] ],
	
	[ "Enclosed CJK Letters and Months", [12800, 13055] ],
	[ "CJK Compatibility", [13056, 13311] ],
	[ "CJK Unified Ideographs Extension A", [13312, 19893] ],
	[ "Yijing Hexagram Symbols", [19894, 19967] ],
	[ "CJK Unified Ideographs", [19968, 40959] ],
	[ "Yi Syllables", [40960, 42143] ],
	[ "Yi Radicals", [42144, 42191] ],
	[ "Lisu", [42192, 42239] ],
	[ "Vai", [42240, 42559] ],
	[ "Cyrillic Extended-B", [42560, 42655] ],
	[ "Bamum", [42656, 42751] ],
	[ "Modifier Tone Letters", [42752, 42783] ],
	[ "Latin Extended-D", [42784, 43007] ],
	[ "Syloti Nagri", [43008, 43055] ],
	[ "Common Indic Number Forms", [43056, 43071] ],
	[ "Phags-pa", [43072, 43135] ],
	[ "Saurashtra", [43136, 43231] ],
	[ "Devanagari Extended", [43232, 43263] ],
	[ "Kayah Li", [43264, 43311] ],
	[ "Rejang", [43312, 43359] ],
	[ "Hangul Jamo Extended-A", [43360, 43391] ],
	
	[ "Javanese", [42496, 42559] ],
	[ "Myanmar Extended-B", [42560, 42655] ],
	[ "Cham", [42656, 42751] ],
	[ "Myanmar Extended-A", [42752, 42783] ],
	[ "Tai Viet", [42784, 42815] ],
	[ "Meetei Mayek Extensions", [42816, 42847] ],
	[ "Ethiopic Extended-A", [42848, 42879] ],
	[ "Latin Extended-E", [42880, 42943] ],
	[ "Cherokee Supplement", [42944, 42975] ],
	[ "Meetei Mayek", [42976, 43007] ],
	[ "Hangul Syllables", [44032, 55215] ],
	[ "Hangul Jamo Extended-B", [55216, 55295] ],
	[ "High Surrogates", [55296, 56191] ],
	[ "High Private Use Surrogates", [56192, 56319] ],
	[ "Low Surrogates", [56320, 57343] ],
	[ "Private Use Area", [57344, 63743] ],
	[ "CJK Compatibility Ideographs", [63744, 64255] ],
	[ "Alphabetic Presentation Forms", [64256, 64335] ],
	
	[ "Arabic Presentation Forms-A", [64208, 65023] ],
	[ "Variation Selectors", [65024, 65039] ],
	[ "Vertical Forms", [65040, 65055] ],
	[ "Combining Half Marks", [65056, 65071] ],
	[ "CJK Compatibility Forms", [65072, 65103] ],
	[ "Small Form Variants", [65104, 65135] ],
	[ "Arabic Presentation Forms-B", [65136, 65279] ],
	[ "Halfwidth and Fullwidth Forms", [65280, 65519] ],
	[ "Specials", [65520, 65535] ],
	[ "Linear B Syllabary", [65536, 65663] ],
	[ "Linear B Ideograms", [65664, 65791] ],
	[ "Aegean Numbers", [65792, 65855] ],
	[ "Ancient Greek Numbers", [65856, 65919] ],
	
	[ "Ancient Symbols", [66000, 66063] ],
	[ "Phaistos Disc", [66064, 66127] ],
	[ "Lycian", [66176, 66207] ],
	[ "Carian", [66208, 66271] ],
	[ "Coptic Epact Numbers", [66272, 66303] ],
	[ "Old Italic", [66304, 66351] ],
	[ "Gothic", [66352, 66383] ],
	[ "Old Permic", [66384, 66431] ],
	[ "Ugaritic", [66432, 66463] ],
	[ "Old Persian", [66464, 66527] ],
	[ "Deseret", [66560, 66639] ],
	[ "Shavian", [66640, 66687] ],
	[ "Osmanya", [66688, 66735] ],
	[ "Osage", [66736, 66815] ],
	[ "Elbasan", [66816, 66863] ],
	[ "Caucasian Albanian", [66864, 66927] ],
	[ "Vithkuqi", [66928, 66959] ],
	[ "Linear A", [67072, 67455] ],
	[ "Latin Extended-F", [67600, 67647] ],
	[ "Cypriot Syllabary", [67648, 67679] ],
	[ "Imperial Aramaic", [67680, 67711] ],
	
	[ "Palmyrene", [67648, 67679] ],
	[ "Nabataean", [67680, 67711] ],
	[ "Hatran", [67840, 67871] ],
	[ "Phoenician", [67872, 67903] ],
	[ "Lydian", [67968, 67999] ],
	[ "Meroitic Hieroglyphs", [68000, 68095] ],
	[ "Meroitic Cursive", [68096, 68191] ],
	[ "Kharoshthi", [68192, 68223] ],
	[ "Old South Arabian", [68224, 68255] ],
	[ "Old North Arabian", [68256, 68287] ],
	[ "Manichaean", [68288, 68351] ],
	[ "Avestan", [68352, 68415] ],
	[ "Inscriptional Parthian", [68416, 68447] ],
	[ "Inscriptional Pahlavi", [68448, 68479] ],
	[ "Psalter Pahlavi", [68480, 68527] ],
	
	[ "Old Turkic", [68608, 68687] ],
	[ "Old Hungarian", [68736, 68799] ],
	[ "Hanifi Rohingya", [69888, 69967] ],
	[ "Rumi Numeral Symbols", [69840, 69871] ],
	[ "Yezidi", [69824, 69839] ],
	[ "Old Sogdian", [69888, 69967] ],
	[ "Sogdian", [69888, 69967] ],
	[ "Old Uyghur", [69968, 70015] ],
	[ "Chorasmian", [70016, 70111] ],
	[ "Elymaic", [70112, 70143] ],
	[ "Brahmi", [69632, 69759] ],
	[ "Kaithi", [69760, 69839] ],
	[ "Sora Sompeng", [69840, 69887] ],
	[ "Chakma", [69888, 69967] ],
	[ "Mahajani", [69968, 70015] ],
	[ "Sharada", [70016, 70111] ],
	[ "Sinhala Archaic Numbers", [70112, 70143] ],
	[ "Khojki", [70144, 70223] ],
	[ "Multani", [70224, 70271] ],
	[ "Khudawadi", [70272, 70319] ],
	
	[ "Grantha", [69632, 69759] ],
	[ "Newa", [69888, 70015] ],
	[ "Tirhuta", [70016, 70111] ],
	[ "Siddham", [70400, 70527] ],
	[ "Modi", [70528, 70655] ],
	[ "Mongolian Supplement", [70656, 70783] ],
	[ "Takri", [70784, 70879] ],
	[ "Ahom", [70880, 70975] ],
	[ "Dogra", [72064, 72159] ],
	[ "Warang Citi", [72272, 72367] ],
	[ "Dives Akuru", [72272, 72367] ],
	[ "Nandinagari", [72816, 72911] ],
	[ "Zanabazar Square", [72816, 72911] ],
	[ "Soyombo", [72960, 73055] ],
	[ "Unified Canadian Aboriginal Syllabics Extended-A", [72816, 72911] ],
	[ "Pau Cin Hau", [73728, 74751] ],
	[ "Bhaiksuki", [73728, 74751] ],
	[ "Marchen", [73728, 74751] ],
	[ "Masaram Gondi", [73728, 74751] ],
	[ "Gunjala Gondi", [73728, 74751] ],
	
	[ "Makasar", [73312, 73359] ],
	[ "Lisu Supplement", [73360, 73375] ],
	[ "Tamil Supplement", [73376, 73439] ],
	[ "Cuneiform", [73728, 74751] ],
	[ "Cuneiform Numbers and Punctuation", [74752, 74879] ],
	[ "Early Dynastic Cuneiform", [74880, 75071] ],
	[ "Cypro-Minoan", [77824, 78895] ],
	[ "Egyptian Hieroglyphs", [77824, 78895] ],
	[ "Egyptian Hieroglyph Format Controls", [78896, 78911] ],
	[ "Anatolian Hieroglyphs", [82944, 83583] ],
	[ "Bamum Supplement", [92544, 92703] ],
	[ "Mro", [92704, 92767] ],
	[ "Tangsa", [92768, 92799] ],
	[ "Bassa Vah", [92800, 92879] ],
	[ "Pahawh Hmong", [92880, 92927] ],
	[ "Medefaidrin", [92928, 92991] ],
	[ "Miao", [92992, 93087] ],
	[ "Ideographic Symbols and Punctuation", [94176, 94207] ],
	[ "Tangut", [98304, 102399] ],
	[ "Tangut Components", [102400, 104447] ],
	[ "Khitan Small Script", [108544, 108671] ],
	[ "Tangut Supplement", [108672, 108799] ],
	
	[ "Kana Extended-B", [110592, 110847] ],
	[ "Kana Supplement", [110848, 110895] ],
	[ "Kana Extended-A", [110896, 110959] ],
	[ "Small Kana Extension", [110960, 111007] ],
	[ "Nushu", [111008, 111231] ],
	[ "Duployan", [113664, 113823] ],
	[ "Shorthand Format Controls", [113824, 113839] ],
	[ "Znamenny Musical Notation", [118784, 118847] ],
	[ "Byzantine Musical Symbols", [119296, 119375] ],
	[ "Musical Symbols", [119552, 119647] ],
	[ "Ancient Greek Musical Notation", [119648, 119711] ],
	[ "Mayan Numerals", [120832, 120883] ],
	[ "Tai Xuan Jing Symbols", [120832, 120883] ],
	[ "Counting Rod Numerals", [120832, 120883] ],
	[ "Mathematical Alphanumeric Symbols", [120832, 120883] ],
	[ "Sutton SignWriting", [120832, 120883] ],
	[ "Latin Extended-G", [120832, 120883] ],
	[ "Glagolitic Supplement", [120832, 120883] ],
	[ "Nyiakeng Puachue Hmong", [120832, 120883] ],
	[ "Toto", [120832, 120883] ],
	[ "Wancho", [120832, 120883] ],
	[ "Ethiopic Extended-B", [123792, 123827] ],
	
	[ "Mende Kikakui", [123840, 123903] ],
	[ "Adlam", [123904, 123951] ],
	[ "Indic Siyaq Numbers", [124608, 124671] ],
	[ "Ottoman Siyaq Numbers", [124672, 124735] ],
	[ "Arabic Mathematical Alphabetic Symbols", [124928, 125183] ],
	[ "Mahjong Tiles", [126976, 127023] ],
	[ "Domino Tiles", [127024, 127135] ],
	[ "Playing Cards", [127136, 127231] ],
	[ "Enclosed Alphanumeric Supplement", [127232, 127487] ],
	[ "Enclosed Ideographic Supplement", [127488, 127743] ],
	[ "Miscellaneous Symbols and Pictographs", [127744, 128511] ],
	[ "Emoticons", [128512, 128591] ],
	[ "Ornamental Dingbats", [128592, 128639] ],
	[ "Transport and Map Symbols", [128640, 128767] ],
	[ "Alchemical Symbols", [128768, 128895] ],
	[ "Geometric Shapes Extended", [128896, 129023] ],
	[ "Supplemental Arrows-C", [129024, 129279] ],
	
	[ "Supplemental Symbols and Pictographs", [128512, 129279] ],
	[ "Chess Symbols", [129280, 129535] ],
	[ "Symbols and Pictographs Extended-A", [129536, 129791] ],
	[ "Symbols for Legacy Computing", [129792, 130047] ],
	[ "CJK Unified Ideographs Extension B", [131072, 173791] ],
	[ "CJK Unified Ideographs Extension C", [173792, 177983] ],
	[ "CJK Unified Ideographs Extension D", [177984, 178207] ],
	[ "CJK Unified Ideographs Extension E", [178208, 183983] ],
	[ "CJK Unified Ideographs Extension F", [183984, 191471] ],
	[ "CJK Compatibility Ideographs Supplement", [194560, 195103] ],
	[ "CJK Unified Ideographs Extension G", [196608, 201551] ],
	[ "Tags", [917504, 917631] ],
	[ "Variation Selectors Supplement", [917760, 917999] ],
	[ "Supplementary Private Use Area-A", [983040, 1048575] ],
	[ "Supplementary Private Use Area-B", [1048576, 1114111] ]
]

_anUnicodesOfBoxChars = 9472:9599

func UnicodesOfBoxChars()
	return _anUnicodesOfBoxChars

func UnicodeBoxChars()
	return UnicodesToChars(_anUnicodesOfBoxChars)

	func BoxChars()
		return UnicodeBoxChars()

func UnicodeData()
	return _cUnicodeData
	
	func StzUnicodeDataQ()
		return new stzUnicodeData()

	func UnicodeDataAsString()
		return UnicodeData()

		func UnicodeDataAsStringQ()
			return new stzUnicodeDataAsString()

func MaxUnicode()
	return _nMaxUnicode

	func LastUnicode()
		return MaxUnicode()

	func MaxUnicodeNumber()
		return MaxUnicode()

func NumberOfUnicodeChars()
	return _nNumberOfUnicodeChars

	func NumberOfUnicodes()
		return NumberOfUnicodeChars1()

	func @NumberOfUnicodeChars()
		return NumberOfUnicodeChars()

	func @NumberOfUnicodes()
		return NumberOfUnicodeChars()

func NumberOfLinesInUnicodeDataFile()
	return _nNumberOfLinesInUnicodeDataFile

func MathUnicodes()
	return _anMathUnicodes

func NumberOfMathChars()
	return len(_anMathUnicodes)

	func HowManyMathChars()
		return NumberOfMathChars()

func MathChars()
	return UnicodesToChars(MathUnicodes())

	func MathCharsQ()
		return MathCharsQR(:stzList)

	func MathCharsQR(pcReturnType)

		switch pcReturnType
		on :stzList
			return new stzList(MathChars())

		on :stzListOfChars
			return new stzListOfChars(MathChars())

		on :stzListOfStrings
			return new stzListOfStrings(MathChars())

		other
			StzRaise("Unsupported return type!")
		off

func NumberOfUnicodeBlocks()
	return len( UnicodeBlocks() )

	func HowManyUnicodeBlocks()
		return NumberOfUnicodeBlocks()

func UnicodeBlocksXT()
	return _aUnicodeBlocksXT

	func UnicodeBlocksAndTheirRanges()
		return UnicodeBlocksXT()

func UnicodeBlocks()
	acResult = []
	nLen = len(_aUnicodeBlocksXT)

	for i = 1 to nLen
		acResult + _aUnicodeBlocksXT[i][1]
	next

	return acResult

	func UnicodeBlocksNames()
		return UnicodeBlocks()

func UnicodeBlocksRanges()
	aResult = []
	nLen = len(_aUnicodeBlocksXT)

	for i = 1 to nLen
		aResult + _aUnicodeBlocksXT[i][2]
	next

	return aResult

func UnicodeBlocksContaining(pcStr)
	acResult = []
	nLen = len(_aUnicodeBlocksXT)

	for i = 1 to nLen
		str = lower(_aUnicodeBlocksXT[i][1])
		if substr(str, pcStr) > 0
			acResult + _aUnicodeBlocksXT[i][1]
		ok
	next

	return acResult

	#< @FunctionAlternativeForms

	func UnicodeBlocksNamesContaining(pcStr)
		return UnicodeBlocksContaining(pcStr)

	func UnicodeBlocksContainingInTheirName(pcStr)
		return UnicodeBlocksContaining(pcStr)

	func UnicodeBlocksContainingInTheirNames(pcStr)
		return UnicodeBlocksContaining(pcStr)

	#--

	func @UnicodeBlocksContaining(pcStr)
		return UnicodeBlocksContaining(pcStr)

	func @UnicodeBlocksNamesContaining(pcStr)
		return UnicodeBlocksContaining(pcStr)

	func @UnicodeBlocksContainingInTheirName(pcStr)
		return UnicodeBlocksContaining(pcStr)

	func @UnicodeBlocksContainingInTheirNames(pcStr)
		return UnicodeBlocksContaining(pcStr)

	#>

func UnicodeBlocksContainingXT(pcStr)
	aResult = []
	nLen = len(_aUnicodeBlocksXT)

	for i = 1 to nLen
		str = lower(_aUnicodeBlocksXT[i][1])
		if substr(str, pcStr) > 0
			aResult + _aUnicodeBlocksXT[i]
		ok
	next

	return aResult

	#< @FunctionAlternativeForms

	func UnicodeBlocksContainingAlongWithTheirRanges(pcStr)
		return UnicodeBlocksContainingXT(pcStr)

	func UnicodeBlocksNamesContainingXT(pcStr)
		return UnicodeBlocksContainingXT(pcStr)

	func UnicodeBlocksNamesContainingAlongWithTheirRanges(pcStr)
		return UnicodeBlocksContainingXT(pcStr)

	#--

	func @UnicodeBlocksContainingXT(pcStr)
		return UnicodeBlocksContainingXT(pcStr)

	func @UnicodeBlocksNamesContainingXT(pcStr)
		return UnicodeBlocksContainingXT(pcStr)

	func @UnicodeBlocksContainingInTheirNameXT(pcStr)
		return UnicodeBlocksContainingXT(pcStr)

	func @UnicodeBlocksContainingInTheirNamesXT(pcStr)
		return UnicodeBlocksContainingXT(pcStr)

	#>

func CharsContainingInTheirName(pcPartOfName)
	oUnicodeData = new stzUnicodeData()
	acResult = oUnicodeData.CharsContaining(pcPartOfName)
	return acResult

	func CharsContaining(pcPartOfName)
		return CharsContainingInTheirName(pcPartOfName)

	func @CharsContainingInTheirName(pcPartOfName)
		return CharsContainingInTheirName(pcPartOfName)

	func @CharsContaining(pcPartOfName)
		return CharsContainingInTheirName(pcPartOfName)


class stzUnicodeDataAsString from stzUnicodeData

class stzUnicodeData
	@oStzStrUnicodeData

	def init()
		@oStzStrUnicodeData = new stzString( UnicodeData() )

	def UnicodeStringObject()
		return @oStzStrUnicodeData

	def ContainsCharName(pcCharName)
		if This.FindCharName(pcCharName) > 0
			return TRUE
		else
			return FALSE
		ok

		def ContainsName(pcCharName)
			return This.ContainsCharName()

	def FindCharName(pcCharName)
		if NOT isString(pcCharName)
			StzRaise("Incorrect param type! pcCharName must be a string.")
		ok

		pcCharName = Q(pcCharName).Uppercased()

		nPos = @oStzStrUnicodeData.FindFirstCS( pcCharName, :CS = FALSE )
		return nPos

		def FindcharByName(pcCharName)
			return This.FindCharName(pcCharName)

	def SearchCharName(pcCharName)
		return @oStzStrUnicodeData.FindAllCS( pcCharName, :CS = FALSE )

		def SearchForCharName(pcCharName)
			return SearchCharName(pcCharName)

		def SearchCharByName(pcCharName)
			return SearchCharName(pcCharName)


	def CharByName(pcCharName)
		cHex = This.CharHexCodeByName(pcCharName)
		nUnicode = HexToDecimal( cHex )

		cChar = StzCharQ(nUnicode).Content()
		return cChar

	def CharHexCodeByName(pcCharName)
		if CheckParams()
			if NOT isString(pcCharName)
				StzRaise("Incorrect param type! pcCharName must be a string.")
			ok
		ok

		pcCharName = StzStringQ(pcCharName).Uppercased()
		n = This.FindCharName(";"+ pcCharName + ";")

		if n > 0
			n2 = n - 1
			n1 = @oStzStrUnicodeData.PreviousOccurrence(NL, n) + 1
			cHex = HexPrefix() + @oStzStrUnicodeData.Section(n1, n2)

			return cHex
		else
			return HexPrefix() 
		ok

	def CharUnicodeByName(pcCharName)
		return StzHexNumberQ( This.CharHexCodeByName(pcCharName) ).ToDecimal()

		def CharDecimalCodeByName(pcCharName)
			return This.CharUnicodeByName(pcCharName)

	def CharByHexCode(pcHex)
		cHex = StzHexNumberQ(pcHex).WithoutPrefix()
		if @oStzStrUnicodeData.Contains(NL + cHex + ";")
			nUnicode = StzHexNumberQ(pcHex).ToDecimal()
			return StzCharQ(nUnicode).Content()
		ok

	def CharByUnicode(nUnicode)
		cHex = StzNumberQ(nUnicode).ToHex()
		return This.CharByHexCode(cHex)

		def CharByDecimalCode(nUnicode)
			return This.CharByUnicode(nUnicode)

	def CharNameByHexCode(pcHex)

		cHex = StzHexNumberQ(pcHex).WithoutPrefix()

		if cHex = ""
			return NULL
		ok

		switch len(cHex)
		on 3
			cHex = "0" + cHex
		on 2
			cHex = "00" + cHex
		on 1
			cHex = "000" + cHex
		off


		n = @oStzStrUnicodeData.FindFirst(NL + cHex + ";")
		
		if n = 0
			return NULL
		ok

		n++	# To compensate the NL

		# Defininging start of the char name in n1

		bContinue = TRUE
		i = 0

		while bContinue
			i++
			c = @oStzStrUnicodeData[n + i]

			if c = ";"
				n1 = n + i + 1
				bContinue = FALSE
			ok
		end

		# Defininging end of the char name in n2
		n = n1
		bContinue = TRUE
		i = 0

		while bContinue
			i++
			c = @oStzStrUnicodeData[n + i]

			if c = ";"
				n2 = n + i - 1
				bContinue = FALSE
			ok
		end

		
		cResult = @oStzStrUnicodeData.Section(n1, n2)
		return cResult

	def CharNameByUnicode(nUnicode)
		cHex = StzNumberQ(nUnicode).ToHex()
		cResult = This.CharNameByHexCode(cHex)
		return cResult

	#==

	def UnicodesOfCharsContaining(cPartOfName)
		if CheckParams()
			if NOT isString(cPartOfName)
				StzRaise("Incorrect param type! cPartOfName must be a string.")
			ok
		ok

		cPartOfName = StzStringQ(cPartOfName).Uppercased()
		acLines = @oStzStrUnicodeData.split(NL)
		nLen = len(acLines)

		anResult = []

		for i = 1 to nLen
			if substr(acLines[i], cPartOfName) > 0
				cHex = ""
				n = 1
				while TRUE
					if acLines[i][n] = ";"
						exit
					else
						cHex += acLines[i][n]
						n++
					ok
				end
				anResult + dec( "0x" + cHex )
		
			ok
		next

		return anResult

	def CharsContaining(cPartOfName)
		acResult = UnicodesToChars( This.UnicodesOfCharsContaining(cPartOfName) )
		return acResult

	#==

	def NumberOfUnicodeChars()
		return @oStzStrUnicodeData.NumberOfLines()

		def NumberOfChars()
			return This.NumberOfUnicodeChars()

		def NumberOfUnicodes()
			return This.NumberOfUnicodeChars()

		def HowManyUnicodeChars()
			return This.NumberOfUnicodeChars()

		def HowManyChars()
			return This.NumberOfUnicodeChars()

		def HowManyUnicodes()
			return This.NumberOfUnicodeChars()
