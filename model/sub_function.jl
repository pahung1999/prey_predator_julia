# Hàm lọc ra những pos có số loài A nhỏ hơn giá trị max_count nào đó từ tập pos_list cho trước 
function pos_filter(pos_list, species, max_count , model)
    function f1(pos)
        count(agent -> agent.species==species ,agents_in_position(pos,model)) < max_count
    end
    return filter(f1,pos_list)
end

# Random vị trí có số lượng min, max một loài nào đó trong pos_list
function get_random_minmax(pos_list, species ,get_max,model)
    dict_count = Dict(
		pos => count(
			is_species(species), 
			agents_in_position(pos,model))
		for pos in pos_list
	)
    if get_max
	    value,pos = findmax(dict_count)
    else
        value,pos = findmin(dict_count)
    end
	new_pos_list=[k for (k,v) in dict_count if v==value]
	return rand(new_pos_list)
end


