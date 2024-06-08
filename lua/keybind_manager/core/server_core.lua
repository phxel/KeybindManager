KeybindManager = KeybindManager or {}
KeybindManager.Profiles = KeybindManager.Profiles or {}
KeybindManager.CurrentProfile = KeybindManager.CurrentProfile or "default"
KeybindManager.KeyStates = KeybindManager.KeyStates or {}

util.AddNetworkString("KeybindManager_ExecuteCommand")

-- listen for KeybindManager_ExecuteCommand message, and execute received command
net.Receive("KeybindManager_ExecuteCommand", function(len, ply)
    local command = net.ReadString()
    if IsValid(ply) and ply:IsPlayer() then
        if ply:IsAdmin() then
            -- Extract command and arguments
            local args = {}
            for arg in command:gmatch("%S+") do
                table.insert(args, arg)
            end
            local cmd = table.remove(args, 1)

            if cmd then
                if cmd == "toggle" and #args == 3 then
                    local convar_name = args[1]
                    local value1 = tonumber(args[2])
                    local value2 = tonumber(args[3])
                    if convar_name and value1 and value2 then
                        local var = GetConVar(convar_name)
                        if var then
                            local currentValue = var:GetInt()
                            local newValue = (currentValue == value1) and value2 or value1
                            RunConsoleCommand(convar_name, tostring(newValue))
                        else
                            print("[KeybindManager] Unknown ConVar for toggle: " .. convar_name)
                        end
                    else
                        print("[KeybindManager] Invalid arguments for toggle")
                    end
                else
                    -- Handle other commands using RunConsoleCommand
                    local success, err = pcall(function()
                        RunConsoleCommand(cmd, unpack(args))
                    end)

                    if not success then
                        print("[KeybindManager] Failed to run command with RunConsoleCommand: " .. err)
                        ply:ConCommand(command)
                    end
                end
            else
                print("[KeybindManager] Command is invalid or empty.")
            end
        else
            ply:ConCommand(command)
        end
    else
        print("[KeybindManager] Invalid player or command received.")
    end
end)

