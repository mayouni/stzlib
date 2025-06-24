# StringArt function and stzStringArt class reference

## Introduction

This document provides a comprehensive reference for the `StringArt` function(s) and the `stzStringArt` class, which are used to create and manipulate string art representations of text in the Softanza library, like this one ;)

```ring
load "stzlib.ring"

? StringArt("Ring")
#-->
/*
███▄▄░░ ███████ ██░░░██ ░▄███▄░
██░░░██ ░░██░░░ ███░░██ ██▀░░░░
███▄▄░░ ░░██░░░ ██▀█░██ ██░░███
██░▀██░ ░░██░░░ ██░▀███ ██▄░░██
██░░░██ ███████ ██░░░██ ░▀███▀░
*/
```

> NOTE: If you're not comfortable reading through a complete reference file and prefer building your comprehension of the StringArt features by crafting quick and small code snippets, you can jump right now to our [Softanza StringArt Quickers](../quickers/stz-string-art-quickers.md) page.

## Softanza Files related to the feature

This section references the Ring files and documentation Markdown files related to stringArt and where they sit according to Softanza software architecture.

### Reminder of the 3 Layers of Softanza Architecture

Softanza's software architecture is elegantly structured into three distinct layers: *Core*, *Prime*, and *Max*, each serving a specific role in scaling your applications.

