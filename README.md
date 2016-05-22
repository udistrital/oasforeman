oasforeman
==========

Todo lo relacionado con **The Foreman** para la OAS.

![foreman architecture](http://theforeman.org/static/images/foreman_architecture.png)

Aprovisiona un servidor de [The Foreman](http://theforeman.org/) local.

## Importante nota sobre servidores proxy

Este programa usa la variable `http_proxy` si esta se encuentra definida, de lo contrario no hará uso de servidor proxy.

Para hacer uso de un servidor proxy defina la variable en su shell (o de manera permanente en su archivo de `~/.profile`).

```
http_proxy=http://proxy.udistrital.edu.co:3128
export http_proxy
```

Para no hacer uso de proxy (por ejemplo mientras trabaja remotamente) borre la variable de su shell actual.

```
unset http_proxy
```

## ¿Cómo usar esto?

1. Necesita un equipo con al menos 4GB (8GB si además quiere aprovisionar Katello) libres de memoria.
1. Clone este repositorio en tu estación de trabajo.

   ```
   git clone https://github.com/udistrital/oasforeman.git
   ```
1. Entre al directorio de checkout.

    ```
    cd oasforeman
    ```
1. Descargue [Vagrant](https://www.vagrantup.com/) y [VirtualBox](https://www.virtualbox.org/)
1. Ejecute en este directorio.

    ```
    vagrant up
    ```
1. Por conveniencia puede agregar estas líneas a su archivo `/etc/hosts` (necesitará acceso de `root`).

    ```
    192.168.12.42 foreman1.oas.local foreman1
    192.168.12.40 katello1.oas.local katello1
    ```

   Edite directamente el archivo `/etc/hosts` o ejecute estos comandos:

    ```
    echo 192.168.12.42 foreman1.oas.local foreman1 | sudo tee -a /etc/hosts
    echo 192.168.12.40 katello1.oas.local katello1 | sudo tee -a /etc/hosts
    ```
1. Guarde la información de acceso a The Foreman; esta aparecerá inmediatamente el comando `vagrant up` termine. Este es un ejemplo de lo que aparecerá en la consola:

   ```
   Ya puede iniciar sesión en https://{FQDN DE FOREMAN}
   La contraseña inicial del usuario admin es: {CONTRASEÑA DE FOREMAN}
   ```
1. Visite [foreman1.oas.local](https://foreman1.oas.local/) o [192.168.12.42](https://192.168.12.42/) en su navegador (la verificación de cerficado fallará sin embargo deberá continuar al sitio).
1. Use las credenciales guardadas del paso anterior para iniciar sesión en The Foreman.
1. Paso opcional. Ejecute:

   ```
   vagrant up katello
   ```
   Desafortunadamente existe una condición de carrera durante la primera vez que se ejecuta el arranque por PXE, el servidor de The Foreman no puede bajar tan rápido de Internet las imágenes de `kernel` e `initrd`, lo cual causa que el arranque se realice con un archivo incompleto. Para corregir esto simplemente cierre (apague) la maquina virtual y vuelva a ejecutar el comando `vagrant up katello`.

## Troubleshooting

Solucionar problemas.

### Actualizar el servidor de The Foreman

```
vagrant provision
```

### Borrar todo y comenzar de cero

```
# localhost >
vagrant destroy
vagrant up
```

### Archivos de log relevantes

 * `/var/log/boot.log` - Archivo de log de DHCP
 * `/var/log/messages` - Archivo de log del sistema operativo
 * `/var/log/foreman/production.log` - Archivo de log principal de The Foreman
 * `/var/log/foreman-proxy/proxy.log` - Archivo de log del proxy de The Foreman

Ver todos a la vez con:

```
# localhost >
vagrant ssh
```

```
# foreman1 >
sudo tail -f /var/log/boot.log /var/log/messages /var/log/foreman/production.log /var/log/foreman-proxy/proxy.log
```


## ¿Por qué esto es relevante?

1. Porque ayuda a probar nuevas funcionalidades en un ambiente aislado.
1. Porque define claramente el proceso de aprovisionamiento del servidor Foreman.
1. Porque permite trabajar remotamente en temas de aprovisionamiento (para usuarios remotos).
1. Porque es el primer paso para definir una infraestructura basada en código.

## Desarrollo

Primero clone este repositorio:

```
git clone https://github.com/udistrital/oasforeman.git
cd oasforeman
```

Luego instale todas las dependencias con:

```
./go
```

Ejecute todas las pruebas con:

```
./go spec
```

Experimente con la librería:

```
exe/console
```

Para instalar este "gem":

```
./go install
```

Para liberar una nueva versión, editar el archivo `version.rb` y luego:

```
./go release
```

Esto creara un "tag" en git para la versión dada. Hará "push" de los commits y tags; y por ultimo "push" del `.gem` a [Katello](http://katello.udistritaloas.edu.co).

## Ambientes

### Desarrollo

El ambiente de desarrollo está definido como lo que se puede hacer con este repositorio usando los comandos `vagrant` listados anteriormente en la sección "_¿Cómo usar esto?_". La llave privada de desarrollo está guardada en este repositorio y se encuentra en la ubicación `keys/desarrollo/private.pem`, la llave pública está guardada en `keys/desarrollo/public.pem`, mantener la llave privada visible al público no debe por ningún motivo representar un problema de seguridad pues el propósito únicamente es servir para desarrollo local.

Las llaves fueron creadas así

```
mkdir -p keys/desarrollo
eyaml createkeys --pkcs7-private-key=keys/desarrollo/private.pem --pkcs7-public-key=keys/desarrollo/public.pem
chmod -R 550 keys
chmod 440 keys/desarrollo/private.pem keys/desarrollo/public.pem
```

Cree o edite valores encriptados de esta manera:

```
git clone https://github.com/udistrital/oashiera.git
EDITOR=gedit eyaml --edit --pkcs7-private-key=keys/desarrollo/private.pem --pkcs7-public-key=keys/desarrollo/public.pem oashiera/ambientes/desarrollo/ARCHIVO/A/EDITAR.yaml
cd oashiera
git add .
git commit -m "actualizando secretos de desarrollo"
git push
```

David McNicol explica el proceso en más detalle [en su blog](https://dmcnicks.wordpress.com/2015/03/01/encrypt-hiera-data-with-eyaml/).

### Plataforma, pruebas y produccion

**Nota importante**

Para los demás ambientes (`plataforma`, `pruebas`, `produccion`) se debe generar un nuevo par de llaves PKCS7 y almacenar **ÚNICAMENTE** la parte pública en este repositorio. La llave privada para estos ambientes debe mantenerse en secreto **SIEMPRE**. También se debe respaldar ya que si se llega a extraviar no hay manera de recuperar los valores que fueron encriptados con la llave pública. Fallar al proteger la llave privada compromete el ambiente y será necesario no solamente un nuevo par de llaves sino también cambiar todos los valores que fueron encriptados para ella. **Idealmente éste es también es el proceso estándar de _off-board_ de un miembro de equipo con acceso a las llaves**.

## Enlaces

 * http://www.katello.org/developers/hammer_dev_env.html - Explica como crear un ambiente de desarrollo de `hammer_cli_katello` lo cual aplica de cierta manera también para `hammer_cli_foreman`.

## Contribuciones

Reportes de bugs y "pull requests" son bienvenidos en GitHub en https://github.com/udistrital/oasforeman.

## Licencia

Este "gem" esta disponible como "open source" bajo los terminos de la [Licencia MIT](http://opensource.org/licenses/MIT).
