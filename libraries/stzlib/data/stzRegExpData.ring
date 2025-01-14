

_$aRegExpPatternsExplanations_ = [

	# Web & Email

	#---

	:email = [ "Matches standard email formats",

	"- `^` and `$`: Start and end of the string.
- `[a-zA-Z0-9._%+-]+`: Local part allowing letters, numbers, and common special characters.
- `@`: Required @ symbol.
- `[a-zA-Z0-9.-]+`: Domain name allowing letters, numbers, dots, and hyphens.
- `\.[a-zA-Z]{2,}`: Last part of the domain (TLD) with minimum 2 letters.

- Matches: `user@domain.com`, `user.name+tag@example.co.uk`
- Non-matches: `@domain.com`, `user@.com`, `user@domain`"
	],

	#---

	:url = [ "Matches web URLs",

	"- `^` and `$`: Start and end of the string.
- `(https?:\/\/)?`: Optional protocol.
- `([\da-z\.-]+)`: Domain name.
- `\.([a-z\.]{2,6})`: Last segment (TLD) like `.com`, `.tn`, etc.
- `([\/\w \.-]*)*\/?`: Optional path.

- Matches: `https://example.com`, `domain.co.tn/path`
- Non-matches: `http:/domain.com`, `.com`, `https://`"
	],

	#---

	:Domain = [ "Matches domain names",

	"- `^` and `$`: Start and end of the string.
- `[a-z0-9](?:[a-z0-9-]*[a-z0-9])?`: Domain segments.
- `\.`: Dot separator.

- Matches: `example.com`, `sub.domain.co.eg`
- Non-matches: `-example.com`, `domain..com`"
	],

	#---

	:IPv4 = [ "Matches IPv4 addresses",

	"- `^` and `$`: Start and end of the string.
- `25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?`: Numbers 0-255.
- Repeated 4 times with dots.

- Matches: `192.168.0.1`, `10.0.0.0`
- Non-matches: `256.1.2.3`, `1.2.3`, `a.b.c.d`"
	],

	#---

	:IPv6 = [ "Matches basic IPv6 addresses",

	"- `^` and `$`: Start and end of the string.
- `[A-F0-9]{1,4}`: Hexadecimal groups.
- Seven groups with colons, plus final group.

- Matches: `2001:0DB8:0000:0000:0000:0000:1428:57AB`
- Non-matches: `2001::1428:57AB` (compressed form)"
	],

	#---

	:socialHandle = [ "Matches social media handles",

	"- `^` and `$`: Start and end of the string.
- `@`: Required @ symbol.
- `[a-zA-Z0-9_]{1,15}`: 1-15 alphanumeric or underscore characters.

- Matches: `@user123`, `@User_name`
- Non-matches: `user123`, `@user-name`, `@toolong123456789`"
	],

	# Dates & Times (International)

	:ISODate = [ "Matches ISO dates (YYYY-MM-DD)",

	"- `^` and `$`: Start and end of the string.
- `\d{4}`: Four-digit year.
- `(?:0[1-9]|1[0-2])`: Months 01-12.
- `(?:0[1-9]|[12]\d|3[01])`: Days 01-31.

- Matches: `2024-01-14`, `2023-12-31`
- Non-matches: `2024-13-01`, `2024-01-32`"
	],

	#--




]


