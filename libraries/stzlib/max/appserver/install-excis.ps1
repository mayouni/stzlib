<#
.SYNOPSIS
    Automated installation script for Softanza PolyServer, the polyglot application
	server allowing Softanza External Code Integration System (EXCIS)
    Prioritizes Ring language and ensures clear documentation for non-expert users.
    This enhanced version includes dynamic downloads, SHA256 hash verification,
    optional component selection, system validation, service verification, and API testing.
.PARAMETER BaseDirectory
    The base directory where EXCIS will be installed. Defaults to C:\excis.
.PARAMETER DatabaseUser
    The default username for the databases. Defaults to excis.
.PARAMETER DatabasePassword
    The default password for the databases. Defaults to excispass.
.PARAMETER DatabaseName
    The default database name. Defaults to excisdb.
.PARAMETER InstallRing
    Switch parameter to indicate if Ring should be installed. Defaults to $true.
.PARAMETER InstallPython
    Switch parameter to indicate if Python should be installed. Defaults to $true.
.PARAMETER InstallNodeJS
    Switch parameter to indicate if Node.js should be installed. Defaults to $true.
.PARAMETER InstallJulia
    Switch parameter to indicate if Julia should be installed. Defaults to $false.
.PARAMETER InstallR
    Switch parameter to indicate if R should be installed. Defaults to $false.
.PARAMETER InstallProlog
    Switch parameter to indicate if SWI-Prolog should be installed. Defaults to $false.
#>
[CmdletBinding()]
param(
    [string]$BaseDirectory = "C:\excis",
    [string]$DatabaseUser = "excis",
    [string]$DatabasePassword = "excispass",
    [string]$DatabaseName = "excisdb",
    [switch]$InstallRing = $true,
    [switch]$InstallPython = $true,
    [switch]$InstallNodeJS = $true,
    [switch]$InstallJulia = $false,
    [switch]$InstallR = $false,
    [switch]$InstallProlog = $false
)

# Ensure script is running with admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires administrator privileges. Please restart as administrator." -ForegroundColor Red
    Exit 1
}

# -----------------------------
# Configuration Section (Dynamic URLs and Hashes)
# -----------------------------
# Subdirectories
$serversDir = Join-Path $BaseDirectory "servers"
$logsDir = Join-Path $BaseDirectory "logs"
$modelsDir = Join-Path $BaseDirectory "models"
$configDir = Join-Path $BaseDirectory "config"
$tempDir = Join-Path $BaseDirectory "temp"

# Port assignments (Ring prioritized)
$requiredPorts = @(
    5001, # Ring
    5002, # Python
    5003, # Node.js
    5004, # Julia
    5005, # R
    5006  # Prolog
	11211 # Memcached
)

# Define download URLs and expected SHA256 hashes
$installers = @{
    "ring" = @{
        "url" = "https://github.com/ring-lang/ring/releases/download/v1.16/Fayed_Ring_1.16_Windows_64bit.exe"
        "hash" = "YOUR_RING_SHA256_HASH" # REPLACE WITH ACTUAL HASH
        "installArgs" = "/VERYSILENT"
        "pathEnvVar" = "C:\Ring\bin"
        "testCommand" = "ring -version"
    }
    "python" = @{
        "url" = "https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe"
        "hash" = "YOUR_PYTHON_SHA256_HASH" # REPLACE WITH ACTUAL HASH
        "installArgs" = @("/quiet", "PrependPath=1")
        "testCommand" = "python --version"
        "packages" = "fastapi uvicorn pandas numpy scikit-learn"
    }
    "node" = @{
        "url" = "https://nodejs.org/dist/v16.20.0/node-v16.20.0-x64.msi"
        "hash" = "YOUR_NODE_SHA256_HASH" # REPLACE WITH ACTUAL HASH
        "installerType" = "msi"
        "installArgs" = @("/i", "$tempDir\node_installer.msi", "/quiet", "/norestart")
        "testCommand" = "node -v"
        "packages" = "express body-parser node-fetch @supabase/supabase-js"
    }
    "julia" = @{
        "url" = "https://julialang-s3.julialang.org/bin/winnt/x64/1.8/julia-1.8.5-win64.exe"
        "hash" = "YOUR_JULIA_SHA256_HASH" # REPLACE WITH ACTUAL HASH
        "installArgs" = @("/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART", "/SP-", "/ALLUSERS")
        "testCommand" = "julia --version"
        "packages" = "using Pkg; Pkg.add([\"HTTP\", \"JSON\", \"Statistics\"])"
        "packageInstallCommand" = "julia -e"
        "optional" = $true
    }
    "r" = @{
        "url" = "https://cran.r-project.org/bin/windows/base/R-4.2.2-win.exe"
        "hash" = "YOUR_R_SHA256_HASH" # REPLACE WITH ACTUAL HASH
        "installArgs" = "/SILENT"
        "testCommand" = "R --version"
        "packages" = "library(plumber); library(jsonlite)"
        "packageInstallCommand" = "R -e"
        "optional" = $true
    }
    "prolog" = @{
        "url" = "https://www.swi-prolog.org/download/stable/bin/swipl-9.0.0-1.x64.exe"
        "hash" = "YOUR_PROLOG_SHA256_HASH" # REPLACE WITH ACTUAL HASH
        "installArgs" = "/SILENT"
        "testCommand" = "swipl --version"
        "optional" = $true
    }
    "nssm" = @{
        "url" = "https://nssm.cc/release/nssm-2.24.zip"
        "hash" = "YOUR_NSSM_SHA256_HASH" # REPLACE WITH ACTUAL HASH
        "installerType" = "zip"
        "extractPath" = "$BaseDirectory\nssm"
        "executable" = "nssm.exe"
    }
	"memcached" = @{
		"url" = "https://github.com/nono303/memcached-win64/releases/download/1.6.9/memcached-1.6.9-win64.zip"
		"hash" = "YOUR_MEMCACHED_SHA256_HASH" # Replace with the actual SHA256 hash of the zip file
		"installerType" = "zip"
		"extractPath" = "$BaseDirectory\memcached"
		"executable" = "memcached.exe"
		"testCommand" = "memcached --version"
		"optional" = $false
	}
}

