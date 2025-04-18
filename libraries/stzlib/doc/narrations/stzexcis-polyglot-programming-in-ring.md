# Softanza EXCIS: Orchestrating a Polyglot Symphony with Ring

Imagine a programming environment where you can harness the raw speed of **C**, the data-crunching power of **R**, the machine learning magic of **Python**, the scientific elegance of **Julia**, the asynchronous agility of **NodeJS**, the logical brilliance of **SWI-Prolog**, and the simplicity of **Ring**—all within a single project. This is the revolutionary vision of **Softanza EXCIS (External Code Integration System)**, a cornerstone of the Softanza library that transforms Ring into a masterful conductor of a polyglot orchestra. By seamlessly integrating seven carefully selected languages, each excelling in its domain, EXCIS empowers developers to craft solutions for complex real-world problems with trust and ease. To draw you into this paradigm, we’ll start with a practical introduction to using EXCIS in Ring, followed by a thrilling performance battle that showcases each language’s strengths, and conclude with why this polyglot approach redefines computational thinking.

## Getting Started with EXCIS: A Practical Introduction

Softanza EXCIS, built on the `stzExtCode` class, makes it effortless to embed and execute code from multiple languages within a Ring program. Whether you’re crunching numbers, building APIs, or solving logical puzzles, EXCIS lets you tap into the right language for the job. Here’s how it is implemented behind the scene:

![Softanza EXCIS System workflow](../images/stz-excis-system.png)
And this is how it works in practice:

### Simple Example: Blending Languages with EXCIS

Suppose you’re building a Ring application that needs to compute statistics with R, perform a quicksort in C, and reason about relationships with Prolog. With EXCIS, you can orchestrate all three in one script:

```ring
# Initialize EXCIS for multiple languages
R = new stzExtCode(:R)
C = new stzExtCode(:C)
Prolog = new stzExtCode(:Prolog)

# 1. R: Calculate mean of a dataset
R.SetCode('
    data <- c(10, 20, 30, 40, 50)
    res <- list(mean = mean(data))
')
R.Run()
? @@(R.Result())
#--> [ [ "mean", 30 ] ]

# 2. C: Sort an array
C.SetCode('
    #include <stdio.h>
    void quicksort(int arr[], int low, int high) {
        if (low < high) {
            int pivot = arr[high];
            int i = low - 1;
            for (int j = low; j < high; j++) {
                if (arr[j] < pivot) {
                    i++;
                    int temp = arr[i];
                    arr[i] = arr[j];
                    arr[j] = temp;
                }
            }
            int temp = arr[i + 1];
            arr[i + 1] = arr[high];
            arr[high] = temp;
            quicksort(arr, low, i);
            quicksort(arr, i + 2, high);
        }
    }
    int main() {
        int arr[] = {5, 2, 8, 1, 9};
        int n = 5;
        quicksort(arr, 0, n-1);
        printf("[");
        for (int i = 0; i < n; i++) {
            printf("%d", arr[i]);
            if (i < n-1) printf(", ");
        }
        printf("]");
        return 0;
    }
')
C.Execute()
? C.Result()
#--> [1, 2, 5, 8, 9]

# 3. Prolog: Query family relationships
Prolog.SetCode('
    parent(john, mary).
    parent(mary, alice).
    ancestor(X, Y) :- parent(X, Y).
    ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).
    res(Result) :- findall([X, Y], ancestor(john, Y), Result).
')
Prolog.Run()
? @@(Prolog.Result())
#--> [ [ "john", "mary" ], [ "john", "alice" ] ]
```

This snippet showcases EXCIS’s power: R computes statistics, C sorts an array with blazing speed, and Prolog reasons about relationships—all orchestrated by Ring. The `stzExtCode` class handles code execution and result transformation, converting outputs (e.g., R’s lists, C’s arrays, Prolog’s terms) into Ring’s native data structures.

> **Note**: Ensure the target languages (e.g., Python, R, Prolog) are installed and accessible in your system PATH. The result variable in each language’s code (e.g., `res` in Prolog) is configurable via the `@cResultVar` attribute in `stzExtCode`.

## The Performance Battle: A Window into Language Strengths

To illustrate why EXCIS’s polyglot approach is so powerful, let’s dive into a performance battle where our seven languages tackle three challenges: calculating the 450th Fibonacci number, sorting a 1,000,000-element array, and multiplying two 250x250 matrices. 

