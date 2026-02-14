--SpawnChairSystem
local folder = game.Workspace.ROPE_SAG

for i = 1, folder.config.NumberOfChairs.Value, 1 do
	local clone = script.chair:Clone()
	clone.Name = "C"..i
	clone.Parent = folder.Chairs
end
