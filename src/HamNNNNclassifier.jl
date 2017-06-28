#!/Applications/Julia-0.5.app/Contents/Resources/julia/bin/julia
# Nearest Neighbor classifier, neural network based, and employing Hamming distances
# This classifier works with any mix of categorical or continuous variables, any number of classes,
# and can handle missing values.

module HamNNNNclassifier
	
export main, train, test, readorangeformat, descriptionreport

using DataTables, CategoricalArrays, CSV, Query

include("HamNNNNclassifierUtilities.jl") # 
include("HamNNNNclassifierReports.jl")

global version = v"0.1"

"""
Terminology:
instances: cases; records; examples
    instances can be grouped into sets, eg training set, test set, validation set
    corresponds to a table row in a tabular data base
Dataset
    consists of a number of instances (cases, or examples)
features: variables; fields; attributes
    corresponds to a column in a tabular data base. The feature name is the column header
    one of the features will be the class feature or class variable (also called the target variable, or
	class attribute)
    features can be combined in various ways, to create new features
feature extraction
    the process of finding those features which provide the best classification performance
classes
    the set of values that the class feature can take
parameters
    eg, the k in k-nearest-neighbors
    often, the work involved in applying machine learning to a problem is to find appropriate or optimal values for the parameters used by a given ML methodology
Hamming distance (may also be called "overlap metric"
bins
    the number of bins or slices to be applied for a given continuous feature
binning
    the process of converting a continuous feature into a discrete feature
discrete (as applied to a feature or variable)
    nominal or ordinal data
continuous (as applied to a feature or variable)
    real-valued
    ordinal data with a range greater than a certain parameter may also be treated as continous data
"""

# """
# The Orange data format encodes information into the column label: the names of the attributes are augmented
# with prefixes that define attribute type (continuous, discrete, time, string) and role (class or meta attribute) Prefixes are separated from the attribute name with a hash sign ("#"). Prefixes for attribute roles are:
#
# c: class attribute
# m: meta attribute
# i: ignore the attribute
# w: instance weights
#
# and for the type:
#
# C: Continuous
# D: Discrete
# T: Time
# S: String
# """

# """
# # Design Principles
# To work with the MLBase Julia package, it will be helpful to have functions which can be used
# as parameters for MLBase functions (see the MLBase documentation), eg for cross_validate,
# estfun –
# The estimation function, which takes a vector of training indices as input and returns a learned model, as:
# model = estfun(train_inds)
# evalfun –
# The evaluation function, which takes a model and a vector of testing indices as input and returns a score that indicates the goodness of the model, as
# score = evalfun(model, test_inds)
#
# """


function train()
	println("training...")
end

function test()
	println("testing...")
end

dataFile="/Users/henryolders/hammingnn/other\ datasets/TestAdjustInputs8.tsv"

function main()
	train()
	test()
	descriptionreport(dataFile)
end

# uncomment the line below, to run this module from the command line.
main()


end # module
