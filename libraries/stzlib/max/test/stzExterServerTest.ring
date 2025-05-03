// stzExterServer Test Samples
// A collection of practical examples using the stzExterServer class

load "stzexterserver.ring"

/*--- Initialize and manage language servers
*/
pr()

XS = new stzExterServer("127.0.0.1")
XS {
    // Only start specific servers to save resources
    startServer("python")
    startServer("nodejs")
    startServer("sqlite")
    
    // Check health of servers
    ? "Server Health:"
    ? "Python: " + getServerHealth("python")
    ? "NodeJS: " + getServerHealth("nodejs")  
    ? "SQLite: " + getServerHealth("sqlite")
    ? "R: " + getServerHealth("r")  // Should be false, we didn't start it
    
    // List available code language servers
    See nl + "Available Language Servers:" + nl
    langs = getAvailableLanguages()
    for lang in langs
        ? "- " + lang["name"] + " (ID: " + lang["id"] + "): " + 
          (lang["status"] ? "Running" : "Not Running")
    next
    
    // Shutdown a specific server
    shutdownServer("nodejs")
    ? nl + "NodeJS server after shutdown: " + (getServerHealth("nodejs") ? "Running" : "Stopped")
    
    // Finally, shutdown all servers
    shutdown()
}

pf()
# Execution time: ~1.2 seconds

