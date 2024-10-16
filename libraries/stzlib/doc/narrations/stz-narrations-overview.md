# Softanza Narrations: Practical Problem-Solving Stories

Softanza's documentation system includes various types of documents, each serving a specific purpose:

- Essentials: Core concepts and fundamentals
- Quickers: Rapid solutions for common tasks
- FAQs: Answers to frequent questions
- Quizzes: Knowledge reinforcement
- References: Comprehensive feature guides
- Overviews: High-level component explanations
- Stats: Performance and usage metrics

Narrations complement these by bridging theory and practice through storytelling in code. They demonstrate how Softanza's components work together to solve real-world problems, making them particularly valuable for intermediate users, visual learners, and those seeking practical applications.

## The Structure of a Narration

Narrations in Softanza follow a defined structure:

1. **Title**: A descriptive headline using Markdown hashtags.
2. **Problem Definition**: A clear statement of the problem to be solved.
3. **Solution Steps**: An outline of the steps needed to solve the problem.
4. **Solution Implementation**: The actual Softanza code that implements the solution.
5. **Results and Reflection**: The output of the code and reflections on the process.
6. **List of Softanza Features Used**: A summary of the Softanza components employed in the solution.

## The Unique Value of Narrations

Narrations differ from other documentation types in several key ways:

1. **Integration of Components**: Unlike Quickers or FAQs that focus on specific tasks, narrations show how multiple Softanza features work together.

2. **Context-Rich Learning**: In contrast to References or Essentials, narrations provide a full context for using Softanza in realistic scenarios.

3. **Guided Problem-Solving**: While Quizzes test knowledge, narrations guide readers through the problem-solving process, promoting critical thinking.

4. **Practical Storytelling**: Overviews give high-level explanations, but narrations tell a story through code, making concepts more relatable and memorable.

By combining these elements, narrations help developers not just learn Softanza's syntax, but understand how to approach problems using the library. They exemplify the WYTIWYR (What You Think Is What You Write) principle, showing how intuitive problem-solving translates directly into Softanza code.

## An Illustrative Example

Here's an example of a Softanza narration, formatted as a Markdown file:

<div style="background-color: #f0f0f0; padding: 10px; border-radius: 5px;">

```markdown
# Data Cleansing and Transformation with Softanza

## Problem Definition

We have a string containing semi-structured data. The data is separated by semicolons and spread across multiple lines, including empty lines. We need to transform this into a clean, structured list of lists.

## Solution Steps

1. Remove empty lines from the input string
2. Convert the remaining lines into a list of strings
3. Trim each string to remove any extra whitespace
4. Split each string using the semicolon as a delimiter

## Solution Implementation

```ring
pron()
# Start with the semi-structured data
o1 = new stzString("
.;1;.;.;.
1;2;3;4;5
.;3;.;.;.
.;4;.;.;.
.;5;.;.;. ")

# Implement the solution steps
? @@SP(
o1.RemoveEmptyLinesQ().
LinesQR(:stzListOfStrings).
TrimQ().
StringsSplitted(:Using = ";")
)
proff()
```

## Results and Reflection

The output of our code:

```ring
[
 [ ".", "1", ".", ".", "." ],
 [ "1", "2", "3", "4", "5" ],
 [ ".", "3", ".", ".", "." ],
 [ ".", "4", ".", ".", "." ],
 [ ".", "5", ".", ".", "." ]
]
# Executed in 0.04 second(s).
```

This solution demonstrates the WYTIWYR (What You Think Is What You Write) principle. Our thought process translated directly into Softanza code, resulting in a concise and readable solution.

## Softanza Features Used

- stzString
- RemoveEmptyLinesQ()
- LinesQR()
- TrimQ()
- StringsSplitted()
- @@SP() (Show Parentheses)
```

</div>

This narration exemplifies how Softanza can be used to solve a real-world data cleansing and transformation problem. It guides the reader through the entire process, from problem definition to reflection on the solution, showcasing Softanza's intuitive syntax and powerful features.

By providing such narrations, Softanza's documentation system offers developers not just isolated code snippets or dry explanations, but complete, context-rich problem-solving experiences. This approach helps bridge the gap between theoretical knowledge and practical application, making it easier for developers to apply Softanza effectively in their own projects.

