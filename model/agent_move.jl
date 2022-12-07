function agent_move!(agent::Animal, model)
	species = agent.species
    move_animal!(agent,model, Val(agent.species))

end

include("./sub_function.jl")



function move_animal!(agent,model, ::Val{:tiger})
	radius=2
	positions = collect(nearby_positions(agent,model, radius))

	#Ô có lợn
	good_positions=pos_filter(positions, :boar, 0 , "greater" , model)  #Có lợn
	if !isempty(good_positions)
		move_agent!(agent, rand(model.rng,good_positions), model)
	else
		move_agent!(agent, rand(model.rng,positions), model)
	end
end

	

function move_animal!(agent, model, ::Val{:leopard})
	# Nearby position
	radius = 2
	positions = collect(nearby_positions(agent,model, radius))

	#Safe: Ô ko hổ
	#Best: Ô có lợn rừng 
	safe_positions=pos_filter(positions, :tiger, 1 , "less" , model)

	if !isempty(safe_positions)
		best_positions=pos_filter(safe_positions, :boar, 0 , "greater" , model)
		if !isempty(best_positions)
			return move_agent!(agent, rand(model.rng,best_positions), model)
		else
			return move_agent!(agent, rand(model.rng,safe_positions), model)
		end
	else
		return move_agent!(agent, rand(model.rng,positions), model)
	end

end

function move_animal!(agent, model, ::Val{:boar})
	# Nearby position
	radius = 1
	positions = collect(nearby_positions(agent,model, radius))

	return move_agent!(agent,rand(model.rng,positions),model)
end
