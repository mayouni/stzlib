# Regex Made Simple and Accessible With Softanza

Softanza makes working with regular expressions significantly easier and more practical. It introduces two key functions: `rx()` and `pat()`. 

- **`rx(cPattern)`**: This function creates an `stzRegex` object from a regex pattern. While it allows direct input of regex strings, constructing long or complex patterns can be tedious and error-prone. 

- **`pat(cPatternName)`**: This addresses the issue of complex regexes by allowing users to reference pre-shipped, domain-specific patterns by name. Softanza comes with a rich library of dozens of commonly used regexes for practical scenarios. For example, the pattern `:xlsArrayFormula` simplifies working with Excel array formulas.

Here's how these features work in practice:

```ring
load "stzlib.ring"

# Match an Excel array formula

rx(pat(:xlsArrayFormula)) { ? Match("{=SUM(A1:A10)}") }
#--> Output: TRUE

# Retrieve and inspect the pattern

rx(pat(:xlsArrayFormula)) { ? Pattern() }
#--> "^\{(?:\s*=\s*[A-Za-z]+\([^\)]*\)|\s*[A-Za-z0-9\+\-\*/\(\)\&\^\.]+(\s*,\s*[A-Za-z0-9\+\-\*/\(\)\&\^\.]+)*\s*)\}$"

# Request a concise explanation

rx(pat(:xlsArrayFormula)) { ? Explain() }
#--> "Matches an array formula in Excel"

# Request an extended breakdown of the regex

rx(pat(:xlsArrayFormula)) { ? ExplainXT() }
#-->
# - `^\\{`: Matches the opening curly brace for the array formula.
# - `(?:`: Start of a non-capturing group.
# - `\\s*=\\s*[A-Za-z]+\\([^\\)]*\\)`: Matches a formula starting with an equal
#   sign, a function name, and arguments enclosed in parentheses.
# - `|`: Alternation to match either a function or plain array values.
# - `\\s*[A-Za-z0-9\\+\\-\\*/\\(\\)\\&\\^\\.]+`: Matches numeric or textual values,
#   operators, and parenthesized expressions.
# - `(\\s*,\\s*[A-Za-z0-9\\+\\-\\*/\\(\\)\\&\\^\\.]+)*`: Optionally matches additional
#   array elements separated by commas.
# - `\\s*`: Allows trailing whitespace.
# - `\\}`: Matches the closing curly brace for the array formula.
# - `$`: Ensures the entire string matches the pattern.
#
# - Matches: `{=SUM(A1:A10)}`, `{1, 2, 3}`, `{A1+B1, C1*D1}`.
# - Non-matches: `{SUM(A1:A10}`, `{1, 2}`, `=SUM(A1:A10)`.```
```

By abstracting complexity, Softanza enables developers to work efficiently with regex, even in complex domains, while providing tools for exploration and understanding, such as the `Explain()` and `ExplainXT()` methods. This integration bridges the gap between power and usability, making regex accessible for both beginners and experts.
