load "../stzmax.ring"

/*---
*/
pr()

ConvertWithCopybook("example.bin", "copybook.cob", true)

pf()

/*---

pr()

# Test the conversion with common EBCDIC values

    see "=== EBCDIC Conversion Test ===" + nl
    
    # Test common characters
    testBytes = [
        64,   # EBCDIC space -> ASCII space (32)
        129,  # EBCDIC 'a' -> ASCII 'a' (97)
        193,  # EBCDIC 'A' -> ASCII 'A' (65)
        240,  # EBCDIC '0' -> ASCII '0' (48)
        249   # EBCDIC '9' -> ASCII '9' (57)
    ]
    
    for ebcdicVal in testBytes
        ebcdicChar = char(ebcdicVal)
        asciiChar = ebcdicToAscii(ebcdicChar)
        see "EBCDIC " + ebcdicVal + " -> ASCII " + ascii(asciiChar) + " ('" + asciiChar + "')" + nl
    next
    
    # Test the @ symbol issue (EBCDIC 64 = ASCII 32 = space)
    see nl + "The '@' symbols in your output are likely EBCDIC spaces (64) converted incorrectly" + nl
    see "EBCDIC 64 should become ASCII 32 (space): '" + ebcdicToAscii(char(64)) + "'" + nl

pf()
