local curl = require('lcurl')

local response = ""

function writeCallback(string)
    response = response .. string
    return #string
end

function get(url)
    curl.easy{
        url = url,
        writefunction = writeCallback
    }:perform():close()
    return response
end

return get

