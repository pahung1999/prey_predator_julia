module Model

using Base: @kwdef
using Agents
using Distributions

const LIST_SPECIES= (:tiger, :leopard, :boar)

const DEFAULT_MAX_ENERGY= Dict(:tiger => 1.0,  :boar => 0.6,  :leopard => 0.8) 
const DEFAULT_ENERGY_TRANSFERT = Dict(:tiger => 0.5,  :boar => 0.15,  :leopard => 0.4)
const DEFAULT_REPRODUCE_PROBA= Dict(:tiger => 0.005,  :boar => 0.01,  :leopard => 0.005)
const DEFAULT_REPRODUCE_ENERGY= Dict(:tiger => 0.5,  :boar => 0.3,  :leopard => 0.4)
const DEFAULT_ENERGY_CONSUME = Dict(:tiger => 0.02,  :boar => 0.015,  :leopard => 0.016)
const MAX_OFFSPRING = Dict(:tiger => 2,  :boar => 6,  :leopard => 4)

const DEFAULT_LIFESPAN = Dict(:tiger => (15*365),  :boar => (12*365),  :leopard => (14*365))
const DEFAULT_CATCH_PROB = Dict(:tiger => 0.9, :leopard => 0.9)

@kwdef struct ModelParams
	energy_consum::Dict{Symbol, Float16} = DEFAULT_ENERGY_CONSUME
	max_energy::Dict{Symbol, Float16} = DEFAULT_MAX_ENERGY
	proba_reproduce::Dict{Symbol, Float16} = DEFAULT_REPRODUCE_PROBA
	max_offsprings::Dict{Symbol, Int16} = MAX_OFFSPRING
	energy_reproduce::Dict{Symbol, Float16} = DEFAULT_REPRODUCE_ENERGY
	max_food::Float16 = 1
	catch_prob::Dict{Symbol, Float16} = DEFAULT_CATCH_PROB
	lifespan::Dict{Symbol, Int16} = DEFAULT_LIFESPAN
	energy_transfert::Dict{Symbol, Float16} = DEFAULT_ENERGY_TRANSFERT
	fight_prob::Float16 = 0.15
	# Initial params
	grid_size::Tuple{Int, Int}
	num_init_tiger::Int
	num_init_boar::Int
end


@agent Animal GridAgent{2} begin
	species::Symbol
	energy::Float16
	age::Int16
end

include("./move_animal.jl")
include("./eat_prey.jl")
include("./agent_step.jl")

#Hàm tạo loài
function animal(id, pos, species; energy = rand(0:0.1:1), age = 0)
	Animal(id, pos, species, DEFAULT_MAX_ENERGY[species], age)
end

function tiger(id, pos; energy = rand(0:0.1:1), age = 0)
	Animal(id, pos, :tiger, energy, age)
end

function boar(id, pos; energy = rand(0:0.1:1), age = 0)
	Animal(id, pos, :boar, energy, age)
end

function leopard(id, pos; energy = rand(0:0.1:1), age = 0)
	Animal(id, pos, :leopard, energy, age)
end


function is_not_tiger(agent)
	agent.species != :tiger
end

#Hàm đếm số lượng
function count_species(model)
	Dict(
		species => [
			count(
				agent -> agent.species == species, 
				agents_in_position(Tuple(I), model))
			for I in CartesianIndices(model.food)
		]
		for species in LIST_SPECIES
	)
end

function count_species(size::Tuple)
	Dict(
		species => zeros(Int, size)
		for species in LIST_SPECIES
	)
end


	
# function count_agent(model)
# 	agent_at
	
function model_step!(model)
	params = model.params
	model.x = rand()
	model.count_species = count_species(model)
	@. model.food = min(model.food + 0.01, params.max_food)
end


function is_species(species)
	return agent -> agent.species == species
end



@kwdef mutable struct ModelProperties
	params::ModelParams
	food::Matrix{Float16}
	count_species::Dict{Symbol, Matrix{Int}}
	x::Float16 = 1
end



function init_model(params)
	FloatType = typeof(params.max_energy[:tiger])
	space = GridSpace(params.grid_size; periodic=false)
	props = ModelProperties(
		params=params, 
		count_species=count_species(params.grid_size),
		food=ones(params.grid_size))
	model = AgentBasedModel(Animal, space; properties=props)

	for _ in 1:params.num_init_tiger
		id = nextid(model)
		pos = random_position(model)
		add_agent!(animal(id, pos, :tiger), model)
		id = nextid(model)
		add_agent!(animal(id, pos, :leopard), model)
	end
	for _ in 1:params.num_init_boar
		id = nextid(model)
		pos = random_position(model)
		add_agent!(animal(id, pos, :boar), model)
	end
	model.count_species = count_species(model)
	
	model , agent_step!, model_step! 
end




end 