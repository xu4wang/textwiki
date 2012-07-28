-- This is an moidifed version of exman.lua by Austin Wang (xu4wang@gmail.com)
-- Extman is a Lua script manager for SciTE. It enables multiple scripts to capture standard events
-- without interfering with each other. For instance, scite_OnDoubleClick() will register handlers
-- for scripts that need to know when a double-click event has happened. (To know whether it
-- was in the output or editor pane, just test editor.Focus).  It provides a useful function scite_Command
-- which allows you to define new commands without messing around with property files (see the
-- examples in the scite_lua directory.) 
-- extman defines three new convenience handlers as well:
--scite_OnWord (called when user has entered a word)
--scite_OnEditorLine (called when a line is entered into the editor)
--scite_OnOutputLine (called when a line is entered into the output pane)
local _MarginClick,_DoubleClick,_SavePointLeft = {},{},{}
local _SavePointReached,_Open,_SwitchFile = {},{},{}
local _BeforeSave,_Save,_Char = {},{},{}
local _Word,_LineEd,_LineOut = {},{},{}
local _OpenSwitch = {}
local _UpdateUI = {}
local _UserListSelection
local _remove = {}
local append = table.insert
local find = string.find
local size = table.getn
local sub = string.sub
local gsub = string.gsub

function OnUserListSelection(tp,str)
  if _UserListSelection then 
     local callback = _UserListSelection 
     _UserListSelection = nil
     return callback(str)
  else return false end
end

local function DispatchOne(handlers,arg)
  for i,handler in pairs(handlers) do
    local fn = handler
    if _remove[fn] then
        handlers[i] = nil
       _remove[fn] = nil
    end
    local ret = fn(arg)
    if ret then return ret end
  end
  return false
end

-- these are the standard SciTE Lua callbacks  - we use them to call installed extman handlers!
function OnMarginClick()
  return DispatchOne(_MarginClick)
end

function OnDoubleClick()
  return DispatchOne(_DoubleClick)
end

function OnSavePointLeft()
  return DispatchOne(_SavePointLeft)
end

function OnSavePointReached()
  return DispatchOne(_SavePointReached)
end

function OnChar(ch)
  return DispatchOne(_Char,ch)
end

function OnSave(file)
  return DispatchOne(_Save,file)
end

function OnBeforeSave(file)
  return DispatchOne(_BeforeSave,file)
end

function OnSwitchFile(file)
  return DispatchOne(_SwitchFile,file)
end

function OnOpen(file)
  return DispatchOne(_Open,file)
end

function OnUpdateUI()
  if editor.Focus then
     return DispatchOne(_UpdateUI)
  else
     return false
  end
end

-- may optionally ask that this handler be immediately
-- removed after it's called
local function append_unique(tbl,fn,remove)
  local once_only
  if type(fn) == 'string' then
     once_only = fn == 'once'
     fn = remove
     remove = nil
     if once_only then _remove[fn] = fn end
  else
    _remove[fn] = nil
  end
  local idx 
  for i,handler in pairs(tbl) do
     if handler == fn then idx = i; break end
  end
  if idx then
    if remove then
      table.remove(tbl,idx)
    end
  else
    if not remove then
      append(tbl,fn)
    end
  end        
end

-- this is how you register your own handlers with extman
function scite_OnMarginClick(fn,remove)
  append_unique(_MarginClick,fn,remove)
end

function scite_OnDoubleClick(fn,remove)
  append_unique(_DoubleClick,fn,remove)
end

function scite_OnSavePointLeft(fn,remove)
  append_unique(_SavePointLeft,fn,remove)
end

function scite_OnSavePointReached(fn,remove)
  append_unique(_SavePointReached,fn,remove)
end

function scite_OnOpen(fn,remove)
  append_unique(_Open,fn,remove)
end

function scite_OnSwitchFile(fn,remove)
  append_unique(_SwitchFile,fn,remove)
end

function scite_OnBeforeSave(fn,remove)
  append_unique(_BeforeSave,fn,remove)
end

function scite_OnSave(fn,remove)
  append_unique(_Save,fn,remove)
end

