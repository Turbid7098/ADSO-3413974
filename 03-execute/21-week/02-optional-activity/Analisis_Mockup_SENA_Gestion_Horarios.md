# Análisis del Mockup — SENA Gestión de Horarios

## 1. Contexto general

Este documento analiza el mockup del sistema **SENA — Gestión de Horarios** desde el enfoque de un **Tecnólogo SENA en Análisis y Desarrollo de Software (ADSO)**. La base documental muestra un prototipo estático con datos mock y una estructura organizada por módulos y roles. El índice visual del mockup llega hasta 53 pantallas/módulos, distribuidos en **Auth y shell, Coordinador, Instructor, Aprendiz, Administrador, Back-office y Parametrización**. fileciteturn0file0L1-L6

El objetivo del análisis es identificar **errores de experiencia de usuario**, **puntos débiles de la interfaz** y **oportunidades de mejora** que puedan justificarse dentro del alcance de un proyecto ADSO de nivel tecnólogo.

## 2. Criterios de evaluación

Para cada pantalla se revisan principalmente estos aspectos:

- claridad,
- navegación,
- consistencia,
- legibilidad,
- eficiencia,
- carga cognitiva,
- estados de interacción,
- y adaptabilidad a diferentes dispositivos.

## 3. Ruta de análisis

El trabajo se desarrolló por flujo de uso:

1. Auth y shell  
2. Coordinador  
3. Instructor  
4. Aprendiz  
5. Administrador  
6. Back-office  
7. Parametrización  

Hasta este punto, el documento consolida los hallazgos de **Auth y shell** y del módulo **Coordinador**.

---

# 4. Módulo 01 — Auth y shell

## 4.1 Login

La pantalla de login presenta una estructura limpia, con identificación institucional, campos de correo y contraseña, opción para mostrar la contraseña, enlace de recuperación y botón principal de ingreso. fileciteturn1file0L1-L2

### Hallazgo 1
**Ausencia de estados de error/validación.**  
La captura muestra solamente el estado normal del formulario, pero no evidencia cómo responde el sistema ante campos vacíos, correo inválido, contraseña incorrecta o usuario no autorizado. La mejora consiste en mostrar mensajes claros de validación y errores cerca del campo correspondiente.

### Hallazgo 2
**Banner vertical institucional como mejora visual.**  
El espacio disponible puede aprovecharse mejor con un banner vertical representativo del SENA, ocupando aproximadamente la mitad de la pantalla. La idea es reforzar la identidad visual sin competir con el formulario de acceso.

---

## 4.2 Recuperar contraseña

La pantalla de recuperación indica de forma clara que el usuario debe ingresar el correo institucional y que, si existe una cuenta, se enviarán instrucciones. La segunda captura del flujo confirma que el estado de éxito sí está contemplado. fileciteturn2file0L1-L2 fileciteturn3file0L1-L2

### Hallazgo
**No se evidencian estados de validación/error para entradas incorrectas o fallos durante el proceso.**  
La mejora consiste en mostrar qué ocurre si el correo está vacío, tiene formato inválido o el envío presenta algún problema.

---

## 4.3 Nueva contraseña

La pantalla para definir una nueva contraseña incluye el título, la regla mínima de 8 caracteres, los campos de nueva contraseña y confirmación, un indicador de fortaleza y el botón de guardar. fileciteturn4file0L1-L2

### Hallazgos
**Falta de estados de validación/error.**  
Debe quedar claro qué ocurre cuando la contraseña no cumple la longitud mínima, cuando ambas contraseñas no coinciden o cuando el formulario está incompleto.

**Inconsistencia: no dispone de mostrar/ocultar contraseña como el Login.**  
La función existe en el inicio de sesión y sería coherente mantenerla también aquí.

**El indicador de fortaleza podría proporcionar información más útil.**  
En lugar de indicar solo un nivel general, podría ayudar a entender mejor qué requisito cumple o incumple la contraseña.

---

## 4.4 App shell por rol

La pantalla del app shell muestra la estructura compartida del sistema, con barra superior, navegación lateral, área de contenido y estados globales. También presenta información técnica de revisión como accesibilidad, design-system y router. fileciteturn5file0L1-L2

### Hallazgos
**Mezcla de información técnica con información destinada al usuario final.**  
La interfaz combina elementos de revisión interna con elementos de uso cotidiano, lo que puede confundir al usuario.

**Mejorar la diferenciación visual de la sección activa.**  
Conviene reforzar de forma más evidente cuál es el módulo o vista seleccionada.

