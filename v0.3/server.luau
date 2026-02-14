--Animation System--
WhereIsFolder = game.Workspace.ROPE_SAG
ChairAmount = WhereIsFolder.config.NumberOfChairs.Value
ChairAmountAlt = 1
GripSetup = WhereIsFolder.ServerLiftAnimations
ServerStorage =  game.ReplicatedStorage.ANIM_SAG.grips

Lift = WhereIsFolder.ServerLiftAnimations
local CurrentNumber = 1

SpeedValue = WhereIsFolder.config.LiftSpeed.Value
wait (1)

for i = 1, ChairAmountAlt, 1 do
	local GripTest = ServerStorage.ServerAnimGrip
	CloneChair = GripTest:Clone()
	CloneChair.Name = "C"..CurrentNumber
	CloneChair.Parent = GripSetup
	CurrentNumber = CurrentNumber + 1
end


variables = {
	animation = WhereIsFolder.config.Animation,
}

local AnimationVariables = {}

for t = 1, ChairAmountAlt do
	loadedAnim =Lift["C"..t].AnimationController:LoadAnimation(variables.animation)
	table.insert(AnimationVariables, loadedAnim)
end

print("Waiting 3 SecondsFromServer")
wait(3)
print("Playing AnimationFromServer")

local LengthAnimationTrack = Lift["C1"].AnimationController:LoadAnimation(variables.animation)

local places = 3 
local Number2 = LengthAnimationTrack.Length
local mult = 10^places
AnimationLength = math.floor(Number2*mult)/mult

local LoopVariable = 1
TimePosition = 0
AddTimePerChair = (AnimationLength/ChairAmount)

for i = 1, ChairAmountAlt, 1 do
	local anim1 = AnimationVariables[LoopVariable]
	anim1:Play()
	anim1.TimePosition = TimePosition
	TimePosition = TimePosition + AddTimePerChair
	LoopVariable = LoopVariable + 1
end

local LoopVariable = 1

for i = 1, ChairAmountAlt, 1 do
	local anim1 = AnimationVariables[LoopVariable]
	anim1:AdjustSpeed(SpeedValue/10)
	LoopVariable = LoopVariable + 1
end

WhereIsFolder.config.LiftSpeed.Changed:Connect(function()
	local LoopVariable = 1

	for i = 1, ChairAmountAlt, 1 do
		local anim1 = AnimationVariables[LoopVariable]
		SpeedValue = WhereIsFolder.config.LiftSpeed.Value
		anim1:AdjustSpeed(SpeedValue)
		LoopVariable = LoopVariable + 1
	end
end)

AnimationNumberValue = 1

local anim1 = AnimationVariables[AnimationNumberValue]
TimePosition = 0

anim1:GetMarkerReachedSignal("sync"):Connect(function(paramString)
	AnimationNumberValue = 1
	local TimePosition1 = anim1.TimePosition
	local AnimationNumber = AnimationNumberValue
	game.ReplicatedStorage.ANIM_SAG.remotes.liftSync:FireAllClients(AnimationNumber, TimePosition1)
end)


game.ReplicatedStorage.ANIM_SAG.remotes.syncRequest.OnServerEvent:Connect(function(Player)
	AnimationNumberValue = 1
	local TimePosition1 = anim1.TimePosition
	local AnimationNumber = AnimationNumberValue
	game.ReplicatedStorage.ANIM_SAG.remotes.liftSync:FireClient(Player, AnimationNumber, TimePosition1)
end)

local anim1 = AnimationVariables[AnimationNumberValue]

while true do
	task.wait(8)
	local TimePosition1 = anim1.TimePosition
	local AnimationNumber = AnimationNumberValue
	game.ReplicatedStorage.ANIM_SAG.remotes.liftSync:FireAllClients(AnimationNumber, TimePosition1)
end
