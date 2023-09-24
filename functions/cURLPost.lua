local curl = require('lcurl')

local function post(filePath, url)
    local fileContent = assert(io.open(filePath, 'rb')):read("*all")
    local easy = curl.easy()

    easy:setopt_url(url)
    easy:setopt(curl.OPT_POSTFIELDS, fileContent)
    
    easy:perform()
    
    easy:close()
    return #fileContent
end

return post