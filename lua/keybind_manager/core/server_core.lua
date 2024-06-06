KeybindManager = KeybindManager or {}
KeybindManager.Profiles = KeybindManager.Profiles or {}
KeybindManager.CurrentProfile = KeybindManager.CurrentProfile or "default"
KeybindManager.KeyStates = KeybindManager.KeyStates or {}

util.AddNetworkString("KeybindManager_ExecuteCommand")

net.Receive("KeybindManager_ExecuteCommand", function(len, ply)
    local command = net.ReadString()
    if IsValid(ply) and ply:IsPlayer() then
        ply:ConCommand(command)
    else
        print("[KeybindManager] Invalid player or command received.")
    end
end)
