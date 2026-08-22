-- =====================================================================
-- SENA -- Gestion de Horarios
-- Script DDL (MySQL 8.0+)
-- Basado en el inventario real de 53 pantallas del Mockup V2 y en los
-- 16 procesos BPMN 2.0 construidos a partir de el (ver documento de
-- analisis). No se modelan tablas para funcionalidades no confirmadas
-- en el mockup (ej. no existe alta/edicion de Fichas: son de solo
-- consulta, ver BPMN-11).
-- =====================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS sena_gestion_horarios
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sena_gestion_horarios;

-- =====================================================================
-- 1. GEOGRAFIA INSTITUCIONAL  (pantalla 52 -- Parametrizacion)
-- Jerarquia: Macroregion -> Microregion -> Departamento -> Municipio
--            -> Centro de formacion -> Unidad
-- =====================================================================

CREATE TABLE macrorregiones (
  id_macrorregion    INT AUTO_INCREMENT PRIMARY KEY,
  nombre             VARCHAR(120) NOT NULL,
  estado             ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo'
) ENGINE=InnoDB;

CREATE TABLE microrregiones (
  id_microrregion    INT AUTO_INCREMENT PRIMARY KEY,
  id_macrorregion     INT NOT NULL,
  nombre             VARCHAR(120) NOT NULL,
  estado             ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
  CONSTRAINT fk_micro_macro FOREIGN KEY (id_macrorregion) REFERENCES macrorregiones(id_macrorregion)
) ENGINE=InnoDB;

CREATE TABLE departamentos (
  id_departamento    INT AUTO_INCREMENT PRIMARY KEY,
  id_microrregion     INT NOT NULL,
  nombre             VARCHAR(120) NOT NULL,
  estado             ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
  CONSTRAINT fk_depto_micro FOREIGN KEY (id_microrregion) REFERENCES microrregiones(id_microrregion)
) ENGINE=InnoDB;

CREATE TABLE municipios (
  id_municipio       INT AUTO_INCREMENT PRIMARY KEY,
  id_departamento    INT NOT NULL,
  nombre             VARCHAR(120) NOT NULL,
  estado             ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
  CONSTRAINT fk_municipio_depto FOREIGN KEY (id_departamento) REFERENCES departamentos(id_departamento)
) ENGINE=InnoDB;

-- Pantalla 52: Centros de formacion (codigo, nombre, municipio, direccion,
-- telefono, estado) -- confirmado por captura "Parametrizacion - Geografia
-- institucional".
CREATE TABLE centros_formacion (
  id_centro          INT AUTO_INCREMENT PRIMARY KEY,
  codigo             VARCHAR(20) NOT NULL UNIQUE,
  nombre             VARCHAR(150) NOT NULL,
  id_municipio       INT NOT NULL,
  direccion          VARCHAR(200),
  telefono           VARCHAR(30),
  estado             ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
  CONSTRAINT fk_centro_municipio FOREIGN KEY (id_municipio) REFERENCES municipios(id_municipio)
) ENGINE=InnoDB;

CREATE TABLE unidades (
  id_unidad          INT AUTO_INCREMENT PRIMARY KEY,
  id_centro          INT NOT NULL,
  nombre             VARCHAR(120) NOT NULL,
  estado             ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
  CONSTRAINT fk_unidad_centro FOREIGN KEY (id_centro) REFERENCES centros_formacion(id_centro)
) ENGINE=InnoDB;

-- =====================================================================
-- 2. CATALOGOS Y PARAMETROS GENERICOS
-- Pantallas 35,36,40,45,46-51 (Datos de referencia / Parametrizacion /
-- CRUD catalogo). Confirmado: todos los catalogos simples (modalidad,
-- jornada, tipo de ambiente, estados de actor, tipos de excepcion, etc.)
-- comparten UNA misma estructura codigo/nombre con el mismo patron de
-- autorizacion (solo ADMIN_STAFF / SYSTEM_ADMIN editan). Ver BPMN-16.
-- =====================================================================

