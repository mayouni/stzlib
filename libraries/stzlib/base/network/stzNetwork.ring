load "libcurl.ring"
load "libuv.ring"

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

func hex2dec(cHex)
    result = 0
    for i = 1 to len(cHex)
        char = cHex[i]
        if char >= "0" and char <= "9"
            digit = ascii(char) - 48
        elseif char >= "A" and char <= "F"
            digit = ascii(char) - 55
        elseif char >= "a" and char <= "f"
            digit = ascii(char) - 87
        else
            digit = 0
        ok
        result = result * 16 + digit
    next
    return result

func str2hex(cStr)
    result = ""
    for char in cStr
        hex = dec2hex(ascii(char))
        if len(hex) = 1 hex = "0" + hex ok
        result += hex
    next
    return result

func dec2hex(nNum)
    if nNum = 0 return "0" ok
    
    hex_chars = "0123456789ABCDEF"
    result = ""
    
    while nNum > 0
        result = hex_chars[nNum % 16 + 1] + result
        nNum = floor(nNum / 16)
    end
    
    return result

# =============================================================================
# BASE NETWORK CLASS - Foundation for all network operations
# =============================================================================

class stzNetwork
    curl_handle = NULL
    last_error = ""
    error_code = 0
    timeout_seconds = 30
    
    def init()
        # Initialize global curl if not done
        if curl_global_init(CURL_GLOBAL_DEFAULT) != 0
            last_error = "Failed to initialize curl globally"
            error_code = -1
        ok
    
    def IsConnected()
        return curl_handle != NULL
    
    def IsSecure()
        if curl_handle = NULL return False ok
        url = curl_simple_getinfo_1(curl_handle, CURLINFO_EFFECTIVE_URL)
        return left(url, 8) = "https://"
    
    def ConnectionInfo()
        if curl_handle = NULL return [] ok
        return [
            :url = curl_simple_getinfo_1(curl_handle, CURLINFO_EFFECTIVE_URL),
            :response_code = curl_simple_getinfo_2(curl_handle, CURLINFO_RESPONSE_CODE),
            :content_type = curl_simple_getinfo_1(curl_handle, CURLINFO_CONTENT_TYPE),
            :total_time = curl_simple_getinfo_3(curl_handle, CURLINFO_TOTAL_TIME),
            :primary_ip = curl_getPrimaryIP(curl_handle),
            :primary_port = curl_getPrimaryPort(curl_handle)
        ]
    
    def LastError()
        return last_error
    
    def HasError()
        return last_error != ""
    
    def ClearErrors()
        last_error = ""
        error_code = 0
        return This
    
    def SetTimeout(nSeconds)
        timeout_seconds = nSeconds
        if curl_handle != NULL
            curl_easy_setopt(curl_handle, CURLOPT_TIMEOUT, nSeconds)
        ok
        return This
    
    def Timeout()
        return timeout_seconds
