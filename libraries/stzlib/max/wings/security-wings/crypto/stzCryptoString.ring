# stzCryptoString class for string-specific operations
class stzCryptoString from stzCrypto
    
    @cString = ""
    
    def init(cString)
        @cString = cString
        return self
    
    def SetString(cString)
        @cString = cString
        return self
    
    def GetString()
        return @cString
    
    def Hash(nAlgorithm)
        return super.Hash(@cString, nAlgorithm)
    
    def MD5()
        return super.MD5(@cString)
    
    def SHA1()
        return super.SHA1(@cString)
    
    def SHA256()
        return super.SHA256(@cString)
    
    def SHA384()
        return super.SHA384(@cString)
    
    def SHA512()
        return super.SHA512(@cString)
    
    def SHA224()
        return super.SHA224(@cString)
    
    def Encrypt(cKey, cIV, cCipher)
        return super.Encrypt(@cString, cKey, cIV, cCipher)
    
    def EncryptedWith(cKey, cIV, cCipher)
        # Returns a new stzCryptoString with encrypted content
        cEncrypted = super.Encrypt(@cString, cKey, cIV, cCipher)
        return new stzCryptoString(cEncrypted)
    
    def Decrypt(cKey, cIV, cCipher)
        return super.Decrypt(@cString, cKey, cIV, cCipher)
    
    def DecryptedWith(cKey, cIV, cCipher)
        # Returns a new stzCryptoString with decrypted content
        cDecrypted = super.Decrypt(@cString, cKey, cIV, cCipher)
        return new stzCryptoString(cDecrypted)
    
    def RSAEncrypt(pRSAKey, nPadding)
        return super.RSAEncrypt(pRSAKey, @cString, nPadding)
    
    def RSAEncryptedWith(pRSAKey, nPadding)
        # Returns a new stzCryptoString with RSA encrypted content
        cEncrypted = super.RSAEncrypt(pRSAKey, @cString, nPadding)
        return new stzCryptoString(cEncrypted)
    
    def RSADecrypt(pRSAKey, nPadding)
        return super.RSADecrypt(pRSAKey, @cString, nPadding)
    
    def RSADecryptedWith(pRSAKey, nPadding)
        # Returns a new stzCryptoString with RSA decrypted content
        cDecrypted = super.RSADecrypt(pRSAKey, @cString, nPadding)
        return new stzCryptoString(cDecrypted)
    
    def RSASign(pRSAKey, nPadding, nHashAlgorithm)
        return super.RSASign(pRSAKey, @cString, nPadding, nHashAlgorithm)
    
    def RSAVerify(pRSAKey, cSignature, nPadding, nHashAlgorithm)
        return super.RSAVerify(pRSAKey, @cString, cSignature, nPadding, nHashAlgorithm)
    
    def IsValidSignature(pRSAKey, cSignature, nPadding, nHashAlgorithm)
        return RSAVerify(pRSAKey, cSignature, nPadding, nHashAlgorithm) = 1
    
    def Length()
        return len(@cString)
    
    def IsEmpty()
        return len(@cString) = 0

