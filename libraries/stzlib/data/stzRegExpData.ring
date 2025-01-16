

#------------------------------------------------------#
#  REGEX DATA : NAMED PATTERNS AND THEIR EXPLANATIONS  #
#------------------------------------------------------#

_$aRegExpPatterns_ = [

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

   	# Modern Data Formats

   	:jwt = "^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]*$",
   	:base64 = "^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$",
   	:uuid = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
	:emoji = "^(?:\\p{Emoji_Presentation}|\\p{Emoji})+$",


	# API & Request Validation

	:apiKey = "^[A-Za-z0-9_-]{20,}$",
	:bearerToken = "^Bearer\s+[A-Za-z0-9\-._~+/]+=*$",
	:queryParam = "^[\w\-%\.]+$",
	:httpMethod = "^(?:GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS)$",
	:contentType = "^[\w\-\./]+(?:\+[\w\-\./]+)?(?:;\s*charset=[\w\-]+)?$",
	:requestId = "^[\w\-]{4,}$",
	:corsOrigin = "^https?://(?:[\w-]+\.)+[\w-]+(?::\d{1,5})?$",

   	# Data Cleaning

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

	# SQL Patters

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
	
	:ringBraceEnd = "^(?i)func\s+braceEnd\s*$",
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
:xlsArrayFormula = "^\\{.*\\}$",


]



#-----------------------------------#
#  UTILITY FUNCTION FOR REGEX DATA  #
#-----------------------------------#

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
