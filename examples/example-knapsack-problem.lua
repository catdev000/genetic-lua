local inspect = require 'inspect'

stuff = {
  { "book", 23 },
  { "mobile phone", 12 },
  { "tablet", 19 },
  { "food", 23 },
  { "drink", 25 },
  { "flowers", 14 },
  { "pencil", 2 }
}
local treshold = 100
local knapsack = {}

local function evaluate(variation)
  local score = 0
  
  for k, v in pairs(variation) do
    score = score + variation[k] * stuff[k][2] 
  end
  
  if score >= treshold then
    score = 0
  end

  return score
end

local best_variation = require("ga").init_ga(
  20, -- generations_count
  30, -- variations_count
  7, -- chromosomes_length
  0, -- chromosome_lowest_value
  1, -- chromosome_highest_value
  evaluate, -- your custom function to evaluate the fitness of the generations based on the task
  0.1 -- mutation rate of each gene (optional)
)

print("Best Variation: " .. inspect(best_variation))
print("Best variation score: " .. evaluate(best_variation))

for i = 1, #stuff do
  if best_variation[i] == 1 then
    table.insert(knapsack, stuff[i])
  end
end

print("The knapsack now contains: " .. inspect(knapsack))