# -----------------------------
# Logging Setup
# -----------------------------
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
}
$logFile = Join-Path $logsDir "excis_install.log"
Start-Transcript -Path $logFile -Append
Write-Host "Softanza EXCIS Installation Started at $(Get-Date)" -ForegroundColor Green

# -----------------------------
# Helper Functions
# -----------------------------

function Test-Port {
    param ([int]$port)
    try {
        $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, $port)
        $listener.Start()
        $listener.Stop()
        return $true
    } catch {
        Write-Warning "Port $port is in use. Error: $_"
        return $false
    }
}

function Download-File {
    param (
        [string]$Url,
        [string]$OutputPath,
        [string]$ExpectedHash
    )
    Write-Host "    Downloading $Url to $OutputPath..." -ForegroundColor Yellow
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
        Write-Host "    Download completed." -ForegroundColor Green
        if ($ExpectedHash) {
            $actualHash = (Get-FileHash -Path $OutputPath -Algorithm SHA256).Hash
            if ($actualHash -ne $ExpectedHash) {
                Write-Error "File hash mismatch for $OutputPath! Expected: $ExpectedHash, Actual: $actualHash"
                return $false
            }
            Write-Host "    File hash verified." -ForegroundColor Green
        }
        return $true
    } catch {
        Write-Error "Failed to download: $_"
        return $false
    }
}

