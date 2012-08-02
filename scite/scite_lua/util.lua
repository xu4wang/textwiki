function dirname(path)
	while true do
		if path == "" or string.sub(path, -1) == "\\" then
			break
		end
		path = string.sub(path, 1, -2)
	end
	if path == "" then
		path = "C:\\"
	end
	return path
end

function stripchars( str, chr )
    local s = ""
    for g in str:gmatch( "[^"..chr.."]" ) do
 	s = s .. g
    end
    return s
end
 
function strip_white(str)
	local chr = " \t\r\n"
	return stripchars( str, chr);
end
