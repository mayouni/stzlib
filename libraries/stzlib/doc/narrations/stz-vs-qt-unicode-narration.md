# Softanza: Simplifying the Power of C++ Backends for Unicode Handling
![Softanza Simplifies Qt, by Microsoft Create AI](../images/stz-vs-qt-unicode.jpg)

In programming in general, there's often a trade-off between power and simplicity. Softanza, a library for the Ring programming language, aims to bridge this gap by leveraging the robust C and C++ libraries, such as Qt, while providing developers with a unified, accessible interface. This article explores how Softanza achieves this balance, with a focus on Unicode handling, using Qt as an illustrative example.

---

## The Power of Qt and the Simplicity of Softanza

Qt is a powerful cross-platform application framework, known for its comprehensive feature set and performance. Ring come with a full support of it via the extensive RingQt library. However, Qt's power comes with complexity that can be challenging for developers, especially those new to the framework. Softanza addresses this by wrapping Qt's functionality in a more intuitive and friendly syntax.

Let's examine how Softanza simplifies Unicode handling, a task that often requires multiple steps when using Qt directly.



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



## Behind the Scenes: How Softanza Uses Qt

While Softanza presents a clean and simple interface, it's leveraging Qt's powerful Unicode handling capabilities under the hood. To illustrate this, let's break down the work done for you internally by Softanza to enable the Char() function above:

1. Creating a QChar object:
   ```ring
   oChar = new QChar(40220) # the char "鴜" coded on 3 bytes
   ```
   This step initializes a Qt character object with the given Unicode code point.

2. Creating a QString from the QChar:
   ```ring
   oStr = new QString2()
   oStr.append_2(oChar)
   ```
   Here, we create a Qt string object and append our character to it.

3. Converting to UTF-8 and retrieving the data:
   ```ring
   ? oStr.ToUtf8().data()
   #--> 鶊
   ```
   Finally, we convert the QString to UTF-8 encoding and retrieve the raw data, resulting in our desired character.

A significant amount of work, complicated by obscure technical details that are challenging to locate amidst the vast expanse of Qt's online documentation!



## Advantages of Softanza's Abstraction Approach

Softanza's abstraction layer offers significant benefits over direct bindings to libraries like Qt:

1. **Simplified API**:
Complex operations are condensed into intuitive function calls.

2. **Backend Flexibility**
Softanza can swap Qt with any other C or C++ library without requiring changes to user code.

3. **Unified Mental Model**
Developers interact with a consistent, Ring-centric API, reducing cognitive overhead.

4. **Reduced Learning Curve**
By abstracting backend complexities, Softanza lowers the barrier to entry for developers.

5. Future-Proof Design
The abstraction layer enables future optimizations and alternative implementations while maintaining API stability.



## Softanza vs Other Qt-based Libraries

Softanza's approach differs from libraries like PyQt, PySide, or even RingQt itself. While these libraries offer direct bindings to Qt, Softanza prioritizes simplicity and abstraction:

1. **High-Level Abstraction**
Softanza encapsulates complex Qt operations into concise, developer-friendly methods, avoiding the boilerplate and class hierarchy typical of direct bindings.

2. **Syntax Adaptation**: Softanza adapts Qt's functionality to it's own user-friendly syntax and idioms, creating a more natural fit for developers. Other Qt bindings often retain C++-style syntax, which can feel out of place.

3. **Adapted Syntaxl**
Softanza aligns Qt functionality with its natural-oriented syntax, making it more intuitive for developers.

4. **Backend Independence**
Unlike direct bindings, Softanza’s API remains agnostic to the underlying backend, allowing for seamless transitions to alternative implementations.

---

## Conclusion

Softanza’s approach to Unicode handling embodies its broader philosophy: leveraging established C and C++ libraries like Qt while providing a more accessible and cohesive interface with complete architectural flexibility.

This strategy ensures developers can harness the power of Qt—or any other backend—without being overwhelmed by complexity.