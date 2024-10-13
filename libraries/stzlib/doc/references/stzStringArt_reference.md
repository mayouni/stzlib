# StringArt function and stzStringArt class reference

## Introduction

This document provides a comprehensive reference for the `StringArt` function and the `stzStringArt` class, which are used to create and manipulate string art representations of text in the Softanza library.

## Quick Reference

| Name | Type | Description | Since Version |
|------|------|-------------|---------------|
| [StringArt(str)](#stringart) | Function | Creates string art representation of text | 1.0 |
| [stzStringArt](#stzstringart-class) | Class | Class for creating and manipulating string art | 1.0 |
| [Content()](#content) | Method | Returns the original content string | 1.0 |
| [Style()](#style) | Method | Returns the current string art style | 1.0 |
| [SetStyle(cStyle)](#setstylecstyle) | Method | Sets the string art style | 1.0 |
| [Artify()](#artify) | Method | Converts the content to string art representation | 1.0 |
| [Boxify()](#boxify) | Method | Creates a boxed version of the string art representation | 1.0 |
| [StringArtStyles()](#stringartstyles) | Function | Returns available string art styles | 1.0 |
| [IsStringArtStyle(str)](#isstringartstylestr) | Function | Checks if a string is a valid art style | 1.0 |
| [DefaultStringArtStyle()](#defaultstringartstyle) | Function | Returns the default string art style | 1.0 |
| [SetDefaultStringArtStyle(cStyle)](#setdefaultstringartstylecstyle) | Function | Sets the default string art style | 1.0 |

## StringArt

### Basic Information

`StringArt(str)` is a function that creates string art representations of text.

### Details

- Accepts a string as input
- Returns a string art representation of the input
- Uses the default string art style (can be changed using `SetDefaultStringArtStyle`)
- Supports a special syntax for string art paintings: `StringArt("#{PaintingName}")`

### Examples

```ring
? StringArt("Hello")
```
Output:
```ring
██░░░██ ███████ ██░░░░░ ██░░░░░ ░▄███▄░
██░░░██ ██░░░░░ ██░░░░░ ██░░░░░ ██▀░▀██
███████ █████░░ ██░░░░░ ██░░░░░ ██░░░██
██░░░██ ██░░░░░ ██░░░░░ ██░░░░░ ██▄░▄██
██░░░██ ███████ ███████ ███████ ░▀███▀░ 
```

```ring
? StringArt("#{Tree}")
```
Output:
```
    🍃
   🍃🍃
  🍃🍃🍃
 🍃🍃🍃🍃
🍃🍃🍃🍃🍃
    ┃━┃
    ┃━┃
```

### Options

- The default style can be changed using `SetDefaultStringArtStyle(cStyle)`

Example:
``ring
SetDefaultStringArtStyle(:neon)
``

### Related Functions

- `StringArtBoxified(str)`: Creates a boxed string art representation
- `CharArtLayers(c)`: Returns a list f strings representing the layers for a single character in string art (used internally by `StringArt()` function)

Example 1:
```ring
? StringArtBoxified("HELLO")
```
Output:
```
╭─────────────────────────────────────────╮
│ ██░░░██ ███████ ██░░░░░ ██░░░░░ ░▄███▄░ │
│ ██░░░██ ██░░░░░ ██░░░░░ ██░░░░░ ██▀░▀██ │
│ ███████ █████░░ ██░░░░░ ██░░░░░ ██░░░██ │
│ ██░░░██ ██░░░░░ ██░░░░░ ██░░░░░ ██▄░▄██ │
│ ██░░░██ ███████ ███████ ███████ ░▀███▀░ │
╰─────────────────────────────────────────╯
```

Example 2:
```ring
? CharArtLayers("R")
```
Output:
```
[
	"███▄▄░░",
	"██░░░██",
	"███▄▄░░",
	"██░▀██░",
	"██░░░██"
]
```


## stzStringArt Class

### Basic Information

`stzStringArt` is a class for creating and manipulating string art representations of text.

### Constructor

```ring
new stzStringArt(str)
```

- `str`: The input string to be converted to string art

### Public Methods

#### Content()

Returns the original content string.

#### Style()

Returns the current string art style.

Example:
```ring
oArt = new stzStringArt("Hi!")
? oArt.Style()
```
Output:
```ring
retro
```

#### SetStyle(cStyle)

Sets the string art style.

- `cStyle`: The name of the style to set (must be a valid style from `StringArtStyles()`)

Example:
```ring
oArt = new stzStringArt("Hi!")
oArt.SetStyle(:flower)
? oArt.Style()
```
Output:
```ring
flower
```


#### Artify()

Converts the content to string art representation.

Example:
```ring
oArt = new stzStringArt("Ring")
? oArt.SetStyle(:flower)
? oArt.Artify()
```
Output:
```ring
.-------.     .-./`)  ,---.   .--.   .-_'''-.   
|  _ _   \    \ .-.') |    \  |  |  '_( )_   \  
| ( ' )  |    / `-' \ |  ,  \ |  | |(_ o _)|  ' 
|(_ o _) /     `-'`'` |  |\_ \|  | . (_,_)/___| 
| (_,_).' __   .---.  |  _( )_\  | |  |  .-----.
|  |\ \  |  |  |   |  | (_ o _)  | '  \  '-   .'
|  | \ `'   /  |   |  |  (_,_)\  |  \  `-'`   | 
|  |  \    /   |   |  |  |    |  |   \        / 
''-'   `'-'    '---'  '--'    '--'    `'-...-'
```


#### Boxify()

Creates a boxed version of the string art representation.

Example:
```ring
oArt = new stzStringArt("Ring")
? oArt.SetStyle(:flower)
? oArt.Artify()
```
Output:
```ring
╭──────────────────────────────────────────────────╮
│ .-------.     .-./`)  ,---.   .--.   .-_'''-.    │
│ |  _ _   \    \ .-.') |    \  |  |  '_( )_   \   │
│ | ( ' )  |    / `-' \ |  ,  \ |  | |(_ o _)|  '  │
│ |(_ o _) /     `-'`'` |  |\_ \|  | . (_,_)/___|  │
│ | (_,_).' __   .---.  |  _( )_\  | |  |  .-----. │
│ |  |\ \  |  |  |   |  | (_ o _)  | '  \  '-   .' │
│ |  | \ `'   /  |   |  |  (_,_)\  |  \  `-'`   |  │
│ |  |  \    /   |   |  |  |    |  |   \        /  │
│ ''-'   `'-'    '---'  '--'    '--'    `'-...-'   │
╰──────────────────────────────────────────────────╯``
```

## Utility Functions

### StringArtStyles()

Returns a list of available string art styles.

Example:
```ring
? StringArtStyles()
```
Output:
```ring
[ "retro", "neon", "geo", "flower" ]
```

### IsStringArtStyle(str)

Checks if the given string is a valid string art style.

Example:
```ring
? IsStringArtStyle(:flower)
```
Output:
```ring
TRUE
```

### DefaultStringArtStyle()

Returns the current default string art style.

Example:
```ring
? DefaultStringArtStyle()
```
Output:
```ring
retro
```

### SetDefaultStringArtStyle(cStyle)

Sets the default string art style.

Example:
```ring
SetDefaultStringArtStyle(:geo)
? DefaultStringArtStyle()
```
Output:
```ring
geo
```

## Data File: stzStringArtData.ring

The `stzStringArtData.ring` file contains the necessary data for StringArt functionality. It defines styles and paintings used by the `StringArt` function and `stzStringArt` class.

### Style Definitions

Styles are defined in the file using the following format:

```ring
$STZ_STRING_ART_STYLE_001 = [
    [ "A" , [
        "░▄███▄░",
        "██▀░▀██",
        "███████",
        "██░░░██",
        "██░░░██"] ],
    [ "B" , [
        "███▄▄░░",
        "██░░░██",
        "███▄▄░░",
        "██░░░██",
        "███▄▄░░"] ],
    // ... more characters
]
```

Each character is associated with an array of strings that represent its string art layers.

The variables containing the styles are gathered in a global list in stzStringArtData:

```ring
$STZ_STR_ART_STYLES_XT = [
    :retro = $STZ_STR_ART_STYLE_001,
    :neon = $STZ_STR_ART_STYLE_002,
    :geo = $STZ_STR_ART_STYLE_003,
    :flower = $STZ_STR_ART_STYLE_004
]
```

Note: If you add a new style, you should also update this list to include your new style.

### Painting Definitions

Paintings are pre-defined string art images, defined in the file like this:

```ring
$STZ_STR_ART_SNIPPERRIFLE =
"   \
 ___\__,_
[________\_____▄▄▄
[_|___|_|_____|---;"

$STZ_STR_ART_GRENADE = 
"   ,-.
  /   \
 /     \
(  ;◯   )
 \     /
  \___/"

$STZ_STR_ART_ROCKETLAUNCHER =
"
  ____
 /    \========[}
<======|________]
 \____/
"
```

These paintings can be accessed using the special syntax `StringArt("#{PaintingName}")`.

To add a new painting, simply add a new variable with a name starting with `$STZ_STR_ART_` and define your string art. The `StringArt("#{...}")` function will automatically recognize it.

Note: This feature is quite flexible. For example, if you add:

```ring
$STZ_STR_ART_MYCUSTOMART = "Your string art content here"
```

You can then use `StringArt("#{my custom art}")` with spaces, and Softanza will automatically concatenate it to match your variable name.


## Note

The "stk" prefix in file names (e.g., **stk**StringArt.ring and **stk**StringArtData.rig), with the "k" representing **SoftanzaCore**, signifies that these components belong to the foundational layer of the Softanza architecture, ensuring their accessibility to all upper levels. Consequently, loading "**stz**lib.ring" at the SoftanzaPrime level will automatically include these core files. However, if desired, you can opt to load only the SoftanzaCore layer by using "load **stk**lib.ring." This approach reduces additional features, streamlines the codebase, and is ideal for constrained environments such as the console, microcontrollers, or web applications.

For more details, see the article: *Overview of the 3 Layers of Softanza Software Architecture* (#TODO: article pending).

## See Also

For a broader understanding of string art support in Softanza, please refer to the article: [An overview of String Art support in Softanza](../doc/overviews/stzStringArt_Overview.md).

For a wide range of practical examples, see the [stzStringArtTest.ring](../core/test/stkStringArtTest.ring) file.

For quick insights into using the StringArt features at a glance, check out our [Softanza StringArt Quickers](link to be added) for an instant feel of how they work.