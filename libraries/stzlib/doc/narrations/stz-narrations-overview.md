# Softanza Narrations: Practical Problem-Solving Stories

Softanza's documentation system includes various types of documents, each serving a specific purpose:

- *Essentials*: Key takeaways for programmers in a harry!
- *Quickers*: for whom prefer learning by doing without reading through extensive documentation 
- *FAQs*: Answers to frequently asked questions
- *Quizzes*: Tests to reinforce Learning and evaluate success
- *References*: Detailed documentation of classes, functions, parameters, and returned values
- *Overviews*: High-level explanations of a feature and its combination with others
- *Stats*: Performance metrics of the library internal code and its usage statistics

> **Narrations** complement these by bridging theory and practice through storytelling in code. They demonstrate how Softanza's features work together to solve real-world problems, making them particularly valuable for intermediate users, visual learners, and those seeking practical applications.

## The Structure of a Narration

Narrations in Softanza follow a defined structure:

1. **Title**: A descriptive headline using Markdown hashtags.
2. **Problem Definition**: A clear statement of the problem to be solved.
3. **Solution Steps**: An outline of the steps needed to solve the problem.
4. **Solution Implementation**: The actual Softanza code that implements the solution.
5. **Results and Reflection**: The output of the code and reflections on the process.
6. **List of Softanza Features Used**: A summary of the Softanza features employed in the solution.

## The Unique Value of Narrations

Narrations differ from other documentation types in several key ways:

1. **Integration of Featuress**: Unlike Quickers or FAQs that focus on specific tasks, narrations show how multiple Softanza features work together.

2. **Context-Rich Learning**: In contrast to References or Essentials, narrations provide a full context for using Softanza in realistic scenarios.

3. **Guided Problem-Solving**: While Quizzes test knowledge, narrations guide readers through the problem-solving process, promoting critical thinking.

4. **Practical Storytelling**: Overviews give high-level explanations, but narrations tell a story through code, making concepts more relatable and memorable.

By combining these elements, narrations help developers not just learn Softanza's syntax, but understand how to approach problems using the library. They exemplify the WYTIWYR (What You Think Is What You Write) principle, showing how intuitive problem-solving translates directly into Softanza code.

## An Illustrative Example

Here's an example of a Softanza narration:

<div style="background-color: #f0f0f0; padding: 10px; border-radius: 5px;">

```markdown
# Title : Data Cleansing and Transformation with Softanza (Tags : #narration #data-cleansing #sdata-transformation)

## Problem Definition

We have a string containing semi-structured data. The data is separated by semicolons and spread across multiple
lines, including empty lines:

	o1 = new stzString("
	.;1;.;.;.
	1;2;3;4;5
	.;3;.;.;.
	.;4;.;.;.
	.;5;.;.;. ")


We need to transform this into a clean, structured list of lists:

[
	[ ".", "1", ".", ".", "." ],
	[ "1", "2", "3", "4", "5" ],
	[ ".", "3", ".", ".", "." ],
	[ ".", "4", ".", ".", "." ],
	[ ".", "5", ".", ".", "." ]
	]
]

## Solution Steps

1. Remove empty lines from the string
2. Convert the remaining lines into a list of strings
3. Trim each string to remove any extra whitespace
4. Split each string using the semicolon as a delimiter

## Solution Implementation

Here is the translation of the thought process of the above section in Softanza:

	# Step 1
	o1.RemoveEmptyLinesQ()

	# Step 2
	o2 = o1.LinesQ().ToStzListOfStrings()

	# Step 3
	o2.Trim()

	# Step 4
	o2.StringsSplitted(:Using = ";")

	? @@(o2.Content())
	#--> You get the well formed table.

## Results and Reflection

The output of our code demonstrates a successful transformation of the semi-structured data into a clean,
structured list of lists. Each inner list represents a row of data, with empty cells represented by dots.

This solution exemplifies the WYTIWYR (What You Think Is What You Write) principle. Our thought process
translated directly into Softanza code, resulting in a concise and readable solution that effectively
cleanses and transforms the data.

## Softanza Features Used

- stzString
- RemoveEmptyLinesQ()
- LinesQR()
- TrimQ()
- StringsSplitted()
- @@()
```
