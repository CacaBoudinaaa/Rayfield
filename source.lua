local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/CacaBoudinaaa/Rayfield/refs/heads/main/RayfieldUI'))()

local Window = Rayfield:CreateWindow({
   Name = "Essence | Rivals",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Essence",
   LoadingSubtitle = "by Anonymous",
   ShowText = "Essence", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "DarkBlue", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = Enum.KeyCode.RightShift, -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "EssenceHub" -- The file name for your hub/game
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "https://discord.gg/xt2g5cyp", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Essence | Key",
      Subtitle = "Link In Discord Server",
      Note = "Join Server (https://discord.gg/xt2g5cyp)", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = true, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"https://pastebin.com/raw/Sd37DTCR"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

-- placeholders so Rayfield callbacks won't error if invoked before implementations below
ESP = {
   Enabled = false,
   Config = {
      ShowName = false,
      ShowDistance = false,
      ShowHealth = false,
      Scale = 15,
      Opacity = 0.9,
      Color = Color3.fromRGB(255, 0, 0), -- Rouge pour les contours
      OutlineColor = Color3.fromRGB(255, 0, 0), -- Contours en rouge
      OutlineThickness = 2,
   },
   _instances = {},
}

SilentAim = {
   Enabled = false,
   ShowFOV = false,
   FOVRadius = 50,
   FOVYOffset = 0,
   TargetPart = "Head",
}

local fovCircle = nil

-- Exunys Aimbot Module (Optimized for First Person)
local ExunysDeveloperAimbot = nil

-- Aimbot initialization function
local function initializeAimbot()
   if ExunysDeveloperAimbot then
      return ExunysDeveloperAimbot
   end

   --[[
   	Universal Aimbot Module by Exunys © CC0 1.0 Universal (2023 - 2024)
   	Modified for First Person Support
   ]]

   --// Services
   local RunService = game:GetService("RunService")
   local UserInputService = game:GetService("UserInputService")
   local TweenService = game:GetService("TweenService")
   local Players = game:GetService("Players")
   local Camera = workspace.CurrentCamera
   local LocalPlayer = Players.LocalPlayer

   --// Variables
   local RequiredDistance, Typing, Running, Animation, ServiceConnections = 2000, false, false, nil, {}

   --// Environment
   local Environment = {
   	Settings = {
   		Enabled = false,
   		TeamCheck = false,
   		AliveCheck = true,
   		WallCheck = false,
   		Sensitivity = 0.2, -- Mouse movement multiplier (higher = faster)
   		TriggerKey = "MouseButton2",
   		Toggle = false,
   		LockPart = "Head", -- Body part to lock on
   		
   		-- Sticky aim settings
   		StickyAim = true,
   		StickyRadius = 120, -- Radius to maintain lock
   		StickyTime = 0.8 -- Time to maintain lock after losing target
   	},

   	FOVSettings = {
   		Enabled = false,
   		Visible = false,
   		Amount = 90,
   		Color = Color3.fromRGB(255, 255, 255),
   		LockedColor = Color3.fromRGB(255, 70, 70),
   		Transparency = 0.5,
   		Sides = 60,
   		Thickness = 1,
   		Filled = false
   	},

   	-- Variables for tracking
   	Locked = nil,
   	LastLockTime = 0,
   	StickyLockActive = false
   }

   -- Create FOV Circle
   local FOVCircle = Drawing.new("Circle")

   --// Core Functions
   local function CancelLock()
   	Environment.Locked = nil
   	Environment.StickyLockActive = false
   	Environment.LastLockTime = 0
   	
   	if Animation then 
   		Animation:Cancel()
   		Animation = nil
   	end
   	
   	FOVCircle.Color = Environment.FOVSettings.Color
   end

   local function GetClosestPlayer()
   	local Settings = Environment.Settings
   	local CurrentTime = tick()

   	-- Si on a déjà une cible et que sticky aim est activé
   	if Environment.Locked and Settings.StickyAim then
   		local Character = Environment.Locked.Character
   		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
   		
   		-- Vérifier si la cible est encore valide
   		if Character and Character:FindFirstChild(Settings.LockPart) and Humanoid then
   			-- Vérifier si la cible est encore vivante
   			if Settings.AliveCheck and Humanoid.Health <= 0 then
   				CancelLock()
   				return
   			end
   			
   			-- Vérifier la distance avec le sticky radius
   			local PartPosition = Character[Settings.LockPart].Position
   			local Vector, OnScreen = Camera:WorldToViewportPoint(PartPosition)
   			
   			if OnScreen then
   				local MouseLocation = UserInputService:GetMouseLocation()
   				local Distance = (Vector2.new(MouseLocation.X, MouseLocation.Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude
   				
   				-- Utiliser le sticky radius au lieu du FOV normal
   				if Distance <= Settings.StickyRadius then
   					Environment.StickyLockActive = true
   					Environment.LastLockTime = CurrentTime
   					return -- Garder la cible actuelle
   				end
   			end
   			
   			-- Si on dépasse le sticky radius, vérifier le temps de grâce
   			if Environment.StickyLockActive and (CurrentTime - Environment.LastLockTime) < Settings.StickyTime then
   				return -- Garder la cible pendant le temps de grâce
   			end
   		end
   		
   		-- Si on arrive ici, perdre la cible
   		CancelLock()
   	end

   	-- Chercher une nouvelle cible si on n'en a pas ou si on a perdu l'ancienne
   	if not Environment.Locked then
   		RequiredDistance = Environment.FOVSettings.Enabled and Environment.FOVSettings.Amount or 2000

   		for _, v in pairs(Players:GetPlayers()) do
   			if v ~= LocalPlayer then
   				if v.Character and v.Character:FindFirstChild(Settings.LockPart) and v.Character:FindFirstChildOfClass("Humanoid") then
   					if Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
   					if Settings.AliveCheck and v.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
   					
   					if Settings.WallCheck then
   						local PartsObscuring = Camera:GetPartsObscuringTarget({v.Character[Settings.LockPart].Position}, v.Character:GetDescendants())
   						if #PartsObscuring > 0 then continue end
   					end

   					local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[Settings.LockPart].Position)
   					local MouseLocation = UserInputService:GetMouseLocation()
   					local Distance = (Vector2.new(MouseLocation.X, MouseLocation.Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude

   					if Distance < RequiredDistance and OnScreen then
   						RequiredDistance = Distance
   						Environment.Locked = v
   						Environment.StickyLockActive = true
   						Environment.LastLockTime = CurrentTime
   					end
   				end
   			end
   		end
   	end
   end

   --// Main Loop
   local function Load()
   	ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
   		-- FOV Circle Update
   		if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
   			FOVCircle.Radius = Environment.FOVSettings.Amount
   			FOVCircle.Thickness = Environment.FOVSettings.Thickness
   			FOVCircle.Filled = Environment.FOVSettings.Filled
   			FOVCircle.NumSides = Environment.FOVSettings.Sides
   			FOVCircle.Color = Environment.FOVSettings.Color
   			FOVCircle.Transparency = Environment.FOVSettings.Transparency
   			FOVCircle.Visible = Environment.FOVSettings.Visible
   			local MouseLocation = UserInputService:GetMouseLocation()
   			FOVCircle.Position = Vector2.new(MouseLocation.X, MouseLocation.Y)
   		else
   			FOVCircle.Visible = false
   		end

   		-- Aimbot Logic
   		if Running and Environment.Settings.Enabled then
   			GetClosestPlayer()

   			if Environment.Locked then
   				local Character = Environment.Locked.Character
   				if Character and Character:FindFirstChild(Environment.Settings.LockPart) then
   					local TargetPart = Character[Environment.Settings.LockPart]
   					local TargetPosition = TargetPart.Position

   					-- Convert 3D position to screen coordinates
   					local Vector, OnScreen = Camera:WorldToViewportPoint(TargetPosition)
   					
   					if OnScreen then
   						local MouseLocation = UserInputService:GetMouseLocation()
   						local DeltaX = Vector.X - MouseLocation.X
   						local DeltaY = Vector.Y - MouseLocation.Y
   						
   						-- Apply smoothing/sensitivity
   						local Smoothing = Environment.Settings.Sensitivity
   						if Smoothing > 0 then
   							DeltaX = DeltaX * Smoothing
   							DeltaY = DeltaY * Smoothing
   						end
   						
   						-- Move mouse cursor using mousemoverel
   						if mousemoverel then
   							mousemoverel(DeltaX, DeltaY)
   						end
   					end

   					-- Update FOV Circle color when locked
   					FOVCircle.Color = Environment.FOVSettings.LockedColor
   				else
   					-- Target part no longer exists
   					CancelLock()
   				end
   			end
   		end
   	end)

   	-- Input handling
   	ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
   		if not Typing then
   			pcall(function()
   				if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
   					if Environment.Settings.Toggle then
   						Running = not Running
   						if not Running then CancelLock() end
   					else
   						Running = true
   					end
   				end
   			end)

   			pcall(function()
   				if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
   					if Environment.Settings.Toggle then
   						Running = not Running
   						if not Running then CancelLock() end
   					else
   						Running = true
   					end
   				end
   			end)
   		end
   	end)

   	ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
   		if not Typing and not Environment.Settings.Toggle then
   			pcall(function()
   				if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
   					Running = false
   					CancelLock()
   				end
   			end)

   			pcall(function()
   				if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
   					Running = false
   					CancelLock()
   				end
   			end)
   		end
   	end)
   end

   --// Typing Check
   ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
   	Typing = true
   end)

   ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
   	Typing = false
   end)

   --// Functions
   Environment.Exit = function()
   	for _, v in pairs(ServiceConnections) do
   		v:Disconnect()
   	end

   	if FOVCircle and FOVCircle.Remove then 
   		FOVCircle:Remove() 
   	end

   	ExunysDeveloperAimbot = nil
   end

   Environment.Restart = function()
   	for _, v in pairs(ServiceConnections) do
   		v:Disconnect()
   	end
   	Load()
   end

   -- Initialize
   Load()
   ExunysDeveloperAimbot = Environment

   return Environment
