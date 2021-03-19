--
-- buttplug.lua
--
-- MIT License
--
-- Copyright (c) 2021 abbiwyn
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local json = require("json")
local pollnet = require("pollnet")

local buttplug = {}

--
-- Buttplug messages
--

local messages = {}

-- Status messages

messages.Ok = {
    Ok = {
        Id = 1
    }
}

messages.Error = {
    Error = {
        Id = 0,
        ErrorMessage = "",
        ErrorCode = 0
    }
}

-- Handshake messages

messages.RequestServerInfo = {
    RequestServerInfo = {
        Id = 1,
        ClientName = "",
        MessageVersion = 1
    }
}

messages.ServerInfo = {
    ServerInfo = {
        Id = 1,
        ServerName = "",
        MessageVersion = 1,
        MaxPingTime = 0
    }
}

-- Enumeration messages

messages.RequestDeviceList = {
    RequestDeviceList = {
        Id = 1
    }
}

messages.DeviceList = {
    DeviceList = {
        Id = 1,
        Devices = {}
    }
}

messages.StartScanning = {
    StartScanning = {
        Id = 1
    }
}

messages.StopScanning = {
    StopScanning = {
        Id = 1
    }
}

messages.DeviceAdded = {
    DeviceAdded = {
        Id = 0,
        DeviceName = "",
        DeviceIndex = 0,
        DeviceMessages = {}
    }
}

messages.DeviceRemoved = {
    DeviceRemoved = {
        Id = 0,
        DeviceIndex = 0
    }
}

-- Generic device messages

messages.StopDeviceCmd = {
    StopDeviceCmd = {
        Id = 1,
        DeviceIndex = 0
    }
}

messages.StopAllDevices = {
    StopAllDevices = {
        Id = 1
    }
}

messages.VibrateCmd = {
    VibrateCmd = {
        Id = 1,
        DeviceIndex = 0,
        Speeds = {}
    }
}

--
-- Global variables
--

buttplug.msg_counter = 1
buttplug.devices = {}
buttplug.got_server_info = false
buttplug.got_device_list = false
buttplug.print = print

--
--
--

local function message_type(msg)
    -- Message type is the first field
    return next(msg)
end

-- Send a message to the Buttplug Server
local function send(msg)
    local message_type = message_type(msg)

    -- Set message ID num and increment counter
    msg[message_type].Id = buttplug.msg_counter
    buttplug.msg_counter = buttplug.msg_counter + 1
    
    local payload = "[" .. json.encode(msg) .. "]"
    buttplug.print("> " .. payload)
    return buttplug.sock:send(payload)
end

function buttplug.request_server_info(client_name)
    local msg = messages.RequestServerInfo

    msg["RequestServerInfo"]["ClientName"] = client_name

    return send(msg)
end

function buttplug.request_device_list()
    return send(messages.RequestDeviceList)
end

function buttplug.start_scanning()
    return send(messages.StartScanning)
end

function buttplug.stop_scanning()
    return send(messages.StopScanning)
end

-- Sends a vibrate command to device with the index `dev_index`.
-- `speeds` is a table with 1 vibration value per motor e.g. { 0.2, 0.2
-- } would set both motors on a device with 2 motors to 0.2
function buttplug.send_vibrate_cmd(dev_index, speeds)
    local msg = messages.VibrateCmd

    msg["VibrateCmd"]["DeviceIndex"] = dev_index

    for i, v in ipairs(speeds) do
        msg["VibrateCmd"]["Speeds"][i] = { Index = i - 1, Speed = v }
    end

    return send(msg)
end

function buttplug.send_stop_device_cmd(dev_index)
    local msg = messages.StopDevice

    msg["StopDeviceCmd"]["DeviceIndex"] = dev_index

    return send(msg)
end

function buttplug.send_stop_all_devices_cmd()
    return send(messages.StopAllDevices)
end

function buttplug.count_devices()
    return table.getn(buttplug.devices)
end

function buttplug.has_devices()
    return buttplug.count_devices() > 0
end

function buttplug.add_device(dev)
    local dev_count = table.getn(buttplug.devices)
        
    buttplug.devices[dev_count + 1] = {
        index = dev["DeviceIndex"],
        name = dev["DeviceName"],
        messages = dev["DeviceMessages"]
    }
end

function buttplug.remove_device(dev_index)
    for i, v in ipairs(buttplug.devices) do
        if v.index == dev_index then
            table.remove(buttplug.devices, i)
        end
    end
end

-- Decide what to do based on the message type
function buttplug.handle_message(raw_message)
    local msg = json.decode(raw_message)[1]
    local msg_type = message_type(msg)
    local msg_contents = msg[msg_type]

    -- if ServerInfo, set flag
    if (msg_type == "ServerInfo") then
        buttplug.got_server_info = true
    end

    -- if DeviceList, add any devices
    if (msg_type == "DeviceList") then
        local devices = msg_contents["Devices"]

        for i, v in ipairs(devices) do
            buttplug.add_device(v)
        end

        buttplug.got_device_list = true
    end

    -- if DeviceAdded, add the device
    if (msg_type == "DeviceAdded") then
        buttplug.add_device(msg_contents)
    end

    -- if DeviceRemoved, remove the device
    if (msg_type == "DeviceRemoved") then
        buttplug.remove_device(msg_contents["DeviceIndex"])
    end
end

-- Gets and handles messages from the server. Returns the message when
-- something goes wrong
function buttplug.get_and_handle_message()
    local happy, message = buttplug.sock:poll()
    
    if not happy then
        return message
    end

    if message then
        buttplug.print("< " .. message)
        buttplug.handle_message(message)
    end
end

-- Open the socket and send a handshake message to the server
function buttplug.connect(client_name, ws_addr)
    buttplug.client_name = client_name
    buttplug.sock = pollnet.open_ws(ws_addr)
    buttplug.request_server_info(buttplug.client_name)
end

return buttplug
