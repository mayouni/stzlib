load "../stzlib.ring"



/*-----------

pron()

# Example usage:
/*
str = "abcdefghi"
chunks = ConsecutiveSubStringsOfNChars(str, 2)
? chunks  # Output: ["ab", "cd", "ef", "gh", "bc", "de", "fg", "hi"]

str = "Hello"
chunks = ConsecutiveSubStringsOfNChars(str, 2)
? chunks  # Output: ["He", "ll", "el", "lo"]

str = "123456789012"
? ConsecutiveSubStringsOfNChars(str,3)

pron()

str = "phpringringringpythonrubyruby"
? ConsecutiveSubStringsOfNChars(str, 4)

proff()

func ConsecutiveSubStringsOfNChars(str, n)

    if not isString(str) return [] ok
    if not isNumber(n) return [] ok
    if n <= 0 return [] ok
    if n > len(str) return [] ok
    
    aResult = []

   for i = 1 to n
	    # First pass - starting from position 1
	    for j = i to len(str) step n
	        if j + n - 1 <= len(str)
	            add(aResult, substr(str, j, n))
	        ok
	    next

   next

    return aResult