end

-- Ensure the aimbot module is created and enabled immediately on injection
pcall(function()
   if not ExunysDeveloperAimbot then
      ExunysDeveloperAimbot = initializeAimbot()
   end
   if ExunysDeveloperAimbot and ExunysDeveloperAimbot.Settings then
      ExunysDeveloperAimbot.Settings.Enabled = false -- Désactivé par défaut, activer via le toggle
   end
end)

-- persistence removed: no local file or Rayfield flag saving

local MainTab = Window:CreateTab("Home", 4483362458) -- Title, Image
local Section = MainTab:CreateSection("Main")

Rayfield:Notify({
   Title = "You executed the script !",
   Content = "Thank's for using Essence",
   Duration = 5,
   Image = 4483362458,
})

local Button = MainTab:CreateButton({
   Name = "Infinite Jump",
   Callback = function()
      -- Toggle infinite jump
      _G.infiniteJumpEnabled = not _G.infiniteJumpEnabled

      if _G.infiniteJumpStarted == nil then
         _G.infiniteJumpStarted = true
         local UserInputService = game:GetService("UserInputService")
         local Players = game:GetService("Players")
         local localPlayer = Players.LocalPlayer

         UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
               if _G.infiniteJumpEnabled then
                  local char = localPlayer.Character
                  if char then
                     local humanoid = char:FindFirstChildOfClass("Humanoid")
                     if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                     end
                  end
               end
            end
         end)

         game.StarterGui:SetCore("SendNotification", {Title="Rivals"; Text=(tostring(_G.infiniteJumpEnabled) == "true" and "Infinite Jump: ON" or "Infinite Jump: OFF"); Duration=3;})
      end
   end,
})

local Button = MainTab:CreateButton({
   Name = "No Clip",
   Callback = function()
      -- Toggle noclip (disable collisions on character parts)
      _G.noclipEnabled = not _G.noclipEnabled

      if _G.noclipEnabled then
         -- start Stepped connection to disable collisions continuously
         local RunService = game:GetService("RunService")
         local Players = game:GetService("Players")
         noclipConnection = RunService.Stepped:Connect(function()
            pcall(function()
               local pl = Players.LocalPlayer
               local char = pl and pl.Character
               if char then
                  for _, part in pairs(char:GetChildren()) do
                     if part:IsA("BasePart") then
                        part.CanCollide = false
                     end
                  end
               end
            end)
         end)

         game:GetService("StarterGui"):SetCore("SendNotification", {Title="Rivals"; Text="Noclip activé"; Duration=3;})
      else
         -- stop and restore collisions for current character
         if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
         end

         pcall(function()
            local Players = game:GetService("Players")
            local pl = Players.LocalPlayer
            local char = pl and pl.Character
            if char then
               for _, part in pairs(char:GetChildren()) do
                  if part:IsA("BasePart") then
                     part.CanCollide = true
                  end
               end
            end
         end)

         game:GetService("StarterGui"):SetCore("SendNotification", {Title="Rivals"; Text="Noclip désactivé"; Duration=3;})
      end
   end,
})

local VisualTab = Window:CreateTab("Visuals", 4483362458) -- Title, Image
local Section = VisualTab:CreateSection("Visuals")

local Toggle = VisualTab:CreateToggle({
   Name = "Enable ESP",
   CurrentValue = false,
   Flag = "toggleenableesp", -- unique flag to persist enable ESP separately
   Callback = function(Value)
   pcall(function()
      if type(ESP) == 'table' then
         ESP.Enabled = Value
         -- if enabling, create ESP immediately for already-connected players
         if Value then
            pcall(function()
               local Players = game:GetService('Players')
               for _, plr in pairs(Players:GetPlayers()) do
                  if plr ~= Players.LocalPlayer then
                     local char = plr.Character
                     if char and char.Parent and not ESP._instances[plr] then
                        pcall(function() createESPForPlayer(plr) end)
                     end
                  end
               end
            end)
         else
            -- if disabling, remove existing ESP instances immediately
            pcall(function()
               for plr, _ in pairs(ESP._instances) do
                  pcall(function() removeESPForPlayer(plr) end)
               end
            end)
         end
      end
   end)
   end,
})

local Slider = VisualTab:CreateSlider({
   Name = "ESP Opacity",
   Range = {0, 50},
   Increment = 1,
   Suffix = "",
   CurrentValue = 40,
   Flag = "slideresp", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   pcall(function()
      if type(ESP) == 'table' and ESP.Config then ESP.Config.Opacity = math.clamp(Value / 50, 0, 1) end
   end)
   end,
})

-- Shaders toggle
local shadersEnabled = false
local originalLighting = {}

local function enableShaders()
   pcall(function()
      local Lighting = game:GetService("Lighting")
      
      -- Save original lighting settings
      originalLighting = {
         Ambient = Lighting.Ambient,
         Brightness = Lighting.Brightness,
         ColorShift_Bottom = Lighting.ColorShift_Bottom,
         ColorShift_Top = Lighting.ColorShift_Top,
         EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
         EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
         GlobalShadows = Lighting.GlobalShadows,
         OutdoorAmbient = Lighting.OutdoorAmbient,
         ShadowSoftness = Lighting.ShadowSoftness,
         ClockTime = Lighting.ClockTime,
         FogEnd = Lighting.FogEnd,
         FogStart = Lighting.FogStart,
         FogColor = Lighting.FogColor,
      }
      
      -- Apply shader-like effects
      Lighting.Ambient = Color3.fromRGB(70, 70, 70)
      Lighting.Brightness = 2.5
      Lighting.ColorShift_Bottom = Color3.fromRGB(11, 0, 20)
      Lighting.ColorShift_Top = Color3.fromRGB(240, 127, 14)
      Lighting.EnvironmentDiffuseScale = 0.2
      Lighting.EnvironmentSpecularScale = 0.2
      Lighting.GlobalShadows = true
      Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
      Lighting.ShadowSoftness = 0.2
      Lighting.ClockTime = 14
      Lighting.FogEnd = 100000
      Lighting.FogStart = 0
      Lighting.FogColor = Color3.fromRGB(86, 86, 86)
      
      -- Add effects if they don't exist
      if not Lighting:FindFirstChild("ColorCorrection") then
         local cc = Instance.new("ColorCorrectionEffect")
         cc.Name = "RivalsShader_ColorCorrection"
         cc.Brightness = 0.1
         cc.Contrast = 0.1
         cc.Saturation = 0.2
         cc.TintColor = Color3.fromRGB(255, 255, 255)
         cc.Parent = Lighting
      end
      
      if not Lighting:FindFirstChild("BloomEffect") then
         local bloom = Instance.new("BloomEffect")
         bloom.Name = "RivalsShader_Bloom"
         bloom.Intensity = 0.4
         bloom.Size = 24
         bloom.Threshold = 1.2
         bloom.Parent = Lighting
      end
      
      if not Lighting:FindFirstChild("SunRaysEffect") then
         local sunRays = Instance.new("SunRaysEffect")
         sunRays.Name = "RivalsShader_SunRays"
         sunRays.Intensity = 0.1
         sunRays.Spread = 0.4
         sunRays.Parent = Lighting
      end
   end)
end

local function disableShaders()
   pcall(function()
      local Lighting = game:GetService("Lighting")
      
      -- Restore original lighting settings
      if originalLighting.Ambient then
         Lighting.Ambient = originalLighting.Ambient
         Lighting.Brightness = originalLighting.Brightness
         Lighting.ColorShift_Bottom = originalLighting.ColorShift_Bottom
         Lighting.ColorShift_Top = originalLighting.ColorShift_Top
         Lighting.EnvironmentDiffuseScale = originalLighting.EnvironmentDiffuseScale
         Lighting.EnvironmentSpecularScale = originalLighting.EnvironmentSpecularScale
         Lighting.GlobalShadows = originalLighting.GlobalShadows
         Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
         Lighting.ShadowSoftness = originalLighting.ShadowSoftness
         Lighting.ClockTime = originalLighting.ClockTime
         Lighting.FogEnd = originalLighting.FogEnd
         Lighting.FogStart = originalLighting.FogStart
         Lighting.FogColor = originalLighting.FogColor
      end
      
      -- Remove shader effects
      local effects = {"RivalsShader_ColorCorrection", "RivalsShader_Bloom", "RivalsShader_SunRays"}
      for _, effectName in pairs(effects) do
         local effect = Lighting:FindFirstChild(effectName)
         if effect then
            effect:Destroy()
         end
      end
   end)
end

local Toggle = VisualTab:CreateToggle({
   Name = "Enable Shaders",
   CurrentValue = false,
   Flag = "toggleshaders",
   Callback = function(Value)
      shadersEnabled = Value
      if Value then
         enableShaders()
         game:GetService('StarterGui'):SetCore('SendNotification', {Title='Rivals', Text='Shaders activés', Duration=3})
      else
         disableShaders()
         game:GetService('StarterGui'):SetCore('SendNotification', {Title='Rivals', Text='Shaders désactivés', Duration=3})
      end
   end,
})

-- Simple Custom Sky Toggle
local customSkyEnabled = false
local originalSkyData = nil

