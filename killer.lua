local args = { ... }
local Event = dofile(args[1] .. "/event.lua")

local registerd_keys = {}
local mousekeys = {
    lbutton = 1,
    mbutton = 2,
    rbutton = 3,
    mouse4 = 4,
    mouse5 = 5
}
local modifiers = {
    "lalt", "ralt", "alt",
    "lshift", "rshift", "shift",
    "lctrl", "rctrl", "ctrl"
}

local defaults = {
    hit_time = 300
}

local mkey = { state = 1, prev = 0 }
function setMKeyState(state)
    mkey.state = state
end

function register(key, info)
    if not info then info = {} end
    for _, action in pairs({ "pressed", "down", "released" }) do
        info[action] = Event.new()
    end

    if info.vars == nil then
        info.vars = {}
    end

    info.vars.last_hit = 0
    info.vars.hits = 0

    info.key = string.lower(key)
    registerd_keys[info.key] = info

    return info
end

function unregister(key)
    registerd_keys[string.lower(key)] = nil
end

function handle_key(key, event)
    info = registerd_keys[key]
    if info == nil then return end

    if event == "pressed" then
        local hit_time = info.vars.hit_time or defaults.hit_time
        if (GetRunningTime() - info.vars.last_hit) < hit_time then
            info.vars.hits = info.vars.hits + 1
        else
            info.vars.hits = 1
        end
        info.vars.start_time = GetRunningTime()
        info.vars.last_hit = GetRunningTime()
    elseif event == "down" then
        info.vars.time = GetRunningTime() - info.vars.start_time
    elseif event == "released" then
        info.vars.time = GetRunningTime() - info.vars.start_time
        info.vars.start_time = nil
    end

    action = info[event]
    if action == nil then return end
    action(info.vars)
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function get_info(event, arg)
    result = split(string.lower(event), "_")
    key, event =  result[1], result[2]
    if arg then
        key = key .. arg
    end
    return key, event
end

function handle_other(key, name, checkFunc)
    down = checkFunc(name)
    info = registerd_keys[key]

    if info then
        if down and info.vars.start_time == nil then
            handle_key(key, "pressed")
        elseif down == false and info.vars.start_time then
            handle_key(key, "released")
        end
    end
end

local polling
function poll()
    -- Check for keys currently pressed down
    for key, info in pairs(registerd_keys) do
        if info.vars.start_time ~= nil then
            handle_key(key, "down")
        end
    end

    -- Check modifiers
    for _, modifier in pairs(modifiers) do
        handle_other(modifier, modifier, IsModifierPressed)
    end

    -- Check mousekeys
    for mousekey, i in pairs(mousekeys) do
        handle_other(mousekey, i, IsMouseButtonPressed)
    end

    Sleep(5)
    SetMKeyState(mkey.state)
end

function OnEvent(event, arg)
    key, action = get_info(event, arg)
    handle_key(key, action)

    if event == "PROFILE_ACTIVATED" then
        ClearLog()
        polling = true
        SetMKeyState(mkey.state)
    elseif event == "PROFILE_DEACTIVATED" then
        polling = false
    end
end

templates = {}
templates.templates = {}

function templates.add(name, action)
    templates.templates[name] = function(key, ...)
        local info = registerd_keys[string.lower(key)]
        if info == nil then
            info = register(key)
        end
        action(info, ...)
    end
end

function templates.get(name)
    return templates.templates[name]
end

-- Setup mkeys for polling
for i = 1, 3 do
    register("m" .. i).pressed:add(function()
        if polling then poll() end
    end)
end
