### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ b4e537e8-4fca-11ed-1ccf-635f335cf7f3
begin
	using Agents
	using PlutoUI
	using PlutoLinks: @ingredients
	using InteractiveDynamics
	using GLMakie
end
# move_animal = @ingredients("./move_animal.jl")

# ╔═╡ 9a7ed791-b78a-4786-8b4c-67c425854e1e
module Model

using Base: @kwdef
using Agents
using Distributions

const LIST_SPECIES= (:tiger, :leopard, :boar)

const DEFAULT_MAX_ENERGY= Dict(:tiger => 5.0,  :boar => 5.6,  :leopard => 5.8) 
const DEFAULT_ENERGY_TRANSFERT = Dict(:tiger => 0.5,  :boar => 0.15,  :leopard => 0.4)
const DEFAULT_REPRODUCE_PROBA= Dict(:tiger => 0.005,  :boar => 0.01,  :leopard => 0.005)
const DEFAULT_REPRODUCE_ENERGY= Dict(:tiger => 0.5,  :boar => 0.3,  :leopard => 0.4)
const DEFAULT_ENERGY_CONSUME = Dict(:tiger => 0.02,  :boar => 0.015,  :leopard => 0.016)
const MAX_OFFSPRING = Dict(:tiger => 2,  :boar => 6,  :leopard => 4)

const DEFAULT_LIFESPAN = Dict(:tiger => 15 * 365,  :boar => 12 * 365,  :leopard => 14 * 365)
const DEFAULT_CATCH_PROB = Dict(:tiger => 0.3, :leopard => 0.5)

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
# include("./eat_prey.jl")
#Chọn con mồi trong 1 ô
function random_prey(pos , species, model)
	agent_list= agents_in_position(pos,model)
	for agent_prey in agent_list
		if agent_prey.species == species
			return agent_prey
		end
	end
	# print("No prey in this cell")
	return 0
end

#Ăn con mồi
function eat_prey!(agent,prey, model)
	params=model.params
    if prey.species == :leopard
        if agent.energy < 0.3 && rand(Uniform(0, 1)) < params.fight_prob
            consumption = min(
				prey.energy,
				params.energy_transfert[agent.species],
				params.max_energy[agent.species] - agent.energy)
            agent.energy += consumption
            kill_agent!(prey,model)
        end
        return
    end

	if rand(Uniform(0, 1)) <= params.catch_prob[agent.species] 
		consumption = min(
				prey.energy,
				params.energy_transfert[agent.species],
				params.max_energy[agent.species] - agent.energy)
		agent.energy += consumption
		kill_agent!(prey,model)
	end
end

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


#Step của từng loài
function agent_step!(agent::Animal, model)
	params = model.params
	species = agent.species
	#Move
	agent.energy = agent.energy - params.energy_consum[species]
	if agent.energy <= 0
		kill_agent!(agent, model)
		return
	end
	agent_step!(agent, model, Val(species))

	#Born
	if agent.energy > params.energy_reproduce[species] && rand(Uniform(0, 1)) <= params.proba_reproduce[species]
		nb_offspring= rand(1:MAX_OFFSPRING[species])
		for _ in 1:nb_offspring
			id = nextid(model)
			pos = agent.pos
			add_agent!(animal(id, pos,species), model)
		end
	end
		
	# Grow
	agent.age += 1
	# Die
	if agent.age >= params.lifespan[species]
		kill_agent!(agent, model)
	end
end

function agent_step!(agent, model, ::Val{:leopard})
	# Walk
	move_animal!(agent,model, Val(agent.species))
	
	agent_prey= random_prey(agent.pos , :boar, model)
	if agent_prey !=0  
		eat_prey!(agent,agent_prey, model)
	end
end
function agent_step!(agent, model, ::Val{:tiger})
	# Walk
	move_animal!(agent,model, Val(agent.species))
	agent_prey= random_prey(agent.pos , :boar, model)
	if agent_prey == 0
		agent_prey= random_prey(agent.pos , :leopard, model)
	end
	if agent_prey !=0
		eat_prey!(agent,agent_prey, model)
	end
	
