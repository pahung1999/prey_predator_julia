function move_animal!(agent,model, ::Val{:tiger})
	radius=2
	positions = collect(nearby_positions(agent,model, radius))

	# Count number of boards and leopard
	count_boars = Dict(
		pos => count(
			is_species(:boar), 
			agents_in_position(pos,model))
		for pos in positions
	)
	count_leopard = Dict(
		pos => count(
			is_species(:leopard), 
			agents_in_position(pos,model))
		for pos in positions
	)

	# Get the position with maximum boar
	num_boar, pos  = get_random_max_pos(count_boars)
	if num_boar>0
		return move_agent!(agent, pos, model)
	elseif agent.energy >= 0.3
		return move_agent!(agent, rand(positions), model)
	end
	
	num_leopard,pos  = get_random_max_pos(count_leopard)
	if num_leopard==0
		return move_agent!(agent, pos, model)
	end
	
	num_leopard,pos  = findmin(filter!(x -> x[2]>0 ,count_leopard))
	return move_agent!(agent, pos , model)
end

	

function move_animal!(agent, model, ::Val{:leopard})
	# Nearby position
	radius = 2
	positions = collect(nearby_positions(agent,model, radius))

	# Count number of boards
	count_boars = Dict(
		pos => count(
			is_species(:boar), 
			agents_in_position(pos,model))
		for pos in positions
	)

	# If energy is more than 0.2
	# Dodge the tigers
	if agent.energy >= 0.2
		filter!(positions) do pos
			count(is_species(:tiger), agents_in_position(pos,model)) == 0
		end
	end


	# Get the position with maximum boar
	num_boar,pos = get_random_max_pos(count_boars)

	# If maximum number of boars is zero
	# walk randomly to a nearby positions
	if num_boar == 0
		return move_agent!(agent, rand(positions), model)
	else
		return move_agent!(agent, pos, model)
	end
end

function move_animal!(agent, model, ::Val{:boar})
	# Nearby position
	radius = 1
	positions = collect(nearby_positions(agent,model, radius))
	# filter!(positions) do pos 
	# 	pos[1] <= model.params.grid_size[1] && pos[2] <= model.params.grid_size[1]
	# end
	# Count number of boars
	count_boars = Dict(
		pos => count(
			is_species(:boar), 
			agents_in_position(pos,model))
		for pos in positions
	)
	
	# Lọc ô hơn 5 lợn ra
	filter!(positions) do pos 
		count_boars[pos] < 5
	end

	if isempty(positions)  #Nếu ô nào cx >= 5 lợn, di chuyển đến ô nhiều cỏ nhất
		positions = collect(nearby_positions(agent,model, radius))		
		energy_count= Dict(
			pos => model.food[pos...]
			for pos in positions
		)
		energy_,pos = get_random_max_pos(energy_count)
		return move_agent!(agent, pos, model)
	end

	energy_count= Dict(
			pos => model.food[pos...]
			for pos in positions
		)

	energy_,pos = get_random_max_pos(energy_count)	
	
	# if pos == agent.pos
	# 	print("Không di chuyển")
	# end
	# print("Position before: \n")
	# print(agent.pos)
	# print("\n")
	# print("Position after: \n")
	# print(pos)
	# print("\n")

	return move_agent!(agent, pos, model)		
end

function get_random_max_pos(dict_count)
	max_value,pos = findmax(dict_count)
	pos_list=[k for (k,v) in dict_count if v==max_value]
	return max_value, rand(pos_list)
end

function collect_nearby_pos!(positions,model)
	filter!(positions) do pos 
		pos[1] <= model.params.grid_size[1] && pos[2] <= model.params.grid_size[1]
	end
end