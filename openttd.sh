#!/bin/sh

SAVEPATH=${SAVEPATH:-"/home/openttd/.openttd/save"}
SAVEGAME="${SAVEPATH}/${SAVENAME}"
LOADGAME_CHECK="${LOADGAME}x"
LOADGAME=${LOADGAME:-"false"}

PUID=${PUID:-911}
PGID=${PGID:-911}
PHOME=${PHOME:-"/home/openttd"}
USER=${USER:-"openttd"}

if [ ! "$(id -u ${USER})" -eq "$PUID" ]; then usermod -o -u "$PUID" ${USER} ; fi
if [ ! "$(id -g ${USER})" -eq "$PGID" ]; then groupmod -o -g "$PGID" ${USER} ; fi
if [ "$(grep ${USER} /etc/passwd | cut -d':' -f6)" != "${PHOME}" ]; then
        if [ ! -d ${PHOME} ]; then
                mkdir -p ${PHOME}
                chown ${USER}:${USER} ${PHOME}
        fi
        usermod -m -d ${PHOME} ${USER}
fi

echo "
-----------------------------------
GID/UID
-----------------------------------
User uid:    $(id -u ${USER})
User gid:    $(id -g ${USER})
User Home:   $(grep ${USER} /etc/passwd | cut -d':' -f6)
-----------------------------------
"

# Loads the desired game, or prepare to load it next time server starts up!
if [ ${LOADGAME_CHECK} != "x" ]; then

        case ${LOADGAME} in
                'true')
                        if [ -f  ${SAVEGAME} ]; then
                                echo "Loading ${SAVEGAME}"
                                su -l openttd -c "/usr/games/openttd -D -g ${SAVEGAME} -x -d ${DEBUG}"
                                exit 0
                        else
                                echo "${SAVEGAME} not found..."
                                exit 0
                        fi
                ;;
                'false')
                        echo "Creating a new game."
                        su -l openttd -c "/usr/games/openttd -D -x -d ${DEBUG}"
                        exit 0
                ;;
                'last-autosave')

			SAVEGAME=${SAVEPATH}/autosave/`ls -rt ${SAVEPATH}/autosave/ | tail -n1`

			if [ -r ${SAVEGAME} ]; then
	                        echo "Loading ${SAVEGAME}"
        	                su -l openttd -c "/usr/games/openttd -D -g ${SAVEGAME} -x -d ${DEBUG}"
                	        exit 0
			else
				echo "${SAVEGAME} not found..."
				exit 1
			fi
                ;;
                'exit')

			SAVEGAME="${SAVEPATH}/autosave/exit.sav"

			if [ -r ${SAVEGAME} ]; then
	                        echo "Loading ${SAVEGAME}"
        	                su -l openttd -c "/usr/games/openttd -D -g ${SAVEGAME} -x -d ${DEBUG}"
                	        exit 0
			else
				echo "${SAVEGAME} not found..."
				exit 1
			fi
                ;;
		*)
			echo "ambigous loadgame (\"${LOADGAME}\") statement inserted."
			exit 1
		;;
        esac
else
	echo "\$loadgame (\"${LOADGAME}\") not set, starting new game"
        su -l openttd -c "/usr/games/openttd -D -x"
        exit 0
fi