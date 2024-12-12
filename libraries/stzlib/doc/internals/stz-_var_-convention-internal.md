# The _var_ Convention: Solving Global Variable Collisions in Softanza
![Softanza Codebase Integrity, by Microsot Image AI](../stz-_var_-convention-internal)

Softanza functions and methods provide powerful tools for developers using the Ring programming language. However, a subtle yet significant issue can arise when local variables used within Softanza code share the **same name** as global variables in the calling program. This can lead to **unexpected modifications** of global variables, causing confusion and hard-to-diagnose bugs.

---

## Introduction

In this article, we explain the root cause of the problem, its implications, and the **design decision** Softanza has adopted to mitigate it. This documentation aims to assist both users and contributors in understanding and addressing the issue.

## The Problem: Variable Name Collisions

Ring supports dynamic scoping, meaning global variables, defined at the main region of the program, can be influenced by local variables, defined inside functions, if they share the same name. Consider the following example:

**Example of the Issue**

```ring
# Softanza library is loaded
load "stzlib.ring"

# A global variable exists in the program
nPos = 20

# A Softanza function is called
? @FindAll([1, 2, "♥", 4, "♥", 6, "♥"], "♥")

# Checking the value of the global variable (20 is expected but...)
? nPos
#--> -1 (Unexpected change caused by Softanza's internal use of nPos)
```

In this scenario, the `@FindAll` function **internally used** a variable named `nPos`. However, because `nPos` is **also defined globally** in the user's program, the internal operations of `@FindAll` inadvertently **overwrited** the global variable, leading to undesired behavior.

## The Softanza Solution: Protected Local Variables

To address this issue, We've adopted a **naming convention** that prevents local variables in Softanza functions and methods from conflicting with user-defined global variables. While this also applies to class attributes, it is beyond our current focus.

Specifically, all local variables are enclosed within double underscores (`_`), ensuring their uniqueness and reducing the likelihood of conflicts with user-defined variable names. 

>**NOTE**: We’ll refer to this as the **_var_** naming convention.

**Revised Implementation of `@FindAll`**

Here is how the `@FindAll` function has been re-implemented using the **_var_** naming convention :

```ring
func @FindAll(aList, pItem)

    # Taking copies of the params

    _aList_ = aList
    _item_ = pItem

    # Preparing the local variables

   	_anResult_ = []
	_nPos_ = -1

	while _TRUE_
		try
			_nPos_ = find(_aList_, _item_)  # If Ring can find it, we are happy ;)
		catch
			return -1                       # Otherwise, we return -1
		done

		if _nPos_ = 0
			exit
		ok

		_anResult_ + _nPos_

        # A touch of magic: to allow Ring's find() method in the try block above
        # to continue searching through the remaining part of the list, we modify
		# the item at the position it just found to ensure it is skipped.

		_aList_[ _nPos_ ] += (""+ _aList_[ _nPos_ ] + 1)
		
	end

	return _anResult_
```

>**TODO**: The entire existing Softanza codebase will be gradually updated to incorporate this convention, and all new code will adhere to it from the outset.

**User Code**

Now, when users call the revised function, their global variables remain unaffected:

```ring
nPos = 20

# A Softanza function is called
? @FindAll([1, 2, "♥", 4, "♥", 6, "♥"], "♥")

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

As part of improving the safety and reliability of Softanza, all instances where default variables such as `TRUE`, `FALSE`, and `NULL` are used have been revised. Over 12,000 occurrences were updated to adopt the **_var_** convention-based approach. This is how Softanza redefined them:

```ring
_TRUE_  = 1
_FALSE_ = 0
_NULL_  = ""
```

These constants are used consistently throughout the library to ensure there are no unintended modifications by external code. This change was necessary to prevent critical program failures. For instance, if a user were to redefine `TRUE` and `FALSE` in their program:

```ring
TRUE = 0
FALSE = 1
```

This would invert the logic across the entire program, leading to potentially catastrophic business consequences. Softanza takes a conservative approach to safeguard against such scenarios, as relying on the goodwill of programmers alone is insufficient.

## Note for Users

Programmers should avoid using global variable names enclosed in double underscores (`_`) in their programs to prevent accidental name collisions with Softanza. For example:

```ring
# Avoid this:
global _nPos_ = 42
```

Doing so may inadvertently overwrite Softanza’s internal variables.

---

## Conclusion

By adopting the protected variable naming convention and standardizing critical constants, Softanza ensures greater safety, reliability, and compatibility for all programs. These measures protect both novice and expert users from unintended side effects, allowing them to focus on building robust applications with confidence.


