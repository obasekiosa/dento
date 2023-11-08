#!/usr/bin/env bash
# exit on error
set -o errexit

export PHX_SERVER=true  
# # Initial setup
# mix deps.get #--only prod
# MIX_ENV=prod mix compile

# mix ecto.migrate

# # Compile assets
# mix phx.digest

# # Build the release and overwrite the existing release directory
# MIX_ENV=prod mix release --overwrite


#  ./_build/prod/rel/dento/bin/dento start 


# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
MIX_ENV=prod mix assets.deploy

# Custom tasks (like DB migrations)
MIX_ENV=prod mix ecto.migrate

# Finally run the server
MIX_ENV=prod mix phx.server
