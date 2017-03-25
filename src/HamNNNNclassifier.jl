#!/Applications/Julia-0.5.1.app/Contents/Resources/julia/bin/julia
# Nearest Neighbor classifier, neural network based, and employing Hamming distances
# This classifier works with any mix of categorical or continuous variables, any number of classes,
# and can handle missing values.

'''
Terminology:
instances: cases; records; examples
    instances can be grouped into sets, eg training set, test set, validation set
    corresponds to a table row in a tabular data base
Dataset
    consists of a number of instances (cases, or examples)
features: variables; fields
    corresponds to a column in a tabular data base. The feature name is the column header
    one of the features will be the class feature or class variable
    features can be combined in various ways, to create new features
feature extraction
    the process of finding those features which provide the best classification performance
classes
    the set of values that the class feature can take
parameters
    eg, the k in k-nearest-neighbors
    often, the work involved in applying machine learning to a problem is to find appropriate or optimal values for the parameters used by a given ML methodology
Hamming distance (may also be called “overlap metric”
bins
    the number of bins or slices to be applied for a given continuous feature
binning
    the process of converting a continuous feature into a discrete feature
discrete (as applied to a feature or variable)
    nominal or ordinal data
continuous (as applied to a feature or variable)
    real-valued
    ordinal data with a range greater than a certain parameter may also be treated as continous data
'''

module HamNNNNclassifier

export train, test

function train()
end

function test()
end

function main()
	train()
	test()
end

# uncomment the line below, to run this module from the command line.
# main()


end # module