function scite_OnUpdateUI(fn,remove)
  append_unique(_UpdateUI,fn,remove)
end

function scite_OnChar(fn,remove)
  append_unique(_Char,fn,remove)  
end

function scite_OnOpenSwitch(fn,remove)
  append_unique(_OpenSwitch,fn,remove)
end

local function buffer_switch(f)
--- OnOpen() is also called if we move to a new folder
   if not find(f,'[\\/]$') then
      DispatchOne(_OpenSwitch,f)
   end
end

scite_OnOpen(buffer_switch)
scite_OnSwitchFile(buffer_switch)

local next_user_id = 13 -- arbitrary

-- the handler is always reset!
function scite_UserListShow(list,start,fn)
  local s = ''
  local sep = ';'
  local n = size(list)
  for i = start,n-1 do
      s = s..list[i]..sep
  end
  s = s..list[n]
  _UserListSelection = fn
  local pane = editor
  if not pane.Focus then pane = output end
  pane.AutoCSeparator = string.byte(sep)
  pane:UserListShow(next_user_id,s)
  pane.AutoCSeparator = string.byte(' ')
end

 local word_start,in_word,current_word

 local function on_word_char(s)
     if not in_word then
        if find(s,'%w') then 
      -- we have hit a word!
         word_start = editor.CurrentPos
         in_word = true
         current_word = s
      end
    else -- we're in a word
   -- and it's another word character, so collect
     if find(s,'%w') then   
       current_word = current_word..s
     else
       -- leaving a word; call the handler
       local word_end = editor.CurrentPos
       DispatchOne(_Word, {word=current_word,
               startp=word_start,endp=editor.CurrentPos,
               ch = s
            })     
       in_word = false
     end   
    end 
  -- don't interfere with usual processing!
    return false
  end  

function scite_OnWord(fn,remove)
  append_unique(_Word,fn,remove)   
  if not remove then
     scite_OnChar(on_word_char)
  else
     scite_OnChar(on_word_char,'remove')
  end
end

local last_pos = 0

local function grab_line_from(pane)
        local line_pos = pane.CurrentPos
        local lineno = pane:LineFromPosition(line_pos)-1
        -- strip linefeeds (Windows is a special case as usual!)
        local endl = 2
        if scite_GetProp('PLAT_WIN') then endl = 3 end
        local line = string.sub(pane:GetLine(lineno),1,-endl)
        return line
end

local function on_line_char(ch,result)
  if ch == '\n' or ch == '\r' then
       if ch == '\n' then
       if editor.Focus then
   	        DispatchOne(_LineEd,grab_line_from(editor))
       else
   	        DispatchOne(_LineOut,grab_line_from(output))
      end
      return result
      end
  end
  return false
end

local function on_line_editor_char(ch)
  return on_line_char(ch,false)
end

local function on_line_output_char(ch)
  return on_line_char(ch,true)
end

local function set_line_handler(fn,rem,handler,on_char)
  append_unique(handler,fn,rem)   
  if not rem then
     scite_OnChar(on_char)
  else
     scite_OnChar(on_char,'remove')
  end
end

function scite_OnEditorLine(fn,rem)
  set_line_handler(fn,rem,_LineEd,on_line_editor_char)  
end
 
function scite_OnOutputLine(fn,rem)
  set_line_handler(fn,rem,_LineOut,on_line_output_char)
end

function scite_GetProp(key,default)
   local val = props[key]
   if val and val ~= '' then return val 
   else return default end
end  

local GTK = scite_GetProp('PLAT_GTK')
local default_path
local tmpfile
if GTK then
	default_path = props['SciteUserHome']
	tmpfile = '/tmp/.scite-temp-files'
else
	default_path = props['SciteDefaultHome']
	tmpfile = '\\scite_temp1'
end

function scite_Files(mask)
  local f,path
  if  GTK then
