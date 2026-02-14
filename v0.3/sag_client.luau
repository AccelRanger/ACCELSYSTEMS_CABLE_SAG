--Animation System--
WhereIsFolder = game.Workspace.ROPE_SAG
ChairAmount = WhereIsFolder.config.NumberOfChairs.Value
GripSetup = WhereIsFolder.LiftAnimations
ChairAmount = WhereIsFolder.config.NumberOfChairs.Value
ServerStorage =  game.ReplicatedStorage.ANIM_SAG.grips
zoneLoaded = script.zoneLoaded.Value

Lift = WhereIsFolder.LiftAnimations
SpeedValue = WhereIsFolder.config.LiftSpeed.Value

local CurrentNumber = 2

task.wait(6)

for i = 2, ChairAmount, 1 do
	local GripTest = ServerStorage.ChairGrip
	CloneChair = GripTest:Clone()
	CloneChair.Name = "C"..CurrentNumber
	CloneChair.Parent = GripSetup
	CurrentNumber = CurrentNumber + 1
end

variables = {
	animation = WhereIsFolder.config.Animation,
}

local AnimationVariables = {}
local RodTable = {}

for t = 2, ChairAmount, 1 do
	local loadedAnim = Lift["C"..t].AnimationController:LoadAnimation(variables.animation)
	table.insert(AnimationVariables, loadedAnim)
end

local LengthAnimationTrack = WhereIsFolder.ServerLiftAnimations["C1"].AnimationController:LoadAnimation(variables.animation)

task.wait(3)

local places = 3 
local Number2 = LengthAnimationTrack.Length
local mult = 10^places
AnimationLength = math.floor(Number2*mult)/mult

local LoopVariable = 1
TimePosition = 0
AddTimePerChair = (AnimationLength/ChairAmount)

for i = 2, ChairAmount, 1 do
	local anim1 = AnimationVariables[LoopVariable]
	anim1:Play()
	anim1.TimePosition = TimePosition
	anim1:AdjustSpeed(SpeedValue*0)
	TimePosition = TimePosition + AddTimePerChair
	LoopVariable = LoopVariable + 1
end

local LoopVariable = 1

for i = 2, ChairAmount, 1 do
	local anim1 = AnimationVariables[LoopVariable]
	anim1:AdjustSpeed(SpeedValue/10)
	LoopVariable = LoopVariable + 1
end

WhereIsFolder.Chairs.C1.grip.AttachPart.Weld.Part1 = WhereIsFolder.ServerLiftAnimations.C1.GripPart

for i = 2, ChairAmount, 1 do
	WhereIsFolder.Chairs["C"..i].grip.AttachPart.Weld.Part1 = WhereIsFolder.LiftAnimations["C"..i].GripPart
end

WhereIsFolder.config.LiftSpeed.Changed:Connect(function()
	local LoopVariable = 1

	for i = 1, ChairAmount, 1 do
		local anim1 = AnimationVariables[LoopVariable]
		anim1:AdjustSpeed(SpeedValue/10)
		LoopVariable = LoopVariable + 1
	end
end)

--[[

test:GetMarkerReachedSignal("connect"):Connect(function(paramString)
		print("connecting")
		local AnimationNumber = AnimationNumberValue
		local Sheave = WhereIsFolder.Sheaves["S"..paramString]
		local chair

		if AnimationNumber == 1 then
			chair = WhereIsFolder.ServerLiftAnimations["C1"]
		else
			chair = WhereIsFolder.LiftAnimations["C"..AnimationNumber]
		end

		if Sheave.Chairs.Value <= 0 then
			Sheave.FrontChair.Value = Lift["C"..AnimationNumber]

			Sheave.RodConstraint.Attachment1 = Sheave.FrontChair.Value.GripPart.front
			chair.RodConstraint.Attachment1 = Sheave.SectionEnd.End
			Sheave.Chairs.Value += 1
		else
			Sheave.RodConstraint.Attachment1 = Sheave.FrontChair.Value.GripPart.front
			chair.RodConstraint.Attachment1 = Sheave.SectionEnd.End
			Sheave.Chairs.Value += 1
		end
	end)	

--]]

function liftSync(AnimationNumberValue, TimePosition1)
	if zoneLoaded.Value == true then
		local AnimationNumberThing = AnimationNumberValue
		for i = 2, ChairAmount, 1 do
			local anim1 = AnimationVariables[AnimationNumberThing]
			if TimePosition1 > AnimationLength then
				TimePosition1 = TimePosition1 - AnimationLength
				anim1.TimePosition = TimePosition1 - 2
			else
				anim1.TimePosition = TimePosition1 - 2
			end
			AnimationNumberThing += 1
			TimePosition1 = TimePosition1 + AddTimePerChair
		end
	end
end


game.ReplicatedStorage.ANIM_SAG.remotes.liftSync.OnClientEvent:Connect(liftSync)