> **Important Note on Performance Stats**: The results, measured in milliseconds, are relative to a specific computer environment and influenced by runtime warmups (e.g., Julia’s JIT compilation or Python’s interpreter startup). These times should be interpreted on a relative scale, comparing languages within this context rather than as absolute measures, as performance can vary across systems and runs.

### Round 1: Fibonacci Frenzy
**Task**: Compute the 94-digit 450th Fibonacci number.

**Results**:
- **C, Python, SWI-Prolog**: 0 ms
- **NodeJS**: 0.07 ms
- **Ring**: 1 ms
- **Julia**: 11 ms
- **R**: 20 ms

**Insights**: **Python** and **SWI-Prolog** excelled with big integer support, while **C** matched their speed but faltered on overflow. **NodeJS** nearly tied C, showcasing its computational versatility. **Ring** performed solidly, but **Julia** and **R** lagged slightly due to warmup and non-numeric focus.

### Round 2: Sorting Showdown
**Task**: Sort a 1,000,000-element array.

**Results**:
- **SWI-Prolog**: 110 ms
- **NodeJS**: 134.67 ms
- **C**: 197 ms
- **R**: 690 ms
- **Julia**: 944 ms
- **Python**: 3,896.04 ms
- **Ring**: 29,923 ms

**Insights**: **SWI-Prolog**’s optimized `sort/2` stunned, outpacing manual quicksorts. **NodeJS** and **C** delivered raw power, while **R** and **Julia** leveraged built-in sorts. **Python** and **Ring** struggled without library optimizations.

### Round 3: Matrix Mania
**Task**: Multiply two 250x250 matrices.

**Results**:
- **R**: 10 ms
- **C**: 61 ms
- **NodeJS**: 80.76 ms
- **Julia**: 255 ms
- **Python**: 2,512.93 ms
- **SWI-Prolog**: 4,250 ms
- **Ring**: 7,805 ms

**Insights**: **R** dominated with BLAS-powered matrix operations, **C** and **NodeJS** showed versatility, and **Julia** held strong. **Python**, **SWI-Prolog**, and **Ring** lagged in pure implementations.

### Total Times (Relative)
- **NodeJS**: 215.5 ms
- **C**: 258 ms
- **R**: 720 ms
- **Julia**: 1,210 ms
- **SWI-Prolog**: 4,360 ms
- **Python**: 6,408.97 ms
- **Ring**: 37,729 ms

**Winner**: **NodeJS**, edging out C, but the real story is how each language excels in its niche.

## Beyond Speed: A Computational Thinking Revolution

The performance battle highlights where each language shines—**C** for raw speed, **R** for matrices, **SWI-Prolog** for sorting efficiency—but EXCIS’s true power lies in enabling a **domain of domains-of-expertise**. Instead of forcing one language to handle every task, EXCIS lets you design solutions by combining the best tools:

- **System Programming**: Use C for low-level efficiency.
- **Data Analysis**: Let R crunch numbers and visualize results.
- **Machine Learning**: Tap Python’s rich ecosystem (e.g., Pandas, scikit-learn).
- **Scientific Computing**: Leverage Julia’s numerical precision.
- **Asynchronous APIs**: Build with NodeJS’s event-driven model.
- **Logic Reasoning**: Solve complex problems with Prolog’s rule-based approach.
- **Prototyping**: Write clear, readable code with Ring.

This polyglot approach fosters **computational thinking**, allowing developers to focus on solution design rather than language limitations. By orchestrating these languages, Ring becomes a polyglot powerhouse, outperforming monolingual environments in tackling multifaceted challenges like AI-driven analytics, real-time systems, or logical constraint solving.

## A Paradigm That Redefines Development

Unlike traditional frameworks (e.g., Spring, Django, Node.js) that rely on a single language, EXCIS embraces diversity, making Ring a unique conductor of specialized tools. This paradigm rivals monolithic stacks by offering flexibility and power, ideal for modern software’s complexity. As explored with Softanza’s features like `py()` for Python integration [Memories: February 24], EXCIS builds on this foundation, scaling Ring’s capabilities to professional-grade applications.

## Final Reflection: Coding’s New Horizon

Softanza EXCIS isn’t just about running code—it’s about reimagining how we solve problems. The performance battle showcased the unique strengths of **C**, **Python**, **R**, **Julia**, **NodeJS**, **SWI-Prolog**, and **Ring**, but EXCIS weaves them into a cohesive tapestry. By enabling developers to use each language where it excels, Ring becomes a trusted ally for building robust, innovative solutions. Welcome to a future where coding is a symphony, and EXCIS conducts it with brilliance. 🎼