load "../stzmax.ring"
load "../wings/cobol-wings/stzCobolReader.ring"

pr()

convertWithCopybook("example.bin", "copybook.cob", true)
//convertWithCopybook("example.bin", "copybook.cob")

pf()
