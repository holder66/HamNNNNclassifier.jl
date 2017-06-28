# __precompile__()

# HamNNNNclassifier reporting functions

function descriptionreport(dataFile)
	codes, names, dt = readorangeformat(dataFile)
	#print date, time, software version, platform, file
	f1 = @sprintf "%18s ; HamNNNNclassifier version %5s" Dates.format(now(), "yyyy-m-d HH:MM:SS") version
	println(f1)
	println("Julia version: ", VERSION)
	println("On a Mac ", Sys.cpu_info()[1].model, " '", ccall(:jl_get_cpu_name, Ref{String}, ()), "', \nRunning ", Sys.MACHINE)	
	println("Data File: ", dataFile)
	# s1 = run(`sw_vers`)
	# println(s1)
	# println(versioninfo())
	#print file type
	println("Orange file format.")
	#for the class attribute, list each class and the number of cases, % of total, as well as the total
	# println(dt)
	# for each attribute:
	# index, label, type, numbers of unique,missing, and don't care values, % of total , 
	# totals and % for missing values
	# totals and % for don't care values
	# counts for types of attributes
	# a rank-ordered list of continuous and discrete attributes
	# processing time
end