local isfile = isfile or function(file)
    local suc, res = pcall(function() return readfile(file) end)
    return suc and res ~= nil and res ~= ''
end

local delfile = delfile or function(file)
    writefile(file, '')
end

local REPO = 'yourusername/custom-vape'
local BASE_FOLDER = 'customvape'

local function downloadFile(path, func)
    if not isfile(path) then
        local suc, res = pcall(function()
            local remotePath = 'https://raw.githubusercontent.com/'..REPO..'/'..
                (readfile(BASE_FOLDER..'/profiles/commit.txt') or 'main')..'/'..path:gsub(BASE_FOLDER..'/', '')
            return game:HttpGet(remotePath, true)
        end)
        if not suc or res == '404: Not Found' then error(res) end
        if path:find('%.lua$') then
            res = '--[[ Auto-delete watermark: remove this line to persist across updates. ]]\n'..res
        end
        writefile(path, res)
    end
    return (func or readfile)(path)
end

local function wipeFolder(path)
    if not isfolder(path) then return end
    for _, file in ipairs(listfiles(path)) do
        if file:find('loader') then continue end
        if isfile(file) and readfile(file):find('Auto%-delete watermark') == 1 then
            delfile(file)
        end
    end
end

for _, folder in ipairs({
    BASE_FOLDER,
    BASE_FOLDER..'/games',
    BASE_FOLDER..'/profiles',
    BASE_FOLDER..'/assets',
    BASE_FOLDER..'/libraries',
    BASE_FOLDER..'/guis',
}) do
    if not isfolder(folder) then makefolder(folder) end
end

if not shared.VapeDeveloper then
    local _, subbed = pcall(function()
        return game:HttpGet('https://github.com/'..REPO)
    end)
    local commit = subbed:find('currentOid')
    commit = commit and subbed:sub(commit + 13, commit + 52) or nil
    commit = commit and #commit == 40 and commit or 'main'
    if commit == 'main' or (isfile(BASE_FOLDER..'/profiles/commit.txt') and readfile(BASE_FOLDER..'/profiles/commit.txt') or '') ~= commit then
        wipeFolder(BASE_FOLDER)
        wipeFolder(BASE_FOLDER..'/games')
        wipeFolder(BASE_FOLDER..'/guis')
        wipeFolder(BASE_FOLDER..'/libraries')
    end
    writefile(BASE_FOLDER..'/profiles/commit.txt', commit)
end

return loadstring(downloadFile(BASE_FOLDER..'/main.lua'), 'main')()
