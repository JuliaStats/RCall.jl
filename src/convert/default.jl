# logic for default rcopy

"""
`rcopy(r)` copies the contents of an R object into a corresponding canonical Julia type.
"""
rcopy(r::RObject{S}; kwargs...) where S<:Sxp = rcopy(r.p; kwargs...)

function rcopy(s::Ptr{S}; kwargs...) where S<:Sxp
    protect(s)
    try
        class = rcopy(Symbol, getclass(s, true))
        if method_exists(rcopytype, Tuple{Type{RClass{class}}, Ptr{S}})
            return rcopy(rcopytype(RClass{class}, s), s; kwargs...)
        else
            return rcopy(rcopytype(s), s; kwargs...)
        end
    finally
        unprotect(1)
    end
end

# NilSxp
rcopy(::Ptr{NilSxp}) = null

# SymSxp and CharSxp
rcopy(s::Ptr{SymSxp}) = rcopy(Symbol,s)
rcopy(s::Ptr{CharSxp}) = rcopy(String,s)

# StrSxp
function rcopytype(s::Ptr{StrSxp})
    if anyna(s)
        DataArray{String}
    elseif length(s) == 1
        String
    else
        Array{String}
    end
end

if Pkg.installed("CategoricalArrays") < v"0.2.0"
    function rcopytype(s::Ptr{IntSxp})
        if isFactor(s)
            if anyna(s)
                NullableCategoricalArray
            else
                CategoricalArray
            end
        elseif anyna(s)
            DataArray{Int}
        elseif length(s) == 1
            Int
        else
            Array{Int}
        end
    end
else
    function rcopytype(s::Ptr{IntSxp})
        if isFactor(s)
            CategoricalArray
        elseif anyna(s)
            DataArray{Int}
        elseif length(s) == 1
            Int
        else
            Array{Int}
        end
    end
end

function rcopytype(s::Ptr{RealSxp})
    if anyna(s)
        DataArray{Float64}
    elseif length(s) == 1
        Float64
    else
        Array{Float64}
    end
end

function rcopytype(s::Ptr{CplxSxp})
    if anyna(s)
        DataArray{Complex128}
    elseif length(s) == 1
        Complex128
    else
        Array{Complex128}
    end
end

function rcopytype(s::Ptr{LglSxp})
    if anyna(s)
        DataArray{Bool}
    elseif length(s) == 1
        Bool
    else
        BitArray
    end
end

function rcopytype(s::Ptr{RawSxp})
    if anyna(s)
        DataArray{UInt8}
    elseif length(s) == 1
        UInt8
    else
        Array{UInt8}
    end
end

# Default behaviors of copying R vectors to arrays and dataarrays
for (J,S) in ((:Int,:IntSxp),
                 (:Float64, :RealSxp),
                 (:Complex128, :CplxSxp),
                 (:Bool, :LglSxp),
                 (:String, :StrSxp),
                 (:UInt8, :RawSxp))
    @eval begin
        function rcopy(::Type{Vector},s::Ptr{$S})
            protect(s)
            try
                class = rcopy(Symbol, getclass(s, true))
                if method_exists(eltype, Tuple{Type{RClass{class}}, Ptr{$S}})
                    return rcopy(Vector{eltype(RClass{class}, s)}, s)
                else
                    return rcopy(Vector{$J},s)
                end
            finally
                unprotect(1)
            end
        end
        function rcopy(::Type{Array},s::Ptr{$S})
            protect(s)
            try
                class = rcopy(Symbol, getclass(s, true))
                if method_exists(eltype, Tuple{Type{RClass{class}}, Ptr{$S}})
                    return rcopy(Array{eltype(RClass{class}, s)}, s)
                else
                    return rcopy(Array{$J},s)
                end
            finally
                unprotect(1)
            end
        end
        function rcopy(::Type{DataVector},s::Ptr{$S})
            protect(s)
            try
                class = rcopy(Symbol, getclass(s, true))
                if method_exists(eltype, Tuple{Type{RClass{class}}, Ptr{$S}})
                    return rcopy(DataVector{eltype(RClass{class}, s)}, s)
                else
                    return rcopy(DataVector{$J},s)
                end
            finally
                unprotect(1)
            end
        end
        function rcopy(::Type{DataArray},s::Ptr{$S})
            protect(s)
            try
                class = rcopy(Symbol, getclass(s, true))
                if method_exists(eltype, Tuple{Type{RClass{class}}, Ptr{$S}})
                    return rcopy(DataArray{eltype(RClass{class}, s)}, s)
                else
                    return rcopy(DataArray{$J},s)
                end
            finally
                unprotect(1)
            end
        end
    end
