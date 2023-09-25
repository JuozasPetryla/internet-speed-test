local serverList = {}
local curl = require('lcurl')
local cjson = require('cjson')

local serversUrl = 'https://raw.githubusercontent.com/JuozasPetryla/internet-speed-test-data/main/speedtest_servers.json'

function serverList.getServerList()
    local serverList

    local serverListFile = io.open('data/speedtest_servers.json', 'r+')
    if serverListFile then 
        serverList = cjson.decode(serverListFile:read()) 
        return serverList
    else
        local responseString = ''
        
        easy = curl.easy({
            url = serversUrl,
            writefunction = (function(response)
                responseString = responseString .. response
                return #response
            end)
        })
        
        status, response = pcall(easy.perform, easy)

        
        easy:close()
        serverList = cjson.decode(responseString)
        return serverList
    end
end

return serverList

