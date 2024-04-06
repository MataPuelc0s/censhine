function byte(input)
    return string.unpack("B", input)
end

function wbyte(input)
    return string.pack("B", input)
end

function uint16(input)
    return string.unpack("H", input)
end

function wuint16(input)
    return string.pack("H", input)
end

function uint32(input)
    return string.unpack("I", input)
end

function wuint32(input)
    return string.pack("I", input)
end
