function agent_move!(agent::Animal, model)
	species = agent.species
    move_animal!(agent,model, Val(agent.species))

end

include("./sub_function.jl")


function move_animal!(agent,model, ::Val{:tiger})

	radius=2
	positions = collect(nearby_positions(agent,model, radius))

	pos_points=Dict( pos=>0 for pos in positions)
	
	for pos in positions
		if animal_in_pos_num(pos, :tiger, model) < 1
			pos_points[pos]+=10
		end
		if animal_in_pos_num(pos, :boar, model) > 0
			pos_points[pos]+=5
		end
		if agent.energy<0.3 && animal_in_pos_num(pos, :leopard, model) > 0
			pos_points[pos]+=5
		end
	end

	max_value, best_pos=get_random_max_pos(pos_points,model)

	move_agent!(agent, best_pos, model)

	# good_positions=pos_filter(positions, :tiger, 1 , "less" , model)

	# if !isempty(good_positions)
	# 	best_positions=pos_filter(good_positions, :boar, 0 , "greater" , model)
	# 	if !isempty(best_positions)
	# 		move_agent!(agent, rand(model.rng,best_positions), model)
	# 	else
	# 		move_agent!(agent, rand(model.rng,good_positions), model)
	# 	end
	# else
	# 	best_positions=pos_filter(positions, :boar, 0 , "greater" , model)
	# 	if !isempty(best_positions)
	# 		move_agent!(agent, rand(model.rng,best_positions), model)
	# 	else
	# 		move_agent!(agent, rand(model.rng,positions), model)
	# 	end
	# end
end

	

function move_animal!(agent, model, ::Val{:leopard})
	# Nearby position
	radius = 2
	positions = collect(nearby_positions(agent,model, radius))

	pos_points=Dict( pos=>0 for pos in positions)
	
	if agent.energy > 0.2
		for pos in positions
			if animal_in_pos_num(pos, :tiger, model) < 1
				pos_points[pos]+=10
			end
			if animal_in_pos_num(pos, :leopard, model) < 3
				pos_points[pos]+=5
			end
			if animal_in_pos_num(pos, :boar, model) > 0
				pos_points[pos]+=1
			end
		end
	else
		for pos in positions
			if animal_in_pos_num(pos, :tiger, model) < 1
				pos_points[pos]+=5
			end
			if animal_in_pos_num(pos, :leopard, model) < 3
				pos_points[pos]+=1
			end
			if animal_in_pos_num(pos, :boar, model) > 0
				pos_points[pos]+=10
			end
		end
	end

	max_value, best_pos=get_random_max_pos(pos_points,model)

	move_agent!(agent, best_pos, model)

	# #Safe: Ô ko hổ
	# #Good: Ô ít báo
	# #Best: Ô có lợn rừng 
	# if agent.energy > 0.2
	# 	#Ô ko hổ
	# 	safe_positions=pos_filter(positions, :tiger, 1 , "less" , model)
	# 	if isempty(safe_positions)
	# 		random_pos=get_random_minmax(positions, :tiger , "min",model)
	# 		move_agent!(agent, random_pos, model)
	# 		return
	# 	else
	# 		good_positions=pos_filter(safe_positions, :leopard, 3 , "less" , model)
	# 		if isempty(good_positions)
	# 			random_pos=get_random_minmax(safe_positions, :leopard , "min",model)
	# 			move_agent!(agent, random_pos, model)
	# 			return
	# 		else
	# 			best_positions=pos_filter(safe_positions, :boar, 0 , "greater" , model)
	# 			if !isempty(best_positions)
	# 				move_agent!(agent, rand(model.rng,best_positions), model)
	# 				return
	# 			else
	# 				move_agent!(agent, rand(model.rng,good_positions), model)
	# 				return
	# 			end
	# 		end
	# 	end
	# end

	# if agent.energy <= 0.2
	# 	best_positions=pos_filter(positions, :boar, 0 , "greater" , model)
	# 	if !isempty(best_positions)
	# 		move_agent!(agent, rand(model.rng,best_positions), model)
	# 		return
	# 	else
	# 		safe_positions=pos_filter(positions, :tiger, 1 , "less" , model)
	# 		if isempty(safe_positions)
	# 			random_pos=get_random_minmax(positions, :tiger , "min",model)
	# 			move_agent!(agent, random_pos, model)
	# 			return
	# 		else
	# 			good_positions=pos_filter(safe_positions, :leopard, 3 , "less" , model)
	# 			if isempty(good_positions)
	# 				random_pos=get_random_minmax(safe_positions, :leopard , "min",model)
	# 				move_agent!(agent, random_pos, model)
	# 				return
	# 			else
	# 				move_agent!(agent, rand(model.rng,good_positions), model)
	# 				return
	# 			end
	# 		end
	# 	end
	# end

end


function move_animal!(agent, model, ::Val{:boar})
	# Nearby position
	radius = 1
	positions = collect(nearby_positions(agent,model, radius))

	pos_points=Dict( pos=>0 for pos in positions)
	
	for pos in positions
		if animal_in_pos_num(pos, :tiger, model) < 1 && animal_in_pos_num(pos, :leopard, model) < 1
			pos_points[pos]+=10
		end
		if animal_in_pos_num(pos, :boar, model) < 5
			pos_points[pos]+=5
		end
		if model.food[pos...] > 0
			pos_points[pos]+=1
		end
	end

	max_value, best_pos=get_random_max_pos(pos_points,model)

	move_agent!(agent, best_pos, model)



	#Lọc vị trí có ít hơn 5 lợn
	# good_positions=pos_filter(positions, :tiger, 5 , "less" , model)
	# if !isempty(good_positions)
	# 	food_dict=Dict( pos => model.food[pos...] for pos in good_positions)
	# 	food_value,best_pos=get_random_max_pos(food_dict,model)
	# 	move_agent!(agent, best_pos, model)
	# end

	# return move_agent!(agent,rand(model.rng,positions),model)
end