local function enableCustomSky()
   pcall(function()
      local Lighting = game:GetService("Lighting")
      
      -- Save original sky if it exists
      local existingSky = Lighting:FindFirstChildOfClass("Sky")
      if existingSky and not originalSkyData then
         originalSkyData = {
            SkyboxBk = existingSky.SkyboxBk,
            SkyboxDn = existingSky.SkyboxDn,
            SkyboxFt = existingSky.SkyboxFt,
            SkyboxLf = existingSky.SkyboxLf,
            SkyboxRt = existingSky.SkyboxRt,
            SkyboxUp = existingSky.SkyboxUp,
         }
      end
      
      -- Create or modify sky
      local sky = existingSky or Instance.new("Sky")
      sky.SkyboxBk = "rbxassetid://271042516"
      sky.SkyboxDn = "rbxassetid://271042556"
      sky.SkyboxFt = "rbxassetid://271042590"
      sky.SkyboxLf = "rbxassetid://271042628"
      sky.SkyboxRt = "rbxassetid://271042664"
      sky.SkyboxUp = "rbxassetid://271042701"
      
      if not existingSky then
         sky.Name = "RivalsCustomSky"
         sky.Parent = Lighting
      end
   end)
end

local function disableCustomSky()
   pcall(function()
      local Lighting = game:GetService("Lighting")
      local sky = Lighting:FindFirstChildOfClass("Sky")
      
      if sky then
         if originalSkyData then
            -- Restore original textures
            sky.SkyboxBk = originalSkyData.SkyboxBk
            sky.SkyboxDn = originalSkyData.SkyboxDn
            sky.SkyboxFt = originalSkyData.SkyboxFt
            sky.SkyboxLf = originalSkyData.SkyboxLf
            sky.SkyboxRt = originalSkyData.SkyboxRt
            sky.SkyboxUp = originalSkyData.SkyboxUp
         elseif sky.Name == "RivalsCustomSky" then
            -- Remove if we created it
            sky:Destroy()
         end
      end
   end)
end

-- Custom Sky Toggle
local Toggle = VisualTab:CreateToggle({
   Name = "Custom Skybox",
   CurrentValue = false,
   Flag = "togglecustomsky",
   Callback = function(Value)
      customSkyEnabled = Value
      if Value then
         enableCustomSky()
         game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = 'Rivals', 
            Text = 'Skybox personnalisé activé', 
            Duration = 3
         })
      else
         disableCustomSky()
         game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = 'Rivals', 
            Text = 'Skybox original restauré', 
            Duration = 3
         })
      end
   end,
})

local Button = VisualTab:CreateButton({
   Name = "Reapply Skybox",
   Callback = function()
      if customSkyEnabled then
         disableCustomSky()
         task.wait(0.1)
         enableCustomSky()
         game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = 'Rivals', 
            Text = 'Skybox réappliqué', 
            Duration = 2
         })
      else
         game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = 'Rivals', 
            Text = 'Activez d\'abord le skybox personnalisé', 
            Duration = 2
         })
      end
   end,
})

-- Remove Flashbang Effect Toggle
local Toggle = VisualTab:CreateToggle({
   Name = "Remove Flashbang Effect",
   CurrentValue = false,
   Flag = "removeflashbang",
   Callback = function(Value)
      if Value then
         pcall(function()
            game:GetService("StarterPlayer").StarterPlayerScripts.UserInterface.FlashbangGui:Destroy()
            game:GetService("Players").LocalPlayer.PlayerScripts.UserInterface.FlashbangGui:Destroy()
         end)
         game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = 'Rivals', 
            Text = 'Flashbang effect removed (rejoin to restore)', 
            Duration = 3
         })
      end
   end,
})

-- Remove Smoke Clouds Toggle
local smokeRemovalEnabled = false
task.spawn(function()
   while true do
      if smokeRemovalEnabled then
         pcall(function()
            for _, v in pairs(workspace:GetChildren()) do
               if v.Name == "Smoke Grenade" then
                  v:Destroy()
               end
            end
         end)
      end
      task.wait(0.1)
   end
end)

local Toggle = VisualTab:CreateToggle({
   Name = "Remove Smoke Clouds",
   CurrentValue = false,
   Flag = "removesmoke",
   Callback = function(Value)
      smokeRemovalEnabled = Value
      if Value then
         game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = 'Rivals', 
            Text = 'Smoke removal activé', 
            Duration = 3
         })
      else
         game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = 'Rivals', 
            Text = 'Smoke removal désactivé', 
            Duration = 3
         })
      end
   end,
})

-- Enemy ESP Color Picker
local ColorPicker = VisualTab:CreateColorPicker({
   Name = "Enemy ESP Color",
   Color = ESP.Config.Color,
   Flag = "espcolor",
   Callback = function(Color)
      pcall(function()
         if type(ESP) == 'table' and ESP.Config then
            ESP.Config.Color = Color
            ESP.Config.OutlineColor = Color
         end
      end)
   end
})

-- 4K Wet/Rain Graphics Toggle (Inspired by pshade)
local graphics4K = false
local originalGraphics = {}
local graphics4KEffects = {}
local originalParts = {}

local function enable4KGraphics()
   pcall(function()
      local Lighting = game:GetService("Lighting")
      local Workspace = game:GetService("Workspace")
      local Terrain = Workspace:FindFirstChildOfClass("Terrain")
      
      -- Sauvegarder TOUS les paramètres originaux (comme pshade)
      originalGraphics = {
         Brightness = Lighting.Brightness,
         ColorShift_Bottom = Lighting.ColorShift_Bottom,
         ColorShift_Top = Lighting.ColorShift_Top,
         EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
         EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
         OutdoorAmbient = Lighting.OutdoorAmbient,
         ShadowSoftness = Lighting.ShadowSoftness,
         ExposureCompensation = Lighting.ExposureCompensation,
         Ambient = Lighting.Ambient,
         ClockTime = Lighting.ClockTime,
         GeographicLatitude = Lighting.GeographicLatitude,
         GlobalShadows = Lighting.GlobalShadows,
      }
      
      -- Sauvegarder les paramètres Terrain/Water
      if Terrain then
         originalGraphics.Terrain = {
            WaterReflectance = Terrain.WaterReflectance,
            WaterTransparency = Terrain.WaterTransparency,
            WaterWaveSize = Terrain.WaterWaveSize,
            WaterWaveSpeed = Terrain.WaterWaveSpeed,
            WaterColor = Terrain.WaterColor,
         }
      end
      
      -- Appliquer les paramètres 4K WET/RAIN (effet mouillé brillant)
      Lighting.Brightness = 3.2 -- Plus brillant pour l'effet mouillé
      Lighting.ColorShift_Bottom = Color3.fromRGB(40, 50, 70) -- Teinte bleutée (pluie)
      Lighting.ColorShift_Top = Color3.fromRGB(180, 200, 220) -- Ciel gris pluie
      Lighting.EnvironmentDiffuseScale = 0.4 -- Plus de diffusion pour brillance
      Lighting.EnvironmentSpecularScale = 0.85 -- TRÈS IMPORTANT pour les reflets mouillés
      Lighting.OutdoorAmbient = Color3.fromRGB(110, 125, 145) -- Ambiance pluie
      Lighting.ShadowSoftness = 0.4 -- Ombres douces (nuages)
      Lighting.ExposureCompensation = 0.35 -- Plus lumineux
      Lighting.Ambient = Color3.fromRGB(90, 100, 120) -- Ambiance bleutée
      Lighting.GlobalShadows = true -- Ombres activées
      Lighting.ClockTime = 15.5 -- Temps nuageux
      
      -- Appliquer effet WET sur le Terrain/Water
      if Terrain then
         Terrain.WaterReflectance = 0.95 -- Maximum de reflet (effet mouillé)
         Terrain.WaterTransparency = 0.85 -- Eau très transparente
         Terrain.WaterWaveSize = 0.15 -- Petites vagues (pluie)
         Terrain.WaterWaveSpeed = 25 -- Vagues rapides
         Terrain.WaterColor = Color3.fromRGB(60, 80, 100) -- Eau grisâtre (pluie)
      end
      
      -- Gérer l'atmosphère (RÉDUITE pour éviter le voile/brouillard)
      local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
      if not atmosphere then
         atmosphere = Instance.new("Atmosphere")
         atmosphere.Parent = Lighting
         table.insert(graphics4KEffects, atmosphere)
      end
      -- Sauvegarder les valeurs originales
      if not originalGraphics.Atmosphere then
         originalGraphics.Atmosphere = {
            Density = atmosphere.Density,
            Offset = atmosphere.Offset,
            Glare = atmosphere.Glare,
            Haze = atmosphere.Haze,
            Color = atmosphere.Color,
            Decay = atmosphere.Decay
         }
      end
      atmosphere.Density = 0.1 -- Très faible (évite le voile)
      atmosphere.Offset = 0.25 -- Brume minimale
      atmosphere.Glare = 0.05 -- Très peu de glare
      atmosphere.Haze = 0.3 -- Très peu de brume (évite le flou)
      atmosphere.Color = Color3.fromRGB(200, 210, 220) -- Couleur claire
      atmosphere.Decay = Color3.fromRGB(150, 160, 180) -- Déclin léger
      
      -- Gérer le bloom (BRILLANCE MOUILLÉE - RÉDUIT POUR ÉVITER FLOU)
      local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
      if not bloom then
         bloom = Instance.new("BloomEffect")
         bloom.Parent = Lighting
         table.insert(graphics4KEffects, bloom)
      end
      -- Sauvegarder les valeurs originales
      if not originalGraphics.Bloom then
         originalGraphics.Bloom = {
            Intensity = bloom.Intensity,
            Size = bloom.Size,
            Threshold = bloom.Threshold,
            Enabled = bloom.Enabled
         }
      end
      bloom.Enabled = true
      bloom.Intensity = 0.45 -- Réduit (évite le flou glow)
      bloom.Size = 24 -- Plus petit (évite le halo flou)
      bloom.Threshold = 0.8 -- Plus haut (moins de surfaces brillent = moins flou)
      
      -- Gérer la profondeur de champ (DÉSACTIVÉ)
      local depth = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
      if not depth then
         depth = Instance.new("DepthOfFieldEffect")
         depth.Parent = Lighting
         table.insert(graphics4KEffects, depth)
      end
      -- Sauvegarder les valeurs originales
      if not originalGraphics.Depth then
         originalGraphics.Depth = {
            FarIntensity = depth.FarIntensity,
            FocusDistance = depth.FocusDistance,
            InFocusRadius = depth.InFocusRadius,
            NearIntensity = depth.NearIntensity,
            Enabled = depth.Enabled
         }
      end
      depth.Enabled = false -- DÉSACTIVÉ pour éviter le flou
      
      -- Ajouter ColorCorrection (TEINTE CLAIRE POUR NETTETÉ)
      local colorcor = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
      if not colorcor then
         colorcor = Instance.new("ColorCorrectionEffect")
         colorcor.Parent = Lighting
         table.insert(graphics4KEffects, colorcor)
      end
      -- Sauvegarder les valeurs originales
      if not originalGraphics.ColorCorrection then
         originalGraphics.ColorCorrection = {
            Brightness = colorcor.Brightness,
            Contrast = colorcor.Contrast,
            Saturation = colorcor.Saturation,
            TintColor = colorcor.TintColor,
            Enabled = colorcor.Enabled
         }
      end
      colorcor.Enabled = true
      colorcor.Brightness = 0.1 -- Légèrement plus lumineux (plus net)
      colorcor.Contrast = 0.2 -- Plus de contraste (plus net)
      colorcor.Saturation = 0 -- Saturation normale (évite ternissement)
      colorcor.TintColor = Color3.fromRGB(220, 230, 245) -- Teinte très claire
      
      -- Ajouter SunRays (désactivé pour temps de pluie)
      local sunrays = Lighting:FindFirstChildOfClass("SunRaysEffect")
      if not sunrays then
         sunrays = Instance.new("SunRaysEffect")
         sunrays.Parent = Lighting
         table.insert(graphics4KEffects, sunrays)
      end
      -- Sauvegarder les valeurs originales
      if not originalGraphics.SunRays then
         originalGraphics.SunRays = {
            Intensity = sunrays.Intensity,
            Spread = sunrays.Spread,
            Enabled = sunrays.Enabled
         }
      end
      sunrays.Enabled = false -- Désactivé (pas de soleil sous la pluie)
      
      -- APPLIQUER EFFET MOUILLÉ SUR TOUTES LES SURFACES (BRILLANCE + LISSE)
      task.spawn(function()
         local count = 0
         local processedParts = {}
         
         -- Fonction pour traiter un objet
         local function processPart(obj)
            if obj:IsA("BasePart") and not processedParts[obj] then
               processedParts[obj] = true
               
               -- Sauvegarder les propriétés originales
               if not originalParts[obj] then
                  originalParts[obj] = {
                     Material = obj.Material,
                     Reflectance = obj.Reflectance,
                  }
               end
               
               -- Appliquer effet mouillé sur TOUS les types de matériaux
               obj.Material = Enum.Material.SmoothPlastic -- Surface lisse
               obj.Reflectance = math.min(obj.Reflectance + 0.35, 0.65) -- Augmenter reflets
               
               count = count + 1
               
               -- Yield toutes les 100 itérations pour éviter les freezes
               if count % 100 == 0 then
                  task.wait()
               end
            end
         end
         
         -- Traiter tous les objets existants
         for _, obj in pairs(Workspace:GetDescendants()) do
            processPart(obj)
         end
         
         -- Écouter les nouveaux objets ajoutés (murs qui spawn après)
         Workspace.DescendantAdded:Connect(function(obj)
            if graphics4K then
               task.wait(0.1) -- Petit délai pour laisser l'objet se charger
               processPart(obj)
            end
         end)
         
         game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = 'Rivals', 
            Text = count .. ' surfaces rendues mouillées/brillantes', 
            Duration = 3
         })
      end)
      
      game:GetService('StarterGui'):SetCore('SendNotification', {
         Title = 'Rivals', 
         Text = '4K Wet/Rain Graphics activé - Traitement en cours...', 
         Duration = 3
      })
   end)
