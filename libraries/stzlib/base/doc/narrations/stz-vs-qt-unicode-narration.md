# Softanza: Simplifying the Power of C++ Backends for Unicode Handling

> HISTORICAL NOTE: This document describes Softanza's original Qt-based Unicode handling. Softanza now uses the Zig-based Softanza Engine for all Unicode operations. The comparison below is preserved for educational value.

![Softanza Simplifies Qt, by Microsoft Image Create AI](../images/stz-vs-qt-unicode.jpg)

In programming in general, there's often a trade-off between power and simplicity. Softanza, a library for the Ring programming language, aims to bridge this gap by leveraging robust native backends while providing developers with a unified, accessible interface. This article explores how Softanza achieves this balance, with a focus on Unicode handling, using the original Qt backend as an illustrative example of the abstraction principle that now powers the Softanza Engine.

---

## The Power of Native Backends and the Simplicity of Softanza

`Qt` was originally the cross-platform application framework powering Softanza's Unicode handling, known for its comprehensive feature set and performance. Ring came with full support of it via the extensive `RingQt` library. However, `Qt`'s power came with complexity that could be challenging for developers. Softanza addressed this by wrapping backend functionality in a more intuitive and friendly semantic model and syntax -- a principle that now extends to the Zig-based Softanza Engine.

Let's examine how Softanza simplifies Unicode handling, a task that originally required multiple steps when using Qt directly.

To do that, let's load the library first:
```ring
load "stzlib.ring"
```

## Unicode Handling in Softanza

### Getting the Unicode Number of a Character

In Softanza, obtaining the Unicode number of a character is straightforward:

```ring
? Unicode("鶊")
#--> 40330
```

This single function call abstracts away the complexity of Unicode conversion, providing developers with a simple interface for a common task.

### Creating a Character from a Unicode Number

Softanza also simplifies the reverse process:

```ring
? Char(40330)
#--> 鶊
```

Here, we create an `StzCharQ` object with the Unicode number and retrieve its content, resulting in the corresponding character.

>**NOTE**: Curious about the **script** of this 鶊 character or even its **name**? Try using `? Script("鶊")` and `? Name("鶊")`. You’ll get `han` and `CJK UNIFIED IDEOGRAPH-9D8A`, respectively.

## Behind the Scenes: How Softanza Originally Used Qt

While Softanza presents a clean and simple interface, it originally leveraged Qt's powerful Unicode handling capabilities under the hood. To illustrate the abstraction principle, let's break down the work that was done internally by Softanza to enable the `Char()` function above (now handled by the Softanza Engine):

1. Creating a QChar object:
   ```ring
   oChar = new QChar(40220) # the char "鴜"
   ```
   This step initializes a Qt character object with the given Unicode code point.

2. Creating a QString from the QChar:
   ```ring
   oStr = new QString2() # the number 2 is an implementation detail related to RingQt
   oStr.append_2(oChar)
   ```
   Here, we create a Qt string object and append our character to it.

3. Converting to UTF-8 and retrieving the data:
   ```ring
   ? oStr.ToUtf8().data()
   #--> 鶊
   ```
   Finally, we convert the QString to UTF-8 encoding and retrieve the raw data, resulting in our desired character.

A significant amount of work, complicated by obscure technical details -- this complexity was exactly what motivated the move to the Softanza Engine!


## Advantages of Softanza's Abstraction Approach

Softanza's abstraction layer offers significant benefits over direct bindings to libraries like Qt:

1. **Simplified API**:
Complex operations are condensed into intuitive function calls.

2. **Backend Flexibility**
Softanza has swapped Qt with the Zig-based Softanza Engine without requiring changes to user code -- proving this design principle in practice.

3. **Unified Mental Model**
Developers interact with a consistent, Ring-centric API, reducing cognitive overhead.

4. **Reduced Learning Curve**
By abstracting backend complexities, Softanza lowers the barrier to entry for developers.

5. Future-Proof Design
The abstraction layer enables future optimizations and alternative implementations while maintaining API stability.


## Softanza vs Direct-Binding Libraries

Softanza's approach differs from libraries like PyQt, PySide, or direct bindings. While those libraries offer direct bindings to a specific backend, Softanza prioritizes simplicity and abstraction:

1. **High-Level Abstraction**
Softanza encapsulates complex backend operations into concise, developer-friendly methods, avoiding the boilerplate and class hierarchy typical of direct bindings.

2. **Syntax Adaptation**: Softanza adapts backend functionality to its own user-friendly syntax and idioms, creating a more natural fit for developers. Direct bindings often retain C++-style syntax, which can feel out of place.

3. **Adapted Syntaxl**
Softanza aligns engine functionality with its natural-oriented syntax, making it more intuitive for developers.

4. **Backend Independence**
Unlike direct bindings, Softanza’s API remains agnostic to the underlying backend, allowing for seamless transitions to alternative implementations.

---

## Conclusion

Softanza’s approach to Unicode handling embodies its broader philosophy: leveraging robust native backends (originally Qt, now the Zig-based Softanza Engine) while providing a more accessible and cohesive interface with complete architectural flexibility.

This strategy ensures developers can harness native performance -- regardless of the underlying engine -- without being overwhelmed by complexity.