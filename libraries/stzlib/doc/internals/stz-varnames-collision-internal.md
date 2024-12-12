# Safe Softanza Codebase : Preventing Global Variable Collisions
![Safe Softanza Codebase, by Microsot Image AI](../images/stz-varnames-collision.jpg)

Softanza functions and methods provide powerful tools for developers using the Ring programming language. However, a subtle yet significant issue can arise when local variables used within Softanza code share the same name as global variables in the calling program. This can lead to unexpected modifications of global variables, causing confusion and hard-to-diagnose bugs.

---

## Introduction

In this article, we explain the root cause of the problem, its implications, and the design decision Softanza has adopted to mitigate it. This documentation aims to assist both users and contributors in understanding and addressing the issue.

**The Problem: Variable Name Collisions**

Ring allows for dynamic scoping, meaning that variables not explicitly declared as local can affect and be affected by the global scope. Consider the following example:

**Example of the Issue**

```ring
# A global variable exists in the program
global nPos = 20

# A Softanza function is called
? SoftanzaFindAll([1, 2, "♥", 4, "♥", 6, "♥"], "♥")

# Checking the value of the global variable
? nPos
# Output: -1 (Unexpected change caused by Softanza's internal use of nPos)
```

In this scenario, the `SoftanzaFindAll` function internally uses a variable named `nPos`. However, because `nPos` is also defined globally in the user's program, the internal operations of `SoftanzaFindAll` inadvertently overwrite the global variable, leading to undesired behavior.

## The Softanza Solution: Protected Local Variables

To address this issue, Softanza has adopted a naming convention that ensures local variables used within Softanza functions and methods do not conflict with user-defined global variables. Specifically, all local variables are enclosed within double underscores (`_`), making them unique and less likely to collide with user-defined variable names.

**Revised Implementation of `SoftanzaFindAll`**

Here is how the `SoftanzaFindAll` function is implemented using protected local variables:

```ring
func SoftanzaFindAll(aList, cItem)
    _nPos_ = 0
    nCount = 0
    while _nPos_ < len(aList)
        _nPos_ = aList.find(cItem, _nPos_ + 1)
        if _nPos_ > 0
            nCount += 1
        else
            break
    ok nCount
```

**User Code**

When users call the revised function, their global variables remain unaffected:

```ring
nPos = 20

# A Softanza function is called
? SoftanzaFindAll([1, 2, "♥", 4, "♥", 6, "♥"], "♥")

? nPos
# Output: 20 (Global variable nPos remains unchanged)
```

**Benefits of the Naming Convention**

1. **Avoids Name Collisions**: Encapsulation of local variables prevents interference with global variables in the calling program.
2. **Enhanced Debugging**: Developers can trust that Softanza functions do not modify their global variables unexpectedly.
3. **Consistency**: A uniform approach across the library ensures reliability and reduces potential errors.

## Best Practices for Contributors

To maintain this standard:
- Always enclose local variable names in double underscores (e.g., `_varName_`).
- Avoid using generic or common variable names without encapsulation.
- Include test cases to verify that no global variables are modified unintentionally.
- Document any internal variables explicitly in the function comments.

## Extended Safeguards: Standardizing Constants

As part of improving the safety and reliability of Softanza, all instances where default variables such as `TRUE` and `FALSE` are used have been revised. Over 12,000 occurrences were updated to adopt a more robust and pragmatic convention-based approach. Instead of relying on global variables `TRUE` and `FALSE`, Softanza now uses explicitly declared global constants:

```ring
global _TRUE_ = 1
global _FALSE_ = 0
```

These constants are used consistently throughout the library to ensure there are no unintended modifications by external code. This change was necessary to prevent critical program failures. For instance, if a user were to redefine `TRUE` and `FALSE` in their program:

```ring
TRUE = 0
FALSE = 1
```

This would invert the logic across the entire program, leading to potentially catastrophic business consequences. Softanza takes a conservative approach to safeguard against such scenarios, as relying on the goodwill of programmers alone is insufficient.

## Note for Users

Users should avoid using global variable names enclosed in double underscores (`_`) in their programs to prevent accidental name collisions with Softanza. For example:

```ring
# Avoid this:
global _TRUE_ = 42
```

Doing so may inadvertently overwrite Softanza’s internal constants or variables.

## Future Enhancements

Softanza is extending this principle to other constants, such as `NULL`, to further enhance safety and reliability for Softanza-based programs.

---

## Conclusion

By adopting the protected variable naming convention and standardizing critical constants, Softanza ensures greater safety, reliability, and compatibility for all programs. These measures protect both novice and expert users from unintended side effects, allowing them to focus on building robust applications with confidence.


