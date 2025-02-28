const { transform_to_ring, writeResultToFile } = (() => {

const fs = require("fs");

function transform_to_ring(data) {
    return _transform(data, 0);
}

function _transform(obj, depth = 0) {
    // Prevent excessive recursion
    if (depth > 100) {
        return "TOO_DEEP";
    }
    
    // Handle null and undefined
    if (obj === null || obj === undefined) {
        return "NULL";
    }
    
    // Handle objects (including arrays)
    if (typeof obj === "object") {
        if (Array.isArray(obj)) {
            // Transform array
            const items = obj.map(item => _transform(item, depth + 1));
            return "[" + items.join(", ") + "]";
        } else {
            // Transform object as key-value pairs
            const items = [];
            for (const key in obj) {
                if (Object.prototype.hasOwnProperty.call(obj, key)) {
                    items.push(`['${key}', ${_transform(obj[key], depth + 1)}]`);
                }
            }
            return "[" + items.join(", ") + "]";
        }
    }
    
    // Handle strings
    if (typeof obj === "string") {
        return `'${obj}'`;
    }
    
    // Handle numbers
    if (typeof obj === "number") {
        // Convert to string to check for scientific notation
        const strVal = String(obj);
        if (strVal.includes("e") || strVal.includes("E")) {
            return `'${strVal}'`;
        }
        return strVal;
    }
    
    // Handle booleans
    if (typeof obj === "boolean") {
        return obj ? "TRUE" : "FALSE";
    }
    
    // Default case
    return `'${String(obj)}'`;
}

// Function to write results to file
function writeResultToFile(data, filename) {
    const result = transform_to_ring(data);
    fs.writeFileSync(filename, result);
    console.log(`Result written to ${filename}`);
}

module.exports = {
    transform_to_ring,
    writeResultToFile
};

    return { transform_to_ring, writeResultToFile };
})();

console.log("NodeJS script starting...");

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

console.log("Writing results to file...");
writeResultToFile(res, "jsresult.txt");
console.log("Data written to file");
