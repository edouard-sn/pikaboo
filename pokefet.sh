#/bin/sh

PKDEX_API=https://courses.cs.washington.edu/courses/cse154/webservices/pokedex/pokedex.php
PKIMG_API=https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/

PKCOUNT=151 # OG shit

TMPDIR=${TMPDIR:-/tmp}

SCALE=1

function main() 
{ 
    if ! which jq &> /dev/null ; then
        echo "Please install jq" # TODO better logging
        exit 1
    fi
    # TODO same for viu - curl > function check all deps in loop 
    
    random_pokemon=$(($RANDOM % PKCOUNT + 1)) # random list index

    pokemons=$(curl -L -s $PKDEX_API?pokedex=all | tail -n$random_pokemon) # piping into cut here doesn't work


    pokemon_name=$(echo $pokemons | cut -d':' -f1) # hope you like comments
    pokemon_info=$(curl -L -s $PKDEX_API?pokemon=$pokemon_name) 
    pokemon_id=$(echo $pokemon_info | jq '.info.id') # real id
    pokemon_image_path="$TMPDIR/poke-$(date +%s).png" # uid - maybe change to pokemon id
    

    curl -L -s "$PKIMG_API/$pokemon_id".png > $pokemon_image_path # -L manages 3XX redirects 
    echo -e "\e[99D" # move cursor 99 to the left
    # TODO a lot of \e#ABCD


    viu "$pokemon_image_path" -h $((10 * $SCALE))
    # Draw picture - TODO create different protocols (kitty icat, maybe w3m)


    # TODO format ugly things
    echo -e $pokemon_name
    echo -e $pokemon_info | jq '.info.description'
}

main $@
