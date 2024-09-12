// Creates a TextCodec object to be used in converting text to and from
// unicode (in stzTextStream)
// --> All necessary methods are not supported yet in RingQt (V1.14)

// o1 = new stzTextCodec("KOI8-R")

_acSupportedTextEncodings = [
	lower("Big5"),
	lower("Big5-HKSCS"),
	lower("CP949"),
	lower("EUC-JP"),
	lower("EUC-KR"),
	lower("GB18030"),
	lower("HP-ROMAN8"),
	lower("IBM 850"),
	lower("IBM 866"),
	lower("IBM 874"),
	lower("ISO 2022-JP"),

	lower("ISO 8859-1"), lower("ISO 8859-2"), lower("ISO 8859-3"),
	lower("ISO 8859-4"), lower("ISO 8859-5"), lower("ISO 8859-6"),
	lower("ISO 8859-7"), lower("ISO 8859-8"), lower("ISO 8859-9"),
	lower("ISO 8859-10"),

	lower("ISO 8859-13"), lower("ISO 8859-14"), lower("ISO 8859-15"),
	lower("ISO 8859-16"), 

	lower("Iscii-Bng"), lower("Iscii-Dev"), lower("Iscii-Gjr"),
	lower("Iscii-Knd"), lower("Iscii-Mlm"), lower("Iscii-Ori"),
	lower("Iscii-Pnj"), lower("Iscii-Tlg"), lower("Iscii-Tml"),

	lower("KOI8-R"),
	lower("KOI8-U"),
	lower("Macintosh"),
	lower("Shift-JIS"),
	lower("TIS-620"),
	lower("TSCII"),

	lower("UTF-8"),
	lower("UTF-16"),
	lower("UTF-16BE"),
	lower("UTF-16LE"),
	lower("UTF-32"),
	lower("UTF-32BE"),
	lower("UTF-32LE"),

	lower("Windows-1250"), lower("Windows-1251"), lower("Windows-1252"),
	lower("Windows-1253"), lower("Windows-1254"), lower("Windows-1255"),
	lower("Windows-1256"), lower("Windows-1257"), lower("Windows-1258")
]

func SupportedTextEncodings()
		return _acSupportedTextEncodings

class stzTextEncoding from stzObject
	oQTextCodec
	cEncodingName = ""

	def init(pcEncodingName)
		pcEncodingName = lower(pcEncodingName)

		oSupportedEncodings = new stzList(_acSupportedTextEncodings)
		if oSupportedEncodings.Contains(pcEncodingName)
			oQTextCodec = new QTextCodec
			oQTextCodec.codecforname(pcEncodingName)
			cEncodingName = pcEncodingName
		else
			StzRaise(stzTextEncodingError(:UnsupportedTextEncoding))
		ok

	def EncodingName()
		return UPPER(cEncodingName)

	def SetSystemEncoding(pcEncodingName)
		pcEncodingName = lower(pcEncodingName)
		oSupportedEncodings = new stzList(_acSupportedTextEncodings)
		oQTextCodec.setCodecForLocale(cEncodingName)

