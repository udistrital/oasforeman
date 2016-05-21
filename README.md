oasforeman
==========

Todo lo relacionado con Foreman para la OAS.

![foreman architecture](http://theforeman.org/static/images/foreman_architecture.png)

Aprovisiona un servidor de [Foreman](http://theforeman.org/) local.

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

1. Necesita un equipo con al menos 4GB (8GB si además quiere aprovisionar Katello) libres de memoria
1. Clonar este repositorio en tu estación de trabajo

    ```
    git clone git@github.com:udistrital/oasforeman.git
    ```
   O por `https` si `ssh` no funciona.

   ```
   git clone https://github.com/udistrital/oasforeman.git
   ```
1. Entrar al directorio de checkout

    ```
    cd oasforeman
    ```
1. Descargue [Vagrant](https://www.vagrantup.com/) y [VirtualBox](https://www.virtualbox.org/)
1. Ejecute `vagrant up ; vagrant provision` en este directorio y guarde la información de acceso a Foreman.

    ```
    Ya puede iniciar sesión en https://foreman1.oas.local
    La contraseña inicial del usuario admin es: CONTRASEÑA
    ```
1. Por conveniencia puede agregar estas líneas a su archivo `/etc/hosts`.

    ```
    192.168.12.42 foreman1.oas.local foreman1
    192.168.12.40 katello1.oas.local katello1
    ```

   O ejecutar el siguiente comando.

    ```
    echo 192.168.12.42 foreman1.oas.local foreman1 | sudo tee -a /etc/hosts
    echo 192.168.12.40 katello1.oas.local katello1 | sudo tee -a /etc/hosts
    ```
1. Visite [foreman1.oas.local](https://foreman1.oas.local/) o [192.168.12.42](https://192.168.12.42/) en su navegador (la verificación de cerficado fallará sin embargo deberá continuar al sitio).
1. Use las credenciales guardadas del paso anterior para iniciar sesión en Foreman (User: admin / Password: CONTRASEÑA).
1. (opcional) Ejecute `vagrant up katello`.

## Troubleshooting

Solucionar problemas.

### Actualizar el servidor de Foreman

```
vagrant provision
```

### Borrar todo y comenzar de cero

```
# localhost >
vagrant destroy -f
vagrant up
```

### Archivos de log relevantes

 * `/var/log/boot.log` - Archivo de log de DHCP
 * `/var/log/messages` - Archivo de log del sistema operativo
 * `/var/log/foreman/production.log` - Archivo de log principal de Foreman
 * `/var/log/foreman-proxy/proxy.log` - Archivo de log del proxy de Foreman

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
1. Porque permite rapidamente crear un nuevo servidor de Foreman para casos de emergencia.
1. Porque permite trabajar remotamente en temas de aprovisionamiento (para usuarios remotos).
1. Porque es el primer paso para definir una infraestructura basada en código.
