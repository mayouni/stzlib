
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

	:fileName = "^[^<>:\" + char(34) + "/\\|?*\r\n]+$",
	:filePath = "^(?:[a-zA-Z]:)?(?:\\\\[^<>:\" + char(34) + "/\\|?*\r\n]+)+\\\\?$",
	:unixFilePath = "^(/[^<>:\" + char(34) + "/\\|?*\r\n]+)+/?$",
	:fileExtension = "\\.[a-zA-Z0-9]+$",
	:relativeFilePath = "^(?:\\.\\.?/|[^/<>:\" + char(34) + "|?*]+)(?:/[^/<>:\" + char(34) + "|?*]+)*/?$",

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
	:dateISO8601 = "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(?:Z|([+-])\\d{2}:\\d{2})?$",

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
	:yamlValue = "^(\ " + char(34) + "[^\ " + char(34) + "]*\ " + char(34) + ")|([0-9]+)|(true|false)|null$",
	:yamlMap = "^[a-zA-Z0-9]+:[ ]*.+$",
	:yamlArray = "^-?[0-9]+$|\ " + char(34) + "[^\ " + char(34) + "]*\ " + char(34) + "$",
	:yamlFrontMatter = "^---\\s*\\n(.*?)\\n---$",

	# HTML

	:htmlComment = "<!--[\s\S]*?-->",
	:htmlDoctype = "<!DOCTYPE[^>]*>",
	:htmlOpenTag = "<([a-zA-Z][a-zA-Z0-9]*)((?:\s+[a-zA-Z][a-zA-Z0-9]*(?:\s*=\s*(?:\" + char(34) + ".*?\" + char(34) + "|'.*?'|[^'\" + char(34) + "<>\\s]+))?)*)\s*/?>",
	:htmlCloseTag = "</([a-zA-Z][a-zA-Z0-9]*)>",
	:htmlAttribute = "(?:\s+[a-zA-Z][a-zA-Z0-9]*(?:\s*=\s*(?:\" + char(34) + ".*?\" + char(34) + "|'.*?'|[^'\" + char(34) + "<>\\s]+))?)",
	:htmlClass = "(?:\\s+class\\s*=\\s*(?:\" + char(34) + "[^\" + char(34) + "]*\" + char(34) + "|'[^']*'|[^'\" + char(34) + "\\s>]+))",
	:htmlId = "(?:\\s+id\\s*=\\s*(?:\" + char(34) + "[^\" + char(34) + "]*\" + char(34) + "|'[^']*'|[^'\" + char(34) + "\\s>]+))",   
	:html5Color = "^#[A-Fa-f0-9]{3,6}$",

	# CSS Patterns

	:idSelector = "^#([a-zA-Z_][a-zA-Z\\d_-]*)$",
	:classSelector = "^\\.([a-zA-Z_][a-zA-Z\\d_-]*)$",
	:attributeSelector = "\\[\\s*([a-zA-Z][a-zA-Z0-9-]*)\\s*(?:([*^$|!~]?=)\\s*(?:\ " + char(34) + "[^\ " + char(34) + "]*\ " + char(34) + "|'[^']*'|[^'\ " + char(34) + "\\s>]+))?\\s*\\]",
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

	:numbersInList = '\b(["' + char(39) + ']?)(-?\d+(?:\.\d+)?)(\1)\b',

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

   	:jsonObject = "\\{(?:\\s*\ " + char(34) + "[a-zA-Z0-9_]+\ " + char(34) + "\\s*:\\s*(?:\ " + char(34) + "[^\ " + char(34) + "]*\ " + char(34) + "|'[^']*'|\\d+|true|false|null|\\{.*?\\}|\\[.*?\\]))*\\s*\\}",
   	:jsonArray = "^\[(?:\s*[^,]+,?\s*)*\]$",
   	:jsonKeyValuePair = "\ " + char(34) + "[a-zA-Z0-9_]+\ " + char(34) + "\\s*:\\s*(?:\ " + char(34) + "[^\ " + char(34) + "]*\ " + char(34) + "|'[^']*'|\\d+|true|false|null|\\{.*?\\}|\\[.*?\\])",
	:geoJSON = "^\\{\\s*\ " + char(34) + "type\ " + char(34) + "\\s*:\\s*\ " + char(34) + "FeatureCollection\ " + char(34) + "\\s*,\\s*\ " + char(34) + "features\ " + char(34) + "\\s*:\\s*\\[.*?\\]\\s*\\}$ + |'.*?'|[^'\ + char(34) + <>\\s]+))?)*)\s*/?>",

   	# CSV Patterns

   	:csvHeaderRow = "^([^,]*,)*[^,]*$",
   	:csvQuotedField = "\ " + char(34) + "[^\ " + char(34) + "]*\ " + char(34),
   	:csvUnquotedField = "[^,\r\n]*",
   	:csvDelimiter = ",",
   	:csvRowEnding = "\r?",
   	:csvEscapedQuote = "\ " + char(34) + "\ " + char(34),
	:csvLine = "^(?:(?:\ " + char(34) + "[^\ " + char(34) + "]*\ " + char(34) + ")|(?:[^,\ " + char(34) + "]+))(?:,(?:(?:\ " + char(34) + "[^\ " + char(34) + "]*\ " + char(34) + ")|(?:[^,\ " + char(34) + "]+)))*$",

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

   	:sqlInjection = "(?:[\ " + char(34) + "'`;]+.*?)+",
   	:xssInjection = "<[a-zA-Z][a-zA-Z0-9]*[^>]*>.*?</[a-zA-Z][a-zA-Z0-9]*>",
   	:emailInjection = ".*[\n\r]+.+@[a-z0-9]+[.][a-z]{2,}.*",
   	:htmlInjection = "<[^>]*?[^<]*[a-zA-Z0-9]+.*[^<]*?>",

	# Ring Language Patterns

	:ringString = "^(?:[" + char(34) + "'].*?[" + char(34) + "']|\[.*?\]|`.*?`)$",
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
	
	:ringSee = "^(?i)See\s+[" + char(34) + "'].*?[" + char(34) + "']|See\s+\w+$",
	:ringGive = "^(?i)Give\s+\w+$",
	:ringLoad = "^(?i)Load\s+[" + char(34) + "'].*?[" + char(34) + "']$",
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
	
	:pythonString = "^(?:[" + char(34) + "]{3}.*?[" + char(34) + "]{3}|[" + char(34) + "].*?[" + char(34) + "]|'''.*?'''|'.*?')$",
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
	:pythonDocstring = "^[" + char(34) + "]{3}[\s\S]*?[" + char(34) + "]{3}$",
	
	:pythonImport = "^(?:import|from)\s+[\w.]+(?:\s+import\s+(?:\w+(?:\s+as\s+\w+)?(?:\s*,\s*\w+(?:\s+as\s+\w+)?)*|\*))?\s*$",
	
	# JavaScript Language Patterns
	
	:jsString = "^(?:[" + char(34) + "].*?[" + char(34) + "]|'.*?'|`[\s\S]*?`)$",
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
	
	:jsImport = "^import\s+(?:{[^}]*}|\*\s+as\s+\w+|\w+)\s+from\s+[" + char(34) + "'].*?[" + char(34) + "']$",
	:jsExport = "^export\s+(?:default\s+)?(?:class|function|const|let|var)\s+.*$",
	
	# Visual Basic Language Patterns
	
	:vbString = "^[" + char(34) + "].*?[" + char(34) + "]$",
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

	:juliaString = "^(?:[" + char(34) + "]{3}.*?[" + char(34) + "]{3}|[" + char(34) + "].*?[" + char(34) + "]|r[" + char(34) + "].*?[" + char(34) + "]|raw[" + char(34) + "].*?[" + char(34) + "])$",
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
	:juliaDocString = "^[" + char(34) + "]{3}[\\s\\S]*?[" + char(34) + "]{3}$",
    
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
	:xlsStringLiteral = "^\" + char(34) + ".*\" + char(34) + "$",
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
	:rStringVector = "^c\\((\\s*\" + char(34) + ".*?\" + char(34) + "\\s*(,\\s*\" + char(34) + ".*?\" + char(34) + "\\s*)*)?\\)$",
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
    
	:quotedWord = char(34) + "([^" + char(34) + "]+)" + char(34),
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

	:punctuationMarks = "^[.,!?;:'\" + char(34) + "”“\(\)\[\]\{\}]+$",

	# Password Complexity Patterns

	:passworWeak = "^.{6,}$",
	:passwordSimple = "^.{8,}$",
	:passwordWithDigits = "^(?=.*[0-9]).{8,}$",
	:passwordWithUpperLower = "^(?=.*[a-z])(?=.*[A-Z]).{8,}$",
	:passwordWithSpecialChar = "^(?=.*[!@#$%^&*(),.?\" + char(34) + ":{}|<>]).{8,}$",
	:passwordStrong = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?\" + char(34) + ":{}|<>]).{12,}$",

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

		"- `^`: Start of string" + NL +
		"- `([^\\d]*)`: First group: any sequence of non-digit characters" + NL +
		"- `(\\d+)`: Second group: one or more digits" + NL +

		"- `$`: End of string" + NL + NL +
		"- Matches: `#1` → [`#`, `1`], `day3` → [`day`, `3`]" + NL +
		"- Non-matches: `123test`, `test`"
	],

	:numberWithTextSuffix = [
		"Splits string into numeric prefix and non-numeric suffix",

		"- `^`: Start of string" + NL +
		"- `(\\d+)`: First group: one or more digits" + NL +
		"- `([^\\d]*)`: Second group: any sequence of non-digit characters" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `123abc` → [`123`, `abc`], `5px` → [`5`, `px`]" + NL +
		"- Non-matches: `abc123`, `abc`"
	],

	:textNumberText = [
		"Splits string into prefix, number, and suffix",

		"- `^`: Start of string" + NL +
		"- `([^\\d]*)`: First group: any sequence of non-digit characters" + NL +
		"- `(\\d+)`: Second group: one or more digits" + NL +
		"- `([^\\d]*)`: Third group: any sequence of non-digit characters" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `page5of10` → [`page`, `5`, `of10`]" + NL +
		"- Non-matches: `page`, `123`"
	],

	:alternatingTextNumber = [
		"Matches strings with alternating text and number segments",

		"- `^`: Start of string" + NL +
		"- `([^\\d]+\\d+)+`: One or more occurrences of text followed by numbers" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `ab12cd34`, `test99more55`" + NL +
		"- Non-matches: `123abc`, `test`"
	],

	:spaceSeparatedWords = [
		"Matches space-separated words",

		"- `^`: Start of string" + NL +
		"- `(\\S+)`: First group: one or more non-whitespace characters" + NL +
		"- `(?:\\s+\\S+)*`: Zero or more occurrences of space(s) and word" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `hello world`, `one two three`" + NL +
		"- Non-matches: `hello\nworld` (contains newline)"
	],

	# Adress patterns

	:addressLine = [
		"Matches a single line of an address",

		"- `^[a-zA-Z0-9.,'’\\-\\s]+$`: Matches alphanumeric characters, common punctuation (`.,'’`), and whitespace." + NL + NL +

		"- Matches: `123 Main St.`, `Apartment 42-B`, `Building A`." + NL +
		"- Non-matches: `123<>|*` (invalid characters)."
	],

	:cityName = [
		"Matches city names",

		"- `^[a-zA-Z\\s\\-']+$`: Matches alphabetic characters, spaces, hyphens, and apostrophes." + NL + NL +

		"- Matches: `San Francisco`, `O'Connor`, `New-York`." + NL +
		"- Non-matches: `123 City` (numbers not allowed)."
	],

	:stateProvinceRegion = [
		"Matches states, provinces, or regions",

		"- `^[a-zA-Z\\s\\-']+$`: Matches alphabetic characters, spaces, hyphens, and apostrophes." + NL + NL +

		"- Matches: `California`, `Baden-Württemberg`, `Québec`." + NL +
		"- Non-matches: `CA123` (numbers not allowed)."
	],

	:postalCode = [
		"Matches postal or ZIP codes",

		"- `^[a-zA-Z0-9\\-\\s]{3,10}$`: Matches alphanumeric characters, hyphens, and spaces, between 3 to 10 characters." + NL + NL +

		"- Matches: `12345`, `W1A 1AA`, `75008`, `123-456`." + NL +
		"- Non-matches: `12` (too short), `12345678910` (too long)."
	],

	:countryName = [
		"Matches country names",

		"- `^[a-zA-Z\\s\\-]+$`: Matches alphabetic characters, spaces, and hyphens." + NL + NL +

		"- Matches: `United States`, `Côte d'Ivoire`, `South-Africa`." + NL +
		"- Non-matches: `123Country` (numbers not allowed)."
	],

	:fullAddress = [
		"Matches a full international address with multiple lines",

		"- `^([a-zA-Z0-9.,'’\\-\\s]+)(\\n[a-zA-Z0-9.,'’\\-\\s]+)*`: Matches one or more address lines." + NL +
		"- `\\n([a-zA-Z\\s\\-']+)`: Matches the city name on a new line." + NL +
		"- `\\n([a-zA-Z\\s\\-']+)`: Matches the state/province/region on another new line." + NL +
		"- `\\n([a-zA-Z0-9\\-\\s]{3,10})`: Matches the postal/ZIP code on a new line." + NL +
		"- `\\n([a-zA-Z\\s\\-]+)$`: Matches the country name on the final line." + NL + NL +

		"- Matches: `123 Main St.\\nApartment 42-B\\nSan Francisco\\nCalifornia\\n94105\\nUnited States`." + NL +
		"- Non-matches: `123 Main St., San Francisco, CA 94105, United States` (not separated into lines)."
	],

	# Patterns to Analyze Regex patterns!

	:rxGroup = [
		"Matches regex groups, including nested ones",

		"- `\\(`: Match the opening parenthesis" + NL +
    		"- `\\)`: Match the closing parenthesis" + NL + NL +

		"- Matches: `(abc)`, `((a)(b))`" + NL +
		"- Non-matches: `abc`, `(abc`"
	],

	:rxQuantifier = [
		"Detects quantifiers used in regex patterns",

		"- `\\*`: Match zero or more quantifiers" + NL +
		"- `\\+`: Match one or more quantifiers" + NL +
		"- `\\?`: Match zero or one quantifiers" + NL +
		"- `\\{\\d+(,\\d*)?\\}`: Match numeric quantifiers like `{1,3}`" + NL + NL +

		"- Matches: `a*`, `a+`, `a{2,5}`" + NL +
		"- Non-matches: `a`, `{}`"
	],

	:rxCharacterClass = [
		"Identifies character classes, including negated ones",

		"- `\\[`: Match the opening bracket" + NL +
		"- `(\\^?[^\]]+)`: Match optional `^` for negation, then all characters until `]`" + NL +
		"- `\\]`: Match the closing bracket" + NL + NL +

		"- Matches: `[abc]`, `[^0-9]`" + NL +
		"- Non-matches: `[`, `[abc`"
	],

	:rxAssertion = [
		"Detects lookahead and lookbehind assertions",

		"- `\\(\\?`: Match opening `(?`" + NL +
		"- `<?[=!]`: Match `=` or `!` for lookahead, or `<=`/`<!` for lookbehind" + NL + NL +

		"- Matches: `(?=abc)`, `(?<=abc)`" + NL +
		"- Non-matches: `abc`, `()`"
	],

	:rxEscapedChar = [
		"Finds escaped characters in regex patterns",

		"- `\\\\`: Match the escape character `\\`" + NL +
		"- `.`: Match any character following the escape" + NL + NL +

		"- Matches: `\\n`, `\\t`, `\\[`, `\\\\`" + NL +
		"- Non-matches: `n`, `[`, `\\\\` (if unescaped)"
	],

	:rxAlternation = [
		"Detects alternation (`|`) in patterns",

		"- `(\\|)`: Match the `|` symbol used for alternation" + NL + NL +

		"- Matches: `a|b`, `(a|b|c)`" + NL +
		"- Non-matches: `a b`, `(abc)`"
	],

	:rxWildcard = [
		"Finds wildcard characters in regex patterns",

		"- `\\.`: Match the `.` character that represents any character" + NL + NL +

		"- Matches: `a.b`, `.*`" + NL +
		"- Non-matches: `a b`, `abc`"
	],

	:rxRedundantAlternation = [
		"Detects redundant alternations that can be replaced by character classes",

		"- `\\(`: Match the opening parenthesis" + NL +
		"- `(?:[a-zA-Z0-9]\\|?)+`: Match multiple alternations of single characters" + NL +
		"- `\\)`: Match the closing parenthesis" + NL + NL +

		"- Matches: `(a|b|c)`, `(1|2|3)`" + NL +
		"- Non-matches: `[abc]`, `1|23`"
	],

	# Files names and paths

	:fileName = [
		"Matches valid file names",

		"- `^[^<>:\" + char(34) + "/\\|?*\r\n]+$`: Matches any string that does not contain invalid file name characters." + NL + NL +

		"- Matches: `document.txt`, `image123.png`, `file_name.ext`." + NL +
		"- Non-matches: `file/name.txt`, `file|name.ext`, `file:name`."
	],

	:filePath = [
		"Matches valid Windows file paths",

		"- `^(?:[a-zA-Z]:)?`: Optionally matches a drive letter followed by a colon (e.g., `C:`)." + NL +
		"- `(?:\\\\[^<>:\" + char(34) + "/\\|?*\r\n]+)+`: Matches one or more folder or file names separated by backslashes." + NL +
		"- `\\\\?$`: Allows an optional trailing backslash." + NL + NL +

		"- Matches: `C:\\Users\\Documents\\file.txt`, `\\folder\\subfolder\\file.ext`." + NL +
		"- Non-matches: `C:/Users/Documents/file.txt`, `/folder/subfolder/file.ext`."
	],

	:unixFilePath = [
		"Matches valid Unix/Linux file paths",

		"- `^/`: Matches a leading forward slash for absolute paths." + NL +
		"- `(/[^<>:\" + char(34) + "/\\|?*\r\n]+)+`: Matches one or more folder or file names separated by forward slashes." + NL +
		"- `/?$`: Allows an optional trailing forward slash." + NL + NL +

		"- Matches: `/home/user/document.txt`, `/var/log/`, `/file`." + NL +
		"- Non-matches: `C:\\Users\\Documents\\file.txt`, `folder/file.txt`."
	],

	:fileExtension = [
		"Matches file extensions",

		"- `\\.[a-zA-Z0-9]+$`: Matches a dot followed by one or more alphanumeric characters." + NL + NL +

		"- Matches: `.txt`, `.png`, `.zip`." + NL +
		"- Non-matches: `filetxt`, `.`, `..ext`."
	],

	:relativeFilePath = [
		"Matches valid relative file paths",

		"- `^(?:\\.\\.?/|[^/<>:\" + char(34) + "|?*]+)`: Matches a dot (`.`) or dot-dot (`..`) for relative paths or a valid folder name." + NL +
		"- `(?:/[^/<>:\" + char(34) + "|?*]+)*`: Matches additional folder or file names separated by slashes." + NL +
		"- `/?$`: Allows an optional trailing slash." + NL + NL +

		"- Matches: `./file.txt`, `../folder/file.txt`, `folder/subfolder/file`." + NL +
		"- Non-matches: `/absolute/path/file.txt`, `C:\\folder\\file.txt`."
	],

	# Web & Email

	:email = [
		"Matches standard email formats",
	
		"- `^` and `$`: Start and end of the string" + NL +
		"- `[a-zA-Z0-9._%+-]+`: Local part allowing letters, numbers, and common special characters" + NL +
		"- `@`: Required @ symbol" + NL +
		"- `[a-zA-Z0-9.-]+`: Domain name allowing letters, numbers, dots, and hyphens" + NL +
		"- `\.[a-zA-Z]{2,}`: Last part of the domain (TLD) with minimum 2 letters" + NL + NL +

		"- Matches: `user@domain.com`, `user.name+tag@example.co.uk`" + NL +
		"- Non-matches: `@domain.com`, `user@.com`, `user@domain`"
	
	],

	:url = [
		"Matches a standard HTTP or HTTPS URL",
	
		"- `^https?:\/\/`: Start with `http://` or `https://`" + NL +
		"- `(?:[a-zA-Z0-9-]+\.)+`: Domain part (subdomains are optional)" + NL +
		"- `[a-zA-Z]{2,}`: Domain TLD (top-level domain), at least two letters" + NL +
		"- `(\/[\w\-._~:/?#[\]@!$&'()*+,;=]*)?$`: Optional path, query, or fragment" + NL + NL +

		"- Matches: `https://example.com`, `http://domain.co.uk/path?query`" + NL +
		"- Non-matches: `htt://example.com`, `://domain.com`"
	],

	:domain = [
		"Matches domain names with letters, numbers, and hyphens",
	
		"- `^[a-zA-Z0-9]`: Domain must start with a letter or number" + NL +
		"- `[a-zA-Z0-9-]{1,61}`: Allowed characters include letters, numbers, and hyphens, between 1 and 61" + NL +
		"- `[a-zA-Z0-9]`: Domain ends with a letter or number" + NL +
		"- `\.[a-zA-Z]{2,}$`: Domain ends with a valid TLD" + NL + NL +

		"- Matches: `domain.com`, `subdomain.domain.org`" + NL +
		"- Non-matches: `-domain.com`, `domain..com`"
	],

	:ipv4 = [
		"Matches valid IPv4 addresses",
	
		"- `^`: Start of string" + NL +
		"- `(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)`: Match numbers 0-255" + NL +
		"- `\.`: Dot separator between octets" + NL +
		"- Pattern repeated 3 times with dots" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `192.168.0.1`, `10.0.0.0`, `255.255.255.255`" + NL +
		"- Non-matches: `256.1.2.3`, `1.2.3`, `300.1.2.3`"
	],

	:ipv6 = [
		"Matches valid IPv6 addresses",
	
		"- `([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}`: Full IPv6 address" + NL +
		"- `([0-9a-fA-F]{1,4}:){1,7}:`: Compressed format with `::`" + NL +
		"- `([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}`: Mixed formats" + NL + NL +

		"- Matches: `2001:0db8:85a3:0000:0000:8a2e:0370:7334`, `fe80::1`" + NL +
		"- Non-matches: `:::1`, `2001:0db8::`"
	],

	:socialHandle = [
		"Matches social media handles",
	
		"- `^`: Start of string" + NL +
		"- `@`: Required @ symbol at start" + NL +
		"- `[a-zA-Z0-9._]{1,30}`: Username with letters, numbers, dots, underscores" + NL +
		"- Maximum length of 30 characters" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `@user123`, `@john.doe`, `@handle_name`" + NL +
		"- Non-matches: `user123`, `@user name`, `@`"
	],

	:slug = [
		"Matches URL-friendly slugs",
	
		"- `^`: Start of string" + NL +
		"- `[a-z0-9]+`: One or more lowercase letters or numbers" + NL +
		"- `(?:-[a-z0-9]+)*`: Optional groups of hyphen followed by alphanumerics" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `my-blog-post`, `article-123`, `hello`" + NL +
		"- Non-matches: `-post`, `Post-Title`, `my--post`"
	],

	# Dates & Times (International)

	:isoDate = [
		"Matches ISO 8601 date format (YYYY-MM-DD)",
	
		"- `^`: Start of string" + NL +
		"- `\d{4}`: Four digits for year" + NL +
		"- `-`: Literal hyphen separator" + NL +
		"- `(0[1-9]|1[0-2])`: Month 01-12" + NL +
		"- `-`: Literal hyphen separator" + NL +
		"- `(0[1-9]|[12][0-9]|3[01])`: Day 01-31" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `2023-12-25`, `2024-01-01`" + NL +
		"- Non-matches: `2023/12/25`, `23-12-25`"
	],

	:isoDateTime = [
		"Matches ISO 8601 datetime format with optional timezone",
	
		"- Starts with ISO date format" + NL +
		"- `T`: Time separator" + NL +
		"- `([01]?[0-9]|2[0-3])`: Hours (00-23)" + NL +
		"- `:[0-5][0-9]:[0-5][0-9]`: Minutes and seconds" + NL +
		"- `(\.[0-9]+)?`: Optional fractional seconds" + NL +
		"- `(Z|[+-][01][0-9]:[0-5][0-9])?`: Optional timezone" + NL + NL +

		"- Matches: `2023-12-25T14:30:00Z`, `2024-01-01T09:00:00+01:00`" + NL +
		"- Non-matches: `2023-12-25 14:30`, `2023-12-25T25:00:00Z`"
	],

	:ddmmyyyy = [
		"Matches dates in DD/MM/YYYY format with various separators",
	
		"- `^`: Start of string" + NL +
		"- `(0[1-9]|[12][0-9]|3[01])`: Day (01-31)" + NL +
		"- `[-/.]`: Separator (hyphen, forward slash, or dot)" + NL +
		"- `(0[1-9]|1[0-2])`: Month (01-12)" + NL +
		"- `[-/.]`: Same separator as above" + NL +
		"- `\d{4}`: Four-digit year" + NL + NL +

		"- Matches: `25/12/2023`, `01-01-2024`, `31.12.2023`" + NL +
		"- Non-matches: `32/12/2023`, `13/13/2023`"
	],

	:mmddyyyy = [
		"Matches dates in MM/DD/YYYY format with various separators",
	
		"- `^`: Start of string" + NL +
		"- `(0[1-9]|1[0-2])`: Month (01-12)" + NL +
		"- `[-/.]`: Separator (hyphen, forward slash, or dot)" + NL +
		"- `(0[1-9]|[12][0-9]|3[01])`: Day (01-31)" + NL +
		"- `[-/.]`: Same separator as above" + NL +
		"- `\d{4}`: Four-digit year" + NL + NL +

		"- Matches: `12/25/2023`, `01-01-2024`, `12.31.2023`" + NL +
		"- Non-matches: `13/25/2023`, `12/32/2023`"
	],

	:time24h = [
		"Matches 24-hour time format (HH:MM)",
	
		"- `^`: Start of string" + NL +
		"- `([01]?[0-9]|2[0-3])`: Hours (0-23)" + NL +
		"- `:`: Time separator" + NL +
		"- `[0-5][0-9]`: Minutes (00-59)" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `23:59`, `00:00`, `14:30`" + NL +
		"- Non-matches: `24:00`, `12:60`, `1:5`"
	],

	# Markdown

	:mdHeader = [
		"Matches Markdown headers",
        
		"- `^`: Start of line" + NL +
		"- `#{1,6}`: 1 to 6 hash symbols" + NL +
		"- `\\s`: Required space" + NL +
		"- `.+`: Header text" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `# Header`, `### Subheader`" + NL +
		"- Non-matches: `#Header`, `####### TooManyHashes`"
	],

	:mdBold = [
		"Matches Markdown bold text",
        
		"- `\\*\\*`: Two asterisks" + NL +
		"- `[^*]+`: Any characters except asterisk" + NL +
		"- `\\*\\*`: Closing asterisks" + NL + NL +

		"- Matches: `**bold text**`, `**important**`" + NL +
		"- Non-matches: `*single*`, `**incomplete`"
	],

	:mdItalic = [
		"Matches Markdown italic text",
 
		"- `\\*`: Single asterisk" + NL +
		"- `[^*]+`: Any characters except asterisk" + NL +
		"- `\\*`: Closing asterisk" + NL + NL +

		"- Matches: `*italic*`, `*emphasized*`" + NL +
		"- Non-matches: `**bold**`, `*incomplete`"
	],

	:mdLink = [
		"Matches Markdown links",

		"- `\\[`: Opening square bracket" + NL +
		"- `([^\\]]+)`: Link text (anything but closing bracket)" + NL +
		"- `\\]`: Closing square bracket" + NL +
		"- `\\(`: Opening parenthesis" + NL +
		"- `([^\\)]+)`: URL (anything but closing parenthesis)" + NL +
		"- `\\)`: Closing parenthesis" + NL + NL +

		"- Matches: `[link](url)`, `[Example](http://example.com)`" + NL +
		"- Non-matches: `[link](`, `[link]`"
	],

	:mdImage = [
		"Matches Markdown images",

		"- `!`: Exclamation mark prefix" + NL +
		"- `\\[`: Opening square bracket" + NL +
		"- `([^\\]]*)`': Alt text (optional, anything but closing bracket)" + NL +
		"- `\\]`: Closing square bracket" + NL +
		"- `\\(`: Opening parenthesis" + NL +
		"- `([^\\)]+)`: Image URL (anything but closing parenthesis)" + NL +
		"- `\\)`: Closing parenthesis" + NL + NL +

		"- Matches: `![alt](image.jpg)`, `![](photo.png)`" + NL +
		"- Non-matches: `[img](pic.jpg)`, `![alt]()`"
	],

	:mdBlockquote = [
		"Matches Markdown blockquotes",

		"- `^`: Start of line" + NL +
		"- `>`: Greater than symbol" + NL +
		"- `\\s`: Required space" + NL +
		"- `.+`: Quoted text" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `> Quote`, `> Multiple words`" + NL +
		"- Non-matches: `>No space`, `Quote>`"
	],

	:mdCodeBlock = [
		"Matches Markdown code blocks",

		"- ```" + char(34) + ": Three backticks opening" + NL +
		"- `[^`]*`: Any characters except backtick" + NL +
		"- ```" + char(34) + ": Three backticks closing" + NL + NL +

		"- Matches: ```code block```, ```multiple" + NL + "lines```" + NL +
		"- Non-matches: ``two ticks``, ````four ticks````"
	],

	:mdInlineCode = [
		"Matches Markdown inline code",

		"- `` ` ``: Single backtick" + NL +
		"- `[^`]+`: Any characters except backtick" + NL +
		"- `` ` ``: Closing backtick" + NL + NL +

		"- Matches: `code`, `var x = 1`" + NL +
		"- Non-matches: ``double``, `unclosed"
	],

	:mdListItem = [
		"Matches Markdown unordered list items",

		"- `^`: Start of line" + NL +
		"- `[-*+]`: Either hyphen, asterisk, or plus sign" + NL +
		"- `\\s`: Required space" + NL +
		"- `.+`: List item text" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `- Item`, `* Point`, `+ Element`" + NL +
		"- Non-matches: `Item-`, `-No space`"
	],

	:mdNumberedList = [
		"Matches Markdown numbered list items",

		"- `^`: Start of line" + NL +
		"- `\\d+`: One or more digits" + NL +
		"- `\\.`: Literal period" + NL +
		"- `\\s`: Required space" + NL +
		"- `.+`: List item text" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `1. First`, `42. Item`" + NL +
		"- Non-matches: `1.No space`, `A. Letter`"
	],

	# YAML Patterns
	
   	:yamlKey = [
		"Matches YAML keys",

		"- `^`: Start of line" + NL +
		"- `[a-zA-Z0-9]+`: At least one alphanumeric character" + NL +
		"- `[a-zA-Z0-9_-]*`: Optional alphanumeric, underscore, or hyphen characters" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `key`, `user123`, `my-key`, `long_key_name`" + NL +
		"- Non-matches: `123`, `-key`, `key:`, `invalid!key`"
	],

	:yamlValue = [
		"Matches YAML values (strings, numbers, booleans, null)",

		"- `^`: Start of line" + NL +
		"- `(`: Start first alternative (quoted strings):" + NL +
		"  - `\\ " + char(34) + "`: Opening quote" + NL +
		"  - `[^\\ " + char(34) + "]*`: Any characters except quotes" + NL +
		"  - `\\ " + char(34) + "`: Closing quote" + NL +
		"- `)`: End first alternative" + NL +
		"- `|`: OR" + NL +
		"- `([0-9]+)`: Second alternative (numbers)" + NL +
		"- `|`: OR" + NL +
		"- `(true|false)|null`: Third alternative (booleans and null)" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `" + char(34) + "hello" + char(34) + "`, `42`, `true`, `false`, `null`" + NL +
		"- Non-matches: `'single quotes'`, `-42`, `True`, `NULL`"
	],

	:yamlMap = [
		"Matches YAML key-value mappings",

		"- `^`: Start of line" + NL +
		"- `[a-zA-Z0-9]+`: Key (at least one alphanumeric character)" + NL +
		"- `:`: Colon separator" + NL +
		"- `[ ]*`: Optional spaces" + NL +
		"- `.+`: Value (any non-empty string)" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `name: John`, `age: 25`, `active: true`" + NL +
		"- Non-matches: `: value`, `key :value`, `key:`, `-key: value`"
	],

	:yamlArray = [
		"Matches YAML array elements (numbers or quoted strings)",

		"- `^`: Start of line" + NL +
		"- `-?[0-9]+`: First alternative (optional negative sign followed by digits)" + NL +
		"- `|`: OR" + NL +
		"- `\\ " + char(34) + "`: Opening quote" + NL +
		"- `[^\\ " + char(34) + "]*`: Any characters except quotes" + NL +
		"- `\\ " + char(34) + "`: Closing quote" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `42`, `-42`, `" + char(34) + "element" + char(34) + "`, `" + char(34) + "item 1" + char(34) + "`" + NL +
		"- Non-matches: `true`, `null`, `'single quotes'`, `plain text`"
	],

	:yamlFrontMatter = [
		"Matches YAML front matter blocks",

		"- `^`: Start of line" + NL +
		"- `---`: Opening delimiter" + NL +
		"- `\\s*\\n`: Optional whitespace and newline" + NL +
		"- `(.*?)`: Non-greedy capture of any characters" + NL +
		"- `\\n---`: Closing delimiter with newline" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches:" + NL +
		"  ```yaml" + NL +
		"  ---" + NL +
		"  title: Post" + NL +
		"  date: 2024-01-15" + NL +
		"  ---" + NL +
		"  ```" + NL + NL +

		"- Non-matches: `---only start`, `--- no end content`"
	],

	# HTML Patterns

	:htmlComment = [
		"Matches HTML comments",

		"- `<!--`: Comment opening sequence" + NL +
		"- `[\\s\\S]*?`: Any characters including newlines (non-greedy)" + NL +
		"- `-->`: Comment closing sequence" + NL + NL +

		"- Matches: `<!-- comment -->`, `<!-- multi" + NL + "line -->`" + NL +
		"- Non-matches: `<!-- unclosed`, `/* css comment */`"
	],

	:htmlDoctype = [
		"Matches HTML DOCTYPE declarations",

		"- `<!DOCTYPE`: DOCTYPE opening sequence" + NL +
		"- `[^>]*`: Any characters except closing bracket" + NL +
		"- `>`: Closing bracket" + NL + NL +

		"- Matches: `<!DOCTYPE html>`, `<!DOCTYPE HTML PUBLIC>`" + NL +
		"- Non-matches: `<!DOCTYPEhtml>`, `<!DOCTYPE>`"
	],

	:htmlOpenTag = [
		"Matches HTML opening tags with optional attributes",

		"- `<`: Opening angle bracket" + NL +
		"- `([a-zA-Z][a-zA-Z0-9]*)`: Tag name" + NL +
		"- `((?:\s+[a-zA-Z][a-zA-Z0-9]*(?:\s*=\s*(?:\ " + NL + char(34) + NL + ".*?\ " + NL + char(34) + NL + "|'.*?'|[^'\ " + NL + char(34) + NL + "<>\\s]+))?)*)`:" + NL +
		"  Optional attributes with values" + NL +
		"- `\s*/?>`: Optional self-closing slash and closing bracket" + NL + NL +

		"- Matches: `<div>`, `<input type=\ " + NL + char(34) + NL + "text\ " + NL + char(34) + NL + ">`, `<br/>`" + NL +
		"- Non-matches: `<1div>`, `<div`, `</div>`"
	],

	:htmlCloseTag = [
		"Matches HTML closing tags",

		"- `</`: Closing tag opening sequence" + NL +
		"- `([a-zA-Z][a-zA-Z0-9]*)`: Tag name" + NL +
		"- `>`: Closing bracket" + NL + NL +

		"- Matches: `</div>`, `</p>`, `</html>`" + NL +
		"- Non-matches: `</1>`, `</>`, `</div`"
	],

	:htmlAttribute = [
		"Matches HTML attributes with optional values",

		"- `\\s+`: Required whitespace" + NL +
		"- `[a-zA-Z][a-zA-Z0-9]*`: Attribute name" + NL +
		"- `(?:\\s*=\\s*`: Optional value assignment" + NL +
		"- `(?:" + char(34) + ".*?" + char(34) + "|'.*?'|[^'" + char(34) + "<>\\s]+))?`: Optional value" + NL + NL +

		"- Matches: `class=" + char(34) + "main" + char(34) + "`, `disabled`, `data-value='123'`" + NL +
		"- Non-matches: `=value`, `123=456`, `class =`"
	],

	:htmlClass = [
		"Matches HTML class attributes",

		"- `\\s+class\\s*=\\s*`: Class attribute declaration" + NL +
		"- `(?:" + char(34) + "[^" + char(34) + "]*" + char(34) + "`: Double-quoted value" + NL +
		"- `|'[^']*'`: Single-quoted value" + NL +
		"- `|[^'" + char(34) + "\\s>]+)`: Unquoted value" + NL + NL +

		"- Matches: `class=" + char(34) + "main" + char(34) + "`, `class='header'`, `class=container`" + NL +
		"- Non-matches: `class=`, `class=>`, `class`"
	],

	:htmlId = [
		"Matches HTML id attributes",

		"- `\\s+id\\s*=\\s*`: ID attribute declaration" + NL +
		"- `(?:" + char(34) + "[^" + char(34) + "]*" + char(34) + "`: Double-quoted value" + NL +
		"- `|'[^']*'`: Single-quoted value" + NL +
		"- `|[^'" + char(34) + "\\s>]+)`: Unquoted value" + NL + NL +

		"- Matches: `id=" + char(34) + "main" + char(34) + "`, `id='header'`, `id=container`" + NL +
		"- Non-matches: `id=`, `id=>`, `id`"
	],

	:html5Color = [
		"Matches HTML5 color hexadecimal values",
    
		"- `^`: Start of line" + NL +
		"- `#`: Hash symbol" + NL +
		"- `[A-Fa-f0-9]{3,6}`: 3 or 6 hexadecimal characters" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `#fff`, `#000000`, `#12AB3F`" + NL +
		"- Non-matches: `#12`, `#1234567`, `123456`"
	],

	# CSS Patterns
	
	:idSelector = [
		"Matches CSS ID selectors",
	
		"- `^`: Start of string" + NL +
		"- `#`: Hash symbol for ID" + NL +
		"- `([a-zA-Z_][a-zA-Z\\d_-]*)`: Valid ID name" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `#header`, `#nav-bar_1`" + NL +
		"- Non-matches: `#1header`, `.class-name`"
	],

	:classSelector = [
		"Matches CSS class selectors",

		"- `^`: Start of line" + NL +
		"- `\\.`: Dot prefix" + NL +
		"- `([a-zA-Z_]`: Must start with letter or underscore" + NL +
		"- `[a-zA-Z\\d_-]*)`: Can contain letters, digits, underscores, hyphens" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `.container`, `.nav_item`, `.btn-primary`" + NL +
		"- Non-matches: `.1class`, `.`, `.class#id`"
	],

	:attributeSelector = [
		"Matches CSS attribute selectors with optional values",

		"- `\\[\\s*`: Opening bracket with optional whitespace" + NL +
		"- `([a-zA-Z][a-zA-Z0-9-]*)`: Attribute name" + NL +
		"- `\\s*`: Optional whitespace" + NL +
		"- `(?:([*^$|!~]?=)`: Optional operator" + NL +
		"- `\\s*`: Optional whitespace" + NL +
		"- `(?:\\ " + char(34) + "[^\\ " + char(34) + "]*\\ " + char(34) + "|'[^']*'|[^'\\ " + char(34) + "\\s>]+))?`: Optional value" + NL +
		"- `\\s*\\]`: Closing bracket with optional whitespace" + NL + NL +

		"- Matches: `[type]`, `[type=" + char(34) + "text" + char(34) + "]`, `[class^=" + char(34) + "btn-" + char(34) + "]`" + NL +
		"- Non-matches: `[1type]`, `[]`, `[type=]`"
	],

	:hexColor = [
		"Matches CSS hexadecimal color values",

		"- `^`: Start of line" + NL +
		"- `#`: Hash symbol" + NL +
		"- `([a-fA-F\\d]{3}`: Three hex digits" + NL +
		"- `|`: OR" + NL +
		"- `[a-fA-F\\d]{6})`: Six hex digits" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `#fff`, `#000000`, `#1a2b3c`" + NL +
		"- Non-matches: `#1`, `#12345`, `#gggggg`"
	],

	:rgbColor = [
		"Matches CSS RGB and RGBA color values",

		"- `^`: Start of line" + NL +
		"- `rgba?`: 'rgb' with optional 'a'" + NL +
		"- `\\(`: Opening parenthesis" + NL +
		"- `\\s*\\d{1,3}\\s*,`: Red value (0-255)" + NL +
		"- `\\s*\\d{1,3}\\s*,`: Green value (0-255)" + NL +
		"- `\\s*\\d{1,3}`: Blue value (0-255)" + NL +
		"- `(\\s*,\\s*(0|1|0?\\.\\d+))?`: Optional alpha value (0-1)" + NL +
		"- `\\s*\\)`: Closing parenthesis" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `rgb(255,0,0)`, `rgba(255, 0, 0, 0.5)`" + NL +
		"- Non-matches: `rgb(300,0,0)`, `rgba(255,0)`, `rgb()`"
	],

	# Numbers & Currency (International)

	:digit = [
		"Matches any single digit (0–9)",

		"- `\d` : A digit from 0 to 9"
	],

	:number = [
		"Matches various number formats including decimals and thousands separators",

		"- `^`: Start of string" + NL +
		"- `-?`: Optional negative sign" + NL +
		"- `(?:\\d+|\\d{1,3}(?:,\\d{3})+)?`: Whole number part with optional thousands separators" + NL +
		"- `(?:\\.\\d+)?`: Optional decimal part" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `1234`, `-123.45`, `1,234,567.89`" + NL +
		"- Non-matches: `123.`, `.123`, `1,23,456`"
	],

	:currencyValue = [
		"Matches currency values formatted with thousand separators and two decimal places",

		"- `^-?`: Optional negative sign" + NL +
		"- `\\d{1,3}(?:,\\d{3})*`: Matches numbers with optional thousand separators (e.g., `1,000`)" + NL +
		"- `(?:\\.\\d{2})?`: Optional decimal part with exactly two digits" + NL + NL +

		"- Matches: `1,234.56`, `1234.00`, `-1,000.99`" + NL +
		"- Non-matches: `1234.5`, `12,34.00`, `123,456.789`"
	],

	:scientificNotation = [
		"Matches numbers in scientific notation format",

		"- `^-?`: Optional negative sign" + NL +
		"- `\\d+(?:\\.\\d+)?`: Matches a number with an optional decimal part" + NL +
		"- `(?:e[+-]?\\d+)?`: Optional scientific notation with exponent (e.g., `e+10`)" + NL + NL +

		"- Matches: `1.23e+3`, `-4.56e-7`, `123e5`, `0.001`" + NL +
		"- Non-matches: `1e`, `1.2.3`, `e+2`"
	],

	:percentage = [
		"Matches percentages with optional decimal points",

		"- `^-?`: Optional negative sign" + NL +
		"- `\\d*\\.?\\d+`: Matches an optional integer or decimal part" + NL +
		"- `%`: Ensures the value ends with a percent symbol" + NL + NL +

		"- Matches: `50%`, `123.45%`, `-0.1%`" + NL +
		"- Non-matches: `50`, `%50`, `123.45`"
	],

	:hexColor = [
		"Matches hexadecimal color codes in 3 or 6 digit formats",

		"- `^#`: Ensures the value starts with a hash (`#`)" + NL +
		"- `([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})`: Matches either a 6-digit or 3-digit hexadecimal value" + NL + NL +

		"- Matches: `#FFF`, `#ffffff`, `#123abc`" + NL +
		"- Non-matches: `#1234`, `123abc`, `#fffffg`"
	],

	# Contact Information (International)
	
	:phoneE164 = [
		"Matches E.164 international phone number format",
	
		"- `^`: Start of string" + NL +
		"- `\\+`: Required plus sign" + NL +
		"- `[1-9]`: First digit must be 1-9" + NL +
		"- `\\d{1,14}`: 1 to 14 additional digits" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `+12345678901`, `+442071234567`" + NL +
		"- Non-matches: `12345678901`, `+0123456789`"
	],
	
	:phoneGeneral = [
		"Matches various phone number formats",
	
		"- `^`: Start of string" + NL +
		"- `[+]?`: Optional plus sign" + NL +
		"- `[(]?`: Optional opening parenthesis" + NL +
		"- `[0-9]{1,4}`: 1-4 digits for country/area code" + NL +
		"- `[)]?`: Optional closing parenthesis" + NL +
		"- `[-\\s./0-9]*`: Any combination of digits, spaces, hyphens, dots, slashes" + NL + NL +

		"- Matches: `(123) 456-7890`, `+1.234.567.8900`, `123-456-7890`" + NL +
		"- Non-matches: `abc-def-ghij`, `12-3456`"
	],

	:postalCode = [
		"Matches postal codes with alphanumeric characters, optional spaces, and hyphens",
    
		"- `^[A-Z0-9]`: Ensures the code starts with an alphanumeric character" + NL +
		"- `[A-Z0-9\\- ]{0,10}`: Matches up to 10 characters including spaces and hyphens" + NL +
		"- `[A-Z0-9]$`: Ensures the code ends with an alphanumeric character" + NL + NL +

		"- Matches: `12345`, `A1B 2C3`, `123-4567`" + NL +
		"- Non-matches: `12 345`, `-12345`, `123 45 `"
	],

	:countryCode = [
		"Matches country codes of 2 to 3 uppercase letters",

		"- `^[A-Z]{2,3}$`: Ensures 2 to 3 uppercase alphabetic characters" + NL + NL +

		"- Matches: `US`, `CAN`, `GB`" + NL +
		"- Non-matches: `Us`, `123`, `USA1`"
	],

	:languageCode = [
		"Matches language codes in `xx-XX` format, where `xx` is a lowercase language code and `XX` is an uppercase country code",

		"- `^[a-z]{2}`: Ensures two lowercase letters for the language code" + NL +
		"- `-[A-Z]{2}`: Ensures a hyphen followed by two uppercase letters for the country code" + NL + NL +

		"- Matches: `en-US`, `fr-CA`, `es-ES`" + NL +
		"- Non-matches: `EN-us`, `english-US`, `us-en`"
	],

	# Modern Data Formats

	:jwt = [
		"Matches JSON Web Tokens",

		"- `^`: Start of string" + NL +
		"- `[A-Za-z0-9-_]+`: Base64url-encoded header" + NL +
		"- `\\.`: Dot separator" + NL +
		"- `[A-Za-z0-9-_]+`: Base64url-encoded payload" + NL +
		"- `\\.`: Dot separator" + NL +
		"- `[A-Za-z0-9-_]*`: Base64url-encoded signature" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U`" + NL +
		"- Non-matches: `abc.def`, `header.payload`"
	],

	:base64 = [
		"Matches strings encoded in Base64 format",

		"- `^(?:[A-Za-z0-9+/]{4})*`: Matches groups of four Base64 characters (letters, digits, `+`, or `/`)" + NL +
		"- `(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$`: Allows padding with `=` for the last group" + NL + NL +

		"- Matches: `TWFu`, `TWE=`, `TQ==`, `YWJjZA==`" + NL +
		"- Non-matches: `T@W==`, `123`, `ABCD==`"
	],

	:emoji = [
		"Matches strings composed entirely of emoji characters",

		"- `^(?:\\p{Emoji_Presentation}|\\p{Emoji})+$`: Matches one or more Unicode emoji characters" + NL + NL +

		"- Matches: `😊`, `🎉🎈`, `👩‍🚀🚀`" + NL +
		"- Non-matches: `😊abc`, `123🎉`, `😀_😊`"
	],

	# API & Request Validation

	:apiKey = [
		"Matches API key formats",
	
		"- `^`: Start of string" + NL +
		"- `[A-Za-z0-9_-]{20,}`: At least 20 characters of letters, numbers, underscores, or hyphens" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `abcd1234_xyz-987654321`, `api_key_123456789abcdefghijk`" + NL +
		"- Non-matches: `short_key`, `invalid#key`, `api@key`"
	],

	:bearerToken = [
		"Matches Bearer authentication tokens",

		"- `^`: Start of string" + NL +
		"- `Bearer\\s+`: 'Bearer' keyword followed by whitespace" + NL +
		"- `[A-Za-z0-9\\-._~+/]+=*`: Base64 URL-safe characters with optional padding" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `Bearer abc123xyz789`, `Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`" + NL +
		"- Non-matches: `bearer token`, `Bearer`, `BearerToken123`"
	],

	:queryParam = [
		"Matches valid URL query parameter names",

		"- `^`: Start of string" + NL +
		"- `[\\w\\-%\\.]+`: One or more word characters, percent signs, or dots" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `page`, `sort-by`, `filter.name`" + NL +
		"- Non-matches: `@param`, `query space`, `param#1`"
	],

	:httpMethod = [
		"Matches valid HTTP methods",

		"- `^`: Start of string" + NL +
		"- `(?:GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS)`: Valid HTTP methods" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `GET`, `POST`, `PUT`" + NL +
		"- Non-matches: `get`, `SEND`, `RETRIEVE`"
	],

	:contentType = [
		"Matches HTTP Content-Type headers with optional charset specifications",

		"- `^[\\w\\-\\.\\/]+`: Matches the primary type and subtype (e.g., `application/json`)" + NL +
		"- `(?:\\+[\\w\\-\\.\\/]+)?`: Optionally matches suffix types (e.g., `application/ld+json`)" + NL +
		"- `(?:;\\s*charset=[\\w\\-]+)?$`: Optionally matches charset parameters (e.g., `charset=utf-8`)" + NL + NL +

		"- Matches: `application/json`, `text/html; charset=utf-8`, `application/ld+json`" + NL +
		"- Non-matches: `application`, `text; utf-8`, `image/jpg; charset`"
	],

	:requestId = [
		"Matches request IDs with a minimum length of 4 characters",

		"- `^[\\w\\-]{4,}$`: Ensures alphanumeric characters, underscores, or hyphens with a minimum length of 4" + NL + NL +

		"- Matches: `abc1`, `1234-5678`, `req_abc`" + NL +
		"- Non-matches: `abc`, `12`, `req!123`"
	],

	:corsOrigin = [
		"Matches valid CORS origin URLs with optional port numbers",

		"- `^https?://`: Matches URLs starting with `http://` or `https://`" + NL +
		"- `(?:[\\w-]+\\.)+[\\w-]+`: Matches domain names with optional subdomains" + NL +
		"- `(?::\\d{1,5})?$`: Optionally matches port numbers (e.g., `:8080`)" + NL + NL +

		"- Matches: `https://example.com`, `http://sub.example.com:3000`" + NL +
		"- Non-matches: `ftp://example.com`, `http://example`, `https://.com`"
	],

	# Data Cleaning

	:alphanumeric = [
		"Matches strings containing only letters and numbers",

		"- `^`: Start of string" + NL +
		"- `[a-zA-Z0-9]+`: One or more letters or numbers" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `ABC123`, `Test999`, `123abc`" + NL +
		"- Non-matches: `ABC-123`, `Test_999`, `Special!`"
	],

	:alphabetic = [
		"Matches strings containing only alphabetic characters (A-Z, a-z)",

		"- `^[a-zA-Z]+$`: Ensures the string contains only uppercase and lowercase letters with no spaces or symbols" + NL + NL +

		"- Matches: `Hello`, `abcXYZ`, `Data`" + NL +
		"- Non-matches: `Hello123`, `Data!`, `Hello World`"
	],

	:numeric = [
		"Matches strings containing only numeric digits (0-9)",

		"- `^[0-9]+$`: Ensures the string consists solely of digits" + NL + NL +

		"- Matches: `12345`, `007`, `2023`" + NL +
		"- Non-matches: `12.34`, `123abc`, `1 2 3`"
	],

	:spaces = [
		"Matches sequences of whitespace characters (spaces, tabs, newlines, and carriage returns)",

		"- `[ \\t\\r\\n]+`: Matches one or more spaces, tabs (`\\t`), carriage returns (`\\r`), or newlines (`\\n`)" + NL + NL +

		"- Matches: ` `, `\t\t`, ` \n \t`" + NL +
		"- Non-matches: `abc`, `123`, `a b` (does not match non-whitespace characters)"
	],

	:trim = [
		"Matches leading and trailing whitespace in a string",
 
		"- `^\\s+`: Matches leading whitespace at the beginning of the string" + NL +
		"- `|\\s+$`: Matches trailing whitespace at the end of the string" + NL + NL +

		"- Matches: Leading/trailing spaces in `  Hello `, `\tWorld\n `" + NL +
		"- Non-matches: `NoSpacesHere`, `A B` (internal spaces are not matched)"
	],

	:nonPrintable = [
		"Matches non-printable ASCII characters",

		"- `[\\x00-\\x1F\\x7F-\\x9F]`: Matches ASCII control characters (0x00–0x1F) and additional non-printable characters (0x7F–0x9F)" + NL + NL +

		"- Matches: `\x00` (null), `\x1B` (escape), `\x7F` (delete)" + NL +
		"- Non-matches: `abc`, `123`, `@#$` (printable characters are not matched)"
	],

	:multipleSpaces = [
		"Matches sequences of two or more whitespace characters",

		"- `{2,}`: Two or more occurrences of the previous pattern" + NL + NL +

		"- Matches: `  `, `   `, multiple spaces/tabs" + NL +
		"- Non-matches: ` ` (single space)"
	],

	# JSON Patterns

	:jsonObject = [
		"Matches JSON object structures",

		"- `\\{`: Opening brace" + NL +
		"- `(?:\\s*\\\ " + NL + char(34) + NL + "[a-zA-Z0-9_]+\\\ " + NL + char(34) + NL + "\\s*:\\s*`: Key part with quotes and colon" + NL +
		"- `(?:\\\ " + NL + char(34) + NL + "[^\\\ " + NL + char(34) + NL + "]*\\\ " + NL + char(34) + NL + "|'[^']*'|\\d+|true|false|null|\\{.*?\\}|\\[.*?\\]))*`: Various value types" + NL +
		"- `\\s*\\}`: Closing brace with optional whitespace" + NL + NL +

		"- Matches: `{\ " + NL + char(34) + NL + "name\ " + NL + char(34) + NL + ":\ " + NL + char(34) + NL + "value\ " + NL + char(34) + NL + "}`, `{\ " + NL + char(34) + NL + "age\ " + NL + char(34) + NL + ":25}`" + NL +
		"- Non-matches: `{name:value}`, `{\ " + NL + char(34) + NL + "key\ " + NL + char(34) + NL + ":}`, `{\ " + NL + char(34) + NL + "key\ " + NL + char(34) + NL + "}`"
	],

	:jsonArray = [
		"Matches JSON array structures",

		"- `^`: Start of string" + NL +
		"- `\\[`: Opening bracket" + NL +
		"- `(?:\\s*[^,]+,?\\s*)*`: Array elements separated by commas" + NL +
		"- `\\]`: Closing bracket" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `[1,2,3]`, `[\ " + NL + char(34) + NL + "a\ " + NL + char(34) + NL + ",\ " + NL + char(34) + NL + "b\ " + NL + char(34) + NL + ",\ " + NL + char(34) + NL + "c\ " + NL + char(34) + NL + "]`" + NL +
		"- Non-matches: `[1,2,]`, `[,]`, `[1,,2]`"
	],

	:jsonKeyValuePair = [
		"Matches a key-value pair in JSON format",

		"- `\" + char(34) + "[a-zA-Z0-9_]+\" + char(34) + "`: Matches a JSON key enclosed in double quotes, consisting of alphanumeric characters and underscores" + NL +
		"- `\\s*:\\s*`: Matches the colon `:` separator with optional spaces around it" + NL +
		"- `(?:\" + char(34) + "[^\" + char(34) + "]*\" + char(34) + "|'[^']*'|\\d+|true|false|null|\\{.*?\\}|\\[.*?\\])`: Matches the value, which can be:" + NL +
		"  - A double-quoted string" + NL +
		"  - A single-quoted string" + NL +
		"  - A number (e.g., `123`)" + NL +
		"  - A boolean (`true` or `false`)" + NL +
		"  - `null`" + NL +
		"  - A JSON object (`{}`) or array (`[]`)" + NL + NL +

		"- Matches: `\" + char(34) + "name\" + char(34) + ":\" + char(34) + "John\" + char(34) + "`, `\" + char(34) + "age\" + char(34) + ":30`, `\" + char(34) + "active\" + char(34) + ":true`, `\" + char(34) + "address\" + char(34) + ":{\" + char(34) + "city\" + char(34) + ":\" + char(34) + "Paris\" + char(34) + "}`" + NL +
		"- Non-matches: `name:John`, `\" + char(34) + "key\" + char(34) + ":`, `\" + char(34) + "invalid\" + char(34) + "\" + char(34) + "value\" + char(34) + "`"
	],

	:geoJSON = [
		"Matches a valid GeoJSON FeatureCollection object",

		"- `^\\{\\s*\" + char(34) + "type\" + char(34) + "\\s*:\\s*\" + char(34) + "FeatureCollection\" + char(34) + "`: Matches the opening of a GeoJSON object with the type `FeatureCollection`" + NL +
		"- `\\s*,\\s*\" + char(34) + "features\" + char(34) + "\\s*:\\s*\\[.*?\\]`: Matches the `features` property containing an array of features" + NL +
		"- `\\s*\\}$`: Matches the closing brace of the GeoJSON object" + NL + NL +

		"- Matches: `{ \" + char(34) + "type\" + char(34) + ": \" + char(34) + "FeatureCollection\" + char(34) + ", \" + char(34) + "features\" + char(34) + ": [] }`, `{ \" + char(34) + "type\" + char(34) + ": \" + char(34) + "FeatureCollection\" + char(34) + ", \" + char(34) + "features\" + char(34) + ": [{\" + char(34) + "type\" + char(34) + ":\" + char(34) + "Feature\" + char(34) + "}] }`" + NL +
		"- Non-matches: `{ \" + char(34) + "type\" + char(34) + ": \" + char(34) + "Feature\" + char(34) + ", \" + char(34) + "features\" + char(34) + ": [] }`, `{ \" + char(34) + "type\" + char(34) + ": \" + char(34) + "FeatureCollection\" + char(34) + " }`"
	],

	# CSV Patterns

	:csvHeaderRow = [
		"Matches CSV header rows",

		"- `^`: Start of string" + NL +
		"- `([^,]*,)*`: Zero or more non-comma characters followed by comma" + NL +
		"- `[^,]*`: Final field without comma" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `name,age,email`, `first,last,address`" + NL +
		"- Non-matches: `name,,age`, `,name,age`"
	],

	:csvQuotedField = [
		"Matches a quoted field in a CSV file",

		"- `\" + char(34) + "[^\" + char(34) + "]*\" + char(34) + "`: Matches any text enclosed within double quotes" + NL + NL +

		"- Matches: `\" + char(34) + "hello\" + char(34) + "`, `\" + char(34) + "123\" + char(34) + "`, `\" + char(34) + "a,b,c\" + char(34) + "`" + NL +
		"- Non-matches: `hello`, `\" + char(34) + "hello` (unclosed quote)"
	],

	:csvUnquotedField = [
		"Matches an unquoted field in a CSV file",

		"- `[^,\\r\\n]*`: Matches any sequence of characters that does not include a comma, carriage return, or newline" + NL + NL +

		"- Matches: `hello`, `123`, `a b c`" + NL +
		"- Non-matches: `hello,world`, `line1\\nline2`"
	],

	:csvDelimiter = [
		"Matches a comma as the field delimiter in a CSV file",

		"- `,`: Matches a singl NL +e comma" + NL + NL +

		"- Matches: `,` in `hello,world`" + NL +
		"- Non-matches: `;`, `\\t`"
	],

	:csvRowEnding = [
		"Matches the end of a row in a CSV file",

		"- `\\r?`: Matches an optional carriage return (\\r) at the end of a row" + NL + NL +

		"- Matches: `\\r`, `\\n`, or an empty string at the end of a row" + NL +
		"- Non-matches: `\\r\\n` (without \\n)"
	],

	:csvEscapedQuote = [
		"Matches escaped double quotes within a quoted CSV field",

		"- `\" + char(34) + "\" + char(34) + "`: Matches two consecutive double quotes inside a quoted field" + NL + NL +

		"- Matches: `\" + char(34) + "hello\" + char(34) + "\" + char(34) + "world\" + char(34) + "` (represents `hello\" + char(34) + "world`)" + NL +
		"- Non-matches: `\" + char(34) + "hello\" + char(34) + "world\" + char(34) + "` (no double quotes to escape)"
	],

	:csvLine = [
		"Matches an entire line of CSV data",

		"- `^(?:(?:\" + char(34) + "[^\" + char(34) + "]*\" + char(34) + ")|(?:[^,\\\" + char(34) + "]+))`: Matches the first field, which can be quoted or unquoted" + NL +
		"- `(?:,(?:(?:\" + char(34) + "[^\" + char(34) + "]*\" + char(34) + ")|(?:[^,\\\" + char(34) + "]+)))*`: Matches subsequent fields separated by commas, which can also be quoted or unquoted" + NL + NL +

		"- Matches: `\" + char(34) + "field1\" + char(34) + ",\" + char(34) + "field2\" + char(34) + "`, `field1,field2`, `\" + char(34) + "field,1\" + char(34) + ",field2`" + NL +
		"- Non-matches: `field1,field2,` (trailing comma), `field1 field2` (no delimiter)"
	],

	:sqlSelectStatement = [
		"Matches SQL SELECT statements",

		"- `^\\s*`: Allows leading whitespace" + NL +
		"- `SELECT\\s+`: Matches the SELECT keyword followed by whitespace" + NL +
		"- `.+?\\s+`: Matches selected columns or expressions followed by whitespace" + NL +
		"- `FROM\\s+`: Matches the FROM keyword followed by whitespace" + NL +
		"- `.+?`: Matches table or subquery names" + NL +
		"- `(?:\\s+WHERE\\s+.+?)?`: Optionally matches the WHERE clause" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `SELECT * FROM table`, `SELECT name, age FROM users WHERE age > 30`" + NL +
		"- Non-matches: `SELCT *`, `SELECT FROM table`"
	],

	:sqlInsertStatement = [
		"Matches SQL INSERT statements",

		"- `^\\s*`: Allows leading whitespace" + NL +
		"- `INSERT\\s+INTO\\s+`: Matches the INSERT INTO keywords followed by whitespace" + NL +
		"- `.+?\\s+`: Matches the table name followed by whitespace" + NL +
		"- `\\(.+?\\)\\s+`: Matches column names in parentheses followed by whitespace" + NL +
		"- `VALUES\\s+\\(.+?\\)`: Matches the VALUES keyword and a list of values in parentheses" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `INSERT INTO table (id, name) VALUES (1, 'Mouddour')`" + NL +
		"- Non-matches: `INSERT table VALUES (1, 'Mouddour')`"
	],

	:sqlUpdateStatement = [
		"Matches SQL UPDATE statements",

		"- `^\\s*`: Allows leading whitespace" + NL +
		"- `UPDATE\\s+`: Matches the UPDATE keyword followed by whitespace" + NL +
		"- `.+?\\s+SET\\s+`: Matches the table name and SET keyword followed by whitespace" + NL +
		"- `.+?`: Matches column-value assignments" + NL +
		"- `(?:\\s+WHERE\\s+.+?)?`: Optionally matches the WHERE clause" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `UPDATE table SET name='Maiga' WHERE id=1`" + NL +
		"- Non-matches: `UPDATE SET name='Harouna'`"
	],

	:sqlDeleteStatement = [
		"Matches SQL DELETE statements",

		"- `^\\s*`: Allows leading whitespace" + NL +
		"- `DELETE\\s+FROM\\s+`: Matches the DELETE FROM keywords followed by whitespace" + NL +
		"- `.+?`: Matches the table name" + NL +
		"- `(?:\\s+WHERE\\s+.+?)?`: Optionally matches the WHERE clause" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `DELETE FROM users WHERE id=1`" + NL +
		"- Non-matches: `DELETE WHERE id=1`, `DELETE FROM`"
	],

	:sqlCreateTable = [
		"Matches SQL CREATE TABLE statements",

		"- `^\\s*`: Allows leading whitespace" + NL +
		"- `CREATE\\s+TABLE\\s+`: Matches the CREATE TABLE keywords followed by whitespace" + NL +
		"- `[\\w]+\\s*\\(.+?\\)`: Matches the table name followed by column definitions in parentheses" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `CREATE TABLE users (id INT, name VARCHAR(100))`" + NL +
		"- Non-matches: `CREATE users`, `TABLE users (id INT)`"
	],

	:sqlDropTable = [
		"Matches SQL DROP TABLE statements",

		"- `^\\s*`: Allows leading whitespace" + NL +
		"- `DROP\\s+TABLE\\s+`: Matches the DROP TABLE keywords followed by whitespace" + NL +
		"- `[\\w]+`: Matches the table name" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `DROP TABLE users`" + NL +
		"- Non-matches: `DROP users`, `TABLE DROP users`"
	],

	:sqlIdentifier = [
		"Matches valid SQL identifiers",

		"- `^[a-zA-Z_][a-zA-Z0-9_]*$`: Matches an identifier starting with a letter or underscore, followed by alphanumeric characters or underscores" + NL + NL +

		"- Matches: `table1`, `_column`, `userName`" + NL +
		"- Non-matches: `1table`, `column-name`, `user.name`"
	],

	:sqlValue = [
		"Matches SQL values",

		"- `^('(?:[^']|''|\\\\')*'|\\d+|NULL)$`: Matches a single-quoted string, a number, or the NULL keyword" + NL + NL +

		"- Matches: `'John'`, `123`, `NULL`" + NL +
		"- Non-matches: `John`, `''`, `12a`"
	],

	:sqlOperator = [
		"Matches SQL comparison operators",

		"- `^(=|<>|!=|<|<=|>|>=|LIKE|IN|IS|BETWEEN)$`: Matches valid SQL operators for comparison" + NL + NL +

		"- Matches: `=`, `<>`, `LIKE`, `BETWEEN`" + NL +
		"- Non-matches: `AND`, `OR`, `==`"
	],

	:sqlJoinClause = [
		"Matches SQL JOIN clauses",

		"- `^\\s*JOIN\\s+`: Matches the JOIN keyword followed by whitespace" + NL +
		"- `.+?\\s+ON\\s+.+?$`: Matches the table being joined and the ON condition" + NL + NL +

		"- Matches: `JOIN orders ON users.id = orders.user_id`" + NL +
		"- Non-matches: `JOIN orders`, `ON users.id = orders.user_id`"
	],

	# Regexes for Potential Security Concerns

	:sqlInjection = [
		"Detects potential SQL injection patterns",

		"- `(?:[\\\ " + NL + char(34) + NL + "';]+.*?)+`: Sequences of quotes or semicolons with following content" + NL +
		"- Matches: `'; DROP TABLE users;--`, `\ " + NL + char(34) + NL + " OR \ " + NL + char(34) + NL + "1\ " + NL + char(34) + NL + "=\ " + NL + char(34) + NL + "1`" + NL + NL +

		"- Non-matches: `normal text`, `user@example.com`" + NL +
		"- Note: This is a basic detection pattern and should be used with other security measures"
	],
	
	:xssInjection = [
		"Detects potential XSS patterns",
	
		"- `<`: Opening angle bracket" + NL +
		"- `[a-zA-Z][a-zA-Z0-9]*`: HTML tag name" + NL +
		"- `[^>]*>`: Tag attributes and closing" + NL +
		"- `.*?`: Content" + NL +
		"- `</[a-zA-Z][a-zA-Z0-9]*>`: Closing tag" + NL + NL +

		"- Matches: `<script>alert('xss')</script>`, `<img src=x onerror=alert(1)>`" + NL +
		"- Non-matches: `<plaintext>`, `normaltext`" + NL + NL +

		"- Note: This is a basic detection pattern and should be used with other security measures"
	],

	:emailInjection = [
		"Matches potential email injection attempts in form inputs",

		"- `.*[\\n\\r]+.+@[a-z0-9]+[.][a-z]{2,}.*`: Matches strings containing newline or carriage return characters, followed by an email-like pattern" + NL +
		"- Components:" + NL +
		"  - `.*`: Matches any characters before the injection" + NL +
		"  - `[\\n\\r]+`: Matches one or more newline (`\\n`) or carriage return (`\\r`) characters" + NL +
		"  - `.+@[a-z0-9]+[.][a-z]{2,}`: Matches a basic email address format" + NL +
		"  - `.*`: Matches any characters after the injection" + NL + NL +

		"- Matches: `hello\\nabc@example.com`, `abc\\r\\ndef@domain.com`" + NL +
		"- Non-matches: `hello@example.com` (no newline characters)"
	],

	:htmlInjection = [
		"Matches potential HTML injection attempts in form inputs",

		"- `<[^>]*?[^<]*[a-zA-Z0-9]+.*[^<]*?>`: Matches strings containing HTML-like tags with potential content inside" + NL +
		"- Components:" + NL +
		"  - `<`: Matches the opening angle bracket of an HTML tag" + NL +
		"  - `[^>]*?`: Matches zero or more characters that are not the closing angle bracket, non-greedily" + NL +
		"  - `[^<]*[a-zA-Z0-9]+`: Ensures the tag contains at least one alphanumeric character" + NL +
		"  - `.*`: Matches any additional content inside the tag" + NL +
		"  - `[^<]*?>`: Matches zero or more characters until the closing angle bracket" + NL + NL +

		"- Matches: `<script>alert('XSS')</script>`, `<div>content</div>`" + NL +
		"- Non-matches: `content`, `< >`, `<tag>` (without meaningful content)"
	],

	# Ring Language Patterns

	:ringString = [
		"Matches Ring string assignments and declarations",

		"- `^=?`: Optional assignment operator at start" + NL +
		"- `*`: Optional whitespace" + NL +
		"- `([ " + char(34) + "'].*?[ " + char(34) + "']|[^ ]+)`: Quoted string or word" + NL +
		"- `*$`: Optional whitespace at end" + NL + NL +

		"- Matches: `name = " + char(34) + "John" + char(34) + "`, `str = 'Hello'`" + NL +
		"- Non-matches: `name = `, `= " + char(34) + "unclosed`"
	],

	:ringNumber = [
		"Matches Ring numeric literals",

		"- `^`: Start of line" + NL +
		"- `-?`: Optional minus sign" + NL +
		"- `\\d+`: One or more digits" + NL +
		"- `(?:\\.\\d+)?`: Optional decimal part" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `42`, `-17`, `3.14`, `-0.001`" + NL +
		"- Non-matches: `.5`, `1.`, `1e5`"
	],

	:ringBoolean = [
		"Matches Ring boolean literals",

		"- `^`: Start of line" + NL +
		"- `(?:True|False)`: Either 'True' or 'False'" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `True`, `False`" + NL +
		"- Non-matches: `true`, `false`, `TRUE`"
	],

	:ringVariable = [
		"Matches Ring variable names",

		"- `^`: Start of line" + NL +
		"- `[a-zA-Z_]`: First character must be letter or underscore" + NL +
		"- `\\w*`: Following characters can be letters, numbers, or underscores" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `name`, `_count`, `myVar123`" + NL +
		"- Non-matches: `123var`, `my-var`, `$var`"
	],

	:ringFunction = [
		"Matches Ring function declarations",

		"- `^func`: Function declaration keyword" + NL +
		"- `(\w+)`: Function name" + NL +
		"- `\s*\((.*?)\)`: Parameters in parentheses" + NL + NL +

		"- Matches: `func sum(x, y)`, `func hello()`" + NL +
		"- Non-matches: `function test()`, `func()`"
	],

	:ringFunctionCall = [
		"Matches Ring function calls",

		"- `^`: Start of line" + NL +
		"- `([a-zA-Z_]\\w*)`: Function name" + NL +
		"- `\\s*\\(`: Opening parenthesis with optional whitespace" + NL +
		"- `(.*?)`: Function arguments" + NL +
		"- `\\)`: Closing parenthesis" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `print()`, `calculate(x,y)`, `func(1,2,3)`" + NL +
		"- Non-matches: `1func()`, `func(`, `func`"
	],

	:ringMainFunction = [
		"Matches Ring main function declaration",

		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `Func\\s+Main\\s*`: 'Func Main' declaration" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `Func Main`, `FUNC MAIN`, `func main`" + NL +
		"- Non-matches: `Func main()`, `Function Main`, `Main`"
		],

	:ringClass = [
		"Matches Ring class declarations",
 
		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `Class\\s+`: 'Class' keyword and whitespace" + NL +
		"- `([a-zA-Z_]\\w*)`: Class name" + NL +
		"- `\\s*`: Optional whitespace" + NL +
		"- `(?:from\\s+([a-zA-Z_]\\w*))?`: Optional inheritance" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `Class Animal`, `Class Dog from Animal`" + NL +
		"- Non-matches: `class animal`, `Class 1Dog`, `Class Dog from`"
	],

	:ringClassAttribute = [
		"Matches Ring class attribute declarations",

		"- `^`: Start of line" + NL +
		"- `[a-zA-Z_]\\w*`: Attribute name" + NL +
		"- `\\s*=\\s*`: Assignment operator" + NL +
		"- `.*`: Attribute value" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `name = value`, `count = 0`, `items = []`" + NL +
		"- Non-matches: `1var = 2`, `= value`, `name =`"
	],

	:ringNewObject = [
		"Matches Ring object instantiation",

		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `New\\s+`: 'New' keyword" + NL +
		"- `([a-zA-Z_]\\w*)`: Class name" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `New Person`, `new Calculator`, `NEW Object`" + NL +
		"- Non-matches: `New`, `New 1Class`, `New()`"
	],

	:ringObjectAccess = [
		"Matches Ring object access expressions",
   
		"- `^`: Start of line" + NL +
		"- `([a-zA-Z_]\\w*)`: Object name" + NL +
		"- `\\s*{\\s*`: Opening brace with optional whitespace" + NL +
		"- `(.*?)`: Member access expression" + NL +
		"- `\\s*}`: Closing brace with optional whitespace" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `obj{method()}`, `list{item}`, `object{property}`" + NL +
		"- Non-matches: `obj{}`, `{prop}`, `obj{`"
	],

	:ringLoop = [
		"Matches Ring loop constructs",

		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `(?:`: Non-capturing group for alternatives:" + NL +
		"  - `for\\s+\\w+\\s*=\\s*\\d+\\s+to\\s+\\d+`: Numeric for loop" + NL +
		"  - `|while\\s+.*`: While loop" + NL +
		"  - `|for\\s+\\w+\\s+in\\s+.*?)`: For-in loop" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `for x = 1 to 10`, `while count > 0`, `for item in list`" + NL +
		"- Non-matches: `for`, `while`, `for x in`"
	],

	:ringIf = [
		"Matches Ring if statements",

		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `if\\s+`: 'if' keyword" + NL +
		"- `.*`: Condition" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `if x > 0`, `IF true`, `if isValid()`" + NL +
		"- Non-matches: `if`, `ifelse`, `if()`"
	],

	:ringSwitch = [
		"Matches Ring switch statements",
 
		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `switch\\s+`: 'switch' keyword" + NL +
		"- `.*`: Switch expression" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `switch x`, `SWITCH value`, `switch expr()`" + NL +
		"- Non-matches: `switch`, `case x`, `switch()`"
	],

	:ringCase = [
	"Matches Ring switch case statements",
 
		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `(?:on|off)`: 'on' or 'off' keyword" + NL +
		"- `\\s+`: Required whitespace" + NL +
		"- `.*`: Case value" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `on 1`, `OFF " + char(34) + "text" + char(34) + "`, `on value`" + NL +
		"- Non-matches: `on`, `case 1`, `on()`"
	],

	:ringList = [
		"Matches Ring list literals",

		"- `^`: Start of line" + NL +
		"- `\\[`: Opening bracket" + NL +
		"- `(?:[^[\\]]*|\\[.*?\\])*`: List contents, including nested lists" + NL +
		"- `\\]`: Closing bracket" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `[1,2,3]`, `[[1,2],[3,4]]`, `[]`" + NL +
		"- Non-matches: `[unclosed`, `[1,2,`, `[[]`"
	],

	:ringListRange = [
		"Matches Ring range format expressions",

		"- `^`: Start of line" + NL +
		"- `([^:]+)`: First capture group for the start value" + NL +
		"- `\\s*:\\s*`: Colon separator with optional whitespace" + NL +
		"- `([^:]+)`: Second capture group for the end value" + NL +
		"- `$`: End of line" + NL + NL +
		"- Matches: `1:3`, `A:C`, `#1:#3`, `day1:day3`" + NL +
		"- Non-matches: `1:3:5`, `1::3`"
	],

	:ringListAccess = [
		"Matches Ring list element access",

		"- `^`: Start of line" + NL +
		"- `([a-zA-Z_]\\w*)`: List variable name" + NL +
		"- `\\s*\\[`: Opening bracket" + NL +
		"- `(\\d+|\\w+)`: Numeric or variable index" + NL +
		"- `\\s*\\]`: Closing bracket" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `list[1]`, `array[i]`, `items[index]`" + NL +
		"- Non-matches: `list[]`, `[1]`, `list[1`"
	],

	:ringHashTable = [
		"Matches Ring hash table literals",

		"- `^`: Start of line" + NL +
		"- `\\[\\s*:`: Opening bracket and colon" + NL +
		"- `(?:\\w+\\s*=\\s*[^,\\]]+\\s*,?\\s*)+`: Key-value pairs" + NL +
		"- `\\]`: Closing bracket" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `[:name=" + char(34) + "John" + char(34) + ",age=30]`, `[:key=value]`" + NL +
		"- Non-matches: `[]`, `[:invalid]`, `[:key=]`"
	],

	:ringComment = [
	"Matches Ring comments",

		"- `^`: Start of line" + NL +
		"- `(?:`: Non-capturing group for alternatives:" + NL +
		"  - `#.*`: Single-line hash comment" + NL +
		"  - `//.*`: Single-line double-slash comment" + NL +
		"  - `/\\*[\\s\\S]*?\\*/`: Multi-line comment" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `# comment`, `// note`, `/* multi line */`" + NL +
		"- Non-matches: `/comment`, `/*unclosed`, `#`"
	],

	:ringSee = [
		"Matches Ring See statements",

		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `See\\s+`: 'See' keyword" + NL +
		"- `(?:[" + char(34) + "'].*?[" + char(34) + "']|\\w+)`: String literal or variable" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `See " + char(34) + "Hello" + char(34) + "`, `SEE x`, `see 'text'`" + NL +
		"- Non-matches: `See`, `See()`, `See,`"
	],

	:ringGive = [
		"Matches Ring Give statements",

		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `Give\\s+`: 'Give' keyword" + NL +
		"- `\\w+`: Variable name" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `Give x`, `GIVE input`, `give variable`" + NL +
 		"- Non-matches: `Give`, `Give 1`, `Give()`"
	],

	:ringLoad = [
		"Matches Ring Load statements",

		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `Load\\s+`: 'Load' keyword" + NL +
		"- `[" + char(34) + "'].*?[" + char(34) + "']`: Quoted filename" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `Load " + char(34) + "file.ring" + char(34) + "`, `LOAD 'module.ring'`" + NL +
		"- Non-matches: `Load`, `Load file`, `Load()`"
	],

	:ringImport = [
		"Matches Ring Import statements",
 
		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `Import\\s+`: 'Import' keyword" + NL +
		"- `[\\w.]+`: Module path" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `Import module`, `IMPORT system.lib`, `import std.core`" + NL +
		"- Non-matches: `Import`, `Import.`, `Import()`"
	],

	:ringOperator = [
		"Matches Ring operators",

		"- `^`: Start of line" + NL +
		"- `(?:`: Non-capturing group for alternatives:" + NL +
		"  - `[+\\-*/=%]`: Arithmetic operators" + NL +
		"  - `|==|!=|>=|<=|>|<`: Comparison operators" + NL +
		"  - `|\\+=|-=|\\*=|/=`: Assignment operators" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `+`, `==`, `<=`, `+=`" + NL +
		"- Non-matches: `++`, `=!`, `=>`"
	],

	:ringLogical = [
		"Matches Ring logical operators",

		"- `^`: Start of line" + NL +
		"- `(?:and|or|not)`: Logical operators" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `and`, `or`, `not`" + NL +
		"- Non-matches: `AND`, `Or`, `Not`"
	],

	:ringExit = [
		"Matches Ring Exit statements",
 
		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `exit`: 'Exit' keyword" + NL +
		"- `(?:\\s+\\d+)?`: Optional exit code" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `exit`, `EXIT 0`, `exit 1`" + NL +
		"- Non-matches: `exit()`, `exit code`, `exit -1`"
	],

	:ringReturn = [
		"Matches Ring Return statements",
        
		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `return`: 'Return' keyword" + NL +
		"- `(?:\\s+.*)?`: Optional return value" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `return`, `RETURN value`, `return 42`" + NL +
		"- Non-matches: `return()`, `return,`, `returns`"
	],

	:ringPackage = [
		"Matches Ring Package declarations",

		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `Package\\s+`: 'Package' keyword" + NL +
		"- `[\\w.]+`: Package name" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `Package myapp`, `PACKAGE system.core`, `package lib.util`" + NL +
		"- Non-matches: `Package`, `Package.`, `Package()`"
	],

	:ringPrivate = [
	"Matches Ring Private declarations",

		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `Private`: 'Private' keyword" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `Private`, `PRIVATE`, `private`" + NL +
		"- Non-matches: `Private()`, `Privates`, `Private var`"
	],

	:ringBracestart = [
		"Matches the Ring function definition for `braceStart`",

		"- `^(?i)`: Case-insensitive match" + NL +
		"- `func\\s+`: Matches the keyword `func` followed by one or more spaces" + NL +
		"- `braceStart`: Matches the function name `braceStart`" + NL +
		"- `\\s*\\(`: Matches optional whitespace followed by an opening parenthesis" + NL +
		"- `\\s*\\)`: Matches optional whitespace followed by a closing parenthesis" + NL +
		"- `\\s*$`: Allows for trailing whitespace after the closing parenthesis" + NL + NL +

		"- Matches: `func braceStart()`" + NL +
		"- Non-matches: `func braceStart() something`, `braceStart()`, `func braceStart`"
	],

	:ringBraceEnd = [
		"Matches the Ring function definition for `braceEnd`",

		"- `^(?i)`: Case-insensitive match" + NL +
		"- `func\\s+`: Matches the keyword `func` followed by one or more spaces" + NL +
		"- `braceEnd`: Matches the function name `braceEnd`" + NL +
		"- `\\s*\\(`: Matches optional whitespace followed by an opening parenthesis" + NL +
		"- `\\s*\\)`: Matches optional whitespace followed by a closing parenthesis" + NL +
		"- `\\s*$`: Allows for trailing whitespace after the closing parenthesis" + NL + NL +

		"- Matches: `func braceEnd()`" + NL +
		"- Non-matches: `func braceEnd() something`, `braceEnd()`, `func braceEnd`"
	],

	:ringEval = [
		"Matches Ring Eval function calls",

		"- `^`: Start of line" + NL +
		"- `(?i)`: Case-insensitive matching" + NL +
		"- `Eval\\s*`: 'Eval' keyword" + NL +
		"- `\\(.*?\\)`: Parentheses with expression" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `Eval(1+1)`, `EVAL(x)`, `eval(expression())`" + NL +
		"- Non-matches: `Eval`, `Eval x`, `Evaluate()`"
	],

	# Python Language Patterns

	:pythonString = [
	        "Matches Python string literals",
	        
	        "- `^`: Start of line" + NL +
	        "- `(?:`: Non-capturing group for alternatives:" + NL +
	        "  - `[" + char(34) + "]{3}.*?[" + char(34) + "]{3}`: Triple double-quoted strings" + NL +
	        "  - `|[" + char(34) + "].*?[" + char(34) + "]`: Double-quoted strings" + NL +
	        "  - `|'''.*?'''`: Triple single-quoted strings" + NL +
	        "  - `|'.*?'`: Single-quoted strings" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `" + char(34) + "hello" + char(34) + "`, `'world'`, `" + char(34) + char(34) + char(34) + "multiline" + char(34) + char(34) + char(34) + "`, `'''text'''`" + NL +
	        "- Non-matches: `" + char(34) + "unclosed`, `''''extra'''`"
    	],

    	:pythonNumber = [
	        "Matches Python numeric literals",
	        
	        "- `^`: Start of line" + NL +
	        "- `-?`: Optional minus sign" + NL +
	        "- `\\d+`: One or more digits" + NL +
	        "- `(?:\\.\\d+)?`: Optional decimal part" + NL +
	        "- `(?:e[+-]?\\d+)?`: Optional scientific notation" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `42`, `-17`, `3.14`, `1e-10`" + NL +
	        "- Non-matches: `.5`, `1.`, `e5`"
    	],

    	:pythonBoolean = [
	        "Matches Python boolean and None literals",
	        
	        "- `^`: Start of line" + NL +
	        "- `(?:True|False|None)`: Either 'True', 'False', or 'None'" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `True`, `False`, `None`" + NL +
	        "- Non-matches: `true`, `false`, `none`, `NULL`"
	],

	:pythonVariable = [
	        "Matches Python variable names",
	        
	        "- `^`: Start of line" + NL +
	        "- `[a-zA-Z_]`: First character must be letter or underscore" + NL +
	        "- `\\w*`: Following characters can be letters, numbers, or underscores" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `name`, `_count`, `myVar123`" + NL +
	        "- Non-matches: `123var`, `my-var`, `$var`"
    	],

    	:pythonFunction = [
	        "Matches Python function definitions",
	        
	        "- `^`: Start of line" + NL +
	        "- `def\\s+`: 'def' keyword and whitespace" + NL +
	        "- `([a-zA-Z_]\\w*)`: Function name" + NL +
	        "- `\\s*\\((.*?)\\)`: Parameter list in parentheses" + NL +
	        "- `(?:\\s*->\\s*[\\w\\[\\],\\s]+)?`: Optional return type annotation" + NL +
	        "- `:`: Function block start" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `def test():`, `def calc(x, y) -> int:`, `def _init():`" + NL +
	        "- Non-matches: `def test`, `def 1func():`, `def()`"
    	],

    	:pythonFunctionCall = [
	        "Matches Python function calls",
	        
	        "- `^`: Start of line" + NL +
	        "- `([a-zA-Z_]\\w*)`: Function name" + NL +
	        "- `\\s*\\((.*?)\\)`: Function arguments in parentheses" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `print()`, `calculate(x, y)`, `func(1, 2, 3)`" + NL +
	        "- Non-matches: `1func()`, `func(`, `func`"
    	],

    	:pythonLambda = [
	        "Matches Python lambda expressions",
	        
	        "- `^`: Start of line" + NL +
	        "- `lambda\\s+`: 'lambda' keyword and whitespace" + NL +
	        "- `.*?`: Lambda parameters" + NL +
	        "- `:\\s*`: Colon and optional whitespace" + NL +
	        "- `.*`: Lambda body" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `lambda x: x*2`, `lambda: True`, `lambda a, b: a+b`" + NL +
	        "- Non-matches: `lambda`, `lambda:`, `lambda x`"
   	 ],

    	:pythonClass = [
	        "Matches Python class definitions",
	        
	        "- `^`: Start of line" + NL +
	        "- `class\\s+`: 'class' keyword and whitespace" + NL +
	        "- `([a-zA-Z_]\\w*)`: Class name" + NL +
	        "- `(?:\\((.*?)\\))?`: Optional parent classes" + NL +
	        "- `:`: Class block start" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `class Test:`, `class Child(Parent):`, `class MyClass(A, B):`" + NL +
	        "- Non-matches: `class Test`, `class 1Test:`, `class:`"
   	 ],

    	:pythonClassMethod = [
	        "Matches Python method decorators",
	        
	        "- `^`: Start of line" + NL +
	        "- `@`: Decorator symbol" + NL +
	        "- `\\w+`: Decorator name" + NL +
	        "- `\\s*`: Optional whitespace" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `@classmethod`, `@staticmethod`, `@property`" + NL +
	        "- Non-matches: `@`, `@1method`, `@class method`"
   	 ],

   	 :pythonDecorator = [
	        "Matches Python decorators",
	        
	        "- `^`: Start of line" + NL +
	        "- `@`: Decorator symbol" + NL +
	        "- `[a-zA-Z_]\\w*`: Decorator name" + NL +
	        "- `(?:\\((.*?)\\))?`: Optional decorator arguments" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `@decorator`, `@wrap(arg)`, `@auth(user='admin')`" + NL +
	        "- Non-matches: `@`, `@1dec`, `@dec(`"
    	],

    	:pythonLoop = [
	        "Matches Python loop statements",
	        
	        "- `^`: Start of line" + NL +
	        "- `(?:`: Non-capturing group for alternatives:" + NL +
	        "  - `for\\s+.*?\\s+in\\s+.*?:`: For loop" + NL +
	        "  - `|while\\s+.*?:`: While loop" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `for i in range(10):`, `while True:`, `for x in list:`" + NL +
	        "- Non-matches: `for`, `while`, `for in:`"
   	 ],

    	:pythonIf = [
	        "Matches Python conditional statements",
	        
	        "- `^`: Start of line" + NL +
	        "- `(?:if|elif|else)`: Conditional keywords" + NL +
	        "- `\\s*.*?:`: Condition and colon" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `if x > 0:`, `elif x < 0:`, `else:`" + NL +
	        "- Non-matches: `if:`, `else if:`, `if x`"
    	],

    	:pythonWith = [
	        "Matches Python with statements",
	        
	        "- `^`: Start of line" + NL +
	        "- `with\\s+`: 'with' keyword" + NL +
	        "- `.*?\\s+`: Context manager expression" + NL +
	        "- `as\\s+`: 'as' keyword" + NL +
	        "- `.*?:`: Target variable and colon" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `with open('file.txt') as f:`, `with context() as c:`" + NL +
	        "- Non-matches: `with:`, `with as:`, `with open()`"
    	],

    	:pythonTry = [
	        "Matches Python exception handling statements",
	        
	        "- `^`: Start of line" + NL +
	        "- `(?:try|except|finally|raise)`: Exception keywords" + NL +
	        "- `\\s*.*?:`: Optional expression and colon" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `try:`, `except ValueError:`, `finally:`, `raise Exception()`" + NL +
	        "- Non-matches: `try`, `except:()`, `raises:`"
    	],

   	:pythonList = [
	        "Matches Python list literals",
	        
	        "- `^`: Start of line" + NL +
	        "- `\\[`: Opening bracket" + NL +
	        "- `(?:[^[\\]]*|\\[.*?\\])*`: List contents, including nested lists" + NL +
	        "- `\\]`: Closing bracket" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `[1,2,3]`, `[[1,2],[3,4]]`, `[]`" + NL +
	        "- Non-matches: `[unclosed`, `[1,2,`, `[[]`"
    	],

   	:pythonDict = [
	        "Matches Python dictionary literals",
	        
	        "- `^`: Start of line" + NL +
	        "- `{`: Opening brace" + NL +
	        "- `(?:[^{}]*|{.*?})*`: Dictionary contents, including nested dicts" + NL +
	        "- `}`: Closing brace" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `{'a':1}`, `{1:2, 3:4}`, `{}`" + NL +
	        "- Non-matches: `{unclosed`, `{:}`, `{{}`"
    	],

	:pythonTuple = [
        	"Matches Python tuple literals",

	        "- `^`: Start of line" + NL +
	        "- `\\(`: Opening parenthesis" + NL +
	        "- `(?:[^()]*|\\(.*?\\))*`: Tuple contents, including nested tuples" + NL +
	        "- `\\)`: Closing parenthesis" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `(1,2)`, `(1,(2,3))`, `()`" + NL +
	        "- Non-matches: `(unclosed`, `(,)`, `(()`"
    	],

    	:pythonComprehension = [
		"Matches Python list comprehensions",

		"- `^`: Start of line" + NL +
		"- `\\[`: Opening bracket" + NL +
		"- `.*?\\s+`: Expression" + NL +
		"- `for\\s+.*?\\s+in\\s+.*?`: For clause" + NL +
		"- `\\]`: Closing bracket" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `[x for x in range(10)]`, `[i*2 for i in list]`" + NL +
		"- Non-matches: `[for in]`, `[x for]`, `[x in y]`"
	],

	:pythonComment = [
		"Matches Python single-line comments",

	        "- `^`: Start of line" + NL +
	        "- `#`: Comment symbol" + NL +
	        "- `.*`: Comment text" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `# comment`, `#note`, `# TODO: fix`" + NL +
	        "- Non-matches: `/#comment`, `comment#`, `##`"
	],

	:pythonDocstring = [
		"Matches Python docstrings",

	        "- `^`: Start of line" + NL +
	        "- `[" + char(34) + "]{3}`: Triple quotes" + NL +
	        "- `[\\s\\S]*?`: Any content including newlines" + NL +
	        "- `[" + char(34) + "]{3}`: Closing triple quotes" + NL +
	        "- `$`: End of line" + NL + NL +

	        "- Matches: `" + char(34) + char(34) + char(34) + "Documentation" + char(34) + char(34) + char(34) + "`, `" + char(34) + char(34) + char(34) + "Multi" + NL + "line" + char(34) + char(34) + char(34) + "`" + NL +
	        "- Non-matches: `" + char(34) + "doc" + char(34) + "`, `" + char(34) + char(34) + char(34) + "unclosed`"
    	],

	:pythonImport = [
	        "Matches Python import statements",

	        "- `^`: Start of line" + NL +
	        "- `(?:import|from)`: 'import' or 'from' keyword" + NL +
	        "- `\\s+[\\w.]+`: Module path" + NL +
	        "- `(?:\\s+import\\s+`: Optional import clause" + NL +
	        "- `(?:\\w+(?:\\s+as\\s+\\w+)?`: Import target with optional alias" + NL +
	        "- `(?:\\s*,\\s*\\w+(?:\\s+as\\s+\\w+)?)*|\\*))?`: Multiple imports or star import" + NL +
	        "- `\\s*$`: End of line" + NL + NL +

	        "- Matches: `import os`, `from sys import path`, `from x import *`" + NL +
	        "- Non-matches: `import`, `from`, `import as`"
    ],

	# JavaScript Language Patterns

	:jsString = [
		"Matches JavaScript string literals",
		
		"- `^`: Start of line" + NL +
		"- `(?:`: Non-capturing group for string types" + NL +
		"- `[" + char(34) + "].*?[" + char(34) + "]`: Double-quoted strings" + NL +
		"- `|'.*?'`: Single-quoted strings" + NL +
		"- `|`[\s\S]*?``: Template literals" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `" + char(34) + "hello" + char(34) + "`, `'world'`, ``template``" + NL +
		"- Non-matches: `hello`, `" + char(34) + "unclosed`"
	],

	:jsNumber = [
		"Matches JavaScript numeric literals",
		
		"- `^`: Start of line" + NL +
		"- `-?`: Optional negative sign" + NL +
		"- `\d+`: One or more digits" + NL +
		"- `(?:\.\d+)?`: Optional decimal portion" + NL +
		"- `(?:e[+-]?\d+)?`: Optional exponential notation" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `42`, `-3.14`, `1.2e-10`" + NL +
		"- Non-matches: `.`, `1.`, `e10`"
	],

	:jsBoolean = [
		"Matches JavaScript boolean and null values",
		
		"- `^`: Start of line" + NL +
		"- `(?:true|false|null|undefined)`: Literal values" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `true`, `false`, `null`, `undefined`" + NL +
		"- Non-matches: `True`, `FALSE`, `Null`"
	],

	:jsVariable = [
		"Matches JavaScript variable declarations",
		
		"- `^`: Start of line" + NL +
		"- `(?:var|let|const)`: Declaration keyword" + NL +
		"- `\s+`: Required whitespace" + NL +
		"- `[a-zA-Z_$][\w$]*`: Variable name" + NL +
		"- `(?:\s*=\s*.*)?`: Optional initialization" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `let x`, `const myVar = 42`" + NL +
		"- Non-matches: `x = 5`, `let 1x`"
	],

	:jsFunction = [
		"Matches JavaScript function declarations",
			
		"- `^`: Start of line" + NL +
		"- `(?:function\s+([a-zA-Z_$][\w$]*)\s*\((.*?)\)`: Named function" + NL +
		"- `|(?:async\s+)?function\s*\((.*?)\))`: Anonymous function" + NL +
		"- `\s*{`: Opening brace" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `function add(a, b) {`, `async function() {`" + NL +
		"- Non-matches: `function`, `function() => {`"
	],

	:jsArrowFunction = [
		"Matches JavaScript arrow function expressions",
			
		"- `^`: Start of line" + NL +
		"- `(?:const\s+)?`: Optional const declaration" + NL +
		"- `([a-zA-Z_$][\w$]*)\s*=\s*`: Variable assignment" + NL +
		"- `(?:async\s+)?`: Optional async keyword" + NL +
		"- `\((.*?)\)\s*=>\s*`: Arrow function syntax" + NL +
		"- `(?:{|\S.*)`: Function body" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `const add = (a, b) => {`, `sum = x => x + 1`" + NL +
		"- Non-matches: `=> {}`, `const = () =>`"
	],

	:jsClass = [
		"Matches JavaScript class declarations",
		
		"- `^`: Start of line" + NL +
		"- `class\s+`: Class keyword" + NL +
		"- `([a-zA-Z_$][\w$]*)`: Class name" + NL +
		"- `(?:\s+extends\s+([a-zA-Z_$][\w$]*))?`: Optional inheritance" + NL +
		"- `$`: End of line" + NL + NL +

		"- Matches: `class Person`, `class Student extends Person`" + NL +
		"- Non-matches: `class`, `class 1Name`"
	],
	
	:jsClassMethod = [
	    	"Matches JavaScript class method declarations",
	
	    	"- `^`: Start of line" + NL +
	    	"- `(?:async\s+)?`: Optional async keyword" + NL +
	    	"- `([a-zA-Z_$][\w$]*)`: Method name" + NL +
	    	"- `\s*\((.*?)\)\s*{`: Parameters and opening brace" + NL +
	    	"- `$`: End of line" + NL + NL +

	    	"- Matches: `getName() {`, `async calculate(x, y) {`" + NL +
	    	"- Non-matches: `method`, `123() {`"
	],

	:jsDecorator = [
    		"Matches JavaScript decorators",

	    	"- `^`: Start of line" + NL +
	    	"- `@`: Decorator symbol" + NL +
	    	"- `[a-zA-Z_$][\w$]*`: Decorator name" + NL +
	    	"- `(?:\((.*?)\))?`: Optional parameters" + NL +
	   	 "- `$`: End of line" + NL + NL +

	    	"- Matches: `@readonly`, `@validate(true)`" + NL +
	    	"- Non-matches: `@`, `@123`"
	],

	:jsLoop = [
	 	"Matches JavaScript loop statements",
	
	    	"- `^`: Start of line" + NL +
	    	"- `(?:for|while|do)`: Loop keyword" + NL +
	    	"- `\s*\(.*?\)`: Condition or iteration expression" + NL +
	    	"- `$`: End of line" + NL + NL +

	    	"- Matches: `for(let i = 0;i<10;i++)`, `while(true)`" + NL +
	    	"- Non-matches: `for`, `while`"
	],

	:jsObject = [
	    "Matches JavaScript object literals",
	
	    "- `^`: Start of line" + NL +
	    "- `{`: Opening brace" + NL +
	    "- `(?:[^{}]*|{.*?})*`: Object content" + NL +
	    "- `}`: Closing brace" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `{x: 1}`, `{a: {b: 2}}`" + NL +
	    "- Non-matches: `{`, `{a:}`"
	],

	:jsArray = [
	    "Matches JavaScript array literals",
	
	    "- `^`: Start of line" + NL +
	    "- `\[`: Opening bracket" + NL +
	    "- `(?:[^[\]]*|\[.*?\])*`: Array content" + NL +
	    "- `\]`: Closing bracket" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `[1,2,3]`, `[[1],[2]]`" + NL +
	    "- Non-matches: `[`, `[1,]`"
	],

	:jsDestructuring = [
	    "Matches JavaScript destructuring assignments",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:let|const|var)?`: Optional declaration" + NL +
	    "- `\s*(?:{[^}]*}|\[[^\]]*\])`: Destructuring pattern" + NL +
	    "- `\s*=\s*.*`: Assignment" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `const {x, y} = obj`, `let [a, b] = arr`" + NL +
	    "- Non-matches: `{a,b}`, `[x,y]`"
	],

	:jsComment = [
	    "Matches JavaScript comments",
	
	    "- `^`: Start of line" + NL +
	    "- `(?://.*|/\*[\s\S]*?\*/)`: Single or multi-line comments" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `//comment`, `/* multi-line */`" + NL +
	    "- Non-matches: `/comment`, `/*unclosed`"
	],

	:jsImport = [
	    "Matches JavaScript import statements",
	
	    "- `^`: Start of line" + NL +
	    "- `import\s+`: Import keyword" + NL +
	    "- `(?:{[^}]*}|\*\s+as\s+\w+|\w+)`: Import specifiers" + NL +
	    "- `\s+from\s+`: From keyword" + NL +
	    "- `[" + char(34) + "'].*?[" + char(34) + "']`: Module path" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `import {x} from " + char(34) + "mod" + char(34) + "`, `import * as y from 'z'`" + NL +
	    "- Non-matches: `import`, `import from`"
	],
	
	:jsExport = [
	    "Matches JavaScript export statements",
	
	    "- `^`: Start of line" + NL +
	    "- `export\s+`: Export keyword" + NL +
	    "- `(?:default\s+)?`: Optional default export" + NL +
	    "- `(?:class|function|const|let|var)`: Exported declaration" + NL +
	    "- `\s+.*`: Export name and body" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `export class X`, `export default function`" + NL +
	    "- Non-matches: `export`, `export 123`"
	],

	# Visual Basic Language Patterns

	:vbString = [
	    "Matches Visual Basic string literals",
	
	    "- `^`: Start of line" + NL +
	    "- `[" + char(34) + "]`: Opening double quote" + NL +
	    "- `.*?`: String content (non-greedy)" + NL +
	    "- `[" + char(34) + "]`: Closing double quote" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `" + char(34) + "Hello World" + char(34) + "`, `" + char(34) + "" + char(34) + "`" + NL +
	    "- Non-matches: `Hello`, `" + char(34) + "unclosed`"
	],
	
	:vbNumber = [
	    "Matches Visual Basic numeric literals",
	
	    "- `^`: Start of line" + NL +
	    "- `-?`: Optional negative sign" + NL +
	    "- `\d+`: One or more digits" + NL +
	    "- `(?:\.\d+)?`: Optional decimal portion" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `42`, `-3.14`, `1000`" + NL +
	    "- Non-matches: `.`, `1.`, `3.14.15`"
	],
	
	:vbBoolean = [
	    "Matches Visual Basic boolean literals",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:True|False)`: Boolean values" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `True`, `False`" + NL +
	    "- Non-matches: `true`, `false`, `TRUE`"
	],
	
	:vbVariable = [
	    "Matches Visual Basic variable declarations",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:Dim|Private|Public|Protected)`: Declaration scope" + NL +
	    "- `\s+`: Required whitespace" + NL +
	    "- `([a-zA-Z_]\w*)`: Variable name" + NL +
	    "- `\s+As\s+`: Type declaration" + NL +
	    "- `\w+`: Variable type" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Dim count As Integer`, `Public name As String`" + NL +
	    "- Non-matches: `Dim x`, `Private 1var As Integer`"
	],
	
	:vbFunction = [
	    "Matches Visual Basic function declarations",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:Public\s+|Private\s+|Protected\s+)?`: Optional scope" + NL +
	    "- `Function\s+`: Function keyword" + NL +
	    "- `([a-zA-Z_]\w*)`: Function name" + NL +
	    "- `\s*\((.*?)\)`: Parameters" + NL +
	    "- `\s+As\s+\w+`: Return type" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Function Add(x As Integer, y As Integer) As Integer`" + NL +
	    "- Non-matches: `Function`, `Public Function()`"
	],
	
	:vbSub = [
	    "Matches Visual Basic subroutine declarations",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:Public\s+|Private\s+|Protected\s+)?`: Optional scope" + NL +
	    "- `Sub\s+`: Sub keyword" + NL +
	    "- `([a-zA-Z_]\w*)`: Subroutine name" + NL +
	    "- `\s*\((.*?)\)`: Parameters" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Public Sub Initialize()`, `Private Sub HandleClick(sender As Object)`" + NL +
	    "- Non-matches: `Sub`, `Public Sub`"
	],
	
	:vbFunctionCall = [
	    "Matches Visual Basic function calls",
	
	    "- `^`: Start of line" + NL +
	    "- `([a-zA-Z_]\w*)`: Function name" + NL +
	    "- `\s*\((.*?)\)`: Function arguments" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Calculate()`, `Add(x, y)`" + NL +
	    "- Non-matches: `Call()`, `1Function()`"
	],
	
	:vbClass = [
	    "Matches Visual Basic class declarations",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:Public\s+|Private\s+)?`: Optional scope" + NL +
	    "- `Class\s+`: Class keyword" + NL +
	    "- `([a-zA-Z_]\w*)`: Class name" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Public Class Customer`, `Private Class Helper`" + NL +
	    "- Non-matches: `Class`, `Public Class 1Name`"
	],
	
	:vbInterface = [
	    "Matches Visual Basic interface declarations",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:Public\s+|Private\s+)?`: Optional scope" + NL +
	    "- `Interface\s+`: Interface keyword" + NL +
	    "- `([a-zA-Z_]\w*)`: Interface name" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Public Interface IDisposable`, `Interface IComparable`" + NL +
	    "- Non-matches: `Interface`, `Public Interface 1Name`"
	],
	
	:vbProperty = [
	    "Matches Visual Basic property declarations",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:Public\s+|Private\s+|Protected\s+)?`: Optional scope" + NL +
	    "- `Property\s+`: Property keyword" + NL +
	    "- `(?:Get|Let|Set)`: Property type" + NL +
	    "- `\s+([a-zA-Z_]\w*)`: Property name" + NL +
	    "- `\s*\((.*?)\)`: Parameters" + NL +
	    "- `\s+As\s+\w+`: Return type" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Property Get Name() As String`, `Public Property Let Value(v As Integer)`" + NL +
	    "- Non-matches: `Property`, `Property Get`"
	],
	
	:vbLoop = [
	    "Matches Visual Basic loop statements",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:For|Do|While|For\s+Each)`: Loop keywords" + NL +
	    "- `\s+.*`: Loop condition or iteration" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `For i = 1 To 10`, `Do While condition`, `For Each item In collection`" + NL +
	    "- Non-matches: `For`, `While`"
	],
	
	:vbIf = [
	    "Matches Visual Basic if statements",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:If|ElseIf|Else)`: Conditional keywords" + NL +
	    "- `\s+.*?\s+`: Condition (if applicable)" + NL +
	    "- `Then`: Required for If/ElseIf" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `If x > 0 Then`, `ElseIf count = 0 Then`, `Else Then`" + NL +
	    "- Non-matches: `If`, `If x > 0`"
	],
	
	:vbSelect = [
	    "Matches Visual Basic select case statements",
	
	    "- `^`: Start of line" + NL +
	    "- `Select\s+Case\s+`: Select Case keywords" + NL +
	    "- `.*`: Expression being tested" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Select Case x`, `Select Case day`" + NL +
	    "- Non-matches: `Select`, `Case`"
	],
	
	:vbTry = [
	    "Matches Visual Basic error handling blocks",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:Try|Catch|Finally)`: Error handling keywords" + NL +
	    "- `\s*`: Optional whitespace" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Try`, `Catch`, `Finally`" + NL +
	    "- Non-matches: `Try Catch`, `Catch Error`"
	],
	
	:vbArray = [
	    "Matches Visual Basic array declarations",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:Dim|Private|Public|Protected)`: Declaration scope" + NL +
	    "- `\s+([a-zA-Z_]\w*)`: Array name" + NL +
	    "- `\s*\(\s*\d*\s*\)`: Array dimensions" + NL +
	    "- `\s+As\s+\w+`: Array type" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Dim numbers(10) As Integer`, `Public matrix(,) As Double`" + NL +
	    "- Non-matches: `Dim array`, `Private arr() As`"
	],
	
	:vbCollection = [
	    "Matches Visual Basic collection instantiation",
	
	    "- `^`: Start of line" + NL +
	    "- `New\s+`: New keyword" + NL +
	    "- `Collection`: Collection type" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `New Collection`" + NL +
	    "- Non-matches: `Collection`, `New List`"
	],
	
	:vbComment = [
	    "Matches Visual Basic single-line comments",
	
	    "- `^`: Start of line" + NL +
	    "- `'`: Comment character" + NL +
	    "- `.*`: Comment text" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `'This is a comment`, `' Note:`" + NL +
	    "- Non-matches: `//comment`, `REM comment`"
	],
	
	:vbRemark = [
	    "Matches Visual Basic REM comments",
	
	    "- `^`: Start of line" + NL +
	    "- `REM\s+`: REM keyword with space" + NL +
	    "- `.*`: Comment text" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `REM This is a remark`, `REM Debug code below`" + NL +
	    "- Non-matches: `REM`, `'REM comment`"
	],
	
	:vbModule = [
	    "Matches Visual Basic module declarations",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:Public\s+|Private\s+)?`: Optional scope" + NL +
	    "- `Module\s+`: Module keyword" + NL +
	    "- `([a-zA-Z_]\w*)`: Module name" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Module Utils`, `Public Module Constants`" + NL +
	    "- Non-matches: `Module`, `Module 1Name`"
	],
	
	:vbNamespace = [
	    "Matches Visual Basic namespace declarations",
	
	    "- `^`: Start of line" + NL +
	    "- `Namespace\s+`: Namespace keyword" + NL +
	    "- `[\w.]+`: Namespace path" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Namespace MyApp`, `Namespace System.Data`" + NL +
	    "- Non-matches: `Namespace`, `Namespace 1.2`"
	],
	
	:vbImports = [
	    "Matches Visual Basic imports statements",
	
	    "- `^`: Start of line" + NL +
	    "- `Imports\s+`: Imports keyword" + NL +
	    "- `[\w.]+`: Imported namespace" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Imports System`, `Imports System.Collections.Generic`" + NL +
	    "- Non-matches: `Imports`, `Imports 1.System`"
	],
	
	:vbReference = [
	    "Matches Visual Basic reference declarations",
	
	    "- `^`: Start of line" + NL +
	    "- `Reference\s+=\s+`: Reference assignment" + NL +
	    "- `.*`: Reference path or name" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Reference = System`, `Reference = " + char(34) + "MyLib.dll" + char(34) + "`" + NL +
	    "- Non-matches: `Reference`, `Reference ==`"
	],
	
	# Julia Language Patterns

	:juliaString = [
	    "Matches Julia string literals including triple-quoted, regular, raw, and literal strings",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:`: Start non-capturing group for string types" + NL +
	    "- `[" + char(34) + "]{3}.*?[" + char(34) + "]{3}`: Triple-quoted strings" + NL +
	    "- `|[" + char(34) + "].*?[" + char(34) + "]`: Regular strings" + NL +
	    "- `|r[" + char(34) + "].*?[" + char(34) + "]`: Raw strings" + NL +
	    "- `|raw[" + char(34) + "].*?[" + char(34) + "])`: Literal strings" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `" + char(34) + "hello" + char(34) + "`, `" + char(34) + char(34) + char(34) + "multiline" + char(34) + char(34) + char(34) + "`, `r" + char(34) + "raw\string" + char(34) + "`" + NL +
	    "- Non-matches: `'string'`, `" + char(34) + "unclosed`"
	],
	
	:juliaNumber = [
	    "Matches Julia numeric literals including integers, floats, and scientific notation",
	
	    "- `^`: Start of line" + NL +
	    "- `-?`: Optional negative sign" + NL +
	    "- `(?:\\d+(?:\\.\\d*)?|\\.\\d+)`: Integer or decimal number" + NL +
	    "- `(?:e[+-]?\\d+)?`: Optional scientific notation" + NL +
	    "- `(?:[ff]32|f64)?`: Optional float type suffix" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `42`, `-3.14`, `1.2e-10`, `3.14f32`" + NL +
	    "- Non-matches: `.`, `1.`, `e10`"
	],
	
	:juliaBoolean = [
	    "Matches Julia boolean and special value literals",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:true|false|nothing|missing)`: Boolean or special values" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `true`, `false`, `nothing`, `missing`" + NL +
	    "- Non-matches: `True`, `NULL`, `nil`"
	],
	
	:juliaVariable = [
	    "Matches Julia variable identifiers",
	
	    "- `^`: Start of line" + NL +
	    "- `[a-zA-Z_]`: First character must be letter or underscore" + NL +
	    "- `[\\w!]*`: Followed by word characters or exclamation mark" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `x`, `myVar`, `function!`, `_temp`" + NL +
	    "- Non-matches: `1x`, `$var`"
	],
	
	:juliaFunction = [
	    "Matches Julia function declarations with optional type annotations and where clauses",
	
	    "- `^`: Start of line" + NL +
	    "- `function\\s+`: Function keyword" + NL +
	    "- `([a-zA-Z_][\\w!]*)`: Function name" + NL +
	    "- `\\s*\\(([^)]*?)\\)`: Parameter list" + NL +
	    "- `(?:\\s*::\\s*[\\w{}.\\[\\]]+)?`: Optional return type" + NL +
	    "- `(?:where\\s+{.*?})?`: Optional where clause" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `function add(x, y)`, `function multiply(x::Int, y::Int)::Int`" + NL +
	    "- Non-matches: `function`, `function()`"
	],
	
	:juliaFunctionCall = [
	    "Matches Julia function calls",
	
	    "- `^`: Start of line" + NL +
	    "- `([a-zA-Z_][\\w!]*)`: Function name" + NL +
	    "- `\\s*\\((.*?)\\)`: Function arguments" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `println(x)`, `add!(1, 2)`" + NL +
	    "- Non-matches: `call x`, `1func()`"
	],
	
	:juliaLambda = [
	    "Matches Julia lambda expressions and anonymous functions",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:[^->]+->|function\\s*\\([^)]*\\))`: Lambda syntax or anonymous function" + NL +
	    "- `.*`: Function body" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `x -> x^2`, `function (x) x + 1 end`" + NL +
	    "- Non-matches: `->`, `function`"
	],
	
	:juliaStruct = [
	    "Matches Julia struct declarations with optional mutability and type parameters",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:mutable\\s+)?`: Optional mutability" + NL +
	    "- `struct\\s+`: Struct keyword" + NL +
	    "- `([a-zA-Z_][\\w!]*)`: Struct name" + NL +
	    "- `(?:{.*?})?`: Optional type parameters" + NL +
	    "- `(?:<:\\s*[\\w.]+)?`: Optional supertype" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `struct Point`, `mutable struct User{T}`" + NL +
	    "- Non-matches: `struct`, `struct 1Point`"
	],
	
	:juliaAbstract = [
	    "Matches Julia abstract type declarations",
	
	    "- `^`: Start of line" + NL +
	    "- `abstract\\s+type\\s+`: Abstract type keywords" + NL +
	    "- `([a-zA-Z_][\\w!]*)`: Type name" + NL +
	    "- `(?:{.*?})?`: Optional type parameters" + NL +
	    "- `(?:<:\\s*[\\w.]+)?`: Optional supertype" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `abstract type Number`, `abstract type Array{T} <: AbstractArray`" + NL +
	    "- Non-matches: `abstract`, `type Number`"
	],
	
	:juliaMacro = [
	    "Matches Julia macro invocations",
	
	    "- `^`: Start of line" + NL +
	    "- `@`: Macro symbol" + NL +
	    "- `[a-zA-Z_][\\w!]*`: Macro name" + NL +
	    "- `(?:\\s|$)`: Space or end of line" + NL + NL +

	    "- Matches: `@time`, `@async`" + NL +
	    "- Non-matches: `@`, `@1macro`"
	],
	
	:juliaLoop = [
	    "Matches Julia loop constructs",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:for\\s+.*?\\s+in\\s+.*?|while\\s+.*?)`: For or while loops" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `for i in 1:10`, `while x < 100`" + NL +
	    "- Non-matches: `for`, `while`"
	],
	
	:juliaIf = [
	    "Matches Julia conditional statements",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:if|elseif|else)`: Conditional keywords" + NL +
	    "- `\\s*.*?`: Condition (if applicable)" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `if x > 0`, `elseif isempty(arr)`, `else`" + NL +
	    "- Non-matches: `ifdef`, `elsif`"
	],
	
	:juliaBegin = [
	    "Matches Julia begin blocks",
	
	    "- `^`: Start of line" + NL +
	    "- `begin`: Begin keyword" + NL +
	    "- `\\s*`: Optional whitespace" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `begin`, `begin `" + NL +
	    "- Non-matches: `begins`, `begin{`"
	],
	
	:juliaTry = [
	    "Matches Julia exception handling blocks",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:try|catch|finally)`: Exception handling keywords" + NL +
	    "- `\\s*.*?`: Optional clause" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `try`, `catch e`, `finally`" + NL +
	    "- Non-matches: `trying`, `catch{`"
	],
	
	:juliaArray = [
	    "Matches Julia array literals",
	
	    "- `^`: Start of line" + NL +
	    "- `\\[`: Opening bracket" + NL +
	    "- `(?:[^\\[\\]]*|\\[.*?\\])*`: Array elements" + NL +
	    "- `\\]`: Closing bracket" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `[1, 2, 3]`, `[[1, 2], [3, 4]]`" + NL +
	    "- Non-matches: `[`, `[1,]`"
	],
	
	:juliaTuple = [
	    "Matches Julia tuple literals",
	
	    "- `^`: Start of line" + NL +
	    "- `\\(`: Opening parenthesis" + NL +
	    "- `(?:[^()]*|\\(.*?\\))*`: Tuple elements" + NL +
	    "- `\\)`: Closing parenthesis" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `(1, 2)`, `(x = 1, y = 2)`" + NL +
	    "- Non-matches: `(`, `(1,`"
	],
	
	:juliaDict = [
	    "Matches Julia dictionary literals",
	
	    "- `^`: Start of line" + NL +
	    "- `Dict\\(`: Dict constructor" + NL +
	    "- `(?:[^()]*|\\(.*?\\))*`: Dictionary key-value pairs" + NL +
	    "- `\\)`: Closing parenthesis" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Dict()`, `Dict(:a => 1, :b => 2)`" + NL +
	    "- Non-matches: `Dict`, `Dict[`"
	],
	
	:juliaComprehension = [
	    "Matches Julia array comprehensions",
	
	    "- `^`: Start of line" + NL +
	    "- `\\[`: Opening bracket" + NL +
	    "- `.*?\\s+for\\s+.*?\\s+in\\s+.*?`: Comprehension syntax" + NL +
	    "- `\\]`: Closing bracket" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `[x^2 for x in 1:10]`, `[i+j for i in 1:3 for j in 1:3]`" + NL +
	    "- Non-matches: `[for in]`, `[x for x]`"
	],
	
	:juliaComment = [
	    "Matches Julia comments (single-line and multi-line)",
	
	    "- `^`: Start of line" + NL +
	    "- `#=(?:[^=#]|=(?!#))*=#`: Multi-line comments" + NL +
	    "- `|^#.*`: Single-line comments" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `# comment`, `#= multi-line comment =#`" + NL +
	    "- Non-matches: `//comment`, `/* comment */`"
	],
	
	:juliaDocString = [
	    "Matches Julia documentation strings",
	
	    "- `^`: Start of line" + NL +
	    "- `[" + char(34) + "]{3}`: Three double quotes" + NL +
	    "- `[\\s\\S]*?`: Documentation content" + NL +
	    "- `[" + char(34) + "]{3}`: Closing three double quotes" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `" + char(34) + char(34) + char(34) + "Function documentation" + char(34) + char(34) + char(34) + "`" + NL +
	    "- Non-matches: `" + char(34) + "doc" + char(34) + "`, `" + char(34) + char(34) + char(34) + "unclosed`"
	],
	
	:juliaImport = [
	    "Matches Julia import and using statements",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:using|import)`: Import keywords" + NL +
	    "- `\\s+`: Required whitespace" + NL +
	    "- `(?:[\\w.]+`: Module path" + NL +
	    "- `(?:\\s*:\\s*(?:[\\w,\\s]+|\\(.*?\\)))?`: Optional specific imports" + NL +
	    "- `(?:\\s*,\\s*[\\w.]+(?:\\s*:\\s*(?:[\\w,\\s]+|\\(.*?\\)))?)*)`: Additional imports" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `using LinearAlgebra`, `import Base: show, print`" + NL +
	    "- Non-matches: `using`, `import 1.2`"
	],
	
	:juliaModule = [
	    "Matches Julia module declarations",
	
	    "- `^`: Start of line" + NL +
	    "- `module\\s+`: Module keyword" + NL +
	    "- `[a-zA-Z_][\\w!]*`: Module name" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `module MyModule`, `module Utils`" + NL +
	    "- Non-matches: `module`, `module 1Name`"
	],
	
	:juliaExport = [
	    "Matches Julia export statements",
	
	    "- `^`: Start of line" + NL +
	    "- `export\\s+`: Export keyword" + NL +
	    "- `(?:[a-zA-Z_][\\w!]*`: First exported name" + NL +
	    "- `(?:\\s*,\\s*[a-zA-Z_][\\w!]*)*)`: Additional exported names" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `export foo`, `export foo, bar, baz`" + NL +
	    "- Non-matches: `export`, `export 1func`"
	],
	
	:juliaTypeParameter = [
	    "Matches Julia type parameter declarations",
	
	    "- `^`: Start of line" + NL +
	    "- `(?:[a-zA-Z_][\\w!]*)`: Type name" + NL +
	    "- `{.*?}`: Type parameters in curly braces" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `Array{T}`, `Dict{K,V}`, `Container{Type}`" + NL +
	    "- Non-matches: `T{}`, `Array{}`"
	],
	
	:juliaTypeAnnotation = [
	    "Matches Julia type annotations",
	
	    "- `^`: Start of line" + NL +
	    "- `::`: Type annotation operator" + NL +
	    "- `\\s*`: Optional whitespace" + NL +
	    "- `[\\w{}.\\[\\]]+`: Type specification" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `::Int`, `::Array{Float64,2}`, `::Dict{String,Any}`" + NL +
	    "- Non-matches: `:Int`, `:: `"
	],
	
	:juliaBroadcast = [
	    "Matches Julia broadcast operators",
	
	    "- `^`: Start of line" + NL +
	    "- `\\.`: Dot operator" + NL +
	    "- `\\w+`: Function or operator name" + NL +
	    "- `$`: End of line" + NL + NL +

	    "- Matches: `.+`, `.^`, `.sqrt`" + NL +
	    "- Non-matches: `.`, `.@`, `.1`"
	],

	# Excel FORMULAT Patterns

	:xlsFunctionCall = [
	    "Matches an Excel function call",
	
	    "- `^\\s*`: Allows leading whitespace" + NL +
	    "- `[A-Z]+`: Matches the function name (uppercase letters)" + NL +
	    "- `\\(.*\\)$`: Matches the opening parenthesis, arguments, and closing parenthesis" + NL + NL +

	    "- Matches: `SUM(A1:A10)`, ` IF(A1>0, TRUE, FALSE)`" + NL +
	    "- Non-matches: `sum(A1:A10)`, `SUM A1:A10`"
	],
	
	:xlsCellReference = [
	    "Matches a single Excel cell reference",
	
	    "- `^[A-Z]+`: Matches the column (letters A to Z)" + NL +
	    "- `\\d+$`: Matches the row (numeric part)" + NL + NL +

	    "- Matches: `A1`, `B12`, `ZZ100`" + NL +
	    "- Non-matches: `1A`, `ABCD`, `A 1`"
	],
	
	:xlsRangeReference = [
	    "Matches an Excel range reference",
	
	    "- `^[A-Z]+\\d+`: Matches the start cell of the range" + NL +
	    "- `:[A-Z]+\\d+$`: Matches the colon and the end cell of the range" + NL + NL +

	    "- Matches: `A1:B10`, `C5:D7`, `Z1:Z100`" + NL +
	    "- Non-matches: `A1:B`, `A1-10`, `1A:B2`"
	],
	
	:xlsRelativeReference = [
	    "Matches a relative Excel cell reference",
	
	    "- `^(?:[A-Z]*\\d+|[A-Z]+\\d*)$`: Matches either column-relative or row-relative references" + NL + NL +

	    "- Matches: `A1`, `1`, `A`" + NL +
	    "- Non-matches: `$A$1`, `$1`, `$A`"
	],
	
	:xlsAbsoluteReference = [
	    "Matches an absolute Excel cell reference",
	
	    "- `^\\$[A-Z]+`: Matches the dollar sign and absolute column reference" + NL +
	    "- `\\$\\d+$`: Matches the dollar sign and absolute row reference" + NL + NL +

	    "- Matches: `$A$1`, `$B$100`" + NL +
	    "- Non-matches: `A1`, `1`, `$A1`"
	],
	
	:xlsMixedReference = [
	    "Matches a mixed Excel cell reference",
	
	    "- `^(?:\\$[A-Z]+\\d+|[A-Z]+\\$\\d+)$`: Matches either absolute column/relative row or relative column/absolute row references" + NL + NL +

	    "- Matches: `$A1`, `A$1`, `$B$2`" + NL +
	    "- Non-matches: `A1`, `$A$1`, `B2$`"
	],
	
	:xlsStringLiteral = [
	    "Matches a string literal in Excel",
	
	   "- `^\" + char(34) + " + char(34) + " + char(34) + ".*\" + char(34) + " + char(34) + " + char(34) + "$`: Matches a string enclosed in double quotes" + NL + NL +

	   "- Matches: `\" + char(34) + "Hello\" + char(34) + "`, `\" + char(34) + "123\" + char(34) + "`, `\" + char(34) + "A1:B10\" + char(34) + "`" + NL +
	    "- Non-matches: `Hello`, `'Hello'`, `\" + char(34) + "Hello`"
	],
	
	:xlsNumberLiteral = [
	    "Matches a numeric literal in Excel",
	
	    "- `^-?\\d+(\\.\\d+)?$`: Matches an integer or decimal number, optionally negative" + NL + NL +

	    "- Matches: `123`, `-45`, `3.14`, `-0.5`" + NL +
	    "- Non-matches: `123A`, `3,14`, `.`"
	],
	
	:xlsBooleanLiteral = [
	    "Matches a boolean literal in Excel",
	
	    "- `^(TRUE|FALSE)$`: Matches the literals TRUE or FALSE (case-sensitive)" + NL + NL +

	    "- Matches: `TRUE`, `FALSE`" + NL +
	    "- Non-matches: `true`, `false`, `1`"
	],
	
	:xlsArithmeticExpression = [
	    "Matches an Excel arithmetic expression",
	
	    "- `^.*(?:[+\\-*/^]).*$`: Matches any formula containing arithmetic operators" + NL + NL +

	    "- Matches: `A1+A2`, `B1-B2`, `3*4`, `5/2`, `2^3`" + NL +
	    "- Non-matches: `A1A2`, `3*`, `*4`"
	],
	
	:xlsConditionalExpression = [
	    "Matches an Excel conditional expression",
	
	    "- `^.*(?:=|<|>|<>).*$`: Matches any formula containing comparison operators" + NL + NL +

	    "- Matches: `A1=A2`, `B1<>C1`, `A1>10`, `5<=6`" + NL +
	    "- Non-matches: `A1A2`, `=A1`, `<B2`"
	],

	:xlsArrayFormula = [
	"Matches an Excel array formula",

		"- `^\\{`: Matches the opening curly brace for the array formula" + NL +
		"- `(?:`: Start of a non-capturing group" + NL +
		"- `\\s*=\\s*[A-Za-z]+\\([^\\)]*\\)`: Matches a formula starting with an equal sign, a function name, and arguments enclosed in parentheses" + NL +
		"- `|`: Alternation to match either a function or plain array values" + NL +
		"- `\\s*[A-Za-z0-9\\+\\-\\*/\\(\\)\\&\\^\\.]+`: Matches numeric or textual values, operators, and parenthesized expressions" + NL +
		"- `(\\s*,\\s*[A-Za-z0-9\\+\\-\\*/\\(\\)\\&\\^\\.]+)*`: Optionally matches additional array elements separated by commas" + NL +
		"- `\\s*`: Allows trailing whitespace" + NL +
		"- `\\}`: Matches the closing curly brace for the array formula" + NL +
		"- `$`: Ensures the entire string matches the pattern" + NL + NL +

		"- Matches: `{=SUM(A1:A10)}`, `{1, 2, 3}`, `{A1+B1, C1*D1}`" + NL +
		"- Non-matches: `{SUM(A1:A10}`, `{1, 2}`, `=SUM(A1:A10)`"
	],

	# R language patterns

	:rVariableName = [
		"Matches valid variable names in R",

		"- `^[A-Za-z.]`: Starts with a letter or a period (but not followed by a number)." + NL +
		"- `[A-Za-z0-9._]*`: Can include letters, digits, periods, and underscores." + NL + NL +

		"- Matches: `x`, `.myVar`, `data_1`." + NL +
		"- Non-matches: `1variable`, `var-name` (invalid characters)."
	],

	:rFunctionCall = [
		"Matches valid R function calls",

		"- `^[A-Za-z.][A-Za-z0-9._]*`: Matches a valid function name." + NL +
		"- `\\s*\\(.*\\)$`: Ensures the function is followed by parentheses with optional arguments inside." + NL + NL +

		"- Matches: `sum(1, 2)`, `myFunc(a = 1)`." + NL +
		"- Non-matches: `sum`, `1sum()` (invalid function name)."
	],

	:rAssignment = [
		"Matches R assignment statements",

		"- `^\\s*`: Optional leading whitespace." + NL +
		"- `[A-Za-z.][A-Za-z0-9._]*`: Matches a valid variable name." + NL +
		"- `\\s*(<-|=)\\s*`: Matches the assignment operator (`<-` or `=`)." + NL +
		"- `.*$`: Matches the assigned value." + NL + NL +

		"- Matches: `x <- 5`, `myVar = c(1, 2, 3)`." + NL +
		"- Non-matches: `<- x 5` (wrong order)."
	],

	:rNumericVector = [
		"Matches R numeric vector syntax",

		"- `^c\\(`: Starts with the `c(` function." + NL +
		"- `(\\s*-?\\d+(\\.\\d+)?\\s*(,\\s*-?\\d+(\\.\\d+)?\\s*)*)?`: Matches one or more numeric values separated by commas." + NL +
		"- `\\)$`: Ends with a closing parenthesis." + NL + NL +

		"- Matches: `c(1, 2, 3)`, `c(-1.5, 0.5)`." + NL +
		"- Non-matches: `c(1; 2; 3)`, `c()` (invalid delimiters or empty vector)."
	],

	:rStringVector = [
		"Matches R string vector syntax",

		"- `^c\\(`: Starts with the `c(` function." + NL +
		"- `(\\s*\" + char(34) + ".*?\" + char(34) + "\\s*(,\\s*\" + char(34) + ".*?\" + char(34) + "\\s*)*)?`: Matches one or more quoted strings separated by commas." + NL +
		"- `\\)$`: Ends with a closing parenthesis." + NL + NL +

		"- Matches: `c(\" + char(34) + "apple\" + char(34) + ", \" + char(34) + "banana\" + char(34) + ")`, `c(\" + char(34) + "hello\" + char(34) + ")`." + NL +
		"- Non-matches: `c(apple, banana)`, `c()` (missing quotes or empty vector)."
	],

	:rDataFrame = [
		"Matches R data frame creation statements",

		"- `^[A-Za-z.][A-Za-z0-9._]*`: Matches a valid variable name for the data frame." + NL +
		"- `\\s*<-\\s*`: Matches the assignment operator with optional whitespace." + NL +
		"- `data\\.frame\\(.*\\)$`: Matches the `data.frame` function with arguments inside." + NL + NL +

		"- Matches: `df <- data.frame(a = 1:5, b = letters[1:5])`." + NL +
		"- Non-matches: `data.frame(a = 1:5)` (missing assignment)."
	],

	:rPipeOperator = [
		"Matches the pipe operator `%>%` in R",

		"- `\\s*%>%\\s*`: Matches the `%>%` operator with optional surrounding whitespace." + NL + NL +

		"- Matches: `data %>% filter(x > 1)`, `a %>% b %>% c`." + NL +
		"- Non-matches: `data |> filter(x > 1)` (different pipe operator)."
	],

	:rComment = [
    		"Matches R comments",

		"- `^\\s*`: Optional leading whitespace." + NL +
		"- `#.*$`: Matches a `#` followed by any characters until the end of the line." + NL + NL +

		"- Matches: `# This is a comment`, `   # Indented comment`." + NL +
		"- Non-matches: `This is not a comment`."
	],

	:rLogicalOperator = [
		"Matches logical operators in R",

		"- `(\\&\\&|\\|\\||\\!|==|!=|<|<=|>|>=)`: Matches logical and comparison operators." + NL + NL +

		"- Matches: `&&`, `||`, `!`, `==`, `!=`, `<`, `<=`, `>`, `>=`." + NL +
		"- Non-matches: `&` (element-wise operator) or invalid syntax."
	],

	:rIndexing = [
		"Matches indexing operations",

		"- `\\[.*?\\]`: Matches square brackets with any content inside (non-greedy)." + NL + NL +

		"- Matches: `x[1]`, `df[1, 2]`, `list[[3]]`." + NL +
		"- Non-matches: `x1` (no brackets), `df[[1, 2]]` (invalid double-bracket indexing)."
	],

	:rForLoop = [
		"Matches R `for` loops",

		"- `^\\s*for\\s*\\(`: Starts with `for` keyword and a parenthesis." + NL +
		"- `[A-Za-z.][A-Za-z0-9._]*`: Matches the loop variable name." + NL +
		"- `in\\s*.*\\)\\s*\\{`: Matches the `in` keyword and loop range followed by `{`." + NL + NL +

		"- Matches: `for (i in 1:10) {`, `for (name in names(vector)) {`." + NL +
		"- Non-matches: `for i in 1:10` (missing parentheses)."
	],

	:rIfStatement = [
		"Matches R `if` statements",

		"- `^\\s*if\\s*\\(`: Starts with `if` keyword and a parenthesis." + NL +
		"- `.*\\)\\s*\\{`: Matches any condition followed by a closing parenthesis and `{`." + NL +
		"- Matches: `if (x > 1) {`, `if (length(vec) == 0) {`." + NL +
		"- Non-matches: `if x > 1 {` (missing parentheses)."
	],

	:rElseStatement = [
		"Matches R `else` statements",

		"- `^\\s*else\\s*\\{`: Matches the `else` keyword followed by `{`." + NL +
		"- Matches: `else {`." + NL +
		"- Non-matches: `else x = 1` (missing `{`)."
	],

	:rLibraryCall = [
		"Matches library or package loading calls",

		"- `^\\s*(library|require)\\s*\\(`: Matches `library` or `require` followed by a parenthesis." + NL +
		"- Matches: `library(ggplot2)`, `require(dplyr)`." + NL +
		"- Non-matches: `load(ggplot2)` (wrong function)."
	],

	:rFunctionDefinition = [
		"Matches R function definitions",

		"- `^[A-Za-z.][A-Za-z0-9._]*\\s*<-\\s*function\\s*\\(`: Matches a valid function name assigned to a function declaration." + NL +
		"- Matches: `myFunc <- function(x) {`." + NL +
		"- Non-matches: `function(x) {` (missing assignment)."
	],

	:rListCreation = [
		"Matches R list creation",

		"- `^list\\(.*\\)$`: Matches the `list` function with any content inside." + NL +
		"- Matches: `list(a = 1, b = 2)`, `list()`." + NL +
		"- Non-matches: `lst(a = 1)` (invalid function name)."
	],

	:rApplyFamily = [
		"Matches functions from the apply family",

		"- `(apply|lapply|sapply|vapply|mapply|tapply)\\s*\\(.*\\)`: Matches any apply function followed by arguments." + NL +
		"- Matches: `apply(matrix, 1, sum)`, `lapply(list, mean)`." + NL +
		"- Non-matches: `applysum(matrix, 1)` (wrong function)."
	],

	# Credit cards and Bank accounts

	:creditCard = [
		"Matches credit card numbers",

		"- `^\\d{4}[- ]?\\d{4}[- ]?\\d{4}[- ]?\\d{4}$`: Matches 16-digit numbers grouped in 4 digits separated by spaces or hyphens, or no separators." + NL + NL +

		"- Matches: `1234 5678 9012 3456`, `1234-5678-9012-3456`, `1234567890123456`." + NL +
		"- Non-matches: `1234 5678 90123`, `12345 6789`, `abcd efgh`."
	],

	:bankAccount = [
		"Matches generic bank account numbers",

		"- `^\\d{8,20}$`: Matches numeric strings between 8 and 20 digits." + NL + NL +

		"- Matches: `12345678`, `98765432101234567890`." + NL +
		"- Non-matches: `1234567`, `12345abcd`, `123456789012345678901`."
	],

	:iban = [
		"Matches International Bank Account Numbers (IBAN)",

		"- `^[A-Z]{2}\\d{2}[A-Z0-9]{1,30}$`: Starts with a 2-letter country code, 2-digit checksum, and up to 30 alphanumeric characters." + NL + NL +

		"- Matches: `GB29NWBK60161331926819`, `DE89370400440532013000`." + NL +
		"- Non-matches: `1234`, `GB29 NWBK60161331926819`."
	],

	:swiftCode = [
		"Matches SWIFT/BIC codes",

		"- `^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$`: Matches 8 or 11-character alphanumeric strings with specific formats." + NL + NL +

		"- Matches: `DEUTDEFF`, `BOFAUS3NXXX`." + NL +
		"- Non-matches: `DEUT1234`, `BOFAUS`."
	],

	# Mathematic formulas

	:simpleEquation = [
		"Matches basic mathematical equations",

		"- `^[A-Za-z0-9\\+\\-\\*/=\\(\\)\\.\\^\\s]+$`: Allows letters, digits, operators, parentheses, decimal points, and spaces." + NL + NL +

		"- Matches: `x + y = 10`, `2 * (a + b) = 3`." + NL +
		"- Non-matches: `x = y & z`, `x ^ 2 == 10`."
	],

	:quadraticFormula = [
    		"Matches quadratic equations",

    		"- `^-?\\d*[A-Za-z]\\^2\\s*[+-]?\\s*\\d*[A-Za-z]\\s*[+-]?\\s*\\d+\\s*=\\s*0$`: Matches equations of the form `ax^2 + bx + c = 0`." + NL + NL +

    		"- Matches: `x^2 + 3x + 2 = 0`, `-5y^2 - y + 1 = 0`." + NL +
    		"- Non-matches: `x + y = 10`, `x^2 + y + 1`."
	],

	# DNA and Chemistry

	:dnaSequence = [
    		"Matches valid DNA sequences",

		"- `^[ACGT]+$`: Matches strings containing only the characters `A`, `C`, `G`, and `T`." + NL + NL +

		"- Matches: `ACGT`, `AGCTAGCT`." + NL +
		"- Non-matches: `ACGUX`, `ACG T`."
	],

	:chemicalFormula = [
		"Matches valid chemical formulas",

		"- `^[A-Z][a-z]?\\d*(?:[A-Z][a-z]?\\d*)*$`: Matches element symbols (capital letter with optional lowercase letter) followed by optional digits." + NL + NL +

		"- Matches: `H2O`, `C6H12O6`, `NaCl`." + NL +
		"- Non-matches: `H20O`, `123H`, `HO2C6`."
	],

	# Measurements

	:metricMeasurement = [
		"Matches metric system measurements",

		"- `^\\d+(\\.\\d+)?\\s?(mm|cm|m|km)$`: Matches numeric values with optional decimals followed by a metric unit." + NL + NL +

		"- Matches: `10 cm`, `2.5 km`, `3m`." + NL +
		"- Non-matches: `10in`, `2.5 cm km`."
	],

	:imperialMeasurement = [
		"Matches imperial system measurements",

		"- `^\\d+(\\.\\d+)?\\s?(in|ft|yd|mi)$`: Matches numeric values with optional decimals followed by an imperial unit." + NL + NL +

		"- Matches: `5 ft`, `12.3 in`, `0.5 mi`." + NL +
		"- Non-matches: `5cm`, `1 ft yd`."
	],

	:temperature = [
		"Matches temperature values",

		"- `^-?\\d+(\\.\\d+)?\\s?(°C|°F|K)$`: Matches numeric values with optional decimals and optional negative sign, followed by a temperature unit." + NL + NL +

		"- Matches: `25°C`, `-10.5°F`, `300K`." + NL +
		"- Non-matches: `25 degrees`, `10C`, `K300`."
	],

	# Barcodes, QR-codes and Alike

	:upc = [
		"Matches Universal Product Code (UPC) barcodes",

		"- `^\\d{12}$`: Matches exactly 12 digits." + NL + NL +

		"- Matches: `012345678905`, `123456789012`." + NL +
		"- Non-matches: `0123456789`, `0123456789012`, `1234-5678-9012`."
	],

	:ean13 = [
		"Matches European Article Number (EAN-13) barcodes",

		"- `^\\d{13}$`: Matches exactly 13 digits." + NL + NL +

		"- Matches: `4006381333931`, `1234567890128`." + NL +
		"- Non-matches: `123456789012`, `12345678901234`, `EAN4006381333931`."
	],

	:code128 = [
		"Matches Code 128 barcodes",

		"- `^[!-~]+$`: Matches one or more printable ASCII characters (33 to 126)." + NL + NL +

		"- Matches: `123ABC!@#$`, `HELLO-WORLD`, `Code128`." + NL +
		"- Non-matches: `123 ABC`, `Code_128` (contains a space or unsupported characters)."
	],

	:qrCodeData = [
		"Matches data strings typically stored in QR codes",

		"- `^[A-Za-z0-9\\-._~:/?#\\[\\]@!$&'()*+,;=%]*$`: Matches URL-safe characters, including alphanumerics and special characters." + NL + NL +

		"- Matches: `https://example.com`, `name=John&age=30`, `qr-code-12345`." + NL +
		"- Non-matches: `http://example.com/ example` (contains spaces)."
	],

	:isbn10 = [
		"Matches ISBN-10 identifiers",

		"- `^\\d{9}[\\dX]$`: Matches 9 digits followed by a digit or `X` (checksum)." + NL + NL +

		"- Matches: `0306406152`, `123456789X`." + NL +
		"- Non-matches: `123456789`, `030640615X2` (invalid length or checksum)."
	],

	:isbn13 = [
		"Matches ISBN-13 identifiers",

		"- `^978\\d{10}$`: Matches strings starting with `978` followed by 10 digits." + NL + NL +

		"- Matches: `9780306406157`, `9781234567897`." + NL +
		"- Non-matches: `1234567890123`, `0306406157` (does not start with `978` or incorrect length)."
	],


	# Semantic Versioning (major.minor.patch)

	:semVer = [
		"Matches Semantic Versioning (SemVer) format (major.minor.patch with optional pre-release and build metadata)",

		"- `^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?(?:\\+([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?$`:" + NL +
		"  - Matches major, minor, and patch versions." + NL +
		"  - Supports optional pre-release (`-alpha.1`, `-rc.2`) and build metadata (`+build123`)." + NL + NL +

		"- Matches: `1.0.0`, `2.1.3-alpha`, `3.2.1-rc.1+build456`." + NL +
		"- Non-matches: `v1.0`, `1.0.0.0` (invalid extra segments)."
	],

	:strictSemVer = [
		"Matches strict Semantic Versioning without pre-release or build metadata (major.minor.patch)",

		"- `^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)$`:" + NL +
		"  - Matches only the three required version segments." + NL +
		"  - Does not allow pre-release or build metadata." + NL + NL +

		"- Matches: `1.0.0`, `2.3.4`, `10.99.100`." + NL +
		"- Non-matches: `1.0.0-alpha`, `v1.0.0`."
	],

	:versionWithBuild = [
		"Matches version numbers with optional build metadata",

		"- `^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:\\+([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?$`:" + NL +
		"  - Matches three-part version numbers." + NL +
		"  - Allows build metadata prefixed by `+`." + NL + NL +

		"- Matches: `1.0.0+build123`, `2.5.6+exp.sha.5114f85`." + NL +
		"- Non-matches: `1.0.0-alpha`, `v1.2.3`."
	],

	:preReleaseVersion = [
		"Matches versions with pre-release identifiers",

		"- `^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)-([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*)$`:" + NL +
		"  - Matches three-part version numbers." + NL +
		"  - Requires a pre-release identifier (e.g., `-beta`, `-rc.1`)." + NL + NL +

		"- Matches: `1.2.3-alpha`, `4.5.6-beta.1`, `10.0.1-rc.2`." + NL +
		"- Non-matches: `1.2.3`, `1.2.3+build`."
	],

	:versionWithPrefix = [
		"Matches version numbers with an optional `v` prefix",

		"- `^v?(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)$`:" + NL +
		"  - Matches three-part version numbers." + NL +
		"  - Allows an optional `v` at the beginning (e.g., `v1.0.0`)." + NL + NL +

		"- Matches: `v1.0.0`, `1.2.3`, `v10.5.7`." + NL +
		"- Non-matches: `1.0`, `1.2.3-beta`."
	],

	:dateVersion = [
		"Matches date-based versioning (YYYY.MM.DD or YYYYMMDD)",

		"- `^(\\d{4})[.-]?(0[1-9]|1[0-2])[.-]?(0[1-9]|[12]\\d|3[01])$`:" + NL +
		"  - Matches year (4 digits), month (01-12), and day (01-31)." + NL +
		"  - Allows `.` or `-` as separators or no separator at all." + NL + NL +

		"- Matches: `2024.06.15`, `20240615`, `2024-12-01`." + NL +
		"- Non-matches: `2024.13.01` (invalid month), `20240632` (invalid day)."
	],

	:windowsVersion = [
		"Matches Windows-style version numbers (major.minor.build.revision)",

		"- `^(\\d+)\\.(\\d+)\\.(\\d+)\\.(\\d+)$`:" + NL +
		"  - Matches four-part version numbers." + NL +
		"  - Each segment is a numeric value." + NL + NL +

		"- Matches: `10.0.19041.572`, `6.1.7601.24540`." + NL +
		"- Non-matches: `10.0.19041`, `v10.0.0.1`."
	],

	:pythonVersion = [
		"Matches Python package versioning (PEP 440 format)",

		"- `^(\\d+)\\.(\\d+)\\.(\\d+)(?:[abrc]\\d+|\\.post\\d+|\\.dev\\d+)?$`:" + NL +
		"  - Matches three-part version numbers." + NL +
		"  - Allows pre-release (`a1`, `b2`, `rc3`), post-release (`.post1`), and development release (`.dev0`)." + NL + NL +

		"- Matches: `3.9.7`, `2.7.18rc1`, `1.2.3.post4`, `4.5.6.dev0`." + NL +
		"- Non-matches: `1.2`, `1.2.3-alpha` (wrong format for PEP 440)."
	],

	:mavenVersion = [
		"Matches Maven/Gradle-style versioning (with optional suffixes)",

		"- `^(\\d+)(?:\\.(\\d+))?(?:\\.(\\d+))?(?:-([A-Za-z0-9.-]+))?$`:" + NL +
		"  - Matches major, minor, and optional patch numbers." + NL +
		"  - Allows suffixes like `-SNAPSHOT`, `-RELEASE`, `-RC1`." + NL + NL +

		"- Matches: `1.0`, `2.3.4`, `3.0-SNAPSHOT`, `5.1.2-RELEASE`." + NL +
		"- Non-matches: `v1.2.3`, `1.2.3+build`."
	],

	# Common word-based regex patterns

	:quotedWord = [
		"Matches text enclosed in double quotes",

		"- `" + char(34) + "`: Opening double quote character" + NL +
		"- `([^" + char(34) + "]+)`: Captures one or more characters that are not double quotes" + NL +
		"- `" + char(34) + "`: Closing double quote character" + NL + NL +

		"- Matches: `\" + char(34) + "Hello World\" + char(34) + "`, `\" + char(34) + "Testing 123\" + char(34) + "`" + NL +
		"- Non-matches: `Hello World` (no quotes), `\" + char(34) + "Unclosed quote` (missing closing quote)"
	],

	:singleWord = [
		"Matches a single word containing only word characters",

		"- `^`: Start of string" + NL +
		"- `\\w+`: One or more word characters (letters, numbers, underscore)" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `Hello`, `Testing123`, `word_with_underscore`" + NL +
		"- Non-matches: `Hello World` (multiple words), `Special!` (special character)"
	],

	:multipleWords = [
		"Matches multiple words with spaces",

		"- `^`: Start of string" + NL +
		"- `[\\w\\s]+`: One or more word characters or whitespace" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `Hello World`, `This is a test`" + NL +
		"- Non-matches: `Hello,World` (comma), `Special!Chars` (special characters)"
	],

	:camelCaseWord = [
		"Matches camelCase formatted words",

		"- `^`: Start of string" + NL +
		"- `[a-z]+`: One or more lowercase letters at start" + NL +
		"- `([A-Z][a-z]*)*`: Zero or more sequences of uppercase followed by lowercase" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `camelCase`, `thisIsATest`" + NL +
		"- Non-matches: `CamelCase` (starts uppercase), `not_camel_case` (underscore)"
	],

	:snakeCaseWord = [
		"Matches snake_case formatted words",

		"- `^`: Start of string" + NL +
		"- `[a-z]+`: One or more lowercase letters" + NL +
		"- `(_[a-z]+)*`: Zero or more sequences of underscore and lowercase letters" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `snake_case`, `this_is_snake`" + NL +
		"- Non-matches: `Snake_Case` (uppercase), `not-snake` (hyphen)"
	],

	:pascalCaseWord = [
		"Matches PascalCase formatted words",

		"- `^`: Start of string" + NL +
		"- `[A-Z]`: First uppercase letter" + NL +
		"- `[a-z]+`: One or more lowercase letters" + NL +
		"- `([A-Z][a-z]*)*`: Zero or more sequences of uppercase followed by lowercase" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `PascalCase`, `ThisIsPascal`" + NL +
		"- Non-matches: `pascalCase` (starts lowercase), `This_Is_Not_Pascal` (underscores)"
	],

	:kebabCaseWord = [
		"Matches kebab-case formatted words",

		"- `^`: Start of string" + NL +
		"- `[a-z]+`: One or more lowercase letters" + NL +
		"- `(-[a-z]+)*`: Zero or more sequences of hyphen and lowercase letters" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `kebab-case`, `this-is-kebab`" + NL +
		"- Non-matches: `Kebab-Case` (uppercase), `this_is_not_kebab` (underscores)"
	],

	# RTL and Language Support

	:arabicChar = [
		"Matches a single Arabic character",

		"- `^`: Start of string" + NL +
		"- `[\\u0600-\\u06FF]`: Single character in Arabic Unicode range" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `ا`, `ب`, `ت`" + NL +
		"- Non-matches: `اب` (multiple characters), `a` (non-Arabic)"
	],

	:arabicWord = [
		"Matches a word composed of Arabic characters",

		"- `^`: Start of string" + NL +
		"- `[\\u0600-\\u06FF]+`: One or more Arabic characters" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `مرحبا`, `عالم`" + NL +
		"- Non-matches: `hello`, `مرحبا123` (mixed with numbers)"
	],

	:rtlSentence = [
		"Matches right-to-left text (Hebrew or Arabic) with spaces",

		"- `^`: Start of string" + NL +
		"- `[\\u0590-\\u05FF\\u0600-\\u06FF\\s]+`: Hebrew/Arabic characters and spaces" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `مرحبا بالعالم`, `שלום עולם`" + NL +
		"- Non-matches: `Hello World`, `مرحبا123` (mixed with numbers)"
	],

	:russianWord = [
		"Matches words in Cyrillic characters",

		"- `^`: Start of string" + NL +
		"- `[\\u0400-\\u04FF]+`: One or more Cyrillic characters" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `привет`, `мир`" + NL +
		"- Non-matches: `hello`, `привет123` (mixed with numbers)"
	],

	:chineseChar = [
		"Matches Chinese characters",

		"- `^`: Start of string" + NL +
		"- `[\\u4E00-\\u9FFF]+`: One or more Chinese characters" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `你好`, `世界`" + NL +
		"- Non-matches: `hello`, `你好123` (mixed with numbers)"
	],

	:nonLatinWord = [
		"Matches words not containing Latin alphabet",

		"- `^`: Start of string" + NL +
		"- `[^a-zA-Z]+`: One or more non-Latin characters" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `数字`, `١٢٣`, `привет`" + NL +
		"- Non-matches: `hello`, `数字abc` (contains Latin)"
	],

	# Number detection in different numeral systems

	:arabicNumerals = [
		"Matches Arabic numerals",

		"- `^`: Start of string" + NL +
		"- `[\\u0660-\\u0669]+`: One or more Arabic numeral characters" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `٠١٢٣`, `٤٥٦`" + NL +
		"- Non-matches: `123`, `٠١a` (mixed with letters)"
	],

	:devanagariNumerals = [
		"Matches Devanagari numerals",

		"- `^`: Start of string" + NL +
		"- `[\\u0966-\\u096F]+`: One or more Devanagari numeral characters" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `०१२`, `३४५`" + NL +
		"- Non-matches: `123`, `०१a` (mixed with letters)"
	],

	:easternArabicNumerals = [
		"Matches Eastern Arabic numerals",

		"- `^`: Start of string" + NL +
		"- `[\\u06F0-\\u06F9]+`: One or more Eastern Arabic numeral characters" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `۰۱۲`, `۳۴۵`" + NL +
		"- Non-matches: `123`, `۰۱a` (mixed with letters)"
	],

	:universalNumber = [
		"Matches numbers in various numeral systems",

		"- `^`: Start of string" + NL +
		"- `[0-9\\u0660-\\u0669\\u06F0-\\u06F9\\u0966-\\u096F]+`: Digits from various systems" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `123`, `٠١٢`, `۰۱۲`, `०१२`" + NL +
		"- Non-matches: `12a`, `١٢٣a` (mixed with letters)"
	],

	# Punctuation variations

	:punctuationMarks = [
		"Matches standard punctuation marks",

		"- `^`: Start of string" + NL +
		"- `[.,!?;:'\" + char(34) + "\" + char(34) + "\" + char(34) + "\\(\\)\\[\\]\\{\\}]+`: One or more punctuation characters" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `...`, `!!!`, `?!.`" + NL +
		"- Non-matches: `hello.` (contains letters), `123!` (contains numbers)"
	],

	# Password Complexity Patterns

	:passwordWeak = [
		"Matches passwords that are at least 6 characters long with no complexity requirements",

		"- `^`: Start of string" + NL +
		"- `.{6,}`: Any character, minimum 6 occurrences" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `abcdef`, `123456`, `password`" + NL +
		"- Non-matches: `abc` (too short)"
	],

	:passwordSimple = [
		"Matches passwords with minimum length requirement",

		"- `^`: Start of string" + NL +
		"- `.{8,}`: Any character, minimum 8 occurrences" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `password123`, `simplepass`" + NL +
		"- Non-matches: `short` (too short), `pass` (too short)"
	],

	:passwordWithDigits = [
		"Matches passwords containing at least one digit",

		"- `^`: Start of string" + NL +
		"- `(?=.*[0-9])`: Positive lookahead for at least one digit" + NL +
		"- `.{8,}`: Any character, minimum 8 occurrences" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `password123`, `my2ndpass`" + NL +
		"- Non-matches: `password` (no digits), `pass1` (too short)"
	],

	:passwordWithUpperLower = [
		"Matches passwords with upper and lowercase letters",

		"- `^`: Start of string" + NL +
		"- `(?=.*[a-z])`: Positive lookahead for lowercase" + NL +
		"- `(?=.*[A-Z])`: Positive lookahead for uppercase" + NL +
		"- `.{8,}`: Any character, minimum 8 occurrences" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `Password123`, `TestPass`" + NL +
		"- Non-matches: `password` (no uppercase), `Pass` (too short)"
	],

	:passwordWithSpecialChar = [
		"Matches passwords containing special characters",

		"- `^`: Start of string" + NL +
		"- `(?=.*[!@#$%^&*(),.?\" + char(34) + ":{}|<>])`: Positive lookahead for special char" + NL +
		"- `.{8,}`: Any character, minimum 8 occurrences" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `Pass@word123`, `Test!Pass`" + NL +
		"- Non-matches: `password` (no special char), `Pass!` (too short)"
	],

	:passwordStrong = [
		"Matches strong passwords with multiple requirements",

		"- `^`: Start of string" + NL +
		"- `(?=.*[a-z])`: Positive lookahead for lowercase" + NL +
		"- `(?=.*[A-Z])`: Positive lookahead for uppercase" + NL +
		"- `(?=.*[0-9])`: Positive lookahead for digit" + NL +
		"- `(?=.*[!@#$%^&*(),.?\" + char(34) + ":{}|<>])`: Positive lookahead for special char" + NL +
		"- `.{12,}`: Any character, minimum 12 occurrences" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `StrongP@ss123`, `C0mpl3x!Pass`" + NL +
		"- Non-matches: `Weak!pass` (too short), `Password123` (no special char)"
	],

	# API Keys and Secrets Detection

	:hexSecret = [
		"Matches hexadecimal secret keys",

		"- `^`: Start of string" + NL +
		"- `[a-fA-F0-9]{32,}`: 32 or more hexadecimal characters" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `1a2b3c4d5e6f7890abcdef1234567890`" + NL +
		"- Non-matches: `123abc` (too short), `12345g` (invalid hex char)"
	],

	:base64Secret = [
		"Matches Base64 encoded strings",

		"- `^`: Start of string" + NL +
		"- `(?:[A-Za-z0-9+/]{4})*`: Groups of four Base64 characters" + NL +
		"- `(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?`: Optional padding" + NL +
		"- `$`: End of string" + NL + NL +

		"- Matches: `SGVsbG8gV29ybGQ=`, `dGVzdA==`" + NL +
		"- Non-matches: `Hello World`, `===invalid===`"
	],

	:jwtToken = [
		"Matches JWT tokens (JSON Web Tokens)",

		"- `^`: Start of string" + NL +
		"- `[A-Za-z0-9-_]+\\.`: Base64-encoded header ending with a dot" + NL +
		"- `[A-Za-z0-9-_]+\\.`: Base64-encoded payload ending with a dot" + NL +
		"- `[A-Za-z0-9-_]+$`: Base64-encoded signature" + NL + NL +

		"- Matches: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c`" + NL +
		"- Non-matches: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ-INVALID` (invalid signature format)"
	],

	:awsAccessKey = [
		"Matches AWS access keys",

		"- `^`: Start of string" + NL +
		"- `AKIA`: AWS access key prefix" + NL +
		"- `[0-9A-Z]{16}$`: 16 uppercase alphanumeric characters" + NL + NL +

		"- Matches: `AKIAIOSFODNN7EXAMPLE`" + NL +
		"- Non-matches: `BKIAIOSFODNN7EXAMPLE` (wrong prefix), `AKIA123` (too short)"
	],

	:awsSecretKey = [
		"Matches AWS secret keys",

		"- `^`: Start of string" + NL +
		"- `[0-9a-zA-Z/+]{40}$`: 40 characters including letters, digits, `/`, `+`" + NL + NL +

		"- Matches: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`" + NL +
		"- Non-matches: `shortkey123` (too short), `invalid_key_with_!@#` (invalid characters)"
	],

	:privateKeyPEM = [
		"Matches PEM formatted private keys",

		"- `-----BEGIN (RSA|EC|DSA|PRIVATE) KEY-----`: Header indicating key type" + NL +
		"- `[\\s\\S]+`: Any characters (multiline support)" + NL +
		"- `-----END (RSA|EC|DSA|PRIVATE) KEY-----`: Footer marking key end" + NL + NL +

		"- Matches: `-----BEGIN RSA KEY-----\nMIIEpAIBAAKCAQEA...\n-----END RSA KEY-----`" + NL +
		"- Non-matches: `-----BEGIN SOME RANDOM DATA-----\n...\n-----END SOME RANDOM DATA-----` (incorrect header/footer)"
	],

	# Personally Identifiable Information (PII)

	:ssnUSA = [
		"Matches US Social Security Numbers (SSN)",

		"- `^`: Start of string" + NL +
		"- `\\d{3}-\\d{2}-\\d{4}$`: Three digits, hyphen, two digits, hyphen, four digits" + NL + NL +

		"- Matches: `123-45-6789`" + NL +
		"- Non-matches: `123456789` (missing hyphens), `12-345-6789` (wrong format)"
	],

	:passportNumber = [
		"Matches passport numbers",

		"- `^`: Start of string" + NL +
		"- `[A-Z0-9]{6,9}$`: 6 to 9 alphanumeric uppercase characters" + NL + NL +

		"- Matches: `A1234567`, `123456789`" + NL +
		"- Non-matches: `12345` (too short), `ABCD123456` (too long)"
	],

	# Other Sensitive Data

	:hexadecimalEntropy = [
		"Matches long hexadecimal strings (potential entropy keys)",

		"- `^`: Start of string" + NL +
		"- `[0-9a-fA-F]{64,}$`: At least 64 hexadecimal characters" + NL + NL +

		"- Matches: `a3f9c...3e0a` (64+ hex chars)" + NL +
		"- Non-matches: `a3f9c` (too short), `GHIJKL1234` (invalid hex characters)"
	],

	:uuid = [
		"Matches UUIDs (Universally Unique Identifiers)",

		"- `^`: Start of string" + NL +
		"- `[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$`: Standard UUID format" + NL + NL +

		"- Matches: `550e8400-e29b-41d4-a716-446655440000`" + NL +
		"- Non-matches: `550e8400e29b41d4a716446655440000` (missing hyphens), `550e8400-e29b-61d4-a716-446655440000` (invalid variant)"
	],

	:bcryptHash = [
		"Matches bcrypt password hashes",

		"- `^\\$2[ayb]\\$\\d{2}\\$`: Bcrypt format identifier and cost factor" + NL +
		"- `[./A-Za-z0-9]{53}$`: 53 base64-like encoded characters" + NL + NL +

		"- Matches: `$2b$12$Qe4VhXyQtk2Hl3m.r3lVze1aeXZ9c7G5YpTmHDHkJxXO/hP9mB0s.`" + NL +
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
