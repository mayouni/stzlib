# Narrative
# --------
# Asynchronous Operations with Promises
#
# Extracted from stzextercodetest.ring, block #36.

load "../../../stzBase.ring"


pr()

njs = new stzExterCode("nodejs")
njs.SetCode('
// Asynchronous operations are a core strength of NodeJS
// This example demonstrates handling multiple async operations

// Helper function to simulate API calls or async tasks
const simulateTask = (name, delay, data) => {
  return new Promise(resolve => {
    setTimeout(() => {
      console.log(`Task ${name} completed after ${delay}ms`);
      resolve(data);
    }, delay);
  });
};

// Function to execute multiple tasks in different ways
async function demonstrateAsync() {
  const startTime = Date.now();
  
  // Method 1: Sequential execution (tasks wait for each other)
  const task1Result = await simulateTask("1-Database", 300, { rows: 10, source: "users_db" });
  const task2Result = await simulateTask("2-API", 200, { status: 200, items: ["item1", "item2"] });
  const task3Result = await simulateTask("3-Cache", 100, { hit: true, value: "cached_data" });
  
  const sequentialTime = Date.now() - startTime;
  
  // Method 2: Parallel execution (all tasks run concurrently)
  const parallelStart = Date.now();
  
  const [task4Result, task5Result, task6Result] = await Promise.all([
    simulateTask("4-Database", 300, { rows: 10, source: "users_db" }),
    simulateTask("5-API", 200, { status: 200, items: ["item1", "item2"] }),
    simulateTask("6-Cache", 100, { hit: true, value: "cached_data" })
  ]);
  
  const parallelTime = Date.now() - parallelStart;
  
  return {
    sequentialExecution: {
      results: [task1Result, task2Result, task3Result],
      totalTime: sequentialTime,
      explanation: "Tasks run one after another, waiting for each to complete"
    },
    parallelExecution: {
      results: [task4Result, task5Result, task6Result],
      totalTime: parallelTime,
      explanation: "All tasks run simultaneously, finishing in the time of the longest task",
      speedImprovement: `${Math.round((sequentialTime / parallelTime) * 100) / 100}x faster than sequential`
    },
    benefits: [
      "Non-blocking I/O means server keeps handling requests",
      "Efficient resource usage during wait times",
      "Perfect for API integrations, database queries, and network operations"
    ]
  };
}

// Create an expressive res object
const res = { 
  title: "NodeJS Asynchronous Operations Demonstration",
  description: "Showcasing how NodeJS handles concurrent tasks efficiently",
  status: "running",
  started: new Date().toISOString()
};

// Execute the async function and update res
demonstrateAsync().then(results => {
  res.status = "complete";
  res.completed = new Date().toISOString();
  res.results = results;
});

') # End of NodeJS code

njs.Execute()
? @@( njs.Result() )
#--> [
#	[ "title", "NodeJS Asynchronous Operations Demonstration" ],
#	[ "description", "Showcasing how NodeJS handles concurrent tasks efficiently" ],
#	[ "status", "running" ],
#	[ "started", "2025-02-28T23:09:58.042Z" ]
# ]

pf()
# Executed in 1.30 second(s) in Ring 1.23
