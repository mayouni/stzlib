load "../max/stzmax.ring"

_$aCLOSING_SUBSTRINGS_ = [

	#---------------------------------#
	#  BASIC BRACKETS AND PARENTHESES #
	#---------------------------------#

	:Bracket = [
		[ "[", "]" ],
		[ "(", ")" ],
		[ "{", "}" ],
		[ "<", ">" ]
	],

	#---------------------#
	#  STRING DELIMITERS  #
	#---------------------#

	:StringDelimiter = [
		[ "'", "'" ],
		[ '"', '"' ],
		[ "`", "`" ],
		[ "'''", "'''" ],	# Multiline strings
		[ "```", "```" ]	# Markdown code blocks
	],

	#------------------#
	#  COMMENT BLOCKS  #
	#------------------#

	:Comment = [
		[ "/*", "*/" ],
		[ "<!--", "-->" ],
		[ "#{", "#}" ]
	],

	#-------------#
	#  HTML TAGS  #
	#-------------#

	:HTML = [
		[ "<html>", "</html>" ],
		[ "<head>", "</head>" ],
		[ "<title>", "</title>" ],
		[ "<body>", "</body>" ],
		[ "<div>", "</div>" ],
		[ "<p>", "</p>" ],
		[ "<span>", "</span>" ],
		[ "<h1>", "</h1>" ],
		[ "<h2>", "</h2>" ],
		[ "<h3>", "</h3>" ],
		[ "<h4>", "</h4>" ],
		[ "<h5>", "</h5>" ],
		[ "<h6>", "</h6>" ],
		[ "<a>", "</a>" ],
		[ "<ul>", "</ul>" ],
		[ "<ol>", "</ol>" ],
		[ "<li>", "</li>" ],
		[ "<table>", "</table>" ],
		[ "<thead>", "</thead>" ],
		[ "<tbody>", "</tbody>" ],
		[ "<tr>", "</tr>" ],
		[ "<td>", "</td>" ],
		[ "<th>", "</th>" ],
		[ "<img>", "</img>" ],
		[ "<script>", "</script>" ],
		[ "<style>", "</style>" ],
		[ "<header>", "</header>" ],
		[ "<footer>", "</footer>" ],
		[ "<nav>", "</nav>" ],
		[ "<section>", "</section>" ],
		[ "<article>", "</article>" ],
		[ "<aside>", "</aside>" ],
		[ "<form>", "</form>" ],
		[ "<input>", "</input>" ],
		[ "<button>", "</button>" ],
		[ "<label>", "</label>" ],
		[ "<select>", "</select>" ],
		[ "<option>", "</option>" ],
		[ "<textarea>", "</textarea>" ],
	],

	#------------#
	#  MARKDOWN  #
	#------------#

	:Markdown = [
		[ "**", "**" ],      // Bold Text
		[ "*", "*" ],        // Italic Text
		[ "~~", "~~" ],      // Strikethrough Text
		[ "`", "`" ],        // Inline Code
		[ "```", "```" ]     // Code Block

	],

	#--------------------#
	#  TEMPLATE ENGINES  #
	#--------------------#

	:Template = [
		[ "<%", "%>" ],
		[ "{{", "}}" ],
		[ "{%", "%}" ]
	],




]


//? ClosingSubStringXT(:Of = "**", :In = :Markdown)
#--> **

//? ClosingSubString("**")

#######

func ClosingSubStrings()
	return _$aCLOSING_SUBSTRINGS_

func ClosingSubStringXT(pcSubStr, pcDomain)
	if CheckParams()
		if isList(pcSubStr) and len(pcSubStr) = 2 and
		   isString(pcSubStr[1]) and pcSubStr[1] = :Of

			pcSubStr = pcSubStr[2]
		ok

		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		if isList(pcDomain) and len(pcDomain) = 2 and
		   isString(pcDomain[1]) and pcDomain[1] = :In

			pcDomain = pcDomain[2]
		ok

		if NOT ( isString(pcDomain) and islower(pcDomain) )
			StzRaise("Incorrect param type! pcDomain must be a lowercased string.")
		ok
	ok

	_cResult_ = ClosingSubStrings()[pcDomain][pcSubStr]
	return _cResult_

func ClosingSubString(pcSubStr)
	if CheckParams()
		if isList(pcSubStr) and len(pcSubStr) = 2 and
		   isString(pcSubStr[1]) and pcSubStr[1] = :Of

			pcSubStr = pcSubStr[2]
		ok

		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok
	ok

	_aData_ = ClosingSubStrings()
	_nLen_ = len(_aData_)

	for @i = 1 to _nLen_
		_aDomainData_ = _aData_[@i][2]
		_cResult_ = _aDomainData_[pcSubstr]

		if _cResult_ != ""
			return _cResult_
		ok

	next

	StzRaise("Can't proceed! There is no closing substring for the string you privided." + NL +
		 "You can add it yourself to the global variable _$aCLOSING_SUBSTRINGS_.")
