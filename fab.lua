-- Joe Gilbert
-- COMP 3200
-- 9/20/19

-- To run the program, type "lua fab.lua" in the output console.
-- (The output console is enabled in the 'View' tab on the toolbar.)
-- NOTE: there is a very specific place the files must go in order to work.
-- The input file (named "fabin.txt") must go in the same folder as the project.
-- The folder for the project can be anywhere however (it was on my desktop the entire time
-- I built it.)  You may also need to run SciTE as an administrator (I had to once to save the
-- config file for the IDE.)
-- This project was made using the SciTE IDE for Lua.
-- Both can be found at https://github.com/rjpcomputing/luaforwindows.
-- The version of SciTE used to make this project was 1.75.
-- http://www.scintilla.org
-- You will also need to download the Lua language itself.
-- The output file will be created in the same folder as project, and should be viewed
-- using Notepad (although any text editing software should work.)
-- Other than that, the program should run on it's own.





--Returns the data it reads from the input.
function readinputfile(inputfile)

	lines = {}
	io.open(inputfile, "r")
	for line in io.lines(inputfile) do

		lines[#lines + 1] = line
	end
	return lines
end



--Gets the alignment chars from a given line.
function getalignmentandnumofcols(line)
	aligntable = {}
		for c in string.gmatch(line,'[<>=]') do
			table.insert(aligntable, c)
		end
	return aligntable
end


--Separates the entries at '&'s.
function separateinputs(line)
	local entrytable = {}
	local separator = "\&"

	for str in string.gmatch(line, "([^"..separator.."]+)") do
		table.insert(entrytable, str)
	end

	return entrytable
end


--Convenient function to turn a row of a table into a column.
function getmultidata(datatable, start, stop)
	local values = {}
	for i = start, stop, 1 do
		table.insert(values, datatable[i])
	end
	return values
end


--Formats the entries themselves.
function formatentries(column, lengtharray, alignment)


	for l = 1, #lengtharray, 1 do
		alignofcol = alignment[l]

		for row = 1, #column[1], 1 do
			entry = column[l][row]
			if (alignofcol == "<") then
			--Left justified
				widthofcol = lengtharray[l] + 1
				if (l == #column) then
				--Rightside
					column[l][row] = "| " ..(string.format("%-"..widthofcol.."s",entry)).. "|"
				else
				--Leftside or normal entry
					column[l][row] = "| " ..(string.format("%-"..widthofcol.."s",entry))
				end

			else if (alignofcol == ">") then
			--Right justified
				widthofcol = lengtharray[l] + 1
				if (l == #column) then
				--Rightside
					column[l][row] = "|" ..(string.format("% "..widthofcol.."s",entry)).. " |"
				else
				--Leftside or normal entry
					column[l][row] = "|" ..(string.format("% "..widthofcol.."s",entry)).. " "
				end

			else
			--Center
				widthofcol = lengtharray[l] + 2
				spaces = widthofcol - #entry
				leftspacing = math.floor(spaces/2) + 1
				rightspacing = math.ceil(spaces/2) + 1
				if (l == #column) then
				--Rightside
					column[l][row] = ((string.format("%-"..leftspacing.."s","| "))..entry..(string.format("% "..(rightspacing-1).."s","|")))
				else
				--Leftside or normal entry
					column[l][row] = ((string.format("%-"..leftspacing.."s","| "))..entry..(string.format("% "..(rightspacing-1).."s"," ")))
				end

				end
			end

		end
	end

end




--Fins the max length of the input column table.
function findlengthofcols(datacol)

	longest = 0
	for i = 1, #datacol, 1 do
		if (#datacol[i] >= longest) then
			longest = #datacol[i]
		else
			longest = longest
		end
	end

	return longest
end
--This function returns an int (length of longest
--string in the col parameter)
--Give it an array (really a table) of strings from a single column.


--Gets the line numbers for the alignment chars.
function getaltable(linestable)
	altable = {}

	for i = 1, #linestable, 1 do
		if (string.find(linestable[i],"[<>=\*]")) then
			table.insert(altable, i)
		end
	end
	return altable
end

--START
local filein = "fabin.txt"
local fileout = io.open("fabout.txt", "w+")
linesread = readinputfile(filein)

altable = getaltable(linesread)

--MAIN LOOP
for alpha = 2, #altable, 1 do
	formatrow = altable[alpha - 1]
	formatnextrow = altable[alpha]
	alignments = getalignmentandnumofcols(linesread[formatrow])


	for i = 1, #alignments, 1 do
		print(alignments[i])
	end

	numofcols = #alignments



	entrylines = {}
	coldata = {}
	subcoldata = {}
	for i = formatrow + 1, formatnextrow - 1, 1 do
		r = separateinputs(linesread[i])
		table.insert(entrylines, r)
	end

	numofentries = #entrylines
	rowsnum = #entrylines
	colsnum = #entrylines[1]


	for i = 1, colsnum, 1 do
		for j = 1, rowsnum, 1 do
			table.insert(subcoldata, entrylines[j][i])
		end
	end

	lengtharray = {}
	column = {}

	for c = 0, colsnum-1, 1 do
		table.insert(column, getmultidata(subcoldata, (1 + (c * rowsnum)), (rowsnum + (c * rowsnum)) ))
	end

	for i = 1, #alignments, 1 do
		table.insert(lengtharray, findlengthofcols(column[i]))
	end


	formatentries(column, lengtharray, alignments)


	--Here, we put in the separators.
	for col = 1, #lengtharray, 1 do

			if (col == 1) then
				if (#lengtharray == 1) then
					bordtop = "@ "..(string.format("% "..(lengtharray[col]+2).."s","@"))
					fbordtop = string.gsub(bordtop, " ", "-")

					--Title border
					bordsub = "| "..(string.format("% "..(lengtharray[col]+2).."s","|"))
					fbordsub = string.gsub(bordsub, " ", "-")

					--Bottom border
					bordbot = "@ "..(string.format("% "..(lengtharray[col]+2).."s","@"))
					fbordbot = string.gsub(bordbot, " ", "-")

					table.insert(column[col], 1, fbordtop)
					table.insert(column[col], 3, fbordsub)
					table.insert(column[col], fbordbot)
				else
					bordtop = "@ "..(string.format("% "..(lengtharray[col]+1).."s","-"))
					fbordtop = string.gsub(bordtop, " ", "-")

					--Title border
					bordsub = "| "..(string.format("% "..(lengtharray[col]+1).."s","-"))
					fbordsub = string.gsub(bordsub, " ", "-")

					--Bottom border
					bordbot = "@ "..(string.format("% "..(lengtharray[col]+1).."s","-"))
					fbordbot = string.gsub(bordbot, " ", "-")
					table.insert(column[col], 1, fbordtop)
					table.insert(column[col], 3, fbordsub)
					table.insert(column[col], fbordbot)
				end
			else if (col == #lengtharray) then


				bordtop = "- "..(string.format("% "..(lengtharray[col]+2).."s","@"))
				fbordtop = string.gsub(bordtop, " ", "-")

				--Title border
				bordsub = "+ "..(string.format("% "..(lengtharray[col]+2).."s","|"))
				fbordsub = string.gsub(bordsub, " ", "-")

				--Bottom border
				bordbot = "- "..(string.format("% "..(lengtharray[col]+2).."s","@"))
				fbordbot = string.gsub(bordbot, " ", "-")

				table.insert(column[col], 1, fbordtop)
				table.insert(column[col], 3, fbordsub)
				table.insert(column[col], fbordbot)

			else
				bordtop = "- "..(string.format("% "..(lengtharray[col]+1).."s"," "))
				fbordtop = string.gsub(bordtop, " ", "-")

				--Title border
				bordsub = "+ "..(string.format("% "..(lengtharray[col]+1).."s"," "))
				fbordsub = string.gsub(bordsub, " ", "-")

				--Bottom border
				bordbot = "- "..(string.format("% "..(lengtharray[col]+1).."s"," "))
				fbordbot = string.gsub(bordbot, " ", "-")

				table.insert(column[col], 1, fbordtop)
				table.insert(column[col], 3, fbordsub)
				table.insert(column[col], fbordbot)
			end
		end
	end


	for i = 1, #column, 1 do
		for j = 1, #column[1], 1 do
			print(column[i][j])
		end
	end



	for i = 1, #column[1], 1 do
		for j = 1, #column, 1 do
			if (j == #column) then
				fileout:write(column[j][i],"\n")
			else
				fileout:write(column[j][i])
			end

		end
	end

--END
end

