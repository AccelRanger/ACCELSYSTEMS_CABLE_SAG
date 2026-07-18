--[[
	============================================================
	 AccelSystems Cable SAG
	 Module   : Lift Animation Synchronization
	 Type     : Client
	============================================================
--]]

local CableSagFolder     = game.Workspace.ROPE_SAG
local GripTemplatesFolder = game.ReplicatedStorage.ANIM_SAG.grips
local ChairCount    = CableSagFolder.config.NumberOfChairs.Value
local LiftSpeed     = CableSagFolder.config.LiftSpeed.Value
local LiftAnimationsFolder = CableSagFolder.LiftAnimations

local ZoneLoadedValue = script.zoneLoaded.Value

print(("[AccelSystems Cable SAG] Booting lift sync :: %d chairs configured"):format(ChairCount))

task.wait(8)

local chairNumber = 2
for i = 2, ChairCount, 1 do
	local ChairGripTemplate = GripTemplatesFolder.ChairGrip
	local newChairGrip = ChairGripTemplate:Clone()
	newChairGrip.Name = "C" .. chairNumber
	newChairGrip.Parent = LiftAnimationsFolder
	chairNumber = chairNumber + 1
end
print(("[AccelSystems Cable SAG] Cloned grips C2 -> C%d"):format(ChairCount))

-- Loads the sag animation onto anim controllers
local AnimationConfig = {
	animation = CableSagFolder.config.Animation,
}

local LiftAnimationTracks = {}

for t = 2, ChairCount, 1 do
	local loadedAnim = LiftAnimationsFolder["C" .. t].AnimationController:LoadAnimation(AnimationConfig.animation)
	table.insert(LiftAnimationTracks, loadedAnim)
end

-- Get reference anim track
local ReferenceAnimationTrack = CableSagFolder.ServerLiftAnimations["C1"].AnimationController:LoadAnimation(AnimationConfig.animation)
task.wait(3)

local ROUND_PLACES = 3
local RoundingMultiplier = 10 ^ ROUND_PLACES
local AnimationLength = math.floor(ReferenceAnimationTrack.Length * RoundingMultiplier) / RoundingMultiplier

print(("[AccelSystems Cable SAG] Animation length resolved: %.3f"):format(AnimationLength))

local TimeOffsetPerChair = AnimationLength / ChairCount
local stagingTimePosition = 0
local trackIndex = 1

for i = 2, ChairCount, 1 do
	local animTrack = LiftAnimationTracks[trackIndex]
	animTrack:Play()
	animTrack.TimePosition = stagingTimePosition
	animTrack:AdjustSpeed(LiftSpeed * 0) -- hold in place until sync kicks in
	stagingTimePosition = stagingTimePosition + TimeOffsetPerChair
	trackIndex = trackIndex + 1
end

-- Start
trackIndex = 1
for i = 2, ChairCount, 1 do
	local animTrack = LiftAnimationTracks[trackIndex]
	animTrack:AdjustSpeed(LiftSpeed / 10)
	trackIndex = trackIndex + 1
end

print("[AccelSystems Cable SAG] Chairs staggered and animating.")

-- Weld Grips
CableSagFolder.Chairs.C1.grip.AttachPart.Weld.Part1 = CableSagFolder.ServerLiftAnimations.C1.GripPart

for i = 2, ChairCount, 1 do
	CableSagFolder.Chairs["C" .. i].grip.AttachPart.Weld.Part1 = LiftAnimationsFolder["C" .. i].GripPart
end

print("[AccelSystems Cable SAG] Grip welds attached to all chairs. Rig is live.")

-- Live updates
CableSagFolder.config.LiftSpeed.Changed:Connect(function()
	local liveTrackIndex = 1
	for i = 2, ChairCount, 1 do
		local animTrack = LiftAnimationTracks[liveTrackIndex]
		animTrack:AdjustSpeed(LiftSpeed / 10)
		liveTrackIndex = liveTrackIndex + 1
	end
	print("[AccelSystems Cable SAG] LiftSpeed changed -> speeds re-applied.")
end)

-- REMOTE SYNC — Client -> Server lift TimePosition sync
local function onLiftSync(startChairIndex, syncTimePosition)
	if ZoneLoadedValue == true then
		local chairIndex = startChairIndex
		for i = 2, ChairCount, 1 do
			local animTrack = LiftAnimationTracks[chairIndex]
			if syncTimePosition > AnimationLength then
				syncTimePosition = syncTimePosition - AnimationLength
				animTrack.TimePosition = syncTimePosition - 2
			else
				animTrack.TimePosition = syncTimePosition - 2
			end
			chairIndex += 1
			syncTimePosition = syncTimePosition + TimeOffsetPerChair
		end
	end
end

game.ReplicatedStorage.ANIM_SAG.remotes.liftSync.OnClientEvent:Connect(onLiftSync)

print("[AccelSystems Cable SAG] liftSync listener connected. System ready.")

--[[
	------------------------------------------------------------
	 Reference only — Sheave hookup logic
	------------------------------------------------------------

	test:GetMarkerReachedSignal("connect"):Connect(function(sheaveId)
		print("connecting")
		local chairNumber = startChairIndex
		local Sheave = CableSagFolder.Sheaves["S" .. sheaveId]
		local chair
		if chairNumber == 1 then
			chair = CableSagFolder.ServerLiftAnimations["C1"]
		else
			chair = LiftAnimationsFolder["C" .. chairNumber]
		end
		if Sheave.Chairs.Value <= 0 then
			Sheave.FrontChair.Value = LiftAnimationsFolder["C" .. chairNumber]
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
