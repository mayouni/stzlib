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
        
        for part in parts
            if not isnumber(part) return False ok
            num = 0 + part
            if num < 0 or num > 255 return False ok
        next
        return True
    
    func IsValidUrl(cUrl)
        return left(cUrl, 7) = "http://" or left(cUrl, 8) = "https://"
    

    func UrlEncode(cString)
        cOut = ""
        for x in cString
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
        while i <= len(cString)
            if cString[i] = "%"
                hex = substr(cString, i+1, 2)
                cOut += char(hex2dec(hex))
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
