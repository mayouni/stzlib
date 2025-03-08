# Calculating Numbers Inside a String—Effortlessly!

In Softanza, you can perform calculations directly on numbers within a string,  and the string updates dynamically with the new values!

## Basic calculation

```ring
o1 = new stzString("The total is 42 dollars and 13 cents.")
o1 {

	MultiplyByN(2)
	? Content()
	#--> The total is 84 dollars and 26 cents.

	DivideByN(2)
	? Content()
	#--> The total is 42 dollars and 13 cents.

	AddN(8)
	? Content()
	#--> The total is 50 dollars and 21 cents.

	RetrieveN(12)
	? Content() + NL
	#--> The total is 38 dollars and 9 cents.
}
```

## Extended calculations

Need different calculations for each number?  
Use the e**XT**ended form to apply unique operations to each number in the string!

```ring
o1 = new stzString("The total is 42 dollars and 13 cents.")
o1 {

	MultiplyByNXT([2, 3])  # "42" is multiplied by 2, "13" by 3
	? Content()
	#--> The total is 84 dollars and 39 cents.

	DivideByNXT([2, 3])
	? Content()
	#--> The total is 42 dollars and 13 cents.

	AddNXT([8, 7])
	? Content()
	#--> The total is 50 dollars and 20 cents.

	RetrieveNXT([40, 10])
	? Content()
	#--> The total is 10 dollars and 10 cents.
}

proff()
# Executed in 0.12 second(s) in Ring 1.22
```

## Practical applications

At first glance, this feature might seem almost fantastical—but it's all serious. With it, you can tackle a multitude of small yet critical tasks that would otherwise require extensive code:

- Financial applications: Dynamically adjust price quotes and invoices
- Report generators: Scale statistics across template documents
- E-commerce systems: Apply discounts or taxes to product descriptions
- Scientific software: Update measurement values while preserving units
- Document processors: Recalculate embedded values on the fly
- Data migration: Transform legacy text records with embedded metrics

> **NOTE:** Softanza includes several other functions for managing numbers within strings, such as `Numbers()`, `ExtractNumbers()`, `FindNumbers()`, `RemoveNumbers()`, and `ReplaceNumbers()`, to name a few.