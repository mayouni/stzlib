# FAQ: StringArt Feature in Softanza

## Q1: What is the StringArt feature in Softanza?

A1: StringArt is a feature in the Softanza library for Ring language that allows you to create ASCII art representations of text and pre-defined paintings. It can generate stylized text (figlets) and ASCII art images, enhancing the visual appeal of console outputs, text-based games, and code narrations.

## Q2: How do I use the StringArt feature?

A2: You can use StringArt in two main ways:
1. Use the `StringArt()` function directly:
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
2. Use the `stzStringArt` object:
   ```ring
   load "stzlib.ring"
   oArt = new stzStringArt("Hello")
   ? oArt.Artify()
   ```

## Q3: What styles are available for text art?

A3: Softanza currently ships with four styles:

- retro : like in the example above
- neon : like in
	```
	 ╭───╮  ╭───╮  ╭────╮ ╭─────╮   ╭─╮   ╭╮   ╭╮ ╭────╮   ╭─╮  
	╱╭───╯ ╱ ╭─╮ ╲ │╭──── ╰──┬──╯  ╱   ╲  │╰╮  ││ ╰───╮╱  ╱   ╲ 
	╲╰───╮ │ │ │ │ │╰───╮    │    ╱─────╲ │ ╰╮ ││    ╱╱  ╱─────╲
	 ╰─╮ ╱ ╲ ╰─╯ ╱ │ │       │    │ ╭─╮ │ │  ╰╮││  ╱╱╯   │ ╭─╮ │
	 ──╯ ╯  ╰───╯  ╰─╯      ╯╰─   ╰─╯ ╰─╯ ╰╮  ╰╯╯ ╰────╯ ╰─╯ ╰─╯
	```

- geo : like in
	```
	╭╮       ╭───╮  ╭╮   ╭╮ ╭────╮  ╭───╮
	││      ╱ ╭─╮ ╲ ││   ││ │╭──── ╱╭───╯
	││      │ │ │ │ ╰╲   ╱╯ │╰───╮ ╲╰───╮
	│╰────╮ ╲ ╰─╯ ╱  ╰╲ ╱╯  │╭───╯  ╰─╮ ╱
	╰─────╯  ╰───╯    ╰─╯   ╰────╯ ╰──╯ ╯

	```
- flower : likke in
	```
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
 
You can check available styles using:
```ring
? StringArtStyles()
#--> [ "retro", "neon", "geo", "flower" ]
```

## Q4: How do I change the style of the string art?

A4: You can change the style in three ways:
1. Set the default style globally:
   ```ring
   SetDefaultStringArtStyle(:neon)
   ```
2. Set the style for a specific `stzStringArt` object:
   ```ring
   oArt = new stzStringArt("Hello")
   oArt.SetStyle(:flower)
   ```
3. Set the style directly with the StringArtXT() function:
   ```ring
   ? StzStringArt("Hello", :retro)
   ```
   > NOTE: The StringArtXT() function does not change the current global style.s

## Q5: Can I create ASCII art images other than text?

A5: Yes! Softanza includes pre-defined ASCII art paintings. You can use them with this syntax:
```ring
? StringArt("#{Tree}")
```

## Q6: How do I add my own ASCII art paintings?

A6: You can add custom paintings by defining a new global variable in the `stzStringArtData.ring` file:
```ring
$STZ_STR_ART_MYCUSTOMART = "Your ASCII art here"
```
Then use it with:
```ring
? StringArt("#{my custom art}")
```

## Q7: Can I put a box around my string art?

A7: Yes! You can use the `Boxify()` method on a `stzStringArt` object, or use the `StringArtBoxified()` function:
```ring
oArt = new stzStringArt("Hello")
? oArt.Boxify()

# Or
? StringArtBoxified("Hello")
```

## Q8: Is StringArt only for visual enhancement, or does it have practical uses?

A8: While StringArt is great for visual enhancement, it has practical uses too:
- Creating eye-catching headers in console applications
- Enhancing text-based games with visual elements
- Improving code narrations and tutorials with visual aids
- Creating visually appealing error messages or prompts

## Q9: How does StringArt handle non-ASCII characters?

A9: StringArt primarily works with ASCII characters. Non-ASCII characters might not render correctly in string art styles. It's best to stick to standard ASCII characters for optimal results.

## Q10: Can I use StringArt in web applications?

A10: While StringArt is primarily designed for console output, you could potentially use it in web applications by rendering the output in a monospace font. However, for web use, you might want to consider more web-friendly alternatives like SVG or canvas-based text rendering.

## Q11: Where can I find more information about StringArt?

A11: For more detailed information, you can refer to:
- [The StringArt overview document](../overviews/stz-string-art-overview.md)
- [The StringArt reference document](../references/stz-string-art-reference.md)
- [The StringArt quickers guide for quick code snippets](../quickers/stz-string-art-quickers.md)
- [The `stkStringArtTest.ring` file for practical examples](../../core/test/stzStringArtTest.ring)

These resources are available in the Softanza documentation.
