# Softanza's stzFolder: A Journey Through Intelligent Directory Navigation

## Introduction

This article examines the `stzFolder` class from the Softanza library for Ring, demonstrating its directory navigation capabilities through practical examples. We'll explore the class's visual representation features, expansion controls, statistical displays, and state management. The analysis includes a comparison with other directory handling frameworks to highlight distinctive approaches.

The examples follow a sequential workflow, showing how the class handles basic display, customization, selective expansion, and comprehensive tree exploration.

## Starting Simple: Visual Tree Structure

We begin by creating a folder object and immediately see Softanza's visual philosophy in action:

```ring
o1 = new stzFolder("c:/testarea")
? o1.Show()
```
Output:
```
🗀 testarea
├─ 🗋 test.txt
├─🗀 docs
├─🖿 images
├─🗀 music
├─🖿 tempo
╰─🗀 videos
```

The output uses Unicode symbols to indicate file types and folder states: `🗋` for files, `🗀` for empty folders, and `🖿` for folders containing items.

## Enhanced Mode: Statistics That Matter

The `ShowXT()` method reveals another layer of thoughtful design:

```ring
? o1.ShowXT()
```
Output:
```
📁 testarea (6)
├─ 🗋 test.txt
├─🗀 Docs
├─🖿 images (4)
├─🗀 music
├─🖿 tempo (2)
╰─🗀 videos
```

The XT mode switches to a folder icon (📁) and adds numerical counts showing elements at each level. The root contains 6 elements total, while subfolders like images (4) and tempo (2) display their own counts. The statistics follow a default pattern, but Softanza's flexibility allows complete customization.

## Customization: Your Statistics, Your Way

Checking the current display pattern:

```ring
? o1.DisplayStat() + NL
#--> "@count"
```

Now let's make it more descriptive:

```ring
o1.SetDisplayStat('@CountFiles files, @CountFolders folders')
? o1.ShowXT()
```
Output:
```
📁 testarea (1 files, 5 folders)   # Your stats displayed here
├─ 🗋 test.txt
├─🗀 docs
├─🖿 images (2 files, 2 folders)   # And here
├─🗀 music
├─🖿 tempo (2 files)               # And here
╰─🗀 videos
```

The custom statistics now appear throughout the tree, providing context at each level. This customization allows the same tool to serve different analysis requirements.

## Granular Insights: Deep vs. Surface Counts

For comprehensive analysis, we can distinguish between immediate and recursive counts:

```ring
o1.SetDisplayStat('
	@CountFiles:@DeepCountFiles files,
	@CountFolders:@DeepCountFolders folders
')
? o1.ShowXT()
```
Output:
```
📁 testarea (1:7 files, 5:7 folders)
├─ 🗋 test.txt
├─🗀 docs
├─🖿 images (2:4 files, 2:2 folders)
├─🗀 music
├─🖿 tempo (2:2 files)
╰─🗀 videos
```

The notation reveals the distinction between immediate and deep counts. The main folder contains 7 files across all levels, with only 1 at the root. Similarly, it has 7 subfolders total, with 5 at the root level.

## Surgical Exploration: Targeted Expansion

Rather than overwhelming with full tree dumps, Softanza provides surgical precision:

```ring
o1.ExpandFolder("/images/")
? o1.ShowXT()
```
Output:
```
📁 testarea (1:7 files, 5:7 folders)
├─ 🗋 test.txt
├─🗀 docs
├─🗁 images (2:4 files, 2:2 folders)   # Only this folder expanded
│ ├─ 🗋 image1.png
│ ├─ 🗋 image2.png
│ ├─🗀 more
│ ╰─🖿 notes (2:2 files)               # It's subfolder are kept collapsed
├─🗀 music
├─🖿 tempo (2:2 files)
╰─🗀 videos
```

The expanded folder changes its icon to 🗁, indicating its current state. Only the images folder opens while others remain collapsed, and subfolders maintain their distinct visual indicators.

## Multi-Target Expansion: Efficiency in Action

Expanding multiple folders simultaneously demonstrates the API's practical design:

```ring
o1.ExpandFolders([ "images", "tempo" ])
? o1.Show()
```
Output:
```
🗀 testarea
├─ 🗋 test.txt
├─🗀 docs
├─🗁 images         # Expanded
│ ├─ 🗋 image1.png
│ ├─ 🗋 image2.png
│ ├─🗀 more
│ ╰─🖿 notes
├─🗀 music
├─🗁 tempo          # Also expanded
│ ├─ 🗋 temp1.txt
│ ╰─ 🗋 temp2.txt
╰─🗀 videos
```

## Stateful Intelligence: Persistent Exploration

A crucial aspect of developer experience—the library remembers your exploration state:

```ring
? o1.Show()
#--> Same output as the previous one
```

This stateful behavior preserves the exploration context across operations, eliminating the need to reconfigure display settings.

## Nested Exploration: Deep Directory Diving

For complex hierarchies, we can expand nested paths precisely:

```ring
o1.Collapse()
o1.ExpandFolders([ "/images/", "/images/notes/" ])
? o1.Show()
```
Output:
```
🗀 testarea
├─ 🗋 test.txt
├─🗀 docs
├─🗁 images         # Expanded
│ ├─ 🗋 image1.png
│ ├─ 🗋 image2.png
│ ├─🗀 more
│ ╰─🗁 notes        # Also expanded
│   ├─ 🗋 howto.txt
│   ╰─ 🗋 sources.txt
├─🗀 music
├─🖿 tempo
╰─🗀 videos
```

