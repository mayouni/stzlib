load "ziplib.ring"

func main
	? "Extracting File : stzlib.zip"
	cDir = CurrentDir()
	chdir(exefolder()+"../libraries")
	zip_extract_allfiles("stzlib.zip","../libraries")
	remove("stzlib.zip")
	? "All files are extracted successfully
	? "See the folder : ring/libraries/stzlib"
	chdir(cDir)
