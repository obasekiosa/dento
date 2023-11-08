#!/usr/bin/env bash
# exit on error
set -o errexit

export PHX_SERVER=true  
# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
mix phx.digest

# Build the release and overwrite the existing release directory
MIX_ENV=prod mix release --overwrite


 ./_build/prod/rel/dento/bin/dento start 