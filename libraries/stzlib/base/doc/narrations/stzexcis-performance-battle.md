# The Performance Battle: A Window into EXCIS system in Softanza

Softanza EXCIS, built on the `stzExtCode` class, makes it effortless to embed and execute code from multiple languages within a Ring program.

Add example here...

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