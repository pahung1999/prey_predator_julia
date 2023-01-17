module Model

using Base: @kwdef
using Agents
using Distributions

const LIST_SPECIES= (:tiger, :leopard, :boar)

const DEFAULT_MAX_ENERGY= Dict(		   :boar => 0.6,     :tiger => 1.0,      :leopard => 0.8) 
const DEFAULT_ENERGY_TRANSFERT = Dict( :boar => 0.15,    :tiger => 0.5,      :leopard => 0.4)
const DEFAULT_ENERGY_CONSUME = Dict(   :boar => 0.015,   :tiger => 0.02,    :leopard => 0.016)
const DEFAULT_REPRODUCE_PROBA= Dict(   :boar => 0.01,    :tiger => 0.005,    :leopard => 0.005)
const MAX_OFFSPRING =      Dict(       :boar => 6,       :tiger => 2  ,      :leopard => 4)
const DEFAULT_REPRODUCE_ENERGY= Dict(  :boar => 0.3,     :tiger => 0.5,      :leopard => 0.4)
const DEFAULT_CATCH_PROB = Dict(         	 	 	     :tiger => 0.3,     :leopard => 0.35)
const DEFAULT_LIFESPAN = Dict(  	   :boar =>(12*365), :tiger => (15*365), :leopard => (14*365))

# Dữ liệu gốc
# const DEFAULT_MAX_ENERGY= Dict(		   :boar => 1.0,     :tiger => 1.0,      :leopard => 0.8) 
# const DEFAULT_ENERGY_TRANSFERT = Dict( :boar => 0.15,    :tiger => 0.4,      :leopard => 0.36)
# const DEFAULT_ENERGY_CONSUME = Dict(   :boar => 0.02,    :tiger => 0.015,    :leopard => 0.0132)
# const DEFAULT_REPRODUCE_PROBA= Dict(   :boar => 0.012,   :tiger => 0.002,    :leopard => 0.003)
# const DEFAULT_REPRODUCE_ENERGY= Dict(  :boar => 0.7,     :tiger => 0.6,      :leopard => 0.48)
# const DEFAULT_CATCH_PROB = Dict(         	 	 	     :tiger => 0.28,     :leopard => 0.31)
# const DEFAULT_LIFESPAN = Dict(  	   :boar =>(12*365), :tiger => (15*365), :leopard => (14*365))

#Dữ liệu "ngon"
# const DEFAULT_MAX_ENERGY= Dict(		   :boar => 0.6,     :tiger => 1.0,      :leopard => 0.8) 
# const DEFAULT_ENERGY_TRANSFERT = Dict( :boar => 0.15,    :tiger => 0.5,      :leopard => 0.4)
# const DEFAULT_ENERGY_CONSUME = Dict(   :boar => 0.015,   :tiger => 0.02,    :leopard => 0.016)
# const DEFAULT_REPRODUCE_PROBA= Dict(   :boar => 0.01,    :tiger => 0.005,    :leopard => 0.005)
# const MAX_OFFSPRING =      Dict(       :boar => 6,       :tiger => 2  ,      :leopard => 4)
# const DEFAULT_REPRODUCE_ENERGY= Dict(  :boar => 0.3,     :tiger => 0.5,      :leopard => 0.4)
# const DEFAULT_CATCH_PROB = Dict(         	 	 	     :tiger => 0.3,     :leopard => 0.35)
# const DEFAULT_LIFESPAN = Dict(  	   :boar =>(12*365), :tiger => (15*365), :leopard => (14*365))

const DEFAULT_GROW_SPEED = 0.01



