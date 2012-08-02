
HOME_DOCUMENT="D:\\wangxu\\wiki\\data\\home.yml"
HOME_PATH="D:\\wangxu\\wiki\\data\\"
DOC_EXT=".yml"
SEC_DOC_EXT=".syml"
LUA_EXT=".lua"

scite_Command 'Open Doc|open_doc|F1'
scite_Command 'Create Doc|create_doc|Ctrl+F1'
scite_Command 'Create Encrypt Doc|create_sec_doc|Shift+Ctrl+F1'
scite_Command 'Open Home|open_home|F2'
scite_Command 'Explore Folder|explore_folder|Ctrl+F2'
scite_Command 'Execute Command|run_cmd|Ctrl+E'
scite_Command 'Execute Lua File|run_lua|Shift+Ctrl+E'

function isWordChar(char)
    local strChar = string.char(char)
    local beginIndex = string.find(strChar, '%w')
    if beginIndex ~= nil then
        return true
    end
    if strChar == '_' or strChar == '$' then
        return true
    end    
    return false
end

function GetCurrentWord()
    local beginPos = editor.CurrentPos
    local endPos = beginPos
    if editor.SelectionStart ~= editor.SelectionEnd then
        return editor:GetSelText()
    end
    while isWordChar(editor.CharAt[beginPos-1]) do
        beginPos = beginPos - 1
    end
    while isWordChar(editor.CharAt[endPos]) do
        endPos = endPos + 1
    end
    return editor:textrange(beginPos,endPos)
end

function run_cmd()
	local filename=strip_word(GetCurrentWord())
    --filename = filename
    os.execute(filename)
end

function run_lua()
	local filename=strip_word(GetCurrentWord())
    filename = HOME_PATH..filename..LUA_EXT
    dofile(filename)
end

function strip_word(word)
     return string.gsub(word, "[\r\n]+$", "")
end

function open_home()
	--print"calling open home"
	scite.Open(HOME_DOCUMENT)
end

function create_doc_with_name(filename)
	if not scite_FileExists(filename) then
		--create document
		local fd = io.open(filename,"w")
		fd:close()
	end
end

function create_doc()
	--print"calling create doc"
	local filename=strip_word(GetCurrentWord())
	filename = HOME_PATH..filename..DOC_EXT
	create_doc_with_name(filename)
	scite.Open(filename)
end

function create_sec_doc()
	--print"calling create sec doc"
	local filename=strip_word(GetCurrentWord())
	filename = HOME_PATH..filename..SEC_DOC_EXT
	create_doc_with_name(filename)
	scite.Open(filename)
end

function open_doc()
	--print"calling open DOC"
	local filename=strip_word(GetCurrentWord())
    local filename_s = HOME_PATH..filename..SEC_DOC_EXT
	local filename = HOME_PATH..filename..DOC_EXT
	if scite_FileExists(filename) then
		scite.Open(filename)
		return
	end
	if scite_FileExists(filename_s) then
		scite.Open(filename_s)
		return
	end
	print(filename.." not found!")
end

function explore_folder()
		 local file_name = props['FilePath']
		 local path = dirname(file_name)
		 os.execute("start explorer "..path)
end
