
using Agents
# using PlutoUI
# using PlutoLinks: @ingredients
using InteractiveDynamics
using GLMakie
using Images


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

function get_first_food_energy(map_path)
    img = load(map_path)
    height, width = size(img)
    green_count = 0.0

    for y = 1:height
        for x = 1:width
            if img[y, x] != RGB(1, 1, 1)
                green_count += 1
            end
        end
    end
    return green_count
end

map_path = "./map/ver_test/map_001.png"
# map_path="./map/map_001.png"
out_folder="data/test/"

max_num_data=15

for i in 1:1000
	tiger_catch = rand(0.6:0.03:0.8)
	leopard_catch = rand(0.3:0.03:0.5)
	folder_name = string(tiger_catch, "_", leopard_catch)
	output_path = joinpath(out_folder, folder_name)
	if !isdir(output_path)
        mkpath(output_path)
    end

	print("===========================================", "\n")
	print("Folder lưu: ", folder_name, "\n")

	for i in 1:max_num_data
		print("Lượt mô phỏng thứ: ", i, "\n")
	
		model, agent_step!, model_step! = let
			params = Model.ModelParams(
				grid_size=(50, 50),
				num_init_tiger=25,
				num_init_leopard=25,
				num_init_boar=500,
				map=map_path,
				catch_prob=Dict(:tiger => tiger_catch, :leopard => leopard_catch)
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
	
		mdata = let 
			num_tiger(model) = model.count_species[:tiger]
			num_boar(model) = model.count_species[:boar]
			num_leopard(model) = model.count_species[:leopard]
			total_food_energy(model)=sum(model.food)
	
			born_leopard(m) = m.born_count[:leopard]
			born_tiger(m) = m.born_count[:tiger]
			born_boar(m) = m.born_count[:boar]
	
			death_tiger_old(m) =  m.death_old[:tiger]
			death_leopard_old(m) = m.death_old[:leopard]
			death_boar_old(m) = m.death_old[:boar]
			
			death_leopard_eaten(m) = m.death_eat[:leopard]
			death_boar_eaten(m) = m.death_eat[:boar]
			
			death_tiger_hungry(m) = m.death_hun[:tiger]
			death_boar_hungry(m) = m.death_hun[:boar]
			death_leopard_hungry(m) = m.death_hun[:leopard]
	
			[healthy_food,total_food_energy, 
			num_tiger, num_boar, num_leopard, 
			born_tiger, born_leopard, born_boar, 
			death_tiger_old, death_leopard_old, death_boar_old,
			death_tiger_hungry, death_leopard_hungry, death_boar_hungry,
			death_leopard_eaten, death_boar_eaten
			]
		end
		
		alabels = ["count_tiger", "count_boar", "count_leopard"]
		steps=7000
		adata, mdata = run!(model, agent_step!, model_step!, steps; mdata)
		# print(adata)
	
		using CSV
		num=parse(Int64, (open(f->read(f, String), "./data_num.txt")))
		
		data_name = string("data_", string(num, pad=5), ".csv")
		csv_path = joinpath(output_path, data_name)
		# csv_path=string("./data/",string(csv_folder),"/data_",string(num, pad=5),".csv")
		CSV.write(csv_path, mdata)
	
		open("./data_num.txt", "w") do io
			write(io, string(num+1))
		end
	end
end




# fig, obs = abmexploration(model;
#                           (agent_step!)=agent_step!,
#                           (model_step!)=model_step!,
# 						#   scheduler = scheduler,
#                           adata=adata,
# 						  alabels=alabels,
#                           mdata=[healthy_food],
#                           frames=steps,
# 						framerate=10,
# 						ac=AgentColor(model),
# 						am=agent_marker,
# 						heatarray=model_heatarray,
# 						heatkwargs=PLOT_MAP_COLOR,
						
# 						# sleep= 0.01,
# 						# spu=50
# 						)
# scene = display(fig)
# wait(scene)

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

