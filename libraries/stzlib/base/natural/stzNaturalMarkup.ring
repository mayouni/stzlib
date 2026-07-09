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
        _nLen_ = len(@acBlocks)
        for i = 1 to _nLen_
            if trim(@acBlocks[i]) != ""
                @aoBlocks + new stzString(@acBlocks[i])
            ok
        next

    def _getHowManyParams(cDynPart)
        _cRev_ = reverse(cDynPart)
        _n_ = StzFindFirst(_cRev_, " ")
    
        _nLen_ = stzlen(cDynPart)
        _cRes_ = ""
        for i = 1 to _n_-1
            _cRes_ += cDynPart[_nLen_-i]
        next
    
        _nRes_ = 0+ reverse(_cRes_)
        return _nRes_

    def _getParamRank(cDynPart)
        _n_ = StzFindFirst(cDynPart, " ")
    
        _cRes_ = ""
        for i = 2 to _n_-1
            _cRes_ += cDynPart[i]
        next
    
        _nRes_ = 0+ _cRes_
        return _nRes_

    def _DynamicPartsPerBlock()
        _nLen_ = len(@aoBlocks)


        for i = 1 to _nLen_
            _aData_ = []
            _acParts_ = @aoBlocks[i].SubstringsBoundedByZZ([ "{", "}" ])
            _nLenParts_ = len(_acParts_)

            for j = 1 to _nLenParts_

                # Checking the left side
                _cLeft_ = StzLeft(_acParts_[j][1], 1)

                if _cLeft_ = "+"
                    _acParts_[j] + "new"

                    _nPos_ = StzFindFirst(_acParts_[j][1], ":")
                    if _nPos_ = 0
                        _nPos_ = StzFindFirst(_acParts_[j][1], " ")
                    ok

                    if _nPos_ > 2
                        _cType_ = @StzMid(_acParts_[j][1], 2, _nPos_-1)
                        _cStzType_ = "stz" + _cType_
                        _acParts_[j] + _cStzType_
                    ok
                    _n_ = j

                but _cLeft_ = "#"
                    _acParts_[j] + "param"
                    _acParts_[j] + _getParamRank(_acParts_[j][1])

                but _cLeft_ = "?"
                    _acParts_[j] + "get"

                but _cLeft_ = "^"
                    _acParts_[j] + "global"
                ok

                # Checking the right side

                _cRight_ = StzRight(_acParts_[j][1], 1)

                if _cRight_ = "~"
                    _acParts_[j] + _getHowManyParams(_acParts_[j][1])
                ok

                _aData_ + _acParts_[j]
            next

            @aDynPartsPerBlock + _aData_
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
