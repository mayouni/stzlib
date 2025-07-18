# stzCryptoFile class for file-specific operations
class stzCryptoFile from stzCrypto
    
    @cFilePath = ""
    @cContent = ""
    @bLoaded = False
    
    def init(cFilePath)
        @cFilePath = cFilePath
        return self
    
    def SetFilePath(cFilePath)
        @cFilePath = cFilePath
        @bLoaded = False
        return self
    
    def GetFilePath()
        return @cFilePath
    
    def LoadFile()
        try
            @cContent = read(@cFilePath)
            @bLoaded = True
        catch
            @cContent = ""
            @bLoaded = False
            raise("Could not read file: " + @cFilePath)
        done
        return self
    
    def Save(cFilePath)
        if cFilePath = NULL
            cFilePath = @cFilePath
        ok
        try
            write(cFilePath, @cContent)
        catch
            raise("Could not write file: " + cFilePath)
        done
        return self
    
    def GetContent()
        if not @bLoaded
            LoadFile()
        ok
        return @cContent
    
    def SetContent(cContent)
        @cContent = cContent
        @bLoaded = True
        return self
    
    def Hash(nAlgorithm)
        if not @bLoaded
            LoadFile()
        ok
        return super.Hash(@cContent, nAlgorithm)
    
    def MD5()
        if not @bLoaded
            LoadFile()
        ok
        return super.MD5(@cContent)
    
    def SHA1()
        if not @bLoaded
            LoadFile()
        ok
        return super.SHA1(@cContent)
    
    def SHA256()
        if not @bLoaded
            LoadFile()
        ok
        return super.SHA256(@cContent)
    
    def SHA384()
        if not @bLoaded
            LoadFile()
        ok
        return super.SHA384(@cContent)
    
    def SHA512()
        if not @bLoaded
            LoadFile()
        ok
        return super.SHA512(@cContent)
    
    def SHA224()
        if not @bLoaded
            LoadFile()
        ok
        return super.SHA224(@cContent)
    
    def HashLarge(nAlgorithm)
        # For large files, use incremental hashing
        pContext = HashInit(nAlgorithm)
        try
            fp = fopen(@cFilePath, "rb")
            while True
                cChunk = fread(fp, 8192)  # Read 8KB chunks
                if len(cChunk) = 0
                    break
                ok
                HashUpdate(pContext, cChunk, nAlgorithm)
            end
            fclose(fp)
        catch
            raise("Could not read file for hashing: " + @cFilePath)
        done
        return HashFinal(pContext, nAlgorithm)
    
    def Encrypt(cKey, cIV, cCipher)
        if not @bLoaded
            LoadFile()
        ok
        @cContent = super.Encrypt(@cContent, cKey, cIV, cCipher)
        return self
    
    def EncryptAndSave(cKey, cIV, cCipher, cOutputPath)
        Encrypt(cKey, cIV, cCipher)
        Save(cOutputPath)
        return self
    
    def Decrypt(cKey, cIV, cCipher)
        if not @bLoaded
            LoadFile()
        ok
        @cContent = super.Decrypt(@cContent, cKey, cIV, cCipher)
        return self
    
    def DecryptAndSave(cKey, cIV, cCipher, cOutputPath)
        Decrypt(cKey, cIV, cCipher)
        Save(cOutputPath)
        return self
    
    def RSAEncrypt(pRSAKey, nPadding)
        if not @bLoaded
            LoadFile()
        ok
        @cContent = super.RSAEncrypt(pRSAKey, @cContent, nPadding)
        return self
    
    def RSADecrypt(pRSAKey, nPadding)
        if not @bLoaded
            LoadFile()
        ok
        @cContent = super.RSADecrypt(pRSAKey, @cContent, nPadding)
        return self
    
    def RSASign(pRSAKey, nPadding, nHashAlgorithm)
        if not @bLoaded
            LoadFile()
        ok
        return super.RSASign(pRSAKey, @cContent, nPadding, nHashAlgorithm)
    
    def RSAVerify(pRSAKey, cSignature, nPadding, nHashAlgorithm)
        if not @bLoaded
            LoadFile()
        ok
        return super.RSAVerify(pRSAKey, @cContent, cSignature, nPadding, nHashAlgorithm)
    
    def IsValidSignature(pRSAKey, cSignature, nPadding, nHashAlgorithm)
        return RSAVerify(pRSAKey, cSignature, nPadding, nHashAlgorithm) = 1
    
    def SaveRSAKey(pRSAKey, cKeyFilePath)
        # Save RSA key to PEM file
        cPEMContent = super.RSAExportPEM(pRSAKey)
        write(cKeyFilePath, cPEMContent)
        return self
    
    def LoadRSAKey(cKeyFilePath)
        # Load RSA key from PEM file
        cPEMContent = read(cKeyFilePath)
        return super.RSAImportPEM(cPEMContent)
    
    def Size()
        if not @bLoaded
            LoadFile()
        ok
        return len(@cContent)
    
    def Exists()
        # Check if file exists
        try
            fp = fopen(@cFilePath, "r")
            if fp != NULL
                fclose(fp)
                return True
            ok
        catch
            # File doesn't exist or can't be opened
        done
        return False
    
    def DownloadFrom(cURL)
        # Download content from URL and save to file
        @cContent = super.Download(cURL)
        @bLoaded = True
        Save(@cFilePath)
        return self
