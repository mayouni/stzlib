# Softanza's System Call Augmentation: Built on Qt's QProcess

## Motivation

Ring's native `system()` function works well for basic cross-platform command execution. Softanza enhances this foundation through `stzsystem()` function adn `stzSystemCall` class , leveraging RingQt's `QProcess` for:

* **Performance**: Qt's optimized process management and I/O handling
* **Configurability**: Fine-grained control over execution, timeouts, and output capture
* **Programmer Experience**: Natural syntax, automatic shell handling, and rich error information

## Core Enhancement: Natural Command Syntax

`stzsystem()` accepts commands as you'd type them in a terminal:

```ring
? stzsystem("echo Hello")           #--> Hello
? stzsystem("dir systest/")         #--> (file listing)
? stzsystem("date /t")              #--> Current date
```

**Automatic Shell Intelligence** Detects when commands need shell interpretation (pipes, redirects, operators) and wraps appropriately:

```ring
? stzsystem("dir | findstr .txt")   # Auto: cmd.exe /c
? stzsystem("echo test && dir")     # Chains work seamlessly
```

**Path Flexibility** Forward or backslashes work on any OS, with smart flag preservation:

```ring
? stzsystem("dir systest/")         # / → \ on Windows
? stzsystem("date /t")              # /t flag preserved
```

**Return Type Specification** Append `@RETURN:type` to automatically convert output to the desired type:

```ring
# String output (default)
? stzsystem("echo test")
#--> "test"

# List output - splits into lines
oCall = new stzSystemCall("dir /B @RETURN:list")
oCall.Run()
? oCall.Output()
#--> ["file1.txt", "file2.txt", "folder"]

# Number output - extracts first numeric value
oCall = new stzSystemCall("echo 42 @RETURN:number")
oCall.Run()
? oCall.Output()
#--> 42
```

The uppercase `@RETURN:` keyword is visually distinct from the command string, making intent clear at a glance.

## Advanced Control: The stzSystemCall Class

For complex scenarios requiring configuration:

```ring
oCall = new stzSystemCall("systeminfo")
oCall {
    SetTimeout(5000)
    HideConsole()
    CaptureOutput()
    Run()
    
    ? "Success: " + Succeeded()
    ? "Data: " + Output()
    ? "Exit code: " + ExitCode()
}
```

**Execution Control**

```ring
oCall = StzSystemCallQ("long-task")
oCall {
    SetTimeout(30000)      # 30 seconds
    ShowConsole()          # Visible progress
    DontCaptureError()     # Ignore stderr
    Run()
}
```

**Parameter Templates**

```ring
oCall = new stzSystemCall(Sys(:CopyFile))
oCall.SetParams([
    [:source, "file1.txt"],
    [:dest, "backup/file1.txt"]
])
oCall.Run()
```

**Reusable Objects**

```ring
oCall = new stzSystemCall("cmd.exe")

# First task
oCall.SetArgs(["/c", "echo", "Task 1"])
oCall.Run()

# Reset and reuse
oCall.Reset()
oCall.SetArgs(["/c", "dir"])
oCall.Run()
```

## Cross-Platform Abstraction: Sys() Commands

`stzSystemCallData.ring` provides 30+ unified commands that work identically across Windows, macOS, and Linux, and callable simply by the small `Sys()` function:

```ring
# Same code, any OS
? stzsystem(Sys(:CurrentDir))       #--> /home/user or C:\Users\...
? stzsystem(Sys(:SystemInfo))       #--> Platform-appropriate details

oCall = new stzSystemCall(Sys(:ListFiles))
oCall.Run()
acFiles = oCall.Output()            #--> Auto-typed as list
```

Each `Sys()` command includes:

* Platform-specific implementations
* Parameter definitions
* Return type annotations
* Human-readable descriptions

## Type-Aware Returns

Sys() commands include `@RETURN:` internally so the output is returned in the correct type:
:

```ring
# Returns list
oCall = new stzSystemCall(Sys(:ListFiles))
oCall.Run()
acFiles = oCall.Output()  # Already a list

# Returns number
oCall = new stzSystemCall(Sys(:CountLines))
oCall.SetParam(:file, "data.txt")
oCall.Run()
nLines = oCall.Output()   # Already a number
```

## Rich Error Information

```ring
oCall = StzSystemCallQ("cmd.exe")
oCall.WithArgs(["/c", "type", "missing.txt"])
oCall.Run()

? oCall.Succeeded()     #--> FALSE
? oCall.Failed()        #--> TRUE
? oCall.ExitCode()      #--> 1
? oCall.Error()         #--> Full error message
? oCall.HasOutput()     #--> TRUE/FALSE
```

## Technical Implementation

**Shell Detection** (`UseShellIfNeeded()`)

* Scans for operators: `|`, `>`, `<`, `&&`, `||`, `&`
* Recognizes 40+ built-in commands (`echo`, `cd`, `if`, `for`, etc.)
* Wraps in `cmd.exe /c` (Windows) or `sh -c` (Unix) when needed

**Path Normalization** (`NormalizePathsInCommand()`)

* Converts path separators contextually
* Preserves command flags (`/t`, `/s`, `/b`)
* OS-aware transformation

**Qt's QProcess Benefits**

* Efficient process lifecycle management
* Asynchronous I/O with timeout control
* Separate stdout/stderr capture
* Environment variable handling

## Fluent API Design

Method chaining for readable configuration:

```ring
StzSystemCallQ("git").
    WithArgsQ(["status"]).
    SetTimeoutQ(5000).
    HideConsoleQ().
    RunQ().
    Output()
```

## Usage Patterns

**Quick one-liners:**

```ring
? stzsystem("whoami")
```

**Configured execution:**

```ring
oCall = new stzSystemCall("ffmpeg")
oCall.SetArgs(["-i", "video.mp4", "output.avi"])
oCall.SetTimeout(60000)
oCall.Run()
```

**Silent background tasks:**

```ring
StzSystemCallQ("backup-script").RunSilently()
```

**Platform-agnostic operations:**

```ring
oCall = new stzSystemCall(Sys(:MakeDir))
oCall.SetParam(:path, "project/logs")
oCall.Run()
```

## Extensibility

Add custom commands to `$aStzSystemCommands`:

```ring
$aStzSystemCommands + [
    :GitStatus = [
        :windows = ["git", ["status"]],
        :unix = ["git", ["status"]],
        :description = "Check git repository status",
        :ReturnType = "string"
    ]
]
```

## Summary

Softanza augments Ring's system interaction with:

* Natural command syntax with automatic shell handling
* Comprehensive execution control and configuration
* Type-safe, cross-platform command abstractions
* Rich error handling and output management
* Qt-powered performance and reliability

The three-layer approach serves different needs: `stzsystem()` for simplicity, `stzSystemCall` for control, and `Sys()` for portability.
