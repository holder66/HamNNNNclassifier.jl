"""
Return an array containing a rank ordering of the processable attributes in the data file.
For each attribute, its index, name, type, rank value, and optimized slices (for continuous attributes)
are included. The array can be printed with printattributeranking().


function generateattributeranking(dataFile)
	table, codes, classValues = generatetraintesttable(dataFile)
	classes = unique(classValues)
	@show table codes classValues
	# loop thru the attributes
	for i in eachindex(codes)
		d = dropnull(table[i])
		uniques=unique(d)
		@show i uniques length(uniques)
		# loop thru unique values
		for j in eachindex(uniques)
			# make a list of all values for each class
			# note the use of get() to enable the == operator; the default "" will always fail
			@show uniques[j]
			# loop thru each class
			for k in eachindex(classes)
				@show classes[k]
				# loop thru each case 
				for m in eachindex(classValues)
					# test whether
					if get(classes[k],"") == get(classValues[m],"")
						@show [get(v,"") == uniques[j] for v in table[i]]
					end
				end
			end
		end
	end
end
"""
function generateattributeranking(dataFile)
	table, codes, classValues = generatetraintesttable(dataFile)
	classes = unique(classValues)
	labels = names(table)
	# @show labels table
	A = falses(length(codes),length(classValues),length(classes),length(classValues))
	B = zeros(Int32,length(codes),length(classValues),length(classes))
	for i in indices(A,1) # attributes
		uniques = unique(dropnull(table[i]))
		values = table[i]
		# @show i labels[i] values uniques
		for j in eachindex(uniques) # unique values for each attribute
			# @show j uniques[j]
			for k in indices(A,3) # classes
				# @show k classes[k]
				for m in indices(A,4) # cases
					# @show m classValues[m] values[m]
					# set an element for a particular class k and unique value j of an attribute i
					# to true if the class for its case m is the same as class k
					equalsvaluesuniques(x::T,y::T) where {T<:Any} = x == y
					equalsvaluesuniques(x::T,y::T) where {T<:Integer} = get(x,0) == get(y,0)
					equalsvaluesuniques(x::T,y::T) where {T<:Rational} = get(x,0.) == get(y,0.)
					equalsvaluesuniques(x::Nullable{String},y::String) = get(x,"") == y
					equalsvaluesuniques(x::Nullable{Int64},y::Int64) = get(x,0) == y
					equalsvaluesuniques(x::Nullable{Float64},y::Float64) = get(x,0.) == y
					# @show equalsvaluesuniques(values[m], uniques[j])
					A[i,j,k,m] = get(classes[k],"") == get(classValues[m],"") && equalsvaluesuniques(values[m], uniques[j]) 
				end
				# @show A[i,j,k,:] sum(A[i,j,k,:])
				# sum along the m dimension; put the result in B
				B[i,j,k] = sum(A[i,j,k,:])
			end
		end
	end
	# @show size(A) A
	# @show size(B) B
	# @show size(B,1)
	# for each attribute, get the absolute values of the differences between each class
	C = Array{Int64,2}(length(codes), 2)
	for i in indices(B,1) # attributes
		rank = 0
		for j in indices(B,2) # cases
			for k in indices(B,3) # classes
#rank1 = [abs(x - y) for (x,y) in zip(B)]
				for m in k:size(B,3) 
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
