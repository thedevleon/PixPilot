--[[
PixPilot PX4 Adapter

PX4 Telemetry Info:

Normal Telemetry data:
#define SMARTPORT_ID_FUEL          0x0600
#define SMARTPORT_ID_ALT           0x0100
#define SMARTPORT_ID_VARIO         0x0110   //VSPEED
#define SMARTPORT_ID_ACCX          0x0700   //Measured in g!
#define SMARTPORT_ID_ACCY          0x0710
#define SMARTPORT_ID_ACCZ          0x0720
#define SMARTPORT_ID_CURR          0x0200
#define SMARTPORT_ID_VFAS          0x0210  //Battery Voltage
#define SMARTPORT_ID_CELLS         0x0300  //Volt per cell
#define SMARTPORT_ID_GPS_LON_LAT   0x0800
#define SMARTPORT_ID_GPS_ALT       0x0820
#define SMARTPORT_ID_GPS_SPD       0x0830
#define SMARTPORT_ID_GPS_CRS       0x0840
#define SMARTPORT_ID_GPS_TIME      0x0850

Custom Telemetry data:
#define SMARTPORT_ID_DIY_NAV_STATE  0x5080
#define SMARTPORT_ID_DIY_GPS_FIX    0x5081
#define SMARTPORT_ID_DIY_ARMING_STATE    0x5082
#define SMARTPORT_ID_DIY_ATTITUDE_ROLL  0x5083
#define SMARTPORT_ID_DIY_ATTITUDE_PITCH   0x5084
#define SMARTPORT_ID_DIY_ATTITUDE_YAW   0x5085
#define SMARTPORT_ID_DIY_MISSION_COUNT 0x5086
#define SMARTPORT_ID_DIY_MISSION_SEQUENCE_REACHED 0x5087 //Sequence is an id for a mission item - "a thing to do"
#define SMARTPORT_ID_DIY_MISSION_SEQUENCE_CURRENT 0x5088
#define SMARTPORT_ID_DIY_MISSION_SEQUENCE_STATUS 0x5089
#define SMARTPORT_ID_DIY_MAVLINK_MESSAGE_BYTE 0x508a //Start bit is 0x02, End bit is 0x03
]]--

pix_adapter_running = false

local controller = "PX4"

-- normal values --
local fuel
local alt
local vario
local accX
local accY
local accZ
local current
local vfas
local cells
local gps_lon_lat
local gps_alt
local gps_spd
local gps_crs
local gps_time

-- custom values --
local nav_state
local gps_fix
local gps_sat
local arming_state
local roll
local pitch
local yaw
local mission_count
local mission_seq_reached
local mission_seq_current
local mission_seq_status_valid
local mission_seq_status_warning
local mission_seq_status_reached
local mission_seq_status_finished
local mission_seq_status_stay_in_failsafe
local mission_seq_status_flight_termination
local mission_seq_status_item_do_jump_changed
local mission_seq_status_failure



-- mavlink message related --
local mavlink_messages = { }
local mavlink_last_message = ""
local mavlink_message_buffer = ""
local mavlink_message_done = false

-- ids --
local fuelId = 1536
local altId = 256
local varioId = 272
local accXId = 1792
local accYId = 1808
local accZId = 1824
local currentId = 512
local vfasId = 528
local cellsId = 768
local gps_lon_latId = 2048
local gps_altId = 2080
local gps_spdId = 2096
local gps_crsId = 2112
local gps_timeId = 2128

-- PX4 specific--
local nav_stateId = 20608
local gps_fix_satId = 20609
local arming_stateId = 20610
local rollId = 20611
local pitchId = 20612
local yawId = 20613
local mission_countId = 20614
local mission_seq_reachedId = 20615
local mission_seq_currentId = 20616
local mission_seq_statusId = 20617
local mavlink_messageId = 20618

-- local functions --

local function init()
    mavlink_messages_init()
    pix_adapter_running = true
end

local function run()
    update_pix_telemetry()
end

function pix_init()
    mavlink_messages_init()
    pix_adapter_running = true
end

function pix_run()
    update_pix_telemetry()
end

function mavlink_messages_init()
    mavlink_messages = {first = 0, last = -1}
end

function mavlink_messages_push(value)
    --only keep the last 8 messages
    if mavlink_messages.last - mavlink_messages.first >= 8 then mavlink_messages_pop() end
    local first = mavlink_messages.first - 1
    mavlink_messages.first = first
    mavlink_messages[first] = value
end

function mavlink_messages_pop()
    local last = mavlink_messages.last
    if mavlink_messages.first > last then return end
    mavlink_messages[last] = nil
    mavlink_messages.last = last - 1
end