function Test-Command {
    param ([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

function Invoke-ExternalCommand {
    param (
        [string]$Command,
        [string]$Arguments = "",
        [string]$WorkingDirectory = $PWD
    )
    Write-Host "    Running: $Command $Arguments" -ForegroundColor Yellow
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $Command
    $processInfo.Arguments = $Arguments
    $processInfo.WorkingDirectory = $WorkingDirectory
    $processInfo.RedirectStandardError = $true
    $processInfo.RedirectStandardOutput = $true
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    $process.Start() | Out-Null
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    $result = @{
        ExitCode = $process.ExitCode
        StdOut = $stdout
        StdErr = $stderr
    }
    if ($process.ExitCode -ne 0) {
        Write-Error "Command '$Command $Arguments' failed with exit code $($process.ExitCode). STDERR: $stderr"
    }
    return $result
}

function Wait-ForServer {
    param (
        [string]$Url,
        [int]$TimeoutSeconds = 30
    )
    $startTime = Get-Date
    while ($true) {
        try {
            $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5
            if ($response.StatusCode -eq 200) {
                return $true
            }
        } catch {
            if ((New-TimeSpan $startTime (Get-Date)).TotalSeconds -ge $TimeoutSeconds) {
                Write-Warning "Server at $Url did not respond within timeout period."
                return $false
            }
            Start-Sleep -Seconds 1
            continue
        }
    }
}

function Test-SystemRequirements {
    Write-Host "Checking system requirements..." -ForegroundColor Cyan
    $osInfo = Get-WmiObject -Class Win32_OperatingSystem
    $osVersion = [Version]$osInfo.Version
    if ($osVersion -lt [Version]"10.0") {
        Write-Error "This script requires Windows 10/Windows Server 2016 or newer. Current version: $($osInfo.Caption)"
        return $false
    }
    Write-Host "    OS Version check passed: $($osInfo.Caption)" -ForegroundColor Green
    if ([Environment]::Is64BitOperatingSystem -eq $false) {
        Write-Error "This script requires a 64-bit operating system."
        return $false
    }
    Write-Host "    Architecture check passed: 64-bit OS" -ForegroundColor Green
    $drive = Split-Path -Qualifier $BaseDirectory
    $disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$drive'"
    $freeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    if ($freeSpaceGB -lt 10) {
        Write-Error "Not enough disk space. Required: 10GB, Available: ${freeSpaceGB}GB on drive $drive"
        return $false
    }
    Write-Host "    Disk space check passed: ${freeSpaceGB}GB available on drive $drive" -ForegroundColor Green
    try {
        $dotNetVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release
        if ($dotNetVersion -lt 394802) {
            Write-Warning "This script works best with .NET Framework 4.6.2 or newer. Consider upgrading."
        } else {
            Write-Host "    .NET Framework check passed" -ForegroundColor Green
        }
    } catch {
        Write-Warning "Could not determine .NET Framework version: $_"
    }
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Warning "This script works best with PowerShell 5.0 or newer. Current version: $($PSVersionTable.PSVersion)"
    } else {
        Write-Host "    PowerShell version check passed: $($PSVersionTable.PSVersion)" -ForegroundColor Green
    }
	# Check available memory (minimum 1GB recommended for Memcached)
	$memoryInfo = Get-WmiObject -Class Win32_OperatingSystem
	$freeMemoryGB = [math]::Round($memoryInfo.FreePhysicalMemory / 1MB, 2)
	if ($freeMemoryGB -lt 1) {
		Write-Warning "Low free memory. Recommended: 1GB, Available: ${freeMemoryGB}GB"
	} else {
		Write-Host "    Memory check passed: ${freeMemoryGB}GB available" -ForegroundColor Green
	}
    return $true
}

function Install-Language {
    param (
        [string]$languageName,
        [hashtable]$config
    )
    Write-Host "Step: Installing $languageName Programming Language..." -ForegroundColor Cyan
    if ($config.testCommand) {
        try {
            $testResult = Invoke-ExternalCommand -Command $config.testCommand
            if ($testResult.ExitCode -eq 0) {
                Write-Host "    $languageName is already installed: $($testResult.StdOut.Trim())" -ForegroundColor Green
                return $true
            }
        } catch {
            # Continue with installation
        }
    }
    if (-not $config.optional) {
        try {
            $checkpointName = "EXCIS_Before_$($languageName)_Install_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Checkpoint-Computer -Description $checkpointName -ErrorAction SilentlyContinue
            Write-Host "    Created system restore point: $checkpointName" -ForegroundColor Green
        } catch {
            Write-Warning "    Could not create system restore point: $_"
        }
    }
    $installerPath = Join-Path $tempDir "$languageName`_installer.$([System.IO.Path]::GetExtension($config.url))"
    if ($config.installerType -eq "zip") {
        $downloaded = Download-File -Url $config.url -OutputPath "$tempDir\$languageName`_installer.zip" -ExpectedHash $config.hash
        if ($downloaded) {
            Write-Host "    Extracting installer..." -ForegroundColor Yellow
            try {
                Expand-Archive -Path "$tempDir\$languageName`_installer.zip" -DestinationPath $config.extractPath -Force
                $installerPath = Join-Path $config.extractPath $config.executable
                Write-Host "    Installer extracted to $installerPath" -ForegroundColor Green
            } catch {
                Write-Error "    Failed to extract installer: $_"
                return $false
            }
        } else {
            Write-Error "    Failed to download $languageName installer."
            return $false
        }
    } else {
        $downloaded = Download-File -Url $config.url -OutputPath $installerPath -ExpectedHash $config.hash
        if (-not $downloaded) {
            Write-Error "    Failed to download $languageName installer."
            return $false
        }
    }
    if ($config.installArgs) {
        Write-Host "    Installing $languageName..." -ForegroundColor Yellow
        $installResult = Start-Process -FilePath $installerPath -ArgumentList $config.installArgs -Wait -PassThru
        if ($installResult.ExitCode -ne 0) {
            Write-Error "    $languageName installation failed with exit code $($installResult.ExitCode)."
            return $false
        }
        Write-Host "    $languageName installed successfully." -ForegroundColor Green
    }
    if ($config.pathEnvVar) {
        $currentPath = [Environment]::GetEnvironmentVariable("Path","Machine")
        if (-not ($currentPath -like "*$($config.pathEnvVar)*")) {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$($config.pathEnvVar)", "Machine")
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            Write-Host "    Added $($languageName) to PATH." -ForegroundColor Green
        } else {
            Write-Host "    $($languageName) already in PATH." -ForegroundColor Green
        }
    }
    if ($config.testCommand) {
        $testResult = Invoke-ExternalCommand -Command $config.testCommand
        if ($testResult.ExitCode -eq 0) {
            Write-Host "    $($languageName) installation verified: $($testResult.StdOut.Trim())" -ForegroundColor Green
        } else {
            Write-Warning "    $($languageName) installation may have issues: $($testResult.StdErr.Trim())"
        }
    }
    if ($config.packages) {
        Write-Host "    Installing $($languageName) packages..." -ForegroundColor Yellow
        $packageInstallCommand = ""
        $packageArgs = ""
        switch ($languageName) {
            "python" {
                $packageInstallCommand = "pip"
                $packageArgs = "install $($config.packages)"
            }
            "node" {
                $packageInstallCommand = "npm"
                $packageArgs = "install -g $($config.packages)"
            }
            "julia" {
                $packageInstallCommand = $config.packageInstallCommand
                $packageArgs = "`"$($config.packages)`""
            }
            "r" {
                $packageInstallCommand = $config.packageInstallCommand
                $packageArgs = "`"$($config.packages)`""
            }
        }
        if ($packageInstallCommand) {
            $packageResult = Invoke-ExternalCommand -Command $packageInstallCommand -Arguments $packageArgs
            if ($packageResult.ExitCode -eq 0) {
                Write-Host "    $($languageName) packages installed successfully." -ForegroundColor Green
            } else {
                Write-Error "    Failed to install $($languageName) packages: $($packageResult.StdErr.Trim())"
            }
        }
    }
    return $true
}

function Create-ServerScript {
    param (
        [string]$languageName,
        [string]$scriptContent,
        [string]$subdirectory
    )
    $scriptPath = Join-Path (Join-Path $serversDir $subdirectory) "server.$($languageName -replace '\.', '')"
    try {
        Set-Content -Path $scriptPath -Value $scriptContent -Force
        Write-Host "    Created server script: $scriptPath" -ForegroundColor Green
    } catch {
        Write-Error "    Failed to create server script at $scriptPath: $_"
        return $false
    }
    return $true
}

function Install-NSSM {
    Write-Host "Step: Installing and Configuring NSSM (Non-Sucking Service Manager)..." -ForegroundColor Cyan
    $nssmConfig = $installers["nssm"]
    if (-not $nssmConfig) {
        Write-Warning "NSSM configuration not found."
        return $false
    }
    if (-not (Test-Path $nssmConfig.extractPath)) {
        Install-Language -languageName "NSSM" -config $nssmConfig
    }
    if (Test-Path $nssmConfig.extractPath) {
        $nssmExecutable = Join-Path $nssmConfig.extractPath $nssmConfig.executable
        if (-not (Test-Path $nssmExecutable)) {
            Write-Error "NSSM executable not found at $($nssmExecutable)."
            return $false
        }
        Write-Host "    NSSM installed." -ForegroundColor Green
        return $nssmExecutable
    } else {
        Write-Host "    NSSM already installed." -ForegroundColor Yellow
        return (Join-Path $nssmConfig.extractPath $nssmConfig.executable)
    }
}

function Register-ServiceNSSM {
    param (
        [string]$serviceName,
        [string]$executablePath,
        [string]$arguments,
        [string]$workingDirectory
    )
    $nssmExecutable = Install-NSSM
    if (-not $nssmExecutable) {
        Write-Warning "NSSM is required to register services."
        return $false
    }
    Write-Host "    Registering service '$serviceName' using NSSM..." -ForegroundColor Yellow
    $nssmCommand = "$nssmExecutable install `"$serviceName`""
    $nssmResult = Invoke-Expression $nssmCommand
    if ($LASTEXITCODE -ne 0) {
        Write-Error "    Failed to create NSSM service definition for '$serviceName'."
        return $false
    }
    & $nssmExecutable set "$serviceName" Application "$executablePath"
    & $nssmExecutable set "$serviceName" AppParameters "$arguments"
    & $nssmExecutable set "$serviceName" AppDirectory "$workingDirectory"
    & $nssmExecutable set "$serviceName" Start SERVICE_AUTO_START
    Write-Host "    Service '$serviceName' registered successfully." -ForegroundColor Green
    return $true
}

function Test-ServiceOperation {
    param (
        [string]$serviceName,
        [string]$testUrl,
        [int]$timeoutSeconds = 30
    )
    Write-Host "    Testing service '$serviceName'..." -ForegroundColor Yellow
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if (-not $service) {
        Write-Error "    Service '$serviceName' does not exist."
        return $false
    }
    if ($service.Status -ne 'Running') {
        Write-Host "    Starting service '$serviceName'..." -ForegroundColor Yellow
        try {
            Start-Service -Name $serviceName
            Start-Sleep -Seconds 3
            $service = Get-Service -Name $serviceName
        } catch {
            Write-Error "    Failed to start service '$serviceName': $_"
            return $false
        }
    }
    if ($service.Status -ne 'Running') {
        Write-Error "    Service '$serviceName' failed to start."
        return $false
    }
    Write-Host "    Service '$serviceName' is running." -ForegroundColor Green
	if ($testUrl) {
		Write-Host "    Testing endpoint at $testUrl..." -ForegroundColor Yellow
		if (Wait-ForServer -Url $testUrl -TimeoutSeconds $timeoutSeconds) {
			Write-Host "    Endpoint test successful." -ForegroundColor Green
		} else {
			Write-Error "    Endpoint test failed. Service may not be responding properly."
			return $false
		}
	} else {
		Write-Host "    No endpoint to test for this service." -ForegroundColor Yellow
	}
	return $true
}

function Test-APIEndpoint {
    param (
        [string]$language,
        [string]$endpoint,
        [string]$testCode
    )
    Write-Host "Testing $language API communication..." -ForegroundColor Yellow
    $testData = @{
        code = $testCode
        params = @{ test = "Hello from $language" }
    } | ConvertTo-Json
    try {
        $response = Invoke-RestMethod -Uri $endpoint -Method Post -Body $testData -ContentType "application/json"
        if ($response.status -eq "success") {
            Write-Host "    $language API test successful!" -ForegroundColor Green
            return $true
        } else {
            Write-Error "    $language API test failed: $($response.error)"
            return $false
        }
    } catch {
        Write-Error "    $language API test failed: $_"
        return $false
    }
}

# -----------------------------
# Main Installation Process
# -----------------------------

if (-not (Test-SystemRequirements)) {
    Write-Error "System requirements not met. Please address the issues and try again."
    Stop-Transcript
    Exit 1
}

# -----------------------------
# Directory Setup (Idempotent)
# -----------------------------
Write-Host "Creating base directories..." -ForegroundColor Cyan
$directories = @(
    $BaseDirectory,
    $serversDir,
    $logsDir,
    $modelsDir,
    $configDir,
    $tempDir,
    (Join-Path $serversDir "ring"),
    (Join-Path $serversDir "python"),
    (Join-Path $serversDir "nodejs"),
    (Join-Path $serversDir "julia"),
    (Join-Path $serversDir "r"),
    (Join-Path $serversDir "prolog")
)
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "    Created directory: $dir" -ForegroundColor Green
    } else {
        Write-Host "    Directory exists: $dir" -ForegroundColor Yellow
    }
}

# -----------------------------
# Port Availability Check
# -----------------------------
Write-Host "Checking required ports..." -ForegroundColor Cyan
$allPortsAvailable = $true
foreach ($port in $requiredPorts) {
    if (-not (Test-Port -port $port)) {
        $allPortsAvailable = $false
    }
}
if (-not $allPortsAvailable) {
    Write-Error "Some required ports are in use. Please free them up before continuing."
    Stop-Transcript
    Exit 1
}

# -----------------------------
# Installation Steps
# -----------------------------

if ($InstallRing) {
    if (Install-Language -languageName "ring" -config $installers["ring"]) {
        $ringServerContent = @"
# Ring HTTP Server Script
# Location: $serversDir\ring\server.ring
# Start: cd "$serversDir\ring" && ring server.ring
# Health: curl http://localhost:5001/health
# Shutdown: curl http://localhost:5001/shutdown
load "httplib.ring"
load "stdlib.ring"
load "jsonlib.ring"

class RingAppServer
    oServer
    aRoutes = []
    aMiddleware = []
    cHost = "127.0.0.1"
    nPort = 5001
    lDebug = _FALSE_

    func init cHostOrPort
        if isNumber(cHostOrPort)
            nPort = cHostOrPort
        else
            cHost = cHostOrPort
        ok
        oServer = new Server(nPort, cHost)

    func route cMethod, cPath, cAction
        aRoutes + [cMethod, cPath, cAction]
        if lDebug see "Route added: " + cMethod + " " + cPath + nl ok

    func gett(cPath, cAction)
        oServer.route("Get", cPath, cAction)

    func postt(cPath, cAction)
        oServer.route("Post", cPath, cAction)

    func use(cMiddleware)
        aMiddleware + cMiddleware
        if lDebug see "Middleware added" + nl ok

    func handleRequest()
        for middleware in aMiddleware
            try
                eval(middleware)
            catch
                if lDebug see "Middleware error: " + cCatchError + nl ok
            done
        next

    func setupRoutes()
        for route in aRoutes
            cMethod = route[1]
            cPath = route[2]
            cAction = route[3]
            oServer.route(cMethod, cPath, "app.handleRequest() " + cAction)
        next

    func setDebug lValue
        lDebug = lValue

    func start
        setupRoutes()
        if lDebug
            ? "Server starting on " + cHost + ":" + nPort
            ? "Debug mode: ON"
            ? "Routes configured: " + len(aRoutes)
        ok
        try
            oServer.listen(cHost, nPort)
        catch
            ? "Server error: " + cCatchError
        done

    func stop()
        if lDebug ? "Server stopping..." ok
        oServer.stop()

    func response(cContent, cType)
        oServer.setContent(cContent, cType)

    func json(cData)
        response(List2Json(cData), "application/json")

    func html(cContent)
        response(cContent, "text/html")

    func getQuery()
        return oServer.Cookies()

    func getParam(cName)
        return oServer[cName]

app = new RingAppServer

app.postt("/execute", {
    try
        requestData = json2map(app.oServer.getBody())
        code = requestData["code"]
        params = requestData["params"] or []
        env = new Env()
        for key in params
            env.(key) = params[key]
        next
        stdout_original = stdout
        stderr_original = stderr
        (rd_out, wr_out) = redirect_stdout()
        (rd_err, wr_err) = redirect_stderr()
        result = exec(code, env)
        flush(wr_out)
        flush(wr_err)
        stdout_text = String(take!(rd_out))
        stderr_text = String(take!(rd_err))
        redirect_stdout(stdout_original)
        redirect_stderr(stderr_original)
        close(wr_out)
        close(wr_err)
        response = map(
            "status", "success",
            "result", result,
            "stdout", stdout_text,
            "stderr", stderr_text
        )
    catch e
        response = map(
            "status", "error",
            "error", string(e),
            "stderr", stderr_text if exists("stderr_text") else ""
        )
    ok
    app.response(Json2Str(response), "application/json")
})

app.gett("/health", {
    app.response(Json2Str(map("status", "healthy")), "application/json")
})

app.gett("/shutdown", {
    app.response(Json2Str(map("status", "shutting down")), "application/json")
    later::later({ quit(save = "no") }, 0.1)
})

app.setDebug(_FALSE_)
app.start()
"@
        Create-ServerScript -languageName "ring" -scriptContent $ringServerContent -subdirectory "ring"
        Register-ServiceNSSM -serviceName "EXCIS-RingServer" -executablePath "ring" -arguments "server.ring" -workingDirectory "$serversDir\ring"
    }
}

if ($InstallPython) {
    if (Install-Language -languageName "python" -config $installers["python"]) {
        $pythonServerContent = @"
# Python Server Script
# Location: $serversDir\python\server.py
# Start: cd "$serversDir\python" && python -m uvicorn server:app --host 127.0.0.1 --port 5002
# Health: curl http://localhost:5002/health
# Shutdown: curl http://localhost:5002/shutdown
from fastapi import FastAPI, Request
import uvicorn
import subprocess
import sys
import io
import contextlib
import json
app = FastAPI()
@app.post("/execute")
async def execute(request: Request):
    data = await request.json()
    code = data.get("code", "")
    params = data.get("params", {})
    try:
        local_vars = {**params}
        stdout = io.StringIO()
        stderr = io.StringIO()
        with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
            exec(code, {}, local_vars)
        if 'result' in local_vars:
            result = local_vars['result']
        else:
            result = stdout.getvalue()
        return {
            "status": "success",
            "result": result,
            "stdout": stdout.getvalue(),
            "stderr": stderr.getvalue()
        }
    except Exception as e:
        return {
            "status": "error",
            "error": str(e),
            "stderr": stderr.getvalue() if 'stderr' in locals() else ""
        }
@app.get("/health")
async def health():
    return {"status": "healthy"}
@app.get("/shutdown")
async def shutdown():
    import threading
    threading.Thread(target=lambda: uvicorn.Server.should_exit()).start()
    return {"status": "shutting down"}
if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=5002)
"@
        Create-ServerScript -languageName "python" -scriptContent $pythonServerContent -subdirectory "python"
        Register-ServiceNSSM -serviceName "EXCIS-PythonServer" -executablePath "python" -arguments "-m uvicorn server:app --host 127.0.0.1 --port 5002" -workingDirectory "$serversDir\python"
    }
}

if ($InstallNodeJS) {
    if (Install-Language -languageName "node" -config $installers["node"]) {
        $nodeServerContent = @"
// Node.js Server Script
// Location: $serversDir\nodejs\server.js
// Start: cd "$serversDir\nodejs" && node server.js
// Health: curl http://localhost:5003/health
// Shutdown: curl http://localhost:5003/shutdown
const express = require('express');
const bodyParser = require('body-parser');
const app = express();
app.use(bodyParser.json());
app.post('/execute', (req, res) => {
  const code = req.body.code || '';
  const params = req.body.params || {};
  try {
    const context = { ...params };
    const executeFunction = new Function(
      ...Object.keys(context),
      `
        try {
          const console = {
            log: function() {
              if (!this.logs) this.logs = [];
              this.logs.push([...arguments].join(' '));
            },
            error: function() {
              if (!this.errors) this.errors = [];
              this.errors.push([...arguments].join(' '));
            },
            logs: [],
            errors: []
          };
          ${code}
          return {
            result: typeof result !== 'undefined' ? result : null,
            stdout: console.logs.join('\\n'),
            stderr: console.errors.join('\\n')
          };
        } catch (e) {
          return { error: e.message };
        }
      `
    );
    const result = executeFunction(...Object.values(context));
    if (result.error) {
      res.json({
        status: 'error',
        error: result.error
      });
    } else {
      res.json({
        status: 'success',
        result: result.result,
        stdout: result.stdout,
        stderr: result.stderr
      });
    }
  } catch (e) {
    res.json({
      status: 'error',
      error: e.message
    });
  }
});
app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});
app.get('/shutdown', (req, res) => {
  res.json({ status: 'shutting down' });
  setTimeout(() => process.exit(0), 100);
});
app.listen(5003, '127.0.0.1', () => {
  console.log('Node.js server listening on port 5003');
});
"@
        Create-ServerScript -languageName "node.js" -scriptContent $nodeServerContent -subdirectory "nodejs"
        Register-ServiceNSSM -serviceName "EXCIS-NodeJSServer" -executablePath "node" -arguments "server.js" -workingDirectory "$serversDir\nodejs"
    }
}

if ($InstallJulia) {
    if (Install-Language -languageName "julia" -config $installers["julia"]) {
        $juliaServerContent = @"
# Julia Server Script
# Location: $serversDir\julia\server.jl
# Start: cd "$serversDir\julia" && julia server.jl
# Health: curl http://localhost:5004/health
# Shutdown: curl http://localhost:5004/shutdown
using HTTP
using JSON
function execute_code(code, params)
    try
        mod = Module()
        for (key, value) in params
            Core.eval(mod, Meta.parse("$key = $(JSON.json(value))"))
        end
        stdout_original = stdout
        stderr_original = stderr
        (rd_out, wr_out) = redirect_stdout()
        (rd_err, wr_err) = redirect_stderr()
        result = Core.eval(mod, Meta.parse(code))
        flush(wr_out)
        flush(wr_err)
        stdout_text = String(take!(rd_out))
        stderr_text = String(take!(rd_err))
        redirect_stdout(stdout_original)
        redirect_stderr(stderr_original)
        close(wr_out)
        close(wr_err)
        return Dict(
            "status" => "success",
            "result" => result,
            "stdout" => stdout_text,
            "stderr" => stderr_text
        )
    catch e
        return Dict(
            "status" => "error",
            "error" => string(e)
        )
    end
end
server = HTTP.Server()
HTTP.@register(server, "POST", "/execute", function(req)
    body = JSON.parse(String(req.body))
    code = get(body, "code", "")
    params = get(body, "params", Dict())
    result = execute_code(code, params)
    return HTTP.Response(200, JSON.json(result))
end)
HTTP.@register(server, "GET", "/health", function(req)
    return HTTP.Response(200, JSON.json(Dict("status" => "healthy")))
end)
HTTP.@register(server, "GET", "/shutdown", function(req)
    @async begin
        sleep(0.1)
        exit()
    end
    return HTTP.Response(200, JSON.json(Dict("status" => "shutting down")))
end)
HTTP.serve(server, "127.0.0.1", 5004)
"@
        Create-ServerScript -languageName "julia" -scriptContent $juliaServerContent -subdirectory "julia"
        Register-ServiceNSSM -serviceName "EXCIS-JuliaServer" -executablePath "julia" -arguments "server.jl" -workingDirectory "$serversDir\julia"
    }
}

if ($InstallR) {
    if (Install-Language -languageName "r" -config $installers["r"]) {
        $rServerContent = @"
# R Server Script
# Location: $serversDir\r\plumber.R
# Start: cd "$serversDir\r" && Rscript plumber.R
# Health: curl http://localhost:5005/health
# Shutdown: curl http://localhost:5005/shutdown
library(plumber)
library(jsonlite)
library(later)
#* @post /execute
function(req) {
  code <- req\$body\$code
  params <- req\$body\$params
  result <- tryCatch({
    env <- new.env()
    if (length(params) > 0) {
      for (name in names(params)) {
        env[[name]] <- params[[name]]
      }
    }
    output <- capture.output({
      eval_result <- eval(parse(text = code), envir = env)
    }, type = "output")
    if (exists("result", envir = env)) {
      final_result <- env\$result
    } else {
      final_result <- eval_result
    }
    list(
      status = "success",
      result = final_result,
      stdout = paste(output, collapse = "\\n"),
      stderr = ""
    )
  }, error = function(e) {
    list(
      status = "error",
      error = as.character(e),
      stderr = as.character(e)
    )
  })
  return(result)
}
#* @get /health
function() {
  list(status = "healthy")
}
#* @get /shutdown
function() {
  later::later(function() {
    quit(save = "no")
  }, 0.1)
  list(status = "shutting down")
}
pr <- plumber::plumb(file = "plumber.R")
pr\$run(host = "127.0.0.1", port = 5005)
"@
        Create-ServerScript -languageName "r" -scriptContent $rServerContent -subdirectory "r"
        Register-ServiceNSSM -serviceName "EXCIS-RServer" -executablePath "Rscript" -arguments "plumber.R" -workingDirectory "$serversDir\r"
    }
}

if ($InstallProlog) {
    if (Install-Language -languageName "prolog" -config $installers["prolog"]) {
        $prologServerContent = @"
% Prolog Server Script
% Location: $serversDir\prolog\server.pl
% Start: cd "$serversDir\prolog" && swipl -f server.pl -g server
% Health: curl http://localhost:5006/health
% Shutdown: curl http://localhost:5006/shutdown
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/json)).
:- use_module(library(json)).
:- http_handler(root(execute), handle_execute, [method(post)]).
:- http_handler(root(health), handle_health, [method(get)]).
:- http_handler(root(shutdown), handle_shutdown, [method(get)]).
:- initialization(server).
server :-
    http_server(http_dispatch, [port(5006)]),
    format('Prolog server running on http://127.0.0.1:5006~n'),
    read_line_to_string(user_input, _).
handle_execute(Request) :-
    http_read_json_dict(Request, Data),
    atom_string(CodeAtom, Data.code),
    tmp_file_stream(text, TmpFile, Stream),
    write(Stream, CodeAtom),
    close(Stream),
    with_output_to(
        string(Output),
        catch(
            (consult(TmpFile), (Data.get(result) -> Result = Data.result ; Result = true)),
            Error,
            (term_string(Error, ErrorStr), Result = error(ErrorStr))
        )
    ),
    delete_file(TmpFile),
    (   is_dict(Result)
    -> Reply = _{status: success, result: Result, stdout: Output, stderr: ''}
    ;   Result = error(ErrorStr)
    -> Reply = _{status: error, error: ErrorStr, stderr: ErrorStr}
    ;   Reply = _{status: success, result: Result, stdout: Output, stderr: ''}
    ),
    reply_json_dict(Reply).
handle_health(_Request) :-
    reply_json_dict(_{status: healthy}).
handle_shutdown(_Request) :-
    reply_json_dict(_{status: 'shutting down'}),
    spawn(halt).
"@
        Create-ServerScript -languageName "prolog" -scriptContent $prologServerContent -subdirectory "prolog"
        Register-ServiceNSSM -serviceName "EXCIS-PrologServer" -executablePath "swipl" -arguments "-f server.pl -g server" -workingDirectory "$serversDir\prolog"
    }
}

if (Install-Language -languageName "memcached" -config $installers["memcached"]) {
    # Register Memcached as a service using NSSM
    $memcachedExecutable = Join-Path $installers["memcached"].extractPath $installers["memcached"].executable
    Register-ServiceNSSM -serviceName "EXCIS-Memcached" -executablePath $memcachedExecutable -arguments "-m 64" -workingDirectory $installers["memcached"].extractPath
}

# -----------------------------
# Verify Service Installation & Operation
# -----------------------------
Write-Host "Verifying installed services..." -ForegroundColor Cyan
$servicesToCheck = @()
if ($InstallRing) { $servicesToCheck += @{name="EXCIS-RingServer"; url="http://localhost:5001/health"} }
if ($InstallPython) { $servicesToCheck += @{name="EXCIS-PythonServer"; url="http://localhost:5002/health"} }
if ($InstallNodeJS) { $servicesToCheck += @{name="EXCIS-NodeJSServer"; url="http://localhost:5003/health"} }
if ($InstallJulia) { $servicesToCheck += @{name="EXCIS-JuliaServer"; url="http://localhost:5004/health"} }
if ($InstallR) { $servicesToCheck += @{name="EXCIS-RServer"; url="http://localhost:5005/health"} }
if ($InstallProlog) { $servicesToCheck += @{name="EXCIS-PrologServer"; url="http://localhost:5006/health"} }
$servicesToCheck += @{name="EXCIS-Memcached"; url=$null}

$allServicesWorking = $true
foreach ($service in $servicesToCheck) {
    if (-not (Test-ServiceOperation -serviceName $service.name -testUrl $service.url)) {
        $allServicesWorking = $false
        Write-Warning "Service validation failed for $($service.name). See log for details."
    }
}
if ($allServicesWorking) {
    Write-Host "All services installed and operating correctly." -ForegroundColor Green
} else {
    Write-Warning "Some services may not be functioning correctly. Please check the log for details."
}

# -----------------------------
# Test API Communication
# -----------------------------
if ($allServicesWorking) {
    Write-Host "Testing API communication with language servers..." -ForegroundColor Cyan
    $apiTests = @()
    if ($InstallRing) {
        $apiTests += @{
            language = "Ring"
            endpoint = "http://localhost:5001/execute"
            testCode = "? 'Hello World from Ring'"
        }
    }
    if ($InstallPython) {
        $apiTests += @{
            language = "Python"
            endpoint = "http://localhost:5002/execute"
            testCode = "print('Hello World from Python')"
        }
    }
    if ($InstallNodeJS) {
        $apiTests += @{
            language = "Node.js"
            endpoint = "http://localhost:5003/execute"
            testCode = "console.log('Hello World from Node.js'); result = 'Success';"
        }
    }
    if ($InstallJulia) {
        $apiTests += @{
            language = "Julia"
            endpoint = "http://localhost:5004/execute"
            testCode = "println(\"Hello World from Julia\")"
        }
    }
    if ($InstallR) {
        $apiTests += @{
            language = "R"
            endpoint = "http://localhost:5005/execute"
            testCode = "cat('Hello World from R')"
        }
    }
    if ($InstallProlog) {
        $apiTests += @{
            language = "Prolog"
            endpoint = "http://localhost:5006/execute"
            testCode = "write('Hello World from Prolog')."
        }
    }
    $allAPIsWorking = $true
    foreach ($test in $apiTests) {
        if (-not (Test-APIEndpoint -language $test.language -endpoint $test.endpoint -testCode $test.testCode)) {
            $allAPIsWorking = $false
        }
    }
    if ($allAPIsWorking) {
        Write-Host "All language APIs are functioning correctly." -ForegroundColor Green
    } else {
        Write-Warning "Some language APIs failed testing. See log for details."
    }
}

# -----------------------------
# Cleanup Temporary Files
# -----------------------------
Write-Host "Cleaning up temporary files..." -ForegroundColor Cyan
Remove-Item -Path (Join-Path $tempDir "*_installer.*") -Force -ErrorAction SilentlyContinue
if (Test-Path (Join-Path $tempDir "*.zip")) {
    Remove-Item -Path (Join-Path $tempDir "*.zip") -Force -ErrorAction SilentlyContinue
}
Write-Host "Temporary files cleaned." -ForegroundColor Green

# -----------------------------
# Finalization
# -----------------------------
Write-Host "Softanza EXCIS Installation Completed at $(Get-Date)" -ForegroundColor Green
Stop-Transcript