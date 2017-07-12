#!/bin/bash
#
# Very simple templating system that replaces {{VAR}} by the value of $VAR.
# Supports default values by writting {{VAR=value}} in the template.
#
# Copyright (c) 2017 Sébastien Lavoie
# Copyright (c) 2017 Johan Haleby
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# See: https://github.com/johanhaleby/bash-templater
# Version: https://github.com/johanhaleby/bash-templater/commit/5ac655d554238ac70b08ee4361d699ea9954c941

# Replaces all {{VAR}} by the $VAR value in a template file and outputs it

readonly PROGNAME=$(basename $0)

config_file="<none>"
print_only="false"
silent="false"

usage="${PROGNAME} [-h] [-d] [-f] [-s] -- 

where:
    -h, --help
        Show this help text
    -p, --print
        Don't do anything, just print the result of the variable expansion(s)
    -f, --file
        Specify a file to read variables from
    -s, --silent
        Don't print warning messages (for example if no variables are found)

examples:
    VAR1=Something VAR2=1.2.3 ${PROGNAME} test.txt 
    ${PROGNAME} test.txt -f my-variables.txt
    ${PROGNAME} test.txt -f my-variables.txt > new-test.txt"

if [ $# -eq 0 ]; then
  echo "$usage"
  exit 1    
fi

if [[ ! -f "${1}" ]]; then
    echo "You need to specify a template file" >&2
    echo "$usage"
    exit 1
fi

template="${1}"

if [ "$#" -ne 0 ]; then
    while [ "$#" -gt 0 ]
    do
        case "$1" in
        -h|--help)
            echo "$usage"
            exit 0
            ;;        
        -p|--print)
            print_only="true"
            ;;
        -f|--file)
            config_file="$2"
            ;;
        -s|--silent)
            silent="true"
            ;;
        --)
            break
            ;;
        -*)
            echo "Invalid option '$1'. Use --help to see the valid options" >&2
            exit 1
            ;;
        # an option argument, continue
        *)  ;;
        esac
        shift
    done
fi

vars=$(grep -oE '\{\{[A-Za-z0-9_]+\}\}' "${template}" | sort | uniq | sed -e 's/^{{//' -e 's/}}$//')

if [[ -z "$vars" ]]; then
    if [ "$silent" == "false" ]; then
        echo "Warning: No variable was found in ${template}, syntax is {{VAR}}" >&2
    fi
fi

# Load variables from file if needed
if [ "${config_file}" != "<none>" ]; then
    if [[ ! -f "${config_file}" ]]; then
      echo "The file ${config_file} does not exists" >&2
      echo "$usage"      
      exit 1
    fi

    # Create temp file where & and "space" is escaped
    tmpfile=`mktemp`   
    sed -e "s;\&;\\\&;g" -e "s;\ ;\\\ ;g" "${config_file}" > $tmpfile
    source $tmpfile
fi    

var_value() {
    eval echo \$$1
}

replaces=""

# Reads default values defined as {{VAR=value}} and delete those lines
# There are evaluated, so you can do {{PATH=$HOME}} or {{PATH=`pwd`}}
# You can even reference variables defined in the template before
defaults=$(grep -oE '^\{\{[A-Za-z0-9_]+=.+\}\}' "${template}" | sed -e 's/^{{//' -e 's/}}$//')

for default in $defaults; do
    var=$(echo "$default" | grep -oE "^[A-Za-z0-9_]+")
    current=`var_value $var`

    # Replace only if var is not set
    if [[ -z "$current" ]]; then
        eval $default
    fi

    # remove define line
    replaces="-e '/^{{$var=/d' $replaces"
    vars="$vars
$current"
done

vars=$(echo $vars | sort | uniq)

if [[ "$print_only" == "true" ]]; then
    for var in $vars; do
        value=`var_value $var`
        echo "$var = $value"
    done
    exit 0
fi

# Replace all {{VAR}} by $VAR value
for var in $vars; do
    value=`var_value $var`
    if [[ -z "$value" ]]; then
        if [ $silent == "false" ]; then
            echo "Warning: $var is not defined and no default is set, replacing by empty" >&2
        fi
    fi

    # Escape slashes
    value=$(echo "$value" | sed 's/\//\\\//g');
    replaces="-e 's/{{$var}}/${value}/g' $replaces"    
done

escaped_template_path=$(echo $template | sed 's/ /\\ /g')
eval sed $replaces "$escaped_template_path"