end

local function disable4KGraphics()
   pcall(function()
      local Lighting = game:GetService("Lighting")
      local Workspace = game:GetService("Workspace")
      local Terrain = Workspace:FindFirstChildOfClass("Terrain")
      
      -- Restaurer tous les paramètres Lighting
      if originalGraphics.Brightness then
         Lighting.Brightness = originalGraphics.Brightness
         Lighting.ColorShift_Bottom = originalGraphics.ColorShift_Bottom
         Lighting.ColorShift_Top = originalGraphics.ColorShift_Top
         Lighting.EnvironmentDiffuseScale = originalGraphics.EnvironmentDiffuseScale
         Lighting.EnvironmentSpecularScale = originalGraphics.EnvironmentSpecularScale
         Lighting.OutdoorAmbient = originalGraphics.OutdoorAmbient
         Lighting.ShadowSoftness = originalGraphics.ShadowSoftness
         Lighting.ExposureCompensation = originalGraphics.ExposureCompensation
         Lighting.Ambient = originalGraphics.Ambient
         Lighting.ClockTime = originalGraphics.ClockTime
         Lighting.GeographicLatitude = originalGraphics.GeographicLatitude
         Lighting.GlobalShadows = originalGraphics.GlobalShadows
      end
      
      -- Restaurer Terrain/Water
      if originalGraphics.Terrain and Terrain then
         Terrain.WaterReflectance = originalGraphics.Terrain.WaterReflectance
         Terrain.WaterTransparency = originalGraphics.Terrain.WaterTransparency
         Terrain.WaterWaveSize = originalGraphics.Terrain.WaterWaveSize
         Terrain.WaterWaveSpeed = originalGraphics.Terrain.WaterWaveSpeed
         Terrain.WaterColor = originalGraphics.Terrain.WaterColor
      end
      
      -- Restaurer Atmosphere
      if originalGraphics.Atmosphere then
         local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
         if atmosphere then
            atmosphere.Density = originalGraphics.Atmosphere.Density
            atmosphere.Offset = originalGraphics.Atmosphere.Offset
            atmosphere.Glare = originalGraphics.Atmosphere.Glare
            atmosphere.Haze = originalGraphics.Atmosphere.Haze
            atmosphere.Color = originalGraphics.Atmosphere.Color
            atmosphere.Decay = originalGraphics.Atmosphere.Decay
         end
      end
      
      -- Restaurer Bloom
      if originalGraphics.Bloom then
         local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
         if bloom then
            bloom.Intensity = originalGraphics.Bloom.Intensity
            bloom.Size = originalGraphics.Bloom.Size
            bloom.Threshold = originalGraphics.Bloom.Threshold
            bloom.Enabled = originalGraphics.Bloom.Enabled
         end
      end
      
      -- Restaurer Depth
      if originalGraphics.Depth then
         local depth = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
         if depth then
            depth.FarIntensity = originalGraphics.Depth.FarIntensity
            depth.FocusDistance = originalGraphics.Depth.FocusDistance
            depth.InFocusRadius = originalGraphics.Depth.InFocusRadius
            depth.NearIntensity = originalGraphics.Depth.NearIntensity
            depth.Enabled = originalGraphics.Depth.Enabled
         end
      end
      
      -- Restaurer ColorCorrection
      if originalGraphics.ColorCorrection then
         local colorcor = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
         if colorcor then
            colorcor.Brightness = originalGraphics.ColorCorrection.Brightness
            colorcor.Contrast = originalGraphics.ColorCorrection.Contrast
            colorcor.Saturation = originalGraphics.ColorCorrection.Saturation
            colorcor.TintColor = originalGraphics.ColorCorrection.TintColor
            colorcor.Enabled = originalGraphics.ColorCorrection.Enabled
         end
      end
      
      -- Restaurer SunRays
      if originalGraphics.SunRays then
         local sunrays = Lighting:FindFirstChildOfClass("SunRaysEffect")
         if sunrays then
            sunrays.Intensity = originalGraphics.SunRays.Intensity
            sunrays.Spread = originalGraphics.SunRays.Spread
            sunrays.Enabled = originalGraphics.SunRays.Enabled
         end
      end
      
      -- Restaurer les propriétés des objets (Material + Reflectance)
      task.spawn(function()
         for obj, props in pairs(originalParts) do
            if obj and obj.Parent then
               pcall(function()
                  obj.Material = props.Material
                  obj.Reflectance = props.Reflectance
               end)
            end
         end
         originalParts = {}
      end)
      
      -- Nettoyer les effets créés
      for _, effect in ipairs(graphics4KEffects) do
         if effect and effect.Parent then
            effect:Destroy()
         end
      end
      graphics4KEffects = {}
      
      game:GetService('StarterGui'):SetCore('SendNotification', {
         Title = 'Rivals', 
         Text = '4K Wet/Rain Graphics désactivé', 
         Duration = 3
      })
   end)
end

local Toggle = VisualTab:CreateToggle({
   Name = "4K Wet/Rain Graphics",
   CurrentValue = false,
   Flag = "toggle4kgraphics",
   Callback = function(Value)
      graphics4K = Value
      if Value then
         enable4KGraphics()
      else
         disable4KGraphics()
      end
   end,
})

local SilentTab = Window:CreateTab("Silent", 4483362458) -- Title, Image
local Section = SilentTab:CreateSection("Silent")

local Toggle = SilentTab:CreateToggle({
   Name = "Silent Aim",
   CurrentValue = false,
   Flag = "togglesilentaim", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   pcall(function()
      if type(SilentAim) == 'table' then SilentAim.Enabled = Value end
   end)
   end,
})

local Toggle = SilentTab:CreateToggle({
   Name = "Show FOV",
   CurrentValue = false,
   Flag = "togglesfovsilent", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   pcall(function()
      if type(SilentAim) == 'table' then SilentAim.ShowFOV = Value end
   end)
   end,
})