**Menú lateral expandible/contraíble.**  
Una navegación que pueda contraerse permite aprovechar mejor el espacio, especialmente en pantallas pequeñas.

**El mensaje azul inferior contiene demasiada información técnica para un usuario final.**  
La explicación sobre rutas no autorizadas y variantes 403 es útil para soporte, pero no debería dominar la experiencia del usuario común.

---

## 4.5 Notificaciones

La sección de notificaciones presenta avisos enviados al usuario y, en su segunda vista, muestra paginación. fileciteturn6file0L1-L3

### Hallazgos
**Inconsistencia en la paginación.**  
La interfaz debe reflejar coherentemente la cantidad mostrada, el selector de elementos por página y el número de páginas disponibles.

**Estado de lectura poco diferenciable.**  
El icono de campana verde debería cambiar visualmente según si la notificación ya fue leída o no, para distinguir mejor el estado del aviso.

---

## 4.6 Estados globales

Las variantes del sistema muestran los estados **403**, **404**, **500** y **sesión expirada**, cada una con un mensaje y una acción principal distinta. fileciteturn7file0L1-L2 fileciteturn7file1L1-L2 fileciteturn7file2L1-L2 fileciteturn7file3L1-L2

### Hallazgo
**Mayor diferenciación visual entre los diferentes tipos de estado/error.**  
La estructura general funciona, pero se puede reforzar el reconocimiento rápido del tipo de estado para que el usuario entienda mejor qué ocurrió.

---

# 5. Módulo 02 — Coordinador

## 5.1 Dashboard / Inicio

El dashboard prioriza conflictos pendientes, indicadores generales y horarios recientes en borrador. Esa jerarquía es correcta porque pone primero lo que requiere atención. fileciteturn8file0L2-L3

### Hallazgos
**Scroll horizontal innecesario en la tabla.**  
La tabla debe mantenerse legible en todos los dispositivos. Una solución adecuada es reorganizar los registros en tarjetas verticales en pantallas pequeñas.

**Duplicación del “+” en “Nuevo horario”.**  
Debe quedar solo como **“+ Nuevo horario”** para evitar redundancia visual.

**Bloque de conflictos demasiado grande.**  
Se recomienda compactar cada conflicto manteniendo la información esencial para mostrar más contenido en el mismo espacio.

**Indicadores demasiado simples.**  
Se puede conservar el número principal, pero agregando una breve referencia contextual sin sobrecargar la tarjeta.

---

## 5.2 Horarios — Lista

La vista de horarios incluye filtros, una tabla de seguimiento y acciones como continuar edición o ver detalle. fileciteturn9file0L2-L3

### Hallazgos
**Tabla poco adaptable en pantallas pequeñas.**  
Con varias columnas, la tabla puede perder legibilidad. La mejora consiste en usar tarjetas o bloques verticales en dispositivos reducidos.

**Duplicación del “+” en “Nuevo horario”.**  
Debe corregirse igual que en el dashboard.

**“Rango de fechas” muestra una sola fecha.**  
El componente debería representar claramente una fecha inicial y una fecha final.

**Alta densidad del bloque de filtros.**  
En pantallas pequeñas conviene agrupar filtros secundarios bajo una opción como **“Más filtros”**.

---

## 5.3 Detalle de horario

La pantalla muestra la información de la ficha, el estado publicado, la tabla de sesiones y la paginación. fileciteturn10file0L2-L3

### Hallazgos
**Paginación inconsistente.**  
La cantidad mostrada, el selector por página y el número de páginas deben ser coherentes.

**Información de la columna Estado parcialmente cortada.**  
La solución es reorganizar la tabla para que el dato permanezca visible en diferentes dispositivos.

**“Ver conflictos (histórico)” es poco preciso.**  
Puede sustituirse por una etiqueta más clara como **“Ver historial de conflictos”**.

---

## 5.4 Crear / editar horario

La pantalla reúne los datos generales del horario, las sesiones y las acciones de guardar, validar y publicar. fileciteturn11file0L2-L3

### Hallazgos
**Configuración de paginación inconsistente.**  
El selector y la información de paginación deben reflejar correctamente el estado real del listado.

**Estado de las sesiones parcialmente cortado.**  
La tabla necesita una adaptación responsive para mantener visible toda la información.

**Jerarquía poco evidente entre Guardar → Validar → Publicar.**  
Conviene hacer explícito el flujo, dejando claro que validar es previo a publicar.

