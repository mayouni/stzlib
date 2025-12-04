load "../stzbase.ring"

# System commands are no longer cryptic shell syntax
# but accessible Softanza objects!
# named, cross-platform, self-documenting, and immediately useful.

/*========================================
   EXAMPLE 1: List Files (Like Rx pattern)
==========================================

pr()

Sy = new stzSystemCall(:ListFiles)
? Sy.Run()

pf()

/*========================================
   EXAMPLE 2: With Braces Syntax
==========================================

pr()

Sy = new stzSystemCall(:SystemInfo)
Sy {
	Run()
	? Output()
}

pf()

/*========================================
   EXAMPLE 3: Copy File with Parameters
==========================================

pr()

Sy = new stzSystemCall(:CopyFile)
Sy {
	SetParam(:source, "test.txt")
	SetParam(:dest, "backup.txt")
	Run()
	
	if Succeeded()
		? "File copied successfully!"
	ok
}

pf()

/*========================================
   EXAMPLE 4: Fluent Style with Params
==========================================

pr()

StzSystemCallQ(:FindFiles).
	SetParamQ(:pattern, "*.ring").
	RunQ() {
	? Output()
}

pf()

/*========================================
   EXAMPLE 5: Multiple Params at Once
==========================================

pr()

Sy = new stzSystemCall(:FindInFile)
Sy {
	SetParams([
		[:text, "function"],
		[:file, "mycode.ring"]
	])
	Run()
	? Output()
}

pf()

/*========================================
   EXAMPLE 6: Ping Host
==========================================

pr()

Sy = new stzSystemCall(:Ping)
Sy {
	SetParam(:host, "google.com")
	Run()
	? Output()
}

pf()

/*========================================
   EXAMPLE 7: Get Date/Time
==========================================

pr()

? new stzSystemCall(:CurrentDate).Run()
? new stzSystemCall(:CurrentTime).Run()

pf()

/*========================================
   EXAMPLE 8: Create Directory
==========================================

pr()

Sy = new stzSystemCall(:MakeDir)
Sy {
	SetParam(:path, "test_folder")
	Run()
	
	? "Exit code: " + ExitCode()
	? "Success: " + Succeeded()
}

pf()

/*========================================
   EXAMPLE 9: Download File
==========================================

pr()

Sy = new stzSystemCall(:DownloadFile)
Sy {
	SetParams([
		[:url, "https://example.com/file.txt"],
		[:file, "downloaded.txt"]
	])
	Run()
	
	if Succeeded()
		? "Download complete!"
	ok
}

pf()

/*========================================
   EXAMPLE 10: Check Disk Space
==========================================

pr()

Sy = new stzSystemCall(:DiskSpace)
? Sy.Run()

pf()

/*========================================
   EXAMPLE 11: Open File/URL
==========================================

pr()

new stzSystemCall(:OpenFile) {
	SetParam(:file, "document.pdf")
	RunSilently()
}

new stzSystemCall(:OpenUrl) {
	SetParam(:url, "https://softanza.com")
	RunSilently()
}

? "Opened!"

pf()

/*========================================
   EXAMPLE 12: Calculate Checksum
==========================================

pr()

Sy = new stzSystemCall(:Sha256sum)
Sy {
	SetParam(:file, "test.txt")
	Run()
	? Output()
}

pf()

/*========================================
   EXAMPLE 13: Reuse Same Object
==========================================

pr()

Sy = new stzSystemCall(:CopyFile)

# First copy
Sy {
	SetParams([[:source, "a.txt"], [:dest, "b.txt"]])
	Run()
	? "Copy 1: " + Succeeded()
}

# Reset and second copy
Sy {
	Reset()
	SetParams([[:source, "c.txt"], [:dest, "d.txt"]])
	Run()
	? "Copy 2: " + Succeeded()
}

pf()

/*========================================
   EXAMPLE 14: Direct Program Call (Original Style)
==========================================

pr()

# Still works - not using syscmd()
Sy = new stzSystemCall("cmd.exe")
Sy {
	SetArgs(["/c", "echo", "Direct call"])
	Run()
	? Output()
}

pf()

load "stzlib.ring"

/*========================================
   GIT WORKFLOW
==========================================

pr()

# Check status
Sy = new stzSystemCall(:GitStatus)
? Sy.Run()

# Commit changes
new stzSystemCall(:GitCommit) {
	SetParam(:message, "Added new feature")
	Run()
	? Output()
}

# Push to remote
new stzSystemCall(:GitPush) {
	SetParam(:branch, "main")
	Run()
}

pf()

/*========================================
   IMAGE BATCH PROCESSING
==========================================

pr()

aImages = ["photo1.jpg", "photo2.jpg", "photo3.jpg"]

for cImage in aImages
	cOutput = "thumbnails/" + cImage
	
	new stzSystemCall(:ResizeImage) {
		SetParam(:input, cImage)
		SetParam(:size, "200x200")
		SetParam(:output, cOutput)
		Run()
		
		? "Resized: " + cImage
	}
next

pf()

/*========================================
   VIDEO PROCESSING
==========================================

pr()

# Convert video to GIF
Sy = new stzSystemCall(:VideoToGif)
Sy {
	SetParam(:video, "demo.mp4")
	SetParam(:output, "demo")
	Run()
	
	if Succeeded()
		? "GIF created: demo.gif"
	ok
}

# Extract audio
new stzSystemCall(:ExtractAudio) {
	SetParams([
		[:video, "demo.mp4"],
		[:output, "audio.mp3"]
	])
	Run()
}

pf()

/*========================================
   DOCKER DEPLOYMENT
==========================================

pr()

# Build image
new stzSystemCall(:DockerBuild) {
	SetParam(:tag, "myapp:latest")
	Run()
	? Output()
}

# Run container
Sy = new stzSystemCall(:DockerRun)
Sy {
	SetParam(:image, "myapp:latest")
	Run()
	cContainerId = Output()
	? "Container: " + cContainerId
}

# List running containers
? new stzSystemCall(:DockerPs).Run()

pf()

/*========================================
   DOCUMENT CONVERSION
==========================================

pr()

# Markdown to HTML
new stzSystemCall(:Markdown2Html) {
	SetParam(:input, "README.md")
	SetParam(:output, "README.html")
	Run()
}

# Markdown to PDF
new stzSystemCall(:Markdown2Pdf) {
	SetParams([
		[:input, "report.md"],
		[:output, "report.pdf"]
	])
	Run()
}

pf()

/*========================================
   FILE SECURITY
==========================================

pr()

# Calculate checksum
Sy = new stzSystemCall(:Sha256sum)
Sy {
	SetParam(:file, "important.zip")
	Run()
	? "Checksum: " + Output()
}

# Encrypt file
new stzSystemCall(:EncryptFile) {
	SetParams([
		[:file, "secret.txt"],
		[:email, "recipient@example.com"]
	])
	Run()
}

pf()

/*========================================
   DATABASE BACKUP
==========================================

pr()

cTimestamp = "" + clock()
cBackup = "backup_" + cTimestamp + ".db"

Sy = new stzSystemCall(:SqliteBackup)
Sy {
	SetParam(:db, "myapp.db")
	SetParam(:output, cBackup)
	Run()
	
	if Succeeded()
		? "Backup created: " + cBackup
	ok
}

pf()

/*========================================
   SYSTEM MONITORING
==========================================

pr()

? "=== SYSTEM INFO ==="
? new stzSystemCall(:SystemInfo).Run()

? NL + "=== DISK SPACE ==="
? new stzSystemCall(:DiskSpace).Run()

? NL + "=== MEMORY ==="
? new stzSystemCall(:MemoryUsage).Run()

? NL + "=== CPU ==="
? new stzSystemCall(:CpuInfo).Run()

pf()

/*========================================
   BATCH FILE OPERATIONS
==========================================

pr()

# Find all large files
Sy = new stzSystemCall(:FindLargeFiles)
Sy {
	SetParam(:size, "100M")
	Run()
	aLargeFiles = split(Output(), NL)
	? "Found " + len(aLargeFiles) + " large files"
}

# Compress to archive
new stzSystemCall(:ZipFiles) {
	SetParams([
		[:source, "project/"],
		[:dest, "project_backup.zip"]
	])
	Run()
}

pf()

/*========================================
   WEB SCRAPING
==========================================

pr()

# Download page
Sy = new stzSystemCall(:CurlGet)
Sy {
	SetParam(:url, "https://example.com")
	Run()
	cHtml = Output()
	write("page.html", cHtml)
}

# POST data
new stzSystemCall(:CurlPost) {
	SetParams([
		[:url, "https://api.example.com/data"],
		[:data, "key=value"]
	])
	Run()
	? Output()
}

pf()

/*========================================
   PACKAGE INSTALLATION
==========================================

pr()

# Install Python package
new stzSystemCall(:PipInstall) {
	SetParam(:package, "requests")
	Run()
	? Output()
}

# Install Node package
new stzSystemCall(:NpmInstall) {
	SetParam(:package, "express")
	Run()
}

pf()

/*========================================
   TEXT PROCESSING PIPELINE
==========================================

pr()

cFile = "data.txt"

# Count words
Sy = new stzSystemCall(:WordCount)
Sy {
	SetParam(:file, cFile)
	Run()
	? "Words: " + Output()
}

# Find and replace
new stzSystemCall(:FindAndReplace) {
	SetParams([
		[:file, cFile],
		[:old, "old_text"],
		[:new, "new_text"]
	])
	Run()
}

# Search in file
new stzSystemCall(:FindInFile) {
	SetParams([
		[:text, "important"],
		[:file, cFile]
	])
	Run()
	? Output()
}

pf()
