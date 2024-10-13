# StringArt and stzStringArt Reference

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
Print(StringArt("Hello"))
Print(StringArt("#{Tree}"))
```

### Options

- The default style can be changed using `SetDefaultStringArtStyle(cStyle)`

### Related Functions

- `StringArtBoxified(str)`: Creates a boxed string art representation
- `CharArtLayers(c)`: Returns the layers for a single character in string art

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

#### SetStyle(cStyle)

Sets the string art style.

- `cStyle`: The name of the style to set (must be a valid style from `StringArtStyles()`)

#### Artify()

Converts the content to string art representation.

#### Boxify()

Creates a boxed version of the string art representation.

### Examples

```ring
oStrArt = new stzStringArt("Hello")
oStrArt.SetStyle("retro")
Print(oStrArt.Artify())
Print(oStrArt.Boxify())
```

## Utility Functions

### StringArtStyles()

Returns a list of available string art styles.

### IsStringArtStyle(str)

Checks if the given string is a valid string art style.

### DefaultStringArtStyle()

Returns the current default string art style.

### SetDefaultStringArtStyle(cStyle)

Sets the default string art style.

## Data File: stzStringArtData.ring

The `stzStringArtData.ring` file contains the necessary data for StringArt functionality. It defines styles and paintings used by the StringArt function and stzStringArt class.

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

## Notes

- The class uses uppercase letters for string art conversion.
- String art styles and paintings are defined in the `stzStringArtData.ring` file.
- The class includes error handling for incorrect parameter types and values.

## See Also

- `StringArtBoxified`
- `CharArtLayers`
- `StringArtPainting`
