function agent_reproduce!(agent::Animal, model)
#Born

    # print("Step: ",model.step_num,". ID",agent.id, ". Species: ",agent.species, ". Position: ", agent.pos, ". Action: Reproduce", "\n")
    params = model.params
    species = agent.species
    
    
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
end