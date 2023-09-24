local socket = require('socket')
local get = require('functions.cURLGet')

function measureDownloadSpeed(url)
    local startTime = socket.gettime()
    
    local errMessage = "Could not measure download speed, please try again"

    local status, downloadedData = pcall(get, url)

    if status then
        local endTime = socket.gettime()
        local downloadTime = endTime - startTime
        local downloadSpeedMbps = ((((#downloadedData * 8) /1000) / (downloadTime *1000) )/8)
        return downloadSpeedMbps
    else
        return errMessage
    end
end


return measureDownloadSpeed