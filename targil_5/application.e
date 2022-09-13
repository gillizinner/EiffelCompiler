note
	description: "targil_5 application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS

create
	make

feature {NONE} -- Initialization
	argumentCount:INTEGER
 	localCount:INTEGER
 	fieldCount:INTEGER
	rowIndex:INTEGER--table row index
 	columnIndex:INTEGER--table column index
 	funcRowIndex:INTEGER--func table row index
 	funcColumnIndex:INTEGER--func table column index
 	symbolTableFunc:ARRAY2[attached STRING]
 	symbolTableClass:ARRAY2[attached STRING]
 	vmTargetFile:PLAIN_TEXT_FILE
 	jackFileName: STRING_32
 	ifLabelCounter:INTEGER--sequence number for if labels
 	whileLabelCounter:INTEGER--sequence number for while labels
 	methodObjectName:STRING
 	methodObjectKind:STRING
 	methodObjectType:STRING
 	bracketFlag:BOOLEAN
	make
		do
			methodObjectName:="" methodObjectKind:="" methodObjectType:=""
			create symbolTableFunc.make_filled ("", 20, 4)--symbol table for function- for argument and local
			create symbolTableClass.make_filled ("", 20, 4)--symbol table for class- for static and field
			ifLabelCounter:=0
			whileLabelCounter:=0
			Io.read_line
 			scannning(Io.last_string)
		end
scannning(s: STRING)
 	local
       counter:INTEGER
       directory :DIRECTORY
       i:INTEGER
       b:BOOLEAN
       jack_file:PLAIN_TEXT_FILE
       sourceXmlT_file:PLAIN_TEXT_FILE
       targetXml_file:PLAIN_TEXT_FILE
       libraryName:STRING_32
       pathOfsourceXmlFile: STRING_32
       pathOfsourceJackFile: STRING_32--new
       pathOftargetXmlFile: STRING_32--new
       pathOftargetVmFile: STRING_32--new
	   tokenString:LIST[attached STRING]
       do
       		counter := 0
       		jackFileName:="Bat"--new
            --pathOfsourceJackFile:=s+"\"+jackFileName+".jack"--new
            --pathOfsourceXmlFile:=s+"\"+jackFileName+"T.xml"--new
            --pathOftargetXmlFile:=s+"\"+jackFileName+".xml"--new
            pathOftargetVmFile:=s+"\"+jackFileName+".vm"--new
            create directory.make_open_read(s)
            --create jack_file.make_open_read_append(pathOfsourceJackFile)
            --create sourceXmlT_file.make_open_read_append (pathOfsourceXmlFile)--new- creating xml file for tokenizing
            --create targetXml_file.make_open_read_append (pathOftargetXmlFile)--new- creating xml file for parsing
            create vmTargetFile.make_open_read_append (pathOftargetVmFile)--new- creating vm file
            --vmTargetFile.delete
            --create vmTargetFile.
            directory.start
            from
              i := 1
          	until
              i>directory.count
          	loop
          	  directory.readentry
          	  if attached directory.last_entry_32 as p2 then
				--need!! if(p2.ends_with (jackFileName+".jack")=true)
				if(p2.ends_with (".jack")=true)
				then b:=true jackFileName:=p2 jackFileName.replace_substring_all (".jack", "")
				else b:=false
				end
			  end
			  if(b=true)
          	  then
          	  	pathOfsourceJackFile:=s+"\"+jackFileName+".jack"--new
            	pathOfsourceXmlFile:=s+"\"+jackFileName+"T.xml"--new
            	pathOftargetXmlFile:=s+"\"+jackFileName+".xml"--new
            	pathOftargetVmFile:=s+"\"+jackFileName+".vm"--new
            	create jack_file.make_open_read_append(pathOfsourceJackFile)
            	create sourceXmlT_file.make_open_read_append (pathOfsourceXmlFile)--new- creating xml file for tokenizing
           		create targetXml_file.make_open_read_append (pathOftargetXmlFile)--new- creating xml file for parsing
            	create vmTargetFile.make_open_read_append (pathOftargetVmFile)--new- creating vm file
          	  if attached directory.last_entry_32 as p2 then
				determineToken(jack_file,sourceXmlT_file,"Main.jack")
				jack_file.close
				sourceXmlT_file.start--new
				tokenString:=getNextToken(sourceXmlT_file)--for <tokens>-dont need it
				ParseClass(sourceXmlT_file,targetXml_file)
				--sourceXmlT_file.close sourceXmlT_file.delete
				--sourceXmlT_file.wipe_out
				--targetXml_file.close targetXml_file.delete
			  end
          	  counter := counter + 1
          	  i:= i + 1
          	  else
              i := i + 1
              end
          	end

          	--need!! targetXml_file.close
       end

feature
 determineToken(sourceJackFile: PLAIN_TEXT_FILE;xmlT_file:PLAIN_TEXT_FILE;JackName:STRING)
 local
 	temp:STRING
 	symbolList:ARRAY[CHARACTER]
 	keyWordList:ARRAY[STRING]
 	flag:BOOLEAN
 	--readChar:CHARACTER
 do
	flag:=false--not a comment
	symbolList:=<<'(',')','{','}','[',']','*','.',',',';','+','-','/','&','|','<','>','=','~'>>
	keyWordList:=<<"class","constructor","function","method","field","static","var","int","char","boolean","void","true","false","null","this","let","do","if","else","while","return">>
 	create temp.make_empty
 	xmlT_file.put_string ("<tokens>%N")
 	from
	sourceJackFile.start
    until
    sourceJackFile.end_of_file=true --as long as we didnt get to the end of file
    loop
   		flag:=false
		sourceJackFile.read_character
    	if(sourceJackFile.last_character.out.same_string ("/") ) then
    	checkForComments(xmlT_file,sourceJackFile) flag:=true
    	end
    	if(symbolList.has (sourceJackFile.last_character)) then
    	if(not(flag=true and sourceJackFile.last_character.out.same_string ("/")=true)) then handleSymbols(sourceJackFile.last_character.out,xmlT_file,sourceJackFile) end
    	end
		if(sourceJackFile.last_character.is_digit)
		then --temp.append (sourceJackFile.last_character.out)
		handleIntegerConstant(temp,xmlT_file,sourceJackFile)
		--sourceJackFile.read_character
		temp:=""
		end
		if(sourceJackFile.last_character.out.same_string (('"').out))
		then --temp.append (sourceJackFile.last_character.out)
		--sourceJackFile.read_character
		handleStringConstant(temp,xmlT_file,sourceJackFile)
		temp:=""
		end
		if(sourceJackFile.last_character.is_alpha)
		then --temp.append (sourceJackFile.last_character.out)
		--sourceJackFile.read_character
		handleAlpha(temp,xmlT_file,sourceJackFile,symbolList,keyWordList)
		temp:=""
		end
    end
    xmlT_file.put_string ("</tokens>%N")
    --printAsm(helloAsm)