## Deep Expansion: Branch-Level Exploration

When you need to see everything within a specific branch:

```ring
o1.Collapse()
o1.DeepExpandFolder("Images")
? o1.Show()
```
Output:
```
🗀 testarea
├─ 🗋 test.txt
├─🗀 Docs
├─🗁 Images            # Folder expanded
│ ├─ 🗋 image1.png
│ ├─ 🗋 image2.png
│ ├─🗁 more            # As well as this (empty) subfolder
│ ╰─🗁 notes           # Idem
│   ├─ 🗋 howto.txt
│   ╰─ 🗋 sources.txt
├─🗀 Music
├─🗀 Videos
╰─🖿 tempo
```

## Complete Revelation: Full Tree Expansion

For comprehensive analysis, expand everything at once:

```ring
o1.DeepExpandAll()
? o1.ShowXT()
```
Output:
```
📁 testarea (1:7 files, 5:7 folders)
├─ 🗋 test.txt
├─🗁 docs
├─🗁 images (2:4 files, 2:2 folders)
│ ├─ 🗋 image1.png
│ ├─ 🗋 image2.png
│ ├─🗁 more
│ ╰─🗁 notes (2:2 files)
│   ├─ 🗋 howto.txt
│   ╰─ 🗋 sources.txt
├─🗁 music
├─🗁 tempo (2:2 files)
│ ├─ 🗋 temp1.txt
│ ╰─ 🗋 temp2.txt
╰─🗁 videos
```

## Visual Search: Finding Files with Context

Softanza extends beyond navigation to include visual search capabilities:

```ring
? o1.VizSearch("*.txt")
```
Output:
```
🗀 testarea (🎯 1 matches for '*.txt') # We've got 1 file at the root
├─ 🗋👉 test.txt
├─🗀 docs
├─📂 images  # May contain matches search covers only the root!
├─🗀 music
├─📂 tempo   # Idem, see next section for searching deep in the tree...
╰─🗀 videos
```

The search results maintain the tree structure while highlighting matches with the pointing finger icon (👉) and adding a target emoji (🎯) in the statistics.

## Deep Search: Comprehensive File Discovery

For searches across the entire directory hierarchy we add `Deep` to the search method:

```ring
? o1.VizDeepSearch("*.txt")
```
Output:
```
🗀 testarea (🎯5 matches for '*.txt')
├─ 🗋👉 test.txt	
├─🗀 docs
├─📂 images (2)
│ ├─ 🗋 image1.png
│ ├─ 🗋 image2.png
│ ├─🗀 more
│ ╰─📂 notes (2)
│   ├─ 🗋👉 howto.txt
│   ╰─ 🗋👉 sources.txt
├─🗀 music
├─📂 tempo (2)
│ ├─ 🗋👉 temp1.txt
│ ╰─ 🗋👉 temp2.txt
╰─🗀 videos
```

The deep search reveals all matching files throughout the hierarchy, automatically expanding necessary folders and highlighting each match. The statistics update to show the total count across all levels.

> **Note:** All `VizSearch` methods also work without the `Viz` prefix, in which case they return a simple list of paths. This behavior will be covered in a separate article.

## Clean Reset: Back to Beginning

When exploration is complete, easily return to the initial state:

```ring
o1.CollapseAll()
? o1.ShowXT()
```
Output:
```
📁 testarea (1:7 files, 5:7 folders)
├─ 🗋 test.txt
├─🗀 docs
├─🖿 images (2:4 files, 2:2 folders)
├─🗀 music
├─🖿 tempo (2:2 files)
╰─🗀 videos
```

## The Softanza Advantage

Softanza's approach to directory navigation stands apart from conventional file system tools:

| Feature | Softanza stzFolder | Node.js fs | Python pathlib | Java Files API | .NET DirectoryInfo |
|---------|-------------------|------------|----------------|-----------------|-------------------|
| **Visual Feedback** | Unicode icons (🗀🖿🗁) | None | None | None | None |
| **Stateful Exploration** | Maintains expansion state | Stateless | Stateless | Stateless | Stateless |
| **Customizable Statistics** | Flexible patterns (@CountFiles:@DeepCountFiles) | Manual calculation | Manual calculation | Manual calculation | Basic properties |
| **Selective Expansion** | Single/multiple/recursive control | Manual traversal | Manual traversal | Manual traversal | Manual traversal |
| **Dual Count Display** | Surface:total notation (1:7 files) | Single level only | Single level only | Single level only | Single level only |
| **Method Naming** | Intuitive (Show(), ShowXT()) | Verbose (readdir, readdirSync) | Mixed (iterdir, glob) | Verbose (list, walk) | Mixed (GetFiles, GetDirectories) |
| **Case Handling** | Automatic normalization | OS-dependent | OS-dependent | OS-dependent | OS-dependent |
| **Tree Visualization** | Built-in formatted output | Manual formatting | Manual formatting | Manual formatting | Manual formatting |
| **Visual Search** | Integrated search with highlighting (👉) | Separate search utilities | Separate search utilities | Separate search utilities | Separate search utilities |

> **Note**: The `stzFolder` class also provides comprehensive file and folder management operations including add, append, delete, move, copy, and content search functionality, which will be covered in a separate article.

## Summary

This examination of `stzFolder` demonstrates its approach to directory navigation through visual representation, flexible statistics, selective expansion controls, and persistent state management. The class provides built-in tree visualization with customizable display patterns, distinguishing it from standard file system APIs that require manual formatting and traversal logic.