function agent_eat!(agent::Animal, model)
	params = model.params
	species = agent.species

    agent_eat!(agent, model, Val(species))

    # print("Step: ",model.step_num,". ID",agent.id, ". Species: ",agent.species, ". Position: ", agent.pos, ". Action: Eat", "\n")

end

function agent_eat!(agent, model, ::Val{:leopard})
	# Walk

	agent_prey= random_prey(agent.pos , :boar, model)
	if agent_prey !=0
		eat_prey!(agent,agent_prey, model, Val(agent.species))
	end
	return
	
end

function agent_eat!(agent, model, ::Val{:tiger})
	
	agent_prey= random_prey(agent.pos , :boar, model)
	if agent_prey == 0
		agent_prey= random_prey(agent.pos , :leopard, model)
	end
	if agent_prey !=0
		eat_prey!(agent,agent_prey, model, Val(agent.species))
	end
end
	
function agent_eat!(agent, model, ::Val{:boar})
	#Ăn
	boar_num=count(is_species(:boar), 
		agents_in_position(agent.pos,model))
	params = model.params

	if model.food[agent.pos...]>0
		energy_get = min(
		model.food[agent.pos...]/boar_num, 
		params.energy_transfert[:boar],
		params.max_energy[agent.species] - agent.energy
	)
		agent.energy += energy_get
		model.food[agent.pos...] -= energy_get
	end
end