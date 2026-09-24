# project-s1

A small tool over your workplace, its conditions declared as data.

## What the guard checks

- your folder holds `rule.txt` (one condition, such as `{ @item > 20 }`), `data.txt` (one number per line) and `tool.ring`
- the guard runs `tool.ring` with `$cProjectFolder` set to your folder
- the tool prints `rule: ` followed by the rule it read from `rule.txt`, and `count: ` followed by how many lines of the data satisfy it
