# Natural Folder Navigation in Softanza

## The Core Principle

In Softanza, **your mental location follows your actions**. When you perform an operation in a folder, the system naturally updates your current position to reflect where you just worked. This eliminates the cognitive overhead of manually tracking your location.

## How It Works

Think of working in a real office. When you walk to the filing cabinet to create a new folder, you're naturally "at" the filing cabinet afterward:

Here's how this natural navigation works in practice:

```ring
# Start at your project root
oFolder = new stzFolder("/my-project")
? oFolder.CurrentPath()  
#--> "/my-project/"

# Create a source folder
oFolder.CreateFolder("src")
? oFolder.CurrentPath()  
#--> "/my-project/src/"

# Create a file - it goes in your current location
oFolder.CreateFile("main.ring")

# Create nested folders
oFolder.CreateFolder("components/ui")
? oFolder.CurrentPath()  
#--> "/my-project/src/components/ui/"
```

When you perform an action somewhere, that becomes your new "here."

## Explicit Navigation When Needed

You can always navigate explicitly when required:

Here are the explicit navigation methods available:

```ring
oFolder = new stzFolder("/my-project")

# Explicit navigation methods
oFolder.GoTo("src/components")          # Navigate to specific path
oFolder.GoUp()                          # Move up one level  
oFolder.GoHome()                        # Return to original folder
oFolder.GoBack()                        # Return to previous location

# Check your location
? oFolder.CurrentPath()                 # Current working directory
? oFolder.IsAtHome()                    # Are we at the original folder?

# Navigation history and context
? oFolder.PathHistory()                 # See where you've been
? oFolder.NavigationInfo()              # Complete navigation state
```

### Combining Both Approaches

This example shows how natural and explicit navigation work together seamlessly:

```ring
oFolder = new stzFolder("/webapp")

# Natural navigation through actions
oFolder.CreateFolder("api/users")       # Now in: /webapp/api/users/
oFolder.CreateFile("controller.ring")   # Creates in current location

# Explicit navigation when needed
oFolder.GoTo("../products")             # Move to: /webapp/api/products/
oFolder.CreateFile("controller.ring")   # Creates in current location

# Use history to return
oFolder.GoBack()                        # Back to: /webapp/api/users/
```

## Natural vs Classical Navigation

Standard Ring file operations, like all other languages, require constant manual path management:

```ring
# Standard Ring - explicit navigation everywhere

# Create src directory
if not direxists("/my-project/src")
    # Ring requires explicit path construction
    system("mkdir /my-project/src")
ok
write("/my-project/src/main.ring", "# Main file")

# Manual path construction for each operation
if not direxists("/my-project/docs")
    system("mkdir /my-project/docs")
ok
write("/my-project/docs/README.md", "# Documentation")
```

Softanza's natural navigation follows your actions:

```ring
# Softanza - location follows intent
oFolder = new stzFolder("/my-project")
oFolder {}
	CreateFolder("src")          # Now in: /my-project/src/
	CreateFile("main.ring")      # Creates in current location

	CreateFolder("docs")         # Now in: /my-project/docs/  
	CreateFile("README.md")      # Creates in current location
}
```

The key difference: **action first, then navigation** vs. **navigate first, then action**.

## Navigation Patterns by Operation Type

Different operations have intuitive navigation behaviors:

### Creation Operations

Creating folders and files automatically moves you to their location:

```ring
oFolder.CreateFolder("api/routes")     # Navigate to: /webapp/api/routes/
oFolder.CreateFile("users.ring")       # Navigate to: /webapp/api/routes/
```

### File Operations

File operations position you at the target location:

```ring
oFolder.FileRead("data/users.json")    # Navigate to: /webapp/data/
oFolder.FileCopy("src/app.ring", "backup/app.ring")    # Navigate TO: /webapp/backup/
```

### Deletion Operations

Deletion operations naturally handle where you end up:

```ring
oFolder.DeleteFolder("old-version")    # Navigate to: parent folder
oFolder.DeleteFile("temp.log")         # Navigate to: file's containing folder
```

## Batch Mode: Multiple Operations Without Moving

When you need to perform multiple operations across different locations without losing your mental position:

```ring
oFolder = new stzFolder("/my-project")

# Enter batch mode
oFolder.SetBatchMode(TRUE)

# Create various folders without moving your mental location
oFolder.CreateFolders([
	"temp/cache",
	"logs/debug", 
	"config/themes"
])

oFolder.CreateFiles([
	"docs/changelog.md",
	"src/main.ring"
])

# Your location hasn't changed!
? oFolder.CurrentPath()  
#--> "/my-project/"

# Exit batch mode - natural navigation resumes
oFolder.SetBatchMode(FALSE)
oFolder.CreateFolder("src")
? oFolder.CurrentPath()  
#--> "/my-project/src/"
```

## Practical Example: Project Setup

Here's how natural navigation simplifies setting up a web project structure:

```ring
# Setting up a web project structure
oFolder = new stzFolder("/webapp")
oFolder {
	CreateFolder("public/css")      # Now in: /webapp/public/css/
	CreateFile("styles.css")        # Creates in current location

	CreateFolder("js")              # Now in: /webapp/public/js/
	CreateFile("app.js")            # Creates in current location

	GoHome()                        # Back to: /webapp/
	CreateFolder("server/routes")   # Now in: /webapp/server/routes/
}
```

## Error Handling and Safety

Softanza includes built-in safety measures for navigation:

```ring
oFolder = new stzFolder("/mycontent")

# Cannot navigate outside the folder boundary
oFolder.CreateFolder("../system")      # Raises error: "Can't navigate outside the folder!"

# File operations validate existence before navigation
oFolder.FileRead("missing.txt")        # Raises error: "cFile does not exist in the folder."

# Deletion operations handle edge cases gracefully
# (Assuming /mycontent/docs/) exists
oFolder.DeleteFolder("docs")           # Safely navigates to parent /mycontent/ after deletion
```

## The Result

You spend less mental energy tracking where you are and more energy focused on what you're building. The system becomes an extension of your intent, automatically maintaining context as you work. Your code reads naturally, your mental model stays clear, and folder operations feel as intuitive as thinking about them.
