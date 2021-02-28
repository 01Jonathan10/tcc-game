function Map:a_star(x_s, y_s, x_f, y_f)
	local path_map = {}
	for i=1,self.dim.x do
		path_map[i] = {}
		for j=1,self.dim.x do
			path_map[i][j] = {}
		end
	end
	
	path_map[x_s][y_s] = {x=x_s,y=y_s, GCost = 0, cameFrom = nil}
	
	local start = path_map[x_s][y_s]
	local goal = {x=x_f,y=y_f}
	
	local openSet = {start}

	local current
	local currentKey
	local smallest = 0
	
    while table.getn(openSet) > 0 do
		smallest = 99999
		for key, each in pairs(openSet) do
			if each.GCost < smallest then
				smallest = each.GCost
				current = each
				currentKey = key
			end
		end
		        
		if current.x == goal.x and current.y == goal.y then
            return self:reconstruct_path(current)
		end

        table.remove(openSet, currentKey)
		current.checked = true

		local neighbors = self:get_path_neighbors(current)

        for _, neighbor in pairs(neighbors) do
            
			if not (path_map[neighbor.x][neighbor.y].checked) then				
				
				if not path_map[neighbor.x][neighbor.y].GCost then
					path_map[neighbor.x][neighbor.y] = neighbor
					table.insert(openSet, path_map[neighbor.x][neighbor.y])
				end
				
				if path_map[neighbor.x][neighbor.y].GCost > neighbor.GCost then
					path_map[neighbor.x][neighbor.y] = neighbor
				end
			end
		end
	end
	
    return nil
end

function Map:reconstruct_path(current)
    local total_path = {}
    
	while current do
		table.insert(total_path, 1, self[current.x][current.y])
        current = current.cameFrom
	end
	
    return total_path
end

function Map:get_path_neighbors(node)
	local neighbor_cells = self:neighbor_cells(self[node.x][node.y], true, 1)
	local neighbors = {}
	local cell
	
	for _, cell in ipairs(neighbor_cells) do
		table.insert(neighbors, {x=cell.x,y=cell.y, GCost = node.GCost + 1, cameFrom = node})
	end
	
	return neighbors
end
