#Chọn con mồi trong 1 ô
include("./sub_function.jl")


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
		leopard_num=count(agent -> agent.species==:leopard,  agents_in_position(prey,model))
		tiger_num=count(agent -> agent.species==:tiger,  agents_in_position(agent,model))
		fight_prob=(leopard_num+1)/(tiger_num+leopard_num+1)
        if agent.energy < 0.3 && rand(model.rng,Uniform(0, 1)) < fight_prob # (params.catch_prob[agent.species]*fight_prob) #
            consumption = min(
				prey.energy,
				params.energy_transfert[agent.species],
				params.max_energy[agent.species] - agent.energy)
            agent.energy += consumption
            kill_agent!(prey,model)
        end
        return
    end

	if rand(model.rng,Uniform(0, 1)) <= params.catch_prob[agent.species] 
		consumption = min(
				prey.energy,
				params.energy_transfert[agent.species],
				params.max_energy[agent.species] - agent.energy)
		agent.energy += consumption
		kill_agent!(prey,model)
		# @info "Chết vì bị ăn"
	end
end

