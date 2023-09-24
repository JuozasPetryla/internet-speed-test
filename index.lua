local cjson = require('cjson')
local get= require('functions.cURLGet')
local argparse = require('argparse')
local measureUploadSpeed = require('functions.measureUpload')
local measureDownloadSpeed = require('functions.measureDownload')

local locationUrl = 'http://ip-api.com/json/'
local serversUrl = 'http://10.0.2.15/speedtest_server_list.json'

local statusLocation, locationFile = pcall(get, locationUrl)
local location = cjson.decode(locationFile)
local ispName = location['isp']


local serversStatus,serverListFile = pcall(get,serversUrl)
local transformedData = cjson.decode(string.sub(serverListFile, 288))

local isp = nil

for i, obj in ipairs(transformedData) do
    if string.find(ispName, obj.provider) then
        isp = obj
        break
    end
end

local ispUrl = isp["host"]


function downloadSpeedTest() 
    local statusDownload, downloadSpeed = pcall(measureDownloadSpeed, ispUrl)
    if type(downloadSpeed) == "number" then
        print("Your internet download speed: ".. string.format("%.2f", downloadSpeed))
    else
        print(downloadSpeed)
    end
end


function uploadSpeedTest () 
    local statusUpload, uploadSpeed = pcall(measureUploadSpeed,'data/speedtest_servers.json',ispUrl)
    if type(uploadSpeed) == "number" then
        print("Your internet upload speed: ".. string.format("%.2f", uploadSpeed))
    else
        print(uploadSpeed)
    end
end

local parser = argparse()
parser:option('f --function', 'Function to execute')

local args = parser:parse()

if args['function'] == "uploadSpeedTest" then
    uploadSpeedTest()
elseif args['function'] == "downloadSpeedTest" then 
    downloadSpeedTest()
else
    downloadSpeedTest()
    uploadSpeedTest()
end

if serversStatus then
    print("Server list file successfully downloaded")
else
    print("Could not download server list file")
end

if statusLocation then
    print("Your location: "..location['city'] .. ", ".. location['country'])
    print("The best server for your location: ".. isp['provider'])
else
    print("Could not get your location or ideal internet service provider")
end

if (type(downloadSpeed) == "number" and type(uploadSpeed) == "number" and statusLocation) then
    local testData = {
        uploadSpeed = uploadSpeed, 
        downloadSpeed = downloadSpeed,
        location = location['city'] .. ", ".. location['country'], 
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





