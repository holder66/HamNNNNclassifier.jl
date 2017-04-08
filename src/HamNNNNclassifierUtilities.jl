__precompile__()

# HamNNNNclassifier utility functions

"""
Read a dataset file in Orange format; returns a 
"""
nas=["", "NULL", "NA", "?"]

function readorangeformat(source, nas)
	println("source file: ", source)
	return readtable(source, nastrings=nas, normalizenames=false, makefactors=true)
end

dataset="/Users/henryolders/hammingnn/other\ datasets/TestAdjustInputs8.tsv"
datat=readorangeformat(dataset, nas)
println(typeof(datat))
println(describe(datat))
# printtable(datat)
