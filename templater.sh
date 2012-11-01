#!/bin/bash
# Replaces all {{VAR}} by the $VAR value in a template file and outputs it

if [[ ! -f "$1" ]]; then
    echo "Usage: VAR=value $0 template" >&2
    exit 1
fi

template="$1"
vars=$(grep -oE '{{[A-Za-z0-9_]+}}' "$template" | sort | uniq | sed -e 's/^{{//' -e 's/}}$//')

if [[ -z "$vars" ]]; then
    echo "Warning: No variable was found in $template, syntax is {{VAR}}" >&2
fi

var_value() {
    eval echo \$$1
}

replaces=""

# Reads default values defined as {{VAR=value}} and delete those lines
# There are evaluated, so you can do {{PATH=$HOME}} or {{PATH=`pwd`}}
# You can even reference variables defined in the template before
defaults=$(grep -oE '{{[A-Za-z0-9_]+=.+}}' "$template" | sed -e 's/^{{//' -e 's/}}$//')
for default in $defaults; do
    var=$(echo "$default" | grep -oE "^[A-Za-z0-9_]+")
    current=`var_value $var`

    # Replace only if var is not set
    if [[ -z "$current" ]]; then
        eval $default
    fi

    # remove define line
    replaces="-e '/^{{$var=/d' $replaces"
done

# Replace all {{VAR}} by $VAR value
for var in $vars; do
    value=`var_value $var`
    if [[ -z "$value" ]]; then
        echo "Warning: $var is not defined and no default is set, replacing by empty" >&2
    fi

    # Escape slashes
    value=$(echo "$value" | sed 's/\//\\\//g');
    replaces="-e 's/{{$var}}/$value/g' $replaces"
done

eval sed $replaces "$template"