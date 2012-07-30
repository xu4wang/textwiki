
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
