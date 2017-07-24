# __precompile__()

# HamNNNNclassifier reporting functions

function printheader()
	#print date, time, software version, platform, file
	print("\n\n")
	f1 = @sprintf "%18s ; HamNNNNclassifier version %5s" Dates.format(now(), "yyyy-m-d HH:MM:SS") version
	print_with_color(:blue, f1, "\n"; bold=true)
	println("Julia version: ", VERSION)
	println("On a Mac ", Sys.cpu_info()[1].model, " '", ccall(:jl_get_cpu_name, Ref{String}, ()), "', \nRunning ", Sys.MACHINE)	
	run(`sw_vers`) # shows os version
	println()
end 

function printdatafiledescription(dataFile)
	printheader()
	print_with_color(:blue, "Data File:\n"; bold=true)
	# print file path
	println(dataFile)
	# print file type
	println("Orange file format: ", getorangefileformat(dataFile), "\n")
	codes, names, dt = readorangeformat(dataFile, getorangefileformat(dataFile))
	@show codes names
	# describe(dt)
	#for the class attribute, list each class and the number of cases, % of total, as well as the total
	printclassdescription(codes, names, dt)
	printattributedescriptions(codes, names, dt)
	# @show extractclassattribute(dt, codes)
	# @show deleteunusedcolumns(dt, :age)
	# for each attribute:
	# index, label, type, numbers of unique,missing, and don't care values, % of total , 
	# totals and % for missing values
	# totals and % for don't care values
	# counts for types of attributes
	# a rank-ordered list of continuous and discrete attributes
	# processing time
end
	
function printclassdescription(codes, names, table)
	#for the class attribute, list each class and the number of cases, % of total, as well as the total
	i, classesVector = extractclassattribute(table, codes)
	classAttributeName = names[i]
	println("Class Attribute: ", classAttributeName)
	casesNo = length(classesVector)
	# extract unique values
	# as it is easy to print out the strings for the levels of a categorical array, do the conversion.
	cv = categorical(classesVector)
	# levels is simply the array of uniques, for a categorical array
	levels = CategoricalArrays.levels(cv)
	# uniques works well as keys for getting values out of a countmap dict
	uniques = unique(cv)
	# create a dict of uniques and their counts
	cm = countmap(classesVector)
	# @show cm levels uniques
	print_with_color(:blue, "\nClass        Number of cases      Percent of total\n"; bold=true)
	foreach((x,y) -> print(rpad(y,20,),rpad(get(cm,x,""),20,),signif(get(cm,x,"")*100/casesNo,4),"\n"), uniques, levels)
	print_with_color(:bold, "total: ", casesNo, " cases\n")
end

function printattributedescriptions(codes, names, table)
	# for each attribute, print its name, type, number of uniques, number and % of missing values;
	# for continuous attributes, print the minimum, maximum, mean, and median
	# start with a header
	println()
	print_with_color(:blue, " Index   Label             Type   Missing      %   Uniques   Min   Max   Mean   Median    Unique Values\n"; bold=true)
	missingTotal = 0
	newCodes = Array{String}(length(names))
	for i in 1:length(names)
		# print the index and the attribute name
		name = rpad(names[i], 18, )
		print(lpad(i,6,),"   ", name)
		d = dropnull(table[i])
		# print the orange format code; if missing, print "C" for continuous (ie numeric)
		# and "D" for discrete (ie categorical) attributes
		if codes[i] == ""
			typeCode = numericattribute(d) ? "C" : "D"
		else
			typeCode = codes[i]
		end
		print(rpad(typeCode,7,))
		# add the new codes to the existing codes, in a newCodes array
		newCodes[i] = typeCode
		# print number and percent of missing values (nulls)
		missing = length(table[i]) - length(d)
		missingTotal += missing
		missingPerCent = roundpercentage(missing * 100 / length(table[i]),2)
		print(lpad(missing,7,), missingPerCent > 0.0 ? lpad(missingPerCent,7,) : "       ")
		# print number of unique values
		print(lpad(length(unique(d)),10,))
		if numericattribute(d)
			((min, max),mean,median) = describeattribute(d)
			print(lpad(min,6,), lpad(max,6,), lpad(roundpercentage(mean,1),7,), lpad(roundpercentage(median,1),9,))	
		else
			uniquesNo, uniques = describeattribute(d)
			print("                                ")
			for i in 1:length(uniques)
				print(uniques[i]," ")
			end
		end
		print("\n")
	end
	# print the total number of missing values and its percentage
	valuesTotal = prod(size(table))
	print_with_color(:bold, "Total missing values: ", missingTotal, " out of ", valuesTotal)
	print_with_color(:bold, " (", roundpercentage(missingTotal * 100 / valuesTotal,2), "%)\n\n")
	# print the counts for each attribute type and the total
	print_with_color(:blue, "Attribute Type   Count\n"; bold=true)
	# print(countmap(newCodes), "\n")
	for (key, value) in countmap(newCodes)
		println(rpad(key,14,), lpad(value,8,))
	end
	print_with_color(:bold, "Total count:        ", length(newCodes), "\n")
end
	