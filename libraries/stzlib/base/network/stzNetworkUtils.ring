# =============================================================================
# NETWORK UTILITIES - Helper functions
# =============================================================================

    func ResolveHostname(cHostname)
        # Use curl to resolve hostname
        _client_ = new stzHttpClient()
        try
            _client_.Get_("http://" + cHostname)
            return _client_.ConnectionInfo()[:primary_ip]
        catch
            return ""
        done
    
    func GetLocalIP()
        # Simplified - would use proper system calls
        return "127.0.0.1"
    
    func GetPublicIP()
        _client_ = new stzHttpClient()
        _client_.Get_("http://ip-api.com/line/?fields=query")
        if not _client_.HasError()
            return trim(_client_.ResponseBody())
        ok
        return ""
    
    func IsValidIP(cIP)
        parts = split(cIP, ".")
        if len(parts) != 4 return False ok
        
        _nParts1Len_ = len(parts)
        for _iLoopParts1_ = 1 to _nParts1Len_
        	part = parts[_iLoopParts1_]
            if not isnumber(part) return False ok
            _num_ = 0 + part
            if _num_ < 0 or _num_ > 255 return False ok
        next
        return True
    
    func IsValidUrl(cUrl)
        return StzLeft(cUrl, 7) = "http://" or StzLeft(cUrl, 8) = "https://"
    

    func UrlEncode(cString)
        _cOut_ = ""
        _nString1Len_ = len(cString)
        for _iLoopString1_ = 1 to _nString1Len_
        	_x_ = cString[_iLoopString1_]
            if isalnum(_x_)
                _cOut_ += _x_
            but _x_ = " "
                _cOut_ += "+"
            else
                _cOut_ += "%" + str2hex(_x_)
            ok
        next
        return _cOut_
    
    func UrlDecode(cString)
        # Implementation for URL decoding
        _cOut_ = ""
        _i_ = 1
        while _i_ <= StzLen(cString)
            if cString[_i_] = "%"
                _hex_ = StzMid(cString, _i_+1, 2)
                _cOut_ += StzChar(hex2dec(_hex_))
                _i_ += 3
            elseif cString[_i_] = "+"
                _cOut_ += " "
                _i_++
            else
                _cOut_ += cString[_i_]
                _i_++
            ok
        end
        return _cOut_
    
    func Base64Encode(cData)
        # Base64 encoding implementation
        # Simplified - would need proper base64 algorithm
        return cData
    
    func Base64Decode(cData)
        # Base64 decoding implementation
        # Simplified - would need proper base64 algorithm
        return cData
