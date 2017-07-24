# __precompile__()

# HamNNNNclassifier io functions

"""
Read a dataset file in Orange format; returns a DataTable object, as well as a list
of attribute names and their codes.
Columns with string entries are set to categorical vectors.
"""
function readorangeformat(sourceFile, fileFormat, nullsString=["", "NULL", "NA", "?"])
	# this function returns an array with the orange format attribute names, one with codes,
	# and a datatable with the attribute values
	# get the header line and split it into words
	header = split(chomp(readline(sourceFile)),'\t')
	# if newer Orange file format, extract codes by splitting labels with #
	if fileFormat == "Newer"
		header1=[split(i,'#') for i in header]
		# @show header header1
		columnNames = [i[end] for i in header1] # list comprehension to generate a list
		# use a function to generate empty codes if none are included
		f(x) = (length(x) == 1) ? "" : x[1]
		columnCodes = [f(i) for i in header1]
		# set the start of the data in the file to the 2nd row
		dataRow = 2
	else # ie Older Orange file format
		# the first line is labels
		# in order for readline to read successive lines, the file must be opened and closed
		f = open(sourceFile)
		# @show f
		columnNames = split(chomp(readline(f)),'\t')
		secondLine = split(chomp(readline(f)),'\t')
		thirdLine = split(chomp(readline(f)),'\t')
		close(f)
		# convert the codes in secondLine to uppercase
		columnCodes = [uppercase(s) for s in secondLine]
		# @show columnCodes
		# change "class" in thirdLine to "c"
		thirdLine = [s == "class" ? "c" : s for s in thirdLine]
		# @show thirdLine
		# replace corresponding columnCodes with third line codes when available
		# note that I was unable to find a way for a list comprehension to do this
		# @show [(s,t) for s in columnCodes, t in thirdLine]
		for i in 1:length(columnCodes)
		 	if thirdLine[i] != ""
		 		columnCodes[i] = thirdLine[i]
		 	end
		 end
		# @show columnCodes
		# set the start of the data in the file to the 4th row
		dataRow = 4
	end 
	# @show columnNames columnCodes
	# read in the file as a datatable, substituting the stripped attribute names
	# for the time being, CSV.read does not support nastring, so we just use "?" to indicate null values
	# also, it is difficult to print out the values for weakrefstrings, so do not use.
	table = CSV.read(sourceFile, DataTable, delim = '\t', null="?", header=columnNames, datarow=dataRow, weakrefstrings=false)
	# @show table
	return columnCodes, columnNames, table
end

"""
Return a string "Newer" or "Older" to correspond to the Orange file format of sourceFile.
"""
function getorangefileformat(sourceFile)
	# if the first line contains the character '#', we conclude the file is in newer
	# Orange format. Else, older Orange file format
	contains(readline(sourceFile), "#") ? "Newer" : "Older"
end
