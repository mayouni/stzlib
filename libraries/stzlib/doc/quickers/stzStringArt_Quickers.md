# Softanza StringArt Quickers

This article provides quick, action-oriented code snippets to help you rapidly understand and start using Softanza's StringArt features. Each snippet demonstrates a specific capability, allowing you to experiment and learn without reading through extensive documentation.

## Quick Learning Path

Click on any topic to jump directly to that section:

1. [Generating basic string art](#1-generating-basic-string-art)
2. [Changing string art styles](#2-changing-string-art-styles)
3. [Creating string art with the stkStringArt class](#3-creating-string-art-with-the-stkstringart-class)
4. [Applying a box to string art](#4-applying-a-box-to-string-art)
5. [Using pre-defined string art paintings](#5-using-pre-defined-string-art-paintings)
6. [Listing available string art styles](#6-listing-available-string-art-styles)
7. [Verifying valid string art styles](#7-verifying-valid-string-art-styles)
8. [Creating custom string art paintings](#8-creating-custom-string-art-paintings)

By working through these snippets, you'll quickly gain a practical understanding of StringArt's core features. Feel free to modify the examples and experiment on your own to deepen your comprehension.

## 1. Generating basic string art

```ring
load "stzlib.ring"

? StringArt("Hello")
#-->
██░░░██ ███████ ██░░░░░ ██░░░░░ ░▄███▄░
██░░░██ ██░░░░░ ██░░░░░ ██░░░░░ ██▀░▀██
███████ █████░░ ██░░░░░ ██░░░░░ ██░░░██
██░░░██ ██░░░░░ ██░░░░░ ██░░░░░ ██▄░▄██
██░░░██ ███████ ███████ ███████ ░▀███▀░ 
```

## 2. Changing string art styles

```ring
load "stzlib.ring"

SetDefaultStringArtStyle("neon")
? StringArt("Hello")
#-->
╭╮ ╭╮ ╭━━━╮ ╭╮    ╭╮    ╭━━━╮
┃┃ ┃┃ ┃╭━━╯ ┃┃    ┃┃    ┃╭━╮┃
┃╰━╯┃ ┃╰━━╮ ┃┃    ┃┃    ┃┃ ┃┃
┃╭━╮┃ ┃╭━━╯ ┃╰━━╮ ┃╰━━╮ ┃╰━╯┃
╰╯ ╰╯ ╰━━━╯ ╰━━━╯ ╰━━━╯ ╰━━━╯
```

## 3. Creating string art with the stkStringArt class

```ring
load "stzlib.ring"

oArt = new stkStringArt("Ring")
oArt.SetStyle("geo")
? oArt.Artify()
#-->
╭────╮  ╭───╮ ╭╮   ╭╮  ╭───╮ 
│╭──╮│   ╱│╲  │╰╮  ││ ╱ ╭───╯
│╰──╯╱    │   │ ╰╮ ││ │ │ ╭╮ 
│  ╱ ╲   ╲│╱  │  ╰╮││ ╲ ╰─╯│ 
╰─╯  ╰╮ ╰───╯ ╰╮  ╰╯╯  ╰───╯ 
```

## 4. Applying a box to string art

```ring
load "stzlib.ring"

? StringArtBoxified("Box")
#-->
╭─────────────────────────────────╮
│ ███▄▄░░ ███████ ██░░░██ ░▄███▄░ │
│ ██░░░██ ░░██░░░ ███░░██ ██▀░░░░ │
│ ███▄▄░░ ░░██░░░ ██▀█░██ ██░░███ │
│ ██░▀██░ ░░██░░░ ██░▀███ ██▄░░██ │
│ ██░░░██ ███████ ██░░░██ ░▀███▀░ │
╰─────────────────────────────────╯
```

## 5. Using pre-defined string art paintings

```ring
load "stzlib.ring"

? StringArt("#{Tree}")
#-->
    🍃
   🍃🍃
  🍃🍃🍃
 🍃🍃🍃🍃
🍃🍃🍃🍃🍃
    ┃━┃
    ┃━┃
 ▔▔▔▔▔▔▔
```

## 6. Listing available string art styles

```ring
load "stzlib.ring"

? StringArtStyles()
#--> ["retro", "neon", "geo", "flower"]
```

## 7. Verifying valid string art styles

```ring
load "stzlib.ring"

? IsStringArtStyle("neon")
#--> TRUE

? IsStringArtStyle("invalid")
#--> FALSE
```

## 8. Creating custom string art paintings

To add a custom string art painting, add this to stkStringArtData.ring:

```ring
$STZ_STR_ART_MYCUSTOMART = "
  /\
 /  \
/____\
  ||
"
```

Then use it like this:

```ring
load "stklib.ring"
? StringArt("#{my custom art}")
#-->
  /\
 /  \
/____\
  ||
```

By experimenting with these quick snippets, you'll quickly gain practical experience with Softanza's StringArt capabilities. Feel free to modify these examples and create your own string art designs!

# Other documentation levels

1. Explore the complete reference document, [StringArt Function and stzStringArt Class Reference](../references/stzStringArt_Reference.md), for a detailed guide on every feature and method.
2. Review the overview narration, [An Overview of StringArt Support in Softanza](../overviews/stzStringArt_Overview.md), for a high-level understanding of StringArt’s key capabilities.
3. Experiment with code samples in the [stkStringArtTest](../../core/test/stkStringArtTest.ring) file to see practical examples of StringArt in action.
