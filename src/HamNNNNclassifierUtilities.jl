__precompile__()

# HamNNNNclassifier utility functions

"""
Reads a dataset file and massages it to return a datatable suitable for training or testing,
and a vector containing values of the class attribute.
minInteger is a parameter that determines the cutoff for considering an integer attribute
as being a categorical (ie discrete) attribute. If the number of uniques for an attribute
is equal to or greater than minInteger; treat as a continuous attribute; else discrete.
"""
function generatetraintesttable(dataFile)
	codes, names, table = readdatafile(dataFile)
	i, classAttributeValues = extractclassattribute(table, codes)
	# @show codes
	for i in 1:length(names)
		# take out null values to get type purity for type dispatching
		d = dropnull(table[i])
		# for missing codes, fill in "C" or "D"
		typeCode = generateattributecode(d, codes[i])
		# convert "C" to "D" for integer attributes in range 0 to 9
		if typeCode == "C"
			typeCode = changeattributetype(d)
		end
		# add the new codes to the existing codes, in a newCodes array
		codes[i] = typeCode
	end
	delete!(table, unusedcolumns(codes))
	# @show table unusedcodes(codes) classAttributeValues
	return table, unusedcodes(codes), classAttributeValues
end

"""
Takes a vector of orange format codes and returns a vector of indices for delete codes. 
"""
unusedcolumns(codes, deletes=["c", "i", "m", "w"]) = [i for i in eachindex(codes) if codes[i] in deletes]
unusedcodes(codes, deletes=["c", "i", "m", "w"]) = [codes[i] for i in eachindex(codes) if ∉(codes[i], deletes)]

function extractclassattribute(table, codes)
	# returns an index for the class attribute within the data table, and
	# a vector with the values for the class attribute
	for i in eachindex(codes)
		if codes[i] == "c"
			return i, table[i]
		end
	end
end

"""
Round to the number of decimal places desired.
"""
roundpercentage(a::Float64, decimals::Integer) = a < 10.0 ? signif(a,decimals+1) : signif(a,decimals+2)

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
describecontinuousattribute{T<:Real}(a::AbstractArray{T}) = return extrema(a), mean(a), median(a)

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


"""
Return an array of the attributes sorted into rank order for relative ability to separate the classes.
"""
function generateattributeranking(dataFile)
	cs(x::NullableArrays.NullableArray{Int64,1}) = convert(Array, x, 0)
	cs(x::NullableArrays.NullableArray{Float64,1}) = convert(Array, x, 0.)
	cs(x::NullableArrays.NullableArray{String,1}) = convert(Array, x, "")	
	table, codes, classVals = generatetraintesttable(dataFile)
	classValues = cs(classVals)
	classes = unique(classValues)
	labels = names(table)
	A = falses(length(codes),length(classValues),length(classes),length(classValues))
	B = zeros(Int32,length(codes),length(classValues),length(classes))
	for i in indices(A,1) # attributes
		uniques = unique(dropnull(table[i]))
		# @show uniques
		# @show table[i]
		values = cs(table[i])
		# @show i labels[i] values uniques
		for j in eachindex(uniques) # unique values for each attribute
			# @show j uniques[j]
			for k in indices(A,3) # classes
				# @show k classes[k]
				for m in indices(A,4) # cases
					# @show m classValues[m] values[m]
					# set an element for a particular class k and unique value j of an attribute i
					# to true if the class for its case m is the same as class k
					# @show classes[k] classValues[m] values[m] uniques[j]
					A[i,j,k,m] = classes[k] == classValues[m] && values[m] == uniques[j]
					# B[i,j,k] = sum(classes[k] == classValues[m] && values[m] == uniques[j])
					
				end
				# @show A[i,j,k,:] sum(A[i,j,k,:])
				# sum along the m dimension; put the result in B
				B[i,j,k] = sum(A[i,j,k,:])
			end
		end
	end
	# @show size(A) A
	# @show size(B,1)
	# for each attribute, get the absolute values of the differences between each class
	C = Array{Int64,2}(length(codes), 2)
	for i in indices(B,1) # attributes
		rank = 0
		for j in indices(B,2) # cases
			for k in indices(B,3) # classes
				for m in k:size(B,3) # other classes
					# @show i j k m
					rank += abs(B[i,j,k] - B[i,j,m])
				end
			end
		end
		# @show i labels[i] rank
		C[i,1] = rank
		C[i,2] = i
	end
	D = sortrows(C,rev=true)
	# @show labels table D
	return labels, codes, table, D
end

