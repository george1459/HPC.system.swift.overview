iden_22 = open(joinpath(dirname(@__FILE__), "..", "2020_09", "iden_4FGL_v22.txt"), "r")
unid_22 = open(joinpath(dirname(@__FILE__), "..", "2020_09", "unid_4FGL_v22.txt"), "r")
iden_27 = open(joinpath(dirname(@__FILE__), "..", "2020_09", "iden_4FGL_v27.txt"), "r")
unid_27 = open(joinpath(dirname(@__FILE__), "..", "2020_09", "unid_4FGL_v27.txt"), "r")
outfd = open(joinpath(dirname(@__FILE__), "..", "2020_09", "database.csv"), "w")

csv_title = "source_name,source_type,source_RA,source_DEC,22present,27present"

iden_22_sources = Dict()
iden_27_sources = Dict()

for line in readlines(iden_22)
    entries = split(line)
    source_name = entries[2] * "_" * entries[3]
    source_type = entries[4]
    ra = entries[5]
    dec = entries[6]
    iden_22_sources[source_name] = "$source_name,$source_type,$ra,$dec"
end

for line in readlines(iden_27)
    entries = split(line)
    source_name = entries[2] * "_" * entries[3]
    source_type = entries[4]
    ra = entries[5]
    dec = entries[6]
    iden_27_sources[source_name] = "$source_name,$source_type,$ra,$dec"
end

output = Any[]

for (key, value) in iden_22_sources
    if haskey(iden_27_sources, key)
        push!(output, value * ",1,1")
    else
        push!(output, value * ",1,0")
    end
end

for (key, value) in iden_27_sources
    if !haskey(iden_22_sources, key)
        push!(output, value * ",0,1")
    end
end

sort!(output, by = x -> split(x, ',')[2])

write(outfd, csv_title * "\n")
for i in output
    write(outfd, i * "\n")
end



# for line in readlines(iden_27)
#     entries = split(line)
#     source_name = entries[2] * "_" * entries[3]
#     source_type = entries[4]
#     ra = entries[5]
#     dec = entries[6]
    
#     found = false
#     if source_type in keys(iden_22_lines)
#         for entry in iden_22_lines[source_type]
#             if occursin(source_name, entry)
#                 entry .*= "1"
#                 found = true
#                 break
#             end
#         end
#     else
#         iden_22_lines[source_type] = Any[]
#     end

#     if found == false
#         push!(iden_22_lines[source_type], "$source_name,$source_type,$ra,$dec,0,1")
#     end
# end



# for (key, value) in iden_22_lines
#     if last(value) == ','
#         value .*= "0"
#     end
# end

# print(iden_22_lines)

# source_name = match(r"4FGL\sJ[\d.+-]*", line)
# if (source_name !== nothing) #&& (line != "\n")
#     source_type = strip(match(r"\s[a-zA-Z]{3}\s", line), [' '])
# else
#     throw(ErrorException("No match found"))
# end