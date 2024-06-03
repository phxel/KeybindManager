KeybindManager = KeybindManager or {}
KeybindManager.Keybinds = KeybindManager.Keybinds or {}
KeybindManager.KeyStates = KeybindManager.KeyStates or {}
KeybindManager.Profiles = KeybindManager.Profiles or {}
KeybindManager.CurrentProfile = KeybindManager.CurrentProfile or "default"

if SERVER then
    util.AddNetworkString("KeybindManager_ExecuteCommand")

    net.Receive("KeybindManager_ExecuteCommand", function(len, ply)
        local command = net.ReadString()
        if IsValid(ply) and ply:IsPlayer() then
            ply:ConCommand(command)  -- Execute the command for the player
        end
    end)
end

if CLIENT then
    -- Register a new keybind
    function KeybindManager:RegisterKeybind(name, defaultKey, description, command, isDefaultAction)
        self.Keybinds[name] = {
            key = defaultKey,
            description = description,
            command = command,
            isDefaultAction = isDefaultAction or false
        }
        self:SaveKeybinds()
    end

    -- Handle key press events
    hook.Add("Think", "KeybindManager_Think", function()
        for name, bind in pairs(KeybindManager.Keybinds) do
            local key = bind.key
            local isPressed = input.IsKeyDown(key)

            if isPressed and not KeybindManager.KeyStates[key] then
                -- Key was just pressed
                if bind.command then
                    if bind.isDefaultAction then
                        -- Execute default action (e.g., shooting, jumping)
                        RunConsoleCommand(bind.command)
                    else
                        net.Start("KeybindManager_ExecuteCommand")
                        net.WriteString(bind.command)
                        net.SendToServer()
                    end
                end
            elseif not isPressed and KeybindManager.KeyStates[key] then
                -- Key was just released
                if bind.isDefaultAction then
                    -- Stop the default action
                    RunConsoleCommand("-" .. bind.command:sub(2))
                end
            end

            -- Update the key state
            KeybindManager.KeyStates[key] = isPressed
        end
    end)

    -- Save keybinds to a JSON file
    function KeybindManager:SaveKeybinds()
        if not file.IsDir("keybindmanager", "DATA") then
            file.CreateDir("keybindmanager")
        end
        self.Profiles[self.CurrentProfile] = self.Keybinds
        local data = util.TableToJSON(self.Profiles)
        file.Write("keybindmanager/keybinds.json", data)
    end

    -- Load keybinds from a JSON file
    function KeybindManager:LoadKeybinds()
        if file.Exists("keybindmanager/keybinds.json", "DATA") then
            local data = file.Read("keybindmanager/keybinds.json", "DATA")
            self.Profiles = util.JSONToTable(data) or {}
            self.Keybinds = self.Profiles[self.CurrentProfile] or {}
        end
    end

    -- Save the current profile
    function KeybindManager:SaveProfile(name)
        self.Profiles[name] = self.Keybinds
        self:SaveKeybinds()
    end

    -- Load a specific profile
    function KeybindManager:LoadProfile(name)
        self.Keybinds = self.Profiles[name] or {}
        self.CurrentProfile = name
        self:SaveKeybinds()
    end

    -- Override default behavior
    hook.Add("PlayerBindPress", "KeybindManager_PlayerBindPress", function(ply, bind, pressed)
        for name, keybind in pairs(KeybindManager.Keybinds) do
            if keybind.isDefaultAction and bind:lower():find(keybind.command) then
                return true -- Block the default action
            end
        end

        -- If the bind is not found in the keybinds, allow the default action
        return nil
    end)
    
    -- This should be at the bottom
    include("keybind_manager/spawnmenu.lua")
end
