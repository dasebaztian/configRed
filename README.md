# configRed

Configurar interfaces de red.

Script que permite configurar interfaces de red inalambricas y alambricas de manera automática o manual en sistemas Linux basados en Debian.
Desarrollado por Daniel Sebastián Sánchez Medina para la materia de Administración de Serviores.
FEI, UV.
# Carácteristicas:
- Instala las dependencias requeridas en el sistema con la opción -h (Distribuciones basadas en Debian)
- Permite configurar interfaces ethernet de manera manual y autómatica
- Permite configurar interfaces wlan de manera manual y autómatica

# Dependencias: 
- rfkill
- wpa_supplicant
- net-tools

## config_red.sh [s h]
	Script que permite configurar interfaces de red inalambricas y alambricas de manera automática o manual. Todo esto a través de preguntas al usuario sobre los parámetros de la red y la interfaz deseada
	Opciones:
	-s: Setup: Instala los programas necesarios para la configuracion de redes y redes inalambricas
	-h: Help: Muestra la ayuda del script


## Funciones

### Main
Esta es la función principal del programa, desde está se manda a llamar a la función obtener interfaz y se toma la decisión sobre que tipo de interfaz se ha seleccionado
para despues mandar a llamar a la función de configuración correspondiente para ese tipo de interfaz.

### Setup
Función encargada de instalar todas las dependencias del script y adémas de desbloquear todas las las interfaces inalámbricas a través del comando rfkill.

### Obtener interfaz
Desde está función se muestran las interfaces conectadas a través del comando ifconfig, aplicando un grep para solo mostrar los nombres de las interfaces y agregandolas a un arreglo sobre el cúal despues
se itera para saber la interfaz seleccionada por el usuario, interfaz que luego se guarda en la variable $interfazSelec, en caso de que la interfaz que ingresa el usuario no esté dentro del arreglo se le
informa al usuario y se sale con código de error 1.

### enconfig_manual
Esta función se manda a llamar desde el main en caso de que la interfaz seleccionada sea alámbrica y se haya decidido configurar de manera manual. Desde está se leen los parámetros básicos para la configuración de red: IP, máscara, puerta de enlace y el servidor dns. Estos se asignan a través de ifconfig, route y añadiendo el dns al archivo /etc/resol.conf

### enconfig_dinamico
Esta función se encarga de levantar la intefaz a través del comando ifconfig y usando el comando dhclient especificando la interfaz a través de la variable $interfazSelec. Se llama desde el main.

### wlconfig_manual
En esta función primero se leen los parámetros básicos para una configuración de red. Además de leer la contraseña de la red WIFI si es que existe para despúes generar el archivo para el wpa_supplicant con el comando wpa_passphrase. Se levanta la interfaz se conecta a la red con wpa_supplicant usando el archivo generado y se asignan los parámetros de red con ifconfig, route y añadiendo el dns al archivo /etc/resolv.com

### wlconfig_dinamica
En esta función primero se lee la contrasñe del SSID seleccionado, se levanta la interfaz y se genera el archivo a través de wpa_passprhase. Se conecta a la red a través de wpa_supplicant y se obtiene la información de la red a través de dhclient $interfazSelec.

### scan_inalambrica
Esta función se encarga de escanear las redes disponibles con el comando iwlist, pasando la salida por un grep que solo muestra el ESSID de la red. Despúes de mostrarlos se pregunta al usuario a que red se quiere conectar
y se busca la respuesta en el arreglo que almacena el ESSID, y se manda a llamar a la función correspondiente dependiendo de la selección del usuario acerca de si se desea configurar la red de forma manual o automática.
