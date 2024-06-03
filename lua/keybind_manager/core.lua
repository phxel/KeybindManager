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
        end
    end)
end

if CLIENT then
    function KeybindManager:RegisterKeybind(name, defaultKey, description, command, isDefaultAction)
        self.Profiles[self.CurrentProfile] = self.Profiles[self.CurrentProfile] or {}
        self.Profiles[self.CurrentProfile][name] = {
            key = defaultKey,
            description = description,
            command = command,
            isDefaultAction = isDefaultAction or false
        }
        self:SaveKeybinds()
    end

    hook.Add("Think", "KeybindManager_Think", function()
        for name, bind in pairs(KeybindManager.Profiles[KeybindManager.CurrentProfile]) do
            local key = bind.key
            local isPressed = input.IsKeyDown(key)

            if isPressed and not KeybindManager.KeyStates[key] then
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
                if bind.isDefaultAction then
                    RunConsoleCommand("-" .. bind.command:sub(2))
                end
            end

            KeybindManager.KeyStates[key] = isPressed
        end
    end)

    function KeybindManager:SaveKeybinds()
        if not file.IsDir("keybindmanager", "DATA") then
            file.CreateDir("keybindmanager")
        end
        local fileName = self.CurrentProfile .. ".json"
        local data = util.TableToJSON(self.Profiles[self.CurrentProfile] or {})
        file.Write("keybindmanager/" .. fileName, data)
    end

    function KeybindManager:LoadKeybinds()
        local files = file.Find("keybindmanager/*.json", "DATA")
        for _, fileName in ipairs(files) do
            if fileName ~= "lastprofile.json" then
                local profileName = fileName:sub(1, -6) -- Remove the .json extension
                local data = file.Read("keybindmanager/" .. fileName, "DATA")
                self.Profiles[profileName] = util.JSONToTable(data) or {}
            end
        end
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
        if not file.IsDir("keybindmanager", "DATA") then
            file.CreateDir("keybindmanager")
        end
        local data = util.TableToJSON({lastProfile = self.CurrentProfile})
        file.Write("keybindmanager/lastprofile.json", data)
    end

    function KeybindManager:LoadLastProfile()
        if file.Exists("keybindmanager/lastprofile.json", "DATA") then
            local data = file.Read("keybindmanager/lastprofile.json", "DATA")
            local decoded = util.JSONToTable(data)
            if decoded and decoded.lastProfile then
                self.CurrentProfile = decoded.lastProfile
            else
                self.CurrentProfile = "default"
            end
        else
            self.CurrentProfile = "default"
        end
    end

    hook.Add("PlayerBindPress", "KeybindManager_PlayerBindPress", function(ply, bind, pressed)
        for name, keybind in pairs(KeybindManager.Profiles[KeybindManager.CurrentProfile]) do
            if keybind.isDefaultAction and bind:lower():find(keybind.command) then
                return true
            end
        end
        return nil
    end)
end