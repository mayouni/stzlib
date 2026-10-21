The K4 twenty tasks, exported as data on 2026-10-21 from the Ring++ session (ringpp haro/spike/v22/k4, tasks.py + expected.json,
prompts and grammar as the local K4 round for Qwen2.5-Coder-1.5B used them: runtime/k4work/qwen25c-1.5b-on).
p_Txx.txt   the ChatML prompt: primer + one worked example + the task, data lines written at the head of the answer
ringpp.gbnf the Ring++ shape grammar (ends with a line holding only <<END>>)
tasks.txt   per task: @a shown data, @b hidden data, @ea / @eb what the reference prints on each
A program PASSES when it prints @ea on the shown data and @eb on the hidden data (judged on rnxc).
