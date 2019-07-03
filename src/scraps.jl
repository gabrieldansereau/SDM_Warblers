#### Scraps ####

## Visualize data
# Dataframe names
names(warblers)
# First entries (~head)
first(df,6)
# Show all columns
show(first(df,6), allcols=true)
# Describe columns (~summary)
show(describe(df), allcols=true)
# Select on conditions (year)
df_full = dropmissing(df, :year)
df_full[df_full.year .< 1900, :]
# Record from 1700 ???
show(warblers[warblers.year .=== 1700, :], allcols=true)
