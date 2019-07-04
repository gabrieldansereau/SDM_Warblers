using Plots

@time include("explo_visualization.jl")

## Map occurences
# Map occurences
map_occ = heatmap(occ.grid)
# Map with coordinates
map_occ_coord = heatmap(longitudes(occ), latitudes(occ), occ.grid)
# Map temperature for same coordinates
temperature_occ = temperature[(minimum(longitudes(occ)), maximum(longitudes(occ))),
                              (minimum(latitudes(occ)), maximum(latitudes(occ)))]
temperature_occ |> x -> heatmap(longitudes(x), latitudes(x), x.grid)

# # Map species per site
# map_species_count = heatmap(species_counts)
# map_occ_per_species = heatmap(occ_obs./species_counts)

# Plot single species occurences
map_single_sp1 = heatmap(reshape(Array(sites_x_species.Setophaga_palmarum), 10, 17))

## Heatmaps for all species (single species per heatmap)
# Option 1: using array of plots, produce plot combining multiple single-species plots
plot_array = Any[]
# 9 species at time, result is ok
for i in 1:9
    push!(plot_array,
          heatmap(reshape(Array(sites_x_species[Symbol(species_list[i])]), 11, 18),
                  title=species_list[i]))
end
map_single_sp_9x = plot(plot_array..., size=(1800,900), aspect_ratio=:equal)

# Option 2: using @eval, produce each species heatmap as 1 element in workspace
for i in 1:length(species_list)
    global j = i
    @eval $(Symbol(string("map_single_sp_", species_list[j]))) = heatmap(reshape(Array(sites_x_species[Symbol(species_list[j])]), 11, 18))
end

# Option 3: using Dict, produce each heatmap as element in dictionnary
species_maps = Dict(Symbol(species_list[i]) =>
                    heatmap(reshape(Array(sites_x_species[Symbol(species_list[i])]), 11, 18))
                    for i=1:length(species_list))
species_maps[Symbol(spewc_vars = temperature, precipitationcies_list[1])]
# Produce all graphs
for i in 1:length(species_list)
    display(species_maps[Symbol(species_list[i])])
end
# useless @eval plot($(Symbol.(string.("map_single_sp_", species_list))))

## Export figures
savefig(map_occ, "fig/map-occurences")
savefig(map_occ_coord, "fig/map-occurences-with-coordinates")
savefig(map_temp, "fig/map-temperature")
savefig(map_occ_bin, "fig/map-occurences-binary-qc")
savefig(map_species_count, "fig/map-species-count")
savefig(map_occ_per_species, "fig/map-occurences-per-species")
savefig(map_single_sp1, "fig/map-single-species-example")
savefig(map_single_sp_9x, "fig/map-single-species-9x.png")
