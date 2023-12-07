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
Manual de Uso:

config_red.sh [s h]
	Script que permite configurar interfaces de red inalambricas y alambricas de manera automática o manual. Todo esto a través de preguntas al usuario sobre los parámetros de la red y la interfaz deseada
	Opciones:
	-s: Setup: Instala los programas necesarios para la configuracion de redes y redes inalambricas
	-h: Help: Muestra la ayuda del script