-- Aimbot Toggle Section
local Section = SilentTab:CreateSection("Aimbot")

local Toggle = SilentTab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Flag = "toggleaimbot", -- A flag is the identifier for the configuration file
   Callback = function(Value)
      pcall(function()
         if not ExunysDeveloperAimbot then
            ExunysDeveloperAimbot = initializeAimbot()
         end
         
         if ExunysDeveloperAimbot and ExunysDeveloperAimbot.Settings then
            ExunysDeveloperAimbot.Settings.Enabled = Value
            
            if Value then
               game:GetService('StarterGui'):SetCore('SendNotification', {
                  Title = 'Rivals', 
                  Text = 'Aimbot activé - Clic droit pour viser', 
                  Duration = 3
               })
            else
               game:GetService('StarterGui'):SetCore('SendNotification', {
                  Title = 'Rivals', 
                  Text = 'Aimbot désactivé', 
                  Duration = 3
               })
            end
         end
      end)
   end,
})

local Toggle = SilentTab:CreateToggle({
   Name = "Wall Check",
   CurrentValue = false,
   Flag = "togglewallcheck",
   Callback = function(Value)
      pcall(function()
         if ExunysDeveloperAimbot and ExunysDeveloperAimbot.Settings then
            ExunysDeveloperAimbot.Settings.WallCheck = Value
         end
      end)
   end,
})

local Toggle = SilentTab:CreateToggle({
   Name = "Show Aimbot FOV",
   CurrentValue = false,
   Flag = "toggleaimbotfov",
   Callback = function(Value)
      pcall(function()
         if ExunysDeveloperAimbot and ExunysDeveloperAimbot.FOVSettings then
            ExunysDeveloperAimbot.FOVSettings.Visible = Value
         end
      end)
   end,
})

local Slider = SilentTab:CreateSlider({
   Name = "Aimbot FOV Size",
   Range = {30, 200},
   Increment = 5,
   Suffix = "",
   CurrentValue = 90,
   Flag = "aimbotfovsize",
   Callback = function(Value)
      pcall(function()
         if ExunysDeveloperAimbot and ExunysDeveloperAimbot.FOVSettings then
            ExunysDeveloperAimbot.FOVSettings.Amount = Value
         end
      end)
   end,
})

local Slider = SilentTab:CreateSlider({
   Name = "Aimbot Smoothness",
   Range = {0.1, 1},
   Increment = 0.05,
   Suffix = "x",
   CurrentValue = 0.2,
   Flag = "aimbotsmooth",
   Callback = function(Value)
      pcall(function()
         if ExunysDeveloperAimbot and ExunysDeveloperAimbot.Settings then
            ExunysDeveloperAimbot.Settings.Sensitivity = Value
         end
      end)
   end,
})

local Slider = SilentTab:CreateSlider({
   Name = "Sticky Radius",
   Range = {60, 200},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 120,
   Flag = "stickyradius",
   Callback = function(Value)
      pcall(function()
         if ExunysDeveloperAimbot and ExunysDeveloperAimbot.Settings then
            ExunysDeveloperAimbot.Settings.StickyRadius = Value
         end
      end)
   end,
})

local Slider = SilentTab:CreateSlider({
   Name = "Sticky Time",
   Range = {0.3, 2},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.8,
   Flag = "stickytime",
   Callback = function(Value)
      pcall(function()
         if ExunysDeveloperAimbot and ExunysDeveloperAimbot.Settings then
            ExunysDeveloperAimbot.Settings.StickyTime = Value
         end
      end)
   end,
})

local Dropdown = SilentTab:CreateDropdown({
   Name = "Aimbot Target Part",
   Options = {"Head", "HumanoidRootPart", "Torso"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Flag = "aimbottarget",
   Callback = function(Options)
      pcall(function()
         if ExunysDeveloperAimbot and ExunysDeveloperAimbot.Settings then
            if type(Options) == 'table' then
               ExunysDeveloperAimbot.Settings.LockPart = Options[1]
            else
               ExunysDeveloperAimbot.Settings.LockPart = Options
            end
         end
      end)
   end,
})

local Section = SilentTab:CreateSection("Silent")

local Slider = SilentTab:CreateSlider({
   Name = "Silent FOV Radius",
   Range = {25, 300},
   Increment = 1,
   Suffix = "",
   CurrentValue = 50, -- default set to 50
   Flag = "slidefovsilent", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   pcall(function()
      -- enforce minimum radius 25
      local clamped = math.max(Value, 25)
      if type(SilentAim) == 'table' then SilentAim.FOVRadius = clamped end
      if fovCircle then pcall(function() fovCircle.Radius = clamped end) end
   end)
   end,
})

local Slider = SilentTab:CreateSlider({
   Name = "FOV Y Offset",
   Range = {-80, 80},
   Increment = 1,
   Suffix = "px",
   CurrentValue = 0,
   Flag = "slidefovyoffset",
   Callback = function(Value)
   pcall(function()
      if type(SilentAim) == 'table' then SilentAim.FOVYOffset = Value end
   end)
   end,
})

local Dropdown = SilentTab:CreateDropdown({
   Name = "Target Dropdown",
   Options = {"Head","Body","Legit"},
   CurrentOption = {"Legit"},
   MultipleOptions = false,
   Flag = "targetsilent", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Options)
      pcall(function()
         if type(SilentAim) == 'table' then
            -- Rayfield dropdown may pass a table when MultipleOptions = false, normalize to string
            if type(Options) == 'table' then
               SilentAim.TargetPart = Options[1]
            else
               SilentAim.TargetPart = Options
            end
         end
      end)
   end,
})

-- #########################

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Initialize defaults and try to read saved Rayfield configuration values if available
do
   -- enforce minimum FOV
   SilentAim.FOVRadius = math.max(SilentAim.FOVRadius or 25, 25)
   if fovCircle then pcall(function() fovCircle.Radius = SilentAim.FOVRadius end) end

   -- persistence disabled: no Rayfield flag restoration
end

-- Ensure SilentAim defaults persist after UI/Rayfield initialization (some UIs restore flags and may override)
spawn(function()
   wait(0.2)
   pcall(function()
      if type(SilentAim) == 'table' then
         SilentAim.Enabled = false
         SilentAim.ShowFOV = false
         SilentAim.FOVRadius = 50
         SilentAim.TargetPart = "Legit"
      end
      if fovCircle then
         pcall(function()
            fovCircle.Radius = SilentAim.FOVRadius
            fovCircle.Visible = SilentAim.ShowFOV
         end)
      end
   end)
end)

-- ESP implementation: Highlight + BillboardGui with name/distance/health
ESP = {
   Enabled = false,
   Config = {
      ShowName = false,
      ShowDistance = false,
   ShowHealth = false,
   Scale = 15,
   Opacity = 0.9,
      Color = Color3.fromRGB(255, 0, 0), -- Rouge pour les contours
      OutlineColor = Color3.fromRGB(255, 0, 0), -- Contours en rouge
      OutlineThickness = 2,
   },
   _instances = {}, -- store per-player created instances and update conn
}

