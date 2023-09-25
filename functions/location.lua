local location = {}
local curl = require('lcurl')
local cjson = require('cjson')


local locationUrl = 'http://ip-api.com/json/'

function location.getLocation()
    local responseString = ''

    easy = curl.easy({
        url = locationUrl,
        writefunction = (function(response)
            responseString = response
        end)
    })
    
    status, response = pcall(easy.perform, easy)
    if not status then
        easy:close()
        
        error("Error: " .. response .. "while getting location", 0)
    end
 
    easy:close()

    local location  = cjson.decode(responseString)
    
    return location
end

function location.getBestServer(serverList)
    local status, location = pcall(location.getLocation)

    local allHostsWithLatencies = {}

    local lowestLatency = math.huge
    local bestHost = ''

    for  i, value in ipairs(serverList) do
        if string.find(location['country'], value.country) then
            easy = curl.easy({
                url = value['host'],
            })
            
            status, response = pcall(easy.perform, easy)
            if not status then
                easy:close()
                
                error("Error: " .. response .. "while fetching server" .. url, 0)
            end
            local latency = easy:getinfo(curl.INFO_TOTAL_TIME) / 1024 / 1024 * 8
            if latency < lowestLatency then 
                lowestLatency = latency 
            end
            table.insert(allHostsWithLatencies, {value['provider'],latency})
            easy:close()
        end
    end
    
    for i, value in ipairs(allHostsWithLatencies) do
        if value[2] == lowestLatency then
            bestHost = value[1]
        end
    end

    return bestHost
end

return location