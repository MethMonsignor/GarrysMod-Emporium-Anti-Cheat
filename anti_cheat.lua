-- Anti-Cheat: Finalized Detection Suite (Pure Logic)
local watchdog = {}
watchdog.fingerprints = {}
watchdog.bytecode = {}
watchdog.suspiciousPlayers = {}

-- Safe metatable locking with fallback logging
local function lockMetatable(tbl, name)
    if type(tbl) ~= "table" then
        print("[Anti-Cheat] Failed to lock metatable: " .. tostring(name) .. " is not a table.")
        return
    end

    local mt = getmetatable(tbl)

    if type(mt) == "string" and mt == "locked" then
        print("[Anti-Cheat] Metatable for " .. name .. " is already protected.")
        return
    end

    if type(mt) ~= "table" then
        mt = {}
    end

    mt.__metatable = "locked"

    local success, err = pcall(function()
        setmetatable(tbl, mt)
    end)

    if not success then
        print("[Anti-Cheat] Could not lock metatable for " .. name .. ": " .. tostring(err))
    else
        print("[Anti-Cheat] Metatable locked for " .. name)
    end
end

-- Apply to core tables
lockMetatable(net, "net")
lockMetatable(hook, "hook")
lockMetatable(_G, "_G")

-- Fingerprint critical functions (C-safe)
local function hashFunction(fn)
    if type(fn) ~= "function" then return "invalid" end
    local dumped
    local success, result = pcall(function()
        return string.dump(fn, true)
    end)
    dumped = success and result or tostring(fn)
    return util.CRC(dumped)
end

local function storeBytecode(name, fn)
    local success, result = pcall(function()
        return string.dump(fn, true)
    end)
    watchdog.bytecode[name] = success and result or nil
end

local function compareBytecode(name, fn)
    local stored = watchdog.bytecode[name]
    if not stored then return true end
    local success, result = pcall(function()
        return string.dump(fn, true)
    end)
    return success and result == stored
end

local function verifyIntegrity()
    local changed = {}
    for name, originalHash in pairs(watchdog.fingerprints) do
        local fn = _G
        for part in string.gmatch(name, "[^.]+") do
            fn = fn and fn[part]
        end
        if type(fn) == "function" then
            if hashFunction(fn) ~= originalHash or not compareBytecode(name, fn) then
                table.insert(changed, name)
            end
        end
    end
    return changed
end

-- Flag player
local function flagPlayer(ply, reason)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    watchdog.suspiciousPlayers[ply:SteamID()] = {
        name = ply:Nick(),
        reason = reason,
        time = os.date("%H:%M:%S")
    }
    print("[Anti-Cheat] Breach by " .. ply:Nick() .. ": " .. reason)
end

-- Initialize fingerprints
local function initWatchdog()
    local targets = {
        "net.Receive", "hook.Add", "RunConsoleCommand",
        "RunString", "CompileString", "concommand.Add",
        "ents.Create", "file.Read", "file.Write", "http.Fetch"
    }
    for _, name in ipairs(targets) do
        local fn = _G
        for part in string.gmatch(name, "[^.]+") do
            fn = fn and fn[part]
        end
        if type(fn) == "function" then
            watchdog.fingerprints[name] = hashFunction(fn)
            storeBytecode(name, fn)
        end
    end
    print("[EmporiumRP Anti-Cheat] Loaded. Monitoring all vectors.")
end

-- Hook hijacking
local baselineHooks = {
    ["PlayerSay"] = true, ["Think"] = true, ["Tick"] = true,
    ["PlayerInitialSpawn"] = true, ["PlayerBindPress"] = true
}

hook.Add("EmporiumRP_HookAudit", "EmporiumRP_HookAudit", function()
    if type(hook) ~= "table" or not hook.GetTable then
        print("[Anti-Cheat] Hook system unavailable—skipping hook audit.")
        return
    end

    for hookName, _ in pairs(hook.GetTable()) do
        if not baselineHooks[hookName] then
            print("[Anti-Cheat] Unexpected hook: " .. hookName)
        end
    end
end)

