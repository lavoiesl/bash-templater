# BASH Templater

Very simple templating system that replace `{{VAR}}` by `$VAR` environment value.

Supports default values by writting `{{VAR=value}}` in the template.

[![Build Status](https://travis-ci.org/lavoiesl/bash-templater.svg?branch=master)](https://travis-ci.org/lavoiesl/bash-templater)

## Author

Sébastien Lavoie <github@lavoie.sl>

Johan Haleby

See http://code.haleby.se/2015/11/20/simple-templating-engine-in-bash/  and http://blog.lavoie.sl/2012/11/simple-templating-system-using-bash.html for more details

## Installation

To install templater in linux type:

    sudo curl -L https://raw.githubusercontent.com/johanhaleby/bash-templater/master/templater.sh -o /usr/local/bin/templater
    sudo chmod +x /usr/local/bin/templater

## Usage
	
```bash
VAR=value templater template
```

Read variables from file:
    
```bash
templater template -f variables.txt
```

e.g.:
```bash
# variables.txt
# The author
AUTHOR=Johan
# The version
VERSION=1.2.3
```

```sh
# Passing arguments directly
VAR=value templater.sh template

# Evaluate /tmp/foo and pass those variables to the template
# Useful for defining variables in a file
# Parentheses are important for not polluting the current shell
(set -a && . /tmp/foo && templater.sh template)

# Passing variables to template via a file
templater.sh template -f variables.txt

# Squelching all warning messages
templater.sh template -s

# A variant that does NOT pass current env variables to the templater
sh -c "set -a && . /tmp/foo && templater.sh template"
```

## Examples
See examples/
