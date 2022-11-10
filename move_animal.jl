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
	num_boar, pos  = findmax(last, count_boars)
	if num_boar>0
		return move_agent!(agent, pos, model)
	elseif agent.energy >= 0.3
		return move_agent!(agent, rand(positions), model)
	end
	
	num_leopard,pos  = findmax(last, count_leopard)
	if num_leopard==0
		return walk!(agent, pos, model)
	end
	
	num_leopard,pos  = findmin(last, filter!(x -> x[2]>0 ,count_leopard))
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
	num_boar,pos = findmax(last, count_boars)

	# If maximum number of boars is zero
	# walk randomly to a nearby positions
	if num_boar == 0
		return move_agent!(agent, rand(positions), model)
	else
		return walk!(agent, pos, model)
	end
end