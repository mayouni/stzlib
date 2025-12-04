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

	# FILE OPERATIONS
	:ListFiles = [
		:windows = ["cmd.exe", ["/c", "dir", "/B"]],
		:unix = ["ls", ["-1"]],
		:description = "List files in current directory (names only)",
		:returns = :output
	],

	:ListFilesXT = [
		:windows = ["cmd.exe", ["/c", "dir"]],
		:unix = ["ls", ["-la"]],
		:description = "List files with details (size, date, permissions)",
		:returns = :output
	],

	:CopyFile = [
		:windows = ["cmd.exe", ["/c", "copy", "{source}", "{dest}"]],
		:unix = ["cp", ["{source}", "{dest}"]],
		:description = "Copy file from source to destination",
		:params = [:source, :dest],
		:returns = :exitcode
	],

	:MoveFile = [
		:windows = ["cmd.exe", ["/c", "move", "{source}", "{dest}"]],
		:unix = ["mv", ["{source}", "{dest}"]],
		:description = "Move/rename file",
		:params = [:source, :dest],
		:returns = :exitcode
	],

	:DeleteFile = [
		:windows = ["cmd.exe", ["/c", "del", "{file}"]],
		:unix = ["rm", ["{file}"]],
		:description = "Delete a file",
		:params = [:file],
		:returns = :exitcode
	],

	:FindFiles = [
		:windows = ["cmd.exe", ["/c", "dir", "/S", "/B", "{pattern}"]],
		:unix = ["find", [".", "-name", "{pattern}"]],
		:description = "Search for files matching pattern",
		:params = [:pattern],
		:returns = :output
	],

	:FindLargeFiles = [
		:windows = ["powershell", ["-Command", "Get-ChildItem", "-Recurse", "|", "Where-Object", "{$_.Length", "-gt", "{size}", "}"]],
		:unix = ["find", [".", "-type", "f", "-size", "+{size}"]],
		:description = "Find files larger than size (e.g., 100M, 1G)",
		:params = [:size],
		:requires = "Built-in",
		:returns = :output
	],

	# DIRECTORY OPERATIONS
	:MakeDir = [
		:windows = ["cmd.exe", ["/c", "mkdir", "{path}"]],
		:unix = ["mkdir", ["-p", "{path}"]],
		:description = "Create directory (and parents if needed)",
		:params = [:path],
		:returns = :exitcode
	],

	:RemoveDir = [
		:windows = ["cmd.exe", ["/c", "rmdir", "/S", "/Q", "{path}"]],
		:unix = ["rm", ["-rf", "{path}"]],
		:description = "Remove directory and contents",
		:params = [:path],
		:returns = :exitcode
	],

	:CurrentDir = [
		:windows = ["cmd.exe", ["/c", "cd"]],
		:unix = ["pwd", []],
		:description = "Get current working directory",
		:returns = :output
	],

	# SYSTEM INFO
	:SystemInfo = [
		:windows = ["systeminfo", []],
		:unix = ["uname", ["-a"]],
		:description = "Get system information",
		:returns = :output
	],

	:DiskSpace = [
		:windows = ["cmd.exe", ["/c", "wmic", "logicaldisk", "get", "size,freespace,caption"]],
		:unix = ["df", ["-h"]],
		:description = "Show disk space usage",
		:returns = :output
	],

	:Processes = [
		:windows = ["tasklist", []],
		:unix = ["ps", ["aux"]],
		:description = "List running processes",
		:returns = :output
	],

	:KillProcess = [
		:windows = ["taskkill", ["/F", "/PID", "{pid}"]],
		:unix = ["kill", ["-9", "{pid}"]],
		:description = "Terminate process by ID",
		:params = [:pid],
		:returns = :exitcode
	],

	:KillByName = [
		:windows = ["taskkill", ["/F", "/IM", "{name}"]],
		:unix = ["killall", ["{name}"]],
		:description = "Terminate all processes by name",
		:params = [:name],
		:returns = :exitcode
	],

	:MemoryUsage = [
		:windows = ["cmd.exe", ["/c", "wmic", "OS", "get", "FreePhysicalMemory,TotalVisibleMemorySize"]],
		:unix = ["free", ["-h"]],
		:description = "Show memory usage",
		:returns = :output
	],

	:CpuInfo = [
		:windows = ["wmic", ["cpu", "get", "name,numberofcores,maxclockspeed"]],
		:unix = ["lscpu", []],
		:description = "Display CPU information",
		:returns = :output
	],

	# NETWORK
	:Ping = [
		:windows = ["ping", ["-n", "4", "{host}"]],
		:unix = ["ping", ["-c", "4", "{host}"]],
		:description = "Ping a host (4 packets)",
		:params = [:host],
		:returns = :output
	],

	:IpConfig = [
		:windows = ["ipconfig", []],
		:unix = ["ifconfig", []],
		:description = "Show network configuration",
		:returns = :output
	],

	:DownloadFile = [
		:windows = ["powershell", ["-Command", "Invoke-WebRequest", "-Uri", "{url}", "-OutFile", "{file}"]],
		:unix = ["curl", ["-o", "{file}", "{url}"]],
		:description = "Download file from URL",
		:params = [:url, :file],
		:returns = :exitcode
	],

	:CurlGet = [
		:windows = ["curl", ["{url}"]],
		:unix = ["curl", ["{url}"]],
		:description = "HTTP GET request",
		:params = [:url],
		:requires = "curl (usually pre-installed)",
		:returns = :output
	],

	:CurlPost = [
		:windows = ["curl", ["-X", "POST", "-d", "{data}", "{url}"]],
		:unix = ["curl", ["-X", "POST", "-d", "{data}", "{url}"]],
		:description = "HTTP POST request with data",
		:params = [:url, :data],
		:requires = "curl",
		:returns = :output
	],

	# TEXT PROCESSING
	:FindInFile = [
		:windows = ["cmd.exe", ["/c", "find", '"{text}"', "{file}"]],
		:unix = ["grep", ["{text}", "{file}"]],
		:description = "Search for text in file",
		:params = [:text, :file],
		:returns = :output
	],

	:CountLines = [
		:windows = ["cmd.exe", ["/c", "find", "/C", "/V", '""', "{file}"]],
		:unix = ["wc", ["-l", "{file}"]],
		:description = "Count lines in file",
		:params = [:file],
		:returns = :output
	],

	:WordCount = [
		:windows = ["powershell", ["-Command", "(Get-Content", "{file}", "|", "Measure-Object", "-Word).Words"]],
		:unix = ["wc", ["-w", "{file}"]],
		:description = "Count words in file",
		:params = [:file],
		:returns = :output
	],

	:FindAndReplace = [
		:windows = ["powershell", ["-Command", "(Get-Content", "{file})", "-replace", "'{old}',", "'{new}'", "|", "Set-Content", "{file}"]],
		:unix = ["sed", ["-i", "s/{old}/{new}/g", "{file}"]],
		:description = "Find and replace text in file",
		:params = [:file, :old, :new],
		:returns = :exitcode
	],

	# COMPRESSION
	:ZipFiles = [
		:windows = ["powershell", ["-Command", "Compress-Archive", "-Path", "{source}", "-DestinationPath", "{dest}"]],
		:unix = ["zip", ["-r", "{dest}", "{source}"]],
		:description = "Create ZIP archive",
		:params = [:source, :dest],
		:returns = :exitcode
	],

	:UnzipFiles = [
		:windows = ["powershell", ["-Command", "Expand-Archive", "-Path", "{source}", "-DestinationPath", "{dest}"]],
		:unix = ["unzip", ["{source}", "-d", "{dest}"]],
		:description = "Extract ZIP archive",
		:params = [:source, :dest],
		:returns = :exitcode
	],

	:TarCreate = [
		:windows = ["tar", ["-czf", "{dest}", "{source}"]],
		:unix = ["tar", ["-czf", "{dest}", "{source}"]],
		:description = "Create tar.gz archive",
		:params = [:source, :dest],
		:requires = "tar (Windows 10+)",
		:returns = :exitcode
	],

	:TarExtract = [
		:windows = ["tar", ["-xzf", "{source}"]],
		:unix = ["tar", ["-xzf", "{source}"]],
		:description = "Extract tar.gz archive",
		:params = [:source],
		:requires = "tar",
		:returns = :exitcode
	],

	# GIT OPERATIONS
	:GitStatus = [
		:windows = ["git", ["status", "--short"]],
		:unix = ["git", ["status", "--short"]],
		:description = "Show git status (short format)",
		:requires = "Git - https://git-scm.com",
		:returns = :output
	],

	:GitCommit = [
		:windows = ["git", ["commit", "-m", "{message}"]],
		:unix = ["git", ["commit", "-m", "{message}"]],
		:description = "Commit changes with message",
		:params = [:message],
		:requires = "Git",
		:returns = :output
	],

	:GitPush = [
		:windows = ["git", ["push", "origin", "{branch}"]],
		:unix = ["git", ["push", "origin", "{branch}"]],
		:description = "Push to remote branch",
		:params = [:branch],
		:requires = "Git",
		:returns = :output
	],

	:GitPull = [
		:windows = ["git", ["pull"]],
		:unix = ["git", ["pull"]],
		:description = "Pull from remote",
		:requires = "Git",
		:returns = :output
	],

	:GitClone = [
		:windows = ["git", ["clone", "{url}"]],
		:unix = ["git", ["clone", "{url}"]],
		:description = "Clone repository",
		:params = [:url],
		:requires = "Git",
		:returns = :output
	],

	:GitLog = [
		:windows = ["git", ["log", "--oneline", "-n", "{n}"]],
		:unix = ["git", ["log", "--oneline", "-n", "{n}"]],
		:description = "Show last N commits",
		:params = [:n],
		:requires = "Git",
		:returns = :output
	],

	# IMAGE PROCESSING
	:ResizeImage = [
		:windows = ["magick", ["{input}", "-resize", "{size}", "{output}"]],
		:unix = ["convert", ["{input}", "-resize", "{size}", "{output}"]],
		:description = "Resize image (e.g., size=800x600)",
		:params = [:input, :size, :output],
		:requires = "ImageMagick - https://imagemagick.org",
		:returns = :exitcode
	],

	:ConvertImage = [
		:windows = ["magick", ["{input}", "{output}"]],
		:unix = ["convert", ["{input}", "{output}"]],
		:description = "Convert image format",
		:params = [:input, :output],
		:requires = "ImageMagick",
		:returns = :exitcode
	],

	:ImageInfo = [
		:windows = ["magick", ["identify", "{file}"]],
		:unix = ["identify", ["{file}"]],
		:description = "Get image dimensions and format",
		:params = [:file],
		:requires = "ImageMagick",
		:returns = :output
	],

	:PdfToImages = [
		:windows = ["magick", ["{pdf}", "{output}-%d.png"]],
		:unix = ["convert", ["{pdf}", "{output}-%d.png"]],
		:description = "Convert PDF pages to images",
		:params = [:pdf, :output],
		:requires = "ImageMagick",
		:returns = :exitcode
	],

	# VIDEO/AUDIO PROCESSING
	:VideoToGif = [
		:windows = ["ffmpeg", ["-i", "{video}", "-vf", "fps=10,scale=320:-1", "{output}.gif"]],
		:unix = ["ffmpeg", ["-i", "{video}", "-vf", "fps=10,scale=320:-1", "{output}.gif"]],
		:description = "Convert video to GIF",
		:params = [:video, :output],
		:requires = "FFmpeg - https://ffmpeg.org",
		:returns = :exitcode
	],

	:ExtractAudio = [
		:windows = ["ffmpeg", ["-i", "{video}", "-vn", "-acodec", "copy", "{output}"]],
		:unix = ["ffmpeg", ["-i", "{video}", "-vn", "-acodec", "copy", "{output}"]],
		:description = "Extract audio from video",
		:params = [:video, :output],
		:requires = "FFmpeg",
		:returns = :exitcode
	],

	:CompressVideo = [
		:windows = ["ffmpeg", ["-i", "{input}", "-vcodec", "h264", "-crf", "28", "{output}"]],
		:unix = ["ffmpeg", ["-i", "{input}", "-vcodec", "h264", "-crf", "28", "{output}"]],
		:description = "Compress video (CRF 28 = good quality/size)",
		:params = [:input, :output],
		:requires = "FFmpeg",
		:returns = :exitcode
	],

	:VideoInfo = [
		:windows = ["ffprobe", ["-v", "error", "-show_format", "-show_streams", "{file}"]],
		:unix = ["ffprobe", ["-v", "error", "-show_format", "-show_streams", "{file}"]],
		:description = "Get video metadata",
		:params = [:file],
		:requires = "FFmpeg",
		:returns = :output
	],

	# DOCUMENT CONVERSION
	:Markdown2Html = [
		:windows = ["pandoc", ["{input}", "-o", "{output}"]],
		:unix = ["pandoc", ["{input}", "-o", "{output}"]],
		:description = "Convert Markdown to HTML",
		:params = [:input, :output],
		:requires = "Pandoc - https://pandoc.org",
		:returns = :exitcode
	],

	:Markdown2Pdf = [
		:windows = ["pandoc", ["{input}", "-o", "{output}", "--pdf-engine=xelatex"]],
		:unix = ["pandoc", ["{input}", "-o", "{output}", "--pdf-engine=xelatex"]],
		:description = "Convert Markdown to PDF",
		:params = [:input, :output],
		:requires = "Pandoc + LaTeX",
		:returns = :exitcode
	],

	# DATABASE OPERATIONS
	:SqliteQuery = [
		:windows = ["sqlite3", ["{db}", "{query}"]],
		:unix = ["sqlite3", ["{db}", "{query}"]],
		:description = "Execute SQLite query",
		:params = [:db, :query],
		:requires = "SQLite - https://sqlite.org",
		:returns = :output
	],

	:SqliteBackup = [
		:windows = ["sqlite3", ["{db}", ".backup", "{output}"]],
		:unix = ["sqlite3", ["{db}", ".backup", "{output}"]],
		:description = "Backup SQLite database",
		:params = [:db, :output],
		:requires = "SQLite",
		:returns = :exitcode
	],

	# SECURITY & ENCRYPTION
	:EncryptFile = [
		:windows = ["gpg", ["--encrypt", "--recipient", "{email}", "{file}"]],
		:unix = ["gpg", ["--encrypt", "--recipient", "{email}", "{file}"]],
		:description = "Encrypt file with GPG",
		:params = [:file, :email],
		:requires = "GPG - https://gnupg.org",
		:returns = :exitcode
	],

	:DecryptFile = [
		:windows = ["gpg", ["--decrypt", "{file}"]],
		:unix = ["gpg", ["--decrypt", "{file}"]],
		:description = "Decrypt GPG file",
		:params = [:file],
		:requires = "GPG",
		:returns = :output
	],

	:GenerateSshKey = [
		:windows = ["ssh-keygen", ["-t", "rsa", "-b", "4096", "-f", "{output}"]],
		:unix = ["ssh-keygen", ["-t", "rsa", "-b", "4096", "-f", "{output}"]],
		:description = "Generate SSH key pair",
		:params = [:output],
		:returns = :exitcode
	],

	# DOCKER OPERATIONS
	:DockerBuild = [
		:windows = ["docker", ["build", "-t", "{tag}", "."]],
		:unix = ["docker", ["build", "-t", "{tag}", "."]],
		:description = "Build Docker image",
		:params = [:tag],
		:requires = "Docker - https://docker.com",
		:returns = :output
	],

	:DockerRun = [
		:windows = ["docker", ["run", "-d", "{image}"]],
		:unix = ["docker", ["run", "-d", "{image}"]],
		:description = "Run Docker container (detached)",
		:params = [:image],
		:requires = "Docker",
		:returns = :output
	],

	:DockerPs = [
		:windows = ["docker", ["ps"]],
		:unix = ["docker", ["ps"]],
		:description = "List running containers",
		:requires = "Docker",
		:returns = :output
	],

	:DockerStop = [
		:windows = ["docker", ["stop", "{container}"]],
		:unix = ["docker", ["stop", "{container}"]],
		:description = "Stop Docker container",
		:params = [:container],
		:requires = "Docker",
		:returns = :exitcode
	],

	# PACKAGE MANAGERS
	:NpmInstall = [
		:windows = ["npm", ["install", "{package}"]],
		:unix = ["npm", ["install", "{package}"]],
		:description = "Install npm package",
		:params = [:package],
		:requires = "Node.js - https://nodejs.org",
		:returns = :output
	],

	:PipInstall = [
		:windows = ["pip", ["install", "{package}"]],
		:unix = ["pip", ["install", "{package}"]],
		:description = "Install Python package",
		:params = [:package],
		:requires = "Python - https://python.org",
		:returns = :output
	],

	# FILE VIEWING
	:OpenFile = [
		:windows = ["cmd.exe", ["/c", "start", "", "{file}"]],
		:unix = ["xdg-open", ["{file}"]],
		:mac = ["open", ["{file}"]],
		:description = "Open file with default application",
		:params = [:file],
		:returns = :exitcode
	],

	:OpenUrl = [
		:windows = ["cmd.exe", ["/c", "start", "{url}"]],
		:unix = ["xdg-open", ["{url}"]],
		:mac = ["open", ["{url}"]],
		:description = "Open URL in default browser",
		:params = [:url],
		:returns = :exitcode
	],

	# CHECKSUM
	:Md5sum = [
		:windows = ["powershell", ["-Command", "Get-FileHash", "-Algorithm", "MD5", "{file}"]],
		:unix = ["md5sum", ["{file}"]],
		:description = "Calculate MD5 checksum",
		:params = [:file],
		:returns = :output
	],

	:Sha256sum = [
		:windows = ["powershell", ["-Command", "Get-FileHash", "-Algorithm", "SHA256", "{file}"]],
		:unix = ["sha256sum", ["{file}"]],
		:description = "Calculate SHA256 checksum",
		:params = [:file],
		:returns = :output
	],

	# DATE/TIME
	:CurrentDate = [
		:windows = ["cmd.exe", ["/c", "date", "/T"]],
		:unix = ["date", ["+%Y-%m-%d"]],
		:description = "Get current date",
		:returns = :output
	],

	:CurrentTime = [
		:windows = ["cmd.exe", ["/c", "time", "/T"]],
		:unix = ["date", ["+%H:%M:%S"]],
		:description = "Get current time",
		:returns = :output
	],

	# ENVIRONMENT
	:GetEnvVar = [
		:windows = ["cmd.exe", ["/c", "echo", "%{var}%"]],
		:unix = ["printenv", ["{var}"]],
		:description = "Get environment variable value",
		:params = [:var],
		:returns = :output
	],

	:ListEnvVars = [
		:windows = ["cmd.exe", ["/c", "set"]],
		:unix = ["printenv", []],
		:description = "List all environment variables",
		:returns = :output
	]
]

# Get system command data
func syscmd(cCommandName)
	if NOT haskey($aStzSystemCommands, cCommandName)
		stzraise("Unknown system command: " + cCommandName)
	ok
	
	return $aStzSystemCommands[cCommandName]
