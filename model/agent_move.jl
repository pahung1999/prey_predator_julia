function agent_move!(agent::Animal, model)
	species = agent.species
    move_animal!(agent,model, Val(agent.species))

end

include("./sub_function.jl")



function move_animal!(agent,model, ::Val{:tiger})
	radius=2
	positions = collect(nearby_positions(agent,model, radius))
	# best_pos_list = []
	# max_point = 0
	# for pos in positions
	# 	pos_point = 0
	# 	#Ít hổ
	# 	if count(agent -> agent.species==:tiger ,agents_in_position(pos,model)) < 1
	# 		if agent.energy < 0.2
	# 			pos_point +=1
	# 		else
	# 			pos_point +=10
	# 		end
	# 	end
	# 	num_boar_in_pos = count(agent -> agent.species==:boar ,agents_in_position(pos,model))
	# 	if num_boar_in_pos > 0
	# 		if agent.energy < 0.2
	# 			pos_point +=10 * num_boar_in_pos
	# 		else
	# 			pos_point += num_boar_in_pos
	# 		end
	# 	end
	# 	print("pos_point: ",pos_point, "\n")
	# 	if pos_point > max_point
	# 		best_pos_list = []
	# 		push!(best_pos_list, pos)
	# 	elseif  pos_point == max_point
	# 		push!(best_pos_list, pos)
	# 	end
	# end
	# move_agent!(agent, rand(model.rng,best_pos_list), model)


	good_positions=pos_filter(positions, :tiger, 1 , "less" , model)

	if !isempty(good_positions)
		best_positions=pos_filter(good_positions, :boar, 0 , "greater" , model)
		if !isempty(best_positions)
			move_agent!(agent, rand(model.rng,best_positions), model)
		else
			move_agent!(agent, rand(model.rng,good_positions), model)
		end
	else
		move_agent!(agent, rand(model.rng,positions), model)
	end
end

	

function move_animal!(agent, model, ::Val{:leopard})
	# Nearby position
	radius = 2
	positions = collect(nearby_positions(agent,model, radius))

	#Safe: Ô ko hổ
	#Good: Ô ít báo
	#Best: Ô có lợn rừng 
	if agent.energy > 0.2
		#Ô ko hổ
		safe_positions=pos_filter(positions, :tiger, 1 , "less" , model)
		if isempty(safe_positions)
			random_pos=get_random_minmax(positions, :tiger , "min",model)
			move_agent!(agent, random_pos, model)
			return
		else
			good_positions=pos_filter(safe_positions, :leopard, 3 , "less" , model)
			if isempty(good_positions)
				random_pos=get_random_minmax(safe_positions, :leopard , "min",model)
				move_agent!(agent, random_pos, model)
				return
			else
				best_positions=pos_filter(safe_positions, :boar, 0 , "greater" , model)
				if !isempty(best_positions)
					move_agent!(agent, rand(model.rng,best_positions), model)
					return
				else
					move_agent!(agent, rand(model.rng,good_positions), model)
					return
				end
			end
		end
	end

	if agent.energy <= 0.2
		best_positions=pos_filter(positions, :boar, 0 , "greater" , model)
		if !isempty(best_positions)
			move_agent!(agent, rand(model.rng,best_positions), model)
			return
		else
			safe_positions=pos_filter(positions, :tiger, 1 , "less" , model)
			if isempty(safe_positions)
				random_pos=get_random_minmax(positions, :tiger , "min",model)
				move_agent!(agent, random_pos, model)
				return
			else
				good_positions=pos_filter(safe_positions, :leopard, 3 , "less" , model)
				if isempty(good_positions)
					random_pos=get_random_minmax(safe_positions, :leopard , "min",model)
					move_agent!(agent, random_pos, model)
					return
				else
					move_agent!(agent, rand(model.rng,good_positions), model)
					return
				end
			end
		end
	end

end


function move_animal!(agent, model, ::Val{:boar})
	# Nearby position
	radius = 1
	positions = collect(nearby_positions(agent,model, radius))

	#Lọc vị trí có ít hơn 5 lợn
	good_positions=safe_positions=pos_filter(positions, :boar, 5 , "less" , model)
	if !isempty(good_positions)
		food_dict=Dict( pos => model.food[pos...] for pos in good_positions)
		food_value,best_pos=get_random_max_pos(food_dict,model)
		move_agent!(agent, best_pos, model)
	end

	return move_agent!(agent,rand(model.rng,positions),model)
end
