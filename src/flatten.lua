local nxml = require "src.nxml"
local io = require "io"

---Flattens the given nxml content
---@param content string
---@param data_folder string
local function flatten(content, data_folder)
	-- Parse
	local seen = false
	local tree = nxml.parse(content)
	local to_add = {}
	for _, v in ipairs(tree.children) do
		if v.name == "Base" then
			if seen then error("Multiple inheritance!") end
			seen = true
			---@type string
			local base_file = v.attr["file"]
			if not base_file then error("Base chilld missing file attribute!") end
			local data = false
			if base_file:find("data") then data = true end
			local path = ""
			if data then
				local addr = base_file:find("data/")
				if not addr then error("Base file data path isn't a valid path!") end
				path = data_folder .. base_file:sub(addr + 5)
			end
			-- Gather
			local file = assert(io.open(path,"r"))
			local parent_content = file:read("*a")
			file:close()
			local parent_tree = flatten(parent_content, data_folder)
			local modifications = {}
			local objects = {}
			for _, modifier in ipairs(v.children) do
				modifications[modifier.name] = {}
				objects[modifier.name] = {}
				for k, modifiction in pairs(v.attr) do
					modifications[modifier.name][k] = modifiction
				end
				for _, object in ipairs(v.children) do
					objects[modifier.name][object.name] = {}
					for k, modifiction in pairs(v.attr) do
						objects[modifier.name][object.name][k] = modifiction
					end
				end
			end
			--TODO: tags
			-- Modify
			for _, thing in ipairs(parent_tree.children) do
				local modifier = modifications[thing.name]
				if modifier then
					for k, modification in pairs(modifier) do
						thing[k] = modification
					end
				end
				for _, object in ipairs(thing.children) do
					--TODO: jump trajectories break this, need recursion
					local modifying_object = objects[object.name]
					if modifying_object then
						for k, modification in pairs(v.attr) do
							object[k] = modification
						end
					end
				end
				-- Incorporate
				table.insert(to_add, thing)
			end
		end
	end
	for _, v in ipairs(to_add) do
		table.insert(tree.children, v)
	end
	local ptr = 1
	while ptr <= #tree.children do
		if tree.children[ptr].name == "Base" then
			table.remove(tree.children,ptr)
		else
			ptr = ptr + 1
		end 
	end
	return tree
end

return flatten
