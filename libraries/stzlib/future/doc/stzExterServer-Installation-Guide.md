# stzExterServer Installation Guide for Windows

This guide will walk you through setting up the Softanza External Code Integration System (EXCIS) on Windows, which enables Ring to work as an orchestration layer for multiple programming languages, LLMs, SQL databases, and includes Supabase integration for complete backend-as-a-service capabilities.

## Prerequisites

Before installing stzExterServer, make sure your system has:

- **Operating System**: Windows 10/11 (64-bit)
- **Memory**: At least 4GB RAM (8GB+ recommended for running multiple language servers)
- **Storage**: Minimum 10GB free space
- **Network**: All servers communicate via HTTP, so ensure local ports 5000-5030 are available
- **PowerShell**: Windows PowerShell or PowerShell Core (for running scripts)

## Step 1: Install Ring Programming Language

First, install the Ring programming language which serves as the orchestration layer:

1. Download the Windows installer from [Ring's GitHub repository](https://github.com/ring-lang/ring/releases/download/v1.16/Fayed_Ring_1.16_Windows_64bit.exe)
2. Run the installer as administrator
3. Follow the on-screen instructions to complete installation
4. Add Ring to your PATH environment variable:
   - Right-click on "This PC" or "My Computer" and select "Properties"
   - Click on "Advanced system settings"
   - Click "Environment Variables"
   - Under "System variables", find and edit "Path"
   - Click "New" and add the Ring installation directory (typically `C:\Ring\bin`)
   - Click "OK" on all dialogs

To test your installation, open Command Prompt and type:
```cmd
ring -version
```

You should see the Ring version information displayed.

## Step 2: Install Required Languages

stzExterServer supports multiple languages. Here's how to install each on Windows:

### Python
1. Download Python installer from [python.org](https://www.python.org/downloads/) (version 3.9+ recommended)
2. Run the installer and check "Add Python to PATH"
3. Open Command Prompt and install required libraries:
```cmd
pip install fastapi uvicorn pandas numpy scikit-learn
```

### Node.js
1. Download Node.js installer from [nodejs.org](https://nodejs.org/) (LTS version recommended)
2. Run the installer and follow the prompts
3. Install required Node.js libraries:
```cmd
npm install -g express body-parser node-fetch @supabase/supabase-js
```

### Julia
1. Download the Windows installer from [julialang.org](https://julialang.org/downloads/)
2. Run the installer and check "Add Julia to PATH"
3. Open Command Prompt and install required packages:
```cmd
julia -e "using Pkg; Pkg.add([\"HTTP\", \"JSON\", \"Statistics\"])"
```

### R
1. Download R installer from [r-project.org](https://cran.r-project.org/bin/windows/base/)
2. Run the installer and follow the prompts
3. Download and install RStudio from [rstudio.com](https://www.rstudio.com/products/rstudio/download/)
4. Open RStudio and install required packages:
```r
install.packages(c("plumber", "ggplot2", "jsonlite"))
```

### Prolog (SWI-Prolog)
1. Download the installer from [swi-prolog.org](https://www.swi-prolog.org/download/stable)
2. Run the installer and check "Add swipl to PATH"
3. Install required libraries from Command Prompt:
```cmd
swipl -g "pack_install(http)" -t halt
```

### C/C++ (for C server)
1. Download and install Visual Studio Community Edition with C++ workload
2. Download CMake from [cmake.org](https://cmake.org/download/)
3. Build the C server:
```cmd
mkdir build
cd build
cmake ..
cmake --build . --config Release
```

### C# (.NET)
1. Download and install .NET SDK from [dotnet.microsoft.com](https://dotnet.microsoft.com/download)
2. Verify installation in Command Prompt:
```cmd
dotnet --version
```

### Java
1. Download JDK from [Oracle](https://www.oracle.com/java/technologies/downloads/) or OpenJDK
2. Run the installer and follow the prompts
3. Add JAVA_HOME to environment variables:
   - Right-click "This PC" and select "Properties"
   - Click "Advanced system settings" → "Environment Variables"
   - Add new system variable: JAVA_HOME = C:\Program Files\Java\jdk-17 (adjust path as needed)
   - Add %JAVA_HOME%\bin to the Path variable

## Step 3: Install LLM Servers

### LightLLM
```cmd
pip install lightllm

# Download models (example)
mkdir models\lightllm
cd models\lightllm
# Use PowerShell to download model
powershell -Command "Invoke-WebRequest -Uri https://huggingface.co/models/example-model/resolve/main/model.bin -OutFile model.bin"
```

### Ollama
1. Download Ollama from [ollama.com](https://ollama.com/download)
2. Run the installer
3. Pull a model from Command Prompt:
```cmd
ollama pull llama2
```

### vLLM
```cmd
pip install vllm

# Required for GPU support
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

## Step 4: Install SQL and Backend Services

### SQLite
1. Download SQLite tools from [sqlite.org](https://www.sqlite.org/download.html)
2. Extract to a folder (e.g., C:\sqlite) and add to PATH
3. Set up Node.js SQLite server:
```cmd
mkdir C:\excis\servers\sqlite
cd C:\excis\servers\sqlite
npm init -y
npm install sqlite3 express body-parser
```

### PostgreSQL
1. Download and install PostgreSQL from [postgresql.org](https://www.postgresql.org/download/windows/)
2. During installation:
   - Remember the password for 'postgres' user
   - Keep default port (5432)
3. After installation, open pgAdmin and create:
   - A new user: 'excis' with password 'excispass'
   - A new database: 'excisdb' with owner 'excis'
4. Set up Node.js PostgreSQL server:
```cmd
mkdir C:\excis\servers\postgresql
cd C:\excis\servers\postgresql
npm init -y
npm install pg express body-parser
```

### MySQL
1. Download and install MySQL from [mysql.com](https://dev.mysql.com/downloads/installer/)
2. During installation:
   - Choose "Developer Default" setup type
   - Remember the root password
3. After installation, open MySQL Workbench and run:
```sql
CREATE USER 'excis'@'localhost' IDENTIFIED BY 'excispass';
GRANT ALL PRIVILEGES ON *.* TO 'excis'@'localhost';
CREATE DATABASE excisdb;
```
4. Set up Node.js MySQL server:
```cmd
mkdir C:\excis\servers\mysql
cd C:\excis\servers\mysql
npm init -y
npm install mysql2 express body-parser
```

### Supabase Integration
1. Set up Supabase Node.js server:
```cmd
mkdir C:\excis\servers\supabase
cd C:\excis\servers\supabase
npm init -y
npm install express body-parser @supabase/supabase-js dotenv
```

2. Create a Supabase server script (supabase_server.js):
```javascript
const express = require('express');
const bodyParser = require('body-parser');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
app.use(bodyParser.json());

// Create Supabase client in execute function to use fresh credentials each time
const createSupabaseClient = (url, key) => {
  return createClient(url, key);
};

app.post('/execute', async (req, res) => {
  const code = req.body.code || '';
  const params = req.body.params || {};
  
  try {
    // Get Supabase credentials from params or environment variables
    const supabaseUrl = params.supabaseUrl || process.env.SUPABASE_URL;
    const supabaseKey = params.supabaseKey || process.env.SUPABASE_KEY;
    
    if (!supabaseUrl || !supabaseKey) {
      throw new Error('Supabase URL and key are required');
    }
    
    // Create Supabase client
    const supabase = createSupabaseClient(supabaseUrl, supabaseKey);
    
    // Prepare execution context with Supabase client
    const executeFunction = new Function(
      'supabase',
      'params',
      `
        return (async () => {
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
            return { error: e.message, stack: e.stack };
          }
        })();
      `
    );
    
    // Execute the code
    const result = await executeFunction(supabase, params);
    
    if (result.error) {
      res.json({
        status: 'error',
        error: result.error,
        stack: result.stack
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
      error: e.message,
      stack: e.stack
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

const PORT = 5030;
app.listen(PORT, '127.0.0.1', () => {
  console.log(`Supabase server listening on port ${PORT}`);
});
```

3. Create a .env file with your Supabase credentials:
```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_KEY=your-supabase-api-key
```

## Step 5: Set Up Language Server Scripts

Create the necessary server scripts for each language in their respective directories. Below are examples for key languages:

### Python Server (server.py)
```python
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
        # Prepare environment with parameters
        local_vars = {**params}
        
        # Capture stdout and stderr
        stdout = io.StringIO()
        stderr = io.StringIO()
        
        # Execute code in isolated environment
        with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
            exec(code, {}, local_vars)
        
        # Get result from the last expression or 'result' variable if exists
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
    # Graceful shutdown
    import threading
    threading.Thread(target=lambda: uvicorn.Server.should_exit()).start()
    return {"status": "shutting down"}

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=5001)
```

### Node.js Server (server.js)
```javascript
const express = require('express');
const bodyParser = require('body-parser');
const app = express();

app.use(bodyParser.json());

app.post('/execute', (req, res) => {
  const code = req.body.code || '';
  const params = req.body.params || {};
  
  try {
    // Create a context with the provided parameters
    const context = { ...params };
    
    // Prepare a function to execute the code with the context
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
    
    // Execute the code
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

app.listen(5002, '127.0.0.1', () => {
  console.log('Node.js server listening on port 5002');
});
```

### Julia Server (server.jl)
```julia
using HTTP
using JSON

function execute_code(code, params)
    try
        # Create a module to execute code in isolation
        mod = Module()
        
        # Add parameters to module
        for (key, value) in params
            Core.eval(mod, Meta.parse("$key = $(JSON.json(value))"))
        end
        
        # Capture stdout and stderr
        stdout_original = stdout
        stderr_original = stderr
        (rd_out, wr_out) = redirect_stdout()
        (rd_err, wr_err) = redirect_stderr()
        
        # Execute code
        result = Core.eval(mod, Meta.parse(code))
        
        # Collect output
        flush(wr_out)
        flush(wr_err)
        stdout_text = String(take!(rd_out))
        stderr_text = String(take!(rd_err))
        
        # Restore stdout and stderr
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

# Create HTTP server
server = HTTP.Server()

# Define routes
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

# Start server
HTTP.serve(server, "127.0.0.1", 5003)
```

## Step 6: Create Server Startup Script

Create a PowerShell script to start all language servers:

```powershell
# start_servers.ps1

# Function to start a process
function Start-ServerProcess {
    param (
        [string]$WorkingDir,
        [string]$Command,
        [string]$Arguments,
        [string]$ServerName
    )
    
    Write-Host "Starting $ServerName server..."
    $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
    $ProcessInfo.FileName = $Command
    $ProcessInfo.Arguments = $Arguments
    $ProcessInfo.WorkingDirectory = $WorkingDir
    $ProcessInfo.CreateNoWindow = $false
    $ProcessInfo.UseShellExecute = $true
    
    $Process = New-Object System.Diagnostics.Process
    $Process.StartInfo = $ProcessInfo
    $Process.Start() | Out-Null
    Write-Host "$ServerName server started with PID: $($Process.Id)"
}

# Start Ring-managed servers
$ExcisDir = "C:\excis"
Start-ServerProcess -WorkingDir $ExcisDir -Command "ring" -Arguments "stzExterServer.ring" -ServerName "EXCIS Manager"

# OR start individual servers manually:
# Python
Start-ServerProcess -WorkingDir "C:\excis\servers\python" -Command "python" -Arguments "server.py" -ServerName "Python"

# Node.js
Start-ServerProcess -WorkingDir "C:\excis\servers\nodejs" -Command "node" -Arguments "server.js" -ServerName "Node.js"

# Julia
Start-ServerProcess -WorkingDir "C:\excis\servers\julia" -Command "julia" -Arguments "server.jl" -ServerName "Julia"

# R
Start-ServerProcess -WorkingDir "C:\excis\servers\r" -Command "Rscript" -Arguments "plumber.R" -ServerName "R"

# Prolog
Start-ServerProcess -WorkingDir "C:\excis\servers\prolog" -Command "swipl" -Arguments "-s server.pl" -ServerName "Prolog"

# C Server
Start-ServerProcess -WorkingDir "C:\excis\servers\c" -Command "C:\excis\servers\c\c_server.exe" -Arguments "" -ServerName "C"

# C# Server
Start-ServerProcess -WorkingDir "C:\excis\servers\csharp" -Command "dotnet" -Arguments "run" -ServerName "C#"

# Java Server
Start-ServerProcess -WorkingDir "C:\excis\servers\java" -Command "java" -Arguments "-jar excis-java.jar" -ServerName "Java"

# LLM Servers
Start-ServerProcess -WorkingDir "C:\excis\servers\lightllm" -Command "python" -Arguments "lightllm_server.py" -ServerName "LightLLM"

Start-ServerProcess -WorkingDir "C:\excis\servers\ollama" -Command "ollama" -Arguments "serve" -ServerName "Ollama"

Start-ServerProcess -WorkingDir "C:\excis\servers\vllm" -Command "python" -Arguments "vllm_server.py" -ServerName "vLLM"

# SQL Servers
Start-ServerProcess -WorkingDir "C:\excis\servers\sqlite" -Command "node" -Arguments "sqlite_server.js" -ServerName "SQLite"

Start-ServerProcess -WorkingDir "C:\excis\servers\postgresql" -Command "node" -Arguments "postgresql_server.js" -ServerName "PostgreSQL"

Start-ServerProcess -WorkingDir "C:\excis\servers\mysql" -Command "node" -Arguments "mysql_server.js" -ServerName "MySQL"

# Supabase Server
Start-ServerProcess -WorkingDir "C:\excis\servers\supabase" -Command "node" -Arguments "supabase_server.js" -ServerName "Supabase"

Write-Host "All servers started."
```

Set the execution policy to allow running the script (run PowerShell as Administrator):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```



## Step 8: Test the System

1. Start the servers using the PowerShell script:
   ```powershell
   .\start_servers.ps1
   ```

2. Create a test script:
   ```ring
   # test_excis.ring
   load "stzExterServer.ring"

   # Create an instance of the server manager
   excisMgr = new stzExterServer()

   # Check health of all servers 
   See "Server Health Status:" + nl
   health = excisMgr.getAllServersHealth()
   for server in health.keys()
       See server + ": " + (health[server] ? "Healthy" : "Not Responding") + nl
   next

   # Test Python execution
   See "Testing Python execution..." + nl
   pyResult = excisMgr.executeCode("python", "
   import math
   result = math.sqrt(16)
   print('Square root calculated!')
   ", {})

   See "Python result: " + pyResult["result"] + nl
   See "Python stdout: " + pyResult["stdout"] + nl

   # Test Node.js execution
   See "Testing Node.js execution..." + nl
   jsResult = excisMgr.executeCode("nodejs", "
   const data = [1, 2, 3, 4, 5];
   const sum = data.reduce((a, b) => a + b, 0);
   console.log('Sum calculated!');
   result = sum;
   ", {})

   See "Node.js result: " + jsResult["result"] + nl
   See "Node.js stdout: " + jsResult["stdout"] + nl

   # Test Supabase integration
   See "Testing Supabase integration..." + nl
   supabaseResult = excisMgr.executeCode("supabase", "
   // Create a new user
   const { data, error } = await supabase.auth.signUp({
     email: 'test@example.com',
     password: 'password123'
   });
   result = data;
   ", {})

   See "Supabase result: " + supabaseResult["result"] + nl

   # Shut down all servers when done
   excisMgr.shutdown()
   ```

3. Run the test from Command Prompt:
   ```cmd
   ring test_excis.ring
   ```

## Step 9: Set Up as a Windows Service (Optional)

For production environments, you'll want to set up the servers as Windows services:

### Using NSSM (Non-Sucking Service Manager)

1. Download NSSM from [nssm.cc](https://nssm.cc/download)
2. Extract the zip file and open Command Prompt as Administrator
3. Navigate to the NSSM directory and use the appropriate version (32 or 64 bit):

```cmd
cd C:\path\to\nssm\win64
nssm install EXCIS
```

4. In the NSSM interface:
   - For "Path", browse to the PowerShell executable (usually `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`)
   - For "Arguments", enter `-ExecutionPolicy Bypass -File "C:\path\to\excis\start_servers.ps1"`
   - For "Working directory", enter `C:\path\to\excis`
   - In the "Details" tab, provide a description
   - Click "Install service"

5. Start the service:
```cmd
nssm start EXCIS
```

## Troubleshooting

### Server Won't Start
- Check if the port is already in use: `sudo lsof -i :5001`
- Verify all dependencies are installed
- Check server log files in the logs directory

### Connection Issues
- Ensure all servers are running: `ps aux | grep server`
- Verify firewall settings: `sudo ufw status`
- Check the health endpoint manually: `curl http://127.0.0.1:5001/health`

### Execution Errors
- Examine server-specific logs
- Increase timeout values in the stzExterServer.ring file
- Check for memory limitations or resource constraints

## Security Considerations

- **Network Security**: By default, servers listen only on localhost (127.0.0.1)
- **Code Isolation**: Consider using Docker containers for each language server
- **Authentication**: Implement API keys or tokens for production use
- **Resource Limits**: Set memory and CPU limits for each server

## Performance Optimization

- Increase or decrease the number of servers based on your hardware
- Adjust timeout values in stzExterServer.ring for long-running operations
- Consider using process managers like PM2 for Node.js servers

## Next Steps

1. Explore the examples in the documentation
2. Create custom language integrations
3. Build applications using multiple languages
4. Implement monitoring and logging solutions

Congratulations! You have successfully set up the stzExterServer system. You can now build powerful polyglot applications that leverage the strengths of multiple programming languages, LLMs, and SQL databases.