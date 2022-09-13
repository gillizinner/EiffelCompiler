note
	description: "targil1_original application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS

create
	make

feature {NONE} -- Initialization  constoctor

 make -- Run application.
 do
 Io.read_line
 scannning(Io.last_string)
 end
feature
 scannning(s: STRING)

       local
       counter:INTEGER
	   numOfVms:INTEGER
       directory :DIRECTORY
       --p: STRING
       i:INTEGER
       b:BOOLEAN
       vm_file:PLAIN_TEXT_FILE
       SimpleAdd:PLAIN_TEXT_FILE
       libraryName:STRING
       temp:STRING
       c:CHARACTER
       do
       		counter := 0
			numOfVms:=0
            --p:="C:\Users\giliz\Downloads\sql (1)\sql"
            --create directory.make_open_read(p)
            create directory.make_open_read(s)
            --directory.readentry

            --if attached directory.last_entry_32 as p2 then
				--create vm_file.make_open_read_append(s+"\"+p2.as_string_32)
				--create SimpleAdd.make_open_read_append (s+p2.as_string_32)
				--determineCmd(vm_file,SimpleAdd,p2.as_string_32)
				--vm_file.close
				--vm_file.putstring (counter.out)

			 --end
            --temp=s.mirror
            -- from
            --  i := 1
          	--until
             -- i> s.count
          	--loop
          	--	c:=temp.at(i)
          	  --  if attached c as CurrentChar then
          		--	if(CurrentChar/="\") then
            	--	libraryName.append (CurrentChar)
            	--	end
            --	end

            --end
            from --counting how many vms in this library
              i := 1
          	until
              i>directory.count
          	loop
          		directory.readentry
          	  if attached directory.last_entry_32 as p2 then
				if(p2.ends_with (".vm")=true) then
				 numOfVms:=numOfVms+1
				end
			  end
				i:=i+1
            end
            create SimpleAdd.make_open_read_append (s+"\FibonacciElement.asm")
            
            directory.start
            from
              i := 1
          	until
              i>directory.count
          	loop
          	  directory.readentry
          	  if attached directory.last_entry_32 as p2 then
				if(p2.ends_with (".vm")=true)
				then b:=true
				else b:=false
				end
			  end
			  if(b=true)
          	  then
          	  if attached directory.last_entry_32 as p2 then
				create vm_file.make_open_read_append(s+"\"+p2.as_string_32)
				determineCmd(vm_file,SimpleAdd,p2.as_string_32)
				vm_file.close
				--vm_file.putstring (counter.out)

			  end
          	  counter := counter + 1
          	  i:= i + 1
          	  else
              i := i + 1
              end
          	end
          	SimpleAdd.close
          	--create vm_file.make_open_read_append(s+"\hello.vm")
          	--createAsm(vm_file,s)
       end

feature
 determineCmd(sourceVMFile: PLAIN_TEXT_FILE;SimpleAdd:PLAIN_TEXT_FILE;VmName:STRING)
 local
 	cmd:STRING
 	segment: STRING
 	index:STRING
 	temp:CHARACTER
 	funcName:STRING
 	numOfArgs:STRING
 	numOfLocalVar:STRING
 	labelName:STRING
 	labelCounter:INTEGER
 	stringArray:LIST[attached STRING]
 do
	labelCounter:= 1
 	--create SimpleAdd.make_open_read_append (s+"\SimpleAdd.asm")--creating the output asm file
 	from
    sourceVMFile.start
    until
    sourceVMFile.end_of_file=true --as long as we didnt get to the end of file
    loop

    	sourceVMFile.readline
    	temp:=' '
    	--stringArray:=sourceVMFile.laststring.split (temp)
    	--funcName:=stringArray[1]
    	--numOfArgs:=stringArray[2]
    	--numOfLocalVar:=stringArray[2]
    	--sourceVMFile.laststring.
    	--temp:=sourceVMFile.last_string
    	--cmd:=temp.remove_head(4)
    	--sourceVMFile.read_word
    	--cmd:=sourceVMFile.last_string
    	--if( sourceVMFile.last_string.starts_with ("//") ) then sourceVMFile.next_line  end
    	if( sourceVMFile.last_string.starts_with ( "neg" )) then HandleNegCommand(SimpleAdd)end
    	if( sourceVMFile.last_string.starts_with("eq")) then HandleEqCommand(SimpleAdd,labelCounter.out) labelCounter:=labelCounter+1 end
    	if( sourceVMFile.last_string.starts_with ("gt" )) then HandleGtCommand(SimpleAdd,labelCounter.out)labelCounter:=labelCounter+1 end
    	if(sourceVMFile.last_string.starts_with ("lt") ) then HandleLtCommand(SimpleAdd,labelCounter.out) labelCounter:=labelCounter+1 end
    	if( sourceVMFile.last_string.starts_with ( "and" )) then HandleAndCommand(SimpleAdd)end
    	if( sourceVMFile.last_string.starts_with ("or") ) then HandleOrCommand(SimpleAdd)end
    	if( sourceVMFile.last_string.starts_with ("not") ) then HandleNotCommand(SimpleAdd)end
    	if( sourceVMFile.last_string.starts_with ("push") ) then sourceVMFile.last_string.remove_head (4)
    							--sourceVMFile.last_string.split (' ').
    							--segment:=sourceVMFile.last_string
    							--sourceVMFile.read_word
    							--index:=sourceVMFile.last_string
    							HandlePushCommand(sourceVMFile.last_string,SimpleAdd,VmName)
    							end
    	if(sourceVMFile.last_string.starts_with ( "pop") ) then sourceVMFile.last_string.remove_head (3)
    							--segment:=sourceVMFile.last_string
    							--sourceVMFile.read_word
    							--index:=sourceVMFile.last_string
    							HandlePopCommand(sourceVMFile.last_string,SimpleAdd,VmName)
    							end
    	if( sourceVMFile.last_string.starts_with ("add" )) then HandleAddCommand(SimpleAdd)end
    	if( sourceVMFile.last_string.starts_with ("sub" )) then HandleSubCommand(SimpleAdd)end

    	--hello.readline
    	--hello.next_line
    	--helloAsm.putstring(hello.last_string)
    	--helloAsm.new_line
    end
    --printAsm(helloAsm)
end
 feature
 	HandleNegCommand(SimpleAdd:PLAIN_TEXT_FILE)
 do
	SimpleAdd.putstring("@SP%N"+"A=M-1%N"+"D=M%N"+"M=-D%N")
    SimpleAdd.new_line

 end

 feature
 	HandleEqCommand(SimpleAdd:PLAIN_TEXT_FILE;labelCounter:STRING)
 do
	--SimpleAdd.putstring("@SP%N"+"A=M-1%N"+"D=M%N"+"A=A-1%N"+"D=D-M%N"+"@IF_TRUE0%N"+"D;JEQ%N"+"D=0%N"+"@SP%N"+"A=M-1%N"+"A=A-1%N"+"M=D%N"+"@IF_FALSE0%N"+"0;JMP%N"+"(IF_TRUE0)%N"+"D=-1%N"+"@SP%N"+"A=M-1%N"+"A=A-1%N"+"M=D%N"+"(IF_FALSE0)%N"+"@SP%N"+"M=M-1%N")
    --SimpleAdd.putstring("0;JMP%N"+"(IF_TRUE0)%N"+"D=-1%N"+"@SP%N"+"A=M-1%N"+"A=A-1%N"+"M=D%N"+"(IF_FALSE0)%N"+"@SP%N"+"M=M-1%N")
    --SimpleAdd.putstring("@SP%N"+"M=M-1%N"+"@SP%N"+"A=M%N"+"D=M%N"+"@SP%N"+"M=M-1%N"+"@SP%N"+"A=M%N"+"A=M%N"+"D=D-A%N"+"@L1%N"+"D ; JEQ%N"+"@L2%N"+"D=0 ; JEQ%N"+"(L1)%N"+"D=-1%N"+"(L2)%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
   --SimpleAdd.putstring("@SP%N"+"M=M-1%N"+"@SP%N"+"A=M%N"+"D=A%N"+"@SP%N"+"M=M-1%N"+"@SP%N"+"A=M%N"+"D=D-A%N"+"@L1%N"+"D ; JEQ%N"+"@L2%N"+"D=0 ; JEQ%N"+"(L1)%N"+"D=-1%N"+"(L2)%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
   SimpleAdd.putstring("@SP%N"+"A=M-1%N"+"D=M%N"+"A=A-1%N"+"D=D-M%N"+"@IF_TRUE"+labelCounter+"%N"+"D;JEQ%N"+"D=0%N"+"@IF_FALSE"+labelCounter+"%N"+"0;JMP%N"+"(IF_TRUE"+labelCounter+")%N"+"D=-1%N"+"(IF_FALSE"+labelCounter+")%N"+"@SP%N"+"A=M-1%N"+"A=A-1%N"+"M=D%N"+"@SP%N"+"M=M-1%N")
   SimpleAdd.new_line
 end

 feature
 	HandleGtCommand(SimpleAdd:PLAIN_TEXT_FILE;labelCounter:STRING)
 do
    --SimpleAdd.putstring("@SP%N"+"M=M-1%N"+"@SP%N"+"A=M%N"+"D=M%N"+"@SP%N"+"M=M-1%N"+"@SP%N"+"A=M%N"+"A=M%N"+"D=A-D%N"+"@L1%N"+"D ; JGT%N"+"@L2%N"+"D=0 ; JEQ%N"+"(L1)%N"+"D=-1%N"+"(L2)%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
    SimpleAdd.putstring("@SP%N"+"A=M-1%N"+"D=M%N"+"A=A-1%N"+"D=D-M%N"+"@IF_TRUE"+labelCounter+"%N"+"D;JLT%N"+"D=0%N"+"@SP%N"+"A=M-1%N"+"A=A-1%N"+"M=D%N"+"@IF_FALSE"+labelCounter+"%N"+"0;JMP%N"+"(IF_TRUE"+labelCounter+")%N"+"D=-1%N"+"@SP%N"+"A=M-1%N"+"A=A-1%N"+"M=D%N"+"(IF_FALSE"+labelCounter+")%N"+"@SP%N"+"M=M-1%N")
    SimpleAdd.new_line
 end

 feature
 	HandleLtCommand(SimpleAdd:PLAIN_TEXT_FILE;labelCounter:STRING)
 do
    --SimpleAdd.putstring("@SP%N"+"M=M-1%N"+"@SP%N"+"A=M%N"+"D=M%N"+"@SP%N"+"M=M-1%N"+"@SP%N"+"A=M%N"+"A=M%N"+" D=D-A%N"+"@L1%N"+"D ; JGT%N"+"@L2%N"+"D=0 ; JEQ%N"+"(L1)%N"+"D=-1%N"+"(L2)%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
    SimpleAdd.putstring("@SP%N"+"A=M-1%N"+"D=M%N"+"A=A-1%N"+"D=D-M%N"+"@IF_TRUE"+labelCounter+"%N"+"D;JGT%N"+"D=0%N"+"@SP%N"+"A=M-1%N"+"A=A-1%N"+"M=D%N"+"@IF_FALSE"+labelCounter+"%N"+"0;JMP%N"+"(IF_TRUE"+labelCounter+")%N"+"D=-1%N"+"@SP%N"+"A=M-1%N"+"A=A-1%N"+"M=D%N"+"(IF_FALSE"+labelCounter+")%N"+"@SP%N"+"M=M-1%N")
    SimpleAdd.new_line
 end

 feature
 	HandleAndCommand(SimpleAdd:PLAIN_TEXT_FILE)
 do
	--SimpleAdd.putstring("@SP%N"+"M=M-1%N"+"@SP%N"+"A=M%N"+"D=M%N"+"@SP%N"+"M=M-1%N"+"@SP%N"+"A=M%N"+"A=M%N"+"D=D&A%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
    SimpleAdd.putstring("@SP%N"+"A=M-1%N"+"D=M%N"+"A=A-1%N"+"M=D&M%N"+"@SP%N"+"M=M-1%N")
    SimpleAdd.new_line
 end

 feature
 	HandleOrCommand(SimpleAdd:PLAIN_TEXT_FILE)
 do
	--SimpleAdd.putstring("@SP%N"+"M=M-1%N"+"@SP%N"+"A=M%N"+"D=M%N"+"@SP%N"+"M=M-1%N"+"@SP%N"+"A=M%N"+"A=M%N"+"D=D|A%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
    SimpleAdd.putstring("@SP%N"+"A=M-1%N"+"D=M%N"+"A=A-1%N"+"M=D|M%N"+"@SP%N"+"M=M-1%N")
    SimpleAdd.new_line
 end

 feature
 	HandleNotCommand(SimpleAdd:PLAIN_TEXT_FILE)
 do
     SimpleAdd.putstring("@SP%N"+"A=M-1%N"+"D=M%N"+"M=!D%N")
     SimpleAdd.new_line
 end

 feature
 	HandlePushCommand(lastString:STRING;SimpleAdd:PLAIN_TEXT_FILE;VmName:STRING)
local
	index:STRING
 do
	if( lastString.has_substring ("constant")) then lastString.remove_head (10)--without the space before and after
											  index:=lastString
											  HandlePushConstant(index,SimpleAdd)end
    if( lastString.has_substring ("argument") ) then lastString.remove_head (10)--without the space before and after
											  	index:=lastString
    											HandlePushArgument(index,SimpleAdd)end
    if( lastString.has_substring ("local") ) then
    										lastString.remove_head (7)--without the space before and after
											index:=lastString
    										HandlePushLocal(index,SimpleAdd)end
    if( lastString.has_substring ("this" )) then
    										lastString.remove_head (6)--without the space before and after
											index:=lastString
    										HandlePushThis(index,SimpleAdd)end
    if( lastString.has_substring ("that") ) then
    										lastString.remove_head (6)--without the space before and after
											index:=lastString
    										HandlePushThat(index,SimpleAdd)end
    if( lastString.has_substring ("static") ) then
    										lastString.remove_head (8)--without the space before and after
											index:=lastString
    										HandlePushStatic(index,SimpleAdd,VmName)end
    if(lastString.has_substring ("temp") ) then
    										lastString.remove_head (6)--without the space before and after
											index:=lastString
    										HandlePushTemp(index,SimpleAdd)end
    if( lastString.has_substring ("pointer") ) then
    											lastString.remove_head (9)--without the space before and after
												index:=lastString
    											HandlePushPointer(index,SimpleAdd)
    											--if(index="0") then
 												--SimpleAdd.putstring("@THIS%N"+"D=M%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
    											--SimpleAdd.new_line
    											--end
    											--if(index="1") then
    											--SimpleAdd.putstring("@THAT%N"+"D=M%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
    											--SimpleAdd.new_line
    											--end
    											end

 end

 feature
 	HandlePopCommand(lastString:STRING;SimpleAdd:PLAIN_TEXT_FILE;VmName:STRING)
 local
	index:STRING
 do
	if( lastString.has_substring ("constant")) then lastString.remove_head (10)--without the space before and after
											  index:=lastString
											  HandlePopConstant(index,SimpleAdd)end
    if( lastString.has_substring ("argument") ) then lastString.remove_head (10)--without the space before and after
											  	index:=lastString
    											HandlePopArgument(index,SimpleAdd)end
    if( lastString.has_substring ("local") ) then
    										lastString.remove_head (7)--without the space before and after
											index:=lastString
    										HandlePopLocal(index,SimpleAdd)end
    if( lastString.has_substring ("this" )) then
    										lastString.remove_head (6)--without the space before and after
											index:=lastString
    										HandlePopThis(index,SimpleAdd)end
    if( lastString.has_substring ("that") ) then
    										lastString.remove_head (6)--without the space before and after
											index:=lastString
    										HandlePopThat(index,SimpleAdd)end
    if( lastString.has_substring ("static") ) then
    										lastString.remove_head (8)--without the space before and after
											index:=lastString
    										HandlePopStatic(index,SimpleAdd,VmName)end
    if(lastString.has_substring ("temp") ) then
    										lastString.remove_head (6)--without the space before and after
											index:=lastString
    										HandlePopTemp(index,SimpleAdd)end
    if( lastString.has_substring ("pointer") ) then
    											lastString.remove_head (9)--without the space before and after
												index:=lastString
    											HandlePopPointer(index,SimpleAdd)
    											--if(index.same_string ("0")) then
 												--SimpleAdd.putstring("@SP%N"+"A=M-1%N"+"D=M%N"+"@THIS%N"+"M=D%N"+"@SP%N"+"M=M-1%N")
    											--SimpleAdd.new_line end
 												--if(index="1") then
 												--SimpleAdd.putstring("@SP%N"+"A=M-1%N"+"D=M%N"+"@THAT%N"+"M=D%N"+"@SP%N"+"M=M-1%N")
    											--SimpleAdd.new_line end
    											end

 end


 feature
 	HandleAddCommand(SimpleAdd:PLAIN_TEXT_FILE)
 do
 	SimpleAdd.putstring("@SP%N"+"A=M-1%N"+"D=M%N"+"A=A-1%N"+"M=D+M%N"+"@SP%N"+"M=M-1%N")
    SimpleAdd.new_line
 end

 feature
 	HandleSubCommand(SimpleAdd:PLAIN_TEXT_FILE)
 do
 	SimpleAdd.putstring("@SP%N"+"A=M-1%N"+"D=M%N"+"A=A-1%N"+"M=M-D%N"+"@SP%N"+"M=M-1%N")
    SimpleAdd.new_line
 end

 feature
 	HandlePushConstant(index:STRING;SimpleAdd:PLAIN_TEXT_FILE)
 do
 	SimpleAdd.putstring("@"+index+"%N"+"D=A%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
    SimpleAdd.new_line
 end

 feature
 	HandlePushArgument(index:STRING;SimpleAdd:PLAIN_TEXT_FILE)
 do
 	SimpleAdd.putstring("@"+index+"%N"+"D=A%N"+"@ARG%N"+"A=M+D%N"+"D=M%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
    SimpleAdd.new_line
 end

 feature
 	HandlePushLocal(index:STRING;SimpleAdd:PLAIN_TEXT_FILE)
 do
 	SimpleAdd.putstring("@"+index+"%N"+"D=A%N"+"@LCL%N"+"A=M+D%N"+"D=M%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
    SimpleAdd.new_line
 end

 feature
 	HandlePushThis(index:STRING;SimpleAdd:PLAIN_TEXT_FILE)
 do
 	SimpleAdd.putstring("@"+index+"%N"+"D=A%N"+"@THIS%N"+"A=M+D%N"+"D=M%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
    SimpleAdd.new_line
 end

 feature
 	HandlePushThat(index:STRING;SimpleAdd:PLAIN_TEXT_FILE)
 do
 	SimpleAdd.putstring("@"+index+"%N"+"D=A%N"+"@THAT%N"+"A=M+D%N"+"D=M%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
    SimpleAdd.new_line
 end

 feature--
 	HandlePushStatic(index:STRING;SimpleAdd:PLAIN_TEXT_FILE;VmName:STRING)
 do
 	SimpleAdd.putstring("@"+VmName+"."+index+"%N"+"D=M%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
    SimpleAdd.new_line
 end

 feature
 	HandlePushTemp(index:STRING;SimpleAdd:PLAIN_TEXT_FILE)
 do
 	SimpleAdd.putstring("@"+index+"%N"+"D=A%N"+"@5%N"+"A=A+D%N"+"D=M%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
    SimpleAdd.new_line
 end

feature
 	HandlePushPointer(index:STRING;SimpleAdd:PLAIN_TEXT_FILE)
 do
 	if(index.has_substring ("0")) then
 	--if(index.same_string ("0")) then \\original
 		SimpleAdd.putstring("@THIS%N"+"D=M%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
    	SimpleAdd.new_line
    	end
    --if(index.same_string ("1")) then \\original
    if(index.has_substring ("1")) then
    	SimpleAdd.putstring("@THAT%N"+"D=M%N"+"@SP%N"+"A=M%N"+"M=D%N"+"@SP%N"+"M=M+1%N")
    	SimpleAdd.new_line
    end
 end


 feature
 	HandlePopConstant(index:STRING;SimpleAdd:PLAIN_TEXT_FILE)
 do
 	SimpleAdd.putstring("@SP%N"+"M=M-1%N")
    SimpleAdd.new_line
 end

 feature
 	HandlePopArgument(index:STRING;SimpleAdd:PLAIN_TEXT_FILE)
 do
 	SimpleAdd.putstring("@SP%N"+"M=M-1%N"+"@"+index+"%N"+"D=A%N"+"@ARG%N"+"D=M+D%N"+"@R13%N"+"M=D%N"+"@SP%N"+"A=M%N"+"D=M%N"+"@R13%N"+"A=M%N"+"M=D%N")
    SimpleAdd.new_line
 end

 feature
 	HandlePopLocal(index:STRING;SimpleAdd:PLAIN_TEXT_FILE)
 do
 	SimpleAdd.putstring("@SP%N"+"M=M-1%N"+"@"+index+"%N"+"D=A%N"+"@LCL%N"+"D=M+D%N"+"@R13%N"+"M=D%N"+"@SP%N"+"A=M%N"+"D=M%N"+"@R13%N"+"A=M%N"+"M=D%N")
    SimpleAdd.new_line
 end

  feature
 	HandlePopThis(index:STRING;SimpleAdd:PLAIN_TEXT_FILE)
 do
 	SimpleAdd.putstring("@SP%N"+"M=M-1%N"+"@"+index+"%N"+"D=A%N"+"@THIS%N"+"D=M+D%N"+"@R13%N"+"M=D%N"+"@SP%N"+"A=M%N"+"D=M%N"+"@R13%N"+"A=M%N"+"M=D%N")
    SimpleAdd.new_line
 end

  feature
 	HandlePopThat(index:STRING;SimpleAdd:PLAIN_TEXT_FILE)
 do
 	SimpleAdd.putstring("@SP%N"+"M=M-1%N"+"@"+index+"%N"+"D=A%N"+"@THAT%N"+"D=M+D%N"+"@R13%N"+"M=D%N"+"@SP%N"+"A=M%N"+"D=M%N"+"@R13%N"+"A=M%N"+"M=D%N")
    SimpleAdd.new_line
 end

  feature--
 	HandlePopStatic(index:STRING;SimpleAdd:PLAIN_TEXT_FILE;VmName:STRING)

 do
 	SimpleAdd.putstring("@SP%N"+"M=M-1%N"+"A=M%N"+"D=M%N"+"@"+VmName+"."+index+"%N"+"M=D%N")
    SimpleAdd.new_line
 end

  feature
 	HandlePopTemp(index:STRING;SimpleAdd:PLAIN_TEXT_FILE)
 do
 	SimpleAdd.putstring("@SP%N"+"M=M-1%N"+"@"+index+"%N"+"D=A%N"+"@5%N"+"D=A+D%N"+"@R13%N"+"M=D%N"+"@SP%N"+"A=M%N"+"D=M%N"+"@R13%N"+"A=M%N"+"M=D%N")
    SimpleAdd.new_line
 end

 feature
 	HandlePopPointer(index:STRING;SimpleAdd:PLAIN_TEXT_FILE)
 do
 	if(index.has_substring ("0")) then
 	--if(index.same_string ("0")) then \\original
 	SimpleAdd.putstring("@SP%N"+"A=M-1%N"+"D=M%N"+"@THIS%N"+"M=D%N"+"@SP%N"+"M=M-1%N")
    SimpleAdd.new_line end
 	--if(index.same_string ("1")) then \\original
    if(index.has_substring ("1")) then
 	SimpleAdd.putstring("@SP%N"+"A=M-1%N"+"D=M%N"+"@THAT%N"+"M=D%N"+"@SP%N"+"M=M-1%N")
    SimpleAdd.new_line end
 end






 end


