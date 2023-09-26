local internet = {}
local curl = require('lcurl')

function discardResponseData(chunk)
    return #chunk
end

function internet.checkConnection()
    local testUrl = "http://www.google.com" 

    local easy = curl.easy({
        url = testUrl,
        connecttimeout = 5,  
    })

    easy:setopt(curl.OPT_NOBODY, true)  
    easy:setopt(curl.OPT_HEADER, true) 
    easy:setopt(curl.OPT_WRITEFUNCTION, discardResponseData)

    local status, value = pcall(easy.perform, easy)

    easy:close()

    if status then
        return true
    else
        return false
    end
end

return internet