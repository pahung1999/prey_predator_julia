
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

const DEFAULT_MAX_ENERGY= Dict(		   :boar => 1.0,     :tiger => 1.0,      :leopard => 1.0) 
const DEFAULT_ENERGY_TRANSFERT = Dict( :boar => 0.3,    :tiger => 0.5,      :leopard => 0.2)
const DEFAULT_ENERGY_CONSUME = Dict(   :boar => 0.018,   :tiger => 0.03,    :leopard => 0.012)
const DEFAULT_REPRODUCE_PROBA= Dict(   :boar => 0.0036,    :tiger => 0.0015,    :leopard => 0.0017)
const MAX_OFFSPRING =      Dict(       :boar => 12,       :tiger => 6  ,      :leopard => 4)
const DEFAULT_REPRODUCE_ENERGY= Dict(  :boar => 0.6,     :tiger => 0.6,      :leopard => 0.6)
const DEFAULT_CATCH_PROB = Dict(         	 	 	     :tiger => 0.6,     :leopard => 0.33)
const DEFAULT_LIFESPAN = Dict(  	   :boar =>(12*365), :tiger => (15*365), :leopard => (14*365))
const DEFAULT_GROW_SPEED = 0.01


new_para_list = [
    Dict("energy_consum_boar_0.036" => Dict(:energy_consum  => Dict(   :boar => 0.036,   :tiger => 0.03,    :leopard => 0.012))),
    Dict("energy_consum_tiger_0.06" => Dict(:energy_consum  => Dict(   :boar => 0.018,   :tiger => 0.06,    :leopard => 0.012))),
    Dict("energy_consum_leopard_0.024" => Dict(:energy_consum  => Dict(   :boar => 0.018,   :tiger => 0.03,    :leopard => 0.024))),

	Dict("lifespan_boar_6" => Dict(:lifespan  => Dict(  	   :boar =>(6*365), :tiger => (15*365), :leopard => (14*365)))),
	Dict("lifespan_tiger_8" => Dict(:lifespan  => Dict(  	   :boar =>(12*365), :tiger => (8*365), :leopard => (14*365)))),
	Dict("lifespan_leopard_7" => Dict(:lifespan  => Dict(  	   :boar =>(12*365), :tiger => (15*365), :leopard => (7*365)))),

	Dict("proba_reproduce_boar_0.0072" => Dict(:proba_reproduce  => Dict(   :boar => 0.0072,    :tiger => 0.0015,    :leopard => 0.0017))),
	Dict("proba_reproduce_tiger_0.003" => Dict(:proba_reproduce  => Dict(   :boar => 0.0072,    :tiger => 0.003,    :leopard => 0.0017))),
	Dict("proba_reproduce_leopard_0.0034" => Dict(:proba_reproduce  => Dict(   :boar => 0.0072,    :tiger => 0.0015,    :leopard => 0.0034))),

	Dict("max_offsprings_boar_24" => Dict(:max_offsprings  => Dict(:boar => 24, :tiger => 6, :leopard => 4))),
	Dict("max_offsprings_tiger_12" => Dict(:max_offsprings  => Dict(:boar => 24, :tiger => 12, :leopard => 4))),
	Dict("max_offsprings_leopard_8" => Dict(:max_offsprings  => Dict(:boar => 24, :tiger => 6, :leopard => 8))),

	Dict("energy_reproduce_all_0.4" => Dict(:energy_reproduce  => Dict(:boar => 0.4, :tiger => 0.4, :leopard => 0.4))),
	Dict("energy_reproduce_boar_0.4" => Dict(:energy_reproduce  => Dict(:boar => 0.4, :tiger => 0.6, :leopard => 0.6))),
	Dict("energy_reproduce_tiger_0.4" => Dict(:energy_reproduce  => Dict(:boar => 0.6, :tiger => 0.4, :leopard => 0.6))),
	Dict("energy_reproduce_leopard_0.4" => Dict(:energy_reproduce  => Dict(:boar => 0.6, :tiger => 0.6, :leopard => 0.4))),

	Dict("grow_speed_0.005" => Dict(:grow_speed  => 0.005)),
	Dict("grow_speed_0.02" => Dict(:grow_speed  => 0.02)),
	Dict("grow_speed_0.05" => Dict(:grow_speed  => 0.05)),

	Dict("energy_transfert_boar_0.6" => Dict(:energy_transfert  => Dict( :boar => 0.6, :tiger => 0.5, :leopard => 0.2))),
	Dict("energy_transfert_tiger_1.0" => Dict(:energy_transfert  => Dict( :boar => 0.3, :tiger => 1.0, :leopard => 0.2))),
	Dict("energy_transfert_leopard_0.4" => Dict(:energy_transfert  => Dict( :boar => 0.3, :tiger => 0.5, :leopard => 0.4))),
]

