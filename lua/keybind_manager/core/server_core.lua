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

            -- Run the command with arguments
            if cmd then
                RunConsoleCommand(cmd, unpack(args))
            end
        else
            ply:ConCommand(command)
        end
    else
        print("[KeybindManager] Invalid player or command received.")
    end
end)


