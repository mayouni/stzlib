# A Guided Path to Problem-Solving: The Softanza Mental Model
![](../images/stz-mental-model.jpg)
*A programmer in a futuristic lab using a holographic interface to explore data step-by-step.*

The **Softanza Mental Model** is a guiding principle for solving problems step-by-step through progressive exploration and manipulation of data.

---

## Introduction

This model addresses the challenge of navigating the thousands of features in the Softanza library. Instead of being overwhelmed by its extensive feature set, programmers are encouraged to focus on their problem, select the appropriate Softanza object—whether basic (like `stzString`, `stzList`, or `stzNumber`) or elaborated (like `stzTable`, `stzHashList`, or `stzGrid`)—and craft their solution by following this intuitive, accurate, memorable, and learnable approach.

## Key Steps of the Softanza Mental Model

### 1. Define Your Problem

   Start by precisely expressing your problem in natural terms. This will help identify relevant keywords that guide the object selection process.
   
   Example:
   
   **Problem:** Exploring *empty strings* inside a *list*.

   **Keywords extracted:**
   - *"empty strings"*: Softanza has functions to handle these directly,
   - *"list"*: Softanza provides `stzList`, and
   - the combination of both: *checking empty strings within a list* is also direclty supported by Softanza.

### 2. Select the Appropriate Object

   Use the keywords from the problem definition to identify the Softanza object that best represents the data or problem you are working on. This could be a simple structure like a string or list, or a more complex one like a table or grid.

   Example:
   ```ring
   o1 = new stzList([ "A", '', "B", '', '', "C" ])
   ```
   In this case, a list is chosen to represent a sequence of values where some are empty strings.

### 3. Ask the Containment Question

   Determine whether the dataset contains elements that meet a specific condition.
   
   Example:
   ```ring
   ? o1.ContainsEmptyStrings()
   #--> TRUE
   ```
   Here, we check if the list contains any empty strings. The answer is `TRUE`, indicating further action is warranted.

### 4. Ask the Count Question

   If the condition is met, quantify how many elements satisfy it.
   
   Example:
   ```ring
   ? o1.CountEmptyStrings() + NL
   #--> 3
   ```
   We find that there are three empty strings in the list.

### 5. Ask for the Positions

   Identify the exact positions of the elements that match the condition.
   
   Example:
   ```ring
   ? o1.FindEmptyStrings()
   #--> [ 2, 4, 5 ]
   ```
   The indices of the empty strings are `[2, 4, 5]`.

### 6. Take Action on the Positions

   Once you know the positions, decide what to do with the elements at those positions. Actions can include retrieving them, removing them, or replacing them.

   #### Get items at positions

   Get the items by their positions or directly by calling them by name.

   ```ring
   ? o1.ItemsAtPositions( o1.FindEmptyStrings() )
   #--> [ "", "", "" ]

   ? o1.EmptyStrings()
   #--> [ "", "", "" ]
   ```

   #### Replace items at position

   Replace the identified elements with a specified value.

   ```ring
   o1.ReplaceEmptyStrings(:With = "~")
   ? o1.Content()
   #--> [ "A", '~', "B", '~', '~', "C" ]
   ```
   The empty strings are replaced with `~`, transforming the list.

   #### Remove items at positions

   or remove the identified elements altogether.

   ```ring
   o1 = new stzList([ "A", '', "B", '', '', "C" ])
   o1.RemoveEmptyStrings()
   ? o1.Content()
   #--> [ "A", "B", "C" ]
   ```
   The empty strings are eliminated, leaving a cleaner dataset.

## The Power of the Softanza Mental Model

The **Softanza Mental Model** is not merely a set of steps but a way of thinking about problems. Starting with the definition of the problem and the selection of an appropriate object, it leads you through progressively detailed inquiries until you reach a point of confident action. Each stage builds upon the last, ensuring clarity and precision in problem-solving.

This systematic approach demonstrates that the extensive Softanza feature set is not a hurdle but an enabler of creative and efficient solutions. Whether working with strings, lists, or other structures, the model helps programmers dissect, understand, and transform their data in a logical and effective manner.

## Broader Implications

The Softanza Mental Model embodies a universal computational philosophy: **"Focus on the problem, refine your inquiries, and act decisively."** It is a pathway not only for working with code but also for tackling complex algorithmic challenges in any domain. By adopting this model, programmers can approach their problems with a structured mindset, ensuring consistent and reliable outcomes.