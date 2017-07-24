# __precompile__()

# HamNNNNclassifier utility functions

"""
Read a dataset file in Orange format; returns a DataTable object.
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

function getorangefileformat(sourceFile)
	# if the first line contains the character '#', we conclude the file is in newer
	# Orange format. Else, older Orange file format
	contains(readline(sourceFile), "#") ? "Newer" : "Older"
end

"""
Reads a dataset file and massages it to return a datatable suitable for training or testing,
and a vector containing values of the class attribute.
"""
function generatetraintesttable(dataFile)
	codes, names, table = readorangeformat(dataFile, getorangefileformat(dataFile))
	i, classAttributeValues = extractclassattribute(table, codes)
	delete!(table, findunusedcolumns(codes))
	return table, classAttributeValues
end

"""
Takes a vector of orange format codes and returns a vector of indices for the 
codes which are found in the deleteCodes parameter.
"""
function findunusedcolumns(columnCodes, deleteCodes=["c", "i", "m", "w"])
	return [i for i in eachindex(columnCodes) if columnCodes[i] in deleteCodes]
end

function extractclassattribute(dataTable, columnCodes)
	# returns an index for the class attribute within the data table, and
	# a vector with the values for the class attribute
	for i in eachindex(columnCodes)
		if columnCodes[i] == "c"
			return i, dataTable[i]
		end
	end
end

function roundpercentage(a::Float64, decimals::Integer)
	a < 10.0 ? signif(a,decimals+1) : signif(a,decimals+2)
end

numericattribute{T<:Real}(a::AbstractArray{T}) = true

numericattribute(a::AbstractArray) = false

function describeattribute{T<:Real}(a::AbstractArray{T})
	return extrema(a), mean(a), median(a)
end

function describeattribute(a::AbstractArray)
	u = unique(a)
	return length(u), u
end