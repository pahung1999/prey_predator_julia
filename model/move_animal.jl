include("./sub_function.jl")

function move_animal!(agent,model, ::Val{:tiger})
	radius=2
	positions = collect(nearby_positions(agent,model, radius))
	
	#Good positions : ô ko có hổ khác (hổ < 1)
	good_positions=pos_filter(positions, :tiger, 1 , "less" , model)
	if isempty(good_positions) #Nếu xung quanh đều có hổ, chọn ô ít hổ nhất
		pos=get_random_minmax(positions, :tiger ,"min",model)
		return move_agent!(agent, pos, model)
	end

	#Trong các ô ko hổ, chọn ngẫu nhiên một ô có lợn
	boar_positions=pos_filter(good_positions, :boar, 0 , "greater" , model)  #Có lợn
	bad_positions=pos_filter(good_positions, :boar, 1 , "less" , model) #Không có lợn
	if !isempty(boar_positions)
		# @info agent, boar_positions, model
		x=rand(model.rng,boar_positions)
		# @info "rand(boar_positions) ", x
		# @info "Agent in x ", agents_in_position(x,model)
		# @info "Agent in before move ", agents_in_position(agent,model)
		return move_agent!(agent, x, model)
	end
	#Khi ko có lợn xung quanh, năng lượng dưới 0.3, thực hiện tìm báo xung quanh
	leopard_positions=pos_filter(positions, :leopard, 0 ,"greater", model) #Có báo
	if agent.energy <=0.3 && !isempty(leopard_positions)
		pos=  get_random_minmax(leopard_positions, :leopard ,"min",model)
		return move_agent!(agent, pos, model)
	end

	return move_agent!(agent, rand(model.rng,bad_positions), model)
end

	

function move_animal!(agent, model, ::Val{:leopard})
	# Nearby position
	radius = 2
	positions = collect(nearby_positions(agent,model, radius))

	#Safe: Ô ko hổ
	#Good: Ô ít báo (<3)
	#Best: Ô có lợn rừng 
	if agent.energy >0.2
		safe_positions=pos_filter(positions, :tiger, 1 , "less" , model)
		if isempty(safe_positions) #nếu ô nào cx có hổ, chọn ô ít hổ nhất
			pos = get_random_minmax(positions, :tiger ,"min",model) 
			return move_agent!(agent, pos, model)
		else #lọc các ô có ít hơn 3 báo
			good_positions=pos_filter(safe_positions, :leopard, 3 , "less" , model)
			if isempty(good_positions) #Nếu ô nào cũng có báo, chọn ô ít báo nhất
				pos=get_random_minmax(positions, :leopard ,"min",model) 
				return move_agent!(agent, pos, model)
			else 
				#Lọc các ô có lợn
				best_positions=pos_filter(good_positions, :boar, 0 , "greater" , model)
				if !isempty(best_positions)
					return move_agent!(agent, rand(model.rng,best_positions), model)
				else
					return move_agent!(agent, rand(model.rng,good_positions), model)
				end
			end
		end
	end
	if agent.energy <=0.2 #Khi quá ít năng lượng, ưu tiên chọn ô có Lợn
		best_positions=pos_filter(positions, :boar, 0 , "greater" , model)
		if !isempty(best_positions)
			return move_agent!(agent, rand(model.rng,best_positions), model)
		end
		#Nếu xung quanh không có Lợn, chọn những ô an toàn (không hổ)
		safe_positions=pos_filter(positions, :tiger, 1 , "less" , model)
		if isempty(safe_positions)
			pos = get_random_minmax(positions, :tiger ,"min",model) 
			return move_agent!(agent, pos, model)
		end
		good_positions=pos_filter(safe_positions, :leopard, 3 , "less" , model)
		if isempty(good_positions)
			pos=get_random_minmax(positions, :leopard ,"min",model) 
			return move_agent!(agent, pos, model)
		end
		return move_agent!(agent, rand(model.rng,good_positions), model)
	end


end

function move_animal!(agent, model, ::Val{:boar})
	# Nearby position
	radius = 1
	positions = collect(nearby_positions(agent,model, radius))

	#Ô có dưới 5 lợn
	good_positions=pos_filter(positions, :boar, 5 ,"less", model)
	if isempty(good_positions)  #Nếu ô nào cx >= 5 lợn, di chuyển đến ô nhiều cỏ nhất	
		energy_count= Dict(
			pos => model.food[pos...]
			for pos in positions
		)
		energy_,pos = get_random_max_pos(energy_count,model)
		return move_agent!(agent, pos, model)
	end

	energy_count= Dict(
			pos => model.food[pos...]
			for pos in good_positions
		)
	energy_,pos = get_random_max_pos(energy_count,model)	
	return move_agent!(agent, pos, model)		
end