-- Net message audit
net.Receive("EmporiumRP_ErrorReport", function(len, ply)
    if len > 1024 then
        flagPlayer(ply, "Oversized net payload")
    end
end)

-- Console command abuse
hook.Add("PlayerSay", "EmporiumRP_CommandAudit", function(ply, text)
    if string.find(string.lower(text), "lua_run") or string.find(string.lower(text), "retry") or string.find(string.lower(text), "disconnect") or string.find(string.lower(text), "kick") or string.find(string.lower(text), "ban") then
        flagPlayer(ply, "Suspicious command: " .. text)
    end
end)

-- Command flooding
local commandCooldown = {}
hook.Add("PlayerSay", "EmporiumRP_CommandFloodCheck", function(ply, text)
    local sid = ply:SteamID()
    if commandCooldown[sid] and CurTime() - commandCooldown[sid] < 1 then
        flagPlayer(ply, "Command flooding")
    end
    commandCooldown[sid] = CurTime()
end)

-- Movement manipulation
hook.Add("Think", "EmporiumRP_MovementAudit", function()
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetWalkSpeed() > 250 or ply:GetRunSpeed() > 500 or ply:GetJumpPower() > 200 then
            flagPlayer(ply, "Movement manipulation")
        end
    end
end)

-- ESP / trace spam
hook.Add("Tick", "EmporiumRP_TraceAudit", function()
    for _, ply in ipairs(player.GetAll()) do
        if ply.LastTraceCheck and CurTime() - ply.LastTraceCheck < 0.1 then
            flagPlayer(ply, "Trace spam (ESP)")
        end
        ply.LastTraceCheck = CurTime()
    end
end)

-- Silent aim detection
hook.Add("StartCommand", "EmporiumRP_AimAudit", function(ply, cmd)
    if not IsValid(ply) then return end
    local delta = (cmd:GetViewAngles() - ply:EyeAngles()):Length()
    if delta > 45 then
        flagPlayer(ply, "Suspicious aim delta")
    end
end)

-- Entity spawn abuse
hook.Add("OnEntityCreated", "EmporiumRP_EntitySpawnAudit", function(ent)
    if not IsValid(ent) then return end
    if ent:GetClass() == "prop_physics" then
        local owner = ent.CPPIGetOwner and ent:CPPIGetOwner()
        if IsValid(owner) and not ent.SpawnedByAntiCheat then
            flagPlayer(owner, "Suspicious entity spawn: " .. ent:GetClass())
            ent.SpawnedByAntiCheat = true
        end
    end
end)

-- Toolgun abuse
hook.Add("CanTool", "EmporiumRP_ToolgunAudit", function(ply, tr, tool)
    if tool == "duplicator" or tool == "advdupe2" then
        flagPlayer(ply, "Toolgun abuse: " .. tool)
    end
end)

-- File system tampering
hook.Add("Think", "EmporiumRP_FileAudit", function()
    for _, name in ipairs({"file.Read", "file.Write", "http.Fetch"}) do
        local fn = _G
        for part in string.gmatch(name, "[^.]+") do
            fn = fn and fn[part]
        end
        if type(fn) == "function" and hashFunction(fn) ~= watchdog.fingerprints[name] then
            print("[Anti-Cheat] File system tampering: " .. name)
        end
    end
end)

-- Global table pollution
hook.Add("Think", "EmporiumRP_GlobalAudit", function()
    for k, v in pairs(_G) do
        if type(v) == "function" and not watchdog.fingerprints[k] and k ~= "_G" then
            print("[Anti-Cheat] Unexpected global function: " .. k)
        end
    end
end)

-- Obfuscated cheat signatures
hook.Add("Think", "EmporiumRP_ObfuscationAudit", function()
    for k, v in pairs(_G) do
        if type(v) == "function" then
            local info = debug.getinfo(v, "uS")
            if info and info.nups and info.nups > 5 then
                print("[Anti-Cheat] Obfuscated function: " .. k)
            end
        end
    end
end)

-- Activate watchdog
initWatchdog()



