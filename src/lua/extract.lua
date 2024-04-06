local luna = require "src.lua.lua_modules.luna"
local argparse = require "argparse"
local constants = require "src.lua.constants"
local inspect = require "inspect"
local fs = require "fs"
require "compat53"
local vertexShaderNames = constants.vertexShaderNames
require "src.lua.censhine.binary"

local parser = argparse("extract", "Extract shaders from dec files")
parser:argument("shadersFilePath", "Path to the binary shaders file")
parser:flag("--decrypt", "Decrypt shader prior to extraction")
parser:flag("--decompile", "Allow shader decompilation for debugging")
parser:flag("--vertex", "Decompile shader as vertex shaders")
parser:flag("--keepversion", "Keep shader version in output")
parser:flag("--preparebuild", "Prepare build folder with extracted shaders")
local args = parser:parse()

args.shadersFilePath = args.shadersFilePath:replace("\\", "/")
local shadersFile = io.open(args.shadersFilePath, "rb")
if args.decrypt then
    local decryptCmdTemplate = constants.commands.decrypt
    local decryptedFilePath = args.shadersFilePath:replace(".enc", ".dec")
    local decryptCmd = decryptCmdTemplate:format(args.shadersFilePath, decryptedFilePath)
    assert(os.execute(decryptCmd), "Could not decrypt file")
    shadersFile = io.open(decryptedFilePath, "rb")
end

local fileString = luna.binary.read(args.shadersFilePath)
assert(fileString, "Could not read shaders file: " .. args.shadersFilePath)
local shaderFileSize = #fileString
local vertexShaderCount = 1
-- https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-part1
local outputExtension = constants.extensions.compiledShaderObject
local pixelShaderNames = {}
local pixelShaderFunctionNames = {}

assert(shadersFile, "Could not open file " .. args.shadersFilePath)
if shadersFile then
    local splitPath = args.shadersFilePath:split "/"
    local shadersFileName = splitPath[#splitPath]:split(".")[1]
    local dumpPath = "dump/shaders/" .. shadersFileName .. "/"
    if args.preparebuild then
        dumpPath = "build/" .. shadersFileName .. "/"
        if not fs.is(dumpPath) then
            fs.mkdir(dumpPath, true)
        end
        assert(fs.is(dumpPath), "Could not create build folder")
    end

    if not args.vertex then
        -- Skip version file
        shadersFile:seek("set", 4)
    end

    local function extractPixelShaders()
        -- print("cursor", string.tohex(shaderContent:seek()))
        local shaderNameSize = uint32(shadersFile:read(4))
        local shaderName = shadersFile:read(shaderNameSize)
        local shaderCount = uint32(shadersFile:read(4))
        local shaderPath = dumpPath .. "/" .. shaderName
        print("Shader: " .. shaderName)
        print("Functions: " .. shaderCount)
        assert(fs.mkdir(shaderPath, true), "Could not create shader folder")
        pixelShaderFunctionNames[shaderName] = {}
        for shaderIndex = 1, shaderCount do
            -- Get shader function name and shader size
            local pixelShaderFunctionNameSize = uint32(shadersFile:read(4))
            local pixelShaderFunctionName = shadersFile:read(pixelShaderFunctionNameSize)
            local pixelShaderSize = uint32(shadersFile:read(4)) * 4
            print(pixelShaderFunctionName .. " (" .. pixelShaderSize .. " bytes)")

            -- Get shader version components
            local splitName = pixelShaderFunctionName:split "_"
            local minorVersion = splitName[#splitName]
            local majorVersion = splitName[#splitName - 1]

            -- Build shader stripped names
            local pixelShaderVersionIdentifier = ("_ps_%s_%s"):format(majorVersion, minorVersion)
            local functionName = pixelShaderFunctionName:gsub("PS_", ""):gsub(
                                     pixelShaderVersionIdentifier, "")
            local pixelShaderFunctionNameNoVersion = "PS_" .. functionName

            -- Save shader index of the original file
            pixelShaderFunctionNames[shaderName][functionName] = shaderIndex

            -- Read shader byte code and save it to a file
            local pixelShaderVersion = uint32(shadersFile:read(4))
            local directX9ByteCode = shadersFile:read(pixelShaderSize - 4)
            local shader = {wuint32(pixelShaderVersion), directX9ByteCode}
            local shaderFinalPath = shaderPath .. "/" .. pixelShaderFunctionNameNoVersion ..
                                        outputExtension
            if args.keepversion then
                shaderFinalPath = shaderPath .. "/" .. pixelShaderFunctionName .. outputExtension
            end
            luna.binary.write(shaderFinalPath, table.concat(shader, ""))
            if args.decompile then
                os.execute(constants.commands.dissamble:format(shaderFinalPath,
                                                               shaderFinalPath .. ".debug"))
            end
        end
        print(
            "--------------------------------------------------------------------------------------------------------------")
    end

    local function extractVertexShaders()
        -- print("cursor", string.tohex(shaderContent:seek()))
        local byteCodeSize = uint32(shadersFile:read(4))
        local shaderName = vertexShaderNames[vertexShaderCount] or ("vsh_" .. vertexShaderCount)
        print("Shader name: " .. shaderName, "Size: " .. byteCodeSize)

        local pixelShaderVersion = uint32(shadersFile:read(4))
        local directX9ByteCode = shadersFile:read(byteCodeSize - 4)
        local shader = {wuint32(pixelShaderVersion), directX9ByteCode}
        local shaderFinalPath = dumpPath .. shaderName .. outputExtension
        print(shaderFinalPath)
        luna.binary.write(shaderFinalPath, table.concat(shader, ""))

        if args.decompile then
            os.execute(constants.commands.dissamble:format(shaderFinalPath,
                                                           shaderFinalPath .. ".debug"))
        end

        vertexShaderCount = vertexShaderCount + 1
    end
    -- Not sure about this 66, needs checking
    while shadersFile:seek() < shaderFileSize - 66 do
        if args.vertex then
            extractVertexShaders()
        else
            extractPixelShaders()
        end
    end
    print("Checksum: ", shadersFile:read(32))
    shadersFile:close()
end
-- print(inspect(pixelShaderNames))
-- print(inspect(pixelShaderFunctionNames))