end
	
function agent_step!(agent, model, ::Val{:boar})
	# Walk
	move_agent!(agent, rand(nearby_positions(agent.pos, model,1) |> Set), model)
	
	params = model.params
	consumption = min(
		model.food[agent.pos...], 
		params.energy_transfert[:boar],
		params.max_energy[agent.species] - agent.energy
	)
	agent.energy += consumption
	model.food[agent.pos...] -= consumption
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

# ╔═╡ 1b950142-cac6-4e15-8fc1-5add615e0365
using DataFrames

# ╔═╡ de1e8ab9-1069-4588-b3e7-e47b67f2cf78
TableOfContents()

# ╔═╡ 8a24d382-ef91-47f2-8951-df8673951230
md"# Setup model"

# ╔═╡ 5c520921-9c7a-4a15-8964-4458964c6069
begin
	x=[1,2,3]
	y=[4,5,6,7]
	print([x;y;x])
end

# ╔═╡ d3a9c48d-3490-4a89-80ce-871789171048
death_list::Array = []

# ╔═╡ 8c5bff5a-5306-452a-b602-df21541d7e1e


# ╔═╡ f809274e-1479-465d-ba24-3343d9de07c4


# ╔═╡ 7c3b1346-ca28-4bc6-8d95-f5353a1df33a


# ╔═╡ 635c4c0e-82fe-4f9e-a4a0-fca47d7ed3de
@bind grid_size PlutoUI.NumberField(100:10:200)

# ╔═╡ e7b3ff98-ad07-4def-8b75-015c34424dc4
function IsSpecies(s)
	function Is(agent)
		agent.species == s
	end
end

# ╔═╡ ceb9fee6-62c4-4f1d-90e7-a57d8d9de97a
function healthy_food(model)
	count(model.food .> 0.01)
end

# ╔═╡ a935a079-83ea-4ba4-bfeb-36318e8cbbaa
adata = [
	(IsSpecies(:tiger), count),
	(IsSpecies(:boar), count),
	(IsSpecies(:leopard), count)
]

# ╔═╡ 4fa148d5-26cb-44e9-a2ff-a73638a19f0e
is_full(x) = x.energy == 1

# ╔═╡ c3b6f460-5b88-4c89-8520-d6b85db10bc5


# ╔═╡ dc1dfc49-3495-45f5-abf7-789b4ce8e946
# model=let 
# 	params = Model.ModelParams(
# 		grid_size=(50, 50),
# 		num_init_tiger=50,
# 		num_init_boar=200
# 	)
# 	# adata
# 	model, agent_step!, model_step! = Model.init_model(params)
# 	adata, mdata = run!(model, agent_step!, model_step!, 100; adata=adata, mdata=[healthy_food])
# 	# innerjoin(adata, mdata, on=:step)
# 	# model
# 	model
# end

params = Model.ModelParams(
		grid_size=(50, 50),
		num_init_tiger=50,
		num_init_boar=200
	)