local function createESPForPlayer(plr)
   if not plr or not plr.Character then return end
   local char = plr.Character
   local head = char:FindFirstChild("Head")
   local humanoid = char:FindFirstChildOfClass('Humanoid')
   if not head or not humanoid then return end

   -- cleanup existing if any
   if ESP._instances[plr] then
      pcall(function()
         for _, obj in pairs(ESP._instances[plr]) do
            if typeof(obj) == 'Instance' then obj:Destroy() end
         end
      end)
      ESP._instances[plr] = nil
   end

   -- Highlight
   local highlight = Instance.new('Highlight')
   highlight.Name = 'Rivals_ESP_Highlight'
   highlight.Adornee = char
   highlight.FillColor = ESP.Config.Color
   highlight.FillTransparency = 0.8 -- Plus transparent pour voir les contours
   highlight.OutlineColor = ESP.Config.OutlineColor or Color3.fromRGB(255, 0, 0)
   highlight.OutlineTransparency = 0 -- Contours bien visibles
   highlight.Parent = char

   -- BillboardGui
   local billboard = Instance.new('BillboardGui')
   billboard.Name = 'Rivals_ESP_Billboard'
   billboard.Adornee = head
   billboard.Size = UDim2.new(0, 200, 0, 60)
   billboard.StudsOffset = Vector3.new(0, 2, 0)
   billboard.AlwaysOnTop = true
   billboard.Parent = head

   local frame = Instance.new('Frame')
   frame.Size = UDim2.new(1, 0, 1, 0)
   frame.BackgroundTransparency = 1 -- transparent background for nametag
   frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
   frame.BorderSizePixel = 0
   frame.Parent = billboard

   local nameLabel = Instance.new('TextLabel')
   nameLabel.Size = UDim2.new(1, -8, 0.5, 0)
   nameLabel.Position = UDim2.new(0, 4, 0, 0)
   nameLabel.BackgroundTransparency = 1
   nameLabel.TextColor3 = ESP.Config.Color
   nameLabel.TextScaled = false
   nameLabel.Font = Enum.Font.SourceSansBold
   nameLabel.Text = plr.Name
   nameLabel.TextSize = math.clamp(ESP.Config.Scale, 8, 64)
   nameLabel.Visible = ESP.Config.ShowName
   nameLabel.Parent = frame

   local infoLabel = Instance.new('TextLabel')
   infoLabel.Size = UDim2.new(1, -8, 0.5, 0)
   infoLabel.Position = UDim2.new(0, 4, 0.5, 0)
   infoLabel.BackgroundTransparency = 1
   infoLabel.TextColor3 = Color3.fromRGB(255,255,255)
   infoLabel.TextScaled = false
   infoLabel.Font = Enum.Font.SourceSans
   infoLabel.Text = ''
   infoLabel.TextSize = math.clamp(ESP.Config.Scale * 0.7, 8, 48)
   infoLabel.Visible = (ESP.Config.ShowDistance or ESP.Config.ShowHealth)
   infoLabel.Parent = frame

   -- Per-player updater
   local conn = RunService.Heartbeat:Connect(function()
      if not plr.Character or not plr.Character.Parent then
         -- character removed
         pcall(function()
            if highlight then highlight:Destroy() end
            if billboard then billboard:Destroy() end
         end)
         if ESP._instances[plr] then ESP._instances[plr] = nil end
         conn:Disconnect()
         return
      end

      -- Update visuals
      local partsOK = plr.Character:FindFirstChild('HumanoidRootPart') and plr.Character:FindFirstChild('Head')
      if not partsOK then return end
      -- distance
      local distText = ''
      if ESP.Config.ShowDistance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') then
         local dist = (LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
         distText = string.format('%.1fm', dist)
      end
      -- health
      local hpText = ''
      if ESP.Config.ShowHealth and plr.Character:FindFirstChildOfClass('Humanoid') then
         hpText = 'HP: ' .. math.floor(plr.Character:FindFirstChildOfClass('Humanoid').Health)
      end

      -- name visibility and sizing
      nameLabel.Visible = ESP.Config.ShowName
      nameLabel.TextSize = math.clamp(ESP.Config.Scale, 8, 64)
      nameLabel.TextColor3 = ESP.Config.Color

      -- info label (distance/health only)
      local infoParts = {}
      if distText ~= '' then table.insert(infoParts, distText) end
      if hpText ~= '' then table.insert(infoParts, hpText) end
      if #infoParts > 0 then
         infoLabel.Visible = true
         infoLabel.Text = table.concat(infoParts, ' | ')
         infoLabel.TextSize = math.clamp(ESP.Config.Scale * 0.7, 8, 48)
      else
         infoLabel.Visible = false
      end

      highlight.FillColor = ESP.Config.Color
      highlight.FillTransparency = 0.8 -- Garder transparent pour les contours
      highlight.OutlineColor = ESP.Config.OutlineColor or Color3.fromRGB(255, 0, 0)
      highlight.OutlineTransparency = 0 -- Contours toujours visibles
   end)

   ESP._instances[plr] = {Highlight = highlight, Billboard = billboard, Conn = conn}
end

local function removeESPForPlayer(plr)
   if not ESP._instances[plr] then return end
   pcall(function()
      local inst = ESP._instances[plr]
      if inst.Conn then inst.Conn:Disconnect() end
      if inst.Highlight and inst.Highlight.Parent then inst.Highlight:Destroy() end
      if inst.Billboard and inst.Billboard.Parent then inst.Billboard:Destroy() end
   end)
   ESP._instances[plr] = nil
end

-- Global update/check loop
RunService.Heartbeat:Connect(function()
   for _, plr in pairs(Players:GetPlayers()) do
      if plr == LocalPlayer then
         -- skip local player
      else
         local char = plr.Character
         if ESP.Enabled then
            if char and char.Parent and not ESP._instances[plr] then
               createESPForPlayer(plr)
            end
         else
            if ESP._instances[plr] then removeESPForPlayer(plr) end
         end
      end
   end
end)

-- Cleanup on player removal
Players.PlayerRemoving:Connect(function(plr)
   removeESPForPlayer(plr)
end)

-- Recreate ESP when a player's character spawns
Players.PlayerAdded:Connect(function(plr)
   plr.CharacterAdded:Connect(function()
      if ESP.Enabled and plr ~= LocalPlayer then
         -- will be picked up by Heartbeat loop
      end
   end)
end)

-- Silent aim (simple camera snap while mouse held)
SilentAim = {
   Enabled = false,
   ShowFOV = true,
   FOVRadius = 50,
   TargetPart = "Legit",
}

-- Create FOV drawing circle (works on many executors)
local fovCircle
pcall(function()
   local Drawing = Drawing
   if Drawing and typeof(Drawing.new) == 'function' then
      fovCircle = Drawing.new('Circle')
      fovCircle.Thickness = 1
      fovCircle.NumSides = 64
      fovCircle.Radius = SilentAim.FOVRadius
      fovCircle.Color = Color3.new(1,1,1)
      fovCircle.Filled = false
      fovCircle.Visible = false
   end
end)

-- Target Info UI (shows current target name, avatar and health bar)
local targetGui
local targetFrame
local targetAvatar
local targetNameLabel
local targetHealthBarBg
local targetHealthBar
pcall(function()
   local PlayersSvc = game:GetService('Players')
   local localPlayer = PlayersSvc.LocalPlayer
   targetGui = Instance.new('ScreenGui')
   targetGui.Name = 'Rivals_TargetInfo'
   targetGui.ResetOnSpawn = false
   targetGui.Parent = localPlayer:WaitForChild('PlayerGui')

   targetFrame = Instance.new('Frame')
   targetFrame.Name = 'TargetFrame'
   targetFrame.Size = UDim2.new(0, 260, 0, 60)
   targetFrame.Position = UDim2.new(0.5, -130, 0.05, 0)
   targetFrame.BackgroundColor3 = Color3.fromRGB(20,20,25)
   targetFrame.BackgroundTransparency = 0
   targetFrame.BorderSizePixel = 0
   targetFrame.Visible = false
   targetFrame.Parent = targetGui

   local corner = Instance.new('UICorner') corner.CornerRadius = UDim.new(0,10) corner.Parent = targetFrame

   targetAvatar = Instance.new('ImageLabel')
   targetAvatar.Name = 'Avatar'
   targetAvatar.Size = UDim2.new(0,48,0,48)
   targetAvatar.Position = UDim2.new(0,6,0,6)
   targetAvatar.BackgroundTransparency = 1
   targetAvatar.Image = ''
   targetAvatar.Parent = targetFrame

   targetNameLabel = Instance.new('TextLabel')
   targetNameLabel.Name = 'Name'
   targetNameLabel.Size = UDim2.new(0,180,0,24)
   targetNameLabel.Position = UDim2.new(0,62,0,6)
   targetNameLabel.BackgroundTransparency = 1
   targetNameLabel.TextColor3 = Color3.fromRGB(255,255,255)
   targetNameLabel.Font = Enum.Font.SourceSansBold
   targetNameLabel.TextSize = 18
   targetNameLabel.TextXAlignment = Enum.TextXAlignment.Left
   targetNameLabel.Text = ''
   targetNameLabel.Parent = targetFrame

   targetHealthBarBg = Instance.new('Frame')
   targetHealthBarBg.Name = 'HPBg'
   targetHealthBarBg.Size = UDim2.new(0,180,0,14)
   targetHealthBarBg.Position = UDim2.new(0,62,0,32)
   targetHealthBarBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
   targetHealthBarBg.BorderSizePixel = 0
   targetHealthBarBg.Parent = targetFrame

   local hpCorner = Instance.new('UICorner') hpCorner.CornerRadius = UDim.new(0,6) hpCorner.Parent = targetHealthBarBg

   targetHealthBar = Instance.new('Frame')
   targetHealthBar.Name = 'HP'
   targetHealthBar.Size = UDim2.new(0,0,1,0)
   targetHealthBar.Position = UDim2.new(0,0,0,0)
   targetHealthBar.BackgroundColor3 = Color3.fromRGB(0,200,50)
   targetHealthBar.BorderSizePixel = 0
   targetHealthBar.Parent = targetHealthBarBg

   local hpInnerCorner = Instance.new('UICorner') hpInnerCorner.CornerRadius = UDim.new(0,6) hpInnerCorner.Parent = targetHealthBar
end)

-- Helper: find nearest visible target to mouse within radius
local function getClosestTargetToCursor(radius)
   local userInput = game:GetService('UserInputService')
   local mx, my
   pcall(function()
      if userInput and userInput.GetMouseLocation then
         local loc = userInput:GetMouseLocation()
         mx, my = loc.X, loc.Y
      end
   end)
   if not mx then
      local m = LocalPlayer:GetMouse()
      mx, my = m.X, m.Y
   end
   local closestPart, closestPlayer, closestDist
   for _, plr in pairs(Players:GetPlayers()) do
      if plr == LocalPlayer then continue end
      local char = plr.Character
      if char then
         local part = nil
         -- determine desired part based on mode: Head, Body or Legit
         local mode = tostring(SilentAim.TargetPart or "Head"):lower()
         local desired = "head"
         if mode == "legit" then
            if not _G.__silentaim_randseeded then math.randomseed(tick()); _G.__silentaim_randseeded = true end
            if math.random() <= 0.25 then
               desired = "head"
            else
               desired = "body"
            end
         elseif mode == "body" then
            desired = "body"
         else
            desired = "head"
         end

         if desired == "body" then
            part = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('UpperTorso') or char:FindFirstChild('LowerTorso') or char:FindFirstChild('Torso')
         else
            part = char:FindFirstChild('Head')
         end
         if part then
            local screenPos = Camera:WorldToViewportPoint(part.Position)
            local onScreen = screenPos.Z > 0
            if onScreen then
               local dx = screenPos.X - mx
               local dy = screenPos.Y - my
               local dist = math.sqrt(dx*dx + dy*dy)
               if dist <= radius then
                  if (not closestDist) or dist < closestDist then
                     closestPart = part
                     closestPlayer = plr
                     closestDist = dist
                  end
               end
            end
         end
      end
   end
   -- store the current target player for UI
   if closestPlayer then
      SilentAim.TargetPlayer = closestPlayer
      return closestPlayer, closestPart
   else
      SilentAim.TargetPlayer = nil
      return nil, nil
   end
end

-- Input handling for silent aim
do
   local mouse = LocalPlayer:GetMouse()
   local userInput = game:GetService('UserInputService')
   local holding = false
   local prevCamCFrame

   mouse.Button1Down:Connect(function()
      if not SilentAim.Enabled then return end
      holding = true
      prevCamCFrame = Camera.CFrame
      local targetPlayer, targetPart = getClosestTargetToCursor(SilentAim.FOVRadius)
      if targetPart then
         Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
      end
   end)

   mouse.Button1Up:Connect(function()
      if holding and prevCamCFrame then
         pcall(function() Camera.CFrame = prevCamCFrame end)
      end
      holding = false
   end)

   RunService.RenderStepped:Connect(function()
      if fovCircle then
         fovCircle.Visible = SilentAim.ShowFOV
         fovCircle.Radius = SilentAim.FOVRadius
         local userInput = game:GetService('UserInputService')
         local mx, my
         pcall(function()
            if userInput and userInput.GetMouseLocation then
               local loc = userInput:GetMouseLocation()
               mx, my = loc.X, loc.Y
            end
         end)
         if not mx then
            local mouse = LocalPlayer:GetMouse()
            mx, my = mouse.X, mouse.Y
         end
         local yOffset = 0
         pcall(function() if type(SilentAim) == 'table' and SilentAim.FOVYOffset then yOffset = SilentAim.FOVYOffset end end)
         fovCircle.Position = Vector2.new(mx, my + yOffset)
      end
   end)
end

RunService.RenderStepped:Connect(function()
   pcall(function()
      if SilentAim.Enabled and SilentAim.TargetPlayer and targetFrame and targetFrame.Parent then
         local tp = SilentAim.TargetPlayer
         local char = tp.Character
         if char and char.Parent then
            local hum = char:FindFirstChildOfClass('Humanoid')
            -- show UI
            targetFrame.Visible = true
            targetNameLabel.Text = tp.Name
            -- update health bar
            if hum and hum.MaxHealth > 0 then
               local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
               targetHealthBar.Size = UDim2.new(pct, 0, 1, 0)
               -- color from green to red
               targetHealthBar.BackgroundColor3 = Color3.fromHSV(pct * 0.33, 1, 0.9)
            else
               targetHealthBar.Size = UDim2.new(0, 0, 1, 0)
            end
            -- avatar thumbnail async (non-blocking)
            spawn(function()
               local ok,thumb = pcall(function()
                  return game:GetService('Players'):GetUserThumbnailAsync(tp.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size48x48)
               end)
               if ok and thumb and targetAvatar then
                  pcall(function() targetAvatar.Image = thumb end)
               end
            end)
         else
            targetFrame.Visible = false
         end
      else
         if targetFrame then targetFrame.Visible = false end
      end
   end)
end)


local SettingsTab = Window:CreateTab("Baltant", 4483362458) -- Title, Image
local Section = SettingsTab:CreateSection("Baltant")

-- Teleport behind toggle (bind to P)
do
   local teleConn = nil
   local function teleportBehindLocal(targetPlayer)
      pcall(function()
         if not targetPlayer or not targetPlayer.Character then return end
         local targetHRP = targetPlayer.Character:FindFirstChild('HumanoidRootPart')
         local me = Players.LocalPlayer
         local myHRP = me and me.Character and me.Character:FindFirstChild('HumanoidRootPart')
         if not targetHRP or not myHRP then return end
         -- place behind target with same orientation as target
         local behind = targetHRP.CFrame * CFrame.new(0, 0, 6) -- Position derrière (z positif)
         myHRP.CFrame = behind -- Garder l'orientation de la cible
         pcall(function() myHRP.AssemblyLinearVelocity = Vector3.new(0,0,0); myHRP.AssemblyAngularVelocity = Vector3.new(0,0,0) end)
      end)
   end

   SettingsTab:CreateToggle({
      Name = "TP Behind (P)",
      CurrentValue = false,
      Flag = "tpbehind_toggle",
      Callback = function(val)
         local UserInput = game:GetService('UserInputService')
         if val then
            if teleConn then teleConn:Disconnect(); teleConn = nil end
            teleConn = UserInput.InputBegan:Connect(function(input, gp)
               if gp then return end
               if input.KeyCode == Enum.KeyCode.P then
                  pcall(function()
                     local target = nil
                     if type(SilentAim) == 'table' and SilentAim.TargetPlayer then target = SilentAim.TargetPlayer end
                     if not target and type(getClosestTargetToCursor) == 'function' then
                        local p, _ = getClosestTargetToCursor(100)
                        target = p
                     end
                     teleportBehindLocal(target)
                  end)
               end
            end)
            game:GetService('StarterGui'):SetCore('SendNotification', {Title='Rivals', Text='TP Behind enabled (P)', Duration=3})
         else
            if teleConn then teleConn:Disconnect(); teleConn = nil end
            game:GetService('StarterGui'):SetCore('SendNotification', {Title='Rivals', Text='TP Behind disabled', Duration=3})
         end
      end,
   })
end

-- Constant teleport behind toggle (follow target continuously)
do
   local followConn = nil
   local isFollowing = false

   local function followTargetBehind()
      pcall(function()
         local target = nil
         if type(SilentAim) == 'table' and SilentAim.TargetPlayer then 
            target = SilentAim.TargetPlayer 
         end
         
         -- Si pas de target du silent aim, chercher le joueur le plus proche
         if not target then
            local closestDist = math.huge
            local closestPlayer = nil
            for _, plr in pairs(Players:GetPlayers()) do
               if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild('HumanoidRootPart') then
                  local myChar = LocalPlayer.Character
                  if myChar and myChar:FindFirstChild('HumanoidRootPart') then
                     local dist = (myChar.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                     if dist < closestDist then
                        closestDist = dist
                        closestPlayer = plr
                     end
                  end
               end
            end
            target = closestPlayer
         end

         if target and target.Character then
            local targetHRP = target.Character:FindFirstChild('HumanoidRootPart')
            local me = LocalPlayer
            local myHRP = me and me.Character and me.Character:FindFirstChild('HumanoidRootPart')
            if targetHRP and myHRP then
               -- Téléporter derrière la cible en gardant la même orientation que la cible
               local behind = targetHRP.CFrame * CFrame.new(0, 0, 6) -- Position derrière (z positif)
               myHRP.CFrame = behind -- Garder l'orientation de la cible
               -- Reset velocity pour éviter les bugs de mouvement
               pcall(function() 
                  myHRP.AssemblyLinearVelocity = Vector3.new(0,0,0)
                  myHRP.AssemblyAngularVelocity = Vector3.new(0,0,0) 
               end)
            end
         end
      end)
   end

   SettingsTab:CreateToggle({
      Name = "Follow Behind Target",
      CurrentValue = false,
      Flag = "followbehind_toggle",
      Callback = function(val)
         isFollowing = val
         if val then
            if followConn then followConn:Disconnect(); followConn = nil end
            followConn = RunService.Heartbeat:Connect(function()
               if isFollowing then
                  followTargetBehind()
               end
            end)
            game:GetService('StarterGui'):SetCore('SendNotification', {Title='Rivals', Text='Follow Behind activated', Duration=3})
         else
            if followConn then followConn:Disconnect(); followConn = nil end
            game:GetService('StarterGui'):SetCore('SendNotification', {Title='Rivals', Text='Follow Behind disabled', Duration=3})
         end
      end,
   })
end

-- Fly System avec contrôle de vitesse
do
   local flyEnabled = false
   local flySpeed = 50
   local flyConnection = nil
   local bodyVelocity = nil
   local bodyGyro = nil

   local function startFly()
      pcall(function()
         local char = LocalPlayer.Character
         if not char then return end
         local hrp = char:FindFirstChild('HumanoidRootPart')
         if not hrp then return end

         -- Créer BodyVelocity et BodyGyro
         if not bodyVelocity then
            bodyVelocity = Instance.new('BodyVelocity')
            bodyVelocity.MaxForce = Vector3.new(1e4, 1e4, 1e4)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = hrp
         end

         if not bodyGyro then
            bodyGyro = Instance.new('BodyGyro')
            bodyGyro.MaxTorque = Vector3.new(1e4, 1e4, 1e4)
            bodyGyro.P = 3000
            bodyGyro.Parent = hrp
         end

         local cam = workspace.CurrentCamera
         local userInput = game:GetService('UserInputService')

         flyConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled or not char or not char.Parent or not hrp or not hrp.Parent then
               if flyConnection then flyConnection:Disconnect() end
               return
            end

            local moveDirection = Vector3.new(0, 0, 0)
            
            -- ZQSD / WASD controls
            if userInput:IsKeyDown(Enum.KeyCode.W) or userInput:IsKeyDown(Enum.KeyCode.Z) then
               moveDirection = moveDirection + (cam.CFrame.LookVector)
            end
            if userInput:IsKeyDown(Enum.KeyCode.S) then
               moveDirection = moveDirection - (cam.CFrame.LookVector)
            end
            if userInput:IsKeyDown(Enum.KeyCode.A) or userInput:IsKeyDown(Enum.KeyCode.Q) then
               moveDirection = moveDirection - (cam.CFrame.RightVector)
            end
            if userInput:IsKeyDown(Enum.KeyCode.D) then
               moveDirection = moveDirection + (cam.CFrame.RightVector)
            end
            
            -- Space pour monter, LeftControl pour descendre
            if userInput:IsKeyDown(Enum.KeyCode.Space) then
               moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if userInput:IsKeyDown(Enum.KeyCode.LeftControl) then
               moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end

            -- Appliquer la vitesse
            if moveDirection.Magnitude > 0 then
               moveDirection = moveDirection.Unit
            end

            bodyVelocity.Velocity = moveDirection * flySpeed
            bodyGyro.CFrame = cam.CFrame
         end)
      end)
   end

   local function stopFly()
      pcall(function()
         if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
         end

         if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
         end

         if bodyGyro then
            bodyGyro:Destroy()
            bodyGyro = nil
         end
      end)
   end

   SettingsTab:CreateToggle({
      Name = "Fly",
      CurrentValue = false,
      Flag = nil, -- Pas de sauvegarde
      Callback = function(val)
         flyEnabled = val
         if val then
            startFly()
            game:GetService('StarterGui'):SetCore('SendNotification', {
               Title='Rivals', 
               Text='Fly activé - ZQSD pour bouger, Space/Ctrl pour monter/descendre', 
               Duration=4
            })
         else
            stopFly()
            game:GetService('StarterGui'):SetCore('SendNotification', {Title='Rivals', Text='Fly désactivé', Duration=3})
         end
      end,
   })

   local Slider = SettingsTab:CreateSlider({
      Name = "Fly Speed",
      Range = {0, 500},
      Increment = 10,
      Suffix = "",
      CurrentValue = 50,
      Flag = nil, -- Pas de sauvegarde
      Callback = function(Value)
         flySpeed = Value
      end,
   })
end

-- ===========================
-- EMOTES TAB (R15 UGC EMOTES)
-- ===========================
local EmotesTab = Window:CreateTab("Emotes", 4483362458)

-- Emotes validés avec IDs fonctionnels (format ID numérique)
local EmoteAnimations = {
   ["Touhou Chirumiru (Spin)"] = 87093097413514,
   ["Backflip Animation"] = 131921180248141, -- Fake Death (Best)
   ["Flat Sitting Pose"] = 114858110513023,
   ["Take The L"] = 125578981255289,
   ["Cute Sit"] = 131836270858895,
   ["E-Girl (Kawaii Doll)"] = 139510904359228, -- kawaii doll sitting pose
   ["Hide"] = 126193377347657,
   ["Flying Bird"] = 126285359578816,
   ["Charleston"] = 72556581432614,
   ["Zero Two Dance"] = 133729878579101,
   ["Griddy"] = 117535973356048,
   ["Orange Justice"] = 95127716920692,
   ["Default Dance"] = 101011728520473,
   ["Kazotsky Kick"] = 119264600441310,
}

-- Variable pour tracker l'animation en cours
local currentEmoteTrack = nil

-- Fonction pour jouer une emote avec le format ID correct
local function playEmote(emoteName, emoteId)
   pcall(function()
      local player = game:GetService("Players").LocalPlayer
      local character = player.Character or player.CharacterAdded:Wait()
      local humanoid = character:FindFirstChildOfClass("Humanoid")
      
      if not humanoid then 
         game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = 'Emotes', 
            Text = 'Humanoid introuvable !', 
            Duration = 3
         })
         return 
      end
      
      -- Arrêter l'animation précédente si elle existe
      if currentEmoteTrack then
         currentEmoteTrack:Stop()
         currentEmoteTrack:Destroy()
         currentEmoteTrack = nil
      end
      
      -- Créer la nouvelle animation avec le format ID correct
      local animator = humanoid:FindFirstChildOfClass("Animator")
      if not animator then
         animator = Instance.new("Animator")
         animator.Parent = humanoid
      end
      
      -- Charger l'animation avec rbxassetid:// + ID
      local animation = Instance.new("Animation")
      animation.AnimationId = "rbxassetid://" .. tostring(emoteId)
      
      currentEmoteTrack = animator:LoadAnimation(animation)
      
      -- Configurer les propriétés de l'animation
      currentEmoteTrack.Priority = Enum.AnimationPriority.Action
      currentEmoteTrack.Looped = true -- La plupart des emotes sont en boucle
      
      -- Jouer l'animation
      currentEmoteTrack:Play()
      
      game:GetService('StarterGui'):SetCore('SendNotification', {
         Title = 'Emotes', 
         Text = emoteName .. ' activé !', 
         Duration = 2
      })
      
      -- Nettoyer l'animation après la fin
      currentEmoteTrack.Stopped:Connect(function()
         if animation then animation:Destroy() end
      end)
   end)
