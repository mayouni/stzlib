# stzCrypto Class System for Softanza Library

load "openssllib.ring"

# Base stzCrypto class
class stzCrypto
    
    # Hash algorithms constants
    @HASH_MD5 = 0
    @HASH_SHA1 = 1
    @HASH_SHA256 = 2
    @HASH_SHA384 = 3
    @HASH_SHA512 = 4
    @HASH_SHA224 = 5
    
    # Cipher algorithms
    @CIPHER_BF = "bf"
    @CIPHER_DES = "des"
    @CIPHER_DES3 = "des3"
    @CIPHER_AES128 = "aes128"
    @CIPHER_AES192 = "aes192"
    @CIPHER_AES256 = "aes256"
    
    # RSA padding types
    @RSA_PKCS1_PADDING = 1
    @RSA_OAEP_PADDING = 2
    @RSA_PSS_PADDING = 3
    @RSA_RAW_PADDING = 4

    def init()
        # Initialize any required state
        return self
    
    # --- Hash Functions ---
    
    def Hash(cString, nAlgorithm)
        switch nAlgorithm
            on @HASH_MD5
                return md5(cString)
            on @HASH_SHA1
                return sha1(cString)
            on @HASH_SHA256
                return sha256(cString)
            on @HASH_SHA384
                return sha384(cString)
            on @HASH_SHA512
                return sha512(cString)
            on @HASH_SHA224
                return sha224(cString)
            other
                raise("Invalid hash algorithm")
        off
    
    def MD5(cString)
        return md5(cString)
    
    def SHA1(cString)
        return sha1(cString)
    
    def SHA256(cString)
        return sha256(cString)
    
    def SHA384(cString)
        return sha384(cString)
    
    def SHA512(cString)
        return sha512(cString)
    
    def SHA224(cString)
        return sha224(cString)
    
    # --- Incremental Hashing ---
    
    def HashInit(nAlgorithm)
        switch nAlgorithm
            on @HASH_MD5
                return md5init()
            on @HASH_SHA1
                return sha1init()
            on @HASH_SHA256
                return sha256init()
            on @HASH_SHA384
                return sha384init()
            on @HASH_SHA512
                return sha512init()
            on @HASH_SHA224
                return sha224init()
            other
                raise("Invalid hash algorithm")
        off
    
    def HashUpdate(pContext, cData, nAlgorithm)
        switch nAlgorithm
            on @HASH_MD5
                return md5update(pContext, cData)
            on @HASH_SHA1
                return sha1update(pContext, cData)
            on @HASH_SHA256
                return sha256update(pContext, cData)
            on @HASH_SHA384
                return sha384update(pContext, cData)
            on @HASH_SHA512
                return sha512update(pContext, cData)
            on @HASH_SHA224
                return sha224update(pContext, cData)
            other
                raise("Invalid hash algorithm")
        off
    
    def HashFinal(pContext, nAlgorithm)
        switch nAlgorithm
            on @HASH_MD5
                return md5final(pContext)
            on @HASH_SHA1
                return sha1final(pContext)
            on @HASH_SHA256
                return sha256final(pContext)
            on @HASH_SHA384
                return sha384final(pContext)
            on @HASH_SHA512
                return sha512final(pContext)
            on @HASH_SHA224
                return sha224final(pContext)
            other
                raise("Invalid hash algorithm")
        off
    
    # --- Symmetric Encryption ---
    
    def GetSupportedCiphers()
        return supportedciphers()
    
    def Encrypt(cPlaintext, cKey, cIV, cCipher)
        if cCipher = NULL
            cCipher = @CIPHER_BF
        ok
        return encrypt(cPlaintext, cKey, cIV, cCipher)
    
    def Decrypt(cCiphertext, cKey, cIV, cCipher)
        if cCipher = NULL
            cCipher = @CIPHER_BF
        ok
        return decrypt(cCiphertext, cKey, cIV, cCipher)
    
    # --- RSA Functions ---
    
    def RSAGenerate(nBits, nPublicExponent)
        if nPublicExponent = NULL
            nPublicExponent = 65537
        ok
        return rsa_generate(nBits, nPublicExponent)
    
    def RSAExportParams(pRSAKey)
        return rsa_export_params(pRSAKey)
    
    def RSAImportParams(aParams)
        return rsa_import_params(aParams)
    
    def RSAExportPEM(pRSAKey)
        return rsa_export_pem(pRSAKey)
    
    def RSAImportPEM(cPEMString)
        return rsa_import_pem(cPEMString)
    
    def RSAIsPrivateKey(pRSAKey)
        return rsa_is_privatekey(pRSAKey)
    
    def RSAEncrypt(pRSAKey, cPlaintext, nPadding)
        if nPadding = NULL
            nPadding = @RSA_PKCS1_PADDING
        ok
        
        switch nPadding
            on @RSA_PKCS1_PADDING
                return rsa_encrypt_pkcs(pRSAKey, cPlaintext)
            on @RSA_OAEP_PADDING
                return rsa_encrypt_oaep(pRSAKey, cPlaintext)
            on @RSA_RAW_PADDING
                return rsa_encrypt_raw(pRSAKey, cPlaintext)
            other
                raise("Invalid RSA padding type")
        off
    
    def RSADecrypt(pRSAKey, cCiphertext, nPadding)
        if nPadding = NULL
            nPadding = @RSA_PKCS1_PADDING
        ok
        
        switch nPadding
            on @RSA_PKCS1_PADDING
                return rsa_decrypt_pkcs(pRSAKey, cCiphertext)
            on @RSA_OAEP_PADDING
                return rsa_decrypt_oaep(pRSAKey, cCiphertext)
            on @RSA_RAW_PADDING
                return rsa_decrypt_raw(pRSAKey, cCiphertext)
            other
                raise("Invalid RSA padding type")
        off
    
    def RSASign(pRSAKey, cData, nPadding, nHashAlgorithm)
        if nPadding = NULL
            nPadding = @RSA_PKCS1_PADDING
        ok
        
        switch nPadding
            on @RSA_PKCS1_PADDING
                return rsa_sign_pkcs(pRSAKey, cData)
            on @RSA_PSS_PADDING
                if nHashAlgorithm = NULL
                    nHashAlgorithm = @HASH_SHA256
                ok
                return rsa_sign_pss(pRSAKey, cData, nHashAlgorithm)
            other
                raise("Invalid RSA padding type for signing")
        off
    
    def RSAVerify(pRSAKey, cData, cSignature, nPadding, nHashAlgorithm)
        if nPadding = NULL
            nPadding = @RSA_PKCS1_PADDING
        ok
        
        switch nPadding
            on @RSA_PKCS1_PADDING
                return rsa_verify_pkcs(pRSAKey, cData, cSignature)
            on @RSA_PSS_PADDING
                if nHashAlgorithm = NULL
                    nHashAlgorithm = @HASH_SHA256
                ok
                return rsa_verify_pss(pRSAKey, cData, cSignature, nHashAlgorithm)
            other
                raise("Invalid RSA padding type for verification")
        off
    
    def RSASignHash(pRSAKey, cHashValue, nPadding, nSaltLength)
        if nPadding = NULL
            nPadding = @RSA_PKCS1_PADDING
        ok
        
        switch nPadding
            on @RSA_PKCS1_PADDING
                return rsa_signhash_pkcs(pRSAKey, cHashValue)
            on @RSA_PSS_PADDING
                if nSaltLength = NULL
                    return rsa_signhash_pss(pRSAKey, cHashValue)
                else
                    return rsa_signhash_pss(pRSAKey, cHashValue, nSaltLength)
                ok
            other
                raise("Invalid RSA padding type for hash signing")
        off
    
    def RSAVerifyHash(pRSAKey, cHashValue, cSignature, nPadding, nSaltLength)
        if nPadding = NULL
            nPadding = @RSA_PKCS1_PADDING
        ok
        
        switch nPadding
            on @RSA_PKCS1_PADDING
                return rsa_verifyhash_pkcs(pRSAKey, cHashValue, cSignature)
            on @RSA_PSS_PADDING
                if nSaltLength = NULL
                    return rsa_verifyhash_pss(pRSAKey, cHashValue, cSignature)
                else
                    return rsa_verifyhash_pss(pRSAKey, cHashValue, cSignature, nSaltLength)
                ok
            other
                raise("Invalid RSA padding type for hash verification")
        off
    
    # --- Random Functions ---
    
    def RandomBytes(nSize)
        return randbytes(nSize)
    
    def GenerateKey(nSize)
        return randbytes(nSize)
    
    def GenerateIV(nSize)
        return randbytes(nSize)
    
    # --- OpenSSL Version ---
    
    def OpenSSLVersion()
        return openssl_version()
    
    def OpenSSLVersionText()
        return openssl_versiontext()
    
    # --- Internet Functions ---
    
    def Download(cURL)
        return download(cURL)
    
    def SendEmail(cSMTPServer, cEmail, cPassword, cSender, cReceiver, cCC, cTitle, cContent)
        return sendemail(cSMTPServer, cEmail, cPassword, cSender, cReceiver, cCC, cTitle, cContent)
