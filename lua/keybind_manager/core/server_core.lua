KeybindManager = KeybindManager or {}
KeybindManager.Profiles = KeybindManager.Profiles or {}
KeybindManager.CurrentProfile = KeybindManager.CurrentProfile or "default"
KeybindManager.KeyStates = KeybindManager.KeyStates or {}

util.AddNetworkString("KeybindManager_ExecuteCommand")

--[[
    this script listens for the KeybindManager_ExecuteCommand network message and executes the received command
    
    - if the player is valid and is an admin:
        - it parses the command and its arguments, disects those and puts the arguments in a table
        - if the command is "toggle" and there are exactly three arguments:
            - the script runs toggle (wow)
        - otherwise, it tries to run the command using RunConsoleCommand
        - if RunConsoleCommand fails, it attempts to run the command using ply:ConCommand
    - if the player is not an admin, it directly runs the command using ply:ConCommand
    - if the player is invalid or the command is invalid, it prints an error message
--]]

net.Receive("KeybindManager_ExecuteCommand", function(len, ply)
    local command = net.ReadString()
    if IsValid(ply) and ply:IsPlayer() then
        if ply:IsAdmin() then
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
                            error("[KeybindManager] Unknown ConVar for toggle: " .. convar_name)
                        end
                    else
                        error("[KeybindManager] Invalid arguments for toggle")
                    end
                else 
                    local success, err = pcall(function()
                        RunConsoleCommand(cmd, unpack(args)) 
                    end)

                    if not success then
                        print("[KeybindManager] Failed to run command with RunConsoleCommand: " .. err) -- print this into console, not an actual "error" per se
                        ply:ConCommand(command) 
                    end
                end
            else
                --error("[KeybindManager] Command is invalid or empty.") -- dont remove this im too lazy to get rid of it :3
            end
        else
            ply:ConCommand(command)
        end
    else
        print("[KeybindManager] Invalid player or command received.")
    end
end)