end

# VecSxp
function rcopytype(s::Ptr{VecSxp}; kwargs...)
    if isFrame(s)
        DataFrame
    elseif isnull(getnames(s))
        Array{Any}
    else
        Dict{Symbol,Any}
    end
end

# FunctionSxp
rcopy(s::Ptr{S}) where S<:FunctionSxp = rcopy(Function,s)

# TODO: LangSxp
rcopy(l::Ptr{LangSxp}) = RObject(l)
rcopy(r::RObject{LangSxp}) = r

# Fallback for non SEXP
rcopy(r) = r


# logic of default sexp

"""
`sexp(x)` converts a Julia object `x` to a pointer to a corresponding Sxp Object.
"""

RObject(s) = RObject(sexp(s))

# nothing
sexp(::Void) = sexp(Const.NilValue)

# Symbol
sexp(s::Symbol) = sexp(SymSxp,s)

# DataFrame
sexp(d::AbstractDataFrame) = sexp(VecSxp, d)

# DataTable
# sexp(d::AbstractDataTable) = sexp(VecSxp, d)


# Number, Array and DataArray
for (J,S) in ((:Integer,:IntSxp),
                 (:AbstractFloat, :RealSxp),
                 (:Complex, :CplxSxp),
                 (:Bool, :LglSxp),
                 (:AbstractString, :StrSxp))
    @eval begin
        sexp(a::AbstractArray{T}) where T<:$J = sexp($S,a)
        sexp(a::AbstractDataArray{T}) where T<:$J = sexp($S,a)
        sexp(v::$J) = sexp($S,v)
    end
end

# Fallback: convert AbstractArray to VecSxp (R list)
sexp(a::AbstractArray) = sexp(VecSxp,a)

# Associative
sexp(d::Associative) = sexp(VecSxp,d)

# Null
sexp(x::Null) = sexp(Const.NilValue)

# Nullable
sexp(x::Nullable{Union{}}) = sexp(NaInt)

for (J,S) in ((:Integer,:IntSxp),
                 (:AbstractFloat, :RealSxp),
                 (:Complex, :CplxSxp),
                 (:Bool, :LglSxp),
                 (:AbstractString, :StrSxp))
    @eval begin
        sexp(x::Nullable{T}) where T<:$J = sexp($S, x)
        sexp(v::NullableArray{T}) where T<:$J = sexp($S, v)
    end
end

# RawSxp
sexp(a::AbstractArray{UInt8}) = sexp(RawSxp, a)
sexp(a::AbstractDataArray{UInt8}) = sexp(RawSxp, a)
sexp(a::NullableArray{UInt8}) = sexp(RawSxp, a)
sexp(x::UInt8) = sexp(RawSxp, x)


if Pkg.installed("CategoricalArrays") < v"0.2.0"
    CAtypes = [:NullableCategoricalArray, :CategoricalArray]
else
    CAtypes = [:CategoricalArray]
end

for typ in CAtypes
    @eval sexp(v::$typ) = sexp(IntSxp, v)
end

# AxisArray
for (J,S) in ((:Integer,:IntSxp),
                 (:AbstractFloat, :RealSxp),
                 (:Complex, :CplxSxp),
                 (:Bool, :LglSxp),
                 (:AbstractString, :StrSxp))
    @eval sexp(aa::AxisArray{T}) where T<:$J = sexp($S, aa)
end

# DataTime
sexp(d::Date) = sexp(RealSxp, d)
sexp(d::AbstractArray{Date}) = sexp(RealSxp, d)
sexp(d::AbstractDataArray{Date}) = sexp(RealSxp, d)
sexp(d::NullableArray{Date}) = sexp(RealSxp, d)
sexp(d::DateTime) = sexp(RealSxp, d)
sexp(d::AbstractArray{DateTime}) = sexp(RealSxp, d)
sexp(d::AbstractDataArray{DateTime}) = sexp(RealSxp, d)
sexp(d::NullableArray{DateTime}) = sexp(RealSxp, d)

# Function
sexp(f::Function) = sexp(ClosSxp, f)