for new_para in new_para_list
	
	parameter_dict = Dict(
		:energy_consum => DEFAULT_ENERGY_CONSUME,
		:max_energy => DEFAULT_MAX_ENERGY,
		:lifespan => DEFAULT_LIFESPAN,
		:proba_reproduce => DEFAULT_REPRODUCE_PROBA,
		:max_offsprings => MAX_OFFSPRING,
		:energy_reproduce => DEFAULT_REPRODUCE_ENERGY,
		:grow_speed => DEFAULT_GROW_SPEED,
		:energy_transfert => DEFAULT_ENERGY_TRANSFERT,
		:catch_prob => DEFAULT_CATCH_PROB,
	)

	name_para = collect(keys(new_para))[1]

    new_value_name = collect(keys(new_para[name_para]))[1]
    
    parameter_dict[new_value_name] = new_para[name_para][new_value_name]

	map_folder = "./map/ver_test/"
	# map_path="./map/map_001.png"
	tiger_catch = 0.74
	leopard_catch = 0.41
	# out_folder=string("data/map_ver_",string(Int(tiger_catch*100)),"_",string(Int(leopard_catch*100)),"/")
	out_folder=string("data/sensitive/",name_para,"/")
	if !isdir(out_folder)
		mkpath(out_folder)
	end
	max_num_data=15

	# Lấy danh sách tất cả các file trong thư mục map_folder
	map_list = readdir(map_folder)
	# print("parameter_dict:", parameter_dict, "\n")
	# Lặp qua từng file
	for file in map_list
		map_path= joinpath(map_folder, file)
		# Lấy tên file và bỏ extension
		file_name = splitext(file)[1]
		
		# Tạo đường dẫn thư mục output
		output_path = joinpath(out_folder, file_name)
		
		# Kiểm tra nếu thư mục chưa tồn tại thì tạo mới
		if !isdir(output_path)
			mkpath(output_path)
		end
		
		csv_folder = joinpath(out_folder, file_name)
		print("===========================================", "\n")
		print("Tên map: ", map_path, "\n")
		print("Folder lưu: ", csv_folder, "\n")
		print("Lượt mô phỏng thứ: ")
		for i in 1:max_num_data
			print(i,", ")
		
			model, agent_step!, model_step! = let
				params = Model.ModelParams(
					grid_size=(50, 50),
					num_init_tiger=25,
					num_init_leopard=25,
					num_init_boar=500,
					map=map_path,
					# catch_prob=Dict(:tiger => tiger_catch, :leopard => leopard_catch),
					energy_consum = parameter_dict[:energy_consum] ,
					max_energy = parameter_dict[:max_energy] ,
					lifespan = parameter_dict[:lifespan] ,
					proba_reproduce = parameter_dict[:proba_reproduce] ,
					max_offsprings = parameter_dict[:max_offsprings] ,
					energy_reproduce = parameter_dict[:energy_reproduce],
					grow_speed = parameter_dict[:grow_speed] ,
					energy_transfert = parameter_dict[:energy_transfert] ,
					catch_prob = parameter_dict[:catch_prob],
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
			csv_path = joinpath(csv_folder, data_name)
			# csv_path=string("./data/",string(csv_folder),"/data_",string(num, pad=5),".csv")
			CSV.write(csv_path, mdata)
		
			open("./data_num.txt", "w") do io
				write(io, string(num+1))
			end
		end
		print("\n")
	end
end


