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
        local fileName = self.CurrentProfile .. ".json"
        if file.Exists("keybindmanager/" .. fileName, "DATA") then
            local data = file.Read("keybindmanager/" .. fileName, "DATA")
            self.Profiles[self.CurrentProfile] = util.JSONToTable(data) or {}
        else
            self.Profiles[self.CurrentProfile] = {}
        end
    end

    function KeybindManager:SaveProfile(name)
        self.CurrentProfile = name
        self:SaveKeybinds()
    end

    function KeybindManager:LoadProfile(name)
        self.CurrentProfile = name
        self:LoadKeybinds()
        hook.Run("KeybindManagerProfileChanged")
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