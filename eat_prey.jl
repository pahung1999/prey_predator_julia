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