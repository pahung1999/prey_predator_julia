
using Agents
# using PlutoUI
# using PlutoLinks: @ingredients
using InteractiveDynamics
using GLMakie


include("./model/model.jl")
include("./visualize.jl")

function healthy_food(model)
	count(model.food .> 0.5)
end

struct IsSpecies <: Function
	species::Symbol
end

function (f::IsSpecies)(agent)
	agent.species == f.species
end

# model, agent_step!, model_step! = Model.init_model(params)

const boar = IsSpecies(:boar)
const leopard = IsSpecies(:leopard)
const tiger = IsSpecies(:tiger)

# const scheduler= Agents.Schedulers.Randomly()


model, agent_step!, model_step! = let
	params = Model.ModelParams(
		grid_size=(50, 50),
		num_init_tiger=50,
		num_init_leopard=50,
		num_init_boar=200,
		map="./map/ver04/grow_diff_01.png",
		
	)
	Model.init_model(params)
end
adata = let
	tiger = agent -> agent.species == :tiger
	boar = agent -> agent.species == :boar
	leopard = agent -> agent.species == :leopard
	[
		(tiger, count),
		(boar, count),
		(leopard, count)
	]
end
alabels = ["count_tiger", "count_boar", "count_leopard"]
steps=10000
# adata, mdata = run!(model, agent_step!, model_step!, steps; adata=adata, mdata=[healthy_food])
# print(adata)

# using CSV
# num=parse(Int64, (open(f->read(f, String), "./data_num.txt")))

# csv_path=string("./data/data_v1_",string(num, pad=3),".csv")
# CSV.write(csv_path, adata)

# open("./data_num.txt", "w") do io
# 	write(io, string(num+1))
# end
fig, obs = abmexploration(model;
                          (agent_step!)=agent_step!,
                          (model_step!)=model_step!,
						#   scheduler = scheduler,
                          adata=adata,
						  alabels=alabels,
                          mdata=[healthy_food],
                          frames=steps,
						framerate=10,
						ac=AgentColor(model),
						am=agent_marker,
						heatarray=model_heatarray,
						heatkwargs=PLOT_MAP_COLOR,
						
						# sleep= 0.01,
						# spu=50
						)
scene = display(fig)
wait(scene)

# videopath="./test_v1.mp4"
# abmvideo(videopath,
# model,
# agent_step!,
# model_step!;#
# frames=steps,
# framerate=5,
# ac=AgentColor(model),
# am=agent_marker,
# heatarray=model_heatarray,
# heatkwargs=(nan_color=(1.0, 1.0, 0.0, 0.5),
# 			colormap=[(0, 1.0, 0, i) for i in 0:0.01:1],
# 			colorrange=(0, 1))
			# )

# adata, mdata = run!(model, agent_step!, model_step!, steps; adata=adata, mdata=[healthy_food])

# print(adata)

