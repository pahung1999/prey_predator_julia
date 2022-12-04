function agent_eat!(agent::Animal, model)
	params = model.params
	species = agent.species

    agent_eat!(agent, model, Val(species))

    # print("Agent ID ở bước ",model.step_num," : ",agent.id, " . Loài: ",agent.species, " . Đang ăn tại vị trí: ", agent.pos, "\n")

end

function agent_eat!(agent, model, ::Val{:leopard})
	# Walk
	agent_prey= random_prey(agent.pos , :boar, model)
	if agent_prey !=0  
		eat_prey!(agent,agent_prey, model)
	end

end

function agent_eat!(agent, model, ::Val{:tiger})
	
	agent_prey= random_prey(agent.pos , :boar, model)
	if agent_prey == 0
		agent_prey= random_prey(agent.pos , :leopard, model)
	end
	if agent_prey !=0
		eat_prey!(agent,agent_prey, model)
	end
	
end
	
function agent_eat!(agent, model, ::Val{:boar})
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

end