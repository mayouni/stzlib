func main
	? "Removing Folder : ring/libraries/stzlib"
	cDir = CurrentDir()
	chdir(exefolder()+"../libraries")
	OSDeleteFolder("stzlib")
	chdir(cDir)

func OSDeleteFolder cFolder 
	if isWindows() 
		systemSilent("rd /s /q " + cFolder)
	else
		systemSilent("rm -r " + cFolder)
	ok

func SystemSilent cCmd
	if isWindows()
		system(cCmd + " >nul 2>nul")
	else 
		system(cCmd + " > /dev/null")
	ok