# Narrative
# --------
# Mixed data types
#
# Extracted from stzextercodetest.ring, block #34.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

njs = new stzExterCode("nodejs")
njs.SetCode('

// Create a complex object with various data types
const res = {
    name: "Product Catalog",
    items: [
        {
            id: 101,
            name: "Laptop",
            price: 1299.99,
            inStock: true,
            specs: {
                cpu: "Intel i7",
                ram: "16GB",
                storage: "512GB SSD"
            }
        },
        {
            id: 102,
            name: "Smartphone",
            price: 899.99,
            inStock: false,
            specs: {
                cpu: "A15 Bionic",
                ram: "8GB",
                storage: "256GB"
            }
        }
    ],
    lastUpdated: "2024-02-28"
};

') # End of NodeJS code

njs.Execute()
? @@( njs.Result() )
#--> [
#	[ "name", "Product Catalog" ],
#	[
#		"items",
#		[
#			[
#				[ "id", 101 ],
#				[ "name", "Laptop" ],
#				[ "price", 1299.99 ],
#				[ "inStock", 1 ],
#				[
#					"specs",
#					[ [ "cpu", "Intel i7" ], [ "ram", "16GB" ], [ "storage", "512GB SSD" ] ]
#				]
#			],
#			[
#				[ "id", 102 ],
#				[ "name", "Smartphone" ],
#				[ "price", 899.99 ],
#				[ "inStock", 0 ],
#				[
#					"specs",
#					[ [ "cpu", "A15 Bionic" ], [ "ram", "8GB" ], [ "storage", "256GB" ] ]
#				]
#			]
#		]
#	],
#	[ "lastUpdated", "2024-02-28" ]
# ]

pf()
# Executed in 0.34 second(s) in Ring 1.23
