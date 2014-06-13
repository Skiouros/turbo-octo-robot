templates.add("taps", function(info, args, action)
    info.pressed:add(function(vars)
        if info.vars.hits == args.taps then
            action(vars)
        end
    end)
end)

templates.add("short_long", function(info, args)
    info.down:add(function(vars)
        if vars.time > args.delay then
            PressKey(args.long_key)
        end
    end)

    info.released:add(function(vars)
        if vars.time <= args.delay then
            if args.sleep then
                PressKey(args.short_key)
                Sleep(args.delay)
                ReleaseKey(args.short_key)
            else
                PressAndReleaseKey(args.short_key)
            end
        else
            ReleaseKey(args.long_key)
        end
    end)
end)

templates.add("tap_hold", function(info, args)
    if args.hit_time then
        info.vars.hit_time = args.hit_time
    end

    info.pressed:add(function()
        PressKey(args.key)
    end)

    info.down:add(function()
        PressKey(args.key)
    end)

    info.released:add(function(vars)
        if vars.tap_hold then
            vars.tap_hold = false
            PressKey(args.key)
        else
            ReleaseKey(args.key)
        end
    end)

    templates.get("taps")(info.key, { taps = args.taps }, function(vars)
        PressKey(args.key)
        vars.tap_hold = true
    end)
end)

-- TODO: Support for mousekey and modifiers
templates.add("map", function(info, args)
    info.pressed:add(function()
        PressKey(args.key)
    end)

    info.down:add(function()
        PressKey(args.key)
    end)

    info.released:add(function()
        ReleaseKey(args.key)
    end)
end)
