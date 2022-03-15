load "ziplib.ring"

func main
	? "Extracting File : softanzalib.zip"
	cDir = CurrentDir()
	chdir(exefolder()+"../libraries")
	zip_extract_allfiles("softanzalib.zip","../libraries")
	remove("softanzalib.zip")
	chdir(cDir)