load "../stzBase.ring"

oEnc = new stzStringEncoder("hello")
cNFKD = oEnc.NormalizedNFKD()
? "NFKD of hello: [" + cNFKD + "]"
? "len: " + len(cNFKD)
? "equal: " + (cNFKD = "hello")