end

-- Fonction pour arrêter l'emote en cours
local function stopEmote()
   pcall(function()
      if currentEmoteTrack then
         currentEmoteTrack:Stop()
         currentEmoteTrack:Destroy()
         currentEmoteTrack = nil
         
         game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = 'Emotes', 
            Text = 'Emote arrêté', 
            Duration = 2
         })
      end
   end)
end

-- Section: Emotes demandés
local Section = EmotesTab:CreateSection("Vos Emotes")

-- Boutons pour les 6 emotes principaux demandés
EmotesTab:CreateButton({
   Name = "🎵 Touhou Chirumiru (Spin)",
   Callback = function()
      playEmote("Touhou Chirumiru", 87093097413514)
   end,
})

EmotesTab:CreateButton({
   Name = "🤸 Backflip Animation",
   Callback = function()
      playEmote("Backflip Animation", 131921180248141)
   end,
})

EmotesTab:CreateButton({
   Name = "💺 Flat Sitting Pose",
   Callback = function()
      playEmote("Flat Sitting Pose", 114858110513023)
   end,
})

EmotesTab:CreateButton({
   Name = "🅱️ Take The L",
   Callback = function()
      playEmote("Take The L", 125578981255289)
   end,
})

EmotesTab:CreateButton({
   Name = "😊 Cute Sit",
   Callback = function()
      playEmote("Cute Sit", 131836270858895)
   end,
})

