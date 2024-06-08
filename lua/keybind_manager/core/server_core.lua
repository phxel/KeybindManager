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
            local args = {} -- new table for arguments
            for arg in command:gmatch("%S+") do -- remove whitespace from command
                table.insert(args, arg) -- insert into args table
            end
            local cmd = table.remove(args, 1) --extract the first element from the table, which would be the toggle in this case

            if cmd then
                if cmd == "toggle" and #args == 3 then -- check if cmd is toggle and 3 arguments are present in args
                    local convar_name = args[1] -- assign the 1st member of table to convar_name, here it would be toggle
                    local value1 = tonumber(args[2]) -- assign 2nd member of table to value1
                    local value2 = tonumber(args[3]) -- assign 3rd member of table to value2
                    if convar_name and value1 and value2 then -- check if all of these have a value
                        local var = GetConVar(convar_name) -- look for convar, again toggle here
                        if var then -- check if var exists by checking if a value is assigned
                            local currentValue = var:GetInt() -- get the assigned value
                            local newValue = (currentValue == value1) and value2 or value1
                            RunConsoleCommand(convar_name, tostring(newValue)) -- ??? ok
                        else
                            error("[KeybindManager] Unknown ConVar for toggle: " .. convar_name)
                        end
                    else
                        error("[KeybindManager] Invalid arguments for toggle")
                    end
                else -- if the command doesn't have toggle as its first member
                    local success, err = pcall(function()
                        RunConsoleCommand(cmd, unpack(args)) -- run command
                    end)

                    if not success then
                        print("[KeybindManager] Failed to run command with RunConsoleCommand: " .. err) -- print this into console, not an actual "error" per se
                        ply:ConCommand(command) -- if somehow success is not true, do this instead
                    end
                end
            else
                --error("[KeybindManager] Command is invalid or empty.")
            end
        else
            ply:ConCommand(command) -- if not admin, run with ConCommand
        end
    else
        print("[KeybindManager] Invalid player or command received.")
    end
end)

