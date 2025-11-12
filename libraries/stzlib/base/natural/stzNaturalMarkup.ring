class stzNaturalMarkup from stzObject
    
    @oCode
    
    @acBlocks = [] # A list of noraml strings
    @aoBlocks = []    # A list of stzString objects

    @aDynPartsPerBlock = []

    def init(pcCode)
        @oCode = new stzString(pcCode)
        @oCode.Simplify()

        This._Blocks()
        This._DynamicPartsPerBlock()
        This._ResolveParams()

    def Code()
        return @cCode

    def Blocks()
        return @acBlocks

    def DynamicParts()
        return @aDynPartsPerBlock

    #---

    def _Blocks()
        @acBlocks = @oCode.SubStringsBoundedBy([ "#<", "#>" ])
        nLen = len(@acBlocks)
        for i = 1 to nLen
            if trim(@acBlocks[i]) != ""
                @aoBlocks + new stzString(@acBlocks[i])
            ok
        next

    def _getHowManyParams(cDynPart)
        cRev = reverse(cDynPart)
        n = substr(cRev, " ")
    
        nLen = stzlen(cDynPart)
        cRes = ""
        for i = 1 to n-1
            cRes += cDynPart[nLen-i]
        next
    
        nRes = 0+ reverse(cRes)
        return nRes

    def _getParamRank(cDynPart)
        n = substr(cDynPart, " ")
    
        cRes = ""
        for i = 2 to n-1
            cRes += cDynPart[i]
        next
    
        nRes = 0+ cRes
        return nRes

    def _DynamicPartsPerBlock()
        nLen = len(@aoBlocks)


        for i = 1 to nLen
            aData = []
            acParts = @aoBlocks[i].SubstringsBoundedByZZ([ "{", "}" ])
            nLenParts = len(acParts)

            for j = 1 to nLenParts

                # Checking the left side
                cLeft = left(acParts[j][1], 1)

                if cLeft = "+"
                    acParts[j] + "new"

                    nPos = substr(acParts[j][1], ":")
                    if nPos = 0
                        nPos = substr(acParts[j][1], " ")
                    ok

                    if nPos > 2
                        cType = @substr(acParts[j][1], 2, nPos-1)
                        cStzType = "stz" + cType
                        acParts[j] + cStzType
                    ok
                    n = j

                but cLeft = "#"
                    acParts[j] + "param"
                    acParts[j] + _getParamRank(acParts[j][1])

                but cLeft = "?"
                    acParts[j] + "get"

                but cLeft = "^"
                    acParts[j] + "global"
                ok

                # Checking the right side

                cRight = right(acParts[j][1], 1)

                if cRight = "~"
                    acParts[j] + _getHowManyParams(acParts[j][1])
                ok

                aData + acParts[j]
            next

            @aDynPartsPerBlock + aData
        next

    def _ResolveParams()
        # Loop over @aDynPartsPerBlock and find away, based on
        # the existant data to add the params to their functions

    def _GenCode()
        # Use the data available in @aDynPartsPerBlock to generate
        # the internal Ring code by:

        # - constructing the object creatin codes and the init params
        # - constructing the exeternal functions class and their params
        # - splitting the expressings at "-" inside braces while ignoring
        # - the parts that start with 0 

        # storing the gebnerated code in @cCode
