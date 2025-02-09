
# A class that applies regex to lists!

class stzListPattern from stzListex

class stzListex

	# The underlying regex engine
	oRegex
	
	# Pattern types we'll support

	NUMBER_PATTERN    = "(?:\d+(?:\.\d+)?)"
	STRING_PATTERN    = "(?:\" + char(34) + "[^\" + char(34) + "]*\" + char(34) + ")"
	ANY_VALUE_PATTERN = "(?:\d+(?:\.\d+)?|\" + char(34) + "[^\" + char(34) + "]*\" + char(34) + ")"
	
	def init(cPattern)

		# Convert the high-level list pattern to a regex pattern
		cRegexPattern = _transformPatternToRegex(cPattern)
		oRegex = new stzRegex(cRegexPattern)
	
	def _transformPatternToRegex(cPattern)

		cResult = cPattern

		# Define our patterns for different types

		NUMBER_PATTERN = "\d+(?:\.\d+)?"
		STRING_PATTERN = '"[^"]*"'
    
		# Replace the special markers with their regex equivalents
		#NOTE // We're not adding extra brackets since they're already in the pattern

		cResult = substr(cResult, "@N", NUMBER_PATTERN)
		cResult = substr(cResult, "@S", STRING_PATTERN)
  
		return cResult
	
	def match(aList)
		cListStr = @@(aList)
		return oRegex.Match(cListStr)
	
	def matchRecursive(aList)
		cListStr = @@(aList)
		return oRegex.MatchRecursive(cListStr)
	
	# Helper method to create common list patterns

	def NumberAtPosition(n)
		return "(?:\[(?:(?:[^,]*,\s*){" + (n-1) + "})" + NUMBER_PATTERN + ")"
	
	def StringAtPosition(n)
		return "(?:\[(?:(?:[^,]*,\s*){" + (n-1) + "})" + STRING_PATTERN + ")"
	
	def HasSublistContaining(cElement)
		return "\[(?:[^\[\]]*|\[(?:[^\[\]]*|(?R))*\])*" + cElement + "(?:[^\[\]]*|\[(?:[^\[\]]*|(?R))*\])*\]"