--    f = io.popen('ls -1 '..mask)
	os.execute('ls -1 '..mask..' > '..tmpfile)
	f = io.open(tmpfile)
    path = ''
  else
    mask = gsub(mask,'/','\\')
    _,_,path = find(mask,'(.*\\)')
    local cmd = 'dir /b "'..mask..'" > '..tmpfile
    if Execute then -- scite_other was found!
       Execute(cmd)
    else
      os.execute(cmd)
    end
    f = io.open(tmpfile)
  end
  local files = {}
  if not f then return files end
  for line in f:lines() do
     append(files,path..line)
  end
  f:close()
  return files
end

function scite_FileExists(f)
  local f = io.open(f)
  if not f then return false
  else
    f:close()
    return true
  end
end

function scite_CurrentFile()
	return props['FilePath']
end

function scite_WordAtPos(pos)
	if not pos then pos = editor.CurrentPos end
	local p2 = editor:WordEndPosition(pos,true)
	local p1 = editor:WordStartPosition(pos,true)
	return editor:textrange(p1,p2)
end

-- allows you to bind given Lua functions to shortcut keys
-- without messing around in the properties files!

function split(s,delim)
	res = {}
	while true do
		p = find(s,delim)
		if not p then
			append(res,s)
			return res 
		end
		append(res,sub(s,1,p-1))
		s = sub(s,p+1)
	end
end

function splitv(s,delim)
	return unpack(split(s,delim))
end

local idx = 10
local shortcuts_used = {}

function scite_Command(tbl)
  if type(tbl) == 'string' then
     tbl = {tbl}
  end
  for i,v in pairs(tbl) do
     local name,cmd,mode,shortcut = splitv(v,'|')
	 if not shortcut then
        shortcut = mode
		mode = '.*'
     else
		mode = '.'..mode
     end
	 -- has this command been defined before?
	 local old_idx = 0
	 for ii = 10,idx do
	    if props['command.name.'..ii..mode] == name then old_idx = ii end
	 end
	 if old_idx == 0 then	 
		 local which = '.'..idx..mode
		 props['command.name'..which] = name
		 props['command'..which] = cmd     
		 props['command.subsystem'..which] = '3'
		 props['command.mode'..which] = 'savebefore:no'
		 if shortcut then 
		   local cmd = shortcuts_used[shortcut]
		   if cmd then
			  print('Error: shortcut already used in "'..cmd..'"')
		   else
		  --   print(name,cmd,shortcut)
			 props['command.shortcut'..which] = shortcut
			 shortcuts_used[shortcut] = name
		   end
		 end
		 idx = idx + 1
    end
  end
end

-- this will quietly fail....

local loaded = {}
local function silent_dofile(f)
 if scite_FileExists(f) then
  --f = gsub(f,'\\','/')
  if not loaded[f] then
    dofile(f)
    loaded[f] = true
  else
    print('already loaded',f)
  end
 end
end

function scite_dofile(f)
 f = default_path..'/'..f
 silent_dofile(f)
end

local path
local lua_dir = scite_GetProp('ext.lua.directory')
if lua_dir then
  path = lua_dir 
else
  path = default_path..'/scite_lua'
end

function scite_require(f)
  f = path..'/'..f
  silent_dofile(f)
end

if not GTK then
   scite_dofile 'scite_other.lua'
end


--~ local script_list = scite_Files(path..'/*.lua')

--~ if not script_list then 
--~   print('Error: no files found in '..path)
--~ else
--~   for i,file in pairs(script_list) do
--~     silent_dofile(file)
--~   end
--~ end

scite_Command 'Reload Script|reload_script|Shift+Ctrl+R'

function reload_script()
   current_file = scite_CurrentFile()
   print('Reloading... '..current_file)
   loaded[current_file] = false
   silent_dofile(current_file)
end

---------------------------------------Prompt.lua-------------------------
 scite_Command('Last Command|do_command_list|Ctrl+Alt+P')

 local prompt = '> '
 local history_len = 4
 local prompt_len = string.len(prompt)
 print 'Scite/Lua'
 trace(prompt)

 function load(file)
	if not file then file = props['FilePath'] end
	dofile(file)
 end

 function edit(file)
	scite.Open(file)
 end

 local sub = string.sub
 local commands = {}

 local function strip_prompt(line)
   if sub(line,1,prompt_len) == prompt then
        line = sub(line,prompt_len+1)
    end	
	return line
 end

