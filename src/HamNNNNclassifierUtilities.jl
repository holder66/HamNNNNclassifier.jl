# __precompile__()

# HamNNNNclassifier utility functions

"""
Read a dataset file in Orange format; returns a DataTable object.
Columns with string entries are set to categorical vectors.
"""

function readorangeformat(sourceFile, nullsString=["", "NULL", "NA", "?"])
	# this function returns an array with the orange format attribute codes,
	# and a datatable with the data
	# get the header line, split it into words, and strip off the orange format codes
	header=split(chomp(readline(sourceFile)),'\t')
	header1=[split(i,'#') for i in header]
	# @show attr attr1
	columnNames = [i[end] for i in header1]
	# use a function to generate empty codes if none are included
	f(x) = (length(x) == 1) ? "" : x[1]
	columnCodes = [f(i) for i in header1]
	# @show attributeCodes
	# read in the file as a datatable, substituting the stripped attribute names
	# for the time being, CSV.read does not support nastring, so we just use "?" to indicate null values
	table = CSV.read(sourceFile, DataTable, delim = '\t', null="?", header=columnNames, datarow=2)
	return columnCodes, columnNames, table
end

function deleteunusedcolumns(dataTable, columnCodes)
	return delete!(dataTable, :firstname)
end

function convertcodestosymbols(codes)
	f(x) = (x == "") ? :null : Symbol(x)
	return [f(x) for x in codes]
end

function extractclassattribute(dataTable, columnCodes)
	@show columnCodes
	sy = convertcodestosymbols(columnCodes)
	i = 1
	for s in sy
		if s == :c
			break
		end
		i += 1
	end
	@show i
	@show dataTable[i]
	return i, dataTable[i]
end

# codes, datat=readorangeformat(dataFile)
# @show codes datat
# # printtable(datat) # note that printtable does not deal with NullableCategoricalArrays
# println("mean of age: ", mean(dropnull(datat[:age])))
# x = @from i in datat begin
# @where i.age>60
# @select {i.age, i.height}
# @collect DataTable
# end
# # @show x
# pdv=categorical(datat[:city])
# @show pdv levels(pdv) length(levels(pdv))
# # @show deleteunusedcolumns(datat, codes)
# @show extractclassattribute(datat, codes)
