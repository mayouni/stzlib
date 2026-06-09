# Narrative
# --------
# Basic Web API Concepts
#
# Extracted from stzextercodetest.ring, block #38.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

# Example 3: Basic Web API Concepts (Simplified Further)
njs = new stzExterCode("nodejs")
njs.SetCode('
// Define a simple API with routes
const routes = [
  { path: "/api/users", method: "GET" },
  { path: "/api/users/:id", method: "GET" },
  { path: "/api/users", method: "POST" }
];

// Sample user data
const users = [
  { id: 1, name: "Alice", role: "admin" },
  { id: 2, name: "Bob", role: "user" }
];

// Simulated request handler
function handleRequest(path, method, body = null) {
  // Simple router
  if (path === "/api/users" && method === "GET") {
    return {
      statusCode: 200,
      data: users
    };
  }
  
  // Handle dynamic path with parameter
  if (path.match(/^\/api\/users\/\d+$/) && method === "GET") {
    const userId = parseInt(path.split("/").pop());
    const user = users.find(u => u.id === userId);
    
    if (user) {
      return {
        statusCode: 200,
        data: user
      };
    } else {
      return {
        statusCode: 404,
        error: "User not found"
      };
    }
  }
  
  // Handle POST request
  if (path === "/api/users" && method === "POST") {
    const newUser = {
      id: users.length + 1,
      ...body
    };
    
    return {
      statusCode: 201,
      data: newUser
    };
  }
  
  return {
    statusCode: 404,
    error: "Route not found"
  };
}

// Create a focused result object with only essential data
const res = {
    getAllUsers: handleRequest("/api/users", "GET"),
    getUserById: handleRequest("/api/users/1", "GET"),
    getUserNotFound: handleRequest("/api/users/999", "GET"),
    createUser: handleRequest("/api/users", "POST", { name: "Charlie", role: "editor" })
};
')

njs.Execute()
? @@( njs.Result() )
#--> [
#	[
#		"getAllUsers",
#		[
#			[ "statusCode", 200 ],
#			[
#				"data",
#				[
#					[ [ "id", 1 ], [ "name", "Alice" ], [ "role", "admin" ] ],
#					[ [ "id", 2 ], [ "name", "Bob" ], [ "role", "user" ] ]
#				]
#			]
#		]
#	],
#	[
#		"getUserById",
#		[
#			[ "statusCode", 200 ],
#			[
#				"data",
#				[ [ "id", 1 ], [ "name", "Alice" ], [ "role", "admin" ] ]
#			]
#		]
#	],
#	[
#		"getUserNotFound",
#		[ [ "statusCode", 404 ], [ "error", "User not found" ] ]
#	],
#	[
#		"createUser",
#		[
#			[ "statusCode", 201 ],
#			[
#				"data",
#				[ [ "id", 3 ], [ "name", "Charlie" ], [ "role", "editor" ] ]
#			]
#		]
#	]
# ]
pf()
# Executed in 0.34 second(s) in Ring 1.23
