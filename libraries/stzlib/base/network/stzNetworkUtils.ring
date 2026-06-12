# =============================================================================
# NETWORK UTILITIES - Helper functions
# =============================================================================

    func ResolveHostname(cHostname)
        # Use curl to resolve hostname
        client = new stzHttpClient()
        try
            client.Get_("http://" + cHostname)
            return client.ConnectionInfo()[:primary_ip]
        catch
            return ""
        done
    
    func GetLocalIP()
        # Simplified - would use proper system calls
        return "127.0.0.1"
    
    func GetPublicIP()
        client = new stzHttpClient()
        client.Get_("http://ip-api.com/line/?fields=query")
        if not client.HasError()
            return trim(client.ResponseBody())
        ok
        return ""
    
    func IsValidIP(cIP)
        parts = split(cIP, ".")
        if len(parts) != 4 return False ok
        
        _nParts1Len_ = len(parts)
        for _iLoopParts1_ = 1 to _nParts1Len_
        	part = parts[_iLoopParts1_]
            if not isnumber(part) return False ok
            num = 0 + part
            if num < 0 or num > 255 return False ok
        next
        return True
    
    func IsValidUrl(cUrl)
        return StzLeft(cUrl, 7) = "http://" or StzLeft(cUrl, 8) = "https://"
    

    func UrlEncode(cString)
        cOut = ""
        _nString1Len_ = len(cString)
        for _iLoopString1_ = 1 to _nString1Len_
        	x = cString[_iLoopString1_]
            if isalnum(x)
                cOut += x
            but x = " "
                cOut += "+"
            else
                cOut += "%" + str2hex(x)
            ok
        next
        return cOut
    
    func UrlDecode(cString)
        # Implementation for URL decoding
        cOut = ""
        i = 1
        while i <= StzLen(cString)
            if cString[i] = "%"
                hex = StzMid(cString, i+1, 2)
                cOut += StzChar(hex2dec(hex))
                i += 3
            elseif cString[i] = "+"
                cOut += " "
                i++
            else
                cOut += cString[i]
                i++
            ok
        end
        return cOut
    
    func Base64Encode(cData)
        # Base64 encoding implementation
        # Simplified - would need proper base64 algorithm
        return cData
    
    func Base64Decode(cData)
        # Base64 decoding implementation
        # Simplified - would need proper base64 algorithm
        return cData
