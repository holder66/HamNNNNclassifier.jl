__precompile__()

# HamNNNNclassifier io functions

"""
Read a dataset file in Orange format, either Newer or Older; returns a DataFrame object, 
as well as a list of attribute names and their codes.
Columns with string values are set to discrete (categorical) attributes (code "D").
Columns with integer values in the range 0 to 9 are converted to discrete attributes.
Other real-valued attributes are treated as continuous (numeric); code "C".
Note that all attributes, including with codes "i" or "m", are returned.
Missing or don't care values are represented as #NULL.
"""
function readdatafile(file)
	neworangeformat(file) ? readneworange(file) : readoldorange(file)
end

function readneworange(file)
	# read first line, list comprehension to split on occurrence of '#', another list 
	# comprehension to get names and codes
	f(x) = (length(x) == 1) ? "" : x[1]
	header = [split(i,'#') for i in readheader(file)]
	names = [i[end] for i in header]
	codes = [f(i) for i in header]
	# read data starting from row 2
	return codes, names, readtable(file, names, 2)
end

function readoldorange(file)
	# in order for readline to read successive lines, the file must be opened and closed
	f = open(file)
	names = readheader(f)
	codes = [uppercase(s) for s in readheader(f)]
	# change "class" to "c" in header line 3
	line3 = [s == "class" ? "c" : s for s in readheader(f)]
	close(f)
	# merge lines 2 and 3 to produce a codes vector
	for i in 1:length(codes)
	 	if line3[i] != ""
	 		codes[i] = line3[i]
	 	end
	 end
	 # read data starting from line 4
	 return codes, names, readtable(file, names, 4)
end

"""
Return a DataTable array object by reading a data file, starting at row, using names.
"""
readtable(file, names, row) = CSV.read(file, delim = '\t', null="?", header=names, datarow=row, weakrefstrings=false)
# readtable(file, names, row) = CSV.read(file, DataTable, delim = '\t', null="?", header=names, datarow=row, weakrefstrings=false)

"""
Returns true if file is Newer Orange format, having '#' in its first line.
"""
neworangeformat(file) = contains(readline(file), "#")

"""
Reads a header line of a data file, splitting on tabs.
"""
readheader(file) = split(chomp(readline(file)),'\t')

"""
Return a string "Newer" or "Older" to correspond to the Orange file format of sourceFile.
"""
function getorangefileformat(sourceFile)
	# if the first line contains the character '#', we conclude the file is in newer
	# Orange format. Else, older Orange file format
	contains(readline(sourceFile), "#") ? "Newer" : "Older"
end
