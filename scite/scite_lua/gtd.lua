scite_Command 'Toggle MISC|gtd_fold|Ctrl+F12'


function gtd_dbg(str)
		print("DGB:"..str)
end

function gtd_fold() 
		local line_num = 0	
		local line,line_chars = editor:GetLine(line_num) 
		while line_chars ~= nil do
				line = strip_white(line)
				if line=="MISC" then
						if editor.LineVisible[line_num]  then
								editor:ToggleFold(line_num)
						end
				end
				line_num=line_num+1
				line, line_chars=editor:GetLine(line_num) 
		end
end