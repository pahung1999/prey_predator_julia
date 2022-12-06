# # Step của từng loài
# function agent_step!(agent::Animal, model)
# 	# print("Bước: ",model.step_num," . model.step_num%3: ",model.step_num%3,"\n")
# 	if model.step_num%3 ==2
# 		agent_move!(agent,model)
# 	elseif model.step_num%3 ==1
# 		agent_eat!(agent,model)
# 	elseif model.step_num%3 ==0
# 		agent_reproduce!(agent,model)
# 	end

# end

function agent_step!(agent::Animal, model)
	params = model.params
	species = agent.species
	#năng lượng tiêu hao mỗi bước
	agent.energy = agent.energy - params.energy_consum[species]

	# print("Step: ",model.step_num,". ID: ",agent.id, ". Species: ",agent.species, ". Position: ", agent.pos,"\n" )


	if agent.energy <= 0
		# print("Chết đói")
		kill_agent!(agent, model)
		return
	end

	# Grow
	agent.age += 1
	# Die
	if agent.age >= params.lifespan[species]
		# print("Chết già")
		kill_agent!(agent, model)
		return
	end

	#Born
	if agent.energy >= params.energy_reproduce[species]  && rand(model.rng,Uniform(0, 1)) <= params.proba_reproduce[species]
		nb_offspring= rand(model.rng,1:params.max_offsprings[species])
		# energy_child=agent.energy/2/nb_offspring
		energy_child=params.max_energy[species]*0.25
		for _ in 1:nb_offspring
			id = nextid(model)
			pos = agent.pos
			
			add_agent!(animal(id, pos,species,energy_child), model)
		end
		agent.energy=agent.energy - energy_child
		# print("ĐẺ")
	end

	#Ăn rồi di chuyển
	agent_step!(agent, model, Val(species))

	
end

function agent_step!(agent, model, ::Val{:leopard})
	# Walk
	agent_prey= random_prey(agent.pos , :boar, model)
	if agent_prey !=0  
		eat_prey!(agent,agent_prey, model)
	end
	
	move_animal!(agent,model, Val(agent.species))
end
function agent_step!(agent, model, ::Val{:tiger})
	
	agent_prey= random_prey(agent.pos , :boar, model)
	if agent_prey == 0
		agent_prey= random_prey(agent.pos , :leopard, model)
	end
	if agent_prey !=0
		eat_prey!(agent,agent_prey, model)
	end
	# Walk
	move_animal!(agent,model, Val(agent.species))
	
end
	
function agent_step!(agent, model, ::Val{:boar})
	#Ăn
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

	#Di chuyển
	move_animal!(agent,model, Val(agent.species))
end