_$aRegExpPatterns_ = [

	# Web & Email

	:email = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}",
	:url = "^https?:\/\/(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(\/[\w\-._~:/?#[\]@!$&'()*+,;=]*)?$",
	:domain = "^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$",
	:ipv4 = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",
	:ipv6 = "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4})",
	:socialHandle = "^@[a-zA-Z0-9._]{1,30}$",

	# Dates & Times (International)

	:isoDate = "^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$",
	:isoDateTime = "^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])T([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\.[0-9]+)?(Z|[+-][01][0-9]:[0-5][0-9])?$",
	:ddmmyyyy = "^(0[1-9]|[12][0-9]|3[01])[-/.](0[1-9]|1[0-2])[-/.]\d{4}$",
	:mmddyyyy = "^(0[1-9]|1[0-2])[-/.](0[1-9]|[12][0-9]|3[01])[-/.]\d{4}$",
	:time24h = "^([01]?[0-9]|2[0-3]):[0-5][0-9]$",

	# Markdown

	:mdHeader = "^#{1,6}\s.+$",
	:mdBold = "\*\*[^*]+\*\*",
	:mdItalic = "\*[^*]+\*",
	:mdLink = "\[([^\]]+)\]\(([^\)]+)\)",
	:mdImage = "!\[([^\]]*)\]\(([^\)]+)\)",
	:mdBlockquote = "^>\s.+$",
	:mdCodeBlock = "```[^`]*```",
	:mdInlineCode = "`[^`]+`",
	:mdListItem = "^[-*+]\s.+$",
	:mdNumberedList = "^\d+\.\s.+$",

	# HTML

	:htmlComment = "<!--[\s\S]*?-->",
	:htmlDoctype = "<!DOCTYPE[^>]*>",
	:htmlOpenTag = "<([a-zA-Z][a-zA-Z0-9]*)((?:\s+[a-zA-Z][a-zA-Z0-9]*(?:\s*=\s*(?:\"+
			char(34) + ".*?\" + char(34) + "|'.*?'|[^'\" + char(34) + ">\\s]+))?)*)\s*/?>",
	:htmlCloseTag = "</([a-zA-Z][a-zA-Z0-9]*)>",
	:htmlAttribute = "([a-zA-Z][a-zA-Z0-9]*)\s*=\s*(\" + char(34) + ".*?\" + char(34) + "|'.*?'|[^'\" + char(34) + ">\\s]+)",
	:htmlClass = "class\s*=\s*[\" + char(34) + "']([^\" + char(34) + "']*)[\" + char(34) + "']",
	:htmlId = "id\s*=\s*[\" + char(34) + "']([^\" + char(34) + "']*)[\" + char(34) + "']",

	# API & Request Validation

	:apiKey = "^[A-Za-z0-9_-]{20,}$",
	:bearerToken = "^Bearer\s+[A-Za-z0-9\-._~+/]+=*$",
	:queryParam = "^[\w\-%\.]+$",
	:httpMethod = "^(?:GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS)$",
	:contentType = "^[\w\-\./]+(?:\+[\w\-\./]+)?(?:;\s*charset=[\w\-]+)?$",
	:requestId = "^[\w\-]{4,}$",
	:corsOrigin = "^https?://(?:[\w-]+\.)+[\w-]+(?::\d{1,5})?$",

	# Numbers & Currency (International)

	:number = "^-?(?:\d+|\d{1,3}(?:,\d{3})+)?(?:\.\d+)?$",
	:currencyValue = "^-?\d{1,3}(?:,\d{3})*(?:\.\d{2})?$",
	:scientificNotation = "^-?\d+(?:\.\d+)?(?:e[+-]?\d+)?$",
	:percentage = "^-?\d*\.?\d+%$",
	:hexColor = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$",

	# Contact Information (International)

	:phoneE164 = "^\+[1-9]\d{1,14}$",
	:phoneGeneral = "^[+]?[(]?[0-9]{1,4}[)]?[-\s./0-9]*$",
	:postalCode = "^[A-Z0-9][A-Z0-9\- ]{0,10}[A-Z0-9]$",
	:countryCode = "^[A-Z]{2,3}$",
	:languageCode = "^[a-z]{2}-[A-Z]{2}$",

	# Data Cleaning

	:alphanumeric = "^[a-zA-Z0-9]+$",
	:alphabetic = "^[a-zA-Z]+$",
	:numeric = "^[0-9]+$",
	:spaces = "[ \t\r\n]+",
	:trim = "^\s+|\s+$",
	:multipleSpaces = "{2,}",
	:nonPrintable = "[\x00-\x1F\x7F-\x9F]",

	# Modern Data Formats

	:jwt = "^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]*$",
	:base64 = "^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$",
	:uuid = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$",
	:semver = "^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$,",
	:imageDataUrl = "^data:image\/(?:jpeg|png|gif|webp);base64,[a-zA-Z0-9+/]+=*$",

	# Security & Input Validation

	:username = "^[a-zA-Z0-9._]{3,24}$",
	:passwordComplexity = "^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,72}$",
	:safeFilename = "^[\w\-. ]+$",
	:safePath = "^(?!.*\.\.)[\w\-./]+$",
	:safeJson = "^[\w\s:,.\{\}\[\]\" + char(34) + "'-]*$",
	:noScriptTags = "^(?!.*<script).*$",
	:noIframes = "^(?!.*<iframe).*$",
	:noEventHandlers = "^(?!.*\bon\w+\s*=).*$",
	:noHtmlTags = "^(?!.*<[^>]+>).*$",

	# SQL & Injection Prevention

	:sqlIdentifier = "^[a-zA-Z_][a-zA-Z0-9_]*$",
	:noSqlKeywords = "^(?!.*(?:SELECT|INSERT|UPDATE|DELETE|DROP|UNION|ALTER)).*$",
	:noCommandInjection = "^[^&|;`$()]+$",
	:noDirectoryTraversal = "^(?!.*(?:\.\.|/|\\\\)).*$",
	:noNullBytes = "^[^\x00]+$",
	:sqlCreateTable = "CREATE\s+TABLE\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\(",
	:sqlSelect = "SELECT\s+(?:(?:DISTINCT|ALL)\s+)?(?:\*|[\w\s,`.*]+)\s+FROM",
	:sqlInsert = "INSERT\s+INTO\s+[a-zA-Z_][a-zA-Z0-9_]*\s*(?:\([^)]*\))?\s*VALUES?\s*\(",
	:sqlUpdate = "UPDATE\s+[a-zA-Z_][a-zA-Z0-9_]*\s+SET",
	:sqlDelete = "DELETE\s+FROM\s+[a-zA-Z_][a-zA-Z0-9_]*",

	# Mobile & Web App Specific

	:mobileDeviceToken = "^[a-zA-Z0-9\-_]{64,}$",
	:appleDeviceToken = "^[a-f0-9]{64}$",
	:fcmToken = "^[a-zA-Z0-9\-_]{150,}$",
	:coordinates = "^-?\d+\.?\d*,\s*-?\d+\.?\d*$",
	:appVersion = "^\d+\.\d+\.\d+$",
	:bundleId = "^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+[a-z0-9_]$",
	:userAgent = "^[a-zA-Z0-9/.()\s;,_-]+$",

	# Content Security

	:allowedHtml = "<(?:b|i|em|strong|span|p|br|hr|h[1-6]|ul|ol|li|blockquote)(?:\s+[^<>]*)?>",
	:allowedCssProperties = "^(color|background-color|font-size|text-align|margin|padding|border|width|height):\s*[^;]+;$",
	:allowedProtocols = "^(?:https?|tel|mailto):",
	:allowedFileTypes = "^.*\.(jpg|jpeg|png|gif|pdf|doc|docx|txt|csv)$",
	:mediaTypes = "^(?:image|video|audio)/[\w-]+$",

	# Education

	:mathEquation = "^-?\d+(?:\s*[-+*/]\s*-?\d+)*\s*=\s*-?\d+$",
	:chemicalFormula = "^(?:[A-Z][a-z]?\d*)+$",
	:dnaSequence = "^[ATCG]+$",
	:romanNumeral = "^(?=[MDCLXVI])M*(C[MD]|D?C{0,3})(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$",
	:musicNote = "^[A-G][#b]?[0-8]$",
	:timezone = "^[A-Z]{3,4}[+-]\d{1,2}(?::\d{2})?$",
	:constellations = "^[A-Z][a-z]{2,}$",
	:elementSymbol = "^(?:[A-Z][a-z]?|[A-Z]{2})$",
	:coordinates2D = "^\(\s*-?\d+\.?\d*\s*,\s*-?\d+\.?\d*\s*\)$",
	:coordinates3D = "^\(\s*-?\d+\.?\d*\s*,\s*-?\d+\.?\d*\s*,\s*-?\d+\.?\d*\s*\)$",
	:rgbColor = "^rgb\(\s*(?:(?:25[0-5]|2[0-4]\d|[0-1]?\d{1,2})\s*,\s*){2}(?:25[0-5]|2[0-4]\d|[0-1]?\d{1,2})\s*\)$" + char(34)

]

func RegExpPatterns()
	return _$aRegExpPatterns_

func RegExpPatternsExplanations()
	return _$aRegExpPatternsExplanations_

func RegExpPatternName(cPatt)

	if CheckParams()
		if NOT isString(cPatt)
			StzRaise("Incorrect param type! cPatt must be a string.")
		ok
	ok

	_cResult_ = ""

	_aPatterns_ = RegExpPatterns()

	_nLen_ = len(_aPatterns_)

	for @i = 1 to _nLen_
		if _aPatterns_[@i][2] = cPatt
			_cResult_ = _aPatterns_[@i][1]
			exit
		ok
	next

	return _cResult_


func RegExpPatternExplanation(cName)

	if CheckParams()
		if NOT isString(cName)
			StzRaise("Incorrect param type! cName must be a string.")
		ok
	ok

	_cResult_ = RegExpPatternsExplanations()[cName]
	if _cResult_ = ""
		StzRaise("Can't find an explanation for the pattern of the provided name.")
	ok

	
	return _cResult_
