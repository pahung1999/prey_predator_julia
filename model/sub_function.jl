# Hàm lọc ra những pos có số loài A nhỏ hoặc lớn hơn giá trị max_count nào đó từ tập pos_list cho trước 
function pos_filter(pos_list, species, max_count, filter_type , model)
    function f1(pos)
        if filter_type == "less"
            count(agent -> agent.species==species ,agents_in_position(pos,model)) < max_count
        else
            count(agent -> agent.species==species ,agents_in_position(pos,model)) > max_count
        end
    end
    return filter(f1,pos_list)
end

# Random vị trí có số lượng min, max một loài nào đó trong pos_list
function get_random_minmax(pos_list, species ,filter_type,model)
    dict_count = Dict(
		pos => count(
			is_species(species), 
			agents_in_position(pos,model))
		for pos in pos_list
	)
    if filter_type == "max"
	    value,pos = findmax(dict_count)
    else
        value,pos = findmin(dict_count)
    end
	new_pos_list=[k for (k,v) in dict_count if v==value]
	return rand(model.rng,new_pos_list)
end

#Lấy random vị trí có giá trị lớn nhất
function get_random_max_pos(dict_count,model)
    
	max_value,pos = findmax(dict_count)
	pos_list=[k for (k,v) in dict_count if v==max_value]
	return max_value, rand(model.rng,pos_list)
end

function kill_an_agent!(agent,model)
    kill_agent!(agent, model)
    append!(model.death_list, agent.id)
end