-- obviously table.concat is much more efficient, but requires that the table values
-- be strings.
function join(tbl,delim,start,finish)
	local n = table.getn(tbl)
	local res = ''
	-- this is a hack to work out if a table is 'list-like' or 'map-like'
	local index1 = n > 0 and tbl[1]
	local index2 = n > 1 and tbl[2]
	if index1 and index2 then
		for i,v in ipairs(tbl) do
			res = res..delim..tostring(v)
		end
	else
		for i,v in pairs(tbl) do
			res = res..delim..tostring(i)..'='..tostring(v)
		end
	end
	return string.sub(res,2)
end

function pretty_print(...)
	for i,val in ipairs(arg) do
	if type(val) == 'table' then
		print('{'..join(val,',',1,20)..'}')
	elseif type(val) == 'string' then
		print("'"..val.."'")
	else
		print(val)
	end
	end
end
  
 scite_OnOutputLine (function (line)
	line = strip_prompt(line)
   table.insert(commands,1,line)
    if table.getn(commands) > history_len then
        table.remove(commands,history_len+1)
    end
    if sub(line,1,1) == '=' then
        line = 'pretty_print('..sub(line,2)..')'
    end    
    local f,err = loadstring(line,'local')
    if not f then 
      print(err)
    else
      local ok,res = pcall(f)
      if ok then
         if res then print('result= '..res) end
      else
         print(res)
      end      
    end
    trace(prompt)
    return true
end)

function insert_command(cmd)
	output:AppendText(cmd)
	output:GotoPos(output.Length)
end

function do_command_list()
     scite_UserListShow(commands,1,insert_command)
end

--------------------------------------------------------------File naviagting -------------------------------------

HOME_DOCUMENT="D:\\wangxu\\wiki\\data\\home.yml"
HOME_PATH="D:\\wangxu\\wiki\\data\\"
DOC_EXT=".yml"
SEC_DOC_EXT=".syml"
LUA_EXT=".lua"

scite_Command 'Open Doc|open_doc|F1'
scite_Command 'Create Doc|create_doc|Ctrl+F1'
scite_Command 'Create Encrypt Doc|create_sec_doc|Shift+Ctrl+F1'
scite_Command 'Open Home|open_home|F2'
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


---------------------------------------------------------------Security  --------------------------------------------


ENCMAGIC = 'SAYAML\r\n'

function need_encode()
    local file_name = props['FilePath']
    if string.len(file_name) > 4 then
      if string.upper(string.sub(file_name,-4)) == 'SYML' then
        return true
      end
    end
    return false
end


function is_encoded(i_str)
  if string.len(i_str)<8 then
    return false
  else
    local token = string.sub(i_str,0,8)
    if token == ENCMAGIC then
      return true
    end
    return false
  end
end

function enc(i_str)
  if (is_encoded(i_str)) then
    return i_str
  else
    return ENCMAGIC..i_str
  end
end

function dec(i_str)
  if (is_encoded(i_str)) then
    return string.sub(i_str,9)
  else
    return i_str
  end
end

--encode buffer
function enc_current_buffer()
  local buf = editor:GetText()
  if buf == nil then
    return
  end
  local p = editor.CurrentPos
  --print("enc  pos ="..p)
  editor:SetText(enc(buf))
  editor:SetSavePoint()    --unmodified
  editor:GotoPos(p)
end

--decode buffer
function dec_current_buffer()
  local buf = editor:GetText()
  if buf == nil then
    return
  end
  local p = editor.CurrentPos
  --print("dec  pos ="..p)
  editor:SetText(dec(buf))
  editor:SetSavePoint()    --unmodified
  editor:GotoPos(p)
end 

scite_OnBeforeSave( function (file)
  --print("OnBeforeSave"..file)
  if need_encode() then
    enc_current_buffer()
  end
end)

scite_OnSave(function(file)
  --print("OnSave"..file)
  if need_encode() then
	dec_current_buffer()
  end
end)

scite_OnOpen(function (file)
  --print("OnOpen"..file)
  --print("Content:  "..editor:GetText() )
  if need_encode() then
	dec_current_buffer()
  end
end)
