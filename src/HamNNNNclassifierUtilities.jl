# __precompile__()

# HamNNNNclassifier utility functions

"""
Reads a dataset file and massages it to return a datatable suitable for training or testing,
and a vector containing values of the class attribute.
minInteger is a parameter that determines the cutoff for considering an integer attribute
as being a categorical (ie discrete) attribute. If the number of uniques for an attribute
is equal to or greater than minInteger; treat as a continuous attribute; else discrete.
"""
function generatetraintesttable(dataFile, minInteger = 10)
	codes, names, table = readorangeformat(dataFile, getorangefileformat(dataFile))
	i, classAttributeValues = extractclassattribute(table, codes)
	# for integer attributes with uniques fewer than minInteger, change code to "D"
	
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
	# specify the number of decimal places desired
	a < 10.0 ? signif(a,decimals+1) : signif(a,decimals+2)
end

"""
The following two function methods are used to differentiate numeric (ie continuous)
attributes from non-numeric, ie strings (discrete).
"""
numericattribute{T<:Real}(a::AbstractArray{T}) = true
numericattribute(a::AbstractArray) = false

"""
The first method returns true for integer attributes; the second returns false for 
non-integer attributes
"""
integerattribute{T<:Integer}(a::AbstractArray{T}) = true
integerattribute(a::AbstractArray) = false

"""
the first method, for numeric attributes, returns the minimum, maximum, mean, and median.
the second method, for string (ie discrete) attributes, returns the number of unique values
and an array with the unique values.
"""
function describecontinuousattribute{T<:Real}(a::AbstractArray{T})
	return extrema(a), mean(a), median(a)
end

function describediscreteattribute(a::AbstractArray)
	u = unique(a)
	return length(u), u
end

"""
Provide codes for continuous or discrete attributes ("C" or "D" respectively) if no code
was in the data file, based on whether the attribute values are numbers or not.
"""
function generateattributecode(vector, code)
	if code != ""
		return code
	else
		# test for whether attribute values are from type Real
		return numericattribute(vector) ? "C" : "D"
	end
end

"""
Change a continuous attribute to discrete, if the attribute is an integer and is a single digit.
"""
function changeattributetype(vector)
	min, max = extrema(vector)
	if integerattribute(vector) && min >= 0 && max < 10
		return "D"
	else
		return "C"
	end
end
