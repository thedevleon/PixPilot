--[[

PixPilot Main Telemetry Screen

]]--

local function init()
    return
end

local function background()
    return
end

local function run(key_event)
    background()

    if pix_adapter_running == nil or pix_adapter_running == false then
        lcd.clear()
        lcd.drawText (0, 10, "PixPilot has not been set up correctly!", 0)
        lcd.drawText (0, 20, "Please refer to the documentation to", 0)
        lcd.drawText (0, 30, "install the correct mixer script")
        lcd.drawText (0, 40, "for your specific platform.", 0)
        return
    end
end

return { run=run, background=background, init=init}