end
feature
 handleSymbols(value:STRING;xmlT_file:PLAIN_TEXT_FILE;sourceJackFile:PLAIN_TEXT_FILE)--handle comments too
 do
	if(value.same_string ("&")) then printTag("symbol","&amp;",xmlT_file) --sourceJackFile.read_character
	  end
 	if(value.same_string ("<"))then printTag("symbol","&lt;",xmlT_file) --sourceJackFile.read_character
 	end
	if(value.same_string (">"))then printTag("symbol","&gt;",xmlT_file) --sourceJackFile.read_character
	 end
	if(value.same_string (('"').out)) then printTag("symbol","&quat;",xmlT_file) --new
	end
	-- maybe need if(value.same_string ("\")) then checkForComments(value,xmlT_file,sourceJackFile) --tupal-how to go back to reading from jack without writing to xmlt
	--sourceJackFile.read_character
	if(value.same_string ("&")=false and value.same_string ("<")=false and value.same_string (">")=false and value.same_string (('"').out)=false  )--new "
	 then printTag("symbol",value,xmlT_file)
	 --sourceJackFile.read_character
	 end
 end
 feature
 checkForComments(xmlT_file:PLAIN_TEXT_FILE;sourceJackFile:PLAIN_TEXT_FILE)
 local
 	char1:CHARACTER
 	char2:CHARACTER
 	offset:INTEGER--new
 	position:INTEGER
 	newPosition:INTEGER
 do
 	if(sourceJackFile.item.out.same_string ("/") or sourceJackFile.item.out.same_string ("*")) then--new
 	--sourceJackFile.read_character--new
 	--if(sourceJackFile.last_character.out.same_string ("/") or sourceJackFile.last_character.out.same_string ("*")) then
 	sourceJackFile.read_character
 	if(sourceJackFile.last_character.out.same_string ("/"))
 	then sourceJackFile.read_line --for next char end
 	end
 	if(sourceJackFile.last_character.out.same_string ("*"))
 	then
 	sourceJackFile.read_character
 	char1:=sourceJackFile.last_character

 	--sourceJackFile.read_character
 	--char2:=sourceJackFile.last_character
 	from--looping in order to check for end of comment

 	until
 		(char1.out.same_string ("*") and char2.out.same_string ("/")) or xmlT_file.end_of_file
 	loop
 		char1:=char2
 		sourceJackFile.read_character
 		char2:=sourceJackFile.last_character
 		--sourceJackFile.read_character
 		--char2:=sourceJackFile.last_character
 	end
 	--sourceJackFile.read_character--for the final / to close the comment
 	--sourceJackFile.read_character--for next char
 	end
 	--sourceJackFile.read_character--for next char
 	else
 	printTag("symbol","/",xmlT_file) --sourceJackFile.back --new,back
 	sourceJackFile.read_character
 	end
 end
feature
 handleIntegerConstant(temp:STRING;xmlT_file:PLAIN_TEXT_FILE;sourceJackFile:PLAIN_TEXT_FILE)
 local
 	flag:BOOLEAN
 	nextChar:INTEGER
 	offset:INTEGER
 	--symbolList:ARRAY[CHARACTER]
 do
 	flag:=false --false to alarms to stop reading
 	--symbolList:=<<'(',')','{','}','[',']','*','.',',',';','+','-','\','&','|','<','>','=','~'>>
 	--xmlT_file.read_character
 	from --what action should it be-apperantly there hasnt got to be

 	until  flag=true or sourceJackFile.end_of_file --should also check that is between 0 and 32767?

 	loop
 		temp.append_character (sourceJackFile.last_character)

 		if(sourceJackFile.item.is_digit ) then
 		--sourceJackFile.read_character--new
 		--if(sourceJackFile.last_character.is_digit ) then--new
 		flag:=false else flag:=true end--if to keep reading, i dont know why but the condition is true when next character is not a digit

 		if(flag=false) then
 		sourceJackFile.read_character end
 	end

 	printTag("integerConstant",temp,xmlT_file)
 end
 feature
 handleStringConstant(temp:STRING;xmlT_file:PLAIN_TEXT_FILE;sourceJackFile:PLAIN_TEXT_FILE)
 do
 	sourceJackFile.read_character
 	--xmlT_file.read_character
	from --what action should it be-apperantly there hasnt got to be

 	until sourceJackFile.last_character.out.same_string (('"').out) or sourceJackFile.end_of_file

 	loop
 		--temp2:=xmlT_file.last_character.out
 		--temp.append (xmlT_file.last_character.out)
 		temp.append_character (sourceJackFile.last_character)
 		sourceJackFile.read_character
 		--xmlT_file.last_character
 	end
 	--xmlT_file.read_character
 	printTag("stringConstant",temp,xmlT_file)
 end
 feature
 handleAlpha(temp:STRING;xmlT_file:PLAIN_TEXT_FILE;sourceJackFile:PLAIN_TEXT_FILE;symbolList:ARRAY[CHARACTER];keyWordList:ARRAY[STRING])
 local
 	flag:BOOLEAN--true if string is identifier
 do
 	flag:=false--alarms when need to stop reading
	from --what action should it be-apperantly there hasnt got to be

 	until sourceJackFile.end_of_file or flag=true
 	loop

 		temp.append_character (sourceJackFile.last_character)
 		--nextChar:=sourceJackFile.last_character.next.code--next not good, doesnt mean next vhar in file but next char in order of values
 		if(sourceJackFile.item.out.same_string (" ") or sourceJackFile.item.out.same_string ("%N") or symbolList.has (sourceJackFile.item)=true ) then flag:=true else flag:=false end--if to keep reading, i dont know why but the condition is true when next character is not a digit
 		--need temp.append_character (sourceJackFile.last_character)
 		if(flag=false) then
 		sourceJackFile.read_character end
 	end
 	if(IsKeyWord(keyWordList,temp)) then handleKeyWords(temp,xmlT_file)
 	else handleIdentifier(temp,xmlT_file)
 	end
 end
feature
 IsKeyWord(keyWordList:ARRAY[STRING];temp:STRING):BOOLEAN
 local
 	i:INTEGER
 do
 	from
 		i:=1
 	until
 		i>keyWordList.count
 	loop
 		if(keyWordList.at (i).same_string (temp)) then Result := true
 		end
 		i:=i+1
 	end
 end
 feature
 handleKeyWords(temp:STRING;xmlT_file:PLAIN_TEXT_FILE)
 do
	printTag("keyword",temp,xmlT_file)
 end

 feature
 handleIdentifier(temp:STRING;xmlT_file:PLAIN_TEXT_FILE)
 do
	printTag("identifier",temp,xmlT_file)
 end
feature
 printTag(tagName:STRING;value:STRING;xmlT_file:PLAIN_TEXT_FILE)
 do
 	xmlT_file.put_string ("<"+tagName+"> "+value+" </"+tagName+">%N")
 	--sourceJackFile.read_character
 end

feature
 getNextToken(sourceXmlT_file:PLAIN_TEXT_FILE):LIST[attached STRING]
 local
 	tokenString:LIST[attached STRING]
 	--openTavit:STRING
 	--closeTavit:STRING
 	--token:STRING
 do
 	--openTavit:="" closeTavit:="" token:=""
 	sourceXmlT_file.readline
 	tokenString:=sourceXmlT_file.last_string.split (' ')
	result:=tokenString
 	--io.putstring (sourceXmlT_file.last_string+"%N")
 	--sourceXmlT_file.next_line
 end
 feature
 checkNextToken(sourceXmlT_file:PLAIN_TEXT_FILE):LIST[attached STRING]
 local
 	tokenString:LIST[attached STRING]
 	currentPosition:INTEGER
 	newPosition:INTEGER
 do
 	currentPosition:=sourceXmlT_file.position
 	sourceXmlT_file.readline
 	tokenString:=sourceXmlT_file.last_string.split (' ')
	result:=tokenString
	newPosition:=sourceXmlT_file.position
	sourceXmlT_file.go (currentPosition)
 	--xmlT_file.put_string ("<"+tagName+"> "+value+" </"+tagName+">%N")
 	--sourceJackFile.read_character
 end

feature
 ParseClass(sXmlT_file:PLAIN_TEXT_FILE;tXml_file:PLAIN_TEXT_FILE)
 local
 	tokenString:LIST[attached STRING]
 	--symbolTableFunc:ARRAY2[attached STRING]--new
	--symbolTableClass:ARRAY2[attached STRING]--new
 do
 	create symbolTableClass.make_filled ("", 20, 4)--symbol table for class- for fiels and static
 	--create symbolTableFunc.make_filled ("", 20, 4)--symbol table for function- for argument and local
 	tXml_file.putstring ("<class>%N")
 	tokenString:=getNextToken(sXmlT_file)
 	tXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for keyword class
 	tokenString:=getNextToken(sXmlT_file)
 	tXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for identifier class name
 	tokenString:=getNextToken(sXmlT_file)
 	tXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol {
 	ParseClassVarDec(sXmlT_file,tXml_file)--for var declaretions
 	ParsesubRoutineDec(sXmlT_file,tXml_file)--for routines implementations
 	tokenString:=getNextToken(sXmlT_file)
 	tXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol }
 	tXml_file.putstring ("</class>%N")
 	--symbolTableClass.clear_all
 end

 ParseClassVarDec(sourceXmlT_file:PLAIN_TEXT_FILE;targetXml_file:PLAIN_TEXT_FILE)
 local
 	tokenString:LIST[attached STRING]
 	Kind:STRING
 	Type:STRING
 	Name:STRING
 	--fieldCount:INTEGER
 	staticCount:INTEGER
 	--i:INTEGER--table row index
 	--j:INTEGER--table column index
 do
 	fieldCount:=0 staticCount:=0
 	rowIndex:=1 columnIndex:=1
 	tokenString:=checkNextToken(sourceXmlT_file)
 	from
 	until not(tokenString.at (2).same_string ("field") or tokenString.at (2).same_string ("static"))
 	loop
 		targetXml_file.putstring ("<classVarDec>%N")
 		tokenString:=getNextToken(sourceXmlT_file)--for keyword static or field
 		targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for keyword static or field
 		Kind:=tokenString.at (2)
 		symbolTableClass.item (rowIndex,columnIndex):=tokenString.at (2) columnIndex:=columnIndex+1--for kind
 		tokenString:=getNextToken(sourceXmlT_file)--for type-char,boolean,int or other class
 		targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for type-char,boolean,int or other class
 		Type:=tokenString.at (2)
 		symbolTableClass.item (rowIndex,columnIndex):=tokenString.at (2) columnIndex:=columnIndex+1--for type
 		tokenString:=getNextToken(sourceXmlT_file)--for var name identifier
 		targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for var name identifier
 		symbolTableClass.item (rowIndex,columnIndex):=tokenString.at (2) columnIndex:=columnIndex+1--for name
 		if(Kind.same_string ("field")) then symbolTableClass.item (rowIndex,columnIndex):=fieldCount.out fieldCount:=fieldCount+1 columnIndex:=1--for counting
 		else symbolTableClass.item (rowIndex,columnIndex):=staticCount.out staticCount:=staticCount+1 columnIndex:=1 end--for counting
 		if(rowIndex>=symbolTableClass.height) then symbolTableClass.resize_with_default ("",rowIndex+10,4) end
 		rowIndex:=rowIndex+1
 		tokenString:=checkNextToken(sourceXmlT_file)
 		from
 		until not(tokenString.at (2).same_string (","))--if there are more variables in this declaretion
 		loop
 		tokenString:=getNextToken(sourceXmlT_file)--for symbol ,
 		targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol ,
 		symbolTableClass.item (rowIndex,columnIndex):=Kind columnIndex:=columnIndex+1
 		symbolTableClass.item (rowIndex,columnIndex):=Type columnIndex:=columnIndex+1
 		tokenString:=getNextToken(sourceXmlT_file)--for var name identifier
 		targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for var name identifier
 		symbolTableClass.item (rowIndex,columnIndex):=tokenString.at (2) columnIndex:=columnIndex+1--for name
 		if(Kind.same_string ("field")) then symbolTableClass.item (rowIndex,columnIndex):=fieldCount.out fieldCount:=fieldCount+1 columnIndex:=1--for counting
 		else symbolTableClass.item (rowIndex,columnIndex):=staticCount.out staticCount:=staticCount+1 columnIndex:=1 end--for counting
 		if(rowIndex>=symbolTableClass.height) then symbolTableClass.resize_with_default ("",rowIndex+10,4) end
 		rowIndex:=rowIndex+1
 		tokenString:=checkNextToken(sourceXmlT_file)--checking for comma ,	
 		end
 		tokenString:=getNextToken(sourceXmlT_file)--for symbol ;
 		targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol ;
 		targetXml_file.putstring ("</classVarDec>%N")
 		tokenString:=checkNextToken(sourceXmlT_file)
 	end

 end

 ParsesubRoutineDec(sourceXmlT_file:PLAIN_TEXT_FILE;targetXml_file:PLAIN_TEXT_FILE)
 local
 	tokenString:LIST[attached STRING]
 	--symbolTableFunc:ARRAY2[attached STRING]
 	--Type:STRING
 	routineName:STRING
 	routineType:STRING
 	--i:INTEGER--table row index
 	--j:INTEGER--table column index
 do

 	argumentCount:=0 localCount:=0
 	funcRowIndex:=1 funcColumnIndex:=1
 	--create symbolTableFunc.make_filled ("", 20, 4)--symbol table for function- for argument and local
 	tokenString:=checkNextToken(sourceXmlT_file)
 	from
 	until not(tokenString.at (2).same_string ("constructor") or tokenString.at (2).same_string ("function") or tokenString.at (2).same_string ("method"))
 	loop
 		targetXml_file.putstring ("<subroutineDec>%N")
 		tokenString:=getNextToken(sourceXmlT_file)--for keyword constructor or function or method
 		targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for keyword constructor or function or method
 		routineType:=tokenString.at (2)
 		if(tokenString.at (2).same_string ("method")) --inserting pointer to object into symbol table
 		then
 			argumentCount:=argumentCount+1
 			symbolTableFunc.item (funcRowIndex, funcColumnIndex):="argument" funcColumnIndex:=funcColumnIndex+1
 			symbolTableFunc.item (funcRowIndex, funcColumnIndex):=methodObjectType funcColumnIndex:=funcColumnIndex+1
 			symbolTableFunc.item (funcRowIndex, funcColumnIndex):=methodObjectName funcColumnIndex:=funcColumnIndex+1
 			symbolTableFunc.item (funcRowIndex, funcColumnIndex):="0" funcColumnIndex:=1
 			methodObjectType:="" methodObjectName:=""
 			funcRowIndex:=funcRowIndex+1
 		end--new
 		tokenString:=getNextToken(sourceXmlT_file)--for keyword int or char or boolean or void or other class -return type
 		targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for keyword int or char or boolean or void or other class -return type
 		tokenString:=getNextToken(sourceXmlT_file)--for routine name identifier
 		targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for routine name identifier
 		routineName:=tokenString.at (2)
 		tokenString:=getNextToken(sourceXmlT_file)--for symbol (
 		targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol (
 		--if(tokenString.at (2).same_string ("method")) then argumentCount:=argumentCount+1 end--new
 		ParseParameterList(sourceXmlT_file,targetXml_file)
 		tokenString:=getNextToken(sourceXmlT_file)--for symbol )
 		targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol )
 		ParseSubRoutineBody(sourceXmlT_file,targetXml_file,routineName,routineType)
 		targetXml_file.putstring ("</subroutineDec>%N")
 		funcRowIndex:=1 funcColumnIndex:=1 localCount:=0 argumentCount:=0
 		symbolTableFunc.make_filled ("",20,4)
 		tokenString:=checkNextToken(sourceXmlT_file)
 	end
 end
 ParseParameterList(sXmlT_file:PLAIN_TEXT_FILE;tXml_file:PLAIN_TEXT_FILE)
 local
 	tokenString:LIST[attached STRING]
 	currentPosition:INTEGER
 	newPosition:INTEGER
 do

 	tokenString:=checkNextToken(sXmlT_file)
 	tXml_file.putstring ("<parameterList>%N")
 	from
 	until not(tokenString.at (1).same_string ("<identifier>") or tokenString.at (2).same_string ("int") or tokenString.at (2).same_string ("char") or tokenString.at (2).same_string ("boolean"))
 	loop
 		symbolTableFunc.item (funcRowIndex,funcColumnIndex):="argument" funcColumnIndex:=funcColumnIndex+1--for kind
 		tokenString:=getNextToken(sXmlT_file)--for type like int, char, boolean or other class
 		tXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for type like int, char, boolean or other class
 		symbolTableFunc.item (funcRowIndex,funcColumnIndex):=tokenString.at (2) funcColumnIndex:=funcColumnIndex+1--for type
 		tokenString:=getNextToken(sXmlT_file)--for parameter name identifier
 		tXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for parameter name identifier
 		symbolTableFunc.item (funcRowIndex,funcColumnIndex):=tokenString.at (2) funcColumnIndex:=funcColumnIndex+1--for name
 		symbolTableFunc.item (funcRowIndex,funcColumnIndex):=argumentCount.out funcColumnIndex:=1
 		argumentCount:=argumentCount+1
 		if(funcRowIndex>=symbolTableFunc.height) then symbolTableFunc.resize_with_default ("",rowIndex+10,4) end
 		funcRowIndex:=funcRowIndex+1--going to next line in symbol table of function for next argument
 		tokenString:=checkNextToken(sXmlT_file)--checking for comma ,
 		from
 		until not(tokenString.at (2).same_string (","))--if there are more variables in this declaretion
 		loop
 		tokenString:=getNextToken(sXmlT_file)--for symbol ,
 		tXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol ,
 		symbolTableFunc.item (funcRowIndex,funcColumnIndex):="argument" funcColumnIndex:=funcColumnIndex+1--for kind
 		tokenString:=getNextToken(sXmlT_file)--for type like int, char, boolean or other class
 		tXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for type like int, char, boolean or other class
 		symbolTableFunc.item (funcRowIndex,funcColumnIndex):=tokenString.at (2) funcColumnIndex:=funcColumnIndex+1--for type
 		tokenString:=getNextToken(sXmlT_file)--for parameter name identifier
 		tXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for parameter name identifier
 		symbolTableFunc.item (funcRowIndex,funcColumnIndex):=tokenString.at (2) funcColumnIndex:=funcColumnIndex+1--for name
 		symbolTableFunc.item (funcRowIndex,funcColumnIndex):=argumentCount.out funcColumnIndex:=1
 		argumentCount:=argumentCount+1
 		if(funcRowIndex>=symbolTableFunc.height) then symbolTableFunc.resize_with_default ("",rowIndex+10,4) end
 		funcRowIndex:=funcRowIndex+1
 		tokenString:=checkNextToken(sXmlT_file)--checking for comma ,	
 		end
 	end
 	tXml_file.putstring ("</parameterList>%N")
 end
  ParseSubRoutineBody(sXmlT_file:PLAIN_TEXT_FILE;tXml_file:PLAIN_TEXT_FILE;routineName:STRING;routineType:STRING)
 local
 	tokenString:LIST[attached STRING]
 	currentPosition:INTEGER
 	newPosition:INTEGER
 do
 	ifLabelCounter:=0
	whileLabelCounter:=0
 	tXml_file.putstring ("<subroutineBody>%N")
 	tokenString:=getNextToken(sXmlT_file)--for symbol {
 	tXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol {
 	ParseVarDec(sXmlT_file,tXml_file,routineName)
 	if(routineType.same_string ("constructor")) --if ctor-call alloc for memory allocation
 		then
 		vmTargetFile.putstring ("push constant "+fieldCount.out+"%N")
 		vmTargetFile.putstring ("call Memory.alloc 1%N")
 		vmTargetFile.putstring ("pop pointer 0%N")
 		end
 	if(routineType.same_string ("method")) --if method- storing first argument-this in ram[3] (this==3)
 		then
 		vmTargetFile.putstring ("push argument 0%N")
 		vmTargetFile.putstring ("pop pointer 0%N")
 		end
 	ParseStatements(sXmlT_file,tXml_file)
 	tokenString:=getNextToken(sXmlT_file)--for symbol }
 	tXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol }
 	tXml_file.putstring ("</subroutineBody>%N")
 end

 ParseVarDec(sourceXmlT_file:PLAIN_TEXT_FILE;targetXml_file:PLAIN_TEXT_FILE;routineName:STRING)
 local
 	tokenString:LIST[attached STRING]
 	Type:STRING
 do
 	tokenString:=checkNextToken(sourceXmlT_file)--checking for variables declaretions
 	from
 	until not(tokenString.at (2).same_string ("var"))--if there are more variables in this declaretion
 	loop
	targetXml_file.putstring ("<varDec>%N")
	symbolTableFunc.item (funcRowIndex,funcColumnIndex):="local" funcColumnIndex:=funcColumnIndex+1--for kind
	tokenString:=getNextToken(sourceXmlT_file)--for var keyword,new
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for var keyword,new
	tokenString:=getNextToken(sourceXmlT_file)--for type like int, char, boolean or other class
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for type like int, char, boolean or other class
 	Type:=tokenString.at (2)
 	symbolTableFunc.item (funcRowIndex,funcColumnIndex):=tokenString.at (2) funcColumnIndex:=funcColumnIndex+1--for type
 	tokenString:=getNextToken(sourceXmlT_file)--for var name identifier
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for var name identifier
 	symbolTableFunc.item (funcRowIndex,funcColumnIndex):=tokenString.at (2) funcColumnIndex:=funcColumnIndex+1--for name
 	symbolTableFunc.item (funcRowIndex,funcColumnIndex):=localCount.out funcColumnIndex:=1
 	localCount:=localCount+1
 	if(funcRowIndex>=symbolTableFunc.height) then symbolTableFunc.resize_with_default ("",rowIndex+10,4) end
 	funcRowIndex:=funcRowIndex+1
 	tokenString:=checkNextToken(sourceXmlT_file)--checking for comma ,
 	from
 	until not(tokenString.at (2).same_string (","))--if there are more variables in this declaretion
 	loop
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol ,
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol ,
 	symbolTableFunc.item (funcRowIndex,funcColumnIndex):="local" funcColumnIndex:=funcColumnIndex+1--for kind
 	symbolTableFunc.item (funcRowIndex,funcColumnIndex):=Type funcColumnIndex:=funcColumnIndex+1--for type
 	tokenString:=getNextToken(sourceXmlT_file)--for var name identifier
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for var name identifier
 	symbolTableFunc.item (funcRowIndex,funcColumnIndex):=tokenString.at (2) funcColumnIndex:=funcColumnIndex+1--for name
 	symbolTableFunc.item (funcRowIndex,funcColumnIndex):=localCount.out funcColumnIndex:=1
 	localCount:=localCount+1
 	if(funcRowIndex>=symbolTableFunc.height) then symbolTableFunc.resize_with_default ("",rowIndex+10,4) end
 	funcRowIndex:=funcRowIndex+1
 	tokenString:=checkNextToken(sourceXmlT_file)--checking for comma ,
 	end
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol ;
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol ;
	targetXml_file.putstring ("</varDec>%N")
	tokenString:=checkNextToken(sourceXmlT_file)--checking for variables declaretions
	end
	vmTargetFile.putstring ("function "+jackFileName+"."+routineName+" "+localCount.out+"%N")
 end

 ParseStatements(sourceXmlT_file:PLAIN_TEXT_FILE;targetXml_file:PLAIN_TEXT_FILE)
 local
 	tokenString:LIST[attached STRING]
 	typeOfStatement:STRING
 do
 	tokenString:=checkNextToken(sourceXmlT_file)--checking for statement
 	typeOfStatement:=tokenString.at (2)
 	if(typeOfStatement.same_string ("if") or typeOfStatement.same_string ("while") or typeOfStatement.same_string ("do") or typeOfStatement.same_string ("return") or typeOfStatement.same_string ("let"))
 	then targetXml_file.putstring ("<statements>%N")
 	from
 	until not(typeOfStatement.same_string ("if") or typeOfStatement.same_string ("while") or typeOfStatement.same_string ("do") or typeOfStatement.same_string ("return") or typeOfStatement.same_string ("let"))
 	loop
 	ParseStatement(sourceXmlT_file,targetXml_file)
 	tokenString:=checkNextToken(sourceXmlT_file)--checking for statement
 	typeOfStatement:=tokenString.at (2)
 	end
 	targetXml_file.putstring ("</statements>%N")
 	end
 end


  ParseStatement(sXmlT_file:PLAIN_TEXT_FILE;tXml_file:PLAIN_TEXT_FILE)
 local
 	tokenString:LIST[attached STRING]
 	typeOfStatement:STRING
 do
 	tokenString:=checkNextToken(sXmlT_file)--checking for type of statement
 	typeOfStatement:=tokenString.at (2)
 	if(typeOfStatement.same_string ("let") or typeOfStatement.same_string ("while") or typeOfStatement.same_string ("if") or typeOfStatement.same_string ("do") or typeOfStatement.same_string ("return")) then
 	--tXml_file.putstring ("<statement>%N")
 	tokenString:=checkNextToken(sXmlT_file)--checking for type of statement
 	if(typeOfStatement.same_string ("let")) then ParseLetStatement(sXmlT_file,tXml_file)
 	end
 	if(typeOfStatement.same_string ("while")) then ParseWhileStatement(sXmlT_file,tXml_file)
 	end
 	if(typeOfStatement.same_string ("if")) then ParseIfStatement(sXmlT_file,tXml_file)
 	end
 	if(typeOfStatement.same_string ("do")) then ParseDoStatement(sXmlT_file,tXml_file)
 	end
 	if(typeOfStatement.same_string ("return")) then ParseReturnStatement(sXmlT_file,tXml_file)
 	end
 	--tXml_file.putstring ("</statement>%N")
 	end
 end

 ParseLetStatement(sourceXmlT_file:PLAIN_TEXT_FILE;targetXml_file:PLAIN_TEXT_FILE)
 local
 	tokenString:LIST[attached STRING]
 	destVar:STRING
 	row:INTEGER
 	column:INTEGER
 	foundRow:INTEGER--row index of dest var
 	arrayFlag:BOOLEAN
 do
 	arrayFlag:=false
	targetXml_file.putstring ("<letStatement>%N")
	tokenString:=getNextToken(sourceXmlT_file)--for keyword let
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for keyword let
 	tokenString:=getNextToken(sourceXmlT_file)--for var name identifier
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for var name identifier
 	destVar:=tokenString.at (2)--the destination variable
 	tokenString:=checkNextToken(sourceXmlT_file)--check for expression
 	if(tokenString.at (2).same_string ("["))
 	then
 	arrayFlag:=true
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol [
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol [
 	ParseExpression(sourceXmlT_file,targetXml_file)--index
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol ]
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol ]
 	from row:=1--searching for destVar in function symbol table
	until symbolTableFunc.height<row
	loop
	if(not(symbolTableFunc.item (row,3).is_empty)) then
	if(symbolTableFunc.item (row,3).same_string (destVar)) then foundRow:=row end
	end
	row:=row+1
	end
	if(foundRow>0) then
	vmTargetFile.putstring ("push "+symbolTableFunc.item (foundRow,1)+" "+symbolTableFunc.item (foundRow,4)+"%N" )
 	vmTargetFile.putstring ("add%N")--calculating the destination address- start of array+index
 	else -- search in class symbol table
	from row:=1--searching for destVar in class symbol table
	until symbolTableClass.height<row
	loop
	if(not(symbolTableClass.item (row,3).is_empty)) then
	if(symbolTableClass.item (row,3).same_string (destVar)) then foundRow:=row end
	end
	row:=row+1
	end
	if(foundRow>0) then
	if(symbolTableFunc.item (foundRow,1).same_string ("field")) then
 	vmTargetFile.putstring ("push this "+symbolTableFunc.item (foundRow,4)+"%N" )
 	else vmTargetFile.putstring ("push "+symbolTableFunc.item (foundRow,1)+" "+symbolTableFunc.item (foundRow,4)+"%N" )
 	end
 	vmTargetFile.putstring ("add%N")--calculating the destination address- start of array+index
 	end
 	end
 	end
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol =
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol =
 	ParseExpression(sourceXmlT_file,targetXml_file)--defining the source expression
 	if(arrayFlag=true)
 	then
 	vmTargetFile.putstring ("pop temp 0%N")--saving the assigned value in temporary place
 	vmTargetFile.putstring ("pop pointer 1%N")--saving the destination address in ram[that]
 	vmTargetFile.putstring ("push temp 0%N")--pushing value into stack
 	vmTargetFile.putstring ("pop that 0%N")--saving the value in destination address
 	end
	tokenString:=getNextToken(sourceXmlT_file)--for symbol ;
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol ;
 	if(arrayFlag=false) then--if not an array
 	from row:=1
	until symbolTableFunc.height<row
	--loop
	--from column:=1
	--until symbolTableFunc.width<column
	loop
	if(not(symbolTableFunc.item (row,3).is_empty)) then
	if(symbolTableFunc.item (row,3).same_string (destVar)) then foundRow:=row end
	end
	--column:=column+1
	--end
	row:=row+1
	end
 	if(foundRow>0)
 	then
 	if(symbolTableFunc.item (foundRow,1).same_string ("field")) then vmTargetFile.putstring ("pop this "+symbolTableFunc.item (foundRow,4)+"%N" )
 	else vmTargetFile.putstring ("pop "+symbolTableFunc.item (foundRow,1)+" "+symbolTableFunc.item (foundRow,4)+"%N" ) end
 	else
 	from row:=1
	until symbolTableClass.height<row
	loop
	if(not(symbolTableClass.item (row,3).is_empty)) then
	if(symbolTableClass.item (row,3).same_string (destVar)) then foundRow:=row end
	end
	row:=row+1
	end
	if(symbolTableClass.item (foundRow,1).same_string ("field")) then vmTargetFile.putstring ("pop this "+symbolTableClass.item (foundRow,4)+"%N" )
 	else vmTargetFile.putstring ("pop "+symbolTableClass.item (foundRow,1)+" "+symbolTableClass.item (foundRow,4)+"%N" ) end
 	end
 	end
	targetXml_file.putstring ("</letStatement>%N")
 end

  ParseWhileStatement(sourceXmlT_file:PLAIN_TEXT_FILE;targetXml_file:PLAIN_TEXT_FILE)
 local
 	tokenString:LIST[attached STRING]
 	current_whileLabelCounter:INTEGER
 do
	targetXml_file.putstring ("<whileStatement>%N")
	vmTargetFile.putstring ("label WHILE_EXP"+whileLabelCounter.out+"%N")--label for start of loop
	tokenString:=getNextToken(sourceXmlT_file)--for keyword while
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for keyword while
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol (
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol (
 	ParseExpression(sourceXmlT_file,targetXml_file)
 	vmTargetFile.putstring ("not%N")
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol )
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol )
 	vmTargetFile.putstring ("if-goto WHILE_END"+whileLabelCounter.out+"%N")--if the expression is false-goto end of loop
 	current_whileLabelCounter:=whileLabelCounter
 	whileLabelCounter:=whileLabelCounter+1
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol {
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol {
 	ParseStatements(sourceXmlT_file,targetXml_file)
 	vmTargetFile.putstring ("goto WHILE_EXP"+current_whileLabelCounter.out+"%N")--going back to start of loop to check condition
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol }
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol }
 	vmTargetFile.putstring ("label WHILE_END"+current_whileLabelCounter.out+"%N")--label for end of loop

	targetXml_file.putstring ("</whileStatement>%N")
 end

  ParseIfStatement(sourceXmlT_file:PLAIN_TEXT_FILE;targetXml_file:PLAIN_TEXT_FILE)
 local
 	tokenString:LIST[attached STRING]
 	current_ifLabelCounter:INTEGER
 do
	targetXml_file.putstring ("<ifStatement>%N")
	tokenString:=getNextToken(sourceXmlT_file)--for keyword if
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for keyword if
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol (
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol (
 	ParseExpression(sourceXmlT_file,targetXml_file)--pushing expression into the stack
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol )
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol )
 	vmTargetFile.putstring ("if-goto IF_TRUE"+ifLabelCounter.out+"%N")
 	vmTargetFile.putstring ("goto IF_FALSE"+ifLabelCounter.out+"%N")
 	vmTargetFile.putstring ("label IF_TRUE"+ifLabelCounter.out+"%N")
 	current_ifLabelCounter:=ifLabelCounter
 	ifLabelCounter:=ifLabelCounter+1
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol {
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol {
 	ParseStatements(sourceXmlT_file,targetXml_file)
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol }
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol }
 	tokenString:=checkNextToken(sourceXmlT_file)--new! check for else
 	if(not(tokenString.at (2).same_string ("else")))
 	then
 	vmTargetFile.putstring ("label IF_FALSE"+current_ifLabelCounter.out+"%N")

 	end
 	tokenString:=checkNextToken(sourceXmlT_file)--check for else
 	if(tokenString.at (2).same_string ("else"))
 	then
 	vmTargetFile.putstring ("goto IF_END"+current_ifLabelCounter.out+"%N")
 	vmTargetFile.putstring ("label IF_FALSE"+current_ifLabelCounter.out+"%N")
 	tokenString:=getNextToken(sourceXmlT_file)--new!! for keyword else
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--new!! for keyword else
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol {
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol {
 	ParseStatements(sourceXmlT_file,targetXml_file)
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol }
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol }
 	vmTargetFile.putstring ("label IF_END"+current_ifLabelCounter.out+"%N")

 	end
	targetXml_file.putstring ("</ifStatement>%N")
 end

  ParseDoStatement(sourceXmlT_file:PLAIN_TEXT_FILE;targetXml_file:PLAIN_TEXT_FILE)
 local
 	tokenString:LIST[attached STRING]
 	routineName:STRING
 	routineType:STRING
 do
	targetXml_file.putstring ("<doStatement>%N")
	tokenString:=getNextToken(sourceXmlT_file)--for keyword do
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for keyword do
 	tokenString:=getNextToken(sourceXmlT_file)--for sub routine name
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for sub routine name
 	ParseSubRoutineCall(sourceXmlT_file,targetXml_file,tokenString.at (2))
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol ;
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol ;
 	vmTargetFile.putstring ("pop temp 0%N")
	targetXml_file.putstring ("</doStatement>%N")
 end

  ParseReturnStatement(sourceXmlT_file:PLAIN_TEXT_FILE;targetXml_file:PLAIN_TEXT_FILE)
 local
 	tokenString:LIST[attached STRING]
 do
 	targetXml_file.putstring ("<returnStatement>%N")
	tokenString:=getNextToken(sourceXmlT_file)--for return keyword
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for return keyword
 	tokenString:=checkNextToken(sourceXmlT_file)--check for expression
 	if(not(tokenString.at (2).same_string (";")))
 	then ParseExpression(sourceXmlT_file,targetXml_file) vmTargetFile.putstring ("return%N")--pushing expression into stack and return
 	else vmTargetFile.putstring ("push constant 0%N"+"return%N")--pushing a random value into the stack and return
 	end
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol ;
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol ;
 	targetXml_file.putstring ("</returnStatement>%N")
 end

  ParseExpression(sXmlT_file:PLAIN_TEXT_FILE;tXml_file:PLAIN_TEXT_FILE)
 local
 	tokenString:LIST[attached STRING]
 	ifOpString:STRING
 do
 	tXml_file.putstring ("<expression>%N")
	ParseTerm(sXmlT_file,tXml_file)
	tokenString:=checkNextToken(sXmlT_file)--check for operator
	ifOpString:=tokenString.at (2)
	from
	until not(ifOpString.same_string ("+") or ifOpString.same_string ("-") or ifOpString.same_string ("*") or ifOpString.same_string ("/") or ifOpString.same_string ("&amp;") or ifOpString.same_string ("|") or ifOpString.same_string ("&gt;") or ifOpString.same_string ("&lt;") or ifOpString.same_string ("="))--if next token is operator
	loop
	tokenString:=getNextToken(sXmlT_file)--for op such as: +,-,*,/,&,|,<,,>,=
 	tXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for op such as: +,-,*,/,&,|,<,,>,=
 	ParseTerm(sXmlT_file,tXml_file)
 	if(ifOpString.same_string ("+")) then vmTargetFile.putstring ("add%N") end
 	if(ifOpString.same_string ("-")) then vmTargetFile.putstring ("sub%N") end
 	if(ifOpString.same_string ("*")) then vmTargetFile.putstring ("call Math.multiply 2%N") end
 	if(ifOpString.same_string ("/")) then vmTargetFile.putstring ("call Math.divide 2%N") end
 	if(ifOpString.same_string ("&amp;")) then vmTargetFile.putstring ("and%N") end
 	if(ifOpString.same_string ("|")) then vmTargetFile.putstring ("or%N") end
 	if(ifOpString.same_string ("&gt;")) then vmTargetFile.putstring ("gt%N") end
 	if(ifOpString.same_string ("&lt;")) then vmTargetFile.putstring ("lt%N") end
 	if(ifOpString.same_string ("=")) then vmTargetFile.putstring ("eq%N") end
 	tokenString:=checkNextToken(sXmlT_file)--check for operator
	ifOpString:=tokenString.at (2)--check for operator
	end
	tXml_file.putstring ("</expression>%N")

 end

   ParseSubRoutineCall(sXmlT_file:PLAIN_TEXT_FILE;tXml_file:PLAIN_TEXT_FILE;Name:STRING)
 local
 	tokenString:LIST[attached STRING]
 	typeOfSubRoutine:STRING
 	row:INTEGER
 	foundRow1:INTEGER
 	foundRow2:INTEGER
 	dotFlag:BOOLEAN--determine the call command for method- append with type of object
 	--bracketFlag:BOOLEAN--determine the call command for method- append with class name
 do
 	methodObjectName:=""
 	dotFlag:=false bracketFlag:=false
 	--tXml_file.putstring ("<SubRoutineCall>%N")
 	tokenString:=checkNextToken(sXmlT_file)--check for type of subroutine
 	typeOfSubRoutine:=tokenString.at (2)
 	if(typeOfSubRoutine.same_string ("("))--if subRoutineName(expressionList)
 	then
 	bracketFlag:=true
	--tokenString:=getNextToken(sourceXmlT_file)--for symbol (
 	--targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol (
 	ParseExpressionList(sXmlT_file,tXml_file,Name,"method",Name)
 	--tokenString:=getNextToken(sourceXmlT_file)--for symbol )
 	--targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol )
 	end
 	if(typeOfSubRoutine.same_string ("."))--if (className|varName).subRoutineName(expressionList)
 	then
 	dotFlag:=true
	tokenString:=getNextToken(sXmlT_file)--for symbol .
 	tXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol .
 	tokenString:=getNextToken(sXmlT_file)--for subroutineName identifier
 	tXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for subroutineName identifier
 	--tokenString:=getNextToken(sourceXmlT_file)--for symbol (
 	--targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol (
 	from row:=1--determine if subroutine is function or method- search in symbol table func
	until symbolTableFunc.height<row
	loop
	if(not(symbolTableFunc.item (row,3).is_empty)) then
	if(symbolTableFunc.item (row,3).same_string (Name)) then foundRow1:=row end
	end
	row:=row+1
	end
	from row:=1--determine if subroutine is function or method- search in symbol table class
	until symbolTableClass.height<row
	loop
	if(not(symbolTableClass.item (row,3).is_empty)) then
	if(symbolTableClass.item (row,3).same_string (Name)) then foundRow2:=row end
	end
	row:=row+1
	end
	if(foundRow1>0) then methodObjectName:=symbolTableFunc.item (foundRow1,3) end--if argument or local
	if(foundRow2>0) then methodObjectName:=symbolTableClass.item (foundRow2,3) end--if field or static
	if(foundRow1>0 or foundRow2>0 )
	then if(bracketFlag=true) then ParseExpressionList(sXmlT_file,tXml_file,tokenString.at (2),"method",Name)--append class name
	else if(foundRow1>0) then ParseExpressionList(sXmlT_file,tXml_file,tokenString.at (2),"method",symbolTableFunc.item (foundRow1,2))--append type of object
	else ParseExpressionList(sXmlT_file,tXml_file,tokenString.at (2),"method",symbolTableClass.item (foundRow2,2)) end end--append type of object
 	else  ParseExpressionList(sXmlT_file,tXml_file,tokenString.at (2),"function",Name) end
 	--tokenString:=getNextToken(sourceXmlT_file)--for symbol )
 	-- targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol )
 	end
 	--tXml_file.putstring ("</SubRoutineCall>%N")
 end

  ParseTerm(sourceXmlT_file:PLAIN_TEXT_FILE;targetXml_file:PLAIN_TEXT_FILE)
 local
 	tokenString:LIST[attached STRING]
 	typeOfTerm1:STRING
 	typeOfTerm2:STRING
 	i:INTEGER
 	destVar:STRING
 	row:INTEGER
 	column:INTEGER
 	foundRow:INTEGER
 	arrayFlag:BOOLEAN
 	subRoutineFlag:BOOLEAN
 	identifierName:STRING
 	sizeOfStringConstant:INTEGER
 	totalStringConstant:STRING
 do
 	totalStringConstant:=""
 	arrayFlag:=false
 	subRoutineFlag:=false
 	targetXml_file.putstring ("<term>%N")
	tokenString:=checkNextToken(sourceXmlT_file)--check for type of term
	typeOfTerm1:=tokenString.at (1)
	typeOfTerm2:=tokenString.at (2)
	if(typeOfTerm1.same_string ("<integerConstant>") or typeOfTerm2.same_string ("true") or typeOfTerm2.same_string ("false") or typeOfTerm2.same_string ("null") or typeOfTerm2.same_string ("this"))
	then
	if(typeOfTerm1.same_string ("<integerConstant>")) then vmTargetFile.putstring ("push constant "+ typeOfTerm2+"%N") end
	if(typeOfTerm2.same_string ("true")) then vmTargetFile.putstring ("push constant 0%N"+"not%N") end
	if(typeOfTerm2.same_string ("false")) then vmTargetFile.putstring ("push constant 0%N") end
	if(typeOfTerm2.same_string ("this")) then vmTargetFile.putstring ("push pointer 0%N") end
	if(typeOfTerm2.same_string ("null")) then vmTargetFile.putstring ("push constant 0%N") end
	tokenString:=getNextToken(sourceXmlT_file)--for integerConstant or stringContant or keyword constant
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for integerConstant or stringContant or keyword constant
	end
	if(typeOfTerm1.same_string ("<stringConstant>"))--new
	then
	tokenString:=getNextToken(sourceXmlT_file)--for stringContant
	from i:=1
	until i>tokenString.count
	loop
	targetXml_file.putstring (tokenString.at (i)+" ")
	i:=i+1
	end

	from i:=2--counting size of string constant
	until i>tokenString.count-1
	loop
	totalStringConstant.append (tokenString.at (i))
	if(not(i+1>tokenString.count-1) and tokenString.at (i).count>0)--there is another string a head
	then totalStringConstant.append(" ") end
	--sizeOfStringConstant:=sizeOfStringConstant+tokenString.at (i).count
	i:=i+1
	end
	sizeOfStringConstant:=totalStringConstant.count
	vmTargetFile.putstring ("push constant "+sizeOfStringConstant.out+"%N")--pushing into the stack size of string constant
	vmTargetFile.putstring ("call String.new 1%N")--allocating memory for string constant
	from i:=1
	until i>sizeOfStringConstant
	loop
		vmTargetFile.putstring ("push constant "+totalStringConstant.at (i).code.out+"%N")--pushing into stack ascii value of current char
		vmTargetFile.putstring ("call String.appendChar 2%N")--appending to string in memory current char
		i:=i+1
	end
	targetXml_file.putstring ("%N")
 	--targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for integerConstant or stringContant or keyword constant
	end

	if(typeOfTerm2.same_string ("("))--for (expression)
	then
	tokenString:=getNextToken(sourceXmlT_file)--for symbol (
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol (
 	ParseExpression(sourceXmlT_file,targetXml_file)
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol )
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol )
	end
	if(typeOfTerm2.same_string ("-") or typeOfTerm2.same_string ("~"))--unary term
	then
	tokenString:=getNextToken(sourceXmlT_file)--for symbol - or ~
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol - or ~
 	ParseTerm(sourceXmlT_file,targetXml_file)
 	if(typeOfTerm2.same_string ("-")) then vmTargetFile.putstring ("neg%N") end
 	if(typeOfTerm2.same_string ("~")) then vmTargetFile.putstring ("not%N") end
	end
	if(typeOfTerm1.same_string ("<identifier>"))--if varName or subroutinecall or varName[expression]
	then
	tokenString:=getNextToken(sourceXmlT_file)--for identifier- varName or subRoutineName
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for identifier- varName or subRoutineName
 	destVar:=tokenString.at (2)
 	from row:=1
	until symbolTableFunc.height<row
	loop
	if(not(symbolTableFunc.item (row,3).is_empty)) then
	if(symbolTableFunc.item (row,3).same_string (destVar)) then foundRow:=row end
	end
	row:=row+1
	end

 	tokenString:=checkNextToken(sourceXmlT_file)--check if subroutinecall or varName[expression]
 	if(tokenString.at (2).same_string ("["))-- if varName[expression]
 	then
 	arrayFlag:=true
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol [
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol [
 	ParseExpression(sourceXmlT_file,targetXml_file)--index
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol ]
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol ]
 	if(foundRow>0) then
 	vmTargetFile.putstring ("push "+symbolTableFunc.item (foundRow,1)+" "+symbolTableFunc.item (foundRow,4)+"%N") --pushing into the stack the address of the start of the array
 	else--search in symbol class table
 	from row:=1
	until symbolTableClass.height<row
	loop
	if(not(symbolTableClass.item (row,3).is_empty)) then
	if(symbolTableClass.item (row,3).same_string (destVar)) then foundRow:=row end
	end
	row:=row+1
	end
	if(foundRow>0) then if(symbolTableClass.item (foundRow,1).same_string ("field")) then vmTargetFile.putstring ("push this "+symbolTableClass.item (foundRow,4)+"%N")
	else vmTargetFile.putstring ("push "+symbolTableClass.item (foundRow,1)+" "+symbolTableClass.item (foundRow,4)+"%N") end
	end
 	end
 	vmTargetFile.putstring ("add%N")--calculating the destination address
 	vmTargetFile.putstring ("pop pointer 1%N")--saving the required address in ram[that]
 	vmTargetFile.putstring ("push that 0%N")--pushing into the stack the value stored in "that" address
 	end
 	if(tokenString.at (2).same_string ("(") or tokenString.at (2).same_string ("."))-- if subroutinecall
 	then
 	subRoutineFlag:=true
 	--if(tokenString.at (2).same_string (".")) --determine rather its a function or a method
 	--then
 	--if(foundRow>0) then
 	ParseSubRoutineCall(sourceXmlT_file,targetXml_file,destVar)
 	--else ParseSubRoutineCall(sourceXmlT_file,targetXml_file,destVar,"function") end--its a function
 	--end
 	--ParseSubRoutineCall(sourceXmlT_file,targetXml_file)
 	end
 	--if its an identifier but not an array and not a subrouyine call
 	if(foundRow>0 and arrayFlag=false and subRoutineFlag=false)
 	then
 	if(symbolTableFunc.item (foundRow,1).same_string ("field")) then vmTargetFile.putstring ("push this "+symbolTableClass.item (foundRow,4)+"%N") --if found in symbol table- it's a variable
	else vmTargetFile.putstring ("push "+symbolTableFunc.item (foundRow,1)+" "+symbolTableFunc.item (foundRow,4)+"%N") end
	else --if not found in function table 'search in class table
	if(arrayFlag=false and subRoutineFlag=false) then
	from row:=1
	until symbolTableClass.height<row
	loop
	if(not(symbolTableClass.item (row,3).is_empty)) then
	if(symbolTableClass.item (row,3).same_string (destVar)) then foundRow:=row end
	end
	row:=row+1
	end
	if(symbolTableClass.item (foundRow,1).same_string ("field")) then vmTargetFile.putstring ("push this "+symbolTableClass.item (foundRow,4)+"%N")
	else vmTargetFile.putstring ("push "+symbolTableClass.item (foundRow,1)+" "+symbolTableClass.item (foundRow,4)+"%N") end
	end
	end
	end
	targetXml_file.putstring ("</term>%N")
 end

  ParseExpressionList(sourceXmlT_file:PLAIN_TEXT_FILE;targetXml_file:PLAIN_TEXT_FILE;routineName:STRING;typeOfRoutine:STRING;NameOfClassFunction:STRING)
 local
 	tokenString:LIST[attached STRING]
 	argumentCounter:INTEGER
 	row:INTEGER
 	foundRow1:INTEGER
 	foundRow2:INTEGER
 do
 	argumentCounter:=0
 	if(typeOfRoutine.same_string ("method")) --if routine is method- send this as first argument
 	then
 	from row:=1--search for object of the method
		until symbolTableFunc.height<row
		loop
		if(not(symbolTableFunc.item (row,3).is_empty)) then
		if(symbolTableFunc.item (row,3).same_string (methodObjectName)) then foundRow1:=row end
		end
		row:=row+1
		end
		from row:=1--search for object of the method
		until symbolTableClass.height<row
		loop
		if(not(symbolTableClass.item (row,3).is_empty)) then
		if(symbolTableClass.item (row,3).same_string (methodObjectName)) then foundRow2:=row end
		end
		row:=row+1
		end
		if(foundRow1>0)
		then vmTargetFile.putstring ("push "+symbolTableFunc.item (foundRow1,1)+" "+symbolTableFunc.item (foundRow1,4)+"%N") methodObjectType:=symbolTableFunc.item (foundRow1,2)
		else if(foundRow2>0)
			then if(symbolTableClass.item (foundRow2,1).same_string ("field"))
				 then vmTargetFile.putstring ("push this "+symbolTableClass.item (foundRow2,4)+"%N") methodObjectType:=symbolTableClass.item (foundRow2,2)
				 else vmTargetFile.putstring ("push "+symbolTableClass.item (foundRow2,1)+" "+symbolTableFunc.item (foundRow2,4)+"%N")  methodObjectType:=symbolTableClass.item (foundRow2,2)
				 end
			else
				vmTargetFile.putstring ("push pointer 0%N")
				 methodObjectType:=JackFileName
			end
		end
 	-------
 	--vmTargetFile.putstring ("push pointer 0%N")
 	end
 	tokenString:=checkNextToken(sourceXmlT_file)--check for expressions
 	if(tokenString.at (2).same_string ("("))
 	then
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol (
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol (
 	targetXml_file.putstring ("<expressionList>%N")
 	tokenString:=checkNextToken(sourceXmlT_file)--check for expressions
 	if(not(tokenString.at (2).same_string (")")))--new
 	then--new
 	ParseExpression(sourceXmlT_file,targetXml_file)
 	argumentCounter:=argumentCounter+1
 	tokenString:=checkNextToken(sourceXmlT_file)--check for expressions
 	from
 	until not(tokenString.at (2).same_string (","))--checking for comma ,- more expressions
 	loop
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol ,
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol ,
 	ParseExpression(sourceXmlT_file,targetXml_file)
 	argumentCounter:=argumentCounter+1
 	tokenString:=checkNextToken(sourceXmlT_file)--check for expressions
 	end
 	end--new
 	targetXml_file.putstring ("</expressionList>%N")
 	tokenString:=getNextToken(sourceXmlT_file)--for symbol )
 	targetXml_file.putstring (tokenString.at (1)+tokenString.at (2)+tokenString.at (3)+"%N")--for symbol )
 	if(typeOfRoutine.same_string ("method"))
 	then
 	argumentCounter:=argumentCounter+1
 	if(bracketFlag=true) then vmTargetFile.putstring ("call "+jackFileName+"."+routineName+" "+argumentCounter.out+"%N")
 	else vmTargetFile.putstring ("call "+NameOfClassFunction+"."+routineName+" "+argumentCounter.out+"%N") end
 	end
 	if(typeOfRoutine.same_string ("function")) then vmTargetFile.putstring ("call "+NameOfClassFunction+"."+routineName+" "+argumentCounter.out+"%N") end
 	end
 end




end
