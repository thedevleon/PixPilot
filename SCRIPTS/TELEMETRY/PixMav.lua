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
        lcd.drawText (0, 1,  "PixPilot has not been set up correctly!", SMLSIZE)
        lcd.drawText (0, 9,  "Please refer to the documentation at", SMLSIZE)
        lcd.drawText (0, 17, "https://goo.gl/4ylfQh", SMLSIZE)
        lcd.drawText (0, 25, "to install the correct mixer script", SMLSIZE)
        lcd.drawText (0, 33, "for your specific platform.", SMLSIZE)
        return
    end


    local mavlink_messages = pix_get_mavlink_messages()
    local n = 0

    for k,v in pairs(mavlink_messages) do
        if (v ~= mavlink_messages.first and v ~= mavlink_messages.last) then
            lcd.drawText (1, 1+8*n , v, SMLSIZE)
            n=n+1
        end
    end
end

return { run=run, background=background, init=init}
