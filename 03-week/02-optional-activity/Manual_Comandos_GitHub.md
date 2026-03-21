# Comandos de GitHub que uso todo el tiempo

> Esto lo escribí para no tener que estar buscando los comandos cada vez que me pierdo. Si estás leyendo esto, espero que te sirva tanto como a mí.

---

## Primero lo primero: configurar Git

Antes de cualquier cosa, hay que decirle a Git quién eres. Esto solo se hace una vez.

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tuemail@correo.com"
```

Y si quieres ver lo que ya tienes configurado:

```bash
git config --list
```

---

## Crear o clonar un repositorio

Si voy a empezar un proyecto desde cero en mi máquina:

```bash
git init
```

Si el repositorio ya existe en GitHub y lo quiero traer a mi PC:

```bash
git clone https://github.com/usuario/repositorio.git
```

También puedo clonarlo con SSH si ya tengo la llave configurada:

```bash
git clone git@github.com:usuario/repositorio.git
```

---

## El ciclo básico de trabajo (el que más uso)

Esto es lo que hago casi todos los días cuando estoy trabajando en un proyecto:

### 1. Ver el estado de mis archivos

```bash
git status
```

Me dice qué archivos cambié, cuáles están listos para commit y cuáles no están siendo rastreados todavía.

### 2. Agregar archivos al área de preparación (staging)

Para agregar un archivo específico:

```bash
git add nombre_del_archivo.txt
```

Para agregar todos los archivos con cambios de una:

```bash
git add .
```

### 3. Hacer el commit

```bash
git commit -m "Descripción corta de lo que hice"
```

Si quiero agregar todos los cambios y hacer commit en un solo paso (solo con archivos que ya están siendo rastreados):

```bash
git commit -am "Descripción del cambio"
```

### 4. Subir los cambios a GitHub

```bash
git push origin main
```

Si la rama se llama diferente, cambio `main` por el nombre que sea:

```bash
git push origin nombre-de-la-rama
```

### 5. Traer cambios del repositorio remoto

```bash
git pull origin main
```

---

## Trabajar con ramas (branches)

Las ramas son lo mejor para no dañar el código principal mientras estoy experimentando.

Ver todas las ramas que tengo:

```bash
git branch
```

Crear una rama nueva:

```bash
git branch nombre-de-la-rama
```

Cambiarme a una rama:

```bash
git checkout nombre-de-la-rama
```

Crear una rama y cambiarme a ella al mismo tiempo (el atajo que más uso):

```bash
git checkout -b nombre-de-la-rama
```

Eliminar una rama que ya no necesito:

```bash
git branch -d nombre-de-la-rama
```

Si la rama no está fusionada y de todas formas la quiero borrar:

```bash
git branch -D nombre-de-la-rama
```

---

## Fusionar ramas (merge)

Cuando termino de trabajar en una rama y quiero unirla con `main`:

```bash
git checkout main
git merge nombre-de-la-rama
```

---

## Ver el historial de commits

Para ver todo lo que ha pasado en el proyecto:

```bash
git log
```

Si quiero verlo más resumido y en una línea por commit:

```bash
git log --oneline
```

Con un gráfico de las ramas (se ve muy bien en proyectos con varios colaboradores):

```bash
git log --oneline --graph --all
```

---

## Ver diferencias entre archivos

Ver qué cambió en los archivos que aún no están en staging:

```bash
git diff
```

Ver qué cambió en los archivos que ya están en staging:

```bash
git diff --staged
```

---

## Deshacer cosas (esto me salvó varias veces)

Sacar un archivo del staging sin perder los cambios:

```bash
git restore --staged nombre_del_archivo.txt
```

Descartar los cambios de un archivo y dejarlo como estaba en el último commit:

```bash
git restore nombre_del_archivo.txt
```

Volver a un commit anterior sin borrar el historial (la opción más segura):

```bash
git revert ID_del_commit
```

Volver a un commit anterior borrando el historial (¡cuidado con esto en ramas compartidas!):

```bash
git reset --hard ID_del_commit
```

---

## Guardar cambios temporalmente (stash)

A veces necesito cambiarme de rama pero tengo cambios sin terminar. El stash es perfecto para eso.

Guardar los cambios temporalmente:

```bash
git stash
```

Ver lo que tengo guardado en el stash:

```bash
git stash list
```

Recuperar los cambios guardados:

```bash
git stash pop
```

---

## Conectar con GitHub (remotos)

Ver los remotos que tengo configurados:

```bash
git remote -v
```

Agregar un repositorio remoto:

```bash
git remote add origin https://github.com/usuario/repositorio.git
```

Cambiar la URL del remoto:

```bash
git remote set-url origin https://github.com/usuario/nuevo-repositorio.git
```

Traer los cambios del remoto sin fusionarlos todavía:

```bash
git fetch origin
```

---

## Etiquetas (tags)

Útil para marcar versiones del proyecto.

Crear una etiqueta:

```bash
git tag v1.0.0
```

Ver todas las etiquetas:

```bash
git tag
```

Subir una etiqueta a GitHub:

```bash
git push origin v1.0.0
```

Subir todas las etiquetas de una vez:

```bash
git push origin --tags
```

---

## Algunos comandos que no se usan tanto pero igual son útiles

Ver quién modificó cada línea de un archivo:

```bash
git blame nombre_del_archivo.txt
```

Buscar un texto dentro de todos los archivos del proyecto:

```bash
git grep "texto a buscar"
```

Renombrar o mover un archivo y que Git lo registre:

```bash
git mv nombre_viejo.txt nombre_nuevo.txt
```

Eliminar un archivo del proyecto y del rastreo de Git:

```bash
git rm nombre_del_archivo.txt
```

---

## El archivo .gitignore

No es un comando pero vale la pena mencionarlo. En este archivo escribo los nombres de carpetas o archivos que no quiero que Git rastree nunca, como:

```
node_modules/
__pycache__/
.env
*.log
```

---

> **Nota personal:** Si algo sale mal, antes de entrar en pánico lo primero que hago es `git status` y `git log --oneline`. Casi siempre eso me ayuda a entender qué pasó.