**Resultado de la validación no visible.**  
Debe existir un espacio para mostrar si el horario quedó válido o si hay conflictos.

**Título superior inconsistente.**  
El texto del encabezado debe ser coherente con la función actual de la pantalla.

---

## 5.5 Modal — Agregar / editar sesión

El modal muestra un conflicto visible debajo del campo de instructor: **“Este instructor ya tiene una sesión en este horario.”** fileciteturn12file0L2-L2

### Hallazgos
**El formulario permite continuar pese a un conflicto.**  
Si existe un conflicto que impide crear la sesión, se deben bloquear las acciones o casillas necesarias hasta solucionar el error.

**Faltan validaciones visibles para otros posibles errores.**  
El formulario debe mostrar mensajes claros para ambiente, franja horaria, fecha y demás campos si presentan problemas.

---

## 5.6 Modal — Confirmar publicación

El modal confirma que el horario está listo para publicarse, muestra un resumen y advierte que después de publicar no se admitirán cambios. fileciteturn13file0L2-L2

### Hallazgos
**Advertencia de publicación definitiva con poco énfasis visual.**  
Debe resaltarse mejor que, una vez publicado, el horario ya no podrá modificarse.

**Reforzar la seguridad de “Confirmar publicación”.**  
Se puede explicar en el documento final con un ejemplo de confirmación final previa a la acción definitiva.

**El resumen no identifica explícitamente su propósito.**  
Sería más claro usar un encabezado como **“Resumen del horario que se publicará”**.

---

## 5.7 Panel de conflictos

El panel muestra conflictos detectados, filtros y acciones para marcarlos como resueltos. fileciteturn14file0L2-L4

### Hallazgos
**“Marcar como resuelto” puede confundirse con solucionar realmente el conflicto.**  
Se debe diferenciar entre revisar el conflicto y corregir la causa real. Marcarlo como resuelto no siempre significa que el problema ya fue solucionado.

**No se indica claramente cuántos conflictos resultan de los filtros aplicados.**  
Conviene mostrar un contador como **“4 conflictos encontrados”** para reforzar el contexto del listado.

---

## 5.8 Disponibilidad

La vista de disponibilidad permite consultar ambientes e instructores disponibles por fecha y rango horario, mostrando estados como Disponible, No disponible y Con excepción.

### Hallazgos
**“No disponible” no explica el motivo.**  
Debe mostrarse la causa concreta del estado al consultar el detalle.

**“Con excepción” no proporciona suficiente contexto.**  
El usuario necesita saber qué excepción afecta al instructor.

**Falta confirmación visual de los criterios de búsqueda.**  
Es útil mostrar el resumen de fecha y rango horario consultados sobre los resultados.

---

## 5.9 Fichas — Lista

La vista de fichas presenta filtros, estados y una tabla general de programas y fichas.

### Hallazgos
**La tabla puede perder legibilidad en pantallas pequeñas.**  
Al tener varias columnas, conviene convertir cada registro en un bloque o tarjeta vertical en dispositivos reducidos.

**“Inicio desde” puede ser ambiguo.**  
Se sugiere usar una etiqueta más explícita como **“Fecha de inicio desde”**.

**Falta una acción claramente identificable para consultar el detalle de la ficha.**  
El número de ficha puede seguir funcionando como enlace, pero sería útil reforzarlo con una acción visible tipo **“Ver detalle”**.

---

## 5.10 Detalle de ficha

La vista de detalle de ficha presenta información del programa, datos de la ficha y horarios asociados. fileciteturn15file0L2-L3

### Hallazgo
**Desplazamiento horizontal innecesario en “Horarios de esta ficha”.**  
La tabla debe adaptarse mejor al espacio disponible. En pantallas pequeñas, la información puede reorganizarse en tarjetas verticales para evitar scroll horizontal.

---

# 6. Conclusión parcial

Hasta este punto, el mockup tiene una base sólida y una organización funcional clara por roles. La estructura general del sistema está bien planteada y varios componentes ya transmiten correctamente la intención de uso.

Sin embargo, los principales problemas detectados están relacionados con:

- validaciones ausentes o incompletas,
- paginación incoherente en algunas vistas,
- tablas que necesitan mejor comportamiento responsive,
- mensajes que deben contextualizar mejor su propósito,
- y acciones que requieren mayor claridad para el usuario.

Este documento queda como **base de análisis parcial** y puede ampliarse más adelante con los módulos pendientes por revisar.
