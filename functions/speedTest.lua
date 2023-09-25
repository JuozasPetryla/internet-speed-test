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


function speedTest.uploadSpeed(url)
    if not url  then
        error("No url", 0)
    end

    local inputFile = io.open('/dev/zero', 'r+')

    if not inputFile then
        error("Error while opening the input file for testing upload speed", 0)
    end

    local uploadData = inputFile:read(70000000)
    local easy = curl.easy({
        httpheader = {
            "User-Agent: curl/7.81.0",
            "Accept: */*",
            "Cache-Control: no-cache"
        },
        [curl.OPT_POSTFIELDS] = uploadData,
        url = url .. "/upload",
        noprogress = false,
        progressfunction = uploadProgressCallback
    })

    testTime = socket.gettime()

    status, value = pcall(easy.perform, easy)

    if not status then
        easy:close()
        error("Error: " .. value .. " while testing upload speed with host " .. url, 0)
    end

    local uploadSpeed = easy:getinfo(curl.INFO_SPEED_UPLOAD) / 1024 / 1024 * 8
    easy:close()

    return uploadSpeed
end



-- function uploadProgressCallback () 
--     local statusUpload, uploadSpeed = pcall(speedTest.uploadSpeed,ispUrl)
--     if type(uploadSpeed) == "number" then
--         print("Your internet upload speed: ".. string.format("%.2f", uploadSpeed).. "Mbps")
--     else
--         print(uploadSpeed)
--     end
-- end


return speedTest