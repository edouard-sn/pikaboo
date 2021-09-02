#!/bin/bash

# first gen english pokedex 
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
BOX_VT="│"
BOX_UL="╭"
BOX_UR="╮"

PADDING=2
MAX_TEXT_LEN=30

HZ_LEN=$(($WIDTH + $((PADDING * 3))+ $MAX_TEXT_LEN - 1))

PRINT_HZ="printf $BOX_HZ%.0s $(seq $HZ_LEN)"
PRINT_VT="printf $BOX_VT$(tput cuf $HZ_LEN)$BOX_VT\n%.0s $(seq $HEIGHT)"

SET_COLOR="tput setaf"
RESET_TXTFX="tput sgr0"

RED=1
BLUE=4

main() 
{ 
    which jq &> /dev/null || (echo "Please install jq"; exit 1)


    # Get pokemon assets and info
    if [ "$#" -eq 0 ]; then
        random_offset=$((RANDOM % PKCOUNT + 1))
        random_pokemons="$(curl -L -s $PKDEX_API?pokedex=all | tail -n$random_offset)" 
        pokemon_name=${random_pokemons%%:*} # remove ':' and what leads it
    else
        pokemon_name=${1,,} # lowercase
        pokemon_name=${pokemon_name^} # uppercase 1st letter
    fi

    pokemon_info=$(curl -L -s "$PKDEX_API?pokemon=$pokemon_name")
    
    [[ "$pokemon_info" =~ "Error" ]] && echo $pokemon_info && exit 1
    
    pokemon_descr=$(echo $pokemon_info | jq '.info.description')
    pokemon_id=$(echo "$pokemon_info" | jq '.info.id') # real id
    pokemon_image_path="$TMPDIR/poke-$pokemon_id.png"

    test -f "$pokemon_image_path" || curl -L -s "$PKIMG_API/$pokemon_id".png > "$pokemon_image_path" # -L manages 3XX redirects 
     

    # Print box and image
    printf "$BOX_UL" && $PRINT_HZ && printf "$BOX_UR\n" && tput cuf $PADDING &&
    viu "$pokemon_image_path" -h$HEIGHT -w$WIDTH -t && # TODO : other image viewers 
    tput cuu $HEIGHT && $PRINT_VT && 
    printf "$BOX_DL" && $PRINT_HZ && printf "$BOX_DR\n"

    # Print infos
    skip_image="tput cuf "$((WIDTH + PADDING * 2))

    tput cuu $HEIGHT && $skip_image && 
    $SET_COLOR $RED && tput bold && 
    printf "Name:$($RESET_TXTFX) %s\n\n\n" $pokemon_name
   
    $SET_COLOR $BLUE
    lines_to_skip=0
    for ((written=0; written<${#pokemon_descr}; written+=$MAX_TEXT_LEN))
    do
        ((lines_to_skip++))
        $skip_image && 
        echo ${pokemon_descr:written:$MAX_TEXT_LEN}
    done
    $RESET_TXTFX
    tput cud $((HEIGHT - lines_to_skip - 3))

}

main "$@"
