#Chọn con mồi trong 1 ô
include("./sub_function.jl")


function random_prey(pos , species, model)
	agent_list= filter(agents -> agents.species== species, collect(agents_in_position(pos,model)))
	if isempty(agent_list)
		return 0
	else
		return rand(model.rng,agent_list)
	end
	# for agent_prey in agent_list
	# 	if agent_prey.species == species
	# 		return agent_prey
	# 	end
	# end
	# print("No prey in this cell")
	# return 0
end


#Hổ ăn
function eat_prey!(agent,prey, model, ::Val{:tiger})
	params=model.params
	catch_prob= 1-prey.energy  #(prey.energy/ params.max_energy[prey.species])
	if prey.species == :leopard 
        if agent.energy < 0.3 && rand(model.rng) < model.fight_prob
            tiger_eat_prey!(agent,prey,model)
			kill_an_agent!(prey, model)
			model.death_eat[prey.species]+=1
        end
        return
    else
		if rand(model.rng) < model.params.catch_prob[agent.species]
            tiger_eat_prey!(agent,prey,model)
			kill_an_agent!(prey, model)
			model.death_eat[prey.species]+=1
        end
		return
	end
end

function tiger_eat_prey!(agent,prey,model)
	params=model.params
	
	energy_get = min(
			# prey.energy,
			params.energy_transfert[agent.species],
			params.max_energy[agent.species] - agent.energy)
	agent.energy += energy_get
end


function eat_prey!(agent,prey, model, ::Val{:leopard})
	params=model.params
	catch_prob= 1-prey.energy*0.8 
	if rand(model.rng) < model.params.catch_prob[agent.species]
		energy_get = min(
				# prey.energy,
				params.energy_transfert[agent.species],
				params.max_energy[agent.species] - agent.energy)
		agent.energy += energy_get
		kill_an_agent!(prey, model)
		model.death_eat[prey.species]+=1
	end
	return
end