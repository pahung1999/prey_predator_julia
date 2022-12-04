function agent_move!(agent::Animal, model)
	params = model.params
	species = agent.species
	#năng lượng tiêu hao mỗi bước
	agent.energy = agent.energy - params.energy_consum[species]

	# print("Agent ID ở bước ",model.step_num," : ",agent.id, " . Loài: ",agent.species, " . Vị trí: từ ", agent.pos)


	if agent.energy <= 0
		# print(" Đến nghĩa địa vì đói \n")
		kill_agent!(agent, model)
        return
	end

	# Grow
	agent.age += 1
	# Die
	if agent.age >= params.lifespan[species]
		# print(" Đến nghĩa địa vì già \n")
		kill_agent!(agent, model)
		return
	end

    move_animal!(agent,model, Val(agent.species))

	# print(" đến ", agent.pos , "\n")
end
