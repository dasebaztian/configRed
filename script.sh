#!/bin/bash

ayuda(){
cat << EOF
config_red.sh [s h]
	Script que permite escoger una interfaz de red para levantar y configurar automaticamente 
	Además permite que si se desea levantar una interfaz inalambrica 
	Opciones:
	-s: Setup: Instala los programas necesarios para la configuracion de redes y redes inalambricas
	-h: Help: Muestra la ayuda del script
	Asegurate de tener los permisos necesarios para cambiar la configuración de red
EOF

}

setup() {
	apt update
	apt install net-tools
	apt install wpa-supplicant
	apt install rfkill
	rfkill unblock
}

obtenerInterfaz() {
	local interfaces=$(ifconfig | grep -Eo "^[a-z][a-z0-9]+")
	local arr_interfaces=( )
	echo "[*] Mostrando las intefaces de red en el dispositivo: "
	for elemento in "${interfaces[@]}"; do
		arr_interfaces+=( $elemento )
		echo "$elemento"
	done
	echo "[*] Escoge una interfaz de las anteriores, considerando que por norma general las interfaces en son alambricas y las wl son inalambricas"	
	read -r respuesta 
	for interfaz in "${arr_interfaces[@]}"; do
		if [ "$respuesta" == "$interfaz" ]; then
			local flag="1"
		fi
	done	
	if test "$flag"; then
		interfazSelec="$respuesta"
	else
		echo "[?] No se encontro ninguna interfaz con ese nombre" && ayuda && exit 1
	fi
}

enconfig_dinamica() {
	ifconfig "$interfazSelec" up
	dhclient "$interfazSelec" -v && echo "[*] Se ha configurado correctamente" && exit 0
}
enconfig_manual() {
	read -p "IP del dispositivo: " -r ipdis
	read -p "Préfijo de red: " -r masred
	read -p "Puerta de enlace: " -r puertaen
	read -p "Servidor DNS: " -r servdns
	ifconfig "$interfazSelec" up
	ip addr add "$ipdis"/"$masred" dev "$interfazSelec"
	route add default gw "$puertaen" "$interfazSelec"
	echo "nameserver $servdns" >> /etc/resolv.conf
	exit 0
}

wlconfig_dinamica() {
	ESSID="$1"
	echo "Ingresa la contraseña de: $ESSID"
	read -r pass
	ip link set "$interfazSelec" up
	wpa_passphrase "$ESSID" "$pass" > "$ESSID".conf
	wpa_supplicant -B -D wext -i "$interfazSelec" -c "$ESSID".conf
	dhclient "$interfazSelec" -v
	exit 0
}

wlconfig_manual() {
	ESSID="$1"
	echo "Ingresa la contraseña de: $ESSID"
	read -r pass
	read -p "IP del dispositivo: " -r ipdis
	read -p "Máscara de red en el formato xxx.xxx.xxx.xxx: " -r masred
	read -p "Puerta de enlace: " -r puertaen
	read -p "Servidor DNS: " -r servdns
	ip link set "$interfazSelec" up
	wpa_passphrase "$ESSID" "$pass" > "$ESSID".conf
	wpa_supplicant -B -D wext -i "$interfazSelec" -c "$ESSID".conf
	ip addr add "$ipdis"/"$masred" dev "$interfazSelec"
	route add default gw "$puertaen" "$interfazSelec"
	echo "nameserver $servdns" >> /etc/resolv.conf
	exit 0
}

scan_inalambrica() {
	local redes=$(iwlist wlp3s0 scan | grep -Po "ESSID:\"\K[^\"]*") 
	local arr_redes=( )
	for elemento in "${redes[@]}"; do
		arr_redes+=( $elemento )
		echo "$elemento"
	done
	echo "[*] Selecciona una red"
	read -r respuesta
	for red in "${arr_redes[@]}"; do
		if [ "$respuesta" == "$red" ]; then
			echo "Has seleccionado $red"
			echo "[*] Configurar de manera:"
			echo "[1] Manual"
			echo "[2] Automática" 
			read -r opcion
			if [ "$opcion" == 1 ]; then
				wlconfig_manual "$red"
			fi
			if [ "$opcion" == 2 ]; then
				wlconfig_dinamica "$red"
			fi
		fi
	done
}
main() {
	obtenerInterfaz
#	echo "Ya obtuve interfaz $interfazSelec"
	tipo_interfaz=$(echo "$interfazSelec" | grep -Eo "^[a-Z]")
	if [ "$tipo_interfaz" == "e" ]; then
		echo "[*] Configurar de manera:"
		echo "[1] Manual"
		echo "[2] Automática" 
		read -r opcion
		if [ "$opcion" == 1 ]; then
			enconfig_manual
		fi
		if [ "$opcion" == 2 ]; then
			enconfig_dinamica
		fi
	elif [ "$tipo_interfaz" == "w" ]; then
		scan_inalambrica
	fi
}

opcionH=""
opcionS=""
while getopts ":hs" opt; do
    case $opt in
	h)
	    opcionH="1";

	    ;;
	s)
	    opcionS="1";
	    ;;
	"?")
	    echo "Opción inválida -$OPTARG";
	    ayuda;
	    exit 1;
	    ;;
	:)
	    echo "Se esperaba un parámetro en -$OPTARG";
	    ayuda;
	    exit 1;
	    ;;
    esac
done

shift $((OPTIND-1)) #borrar todos los params que ya procesó getopts

test "$opcionH" && { ayuda; exit 0; }
test "$opcionS" && setup
main