# ╔═╡ d20ea126-bf30-490f-87dc-9da40a8fd078
begin
	using Colors
	
	# Agent coloring
	struct AgentColor <: Function
	    model::AgentBasedModel
	end
	
	function (ac::AgentColor)(agent)
	    x, y = agent.pos
	    model = ac.model
	    if isnan(model.food[x, y])
	        RGBAf(0.0f0, 0.0f0, 0.0f0)
	    elseif agent.age < model.params.lifespan[agent.species]
	        RGBAf(0.0f0, 0.0f0, 1.0f0)
	    else
	        RGBAf(1.0f0, 0.0f0, 0.0f0)
	    end
	end
	
	# Agent marker
	function agent_marker(agent)
	    if agent.species==:tiger
	        return :circle
		end
	    if agent.species==:leopard
	        return :circle
		end
	    if agent.species== :boar
	        return :utriangle
		end
	end
	
	# Model map
	function model_heatarray(model)
	    return model.food
	end
	
	function video(videopath::String,
	               crop,
	               init_nb_bph,
	               position,
	               pr_eliminate0;
	               seed,
	               frames=2880,
	               kwargs...)
	    # @info "Video seed: $seed"
	    model, agent_step!, model_step! = Model.init_model(params)
	    return abm_video(videopath,
	                     model,
	                     agent_step!,
	                     model_step!;
	                     frames=frames,
	                     framerate=24,
	                     ac=ac(model),
	                     am=am,
	                     heatarray=heatarray,
	                     heatkwargs=(nan_color=(1.0, 1.0, 0.0, 0.5),
	                                 colormap=[(0, 1.0, 0, i) for i in 0:0.01:1],
	                                 colorrange=(0, 1)))
	end
	
	const PLOT_AGENT_MARKERS = Dict(true => :circle, false => :utriangle)
	const PLOT_MAP_COLOR = (nan_color=RGBA(1.0, 1.0, 0.0, 0.5),
	                        colormap=[RGBA(0, 1.0, 0, i) for i in 0:0.01:1],
	                        colorrange=(0, 1))
	function get_plot_kwargs(model)
	    return (frames=2880,
	            framerate=24,
	            ac=AgentColor(model),
	            am=agent_marker,
	            heatarray=model_heatarray,
	            heatkwargs=PLOT_MAP_COLOR)
	end
	
	
end

# ╔═╡ 768d6467-fc84-4439-8b4c-9aedb0ae495b
begin
	# adata
	model, agent_step!, model_step! = Model.init_model(params)
	steps=300
	videopath="./test_v1.mp4"
end

# ╔═╡ 03939ca5-f9bd-412d-8cab-61f832c1047f

abmvideo(videopath,
		model,
		agent_step!,
		model_step!;
		frames=steps,
		framerate=10,
		ac=AgentColor(model),
		am=agent_marker,
		heatarray=model_heatarray,
		# heatkwargs=(nan_color=(1.0, 1.0, 0.0, 0.5),
		# 			colormap=[(0, 1.0, 0, i) for i in 0:0.01:1],
		# 			colorrange=(0, 1))
		)


# ╔═╡ 0d758131-fc07-48b5-b58b-888f3b0d7b8d
# y=[0.02 0.015 0.016]

# ╔═╡ 274b43b8-6fb9-4e79-8539-3cc4258bb956
# abmvideo("./test_v1.mp4", model, agent_step! , model_step!; spf = 1, framerate = 30,frames = 200)

# ╔═╡ 78d4b94f-22e9-4f4f-83ac-311759893219
# model=let 
# 	params = Model.ModelParams(
# 		grid_size=(50, 50),
# 		num_init_tiger=50,
# 		num_init_boar=200
# 	)
# 	# adata
# 	model, agent_step!, model_step! = Model.init_model(params)
# 	adata, mdata = run!(model, agent_step!, model_step!, 100; adata=adata, mdata=[healthy_food])
# 	# innerjoin(adata, mdata, on=:step)
# 	# model
# 	model
# end

# ╔═╡ 4f2bbb75-8b54-4f58-a629-4ceb8903b2c1
# CartesianIndices(model.food)
agents_in_position.(Tuple.(CartesianIndices(model.food)), (model,))

# ╔═╡ c3d007fd-7889-4448-a99b-4bb66163a1db
begin
	function is_species(species)
		return (agent -> agent.species == species)
	end

	function is_species(agent, species)
		agent.species == species
	end
end

# ╔═╡ 3cca8d9d-c584-44bd-96e4-0dde139f851b
function count_species(model)
	Dict(
		species => [
			count(is_species(species), agents_in_position(Tuple(I), model))
			for I in CartesianIndices(model.food)
		]
		for species in [:tiger, :board, :boar]
	)
end

# ╔═╡ 90976414-79c9-420d-a845-d9dd856a4a52
# x=[1 0.6 0.8]

# ╔═╡ 64d51cc3-7c99-457b-a558-695e8b7b50ac
rand(x)

