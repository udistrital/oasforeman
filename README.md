# oasforeman

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

1. Descargue [Vagrant](https://www.vagrantup.com/) y [VirtualBox](https://www.virtualbox.org/)
1. Ejecute `vagrant up` en este directorio, guarde la información de acceso a Foreman.

    ```
    * Foreman is running at https://192.168.12.42
        Initial credentials are admin / CONTRASEÑA
    ```
1. Por conveniencia puede agregar estas líneas a su archivo `/etc/hosts`.

    ```
    192.168.12.42 foreman1.oas.local foreman1
    ```

   O ejecutar el siguiente comando.

    ```
    echo 192.168.12.42 foreman1.oas.local foreman1 | sudo tee -a /etc/hosts
    ```
1. Visite [foreman1.oas.local](https:/foreman1.oas.local/) o https://192.168.12.42/ en su navegador (la verificación de cerficado fallará sin embargo deberá continuar al sitio).
1. Use las credenciales guardadas del paso anterior para iniciar sesión en Foreman (`admin / CONTRASEÑA`).

## Troubleshooting

Para actualizar el servidor de Foreman.

```
vagrant provision
```

Para borrar todo y comenzar de cero.

```
vagrant destroy -f
vagrant up
```

## ¿Por qué esto es relevante?

1. Porque ayuda a probar nuevas funcionalidades en un ambiente seguro.
1. Porque define claramente el proceso de aprovisionamiento del servidor Foreman.
1. Porque permite rapidamente crear un nuevo servidor de Foreman para casos de emergencia.
1. Porque permite trabajar remotamente en temas de aprovisionamiento (para usuarios remotos).
