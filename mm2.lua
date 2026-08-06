local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local cfg = getgenv().MM2Hub or {}
getgenv().MM2Hub = cfg
cfg.silentAimEnabled = cfg.silentAimEnabled or false

if cfg.cleanup then
	pcall(cfg.cleanup)
end
cfg.cleanup = nil
cfg.installed = nil

local function nearestTarget()
	local best, bestDist = nil, math.huge
	local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end
	local origin = root.Position
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl ~= lp then
			local c = pl.Character
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			local hum = c and c:FindFirstChildOfClass("Humanoid")
			if hrp and hum and hum.Health > 0 then
				local d = (hrp.Position - origin).Magnitude
				if d < bestDist then
					best, bestDist = hrp, d
				end
			end
		end
	end
	return best
end

local function installSilentAim()
	if cfg.silentAimInstalled then
		return
	end
	local WeaponService = require(game:GetService("ReplicatedStorage"):WaitForChild("ClientServices"):WaitForChild("WeaponService"))

	local function aimPoint()
		if cfg.silentAimEnabled then
			local target = nearestTarget()
			if target then
				return CFrame.new(target.Position)
			end
		end
		return nil
	end

	local oldMouse = WeaponService.GetMouseTargetCFrame
	WeaponService.GetMouseTargetCFrame = newcclosure(function(self, ...)
		local p = aimPoint()
		if p then
			return p
		end
		return oldMouse(self, ...)
	end)

	local oldPos = WeaponService.GetTargetPosition
	WeaponService.GetTargetPosition = newcclosure(function(self, ...)
		local p = aimPoint()
		if p then
			return p
		end
		return oldPos(self, ...)
	end)

	cfg.silentAimInstalled = true
end

local ok, Rayfield = pcall(function()
	return loadstring(game:HttpGet("https://sirius.menu/gen2"))()
end)
if not ok or not Rayfield then
	warn("[AeroX] Rayfield failed to load: " .. tostring(Rayfield))
	return
end

local Window = Rayfield:CreateWindow({
	Name = "Project AeroX -- t.me/qvrezikk",
	Subtitle = "Silent Aim",
	Theme = "Dark",
	Configuration = {
		AutoSave = true,
		AutoLoad = true,
		FileName = "MM2Hub",
	},
})

local AimTab = Window:CreateTab({ Name = "Aim", Icon = "target" })

AimTab:CreateToggle({
	Name = "Silent Aim",
	Description = "Redericting knife/gun bullet into a target",
	Flag = "SilentAim",
	Value = cfg.silentAimEnabled,
	Callback = function(v)
		cfg.silentAimEnabled = v
	end,
})

installSilentAim()

cfg.cleanup = function()
	cfg.silentAimInstalled = nil
	cfg.installed = nil
end

cfg.installed = true
