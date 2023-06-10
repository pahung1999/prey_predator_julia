module Model
using Images
using Base: @kwdef
using Agents
using Distributions

const LIST_SPECIES= (:tiger, :leopard, :boar)

const DEFAULT_MAX_ENERGY= Dict(		   :boar => 1.0,     :tiger => 1.0,      :leopard => 1.0) 
const DEFAULT_ENERGY_TRANSFERT = Dict( :boar => 0.3,    :tiger => 0.5,      :leopard => 0.2)
const DEFAULT_ENERGY_CONSUME = Dict(   :boar => 0.018,   :tiger => 0.03,    :leopard => 0.012)
const DEFAULT_REPRODUCE_PROBA= Dict(   :boar => 0.0036,    :tiger => 0.0015,    :leopard => 0.0017)
const MAX_OFFSPRING =      Dict(       :boar => 12,       :tiger => 6  ,      :leopard => 4)
const DEFAULT_REPRODUCE_ENERGY= Dict(  :boar => 0.6,     :tiger => 0.6,      :leopard => 0.6)
const DEFAULT_CATCH_PROB = Dict(         	 	 	     :tiger => 0.6,     :leopard => 0.35)
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
	map::String



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
	mask::Matrix{Float16}

	count_species::Dict{Symbol, Int}
	born_count::Dict{Symbol, Int} =  Dict(:boar =>0, :tiger => 0, :leopard => 0)
	death_eat::Dict{Symbol, Int} =  Dict(:boar =>0, :tiger => 0, :leopard => 0)
	death_hun::Dict{Symbol, Int} =  Dict(:boar =>0, :tiger => 0, :leopard => 0)
	death_old::Dict{Symbol, Int} =  Dict(:boar =>0, :tiger => 0, :leopard => 0)
	
	# x::Float16 = 1
	step_num::Int16 = 0
	death_list::Array{Int} = []
	
	fight_prob::Float32 = 0.15


end



function init_model(params)
	
	FloatType = typeof(params.max_energy[:tiger])
	space = GridSpace(params.grid_size; periodic=false)

	#Load map
	# img = load(params.map)
	# img_gray=Gray.(1 .- red.(img))
	# mat = convert(Array{Float16}, img_gray)
	# mask = img_gray .> 0
	# mat_mask = convert(Array{Float16}, img_gray)
	
	image = load(params.map)
	w, h = size(image)
	# Extract the R, G, B matrix
	r_matrix = red.(image)
	g_matrix = green.(image)
	b_matrix = blue.(image)

	matrix = fill(Float16(1.0), w, h)
	food_mask= fill(Float16(1.0), w, h)
	for i in 1:w
		for j in 1:h
			# Đoạn code bạn muốn thực hiện cho từng cặp giá trị i và j
			if r_matrix[i, j] == 1.0 &&  g_matrix[i, j] == 1.0 &&  b_matrix[i, j] == 1.0
				matrix[i, j] = 0.0
				food_mask[i, j] = 0.0
			else
				luminance = 0.299 * r_matrix[i, j] + 0.587 * g_matrix[i, j] + 0.114 * b_matrix[i, j]
				matrix[i, j] =  1 - luminance
			end
		end
	end
	# Tìm giá trị lớn nhất trong ma trận
	max_value = maximum(matrix)
	# Chia từng giá trị trong ma trận cho giá trị lớn nhất
	mask_mat = matrix / max_value
	

	props = ModelProperties(
		params=params, 
		count_species=count_species(params.grid_size),
		food=food_mask, #ones(params.grid_size),
		mask=mask_mat
		)

	model = AgentBasedModel(Animal, space; properties=props) #scheduler = spiece_scheduler
	max_energy=params.max_energy

	
	for _ in 1:params.num_init_boar
		id = nextid(model)
		pos = random_position(model)
		add_agent!(animal(id, pos, :boar,rand(model.rng,Uniform(0.5,1))*max_energy[:boar], rand(model.rng,1:1:params.lifespan[:boar])), model)
	end
	for _ in 1:params.num_init_tiger
		id = nextid(model)
		pos = random_position(model)
		add_agent!(animal(id, pos, :tiger, rand(model.rng,Uniform(0.5,1))*max_energy[:tiger], rand(model.rng,1:1:params.lifespan[:tiger])), model)
	end
	for _ in 1:params.num_init_leopard
		pos = random_position(model)
		id = nextid(model)
		add_agent!(animal(id, pos, :leopard,rand(model.rng,Uniform(0.5,1))*max_energy[:leopard], rand(model.rng,1:1:params.lifespan[:tiger])), model)
	end
	
	model.count_species = count_species(model)
	
	# print(model.params.catch_prob)
	# print("model.count_species: ",model.count_species)
	# model , agent_step!, model_step! ,spiece_scheduler
	
	model, dummystep, complex_step!
	# agent_eat!, agent_reproduce!
	# model ,agent_move!,model_step! 
	
end


end 
