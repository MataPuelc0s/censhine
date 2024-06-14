local argparse = require "argparse"
local glue = require "glue"
local luna = require "src.lua.lua_modules.luna"
local md5 = require "md5"
local fs = require "fs"
require "compat53"
local constants = require "src.lua.constants"
local vertexShaderNames = constants.vertexShaderNames
local pixelShaderNames = constants.pixelShaderNames
local pixelShaderFunctions = constants.pixelShaderFunctions
local binaries = constants.binaries
require "src.lua.censhine.binary"

local parser = argparse("build", "Build shaders for Halo Custom Edition from dxbc files")
parser:argument("shadersPath", "Path to directX byte code shader files")
parser:flag("--vertex", "Build vertex shaders")
parser:flag("--verifystock", "Verify stock shaders")
parser:flag("--encrypt", "Encrypt shaders output file")
parser:flag("--verbose", "Verbose output")
parser:flag("--unknown", "Include unknown shaders")
local args = parser:parse()
local splitPath = args.shadersPath:split "/"
local shadersFileName = splitPath[#splitPath]
local shadersOutputPath = "dist/"
fs.mkdir(shadersOutputPath, true)
local shadersOutputFilePath = shadersOutputPath .. shadersFileName .. ".dec"

local function log(...)
    if args.verbose then
        print(...)
    end
end

if args.vertex then
    shadersOutputFilePath = shadersOutputPath .. "vsh.dec"
end
local shadersFile = io.open(shadersOutputFilePath, "wb")
assert(shadersFile, "Failed to open output file " .. shadersOutputFilePath)
if not args.vertex then
    -- Effect Collection Version
    shadersFile:write(wuint32(126))
end

local pixelShaders = {}
local vertexShaders = {}

for shaderName, shaderFolderEntry in fs.dir(args.shadersPath) do
    assert(shaderName, "Could not read shader folder entry")
    print("Bulding shader: " .. shaderName)
    if not args.vertex then
        local shaders = {}
        for shaderFunctionFile, shaderCSOEntry in fs.dir(shaderFolderEntry:path()) do
            assert(shaderFunctionFile)
            if shaderFunctionFile:endswith(constants.extensions.compiledShaderObject) then
                local shaderFunctionName = shaderFunctionFile:replace(constants.extensions
                                                                          .compiledShaderObject, "")
                assert(pixelShaderFunctions[shaderName], "Unknown pixel shader: " .. shaderName)
                local byteCode = luna.binary.read(shaderCSOEntry:path())
                assert(byteCode, "Could not read shader file: " .. shaderCSOEntry:path())
                local minorVersion = byte(byteCode:sub(1))
                local majorVersion = byte(byteCode:sub(2))
                local version = ("_ps_%s_%s"):format(majorVersion, minorVersion)
                local functionName = shaderFunctionName:replace("PS_", ""):replace(version, "")
                -- print(shaderName, shaderFunctionName, functionName, majorVersion, minorVersion)
                local pixelShaderFunctionIndex = pixelShaderFunctions[shaderName][functionName]
                if not pixelShaderFunctionIndex then
                    print("ERROR! Unknown pixel shader function: " .. shaderName .. " " ..
                              shaderFunctionName)
                    os.exit(1)
                end
                local shaderFunctionNameWithVersion =
                    shaderFunctionName .. "_ps_" .. majorVersion .. "_" .. minorVersion
                shaders[pixelShaderFunctionIndex] = {shaderFunctionNameWithVersion, byteCode}
            end
        end
        local pixelShaderIndex = table.indexof(pixelShaderNames, shaderName)
        if pixelShaderIndex then
            pixelShaders[pixelShaderIndex] = {shaderName, shaders}
        else
            if not args.unknown then
                print("Warning! Unknown pixel shader has been added: " .. shaderName)
                print("Do you want to continue? (y/n)")
                local response = io.read()
                if response:lower() ~= "y" then
                    os.exit(1)
                end
            end
        end
    end
    if args.vertex then
        if shaderName:endswith(constants.extensions.compiledShaderObject) then
            local byteCode = luna.binary.read(shaderFolderEntry:path())
            assert(shaderName)
            local vertexShaderName = shaderName:replace(constants.extensions.compiledShaderObject,
                                                        "")
            local vertexShaderIndex = table.flip(vertexShaderNames)[vertexShaderName] or
                                          tonumber(vertexShaderName:split("vsh_")[2])
            if vertexShaderIndex then
                vertexShaders[vertexShaderIndex] = byteCode
            end
        end
    end
end
if not args.vertex then
    assert(#pixelShaders == #pixelShaderNames, "Error, missing pixel shaders to compile")
    for pixelShaderIndex, shaderData in pairs(pixelShaders) do
        local shaderName = shaderData[1]
        log("Shader: " .. shaderName)
        local shaders = shaderData[2]
        shadersFile:write(wuint32(#shaderName))
        shadersFile:write(shaderName)
        shadersFile:write(wuint32(#table.keys(shaders)))
        for shaderFunctionIndex, shaderData in pairs(shaders) do
            local shaderFunctionName = shaderData[1]
            log("Function " .. shaderFunctionIndex .. ": " .. shaderFunctionName)
            local byteCode = shaderData[2]
            shadersFile:write(wuint32(#shaderFunctionName))
            shadersFile:write(shaderFunctionName)
            shadersFile:write(wuint32(#byteCode / 4))
            shadersFile:write(byteCode)
        end
        log("-")
    end
else
    assert(#vertexShaders == #vertexShaderNames, "Error, missing vertex shaders to compile")
    for vertexShaderIndex, byteCode in ipairs(vertexShaders) do
        -- print(vertexShaderNames[vertexShaderIndex] or "unknown", vertexShaderIndex)
        shadersFile:write(wuint32(#byteCode))
        shadersFile:write(byteCode)
    end
end

shadersFile:seek("set", 1)
shadersFile:close()
shadersFile = io.open(shadersOutputFilePath, "rw+b")
local checksum = glue.string.tohex(md5.sum(shadersFile:read("a")))
shadersFile:write(checksum)
shadersFile:write("\0")
shadersFile:close()
print(("SUCCESS - \"%s\" - MD5SUM: " .. checksum):format(shadersFileName))
if args.verifystock then
    if checksum ~= "d699e3afb32d2c8361a4a69b5d45b7b3" then
        print("Error, checksum does not match for original shaders!")
    end
end
if args.encrypt then
    os.execute(binaries.encrypt .. " " .. shadersOutputFilePath)
end
