# Narrative
# --------
# Data Processing with Modern JavaScript
#
# Extracted from stzextercodetest.ring, block #37.

load "../../stzBase.ring"


pr()

njs = new stzExterCode("nodejs")
njs.SetCode('

// Sample dataset for processing
const dataset = [
  { category: "Electronics", price: 1200, stock: 45, rating: 4.5 },
  { category: "Books", price: 25, stock: 200, rating: 4.8 },
  { category: "Clothing", price: 85, stock: 30, rating: 3.9 },
  { category: "Electronics", price: 800, stock: 10, rating: 4.2 },
  { category: "Books", price: 30, stock: 65, rating: 4.0 }
];

// Using modern JS features for data transformation
const res = {
  // Group items by category with aggregated metrics
  categorySummary: Object.entries(dataset.reduce((acc, item) => {
    if (!acc[item.category]) {
      acc[item.category] = { count: 0, totalValue: 0, avgRating: 0 };
    }
    
    acc[item.category].count += 1;
    acc[item.category].totalValue += (item.price * item.stock);
    acc[item.category].avgRating = 
      ((acc[item.category].avgRating * (acc[item.category].count - 1)) + item.rating) / acc[item.category].count;
    
    return acc;
  }, {})),
  
  // Find high-value items (price * stock > 1000)
  highValueItems: dataset
    .filter(item => item.price * item.stock > 1000)
    .map(item => ({
      category: item.category,
      totalValue: item.price * item.stock
    })),
    
  // Total inventory value
  totalInventoryValue: dataset.reduce((sum, item) => sum + (item.price * item.stock), 0)
};
')

njs.Execute()
? @@( njs.Result() )
#--> [
#	[
#		"categorySummary",
#		[
#			[
#				"Electronics",
#				[ [ "count", 2 ], [ "totalValue", 62000 ], [ "avgRating", 4.35 ] ]
#			],
#			[
#				"Books",
#				[ [ "count", 2 ], [ "totalValue", 6950 ], [ "avgRating", 4.40 ] ]
#			],
#			[
#				"Clothing",
#				[ [ "count", 1 ], [ "totalValue", 2550 ], [ "avgRating", 3.90 ] ]
#			]
#		]
#	],
#	[
#		"highValueItems",
#		[
#			[ [ "category", "Electronics" ], [ "totalValue", 54000 ] ],
#			[ [ "category", "Books" ], [ "totalValue", 5000 ] ],
#			[ [ "category", "Clothing" ], [ "totalValue", 2550 ] ],
#			[ [ "category", "Electronics" ], [ "totalValue", 8000 ] ],
#			[ [ "category", "Books" ], [ "totalValue", 1950 ] ]
#		]
#	],
#	[ "totalInventoryValue", 71500 ]
# ]

pf()
# Executed in 0.40 second(s) in Ring 1.23
