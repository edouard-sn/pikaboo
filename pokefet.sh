#!/bin/sh

# first gen pokedex
PKDEX_API=https://courses.cs.washington.edu/courses/cse154/webservices/pokedex/pokedex.php 

# original sprites
PKIMG_API=https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/

PKCOUNT=151 

TMPDIR=${TMPDIR:-/tmp}

RANDOM=${RANDOM:-$(od -tu2 -An -N2 < /dev/urandom)} # if RANDOM's not defined, use od to read a 2 bytes sized unsigned integer

SCALE=1

# IMG_BACKEND="viu" TODO

main() 
{ 
    if ! which jq > /dev/null 2>&1; then # 2>&1 redirects error output to standart output
        printf "Please install jq" # TODO better logging
        exit 1
    fi
    # TODO same for viu - curl > function check all deps in loop 

    random_offset=$((RANDOM % PKCOUNT + 1)) # random list index
    random_pokemons="$(curl -L -s $PKDEX_API?pokedex=all | tail -n$random_offset)"
    
    pokemon_name=${random_pokemons%%:*} # remove ':' and what leads it
    pokemon_info=$(curl -L -s "$PKDEX_API?pokemon=$pokemon_name") 
    pokemon_id=$(echo "$pokemon_info" | jq '.info.id') # real id
    pokemon_image_path="$TMPDIR/poke-$pokemon_id.png"

    if ! test -f "$pokemon_image_path"; then 
        curl -L -s "$PKIMG_API/$pokemon_id".png > "$pokemon_image_path" # -L manages 3XX redirects 
    fi 

    printf "%b" "\e[99D" # move cursor 99 to the left
    # TODO a lot of \e#ABCD


    viu "$pokemon_image_path" -h $((10 * SCALE))
    # Draw picture - TODO create different protocols (kitty icat, maybe w3m)

    # TODO format ugly things
    printf "%s\n" "$pokemon_name"
    printf "%s\n" "$pokemon_info" | jq '.info.description'

}

main "$@"
