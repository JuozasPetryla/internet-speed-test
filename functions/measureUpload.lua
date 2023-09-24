local socket = require('socket')
local post = require('functions.cURLPost')

function measureUploadSpeed(filePath,url)
    local startTime = socket.gettime()
    local errMessage = "Could not measure upload speed, please try again"
    
    local status, fileSize = pcall(post, filePath, url)

    if status then 
        local endTime = socket.gettime()
        local uploadTime = endTime - startTime
        local uploadSpeedMbps = ((((fileSize * 8) /1000) / (uploadTime *1000) )/8)
    
        return uploadSpeedMbps
    else 
        return errMessage
    end

end


return measureUploadSpeed