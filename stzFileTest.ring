load "stzlib.ring"

oFile = new stzFile("max.txt", :WriteToEnd)
? oFile.IsWritable()
oFile.Write("Salem")

