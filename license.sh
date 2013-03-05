#!/bin/bash

if [ $# -lt 1 ]; then
	echo "Usage: $0 FILENAME [LICENSE_TYPE]"
	exit
fi

FILE=$1
LICENSE=$2
NAME=$(finger $(whoami) | gawk 'match($0, /Name: (.*$)/, out) { print out[1] }')
YEAR=$(date +%Y)
if [ ${EMAIL} ]; then
	EMAIL_INSERT="<${EMAIL}>"
fi

APACHE_LICENSE="\
Copyright ${YEAR} ${NAME} ${EMAIL_INSERT}\\n\
\\n\
Licensed under the Apache License, Version 2.0 (the \"License\");\\n\
you may not use this file except in compliance with the License.\\n\
You may obtain a copy of the License at\\n\
\\n\
http://www.apache.org/licenses/LICENSE-2.0\\n\
\\n\
Unless required by applicable law or agreed to in writing, software\\n\
distributed under the License is distributed on an \"AS IS\" BASIS,\\n\
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\\n\
See the License for the specific language governing permissions and\\n\
limitations under the License."

PERSONAL_LICENSE="\
Copyright ${YEAR} ${NAME} ${EMAIL_INSERT}\\n\
All rights reserved."

if [ ${LICENSE} ]; then
	case ${LICENSE} in
		apache)
			LICENSE=$(echo ${APACHE_LICENSE})
			;;
		personal)
			LICENSE=$(echo ${PERSONAL_LICENSE})
			;;
	esac
else
	# If no license is specified
	LICENSE=$(echo ${PERSONAL_LICENSE})
fi

# Determine filetype extension
EXTENSION=$(echo $1 | gawk 'match($0, /^.*\.(.*$)/, out) { print out[1] }')

# Create file if it doesn't exist
if [ ! -f $1 ]; then
	touch ${FILE}
	case ${EXTENSION} in
		c|cpp|c++|h|hpp|cs|vala|java)
		# Nothing needs to be done
		;;
		py)
		echo '#!/usr/bin/python' >> ${FILE}
		;;
		pl)
		echo '#!/usr/bin/perl' >> ${FILE}
		;;
		sh)
		echo '#!/bin/bash' >> ${FILE}
		;;
	esac
	# Adding a newline so the sed insertions work
	echo >> ${FILE}
fi

# Insert license into file
case ${EXTENSION} in
	c|cpp|c++|h|hpp|cs|vala|java)
	sed -i '1i\ \*/\n' ${FILE}
	INSERT=$(echo ${LICENSE} | sed -e 's/^/ \* /' -e 's/\\n/\\n \* /g')
	sed -i 1i"${INSERT}" ${FILE}
	sed -i '1s/^/ /' ${FILE}
	sed -i '1i\/*' ${FILE}
	;;
	py)
	sed -i '/#!/a """' ${FILE}
	sed -i "/#!/a ${LICENSE}" ${FILE}
	sed -i '/#!/a """' ${FILE}
	sed -i '/#!/G' ${FILE}
	;;
	pl|sh)
	INSERT=$(echo ${LICENSE} | sed -e 's/^/# /' -e 's/\\n/\\n# /g')
	sed -i "/#!/a ${INSERT}" ${FILE}
	sed -i '/#!/G' ${FILE}
	;;
esac
