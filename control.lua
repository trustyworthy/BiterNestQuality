--control.lua
function roll_weighted_die(bias)
    local weights = {9000, 900, 90, 9, 1}
    local reversed_weights = {1, 9, 90, 900, 9000}
    local bias = game.forces["enemy"].get_evolution_factor("nauvis")
    for i = 1, #weights do
        weights[i] = weights[i] * (1 - bias) + reversed_weights[i] * bias
    end
    local total_weight = 0
    for _, weight in ipairs(weights) do
        total_weight = total_weight + weight
    end
    local rand = math.random(math.floor(total_weight))
    local cumulative_weight = 0
    for side, weight in ipairs(weights) do
        cumulative_weight = cumulative_weight + weight
        if rand <= cumulative_weight then
            return side
        end
    end
end
function roll_quality(bias)
	local quality = roll_weighted_die(bias)

	if quality == 1 then
		return "normal"
    end
	if quality == 2 then
		return "uncommon"
    end
	if quality == 3 then
		return "rare"
    end
	if quality == 4 then
		return "epic"
    end
	if quality == 5 then
		return "legendary"
    end
end
script.on_event(defines.events.on_biter_base_built,
	function(event)
		if event.entity.surface.name == "nauvis" then
			local nest = event.entity 
			local nest_pos = nest.position
			local nest_type = nest.name
			local nest_quality = roll_quality(game.forces["enemy"].get_evolution_factor("nauvis"))
			if settings.startup["spawn_location_and_quality_debug"].value == true then
				game.print("New nest created at: ")
				game.print(tostring(nest_pos.x))
				game.print(tostring(nest_pos.y))
				game.print("Nest Quality: ")
				game.print(nest_quality)
			end
			nest.destroy({raise_destroy = false})
			game.surfaces["nauvis"].create_entity({name = nest_type, quality = nest_quality, position = nest_pos})
		end
	end
)