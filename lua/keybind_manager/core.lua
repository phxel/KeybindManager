KeybindManager = KeybindManager or {}
KeybindManager.Profiles = KeybindManager.Profiles or {}
KeybindManager.CurrentProfile = KeybindManager.CurrentProfile or "default"
KeybindManager.KeyStates = KeybindManager.KeyStates or {}

if SERVER then
    util.AddNetworkString("KeybindManager_ExecuteCommand")

    net.Receive("KeybindManager_ExecuteCommand", function(len, ply)
        local command = net.ReadString()
        if IsValid(ply) and ply:IsPlayer() then
            ply:ConCommand(command)
        else
            print("[KeybindManager] Invalid player or command received.")
        end
    end)
end

if CLIENT then
    local function isValidKeybind(name, defaultKey, description, command)
        return name and defaultKey and description and command
    end

    function KeybindManager:RegisterKeybind(name, defaultKey, description, command, isDefaultAction, releaseCommand)
        if not isValidKeybind(name, defaultKey, description, command) then
            error("[KeybindManager] Invalid arguments passed to KeybindManager:RegisterKeybind")
            return
        end

        self.Profiles[self.CurrentProfile] = self.Profiles[self.CurrentProfile] or {}
        self.Profiles[self.CurrentProfile][name] = {
            key = defaultKey,
            description = description,
            command = command,
            isDefaultAction = isDefaultAction or false,
            releaseCommand = releaseCommand or nil
        }
        self:SaveKeybinds()
    end

    hook.Add("Think", "KeybindManager_Think", function()
        for name, bind in pairs(KeybindManager.Profiles[KeybindManager.CurrentProfile] or {}) do
            local key = bind.key
            local isPressed = input.IsKeyDown(key)

            if isPressed and not KeybindManager.KeyStates[key] then
                -- Key pressed
                if bind.command then
                    if bind.isDefaultAction then
                        RunConsoleCommand(bind.command)
                    else
                        net.Start("KeybindManager_ExecuteCommand")
                        net.WriteString(bind.command)
                        net.SendToServer()
                    end
                end
            elseif not isPressed and KeybindManager.KeyStates[key] then
                -- Key released
                if bind.releaseCommand then
                    if bind.isDefaultAction then
                        RunConsoleCommand(bind.releaseCommand)
                    else
                        net.Start("KeybindManager_ExecuteCommand")
                        net.WriteString(bind.releaseCommand)
                        net.SendToServer()
                    end
                end
            end

            KeybindManager.KeyStates[key] = isPressed
        end
    end)

    function KeybindManager:SaveKeybinds()
        -- Create the directory if it doesn't exist
        if not file.Exists("keybindmanager", "DATA") then
            file.CreateDir("keybindmanager")
        end

        local fileName = self.CurrentProfile .. ".json"
        local data = util.TableToJSON(self.Profiles[self.CurrentProfile] or {})
        
        -- Perform the file write operation
        local success, err = pcall(function()
            file.Write("keybindmanager/" .. fileName, data)
        end)
        if not success then
            error("[KeybindManager] Failed to save keybinds: " .. err)
        end
    end

    local function loadKeybindFile(fileName)
        local data = file.Read("keybindmanager/" .. fileName, "DATA")
        if not data then
            error("[KeybindManager] Failed to read keybind file: " .. fileName)
        end
        return util.JSONToTable(data) or {}
    end

    function KeybindManager:LoadKeybinds()
        local files = file.Find("keybindmanager/*.json", "DATA")
        
        -- Cache the loaded profiles
        local loadedProfiles = {}
        
        for _, fileName in ipairs(files) do
            if fileName ~= "lastprofile.json" then
                local profileName = fileName:sub(1, -6) -- Remove the .json extension
                local success, profile = pcall(loadKeybindFile, fileName)
                if success then
                    loadedProfiles[profileName] = profile
                else
                    print("[KeybindManager] Error loading profile " .. profileName .. ": " .. profile)
                end
            end
        end
        
        -- Assign the loaded profiles to the Profiles table
        self.Profiles = loadedProfiles
    end

    function KeybindManager:SaveProfile(name)
        self.CurrentProfile = name
        if not self.Profiles[self.CurrentProfile] then
            self.Profiles[self.CurrentProfile] = {}
        end
        self:SaveKeybinds()
    end

    function KeybindManager:LoadProfile(name)
        self.CurrentProfile = name
        if not self.Profiles[self.CurrentProfile] then
            self.Profiles[self.CurrentProfile] = {}
        end
        self:LoadKeybinds()
        hook.Run("KeybindManagerProfileChanged")
    end

    function KeybindManager:SaveLastProfile()
        -- Create the directory if it doesn't exist
        if not file.Exists("keybindmanager", "DATA") then
            file.CreateDir("keybindmanager")
        end

        local data = util.TableToJSON({lastProfile = self.CurrentProfile})
        
        -- Perform the file write operation
        local success, err = pcall(function()
            file.Write("keybindmanager/lastprofile.json", data)
        end)
        if not success then
            error("[KeybindManager] Failed to save last profile: " .. err)
        end
    end

    function KeybindManager:LoadLastProfile()
        if file.Exists("keybindmanager/lastprofile.json", "DATA") then
            local data = file.Read("keybindmanager/lastprofile.json", "DATA")
            if not data then
                error("[KeybindManager] Failed to read last profile file")
            end

            local decoded = util.JSONToTable(data)
            self.CurrentProfile = decoded and decoded.lastProfile or "default"
        else
            self.CurrentProfile = "default"
        end
    end
end
