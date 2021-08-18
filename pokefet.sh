#!/bin/bash

# first gen pokedex
PKDEX_API=https://courses.cs.washington.edu/courses/cse154/webservices/pokedex/pokedex.php 

# original sprites
PKIMG_API=https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/

PKCOUNT=151 

TMPDIR=${TMPDIR:-/tmp}

RANDOM=${RANDOM:-$(hexdump -n 2 -e '"%u"' /dev/urandom)}

HEIGHT=10
WIDTH=18

BOX_DL="╰"
BOX_DR="╯"
BOX_HZ="─"
BOX_VT="|"
BOX_UL="╭"
BOX_UR="╮"

PADDING=10
MAX_TEXT_LEN=30

HZ_LEN=$(($WIDTH - 2 + $PADDING + $MAX_TEXT_LEN))
PRINT_HZ="printf $BOX_HZ%.0s $(seq $HZ_LEN)"

VT_LEN=$(($HEIGHT - 2))
PRINT_VT="printf $BOX_VT\n%.0s"


# IMG_BACKEND="viu" TODO - w3m, kitty icat, maybe imgcat

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

    if ! test -f "$pokemon_image_path"; then # if file doesn't exist, download it 
        curl -L -s "$PKIMG_API/$pokemon_id".png > "$pokemon_image_path" # -L manages 3XX redirects 
    fi 

    printf "$BOX_UL" && $PRINT_HZ && printf "$BOX_UR\n " &&
    
    viu "$pokemon_image_path" -h$HEIGHT -w$WIDTH &&
    
    printf "$BOX_DL" && $PRINT_HZ && printf "$BOX_DR\n"

    # Draw picture - TODO create different protocols (kitty icat (weird --place), maybe w3m)
 
    # TODO format ugly things
    

    printf "%s\n" "$pokemon_name"
    printf "%s\n" "$pokemon_info" | jq '.info.description'

}

main "$@"