CREATE TABLE catalogos (
  id_catalogo        INT AUTO_INCREMENT PRIMARY KEY,
  codigo             VARCHAR(60) NOT NULL UNIQUE,   -- TRAINING_MODALITY, TRAINING_SHIFT, ENVIRONMENT_TYPE...
  nombre             VARCHAR(150) NOT NULL,          -- "Modalidad de formacion", "Jornada de formacion"...
  descripcion        VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE valores_catalogo (
  id_valor           INT AUTO_INCREMENT PRIMARY KEY,
  id_catalogo        INT NOT NULL,
  codigo             VARCHAR(60) NOT NULL,
  nombre             VARCHAR(150) NOT NULL,
  estado             ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
  orden               INT DEFAULT 0,
  CONSTRAINT fk_valor_catalogo FOREIGN KEY (id_catalogo) REFERENCES catalogos(id_catalogo),
  UNIQUE KEY uq_valor_por_catalogo (id_catalogo, codigo)
) ENGINE=InnoDB;

-- Pantalla 36 -- "Parametros" (clave/valor/tipo/descripcion). Confirmado:
-- solo SYSTEM_ADMIN puede editar (regla mas estricta que los catalogos).
CREATE TABLE parametros_sistema (
  clave              VARCHAR(80) PRIMARY KEY,        -- MAX_HOURS_PER_WEEK, SCHEDULE_LOCK_MINUTES...
  valor              VARCHAR(255) NOT NULL,
  tipo               ENUM('integer','decimal','string','boolean') NOT NULL,
  descripcion        VARCHAR(255),
  modificado_por     INT,
  fecha_modificacion DATETIME
) ENGINE=InnoDB;

-- =====================================================================
-- 3. IAM -- USUARIOS, ROLES Y PERMISOS
-- Pantallas 1,2,3,29-34,53 (Login, recuperacion, usuarios, RBAC).
-- Roles confirmados (7): SYSTEM_ADMIN, CENTER_DIRECTOR, COORDINATOR,
-- AREA_LEADER, INSTRUCTOR, LEARNER, ADMIN_STAFF.
-- =====================================================================

CREATE TABLE roles (
  id_rol             INT AUTO_INCREMENT PRIMARY KEY,
  codigo             VARCHAR(40) NOT NULL UNIQUE,    -- SYSTEM_ADMIN, COORDINATOR...
  nombre             VARCHAR(120) NOT NULL,          -- "Coordinador Academico"
  descripcion        VARCHAR(255),
  tipo               ENUM('Rol de sistema','Rol personalizado') NOT NULL DEFAULT 'Rol de sistema',
  estado             ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo'
) ENGINE=InnoDB;

CREATE TABLE permisos (
  id_permiso         INT AUTO_INCREMENT PRIMARY KEY,
  codigo             VARCHAR(60) NOT NULL UNIQUE,    -- SCH_VIEW_OWN, SCH_PUBLISH, REF_EDIT...
  descripcion        VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE rol_permiso (
  id_rol             INT NOT NULL,
  id_permiso         INT NOT NULL,
  PRIMARY KEY (id_rol, id_permiso),
  CONSTRAINT fk_rp_rol FOREIGN KEY (id_rol) REFERENCES roles(id_rol),
  CONSTRAINT fk_rp_permiso FOREIGN KEY (id_permiso) REFERENCES permisos(id_permiso)
) ENGINE=InnoDB;

-- Pantallas 31-33: Usuarios -- lista / crear-editar / detalle.
CREATE TABLE usuarios (
  id_usuario         INT AUTO_INCREMENT PRIMARY KEY,
  nombre_completo    VARCHAR(150) NOT NULL,
  correo             VARCHAR(150) NOT NULL UNIQUE,
  password_hash      VARCHAR(255) NOT NULL,
  id_centro          INT,
  estado             ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
  ultimo_acceso      DATETIME,
  fecha_creacion     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_usuario_centro FOREIGN KEY (id_centro) REFERENCES centros_formacion(id_centro)
) ENGINE=InnoDB;

-- Pantalla 34: Modal asignar / revocar rol -- se modela como historico
-- (permite auditar cuando se asigno o revoco cada rol).
CREATE TABLE usuario_rol (
  id_usuario_rol     INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario         INT NOT NULL,
  id_rol             INT NOT NULL,
  estado             ENUM('Activo','Revocado') NOT NULL DEFAULT 'Activo',
  asignado_por       INT,
  fecha_asignacion   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_revocacion   DATETIME,
  CONSTRAINT fk_ur_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
  CONSTRAINT fk_ur_rol FOREIGN KEY (id_rol) REFERENCES roles(id_rol),
  CONSTRAINT fk_ur_asignador FOREIGN KEY (asignado_por) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

-- Pantallas 2,3: recuperacion de contrasena (BPMN-01).
CREATE TABLE tokens_recuperacion (
  id_token           INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario         INT NOT NULL,
  token              VARCHAR(255) NOT NULL UNIQUE,
  fecha_solicitud    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_expiracion   DATETIME NOT NULL,
  usado              BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT fk_token_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

-- =====================================================================
-- 4. ACADEMICO -- PROGRAMAS, COMPETENCIAS, FICHAS
-- Pantallas 17,18 (Fichas -- SOLO CONSULTA, confirmado: no existe boton
-- "nueva ficha" en el mockup) y 47 (Curriculo academico, Parametrizacion).
-- =====================================================================

CREATE TABLE programas (
  id_programa        INT AUTO_INCREMENT PRIMARY KEY,
  codigo             VARCHAR(20) NOT NULL UNIQUE,    -- 233104
  nombre             VARCHAR(150) NOT NULL,          -- "Analisis y Desarrollo de Software"
  estado             ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo'
) ENGINE=InnoDB;

-- Pantalla 47 -- Curriculo academico (competencias por programa).
CREATE TABLE competencias (
  id_competencia     INT AUTO_INCREMENT PRIMARY KEY,
  id_programa        INT NOT NULL,
  nombre             VARCHAR(200) NOT NULL,          -- "Desarrollar software segun requerimientos"
  estado             ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
  CONSTRAINT fk_competencia_programa FOREIGN KEY (id_programa) REFERENCES programas(id_programa)
) ENGINE=InnoDB;

-- Pantallas 17,18 -- Fichas (solo lectura desde este sistema; el origen
-- del dato se asume Sofia Plus / sistema academico externo).
CREATE TABLE fichas (
  id_ficha           INT PRIMARY KEY,                -- codigo real de ficha, ej. 2874412
  id_programa        INT NOT NULL,
  id_centro          INT NOT NULL,
  id_jornada         INT NOT NULL,                   -- valores_catalogo (TRAINING_SHIFT)
  id_modalidad       INT NOT NULL,                   -- valores_catalogo (TRAINING_MODALITY)
  cupo_maximo        INT NOT NULL,
  fecha_inicio       DATE NOT NULL,
  fecha_fin_esperada DATE,
  fecha_fin_real     DATE,
  estado             ENUM('Induccion','Ejecucion','Etapa productiva','Finalizada') NOT NULL,
  fecha_actualizacion DATETIME,
  CONSTRAINT fk_ficha_programa FOREIGN KEY (id_programa) REFERENCES programas(id_programa),
  CONSTRAINT fk_ficha_centro FOREIGN KEY (id_centro) REFERENCES centros_formacion(id_centro),
  CONSTRAINT fk_ficha_jornada FOREIGN KEY (id_jornada) REFERENCES valores_catalogo(id_valor),
  CONSTRAINT fk_ficha_modalidad FOREIGN KEY (id_modalidad) REFERENCES valores_catalogo(id_valor)
) ENGINE=InnoDB;

-- Matricula del aprendiz en una ficha (usuario con rol LEARNER).
CREATE TABLE matriculas (
  id_matricula       INT AUTO_INCREMENT PRIMARY KEY,
  id_ficha           INT NOT NULL,
  id_usuario         INT NOT NULL,
  fecha_matricula    DATE NOT NULL,
  estado             ENUM('Activo','Retirado','Certificado') NOT NULL DEFAULT 'Activo',
  CONSTRAINT fk_matricula_ficha FOREIGN KEY (id_ficha) REFERENCES fichas(id_ficha),
  CONSTRAINT fk_matricula_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
  UNIQUE KEY uq_ficha_aprendiz (id_ficha, id_usuario)
) ENGINE=InnoDB;

-- =====================================================================
-- 5. AMBIENTES
-- Pantallas 15,16 (Disponibilidad, Detalle de ambiente -- consulta) y
-- 49 (Tipos de ambiente e inventario, Parametrizacion).
-- =====================================================================

CREATE TABLE ambientes (
  id_ambiente        INT AUTO_INCREMENT PRIMARY KEY,
  codigo             VARCHAR(20) NOT NULL UNIQUE,    -- A-204
  nombre             VARCHAR(120) NOT NULL,          -- "Laboratorio A-204"
  id_tipo_ambiente   INT NOT NULL,                   -- valores_catalogo (ENVIRONMENT_TYPE)
  id_centro          INT NOT NULL,
  aforo              INT NOT NULL,
  ubicacion          VARCHAR(120),                   -- "Bloque A, piso 2"
  estado_inspeccion  ENUM('Vigente','Vencida','Sin inspeccion') NOT NULL DEFAULT 'Sin inspeccion',
  fecha_inspeccion   DATE,
  certificacion_requerida VARCHAR(120),
  estado             ENUM('Disponible','No disponible') NOT NULL DEFAULT 'Disponible',
  CONSTRAINT fk_ambiente_tipo FOREIGN KEY (id_tipo_ambiente) REFERENCES valores_catalogo(id_valor),
  CONSTRAINT fk_ambiente_centro FOREIGN KEY (id_centro) REFERENCES centros_formacion(id_centro)
) ENGINE=InnoDB;

CREATE TABLE mantenimientos_ambiente (
  id_mantenimiento   INT AUTO_INCREMENT PRIMARY KEY,
  id_ambiente        INT NOT NULL,
  fecha_inicio       DATETIME NOT NULL,
  fecha_fin          DATETIME NOT NULL,
  motivo             VARCHAR(255),
  CONSTRAINT fk_mant_ambiente FOREIGN KEY (id_ambiente) REFERENCES ambientes(id_ambiente)
) ENGINE=InnoDB;

-- =====================================================================
-- 6. HORARIOS -- SESIONES -- CONFLICTOS
-- Pantallas 7-14 (dashboard, lista, detalle, crear/editar, modal sesion,
-- modal publicacion, panel de conflictos, modal resolver conflicto).
-- Corresponde a BPMN-02, BPMN-03, BPMN-04.
-- =====================================================================

CREATE TABLE horarios (
  id_horario         INT AUTO_INCREMENT PRIMARY KEY,
  id_ficha           INT NOT NULL,
  periodo            VARCHAR(20) NOT NULL,           -- "2026-2"
  nombre             VARCHAR(150) NOT NULL,          -- "ADSO -- Trimestre III"
  estado             ENUM('Borrador','En revision','Publicado') NOT NULL DEFAULT 'Borrador',
  creado_por         INT NOT NULL,
  fecha_creacion     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  publicado_por      INT,
  fecha_publicacion  DATETIME,
  fecha_actualizacion DATETIME,
  CONSTRAINT fk_horario_ficha FOREIGN KEY (id_ficha) REFERENCES fichas(id_ficha),
  CONSTRAINT fk_horario_creador FOREIGN KEY (creado_por) REFERENCES usuarios(id_usuario),
  CONSTRAINT fk_horario_publicador FOREIGN KEY (publicado_por) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

CREATE TABLE sesiones (
  id_sesion          INT AUTO_INCREMENT PRIMARY KEY,
  id_horario         INT NOT NULL,
  id_competencia     INT NOT NULL,
  id_instructor      INT NOT NULL,                   -- usuarios (rol INSTRUCTOR)
  id_ambiente        INT NOT NULL,
  dia_semana         ENUM('Lunes','Martes','Miercoles','Jueves','Viernes','Sabado') NOT NULL,
  fecha              DATE NOT NULL,
  hora_inicio        TIME NOT NULL,
  hora_fin           TIME NOT NULL,
  notas              VARCHAR(255),
  estado             ENUM('Activa','Cancelada') NOT NULL DEFAULT 'Activa',
  ejecucion_estado   ENUM('Pendiente','Ejecutada','No ejecutada') NOT NULL DEFAULT 'Pendiente',
  CONSTRAINT fk_sesion_horario FOREIGN KEY (id_horario) REFERENCES horarios(id_horario),
  CONSTRAINT fk_sesion_competencia FOREIGN KEY (id_competencia) REFERENCES competencias(id_competencia),
  CONSTRAINT fk_sesion_instructor FOREIGN KEY (id_instructor) REFERENCES usuarios(id_usuario),
  CONSTRAINT fk_sesion_ambiente FOREIGN KEY (id_ambiente) REFERENCES ambientes(id_ambiente)
) ENGINE=InnoDB;

-- Pantallas 13,14 -- Panel de conflictos / Modal resolver conflicto.
CREATE TABLE conflictos_horario (
  id_conflicto       INT AUTO_INCREMENT PRIMARY KEY,
  id_horario         INT NOT NULL,
  tipo               ENUM('Instructor doble-asignado','Ambiente doble-asignado','Sesiones solapadas') NOT NULL,
  severidad          ENUM('Alta','Media','Baja') NOT NULL,
  id_sesion_1        INT NOT NULL,
  id_sesion_2        INT,
  bloquea_publicacion BOOLEAN NOT NULL DEFAULT TRUE,
  estado             ENUM('Pendiente','Resuelto') NOT NULL DEFAULT 'Pendiente',
  fecha_deteccion    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  justificacion_resolucion VARCHAR(500),
  resuelto_por       INT,
  fecha_resolucion   DATETIME,
  CONSTRAINT fk_conflicto_horario FOREIGN KEY (id_horario) REFERENCES horarios(id_horario),
  CONSTRAINT fk_conflicto_sesion1 FOREIGN KEY (id_sesion_1) REFERENCES sesiones(id_sesion),
  CONSTRAINT fk_conflicto_sesion2 FOREIGN KEY (id_sesion_2) REFERENCES sesiones(id_sesion),
  CONSTRAINT fk_conflicto_resolutor FOREIGN KEY (resuelto_por) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

-- =====================================================================
-- 7. DISPONIBILIDAD DEL INSTRUCTOR
-- Pantallas 21,22 (Mi disponibilidad, Modal crear excepcion). BPMN-05.
-- =====================================================================

CREATE TABLE excepciones_disponibilidad (
  id_excepcion       INT AUTO_INCREMENT PRIMARY KEY,
  id_instructor      INT NOT NULL,
  tipo               ENUM('Incapacidad medica','Capacitacion','Comision') NOT NULL,
  fecha_inicio       DATETIME NOT NULL,
  fecha_fin          DATETIME NOT NULL,
  descripcion        VARCHAR(255),
  documento_soporte_url VARCHAR(255),               -- obligatorio para los 3 tipos (confirmado)
  estado             ENUM('Pendiente de revision','Aprobada','Rechazada','Anulada') NOT NULL DEFAULT 'Pendiente de revision',
  revisado_por       INT,
  fecha_revision     DATETIME,
  comentario_revision VARCHAR(255),
  CONSTRAINT fk_excepcion_instructor FOREIGN KEY (id_instructor) REFERENCES usuarios(id_usuario),
  CONSTRAINT fk_excepcion_revisor FOREIGN KEY (revisado_por) REFERENCES usuarios(id_usuario),
  CHECK (fecha_fin > fecha_inicio)
) ENGINE=InnoDB;

-- =====================================================================
-- 8. SEGUIMIENTO ACADEMICO E INDICADORES (KPI)
-- Pantallas 23,24 (Seguimiento de ficha, Registrar seguimiento) y
-- 29,30,50 (Panel de indicadores, Drill-down, Catalogos de monitoreo).
-- BPMN-09, BPMN-12.
-- =====================================================================

CREATE TABLE seguimientos_ficha (
  id_seguimiento     INT AUTO_INCREMENT PRIMARY KEY,
  id_ficha           INT NOT NULL,
  id_instructor      INT NOT NULL,
  fecha              DATE NOT NULL,
  tipo_sesion        ENUM('Academico','Proyecto','Bienestar') NOT NULL,
  asistentes         INT NOT NULL,
  total_aprendices   INT NOT NULL,
  avance_curricular_pct DECIMAL(5,2) NOT NULL,
  requiere_seguimiento BOOLEAN NOT NULL DEFAULT FALSE,
  observaciones      VARCHAR(500),
  CONSTRAINT fk_seg_ficha FOREIGN KEY (id_ficha) REFERENCES fichas(id_ficha),
  CONSTRAINT fk_seg_instructor FOREIGN KEY (id_instructor) REFERENCES usuarios(id_usuario),
  CHECK (asistentes <= total_aprendices)
) ENGINE=InnoDB;

-- Pantalla 50 -- catalogo de KPI (con umbral, a diferencia de los
-- catalogos simples codigo/nombre).
CREATE TABLE indicadores_kpi (
  id_kpi             INT AUTO_INCREMENT PRIMARY KEY,
  nombre             VARCHAR(120) NOT NULL,          -- "Asistencia", "Avance curricular"...
  umbral             DECIMAL(6,2) NOT NULL,
  unidad             ENUM('porcentaje','numero') NOT NULL DEFAULT 'porcentaje',
  estado             ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo'
) ENGINE=InnoDB;

CREATE TABLE mediciones_kpi (
  id_medicion        INT AUTO_INCREMENT PRIMARY KEY,
  id_kpi             INT NOT NULL,
  id_ficha           INT NOT NULL,
  periodo            VARCHAR(20) NOT NULL,           -- "Ago 2026"
  valor              DECIMAL(6,2) NOT NULL,
  estado             ENUM('En seguimiento','En riesgo','Critico') NOT NULL,
  fecha_medicion     DATE NOT NULL,
  CONSTRAINT fk_medicion_kpi FOREIGN KEY (id_kpi) REFERENCES indicadores_kpi(id_kpi),
  CONSTRAINT fk_medicion_ficha FOREIGN KEY (id_ficha) REFERENCES fichas(id_ficha)
) ENGINE=InnoDB;

-- =====================================================================
-- 9. NOTIFICACIONES
-- Pantallas 5,26,28 (Panel de notificaciones, Notificaciones, Detalle).
-- BPMN-07.
-- =====================================================================

CREATE TABLE notificaciones (
  id_notificacion    INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario_destino INT NOT NULL,
  tipo               ENUM('Cambio de ambiente','Horario publicado','Sesion cancelada',
                            'Seguimiento academico','Actualizacion de horario') NOT NULL,
  titulo             VARCHAR(150) NOT NULL,
  mensaje            VARCHAR(500) NOT NULL,
  prioridad          ENUM('Alta','Normal') NOT NULL DEFAULT 'Normal',
  estado_lectura     ENUM('Nueva','Leida') NOT NULL DEFAULT 'Nueva',
  estado_envio       ENUM('Enviado','Enviando','No se pudo entregar') NOT NULL DEFAULT 'Enviando',
  entidad_tipo       VARCHAR(60),                    -- 'horario','sesion','excepcion'...
  entidad_id         INT,
  fecha_creacion     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notif_usuario FOREIGN KEY (id_usuario_destino) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

-- =====================================================================
-- 10. GESTION DOCUMENTAL
-- Pantallas 37,38,41,42,43 (Documentos, Plantillas, Detalle+versiones,
-- Generar documento, Editor/preview). BPMN-14.
-- =====================================================================

CREATE TABLE plantillas_documento (
  id_plantilla       INT AUTO_INCREMENT PRIMARY KEY,
  nombre             VARCHAR(150) NOT NULL,
  contenido_url      VARCHAR(255),
  estado             ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo'
) ENGINE=InnoDB;

CREATE TABLE documentos (
  id_documento       INT AUTO_INCREMENT PRIMARY KEY,
  id_plantilla       INT NOT NULL,
  nombre             VARCHAR(150) NOT NULL,
  entidad_origen_tipo VARCHAR(60),                   -- 'ficha','horario','excepcion'...
  entidad_origen_id  INT,
  generado_por       INT NOT NULL,
  fecha_generacion   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_doc_plantilla FOREIGN KEY (id_plantilla) REFERENCES plantillas_documento(id_plantilla),
  CONSTRAINT fk_doc_generador FOREIGN KEY (generado_por) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

CREATE TABLE versiones_documento (
  id_version         INT AUTO_INCREMENT PRIMARY KEY,
  id_documento       INT NOT NULL,
  numero_version     INT NOT NULL,
  contenido_url      VARCHAR(255) NOT NULL,
  creado_por         INT NOT NULL,
  fecha_creacion     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_version_documento FOREIGN KEY (id_documento) REFERENCES documentos(id_documento),
  CONSTRAINT fk_version_creador FOREIGN KEY (creado_por) REFERENCES usuarios(id_usuario),
  UNIQUE KEY uq_doc_version (id_documento, numero_version)
) ENGINE=InnoDB;

-- =====================================================================
-- 11. AUDITORIA
-- Pantallas 39,44 (Auditoria, Modal detalle de auditoria). BPMN-15.
-- Registra tambien las resoluciones de conflicto y ediciones de
-- catalogos/parametros, que exigen trazabilidad segun lo confirmado.
-- =====================================================================

CREATE TABLE auditoria (
  id_evento          BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_usuario         INT,
  accion             VARCHAR(100) NOT NULL,          -- 'PUBLICAR_HORARIO','RESOLVER_CONFLICTO','EDITAR_CATALOGO'...
  entidad_tipo       VARCHAR(60) NOT NULL,
  entidad_id         VARCHAR(60),
  detalle            VARCHAR(500),
  fecha_evento       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ip_origen          VARCHAR(45),
  CONSTRAINT fk_auditoria_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

-- =====================================================================
-- INDICES ADICIONALES DE APOYO A CONSULTAS FRECUENTES
-- =====================================================================

CREATE INDEX idx_sesiones_instructor_fecha ON sesiones (id_instructor, fecha, hora_inicio);
CREATE INDEX idx_sesiones_ambiente_fecha   ON sesiones (id_ambiente, fecha, hora_inicio);
CREATE INDEX idx_horarios_ficha_estado     ON horarios (id_ficha, estado);
CREATE INDEX idx_conflictos_estado         ON conflictos_horario (estado, severidad);
CREATE INDEX idx_notificaciones_usuario    ON notificaciones (id_usuario_destino, estado_lectura);
CREATE INDEX idx_auditoria_entidad         ON auditoria (entidad_tipo, entidad_id);
CREATE INDEX idx_mediciones_ficha_periodo  ON mediciones_kpi (id_ficha, periodo);

SET FOREIGN_KEY_CHECKS = 1;
