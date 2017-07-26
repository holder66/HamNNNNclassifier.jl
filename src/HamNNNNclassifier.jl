#!/Applications/Julia-0.6.app/Contents/Resources/julia/bin/julia
# Nearest Neighbor classifier, neural network based, and employing Hamming distances
# This classifier works with any mix of categorical or continuous variables, any number of classes,
# and can handle missing values.

__precompile__()

module HamNNNNclassifier
	
export main, train, test, readdatafile, printdatafiledescription, hamclass, generatetraintesttable

using DataTables, CategoricalArrays, CSV, Query, StatsBase, ArgParse

include("HamNNNNclassifierUtilities.jl")
include("HamNNNNclassifierio.jl")
include("HamNNNNclassifierReports.jl")

global version = v"0.1"


# Terminology:
# instances: cases; records; examples
#     instances can be grouped into sets, eg training set, test set, validation set
#     corresponds to a table row in a tabular data base
# Dataset
#     consists of a number of instances (cases, or examples)
# features: variables; fields; attributes
#     corresponds to a column in a tabular data base. The feature name is the column header
#     one of the features will be the class feature or class variable (also called the target variable, or
# 	class attribute)
#     features can be combined in various ways, to create new features
# feature extraction
#     the process of finding those features which provide the best classification performance
# classes
#     the set of values that the class feature can take
# parameters
#     eg, the k in k-nearest-neighbors
#     often, the work involved in applying machine learning to a problem is to find appropriate or optimal values for the parameters used by a given ML methodology
# Hamming distance (may also be called "overlap metric"
# bins
#     the number of bins or slices to be applied for a given continuous feature
# binning
#     the process of converting a continuous feature into a discrete feature
# discrete (as applied to a feature or variable)
#     nominal or ordinal data
# continuous (as applied to a feature or variable)
#     real-valued
#     ordinal data with a range greater than a certain parameter may also be treated as continous data

# NEWER ORANGE FORMAT:
# Prefixed attributes contain a one- or two-lettered prefix, followed by '#'
# and the attribute name. The first letter of the prefix can be:
# 	'm' for meta-attributes
# 	'i' to ignore the attribute
# 	'c' to define the class attribute
#
# the second letter of the prefix can be:
# 	'D' for discrete
# 	'C' for continuous
# 	'S' for string
# 	'B' for basket
# if there are no prefixes for an attribute (ie just the attribute name)
# then the attribute will be treated as discrete, unless the actual values
# are numbers, in which case it will be treated as continuous.
#
# OLDER ORANGE FORMAT:
# the information about variable type, etc is contained in two rows, following the row with
# attribute names:
# in the second line:
# 	'd' or 'discrete' or a list of values: denotes a discrete attribute
# 	'c' or 'continuous': denotes a continuous attribute
# 	'string' denotes a string variable, which we ignore
# 	'basket': these are continuous-valued meta attributes; ignore
# 	it may also contain a string of values separated by spaces. Use these
# 	as the values for a discrete attribute.
# the third line contains optional flags:
# 	'i' or 'ignore'
# 	'c' or 'class': there can only be one class attribute. If none is found,
# 	 use the last attribute as the class attribute.
# 	'm' or 'meta': meta attribute, eg weighting information; ignore
# 	'-dc' followed by a value: indicates how a don't care is represented.

# # Design Principles
# To work with the MLBase Julia package, it will be helpful to have functions which can be used
# as parameters for MLBase functions (see the MLBase documentation), eg for cross_validate,
# estfun –
# The estimation function, which takes a vector of training indices as input and returns a learned model, as:
# model = estfun(train_inds)
# evalfun –
# The evaluation function, which takes a model and a vector of testing indices as input and returns a score that indicates the goodness of the model, as
# score = evalfun(model, test_inds)

function hamclass()
	println("hamclass...")
end

function train()
	println("training...")
end

function test()
	println("testing...")
end

function parse_commandline()
	s = ArgParseSettings()

	@add_arg_table s begin
		"--opt1"
			help = "an option with an argument"
		"--opt2", "-o"
			help = "another option with an argument"
			arg_type = Int
			default = 0
		"--flag1"
			help = "an option without argument, i.e. a flag"
			action = :store_true
		"arg1"
			help = "a positional argument"
			required = true
	end

	return parse_args(s)
end

# function main()
# 	parsed_args = parse_commandline()
# 	println("Parsed args:")
# 	for (arg,val) in parsed_args
# 		println("  $arg  =>  $val")
# 	end
# end

paramDict = Dict

dataFile="/Users/henryolders/hammingnn/other\ datasets/TestAdjustInputs8.tsv"

function main()
	printdatafiledescription(dataFile)
	printattributeranking(dataFile)
	train_x, train_codes, train_y = generatetraintesttable(dataFile)
	@show train_x train_codes train_y
	train()
	test()
end

# uncomment the line below, to run this module from the command line.
main()


end # module
