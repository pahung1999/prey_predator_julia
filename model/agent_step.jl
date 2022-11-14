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