local speedTest = {}
local socket = require('socket')
local curl = require('lcurl')


function speedTest.downloadSpeed(url) 
    if not url then error("No url", 0) end

    local outputFile = io.open("/dev/null", 'r+')
    if not outputFile then
        error("Error while opening /dev/null for testing donwload speed", 0)
    end

    easy = curl.easy({
        httpheader = {
            "User-Agent: curl/7.81.0", "Accept: */*","Cache-Control: no-cache"
        },
        [curl.OPT_IGNORE_CONTENT_LENGTH] = true,
        url = url .. "/download",
        writefunction = outputFile,
        noprogress = false,
    })

    testTime = socket.gettime()

    status, value = pcall(easy.perform, easy)
    io.close(outputFile)
    if not status then
        easy:close()

        error("Error: " .. value .. "while testing download speed with host " .. url, 0)
    end
    local downloadSpeed = easy:getinfo(curl.INFO_SPEED_DOWNLOAD) / 1024 / 1024 * 8
    easy:close()

    return downloadSpeed
end


function speedTest.uploadSpeed(url, testDurationSeconds)
    if not url then
        error("No url", 0)
    end

    local maxChunkSize = 1024  
    local targetInterval = 5  

    while maxChunkSize * 8 /90 < 2000000 and maxChunkSize < 20000000 do
        maxChunkSize = maxChunkSize * 2
    end

    local easy = curl.easy({
        httpheader = {
            "User-Agent: curl/7.81.0",
            "Accept: */*",
            "Cache-Control: no-cache"
        },
        url = url .. "/upload",
        noprogress = false,
    })

    local startTime = socket.gettime()
    local totalBytesSent = 0

    while (socket.gettime() - startTime) < 15 do
        local uploadData = string.rep("a", maxChunkSize)

        easy:setopt(curl.OPT_POSTFIELDS, uploadData) 
        local status, value = pcall(easy.perform, easy) 

        if not status then
            easy:close()
            error("Error: " .. value .. " while testing upload speed with host " .. url, 0)
        end

        totalBytesSent = totalBytesSent + maxChunkSize
    end

    easy:close() 

    local uploadSpeed = totalBytesSent / 15 / 1024 / 1024 * 8
    return uploadSpeed
end

return speedTest