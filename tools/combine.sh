#!/bin/bash

usage() {
  echo "./tools/combine.sh combined.pbf 3000 4000 s1.pbf s2.pbf s3.pbf [s4.pbf].."
  exit 1
}

target=$1; shift
start_node=$1; shift
start_way=$1; shift
first=$1; shift 
rest=$@; shift

[ "$target" ] || usage
[ "$start_node" ] && [ "$start_node" -eq "$start_node" ] || usage
[ "$start_way" ] && [ "$start_way" -eq "$start_way" ] || usage
[ -f "$first" ] || usage
for i in $rest; do
  [ -f "$i" ] || usage
done

[ -f "$target" ] && rm -f "$target"

osmium renumber \
    -s $start_node,$start_way,0 \
    "$first" \
    -Oo "$target"

for i in $rest; do 
  ./tools/osmium-append.sh "$target" "$i" || break
done
