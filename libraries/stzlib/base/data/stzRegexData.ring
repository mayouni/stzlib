
#-----------------------------#
#  REGEX DATA NAMED PATTERNS  #
#-----------------------------#

_$aRegexPatterns_ = [

	# String Structure Patterns

	:textWithNumberSuffix = "^([^\d]*)(\d+)$",
	:numberWithTextSuffix = "^(\d+)([^\d]*)$", 
	:textNumberText = "^([^\d]*)(\d+)([^\d]*)$",
	:alternatingTextNumber = "^([^\d]+\d+)+$",
	:spaceSeparatedWords = "^(\S+)(?:\s+\S+)*$",

	# Basic structure for international addresses
	
	:addressLine = "^[a-zA-Z0-9.,'’\\-\\s]+$",
	:cityName = "^[a-zA-Z\\s\\-']+$",
	:stateProvinceRegion = "^[a-zA-Z\\s\\-']+$",
	:postalCode = "^[a-zA-Z0-9\\-\\s]{3,10}$",
	:countryName = "^[a-zA-Z\\s\\-]+$",
	:fullAddress = "^([a-zA-Z0-9.,'’\\-\\s]+)(\\n[a-zA-Z0-9.,'’\\-\\s]+)*\\n([a-zA-Z\\s\\-']+)\\n([a-zA-Z\\s\\-']+)\\n([a-zA-Z0-9\\-\\s]{3,10})\\n([a-zA-Z\\s\\-]+)$",
	
	# Patterns to Analyze Regex patterns!

	:rxGroup = "\\(([^()]*|(?R))*\\)",
	:rxQuantifier = "\\*|\\+|\\?|(\\{\\d+(,\\d*)?\\})",
	:rxCharacterClass = "\\[(\\^?[^\]]+)\\]",
	:rxAssertion = "\\(\\?<?[=!]",
	:rxEscapedChar = "\\\\",
	:rxAlternation = "(\\|)",
	:rxWildcard = "\\",
	:rxRedundantAlternation = "\\((?:[a-zA-Z0-9]\\|?)+\\)",

	# Files names and paths

	:fileName = "^[^<>:\" + StzChar(34) + "/\\|?*\r\n]+$",
	:filePath = "^(?:[a-zA-Z]:)?(?:\\\\[^<>:\" + StzChar(34) + "/\\|?*\r\n]+)+\\\\?$",
	:unixFilePath = "^(/[^<>:\" + StzChar(34) + "/\\|?*\r\n]+)+/?$",
	:fileExtension = "\\.[a-zA-Z0-9]+$",
	:relativeFilePath = "^(?:\\.\\.?/|[^/<>:\" + StzChar(34) + "|?*]+)(?:/[^/<>:\" + StzChar(34) + "|?*]+)*/?$",

	# Web & Email

	:email = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}",
	:url = "^https?:\/\/(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(\/[\w\-._~:/?#[\]@!$&'()*+,;=]*)?$",
	:domain = "^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$",
	:ipv4 = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",
	:ipv6 = "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4})",
	:socialHandle = "^@[a-zA-Z0-9._]{1,30}$",
	:slug = "^[a-z0-9]+(?:-[a-z0-9]+)*$",

	# Dates & Times (International)

	:isoDate = "^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$",
	:isoDateTime = "^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])T([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\.[0-9]+)?(Z|[+-][01][0-9]:[0-5][0-9])?$",

	:ddmmyyyy = "^(0[1-9]|[12][0-9]|3[01])[-/.](0[1-9]|1[0-2])[-/.]\d{4}$",
	:mmddyyyy = "^(0[1-9]|1[0-2])[-/.](0[1-9]|[12][0-9]|3[01])[-/.]\d{4}$",

	:time24h = "^([01]?[0-9]|2[0-3]):[0-5][0-9]$",
	:time24hSeconds = "^([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$",
	:time12h = "^(0?[1-9]|1[0-2]):[0-5][0-9]\s?(AM|PM|am|pm)$",
	:time12hSeconds = "^(0?[1-9]|1[0-2]):[0-5][0-9]:[0-5][0-9]\s?(AM|PM|am|pm)$",

	:dateISO8601 = "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(?:Z|([+-])\\d{2}:\\d{2})?$",
	:date = "\b(?:\d{1,4}[-/.]\d{1,2}[-/.]\d{1,4}|\d{1,2}\s+[A-Za-z]{3,9}\s+\d{2,4})\b",

	# DateTime Combined Patterns
	
	:dateTimeSpace = "^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])\s([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$",
	:dateTimeUS = "^(0[1-9]|1[0-2])[-/.](0[1-9]|[12][0-9]|3[01])[-/.]\d{4}\s([01]?[0-9]|2[0-3]):[0-5][0-9]$",
	:dateTimeEU = "^(0[1-9]|[12][0-9]|3[01])[-/.](0[1-9]|1[0-2])[-/.]\d{4}\s([01]?[0-9]|2[0-3]):[0-5][0-9]$",
	
	:dateTime12h = "^(0[1-9]|1[0-2])[-/.](0[1-9]|[12][0-9]|3[01])[-/.]\d{4}\s(0?[1-9]|1[0-2]):[0-5][0-9]\s?(AM|PM|am|pm)$",
	:dateTimeLong = "^\d{1,2}\s[A-Za-z]{3,9}\s\d{4},?\s([01]?[0-9]|2[0-3]):[0-5][0-9]$",
	
	# Timestamp & Unix Patterns
	
	:unixTimestamp = "^\d{10}$",
	:unixTimestampMillis = "^\d{13}$",
	:timestampWithMillis = "^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])T([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]\.\d{3}Z?$",
	
	# Flexible DateTime Patterns
	
	:DateTime = "\b\d{4}[-/.]\d{1,2}[-/.]\d{1,2}[T\s]\d{1,2}:\d{2}(:\d{2})?(\.\d+)?(Z|[+-]\d{2}:\d{2})?\b",
	:rfc2822DateTime = "^[A-Za-z]{3},\s\d{1,2}\s[A-Za-z]{3}\s\d{4}\s\d{2}:\d{2}:\d{2}\s[+-]\d{4}$",

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

	# YAML Patterns
	
	:yamlKey = "^[a-zA-Z0-9]+[a-zA-Z0-9_-]*$",
	:yamlValue = "^(\ " + StzChar(34) + "[^\ " + StzChar(34) + "]*\ " + StzChar(34) + ")|([0-9]+)|(true|false)|null$",
	:yamlMap = "^[a-zA-Z0-9]+:[ ]*.+$",
	:yamlArray = "^-?[0-9]+$|\ " + StzChar(34) + "[^\ " + StzChar(34) + "]*\ " + StzChar(34) + "$",
	:yamlFrontMatter = "^---\\s*\\n(.*?)\\n---$",

	# HTML

	:htmlComment = "<!--[\s\S]*?-->",
	:htmlDoctype = "<!DOCTYPE[^>]*>",
	:htmlOpenTag = "<([a-zA-Z][a-zA-Z0-9]*)((?:\s+[a-zA-Z][a-zA-Z0-9]*(?:\s*=\s*(?:\" + StzChar(34) + ".*?\" + StzChar(34) + "|'.*?'|[^'\" + StzChar(34) + "<>\\s]+))?)*)\s*/?>",
	:htmlCloseTag = "</([a-zA-Z][a-zA-Z0-9]*)>",
	:htmlAttribute = "(?:\s+[a-zA-Z][a-zA-Z0-9]*(?:\s*=\s*(?:\" + StzChar(34) + ".*?\" + StzChar(34) + "|'.*?'|[^'\" + StzChar(34) + "<>\\s]+))?)",
	:htmlClass = "(?:\\s+class\\s*=\\s*(?:\" + StzChar(34) + "[^\" + StzChar(34) + "]*\" + StzChar(34) + "|'[^']*'|[^'\" + StzChar(34) + "\\s>]+))",
	:htmlId = "(?:\\s+id\\s*=\\s*(?:\" + StzChar(34) + "[^\" + StzChar(34) + "]*\" + StzChar(34) + "|'[^']*'|[^'\" + StzChar(34) + "\\s>]+))",   
	:html5Color = "^#[A-Fa-f0-9]{3,6}$",

	:htmlTableOpen = "<table((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\" + StzChar(34) + ".*?\" + StzChar(34) + "|'.*?'|[^'\" + StzChar(34) + "<>\\s]+))?)*)\\s*>",
	:htmlTableClose = "</table>",
	:htmlRowOpen = "<tr((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\" + StzChar(34) + ".*?\" + StzChar(34) + "|'.*?'|[^'\" + StzChar(34) + "<>\\s]+))?)*)\\s*>",
	:htmlRowClose = "</tr>",
	:htmlCellOpen = "<td((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\" + StzChar(34) + ".*?\" + StzChar(34) + "|'.*?'|[^'\" + StzChar(34) + "<>\\s]+))?)*)\\s*>",
	:htmlCellClose = "</td>",
	:htmlHeaderCellOpen = "<th((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\" + StzChar(34) + ".*?\" + StzChar(34) + "|'.*?'|[^'\" + StzChar(34) + "<>\\s]+))?)*)\\s*>",
	:htmlHeaderCellClose = "</th>",
	:htmlTableSectionOpen = "<(thead|tbody|tfoot)((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\" + StzChar(34) + ".*?\" + StzChar(34) + "|'.*?'|[^'\" + StzChar(34) + "<>\\s]+))?)*)\\s*>",
	:htmlTableSectionClose = "</(thead|tbody|tfoot)>",

	# CSS Patterns

	:idSelector = "^#([a-zA-Z_][a-zA-Z\\d_-]*)$",
	:classSelector = "^\\.([a-zA-Z_][a-zA-Z\\d_-]*)$",
	:attributeSelector = "\\[\\s*([a-zA-Z][a-zA-Z0-9-]*)\\s*(?:([*^$|!~]?=)\\s*(?:\ " + StzChar(34) + "[^\ " + StzChar(34) + "]*\ " + StzChar(34) + "|'[^']*'|[^'\ " + StzChar(34) + "\\s>]+))?\\s*\\]",
	:hexColor = "^#([a-fA-F\\d]{3}|[a-fA-F\\d]{6})$",
	:rgbColor = "^rgba?\\(\\s*\\d{1,3}\\s*,\\s*\\d{1,3}\\s*,\\s*\\d{1,3}(\\s*,\\s*(0|1|0?\\.\\d+))?\\s*\\)$",

	# Numbers & Currency (International)

	:digit = "\d",
	:number = "^-?(?:\d+|\d{1,3}(?:,\d{3})+)?(?:\.\d+)?$",
	:currencyValue = "^-?\d{1,3}(?:,\d{3})*(?:\.\d{2})?$",
	:scientificNotation = "^-?\d+(?:\.\d+)?(?:e[+-]?\d+)?$",
	:percentage = "^-?\d*\.?\d+%$",
	:hexColor = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$",
	
	:integer = "^-?\d+$",
	:positiveInteger = "^\d+$",
	:negativeInteger = "^-\d+$",
	
	:float = "^-?\d+\.\d+$",
	:positiveFloat = "^\d+\.\d+$",
	:negativeFloat = "^-\d+\.\d+$",
		
	:binaryNumber = "^[01]+$",
	:octalNumber = "^[0-7]+$",
	:hexNumber = "^0[xX][A-Fa-f0-9]+$",
	:romanNumber = "^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$",
	
	:measurementValue = "^-?\d+(?:\.\d+)?\s?(cm|mm|m|km|g|kg|lb|oz|L|ml|mL|ft|inch|in|yd|mi)$",
	:phoneNumber = "^\+?\d{1,3}?[-.●]?\(?\d{1,4}?\)?[-.●]?\d{1,4}[-.●]?\d{1,9}$",

	# Special patters for capturing numbers inside string

	:numbersInSingleQuotes = "'-?\d+(?:\.\d+)?'",
	:numbersInDoubleQuotes = '"-?\d+(?:\.\d+)?\"',
	:numbersInBackticks = "-?\d+(?:\.\d+)?",
	:numbersInCurlySingleQuotes = '[‘’]-?\d+(?:\.\d+)?[‘’]',
	:numbersInCurlyDoubleQuotes = '[“”]-?\d+(?:\.\d+)?[“”]',

	:numbersInQuotes = "'-?\d+(?:\.\d+)?'" + "|" +
		'"-?\d+(?:\.\d+)?\"' + "|" +
		"-?\d+(?:\.\d+)?" + "|" +
		'[‘’]-?\d+(?:\.\d+)?[‘’]' + "|" +
		'[“”]-?\d+(?:\.\d+)?[“”]',

	:numbersInString = "(?<!\w)-?\d+(?:\.\d+)?(?!\w)",

	:numbersInParentheses = "\(\s*-?\d+(?:\.\d+)?\s*\)",
	:numbersAfterEquals = "=\s*-?\d+(?:\.\d+)?\b",
	:numbersInCSV = '(?<=,|;|\s|^)-?\d+(?:\.\d+)?(?=,|;|\s|$)',
	:numbersInBrackets = '\[\s*-?\d+(?:\.\d+)?\s*\]',
	:numbersAfterColon = ':\s*-?\d+(?:\.\d+)?\b',

	:numbersAsValuesInHashList = '=\s*"?([+-]?\d+(?:\.\d+)?)"?',
	:numbersAsValuesInPairs = ',\s*"?([+-]?\d+(?:\.\d+)?)"?',
	:numbersAsValuesInJSON = ':\s*"?([+-]?\d+(?:\.\d+)?)"?',

	:numbersInList = '\b(["' + StzChar(39) + ']?)(-?\d+(?:\.\d+)?)(\1)\b',

   	# Contact Information (International)

   	:phoneE164 = "^\+[1-9]\d{1,14}$",
   	:phoneGeneral = "^[+]?[(]?[0-9]{1,4}[)]?[-\s./0-9]*$",
   	:postalCode = "^[A-Z0-9][A-Z0-9\- ]{0,10}[A-Z0-9]$",
   	:countryCode = "^[A-Z]{2,3}$",
   	:languageCode = "^[a-z]{2}-[A-Z]{2}$",

   	# Modern Data Formats

   	:jwt = "^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]*$",
   	:base64 = "^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$",
	:emoji = "^(?:\\p{Emoji_Presentation}|\\p{Emoji})+$",


	# API & Request Validation

	:apiKey = "^[A-Za-z0-9_-]{20,}$",
	:bearerToken = "^Bearer\s+[A-Za-z0-9\-._~+/]+=*$",
	:queryParam = "^[\w\-%\.]+$",
	:httpMethod = "^(?:GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS)$",
	:contentType = "^[\w\-\./]+(?:\+[\w\-\./]+)?(?:;\s*charset=[\w\-]+)?$",
	:requestId = "^[\w\-]{4,}$",
	:corsOrigin = "^https?://(?:[\w-]+\.)+[\w-]+(?::\d{1,5})?$",

   	# Data Cleaning Patterns

   	:alphanumeric = "^[a-zA-Z0-9]+$",
   	:alphabetic = "^[a-zA-Z]+$",
   	:numeric = "^[0-9]+$",
   	:spaces = "[ \t\r\n]+",
   	:trim = "^\s+|\s+$",
   	:multipleSpaces = "{2,}",
   	:nonPrintable = "[\x00-\x1F\x7F-\x9F]",

   	# JSON Patterns

   	:jsonObject = "\\{(?:\\s*\ " + StzChar(34) + "[a-zA-Z0-9_]+\ " + StzChar(34) + "\\s*:\\s*(?:\ " + StzChar(34) + "[^\ " + StzChar(34) + "]*\ " + StzChar(34) + "|'[^']*'|\\d+|true|false|null|\\{.*?\\}|\\[.*?\\]))*\\s*\\}",
   	:jsonArray = "^\[(?:\s*[^,]+,?\s*)*\]$",
   	:jsonKeyValuePair = "\ " + StzChar(34) + "[a-zA-Z0-9_]+\ " + StzChar(34) + "\\s*:\\s*(?:\ " + StzChar(34) + "[^\ " + StzChar(34) + "]*\ " + StzChar(34) + "|'[^']*'|\\d+|true|false|null|\\{.*?\\}|\\[.*?\\])",
	:geoJSON = "^\\{\\s*\ " + StzChar(34) + "type\ " + StzChar(34) + "\\s*:\\s*\ " + StzChar(34) + "FeatureCollection\ " + StzChar(34) + "\\s*,\\s*\ " + StzChar(34) + "features\ " + StzChar(34) + "\\s*:\\s*\\[.*?\\]\\s*\\}$ + |'.*?'|[^'\ + StzChar(34) + <>\\s]+))?)*)\s*/?>",

   	# CSV Patterns

   	:csvHeaderRow = "^([^,]*,)*[^,]*$",
   	:csvQuotedField = "\ " + StzChar(34) + "[^\ " + StzChar(34) + "]*\ " + StzChar(34),
   	:csvUnquotedField = "[^,\r\n]*",
   	:csvDelimiter = ",",
   	:csvRowEnding = "\r?",
   	:csvEscapedQuote = "\ " + StzChar(34) + "\ " + StzChar(34),
	:csvLine = "^(?:(?:\ " + StzChar(34) + "[^\ " + StzChar(34) + "]*\ " + StzChar(34) + ")|(?:[^,\ " + StzChar(34) + "]+))(?:,(?:(?:\ " + StzChar(34) + "[^\ " + StzChar(34) + "]*\ " + StzChar(34) + ")|(?:[^,\ " + StzChar(34) + "]+)))*$",

	# SQL Patterns

	:sqlSelectStatement = "^\\s*SELECT\\s+.+?\\s+FROM\\s+.+?(?:\\s+WHERE\\s+.+?)?$",
	:sqlInsertStatement = "^\\s*INSERT\\s+INTO\\s+.+?\\s+\\(.+?\\)\\s+VALUES\\s+\\(.+?\\)\\s*$",
	:sqlUpdateStatement = "^\\s*UPDATE\\s+.+?\\s+SET\\s+.+?(?:\\s+WHERE\\s+.+?)?$",
	:sqlDeleteStatement = "^\\s*DELETE\\s+FROM\\s+.+?(?:\\s+WHERE\\s+.+?)?$",
	:sqlCreateTable = "^\\s*CREATE\\s+TABLE\\s+[\\w]+\\s*\\(.+?\\)\\s*$",
	:sqlDropTable = "^\\s*DROP\\s+TABLE\\s+[\\w]+\\s*$",
	:sqlIdentifier = "^[a-zA-Z_][a-zA-Z0-9_]*$",
	:sqlValue = "^('(?:[^']|''|\\\\')*'|\\d+|NULL)$",
	:sqlOperator = "^(=|<>|!=|<|<=|>|>=|LIKE|IN|IS|BETWEEN)$",
	:sqlJoinClause = "^\\s*JOIN\\s+.+?\\s+ON\\s+.+?$",


   	# Regexes for Potential Security Concerns

   	:sqlInjection = "(?:[\ " + StzChar(34) + "'`;]+.*?)+",
   	:xssInjection = "<[a-zA-Z][a-zA-Z0-9]*[^>]*>.*?</[a-zA-Z][a-zA-Z0-9]*>",
   	:emailInjection = ".*[\n\r]+.+@[a-z0-9]+[.][a-z]{2,}.*",
   	:htmlInjection = "<[^>]*?[^<]*[a-zA-Z0-9]+.*[^<]*?>",

	# Ring Language Patterns

	:ringString = "^(?:[" + StzChar(34) + "'].*?[" + StzChar(34) + "']|\[.*?\]|`.*?`)$",
	:ringNumber = "^-?\d+(?:\.\d+)?$",
	:ringBoolean = "^(?:True|False)$",
	:ringVariable = "^[a-zA-Z_]\w*$",

	:ringFunction = "^(?i)Func\s+([a-zA-Z_]\w*)\s*(?:\((.*?)\))?$",
	:ringFunctionCall = "^([a-zA-Z_]\w*)\s*\((.*?)\)$",
	:ringMainFunction = "^(?i)Func\s+Main\s*$",

	:ringClass = "^(?i)Class\s+([a-zA-Z_]\w*)\s*(?:from\s+([a-zA-Z_]\w*))?$",
	:ringClassAttribute = "^[a-zA-Z_]\w*\s*=\s*.*$",
	:ringNewObject = "^(?i)New\s+([a-zA-Z_]\w*)$",
	:ringObjectAccess = "^([a-zA-Z_]\w*)\s*{\s*(.*?)\s*}$",

	:ringLoop = "^(?i)(?:for\s+\w+\s*=\s*\d+\s+to\s+\d+|while\s+.*|for\s+\w+\s+in\s+.*?)$",
	:ringIf = "^(?i)if\s+.*$",
	:ringSwitch = "^(?i)switch\s+.*$",
	:ringCase = "^(?i)(?:on|off)\s+.*$",

	:ringList = "^\[(?:[^[\]]*|\[.*?\])*\]$",
	:ringListAccess = "^([a-zA-Z_]\w*)\s*\[\s*(\d+|\w+)\s*\]$",
	:ringListRange = "^([^:]+)\s*:\s*([^:]+)$",  #--> 1:3, A:C, #1:#3, day1:day3
	:ringHashTable = "^\[\s*:(?:\w+\s*=\s*[^,\]]+\s*,?\s*)+\]$",

	:ringComment = "^(?:#.*|//.*|/\*[\s\S]*?\*/)$",
	
	:ringSee = "^(?i)See\s+[" + StzChar(34) + "'].*?[" + StzChar(34) + "']|See\s+\w+$",
	:ringGive = "^(?i)Give\s+\w+$",
	:ringLoad = "^(?i)Load\s+[" + StzChar(34) + "'].*?[" + StzChar(34) + "']$",
	:ringImport = "^(?i)Import\s+[\w.]+$",
	
	:ringOperator = "^(?:[+\-*/=%]|==|!=|>=|<=|>|<|\+=|-=|\*=|/=)$",
	:ringLogical = "^(?:and|or|not)$",

	:ringExit = "^(?i)exit(?:\s+\d+)?$",
	:ringReturn = "^(?i)return(?:\s+.*)?$",

	:ringPackage = "^(?i)Package\s+[\w.]+$",
	:ringPrivate = "^(?i)Private$",

	:ringBracestart = "^(?i)func\s+braceStart\s*\(\s*\)\s*$",
	:ringBraceEnd = "^(?i)func\s+braceEnd\s*\(\s*\)\s*$",
	:ringEval = "^(?i)Eval\s*\(.*?\)$",

	# Python Language Patterns
	
	:pythonString = "^(?:[" + StzChar(34) + "]{3}.*?[" + StzChar(34) + "]{3}|[" + StzChar(34) + "].*?[" + StzChar(34) + "]|'''.*?'''|'.*?')$",
	:pythonNumber = "^-?\d+(?:\.\d+)?(?:e[+-]?\d+)?$",
	:pythonBoolean = "^(?:True|False|None)$",
	:pythonVariable = "^[a-zA-Z_]\w*$",
	
	:pythonFunction = "^def\s+([a-zA-Z_]\w*)\s*\((.*?)\)(?:\s*->\s*[\w\[\],\s]+)?:$",
	:pythonFunctionCall = "^([a-zA-Z_]\w*)\s*\((.*?)\)$",
	:pythonLambda = "^lambda\s+.*?:\s*.*$",
	
	:pythonClass = "^class\s+([a-zA-Z_]\w*)(?:\((.*?)\))?:$",
	:pythonClassMethod = "^@\w+\s*$",
	:pythonDecorator = "^@[a-zA-Z_]\w*(?:\((.*?)\))?$",
	
	:pythonLoop = "^(?:for\s+.*?\s+in\s+.*?:|while\s+.*?:)$",
	:pythonIf = "^(?:if|elif|else)\s*.*?:$",
	:pythonWith = "^with\s+.*?\s+as\s+.*?:$",
	:pythonTry = "^(?:try|except|finally|raise)\s*.*?:$",
	
	:pythonList = "^\[(?:[^[\]]*|\[.*?\])*\]$",
	:pythonDict = "^{(?:[^{}]*|{.*?})*}$",
	:pythonTuple = "^\((?:[^()]*|\(.*?\))*\)$",
	:pythonComprehension = "^\[.*?\s+for\s+.*?\s+in\s+.*?\]$",
	
	:pythonComment = "^#.*$",
	:pythonDocstring = "^[" + StzChar(34) + "]{3}[\s\S]*?[" + StzChar(34) + "]{3}$",
	
	:pythonImport = "^(?:import|from)\s+[\w.]+(?:\s+import\s+(?:\w+(?:\s+as\s+\w+)?(?:\s*,\s*\w+(?:\s+as\s+\w+)?)*|\*))?\s*$",
	
	# JavaScript Language Patterns
	
	:jsString = "^(?:[" + StzChar(34) + "].*?[" + StzChar(34) + "]|'.*?'|`[\s\S]*?`)$",
	:jsNumber = "^-?\d+(?:\.\d+)?(?:e[+-]?\d+)?$",
	:jsBoolean = "^(?:true|false|null|undefined)$",
	:jsVariable = "^(?:var|let|const)\s+[a-zA-Z_$][\w$]*(?:\s*=\s*.*)?$",
	
	:jsFunction = "^(?:function\s+([a-zA-Z_$][\w$]*)\s*\((.*?)\)|(?:async\s+)?function\s*\((.*?)\))\s*{$",
	:jsArrowFunction = "^(?:const\s+)?([a-zA-Z_$][\w$]*)\s*=\s*(?:async\s+)?\((.*?)\)\s*=\s*(?:{|\S.*)$",
	:jsFunctionCall = "^([a-zA-Z_$][\w$]*)\s*\((.*?)\)$",
	
	:jsClass = "^class\s+([a-zA-Z_$][\w$]*)(?:\s+extends\s+([a-zA-Z_$][\w$]*))?$",
	:jsClassMethod = "^(?:async\s+)?([a-zA-Z_$][\w$]*)\s*\((.*?)\)\s*{$",
	:jsDecorator = "^@[a-zA-Z_$][\w$]*(?:\((.*?)\))?$",
	
	:jsLoop = "^(?:for|while|do)\s*\(.*?\)$",
	:jsIf = "^if\s*\(.*?\)$",
	:jsSwitch = "^switch\s*\(.*?\)\s*{$",
	:jsTry = "^(?:try|catch|finally)\s*(?:\(.*?\))?\s*{$",
	
	:jsObject = "^{(?:[^{}]*|{.*?})*}$",
	:jsArray = "^\[(?:[^[\]]*|\[.*?\])*\]$",
	:jsDestructuring = "^(?:let|const|var)?\s*(?:{[^}]*}|\[[^\]]*\])\s*=\s*.*$",
	
	:jsComment = "^(?://.*|/\*[\s\S]*?\*/)$",
	
	:jsImport = "^import\s+(?:{[^}]*}|\*\s+as\s+\w+|\w+)\s+from\s+[" + StzChar(34) + "'].*?[" + StzChar(34) + "']$",
	:jsExport = "^export\s+(?:default\s+)?(?:class|function|const|let|var)\s+.*$",
	
	# Visual Basic Language Patterns
	
	:vbString = "^[" + StzChar(34) + "].*?[" + StzChar(34) + "]$",
	:vbNumber = "^-?\d+(?:\.\d+)?$",
	:vbBoolean = "^(?:True|False)$",
	:vbVariable = "^(?:Dim|Private|Public|Protected)\s+([a-zA-Z_]\w*)\s+As\s+\w+$",
	
	:vbFunction = "^(?:Public\s+|Private\s+|Protected\s+)?Function\s+([a-zA-Z_]\w*)\s*\((.*?)\)\s+As\s+\w+$",
	:vbSub = "^(?:Public\s+|Private\s+|Protected\s+)?Sub\s+([a-zA-Z_]\w*)\s*\((.*?)\)$",
	:vbFunctionCall = "^([a-zA-Z_]\w*)\s*\((.*?)\)$",
	
	:vbClass = "^(?:Public\s+|Private\s+)?Class\s+([a-zA-Z_]\w*)$",
	:vbInterface = "^(?:Public\s+|Private\s+)?Interface\s+([a-zA-Z_]\w*)$",
	:vbProperty = "^(?:Public\s+|Private\s+|Protected\s+)?Property\s+(?:Get|Let|Set)\s+([a-zA-Z_]\w*)\s*\((.*?)\)\s+As\s+\w+$",
	
	:vbLoop = "^(?:For|Do|While|For\s+Each)\s+.*$",
	:vbIf = "^(?:If|ElseIf|Else)\s+.*?\s+Then$",
	:vbSelect = "^Select\s+Case\s+.*$",
	:vbTry = "^(?:Try|Catch|Finally)\s*$",
	
	:vbArray = "^(?:Dim|Private|Public|Protected)\s+([a-zA-Z_]\w*)\s*\(\s*\d*\s*\)\s+As\s+\w+$",
	:vbCollection = "^New\s+Collection$",
	
	:vbComment = "^'.*$",
	:vbRemark = "^REM\s+.*$",
	
	:vbModule = "^(?:Public\s+|Private\s+)?Module\s+([a-zA-Z_]\w*)$",
	:vbNamespace = "^Namespace\s+[\w.]+$",
	
	:vbImports = "^Imports\s+[\w.]+$",
	:vbReference = "^Reference\s+=\s+.*$",

	# Julia Language Patterns

	:juliaString = "^(?:[" + StzChar(34) + "]{3}.*?[" + StzChar(34) + "]{3}|[" + StzChar(34) + "].*?[" + StzChar(34) + "]|r[" + StzChar(34) + "].*?[" + StzChar(34) + "]|raw[" + StzChar(34) + "].*?[" + StzChar(34) + "])$",
	:juliaNumber = "^-?(?:\\d+(?:\\.\\d*)?|\\.\\d+)(?:e[+-]?\\d+)?(?:[ff]32|f64)?$",
	:juliaBoolean = "^(?:true|false|nothing|missing)$",
	:juliaVariable = "^[a-zA-Z_][\\w!]*$",
    
	:juliaFunction = "^function\\s+([a-zA-Z_][\\w!]*)\\s*\\(([^)]*?)\\)(?:\\s*::\\s*[\\w{}.\\[\\]]+)?\\s*(?:where\\s+{.*?})?$",
	:juliaFunctionCall = "^([a-zA-Z_][\\w!]*)\\s*\\((.*?)\\)$",
	:juliaLambda = "^(?:[^->]+->|function\\s*\\([^)]*\\)).*$",
    
	:juliaStruct = "^(?:mutable\\s+)?struct\\s+([a-zA-Z_][\\w!]*)(?:{.*?})?(?:<:\\s*[\\w.]+)?$",
	:juliaAbstract = "^abstract\\s+type\\s+([a-zA-Z_][\\w!]*)(?:{.*?})?(?:<:\\s*[\\w.]+)?$",
	:juliaMacro = "^@[a-zA-Z_][\\w!]*(?:\\s|$)",
    
	:juliaLoop = "^(?:for\\s+.*?\\s+in\\s+.*?|while\\s+.*?)$",
	:juliaIf = "^(?:if|elseif|else)\\s*.*?$",
	:juliaBegin = "^begin\\s*$",
	:juliaTry = "^(?:try|catch|finally)\\s*.*?$",
    
	:juliaArray = "^\\[(?:[^\\[\\]]*|\\[.*?\\])*\\]$",
	:juliaTuple = "^\\((?:[^()]*|\\(.*?\\))*\\)$",
	:juliaDict = "^Dict\\((?:[^()]*|\\(.*?\\))*\\)$",
	:juliaComprehension = "^\\[.*?\\s+for\\s+.*?\\s+in\\s+.*?\\]$",
    
	:juliaComment = "^#=(?:[^=#]|=(?!#))*=#$|^#.*$",
	:juliaDocString = "^[" + StzChar(34) + "]{3}[\\s\\S]*?[" + StzChar(34) + "]{3}$",
    
	:juliaImport = "^(?:using|import)\\s+(?:[\\w.]+(?:\\s*:\\s*(?:[\\w,\\s]+|\\(.*?\\)))?(?:\\s*,\\s*[\\w.]+(?:\\s*:\\s*(?:[\\w,\\s]+|\\(.*?\\)))?)*)$",
    
	:juliaModule = "^module\\s+[a-zA-Z_][\\w!]*$",
	:juliaExport = "^export\\s+(?:[a-zA-Z_][\\w!]*(?:\\s*,\\s*[a-zA-Z_][\\w!]*)*)$",
    
	:juliaTypeParameter = "^(?:[a-zA-Z_][\\w!]*){.*?}$",
	:juliaTypeAnnotation = "^::\\s*[\\w{}.\\[\\]]+$",
    
	:juliaBroadcast = "^\\.\\w+$",

	# Excel Formula Script

	:xlsFunctionCall = "^\\s*[A-Z]+\\(.*\\)$",
	:xlsCellReference = "^[A-Z]+\\d+$",
	:xlsRangeReference = "^[A-Z]+\\d+:[A-Z]+\\d+$",
	:xlsRelativeReference = "^(?:[A-Z]*\\d+|[A-Z]+\\d*)$",
	:xlsAbsoluteReference = "^\\$[A-Z]+\\$\\d+$",
	:xlsMixedReference = "^(?:\\$[A-Z]+\\d+|[A-Z]+\\$\\d+)$",
	:xlsStringLiteral = "^\" + StzChar(34) + ".*\" + StzChar(34) + "$",
	:xlsNumberLiteral = "^-?\\d+(\\.\\d+)?$",
	:xlsBooleanLiteral = "^(TRUE|FALSE)$",
	:xlsArithmeticExpression = "^.*(?:[+\\-*/^]).*$",
	:xlsConditionalExpression = "^.*(?:=|<|>|<>).*$",
	:xlsArrayFormula = "^\{(?:\s*=\s*[A-Za-z]+\([^\)]*\)|\s*[A-Za-z0-9\+\-\*/\(\)\&\^\.]+(\s*,\s*[A-Za-z0-9\+\-\*/\(\)\&\^\.]+)*\s*)\}$",

	# R language patterns

	:rVariableName = "^[A-Za-z.][A-Za-z0-9._]*$",
	:rFunctionCall = "^[A-Za-z.][A-Za-z0-9._]*\\s*\\(.*\\)$",
	:rAssignment = "^\\s*[A-Za-z.][A-Za-z0-9._]*\\s*(<-|=)\\s*.*$",
	:rNumericVector = "^c\\((\\s*-?\\d+(\\.\\d+)?\\s*(,\\s*-?\\d+(\\.\\d+)?\\s*)*)?\\)$",
	:rStringVector = "^c\\((\\s*\" + StzChar(34) + ".*?\" + StzChar(34) + "\\s*(,\\s*\" + StzChar(34) + ".*?\" + StzChar(34) + "\\s*)*)?\\)$",
	:rDataFrame = "^[A-Za-z.][A-Za-z0-9._]*\\s*<-\\s*data\\.frame\\(.*\\)$",
	:rPipeOperator = "\\s*%>%\\s*",
	:rComment = "^\\s*#.*$",
	:rLogicalOperator = "(\\&\\&|\\|\\||\\!|==|!=|<|<=|>|>=)",
	:rIndexing = "\\[.*?\\]",
	:rForLoop = "^\\s*for\\s*\\(\\s*[A-Za-z.][A-Za-z0-9._]*\\s*in\\s*.*\\)\\s*\\{",
	:rIfStatement = "^\\s*if\\s*\\(.*\\)\\s*\\{",
	:rElseStatement = "^\\s*else\\s*\\{",
	:rLibraryCall = "^\\s*(library|require)\\s*\\(.*\\)$",
	:rFunctionDefinition = "^\\s*[A-Za-z.][A-Za-z0-9._]*\\s*<-\\s*function\\s*\\(.*\\)\\s*\\{",
	:rListCreation = "^list\\(.*\\)$",
	:rApplyFamily = "(apply|lapply|sapply|vapply|mapply|tapply)\\s*\\(.*\\)",

	# Credit cards and Bank accounts

	:creditCard = "^\\d{4}[- ]?\\d{4}[- ]?\\d{4}[- ]?\\d{4}$",
	:bankAccount = "^\\d{8,20}$",
	:iban = "^[A-Z]{2}\\d{2}[A-Z0-9]{1,30}$",
	:swiftCode = "^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$",

	# Mathematic formulas

	:simpleEquation = "^[A-Za-z0-9\\+\\-\\*/=\\(\\)\\.\\^\\s]+$",
	:quadraticFormula = "^-?\\d*[A-Za-z]\\^2\\s*[+-]?\\s*\\d*[A-Za-z]\\s*[+-]?\\s*\\d+\\s*=\\s*0$",

	# DNA and Chemistry

	:dnaSequence = "^[ACGT]+$",
	:chemicalFormula = "^[A-Z][a-z]?\\d*(?:[A-Z][a-z]?\\d*)*$",

	# Measurements

	:metricMeasurement = "^\\d+(\\.\\d+)?\\s?(mm|cm|m|km)$",
	:imperialMeasurement = "^\\d+(\\.\\d+)?\\s?(in|ft|yd|mi)$",
	:temperature = "^-?\\d+(\\.\\d+)?\\s?(°C|°F|K)$",

	# Batcodes and QR-codes

	:upc = "^\\d{12}$",
	:ean13 = "^\\d{13}$",
	:code128 = "^[!-~]+$", 
	:qrCodeData = "^[A-Za-z0-9\\-._~:/?#\\[\\]@!$&'()*+,;=%]*$", 
	:isbn10 = "^\\d{9}[\\dX]$", 
	:isbn13 = "^978\\d{10}$",

	# Semantic Versioning (major.minor.patch)

	:semVer = "^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?(?:\\+([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?$",
	:strictSemVer = "^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)$",
	:versionWithBuild = "^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:\\+([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?$",
	:preReleaseVersion = "^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)-([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*)$",
	:versionWithPrefix = "^v?(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)$",
	:dateVersion = "^(\\d{4})[.-]?(0[1-9]|1[0-2])[.-]?(0[1-9]|[12]\\d|3[01])$",
	:windowsVersion = "^(\\d+)\\.(\\d+)\\.(\\d+)\\.(\\d+)$",
	:pythonVersion = "^(\\d+)\\.(\\d+)\\.(\\d+)(?:[abrc]\\d+|\\.post\\d+|\\.dev\\d+)?$",
	:mavenVersion = "^(\\d+)(?:\\.(\\d+))?(?:\\.(\\d+))?(?:-([A-Za-z0-9.-]+))?$",

	# Common word-based regex patterns
    
	:quotedWord = StzChar(34) + "([^" + StzChar(34) + "]+)" + StzChar(34),
	:singleWord = "^\\w+$",
	:multipleWords = "^[\\w\\s]+$",
	:camelCaseWord = "^[a-z]+([A-Z][a-z]*)*$",
	:snakeCaseWord = "^[a-z]+(_[a-z]+)*$",
	:pascalCaseWord = "^[A-Z][a-z]+([A-Z][a-z]*)*$",
	:kebabCaseWord = "^[a-z]+(-[a-z]+)*$",
    
	# RTL and Language Support

	:arabicChar = "^[\u0600-\u06FF]$",
	:arabicWord = "^[\u0600-\u06FF]+$",
	:rtlSentence = "^[\u0590-\u05FF\u0600-\u06FF\\s]+$",
	:russianWord = "^[\u0400-\u04FF]+$",
	:chineseChar = "^[\u4E00-\u9FFF]+$",
	:nonLatinWord = "^[^a-zA-Z]+$",
    
	# Number detection in different numeral systems

	:arabicNumerals = "^[\u0660-\u0669]+$",
	:devanagariNumerals = "^[\u0966-\u096F]+$",
	:easternArabicNumerals = "^[\u06F0-\u06F9]+$",
	:universalNumber = "^[0-9\u0660-\u0669\u06F0-\u06F9\u0966-\u096F]+$",
    
	# Punctuation variations

	:punctuationMarks = "^[.,!?;:'\" + StzChar(34) + "”“\(\)\[\]\{\}]+$",

	# Password Complexity Patterns

	:passworWeak = "^.{6,}$",
	:passwordSimple = "^.{8,}$",
	:passwordWithDigits = "^(?=.*[0-9]).{8,}$",
	:passwordWithUpperLower = "^(?=.*[a-z])(?=.*[A-Z]).{8,}$",
	:passwordWithSpecialChar = "^(?=.*[!@#$%^&*(),.?\" + StzChar(34) + ":{}|<>]).{8,}$",
	:passwordStrong = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?\" + StzChar(34) + ":{}|<>]).{12,}$",

	# API Keys and Secrets Detection

	:hexSecret = "^[a-fA-F0-9]{32,}$",
	:base64Secret = "^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$",
	:jwtToken = "^[A-Za-z0-9-_]+\\.[A-Za-z0-9-_]+\\.[A-Za-z0-9-_]+$",
	:awsAccessKey = "^AKIA[0-9A-Z]{16}$",
	:awsSecretKey = "^[0-9a-zA-Z/+]{40}$",
	:privateKeyPEM = "-----BEGIN (RSA|EC|DSA|PRIVATE) KEY-----[\\s\\S]+-----END (RSA|EC|DSA|PRIVATE) KEY-----",

	# Personally Identifiable Information (PII)

	:ssnUSA = "^\\d{3}-\\d{2}-\\d{4}$",
	:passportNumber = "^[A-Z0-9]{6,9}$",

	# Other Sensitive Data

	:hexadecimalEntropy = "^[0-9a-fA-F]{64,}$",
	:uuid = "^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
	:bcryptHash = "^\\$2[ayb]\\$\\d{2}\\$[./A-Za-z0-9]{53}$"

]