@kwdef struct ModelParams
	energy_consum::Dict{Symbol, Float16} = DEFAULT_ENERGY_CONSUME
	max_energy::Dict{Symbol, Float16} = DEFAULT_MAX_ENERGY
	lifespan::Dict{Symbol, Int32} = DEFAULT_LIFESPAN

	# produce_age::Dict{Symbol, Int16} = DEFAULT_PRODUCE_AGE
	proba_reproduce::Dict{Symbol, Float16} = DEFAULT_REPRODUCE_PROBA
	max_offsprings::Dict{Symbol, Int16} = MAX_OFFSPRING
	energy_reproduce::Dict{Symbol, Float16} = DEFAULT_REPRODUCE_ENERGY

	grow_speed::Float16 = DEFAULT_GROW_SPEED
	max_food::Float16 = 1
	energy_transfert::Dict{Symbol, Float16} = DEFAULT_ENERGY_TRANSFERT

	catch_prob::Dict{Symbol, Float16} = DEFAULT_CATCH_PROB
	
	# Initial params
	grid_size::Tuple{Int, Int}
	num_init_tiger::Int
	num_init_boar::Int
	num_init_leopard::Int

end


@agent Animal GridAgent{2} begin
	species::Symbol
	energy::Float16
	age::Int16
end

include("./move_animal.jl")
include("./eat_prey.jl")
include("./agent_step.jl")
include("./sub_function.jl")
include("./agent_move.jl")
include("./agent_eat.jl")
include("./agent_reproduce.jl")
include("./scheduler.jl")
#Hàm tạo loài
function animal(id, pos, species, energy, age = 0)
	Animal(id, pos, species, energy, age)
end

# function tiger(id, pos; energy = rand(0:0.1:1), age = 0)
# 	Animal(id, pos, :tiger, energy, age)
# end

# function boar(id, pos; energy = rand(0:0.1:1), age = 0)
# 	Animal(id, pos, :boar, energy, age)
# end

# function leopard(id, pos; energy = rand(0:0.1:1), age = 0)
# 	Animal(id, pos, :leopard, energy, age)
# end


function is_not_tiger(agent)
	agent.species != :tiger
end

# Hàm đếm số lượng
function count_species(model)
	Dict(
		species => count(
			id -> model[id].species == species, 
			collect(allids(model)))

		for species in LIST_SPECIES
	)
end

function count_species(size::Tuple)
	Dict(
		# species => zeros(Int, size)
		species => 0
		for species in LIST_SPECIES
	)
end


	
# function count_agent(model)
# 	agent_at
	


function is_species(species)
	return agent -> agent.species == species
end



@kwdef mutable struct ModelProperties
	params::ModelParams
	food::Matrix{Float16}
	count_species::Dict{Symbol, Int}
	# x::Float16 = 1
	step_num::Int16 = 0
	death_list::Array{Int} = []

	fight_prob::Float32 = 0.15
end





function init_model(params)
	
	FloatType = typeof(params.max_energy[:tiger])
	space = GridSpace(params.grid_size; periodic=false)
	props = ModelProperties(
		params=params, 
		count_species=count_species(params.grid_size),
		food=ones(params.grid_size),
		)
	model = AgentBasedModel(Animal, space; properties=props) #scheduler = spiece_scheduler
	max_energy=params.max_energy

	

	for _ in 1:params.num_init_boar
		id = nextid(model)
		pos = random_position(model)
		add_agent!(animal(id, pos, :boar,rand(model.rng,Uniform(0.5,1))*max_energy[:boar]), model)
	end
	for _ in 1:params.num_init_tiger
		id = nextid(model)
		pos = random_position(model)
		add_agent!(animal(id, pos, :tiger, rand(model.rng,Uniform(0.5,1))*max_energy[:tiger]), model)
	end
	for _ in 1:params.num_init_leopard
		pos = random_position(model)
		id = nextid(model)
		add_agent!(animal(id, pos, :leopard,rand(model.rng,Uniform(0.5,1))*max_energy[:leopard]), model)
	end
	
	model.count_species = count_species(model)
	
	# print("model.count_species: ",model.count_species)
	# model , agent_step!, model_step! ,spiece_scheduler
	
	model, dummystep, complex_step!
	# agent_eat!, agent_reproduce!
	# model ,agent_move!,model_step! 
end


end 