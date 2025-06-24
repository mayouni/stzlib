load "closing.ring" # Temprorarily file!

/*---
*/
cHtmlDoc = "
<html>
    <head>
        <title>Sample Document</title>
    </head>
    <body>
        <div>
            <h1>Title of the Document</h1>
            <p>First paragraph</p>
            <div>
                <span>Nested span content</span>
                <div>
                    <p>Inner content goes here...</p>
                    <ul>
                        <li>First item</li>
                        <li>Second item</li>
                        <li>Third item</li>
                    </ul>
                </div>
            </div>
            <footer>
                <p>Footer of the document</p>
            </footer>
        </div>
    </body>
</html>
"

oParser = new StzDocParser(cHtmlDoc)
oParser.parse(:HTML)
oParser.Show()

#-->
# <div> «<p>First paragraph</p>»
# ├── <p> «First paragraph»
# ├── <div> «<span>Nested span</span>»
#     └── <span> «Nested span»
# └── <p> «Last paragraph»



class StzDocParser
	aStack = []
	cContent = ""
	aDomain = []
	aResult = []
	aNodeStack = []

	def init(cStr)
		cContent = cStr
		aStack = []
		aResult = []
		aNodeStack = []

	def parse(cDomain)
		if _$aCLOSING_SUBSTRINGS_[cDomain] != ""
			aDomain = _$aCLOSING_SUBSTRINGS_[cDomain]
		else
			return "Error: Domain not found"
		ok
	
		nPos = 1
		
		while nPos <= len(cContent)
			cFound = findOpeningAt(nPos)
			
			if cFound != NULL
				aNode = []
				aNode = [
					:type = cFound,
					:start = nPos,
					:content = "",
					:children = [],
					:end = 0
				]
				
				# Store current position to reparse inner content
				nInnerStart = nPos + len(cFound)
				
				nClosingPos = findClosing(cFound, nInnerStart)
				
				if nClosingPos > 0
					# Get the inner content
					cInnerContent = substr(cContent, 
						nInnerStart,
						nClosingPos - nInnerStart)
					
					# Parse inner content recursively
					oInnerParser = new StzDocParser(cInnerContent)
					aInnerResult = oInnerParser.parse(cDomain)
					
					# Update node
					aNode[:content] = cInnerContent
					aNode[:end] = nClosingPos
					aNode[:children] = aInnerResult
					
					# Add to result
					aResult + aNode
					
					# Move position
					nPos = nClosingPos + len(ClosingSubString(cFound))
				else
					return "Error: Unclosed delimiter " + cFound
				ok
			else
				nPos++
			ok
		end
		
		return aResult

	func show()
		see nl + "Document Structure:" + nl + nl
		showNode(aResult, 0, [])

	private

	def findOpeningAt(nPos)
		for aDelim in aDomain
			cOpening = aDelim[1]
			if substr(cContent, nPos, len(cOpening)) = cOpening
				return cOpening
			ok
		next
		return NULL

	def findClosing(cOpening, nStartPos)
		cClosing = ClosingSubString(cOpening)
		nLevel = 1
		
		for i = nStartPos to len(cContent)
			if substr(cContent, i, len(cOpening)) = cOpening
				nLevel++
			but substr(cContent, i, len(cClosing)) = cClosing
				nLevel--
				if nLevel = 0
					return i
				ok
			ok
		next
		
		return 0

	func showNode(aNodes, nLevel, aLastBranches)
		for node in aNodes
			isLast = (node = aNodes[len(aNodes)])
			
			# Draw branch based on level
			if nLevel > 0
				for i = 1 to nLevel-1
					see "│   "
				next
				
				if isLast
					see "└── "
				else
					see "├── "
				ok
			ok

			# Show node type and brief content preview
			cPreview = _formatContent(node[:content])
			see node[:type] + " " + cPreview + nl
			
			# Add current branch status for children
			if len(node[:children]) > 0
				aNewBranches = aLastBranches + isLast
				showNode(node[:children], nLevel + 1, aNewBranches)
			ok
		next

	func _formatContent(cContent)
		# Get first non-empty line of content
		aLines = split(cContent, nl)
		for cLine in aLines
			cLine = trim(cLine)
			if len(cLine) > 0
				if len(cLine) > 30
					return "«" + left(cLine, 27) + "...»"
				else
					return "«" + cLine + "»"
				ok
			ok
		next
		return ""
