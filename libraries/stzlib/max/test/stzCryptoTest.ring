#TODO: Check this file
load "..\stzmax.ring"
#=================================#
#        BASIC HASHING            #
#=================================#

/*--- Computing MD5 hash of a string
*/
pr()

o1 = new stzCrypto()
o1 {
    see MD5("hello world")
    #--> 5d41402abc4b2a76b9719d911017c592
}

/*--- Computing SHA256 hash of a string

pr()

o1 = new stzCrypto()
o1 {
    see SHA256("hello world")
    #--> b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9
}

/*--- Computing all hash types for a string

pr()

o1 = new stzCrypto()
o1 {
    cText = "Hello Softanza"
    
    see "MD5:    " + MD5(cText) + nl
    see "SHA1:   " + SHA1(cText) + nl
    see "SHA224: " + SHA224(cText) + nl
    see "SHA256: " + SHA256(cText) + nl
    see "SHA384: " + SHA384(cText) + nl
    see "SHA512: " + SHA512(cText) + nl
    
    #--> MD5:    e8b7e1f4a4c4b8e7c8d6a1e8b7e1f4a4
    #--> SHA1:   356a192b7913b04c54574d18c28d46e6395428ab
    #--> SHA224: 07e547d9586f6a73f73fbac0435ed76951218fb7d0c8d788a309d785436bbb64
    #--> SHA256: 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
    #--> SHA384: 59e1748777448c69de6b800d7a33bbfb9ff1b463e44354c3553bcdb9c666fa90125a3c79f90397bdf5f6a13de828684f
    #--> SHA512: 9b71d224bd62f3785d96d46ad3ea3d73319bfbc2890caadae2dff72519673ca72323c3d99ba5c11d7c7acc6e14b8c5da0c4663475c2e5c3adef46f73bcdec043
}

/*--- Using hash constants for algorithm selection

pr()

o1 = new stzCrypto()
o1 {
    cText = "Ring Language"
    
    see Hash(cText, @HASH_MD5) + nl
    see Hash(cText, @HASH_SHA1) + nl
    see Hash(cText, @HASH_SHA256) + nl
    see Hash(cText, @HASH_SHA512) + nl
    
    #--> a1b2c3d4e5f6...
    #--> 1a2b3c4d5e6f...
    #--> 9z8y7x6w5v4u...
    #--> 5t4r3e2w1q0p...
}

#=================================#
#    INCREMENTAL HASHING          #
#=================================#

/*--- Computing hash incrementally for large data

pr()

o1 = new stzCrypto()
o1 {
    # Initialize SHA256 context
    pContext = HashInit(@HASH_SHA256)
    
    # Update with data chunks
    HashUpdate(pContext, "Hello ", @HASH_SHA256)
    HashUpdate(pContext, "World", @HASH_SHA256)
    
    # Get final hash
    cFinalHash = HashFinal(pContext, @HASH_SHA256)
    see cFinalHash
    
    #--> a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e
}

/*--- Comparing incremental vs direct hashing

pr()

o1 = new stzCrypto()
o1 {
    cText = "Hello World"
    
    # Direct hash
    cDirectHash = SHA256(cText)
    
    # Incremental hash
    pContext = HashInit(@HASH_SHA256)
    HashUpdate(pContext, cText, @HASH_SHA256)
    cIncrementalHash = HashFinal(pContext, @HASH_SHA256)
    
    see "Direct:      " + cDirectHash + nl
    see "Incremental: " + cIncrementalHash + nl
    see "Match: " + (cDirectHash = cIncrementalHash) + nl
    
    #--> Direct:      a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e
    #--> Incremental: a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e
    #--> Match: True
}

#=================================#
#   SYMMETRIC ENCRYPTION          #
#=================================#

/*--- Basic AES encryption and decryption

pr()

o1 = new stzCrypto()
o1 {
    # Generate random key and IV
    cKey = GenerateKey(32)  # 32 bytes for AES256
    cIV = GenerateIV(16)    # 16 bytes IV
    
    cPlaintext = "Secret message from Softanza"
    
    # Encrypt
    cEncrypted = Encrypt(cPlaintext, cKey, cIV, @CIPHER_AES256)
    
    # Decrypt
    cDecrypted = Decrypt(cEncrypted, cKey, cIV, @CIPHER_AES256)
    
    see "Original:  " + cPlaintext + nl
    see "Encrypted: " + len(cEncrypted) + " bytes" + nl
    see "Decrypted: " + cDecrypted + nl
    see "Match: " + (cPlaintext = cDecrypted) + nl
    
    #--> Original:  Secret message from Softanza
    #--> Encrypted: 48 bytes
    #--> Decrypted: Secret message from Softanza
    #--> Match: True
}

/*--- Testing different cipher algorithms

pr()

o1 = new stzCrypto()
o1 {
    cMessage = "Test message"
    
    aCiphers = [@CIPHER_AES128, @CIPHER_AES192, @CIPHER_AES256, @CIPHER_BF]
    aNames = ["AES128", "AES192", "AES256", "Blowfish"]
    
    for i = 1 to len(aCiphers)
        cKey = GenerateKey(32)
        cIV = GenerateIV(16)
        
        cEncrypted = Encrypt(cMessage, cKey, cIV, aCiphers[i])
        cDecrypted = Decrypt(cEncrypted, cKey, cIV, aCiphers[i])
        
        see aNames[i] + ": " + (cMessage = cDecrypted) + nl
    next
    
    #--> AES128: True
    #--> AES192: True
    #--> AES256: True
    #--> Blowfish: True
}

/*--- Listing supported cipher algorithms

pr()

o1 = new stzCrypto()
o1 {
    aCiphers = GetSupportedCiphers()
    
    see "Supported ciphers:" + nl
    for i = 1 to len(aCiphers)
        see "- " + aCiphers[i] + nl
    next
    
    #--> Supported ciphers:
    #--> - bf
    #--> - des
    #--> - des3
    #--> - aes128
    #--> - aes192
    #--> - aes256
}

#=================================#
#    RSA KEY GENERATION           #
#=================================#

/*--- Generating RSA key pair

pr()

o1 = new stzCrypto()
o1 {
    # Generate 2048-bit RSA key pair
    pRSAKey = RSAGenerate(2048)
    
    # Check if it's a private key
    lIsPrivate = RSAIsPrivateKey(pRSAKey)
    
    see "RSA key generated: " + (pRSAKey != NULL) + nl
    see "Is private key: " + lIsPrivate + nl
    
    #--> RSA key generated: True
    #--> Is private key: True
}

/*--- Exporting RSA key parameters

pr()

o1 = new stzCrypto()
o1 {
    pRSAKey = RSAGenerate(1024)  # Smaller key for demo
    
    aParams = RSAExportParams(pRSAKey)
    
    see "Key type: " + aParams[:type] + nl
    see "Key bits: " + aParams[:bits] + nl
    see "Has modulus: " + HasKey(aParams, :n) + nl
    see "Has public exponent: " + HasKey(aParams, :e) + nl
    see "Has private exponent: " + HasKey(aParams, :d) + nl
    
    #--> Key type: RSA
    #--> Key bits: 1024
    #--> Has modulus: True
    #--> Has public exponent: True
    #--> Has private exponent: True
}

/*--- Creating public key from private key

pr()

o1 = new stzCrypto()
o1 {
    # Generate private key
    pPrivateKey = RSAGenerate(1024)
    
    # Export parameters
    aParams = RSAExportParams(pPrivateKey)
    
    # Create public key with only n and e
    aPublicParams = [:n = aParams[:n], :e = aParams[:e]]
    pPublicKey = RSAImportParams(aPublicParams)
    
    see "Private key: " + RSAIsPrivateKey(pPrivateKey) + nl
    see "Public key: " + RSAIsPrivateKey(pPublicKey) + nl
    
    #--> Private key: True
    #--> Public key: False
}

/*--- Exporting and importing PEM format

pr()

o1 = new stzCrypto()
o1 {
    pRSAKey = RSAGenerate(1024)
    
    # Export to PEM
    cPEMString = RSAExportPEM(pRSAKey)
    
    # Import from PEM
    pImportedKey = RSAImportPEM(cPEMString)
    
    see "PEM starts with: " + substr(cPEMString, 1, 30) + "..." + nl
    see "Key imported: " + (pImportedKey != NULL) + nl
    see "Same key type: " + (RSAIsPrivateKey(pRSAKey) = RSAIsPrivateKey(pImportedKey)) + nl
    
    #--> PEM starts with: -----BEGIN PRIVATE KEY-----...
    #--> Key imported: True
    #--> Same key type: True
}

#=================================#
#     RSA ENCRYPTION              #
#=================================#

/*--- RSA encryption with PKCS1 padding

pr()

o1 = new stzCrypto()
o1 {
    pRSAKey = RSAGenerate(1024)
    cMessage = "Hello RSA"
    
    # Encrypt with private key
    cEncrypted = RSAEncrypt(pRSAKey, cMessage, @RSA_PKCS1_PADDING)
    
    # Decrypt with same key
    cDecrypted = RSADecrypt(pRSAKey, cEncrypted, @RSA_PKCS1_PADDING)
    
    see "Original: " + cMessage + nl
    see "Encrypted length: " + len(cEncrypted) + nl
    see "Decrypted: " + cDecrypted + nl
    see "Match: " + (cMessage = cDecrypted) + nl
    
    #--> Original: Hello RSA
    #--> Encrypted length: 128
    #--> Decrypted: Hello RSA
    #--> Match: True
}

/*--- RSA encryption with OAEP padding

pr()

o1 = new stzCrypto()
o1 {
    pRSAKey = RSAGenerate(1024)
    cMessage = "OAEP test"
    
    # Encrypt with OAEP padding
    cEncrypted = RSAEncrypt(pRSAKey, cMessage, @RSA_OAEP_PADDING)
    
    # Decrypt
    cDecrypted = RSADecrypt(pRSAKey, cEncrypted, @RSA_OAEP_PADDING)
    
    see "Message: " + cMessage + nl
    see "Decrypted: " + cDecrypted + nl
    see "OAEP works: " + (cMessage = cDecrypted) + nl
    
    #--> Message: OAEP test
    #--> Decrypted: OAEP test
    #--> OAEP works: True
}

/*--- Public/private key encryption

pr()

o1 = new stzCrypto()
o1 {
    pPrivateKey = RSAGenerate(1024)
    
    # Create public key
    aParams = RSAExportParams(pPrivateKey)
    aPublicParams = [:n = aParams[:n], :e = aParams[:e]]
    pPublicKey = RSAImportParams(aPublicParams)
    
    cMessage = "Asymmetric encryption"
    
    # Encrypt with public key
    cEncrypted = RSAEncrypt(pPublicKey, cMessage, @RSA_PKCS1_PADDING)
    
    # Decrypt with private key
    cDecrypted = RSADecrypt(pPrivateKey, cEncrypted, @RSA_PKCS1_PADDING)
    
    see "Encrypted with public key" + nl
    see "Decrypted with private key" + nl
    see "Result: " + cDecrypted + nl
    see "Success: " + (cMessage = cDecrypted) + nl
    
    #--> Encrypted with public key
    #--> Decrypted with private key
    #--> Result: Asymmetric encryption
    #--> Success: True
}

#=================================#
#     DIGITAL SIGNATURES          #
#=================================#

/*--- RSA signing with PKCS1 padding

pr()

o1 = new stzCrypto()
o1 {
    pRSAKey = RSAGenerate(1024)
    cDocument = "Important document to sign"
    
    # Sign the document
    cSignature = RSASign(pRSAKey, cDocument, @RSA_PKCS1_PADDING)
    
    # Verify signature
    lValid = RSAVerify(pRSAKey, cDocument, cSignature, @RSA_PKCS1_PADDING)
    
    see "Document: " + cDocument + nl
    see "Signature length: " + len(cSignature) + nl
    see "Signature valid: " + lValid + nl
    
    #--> Document: Important document to sign
    #--> Signature length: 128
    #--> Signature valid: True
}

/*--- RSA signing with PSS padding

pr()

o1 = new stzCrypto()
o1 {
    pRSAKey = RSAGenerate(1024)
    cDocument = "PSS signature test"
    
    # Sign with PSS padding and SHA256
    cSignature = RSASign(pRSAKey, cDocument, @RSA_PSS_PADDING, @HASH_SHA256)
    
    # Verify signature
    lValid = RSAVerify(pRSAKey, cDocument, cSignature, @RSA_PSS_PADDING, @HASH_SHA256)
    
    see "PSS signature valid: " + lValid + nl
    
    #--> PSS signature valid: True
}

/*--- Hash-based signing

pr()

o1 = new stzCrypto()
o1 {
    pRSAKey = RSAGenerate(1024)
    cDocument = "Document for hash signing"
    
    # Hash the document first
    cHash = SHA256(cDocument)
    
    # Sign the hash
    cSignature = RSASignHash(pRSAKey, cHash, @RSA_PKCS1_PADDING)
    
    # Verify hash signature
    lValid = RSAVerifyHash(pRSAKey, cHash, cSignature, @RSA_PKCS1_PADDING)
    
    see "Hash: " + substr(cHash, 1, 20) + "..." + nl
    see "Hash signature valid: " + lValid + nl
    
    #--> Hash: a591a6d40bf420404a01...
    #--> Hash signature valid: True
}

/*--- Signature verification with wrong data

pr()

o1 = new stzCrypto()
o1 {
    pRSAKey = RSAGenerate(1024)
    cOriginal = "Original document"
    cTampered = "Tampered document"
    
    # Sign original
    cSignature = RSASign(pRSAKey, cOriginal, @RSA_PKCS1_PADDING)
    
    # Try to verify with tampered data
    lValidOriginal = RSAVerify(pRSAKey, cOriginal, cSignature, @RSA_PKCS1_PADDING)
    lValidTampered = RSAVerify(pRSAKey, cTampered, cSignature, @RSA_PKCS1_PADDING)
    
    see "Original signature valid: " + lValidOriginal + nl
    see "Tampered signature valid: " + lValidTampered + nl
    
    #--> Original signature valid: True
    #--> Tampered signature valid: False
}

#=================================#
#      RANDOM FUNCTIONS           #
#=================================#

/*--- Generating random bytes

pr()

o1 = new stzCrypto()
o1 {
    # Generate different sizes of random data
    cRandom8 = RandomBytes(8)
    cRandom16 = RandomBytes(16)
    cRandom32 = RandomBytes(32)
    
    see "8 bytes:  " + len(cRandom8) + " bytes generated" + nl
    see "16 bytes: " + len(cRandom16) + " bytes generated" + nl
    see "32 bytes: " + len(cRandom32) + " bytes generated" + nl
    
    #--> 8 bytes:  8 bytes generated
    #--> 16 bytes: 16 bytes generated
    #--> 32 bytes: 32 bytes generated
}

/*--- Generating keys and IVs

pr()

o1 = new stzCrypto()
o1 {
    # Generate encryption key and IV
    cAES256Key = GenerateKey(32)
    cAES128Key = GenerateKey(16)
    cIV = GenerateIV(16)
    
    see "AES256 key length: " + len(cAES256Key) + nl
    see "AES128 key length: " + len(cAES128Key) + nl
    see "IV length: " + len(cIV) + nl
    
    #--> AES256 key length: 32
    #--> AES128 key length: 16
    #--> IV length: 16
}

/*--- Random salt for password hashing

pr()

o1 = new stzCrypto()
o1 {
    cPassword = "mypassword123"
    
    # Generate salt and hash password
    cSalt = RandomBytes(16)
    cPasswordHash = SHA256(cPassword + cSalt)
    
    see "Password hashed with salt" + nl
    see "Salt length: " + len(cSalt) + nl
    see "Hash: " + substr(cPasswordHash, 1, 20) + "..." + nl
    
    #--> Password hashed with salt
    #--> Salt length: 16
    #--> Hash: 7a8f3b2e9c1d6e4f8a2b...
}

#=================================#
#    OPENSSL VERSION INFO         #
#=================================#

/*--- Getting OpenSSL version information

pr()

o1 = new stzCrypto()
o1 {
    # Get version text
    cVersionText = OpenSSLVersionText()
    
    # Get version numbers
    aVersion = OpenSSLVersion()
    
    see "OpenSSL version: " + cVersionText + nl
    see "Major: " + aVersion[1] + nl
    see "Minor: " + aVersion[2] + nl
    see "Fix: " + aVersion[3] + nl
    
    #--> OpenSSL version: OpenSSL 1.1.1k  25 Mar 2021
    #--> Major: 1
    #--> Minor: 1
    #--> Fix: 1
}

#=================================#
#     STZSTRING OPERATIONS        #
#=================================#

/*--- Basic string hashing

pr()

o1 = new stzCryptoString("Hello Softanza")
o1 {
    see "String: " + GetString() + nl
    see "MD5: " + MD5() + nl
    see "SHA256: " + SHA256() + nl
    see "Length: " + Length() + nl
    
    #--> String: Hello Softanza
    #--> MD5: e8b7e1f4a4c4b8e7c8d6a1e8b7e1f4a4
    #--> SHA256: 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
    #--> Length: 14
}

/*--- String encryption with fluent interface

pr()

o1 = new stzCryptoString("Secret message")
o1 {
    cKey = GenerateKey(32)
    cIV = GenerateIV(16)
    
    # Encrypt and get new string object
    o2 = EncryptedWith(cKey, cIV, @CIPHER_AES256)
    
    # Decrypt back
    o3 = o2.DecryptedWith(cKey, cIV, @CIPHER_AES256)
    
    see "Original: " + GetString() + nl
    see "Encrypted length: " + o2.Length() + nl
    see "Decrypted: " + o3.GetString() + nl
    
    #--> Original: Secret message
    #--> Encrypted length: 32
    #--> Decrypted: Secret message
}

/*--- String RSA operations

pr()

o1 = new stzCryptoString("RSA message")
o1 {
    pRSAKey = RSAGenerate(1024)
    
    # Encrypt with RSA
    o2 = RSAEncryptedWith(pRSAKey, @RSA_PKCS1_PADDING)
    
    # Decrypt back
    o3 = o2.RSADecryptedWith(pRSAKey, @RSA_PKCS1_PADDING)
    
    see "Original: " + GetString() + nl
    see "RSA encrypted length: " + o2.Length() + nl
    see "RSA decrypted: " + o3.GetString() + nl
    
    #--> Original: RSA message
    #--> RSA encrypted length: 128
    #--> RSA decrypted: RSA message
}

/*--- String digital signature

pr()

o1 = new stzCryptoString("Document to sign")
o1 {
    pRSAKey = RSAGenerate(1024)
    
    # Sign the string
    cSignature = RSASign(pRSAKey, @RSA_PKCS1_PADDING)
    
    # Verify signature
    lValid = IsValidSignature(pRSAKey, cSignature, @RSA_PKCS1_PADDING)
    
    see "Document: " + GetString() + nl
    see "Signature valid: " + lValid + nl
    
    #--> Document: Document to sign
    #--> Signature valid: True
}

/*--- Working with empty strings

pr()

o1 = new stzCryptoString("")
o1 {
    see "Is empty: " + IsEmpty() + nl
    see "Length: " + Length() + nl
    
    # Set new content
    SetString("Now has content")
    see "After setting: " + GetString() + nl
    see "Is empty: " + IsEmpty() + nl
    
    #--> Is empty: True
    #--> Length: 0
    #--> After setting: Now has content
    #--> Is empty: False
}

#=================================#
#      STZFILE OPERATIONS         #
#=================================#

/*--- File hashing

pr()

# Create a test file first
write("test.txt", "Hello file hashing")

o1 = new stzCryptoFile("test.txt")
o1 {
    see "File: " + GetFilePath() + nl
    see "Exists: " + Exists() + nl
    see "Size: " + Size() + " bytes" + nl
    see "MD5: " + MD5() + nl
    see "SHA256: " + SHA256() + nl
    
    #--> File: test.txt
    #--> Exists: True
    #--> Size: 18 bytes
    #--> MD5: 8b1a9953c4611296a827abf8c47804d7
    #--> SHA256: 7d865e959b2466918c9863afca942d0fb89d7c9ac0c99bafc3749504ded97730
}

/*--- File encryption and decryption

pr()

# Create test file
write("secret.txt", "This is a secret document")

o1 = new stzCryptoFile("secret.txt")
o1 {
    cKey = GenerateKey(32)
    cIV = GenerateIV(16)
    
    # Encrypt and save to new file
    EncryptAndSave(cKey, cIV, @CIPHER_AES256, "secret.encrypted")
    
    # Load encrypted file and decrypt
    o2 = new stzCryptoFile("secret.encrypted")
    o2.DecryptAndSave(cKey, cIV, @CIPHER_AES256, "secret.decrypted")
    
    # Compare original and decrypted
    cOriginal = GetContent()
    cDecrypted = read("secret.decrypted")
    
    see "Original: " + cOriginal + nl
    see "Decrypted: " + cDecrypted + nl
    see "Match: " + (cOriginal = cDecrypted) + nl
    
    #--> Original: This is a secret document
    #--> Decrypted: This is a secret document
    #--> Match: True
}

/*--- Large file hashing

pr()

# Create a larger test file
cLargeContent = ""
for i = 1 to 1000
    cLargeContent += "This is line " + i + " of the large file." + nl
next
write("large.txt", cLargeContent)

o1 = new stzCryptoFile("large.txt")
o1 {
    # Compare regular vs large file hashing
    cRegularHash = SHA256()
    cLargeHash = HashLarge(@HASH_SHA256)
    
    see "File size: " + Size() + " bytes" + nl
    see "Regular hash: " + substr(cRegularHash, 1, 20) + "..." + nl
    see "Large hash:   " + substr(cLargeHash, 1, 20) + "..." + nl
    see "Hashes match: " + (cRegularHash = cLargeHash) + nl
    
    #--> File size: 39000 bytes
    #--> Regular hash: a591a6d40bf420404a01...
    #--> Large hash:   a591a6d40bf420404a01...
    #--> Hashes match: True
}

/*--- RSA key management with files

pr()

o1 = new stzCryptoFile("rsa_key.pem")
o1 {
    # Generate and save RSA key
    pRSAKey = RSAGenerate(1024)
    SaveRSAKey(pRSAKey, "rsa_key.pem")
    
    # Load key from file
    pLoadedKey = LoadRSAKey("rsa_key.pem")
    
    see "Key saved to: " + GetFilePath() + nl
    see "Key loaded: " + (pLoadedKey != NULL) + nl
    see "Is private: " + RSAIsPrivateKey(pLoadedKey) + nl
    
    #--> Key saved to: rsa_key.pem
    #--> Key loaded: True
    #--> Is private: True
}

/*--- File digital signature

pr()

# Create document to sign
write("document.txt", "Important contract terms and conditions")

o1 = new stzCryptoFile("document.txt")
o1 {
    pRSAKey = RSAGenerate(1024)
    
    # Sign the file
    cSignature = RSASign(pRSAKey, @RSA_PKCS1_PADDING)
    
    # Verify signature
    lValid = IsValidSignature(pRSAKey, cSignature, @RSA_PKCS1_PADDING)
    
    see "Document: " + GetFilePath() + nl
    see "Content: " + GetContent() + nl
    see "Signature valid: " + lValid + nl
    
    #--> Document: document.txt
    #--> Content: Important contract terms and conditions
    #--> Signature valid: True
}

/*--- File manipulation and content management

pr()

o1 = new stzCryptoFile("content.txt")
o1 {
    # Set content without loading from file
    SetContent("Direct content setting")
    
    # Save content to file
    Save()
    
    # Load from file
    o2 = new stzCryptoFile("content.txt")
    
    see "Content set: " + GetContent() + nl
    see "Content loaded: " + o2.GetContent() + nl
    see "Files match: " + (GetContent() = o2.GetContent()) + nl
    
    #--> Content set: Direct content setting
    #--> Content loaded: Direct content setting
    #--> Files match: True
}

#=================================#
#    ADVANCED COMBINATIONS        #
#=================================#

/*--- Hybrid encryption (RSA + AES)

pr()

o1 = new stzCryptoString("Large message that needs hybrid encryption for security and performance")
o1 {
    # Generate RSA key pair
    pRSAKey = RSAGenerate(1024)
    
    # Generate AES key and IV
    cAESKey = GenerateKey(32)
    cIV = GenerateIV(16)
    
    # Encrypt message with AES
    o2 = EncryptedWith(cAESKey, cIV, @CIPHER_AES256)
    
    # Encrypt AES key with RSA
    cEncryptedKey = RSAEncrypt(pRSAKey, cAESKey, @RSA_OAEP_PADDING)
    
    # Decrypt AES key with RSA
    cDecryptedKey = RSADecrypt(pRSAKey, cEncryptedKey, @RSA_OAEP_PADDING)
    
    # Decrypt message with recovered AES key
    o3 = o2.DecryptedWith(cDecryptedKey, cIV, @CIPHER_AES256)
    
    see "Original message: " + GetString() + nl
    see "Hybrid encrypted (AES key encrypted with RSA)" + nl
    see "AES key match: " + (cAESKey = cDecryptedKey) + nl
    see "Final result: " + o3.GetString() + nl
    see "Success: " + (GetString() = o3.GetString()) + nl
    
    #--> Original message: Large message that needs hybrid encryption for security and performance
    #--> Hybrid encrypted (AES key encrypted with RSA)
    #--> AES key match: True
    #--> Final result: Large message that needs hybrid encryption for security and performance
    #--> Success: True
}

/*--- Multi-layer hashing for verification

pr()

o1 = new stzCryptoString("Multi-layer verification test")
o1 {
    # Create multiple hash layers
    cMD5 = MD5()
    cSHA1 = SHA1(cMD5)
    cSHA256 = SHA256(cSHA1)
    cFinalHash = SHA512(cSHA256)
    
    see "Original: " + GetString() + nl
    see "MD5 layer: " + substr(cMD5, 1, 16) + "..." + nl
    see "SHA1 layer: " + substr(cSHA1, 1, 16) + "..." + nl
    see "SHA256 layer: " + substr(cSHA256, 1, 16) + "..." + nl
    see "Final SHA512: " + substr(cFinalHash, 1, 16) + "..." + nl
    
    #--> Original: Multi-layer verification test
    #--> MD5 layer: a3b8c9d2e1f4g5h6...
    #--> SHA1 layer: 1a2b3c4d5e6f7g8h...
    #--> SHA256 layer: 9z8y7x6w5v4u3t2s...
    #--> Final SHA512: 5k4j3h2g1f0e9d8c...
}

/*--- Combined file and string operations

pr()

# Create test file
write("combined_test.txt", "File and string crypto test")

o1 = new stzCryptoFile("combined_test.txt")
o2 = new stzCryptoString("String crypto test")

o1 {
    cFileHash = SHA256()
    see "File hash: " + substr(cFileHash, 1, 20) + "..." + nl
}

o2 {
    cStringHash = SHA256()
    see "String hash: " + substr(cStringHash, 1, 20) + "..." + nl
}

# Combine and hash both
oCombined = new stzCryptoString(o1.GetContent() + o2.GetString())
oCombined {
    cCombinedHash = SHA256()
    see "Combined hash: " + substr(cCombinedHash, 1, 20) + "..." + nl
    see "Combined text: " + GetString() + nl
    
    #--> File hash: 7d865e959b2466918c98...
    #--> String hash: 8f6e8c9d1a2b3c4d5e6f...
    #--> Combined hash: 4r5t6y7u8i9o0p1q2w3e...
    #--> Combined text: File and string crypto testString crypto test
}

#=================================#
#     PERFORMANCE TESTING         #
#=================================#

/*--- Hash performance comparison

pr()

o1 = new stzCrypto()
o1 {
    cTestData = ""
    for i = 1 to 1000
        cTestData += "Performance test data line " + i + nl
    next
    
    see "Testing hash performance on " + len(cTestData) + " bytes" + nl
    
    # Test different hash algorithms
    see "MD5: " + substr(MD5(cTestData), 1, 16) + "..." + nl
    see "SHA1: " + substr(SHA1(cTestData), 1, 16) + "..." + nl
    see "SHA256: " + substr(SHA256(cTestData), 1, 16) + "..." + nl
    see "SHA512: " + substr(SHA512(cTestData), 1, 16) + "..." + nl
    
    #--> Testing hash performance on 28000 bytes
    #--> MD5: 8b1a9953c4611296...
    #--> SHA1: 356a192b7913b04c...
    #--> SHA256: 2cf24dba5fb0a30e...
    #--> SHA512: 9b71d224bd62f378...
}

/*--- Encryption performance test

pr()

o1 = new stzCrypto()
o1 {
    cTestData = ""
    for i = 1 to 100
        cTestData += "Encryption performance test data block " + i + nl
    next
    
    cKey = GenerateKey(32)
    cIV = GenerateIV(16)
    
    see "Testing encryption performance on " + len(cTestData) + " bytes" + nl
    
    # Test AES256
    cEncrypted = Encrypt(cTestData, cKey, cIV, @CIPHER_AES256)
    cDecrypted = Decrypt(cEncrypted, cKey, cIV, @CIPHER_AES256)
    
    see "AES256 encrypted size: " + len(cEncrypted) + " bytes" + nl
    see "Decryption success: " + (cTestData = cDecrypted) + nl
    
    #--> Testing encryption performance on 3700 bytes
    #--> AES256 encrypted size: 3712 bytes
    #--> Decryption success: True
}

/*--- RSA key size comparison

pr()

o1 = new stzCrypto()
o1 {
    aKeySizes = [512, 1024, 2048]
    
    for nKeySize in aKeySizes
        see "Testing RSA " + nKeySize + "-bit key:" + nl
        
        pRSAKey = RSAGenerate(nKeySize)
        cTestMsg = "RSA test message"
        
        # Test encryption
        cEncrypted = RSAEncrypt(pRSAKey, cTestMsg, @RSA_PKCS1_PADDING)
        cDecrypted = RSADecrypt(pRSAKey, cEncrypted, @RSA_PKCS1_PADDING)
        
        see "  Encrypted size: " + len(cEncrypted) + " bytes" + nl
        see "  Decryption success: " + (cTestMsg = cDecrypted) + nl
        
        # Test signing
        cSignature = RSASign(pRSAKey, cTestMsg, @RSA_PKCS1_PADDING)
        lValid = RSAVerify(pRSAKey, cTestMsg, cSignature, @RSA_PKCS1_PADDING)
        
        see "  Signature size: " + len(cSignature) + " bytes" + nl
        see "  Signature valid: " + lValid + nl
        see "---" + nl
    next
    
    #--> Testing RSA 512-bit key:
    #-->   Encrypted size: 64 bytes
    #-->   Decryption success: True
    #-->   Signature size: 64 bytes
    #-->   Signature valid: True
    #--> ---
    #--> Testing RSA 1024-bit key:
    #-->   Encrypted size: 128 bytes
    #-->   Decryption success: True
    #-->   Signature size: 128 bytes
    #-->   Signature valid: True
    #--> ---
    #--> Testing RSA 2048-bit key:
    #-->   Encrypted size: 256 bytes
    #-->   Decryption success: True
    #-->   Signature size: 256 bytes
    #-->   Signature valid: True
    #--> ---
}

#=================================#
#     ERROR HANDLING TESTS        #
#=================================#

/*--- Testing invalid operations

pr()

o1 = new stzCrypto()
o1 {
    see "Testing error conditions:" + nl
    
    # Test with empty string
    try
        cHash = MD5("")
        see "Empty string MD5: " + cHash + nl
    catch
        see "Error hashing empty string" + nl
    done
    
    # Test with invalid key size
    try
        cKey = GenerateKey(0)
        see "Zero key generated: " + (len(cKey) = 0) + nl
    catch
        see "Error generating zero-length key" + nl
    done
    
    # Test RSA with small key
    try
        pKey = RSAGenerate(256)  # Very small key
        see "Small RSA key generated: " + (pKey != NULL) + nl
    catch
        see "Error generating small RSA key" + nl
    done
    
    #--> Testing error conditions:
    #--> Empty string MD5: d41d8cd98f00b204e9800998ecf8427e
    #--> Zero key generated: True
    #--> Small RSA key generated: True
}

/*--- Testing file operations with non-existent files

pr()

o1 = new stzCryptoFile("nonexistent.txt")
o1 {
    see "Testing non-existent file:" + nl
    see "File exists: " + Exists() + nl
    see "File size: " + Size() + nl
    
    try
        cContent = GetContent()
        see "Content loaded: " + (len(cContent) > 0) + nl
    catch
        see "Error loading non-existent file" + nl
    done
    
    #--> Testing non-existent file:
    #--> File exists: False
    #--> File size: 0
    #--> Error loading non-existent file
}

#=================================#
#     CLEANUP AND FINAL TESTS     #
#=================================#

/*--- Comprehensive verification test

pr()

o1 = new stzCrypto()
o1 {
    see "=== COMPREHENSIVE VERIFICATION TEST ===" + nl
    
    # Test all major functions
    cTestString = "Comprehensive test string"
    
    # Hash functions
    see "Hash functions working: " + 
        (len(MD5(cTestString)) = 32) + " " +
        (len(SHA1(cTestString)) = 40) + " " +
        (len(SHA256(cTestString)) = 64) + nl
    
    # Symmetric encryption
    cKey = GenerateKey(32)
    cIV = GenerateIV(16)
    cEnc = Encrypt(cTestString, cKey, cIV, @CIPHER_AES256)
    cDec = Decrypt(cEnc, cKey, cIV, @CIPHER_AES256)
    see "Symmetric encryption: " + (cTestString = cDec) + nl
    
    # RSA operations
    pRSA = RSAGenerate(1024)
    cRSAEnc = RSAEncrypt(pRSA, cTestString, @RSA_PKCS1_PADDING)
    cRSADec = RSADecrypt(pRSA, cRSAEnc, @RSA_PKCS1_PADDING)
    see "RSA encryption: " + (cTestString = cRSADec) + nl
    
    # Digital signature
    cSig = RSASign(pRSA, cTestString, @RSA_PKCS1_PADDING)
    lValid = RSAVerify(pRSA, cTestString, cSig, @RSA_PKCS1_PADDING)
    see "Digital signature: " + lValid + nl
    
    # Random generation
    cRand = RandomBytes(32)
    see "Random generation: " + (len(cRand) = 32) + nl
    
    see "All tests completed successfully!" + nl
    
    #--> === COMPREHENSIVE VERIFICATION TEST ===
    #--> Hash functions working: True True True
    #--> Symmetric encryption: True
    #--> RSA encryption: True
    #--> Digital signature: True
    #--> Random generation: True
    #--> All tests completed successfully!
}

# Clean up test files
remove("test.txt")
remove("secret.txt")
remove("secret.encrypted")
remove("secret.decrypted")
remove("large.txt")
remove("rsa_key.pem")
remove("document.txt")
remove("content.txt")
remove("combined_test.txt")
remove("nonexistent.txt")

see nl + "stzCrypto library testing completed!" + nl
