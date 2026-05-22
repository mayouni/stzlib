// Auto-generated from stzRegexData.ring
// Source: stzlib/base/data/stzRegexData.ring
//
// Conversion rules applied:
//   - StzChar(34) -> literal " -> Zig \"
//   - StzChar(39) -> literal ' -> Zig ' (no escaping needed)
//   - Ring double-quoted string escapes (\n, \r, \t, \\) map 1:1 to Zig
//   - Multi-line Ring concatenations joined into single Zig string literal
//   - geoJSON pattern is malformed in the original Ring source (noted inline)

pub const Pattern = struct { name: []const u8, pattern: []const u8 };

pub const patterns = [_]Pattern{
    // String Structure Patterns
    .{ .name = "textWithNumberSuffix", .pattern = "^([^\\d]*)(\\d+)$" },
    .{ .name = "numberWithTextSuffix", .pattern = "^(\\d+)([^\\d]*)$" },
    .{ .name = "textNumberText", .pattern = "^([^\\d]*)(\\d+)([^\\d]*)$" },
    .{ .name = "alternatingTextNumber", .pattern = "^([^\\d]+\\d+)+$" },
    .{ .name = "spaceSeparatedWords", .pattern = "^(\\S+)(?:\\s+\\S+)*$" },

    // Basic structure for international addresses
    .{ .name = "addressLine", .pattern = "^[a-zA-Z0-9.,''\\-\\s]+$" },
    .{ .name = "cityName", .pattern = "^[a-zA-Z\\s\\-']+$" },
    .{ .name = "stateProvinceRegion", .pattern = "^[a-zA-Z\\s\\-']+$" },
    .{ .name = "postalCode", .pattern = "^[a-zA-Z0-9\\-\\s]{3,10}$" },
    .{ .name = "countryName", .pattern = "^[a-zA-Z\\s\\-]+$" },
    .{ .name = "fullAddress", .pattern = "^([a-zA-Z0-9.,''\\-\\s]+)(\\n[a-zA-Z0-9.,''\\-\\s]+)*\\n([a-zA-Z\\s\\-']+)\\n([a-zA-Z\\s\\-']+)\\n([a-zA-Z0-9\\-\\s]{3,10})\\n([a-zA-Z\\s\\-]+)$" },

    // Patterns to Analyze Regex patterns
    .{ .name = "rxGroup", .pattern = "\\(([^()]*|(?R))*\\)" },
    .{ .name = "rxQuantifier", .pattern = "\\*|\\+|\\?|(\\{\\d+(,\\d*)?\\})" },
    .{ .name = "rxCharacterClass", .pattern = "\\[(\\^?[^\\]]+)\\]" },
    .{ .name = "rxAssertion", .pattern = "\\(\\?<?[=!]" },
    .{ .name = "rxEscapedChar", .pattern = "\\\\" },
    .{ .name = "rxAlternation", .pattern = "(\\|)" },
    .{ .name = "rxWildcard", .pattern = "\\" },
    .{ .name = "rxRedundantAlternation", .pattern = "\\((?:[a-zA-Z0-9]\\|?)+\\)" },

    // Files names and paths
    // Note: \r\n in the character class are literal CR/LF bytes (excluded from filenames)
    .{ .name = "fileName", .pattern = "^[^<>:\"/\\\\|?*\r\n]+$" },
    .{ .name = "filePath", .pattern = "^(?:[a-zA-Z]:)?(?:\\\\[^<>:\"/\\\\|?*\r\n]+)+\\\\?$" },
    .{ .name = "unixFilePath", .pattern = "^(/[^<>:\"/\\\\|?*\r\n]+)+/?$" },
    .{ .name = "fileExtension", .pattern = "\\.[a-zA-Z0-9]+$" },
    .{ .name = "relativeFilePath", .pattern = "^(?:\\.\\.?/|[^/<>:\"|?*]+)(?:/[^/<>:\"|?*]+)*/?$" },

    // Web & Email
    .{ .name = "email", .pattern = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}" },
    .{ .name = "url", .pattern = "^https?:\\/\\/(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,}(\\/[\\w\\-._~:/?#[\\]@!$&'()*+,;=]*)?$" },
    .{ .name = "domain", .pattern = "^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\\.[a-zA-Z]{2,}$" },
    .{ .name = "ipv4", .pattern = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$" },
    .{ .name = "ipv6", .pattern = "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4})" },
    .{ .name = "socialHandle", .pattern = "^@[a-zA-Z0-9._]{1,30}$" },
    .{ .name = "slug", .pattern = "^[a-z0-9]+(?:-[a-z0-9]+)*$" },

    // Dates & Times (International)
    .{ .name = "isoDate", .pattern = "^\\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$" },
    .{ .name = "isoDateTime", .pattern = "^\\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])T([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\\.[0-9]+)?(Z|[+-][01][0-9]:[0-5][0-9])?$" },
    .{ .name = "ddmmyyyy", .pattern = "^(0[1-9]|[12][0-9]|3[01])[-/.](0[1-9]|1[0-2])[-/.]\\d{4}$" },
    .{ .name = "mmddyyyy", .pattern = "^(0[1-9]|1[0-2])[-/.](0[1-9]|[12][0-9]|3[01])[-/.]\\d{4}$" },
    .{ .name = "time24h", .pattern = "^([01]?[0-9]|2[0-3]):[0-5][0-9]$" },
    .{ .name = "time24hSeconds", .pattern = "^([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$" },
    .{ .name = "time12h", .pattern = "^(0?[1-9]|1[0-2]):[0-5][0-9]\\s?(AM|PM|am|pm)$" },
    .{ .name = "time12hSeconds", .pattern = "^(0?[1-9]|1[0-2]):[0-5][0-9]:[0-5][0-9]\\s?(AM|PM|am|pm)$" },
    .{ .name = "dateISO8601", .pattern = "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(?:Z|([+-])\\d{2}:\\d{2})?$" },
    .{ .name = "date", .pattern = "\\b(?:\\d{1,4}[-/.]\\d{1,2}[-/.]\\d{1,4}|\\d{1,2}\\s+[A-Za-z]{3,9}\\s+\\d{2,4})\\b" },

    // DateTime Combined Patterns
    .{ .name = "dateTimeSpace", .pattern = "^\\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])\\s([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$" },
    .{ .name = "dateTimeUS", .pattern = "^(0[1-9]|1[0-2])[-/.](0[1-9]|[12][0-9]|3[01])[-/.]\\d{4}\\s([01]?[0-9]|2[0-3]):[0-5][0-9]$" },
    .{ .name = "dateTimeEU", .pattern = "^(0[1-9]|[12][0-9]|3[01])[-/.](0[1-9]|1[0-2])[-/.]\\d{4}\\s([01]?[0-9]|2[0-3]):[0-5][0-9]$" },
    .{ .name = "dateTime12h", .pattern = "^(0[1-9]|1[0-2])[-/.](0[1-9]|[12][0-9]|3[01])[-/.]\\d{4}\\s(0?[1-9]|1[0-2]):[0-5][0-9]\\s?(AM|PM|am|pm)$" },
    .{ .name = "dateTimeLong", .pattern = "^\\d{1,2}\\s[A-Za-z]{3,9}\\s\\d{4},?\\s([01]?[0-9]|2[0-3]):[0-5][0-9]$" },

    // Timestamp & Unix Patterns
    .{ .name = "unixTimestamp", .pattern = "^\\d{10}$" },
    .{ .name = "unixTimestampMillis", .pattern = "^\\d{13}$" },
    .{ .name = "timestampWithMillis", .pattern = "^\\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])T([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]\\.\\d{3}Z?$" },

    // Flexible DateTime Patterns
    .{ .name = "DateTime", .pattern = "\\b\\d{4}[-/.]\\d{1,2}[-/.]\\d{1,2}[T\\s]\\d{1,2}:\\d{2}(:\\d{2})?(\\.\\d+)?(Z|[+-]\\d{2}:\\d{2})?\\b" },
    .{ .name = "rfc2822DateTime", .pattern = "^[A-Za-z]{3},\\s\\d{1,2}\\s[A-Za-z]{3}\\s\\d{4}\\s\\d{2}:\\d{2}:\\d{2}\\s[+-]\\d{4}$" },

    // Markdown
    .{ .name = "mdHeader", .pattern = "^#{1,6}\\s.+$" },
    .{ .name = "mdBold", .pattern = "\\*\\*[^*]+\\*\\*" },
    .{ .name = "mdItalic", .pattern = "\\*[^*]+\\*" },
    .{ .name = "mdLink", .pattern = "\\[([^\\]]+)\\]\\(([^\\)]+)\\)" },
    .{ .name = "mdImage", .pattern = "!\\[([^\\]]*)\\]\\(([^\\)]+)\\)" },
    .{ .name = "mdBlockquote", .pattern = "^>\\s.+$" },
    .{ .name = "mdCodeBlock", .pattern = "```[^`]*```" },
    .{ .name = "mdInlineCode", .pattern = "`[^`]+`" },
    .{ .name = "mdListItem", .pattern = "^[-*+]\\s.+$" },
    .{ .name = "mdNumberedList", .pattern = "^\\d+\\.\\s.+$" },

    // YAML Patterns
    .{ .name = "yamlKey", .pattern = "^[a-zA-Z0-9]+[a-zA-Z0-9_-]*$" },
    .{ .name = "yamlValue", .pattern = "^(\"[^\"]*\")|([0-9]+)|(true|false)|null$" },
    .{ .name = "yamlMap", .pattern = "^[a-zA-Z0-9]+:[ ]*.+$" },
    .{ .name = "yamlArray", .pattern = "^-?[0-9]+$|\"[^\"]*\"$" },
    .{ .name = "yamlFrontMatter", .pattern = "^---\\s*\\n(.*?)\\n---$" },

    // HTML
    .{ .name = "htmlComment", .pattern = "<!--[\\s\\S]*?-->" },
    .{ .name = "htmlDoctype", .pattern = "<!DOCTYPE[^>]*>" },
    .{ .name = "htmlOpenTag", .pattern = "<([a-zA-Z][a-zA-Z0-9]*)((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\".*?\"|'.*?'|[^'\"<>\\s]+))?)*)\\s*/?>" },
    .{ .name = "htmlCloseTag", .pattern = "</([a-zA-Z][a-zA-Z0-9]*)>" },
    .{ .name = "htmlAttribute", .pattern = "(?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\".*?\"|'.*?'|[^'\"<>\\s]+))?)" },
    .{ .name = "htmlClass", .pattern = "(?:\\s+class\\s*=\\s*(?:\"[^\"]*\"|'[^']*'|[^'\"\\s>]+))" },
    .{ .name = "htmlId", .pattern = "(?:\\s+id\\s*=\\s*(?:\"[^\"]*\"|'[^']*'|[^'\"\\s>]+))" },
    .{ .name = "html5Color", .pattern = "^#[A-Fa-f0-9]{3,6}$" },
    .{ .name = "htmlTableOpen", .pattern = "<table((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\".*?\"|'.*?'|[^'\"<>\\s]+))?)*)\\s*>" },
    .{ .name = "htmlTableClose", .pattern = "</table>" },
    .{ .name = "htmlRowOpen", .pattern = "<tr((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\".*?\"|'.*?'|[^'\"<>\\s]+))?)*)\\s*>" },
    .{ .name = "htmlRowClose", .pattern = "</tr>" },
    .{ .name = "htmlCellOpen", .pattern = "<td((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\".*?\"|'.*?'|[^'\"<>\\s]+))?)*)\\s*>" },
    .{ .name = "htmlCellClose", .pattern = "</td>" },
    .{ .name = "htmlHeaderCellOpen", .pattern = "<th((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\".*?\"|'.*?'|[^'\"<>\\s]+))?)*)\\s*>" },
    .{ .name = "htmlHeaderCellClose", .pattern = "</th>" },
    .{ .name = "htmlTableSectionOpen", .pattern = "<(thead|tbody|tfoot)((?:\\s+[a-zA-Z][a-zA-Z0-9]*(?:\\s*=\\s*(?:\".*?\"|'.*?'|[^'\"<>\\s]+))?)*)\\s*>" },
    .{ .name = "htmlTableSectionClose", .pattern = "</(thead|tbody|tfoot)>" },

    // CSS Patterns
    .{ .name = "idSelector", .pattern = "^#([a-zA-Z_][a-zA-Z\\d_-]*)$" },
    .{ .name = "classSelector", .pattern = "^\\.([a-zA-Z_][a-zA-Z\\d_-]*)$" },
    .{ .name = "attributeSelector", .pattern = "\\[\\s*([a-zA-Z][a-zA-Z0-9-]*)\\s*(?:([*^$|!~]?=)\\s*(?:\"[^\"]*\"|'[^']*'|[^'\"\\s>]+))?\\s*\\]" },
    .{ .name = "hexColor", .pattern = "^#([a-fA-F\\d]{3}|[a-fA-F\\d]{6})$" },
    .{ .name = "rgbColor", .pattern = "^rgba?\\(\\s*\\d{1,3}\\s*,\\s*\\d{1,3}\\s*,\\s*\\d{1,3}(\\s*,\\s*(0|1|0?\\.\\d+))?\\s*\\)$" },

    // Numbers & Currency (International)
    .{ .name = "digit", .pattern = "\\d" },
    .{ .name = "number", .pattern = "^-?(?:\\d+|\\d{1,3}(?:,\\d{3})+)?(?:\\.\\d+)?$" },
    .{ .name = "currencyValue", .pattern = "^-?\\d{1,3}(?:,\\d{3})*(?:\\.\\d{2})?$" },
    .{ .name = "scientificNotation", .pattern = "^-?\\d+(?:\\.\\d+)?(?:e[+-]?\\d+)?$" },
    .{ .name = "percentage", .pattern = "^-?\\d*\\.?\\d+%$" },
    // Note: hexColor appears twice in Ring source (Numbers section overrides CSS section)
    .{ .name = "hexColor2", .pattern = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$" },
    .{ .name = "integer", .pattern = "^-?\\d+$" },
    .{ .name = "positiveInteger", .pattern = "^\\d+$" },
    .{ .name = "negativeInteger", .pattern = "^-\\d+$" },
    .{ .name = "float", .pattern = "^-?\\d+\\.\\d+$" },
    .{ .name = "positiveFloat", .pattern = "^\\d+\\.\\d+$" },
    .{ .name = "negativeFloat", .pattern = "^-\\d+\\.\\d+$" },
    .{ .name = "binaryNumber", .pattern = "^[01]+$" },
    .{ .name = "octalNumber", .pattern = "^[0-7]+$" },
    .{ .name = "hexNumber", .pattern = "^0[xX][A-Fa-f0-9]+$" },
    .{ .name = "romanNumber", .pattern = "^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$" },
    .{ .name = "measurementValue", .pattern = "^-?\\d+(?:\\.\\d+)?\\s?(cm|mm|m|km|g|kg|lb|oz|L|ml|mL|ft|inch|in|yd|mi)$" },
    .{ .name = "phoneNumber", .pattern = "^\\+?\\d{1,3}?[-.●]?\\(?\\d{1,4}?\\)?[-.●]?\\d{1,4}[-.●]?\\d{1,9}$" },

    // Special patterns for capturing numbers inside string
    .{ .name = "numbersInSingleQuotes", .pattern = "'-?\\d+(?:\\.\\d+)?'" },
    .{ .name = "numbersInDoubleQuotes", .pattern = "\"-?\\d+(?:\\.\\d+)?\\\"" },
    .{ .name = "numbersInBackticks", .pattern = "`-?\\d+(?:\\.\\d+)?`" },
    .{ .name = "numbersInCurlySingleQuotes", .pattern = "[‘’]-?\\d+(?:\\.\\d+)?[‘’]" },
    .{ .name = "numbersInCurlyDoubleQuotes", .pattern = "[“”]-?\\d+(?:\\.\\d+)?[“”]" },
    .{ .name = "numbersInQuotes", .pattern = "'-?\\d+(?:\\.\\d+)?'|\"-?\\d+(?:\\.\\d+)?\"|`-?\\d+(?:\\.\\d+)?`|[‘’]-?\\d+(?:\\.\\d+)?[‘’]|[“”]-?\\d+(?:\\.\\d+)?[“”]" },
    .{ .name = "numbersInString", .pattern = "(?<!\\w)-?\\d+(?:\\.\\d+)?(?!\\w)" },
    .{ .name = "numbersInParentheses", .pattern = "\\(\\s*-?\\d+(?:\\.\\d+)?\\s*\\)" },
    .{ .name = "numbersAfterEquals", .pattern = "=\\s*-?\\d+(?:\\.\\d+)?\\b" },
    .{ .name = "numbersInCSV", .pattern = "(?<=,|;|\\s|^)-?\\d+(?:\\.\\d+)?(?=,|;|\\s|$)" },
    .{ .name = "numbersInBrackets", .pattern = "\\[\\s*-?\\d+(?:\\.\\d+)?\\s*\\]" },
    .{ .name = "numbersAfterColon", .pattern = ":\\s*-?\\d+(?:\\.\\d+)?\\b" },
    .{ .name = "numbersAsValuesInHashList", .pattern = "=\\s*\"?([+-]?\\d+(?:\\.\\d+)?)\"?" },
    .{ .name = "numbersAsValuesInPairs", .pattern = ",\\s*\"?([+-]?\\d+(?:\\.\\d+)?)\"?" },
    .{ .name = "numbersAsValuesInJSON", .pattern = ":\\s*\"?([+-]?\\d+(?:\\.\\d+)?)\"?" },
    .{ .name = "numbersInList", .pattern = "\\b([\"']?)(-?\\d+(?:\\.\\d+)?)(\\1)\\b" },

    // Contact Information (International)
    .{ .name = "phoneE164", .pattern = "^\\+[1-9]\\d{1,14}$" },
    .{ .name = "phoneGeneral", .pattern = "^[+]?[(]?[0-9]{1,4}[)]?[-\\s./0-9]*$" },
    // Note: postalCode appears twice; second occurrence (more general)
    .{ .name = "postalCodeIntl", .pattern = "^[A-Z0-9][A-Z0-9\\- ]{0,10}[A-Z0-9]$" },
    .{ .name = "countryCode", .pattern = "^[A-Z]{2,3}$" },
    .{ .name = "languageCode", .pattern = "^[a-z]{2}-[A-Z]{2}$" },

    // Modern Data Formats
    .{ .name = "jwt", .pattern = "^[A-Za-z0-9-_]+\\.[A-Za-z0-9-_]+\\.[A-Za-z0-9-_]*$" },
    .{ .name = "base64", .pattern = "^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$" },
    .{ .name = "emoji", .pattern = "^(?:\\p{Emoji_Presentation}|\\p{Emoji})+$" },

    // API & Request Validation
    .{ .name = "apiKey", .pattern = "^[A-Za-z0-9_-]{20,}$" },
    .{ .name = "bearerToken", .pattern = "^Bearer\\s+[A-Za-z0-9\\-._~+/]+=*$" },
    .{ .name = "queryParam", .pattern = "^[\\w\\-%\\.]+$" },
    .{ .name = "httpMethod", .pattern = "^(?:GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS)$" },
    .{ .name = "contentType", .pattern = "^[\\w\\-\\./]+(?:\\+[\\w\\-\\./]+)?(?:;\\s*charset=[\\w\\-]+)?$" },
    .{ .name = "requestId", .pattern = "^[\\w\\-]{4,}$" },
    .{ .name = "corsOrigin", .pattern = "^https?://(?:[\\w-]+\\.)+[\\w-]+(?::\\d{1,5})?$" },

    // Data Cleaning Patterns
    .{ .name = "alphanumeric", .pattern = "^[a-zA-Z0-9]+$" },
    .{ .name = "alphabetic", .pattern = "^[a-zA-Z]+$" },
    .{ .name = "numeric", .pattern = "^[0-9]+$" },
    .{ .name = "spaces", .pattern = "[ \\t\\r\\n]+" },
    .{ .name = "trim", .pattern = "^\\s+|\\s+$" },
    .{ .name = "multipleSpaces", .pattern = " {2,}" },
    .{ .name = "nonPrintable", .pattern = "[\\x00-\\x1F\\x7F-\\x9F]" },

    // JSON Patterns
    .{ .name = "jsonObject", .pattern = "\\{(?:\\s*\"[a-zA-Z0-9_]+\"\\s*:\\s*(?:\"[^\"]*\"|'[^']*'|\\d+|true|false|null|\\{.*?\\}|\\[.*?\\]))*\\s*\\}" },
    .{ .name = "jsonArray", .pattern = "^\\[(?:\\s*[^,]+,?\\s*)*\\]$" },
    .{ .name = "jsonKeyValuePair", .pattern = "\"[a-zA-Z0-9_]+\"\\s*:\\s*(?:\"[^\"]*\"|'[^']*'|\\d+|true|false|null|\\{.*?\\}|\\[.*?\\])" },
    // NOTE: geoJSON pattern is malformed in the original Ring source (line 234 of stzRegexData.ring).
    // The pattern string is broken/truncated. Included as-is from the Ring source reconstruction.
    .{ .name = "geoJSON", .pattern = "^\\{\\s*\"type\"\\s*:\\s*\"FeatureCollection\"\\s*,\\s*\"features\"\\s*:\\s*\\[.*?\\]\\s*\\}$" },

    // CSV Patterns
    .{ .name = "csvHeaderRow", .pattern = "^([^,]*,)*[^,]*$" },
    .{ .name = "csvQuotedField", .pattern = "\"[^\"]*\"" },
    .{ .name = "csvUnquotedField", .pattern = "[^,\\r\\n]*" },
    .{ .name = "csvDelimiter", .pattern = "," },
    .{ .name = "csvRowEnding", .pattern = "\\r?" },
    .{ .name = "csvEscapedQuote", .pattern = "\"\"" },
    .{ .name = "csvLine", .pattern = "^(?:(?:\"[^\"]*\")|(?:[^,\"]+))(?:,(?:(?:\"[^\"]*\")|(?:[^,\"]+)))*$" },

    // SQL Patterns
    .{ .name = "sqlSelectStatement", .pattern = "^\\s*SELECT\\s+.+?\\s+FROM\\s+.+?(?:\\s+WHERE\\s+.+?)?$" },
    .{ .name = "sqlInsertStatement", .pattern = "^\\s*INSERT\\s+INTO\\s+.+?\\s+\\(.+?\\)\\s+VALUES\\s+\\(.+?\\)\\s*$" },
    .{ .name = "sqlUpdateStatement", .pattern = "^\\s*UPDATE\\s+.+?\\s+SET\\s+.+?(?:\\s+WHERE\\s+.+?)?$" },
    .{ .name = "sqlDeleteStatement", .pattern = "^\\s*DELETE\\s+FROM\\s+.+?(?:\\s+WHERE\\s+.+?)?$" },
    .{ .name = "sqlCreateTable", .pattern = "^\\s*CREATE\\s+TABLE\\s+[\\w]+\\s*\\(.+?\\)\\s*$" },
    .{ .name = "sqlDropTable", .pattern = "^\\s*DROP\\s+TABLE\\s+[\\w]+\\s*$" },
    .{ .name = "sqlIdentifier", .pattern = "^[a-zA-Z_][a-zA-Z0-9_]*$" },
    .{ .name = "sqlValue", .pattern = "^('(?:[^']|''|\\\\')*'|\\d+|NULL)$" },
    .{ .name = "sqlOperator", .pattern = "^(=|<>|!=|<|<=|>|>=|LIKE|IN|IS|BETWEEN)$" },
    .{ .name = "sqlJoinClause", .pattern = "^\\s*JOIN\\s+.+?\\s+ON\\s+.+?$" },

    // Regexes for Potential Security Concerns
    .{ .name = "sqlInjection", .pattern = "(?:[\"'`;]+.*?)+" },
    .{ .name = "xssInjection", .pattern = "<[a-zA-Z][a-zA-Z0-9]*[^>]*>.*?</[a-zA-Z][a-zA-Z0-9]*>" },
    .{ .name = "emailInjection", .pattern = ".*[\\n\\r]+.+@[a-z0-9]+[.][a-z]{2,}.*" },
    .{ .name = "htmlInjection", .pattern = "<[^>]*?[^<]*[a-zA-Z0-9]+.*[^<]*?>" },

    // Ring Language Patterns
    .{ .name = "ringString", .pattern = "^(?:[\"'].*?[\"']|\\[.*?\\]|`.*?`)$" },
    .{ .name = "ringNumber", .pattern = "^-?\\d+(?:\\.\\d+)?$" },
    .{ .name = "ringBoolean", .pattern = "^(?:True|False)$" },
    .{ .name = "ringVariable", .pattern = "^[a-zA-Z_]\\w*$" },
    .{ .name = "ringFunction", .pattern = "^(?i)Func\\s+([a-zA-Z_]\\w*)\\s*(?:\\((.*?)\\))?$" },
    .{ .name = "ringFunctionCall", .pattern = "^([a-zA-Z_]\\w*)\\s*\\((.*?)\\)$" },
    .{ .name = "ringMainFunction", .pattern = "^(?i)Func\\s+Main\\s*$" },
    .{ .name = "ringClass", .pattern = "^(?i)Class\\s+([a-zA-Z_]\\w*)\\s*(?:from\\s+([a-zA-Z_]\\w*))?$" },
    .{ .name = "ringClassAttribute", .pattern = "^[a-zA-Z_]\\w*\\s*=\\s*.*$" },
    .{ .name = "ringNewObject", .pattern = "^(?i)New\\s+([a-zA-Z_]\\w*)$" },
    .{ .name = "ringObjectAccess", .pattern = "^([a-zA-Z_]\\w*)\\s*\\{\\s*(.*?)\\s*\\}$" },
    .{ .name = "ringLoop", .pattern = "^(?i)(?:for\\s+\\w+\\s*=\\s*\\d+\\s+to\\s+\\d+|while\\s+.*|for\\s+\\w+\\s+in\\s+.*?)$" },
    .{ .name = "ringIf", .pattern = "^(?i)if\\s+.*$" },
    .{ .name = "ringSwitch", .pattern = "^(?i)switch\\s+.*$" },
    .{ .name = "ringCase", .pattern = "^(?i)(?:on|off)\\s+.*$" },
    .{ .name = "ringList", .pattern = "^\\[(?:[^[\\]]*|\\[.*?\\])*\\]$" },
    .{ .name = "ringListAccess", .pattern = "^([a-zA-Z_]\\w*)\\s*\\[\\s*(\\d+|\\w+)\\s*\\]$" },
    .{ .name = "ringListRange", .pattern = "^([^:]+)\\s*:\\s*([^:]+)$" },
    .{ .name = "ringHashTable", .pattern = "^\\[\\s*:(?:\\w+\\s*=\\s*[^,\\]]+\\s*,?\\s*)+\\]$" },
    .{ .name = "ringComment", .pattern = "^(?:#.*|//.*|/\\*[\\s\\S]*?\\*/)$" },
    .{ .name = "ringSee", .pattern = "^(?i)See\\s+[\"'].*?[\"']|See\\s+\\w+$" },
    .{ .name = "ringGive", .pattern = "^(?i)Give\\s+\\w+$" },
    .{ .name = "ringLoad", .pattern = "^(?i)Load\\s+[\"'].*?[\"']$" },
    .{ .name = "ringImport", .pattern = "^(?i)Import\\s+[\\w.]+$" },
    .{ .name = "ringOperator", .pattern = "^(?:[+\\-*/=%]|==|!=|>=|<=|>|<|\\+=|-=|\\*=|/=)$" },
    .{ .name = "ringLogical", .pattern = "^(?:and|or|not)$" },
    .{ .name = "ringExit", .pattern = "^(?i)exit(?:\\s+\\d+)?$" },
    .{ .name = "ringReturn", .pattern = "^(?i)return(?:\\s+.*)?$" },
    .{ .name = "ringPackage", .pattern = "^(?i)Package\\s+[\\w.]+$" },
    .{ .name = "ringPrivate", .pattern = "^(?i)Private$" },
    .{ .name = "ringBracestart", .pattern = "^(?i)func\\s+braceStart\\s*\\(\\s*\\)\\s*$" },
    .{ .name = "ringBraceEnd", .pattern = "^(?i)func\\s+braceEnd\\s*\\(\\s*\\)\\s*$" },
    .{ .name = "ringEval", .pattern = "^(?i)Eval\\s*\\(.*?\\)$" },

    // Python Language Patterns
    .{ .name = "pythonString", .pattern = "^(?:\"\"\".*?\"\"\"|\".*?\"|'''.*?'''|'.*?')$" },
    .{ .name = "pythonNumber", .pattern = "^-?\\d+(?:\\.\\d+)?(?:e[+-]?\\d+)?$" },
    .{ .name = "pythonBoolean", .pattern = "^(?:True|False|None)$" },
    .{ .name = "pythonVariable", .pattern = "^[a-zA-Z_]\\w*$" },
    .{ .name = "pythonFunction", .pattern = "^def\\s+([a-zA-Z_]\\w*)\\s*\\((.*?)\\)(?:\\s*->\\s*[\\w\\[\\],\\s]+)?:$" },
    .{ .name = "pythonFunctionCall", .pattern = "^([a-zA-Z_]\\w*)\\s*\\((.*?)\\)$" },
    .{ .name = "pythonLambda", .pattern = "^lambda\\s+.*?:\\s*.*$" },
    .{ .name = "pythonClass", .pattern = "^class\\s+([a-zA-Z_]\\w*)(?:\\((.*?)\\))?:$" },
    .{ .name = "pythonClassMethod", .pattern = "^@\\w+\\s*$" },
    .{ .name = "pythonDecorator", .pattern = "^@[a-zA-Z_]\\w*(?:\\((.*?)\\))?$" },
    .{ .name = "pythonLoop", .pattern = "^(?:for\\s+.*?\\s+in\\s+.*?:|while\\s+.*?:)$" },
    .{ .name = "pythonIf", .pattern = "^(?:if|elif|else)\\s*.*?:$" },
    .{ .name = "pythonWith", .pattern = "^with\\s+.*?\\s+as\\s+.*?:$" },
    .{ .name = "pythonTry", .pattern = "^(?:try|except|finally|raise)\\s*.*?:$" },
    .{ .name = "pythonList", .pattern = "^\\[(?:[^[\\]]*|\\[.*?\\])*\\]$" },
    .{ .name = "pythonDict", .pattern = "^\\{(?:[^{}]*|\\{.*?\\})*\\}$" },
    .{ .name = "pythonTuple", .pattern = "^\\((?:[^()]*|\\(.*?\\))*\\)$" },
    .{ .name = "pythonComprehension", .pattern = "^\\[.*?\\s+for\\s+.*?\\s+in\\s+.*?\\]$" },
    .{ .name = "pythonComment", .pattern = "^#.*$" },
    .{ .name = "pythonDocstring", .pattern = "^\"\"\"[\\s\\S]*?\"\"\"$" },
    .{ .name = "pythonImport", .pattern = "^(?:import|from)\\s+[\\w.]+(?:\\s+import\\s+(?:\\w+(?:\\s+as\\s+\\w+)?(?:\\s*,\\s*\\w+(?:\\s+as\\s+\\w+)?)*|\\*))?\\s*$" },

    // JavaScript Language Patterns
    .{ .name = "jsString", .pattern = "^(?:\".*?\"|'.*?'|`[\\s\\S]*?`)$" },
    .{ .name = "jsNumber", .pattern = "^-?\\d+(?:\\.\\d+)?(?:e[+-]?\\d+)?$" },
    .{ .name = "jsBoolean", .pattern = "^(?:true|false|null|undefined)$" },
    .{ .name = "jsVariable", .pattern = "^(?:var|let|const)\\s+[a-zA-Z_$][\\w$]*(?:\\s*=\\s*.*)?$" },
    .{ .name = "jsFunction", .pattern = "^(?:function\\s+([a-zA-Z_$][\\w$]*)\\s*\\((.*?)\\)|(?:async\\s+)?function\\s*\\((.*?)\\))\\s*\\{$" },
    .{ .name = "jsArrowFunction", .pattern = "^(?:const\\s+)?([a-zA-Z_$][\\w$]*)\\s*=\\s*(?:async\\s+)?\\((.*?)\\)\\s*=>\\s*(?:\\{|\\S.*)$" },
    .{ .name = "jsFunctionCall", .pattern = "^([a-zA-Z_$][\\w$]*)\\s*\\((.*?)\\)$" },
    .{ .name = "jsClass", .pattern = "^class\\s+([a-zA-Z_$][\\w$]*)(?:\\s+extends\\s+([a-zA-Z_$][\\w$]*))?$" },
    .{ .name = "jsClassMethod", .pattern = "^(?:async\\s+)?([a-zA-Z_$][\\w$]*)\\s*\\((.*?)\\)\\s*\\{$" },
    .{ .name = "jsDecorator", .pattern = "^@[a-zA-Z_$][\\w$]*(?:\\((.*?)\\))?$" },
    .{ .name = "jsLoop", .pattern = "^(?:for|while|do)\\s*\\(.*?\\)$" },
    .{ .name = "jsIf", .pattern = "^if\\s*\\(.*?\\)$" },
    .{ .name = "jsSwitch", .pattern = "^switch\\s*\\(.*?\\)\\s*\\{$" },
    .{ .name = "jsTry", .pattern = "^(?:try|catch|finally)\\s*(?:\\(.*?\\))?\\s*\\{$" },
    .{ .name = "jsObject", .pattern = "^\\{(?:[^{}]*|\\{.*?\\})*\\}$" },
    .{ .name = "jsArray", .pattern = "^\\[(?:[^[\\]]*|\\[.*?\\])*\\]$" },
    .{ .name = "jsDestructuring", .pattern = "^(?:let|const|var)?\\s*(?:\\{[^}]*\\}|\\[[^\\]]*\\])\\s*=\\s*.*$" },
    .{ .name = "jsComment", .pattern = "^(?://.*|/\\*[\\s\\S]*?\\*/)$" },
    .{ .name = "jsImport", .pattern = "^import\\s+(?:\\{[^}]*\\}|\\*\\s+as\\s+\\w+|\\w+)\\s+from\\s+[\"'].*?[\"']$" },
    .{ .name = "jsExport", .pattern = "^export\\s+(?:default\\s+)?(?:class|function|const|let|var)\\s+.*$" },

    // Visual Basic Language Patterns
    .{ .name = "vbString", .pattern = "^\".*?\"$" },
    .{ .name = "vbNumber", .pattern = "^-?\\d+(?:\\.\\d+)?$" },
    .{ .name = "vbBoolean", .pattern = "^(?:True|False)$" },
    .{ .name = "vbVariable", .pattern = "^(?:Dim|Private|Public|Protected)\\s+([a-zA-Z_]\\w*)\\s+As\\s+\\w+$" },
    .{ .name = "vbFunction", .pattern = "^(?:Public\\s+|Private\\s+|Protected\\s+)?Function\\s+([a-zA-Z_]\\w*)\\s*\\((.*?)\\)\\s+As\\s+\\w+$" },
    .{ .name = "vbSub", .pattern = "^(?:Public\\s+|Private\\s+|Protected\\s+)?Sub\\s+([a-zA-Z_]\\w*)\\s*\\((.*?)\\)$" },
    .{ .name = "vbFunctionCall", .pattern = "^([a-zA-Z_]\\w*)\\s*\\((.*?)\\)$" },
    .{ .name = "vbClass", .pattern = "^(?:Public\\s+|Private\\s+)?Class\\s+([a-zA-Z_]\\w*)$" },
    .{ .name = "vbInterface", .pattern = "^(?:Public\\s+|Private\\s+)?Interface\\s+([a-zA-Z_]\\w*)$" },
    .{ .name = "vbProperty", .pattern = "^(?:Public\\s+|Private\\s+|Protected\\s+)?Property\\s+(?:Get|Let|Set)\\s+([a-zA-Z_]\\w*)\\s*\\((.*?)\\)\\s+As\\s+\\w+$" },
    .{ .name = "vbLoop", .pattern = "^(?:For|Do|While|For\\s+Each)\\s+.*$" },
    .{ .name = "vbIf", .pattern = "^(?:If|ElseIf|Else)\\s+.*?\\s+Then$" },
    .{ .name = "vbSelect", .pattern = "^Select\\s+Case\\s+.*$" },
    .{ .name = "vbTry", .pattern = "^(?:Try|Catch|Finally)\\s*$" },
    .{ .name = "vbArray", .pattern = "^(?:Dim|Private|Public|Protected)\\s+([a-zA-Z_]\\w*)\\s*\\(\\s*\\d*\\s*\\)\\s+As\\s+\\w+$" },
    .{ .name = "vbCollection", .pattern = "^New\\s+Collection$" },
    .{ .name = "vbComment", .pattern = "^'.*$" },
    .{ .name = "vbRemark", .pattern = "^REM\\s+.*$" },
    .{ .name = "vbModule", .pattern = "^(?:Public\\s+|Private\\s+)?Module\\s+([a-zA-Z_]\\w*)$" },
    .{ .name = "vbNamespace", .pattern = "^Namespace\\s+[\\w.]+$" },
    .{ .name = "vbImports", .pattern = "^Imports\\s+[\\w.]+$" },
    .{ .name = "vbReference", .pattern = "^Reference\\s+=\\s+.*$" },

    // Julia Language Patterns
    .{ .name = "juliaString", .pattern = "^(?:\"\"\".*?\"\"\"|\".*?\"|r\".*?\"|raw\".*?\")$" },
    .{ .name = "juliaNumber", .pattern = "^-?(?:\\d+(?:\\.\\d*)?|\\.\\d+)(?:e[+-]?\\d+)?(?:[ff]32|f64)?$" },
    .{ .name = "juliaBoolean", .pattern = "^(?:true|false|nothing|missing)$" },
    .{ .name = "juliaVariable", .pattern = "^[a-zA-Z_][\\w!]*$" },
    .{ .name = "juliaFunction", .pattern = "^function\\s+([a-zA-Z_][\\w!]*)\\s*\\([^)]*?\\)(?:\\s*::\\s*[\\w{}.\\[\\]]+)?\\s*(?:where\\s+\\{.*?\\})?$" },
    .{ .name = "juliaFunctionCall", .pattern = "^([a-zA-Z_][\\w!]*)\\s*\\((.*?)\\)$" },
    .{ .name = "juliaLambda", .pattern = "^(?:[^->]+->|function\\s*\\([^)]*\\)).*$" },
    .{ .name = "juliaStruct", .pattern = "^(?:mutable\\s+)?struct\\s+([a-zA-Z_][\\w!]*)(?:\\{.*?\\})?(?:<:\\s*[\\w.]+)?$" },
    .{ .name = "juliaAbstract", .pattern = "^abstract\\s+type\\s+([a-zA-Z_][\\w!]*)(?:\\{.*?\\})?(?:<:\\s*[\\w.]+)?$" },
    .{ .name = "juliaMacro", .pattern = "^@[a-zA-Z_][\\w!]*(?:\\s|$)" },
    .{ .name = "juliaLoop", .pattern = "^(?:for\\s+.*?\\s+in\\s+.*?|while\\s+.*?)$" },
    .{ .name = "juliaIf", .pattern = "^(?:if|elseif|else)\\s*.*?$" },
    .{ .name = "juliaBegin", .pattern = "^begin\\s*$" },
    .{ .name = "juliaTry", .pattern = "^(?:try|catch|finally)\\s*.*?$" },
    .{ .name = "juliaArray", .pattern = "^\\[(?:[^\\[\\]]*|\\[.*?\\])*\\]$" },
    .{ .name = "juliaTuple", .pattern = "^\\((?:[^()]*|\\(.*?\\))*\\)$" },
    .{ .name = "juliaDict", .pattern = "^Dict\\((?:[^()]*|\\(.*?\\))*\\)$" },
    .{ .name = "juliaComprehension", .pattern = "^\\[.*?\\s+for\\s+.*?\\s+in\\s+.*?\\]$" },
    .{ .name = "juliaComment", .pattern = "^#=(?:[^=#]|=(?!#))*=#$|^#.*$" },
    .{ .name = "juliaDocString", .pattern = "^\"\"\"[\\s\\S]*?\"\"\"$" },
    .{ .name = "juliaImport", .pattern = "^(?:using|import)\\s+(?:[\\w.]+(?:\\s*:\\s*(?:[\\w,\\s]+|\\(.*?\\)))?(?:\\s*,\\s*[\\w.]+(?:\\s*:\\s*(?:[\\w,\\s]+|\\(.*?\\)))?)*)$" },
    .{ .name = "juliaModule", .pattern = "^module\\s+[a-zA-Z_][\\w!]*$" },
    .{ .name = "juliaExport", .pattern = "^export\\s+(?:[a-zA-Z_][\\w!]*(?:\\s*,\\s*[a-zA-Z_][\\w!]*)*)$" },
    .{ .name = "juliaTypeParameter", .pattern = "^(?:[a-zA-Z_][\\w!]*)\\{.*?\\}$" },
    .{ .name = "juliaTypeAnnotation", .pattern = "^::\\s*[\\w{}.\\[\\]]+$" },
    .{ .name = "juliaBroadcast", .pattern = "^\\.\\w+$" },

    // Excel Formula Script
    .{ .name = "xlsFunctionCall", .pattern = "^\\s*[A-Z]+\\(.*\\)$" },
    .{ .name = "xlsCellReference", .pattern = "^[A-Z]+\\d+$" },
    .{ .name = "xlsRangeReference", .pattern = "^[A-Z]+\\d+:[A-Z]+\\d+$" },
    .{ .name = "xlsRelativeReference", .pattern = "^(?:[A-Z]*\\d+|[A-Z]+\\d*)$" },
    .{ .name = "xlsAbsoluteReference", .pattern = "^\\$[A-Z]+\\$\\d+$" },
    .{ .name = "xlsMixedReference", .pattern = "^(?:\\$[A-Z]+\\d+|[A-Z]+\\$\\d+)$" },
    .{ .name = "xlsStringLiteral", .pattern = "^\".*\"$" },
    .{ .name = "xlsNumberLiteral", .pattern = "^-?\\d+(\\.\\d+)?$" },
    .{ .name = "xlsBooleanLiteral", .pattern = "^(TRUE|FALSE)$" },
    .{ .name = "xlsArithmeticExpression", .pattern = "^.*(?:[+\\-*/^]).*$" },
    .{ .name = "xlsConditionalExpression", .pattern = "^.*(?:=|<|>|<>).*$" },
    .{ .name = "xlsArrayFormula", .pattern = "^\\{(?:\\s*=\\s*[A-Za-z]+\\([^\\)]*\\)|\\s*[A-Za-z0-9\\+\\-\\*/\\(\\)\\&\\^\\.]+(?:\\s*,\\s*[A-Za-z0-9\\+\\-\\*/\\(\\)\\&\\^\\.]+)*\\s*)\\}$" },

    // R language patterns
    .{ .name = "rVariableName", .pattern = "^[A-Za-z.][A-Za-z0-9._]*$" },
    .{ .name = "rFunctionCall", .pattern = "^[A-Za-z.][A-Za-z0-9._]*\\s*\\(.*\\)$" },
    .{ .name = "rAssignment", .pattern = "^\\s*[A-Za-z.][A-Za-z0-9._]*\\s*(<-|=)\\s*.*$" },
    .{ .name = "rNumericVector", .pattern = "^c\\((\\s*-?\\d+(\\.\\d+)?\\s*(,\\s*-?\\d+(\\.\\d+)?\\s*)*)?\\)$" },
    .{ .name = "rStringVector", .pattern = "^c\\((\\s*\".*?\"\\s*(,\\s*\".*?\"\\s*)*)?\\)$" },
    .{ .name = "rDataFrame", .pattern = "^[A-Za-z.][A-Za-z0-9._]*\\s*<-\\s*data\\.frame\\(.*\\)$" },
    .{ .name = "rPipeOperator", .pattern = "\\s*%>%\\s*" },
    .{ .name = "rComment", .pattern = "^\\s*#.*$" },
    .{ .name = "rLogicalOperator", .pattern = "(\\&\\&|\\|\\||\\!|==|!=|<|<=|>|>=)" },
    .{ .name = "rIndexing", .pattern = "\\[.*?\\]" },
    .{ .name = "rForLoop", .pattern = "^\\s*for\\s*\\(\\s*[A-Za-z.][A-Za-z0-9._]*\\s*in\\s*.*\\)\\s*\\{" },
    .{ .name = "rIfStatement", .pattern = "^\\s*if\\s*\\(.*\\)\\s*\\{" },
    .{ .name = "rElseStatement", .pattern = "^\\s*else\\s*\\{" },
    .{ .name = "rLibraryCall", .pattern = "^\\s*(library|require)\\s*\\(.*\\)$" },
    .{ .name = "rFunctionDefinition", .pattern = "^\\s*[A-Za-z.][A-Za-z0-9._]*\\s*<-\\s*function\\s*\\(.*\\)\\s*\\{" },
    .{ .name = "rListCreation", .pattern = "^list\\(.*\\)$" },
    .{ .name = "rApplyFamily", .pattern = "(apply|lapply|sapply|vapply|mapply|tapply)\\s*\\(.*\\)" },

    // Credit cards and Bank accounts
    .{ .name = "creditCard", .pattern = "^\\d{4}[- ]?\\d{4}[- ]?\\d{4}[- ]?\\d{4}$" },
    .{ .name = "bankAccount", .pattern = "^\\d{8,20}$" },
    .{ .name = "iban", .pattern = "^[A-Z]{2}\\d{2}[A-Z0-9]{1,30}$" },
    .{ .name = "swiftCode", .pattern = "^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$" },

    // Mathematic formulas
    .{ .name = "simpleEquation", .pattern = "^[A-Za-z0-9\\+\\-\\*/=\\(\\)\\.\\^\\s]+$" },
    .{ .name = "quadraticFormula", .pattern = "^-?\\d*[A-Za-z]\\^2\\s*[+-]?\\s*\\d*[A-Za-z]\\s*[+-]?\\s*\\d+\\s*=\\s*0$" },

    // DNA and Chemistry
    .{ .name = "dnaSequence", .pattern = "^[ACGT]+$" },
    .{ .name = "chemicalFormula", .pattern = "^[A-Z][a-z]?\\d*(?:[A-Z][a-z]?\\d*)*$" },

    // Measurements
    .{ .name = "metricMeasurement", .pattern = "^\\d+(\\.\\d+)?\\s?(mm|cm|m|km)$" },
    .{ .name = "imperialMeasurement", .pattern = "^\\d+(\\.\\d+)?\\s?(in|ft|yd|mi)$" },
    .{ .name = "temperature", .pattern = "^-?\\d+(\\.\\d+)?\\s?(°C|°F|K)$" },

    // Barcodes and QR-codes
    .{ .name = "upc", .pattern = "^\\d{12}$" },
    .{ .name = "ean13", .pattern = "^\\d{13}$" },
    .{ .name = "code128", .pattern = "^[!-~]+$" },
    .{ .name = "qrCodeData", .pattern = "^[A-Za-z0-9\\-._~:/?#\\[\\]@!$&'()*+,;=%]*$" },
    .{ .name = "isbn10", .pattern = "^\\d{9}[\\dX]$" },
    .{ .name = "isbn13", .pattern = "^978\\d{10}$" },

    // Semantic Versioning (major.minor.patch)
    .{ .name = "semVer", .pattern = "^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?(?:\\+([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?$" },
    .{ .name = "strictSemVer", .pattern = "^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)$" },
    .{ .name = "versionWithBuild", .pattern = "^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:\\+([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?$" },
    .{ .name = "preReleaseVersion", .pattern = "^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)-([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*)$" },
    .{ .name = "versionWithPrefix", .pattern = "^v?(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)$" },
    .{ .name = "dateVersion", .pattern = "^(\\d{4})[.-]?(0[1-9]|1[0-2])[.-]?(0[1-9]|[12]\\d|3[01])$" },
    .{ .name = "windowsVersion", .pattern = "^(\\d+)\\.(\\d+)\\.(\\d+)\\.(\\d+)$" },
    .{ .name = "pythonVersion", .pattern = "^(\\d+)\\.(\\d+)\\.(\\d+)(?:[abrc]\\d+|\\.post\\d+|\\.dev\\d+)?$" },
    .{ .name = "mavenVersion", .pattern = "^(\\d+)(?:\\.(\\d+))?(?:\\.(\\d+))?(?:-([A-Za-z0-9.-]+))?$" },

    // Common word-based regex patterns
    .{ .name = "quotedWord", .pattern = "\"([^\"]+)\"" },
    .{ .name = "singleWord", .pattern = "^\\w+$" },
    .{ .name = "multipleWords", .pattern = "^[\\w\\s]+$" },
    .{ .name = "camelCaseWord", .pattern = "^[a-z]+([A-Z][a-z]*)*$" },
    .{ .name = "snakeCaseWord", .pattern = "^[a-z]+(_[a-z]+)*$" },
    .{ .name = "pascalCaseWord", .pattern = "^[A-Z][a-z]+([A-Z][a-z]*)*$" },
    .{ .name = "kebabCaseWord", .pattern = "^[a-z]+(-[a-z]+)*$" },

    // RTL and Language Support
    .{ .name = "arabicChar", .pattern = "^[\\u0600-\\u06FF]$" },
    .{ .name = "arabicWord", .pattern = "^[\\u0600-\\u06FF]+$" },
    .{ .name = "rtlSentence", .pattern = "^[\\u0590-\\u05FF\\u0600-\\u06FF\\s]+$" },
    .{ .name = "russianWord", .pattern = "^[\\u0400-\\u04FF]+$" },
    .{ .name = "chineseChar", .pattern = "^[\\u4E00-\\u9FFF]+$" },
    .{ .name = "nonLatinWord", .pattern = "^[^a-zA-Z]+$" },

    // Number detection in different numeral systems
    .{ .name = "arabicNumerals", .pattern = "^[\\u0660-\\u0669]+$" },
    .{ .name = "devanagariNumerals", .pattern = "^[\\u0966-\\u096F]+$" },
    .{ .name = "easternArabicNumerals", .pattern = "^[\\u06F0-\\u06F9]+$" },
    .{ .name = "universalNumber", .pattern = "^[0-9\\u0660-\\u0669\\u06F0-\\u06F9\\u0966-\\u096F]+$" },

    // Punctuation variations
    // Pattern contains Unicode curly double quotes U+201D (right) and U+201C (left)
    .{ .name = "punctuationMarks", .pattern = "^[.,!?;:'\"" ++ "\u{201D}\u{201C}" ++ "\\(\\)\\[\\]\\{\\}]+$" },

    // Password Complexity Patterns
    .{ .name = "passworWeak", .pattern = "^.{6,}$" },
    .{ .name = "passwordSimple", .pattern = "^.{8,}$" },
    .{ .name = "passwordWithDigits", .pattern = "^(?=.*[0-9]).{8,}$" },
    .{ .name = "passwordWithUpperLower", .pattern = "^(?=.*[a-z])(?=.*[A-Z]).{8,}$" },
    .{ .name = "passwordWithSpecialChar", .pattern = "^(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$" },
    .{ .name = "passwordStrong", .pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?\":{}|<>]).{12,}$" },

    // API Keys and Secrets Detection
    .{ .name = "hexSecret", .pattern = "^[a-fA-F0-9]{32,}$" },
    .{ .name = "base64Secret", .pattern = "^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$" },
    .{ .name = "jwtToken", .pattern = "^[A-Za-z0-9-_]+\\.[A-Za-z0-9-_]+\\.[A-Za-z0-9-_]+$" },
    .{ .name = "awsAccessKey", .pattern = "^AKIA[0-9A-Z]{16}$" },
    .{ .name = "awsSecretKey", .pattern = "^[0-9a-zA-Z/+]{40}$" },
    .{ .name = "privateKeyPEM", .pattern = "-----BEGIN (RSA|EC|DSA|PRIVATE) KEY-----[\\s\\S]+-----END (RSA|EC|DSA|PRIVATE) KEY-----" },

    // Personally Identifiable Information (PII)
    .{ .name = "ssnUSA", .pattern = "^\\d{3}-\\d{2}-\\d{4}$" },
    .{ .name = "passportNumber", .pattern = "^[A-Z0-9]{6,9}$" },

    // Other Sensitive Data
    .{ .name = "hexadecimalEntropy", .pattern = "^[0-9a-fA-F]{64,}$" },
    .{ .name = "uuid", .pattern = "^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$" },
    .{ .name = "bcryptHash", .pattern = "^\\$2[ayb]\\$\\d{2}\\$[./A-Za-z0-9]{53}$" },
};
