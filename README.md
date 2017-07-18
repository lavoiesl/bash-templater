# BASH Templater
Very simple templating system that replace {{VAR}} by $VAR environment value
Supports default values by writting {{VAR=value}} in the template

## Author

Sébastien Lavoie <github@lavoie.sl>

See http://blog.lavoie.sl/2012/11/simple-templating-system-using-bash.html for other details

## Usage

```sh
# Passing arguments directly
VAR=value templater.sh template

# Evaluate /tmp/foo and pass those variables to the template
# Useful for defining variables in a file
# Parentheses are important for not polluting the current shell
(set -a && . /tmp/foo && templater.sh template)

# A variant that does NOT pass current env variables to the templater
sh -c "set -a && . /tmp/foo && templater.sh template"
```

## Examples
See examples/
