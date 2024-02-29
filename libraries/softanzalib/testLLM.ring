
# Example of code generated using Amistral AO (LeChat)
# (https://chat.mistral.ai/)

# Prompt used :
# 	Write a code in Ring programming language of a function
#	called RemoveBounds(str) that removes bounds from a strings.
#	Bounds are made of a repeated char at the start or the end
#	of the string. For example the string "<<<hello>>>" is bounded
#	with "<<<" and ">>>", and feeded to the function
#	RemoveBounds("<<<hello>>", the function should return "hello".

# Generated code:

# Project : Remove bounds from string

	str = "<<<hello>>>"
	str = RemoveBounds(str)
	see "The string after removing bounds is : " + str
	
	func RemoveBounds str
	     // Get the first and last characters of the string
	     boundStart = str[1]
	     boundEnd = str[len(str)]
	
	     // Find the first character that is not the same as the start of the string
	     i = 1
	     while str[i] = boundStart
	          i = i + 1
	     end
	
	     // Remove the bounds from the end of the string
	     while str[len(str)] = boundEnd
	          str = substr(str, 1, len(str) - 1)
	     end
	
	     // Return the substring between the first and last non-bound characters
	     return substr(str, i, len(str) - i + 1)

