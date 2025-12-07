# stzSystemCallData - Ready-to-use system commands repository

/*=================================================================
  EXTERNAL TOOLS INSTALLATION GUIDE
=================================================================

# GIT (Version Control)
Windows: Download from https://git-scm.com/download/win
Linux: sudo apt install git  OR  sudo yum install git
macOS: brew install git  OR  install Xcode Command Line Tools

# IMAGEMAGICK (Image Processing)
Windows: Download from https://imagemagick.org/script/download.php
Linux: sudo apt install imagemagick
macOS: brew install imagemagick

# FFMPEG (Video/Audio Processing)
Windows: Download from https://ffmpeg.org/download.html
Linux: sudo apt install ffmpeg
macOS: brew install ffmpeg

# GRAPHVIZ (Diagrams - already covered)
Windows: Download from https://graphviz.org/download/
Linux: sudo apt install graphviz
macOS: brew install graphviz

# PANDOC (Document Conversion)
Windows: Download from https://pandoc.org/installing.html
Linux: sudo apt install pandoc
macOS: brew install pandoc

# SQLITE (Database)
Windows: Download from https://www.sqlite.org/download.html
Linux: sudo apt install sqlite3
macOS: brew install sqlite

# GPG (Encryption)
Windows: Download Gpg4win from https://gpg4win.org/
Linux: sudo apt install gnupg
macOS: brew install gnupg

# DOCKER (Containerization)
Windows: Docker Desktop from https://www.docker.com/products/docker-desktop
Linux: curl -fsSL https://get.docker.com | sh
macOS: Docker Desktop from https://www.docker.com/products/docker-desktop

# AWS CLI (Cloud)
All: pip install awscli  OR  https://aws.amazon.com/cli/

# NODE.JS & NPM (JavaScript)
All: Download from https://nodejs.org/

# PYTHON & PIP (Python packages)
All: Download from https://www.python.org/downloads/

=================================================================*/

$aStzSystemCommands = [

	# SYSTEM INFO
	:SystemInfo = [
		:windows = ["cmd.exe", ["/c", "systeminfo"]],
		:unix = ["sh", ["-c", "uname -a && lscpu && free -h"]],
		:description = "Display system information (OS version, architecture, kernel)",
		:ReturnType = "string"
	],

	# FILE OPERATIONS
	:ListFiles = [
		:windows = ["cmd.exe", ["/c", "dir", "/B"]],
		:unix = ["ls", ["-1"]],
		:description = "List files in current directory (names only)",
		:ReturnType = "list"
	],

	:ListFilesXT = [
		:windows = ["cmd.exe", ["/c", "dir"]],
		:unix = ["ls", ["-la"]],
		:description = "List files with details (size, date, permissions)",
		:ReturnType = "string"
	],

	:CopyFile = [
		:windows = ["cmd.exe", ["/c", "copy", "{source}", "{dest}"]],
		:unix = ["cp", ["{source}", "{dest}"]],
		:description = "Copy file from source to destination",
		:params = [:source, :dest],
		:ReturnType = "string"
	],

	:MoveFile = [
		:windows = ["cmd.exe", ["/c", "move", "{source}", "{dest}"]],
		:unix = ["mv", ["{source}", "{dest}"]],
		:description = "Move/rename file",
		:params = [:source, :dest],
		:ReturnType = "string"
	],

	:DeleteFile = [
		:windows = ["cmd.exe", ["/c", "del", "{file}"]],
		:unix = ["rm", ["{file}"]],
		:description = "Delete a file",
		:params = [:file],
		:ReturnType = "string"
	],

	:FindFiles = [
		:windows = ["cmd.exe", ["/c", "dir", "/S", "/B", "{pattern}"]],
		:unix = ["find", [".", "-name", "{pattern}"]],
		:description = "Search for files matching pattern",
		:params = [:pattern],
		:ReturnType = "list"
	],

	:CountLines = [
		:windows = ["cmd.exe", ["/c", "find", "/C", "/V", '""', "{file}"]],
		:unix = ["wc", ["-l", "{file}"]],
		:description = "Count lines in file",
		:params = [:file],
		:ReturnType = "number"
	],

	:WordCount = [
		:windows = ["powershell", ["-Command", "(Get-Content", "{file}", "|", "Measure-Object", "-Word).Words"]],
		:unix = ["wc", ["-w", "{file}"]],
		:description = "Count words in file",
		:params = [:file],
		:ReturnType = "number"
	],

	# DIRECTORY OPERATIONS
	:MakeDir = [
		:windows = ["cmd.exe", ["/c", "mkdir", "{path}"]],
		:unix = ["mkdir", ["-p", "{path}"]],
		:description = "Create directory (and parents if needed)",
		:params = [:path],
		:ReturnType = "string"
	],

	:RemoveDir = [
		:windows = ["cmd.exe", ["/c", "rmdir", "/S", "/Q", "{path}"]],
		:unix = ["rm", ["-rf", "{path}"]],
		:description = "Remove directory and contents",
		:params = [:path],
		:ReturnType = "string"
	],

	:CurrentDir = [
		:windows = ["cmd.exe", ["/c", "cd"]],
		:unix = ["pwd", []],
		:description = "Get current working directory",
		:ReturnType = "string"
	]
]

# Get system command data
func SysData(cCommandName)
	if NOT haskey($aStzSystemCommands, cCommandName)
		stzraise("Unknown system command: " + cCommandName)
	ok
	
	return $aStzSystemCommands[cCommandName]

	func SysCmdData(cCommandName)
		return SysData(cCommandName)

	func SystemCommandData(cCommandName)
		return SysData(cCommandName)


# Create StzSystemCall with return type automatically set
func Sys(cCommand)
	if NOT haskey($aStzSystemCommands, cCommand)
		stzraise("Unknown system command: " + cCommand)
	ok
	
	aCmd = $aStzSystemCommands[cCommand]
	
	# Get platform-specific command
	aPlatformCmd = ""
	if isWindows() and haskey(aCmd, :windows)
		aPlatformCmd = aCmd[:windows]
	but isMacOS() and haskey(aCmd, :mac)
		aPlatformCmd = aCmd[:mac]
	but haskey(aCmd, :unix)
		aPlatformCmd = aCmd[:unix]
	ok
	
	if aPlatformCmd = ""
		stzraise("Command not supported on this platform: " + cCommand)
	ok
	
	# Build command string
	cProgram = aPlatformCmd[1]
	acArgs = aPlatformCmd[2]
	
	cResult = cProgram
	for cArg in acArgs
		cResult += " " + cArg
	next
	
	# Add return type suffix
	if haskey(aCmd, :ReturnType)
		cResult += " @RETURN:" + aCmd[:ReturnType]
	ok
	
	return cResult

	func SysCmd(cCommand)
		return Sys(cCommand)

	def SystemCommand(cCommand)
		return Sys(cCommand)
