function agent_reproduce!(agent::Animal, model)
#Born

    # print("Step: ",model.step_num,". ID",agent.id, ". Species: ",agent.species, ". Position: ", agent.pos, ". Action: Reproduce", "\n")
    params = model.params
    species = agent.species
    
    #năng lượng tiêu hao mỗi bước
	agent.energy = agent.energy - params.energy_consum[species]

	# print("Step: ",model.step_num,". ID",agent.id, ". Species: ",agent.species, ". Position: ", agent.pos, ". Action: Move", "\n")


	if agent.energy <= 0
		# print(" Đến nghĩa địa vì đói \n")
		# kill_agent!(agent, model)
		kill_an_agent!(agent, model)
        model.death_hun[species]+=1
        return
	end

	# Grow
	agent.age += 1
	# Die
	if agent.age >= params.lifespan[species]
		# print(" Đến nghĩa địa vì già \n")
		# kill_agent!(agent, model)
		kill_an_agent!(agent, model)
        model.death_old[species]+=1
		return
	end
    
    if agent.energy >= params.energy_reproduce[species]  && rand(model.rng,Uniform(0, 1)) <= params.proba_reproduce[species]
        nb_offspring= rand(model.rng,1:params.max_offsprings[species])

        energy_child=agent.energy/nb_offspring
        for _ in 1:nb_offspring
            id = nextid(model)
            pos = agent.pos
            
            add_agent!(animal(id, pos,species,energy_child), model)
            model.born_count[species]+=1
        end
        agent.energy=energy_child
        # print("ĐẺ")
    end
end