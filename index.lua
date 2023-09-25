local cjson = require('cjson')
local argparse = require('argparse')
local speedTest = require('functions.speedTest')
local location = require('functions.location')
local serverList = require('functions.serverList')

local userLocation = location.getLocation()
    local ispName = userLocation['isp']
    local serverList = serverList.getServerList()
    
    local isp = nil

    for i, obj in ipairs(serverList) do
        if string.find(ispName, obj.provider)then
            isp = obj
            break
        end
    end

local ispUrl = isp['host']

local parser = argparse()
parser:option('f --function', 'Function to execute')

local args = parser:parse()

if args['function'] == "upload-speed" then
    local uploadSpeed = speedTest.uploadSpeed(ispUrl)
    print("Your internet upload speed: ".. string.format("%.2f", uploadSpeed).. "Mbps")
elseif args['function'] == "download-speed" then 
    local downloadSpeed = speedTest.downloadSpeed(ispUrl)
    print("Your internet upload speed: ".. string.format("%.2f", downloadSpeed).. "Mbps")
elseif args['function'] == "get-location" then
    local userLocation = location.getLocation()
    print("Your current location is: ".. userLocation['city'] .. ", " .. userLocation["country"])
elseif args['function'] == "get-best-server" then
    local bestIsp = location.getBestServer(serverList)
    print("Your best internet service provider: "..bestIsp)
else
    local downloadSpeed = speedTest.downloadSpeed(ispUrl)
    print("Your internet upload speed: ".. string.format("%.2f", downloadSpeed).. "Mbps")

    local uploadSpeed = speedTest.uploadSpeed(ispUrl)
    print("Your internet upload speed: ".. string.format("%.2f", uploadSpeed).. "Mbps")
    
    print("Your current location is: ".. userLocation['city'] .. ", " .. userLocation["country"])
    local bestIsp = location.getBestServer(serverList)

    print("Your best internet service provider: " .. bestIsp)

    if (type(downloadSpeed) == "number" and type(uploadSpeed) == "number" and userLocation) then
        local testData = {
            uploadSpeed = uploadSpeed, 
            downloadSpeed = downloadSpeed,
            location = userLocation['city'] .. ", ".. userLocation['country'], 
            idealIsp = isp['provider']
        }
        local testDataFile = cjson.encode(testData)
        local file = io.open('data/testData.json', 'w')
        if file then 
            file:write(testDataFile)
            file:close()
        else
            print("Failed writing JSON to file")
        end
    end
end






