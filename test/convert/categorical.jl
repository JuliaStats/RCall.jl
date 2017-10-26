using CategoricalArrays

# CategoricalArrays
v = CategoricalArray(repeat(["a", "b"], inner = 5))
@test isequal(rcopy(CategoricalArray,RObject(v)), v)
v = CategoricalArray(repeat(["a", "b"], inner = 5), ordered=true)
@test isequal(rcopy(CategoricalArray,RObject(v)), v)
@test_throws ErrorException rcopy(NullableArray,R"as.factor(c('a','a','c'))")
@test CategoricalArrays.levels(rcopy(CategoricalArray,R"factor(c('a','a','c'))")) == ["a","c"]
@test CategoricalArrays.isordered(rcopy(CategoricalArray,R"ordered(c('a','a','c'))"))

a = Array{Union{Null, String}}(repeat(["a", "b"], inner = 5))
a[repeat([true, false], outer = 5)] = null
v = CategoricalArray(a)
@test isequal(rcopy(CategoricalArray,RObject(v)), v)
v = CategoricalArray(a, ordered=true)
@test isequal(rcopy(CategoricalArray,RObject(v)), v)
@test CategoricalArrays.levels(rcopy(CategoricalArray,R"factor(c('a',NA,'c'))")) == ["a","c"]
@test CategoricalArrays.isordered(rcopy(CategoricalArray,R"ordered(c('a',NA,'c'))"))
