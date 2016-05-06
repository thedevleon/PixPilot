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
local gps_lon
local gps_lat
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
local mission_seq_status

--mavlink message related --
local mavlink_messages = { }
local mavlink_last_message = ""
local mavlink_message_buffer = ""
local mavlink_message_done = false

--ids --
local fuelId
local altId
local varioId
local accXId
local accYId
local accZId
local currentId
local vfasId
local cellsId
local gps_lonId
local gps_latId
local gps_altId
local gps_spdId
local gps_crsId
local gps_timeId
local nav_stateId
local gps_fix_satId
local arming_stateId
local rollId
local pitchId
local yawId
local mission_countId
local mission_seq_reachedId
local mission_seq_currentId
local mission_seq_statusId
local mavlink_messageId = 20618

-- local functions --

local function init()
    mavlink_messages = mavlink_messages.init()
    pix_adapter_running = true
end

local function run()
    update_pix_telemetry()
end

--[[
this function might need to be called from the telemetry script instead of
here, since mixer scripts are limited to 30 milliseconds execution time
]]--
local function update_pix_telemetry()

    -- mavlink message parsing --
    local physicalId, primId, dataId, value = telemetryPop()

    if dataId == mavlink_messageId then
        local byte1 = 0
        local byte2 = 0
        local byte3 = 0
        local byte4 = 0

        byte1 = math.floor(value / 2^24)
        byte2 = math.floor((value % 2^24) / 2^16)
        byte3 = math.floor((value % 2^16) / 2^8)
        byte4 = value % 2^8


        if(byte1 == 0x02) then
            messagedone = false;
        elseif(byte1 == 0x03) then
            messagedone = true
            lastmessage = messagebuffer
            messagebuffer = ""
        elseif(byte1 >= 20) then
            messagebuffer = messagebuffer..string.char(byte1)
        end

        if(byte2 == 0x02) then
            messagedone = false;
        elseif(byte2 == 0x03) then
            messagedone = true
            lastmessage = messagebuffer
            messagebuffer = ""
        elseif(byte2 >= 20) then
            messagebuffer = messagebuffer..string.char(byte2)
        end

        if(byte3 == 0x02) then
            messagedone = false;
        elseif(byte3 == 0x03) then
            messagedone = true
            lastmessage = messagebuffer
            messagebuffer = ""
        elseif(byte3 >= 20) then
            messagebuffer = messagebuffer..string.char(byte3)
        end

        if(byte4 == 0x02) then
            messagedone = false;
        elseif(byte4 == 0x03) then
            messagedone = true
            lastmessage = messagebuffer
            messagebuffer = ""
        elseif(byte4 >= 20) then
            messagebuffer = messagebuffer..string.char(byte4)
        end

        if(messagedone) then
            mavlink_messages.push(mavlink_messages, messagebuffer)
        end
    end
end

function mavlink_messages.init()
    return {first = 0, last = -1}
end

function mavlink_messages.push(list, value)
    --only keep the last 8 messages
    if math.abs(list.first - list.last) >= 8 then list.pop(list) end
    local first = list.first - 1
    list.first = first
    list[first] = value
end

function mavlink_messages.pop(list)
  local last = list.last
  if list.first > last then return nil end
  local value = list[last]
  list[last] = nil
  list.last = last - 1
  return value
end

-- global functions --


function pix_say_flight_mode()

end



return { run=run, init=init }
