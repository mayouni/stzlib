load "../stzbase.ring"

/*---
*/

pr()

Rs = new stzReactiveSystem()
Rs {
    // Create a task to compute a score
    task = CreateTask("compute_score", func {
        return 1000 + random(500) // Simulate a score calculation
    })
    
    task.Then_(func(score) {
        ? "Player score: " + score
    }).Catch_(func(error) {
        ? "Oops, score calc failed: " + error
    })
    
    Start()
}

// Output: Player score: 1234 (or some random score)

pf()