- `SoftanzaCore` is the lightweight foundation on which all the upper layers are build (suitable for small apps, web, console, and microcontroller programs.
- `SoftanzaPrime` contains all the major features of the library that you need to develop midum to large Ring applications.
- `SoftanzaMax` augments SoftanzaPrime with Advanced features thay you mayn need in developing complex, undustrial grade applications and platforms.

> NOTE: You can read more about it in this article : [Understanding Softanza Lyered Softaware Architecture](#TODO Article to be Added)

### Reminder of the 4 types of files in Softanza

There are 4 types of files for each Softanza feature: *MainCodeFile*, *TestCodeFile*, *DataFile*, and *DocFiles*.

1- *MainCodeFile*: A Ring file that contains the code for the feature (including all functions and classes), named after the main class itself, like `stzStringArt.ring` in our current case. This file resides in the `../stz/string/` folder (in our case, because `StringArt` belongs to the *String* domain).

2- *TestCodeFile*: A Ring file that contains test examples, also named after the class with the `Test` extension, like `stzStringArtTest.ring`. This file is located in the '../stz/tests/' folder.

3- *DataFile*: A Ring or text file containing the data used by the functions and classes of the feature, such as 'stzStringArtData.ring' in our case, which resides in the '../stz/data/' folder.

4- *DocFiles*: Multiple files in `Markdown` format, related to various documentation levels provided for each feature, such as `stzStringArt_Reference.md`, `stzStringArt_Overview.md`, `stzStringArt_Quickers.md`, and `stzStringArt_FAQs.md`. These files are available in the respective folders `../stz/doc/references/`, `../stz/doc/overviews/`, `../stz/doc/quickers/`, and `../stz/doc/faqs/`.

>For more insights about that, read: [Understanding Files Typology in Softanza Design](#TODO add article and link)

### Related files in the SoftanzaPrime layer

| File | Type | Description | Path | Status |
|------|-------------|-------|------|--------|
| stzStringArt.ring | Code | Warpper class that ineherits from stkStringArt in SoftanzaCore | ../string/stzStringArt.ring | Usable |
| stzStringArtTest.ring | Test | Has few samples since all tests are made in stkStringArt.ring in SoftanzaCore| ../string/stzStringArt.ring | Usable |
| stzStringArt_Reference.md | Doc | Complete reference of the StringArt API (class and functions ) | ../doc/references/stzStringArt_Reference.md | Usable |
| stzStringArt_Overview.md | Doc | Comprehensive overview of the StringArt feature and its applications |  ../doc/references/stz-string-art-reference.md | Usable |
| stzStringArt_quickers.md | Doc | Quick hand-on code snippets to build an instant understanding of the feature | ../doc/quickers/stz-string-art-quickers.md | Usable |
| stzStringArt_FAQs.md | Doc | Frequent asked questions about the feature along with their answers | ../doc/faqs/stz-string-art-faqs.md | Usable |

> NOTE: There is no a DATA file at this layer because the data file hosted in SoftanzaCore layer is used in the backgound (see next table).

### Related files in the SoftanzaCore layer

| File | Type | Description | Path | Status |
|------|-------------|-------|------|--------|
| stkStringArt.ring | Code | Contains core code of StringArt functions and stkStringArt class | ../core/string/stkStringArt.ring | Usable |
| stkStringArtData.ring | Data | Contains the necerray data manipulated by StringArt function(s) and stkStringArt class | ../core/data/stkStringData.ring | Usable |
| stkStringArtTest.ring | Test | Contains the test samples related to the stkStringArt.ring file | ../core/stkStringArt.ring | Usable |

> NOTE: There is no DOC files at this layer because the doc files hosted in SoftanzaPrime layer are used everywhere (see previous table).

### Related files in the SoftanzaMAX layer

There are no files at this layer at the moment.


## stzStringArt Class

### Quick Reference

| Name | Type | Description | Since | Code |
|------|------|-------------|-------|------|
| [stzStringArt](#stzstringart-class) | Class | Class for creating and manipulating string art | V1.0 | Link |
| [Content()](#content) | Method | Returns the original content string | V1.0 | Link |
| [Style()](#style) | Method | Returns the current string art style | V1.0 | Link |
| [SetStyle(cStyle)](#setstylecstyle) | Method | Sets the string art style | V1.0 | Link |
| [Artify()](#artify) | Method | Converts the content to string art representation | V1.0 | Link |
| [Boxify()](#boxify) | Method | Creates a boxed version of the string art representation | V1.0 | Link |


### Basic Information

`stzStringArt` is a class for creating and manipulating string art representations of text.

### Constructor

```ring
load "stzlib.ring"

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
load "stzlib.ring"

oArt = new stzStringArt("Hi!")
? oArt.Style()
#--> retro
```

#### SetStyle(cStyle)

Sets the string art style.

- `cStyle`: The name of the style to set (must be a valid style from `StringArtStyles()`)

Example:
```ring
load "stzlib.ring"

oArt = new stzStringArt("Hi!")
oArt.SetStyle(:flower)
? oArt.Style()
#--> flower
```


#### Artify()

Converts the content to string art representation.

Example:
```ring
load "stzlib.ring"

oArt = new stzStringArt("Ring")

oArt.SetStyle(:flower)
? oArt.Artify()

#-->
/*
.-------.     .-./`)  ,---.   .--.   .-_'''-.   
|  _ _   \    \ .-.') |    \  |  |  '_( )_   \  
| ( ' )  |    / `-' \ |  ,  \ |  | |(_ o _)|  ' 
|(_ o _) /     `-'`'` |  |\_ \|  | . (_,_)/___| 
| (_,_).' __   .---.  |  _( )_\  | |  |  .-----.
|  |\ \  |  |  |   |  | (_ o _)  | '  \  '-   .'
|  | \ `'   /  |   |  |  (_,_)\  |  \  `-'`   | 
|  |  \    /   |   |  |  |    |  |   \        / 
''-'   `'-'    '---'  '--'    '--'    `'-...-'
*/
```


#### Boxify()

Creates a boxed version of the string art representation.

Example:
```ring
load "stzlib.ring"

oArt = new stzStringArt("Ring")

oArt.SetStyle(:flower)
? oArt.Artify()

#-->
/*
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
╰──────────────────────────────────────────────────╯
*/
```

## StringArt functions

### Quick reference

| Name | Type | Description | Since | Code |
|------|------|-------------|-------|------|
| [StringArt(str)](#stringart) | Function | Creates string art representation of text | V1.0 | Link |
| [StringArtXT(str, cStyle)](#stringartxtstr-cstyle) | Function | Creates string art representation of text in the given style | V1.0 | Link |
| [StringArtStyles()](#stringartstyles) | Function | Returns available string art styles | V1.0 | Link |
| [IsStringArtStyle(str)](#isstringartstylestr) | Function | Checks if a string is a valid art style | V1.0 | Link |
| [DefaultStringArtStyle()](#defaultstringartstyle) | Function | Returns the default string art style | V1.0 | Link |
| [SetDefaultStringArtStyle(cStyle)](#setdefaultstringartstylecstyle) | Function | Sets the default string art style | V1.0 | Link |

### Basic Information

`StringArt(str)` is a function that creates string art representations of text.

### Details

- Accepts a string as input
- Returns a string art representation of the input
- Uses the default string art style (can be changed using `SetDefaultStringArtStyle`)
- Supports a special syntax for string art paintings: `StringArt("#{PaintingName}")`

### Examples

```ring
load "stzlib.ring"

? StringArt("Hello")
#-->
/*
██░░░██ ███████ ██░░░░░ ██░░░░░ ░▄███▄░
██░░░██ ██░░░░░ ██░░░░░ ██░░░░░ ██▀░▀██
███████ █████░░ ██░░░░░ ██░░░░░ ██░░░██
██░░░██ ██░░░░░ ██░░░░░ ██░░░░░ ██▄░▄██
██░░░██ ███████ ███████ ███████ ░▀███▀░ 
*/
```

```ring
load "stzlib.ring"

? StringArt("#{Tree}")
#-->
/*
    🍃
   🍃🍃
  🍃🍃🍃
 🍃🍃🍃🍃
🍃🍃🍃🍃🍃
    ┃━┃
    ┃━┃
*/
```

### Options

- The default style can be changed using `SetDefaultStringArtStyle(cStyle)`

Example:
```ring
load "stzlib.ring"

SetDefaultStringArtStyle(:neon)
```

- Or the StringArtXT() function can be used directly to generate a string art in the given style:
```ring
load "stzlib.ring"

? StringArtXT("Ring", :retro)
```

### Related Functions

- `StringArtBoxified(str)`: Creates a boxed string art representation
- `CharArtLayers(c)`: Returns a list f strings representing the layers for a single character in string art (used internally by `StringArt()` function)

Example 1:
```ring
load "stzlib.ring"

? StringArtBoxified("HELLO")
#-->
/*
╭─────────────────────────────────────────╮
│ ██░░░██ ███████ ██░░░░░ ██░░░░░ ░▄███▄░ │
│ ██░░░██ ██░░░░░ ██░░░░░ ██░░░░░ ██▀░▀██ │
│ ███████ █████░░ ██░░░░░ ██░░░░░ ██░░░██ │
│ ██░░░██ ██░░░░░ ██░░░░░ ██░░░░░ ██▄░▄██ │
│ ██░░░██ ███████ ███████ ███████ ░▀███▀░ │
╰─────────────────────────────────────────╯
*/
```

Example 2:
```ring
load "stzlib.ring"

? CharArtLayers("R")
#-->
/*
[
	"███▄▄░░",
	"██░░░██",
	"███▄▄░░",
	"██░▀██░",
	"██░░░██"
]
*/
```

## Utility Functions

### StringArtXT(str, cStyle)

Creates string art representations of text in the given style.

Example
```ring
load "stzlib.ring"

? StringArtXT("R", :flower)
#-->
*/
.-------.    
|  _ _   \   
| ( ' )  |   
|(_ o _) /   
| (_,_).' __ 
|  |\ \  |  |
|  | \ `'   /
|  |  \    / 
''-'   `'-'  
*/
```

> NOTE: This function is more concise than `StringArt()` and does not affect the global string art style.
Example:
```ring
load "stzlib.ring"

? DefaultStringArtStyle()
#--> :retro

? StringArtXT("R", :flower)
#--> You get the floral R as showan in the example above

? DefaultStringStyle()
#--> :retro
```


### StringArtStyles()

Returns a list of available string art styles.

Example:
```ring
load "stzlib.ring"

? StringArtStyles()
#--> [ "retro", "neon", "geo", "flower" ]

```

### IsStringArtStyle(str)

Checks if the given string is a valid string art style.

Example:
```ring
load "stzlib.ring"

? IsStringArtStyle(:flower)
#--> TRUE
```

### DefaultStringArtStyle()

Returns the current default string art style.

Example:
```ring
load "stzlib.ring"

? DefaultStringArtStyle()
#--> retro
```

### SetDefaultStringArtStyle(cStyle)

Sets the default string art style.

Example:
```ring
load "stzlib.ring"

SetDefaultStringArtStyle(:geo)
? DefaultStringArtStyle()
#--> geo
```

## Data File: stkStringArtData.ring

The `stkStringArtData.ring` file (hosted in ../core/data/stkStringArtData.ring) contains the necessary data for StringArt functionality. It defines styles and paintings used by the `StringArt` function and `stzStringArt` class.

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

- For a broader understanding of string art support in Softanza, please refer to the article: [An overview of String Art support in Softanza](../overviews/stz-string-art-overview.md).
- For a wide range of practical examples, see the [stzStringArtTest.ring](../../core/test/stkStringArtTest.ring) file.
- For frequent asked questions and their answers, see [stzStringArt_FAQs](../../doc/faqs/stz-string-art-faqs.md) page.
