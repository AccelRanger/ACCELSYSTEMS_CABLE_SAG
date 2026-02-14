--// AccelRanger

local Folder = game.Workspace.waypoints
local Waypoints = {}

for _, obj in ipairs(Folder:GetChildren()) do
	if tonumber(obj.Name) then
		table.insert(Waypoints, obj)
	end
end

table.sort(Waypoints, function(a, b)
	return tonumber(a.Name) < tonumber(b.Name)
end)

local KeyframeSequence = Instance.new("KeyframeSequence")
KeyframeSequence.Name = "GeneratedAnimation"

local baseSpeed = 15
local time = 0
local halfingPoint = 128 --#Waypoints/2 -- midpoint

for i = 1, #Waypoints do
	local waypoint = Waypoints[i]

	if i > 1 then
		local prev = Waypoints[i - 1]
		local dist = (waypoint.Position - prev.Position).Magnitude

		local station = waypoint:FindFirstChild("station")
		local deaccel = waypoint:FindFirstChild("deacceleration")

		local speed = baseSpeed
		if station and station.Value == true then
			speed = baseSpeed / 5
		elseif deaccel and deaccel.Value > 0 then
			speed = baseSpeed / deaccel.Value
		end

		local deltaT = dist / speed
		time += deltaT
	end

	local Keyframe = Instance.new("Keyframe")
	Keyframe.Time = time

	local RootPose = Instance.new("Pose")
	RootPose.Name = "HumanoidRootPart"
	RootPose.Weight = 0

	local cf = waypoint.CFrame

	if i > halfingPoint then
		cf += Vector3.new(0.6, 0, 0)
	end

	local GripPose = Instance.new("Pose")
	GripPose.Name = "GripPart"
	GripPose.CFrame = cf

	GripPose.Parent = RootPose
	Keyframe:AddPose(RootPose)

	Keyframe.Parent = KeyframeSequence
end

KeyframeSequence.Parent = Folder
print("Animation generated with " .. #Waypoints .. " keyframes for GripPart under HumanoidRootPart.")
