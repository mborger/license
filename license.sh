#!/bin/bash

if [ $# -lt 1 ]; then
	echo "Usage: $0 FILENAME [LICENSE_TYPE]"
	exit
fi

FILE=$1
LICENSE=$2
NAME=$(finger $(whoami) | gawk 'match($0, /Name: (.*$)/, out) { print out[1] }')
EMAIL="<matthew@borgernet.com>"
YEAR=$(date +%Y)

APACHE_LICENSE="\
Copyright ${YEAR} ${NAME} ${EMAIL}\\n\
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
Copyright ${YEAR} ${NAME} ${EMAIL}\\n\
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
	LICENSE=$(echo ${PERSONAL_LICENSE})
fi

# Determine filetype extension
EXTENSION=$(echo $1 | gawk 'match($0, /^.*\.(.*$)/, out) { print out[1] }')

if [ -f $1 ]; then
	# file exists
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
		sed -i '/#!/a \
		' ${FILE}
		;;
		sh)
		INSERT=$(echo ${LICENSE} | sed -e 's/^/# /' -e 's/\\n/\\n# /g')
		sed -i "/#!/a ${INSERT}" ${FILE}
		sed -i '/#!/G' ${FILE}
		;;
	esac
else
	# creating new file
	case ${EXTENSION} in
		c|cpp|c++|h|hpp|cs|vala|java)
		echo "/*" > ${FILE}
		echo -e ${LICENSE} | sed 's/^/ \* /' >> ${FILE}
		echo " */" >> ${FILE}
		;;
		py)
		echo -e "#!/usr/bin/python\n" > ${FILE}
		echo "\"\"\"" >> ${FILE}
		echo -e ${LICENSE} >> ${FILE}
		echo "\"\"\"" >> ${FILE}
		;;
		pl)
		echo -e "#!/usr/bin/perl\n" > ${FILE}
		echo -e ${LICENSE} | sed 's/^/# /' >> ${FILE}
		;;
		sh)
		echo -e "#!/usr/bin/bash\n" > ${FILE}
		echo -e ${LICENSE} | sed 's/^/# /' >> ${FILE}
		;;
		*)
		echo No match
		;;
	esac
fi
