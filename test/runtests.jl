using HamNNNNclassifier
using Base.Test

# write your own tests here
@test train() == println("training...")
@test descriptionreport("/Users/henryolders/hammingnn/other\ datasets/TestAdjustInputs8.tsv") == ""