--[[
	============================================================
	 AccelSystems Cable SAG
	 Module   : Lift Animation Synchronization
	 Type     : Server
	============================================================
--]]

local CableSagFolder             = game.Workspace.ROPE_SAG
local GripTemplatesFolder        = game.ReplicatedStorage.ANIM_SAG.grips
local ServerLiftAnimationsFolder = CableSagFolder.ServerLiftAnimations
local LiftSyncRemote             = game.ReplicatedStorage.ANIM_SAG.remotes.liftSync
local SyncRequestRemote          = game.ReplicatedStorage.ANIM_SAG.remotes.syncRequest

local ChairCount = CableSagFolder.config.NumberOfChairs.Value
local LiftSpeed  = CableSagFolder.config.LiftSpeed.Value

print(("[AccelSystems Cable SAG] Booting server lift sync :: %d chairs configured"):format(ChairCount))

task.wait(1)

local ServerGripTemplate = GripTemplatesFolder.ServerAnimGrip
local ServerChairGrip = ServerGripTemplate:Clone()
ServerChairGrip.Name = "C1"
ServerChairGrip.Parent = ServerLiftAnimationsFolder

print("[AccelSystems Cable SAG] Cloned server reference grip C1")

-- Loads the sag animation onto the reference anim controller
local AnimationConfig = {
	animation = CableSagFolder.config.Animation,
}

local ReferenceAnimationTrack = ServerLiftAnimationsFolder.C1.AnimationController:LoadAnimation(AnimationConfig.animation)

print("[AccelSystems Cable SAG] Waiting 3 seconds before playback")
task.wait(3)
print("[AccelSystems Cable SAG] Playing reference animation")

local LengthAnimationTrack = ServerLiftAnimationsFolder.C1.AnimationController:LoadAnimation(AnimationConfig.animation)

local ROUND_PLACES = 3
local RoundingMultiplier = 10 ^ ROUND_PLACES
local AnimationLength = math.floor(LengthAnimationTrack.Length * RoundingMultiplier) / RoundingMultiplier

print(("[AccelSystems Cable SAG] Animation length resolved: %.3f"):format(AnimationLength))

-- Start reference animation
ReferenceAnimationTrack:Play()
ReferenceAnimationTrack.TimePosition = 0
ReferenceAnimationTrack:AdjustSpeed(LiftSpeed / 10)

print("[AccelSystems Cable SAG] Reference animation playing.")

-- Live updates
CableSagFolder.config.LiftSpeed.Changed:Connect(function()
	LiftSpeed = CableSagFolder.config.LiftSpeed.Value
	ReferenceAnimationTrack:AdjustSpeed(LiftSpeed)
	print("[AccelSystems Cable SAG] LiftSpeed changed -> speed re-applied.")
end)

local function broadcastSync()
	local syncTimePosition = ReferenceAnimationTrack.TimePosition
	LiftSyncRemote:FireAllClients(1, syncTimePosition)
end

ReferenceAnimationTrack:GetMarkerReachedSignal("sync"):Connect(broadcastSync)

SyncRequestRemote.OnServerEvent:Connect(function(player)
	local syncTimePosition = ReferenceAnimationTrack.TimePosition
	LiftSyncRemote:FireClient(player, 1, syncTimePosition)
end)

print("[AccelSystems Cable SAG] Sync remotes connected. Server ready.")

-- fallback sync, every 8 seconds
while true do
	task.wait(8)
	broadcastSync()
end