/*--- Execute Python code
pr()

XS = new stzExterServer()
XS {
    startServer("python")
    
    pythonCode = `
import numpy as np

def calculate_statistics(data):
    return {
        "mean": np.mean(data),
        "median": np.median(data),
        "std": np.std(data),
        "min": np.min(data),
        "max": np.max(data)
    }

result = calculate_statistics([10, 20, 30, 40, 50, 60, 70, 80, 90, 100])
`
    
    response = executePython(pythonCode)
    
    if response["status"] = "success"
        ? "Python Execution Results:"
        stats = response["result"]
        ? "Mean: " + stats["mean"]
        ? "Median: " + stats["median"]
        ? "Standard Deviation: " + stats["std"]
        ? "Min: " + stats["min"]
        ? "Max: " + stats["max"]
    else
        ? "Error: " + response["error"]
    ok
    
    shutdown()
}

pf()
# Execution time: ~0.8 seconds

/*--- Execute NodeJS with parameters
pr()

XS = new stzExterServer()
XS {
    startServer("nodejs")
    
    // Define the Node.js code to execute
    nodeCode = `
const names = params.names;
const greeting = params.greeting || "Hello";

// Process the names and create greetings
const result = names.map(name => `${greeting}, ${name}!`);

// Return the result
`
    
    // Define parameters to pass to the code
    params = {
        "names": ["John", "Sarah", "Michael", "Emma"],
        "greeting": "Welcome"
    }
    
    // Execute the code
    response = executeNodeJS(nodeCode, params)
    
    if response["status"] = "success"
        ? "NodeJS Execution Results:"
        greetings = response["result"]
        for greeting in greetings
            ? greeting
        next
    else
        ? "Error: " + response["error"]
    ok
    
    shutdown()
}

pf()
# Execution time: ~0.7 seconds

/*--- Execute SQL query
pr()

XS = new stzExterServer()
XS {
    startServer("sqlite")
    
    // Define an SQL query to create a table and insert data
    sqlSetup = `
CREATE TABLE IF NOT EXISTS employees (
    id INTEGER PRIMARY KEY,
    name TEXT,
    department TEXT,
    salary REAL
);

DELETE FROM employees;

INSERT INTO employees (name, department, salary) VALUES 
    ('Alice', 'Engineering', 85000),
    ('Bob', 'Marketing', 72000),
    ('Charlie', 'Engineering', 92000),
    ('Diana', 'HR', 65000),
    ('Edward', 'Engineering', 78000);

SELECT 'Database setup complete' as message;
`
    
    // Execute setup query
    setupResult = executeSQL("sqlite", sqlSetup)
    ? "Setup Result: " + setupResult["result"][1]["message"]
    
    // Query to analyze employee data
    sqlQuery = `
SELECT 
    department,
    COUNT(*) as employee_count,
    AVG(salary) as avg_salary,
    MAX(salary) as max_salary,
    MIN(salary) as min_salary
FROM employees
GROUP BY department
ORDER BY avg_salary DESC;
`
    
    // Execute the analysis query
    response = executeSQL("sqlite", sqlQuery)
    
    if response["status"] = "success"
        ? nl + "Department Analysis:"
        for dept in response["result"]
            ? "Department: " + dept["department"]
            ? "- Employee Count: " + dept["employee_count"]
            ? "- Average Salary: $" + dept["avg_salary"]
            ? "- Salary Range: $" + dept["min_salary"] + " - $" + dept["max_salary"]
            ? ""
        next
    else
        ? "Error: " + response["error"]
    ok
    
    shutdown()
}

pf()
# Execution time: ~0.9 seconds

/*--- Execute LLM prompt
pr()

XS = new stzExterServer()
XS {
    startServer("lightllm")
    
    // Define a prompt for the LLM
    prompt = "Create a short poem about programming in multiple languages."
    
    // Set parameters for the LLM
    params = {
        "temperature": 0.7,
        "max_tokens": 150
    }
    
    // Execute the LLM
    response = executeLLM("lightllm", prompt, params)
    
    if response["status"] = "success"
        ? "LLM Generated Poem:"
        ? response["result"]
    else
        ? "Error: " + response["error"]
    ok
    
    shutdown()
}

pf()
# Execution time: ~1.5 seconds

/*--- Multi-language integration
pr()

XS = new stzExterServer()
XS {
    startServer("python")
    startServer("nodejs")
    
    // Step 1: Generate data with Python
    pythonCode = `
import numpy as np
import json

# Generate random sales data
np.random.seed(42)
months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
          
sales_data = {
    month: round(float(np.random.normal(10000, 2000)), 2) 
    for month in months
}

result = sales_data
`
    python_result = executePython(pythonCode)
    sales_data = python_result["result"]
    
    ? "Python Generated Sales Data:"
    ? list2json(sales_data)
    
    // Step 2: Process the data with Node.js
    nodeCode = `
// Convert sales data to the format needed for analysis
const salesData = params.salesData;
const months = Object.keys(salesData);

// Calculate key metrics
let total = 0;
let highest = { month: '', value: 0 };
let lowest = { month: '', value: Number.MAX_VALUE };

for (let month of months) {
    const value = salesData[month];
    total += value;
    
    if (value > highest.value) {
        highest = { month, value };
    }
    
    if (value < lowest.value) {
        lowest = { month, value };
    }
}

const average = total / months.length;

// Format currency values
const formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD'
});

// Prepare the report
result = {
    totalSales: formatter.format(total),
    averageMonthlySales: formatter.format(average),
    highestMonth: {
        month: highest.month,
        sales: formatter.format(highest.value)
    },
    lowestMonth: {
        month: lowest.month,
        sales: formatter.format(lowest.value)
    }
};
`
    
    // Pass the Python-generated data to Node.js
    node_params = { "salesData": sales_data }
    node_result = executeNodeJS(nodeCode, node_params)
    
    ? nl + "Node.js Processed Sales Report:"
    report = node_result["result"]
    ? "Total Annual Sales: " + report["totalSales"]
    ? "Average Monthly Sales: " + report["averageMonthlySales"]
    ? "Best Month: " + report["highestMonth"]["month"] + " with " + report["highestMonth"]["sales"]
    ? "Worst Month: " + report["lowestMonth"]["month"] + " with " + report["lowestMonth"]["sales"]
    
    shutdown()
}

pf()
# Execution time: ~1.1 seconds

/*--- Language Server Manager Status Dashboard
pr()

XS = new stzExterServer()
XS {
    // Start a few servers
    startServer("python")
    startServer("sqlite")
    startServer("lightllm")
    
    // Generate a dashboard of server status
    serverCategories = {
        "code": getCodeServers(),
        "sql": getSQLServers(),
        "llm": getLLMServers()
    }
    
    ? "===== EXCIS SERVER STATUS DASHBOARD ====="
    ? "Date: " + date() + " | Time: " + time()
    ? "========================================"
    
    for category in serverCategories
        catName = category[1]
        servers = category[2]
        
        ? nl + "[ " + upper(catName) + " SERVERS ]"
        ? "--------------------------"
        
        for server in servers
            status = server.checkHealth()
            statusText = status ? "✓ ONLINE" : "✗ OFFLINE"
            
            if status
                ? server.name + " (" + server.id + "): " + statusText
            else
                ? server.name + " (" + server.id + "): " + statusText + " -> " + server.host + ":" + server.port
            ok
        next
    next
    
    ? nl + "========================================" 
    ? "Total Servers: " + len(servers)
    ? "Active Servers: " + len(getAllServersHealth().filter(:value = true))
    
    shutdown()
}

pf()
# Execution time: ~0.6 seconds

/*--- Supabase Authentication Example
pr()

XS = new stzExterServer()
XS {
    // Configure Supabase
    configureSupabase(
        "https://your-project-id.supabase.co",
        "your-supabase-api-key"
    )
    
    // Start the Supabase server
    startServer("supabase")
    
    // Register a new user
    signupResult = auth().signUp(
        "user@example.com",
        "securepassword123",
        { "data": { "name": "John Doe", "role": "customer" } }
    )
    
    if signupResult["status"] = "success"
        ? "User registration successful!"
        ? "User ID: " + signupResult["result"]["user"]["id"]
        
        // Sign in with the new account
        signinResult = auth().signIn("user@example.com", "securepassword123")
        
        if signinResult["status"] = "success"
            ? "Login successful!"
            ? "Access Token: " + signinResult["result"]["access_token"][:10] + "..."
            
            // Get user profile
            jwt = signinResult["result"]["access_token"]
            userResult = auth().getUser(jwt)
            
            if userResult["status"] = "success"
                ? "User Profile:"
                ? "Email: " + userResult["result"]["email"]
                ? "Name: " + userResult["result"]["user_metadata"]["name"]
                ? "Role: " + userResult["result"]["user_metadata"]["role"]
            ok
            
            // Sign out
            auth().signOut(jwt)
            ? "User signed out successfully!"
        else
            ? "Login failed: " + signinResult["error"]
        ok
    else
        ? "Registration failed: " + signupResult["error"]
    ok
    
    shutdown()
}

pf()
# Execution time: ~1.0 seconds

/*--- Supabase Database Operations
pr()

XS = new stzExterServer()
XS {
    // Configure Supabase
    configureSupabase(
        "https://your-project-id.supabase.co",
        "your-supabase-api-key"
    )
    
    // Start the Supabase server
    startServer("supabase")
    
    // Insert data into a table
    productData = {
        "name": "Ergonomic Chair",
        "description": "Office chair with lumbar support",
        "price": 299.99,
        "stock": 15,
        "category": "furniture"
    }
