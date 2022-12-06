function agent_move!(agent::Animal, model)
	params = model.params
	species = agent.species
	#năng lượng tiêu hao mỗi bước
	agent.energy = agent.energy - params.energy_consum[species]

	# print("Step: ",model.step_num,". ID",agent.id, ". Species: ",agent.species, ". Position: ", agent.pos, ". Action: Move", "\n")


	if agent.energy <= 0
		# print(" Đến nghĩa địa vì đói \n")
		# kill_agent!(agent, model)
		kill_an_agent!(agent, model)
        return
	end

	# Grow
	agent.age += 1
	# Die
	if agent.age >= params.lifespan[species]
		# print(" Đến nghĩa địa vì già \n")
		# kill_agent!(agent, model)
		kill_an_agent!(agent, model)
		return
	end

    move_animal!(agent,model, Val(agent.species))

	# print(" đến ", agent.pos , "\n")
end