EmotesTab:CreateButton({
   Name = "👧 E-Girl (Kawaii Doll)",
   Callback = function()
      playEmote("E-Girl", 139510904359228)
   end,
})

-- Section: Emotes populaires
local Section2 = EmotesTab:CreateSection("Emotes Populaires")

EmotesTab:CreateButton({
   Name = "💃 Griddy",
   Callback = function()
      playEmote("Griddy", 117535973356048)
   end,
})

EmotesTab:CreateButton({
   Name = "🍊 Orange Justice",
   Callback = function()
      playEmote("Orange Justice", 95127716920692)
   end,
})

EmotesTab:CreateButton({
   Name = "🕺 Default Dance",
   Callback = function()
      playEmote("Default Dance", 101011728520473)
   end,
})

EmotesTab:CreateButton({
   Name = "⚡ Zero Two Dance",
   Callback = function()
      playEmote("Zero Two Dance", 133729878579101)
   end,
})

EmotesTab:CreateButton({
   Name = "🎩 Charleston",
   Callback = function()
      playEmote("Charleston", 72556581432614)
   end,
})

EmotesTab:CreateButton({
   Name = "🤝 Kazotsky Kick",
   Callback = function()
      playEmote("Kazotsky Kick", 119264600441310)
   end,
})

-- Section: Contrôles
local Section3 = EmotesTab:CreateSection("Contrôles")

EmotesTab:CreateButton({
   Name = "⏹️ Stop Emote",
   Callback = function()
      stopEmote()
   end,
})

-- Section: Informations
local Section4 = EmotesTab:CreateSection("Info")

EmotesTab:CreateButton({
   Name = "ℹ️ Instructions",
   Callback = function()
      game:GetService('StarterGui'):SetCore('SendNotification', {
         Title = 'Emotes Info', 
         Text = 'IDs validés depuis le script R15 UGC. Clique pour jouer, Stop pour arrêter.', 
         Duration = 5
      })
   end,
})

-- Charger la configuration sauvegardée
Rayfield:LoadConfiguration()

-- ===========================
-- AUTOLOAD SYSTEM (FONCTIONNEL)
-- ===========================
-- Relance automatiquement le script lors du changement de serveur

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- URL du script à recharger
local SCRIPT_URL = "https://raw.githubusercontent.com/CacaBoudinaaa/Rayfield/refs/heads/main/source.lua"

-- Détection du changement de serveur
if queue_on_teleport then
   -- Code injecté qui sera exécuté dans le nouveau serveur
   local autoloadCode = string.format([[
      -- Autoload Essence après téléportation
      task.wait(4) -- Attendre que le nouveau serveur soit complètement chargé
      
      pcall(function()
         local success, result = pcall(function()
            return game:HttpGet('%s')
         end)
         
         if success and result then
            local loadSuccess, loadError = pcall(function()
               loadstring(result)()
            end)
            
            if loadSuccess then
               task.wait(0.5)
               game:GetService('StarterGui'):SetCore('SendNotification', {
                  Title = 'Essence Autoload', 
                  Text = '✓ Script rechargé avec succès !', 
                  Duration = 4
               })
            else
               warn("[Essence Autoload] Erreur de chargement:", loadError)
            end
         else
            warn("[Essence Autoload] Erreur HTTP:", result)
         end
      end)
   ]], SCRIPT_URL)
   
   -- Enregistrer le code d'autoload
   queue_on_teleport(autoloadCode)
   
   -- Réenregistrer l'autoload à chaque téléportation
   LocalPlayer.OnTeleport:Connect(function(State)
      if State == Enum.TeleportState.Started then
         -- Notifier l'utilisateur
         pcall(function()
            game:GetService('StarterGui'):SetCore('SendNotification', {
               Title = 'Essence Autoload', 
               Text = '🔄 Changement de serveur détecté...', 
               Duration = 3
            })
         end)
         
         -- Réinjecter le code d'autoload pour le prochain serveur
         queue_on_teleport(autoloadCode)
      end
   end)
   
   -- Notification de confirmation
   game:GetService('StarterGui'):SetCore('SendNotification', {
      Title = 'Essence Autoload', 
      Text = '✓ Autoload activé (changement de serveur)', 
      Duration = 3
   })
else
   -- L'exécuteur ne supporte pas queue_on_teleport
   warn("[Essence] Votre exécuteur ne supporte pas queue_on_teleport - Autoload désactivé")
   game:GetService('StarterGui'):SetCore('SendNotification', {
      Title = 'Essence Autoload', 
      Text = '⚠️ Autoload non disponible sur cet exécuteur', 
      Duration = 4
   })
end
