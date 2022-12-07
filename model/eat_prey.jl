#Chọn con mồi trong 1 ô
include("./sub_function.jl")


function random_prey(pos , species, model)
	agent_list= filter(agents -> agents.species== species, collect(agents_in_position(pos,model)))
	if isempty(agent_list)
		return 0
	else
		return rand(model.rng,agent_list)
	end
	# for agent_prey in agent_list
	# 	if agent_prey.species == species
	# 		return agent_prey
	# 	end
	# end
	# print("No prey in this cell")
	# return 0
end


#Hổ ăn
function eat_prey!(agent,prey, model, ::Val{:tiger})

	if prey.species == :leopard 
        if agent.energy < 0.3 && rand(model.rng,Uniform(0, 1)) < model.fight_prob
            tiger_eat_prey!(agent,prey,model)
			kill_an_agent!(prey, model)
        end
        return
    else
		if rand(model.rng,Uniform(0, 1)) < model.params.catch_prob[agent.species]
            tiger_eat_prey!(agent,prey,model)
			kill_an_agent!(prey, model)
        end
		return
	end
end

function tiger_eat_prey!(agent,prey,model)
	params=model.params

	agent_list= filter(agent -> agent.species==:tiger, collect(agents_in_position(agent,model)))

	tiger_num_in_pos= length(agent_list)
	energy_1_tiger=prey.energy/tiger_num_in_pos
	
	for agent_tiger in agent_list
		energy_get = min(
				energy_1_tiger,
				params.energy_transfert[agent_tiger.species],
				params.max_energy[agent_tiger.species] - agent_tiger.energy)
		agent_tiger.energy += energy_get
	end
end


function eat_prey!(agent,prey, model, ::Val{:leopard})
	params=model.params
	if rand(model.rng,Uniform(0, 1)) < model.params.catch_prob[agent.species]
		energy_get = min(
				prey.energy,
				params.energy_transfert[agent.species],
				params.max_energy[agent.species] - agent.energy)
		agent.energy += energy_get
		kill_an_agent!(prey, model)
	end
	return
end