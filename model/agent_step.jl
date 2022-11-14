#Step của từng loài
function agent_step!(agent::Animal, model)
	params = model.params
	species = agent.species
	#Move
	agent.energy = agent.energy - params.energy_consum[species]
	if agent.energy <= 0
		# print("Chết đói")
		kill_agent!(agent, model)
		return
	end

	agent_step!(agent, model, Val(species))

	#Born
	if agent.energy > params.energy_reproduce[species] && rand(Uniform(0, 1)) <= params.proba_reproduce[species]
		nb_offspring= rand(1:params.max_offsprings[species])
		energy_child=agent.energy/nb_offspring
		for _ in 1:nb_offspring
			id = nextid(model)
			pos = agent.pos
			
			add_agent!(animal(id, pos,species,energy_child), model)
		end
		agent.energy=agent.energy/nb_offspring
		# print("ĐẺ")
	end

	
	

	# Grow
	agent.age += 1
	# Die
	if agent.age >= params.lifespan[species]
		print("Chết già")
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
	# move_agent!(agent, rand(nearby_positions(agent.pos, model,1) |> Set), model)
	# before_pos=agent.pos
	move_animal!(agent,model, Val(agent.species))
	# after_pos=agent.pos
	# if before_pos==after_pos
	# 	print("Ko di chuyen")
	# end
	boar_num=count(is_species(:boar), 
		agents_in_position(agent.pos,model))
	params = model.params
	consumption = min(
		model.food[agent.pos...]/boar_num, 
		params.energy_transfert[:boar],
		params.max_energy[agent.species] - agent.energy
	)
	
	agent.energy += consumption
	model.food[agent.pos...] -= consumption
end