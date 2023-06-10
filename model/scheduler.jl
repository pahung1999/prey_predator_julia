function spiece_scheduler(model::ABM)
	ids = collect(allids(model))
	# print("all IDS: ",ids)
	# filter all ids whose agents have `w` less than some amount
	ids_boar= filter(id -> model[id].species == :boar, ids)
	ids_tiger= filter(id -> model[id].species == :tiger, ids)
	ids_leopard= filter(id -> model[id].species == :leopard, ids)
	
	# print( [ids_boar;ids_tiger;ids_leopard])
	return [ids_boar;ids_tiger;ids_leopard]
end

function model_step!(model)
	params = model.params
	# @. model.food = min(model.food + params.grow_speed, params.max_food)
	@. model.food = min(model.food + model.mask * params.grow_speed, params.max_food)
	model.step_num +=1
	# print("Hết bước ", model.step_num)
	# print("==================================\n")

	model.count_species = count_species(model)

	# model.fight_prob= (model.count_species[:leopard]+1)/(model.count_species[:leopard] + model.count_species[:tiger] + 1)
end

function boar_scheduler(model::ABM)
	ids = collect(allids(model))
	filter!(id -> model[id].species == :boar, ids)
	return ids
end
function tiger_scheduler(model::ABM)
	ids = collect(allids(model))
	filter!(id -> model[id].species == :tiger, ids)
	return ids
end
function leopard_scheduler(model::ABM)
	ids = collect(allids(model))
	filter!(id -> model[id].species == :leopard, ids)
	return ids
end


function complex_step!(model)


    
    for id in boar_scheduler(model)
		
		agent_reproduce!(model[id], model)
		if id in model.death_list
			# print("id: ",id, ". list: ",model.death_list,"\n")
			continue
		end
		agent_eat!(model[id], model)
		agent_move!(model[id], model)
    end
  
	for id in tiger_scheduler(model)
        agent_reproduce!(model[id], model)
		if id in model.death_list
			# print("id: ",id, ". list: ",model.death_list,"\n")
			continue
		end
		agent_eat!(model[id], model)
		agent_move!(model[id], model)
    end
	
	for id in leopard_scheduler(model)
		agent_reproduce!(model[id], model)
		if id in model.death_list
			# print("id: ",id, ". list: ",model.death_list,"\n")
			continue
		end
		agent_eat!(model[id], model)
		agent_move!(model[id], model)
    end
    
	

	model_step!(model)


end