# ╔═╡ 403986fc-c0a7-4420-8d3b-c7d9b44ea43c
md"# Model params"

# ╔═╡ 77ef75a9-f76c-441a-b8c0-96d3a6e515ee
function print_x(x=10,y=30)
	print(x)
	print(y)
end

# ╔═╡ 9adcfec2-196d-4e38-b8e8-1821007c7b57
count

# ╔═╡ 7d4253e6-bff1-4cd2-a724-9f97506eda1d
begin
	f(x, ::Val{:add1}) = x + 1
	f(x, ::Val{:sub1}) = x - 1
	f(x, ::Val{:mul2}) = x * 2
end

# ╔═╡ 23366a99-a453-4eb9-86d8-8d05a0ba84a3
f(1, Val(:sub1))

# ╔═╡ a6c76101-097e-4373-a69d-9a49bad233d8
begin
	function is_tiger(x)
		x.species == :tiger
	end
	function is_leopard(x)
		x.species == :leopard
	end
	function is_boar(x)
		x.species == :boar
	end
	
end

# ╔═╡ 2acf8cff-5998-40f0-b9ce-d3f09dc00487
count(is_tiger, collect(agents_in_position((1,1),model)))

# ╔═╡ Cell order:
# ╠═b4e537e8-4fca-11ed-1ccf-635f335cf7f3
# ╠═de1e8ab9-1069-4588-b3e7-e47b67f2cf78
# ╟─8a24d382-ef91-47f2-8951-df8673951230
# ╠═5c520921-9c7a-4a15-8964-4458964c6069
# ╠═d3a9c48d-3490-4a89-80ce-871789171048
# ╠═8c5bff5a-5306-452a-b602-df21541d7e1e
# ╠═f809274e-1479-465d-ba24-3343d9de07c4
# ╟─7c3b1346-ca28-4bc6-8d95-f5353a1df33a
# ╠═9a7ed791-b78a-4786-8b4c-67c425854e1e
# ╠═635c4c0e-82fe-4f9e-a4a0-fca47d7ed3de
# ╠═e7b3ff98-ad07-4def-8b75-015c34424dc4
# ╠═ceb9fee6-62c4-4f1d-90e7-a57d8d9de97a
# ╠═a935a079-83ea-4ba4-bfeb-36318e8cbbaa
# ╠═4fa148d5-26cb-44e9-a2ff-a73638a19f0e
# ╠═d20ea126-bf30-490f-87dc-9da40a8fd078
# ╠═c3b6f460-5b88-4c89-8520-d6b85db10bc5
# ╠═1b950142-cac6-4e15-8fc1-5add615e0365
# ╠═dc1dfc49-3495-45f5-abf7-789b4ce8e946
# ╠═768d6467-fc84-4439-8b4c-9aedb0ae495b
# ╠═03939ca5-f9bd-412d-8cab-61f832c1047f
# ╠═0d758131-fc07-48b5-b58b-888f3b0d7b8d
# ╠═274b43b8-6fb9-4e79-8539-3cc4258bb956
# ╠═78d4b94f-22e9-4f4f-83ac-311759893219
# ╠═4f2bbb75-8b54-4f58-a629-4ceb8903b2c1
# ╠═3cca8d9d-c584-44bd-96e4-0dde139f851b
# ╠═c3d007fd-7889-4448-a99b-4bb66163a1db
# ╠═90976414-79c9-420d-a845-d9dd856a4a52
# ╠═64d51cc3-7c99-457b-a558-695e8b7b50ac
# ╠═2acf8cff-5998-40f0-b9ce-d3f09dc00487
# ╠═403986fc-c0a7-4420-8d3b-c7d9b44ea43c
# ╠═77ef75a9-f76c-441a-b8c0-96d3a6e515ee
# ╠═9adcfec2-196d-4e38-b8e8-1821007c7b57
# ╠═7d4253e6-bff1-4cd2-a724-9f97506eda1d
# ╠═23366a99-a453-4eb9-86d8-8d05a0ba84a3
# ╠═a6c76101-097e-4373-a69d-9a49bad233d8