#-----------------------------------#
#  REGEX EXPLANATIONS KNWOLEDGBASE  #
#-----------------------------------#

_$aRegexPatternsExplanations_ = [

	# String patterns

	:textWithNumberSuffix = [
		"Splits string into non-numeric prefix and numeric suffix",

		"- `^`: Start of string" + char(10) +
		"- `([^\\d]*)`: First group: any sequence of non-digit characters" + char(10) +
		"- `(\\d+)`: Second group: one or more digits" + char(10) +

		"- `$`: End of string" + char(10) + char(10) +
		"- Matches: `#1` → [`#`, `1`], `day3` → [`day`, `3`]" + char(10) +
		"- Non-matches: `123test`, `test`"
	],

	:numberWithTextSuffix = [
		"Splits string into numeric prefix and non-numeric suffix",

		"- `^`: Start of string" + char(10) +
		"- `(\\d+)`: First group: one or more digits" + char(10) +
		"- `([^\\d]*)`: Second group: any sequence of non-digit characters" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `123abc` → [`123`, `abc`], `5px` → [`5`, `px`]" + char(10) +
		"- Non-matches: `abc123`, `abc`"
	],

	:textNumberText = [
		"Splits string into prefix, number, and suffix",

		"- `^`: Start of string" + char(10) +
		"- `([^\\d]*)`: First group: any sequence of non-digit characters" + char(10) +
		"- `(\\d+)`: Second group: one or more digits" + char(10) +
		"- `([^\\d]*)`: Third group: any sequence of non-digit characters" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `page5of10` → [`page`, `5`, `of10`]" + char(10) +
		"- Non-matches: `page`, `123`"
	],

	:alternatingTextNumber = [
		"Matches strings with alternating text and number segments",

		"- `^`: Start of string" + char(10) +
		"- `([^\\d]+\\d+)+`: One or more occurrences of text followed by numbers" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `ab12cd34`, `test99more55`" + char(10) +
		"- Non-matches: `123abc`, `test`"
	],

	:spaceSeparatedWords = [
		"Matches space-separated words",

		"- `^`: Start of string" + char(10) +
		"- `(\\S+)`: First group: one or more non-whitespace characters" + char(10) +
		"- `(?:\\s+\\S+)*`: Zero or more occurrences of space(s) and word" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `hello world`, `one two three`" + char(10) +
		"- Non-matches: `hello\nworld` (contains newline)"
	],

	# Adress patterns

	:addressLine = [
		"Matches a single line of an address",

		"- `^[a-zA-Z0-9.,'’\\-\\s]+$`: Matches alphanumeric characters, common punctuation (`.,'’`), and whitespace." + char(10) + char(10) +

		"- Matches: `123 Main St.`, `Apartment 42-B`, `Building A`." + char(10) +
		"- Non-matches: `123<>|*` (invalid characters)."
	],

	:cityName = [
		"Matches city names",

		"- `^[a-zA-Z\\s\\-']+$`: Matches alphabetic characters, spaces, hyphens, and apostrophes." + char(10) + char(10) +

		"- Matches: `San Francisco`, `O'Connor`, `New-York`." + char(10) +
		"- Non-matches: `123 City` (numbers not allowed)."
	],

	:stateProvinceRegion = [
		"Matches states, provinces, or regions",

		"- `^[a-zA-Z\\s\\-']+$`: Matches alphabetic characters, spaces, hyphens, and apostrophes." + char(10) + char(10) +

		"- Matches: `California`, `Baden-Württemberg`, `Québec`." + char(10) +
		"- Non-matches: `CA123` (numbers not allowed)."
	],

	:postalCode = [
		"Matches postal or ZIP codes",

		"- `^[a-zA-Z0-9\\-\\s]{3,10}$`: Matches alphanumeric characters, hyphens, and spaces, between 3 to 10 characters." + char(10) + char(10) +

		"- Matches: `12345`, `W1A 1AA`, `75008`, `123-456`." + char(10) +
		"- Non-matches: `12` (too short), `12345678910` (too long)."
	],

	:countryName = [
		"Matches country names",

		"- `^[a-zA-Z\\s\\-]+$`: Matches alphabetic characters, spaces, and hyphens." + char(10) + char(10) +

		"- Matches: `United States`, `Côte d'Ivoire`, `South-Africa`." + char(10) +
		"- Non-matches: `123Country` (numbers not allowed)."
	],

	:fullAddress = [
		"Matches a full international address with multiple lines",

		"- `^([a-zA-Z0-9.,'’\\-\\s]+)(\\n[a-zA-Z0-9.,'’\\-\\s]+)*`: Matches one or more address lines." + char(10) +
		"- `\\n([a-zA-Z\\s\\-']+)`: Matches the city name on a new line." + char(10) +
		"- `\\n([a-zA-Z\\s\\-']+)`: Matches the state/province/region on another new line." + char(10) +
		"- `\\n([a-zA-Z0-9\\-\\s]{3,10})`: Matches the postal/ZIP code on a new line." + char(10) +
		"- `\\n([a-zA-Z\\s\\-]+)$`: Matches the country name on the final line." + char(10) + char(10) +

		"- Matches: `123 Main St.\\nApartment 42-B\\nSan Francisco\\nCalifornia\\n94105\\nUnited States`." + char(10) +
		"- Non-matches: `123 Main St., San Francisco, CA 94105, United States` (not separated into lines)."
	],

	# Patterns to Analyze Regex patterns!

	:rxGroup = [
		"Matches regex groups, including nested ones",

		"- `\\(`: Match the opening parenthesis" + char(10) +
    		"- `\\)`: Match the closing parenthesis" + char(10) + char(10) +

		"- Matches: `(abc)`, `((a)(b))`" + char(10) +
		"- Non-matches: `abc`, `(abc`"
	],

	:rxQuantifier = [
		"Detects quantifiers used in regex patterns",

		"- `\\*`: Match zero or more quantifiers" + char(10) +
		"- `\\+`: Match one or more quantifiers" + char(10) +
		"- `\\?`: Match zero or one quantifiers" + char(10) +
		"- `\\{\\d+(,\\d*)?\\}`: Match numeric quantifiers like `{1,3}`" + char(10) + char(10) +

		"- Matches: `a*`, `a+`, `a{2,5}`" + char(10) +
		"- Non-matches: `a`, `{}`"
	],

	:rxCharacterClass = [
		"Identifies character classes, including negated ones",

		"- `\\[`: Match the opening bracket" + char(10) +
		"- `(\\^?[^\]]+)`: Match optional `^` for negation, then all characters until `]`" + char(10) +
		"- `\\]`: Match the closing bracket" + char(10) + char(10) +

		"- Matches: `[abc]`, `[^0-9]`" + char(10) +
		"- Non-matches: `[`, `[abc`"
	],

	:rxAssertion = [
		"Detects lookahead and lookbehind assertions",

		"- `\\(\\?`: Match opening `(?`" + char(10) +
		"- `<?[=!]`: Match `=` or `!` for lookahead, or `<=`/`<!` for lookbehind" + char(10) + char(10) +

		"- Matches: `(?=abc)`, `(?<=abc)`" + char(10) +
		"- Non-matches: `abc`, `()`"
	],

	:rxEscapedChar = [
		"Finds escaped characters in regex patterns",

		"- `\\\\`: Match the escape character `\\`" + char(10) +
		"- `.`: Match any character following the escape" + char(10) + char(10) +

		"- Matches: `\\n`, `\\t`, `\\[`, `\\\\`" + char(10) +
		"- Non-matches: `n`, `[`, `\\\\` (if unescaped)"
	],

	:rxAlternation = [
		"Detects alternation (`|`) in patterns",

		"- `(\\|)`: Match the `|` symbol used for alternation" + char(10) + char(10) +

		"- Matches: `a|b`, `(a|b|c)`" + char(10) +
		"- Non-matches: `a b`, `(abc)`"
	],

	:rxWildcard = [
		"Finds wildcard characters in regex patterns",

		"- `\\.`: Match the `.` character that represents any character" + char(10) + char(10) +

		"- Matches: `a.b`, `.*`" + char(10) +
		"- Non-matches: `a b`, `abc`"
	],

	:rxRedundantAlternation = [
		"Detects redundant alternations that can be replaced by character classes",

		"- `\\(`: Match the opening parenthesis" + char(10) +
		"- `(?:[a-zA-Z0-9]\\|?)+`: Match multiple alternations of single characters" + char(10) +
		"- `\\)`: Match the closing parenthesis" + char(10) + char(10) +

		"- Matches: `(a|b|c)`, `(1|2|3)`" + char(10) +
		"- Non-matches: `[abc]`, `1|23`"
	],

	# Files names and paths

	:fileName = [
		"Matches valid file names",

		"- `^[^<>:\" + StzChar(34) + "/\\|?*\r\n]+$`: Matches any string that does not contain invalid file name characters." + char(10) + char(10) +

		"- Matches: `document.txt`, `image123.png`, `file_name.ext`." + char(10) +
		"- Non-matches: `file/name.txt`, `file|name.ext`, `file:name`."
	],

	:filePath = [
		"Matches valid Windows file paths",

		"- `^(?:[a-zA-Z]:)?`: Optionally matches a drive letter followed by a colon (e.g., `C:`)." + char(10) +
		"- `(?:\\\\[^<>:\" + StzChar(34) + "/\\|?*\r\n]+)+`: Matches one or more folder or file names separated by backslashes." + char(10) +
		"- `\\\\?$`: Allows an optional trailing backslash." + char(10) + char(10) +

		"- Matches: `C:\\Users\\Documents\\file.txt`, `\\folder\\subfolder\\file.ext`." + char(10) +
		"- Non-matches: `C:/Users/Documents/file.txt`, `/folder/subfolder/file.ext`."
	],

	:unixFilePath = [
		"Matches valid Unix/Linux file paths",

		"- `^/`: Matches a leading forward slash for absolute paths." + char(10) +
		"- `(/[^<>:\" + StzChar(34) + "/\\|?*\r\n]+)+`: Matches one or more folder or file names separated by forward slashes." + char(10) +
		"- `/?$`: Allows an optional trailing forward slash." + char(10) + char(10) +

		"- Matches: `/home/user/document.txt`, `/var/log/`, `/file`." + char(10) +
		"- Non-matches: `C:\\Users\\Documents\\file.txt`, `folder/file.txt`."
	],

	:fileExtension = [
		"Matches file extensions",

		"- `\\.[a-zA-Z0-9]+$`: Matches a dot followed by one or more alphanumeric characters." + char(10) + char(10) +

		"- Matches: `.txt`, `.png`, `.zip`." + char(10) +
		"- Non-matches: `filetxt`, `.`, `..ext`."
	],

	:relativeFilePath = [
		"Matches valid relative file paths",

		"- `^(?:\\.\\.?/|[^/<>:\" + StzChar(34) + "|?*]+)`: Matches a dot (`.`) or dot-dot (`..`) for relative paths or a valid folder name." + char(10) +
		"- `(?:/[^/<>:\" + StzChar(34) + "|?*]+)*`: Matches additional folder or file names separated by slashes." + char(10) +
		"- `/?$`: Allows an optional trailing slash." + char(10) + char(10) +

		"- Matches: `./file.txt`, `../folder/file.txt`, `folder/subfolder/file`." + char(10) +
		"- Non-matches: `/absolute/path/file.txt`, `C:\\folder\\file.txt`."
	],

	# Web & Email

	:email = [
		"Matches standard email formats",
	
		"- `^` and `$`: Start and end of the string" + char(10) +
		"- `[a-zA-Z0-9._%+-]+`: Local part allowing letters, numbers, and common special characters" + char(10) +
		"- `@`: Required @ symbol" + char(10) +
		"- `[a-zA-Z0-9.-]+`: Domain name allowing letters, numbers, dots, and hyphens" + char(10) +
		"- `\.[a-zA-Z]{2,}`: Last part of the domain (TLD) with minimum 2 letters" + char(10) + char(10) +

		"- Matches: `user@domain.com`, `user.name+tag@example.co.uk`" + char(10) +
		"- Non-matches: `@domain.com`, `user@.com`, `user@domain`"
	
	],

	:url = [
		"Matches a standard HTTP or HTTPS URL",
	
		"- `^https?:\/\/`: Start with `http://` or `https://`" + char(10) +
		"- `(?:[a-zA-Z0-9-]+\.)+`: Domain part (subdomains are optional)" + char(10) +
		"- `[a-zA-Z]{2,}`: Domain TLD (top-level domain), at least two letters" + char(10) +
		"- `(\/[\w\-._~:/?#[\]@!$&'()*+,;=]*)?$`: Optional path, query, or fragment" + char(10) + char(10) +

		"- Matches: `https://example.com`, `http://domain.co.uk/path?query`" + char(10) +
		"- Non-matches: `htt://example.com`, `://domain.com`"
	],

	:domain = [
		"Matches domain names with letters, numbers, and hyphens",
	
		"- `^[a-zA-Z0-9]`: Domain must start with a letter or number" + char(10) +
		"- `[a-zA-Z0-9-]{1,61}`: Allowed characters include letters, numbers, and hyphens, between 1 and 61" + char(10) +
		"- `[a-zA-Z0-9]`: Domain ends with a letter or number" + char(10) +
		"- `\.[a-zA-Z]{2,}$`: Domain ends with a valid TLD" + char(10) + char(10) +

		"- Matches: `domain.com`, `subdomain.domain.org`" + char(10) +
		"- Non-matches: `-domain.com`, `domain..com`"
	],

	:ipv4 = [
		"Matches valid IPv4 addresses",
	
		"- `^`: Start of string" + char(10) +
		"- `(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)`: Match numbers 0-255" + char(10) +
		"- `\.`: Dot separator between octets" + char(10) +
		"- Pattern repeated 3 times with dots" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `192.168.0.1`, `10.0.0.0`, `255.255.255.255`" + char(10) +
		"- Non-matches: `256.1.2.3`, `1.2.3`, `300.1.2.3`"
	],

	:ipv6 = [
		"Matches valid IPv6 addresses",
	
		"- `([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}`: Full IPv6 address" + char(10) +
		"- `([0-9a-fA-F]{1,4}:){1,7}:`: Compressed format with `::`" + char(10) +
		"- `([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}`: Mixed formats" + char(10) + char(10) +

		"- Matches: `2001:0db8:85a3:0000:0000:8a2e:0370:7334`, `fe80::1`" + char(10) +
		"- Non-matches: `:::1`, `2001:0db8::`"
	],

	:socialHandle = [
		"Matches social media handles",
	
		"- `^`: Start of string" + char(10) +
		"- `@`: Required @ symbol at start" + char(10) +
		"- `[a-zA-Z0-9._]{1,30}`: Username with letters, numbers, dots, underscores" + char(10) +
		"- Maximum length of 30 characters" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `@user123`, `@john.doe`, `@handle_name`" + char(10) +
		"- Non-matches: `user123`, `@user name`, `@`"
	],

	:slug = [
		"Matches URL-friendly slugs",
	
		"- `^`: Start of string" + char(10) +
		"- `[a-z0-9]+`: One or more lowercase letters or numbers" + char(10) +
		"- `(?:-[a-z0-9]+)*`: Optional groups of hyphen followed by alphanumerics" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `my-blog-post`, `article-123`, `hello`" + char(10) +
		"- Non-matches: `-post`, `Post-Title`, `my--post`"
	],

	# Dates & Times (International)

	:isoDate = [
		"Matches ISO 8601 date format (YYYY-MM-DD)",
	
		"- `^`: Start of string" + char(10) +
		"- `\d{4}`: Four digits for year" + char(10) +
		"- `-`: Literal hyphen separator" + char(10) +
		"- `(0[1-9]|1[0-2])`: Month 01-12" + char(10) +
		"- `-`: Literal hyphen separator" + char(10) +
		"- `(0[1-9]|[12][0-9]|3[01])`: Day 01-31" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `2023-12-25`, `2024-01-01`" + char(10) +
		"- Non-matches: `2023/12/25`, `23-12-25`"
	],

	:isoDateTime = [
		"Matches ISO 8601 datetime format with optional timezone",
	
		"- Starts with ISO date format" + char(10) +
		"- `T`: Time separator" + char(10) +
		"- `([01]?[0-9]|2[0-3])`: Hours (00-23)" + char(10) +
		"- `:[0-5][0-9]:[0-5][0-9]`: Minutes and seconds" + char(10) +
		"- `(\.[0-9]+)?`: Optional fractional seconds" + char(10) +
		"- `(Z|[+-][01][0-9]:[0-5][0-9])?`: Optional timezone" + char(10) + char(10) +

		"- Matches: `2023-12-25T14:30:00Z`, `2024-01-01T09:00:00+01:00`" + char(10) +
		"- Non-matches: `2023-12-25 14:30`, `2023-12-25T25:00:00Z`"
	],

	:ddmmyyyy = [
		"Matches dates in DD/MM/YYYY format with various separators",
	
		"- `^`: Start of string" + char(10) +
		"- `(0[1-9]|[12][0-9]|3[01])`: Day (01-31)" + char(10) +
		"- `[-/.]`: Separator (hyphen, forward slash, or dot)" + char(10) +
		"- `(0[1-9]|1[0-2])`: Month (01-12)" + char(10) +
		"- `[-/.]`: Same separator as above" + char(10) +
		"- `\d{4}`: Four-digit year" + char(10) + char(10) +

		"- Matches: `25/12/2023`, `01-01-2024`, `31.12.2023`" + char(10) +
		"- Non-matches: `32/12/2023`, `13/13/2023`"
	],

	:mmddyyyy = [
		"Matches dates in MM/DD/YYYY format with various separators",
	
		"- `^`: Start of string" + char(10) +
		"- `(0[1-9]|1[0-2])`: Month (01-12)" + char(10) +
		"- `[-/.]`: Separator (hyphen, forward slash, or dot)" + char(10) +
		"- `(0[1-9]|[12][0-9]|3[01])`: Day (01-31)" + char(10) +
		"- `[-/.]`: Same separator as above" + char(10) +
		"- `\d{4}`: Four-digit year" + char(10) + char(10) +

		"- Matches: `12/25/2023`, `01-01-2024`, `12.31.2023`" + char(10) +
		"- Non-matches: `13/25/2023`, `12/32/2023`"
	],

	:time24h = [
		"Matches 24-hour time format (HH:MM)",
	
		"- `^`: Start of string" + char(10) +
		"- `([01]?[0-9]|2[0-3])`: Hours (0-23)" + char(10) +
		"- `:`: Time separator" + char(10) +
		"- `[0-5][0-9]`: Minutes (00-59)" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `23:59`, `00:00`, `14:30`" + char(10) +
		"- Non-matches: `24:00`, `12:60`, `1:5`"
	],

	:time24hSeconds = [
		"Matches 24-hour time format with seconds (HH:MM:SS)",
	
		"- `^`: Start of string" + char(10) +
		"- `([01]?[0-9]|2[0-3])`: Hours (0-23)" + char(10) +
		"- `:[0-5][0-9]`: Minutes (00-59)" + char(10) +
		"- `:[0-5][0-9]`: Seconds (00-59)" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `23:59:59`, `00:00:00`, `14:30:45`" + char(10) +
		"- Non-matches: `24:00:00`, `12:60:30`"
	],

	:time12h = [
		"Matches 12-hour time format with AM/PM (HH:MM AM/PM)",
	
		"- `^`: Start of string" + char(10) +
		"- `(0?[1-9]|1[0-2])`: Hours (1-12, optional leading zero)" + char(10) +
		"- `:[0-5][0-9]`: Minutes (00-59)" + char(10) +
		"- `\s?`: Optional whitespace before AM/PM" + char(10) +
		"- `(AM|PM|am|pm)`: AM or PM (case insensitive)" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `11:30 PM`, `9:45AM`, `12:00 am`" + char(10) +
		"- Non-matches: `13:00 PM`, `00:30 AM`"
	],

	:time12hSeconds = [
		"Matches 12-hour time format with seconds and AM/PM",
	
		"- `^`: Start of string" + char(10) +
		"- `(0?[1-9]|1[0-2])`: Hours (1-12)" + char(10) +
		"- `:[0-5][0-9]:[0-5][0-9]`: Minutes and seconds" + char(10) +
		"- `\s?(AM|PM|am|pm)`: Optional space before AM/PM" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `11:30:45 PM`, `9:45:00AM`" + char(10) +
		"- Non-matches: `13:00:00 PM`"
	],

	:date = [
	    "Matches common date formats without time",
	    
	    "- `\\b`: Word boundary to avoid matching inside words" + char(10) +
	    "- `(?: ... )`: Non-capturing group for alternative formats" + char(10) +
	
	    "- `\\d{1,4}[-/.]\\d{1,2}[-/.]\\d{1,4}`: Numeric date format" + char(10) +
	    "    • Examples: `2025-09-30`, `30/09/2025`, `09.30.25`" + char(10) +
	
	    "- `|`: OR (between numeric and text month formats)" + char(10) +
	
	    "- `\\d{1,2}\\s+[A-Za-z]{3,9}\\s+\\d{2,4}`: Day MonthName Year format" + char(10) +
	    "    • Examples: `30 Sept 2025`, `1 January 99`" + char(10) +
	
	    "- `[-/.]`: Accepts `-`, `/`, or `.` as separators" + char(10) +
	    "- `[A-Za-z]{3,9}`: Matches month names (short or long)" + char(10) +
	    "- `\\b`: Word boundary at the end" + char(10) + char(10) +
	
	    "- Matches: `2025-09-30`, `30/09/2025`, `09.30.25`, `30 Sept 2025`" + char(10) +
	    "- Non-matches: `2025-09-30 12:00`, `hello2025-09-30world`, `99/99/9999`"
	],

	# DateTime Combined Patterns

	:dateTimeSpace = [
		"Matches ISO date with 24-hour time separated by space",

		"- `^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])`: ISO date" + char(10) +
		"- `\s`: Space separator" + char(10) +
		"- `([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]`: 24-hour time with seconds" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `2024-01-15 14:30:00`, `2023-12-31 23:59:59`" + char(10) +
		"- Non-matches: `2024-01-15T14:30:00`, `2024/01/15 14:30:00`"
	],

	:dateTimeUS = [
		"Matches US date format (MM/DD/YYYY) with 24-hour time",

		"- `^(0[1-9]|1[0-2])[-/.](0[1-9]|[12][0-9]|3[01])[-/.]\d{4}`: US date" + char(10) +
		"- `\s`: Space separator" + char(10) +
		"- `([01]?[0-9]|2[0-3]):[0-5][0-9]`: 24-hour time" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `12/25/2023 14:30`, `01-01-2024 09:00`" + char(10) +
		"- Non-matches: `25/12/2023 14:30`, `13/01/2024 14:30`"
	],

	:dateTimeEU = [
		"Matches European date format (DD/MM/YYYY) with 24-hour time",

		"- `^(0[1-9]|[12][0-9]|3[01])[-/.](0[1-9]|1[0-2])[-/.]\d{4}`: EU date" + char(10) +
		"- `\s`: Space separator" + char(10) +
		"- `([01]?[0-9]|2[0-3]):[0-5][0-9]`: 24-hour time" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `25/12/2023 14:30`, `01-01-2024 09:00`" + char(10) +
		"- Non-matches: `12/25/2023 14:30`, `32/12/2023 14:30`"
	],

	:dateTime12h = [
		"Matches US date with 12-hour time and AM/PM",

		"- `^(0[1-9]|1[0-2])[-/.](0[1-9]|[12][0-9]|3[01])[-/.]\d{4}`: US date" + char(10) +
		"- `\s`: Space separator" + char(10) +
		"- `(0?[1-9]|1[0-2]):[0-5][0-9]`: 12-hour time" + char(10) +
		"- `\s?(AM|PM|am|pm)`: Optional space before AM/PM" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `12/25/2023 2:30 PM`, `01-01-2024 09:00AM`" + char(10) +
		"- Non-matches: `25/12/2023 14:30 PM`, `12/25/2023 13:00 PM`"
	],

	:dateTimeLong = [
		"Matches long date format with time (D Month YYYY, HH:MM)",

		"- `^\d{1,2}`: Day (1-31)" + char(10) +
		"- `\s[A-Za-z]{3,9}\s`: Month name (short or long)" + char(10) +
		"- `\d{4}`: Four-digit year" + char(10) +
		"- `,?`: Optional comma" + char(10) +
		"- `\s([01]?[0-9]|2[0-3]):[0-5][0-9]`: 24-hour time" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `25 December 2023, 14:30`, `1 Jan 2024 09:00`" + char(10) +
		"- Non-matches: `December 25 2023, 14:30`, `32 Dec 2023 14:30`"
	],

	# Timestamp & Unix Patterns

	:unixTimestamp = [
		"Matches Unix timestamp in seconds (10 digits)",

		"- `^`: Start of string" + char(10) +
		"- `\d{10}`: Exactly 10 digits" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `1609459200`, `1672531199`" + char(10) +
		"- Non-matches: `160945920`, `16094592000`"
	],

	:unixTimestampMillis = [
		"Matches Unix timestamp in milliseconds (13 digits)",

		"- `^`: Start of string" + char(10) +
		"- `\d{13}`: Exactly 13 digits" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `1609459200000`, `1672531199999`" + char(10) +
		"- Non-matches: `1609459200`, `16094592000000`"
	],

	:timestampWithMillis = [
		"Matches ISO 8601 timestamp with milliseconds",

		"- ISO date format (YYYY-MM-DD)" + char(10) +
		"- `T`: Time separator" + char(10) +
		"- `([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]`: Time" + char(10) +
		"- `\.\d{3}`: Dot and exactly 3 millisecond digits" + char(10) +
		"- `Z?`: Optional UTC timezone indicator" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `2023-12-25T14:30:00.123Z`, `2024-01-01T00:00:00.000`" + char(10) +
		"- Non-matches: `2023-12-25T14:30:00`, `2023-12-25T14:30:00.12Z`"
	],

	# Flexible DateTime Patterns

	:DateTime = [
		"Matches various datetime formats flexibly",

		"- `\\b`: Word boundary" + char(10) +
		"- `\d{4}[-/.]\d{1,2}[-/.]\d{1,2}`: Date part with flexible separators" + char(10) +
		"- `[T\s]`: T or space separator" + char(10) +
		"- `\d{1,2}:\d{2}`: Hours and minutes" + char(10) +
		"- `(:\d{2})?`: Optional seconds" + char(10) +
		"- `(\.\d+)?`: Optional fractional seconds" + char(10) +
		"- `(Z|[+-]\d{2}:\d{2})?`: Optional timezone" + char(10) +
		"- `\\b`: Word boundary" + char(10) + char(10) +

		"- Matches: `2023-12-25T14:30`, `2024/01/01 9:00:00.123Z`, `2023.12.25 14:30:00+01:00`" + char(10) +
		"- Non-matches: `Hello 2023-12-25T14:30 World` (extracts the datetime)"
	],

	:rfc2822DateTime = [
		"Matches RFC 2822 datetime format (email headers)",

		"- `^[A-Za-z]{3}`: Day of week (3 letters)" + char(10) +
		"- `,\s\d{1,2}\s`: Comma, space, day (1-2 digits), space" + char(10) +
		"- `[A-Za-z]{3}\s`: Month (3 letters), space" + char(10) +
		"- `\d{4}\s`: Four-digit year, space" + char(10) +
		"- `\d{2}:\d{2}:\d{2}\s`: Time (HH:MM:SS), space" + char(10) +
		"- `[+-]\d{4}`: Timezone offset (+/-HHMM)" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `Mon, 25 Dec 2023 14:30:00 +0000`, `Fri, 1 Jan 2024 09:00:00 -0500`" + char(10) +
		"- Non-matches: `25 Dec 2023 14:30:00`, `Mon Dec 25 2023 14:30:00`"
	],

	# Markdown

	:mdHeader = [
		"Matches Markdown headers",
        
		"- `^`: Start of line" + char(10) +
		"- `#{1,6}`: 1 to 6 hash symbols" + char(10) +
		"- `\\s`: Required space" + char(10) +
		"- `.+`: Header text" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `# Header`, `### Subheader`" + char(10) +
		"- Non-matches: `#Header`, `####### TooManyHashes`"
	],

	:mdBold = [
		"Matches Markdown bold text",
        
		"- `\\*\\*`: Two asterisks" + char(10) +
		"- `[^*]+`: Any characters except asterisk" + char(10) +
		"- `\\*\\*`: Closing asterisks" + char(10) + char(10) +

		"- Matches: `**bold text**`, `**important**`" + char(10) +
		"- Non-matches: `*single*`, `**incomplete`"
	],

	:mdItalic = [
		"Matches Markdown italic text",
 
		"- `\\*`: Single asterisk" + char(10) +
		"- `[^*]+`: Any characters except asterisk" + char(10) +
		"- `\\*`: Closing asterisk" + char(10) + char(10) +

		"- Matches: `*italic*`, `*emphasized*`" + char(10) +
		"- Non-matches: `**bold**`, `*incomplete`"
	],

	:mdLink = [
		"Matches Markdown links",

		"- `\\[`: Opening square bracket" + char(10) +
		"- `([^\\]]+)`: Link text (anything but closing bracket)" + char(10) +
		"- `\\]`: Closing square bracket" + char(10) +
		"- `\\(`: Opening parenthesis" + char(10) +
		"- `([^\\)]+)`: URL (anything but closing parenthesis)" + char(10) +
		"- `\\)`: Closing parenthesis" + char(10) + char(10) +

		"- Matches: `[link](url)`, `[Example](http://example.com)`" + char(10) +
		"- Non-matches: `[link](`, `[link]`"
	],

	:mdImage = [
		"Matches Markdown images",

		"- `!`: Exclamation mark prefix" + char(10) +
		"- `\\[`: Opening square bracket" + char(10) +
		"- `([^\\]]*)`': Alt text (optional, anything but closing bracket)" + char(10) +
		"- `\\]`: Closing square bracket" + char(10) +
		"- `\\(`: Opening parenthesis" + char(10) +
		"- `([^\\)]+)`: Image URL (anything but closing parenthesis)" + char(10) +
		"- `\\)`: Closing parenthesis" + char(10) + char(10) +

		"- Matches: `![alt](image.jpg)`, `![](photo.png)`" + char(10) +
		"- Non-matches: `[img](pic.jpg)`, `![alt]()`"
	],

	:mdBlockquote = [
		"Matches Markdown blockquotes",

		"- `^`: Start of line" + char(10) +
		"- `>`: Greater than symbol" + char(10) +
		"- `\\s`: Required space" + char(10) +
		"- `.+`: Quoted text" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `> Quote`, `> Multiple words`" + char(10) +
		"- Non-matches: `>No space`, `Quote>`"
	],

	:mdCodeBlock = [
		"Matches Markdown code blocks",

		"- ```" + StzChar(34) + ": Three backticks opening" + char(10) +
		"- `[^`]*`: Any characters except backtick" + char(10) +
		"- ```" + StzChar(34) + ": Three backticks closing" + char(10) + char(10) +

		"- Matches: ```code block```, ```multiple" + char(10) + "lines```" + char(10) +
		"- Non-matches: ``two ticks``, ````four ticks````"
	],

	:mdInlineCode = [
		"Matches Markdown inline code",

		"- `` ` ``: Single backtick" + char(10) +
		"- `[^`]+`: Any characters except backtick" + char(10) +
		"- `` ` ``: Closing backtick" + char(10) + char(10) +

		"- Matches: `code`, `var x = 1`" + char(10) +
		"- Non-matches: ``double``, `unclosed"
	],

	:mdListItem = [
		"Matches Markdown unordered list items",

		"- `^`: Start of line" + char(10) +
		"- `[-*+]`: Either hyphen, asterisk, or plus sign" + char(10) +
		"- `\\s`: Required space" + char(10) +
		"- `.+`: List item text" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `- Item`, `* Point`, `+ Element`" + char(10) +
		"- Non-matches: `Item-`, `-No space`"
	],

	:mdNumberedList = [
		"Matches Markdown numbered list items",

		"- `^`: Start of line" + char(10) +
		"- `\\d+`: One or more digits" + char(10) +
		"- `\\.`: Literal period" + char(10) +
		"- `\\s`: Required space" + char(10) +
		"- `.+`: List item text" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `1. First`, `42. Item`" + char(10) +
		"- Non-matches: `1.No space`, `A. Letter`"
	],

	# YAML Patterns
	
   	:yamlKey = [
		"Matches YAML keys",

		"- `^`: Start of line" + char(10) +
		"- `[a-zA-Z0-9]+`: At least one alphanumeric character" + char(10) +
		"- `[a-zA-Z0-9_-]*`: Optional alphanumeric, underscore, or hyphen characters" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `key`, `user123`, `my-key`, `long_key_name`" + char(10) +
		"- Non-matches: `123`, `-key`, `key:`, `invalid!key`"
	],

	:yamlValue = [
		"Matches YAML values (strings, numbers, booleans, null)",

		"- `^`: Start of line" + char(10) +
		"- `(`: Start first alternative (quoted strings):" + char(10) +
		"  - `\\ " + StzChar(34) + "`: Opening quote" + char(10) +
		"  - `[^\\ " + StzChar(34) + "]*`: Any characters except quotes" + char(10) +
		"  - `\\ " + StzChar(34) + "`: Closing quote" + char(10) +
		"- `)`: End first alternative" + char(10) +
		"- `|`: OR" + char(10) +
		"- `([0-9]+)`: Second alternative (numbers)" + char(10) +
		"- `|`: OR" + char(10) +
		"- `(true|false)|null`: Third alternative (booleans and null)" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `" + StzChar(34) + "hello" + StzChar(34) + "`, `42`, `true`, `false`, `null`" + char(10) +
		"- Non-matches: `'single quotes'`, `-42`, `True`, `NULL`"
	],

	:yamlMap = [
		"Matches YAML key-value mappings",

		"- `^`: Start of line" + char(10) +
		"- `[a-zA-Z0-9]+`: Key (at least one alphanumeric character)" + char(10) +
		"- `:`: Colon separator" + char(10) +
		"- `[ ]*`: Optional spaces" + char(10) +
		"- `.+`: Value (any non-empty string)" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `name: John`, `age: 25`, `active: true`" + char(10) +
		"- Non-matches: `: value`, `key :value`, `key:`, `-key: value`"
	],

	:yamlArray = [
		"Matches YAML array elements (numbers or quoted strings)",

		"- `^`: Start of line" + char(10) +
		"- `-?[0-9]+`: First alternative (optional negative sign followed by digits)" + char(10) +
		"- `|`: OR" + char(10) +
		"- `\\ " + StzChar(34) + "`: Opening quote" + char(10) +
		"- `[^\\ " + StzChar(34) + "]*`: Any characters except quotes" + char(10) +
		"- `\\ " + StzChar(34) + "`: Closing quote" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `42`, `-42`, `" + StzChar(34) + "element" + StzChar(34) + "`, `" + StzChar(34) + "item 1" + StzChar(34) + "`" + char(10) +
		"- Non-matches: `true`, `null`, `'single quotes'`, `plain text`"
	],

	:yamlFrontMatter = [
		"Matches YAML front matter blocks",

		"- `^`: Start of line" + char(10) +
		"- `---`: Opening delimiter" + char(10) +
		"- `\\s*\\n`: Optional whitespace and newline" + char(10) +
		"- `(.*?)`: Non-greedy capture of any characters" + char(10) +
		"- `\\n---`: Closing delimiter with newline" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches:" + char(10) +
		"  ```yaml" + char(10) +
		"  ---" + char(10) +
		"  title: Post" + char(10) +
		"  date: 2024-01-15" + char(10) +
		"  ---" + char(10) +
		"  ```" + char(10) + char(10) +

		"- Non-matches: `---only start`, `--- no end content`"
	],

	# HTML Patterns

	:htmlComment = [
		"Matches HTML comments",

		"- `<!--`: Comment opening sequence" + char(10) +
		"- `[\\s\\S]*?`: Any characters including newlines (non-greedy)" + char(10) +
		"- `-->`: Comment closing sequence" + char(10) + char(10) +

		"- Matches: `<!-- comment -->`, `<!-- multi" + char(10) + "line -->`" + char(10) +
		"- Non-matches: `<!-- unclosed`, `/* css comment */`"
	],

	:htmlDoctype = [
		"Matches HTML DOCTYPE declarations",

		"- `<!DOCTYPE`: DOCTYPE opening sequence" + char(10) +
		"- `[^>]*`: Any characters except closing bracket" + char(10) +
		"- `>`: Closing bracket" + char(10) + char(10) +

		"- Matches: `<!DOCTYPE html>`, `<!DOCTYPE HTML PUBLIC>`" + char(10) +
		"- Non-matches: `<!DOCTYPEhtml>`, `<!DOCTYPE>`"
	],

	:htmlOpenTag = [
		"Matches HTML opening tags with optional attributes",

		"- `<`: Opening angle bracket" + char(10) +
		"- `([a-zA-Z][a-zA-Z0-9]*)`: Tag name" + char(10) +
		"- `((?:\s+[a-zA-Z][a-zA-Z0-9]*(?:\s*=\s*(?:\ " + char(10) + StzChar(34) + char(10) + ".*?\ " + char(10) + StzChar(34) + char(10) + "|'.*?'|[^'\ " + char(10) + StzChar(34) + char(10) + "<>\\s]+))?)*)`:" + char(10) +
		"  Optional attributes with values" + char(10) +
		"- `\s*/?>`: Optional self-closing slash and closing bracket" + char(10) + char(10) +

		"- Matches: `<div>`, `<input type=\ " + char(10) + StzChar(34) + char(10) + "text\ " + char(10) + StzChar(34) + char(10) + ">`, `<br/>`" + char(10) +
		"- Non-matches: `<1div>`, `<div`, `</div>`"
	],

	:htmlCloseTag = [
		"Matches HTML closing tags",

		"- `</`: Closing tag opening sequence" + char(10) +
		"- `([a-zA-Z][a-zA-Z0-9]*)`: Tag name" + char(10) +
		"- `>`: Closing bracket" + char(10) + char(10) +

		"- Matches: `</div>`, `</p>`, `</html>`" + char(10) +
		"- Non-matches: `</1>`, `</>`, `</div`"
	],

	:htmlAttribute = [
		"Matches HTML attributes with optional values",

		"- `\\s+`: Required whitespace" + char(10) +
		"- `[a-zA-Z][a-zA-Z0-9]*`: Attribute name" + char(10) +
		"- `(?:\\s*=\\s*`: Optional value assignment" + char(10) +
		"- `(?:" + StzChar(34) + ".*?" + StzChar(34) + "|'.*?'|[^'" + StzChar(34) + "<>\\s]+))?`: Optional value" + char(10) + char(10) +

		"- Matches: `class=" + StzChar(34) + "main" + StzChar(34) + "`, `disabled`, `data-value='123'`" + char(10) +
		"- Non-matches: `=value`, `123=456`, `class =`"
	],

	:htmlClass = [
		"Matches HTML class attributes",

		"- `\\s+class\\s*=\\s*`: Class attribute declaration" + char(10) +
		"- `(?:" + StzChar(34) + "[^" + StzChar(34) + "]*" + StzChar(34) + "`: Double-quoted value" + char(10) +
		"- `|'[^']*'`: Single-quoted value" + char(10) +
		"- `|[^'" + StzChar(34) + "\\s>]+)`: Unquoted value" + char(10) + char(10) +

		"- Matches: `class=" + StzChar(34) + "main" + StzChar(34) + "`, `class='header'`, `class=container`" + char(10) +
		"- Non-matches: `class=`, `class=>`, `class`"
	],

	:htmlId = [
		"Matches HTML id attributes",

		"- `\\s+id\\s*=\\s*`: ID attribute declaration" + char(10) +
		"- `(?:" + StzChar(34) + "[^" + StzChar(34) + "]*" + StzChar(34) + "`: Double-quoted value" + char(10) +
		"- `|'[^']*'`: Single-quoted value" + char(10) +
		"- `|[^'" + StzChar(34) + "\\s>]+)`: Unquoted value" + char(10) + char(10) +

		"- Matches: `id=" + StzChar(34) + "main" + StzChar(34) + "`, `id='header'`, `id=container`" + char(10) +
		"- Non-matches: `id=`, `id=>`, `id`"
	],

	:html5Color = [
		"Matches HTML5 color hexadecimal values",
    
		"- `^`: Start of line" + char(10) +
		"- `#`: Hash symbol" + char(10) +
		"- `[A-Fa-f0-9]{3,6}`: 3 or 6 hexadecimal characters" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `#fff`, `#000000`, `#12AB3F`" + char(10) +
		"- Non-matches: `#12`, `#1234567`, `123456`"
	],

	:htmlTableOpen = [ "Matches HTML table opening tags with optional attributes",
	
	"- `<table`: Table opening sequence" + char(10) +
	"- `((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\" + StzChar(34) + ".*?\" + StzChar(34) + "|'.*?'|[^'\" + StzChar(34) + "<>\\s]+))?)*)`: Zero or more attributes (e.g., class, id) with optional double-quoted, single-quoted, or unquoted values" + char(10) +
	"- `\\s*>`: Optional whitespace and closing bracket" + char(10) + char(10) +
	
	"- Matches: `<table>`, `<table class=\" + StzChar(34) + "data\" + StzChar(34) + " id='t1'>`" + char(10) +
	"- Non-matches: `<tablee>`, `<table class>`"
	
	],
	
	:htmlTableClose = [ "Matches HTML table closing tags",
	
	"- `</table>`: Table closing sequence" + char(10) + char(10) +
	
	"- Matches: `</table>`" + char(10) +
	"- Non-matches: `</tables>`, `</table >`"
	
	],
	
	:htmlRowOpen = [ "Matches HTML table row opening tags with optional attributes",
	
	"- `<tr`: Row opening sequence" + char(10) +
	"- `((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\" + StzChar(34) + ".*?\" + StzChar(34) + "|'.*?'|[^'\" + StzChar(34) + "<>\\s]+))?)*)`: Zero or more attributes (e.g., class, style) with optional double-quoted, single-quoted, or unquoted values" + char(10) +
	"- `\\s*>`: Optional whitespace and closing bracket" + char(10) + char(10) +
	
	"- Matches: `<tr>`, `<tr class=\" + StzChar(34) + "row\" + StzChar(34) + " align='center'>`" + char(10) +
	"- Non-matches: `<trr>`, `<tr class>`"
	
	],
	
	:htmlRowClose = [ "Matches HTML table row closing tags",
	
	"- `</tr>`: Row closing sequence" + char(10) + char(10) +
	
	"- Matches: `</tr>`" + char(10) +
	"- Non-matches: `</trr>`, `</tr >`"
	
	],
	
	:htmlCellOpen = [ "Matches HTML table cell opening tags with optional attributes",
	
	"- `<td`: Cell opening sequence" + char(10) +
	"- `((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\" + StzChar(34) + ".*?\" + StzChar(34) + "|'.*?'|[^'\" + StzChar(34) + "<>\\s]+))?)*)`: Zero or more attributes (e.g., colspan, class) with optional double-quoted, single-quoted, or unquoted values" + char(10) +
	"- `\\s*>`: Optional whitespace and closing bracket" + char(10) + char(10) +
	
	"- Matches: `<td>`, `<td colspan=\" + StzChar(34) + "2\" + StzChar(34) + " class='cell'>`" + char(10) +
	"- Non-matches: `<tdd>`, `<td colspan>`"
	
	],
	
	:htmlCellClose = [ "Matches HTML table cell closing tags",
	
	"- `</td>`: Cell closing sequence" + char(10) + char(10) +
	
	"- Matches: `</td>`" + char(10) +
	"- Non-matches: `</tdd>`, `</td >`"
	
	],
	
	:htmlHeaderCellOpen = [ "Matches HTML table header cell opening tags with optional attributes",
	
	"- `<th`: Header cell opening sequence" + char(10) +
	"- `((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\" + StzChar(34) + ".*?\" + StzChar(34) + "|'.*?'|[^'\" + StzChar(34) + "<>\\s]+))?)*)`: Zero or more attributes (e.g., scope, class) with optional double-quoted, single-quoted, or unquoted values" + char(10) +
	"- `\\s*>`: Optional whitespace and closing bracket" + char(10) + char(10) +
	
	"- Matches: `<th>`, `<th scope=\" + StzChar(34) + "col\" + StzChar(34) + " class='header'>`" + char(10) +
	"- Non-matches: `<thh>`, `<th scope>`"
	
	],
	
	:htmlHeaderCellClose = [ "Matches HTML table header cell closing tags",
	
	"- `</th>`: Header cell closing sequence" + char(10) + char(10) +
	
	"- Matches: `</th>`" + char(10) +
	"- Non-matches: `</thh>`, `</th >`"
	
	],
	
	:htmlTableSectionOpen = [ "Matches HTML table section opening tags (thead, tbody, tfoot) with optional attributes",
	
	"- `<(thead|tbody|tfoot)`: Section opening sequence for thead, tbody, or tfoot" + char(10) +
	"- `((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\" + StzChar(34) + ".*?\" + StzChar(34) + "|'.*?'|[^'\" + StzChar(34) + "<>\\s]+))?)*)`: Zero or more attributes (e.g., class, id) with optional double-quoted, single-quoted, or unquoted values" + char(10) +
	"- `\\s*>`: Optional whitespace and closing bracket" + char(10) + char(10) +
	
	"- Matches: `<thead>`, `<tbody class=\" + StzChar(34) + "main\" + StzChar(34) + ">`" + char(10) +
	"- Non-matches: `<tbodyy>`, `<thead class>`"
	
	],
	
	:htmlTableSectionClose = [ "Matches HTML table section closing tags (thead, tbody, tfoot)",
	
	"- `</(thead|tbody|tfoot)>`: Section closing sequence for thead, tbody, or tfoot" + char(10) + char(10) +
	
	"- Matches: `</thead>`, `</tbody>`, `</tfoot>`" + char(10) +
	"- Non-matches: `</tbodyy>`, `</thead >`"
	
	],

	# CSS Patterns
	
	:idSelector = [
		"Matches CSS ID selectors",
	
		"- `^`: Start of string" + char(10) +
		"- `#`: Hash symbol for ID" + char(10) +
		"- `([a-zA-Z_][a-zA-Z\\d_-]*)`: Valid ID name" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `#header`, `#nav-bar_1`" + char(10) +
		"- Non-matches: `#1header`, `.class-name`"
	],

	:classSelector = [
		"Matches CSS class selectors",

		"- `^`: Start of line" + char(10) +
		"- `\\.`: Dot prefix" + char(10) +
		"- `([a-zA-Z_]`: Must start with letter or underscore" + char(10) +
		"- `[a-zA-Z\\d_-]*)`: Can contain letters, digits, underscores, hyphens" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `.container`, `.nav_item`, `.btn-primary`" + char(10) +
		"- Non-matches: `.1class`, `.`, `.class#id`"
	],

	:attributeSelector = [
		"Matches CSS attribute selectors with optional values",

		"- `\\[\\s*`: Opening bracket with optional whitespace" + char(10) +
		"- `([a-zA-Z][a-zA-Z0-9-]*)`: Attribute name" + char(10) +
		"- `\\s*`: Optional whitespace" + char(10) +
		"- `(?:([*^$|!~]?=)`: Optional operator" + char(10) +
		"- `\\s*`: Optional whitespace" + char(10) +
		"- `(?:\\ " + StzChar(34) + "[^\\ " + StzChar(34) + "]*\\ " + StzChar(34) + "|'[^']*'|[^'\\ " + StzChar(34) + "\\s>]+))?`: Optional value" + char(10) +
		"- `\\s*\\]`: Closing bracket with optional whitespace" + char(10) + char(10) +

		"- Matches: `[type]`, `[type=" + StzChar(34) + "text" + StzChar(34) + "]`, `[class^=" + StzChar(34) + "btn-" + StzChar(34) + "]`" + char(10) +
		"- Non-matches: `[1type]`, `[]`, `[type=]`"
	],

	:hexColor = [
		"Matches CSS hexadecimal color values",

		"- `^`: Start of line" + char(10) +
		"- `#`: Hash symbol" + char(10) +
		"- `([a-fA-F\\d]{3}`: Three hex digits" + char(10) +
		"- `|`: OR" + char(10) +
		"- `[a-fA-F\\d]{6})`: Six hex digits" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `#fff`, `#000000`, `#1a2b3c`" + char(10) +
		"- Non-matches: `#1`, `#12345`, `#gggggg`"
	],

	:rgbColor = [
		"Matches CSS RGB and RGBA color values",

		"- `^`: Start of line" + char(10) +
		"- `rgba?`: 'rgb' with optional 'a'" + char(10) +
		"- `\\(`: Opening parenthesis" + char(10) +
		"- `\\s*\\d{1,3}\\s*,`: Red value (0-255)" + char(10) +
		"- `\\s*\\d{1,3}\\s*,`: Green value (0-255)" + char(10) +
		"- `\\s*\\d{1,3}`: Blue value (0-255)" + char(10) +
		"- `(\\s*,\\s*(0|1|0?\\.\\d+))?`: Optional alpha value (0-1)" + char(10) +
		"- `\\s*\\)`: Closing parenthesis" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `rgb(255,0,0)`, `rgba(255, 0, 0, 0.5)`" + char(10) +
		"- Non-matches: `rgb(300,0,0)`, `rgba(255,0)`, `rgb()`"
	],

	# Numbers & Currency (International)

	:digit = [
		"Matches any single digit (0–9)",

		"- `\d` : A digit from 0 to 9"
	],

	:number = [
		"Matches various number formats including decimals and thousands separators",

		"- `^`: Start of string" + char(10) +
		"- `-?`: Optional negative sign" + char(10) +
		"- `(?:\\d+|\\d{1,3}(?:,\\d{3})+)?`: Whole number part with optional thousands separators" + char(10) +
		"- `(?:\\.\\d+)?`: Optional decimal part" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `1234`, `-123.45`, `1,234,567.89`" + char(10) +
		"- Non-matches: `123.`, `.123`, `1,23,456`"
	],

	:currencyValue = [
		"Matches currency values formatted with thousand separators and two decimal places",

		"- `^-?`: Optional negative sign" + char(10) +
		"- `\\d{1,3}(?:,\\d{3})*`: Matches numbers with optional thousand separators (e.g., `1,000`)" + char(10) +
		"- `(?:\\.\\d{2})?`: Optional decimal part with exactly two digits" + char(10) + char(10) +

		"- Matches: `1,234.56`, `1234.00`, `-1,000.99`" + char(10) +
		"- Non-matches: `1234.5`, `12,34.00`, `123,456.789`"
	],

	:scientificNotation = [
		"Matches numbers in scientific notation format",

		"- `^-?`: Optional negative sign" + char(10) +
		"- `\\d+(?:\\.\\d+)?`: Matches a number with an optional decimal part" + char(10) +
		"- `(?:e[+-]?\\d+)?`: Optional scientific notation with exponent (e.g., `e+10`)" + char(10) + char(10) +

		"- Matches: `1.23e+3`, `-4.56e-7`, `123e5`, `0.001`" + char(10) +
		"- Non-matches: `1e`, `1.2.3`, `e+2`"
	],

	:percentage = [
		"Matches percentages with optional decimal points",

		"- `^-?`: Optional negative sign" + char(10) +
		"- `\\d*\\.?\\d+`: Matches an optional integer or decimal part" + char(10) +
		"- `%`: Ensures the value ends with a percent symbol" + char(10) + char(10) +

		"- Matches: `50%`, `123.45%`, `-0.1%`" + char(10) +
		"- Non-matches: `50`, `%50`, `123.45`"
	],

	:hexColor = [
		"Matches hexadecimal color codes in 3 or 6 digit formats",

		"- `^#`: Ensures the value starts with a hash (`#`)" + char(10) +
		"- `([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})`: Matches either a 6-digit or 3-digit hexadecimal value" + char(10) + char(10) +

		"- Matches: `#FFF`, `#ffffff`, `#123abc`" + char(10) +
		"- Non-matches: `#1234`, `123abc`, `#fffffg`"
	],

	# Contact Information (International)
	
	:phoneE164 = [
		"Matches E.164 international phone number format",
	
		"- `^`: Start of string" + char(10) +
		"- `\\+`: Required plus sign" + char(10) +
		"- `[1-9]`: First digit must be 1-9" + char(10) +
		"- `\\d{1,14}`: 1 to 14 additional digits" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `+12345678901`, `+442071234567`" + char(10) +
		"- Non-matches: `12345678901`, `+0123456789`"
	],
	
	:phoneGeneral = [
		"Matches various phone number formats",
	
		"- `^`: Start of string" + char(10) +
		"- `[+]?`: Optional plus sign" + char(10) +
		"- `[(]?`: Optional opening parenthesis" + char(10) +
		"- `[0-9]{1,4}`: 1-4 digits for country/area code" + char(10) +
		"- `[)]?`: Optional closing parenthesis" + char(10) +
		"- `[-\\s./0-9]*`: Any combination of digits, spaces, hyphens, dots, slashes" + char(10) + char(10) +

		"- Matches: `(123) 456-7890`, `+1.234.567.8900`, `123-456-7890`" + char(10) +
		"- Non-matches: `abc-def-ghij`, `12-3456`"
	],

	:postalCode = [
		"Matches postal codes with alphanumeric characters, optional spaces, and hyphens",
    
		"- `^[A-Z0-9]`: Ensures the code starts with an alphanumeric character" + char(10) +
		"- `[A-Z0-9\\- ]{0,10}`: Matches up to 10 characters including spaces and hyphens" + char(10) +
		"- `[A-Z0-9]$`: Ensures the code ends with an alphanumeric character" + char(10) + char(10) +

		"- Matches: `12345`, `A1B 2C3`, `123-4567`" + char(10) +
		"- Non-matches: `12 345`, `-12345`, `123 45 `"
	],

	:countryCode = [
		"Matches country codes of 2 to 3 uppercase letters",

		"- `^[A-Z]{2,3}$`: Ensures 2 to 3 uppercase alphabetic characters" + char(10) + char(10) +

		"- Matches: `US`, `CAN`, `GB`" + char(10) +
		"- Non-matches: `Us`, `123`, `USA1`"
	],

	:languageCode = [
		"Matches language codes in `xx-XX` format, where `xx` is a lowercase language code and `XX` is an uppercase country code",

		"- `^[a-z]{2}`: Ensures two lowercase letters for the language code" + char(10) +
		"- `-[A-Z]{2}`: Ensures a hyphen followed by two uppercase letters for the country code" + char(10) + char(10) +

		"- Matches: `en-US`, `fr-CA`, `es-ES`" + char(10) +
		"- Non-matches: `EN-us`, `english-US`, `us-en`"
	],

	# Modern Data Formats

	:jwt = [
		"Matches JSON Web Tokens",

		"- `^`: Start of string" + char(10) +
		"- `[A-Za-z0-9-_]+`: Base64url-encoded header" + char(10) +
		"- `\\.`: Dot separator" + char(10) +
		"- `[A-Za-z0-9-_]+`: Base64url-encoded payload" + char(10) +
		"- `\\.`: Dot separator" + char(10) +
		"- `[A-Za-z0-9-_]*`: Base64url-encoded signature" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U`" + char(10) +
		"- Non-matches: `abc.def`, `header.payload`"
	],

	:base64 = [
		"Matches strings encoded in Base64 format",

		"- `^(?:[A-Za-z0-9+/]{4})*`: Matches groups of four Base64 characters (letters, digits, `+`, or `/`)" + char(10) +
		"- `(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$`: Allows padding with `=` for the last group" + char(10) + char(10) +

		"- Matches: `TWFu`, `TWE=`, `TQ==`, `YWJjZA==`" + char(10) +
		"- Non-matches: `T@W==`, `123`, `ABCD==`"
	],

	:emoji = [
		"Matches strings composed entirely of emoji characters",

		"- `^(?:\\p{Emoji_Presentation}|\\p{Emoji})+$`: Matches one or more Unicode emoji characters" + char(10) + char(10) +

		"- Matches: `😊`, `🎉🎈`, `👩‍🚀🚀`" + char(10) +
		"- Non-matches: `😊abc`, `123🎉`, `😀_😊`"
	],

	# API & Request Validation

	:apiKey = [
		"Matches API key formats",
	
		"- `^`: Start of string" + char(10) +
		"- `[A-Za-z0-9_-]{20,}`: At least 20 characters of letters, numbers, underscores, or hyphens" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `abcd1234_xyz-987654321`, `api_key_123456789abcdefghijk`" + char(10) +
		"- Non-matches: `short_key`, `invalid#key`, `api@key`"
	],

	:bearerToken = [
		"Matches Bearer authentication tokens",

		"- `^`: Start of string" + char(10) +
		"- `Bearer\\s+`: 'Bearer' keyword followed by whitespace" + char(10) +
		"- `[A-Za-z0-9\\-._~+/]+=*`: Base64 URL-safe characters with optional padding" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `Bearer abc123xyz789`, `Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`" + char(10) +
		"- Non-matches: `bearer token`, `Bearer`, `BearerToken123`"
	],

	:queryParam = [
		"Matches valid URL query parameter names",

		"- `^`: Start of string" + char(10) +
		"- `[\\w\\-%\\.]+`: One or more word characters, percent signs, or dots" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `page`, `sort-by`, `filter.name`" + char(10) +
		"- Non-matches: `@param`, `query space`, `param#1`"
	],

	:httpMethod = [
		"Matches valid HTTP methods",

		"- `^`: Start of string" + char(10) +
		"- `(?:GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS)`: Valid HTTP methods" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `GET`, `POST`, `PUT`" + char(10) +
		"- Non-matches: `get`, `SEND`, `RETRIEVE`"
	],

	:contentType = [
		"Matches HTTP Content-Type headers with optional charset specifications",

		"- `^[\\w\\-\\.\\/]+`: Matches the primary type and subtype (e.g., `application/json`)" + char(10) +
		"- `(?:\\+[\\w\\-\\.\\/]+)?`: Optionally matches suffix types (e.g., `application/ld+json`)" + char(10) +
		"- `(?:;\\s*charset=[\\w\\-]+)?$`: Optionally matches charset parameters (e.g., `charset=utf-8`)" + char(10) + char(10) +

		"- Matches: `application/json`, `text/html; charset=utf-8`, `application/ld+json`" + char(10) +
		"- Non-matches: `application`, `text; utf-8`, `image/jpg; charset`"
	],

	:requestId = [
		"Matches request IDs with a minimum length of 4 characters",

		"- `^[\\w\\-]{4,}$`: Ensures alphanumeric characters, underscores, or hyphens with a minimum length of 4" + char(10) + char(10) +

		"- Matches: `abc1`, `1234-5678`, `req_abc`" + char(10) +
		"- Non-matches: `abc`, `12`, `req!123`"
	],

	:corsOrigin = [
		"Matches valid CORS origin URLs with optional port numbers",

		"- `^https?://`: Matches URLs starting with `http://` or `https://`" + char(10) +
		"- `(?:[\\w-]+\\.)+[\\w-]+`: Matches domain names with optional subdomains" + char(10) +
		"- `(?::\\d{1,5})?$`: Optionally matches port numbers (e.g., `:8080`)" + char(10) + char(10) +

		"- Matches: `https://example.com`, `http://sub.example.com:3000`" + char(10) +
		"- Non-matches: `ftp://example.com`, `http://example`, `https://.com`"
	],

	# Data Cleaning

	:alphanumeric = [
		"Matches strings containing only letters and numbers",

		"- `^`: Start of string" + char(10) +
		"- `[a-zA-Z0-9]+`: One or more letters or numbers" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `ABC123`, `Test999`, `123abc`" + char(10) +
		"- Non-matches: `ABC-123`, `Test_999`, `Special!`"
	],

	:alphabetic = [
		"Matches strings containing only alphabetic characters (A-Z, a-z)",

		"- `^[a-zA-Z]+$`: Ensures the string contains only uppercase and lowercase letters with no spaces or symbols" + char(10) + char(10) +

		"- Matches: `Hello`, `abcXYZ`, `Data`" + char(10) +
		"- Non-matches: `Hello123`, `Data!`, `Hello World`"
	],

	:numeric = [
		"Matches strings containing only numeric digits (0-9)",

		"- `^[0-9]+$`: Ensures the string consists solely of digits" + char(10) + char(10) +

		"- Matches: `12345`, `007`, `2023`" + char(10) +
		"- Non-matches: `12.34`, `123abc`, `1 2 3`"
	],

	:spaces = [
		"Matches sequences of whitespace characters (spaces, tabs, newlines, and carriage returns)",

		"- `[ \\t\\r\\n]+`: Matches one or more spaces, tabs (`\\t`), carriage returns (`\\r`), or newlines (`\\n`)" + char(10) + char(10) +

		"- Matches: ` `, `\t\t`, ` \n \t`" + char(10) +
		"- Non-matches: `abc`, `123`, `a b` (does not match non-whitespace characters)"
	],

	:trim = [
		"Matches leading and trailing whitespace in a string",
 
		"- `^\\s+`: Matches leading whitespace at the beginning of the string" + char(10) +
		"- `|\\s+$`: Matches trailing whitespace at the end of the string" + char(10) + char(10) +

		"- Matches: Leading/trailing spaces in `  Hello `, `\tWorld\n `" + char(10) +
		"- Non-matches: `NoSpacesHere`, `A B` (internal spaces are not matched)"
	],

	:nonPrintable = [
		"Matches non-printable ASCII characters",

		"- `[\\x00-\\x1F\\x7F-\\x9F]`: Matches ASCII control characters (0x00–0x1F) and additional non-printable characters (0x7F–0x9F)" + char(10) + char(10) +

		"- Matches: `\x00` (null), `\x1B` (escape), `\x7F` (delete)" + char(10) +
		"- Non-matches: `abc`, `123`, `@#$` (printable characters are not matched)"
	],

	:multipleSpaces = [
		"Matches sequences of two or more whitespace characters",

		"- `{2,}`: Two or more occurrences of the previous pattern" + char(10) + char(10) +

		"- Matches: `  `, `   `, multiple spaces/tabs" + char(10) +
		"- Non-matches: ` ` (single space)"
	],

	# JSON Patterns

	:jsonObject = [
		"Matches JSON object structures",

		"- `\\{`: Opening brace" + char(10) +
		"- `(?:\\s*\\\ " + char(10) + StzChar(34) + char(10) + "[a-zA-Z0-9_]+\\\ " + char(10) + StzChar(34) + char(10) + "\\s*:\\s*`: Key part with quotes and colon" + char(10) +
		"- `(?:\\\ " + char(10) + StzChar(34) + char(10) + "[^\\\ " + char(10) + StzChar(34) + char(10) + "]*\\\ " + char(10) + StzChar(34) + char(10) + "|'[^']*'|\\d+|true|false|null|\\{.*?\\}|\\[.*?\\]))*`: Various value types" + char(10) +
		"- `\\s*\\}`: Closing brace with optional whitespace" + char(10) + char(10) +

		"- Matches: `{\ " + char(10) + StzChar(34) + char(10) + "name\ " + char(10) + StzChar(34) + char(10) + ":\ " + char(10) + StzChar(34) + char(10) + "value\ " + char(10) + StzChar(34) + char(10) + "}`, `{\ " + char(10) + StzChar(34) + char(10) + "age\ " + char(10) + StzChar(34) + char(10) + ":25}`" + char(10) +
		"- Non-matches: `{name:value}`, `{\ " + char(10) + StzChar(34) + char(10) + "key\ " + char(10) + StzChar(34) + char(10) + ":}`, `{\ " + char(10) + StzChar(34) + char(10) + "key\ " + char(10) + StzChar(34) + char(10) + "}`"
	],

	:jsonArray = [
		"Matches JSON array structures",

		"- `^`: Start of string" + char(10) +
		"- `\\[`: Opening bracket" + char(10) +
		"- `(?:\\s*[^,]+,?\\s*)*`: Array elements separated by commas" + char(10) +
		"- `\\]`: Closing bracket" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `[1,2,3]`, `[\ " + char(10) + StzChar(34) + char(10) + "a\ " + char(10) + StzChar(34) + char(10) + ",\ " + char(10) + StzChar(34) + char(10) + "b\ " + char(10) + StzChar(34) + char(10) + ",\ " + char(10) + StzChar(34) + char(10) + "c\ " + char(10) + StzChar(34) + char(10) + "]`" + char(10) +
		"- Non-matches: `[1,2,]`, `[,]`, `[1,,2]`"
	],

	:jsonKeyValuePair = [
		"Matches a key-value pair in JSON format",

		"- `\" + StzChar(34) + "[a-zA-Z0-9_]+\" + StzChar(34) + "`: Matches a JSON key enclosed in double quotes, consisting of alphanumeric characters and underscores" + char(10) +
		"- `\\s*:\\s*`: Matches the colon `:` separator with optional spaces around it" + char(10) +
		"- `(?:\" + StzChar(34) + "[^\" + StzChar(34) + "]*\" + StzChar(34) + "|'[^']*'|\\d+|true|false|null|\\{.*?\\}|\\[.*?\\])`: Matches the value, which can be:" + char(10) +
		"  - A double-quoted string" + char(10) +
		"  - A single-quoted string" + char(10) +
		"  - A number (e.g., `123`)" + char(10) +
		"  - A boolean (`true` or `false`)" + char(10) +
		"  - `null`" + char(10) +
		"  - A JSON object (`{}`) or array (`[]`)" + char(10) + char(10) +

		"- Matches: `\" + StzChar(34) + "name\" + StzChar(34) + ":\" + StzChar(34) + "John\" + StzChar(34) + "`, `\" + StzChar(34) + "age\" + StzChar(34) + ":30`, `\" + StzChar(34) + "active\" + StzChar(34) + ":true`, `\" + StzChar(34) + "address\" + StzChar(34) + ":{\" + StzChar(34) + "city\" + StzChar(34) + ":\" + StzChar(34) + "Paris\" + StzChar(34) + "}`" + char(10) +
		"- Non-matches: `name:John`, `\" + StzChar(34) + "key\" + StzChar(34) + ":`, `\" + StzChar(34) + "invalid\" + StzChar(34) + "\" + StzChar(34) + "value\" + StzChar(34) + "`"
	],

	:geoJSON = [
		"Matches a valid GeoJSON FeatureCollection object",

		"- `^\\{\\s*\" + StzChar(34) + "type\" + StzChar(34) + "\\s*:\\s*\" + StzChar(34) + "FeatureCollection\" + StzChar(34) + "`: Matches the opening of a GeoJSON object with the type `FeatureCollection`" + char(10) +
		"- `\\s*,\\s*\" + StzChar(34) + "features\" + StzChar(34) + "\\s*:\\s*\\[.*?\\]`: Matches the `features` property containing an array of features" + char(10) +
		"- `\\s*\\}$`: Matches the closing brace of the GeoJSON object" + char(10) + char(10) +

		"- Matches: `{ \" + StzChar(34) + "type\" + StzChar(34) + ": \" + StzChar(34) + "FeatureCollection\" + StzChar(34) + ", \" + StzChar(34) + "features\" + StzChar(34) + ": [] }`, `{ \" + StzChar(34) + "type\" + StzChar(34) + ": \" + StzChar(34) + "FeatureCollection\" + StzChar(34) + ", \" + StzChar(34) + "features\" + StzChar(34) + ": [{\" + StzChar(34) + "type\" + StzChar(34) + ":\" + StzChar(34) + "Feature\" + StzChar(34) + "}] }`" + char(10) +
		"- Non-matches: `{ \" + StzChar(34) + "type\" + StzChar(34) + ": \" + StzChar(34) + "Feature\" + StzChar(34) + ", \" + StzChar(34) + "features\" + StzChar(34) + ": [] }`, `{ \" + StzChar(34) + "type\" + StzChar(34) + ": \" + StzChar(34) + "FeatureCollection\" + StzChar(34) + " }`"
	],

	# CSV Patterns

	:csvHeaderRow = [
		"Matches CSV header rows",

		"- `^`: Start of string" + char(10) +
		"- `([^,]*,)*`: Zero or more non-comma characters followed by comma" + char(10) +
		"- `[^,]*`: Final field without comma" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `name,age,email`, `first,last,address`" + char(10) +
		"- Non-matches: `name,,age`, `,name,age`"
	],

	:csvQuotedField = [
		"Matches a quoted field in a CSV file",

		"- `\" + StzChar(34) + "[^\" + StzChar(34) + "]*\" + StzChar(34) + "`: Matches any text enclosed within double quotes" + char(10) + char(10) +

		"- Matches: `\" + StzChar(34) + "hello\" + StzChar(34) + "`, `\" + StzChar(34) + "123\" + StzChar(34) + "`, `\" + StzChar(34) + "a,b,c\" + StzChar(34) + "`" + char(10) +
		"- Non-matches: `hello`, `\" + StzChar(34) + "hello` (unclosed quote)"
	],

	:csvUnquotedField = [
		"Matches an unquoted field in a CSV file",

		"- `[^,\\r\\n]*`: Matches any sequence of characters that does not include a comma, carriage return, or newline" + char(10) + char(10) +

		"- Matches: `hello`, `123`, `a b c`" + char(10) +
		"- Non-matches: `hello,world`, `line1\\nline2`"
	],

	:csvDelimiter = [
		"Matches a comma as the field delimiter in a CSV file",

		"- `,`: Matches a singl NL +e comma" + char(10) + char(10) +

		"- Matches: `,` in `hello,world`" + char(10) +
		"- Non-matches: `;`, `\\t`"
	],

	:csvRowEnding = [
		"Matches the end of a row in a CSV file",

		"- `\\r?`: Matches an optional carriage return (\\r) at the end of a row" + char(10) + char(10) +

		"- Matches: `\\r`, `\\n`, or an empty string at the end of a row" + char(10) +
		"- Non-matches: `\\r\\n` (without \\n)"
	],

	:csvEscapedQuote = [
		"Matches escaped double quotes within a quoted CSV field",

		"- `\" + StzChar(34) + "\" + StzChar(34) + "`: Matches two consecutive double quotes inside a quoted field" + char(10) + char(10) +

		"- Matches: `\" + StzChar(34) + "hello\" + StzChar(34) + "\" + StzChar(34) + "world\" + StzChar(34) + "` (represents `hello\" + StzChar(34) + "world`)" + char(10) +
		"- Non-matches: `\" + StzChar(34) + "hello\" + StzChar(34) + "world\" + StzChar(34) + "` (no double quotes to escape)"
	],

	:csvLine = [
		"Matches an entire line of CSV data",

		"- `^(?:(?:\" + StzChar(34) + "[^\" + StzChar(34) + "]*\" + StzChar(34) + ")|(?:[^,\\\" + StzChar(34) + "]+))`: Matches the first field, which can be quoted or unquoted" + char(10) +
		"- `(?:,(?:(?:\" + StzChar(34) + "[^\" + StzChar(34) + "]*\" + StzChar(34) + ")|(?:[^,\\\" + StzChar(34) + "]+)))*`: Matches subsequent fields separated by commas, which can also be quoted or unquoted" + char(10) + char(10) +

		"- Matches: `\" + StzChar(34) + "field1\" + StzChar(34) + ",\" + StzChar(34) + "field2\" + StzChar(34) + "`, `field1,field2`, `\" + StzChar(34) + "field,1\" + StzChar(34) + ",field2`" + char(10) +
		"- Non-matches: `field1,field2,` (trailing comma), `field1 field2` (no delimiter)"
	],

	:sqlSelectStatement = [
		"Matches SQL SELECT statements",

		"- `^\\s*`: Allows leading whitespace" + char(10) +
		"- `SELECT\\s+`: Matches the SELECT keyword followed by whitespace" + char(10) +
		"- `.+?\\s+`: Matches selected columns or expressions followed by whitespace" + char(10) +
		"- `FROM\\s+`: Matches the FROM keyword followed by whitespace" + char(10) +
		"- `.+?`: Matches table or subquery names" + char(10) +
		"- `(?:\\s+WHERE\\s+.+?)?`: Optionally matches the WHERE clause" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `SELECT * FROM table`, `SELECT name, age FROM users WHERE age > 30`" + char(10) +
		"- Non-matches: `SELCT *`, `SELECT FROM table`"
	],

	:sqlInsertStatement = [
		"Matches SQL INSERT statements",

		"- `^\\s*`: Allows leading whitespace" + char(10) +
		"- `INSERT\\s+INTO\\s+`: Matches the INSERT INTO keywords followed by whitespace" + char(10) +
		"- `.+?\\s+`: Matches the table name followed by whitespace" + char(10) +
		"- `\\(.+?\\)\\s+`: Matches column names in parentheses followed by whitespace" + char(10) +
		"- `VALUES\\s+\\(.+?\\)`: Matches the VALUES keyword and a list of values in parentheses" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `INSERT INTO table (id, name) VALUES (1, 'Mouddour')`" + char(10) +
		"- Non-matches: `INSERT table VALUES (1, 'Mouddour')`"
	],

	:sqlUpdateStatement = [
		"Matches SQL UPDATE statements",

		"- `^\\s*`: Allows leading whitespace" + char(10) +
		"- `UPDATE\\s+`: Matches the UPDATE keyword followed by whitespace" + char(10) +
		"- `.+?\\s+SET\\s+`: Matches the table name and SET keyword followed by whitespace" + char(10) +
		"- `.+?`: Matches column-value assignments" + char(10) +
		"- `(?:\\s+WHERE\\s+.+?)?`: Optionally matches the WHERE clause" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `UPDATE table SET name='Maiga' WHERE id=1`" + char(10) +
		"- Non-matches: `UPDATE SET name='Harouna'`"
	],

	:sqlDeleteStatement = [
		"Matches SQL DELETE statements",

		"- `^\\s*`: Allows leading whitespace" + char(10) +
		"- `DELETE\\s+FROM\\s+`: Matches the DELETE FROM keywords followed by whitespace" + char(10) +
		"- `.+?`: Matches the table name" + char(10) +
		"- `(?:\\s+WHERE\\s+.+?)?`: Optionally matches the WHERE clause" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `DELETE FROM users WHERE id=1`" + char(10) +
		"- Non-matches: `DELETE WHERE id=1`, `DELETE FROM`"
	],

	:sqlCreateTable = [
		"Matches SQL CREATE TABLE statements",

		"- `^\\s*`: Allows leading whitespace" + char(10) +
		"- `CREATE\\s+TABLE\\s+`: Matches the CREATE TABLE keywords followed by whitespace" + char(10) +
		"- `[\\w]+\\s*\\(.+?\\)`: Matches the table name followed by column definitions in parentheses" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `CREATE TABLE users (id INT, name VARCHAR(100))`" + char(10) +
		"- Non-matches: `CREATE users`, `TABLE users (id INT)`"
	],

	:sqlDropTable = [
		"Matches SQL DROP TABLE statements",

		"- `^\\s*`: Allows leading whitespace" + char(10) +
		"- `DROP\\s+TABLE\\s+`: Matches the DROP TABLE keywords followed by whitespace" + char(10) +
		"- `[\\w]+`: Matches the table name" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `DROP TABLE users`" + char(10) +
		"- Non-matches: `DROP users`, `TABLE DROP users`"
	],

	:sqlIdentifier = [
		"Matches valid SQL identifiers",

		"- `^[a-zA-Z_][a-zA-Z0-9_]*$`: Matches an identifier starting with a letter or underscore, followed by alphanumeric characters or underscores" + char(10) + char(10) +

		"- Matches: `table1`, `_column`, `userName`" + char(10) +
		"- Non-matches: `1table`, `column-name`, `user.name`"
	],

	:sqlValue = [
		"Matches SQL values",

		"- `^('(?:[^']|''|\\\\')*'|\\d+|NULL)$`: Matches a single-quoted string, a number, or the NULL keyword" + char(10) + char(10) +

		"- Matches: `'John'`, `123`, `NULL`" + char(10) +
		"- Non-matches: `John`, `''`, `12a`"
	],

	:sqlOperator = [
		"Matches SQL comparison operators",

		"- `^(=|<>|!=|<|<=|>|>=|LIKE|IN|IS|BETWEEN)$`: Matches valid SQL operators for comparison" + char(10) + char(10) +

		"- Matches: `=`, `<>`, `LIKE`, `BETWEEN`" + char(10) +
		"- Non-matches: `AND`, `OR`, `==`"
	],

	:sqlJoinClause = [
		"Matches SQL JOIN clauses",

		"- `^\\s*JOIN\\s+`: Matches the JOIN keyword followed by whitespace" + char(10) +
		"- `.+?\\s+ON\\s+.+?$`: Matches the table being joined and the ON condition" + char(10) + char(10) +

		"- Matches: `JOIN orders ON users.id = orders.user_id`" + char(10) +
		"- Non-matches: `JOIN orders`, `ON users.id = orders.user_id`"
	],

	# Regexes for Potential Security Concerns

	:sqlInjection = [
		"Detects potential SQL injection patterns",

		"- `(?:[\\\ " + char(10) + StzChar(34) + char(10) + "';]+.*?)+`: Sequences of quotes or semicolons with following content" + char(10) +
		"- Matches: `'; DROP TABLE users;--`, `\ " + char(10) + StzChar(34) + char(10) + " OR \ " + char(10) + StzChar(34) + char(10) + "1\ " + char(10) + StzChar(34) + char(10) + "=\ " + char(10) + StzChar(34) + char(10) + "1`" + char(10) + char(10) +

		"- Non-matches: `normal text`, `user@example.com`" + char(10) +
		"- Note: This is a basic detection pattern and should be used with other security measures"
	],
	
	:xssInjection = [
		"Detects potential XSS patterns",
	
		"- `<`: Opening angle bracket" + char(10) +
		"- `[a-zA-Z][a-zA-Z0-9]*`: HTML tag name" + char(10) +
		"- `[^>]*>`: Tag attributes and closing" + char(10) +
		"- `.*?`: Content" + char(10) +
		"- `</[a-zA-Z][a-zA-Z0-9]*>`: Closing tag" + char(10) + char(10) +

		"- Matches: `<script>alert('xss')</script>`, `<img src=x onerror=alert(1)>`" + char(10) +
		"- Non-matches: `<plaintext>`, `normaltext`" + char(10) + char(10) +

		"- Note: This is a basic detection pattern and should be used with other security measures"
	],

	:emailInjection = [
		"Matches potential email injection attempts in form inputs",

		"- `.*[\\n\\r]+.+@[a-z0-9]+[.][a-z]{2,}.*`: Matches strings containing newline or carriage return characters, followed by an email-like pattern" + char(10) +
		"- Components:" + char(10) +
		"  - `.*`: Matches any characters before the injection" + char(10) +
		"  - `[\\n\\r]+`: Matches one or more newline (`\\n`) or carriage return (`\\r`) characters" + char(10) +
		"  - `.+@[a-z0-9]+[.][a-z]{2,}`: Matches a basic email address format" + char(10) +
		"  - `.*`: Matches any characters after the injection" + char(10) + char(10) +

		"- Matches: `hello\\nabc@example.com`, `abc\\r\\ndef@domain.com`" + char(10) +
		"- Non-matches: `hello@example.com` (no newline characters)"
	],

	:htmlInjection = [
		"Matches potential HTML injection attempts in form inputs",

		"- `<[^>]*?[^<]*[a-zA-Z0-9]+.*[^<]*?>`: Matches strings containing HTML-like tags with potential content inside" + char(10) +
		"- Components:" + char(10) +
		"  - `<`: Matches the opening angle bracket of an HTML tag" + char(10) +
		"  - `[^>]*?`: Matches zero or more characters that are not the closing angle bracket, non-greedily" + char(10) +
		"  - `[^<]*[a-zA-Z0-9]+`: Ensures the tag contains at least one alphanumeric character" + char(10) +
		"  - `.*`: Matches any additional content inside the tag" + char(10) +
		"  - `[^<]*?>`: Matches zero or more characters until the closing angle bracket" + char(10) + char(10) +

		"- Matches: `<script>alert('XSS')</script>`, `<div>content</div>`" + char(10) +
		"- Non-matches: `content`, `< >`, `<tag>` (without meaningful content)"
	],

	# Ring Language Patterns

	:ringString = [
		"Matches Ring string assignments and declarations",

		"- `^=?`: Optional assignment operator at start" + char(10) +
		"- `*`: Optional whitespace" + char(10) +
		"- `([ " + StzChar(34) + "'].*?[ " + StzChar(34) + "']|[^ ]+)`: Quoted string or word" + char(10) +
		"- `*$`: Optional whitespace at end" + char(10) + char(10) +

		"- Matches: `name = " + StzChar(34) + "John" + StzChar(34) + "`, `str = 'Hello'`" + char(10) +
		"- Non-matches: `name = `, `= " + StzChar(34) + "unclosed`"
	],

	:ringNumber = [
		"Matches Ring numeric literals",

		"- `^`: Start of line" + char(10) +
		"- `-?`: Optional minus sign" + char(10) +
		"- `\\d+`: One or more digits" + char(10) +
		"- `(?:\\.\\d+)?`: Optional decimal part" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `42`, `-17`, `3.14`, `-0.001`" + char(10) +
		"- Non-matches: `.5`, `1.`, `1e5`"
	],

	:ringBoolean = [
		"Matches Ring boolean literals",

		"- `^`: Start of line" + char(10) +
		"- `(?:True|False)`: Either 'True' or 'False'" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `True`, `False`" + char(10) +
		"- Non-matches: `true`, `false`, `TRUE`"
	],

	:ringVariable = [
		"Matches Ring variable names",

		"- `^`: Start of line" + char(10) +
		"- `[a-zA-Z_]`: First character must be letter or underscore" + char(10) +
		"- `\\w*`: Following characters can be letters, numbers, or underscores" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `name`, `_count`, `myVar123`" + char(10) +
		"- Non-matches: `123var`, `my-var`, `$var`"
	],

	:ringFunction = [
		"Matches Ring function declarations",

		"- `^func`: Function declaration keyword" + char(10) +
		"- `(\w+)`: Function name" + char(10) +
		"- `\s*\((.*?)\)`: Parameters in parentheses" + char(10) + char(10) +

		"- Matches: `func sum(x, y)`, `func hello()`" + char(10) +
		"- Non-matches: `function test()`, `func()`"
	],

	:ringFunctionCall = [
		"Matches Ring function calls",

		"- `^`: Start of line" + char(10) +
		"- `([a-zA-Z_]\\w*)`: Function name" + char(10) +
		"- `\\s*\\(`: Opening parenthesis with optional whitespace" + char(10) +
		"- `(.*?)`: Function arguments" + char(10) +
		"- `\\)`: Closing parenthesis" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `print()`, `calculate(x,y)`, `func(1,2,3)`" + char(10) +
		"- Non-matches: `1func()`, `func(`, `func`"
	],

	:ringMainFunction = [
		"Matches Ring main function declaration",

		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `Func\\s+Main\\s*`: 'Func Main' declaration" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `Func Main`, `FUNC MAIN`, `func main`" + char(10) +
		"- Non-matches: `Func main()`, `Function Main`, `Main`"
		],

	:ringClass = [
		"Matches Ring class declarations",
 
		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `Class\\s+`: 'Class' keyword and whitespace" + char(10) +
		"- `([a-zA-Z_]\\w*)`: Class name" + char(10) +
		"- `\\s*`: Optional whitespace" + char(10) +
		"- `(?:from\\s+([a-zA-Z_]\\w*))?`: Optional inheritance" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `Class Animal`, `Class Dog from Animal`" + char(10) +
		"- Non-matches: `class animal`, `Class 1Dog`, `Class Dog from`"
	],

	:ringClassAttribute = [
		"Matches Ring class attribute declarations",

		"- `^`: Start of line" + char(10) +
		"- `[a-zA-Z_]\\w*`: Attribute name" + char(10) +
		"- `\\s*=\\s*`: Assignment operator" + char(10) +
		"- `.*`: Attribute value" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `name = value`, `count = 0`, `items = []`" + char(10) +
		"- Non-matches: `1var = 2`, `= value`, `name =`"
	],

	:ringNewObject = [
		"Matches Ring object instantiation",

		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `New\\s+`: 'New' keyword" + char(10) +
		"- `([a-zA-Z_]\\w*)`: Class name" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `New Person`, `new Calculator`, `NEW Object`" + char(10) +
		"- Non-matches: `New`, `New 1Class`, `New()`"
	],

	:ringObjectAccess = [
		"Matches Ring object access expressions",
   
		"- `^`: Start of line" + char(10) +
		"- `([a-zA-Z_]\\w*)`: Object name" + char(10) +
		"- `\\s*{\\s*`: Opening brace with optional whitespace" + char(10) +
		"- `(.*?)`: Member access expression" + char(10) +
		"- `\\s*}`: Closing brace with optional whitespace" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `obj{method()}`, `list{item}`, `object{property}`" + char(10) +
		"- Non-matches: `obj{}`, `{prop}`, `obj{`"
	],

	:ringLoop = [
		"Matches Ring loop constructs",

		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `(?:`: Non-capturing group for alternatives:" + char(10) +
		"  - `for\\s+\\w+\\s*=\\s*\\d+\\s+to\\s+\\d+`: Numeric for loop" + char(10) +
		"  - `|while\\s+.*`: While loop" + char(10) +
		"  - `|for\\s+\\w+\\s+in\\s+.*?)`: For-in loop" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `for x = 1 to 10`, `while count > 0`, `for item in list`" + char(10) +
		"- Non-matches: `for`, `while`, `for x in`"
	],

	:ringIf = [
		"Matches Ring if statements",

		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `if\\s+`: 'if' keyword" + char(10) +
		"- `.*`: Condition" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `if x > 0`, `IF true`, `if isValid()`" + char(10) +
		"- Non-matches: `if`, `ifelse`, `if()`"
	],

	:ringSwitch = [
		"Matches Ring switch statements",
 
		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `switch\\s+`: 'switch' keyword" + char(10) +
		"- `.*`: Switch expression" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `switch x`, `SWITCH value`, `switch expr()`" + char(10) +
		"- Non-matches: `switch`, `case x`, `switch()`"
	],

	:ringCase = [
	"Matches Ring switch case statements",
 
		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `(?:on|off)`: 'on' or 'off' keyword" + char(10) +
		"- `\\s+`: Required whitespace" + char(10) +
		"- `.*`: Case value" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `on 1`, `OFF " + StzChar(34) + "text" + StzChar(34) + "`, `on value`" + char(10) +
		"- Non-matches: `on`, `case 1`, `on()`"
	],

	:ringList = [
		"Matches Ring list literals",

		"- `^`: Start of line" + char(10) +
		"- `\\[`: Opening bracket" + char(10) +
		"- `(?:[^[\\]]*|\\[.*?\\])*`: List contents, including nested lists" + char(10) +
		"- `\\]`: Closing bracket" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `[1,2,3]`, `[[1,2],[3,4]]`, `[]`" + char(10) +
		"- Non-matches: `[unclosed`, `[1,2,`, `[[]`"
	],

	:ringListRange = [
		"Matches Ring range format expressions",

		"- `^`: Start of line" + char(10) +
		"- `([^:]+)`: First capture group for the start value" + char(10) +
		"- `\\s*:\\s*`: Colon separator with optional whitespace" + char(10) +
		"- `([^:]+)`: Second capture group for the end value" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +
		"- Matches: `1:3`, `A:C`, `#1:#3`, `day1:day3`" + char(10) +
		"- Non-matches: `1:3:5`, `1::3`"
	],

	:ringListAccess = [
		"Matches Ring list element access",

		"- `^`: Start of line" + char(10) +
		"- `([a-zA-Z_]\\w*)`: List variable name" + char(10) +
		"- `\\s*\\[`: Opening bracket" + char(10) +
		"- `(\\d+|\\w+)`: Numeric or variable index" + char(10) +
		"- `\\s*\\]`: Closing bracket" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `list[1]`, `array[i]`, `items[index]`" + char(10) +
		"- Non-matches: `list[]`, `[1]`, `list[1`"
	],

	:ringHashTable = [
		"Matches Ring hash table literals",

		"- `^`: Start of line" + char(10) +
		"- `\\[\\s*:`: Opening bracket and colon" + char(10) +
		"- `(?:\\w+\\s*=\\s*[^,\\]]+\\s*,?\\s*)+`: Key-value pairs" + char(10) +
		"- `\\]`: Closing bracket" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `[:name=" + StzChar(34) + "John" + StzChar(34) + ",age=30]`, `[:key=value]`" + char(10) +
		"- Non-matches: `[]`, `[:invalid]`, `[:key=]`"
	],

	:ringComment = [
	"Matches Ring comments",

		"- `^`: Start of line" + char(10) +
		"- `(?:`: Non-capturing group for alternatives:" + char(10) +
		"  - `#.*`: Single-line hash comment" + char(10) +
		"  - `//.*`: Single-line double-slash comment" + char(10) +
		"  - `/\\*[\\s\\S]*?\\*/`: Multi-line comment" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `# comment`, `// note`, `/* multi line */`" + char(10) +
		"- Non-matches: `/comment`, `/*unclosed`, `#`"
	],

	:ringSee = [
		"Matches Ring See statements",

		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `See\\s+`: 'See' keyword" + char(10) +
		"- `(?:[" + StzChar(34) + "'].*?[" + StzChar(34) + "']|\\w+)`: String literal or variable" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `See " + StzChar(34) + "Hello" + StzChar(34) + "`, `SEE x`, `see 'text'`" + char(10) +
		"- Non-matches: `See`, `See()`, `See,`"
	],

	:ringGive = [
		"Matches Ring Give statements",

		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `Give\\s+`: 'Give' keyword" + char(10) +
		"- `\\w+`: Variable name" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `Give x`, `GIVE input`, `give variable`" + char(10) +
 		"- Non-matches: `Give`, `Give 1`, `Give()`"
	],

	:ringLoad = [
		"Matches Ring Load statements",

		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `Load\\s+`: 'Load' keyword" + char(10) +
		"- `[" + StzChar(34) + "'].*?[" + StzChar(34) + "']`: Quoted filename" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `Load " + StzChar(34) + "file.ring" + StzChar(34) + "`, `LOAD 'module.ring'`" + char(10) +
		"- Non-matches: `Load`, `Load file`, `Load()`"
	],

	:ringImport = [
		"Matches Ring Import statements",
 
		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `Import\\s+`: 'Import' keyword" + char(10) +
		"- `[\\w.]+`: Module path" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `Import module`, `IMPORT system.lib`, `import std.core`" + char(10) +
		"- Non-matches: `Import`, `Import.`, `Import()`"
	],

	:ringOperator = [
		"Matches Ring operators",

		"- `^`: Start of line" + char(10) +
		"- `(?:`: Non-capturing group for alternatives:" + char(10) +
		"  - `[+\\-*/=%]`: Arithmetic operators" + char(10) +
		"  - `|==|!=|>=|<=|>|<`: Comparison operators" + char(10) +
		"  - `|\\+=|-=|\\*=|/=`: Assignment operators" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `+`, `==`, `<=`, `+=`" + char(10) +
		"- Non-matches: `++`, `=!`, `=>`"
	],

	:ringLogical = [
		"Matches Ring logical operators",

		"- `^`: Start of line" + char(10) +
		"- `(?:and|or|not)`: Logical operators" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `and`, `or`, `not`" + char(10) +
		"- Non-matches: `AND`, `Or`, `Not`"
	],

	:ringExit = [
		"Matches Ring Exit statements",
 
		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `exit`: 'Exit' keyword" + char(10) +
		"- `(?:\\s+\\d+)?`: Optional exit code" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `exit`, `EXIT 0`, `exit 1`" + char(10) +
		"- Non-matches: `exit()`, `exit code`, `exit -1`"
	],

	:ringReturn = [
		"Matches Ring Return statements",
        
		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `return`: 'Return' keyword" + char(10) +
		"- `(?:\\s+.*)?`: Optional return value" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `return`, `RETURN value`, `return 42`" + char(10) +
		"- Non-matches: `return()`, `return,`, `returns`"
	],

	:ringPackage = [
		"Matches Ring Package declarations",

		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `Package\\s+`: 'Package' keyword" + char(10) +
		"- `[\\w.]+`: Package name" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `Package myapp`, `PACKAGE system.core`, `package lib.util`" + char(10) +
		"- Non-matches: `Package`, `Package.`, `Package()`"
	],

	:ringPrivate = [
	"Matches Ring Private declarations",

		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `Private`: 'Private' keyword" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `Private`, `PRIVATE`, `private`" + char(10) +
		"- Non-matches: `Private()`, `Privates`, `Private var`"
	],

	:ringBracestart = [
		"Matches the Ring function definition for `braceStart`",

		"- `^(?i)`: Case-insensitive match" + char(10) +
		"- `func\\s+`: Matches the keyword `func` followed by one or more spaces" + char(10) +
		"- `braceStart`: Matches the function name `braceStart`" + char(10) +
		"- `\\s*\\(`: Matches optional whitespace followed by an opening parenthesis" + char(10) +
		"- `\\s*\\)`: Matches optional whitespace followed by a closing parenthesis" + char(10) +
		"- `\\s*$`: Allows for trailing whitespace after the closing parenthesis" + char(10) + char(10) +

		"- Matches: `func braceStart()`" + char(10) +
		"- Non-matches: `func braceStart() something`, `braceStart()`, `func braceStart`"
	],

	:ringBraceEnd = [
		"Matches the Ring function definition for `braceEnd`",

		"- `^(?i)`: Case-insensitive match" + char(10) +
		"- `func\\s+`: Matches the keyword `func` followed by one or more spaces" + char(10) +
		"- `braceEnd`: Matches the function name `braceEnd`" + char(10) +
		"- `\\s*\\(`: Matches optional whitespace followed by an opening parenthesis" + char(10) +
		"- `\\s*\\)`: Matches optional whitespace followed by a closing parenthesis" + char(10) +
		"- `\\s*$`: Allows for trailing whitespace after the closing parenthesis" + char(10) + char(10) +

		"- Matches: `func braceEnd()`" + char(10) +
		"- Non-matches: `func braceEnd() something`, `braceEnd()`, `func braceEnd`"
	],

	:ringEval = [
		"Matches Ring Eval function calls",

		"- `^`: Start of line" + char(10) +
		"- `(?i)`: Case-insensitive matching" + char(10) +
		"- `Eval\\s*`: 'Eval' keyword" + char(10) +
		"- `\\(.*?\\)`: Parentheses with expression" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `Eval(1+1)`, `EVAL(x)`, `eval(expression())`" + char(10) +
		"- Non-matches: `Eval`, `Eval x`, `Evaluate()`"
	],

	# Python Language Patterns

	:pythonString = [
	        "Matches Python string literals",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `(?:`: Non-capturing group for alternatives:" + char(10) +
	        "  - `[" + StzChar(34) + "]{3}.*?[" + StzChar(34) + "]{3}`: Triple double-quoted strings" + char(10) +
	        "  - `|[" + StzChar(34) + "].*?[" + StzChar(34) + "]`: Double-quoted strings" + char(10) +
	        "  - `|'''.*?'''`: Triple single-quoted strings" + char(10) +
	        "  - `|'.*?'`: Single-quoted strings" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `" + StzChar(34) + "hello" + StzChar(34) + "`, `'world'`, `" + StzChar(34) + StzChar(34) + StzChar(34) + "multiline" + StzChar(34) + StzChar(34) + StzChar(34) + "`, `'''text'''`" + char(10) +
	        "- Non-matches: `" + StzChar(34) + "unclosed`, `''''extra'''`"
    	],

    	:pythonNumber = [
	        "Matches Python numeric literals",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `-?`: Optional minus sign" + char(10) +
	        "- `\\d+`: One or more digits" + char(10) +
	        "- `(?:\\.\\d+)?`: Optional decimal part" + char(10) +
	        "- `(?:e[+-]?\\d+)?`: Optional scientific notation" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `42`, `-17`, `3.14`, `1e-10`" + char(10) +
	        "- Non-matches: `.5`, `1.`, `e5`"
    	],

    	:pythonBoolean = [
	        "Matches Python boolean and None literals",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `(?:True|False|None)`: Either 'True', 'False', or 'None'" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `True`, `False`, `None`" + char(10) +
	        "- Non-matches: `true`, `false`, `none`, `NULL`"
	],

	:pythonVariable = [
	        "Matches Python variable names",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `[a-zA-Z_]`: First character must be letter or underscore" + char(10) +
	        "- `\\w*`: Following characters can be letters, numbers, or underscores" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `name`, `_count`, `myVar123`" + char(10) +
	        "- Non-matches: `123var`, `my-var`, `$var`"
    	],

    	:pythonFunction = [
	        "Matches Python function definitions",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `def\\s+`: 'def' keyword and whitespace" + char(10) +
	        "- `([a-zA-Z_]\\w*)`: Function name" + char(10) +
	        "- `\\s*\\((.*?)\\)`: Parameter list in parentheses" + char(10) +
	        "- `(?:\\s*->\\s*[\\w\\[\\],\\s]+)?`: Optional return type annotation" + char(10) +
	        "- `:`: Function block start" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `def test():`, `def calc(x, y) -> int:`, `def _init():`" + char(10) +
	        "- Non-matches: `def test`, `def 1func():`, `def()`"
    	],

    	:pythonFunctionCall = [
	        "Matches Python function calls",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `([a-zA-Z_]\\w*)`: Function name" + char(10) +
	        "- `\\s*\\((.*?)\\)`: Function arguments in parentheses" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `print()`, `calculate(x, y)`, `func(1, 2, 3)`" + char(10) +
	        "- Non-matches: `1func()`, `func(`, `func`"
    	],

    	:pythonLambda = [
	        "Matches Python lambda expressions",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `lambda\\s+`: 'lambda' keyword and whitespace" + char(10) +
	        "- `.*?`: Lambda parameters" + char(10) +
	        "- `:\\s*`: Colon and optional whitespace" + char(10) +
	        "- `.*`: Lambda body" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `lambda x: x*2`, `lambda: True`, `lambda a, b: a+b`" + char(10) +
	        "- Non-matches: `lambda`, `lambda:`, `lambda x`"
   	 ],

    	:pythonClass = [
	        "Matches Python class definitions",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `class\\s+`: 'class' keyword and whitespace" + char(10) +
	        "- `([a-zA-Z_]\\w*)`: Class name" + char(10) +
	        "- `(?:\\((.*?)\\))?`: Optional parent classes" + char(10) +
	        "- `:`: Class block start" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `class Test:`, `class Child(Parent):`, `class MyClass(A, B):`" + char(10) +
	        "- Non-matches: `class Test`, `class 1Test:`, `class:`"
   	 ],

    	:pythonClassMethod = [
	        "Matches Python method decorators",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `@`: Decorator symbol" + char(10) +
	        "- `\\w+`: Decorator name" + char(10) +
	        "- `\\s*`: Optional whitespace" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `@classmethod`, `@staticmethod`, `@property`" + char(10) +
	        "- Non-matches: `@`, `@1method`, `@class method`"
   	 ],

   	 :pythonDecorator = [
	        "Matches Python decorators",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `@`: Decorator symbol" + char(10) +
	        "- `[a-zA-Z_]\\w*`: Decorator name" + char(10) +
	        "- `(?:\\((.*?)\\))?`: Optional decorator arguments" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `@decorator`, `@wrap(arg)`, `@auth(user='admin')`" + char(10) +
	        "- Non-matches: `@`, `@1dec`, `@dec(`"
    	],

    	:pythonLoop = [
	        "Matches Python loop statements",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `(?:`: Non-capturing group for alternatives:" + char(10) +
	        "  - `for\\s+.*?\\s+in\\s+.*?:`: For loop" + char(10) +
	        "  - `|while\\s+.*?:`: While loop" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `for i in range(10):`, `while True:`, `for x in list:`" + char(10) +
	        "- Non-matches: `for`, `while`, `for in:`"
   	 ],

    	:pythonIf = [
	        "Matches Python conditional statements",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `(?:if|elif|else)`: Conditional keywords" + char(10) +
	        "- `\\s*.*?:`: Condition and colon" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `if x > 0:`, `elif x < 0:`, `else:`" + char(10) +
	        "- Non-matches: `if:`, `else if:`, `if x`"
    	],

    	:pythonWith = [
	        "Matches Python with statements",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `with\\s+`: 'with' keyword" + char(10) +
	        "- `.*?\\s+`: Context manager expression" + char(10) +
	        "- `as\\s+`: 'as' keyword" + char(10) +
	        "- `.*?:`: Target variable and colon" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `with open('file.txt') as f:`, `with context() as c:`" + char(10) +
	        "- Non-matches: `with:`, `with as:`, `with open()`"
    	],

    	:pythonTry = [
	        "Matches Python exception handling statements",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `(?:try|except|finally|raise)`: Exception keywords" + char(10) +
	        "- `\\s*.*?:`: Optional expression and colon" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `try:`, `except ValueError:`, `finally:`, `raise Exception()`" + char(10) +
	        "- Non-matches: `try`, `except:()`, `raises:`"
    	],

   	:pythonList = [
	        "Matches Python list literals",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `\\[`: Opening bracket" + char(10) +
	        "- `(?:[^[\\]]*|\\[.*?\\])*`: List contents, including nested lists" + char(10) +
	        "- `\\]`: Closing bracket" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `[1,2,3]`, `[[1,2],[3,4]]`, `[]`" + char(10) +
	        "- Non-matches: `[unclosed`, `[1,2,`, `[[]`"
    	],

   	:pythonDict = [
	        "Matches Python dictionary literals",
	        
	        "- `^`: Start of line" + char(10) +
	        "- `{`: Opening brace" + char(10) +
	        "- `(?:[^{}]*|{.*?})*`: Dictionary contents, including nested dicts" + char(10) +
	        "- `}`: Closing brace" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `{'a':1}`, `{1:2, 3:4}`, `{}`" + char(10) +
	        "- Non-matches: `{unclosed`, `{:}`, `{{}`"
    	],

	:pythonTuple = [
        	"Matches Python tuple literals",

	        "- `^`: Start of line" + char(10) +
	        "- `\\(`: Opening parenthesis" + char(10) +
	        "- `(?:[^()]*|\\(.*?\\))*`: Tuple contents, including nested tuples" + char(10) +
	        "- `\\)`: Closing parenthesis" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `(1,2)`, `(1,(2,3))`, `()`" + char(10) +
	        "- Non-matches: `(unclosed`, `(,)`, `(()`"
    	],

    	:pythonComprehension = [
		"Matches Python list comprehensions",

		"- `^`: Start of line" + char(10) +
		"- `\\[`: Opening bracket" + char(10) +
		"- `.*?\\s+`: Expression" + char(10) +
		"- `for\\s+.*?\\s+in\\s+.*?`: For clause" + char(10) +
		"- `\\]`: Closing bracket" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `[x for x in range(10)]`, `[i*2 for i in list]`" + char(10) +
		"- Non-matches: `[for in]`, `[x for]`, `[x in y]`"
	],

	:pythonComment = [
		"Matches Python single-line comments",

	        "- `^`: Start of line" + char(10) +
	        "- `#`: Comment symbol" + char(10) +
	        "- `.*`: Comment text" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `# comment`, `#note`, `# TODO: fix`" + char(10) +
	        "- Non-matches: `/#comment`, `comment#`, `##`"
	],

	:pythonDocstring = [
		"Matches Python docstrings",

	        "- `^`: Start of line" + char(10) +
	        "- `[" + StzChar(34) + "]{3}`: Triple quotes" + char(10) +
	        "- `[\\s\\S]*?`: Any content including newlines" + char(10) +
	        "- `[" + StzChar(34) + "]{3}`: Closing triple quotes" + char(10) +
	        "- `$`: End of line" + char(10) + char(10) +

	        "- Matches: `" + StzChar(34) + StzChar(34) + StzChar(34) + "Documentation" + StzChar(34) + StzChar(34) + StzChar(34) + "`, `" + StzChar(34) + StzChar(34) + StzChar(34) + "Multi" + char(10) + "line" + StzChar(34) + StzChar(34) + StzChar(34) + "`" + char(10) +
	        "- Non-matches: `" + StzChar(34) + "doc" + StzChar(34) + "`, `" + StzChar(34) + StzChar(34) + StzChar(34) + "unclosed`"
    	],

	:pythonImport = [
	        "Matches Python import statements",

	        "- `^`: Start of line" + char(10) +
	        "- `(?:import|from)`: 'import' or 'from' keyword" + char(10) +
	        "- `\\s+[\\w.]+`: Module path" + char(10) +
	        "- `(?:\\s+import\\s+`: Optional import clause" + char(10) +
	        "- `(?:\\w+(?:\\s+as\\s+\\w+)?`: Import target with optional alias" + char(10) +
	        "- `(?:\\s*,\\s*\\w+(?:\\s+as\\s+\\w+)?)*|\\*))?`: Multiple imports or star import" + char(10) +
	        "- `\\s*$`: End of line" + char(10) + char(10) +

	        "- Matches: `import os`, `from sys import path`, `from x import *`" + char(10) +
	        "- Non-matches: `import`, `from`, `import as`"
    ],

	# JavaScript Language Patterns

	:jsString = [
		"Matches JavaScript string literals",
		
		"- `^`: Start of line" + char(10) +
		"- `(?:`: Non-capturing group for string types" + char(10) +
		"- `[" + StzChar(34) + "].*?[" + StzChar(34) + "]`: Double-quoted strings" + char(10) +
		"- `|'.*?'`: Single-quoted strings" + char(10) +
		"- `|`[\s\S]*?``: Template literals" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `" + StzChar(34) + "hello" + StzChar(34) + "`, `'world'`, ``template``" + char(10) +
		"- Non-matches: `hello`, `" + StzChar(34) + "unclosed`"
	],

	:jsNumber = [
		"Matches JavaScript numeric literals",
		
		"- `^`: Start of line" + char(10) +
		"- `-?`: Optional negative sign" + char(10) +
		"- `\d+`: One or more digits" + char(10) +
		"- `(?:\.\d+)?`: Optional decimal portion" + char(10) +
		"- `(?:e[+-]?\d+)?`: Optional exponential notation" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `42`, `-3.14`, `1.2e-10`" + char(10) +
		"- Non-matches: `.`, `1.`, `e10`"
	],

	:jsBoolean = [
		"Matches JavaScript boolean and null values",
		
		"- `^`: Start of line" + char(10) +
		"- `(?:true|false|null|undefined)`: Literal values" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `true`, `false`, `null`, `undefined`" + char(10) +
		"- Non-matches: `True`, `FALSE`, `Null`"
	],

	:jsVariable = [
		"Matches JavaScript variable declarations",
		
		"- `^`: Start of line" + char(10) +
		"- `(?:var|let|const)`: Declaration keyword" + char(10) +
		"- `\s+`: Required whitespace" + char(10) +
		"- `[a-zA-Z_$][\w$]*`: Variable name" + char(10) +
		"- `(?:\s*=\s*.*)?`: Optional initialization" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `let x`, `const myVar = 42`" + char(10) +
		"- Non-matches: `x = 5`, `let 1x`"
	],

	:jsFunction = [
		"Matches JavaScript function declarations",
			
		"- `^`: Start of line" + char(10) +
		"- `(?:function\s+([a-zA-Z_$][\w$]*)\s*\((.*?)\)`: Named function" + char(10) +
		"- `|(?:async\s+)?function\s*\((.*?)\))`: Anonymous function" + char(10) +
		"- `\s*{`: Opening brace" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `function add(a, b) {`, `async function() {`" + char(10) +
		"- Non-matches: `function`, `function() => {`"
	],

	:jsArrowFunction = [
		"Matches JavaScript arrow function expressions",
			
		"- `^`: Start of line" + char(10) +
		"- `(?:const\s+)?`: Optional const declaration" + char(10) +
		"- `([a-zA-Z_$][\w$]*)\s*=\s*`: Variable assignment" + char(10) +
		"- `(?:async\s+)?`: Optional async keyword" + char(10) +
		"- `\((.*?)\)\s*=>\s*`: Arrow function syntax" + char(10) +
		"- `(?:{|\S.*)`: Function body" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `const add = (a, b) => {`, `sum = x => x + 1`" + char(10) +
		"- Non-matches: `=> {}`, `const = () =>`"
	],

	:jsClass = [
		"Matches JavaScript class declarations",
		
		"- `^`: Start of line" + char(10) +
		"- `class\s+`: Class keyword" + char(10) +
		"- `([a-zA-Z_$][\w$]*)`: Class name" + char(10) +
		"- `(?:\s+extends\s+([a-zA-Z_$][\w$]*))?`: Optional inheritance" + char(10) +
		"- `$`: End of line" + char(10) + char(10) +

		"- Matches: `class Person`, `class Student extends Person`" + char(10) +
		"- Non-matches: `class`, `class 1Name`"
	],
	
	:jsClassMethod = [
	    	"Matches JavaScript class method declarations",
	
	    	"- `^`: Start of line" + char(10) +
	    	"- `(?:async\s+)?`: Optional async keyword" + char(10) +
	    	"- `([a-zA-Z_$][\w$]*)`: Method name" + char(10) +
	    	"- `\s*\((.*?)\)\s*{`: Parameters and opening brace" + char(10) +
	    	"- `$`: End of line" + char(10) + char(10) +

	    	"- Matches: `getName() {`, `async calculate(x, y) {`" + char(10) +
	    	"- Non-matches: `method`, `123() {`"
	],

	:jsDecorator = [
    		"Matches JavaScript decorators",

	    	"- `^`: Start of line" + char(10) +
	    	"- `@`: Decorator symbol" + char(10) +
	    	"- `[a-zA-Z_$][\w$]*`: Decorator name" + char(10) +
	    	"- `(?:\((.*?)\))?`: Optional parameters" + char(10) +
	   	 "- `$`: End of line" + char(10) + char(10) +

	    	"- Matches: `@readonly`, `@validate(true)`" + char(10) +
	    	"- Non-matches: `@`, `@123`"
	],

	:jsLoop = [
	 	"Matches JavaScript loop statements",
	
	    	"- `^`: Start of line" + char(10) +
	    	"- `(?:for|while|do)`: Loop keyword" + char(10) +
	    	"- `\s*\(.*?\)`: Condition or iteration expression" + char(10) +
	    	"- `$`: End of line" + char(10) + char(10) +

	    	"- Matches: `for(let i = 0;i<10;i++)`, `while(true)`" + char(10) +
	    	"- Non-matches: `for`, `while`"
	],

	:jsObject = [
	    "Matches JavaScript object literals",
	
	    "- `^`: Start of line" + char(10) +
	    "- `{`: Opening brace" + char(10) +
	    "- `(?:[^{}]*|{.*?})*`: Object content" + char(10) +
	    "- `}`: Closing brace" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `{x: 1}`, `{a: {b: 2}}`" + char(10) +
	    "- Non-matches: `{`, `{a:}`"
	],

	:jsArray = [
	    "Matches JavaScript array literals",
	
	    "- `^`: Start of line" + char(10) +
	    "- `\[`: Opening bracket" + char(10) +
	    "- `(?:[^[\]]*|\[.*?\])*`: Array content" + char(10) +
	    "- `\]`: Closing bracket" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `[1,2,3]`, `[[1],[2]]`" + char(10) +
	    "- Non-matches: `[`, `[1,]`"
	],

	:jsDestructuring = [
	    "Matches JavaScript destructuring assignments",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:let|const|var)?`: Optional declaration" + char(10) +
	    "- `\s*(?:{[^}]*}|\[[^\]]*\])`: Destructuring pattern" + char(10) +
	    "- `\s*=\s*.*`: Assignment" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `const {x, y} = obj`, `let [a, b] = arr`" + char(10) +
	    "- Non-matches: `{a,b}`, `[x,y]`"
	],

	:jsComment = [
	    "Matches JavaScript comments",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?://.*|/\*[\s\S]*?\*/)`: Single or multi-line comments" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `//comment`, `/* multi-line */`" + char(10) +
	    "- Non-matches: `/comment`, `/*unclosed`"
	],

	:jsImport = [
	    "Matches JavaScript import statements",
	
	    "- `^`: Start of line" + char(10) +
	    "- `import\s+`: Import keyword" + char(10) +
	    "- `(?:{[^}]*}|\*\s+as\s+\w+|\w+)`: Import specifiers" + char(10) +
	    "- `\s+from\s+`: From keyword" + char(10) +
	    "- `[" + StzChar(34) + "'].*?[" + StzChar(34) + "']`: Module path" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `import {x} from " + StzChar(34) + "mod" + StzChar(34) + "`, `import * as y from 'z'`" + char(10) +
	    "- Non-matches: `import`, `import from`"
	],
	
	:jsExport = [
	    "Matches JavaScript export statements",
	
	    "- `^`: Start of line" + char(10) +
	    "- `export\s+`: Export keyword" + char(10) +
	    "- `(?:default\s+)?`: Optional default export" + char(10) +
	    "- `(?:class|function|const|let|var)`: Exported declaration" + char(10) +
	    "- `\s+.*`: Export name and body" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `export class X`, `export default function`" + char(10) +
	    "- Non-matches: `export`, `export 123`"
	],

	# Visual Basic Language Patterns

	:vbString = [
	    "Matches Visual Basic string literals",
	
	    "- `^`: Start of line" + char(10) +
	    "- `[" + StzChar(34) + "]`: Opening double quote" + char(10) +
	    "- `.*?`: String content (non-greedy)" + char(10) +
	    "- `[" + StzChar(34) + "]`: Closing double quote" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `" + StzChar(34) + "Hello World" + StzChar(34) + "`, `" + StzChar(34) + "" + StzChar(34) + "`" + char(10) +
	    "- Non-matches: `Hello`, `" + StzChar(34) + "unclosed`"
	],
	
	:vbNumber = [
	    "Matches Visual Basic numeric literals",
	
	    "- `^`: Start of line" + char(10) +
	    "- `-?`: Optional negative sign" + char(10) +
	    "- `\d+`: One or more digits" + char(10) +
	    "- `(?:\.\d+)?`: Optional decimal portion" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `42`, `-3.14`, `1000`" + char(10) +
	    "- Non-matches: `.`, `1.`, `3.14.15`"
	],
	
	:vbBoolean = [
	    "Matches Visual Basic boolean literals",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:True|False)`: Boolean values" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `True`, `False`" + char(10) +
	    "- Non-matches: `true`, `false`, `TRUE`"
	],
	
	:vbVariable = [
	    "Matches Visual Basic variable declarations",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:Dim|Private|Public|Protected)`: Declaration scope" + char(10) +
	    "- `\s+`: Required whitespace" + char(10) +
	    "- `([a-zA-Z_]\w*)`: Variable name" + char(10) +
	    "- `\s+As\s+`: Type declaration" + char(10) +
	    "- `\w+`: Variable type" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Dim count As Integer`, `Public name As String`" + char(10) +
	    "- Non-matches: `Dim x`, `Private 1var As Integer`"
	],
	
	:vbFunction = [
	    "Matches Visual Basic function declarations",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:Public\s+|Private\s+|Protected\s+)?`: Optional scope" + char(10) +
	    "- `Function\s+`: Function keyword" + char(10) +
	    "- `([a-zA-Z_]\w*)`: Function name" + char(10) +
	    "- `\s*\((.*?)\)`: Parameters" + char(10) +
	    "- `\s+As\s+\w+`: Return type" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Function Add(x As Integer, y As Integer) As Integer`" + char(10) +
	    "- Non-matches: `Function`, `Public Function()`"
	],
	
	:vbSub = [
	    "Matches Visual Basic subroutine declarations",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:Public\s+|Private\s+|Protected\s+)?`: Optional scope" + char(10) +
	    "- `Sub\s+`: Sub keyword" + char(10) +
	    "- `([a-zA-Z_]\w*)`: Subroutine name" + char(10) +
	    "- `\s*\((.*?)\)`: Parameters" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Public Sub Initialize()`, `Private Sub HandleClick(sender As Object)`" + char(10) +
	    "- Non-matches: `Sub`, `Public Sub`"
	],
	
	:vbFunctionCall = [
	    "Matches Visual Basic function calls",
	
	    "- `^`: Start of line" + char(10) +
	    "- `([a-zA-Z_]\w*)`: Function name" + char(10) +
	    "- `\s*\((.*?)\)`: Function arguments" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Calculate()`, `Add(x, y)`" + char(10) +
	    "- Non-matches: `Call()`, `1Function()`"
	],
	
	:vbClass = [
	    "Matches Visual Basic class declarations",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:Public\s+|Private\s+)?`: Optional scope" + char(10) +
	    "- `Class\s+`: Class keyword" + char(10) +
	    "- `([a-zA-Z_]\w*)`: Class name" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Public Class Customer`, `Private Class Helper`" + char(10) +
	    "- Non-matches: `Class`, `Public Class 1Name`"
	],
	
	:vbInterface = [
	    "Matches Visual Basic interface declarations",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:Public\s+|Private\s+)?`: Optional scope" + char(10) +
	    "- `Interface\s+`: Interface keyword" + char(10) +
	    "- `([a-zA-Z_]\w*)`: Interface name" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Public Interface IDisposable`, `Interface IComparable`" + char(10) +
	    "- Non-matches: `Interface`, `Public Interface 1Name`"
	],
	
	:vbProperty = [
	    "Matches Visual Basic property declarations",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:Public\s+|Private\s+|Protected\s+)?`: Optional scope" + char(10) +
	    "- `Property\s+`: Property keyword" + char(10) +
	    "- `(?:Get|Let|Set)`: Property type" + char(10) +
	    "- `\s+([a-zA-Z_]\w*)`: Property name" + char(10) +
	    "- `\s*\((.*?)\)`: Parameters" + char(10) +
	    "- `\s+As\s+\w+`: Return type" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Property Get Name() As String`, `Public Property Let Value(v As Integer)`" + char(10) +
	    "- Non-matches: `Property`, `Property Get`"
	],
	
	:vbLoop = [
	    "Matches Visual Basic loop statements",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:For|Do|While|For\s+Each)`: Loop keywords" + char(10) +
	    "- `\s+.*`: Loop condition or iteration" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `For i = 1 To 10`, `Do While condition`, `For Each item In collection`" + char(10) +
	    "- Non-matches: `For`, `While`"
	],
	
	:vbIf = [
	    "Matches Visual Basic if statements",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:If|ElseIf|Else)`: Conditional keywords" + char(10) +
	    "- `\s+.*?\s+`: Condition (if applicable)" + char(10) +
	    "- `Then`: Required for If/ElseIf" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `If x > 0 Then`, `ElseIf count = 0 Then`, `Else Then`" + char(10) +
	    "- Non-matches: `If`, `If x > 0`"
	],
	
	:vbSelect = [
	    "Matches Visual Basic select case statements",
	
	    "- `^`: Start of line" + char(10) +
	    "- `Select\s+Case\s+`: Select Case keywords" + char(10) +
	    "- `.*`: Expression being tested" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Select Case x`, `Select Case day`" + char(10) +
	    "- Non-matches: `Select`, `Case`"
	],
	
	:vbTry = [
	    "Matches Visual Basic error handling blocks",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:Try|Catch|Finally)`: Error handling keywords" + char(10) +
	    "- `\s*`: Optional whitespace" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Try`, `Catch`, `Finally`" + char(10) +
	    "- Non-matches: `Try Catch`, `Catch Error`"
	],
	
	:vbArray = [
	    "Matches Visual Basic array declarations",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:Dim|Private|Public|Protected)`: Declaration scope" + char(10) +
	    "- `\s+([a-zA-Z_]\w*)`: Array name" + char(10) +
	    "- `\s*\(\s*\d*\s*\)`: Array dimensions" + char(10) +
	    "- `\s+As\s+\w+`: Array type" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Dim numbers(10) As Integer`, `Public matrix(,) As Double`" + char(10) +
	    "- Non-matches: `Dim array`, `Private arr() As`"
	],
	
	:vbCollection = [
	    "Matches Visual Basic collection instantiation",
	
	    "- `^`: Start of line" + char(10) +
	    "- `New\s+`: New keyword" + char(10) +
	    "- `Collection`: Collection type" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `New Collection`" + char(10) +
	    "- Non-matches: `Collection`, `New List`"
	],
	
	:vbComment = [
	    "Matches Visual Basic single-line comments",
	
	    "- `^`: Start of line" + char(10) +
	    "- `'`: Comment character" + char(10) +
	    "- `.*`: Comment text" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `'This is a comment`, `' Note:`" + char(10) +
	    "- Non-matches: `//comment`, `REM comment`"
	],
	
	:vbRemark = [
	    "Matches Visual Basic REM comments",
	
	    "- `^`: Start of line" + char(10) +
	    "- `REM\s+`: REM keyword with space" + char(10) +
	    "- `.*`: Comment text" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `REM This is a remark`, `REM Debug code below`" + char(10) +
	    "- Non-matches: `REM`, `'REM comment`"
	],
	
	:vbModule = [
	    "Matches Visual Basic module declarations",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:Public\s+|Private\s+)?`: Optional scope" + char(10) +
	    "- `Module\s+`: Module keyword" + char(10) +
	    "- `([a-zA-Z_]\w*)`: Module name" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Module Utils`, `Public Module Constants`" + char(10) +
	    "- Non-matches: `Module`, `Module 1Name`"
	],
	
	:vbNamespace = [
	    "Matches Visual Basic namespace declarations",
	
	    "- `^`: Start of line" + char(10) +
	    "- `Namespace\s+`: Namespace keyword" + char(10) +
	    "- `[\w.]+`: Namespace path" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Namespace MyApp`, `Namespace System.Data`" + char(10) +
	    "- Non-matches: `Namespace`, `Namespace 1.2`"
	],
	
	:vbImports = [
	    "Matches Visual Basic imports statements",
	
	    "- `^`: Start of line" + char(10) +
	    "- `Imports\s+`: Imports keyword" + char(10) +
	    "- `[\w.]+`: Imported namespace" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Imports System`, `Imports System.Collections.Generic`" + char(10) +
	    "- Non-matches: `Imports`, `Imports 1.System`"
	],
	
	:vbReference = [
	    "Matches Visual Basic reference declarations",
	
	    "- `^`: Start of line" + char(10) +
	    "- `Reference\s+=\s+`: Reference assignment" + char(10) +
	    "- `.*`: Reference path or name" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Reference = System`, `Reference = " + StzChar(34) + "MyLib.dll" + StzChar(34) + "`" + char(10) +
	    "- Non-matches: `Reference`, `Reference ==`"
	],
	
	# Julia Language Patterns

	:juliaString = [
	    "Matches Julia string literals including triple-quoted, regular, raw, and literal strings",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:`: Start non-capturing group for string types" + char(10) +
	    "- `[" + StzChar(34) + "]{3}.*?[" + StzChar(34) + "]{3}`: Triple-quoted strings" + char(10) +
	    "- `|[" + StzChar(34) + "].*?[" + StzChar(34) + "]`: Regular strings" + char(10) +
	    "- `|r[" + StzChar(34) + "].*?[" + StzChar(34) + "]`: Raw strings" + char(10) +
	    "- `|raw[" + StzChar(34) + "].*?[" + StzChar(34) + "])`: Literal strings" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `" + StzChar(34) + "hello" + StzChar(34) + "`, `" + StzChar(34) + StzChar(34) + StzChar(34) + "multiline" + StzChar(34) + StzChar(34) + StzChar(34) + "`, `r" + StzChar(34) + "raw\string" + StzChar(34) + "`" + char(10) +
	    "- Non-matches: `'string'`, `" + StzChar(34) + "unclosed`"
	],
	
	:juliaNumber = [
	    "Matches Julia numeric literals including integers, floats, and scientific notation",
	
	    "- `^`: Start of line" + char(10) +
	    "- `-?`: Optional negative sign" + char(10) +
	    "- `(?:\\d+(?:\\.\\d*)?|\\.\\d+)`: Integer or decimal number" + char(10) +
	    "- `(?:e[+-]?\\d+)?`: Optional scientific notation" + char(10) +
	    "- `(?:[ff]32|f64)?`: Optional float type suffix" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `42`, `-3.14`, `1.2e-10`, `3.14f32`" + char(10) +
	    "- Non-matches: `.`, `1.`, `e10`"
	],
	
	:juliaBoolean = [
	    "Matches Julia boolean and special value literals",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:true|false|nothing|missing)`: Boolean or special values" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `true`, `false`, `nothing`, `missing`" + char(10) +
	    "- Non-matches: `True`, `NULL`, `nil`"
	],
	
	:juliaVariable = [
	    "Matches Julia variable identifiers",
	
	    "- `^`: Start of line" + char(10) +
	    "- `[a-zA-Z_]`: First character must be letter or underscore" + char(10) +
	    "- `[\\w!]*`: Followed by word characters or exclamation mark" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `x`, `myVar`, `function!`, `_temp`" + char(10) +
	    "- Non-matches: `1x`, `$var`"
	],
	
	:juliaFunction = [
	    "Matches Julia function declarations with optional type annotations and where clauses",
	
	    "- `^`: Start of line" + char(10) +
	    "- `function\\s+`: Function keyword" + char(10) +
	    "- `([a-zA-Z_][\\w!]*)`: Function name" + char(10) +
	    "- `\\s*\\(([^)]*?)\\)`: Parameter list" + char(10) +
	    "- `(?:\\s*::\\s*[\\w{}.\\[\\]]+)?`: Optional return type" + char(10) +
	    "- `(?:where\\s+{.*?})?`: Optional where clause" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `function add(x, y)`, `function multiply(x::Int, y::Int)::Int`" + char(10) +
	    "- Non-matches: `function`, `function()`"
	],
	
	:juliaFunctionCall = [
	    "Matches Julia function calls",
	
	    "- `^`: Start of line" + char(10) +
	    "- `([a-zA-Z_][\\w!]*)`: Function name" + char(10) +
	    "- `\\s*\\((.*?)\\)`: Function arguments" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `println(x)`, `add!(1, 2)`" + char(10) +
	    "- Non-matches: `call x`, `1func()`"
	],
	
	:juliaLambda = [
	    "Matches Julia lambda expressions and anonymous functions",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:[^->]+->|function\\s*\\([^)]*\\))`: Lambda syntax or anonymous function" + char(10) +
	    "- `.*`: Function body" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `x -> x^2`, `function (x) x + 1 end`" + char(10) +
	    "- Non-matches: `->`, `function`"
	],
	
	:juliaStruct = [
	    "Matches Julia struct declarations with optional mutability and type parameters",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:mutable\\s+)?`: Optional mutability" + char(10) +
	    "- `struct\\s+`: Struct keyword" + char(10) +
	    "- `([a-zA-Z_][\\w!]*)`: Struct name" + char(10) +
	    "- `(?:{.*?})?`: Optional type parameters" + char(10) +
	    "- `(?:<:\\s*[\\w.]+)?`: Optional supertype" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `struct Point`, `mutable struct User{T}`" + char(10) +
	    "- Non-matches: `struct`, `struct 1Point`"
	],
	
	:juliaAbstract = [
	    "Matches Julia abstract type declarations",
	
	    "- `^`: Start of line" + char(10) +
	    "- `abstract\\s+type\\s+`: Abstract type keywords" + char(10) +
	    "- `([a-zA-Z_][\\w!]*)`: Type name" + char(10) +
	    "- `(?:{.*?})?`: Optional type parameters" + char(10) +
	    "- `(?:<:\\s*[\\w.]+)?`: Optional supertype" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `abstract type Number`, `abstract type Array{T} <: AbstractArray`" + char(10) +
	    "- Non-matches: `abstract`, `type Number`"
	],
	
	:juliaMacro = [
	    "Matches Julia macro invocations",
	
	    "- `^`: Start of line" + char(10) +
	    "- `@`: Macro symbol" + char(10) +
	    "- `[a-zA-Z_][\\w!]*`: Macro name" + char(10) +
	    "- `(?:\\s|$)`: Space or end of line" + char(10) + char(10) +

	    "- Matches: `@time`, `@async`" + char(10) +
	    "- Non-matches: `@`, `@1macro`"
	],
	
	:juliaLoop = [
	    "Matches Julia loop constructs",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:for\\s+.*?\\s+in\\s+.*?|while\\s+.*?)`: For or while loops" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `for i in 1:10`, `while x < 100`" + char(10) +
	    "- Non-matches: `for`, `while`"
	],
	
	:juliaIf = [
	    "Matches Julia conditional statements",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:if|elseif|else)`: Conditional keywords" + char(10) +
	    "- `\\s*.*?`: Condition (if applicable)" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `if x > 0`, `elseif isempty(arr)`, `else`" + char(10) +
	    "- Non-matches: `ifdef`, `elsif`"
	],
	
	:juliaBegin = [
	    "Matches Julia begin blocks",
	
	    "- `^`: Start of line" + char(10) +
	    "- `begin`: Begin keyword" + char(10) +
	    "- `\\s*`: Optional whitespace" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `begin`, `begin `" + char(10) +
	    "- Non-matches: `begins`, `begin{`"
	],
	
	:juliaTry = [
	    "Matches Julia exception handling blocks",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:try|catch|finally)`: Exception handling keywords" + char(10) +
	    "- `\\s*.*?`: Optional clause" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `try`, `catch e`, `finally`" + char(10) +
	    "- Non-matches: `trying`, `catch{`"
	],
	
	:juliaArray = [
	    "Matches Julia array literals",
	
	    "- `^`: Start of line" + char(10) +
	    "- `\\[`: Opening bracket" + char(10) +
	    "- `(?:[^\\[\\]]*|\\[.*?\\])*`: Array elements" + char(10) +
	    "- `\\]`: Closing bracket" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `[1, 2, 3]`, `[[1, 2], [3, 4]]`" + char(10) +
	    "- Non-matches: `[`, `[1,]`"
	],
	
	:juliaTuple = [
	    "Matches Julia tuple literals",
	
	    "- `^`: Start of line" + char(10) +
	    "- `\\(`: Opening parenthesis" + char(10) +
	    "- `(?:[^()]*|\\(.*?\\))*`: Tuple elements" + char(10) +
	    "- `\\)`: Closing parenthesis" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `(1, 2)`, `(x = 1, y = 2)`" + char(10) +
	    "- Non-matches: `(`, `(1,`"
	],
	
	:juliaDict = [
	    "Matches Julia dictionary literals",
	
	    "- `^`: Start of line" + char(10) +
	    "- `Dict\\(`: Dict constructor" + char(10) +
	    "- `(?:[^()]*|\\(.*?\\))*`: Dictionary key-value pairs" + char(10) +
	    "- `\\)`: Closing parenthesis" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Dict()`, `Dict(:a => 1, :b => 2)`" + char(10) +
	    "- Non-matches: `Dict`, `Dict[`"
	],
	
	:juliaComprehension = [
	    "Matches Julia array comprehensions",
	
	    "- `^`: Start of line" + char(10) +
	    "- `\\[`: Opening bracket" + char(10) +
	    "- `.*?\\s+for\\s+.*?\\s+in\\s+.*?`: Comprehension syntax" + char(10) +
	    "- `\\]`: Closing bracket" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `[x^2 for x in 1:10]`, `[i+j for i in 1:3 for j in 1:3]`" + char(10) +
	    "- Non-matches: `[for in]`, `[x for x]`"
	],
	
	:juliaComment = [
	    "Matches Julia comments (single-line and multi-line)",
	
	    "- `^`: Start of line" + char(10) +
	    "- `#=(?:[^=#]|=(?!#))*=#`: Multi-line comments" + char(10) +
	    "- `|^#.*`: Single-line comments" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `# comment`, `#= multi-line comment =#`" + char(10) +
	    "- Non-matches: `//comment`, `/* comment */`"
	],
	
	:juliaDocString = [
	    "Matches Julia documentation strings",
	
	    "- `^`: Start of line" + char(10) +
	    "- `[" + StzChar(34) + "]{3}`: Three double quotes" + char(10) +
	    "- `[\\s\\S]*?`: Documentation content" + char(10) +
	    "- `[" + StzChar(34) + "]{3}`: Closing three double quotes" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `" + StzChar(34) + StzChar(34) + StzChar(34) + "Function documentation" + StzChar(34) + StzChar(34) + StzChar(34) + "`" + char(10) +
	    "- Non-matches: `" + StzChar(34) + "doc" + StzChar(34) + "`, `" + StzChar(34) + StzChar(34) + StzChar(34) + "unclosed`"
	],
	
	:juliaImport = [
	    "Matches Julia import and using statements",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:using|import)`: Import keywords" + char(10) +
	    "- `\\s+`: Required whitespace" + char(10) +
	    "- `(?:[\\w.]+`: Module path" + char(10) +
	    "- `(?:\\s*:\\s*(?:[\\w,\\s]+|\\(.*?\\)))?`: Optional specific imports" + char(10) +
	    "- `(?:\\s*,\\s*[\\w.]+(?:\\s*:\\s*(?:[\\w,\\s]+|\\(.*?\\)))?)*)`: Additional imports" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `using LinearAlgebra`, `import Base: show, print`" + char(10) +
	    "- Non-matches: `using`, `import 1.2`"
	],
	
	:juliaModule = [
	    "Matches Julia module declarations",
	
	    "- `^`: Start of line" + char(10) +
	    "- `module\\s+`: Module keyword" + char(10) +
	    "- `[a-zA-Z_][\\w!]*`: Module name" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `module MyModule`, `module Utils`" + char(10) +
	    "- Non-matches: `module`, `module 1Name`"
	],
	
	:juliaExport = [
	    "Matches Julia export statements",
	
	    "- `^`: Start of line" + char(10) +
	    "- `export\\s+`: Export keyword" + char(10) +
	    "- `(?:[a-zA-Z_][\\w!]*`: First exported name" + char(10) +
	    "- `(?:\\s*,\\s*[a-zA-Z_][\\w!]*)*)`: Additional exported names" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `export foo`, `export foo, bar, baz`" + char(10) +
	    "- Non-matches: `export`, `export 1func`"
	],
	
	:juliaTypeParameter = [
	    "Matches Julia type parameter declarations",
	
	    "- `^`: Start of line" + char(10) +
	    "- `(?:[a-zA-Z_][\\w!]*)`: Type name" + char(10) +
	    "- `{.*?}`: Type parameters in curly braces" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `Array{T}`, `Dict{K,V}`, `Container{Type}`" + char(10) +
	    "- Non-matches: `T{}`, `Array{}`"
	],
	
	:juliaTypeAnnotation = [
	    "Matches Julia type annotations",
	
	    "- `^`: Start of line" + char(10) +
	    "- `::`: Type annotation operator" + char(10) +
	    "- `\\s*`: Optional whitespace" + char(10) +
	    "- `[\\w{}.\\[\\]]+`: Type specification" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `::Int`, `::Array{Float64,2}`, `::Dict{String,Any}`" + char(10) +
	    "- Non-matches: `:Int`, `:: `"
	],
	
	:juliaBroadcast = [
	    "Matches Julia broadcast operators",
	
	    "- `^`: Start of line" + char(10) +
	    "- `\\.`: Dot operator" + char(10) +
	    "- `\\w+`: Function or operator name" + char(10) +
	    "- `$`: End of line" + char(10) + char(10) +

	    "- Matches: `.+`, `.^`, `.sqrt`" + char(10) +
	    "- Non-matches: `.`, `.@`, `.1`"
	],

	# Excel FORMULAT Patterns

	:xlsFunctionCall = [
	    "Matches an Excel function call",
	
	    "- `^\\s*`: Allows leading whitespace" + char(10) +
	    "- `[A-Z]+`: Matches the function name (uppercase letters)" + char(10) +
	    "- `\\(.*\\)$`: Matches the opening parenthesis, arguments, and closing parenthesis" + char(10) + char(10) +

	    "- Matches: `SUM(A1:A10)`, ` IF(A1>0, TRUE, FALSE)`" + char(10) +
	    "- Non-matches: `sum(A1:A10)`, `SUM A1:A10`"
	],
	
	:xlsCellReference = [
	    "Matches a single Excel cell reference",
	
	    "- `^[A-Z]+`: Matches the column (letters A to Z)" + char(10) +
	    "- `\\d+$`: Matches the row (numeric part)" + char(10) + char(10) +

	    "- Matches: `A1`, `B12`, `ZZ100`" + char(10) +
	    "- Non-matches: `1A`, `ABCD`, `A 1`"
	],
	
	:xlsRangeReference = [
	    "Matches an Excel range reference",
	
	    "- `^[A-Z]+\\d+`: Matches the start cell of the range" + char(10) +
	    "- `:[A-Z]+\\d+$`: Matches the colon and the end cell of the range" + char(10) + char(10) +

	    "- Matches: `A1:B10`, `C5:D7`, `Z1:Z100`" + char(10) +
	    "- Non-matches: `A1:B`, `A1-10`, `1A:B2`"
	],
	
	:xlsRelativeReference = [
	    "Matches a relative Excel cell reference",
	
	    "- `^(?:[A-Z]*\\d+|[A-Z]+\\d*)$`: Matches either column-relative or row-relative references" + char(10) + char(10) +

	    "- Matches: `A1`, `1`, `A`" + char(10) +
	    "- Non-matches: `$A$1`, `$1`, `$A`"
	],
	
	:xlsAbsoluteReference = [
	    "Matches an absolute Excel cell reference",
	
	    "- `^\\$[A-Z]+`: Matches the dollar sign and absolute column reference" + char(10) +
	    "- `\\$\\d+$`: Matches the dollar sign and absolute row reference" + char(10) + char(10) +

	    "- Matches: `$A$1`, `$B$100`" + char(10) +
	    "- Non-matches: `A1`, `1`, `$A1`"
	],
	
	:xlsMixedReference = [
	    "Matches a mixed Excel cell reference",
	
	    "- `^(?:\\$[A-Z]+\\d+|[A-Z]+\\$\\d+)$`: Matches either absolute column/relative row or relative column/absolute row references" + char(10) + char(10) +

	    "- Matches: `$A1`, `A$1`, `$B$2`" + char(10) +
	    "- Non-matches: `A1`, `$A$1`, `B2$`"
	],
	
	:xlsStringLiteral = [
	    "Matches a string literal in Excel",
	
	   "- `^\" + StzChar(34) + " + StzChar(34) + " + StzChar(34) + ".*\" + StzChar(34) + " + StzChar(34) + " + StzChar(34) + "$`: Matches a string enclosed in double quotes" + char(10) + char(10) +

	   "- Matches: `\" + StzChar(34) + "Hello\" + StzChar(34) + "`, `\" + StzChar(34) + "123\" + StzChar(34) + "`, `\" + StzChar(34) + "A1:B10\" + StzChar(34) + "`" + char(10) +
	    "- Non-matches: `Hello`, `'Hello'`, `\" + StzChar(34) + "Hello`"
	],
	
	:xlsNumberLiteral = [
	    "Matches a numeric literal in Excel",
	
	    "- `^-?\\d+(\\.\\d+)?$`: Matches an integer or decimal number, optionally negative" + char(10) + char(10) +

	    "- Matches: `123`, `-45`, `3.14`, `-0.5`" + char(10) +
	    "- Non-matches: `123A`, `3,14`, `.`"
	],
	
	:xlsBooleanLiteral = [
	    "Matches a boolean literal in Excel",
	
	    "- `^(TRUE|FALSE)$`: Matches the literals TRUE or FALSE (case-sensitive)" + char(10) + char(10) +

	    "- Matches: `TRUE`, `FALSE`" + char(10) +
	    "- Non-matches: `true`, `false`, `1`"
	],
	
	:xlsArithmeticExpression = [
	    "Matches an Excel arithmetic expression",
	
	    "- `^.*(?:[+\\-*/^]).*$`: Matches any formula containing arithmetic operators" + char(10) + char(10) +

	    "- Matches: `A1+A2`, `B1-B2`, `3*4`, `5/2`, `2^3`" + char(10) +
	    "- Non-matches: `A1A2`, `3*`, `*4`"
	],
	
	:xlsConditionalExpression = [
	    "Matches an Excel conditional expression",
	
	    "- `^.*(?:=|<|>|<>).*$`: Matches any formula containing comparison operators" + char(10) + char(10) +

	    "- Matches: `A1=A2`, `B1<>C1`, `A1>10`, `5<=6`" + char(10) +
	    "- Non-matches: `A1A2`, `=A1`, `<B2`"
	],

	:xlsArrayFormula = [
	"Matches an Excel array formula",

		"- `^\\{`: Matches the opening curly brace for the array formula" + char(10) +
		"- `(?:`: Start of a non-capturing group" + char(10) +
		"- `\\s*=\\s*[A-Za-z]+\\([^\\)]*\\)`: Matches a formula starting with an equal sign, a function name, and arguments enclosed in parentheses" + char(10) +
		"- `|`: Alternation to match either a function or plain array values" + char(10) +
		"- `\\s*[A-Za-z0-9\\+\\-\\*/\\(\\)\\&\\^\\.]+`: Matches numeric or textual values, operators, and parenthesized expressions" + char(10) +
		"- `(\\s*,\\s*[A-Za-z0-9\\+\\-\\*/\\(\\)\\&\\^\\.]+)*`: Optionally matches additional array elements separated by commas" + char(10) +
		"- `\\s*`: Allows trailing whitespace" + char(10) +
		"- `\\}`: Matches the closing curly brace for the array formula" + char(10) +
		"- `$`: Ensures the entire string matches the pattern" + char(10) + char(10) +

		"- Matches: `{=SUM(A1:A10)}`, `{1, 2, 3}`, `{A1+B1, C1*D1}`" + char(10) +
		"- Non-matches: `{SUM(A1:A10}`, `{1, 2}`, `=SUM(A1:A10)`"
	],

	# R language patterns

	:rVariableName = [
		"Matches valid variable names in R",

		"- `^[A-Za-z.]`: Starts with a letter or a period (but not followed by a number)." + char(10) +
		"- `[A-Za-z0-9._]*`: Can include letters, digits, periods, and underscores." + char(10) + char(10) +

		"- Matches: `x`, `.myVar`, `data_1`." + char(10) +
		"- Non-matches: `1variable`, `var-name` (invalid characters)."
	],

	:rFunctionCall = [
		"Matches valid R function calls",

		"- `^[A-Za-z.][A-Za-z0-9._]*`: Matches a valid function name." + char(10) +
		"- `\\s*\\(.*\\)$`: Ensures the function is followed by parentheses with optional arguments inside." + char(10) + char(10) +

		"- Matches: `sum(1, 2)`, `myFunc(a = 1)`." + char(10) +
		"- Non-matches: `sum`, `1sum()` (invalid function name)."
	],

	:rAssignment = [
		"Matches R assignment statements",

		"- `^\\s*`: Optional leading whitespace." + char(10) +
		"- `[A-Za-z.][A-Za-z0-9._]*`: Matches a valid variable name." + char(10) +
		"- `\\s*(<-|=)\\s*`: Matches the assignment operator (`<-` or `=`)." + char(10) +
		"- `.*$`: Matches the assigned value." + char(10) + char(10) +

		"- Matches: `x <- 5`, `myVar = c(1, 2, 3)`." + char(10) +
		"- Non-matches: `<- x 5` (wrong order)."
	],

	:rNumericVector = [
		"Matches R numeric vector syntax",

		"- `^c\\(`: Starts with the `c(` function." + char(10) +
		"- `(\\s*-?\\d+(\\.\\d+)?\\s*(,\\s*-?\\d+(\\.\\d+)?\\s*)*)?`: Matches one or more numeric values separated by commas." + char(10) +
		"- `\\)$`: Ends with a closing parenthesis." + char(10) + char(10) +

		"- Matches: `c(1, 2, 3)`, `c(-1.5, 0.5)`." + char(10) +
		"- Non-matches: `c(1; 2; 3)`, `c()` (invalid delimiters or empty vector)."
	],

	:rStringVector = [
		"Matches R string vector syntax",

		"- `^c\\(`: Starts with the `c(` function." + char(10) +
		"- `(\\s*\" + StzChar(34) + ".*?\" + StzChar(34) + "\\s*(,\\s*\" + StzChar(34) + ".*?\" + StzChar(34) + "\\s*)*)?`: Matches one or more quoted strings separated by commas." + char(10) +
		"- `\\)$`: Ends with a closing parenthesis." + char(10) + char(10) +

		"- Matches: `c(\" + StzChar(34) + "apple\" + StzChar(34) + ", \" + StzChar(34) + "banana\" + StzChar(34) + ")`, `c(\" + StzChar(34) + "hello\" + StzChar(34) + ")`." + char(10) +
		"- Non-matches: `c(apple, banana)`, `c()` (missing quotes or empty vector)."
	],

	:rDataFrame = [
		"Matches R data frame creation statements",

		"- `^[A-Za-z.][A-Za-z0-9._]*`: Matches a valid variable name for the data frame." + char(10) +
		"- `\\s*<-\\s*`: Matches the assignment operator with optional whitespace." + char(10) +
		"- `data\\.frame\\(.*\\)$`: Matches the `data.frame` function with arguments inside." + char(10) + char(10) +

		"- Matches: `df <- data.frame(a = 1:5, b = letters[1:5])`." + char(10) +
		"- Non-matches: `data.frame(a = 1:5)` (missing assignment)."
	],

	:rPipeOperator = [
		"Matches the pipe operator `%>%` in R",

		"- `\\s*%>%\\s*`: Matches the `%>%` operator with optional surrounding whitespace." + char(10) + char(10) +

		"- Matches: `data %>% filter(x > 1)`, `a %>% b %>% c`." + char(10) +
		"- Non-matches: `data |> filter(x > 1)` (different pipe operator)."
	],

	:rComment = [
    		"Matches R comments",

		"- `^\\s*`: Optional leading whitespace." + char(10) +
		"- `#.*$`: Matches a `#` followed by any characters until the end of the line." + char(10) + char(10) +

		"- Matches: `# This is a comment`, `   # Indented comment`." + char(10) +
		"- Non-matches: `This is not a comment`."
	],

	:rLogicalOperator = [
		"Matches logical operators in R",

		"- `(\\&\\&|\\|\\||\\!|==|!=|<|<=|>|>=)`: Matches logical and comparison operators." + char(10) + char(10) +

		"- Matches: `&&`, `||`, `!`, `==`, `!=`, `<`, `<=`, `>`, `>=`." + char(10) +
		"- Non-matches: `&` (element-wise operator) or invalid syntax."
	],

	:rIndexing = [
		"Matches indexing operations",

		"- `\\[.*?\\]`: Matches square brackets with any content inside (non-greedy)." + char(10) + char(10) +

		"- Matches: `x[1]`, `df[1, 2]`, `list[[3]]`." + char(10) +
		"- Non-matches: `x1` (no brackets), `df[[1, 2]]` (invalid double-bracket indexing)."
	],

	:rForLoop = [
		"Matches R `for` loops",

		"- `^\\s*for\\s*\\(`: Starts with `for` keyword and a parenthesis." + char(10) +
		"- `[A-Za-z.][A-Za-z0-9._]*`: Matches the loop variable name." + char(10) +
		"- `in\\s*.*\\)\\s*\\{`: Matches the `in` keyword and loop range followed by `{`." + char(10) + char(10) +

		"- Matches: `for (i in 1:10) {`, `for (name in names(vector)) {`." + char(10) +
		"- Non-matches: `for i in 1:10` (missing parentheses)."
	],

	:rIfStatement = [
		"Matches R `if` statements",

		"- `^\\s*if\\s*\\(`: Starts with `if` keyword and a parenthesis." + char(10) +
		"- `.*\\)\\s*\\{`: Matches any condition followed by a closing parenthesis and `{`." + char(10) +
		"- Matches: `if (x > 1) {`, `if (length(vec) == 0) {`." + char(10) +
		"- Non-matches: `if x > 1 {` (missing parentheses)."
	],

	:rElseStatement = [
		"Matches R `else` statements",

		"- `^\\s*else\\s*\\{`: Matches the `else` keyword followed by `{`." + char(10) +
		"- Matches: `else {`." + char(10) +
		"- Non-matches: `else x = 1` (missing `{`)."
	],

	:rLibraryCall = [
		"Matches library or package loading calls",

		"- `^\\s*(library|require)\\s*\\(`: Matches `library` or `require` followed by a parenthesis." + char(10) +
		"- Matches: `library(ggplot2)`, `require(dplyr)`." + char(10) +
		"- Non-matches: `load(ggplot2)` (wrong function)."
	],

	:rFunctionDefinition = [
		"Matches R function definitions",

		"- `^[A-Za-z.][A-Za-z0-9._]*\\s*<-\\s*function\\s*\\(`: Matches a valid function name assigned to a function declaration." + char(10) +
		"- Matches: `myFunc <- function(x) {`." + char(10) +
		"- Non-matches: `function(x) {` (missing assignment)."
	],

	:rListCreation = [
		"Matches R list creation",

		"- `^list\\(.*\\)$`: Matches the `list` function with any content inside." + char(10) +
		"- Matches: `list(a = 1, b = 2)`, `list()`." + char(10) +
		"- Non-matches: `lst(a = 1)` (invalid function name)."
	],

	:rApplyFamily = [
		"Matches functions from the apply family",

		"- `(apply|lapply|sapply|vapply|mapply|tapply)\\s*\\(.*\\)`: Matches any apply function followed by arguments." + char(10) +
		"- Matches: `apply(matrix, 1, sum)`, `lapply(list, mean)`." + char(10) +
		"- Non-matches: `applysum(matrix, 1)` (wrong function)."
	],

	# Credit cards and Bank accounts

	:creditCard = [
		"Matches credit card numbers",

		"- `^\\d{4}[- ]?\\d{4}[- ]?\\d{4}[- ]?\\d{4}$`: Matches 16-digit numbers grouped in 4 digits separated by spaces or hyphens, or no separators." + char(10) + char(10) +

		"- Matches: `1234 5678 9012 3456`, `1234-5678-9012-3456`, `1234567890123456`." + char(10) +
		"- Non-matches: `1234 5678 90123`, `12345 6789`, `abcd efgh`."
	],

	:bankAccount = [
		"Matches generic bank account numbers",

		"- `^\\d{8,20}$`: Matches numeric strings between 8 and 20 digits." + char(10) + char(10) +

		"- Matches: `12345678`, `98765432101234567890`." + char(10) +
		"- Non-matches: `1234567`, `12345abcd`, `123456789012345678901`."
	],

	:iban = [
		"Matches International Bank Account Numbers (IBAN)",

		"- `^[A-Z]{2}\\d{2}[A-Z0-9]{1,30}$`: Starts with a 2-letter country code, 2-digit checksum, and up to 30 alphanumeric characters." + char(10) + char(10) +

		"- Matches: `GB29NWBK60161331926819`, `DE89370400440532013000`." + char(10) +
		"- Non-matches: `1234`, `GB29 NWBK60161331926819`."
	],

	:swiftCode = [
		"Matches SWIFT/BIC codes",

		"- `^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$`: Matches 8 or 11-character alphanumeric strings with specific formats." + char(10) + char(10) +

		"- Matches: `DEUTDEFF`, `BOFAUS3NXXX`." + char(10) +
		"- Non-matches: `DEUT1234`, `BOFAUS`."
	],

	# Mathematic formulas

	:simpleEquation = [
		"Matches basic mathematical equations",

		"- `^[A-Za-z0-9\\+\\-\\*/=\\(\\)\\.\\^\\s]+$`: Allows letters, digits, operators, parentheses, decimal points, and spaces." + char(10) + char(10) +

		"- Matches: `x + y = 10`, `2 * (a + b) = 3`." + char(10) +
		"- Non-matches: `x = y & z`, `x ^ 2 == 10`."
	],

	:quadraticFormula = [
    		"Matches quadratic equations",

    		"- `^-?\\d*[A-Za-z]\\^2\\s*[+-]?\\s*\\d*[A-Za-z]\\s*[+-]?\\s*\\d+\\s*=\\s*0$`: Matches equations of the form `ax^2 + bx + c = 0`." + char(10) + char(10) +

    		"- Matches: `x^2 + 3x + 2 = 0`, `-5y^2 - y + 1 = 0`." + char(10) +
    		"- Non-matches: `x + y = 10`, `x^2 + y + 1`."
	],

	# DNA and Chemistry

	:dnaSequence = [
    		"Matches valid DNA sequences",

		"- `^[ACGT]+$`: Matches strings containing only the characters `A`, `C`, `G`, and `T`." + char(10) + char(10) +

		"- Matches: `ACGT`, `AGCTAGCT`." + char(10) +
		"- Non-matches: `ACGUX`, `ACG T`."
	],

	:chemicalFormula = [
		"Matches valid chemical formulas",

		"- `^[A-Z][a-z]?\\d*(?:[A-Z][a-z]?\\d*)*$`: Matches element symbols (capital letter with optional lowercase letter) followed by optional digits." + char(10) + char(10) +

		"- Matches: `H2O`, `C6H12O6`, `NaCl`." + char(10) +
		"- Non-matches: `H20O`, `123H`, `HO2C6`."
	],

	# Measurements

	:metricMeasurement = [
		"Matches metric system measurements",

		"- `^\\d+(\\.\\d+)?\\s?(mm|cm|m|km)$`: Matches numeric values with optional decimals followed by a metric unit." + char(10) + char(10) +

		"- Matches: `10 cm`, `2.5 km`, `3m`." + char(10) +
		"- Non-matches: `10in`, `2.5 cm km`."
	],

	:imperialMeasurement = [
		"Matches imperial system measurements",

		"- `^\\d+(\\.\\d+)?\\s?(in|ft|yd|mi)$`: Matches numeric values with optional decimals followed by an imperial unit." + char(10) + char(10) +

		"- Matches: `5 ft`, `12.3 in`, `0.5 mi`." + char(10) +
		"- Non-matches: `5cm`, `1 ft yd`."
	],

	:temperature = [
		"Matches temperature values",

		"- `^-?\\d+(\\.\\d+)?\\s?(°C|°F|K)$`: Matches numeric values with optional decimals and optional negative sign, followed by a temperature unit." + char(10) + char(10) +

		"- Matches: `25°C`, `-10.5°F`, `300K`." + char(10) +
		"- Non-matches: `25 degrees`, `10C`, `K300`."
	],

	# Barcodes, QR-codes and Alike

	:upc = [
		"Matches Universal Product Code (UPC) barcodes",

		"- `^\\d{12}$`: Matches exactly 12 digits." + char(10) + char(10) +

		"- Matches: `012345678905`, `123456789012`." + char(10) +
		"- Non-matches: `0123456789`, `0123456789012`, `1234-5678-9012`."
	],

	:ean13 = [
		"Matches European Article Number (EAN-13) barcodes",

		"- `^\\d{13}$`: Matches exactly 13 digits." + char(10) + char(10) +

		"- Matches: `4006381333931`, `1234567890128`." + char(10) +
		"- Non-matches: `123456789012`, `12345678901234`, `EAN4006381333931`."
	],

	:code128 = [
		"Matches Code 128 barcodes",

		"- `^[!-~]+$`: Matches one or more printable ASCII characters (33 to 126)." + char(10) + char(10) +

		"- Matches: `123ABC!@#$`, `HELLO-WORLD`, `Code128`." + char(10) +
		"- Non-matches: `123 ABC`, `Code_128` (contains a space or unsupported characters)."
	],

	:qrCodeData = [
		"Matches data strings typically stored in QR codes",

		"- `^[A-Za-z0-9\\-._~:/?#\\[\\]@!$&'()*+,;=%]*$`: Matches URL-safe characters, including alphanumerics and special characters." + char(10) + char(10) +

		"- Matches: `https://example.com`, `name=John&age=30`, `qr-code-12345`." + char(10) +
		"- Non-matches: `http://example.com/ example` (contains spaces)."
	],

	:isbn10 = [
		"Matches ISBN-10 identifiers",

		"- `^\\d{9}[\\dX]$`: Matches 9 digits followed by a digit or `X` (checksum)." + char(10) + char(10) +

		"- Matches: `0306406152`, `123456789X`." + char(10) +
		"- Non-matches: `123456789`, `030640615X2` (invalid length or checksum)."
	],

	:isbn13 = [
		"Matches ISBN-13 identifiers",

		"- `^978\\d{10}$`: Matches strings starting with `978` followed by 10 digits." + char(10) + char(10) +

		"- Matches: `9780306406157`, `9781234567897`." + char(10) +
		"- Non-matches: `1234567890123`, `0306406157` (does not start with `978` or incorrect length)."
	],


	# Semantic Versioning (major.minor.patch)

	:semVer = [
		"Matches Semantic Versioning (SemVer) format (major.minor.patch with optional pre-release and build metadata)",

		"- `^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?(?:\\+([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?$`:" + char(10) +
		"  - Matches major, minor, and patch versions." + char(10) +
		"  - Supports optional pre-release (`-alpha.1`, `-rc.2`) and build metadata (`+build123`)." + char(10) + char(10) +

		"- Matches: `1.0.0`, `2.1.3-alpha`, `3.2.1-rc.1+build456`." + char(10) +
		"- Non-matches: `v1.0`, `1.0.0.0` (invalid extra segments)."
	],

	:strictSemVer = [
		"Matches strict Semantic Versioning without pre-release or build metadata (major.minor.patch)",

		"- `^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)$`:" + char(10) +
		"  - Matches only the three required version segments." + char(10) +
		"  - Does not allow pre-release or build metadata." + char(10) + char(10) +

		"- Matches: `1.0.0`, `2.3.4`, `10.99.100`." + char(10) +
		"- Non-matches: `1.0.0-alpha`, `v1.0.0`."
	],

	:versionWithBuild = [
		"Matches version numbers with optional build metadata",

		"- `^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:\\+([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?$`:" + char(10) +
		"  - Matches three-part version numbers." + char(10) +
		"  - Allows build metadata prefixed by `+`." + char(10) + char(10) +

		"- Matches: `1.0.0+build123`, `2.5.6+exp.sha.5114f85`." + char(10) +
		"- Non-matches: `1.0.0-alpha`, `v1.2.3`."
	],

	:preReleaseVersion = [
		"Matches versions with pre-release identifiers",

		"- `^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)-([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*)$`:" + char(10) +
		"  - Matches three-part version numbers." + char(10) +
		"  - Requires a pre-release identifier (e.g., `-beta`, `-rc.1`)." + char(10) + char(10) +

		"- Matches: `1.2.3-alpha`, `4.5.6-beta.1`, `10.0.1-rc.2`." + char(10) +
		"- Non-matches: `1.2.3`, `1.2.3+build`."
	],

	:versionWithPrefix = [
		"Matches version numbers with an optional `v` prefix",

		"- `^v?(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)$`:" + char(10) +
		"  - Matches three-part version numbers." + char(10) +
		"  - Allows an optional `v` at the beginning (e.g., `v1.0.0`)." + char(10) + char(10) +

		"- Matches: `v1.0.0`, `1.2.3`, `v10.5.7`." + char(10) +
		"- Non-matches: `1.0`, `1.2.3-beta`."
	],

	:dateVersion = [
		"Matches date-based versioning (YYYY.MM.DD or YYYYMMDD)",

		"- `^(\\d{4})[.-]?(0[1-9]|1[0-2])[.-]?(0[1-9]|[12]\\d|3[01])$`:" + char(10) +
		"  - Matches year (4 digits), month (01-12), and day (01-31)." + char(10) +
		"  - Allows `.` or `-` as separators or no separator at all." + char(10) + char(10) +

		"- Matches: `2024.06.15`, `20240615`, `2024-12-01`." + char(10) +
		"- Non-matches: `2024.13.01` (invalid month), `20240632` (invalid day)."
	],

	:windowsVersion = [
		"Matches Windows-style version numbers (major.minor.build.revision)",

		"- `^(\\d+)\\.(\\d+)\\.(\\d+)\\.(\\d+)$`:" + char(10) +
		"  - Matches four-part version numbers." + char(10) +
		"  - Each segment is a numeric value." + char(10) + char(10) +

		"- Matches: `10.0.19041.572`, `6.1.7601.24540`." + char(10) +
		"- Non-matches: `10.0.19041`, `v10.0.0.1`."
	],

	:pythonVersion = [
		"Matches Python package versioning (PEP 440 format)",

		"- `^(\\d+)\\.(\\d+)\\.(\\d+)(?:[abrc]\\d+|\\.post\\d+|\\.dev\\d+)?$`:" + char(10) +
		"  - Matches three-part version numbers." + char(10) +
		"  - Allows pre-release (`a1`, `b2`, `rc3`), post-release (`.post1`), and development release (`.dev0`)." + char(10) + char(10) +

		"- Matches: `3.9.7`, `2.7.18rc1`, `1.2.3.post4`, `4.5.6.dev0`." + char(10) +
		"- Non-matches: `1.2`, `1.2.3-alpha` (wrong format for PEP 440)."
	],

	:mavenVersion = [
		"Matches Maven/Gradle-style versioning (with optional suffixes)",

		"- `^(\\d+)(?:\\.(\\d+))?(?:\\.(\\d+))?(?:-([A-Za-z0-9.-]+))?$`:" + char(10) +
		"  - Matches major, minor, and optional patch numbers." + char(10) +
		"  - Allows suffixes like `-SNAPSHOT`, `-RELEASE`, `-RC1`." + char(10) + char(10) +

		"- Matches: `1.0`, `2.3.4`, `3.0-SNAPSHOT`, `5.1.2-RELEASE`." + char(10) +
		"- Non-matches: `v1.2.3`, `1.2.3+build`."
	],

	# Common word-based regex patterns

	:quotedWord = [
		"Matches text enclosed in double quotes",

		"- `" + StzChar(34) + "`: Opening double quote character" + char(10) +
		"- `([^" + StzChar(34) + "]+)`: Captures one or more characters that are not double quotes" + char(10) +
		"- `" + StzChar(34) + "`: Closing double quote character" + char(10) + char(10) +

		"- Matches: `\" + StzChar(34) + "Hello World\" + StzChar(34) + "`, `\" + StzChar(34) + "Testing 123\" + StzChar(34) + "`" + char(10) +
		"- Non-matches: `Hello World` (no quotes), `\" + StzChar(34) + "Unclosed quote` (missing closing quote)"
	],

	:singleWord = [
		"Matches a single word containing only word characters",

		"- `^`: Start of string" + char(10) +
		"- `\\w+`: One or more word characters (letters, numbers, underscore)" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `Hello`, `Testing123`, `word_with_underscore`" + char(10) +
		"- Non-matches: `Hello World` (multiple words), `Special!` (special character)"
	],

	:multipleWords = [
		"Matches multiple words with spaces",

		"- `^`: Start of string" + char(10) +
		"- `[\\w\\s]+`: One or more word characters or whitespace" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `Hello World`, `This is a test`" + char(10) +
		"- Non-matches: `Hello,World` (comma), `Special!Chars` (special characters)"
	],

	:camelCaseWord = [
		"Matches camelCase formatted words",

		"- `^`: Start of string" + char(10) +
		"- `[a-z]+`: One or more lowercase letters at start" + char(10) +
		"- `([A-Z][a-z]*)*`: Zero or more sequences of uppercase followed by lowercase" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `camelCase`, `thisIsATest`" + char(10) +
		"- Non-matches: `CamelCase` (starts uppercase), `not_camel_case` (underscore)"
	],

	:snakeCaseWord = [
		"Matches snake_case formatted words",

		"- `^`: Start of string" + char(10) +
		"- `[a-z]+`: One or more lowercase letters" + char(10) +
		"- `(_[a-z]+)*`: Zero or more sequences of underscore and lowercase letters" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `snake_case`, `this_is_snake`" + char(10) +
		"- Non-matches: `Snake_Case` (uppercase), `not-snake` (hyphen)"
	],

	:pascalCaseWord = [
		"Matches PascalCase formatted words",

		"- `^`: Start of string" + char(10) +
		"- `[A-Z]`: First uppercase letter" + char(10) +
		"- `[a-z]+`: One or more lowercase letters" + char(10) +
		"- `([A-Z][a-z]*)*`: Zero or more sequences of uppercase followed by lowercase" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `PascalCase`, `ThisIsPascal`" + char(10) +
		"- Non-matches: `pascalCase` (starts lowercase), `This_Is_Not_Pascal` (underscores)"
	],

	:kebabCaseWord = [
		"Matches kebab-case formatted words",

		"- `^`: Start of string" + char(10) +
		"- `[a-z]+`: One or more lowercase letters" + char(10) +
		"- `(-[a-z]+)*`: Zero or more sequences of hyphen and lowercase letters" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `kebab-case`, `this-is-kebab`" + char(10) +
		"- Non-matches: `Kebab-Case` (uppercase), `this_is_not_kebab` (underscores)"
	],

	# RTL and Language Support

	:arabicChar = [
		"Matches a single Arabic character",

		"- `^`: Start of string" + char(10) +
		"- `[\\u0600-\\u06FF]`: Single character in Arabic Unicode range" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `ا`, `ب`, `ت`" + char(10) +
		"- Non-matches: `اب` (multiple characters), `a` (non-Arabic)"
	],

	:arabicWord = [
		"Matches a word composed of Arabic characters",

		"- `^`: Start of string" + char(10) +
		"- `[\\u0600-\\u06FF]+`: One or more Arabic characters" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `مرحبا`, `عالم`" + char(10) +
		"- Non-matches: `hello`, `مرحبا123` (mixed with numbers)"
	],

	:rtlSentence = [
		"Matches right-to-left text (Hebrew or Arabic) with spaces",

		"- `^`: Start of string" + char(10) +
		"- `[\\u0590-\\u05FF\\u0600-\\u06FF\\s]+`: Hebrew/Arabic characters and spaces" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `مرحبا بالعالم`, `שלום עולם`" + char(10) +
		"- Non-matches: `Hello World`, `مرحبا123` (mixed with numbers)"
	],

	:russianWord = [
		"Matches words in Cyrillic characters",

		"- `^`: Start of string" + char(10) +
		"- `[\\u0400-\\u04FF]+`: One or more Cyrillic characters" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `привет`, `мир`" + char(10) +
		"- Non-matches: `hello`, `привет123` (mixed with numbers)"
	],

	:chineseChar = [
		"Matches Chinese characters",

		"- `^`: Start of string" + char(10) +
		"- `[\\u4E00-\\u9FFF]+`: One or more Chinese characters" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `你好`, `世界`" + char(10) +
		"- Non-matches: `hello`, `你好123` (mixed with numbers)"
	],

	:nonLatinWord = [
		"Matches words not containing Latin alphabet",

		"- `^`: Start of string" + char(10) +
		"- `[^a-zA-Z]+`: One or more non-Latin characters" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `数字`, `١٢٣`, `привет`" + char(10) +
		"- Non-matches: `hello`, `数字abc` (contains Latin)"
	],

	# Number detection in different numeral systems

	:arabicNumerals = [
		"Matches Arabic numerals",

		"- `^`: Start of string" + char(10) +
		"- `[\\u0660-\\u0669]+`: One or more Arabic numeral characters" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `٠١٢٣`, `٤٥٦`" + char(10) +
		"- Non-matches: `123`, `٠١a` (mixed with letters)"
	],

	:devanagariNumerals = [
		"Matches Devanagari numerals",

		"- `^`: Start of string" + char(10) +
		"- `[\\u0966-\\u096F]+`: One or more Devanagari numeral characters" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `०१२`, `३४५`" + char(10) +
		"- Non-matches: `123`, `०१a` (mixed with letters)"
	],

	:easternArabicNumerals = [
		"Matches Eastern Arabic numerals",

		"- `^`: Start of string" + char(10) +
		"- `[\\u06F0-\\u06F9]+`: One or more Eastern Arabic numeral characters" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `۰۱۲`, `۳۴۵`" + char(10) +
		"- Non-matches: `123`, `۰۱a` (mixed with letters)"
	],

	:universalNumber = [
		"Matches numbers in various numeral systems",

		"- `^`: Start of string" + char(10) +
		"- `[0-9\\u0660-\\u0669\\u06F0-\\u06F9\\u0966-\\u096F]+`: Digits from various systems" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `123`, `٠١٢`, `۰۱۲`, `०१२`" + char(10) +
		"- Non-matches: `12a`, `١٢٣a` (mixed with letters)"
	],

	# Punctuation variations

	:punctuationMarks = [
		"Matches standard punctuation marks",

		"- `^`: Start of string" + char(10) +
		"- `[.,!?;:'\" + StzChar(34) + "\" + StzChar(34) + "\" + StzChar(34) + "\\(\\)\\[\\]\\{\\}]+`: One or more punctuation characters" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `...`, `!!!`, `?!.`" + char(10) +
		"- Non-matches: `hello.` (contains letters), `123!` (contains numbers)"
	],

	# Password Complexity Patterns

	:passwordWeak = [
		"Matches passwords that are at least 6 characters long with no complexity requirements",

		"- `^`: Start of string" + char(10) +
		"- `.{6,}`: Any character, minimum 6 occurrences" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `abcdef`, `123456`, `password`" + char(10) +
		"- Non-matches: `abc` (too short)"
	],

	:passwordSimple = [
		"Matches passwords with minimum length requirement",

		"- `^`: Start of string" + char(10) +
		"- `.{8,}`: Any character, minimum 8 occurrences" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `password123`, `simplepass`" + char(10) +
		"- Non-matches: `short` (too short), `pass` (too short)"
	],

	:passwordWithDigits = [
		"Matches passwords containing at least one digit",

		"- `^`: Start of string" + char(10) +
		"- `(?=.*[0-9])`: Positive lookahead for at least one digit" + char(10) +
		"- `.{8,}`: Any character, minimum 8 occurrences" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `password123`, `my2ndpass`" + char(10) +
		"- Non-matches: `password` (no digits), `pass1` (too short)"
	],

	:passwordWithUpperLower = [
		"Matches passwords with upper and lowercase letters",

		"- `^`: Start of string" + char(10) +
		"- `(?=.*[a-z])`: Positive lookahead for lowercase" + char(10) +
		"- `(?=.*[A-Z])`: Positive lookahead for uppercase" + char(10) +
		"- `.{8,}`: Any character, minimum 8 occurrences" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `Password123`, `TestPass`" + char(10) +
		"- Non-matches: `password` (no uppercase), `Pass` (too short)"
	],

	:passwordWithSpecialChar = [
		"Matches passwords containing special characters",

		"- `^`: Start of string" + char(10) +
		"- `(?=.*[!@#$%^&*(),.?\" + StzChar(34) + ":{}|<>])`: Positive lookahead for special char" + char(10) +
		"- `.{8,}`: Any character, minimum 8 occurrences" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `Pass@word123`, `Test!Pass`" + char(10) +
		"- Non-matches: `password` (no special char), `Pass!` (too short)"
	],

	:passwordStrong = [
		"Matches strong passwords with multiple requirements",

		"- `^`: Start of string" + char(10) +
		"- `(?=.*[a-z])`: Positive lookahead for lowercase" + char(10) +
		"- `(?=.*[A-Z])`: Positive lookahead for uppercase" + char(10) +
		"- `(?=.*[0-9])`: Positive lookahead for digit" + char(10) +
		"- `(?=.*[!@#$%^&*(),.?\" + StzChar(34) + ":{}|<>])`: Positive lookahead for special char" + char(10) +
		"- `.{12,}`: Any character, minimum 12 occurrences" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `StrongP@ss123`, `C0mpl3x!Pass`" + char(10) +
		"- Non-matches: `Weak!pass` (too short), `Password123` (no special char)"
	],

	# API Keys and Secrets Detection

	:hexSecret = [
		"Matches hexadecimal secret keys",

		"- `^`: Start of string" + char(10) +
		"- `[a-fA-F0-9]{32,}`: 32 or more hexadecimal characters" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `1a2b3c4d5e6f7890abcdef1234567890`" + char(10) +
		"- Non-matches: `123abc` (too short), `12345g` (invalid hex char)"
	],

	:base64Secret = [
		"Matches Base64 encoded strings",

		"- `^`: Start of string" + char(10) +
		"- `(?:[A-Za-z0-9+/]{4})*`: Groups of four Base64 characters" + char(10) +
		"- `(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?`: Optional padding" + char(10) +
		"- `$`: End of string" + char(10) + char(10) +

		"- Matches: `SGVsbG8gV29ybGQ=`, `dGVzdA==`" + char(10) +
		"- Non-matches: `Hello World`, `===invalid===`"
	],

	:jwtToken = [
		"Matches JWT tokens (JSON Web Tokens)",

		"- `^`: Start of string" + char(10) +
		"- `[A-Za-z0-9-_]+\\.`: Base64-encoded header ending with a dot" + char(10) +
		"- `[A-Za-z0-9-_]+\\.`: Base64-encoded payload ending with a dot" + char(10) +
		"- `[A-Za-z0-9-_]+$`: Base64-encoded signature" + char(10) + char(10) +

		"- Matches: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c`" + char(10) +
		"- Non-matches: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ-INVALID` (invalid signature format)"
	],

	:awsAccessKey = [
		"Matches AWS access keys",

		"- `^`: Start of string" + char(10) +
		"- `AKIA`: AWS access key prefix" + char(10) +
		"- `[0-9A-Z]{16}$`: 16 uppercase alphanumeric characters" + char(10) + char(10) +

		"- Matches: `AKIAIOSFODNN7EXAMPLE`" + char(10) +
		"- Non-matches: `BKIAIOSFODNN7EXAMPLE` (wrong prefix), `AKIA123` (too short)"
	],

	:awsSecretKey = [
		"Matches AWS secret keys",

		"- `^`: Start of string" + char(10) +
		"- `[0-9a-zA-Z/+]{40}$`: 40 characters including letters, digits, `/`, `+`" + char(10) + char(10) +

		"- Matches: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`" + char(10) +
		"- Non-matches: `shortkey123` (too short), `invalid_key_with_!@#` (invalid characters)"
	],

	:privateKeyPEM = [
		"Matches PEM formatted private keys",

		"- `-----BEGIN (RSA|EC|DSA|PRIVATE) KEY-----`: Header indicating key type" + char(10) +
		"- `[\\s\\S]+`: Any characters (multiline support)" + char(10) +
		"- `-----END (RSA|EC|DSA|PRIVATE) KEY-----`: Footer marking key end" + char(10) + char(10) +

		"- Matches: `-----BEGIN RSA KEY-----\nMIIEpAIBAAKCAQEA...\n-----END RSA KEY-----`" + char(10) +
		"- Non-matches: `-----BEGIN SOME RANDOM DATA-----\n...\n-----END SOME RANDOM DATA-----` (incorrect header/footer)"
	],

	# Personally Identifiable Information (PII)

	:ssnUSA = [
		"Matches US Social Security Numbers (SSN)",

		"- `^`: Start of string" + char(10) +
		"- `\\d{3}-\\d{2}-\\d{4}$`: Three digits, hyphen, two digits, hyphen, four digits" + char(10) + char(10) +

		"- Matches: `123-45-6789`" + char(10) +
		"- Non-matches: `123456789` (missing hyphens), `12-345-6789` (wrong format)"
	],

	:passportNumber = [
		"Matches passport numbers",

		"- `^`: Start of string" + char(10) +
		"- `[A-Z0-9]{6,9}$`: 6 to 9 alphanumeric uppercase characters" + char(10) + char(10) +

		"- Matches: `A1234567`, `123456789`" + char(10) +
		"- Non-matches: `12345` (too short), `ABCD123456` (too long)"
	],

	# Other Sensitive Data

	:hexadecimalEntropy = [
		"Matches long hexadecimal strings (potential entropy keys)",

		"- `^`: Start of string" + char(10) +
		"- `[0-9a-fA-F]{64,}$`: At least 64 hexadecimal characters" + char(10) + char(10) +

		"- Matches: `a3f9c...3e0a` (64+ hex chars)" + char(10) +
		"- Non-matches: `a3f9c` (too short), `GHIJKL1234` (invalid hex characters)"
	],

	:uuid = [
		"Matches UUIDs (Universally Unique Identifiers)",

		"- `^`: Start of string" + char(10) +
		"- `[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$`: Standard UUID format" + char(10) + char(10) +

		"- Matches: `550e8400-e29b-41d4-a716-446655440000`" + char(10) +
		"- Non-matches: `550e8400e29b41d4a716446655440000` (missing hyphens), `550e8400-e29b-61d4-a716-446655440000` (invalid variant)"
	],

	:bcryptHash = [
		"Matches bcrypt password hashes",

		"- `^\\$2[ayb]\\$\\d{2}\\$`: Bcrypt format identifier and cost factor" + char(10) +
		"- `[./A-Za-z0-9]{53}$`: 53 base64-like encoded characters" + char(10) + char(10) +

		"- Matches: `$2b$12$Qe4VhXyQtk2Hl3m.r3lVze1aeXZ9c7G5YpTmHDHkJxXO/hP9mB0s.`" + char(10) +
		"- Non-matches: `$2x$12$Qe4VhXyQtk2Hl3m.r3lVze1aeXZ9c7G5YpTmHDHkJxXO/hP9mB0s.` (invalid type), `$2b$12$short` (too short)"
	]
]

#-----------------------------------#
#  UTILITY FUNCTION FOR REGEX DATA  #
#-----------------------------------#

func RegexPatterns()
	return _$aRegexPatterns_

func RegexPatternsExplanations()
	return _$aRegexPatternsExplanations_

func RegexPatternName(cPatt)

	if CheckParams()
		if NOT isString(cPatt)
			StzRaise("Incorrect param type! cPatt must be a string.")
		ok
	ok

	_cResult_ = ""

	_aPatterns_ = RegexPatterns()

	_nLen_ = len(_aPatterns_)

	for @i = 1 to _nLen_
		if _aPatterns_[@i][2] = cPatt
			_cResult_ = _aPatterns_[@i][1]
			exit
		ok
	next

	return _cResult_


func RegexPatternExplanation(cName)

	if CheckParams()
		if NOT isString(cName)
			StzRaise("Incorrect param type! cName must be a string.")
		ok
	ok

	_cResult_ = RegexPatternsExplanations()[cName]
	if _cResult_ = ""
		StzRaise("Can't find an explanation for the pattern of the provided name.")
	ok

	
	return _cResult_
