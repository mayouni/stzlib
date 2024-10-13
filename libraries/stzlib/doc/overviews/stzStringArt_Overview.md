# An overview of String Art support in Softanza

The Softanza library for Ring language introduces string art texts and paintings, enhancing the programming experience in code narrations, educational examples, and console text-based games. This feature makes programming more engaging, enjoyable, and visually appealing.

## StringArt() Function Features

The **StringArt()** function in Softanza offers two main capabilities:

1. Generating ASCII Art Text (Figlets)
2. Generating ASCII Art Paintings

### ASCII Art Text (Figlets)

**StringArt()** can generate stylized text using ASCII characters, also known as figlets. This feature creates eye-catching headers, titles, or text-based visual elements.

Example:
```ring
load "stzlib.ring"

SetStringArtStyle(:flower)
? StringArt("Ring") + NL
? "IS MORE BEAUTIFUL, YET POWERFUL WITH SOFTANZA!"
#-->
# .-------.     .-./`)  ,---.   .--.   .-_'''-.   
# |  _ _   \    \ .-.') |    \  |  |  '_( )_   \  
# | ( ' )  |    / `-' \ |  ,  \ |  | |(_ o _)|  ' 
# |(_ o _) /     `-'`'` |  |\_ \|  | . (_,_)/___| 
# | (_,_).' __   .---.  |  _( )_\  | |  |  .-----.
# |  |\ \  |  |  |   |  | (_ o _)  | '  \  '-   .'
# |  | \ `'   /  |   |  |  (_,_)\  |  \  `-'`   | 
# |  |  \    /   |   |  |  |    |  |   \        / 
# ''-'   `'-'    '---'  '--'    '--'    `'-...-'  
# 
# IS MORE BEAUTIFUL, YET POWERFUL WITH SOFTANZA!
```
You can use the **StringArt()** function like in the code above, or you can use the **stzStringArt** object, along with its methods **SetStyle()**, **Style()**, **Artify()**, and **Boxify()** like we are going to do in the next samples.

Currently, Softanza ships with 4 beautiful font art styles. 

### FLOWER, it's beautiful!

 This style, used in the previous sample to generate the word "Ring", creates beautiful floral and plant-like shapes.

### RETRO, the nice old days

This style has a distinctly digital, retro-computer feel. The letters are formed by small square units, giving it a pixelated look. The white outline on a dark background with faint grid lines in the background evokes the aesthetics of old-school computer graphics or architectural blueprints.

Example:
```ring
load "stzlib.ring"

o1 = new stzStringArt("SOFTANZA")
o1 {
    ? "Current style : " + Style() + NL
	? Artify()
}
#-->
# Current style : retro
#
# ░▄███▄░ ░▄███▄░ ███████ ███████ ░▄███▄░ ██░░░██ ███████ ░▄███▄░
# ██▀░░░░ ██▀░▀██ ██░░░░░ ░░██░░░ ██▀░▀██ ███░░██ ░░░▄██░ ██▀░▀██
# ░▀███▄░ ██░░░██ █████░░ ░░██░░░ ███████ ██▀█░██ ░▄██░░░ ███████
# ░░░░▀██ ██▄░▄██ ██░░░░░ ░░██░░░ ██░░░██ ██░▀███ ▄██░░░░ ██░░░██
# ███▄▄█▀ ░▀███▀░ ██░░░░░ ░░██░░░ ██░░░██ ██░░░██ ███████ ██░░░██
```

### NEON, for clean outlines

This style features clean, continuous lines that form the letters, with an outline effect reminiscent of neon signs. The font has a modern, sleek appearance with rounded corners and a consistent thickness throughout.

Example:
```ring
load "stzlib.ring"

o1 = new stzStringArt("SOFTANZA")
o1 {
    SetStyle(:neon)
	? Artify()
}
#-->
#  ╭───╮  ╭───╮  ╭────╮ ╭─────╮   ╭─╮   ╭╮   ╭╮ ╭────╮   ╭─╮  
# ╱╭───╯ ╱ ╭─╮ ╲ │╭──── ╰──┬──╯  ╱   ╲  │╰╮  ││ ╰───╮╱  ╱   ╲ 
# ╲╰───╮ │ │ │ │ │╰───╮    │    ╱─────╲ │ ╰╮ ││    ╱╱  ╱─────╲
#  ╰─╮ ╱ ╲ ╰─╯ ╱ │ │       │    │ ╭─╮ │ │  ╰╮││  ╱╱╯   │ ╭─╮ │
# ╰──╯ ╯  ╰───╯  ╰─╯      ╯╰─   ╰─╯ ╰─╯ ╰╮  ╰╯╯ ╰────╯ ╰─╯ ╰─╯
```

### GEO, explore the relief

This style offers a modern, slightly futuristic look while maintaining readability. It could be particularly effective for headlines, logos, or any application where you want to combine a tech-savvy feel with a touch of elegance.

Example:
```ring
load "stzlib.ring"

o1 = new stzStringArt("SOFTANZA")
o1 {
    SetStyle(:neon)
	? Boxify()
}
#-->
# ╭───────────────────────────────────────────────────╮
# │ ╭━━━╮ ╭━━━╮ ╭━━━╮ ╭━━━━╮ ╭━━━╮ ╭━╮ ╭╮ ╭━━━╮ ╭━━━╮ │
# │ ┃╭━━╯ ┃╭━╮┃ ┃╭━━╯ ┃ ┃┃ ┃ ┃╭━╮┃ ┃┃╰╮┃┃ ╰━━╮┃ ┃╭━╮┃ │
# │ ╰━━╮  ┃┃ ┃┃ ┃╰━━╮   ┃┃   ┃┃━┃┃ ┃╭╮╰╯┃  ╭━╯┃ ┃┃━┃┃ │
# │ ╭━━╯  ┃╰━╯┃ ┃╭━╰╯   ┃┃   ┃┃ ┃┃ ┃┃╰╮┃┃ ╭╯╭━╯ ┃┃ ┃┃ │
# │ ╰━━━╯ ╰━━━╯ ╰╯      ╰╯   ╰━ ━╯ ╰╯ ╰━╯ ╰━━━╯ ╰━ ━╯ │
# ╰───────────────────────────────────────────────────╯
```

## The Power of Visual Appeal

Softanza library offers a wide array of string art designs, ranging from simple shapes to complex scenes. These include:

1. Collectibles (coins, stars, hearts)
2. Environmental elements (trees, clouds)
3. Game elements (checkpoints, arrows)
4. Transportation (rockets, cars, spaceships)
5. Animals (cats, dogs, teddies)
6. Characters (heroes, wizards, princesses)
7. Buildings (castles)
8. Special effects (explosions, rain, fire)
9. Weapons (swords, bows, wands)
10. Human body parts
11. Miscellaneous designs

You can see them all in the **stzStringArtData.ring** file ([Link](../../core/data/stkStringArtData.ring).

By incorporating these visual elements into your code, you can create more engaging console outputs, making your programs not just functional, but visually appealing as well.

## Enhancing Code Narrations

One of the primary uses of string art in programming is to enhance code narrations. Instead of plain text explanations, you can use relevant icons or images to illustrate your points. For example:

```ring
load "stzlib.ring"

? "Welcome to our coding adventure!"
? StringArt("#{Rocket}")
? "Let's blast off into the world of Ring programming!"

#-->
# Welcome to our coding adventure!
#      △
#     ╱▲╲
#    ╱╱ ╲╲
#   ╱╱···╲╲
#  ╱╱·····╲╲
# ╱╱┌─────┐╲╲
# │││ ▓▓▓ │││
# │││ ▓▓▓ │││
# ╰╰───────╯╯
#  ╰┌─────┐╯
#   │ ███ │
#   │ ███ │
#   ╰─────╯
# Let's blast off into the world of Ring programming!
```

## Making Educational Examples More Engaging

When teaching programming concepts, visual aids can significantly improve understanding and retention. The string art can be used to create more engaging educational examples. For instance, when explaining conditional statements:

```ring
load "stzlib.ring"

func CheckWeather(temperature)
    if temperature > 30
        ? "It's hot outside!"
        ? StringArt("#{Sun rise}")
    else
        ? "It's cool today."
        ? StringArt("#{Cloud}")
    ok

CheckWeather(35)
#-->
# It's hot outside!
#    \   🌞  /
#   \  \│/  /
# ─ ─ ─ ☀ ─ ─ ─
#   /  /│\  \
#     /    \  \

CheckWeather(25)
#-->
# It's cool today.
#          .-~~~-.
#  .- ~ ~-(       )_ _
# /                     ~ -.
# |                           \
#  \                         .'
#    ~- . _____________ . -~
```

## Elevating Console Text-Based Games

Perhaps the most exciting application of string art is in console text-based games. These visual elements can transform simple text adventures into more immersive experiences. Let's explore how you can use string art to create engaging game elements.

### Creating an Attractive Game Start Screen

First, you can use string art to propose a beautiful startup screen for your console program:

```ring
load "stzlib.ring"

# Displaying the game logo
? StringArt("#{tree}")

# Displaying the game title
SetStringArtStyle(:neon)
? StringArt("MIMOSA") + NL

# Showing the start button
? StzStringQ(" PLAY NOW! ").BoxedRound() + NL

# A secondary text
? " Powered by: Softanza and the Ring GameEngine (c)"

#-->
#    🍃
#    🍃🍃
#   🍃🍃🍃
#  🍃🍃🍃🍃
# 🍃🍃🍃🍃🍃
#     ┃━┃
#     ┃━┃
#  ▔▔▔▔▔▔▔
# ╭━╮╭━╮ ╭━━━╮ ╭━╮╭━╮ ╭━━━╮ ╭━━━╮ ╭━━━╮
# ┃┃╰╯┃┃ ┃┃┃┃┃ ┃┃╰╯┃┃ ┃╭━╮┃ ┃╭━━╯ ┃╭━╮┃
# ┃╭╮╭╮┃  ┃┃┃  ┃╭╮╭╮┃ ┃┃ ┃┃ ╰━━╮  ┃┃━┃┃
# ┃┃┃┃┃┃ ┃┃┃┃┃ ┃┃┃┃┃┃ ┃╰━╯┃ ╭━━╯  ┃┃ ┃┃
# ╰╯╰╯╰╯ ╰━━━╯ ╰╯╰╯╰╯ ╰━━━╯ ╰━━━╯ ╰━ ━╯
# 
# ╭─────────────╮
# │  PLAY NOW!  │
# ╰─────────────╯
# 
# Powered by: Softanza and the Ring GameEngine (c)
```

### Implementing Game Encounters

You can use string art to make text-based RPG encounters as engaging as this:

```ring
load "stzlib.ring"

func EncounterMonster()
    ? "You encounter a fearsome dragon!"
    ? StringArt("#{Dragon}") + NL
    ? "What will you do?"
    ? "1. Fight"
    ? "2. Run"

    ? "Enter your choice: " give choice

    if choice = "1"
        ? "You draw your sword and prepare for battle!"
        ? StringArt("#{Sword}")
    else
        ? "You turn and run as fast as you can!"
        ? StringArt("#{RightFeet}")
    ok

EncounterMonster()
#-->
# You encounter a fearsome dragon!
#    /\\__/\\
#   (  @@  )
#  /\\  )\(  /\\
# (__\\/  \\/__)
#    | /\\ |
#    \\(__)/
#     `''`
# 
# What will you do?
# 1. Fight
# 2. Run
# Enter your choice: 2
# 
# You turn and run as fast as you can!
# oooO
# ( )
# \ (
# \_)
```

## Using Other Visual Features

Along with string arts, Softanza provides you with other interesting visual features that you can use to boost your text-based UIs:

### Boxing Strings

You can create buttons and other framed dialogs using the boxing feature in stzString:

```ring
load "stzlib.ring"

? StzStringQ("  PLAY NOW!  ").Boxed() + NL
#-->
# ╭─────────────╮
# │  PLAY NOW!  │
# ╰─────────────╯
```

### Displaying Grids

Softanza allows you to create and manipulate grids, which can be useful for game boards or data visualization:

```ring
# Create a grid of 10 by 10 nodes
StzGridQ([ :Of = 10, :By = 10 ]) {
    # Fill the grid with the chars between " " and "z"
    FillWith( CharsBetween(" ", :And = "z") )

    # Show the grid
    Show()
}

#-->
#   ! " # $ % & ' ( ) *
#   + , - . / 0 1 2 3 4
#   5 6 7 8 9 : ; < = >
#   ? @ A B C D E F G H
#   I J K L M N O P Q R
#   S T U V W X Y Z [ \
#   ] ^ _ ` a b c d e f
#   g h i j k l m n o p
```

### Displaying Tabular Data

Softanza's stzTable object allows you to beautifully display tabular data on the screen, which can be particularly useful for game statistics or any other tabular data presentation need:

```ring
# Create a table with this structure:
o1 = new stzTable([
    [ :COL1,    :COL2,    :COL3 ],
    #----------------------------#
    [ 10,       100,      1000  ],
    [ 20,       200,      2000  ],
    [ "*",      "*",      "*"   ],
    [ 30,       300,      3000  ]
])

# Show it on screen:
? o1.Show() + NL

#-->  COL1    COL2   COL3
#    ------ ------- ------
#       10     100    1000
#       20     200    2000
#        *       *       *
#       30     300    3000
```
> [NOTE]
> You can configure the table's stroke, adjustment, and other thinks, but let's keep it simple for now.

### Visual Search and Highlight

One of Softanza's unique features is its ability to visually find and highlight elements within a string or list. This can be incredibly useful for debugging, data analysis, or creating interactive tutorials.

```ring
load "stzlib.ring"

? Q("RINGORIALAND").vizFindAll("I")
#--> RINGORIALAND
#    -^----^-----

? Q("CAIRO").vizFindXT("I", [:Boxed = TRUE, :Rounded = TRUE, :VisualSign = "♥"])
#-->
#    ╭───┬───┬───┬───┬───╮
#--> │ C │ A │ I │ R │ O │
#    ╰───┴───┴─♥─┴───┴───╯
```

## Creating Custom Designs

The Softanza library also allows for easily adding custom string art designs. You just need to add a string global variable, containing the design, prefebraly into the **stzStringData.ring** file, and use its global name (which must be preceded by the char **$STZ_STR_ART_...**) when you call the **StringArt()** function. For example:

```ring
load "stzStringArt.ring"

$STZ_STR_ART_MyCustomLogo = "
   ____  _
  / __ \(_)____  ____ _
 / /_/ / / ___/ / __ `/
/ _, _/ / /    / /_/ /
/_/ |_/_/_/     \__,_/
"

? StringArt("#{" + my custom logo + "}") # Note how you can write the words separated by spaces
#-->
   ____  _
  / __ \(_)____  ____ _
 / /_/ / / ___/ / __ `/
/ _, _/ / /    / /_/ /
/_/ |_/_/_/     \__,_/
```

## Advanced Game Development

For more sophisticated game development, Softanza can be combined with other Ring libraries:

- **RingRogueUtil** extension for making console text-based user interfaces
- **RingEngine** library for more advanced game development features

These tools, when used in conjunction with Softanza's string art capabilities, can help you create rich, interactive console-based games with visually appealing interfaces.

## Conclusion

The string art feature in the Softanza library for Ring language demonstrates that programming doesn't have to be all about dry code and plain text outputs. By incorporating visual elements, we can make the coding experience more enjoyable, educational content more engaging, and console applications more appealing.
