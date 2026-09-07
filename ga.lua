local M = {}

local function generate_random_generation(variations_count, chromosomes_length, chromosome_lowest_value, chromosome_highest_value)
  local pool = {}
  local chromosomes = {}
  for i = 1, variations_count do 
    for j = 1, chromosomes_length do
      table.insert(chromosomes, math.random(chromosome_lowest_value, chromosome_highest_value))
    end
    table.insert(pool, chromosomes)
    chromosomes = {}
  end
  return pool
end

local function evaluate_fitness(pool, evaluate_fitness_function)
  local evaluations = {}

  for i, x in ipairs(pool) do
    table.insert(evaluations, evaluate_fitness_function(pool[i]))
  end

  return evaluations
end

local function filter_best(pool, evaluation)
  local highest = -math.huge
  local secondHighest = -math.huge
  local highestIdx = nil
  local secondHighestIdx = nil

  for i, v in ipairs(evaluation) do
    if v > highest then
        secondHighest = highest
        secondHighestIdx = highestIdx
        highest = v
        highestIdx = i
    elseif v > secondHighest and v ~= highest then
        secondHighest = v
        secondHighestIdx = i
    end
  end

  return { pool[highestIdx], pool[secondHighestIdx] }
end

local function generate_mutated_generation(
  pool, 
  variations_count, 
  chromosomes_length, 
  chromosome_lowest_value, 
  chromosome_highest_value,
  mutation_rate
)

  local length_chromosomes = #pool[1]
  local randomSplitIndex = math.random(1, length_chromosomes)

  local combined_parent = {} -- combine chromosomes of both parents at randomSplitIndex
  for k, v in ipairs(pool[1]) do
    if randomSplitIndex >= k then
      table.insert(combined_parent, pool[1][k])
    end
  end
  for k, v in ipairs(pool[2]) do
    if randomSplitIndex < k then
      table.insert(combined_parent, pool[2][k])
    end
  end
  
  local new_pool = {}
  local new_variation = {}

  -- "clone" parents to avoid reduction of fitness
  table.insert(new_pool, pool[1])
  table.insert(new_pool, pool[2])
  variations_count = variations_count - 2

  -- generate new mutations
  for i = 1, variations_count do
    for j = 1, #combined_parent do
      if math.random() < mutation_rate then
        table.insert(new_variation, math.random(chromosome_lowest_value, chromosome_highest_value))
      else
        table.insert(new_variation, combined_parent[j])
      end
    end
    table.insert(new_pool, new_variation)
    new_variation = {}
  end

  return new_pool
end

function M.init_ga(
  generations_count,
  variations_count,
  chromosomes_length,
  chromosome_lowest_value,
  chromosome_highest_value,
  evaluate_fitness_function,
  gene_mutation_rate
)
  -- error handling
  if generations_count == nil or variations_count == nil or chromosomes_length == nil or chromosome_lowest_value == nil or chromosome_highest_value == nil or evaluate_fitness_function == nil then
    error("Please set generations_count, variations_count, chromosomes_length, chromosome_lowest_value, chromosome_highest_value and the function to evaluate the fitness of a variation")
  end

  if variations_count < 2 then
    error("variations_count must be at least 2")
  end
  
  local pool = {}
  local evaluation = {}
  local mutation_rate = gene_mutation_rate or 0.1

  pool = generate_random_generation(variations_count, chromosomes_length, chromosome_lowest_value, chromosome_highest_value)
    
  for i = 2, generations_count do
    evaluation = evaluate_fitness(pool, evaluate_fitness_function)
    pool = filter_best(pool, evaluation)
    pool = generate_mutated_generation(
      pool, 
      variations_count, 
      chromosomes_length, 
      chromosome_lowest_value, 
      chromosome_highest_value, 
      mutation_rate
    )
  end
  
  pool = filter_best(pool, evaluation)
  return pool[1]
end


return M
