--[[

PixPilot Mavlink Messages Screen

]]--

local function init()
    return
end

local function background()
    return
end

local function run(key_event)
    background()

    lcd.clear()

    if pix_adapter_running == nil or pix_adapter_running == false then
        lcd.drawText (0, 10, "PixPilot has not been set up correctly!", 0)
        lcd.drawText (0, 20, "Please refer to the documentation to", 0)
        lcd.drawText (0, 30, "install the correct mixer script")
        lcd.drawText (0, 40, "for your specific platform.", 0)
        return
    end


    local mavlink_messages = pix_get_mavlink_messages()
    local n = 0

    for k,v in pairs(mavlink_messages) do
        lcd.drawText (1, 1+8*n , v, 0)
        n=n+1
    end
end

return { run=run, background=background, init=init}
