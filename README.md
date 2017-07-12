# BASH Templater
Very simple templating system that replace {{VAR}} by $VAR environment value
Supports default values by writting {{VAR=value}} in the template

## Author

Sébastien Lavoie <github@lavoie.sl>

Johan Haleby

See http://code.haleby.se/2015/11/20/simple-templating-engine-in-bash/  and http://blog.lavoie.sl/2012/11/simple-templating-system-using-bash.html for more details

## Usage
	
```bash
VAR=value templater.sh template
```

Read variables from file:
    
```bash
templater.sh template -f variables.txt
```

e.g.:
```bash
# variables.txt
# The author
AUTHOR=Johan
# The version
VERSION=1.2.3
```

Don't print any warning messages:

```bash
templater.sh template -f variables.txt -s
```

## Examples
See examples/
