#!/bin/bash
#Variable
repo="Ejercicio-1-Linux-y-Automatizaci-n"
USERID=$(id -u)

echo "//=========================================//"
echo "//============Inicio del Script============//"
echo "//=========================================//"
echo ""
echo ""

#Verificando ejecucion con usuario ROOT

if [ "${USERID}" -ne 0 ]; then
    echo -e "Correr con usuario ROOT"
    echo -e "Saliendo del Script..."
    exit
fi

#Verificando actualizacion de sistema

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

echo -e "Actualizando Sistema..."
    apt-get update
echo -e "El sistema fue actualizado..."

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

#Comprobando Instalacion de GIT

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

echo -e "Comprobando instalacion de GIT..."
if dpkg -l | grep git; then
    echo "Git ya se encuentra instalado en el Sistema..."
else
    echo "Instalando Git..."
    apt install -y git
fi
echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

#Comprobando instalacion de MariaDB

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""
echo -e "Comprobando instalacion de MariDB..."
if dpkg -l | grep mariadb-server; then
    echo -e "MariaDB ya se encuentra instalado en el Sistema..."
else
    echo -e "Instalando MariaDB..."
    apt install -y mariadb-server
    systemctl start mariadb
    systemctl enable mariadb
fi
echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

#Coprobando Instalacion de APACHE2

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

echo -e "Comprobando instalacion de Apache2..."

if dpkg -l | grep apache2; then
    echo -e "Apache2 ya se encuentra instalado en el Sistema..."
else
echo -e "Instalando Apache"
    apt install apache2 -y
    apt install -y php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-json php-curl 
    #Configurando Apache
    systemctl start apache2
    systemctl enable apache2
    php -v
    mv /var/www/html/index.html /var/www/html/index.html.bkp
fi
sed -i 's/index.html/index.php index.html/g' /etc/apache2/mods-enabled/dir.conf
systemctl reload apache2
echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

#Configurando Base de Datos

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

echo -e "Comprobando base de datos"
if mysqlshow devopstravel > /dev/null 2>&1; then
    echo -e "La base de datos devopstravel ya existe"
else
    echo -e "Generando base de datos"
        mysql -e "CREATE DATABASE devopstravel;"
        echo -e "La base de datos fue creada"
fi
echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

#Creando usuario de base de datos

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

echo -e "Usuario de base de datos"
if mysql -e "SELECT user FROM mysql.user GROUP BY user;" | grep codeuser > /dev/null 2>&1; then
    echo -e "El usuario codeuser ya existe"
else
    mysql -e "
        CREATE USER 'codeuser'@'localhost' IDENTIFIED BY 'codepass';
        GRANT ALL PRIVILEGES ON *.* TO 'codeuser'@'localhost';
        FLUSH PRIVILEGES;"
    echo -e "El usuario codeuser fue creado"
fi

echo -e "La base de datos fue creada y configurada con exito"

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

#Clonacion del repositorio

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

if [[ -d $repo ]]; then
    echo -e "El repositorio ${repo} ya existe"
    cd ${repo}
    git pull origin bootcamp-devops-2023
else
    echo -e "Clonando el repositorio"
    git clone https://github.com/wxllgz/$repo.git
    cd ${repo}
    git pull origin bootcamp-devops-2023
    echo $repo
fi
echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

#Copiando los archivos de la web

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

echo -e "Copiando los archivos para ejecucion"

cp -r ~/${repo}/app-295devops-travel/* /var/www/html

echo -e "Archivos copiados"

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

#Cargado datos a la base de datos

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

echo -e "Cargando datos a la base"

mysql < ~/$repo/app-295devops-travel/database/devopstravel.sql

echo -e "La base de datos fue cargada"

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

#Confifuracion de contraseña de la Base

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

echo -e "Ingrese la contraseña de la  base de datos"
    sleep 3
    nano /var/www/html/config.php
    systemctl reload apache2


echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

#Deploy

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

echo -e "Pruebe la pagina ingrasando a: http://localhost o http://ip"

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""

# Configura el token de acceso de tu bot de Discord
DISCORD="https://discord.com/api/webhooks/1169002249939329156/7MOorDwzym-yBUs3gp0k5q7HyA42M5eYjfjpZgEwmAx1vVVcLgnlSh4TmtqZqCtbupov"

# Verifica si se proporcionó el argumento del directorio del repositorio
#if [ $# -ne 1 ]; then
#  echo "Uso: $0 <ruta_al_repositorio>"
#  exit 1
#fi

# Cambia al directorio del repositorio
#cd "$1"

# Obtiene el nombre del repositorio
REPO_NAME=$(basename $(git rev-parse --show-toplevel))
# Obtiene la URL remota del repositorio
REPO_URL=$(git remote get-url origin)
WEB_URL="localhost"
# Realiza una solicitud HTTP GET a la URL
HTTP_STATUS=$(curl -Is "$WEB_URL" | head -n 1)

# Verifica si la respuesta es 200 OK (puedes ajustar esto según tus necesidades)
if [[ "$HTTP_STATUS" == *"200 OK"* ]]; then
  # Obtén información del repositorios
    DEPLOYMENT_INFO2="Despliegue del repositorio $REPO_NAME: "
    DEPLOYMENT_INFO="La página web $WEB_URL está en línea."
    COMMIT="Commit: $(git rev-parse --short HEAD)"
    AUTHOR="Autor: $(git log -1 --pretty=format:'%an')"
    DESCRIPTION="Descripción: $(git log -1 --pretty=format:'%s')"
else
  DEPLOYMENT_INFO="La página web $WEB_URL no está en línea."
fi

# Obtén información del repositorio


# Construye el mensaje
MESSAGE="$DEPLOYMENT_INFO2\n$DEPLOYMENT_INFO\n$COMMIT\n$AUTHOR\n$REPO_URL\n$DESCRIPTION"

# Envía el mensaje a Discord utilizando la API de Discord
curl -X POST -H "Content-Type: application/json" \
     -d '{
       "content": "'"${MESSAGE}"'"
     }' "$DISCORD"

echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""
echo -e "Enviando notificacion a Discord"
echo ""
echo ""
echo "//=========================================//"
echo ""
echo ""
echo "//==========================================//"
echo "//==============Fin del Script==============//"
echo "//==========================================//"