--[[
this function might need to be called from the telemetry script instead of
here, since mixer scripts are limited to 30 milliseconds execution time
]]--
function update_pix_telemetry()

    -- normal id parsing --

    fuel = getValue(fuelId)
    alt = getValue(altId)
    vario = getValue(varioId)
    accX = getValue(accXId)
    accY = getValue(accYId)
    accZ = getValue(accZId)
    current = getValue(currentId)
    vfas = getValue(vfasId)
    cells = getValue(cellsId)
    gps_lon_lat = getValue(gps_lon_latId)
    gps_alt = getValue(gps_altId)
    gps_spd = getValue(gps_spdId)
    gps_crs = getValue(gps_crsId)
    gps_time = getValue(gps_timeId)

    -- mavlink message parsing --
    local physicalId, primId, dataId, value = telemetryPop()

    if dataId == nav_stateId then
        nav_state = value

    elseif dataId == gps_fix_satId then
        gps_fix =  value % 10
        gps_sat =   (value -  (value % 10)) * 0.1

    elseif dataId == arming_stateId then
        arming_state = value

    elseif dataId == rollId then
        roll = value / 100000.0

    elseif dataId == pitchId then
        pitch = value / 100000.0

    elseif dataId == yawId then
        yaw = value / 100000.0

    elseif dataid == mission_countId then
        mission_countId = value

    elseif dataId == mission_seq_reachedId then
        mission_seq_reached = value

    elseif dataId == mission_seq_currentId then
        mission_seq_current = value

    elseif dataId == mission_seq_statusId then
        --TODO mission bitflags

    elseif dataId == mavlink_messageId then
        local byte1 = 0
        local byte2 = 0
        local byte3 = 0
        local byte4 = 0

        byte1 = math.floor(value / 2^24)
        byte2 = math.floor((value % 2^24) / 2^16)
        byte3 = math.floor((value % 2^16) / 2^8)
        byte4 = value % 2^8


        if(byte1 == 0x02) then
            mavlink_message_done = false;
        elseif(byte1 == 0x03) then
            mavlink_message_done = true
            mavlink_last_message = mavlink_message_buffer
            mavlink_message_buffer = ""
        elseif(byte1 >= 20) then
            mavlink_message_buffer = mavlink_message_buffer..string.char(byte1)
        end

        if(byte2 == 0x02) then
            mavlink_message_done = false;
        elseif(byte2 == 0x03) then
            mavlink_message_done = true
            mavlink_last_message = mavlink_message_buffer
            mavlink_message_buffer = ""
        elseif(byte2 >= 20) then
            mavlink_message_buffer = mavlink_message_buffer..string.char(byte2)
        end

        if(byte3 == 0x02) then
            mavlink_message_done = false;
        elseif(byte3 == 0x03) then
            mavlink_message_done = true
            mavlink_last_message = mavlink_message_buffer
            mavlink_message_buffer = ""
        elseif(byte3 >= 20) then
            mavlink_message_buffer = mavlink_message_buffer..string.char(byte3)
        end

        if(byte4 == 0x02) then
            mavlink_message_done = false;
        elseif(byte4 == 0x03) then
            mavlink_message_done = true
            mavlink_last_message = mavlink_message_buffer
            mavlink_message_buffer = ""
        elseif(byte4 >= 20) then
            mavlink_message_buffer = mavlink_message_buffer..string.char(byte4)
        end

        if(mavlink_message_done) then
            mavlink_messages_push(mavlink_last_message)
            mavlink_message_done = false
        end
    end
end


-- global functions --

function pix_get_controller_name()
    return controller
end

function pix_get_alt()
    return alt
end

function pix_get_vario()
    return vario
end

function pix_get_accX()
    return accX
end

function pix_get_accY()
    return accY
end

function pix_get_current()
    return current
end

function pix_get_vfas()
    return vfas
end

function pix_get_cells()
    return cells
end

function pix_get_gps_lon_lan()
    return gps_lon_lat
end

function pix_get_gps_alt()
    return gps_alt
end

function pix_get_gps_spd()
    return gps_spd
end

function pix_get_gps_crs()
    return gps_crs
end

function pix_get_gps_time()
    return gps_time
end

function pix_get_flightmode()
        if nav_state == 0  then return "Manual"
    elseif nav_state == 1  then return "Altitude Control"
    elseif nav_state == 2  then return "Position Control"
    elseif nav_state == 3  then return "Mission"
    elseif nav_state == 4  then return "Loiter"
    elseif nav_state == 5  then return "RTL"
    elseif nav_state == 6  then return "RC Recover"
    elseif nav_state == 7  then return "RTGS - Link Loss"
    elseif nav_state == 8  then return "Land - Engine Fail"
    elseif nav_state == 9  then return "Land - GPS Fail"
    elseif nav_state == 10 then return "Acro"
    elseif nav_state == 11 then return "Unused"
    elseif nav_state == 12 then return "Descend"
    elseif nav_state == 13 then return "Termination"
    elseif nav_state == 14 then return "Offboard"
    elseif nav_state == 15 then return "Stabilized"
    elseif nav_state == 16 then return "RAttitude"
    elseif nav_state == 17 then return "Takeoff"
    elseif nav_state == 18 then return "Land"
    elseif nav_state == 19 then return "Auto Follow"
    elseif nav_state == 10 then return "Max"
    end
end


function pix_get_gps_fix()
    return gps_fix
end

function pix_get_gps_sat()
    return gps_sat
end

function pix_get_arming_state()
        if arming_state == 0  then return "Init"
    elseif arming_state == 1  then return "Standby"
    elseif arming_state == 2  then return "Armed"
    elseif arming_state == 3  then return "Armed Error"
    elseif arming_state == 4  then return "Standby Error"
    elseif arming_state == 5  then return "Reboot"
    elseif arming_state == 6  then return "In Air Restore"
    elseif arming_state == 7  then return "Max"
    end
end

function pix_get_roll()
    return roll
end

function pix_get_pitch()
    return pitch
end

function pix_get_yaw()
    return yaw
end

function pix_get_mission_count()
    return mission_count
end

function pix_get_mission_seq_reached()
    return mission_seq_reached
end

function pix_get_mission_seq_current()
    return mission_seq_current
end

--TODO add mission_seq_status functions

function pix_get_mavlink_messages()
    return mavlink_messages
end

function pix_say_flight_mode()
    --TODO implement
end

return { run=run, init=init }
