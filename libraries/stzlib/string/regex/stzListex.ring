# stzListex.ring
# A class that applies regex patterns to lists, allowing for
# powerful list structure matching

# ListEx - List Pattern Matching
# Example: [@N, @S+] matches [42, "hello", "world"]

# stzListex.ring
# A class that applies regex patterns to lists, allowing for
# powerful list structure matching

#----------- IMPLEMENTED BY QWENT AI

class stzListPattern from stzListex

class stzListEx
    # Core regex patterns for different types
    NUMBER_PATTERN = "(?:-?\d+(?:\.\d+)?)"
    STRING_PATTERN = '\"(?:[^\"\\]|\\.)*\"'
    LIST_PATTERN = "\[(?:[^\[\]]|\[(?:[^\[\]]|(?R))*\])*\]"
    BOOLEAN_PATTERN = "(?i)(?:true|false)"
    NULL_PATTERN = "(?i)null"
    ANY_PATTERN = "(?:" + NUMBER_PATTERN + "|" + STRING_PATTERN + "|" + 
                  LIST_PATTERN + "|" + BOOLEAN_PATTERN + "|" + NULL_PATTERN + ")"

    oRegex
    oPattern

    def init(cPattern)
        oPattern = cPattern
        cRegexPattern = _transformPatternToRegex(cPattern)
        oRegex = new stzRegex(cRegexPattern)
    def _transformPatternToRegex(cPattern)
        # Ensure pattern is wrapped in list brackets
        if NOT (left(cPattern, 1) = "[" and right(cPattern, 1) = "]")
            cPattern = "[" + cPattern + "]"
        ok

        # Process pattern transformations in order
        cPattern = _handleRangeRepetitions(cPattern)
        cPattern = _handleFixedRepetitions(cPattern)
        cPattern = _handleQuantifiers(cPattern)
        cPattern = _replaceBasePatterns(cPattern)
        cPattern = _normalizeSpacing(cPattern)
        
        return "^" + cPattern + "$"

    def _handleRangeRepetitions(cPattern)
        # Handle @XRm-n patterns
        while true
            oMatcher = new stzRegex("@([NSLBU$])R(\d+)-(\d+)")
            if NOT oMatcher.Match(cPattern)
                exit
            ok

            aMatches = oMatcher.CapturedGroups()
            cType = aMatches[1]
            nMin = number(aMatches[2])
            nMax = number(aMatches[3])
            
            cReplacement = "(?:@" + cType + "(?:,\s*@" + cType + "){" + 
                          (nMin-1) + "," + (nMax-1) + "})"
            
            cPattern = oMatcher.SubStr(cPattern, cReplacement, 1)
        end
        return cPattern

    def _handleFixedRepetitions(cPattern)
        # Handle @XRn patterns
        while true
            oMatcher = new stzRegex("@([NSLBU$])R(\d+)")
            if NOT oMatcher.Match(cPattern)
                exit
            ok

            aMatches = oMatcher.CapturedGroups()
            cType = aMatches[1]
            nCount = number(aMatches[2])
            
            cReplacement = "(?:@" + cType + "(?:,\s*@" + cType + "){" + 
                          (nCount-1) + "})"
            
            cPattern = oMatcher.SubStr(cPattern, cReplacement, 1)
        end
        return cPattern

def _handleQuantifiers(cPattern)
        aQuantifiers = [
            ["@([NSLBU$])\+", "{1,}"],
            ["@([NSLBU$])\*", "{0,}"],
            ["@([NSLBU$])\?", "{0,1}"]
        ]

        for aQuant in aQuantifiers
            while true
                oMatcher = new stzRegex(aQuant[1])
                if NOT oMatcher.Match(cPattern)
                    exit
                ok

                aGroups = oMatcher.CapturedGroups()
                if len(aGroups) = 0
                    exit
                ok

                cType = aGroups[1]
                cReplacement = "(?:@" + cType + "(?:,\s*@" + cType + ")" + 
                              aQuant[2] + ")"
                
                cPattern = oMatcher.SubStr(cPattern, cReplacement, 1)
            end
        next
        return cPattern

    def _replaceBasePatterns(cPattern)
        # Replace @X tokens with actual regex patterns
        aPatterns = [
            ["@N", NUMBER_PATTERN],
            ["@S", STRING_PATTERN],
            ["@L", LIST_PATTERN],
            ["@B", BOOLEAN_PATTERN],
            ["@U", NULL_PATTERN],
            ["@$", ANY_PATTERN]
        ]

        for aPat in aPatterns
            cPattern = substr(cPattern, aPat[1], "(?:" + aPat[2] + ")")
        next
        return cPattern

    def _normalizeSpacing(cPattern)
        # Normalize whitespace around delimiters
        cPattern = substr(cPattern, ",", "\s*,\s*")
        cPattern = substr(cPattern, "[", "\[\s*")
        cPattern = substr(cPattern, "]", "\s*\]")
        return cPattern

    def Match(aList)
        return oRegex.Match(@@(aList))

    def Pattern()
        return oPattern

    def RegexPattern()
        return oRegex.Pattern()
