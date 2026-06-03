# Guía: Cómo configurar OpenClaw para publicar un Newsletter con cadencia, research curado y buena escritura

> Una guía de builder, basada en la implementación real de **AI for Executives** — un Substack de inteligencia artificial para ejecutivos LATAM construido íntegramente con OpenClaw desde Telegram.
>
> Esta guía te muestra **el patrón exacto** para replicar el sistema en cualquier tema: finanzas, climate tech, biotech, startups, lo que sea. No te enseña la teoría — te muestra los mensajes literales, las plantillas, los crons y los troubleshootings.

---

## TL;DR — el sistema en una imagen mental

```
┌─────────────────────────────────────────────────────────────────┐
│  TELEGRAM (interfaz)                                            │
│  ── tú hablas/escribes a tu agente OpenClaw                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  AGENTE OPENCLAW                                                │
│  ── identidad + memoria persistente                             │
│  ── workspace: /root/.openclaw/workspace/projects/<tu-proyecto>/│
│  ── 4 crons activos (research diario + 3 ediciones semanales)   │
└─────────────────────────────────────────────────────────────────┘
        │                     │                       │
        ▼                     ▼                       ▼
┌──────────────┐     ┌──────────────────┐    ┌─────────────────┐
│ NOTION       │     │ SLACK            │    │ SUBSTACK        │
│ ── HQ docs   │     │ ── notificación  │    │ ── publicación  │
│ ── DB Research│    │   al equipo de   │    │   manual final  │
│ ── DB Pipeline│    │   feedback       │    │   (copy/paste)  │
└──────────────┘     └──────────────────┘    └─────────────────┘
```

**El flujo semanal en mente:**

```
Día      Hora        Cron                                       Tu tiempo
─────────────────────────────────────────────────────────────────────────
Diario   06:00       Research + scoring + bank to Notion          0 min
Diario   ad-hoc      Nugget check (alertas urgentes)              5 min
Lunes    06:30       Edición Profunda — selecciona y arranca     30 min
Miércoles 06:30      Herramientas en Acción — usa transcript     20 min
Viernes  07:00       Briefing Ejecutivo — top 3 noticias         20 min
─────────────────────────────────────────────────────────────────────────
TOTAL                                                          ~80 min/sem
```

---

## Parte 0 — Mentalidad

Antes de tocar Telegram, internaliza esto:

1. **No es no-code tipo Zapier.** No tienes nodos, ni un canvas visual, ni JSON. La configuración **es la conversación**. Cada mensaje de voz o texto que le mandas al bot queda como contexto, memoria, regla, o ejecución.

2. **OpenClaw vive en un filesystem.** Cuando configuras un proyecto, el bot crea archivos en `/root/.openclaw/workspace/projects/<tu-proyecto>/` (playbooks, guías, configs, credenciales). Pídele que te muestre la estructura si quieres verla.

3. **La memoria es persistente y versionada.** El bot guarda todo lo que defines (identidad, guías editoriales, playbooks) en archivos `.md` y puede versionarlos (`V1.0`, `V1.3`, etc.). Cuando le pides cambios, sube la versión.

4. **El bot puede iniciar acciones automáticas.** Configurando crons, OpenClaw despierta solo a la hora que le digas y ejecuta su rutina (research, drafting, scoring) sin que tú mandes nada.

5. **Las APIs externas se conectan con credenciales que tú le pasas.** Notion (token), Slack (bot token + channel), OpenAI/Groq (API key), Whisper (instalación en servidor). Estas viven en archivos del workspace.

6. **El bot pide permiso antes de cambiar cosas.** Le pones la regla "siempre que vayas a crear algo, cuéntame y aprobamos" y la respeta.

> **Insight clave:** la fórmula que destrabó todo es **"yo digo qué quiero → el bot propone → yo apruebo → el bot guarda y ejecuta"**. No funciona si tú quieres dictar la estructura. Funciona si tú das contexto + intención y dejas que el bot proponga.

---

## Parte 1 — Pre-requisitos (Día -1)

Antes de mandar `/start`, ten esto listo:

| Recurso | Para qué | Cómo obtenerlo |
|---|---|---|
| **Cuenta OpenClaw** + agente en Telegram | Es el bot mismo | https://openclaw.com (instala el bot, te da un chat de Telegram personal) |
| **API key de Groq** (gratis) | Para que el bot transcriba audios de voz | console.groq.com → API Keys |
| **API key de OpenAI** (opcional, paga) | Para transcripción más fina con Whisper hosted | platform.openai.com |
| **Integration token de Notion** | Para que escriba en tu Notion | notion.so/my-integrations → New integration → copiar token |
| **Página de Notion compartida** con el integration | El "HQ" del newsletter | Crea página → Share → Add connection → tu integration |
| **Bot de Slack** (opcional) | Para notificar a tu equipo de feedback | api.slack.com/apps → Create New App → bot token + canal donde pueda escribir |
| **Cuenta de Substack** ya creada | Destino de publicación | substack.com — no necesita API |
| **Brief editorial** (opcional, recomendado) | El "ADN" del newsletter | 1 documento con: para quién, tono, voz, sources, no-hacer |

> **Truco real:** la guía editorial de AI for Executives empezó como un Google Doc largo que se le pegó al bot, no como una respuesta corta en chat. Si tienes el documento, mejor. Si no, el bot te puede ayudar a construirlo en conversación (Parte 3).

---

## Parte 2 — Setup inicial: identidad + comandos base (Día 1, primeros 10 min)

### Paso 2.1 — `/start`

```
Tú: /start
```

El bot abre el wizard inicial. La primera pregunta es esencialmente *"¿quién eres tú y cómo me quieres llamar?"*.

### Paso 2.2 — Define la identidad del agente

Esta es **la decisión más importante de toda la configuración**. La identidad determina cómo el agente se va a comportar en todos los siguientes meses.

**Plantilla de mensaje (texto o voz):**

```
Tú eres [NOMBRE DEL AGENTE] y yo soy [TU NOMBRE].

Tú eres una versión de mí pero con esteroides. Yo te voy a compartir
todo lo que sea, vamos a co-crear, y tú me vas a ayudar a:
- crear proyectos
- crear estrategia
- crear tareas
- comunicarte con mi equipo (reportes, follow-ups, responder preguntas)

Eres genio, eres muy inteligente, sabes todo, y lo más importante:
todo lo haces con un nivel de detalle y de calidad excepcional.
Eres orientada al detalle y a la calidad siempre.
```

> Notas reales del chat de AI for Executives:
> - El bot confirma con algo como: *"Ya soy oficialmente [NOMBRE]. Ya borré el archivo de bootstrap."*
> - El bot **literalmente reemplaza su archivo de bootstrap** con tu identidad — esto se vuelve su system prompt persistente.

### Paso 2.3 — Carga el contexto del mundo donde vive

Cuando ya tiene identidad, pásale el "mundo" en el que va a trabajar. Sin esto el bot no puede juzgar relevancia.

**Plantilla:**

```
Antes de empezar el primer proyecto, contexto rápido de todo lo que hago.

EMPRESA: [Nombre + 1 línea de misión]
- Lo que más nos caracteriza es [CALIDAD / RIGOR / VELOCIDAD / etc.]
- Esto debe estar en tu ADN.

FUNDADORES / STAKEHOLDERS CLAVE:
- [Persona 1] — [rol, contexto, qué te aprueba / a quién le reportas]
- [Persona 2] — [rol]
- [Persona 3] — [rol]

MI ROL: [tu posición + qué proyectos tienes en marcha]

CULTURA / VALORES no-negociables:
- [ej: nunca usamos fuentes sin verificar]
- [ej: siempre la calidad va sobre la velocidad]
- [ej: empatía total con el cliente]
```

> El bot guarda esto como contexto permanente. Cada decisión futura (qué fuente usar, qué tono escribir) la va a chequear contra este marco.

### Paso 2.4 — Habilita la transcripción de audio (necesario casi siempre)

Tú vas a hablar mucho por voz. El bot por defecto **no transcribe**. La conversación literal es:

```
Tú: [audio largo]
Bot: Mmm, revisé todo — el problema no es una Skill, sino que
     necesito una API key para transcribir audio. OpenClaw puede usar:
     • OpenAI (Whisper/gpt-4o-mini-transcribe) — necesita OPENAI_API_KEY
     • Groq — necesita GROQ_API_KEY (tiene capa gratuita 🆓)
     • Deepgram — necesita DEEPGRAM_API_KEY
     • Whisper local — se instala en el servidor, sin costo
     ¿Tienes alguna de estas API keys?
```

**Respuesta sugerida:**

```
Usa Groq gratis. Mi GROQ_API_KEY es: gsk_xxxxxxxxxxxxxxxx

Cuando ya esté guardada, instala también Whisper local en el servidor
como respaldo gratuito para cuando se acabe la capa gratis de Groq.
```

El bot guarda la key en su workspace (no la vas a ver más) y desde ahí transcribe todo lo que mandes por voz.

---

## Parte 3 — Definir el capability (Día 1, mismo día, ~2 horas)

### Por qué un "capability"

Antes de pedirle al bot que ejecute, hay que enmarcar el proyecto como **una capability** — una capacidad repetible que vas a montar. El framework que se usa (y que el bot conoce) es el **Canvas de Declaración del Problema** de Andrés Bilbao (30X), con 7 campos:

1. **Pregunta básica / Objetivo SMART**
2. **Perspectiva / Contexto**
3. **Criterios de éxito y métricas clave del negocio**
4. **Alcance del espacio de solución**
5. **Restricciones**
6. **Stakeholders**
7. **Fuentes clave de conocimiento** ← *el más subestimado, el más importante*
8. **Quick Wins** (capturan valor inmediato)

### Cómo llenar el canvas con el bot

No le mandes un mensaje gigante. Llena campo por campo, en orden.

**Mensaje de arranque:**

```
El primer proyecto que vamos a hacer es un Substack llamado
"[NOMBRE DEL NEWSLETTER]".

Vamos a usar el canvas de capability para enmarcarlo bien antes
de ejecutar. Empecemos por la pregunta básica / objetivo SMART.

[SI YA SABES TU OBJETIVO]
El objetivo es: [...]

[SI NO LO TIENES CLARO]
Honestamente no tengo claro el objetivo SMART todavía. Ayúdame
a pensarlo. Lo que me interesa en este momento es calidad —
entregar un producto de excelente calidad. ¿Cómo lo aterrizamos
como meta medible?
```

> En el chat real, Estefany no tenía un objetivo SMART al principio y dejó que el bot lo propusiera. El bot terminó proponiendo: *"Top 5 de tecnología en Substack Español + 45%+ open rate + 2,000 suscriptores en 6 meses"* a partir del contexto. **Funciona pedirle que proponga la métrica si tú tienes la intención clara pero no el número.**

**Campo por campo, mensajes-ejemplo:**

```
[Campo 2 — Contexto]
Contexto del newsletter:
- Audiencia: [perfil específico — ej: CEO/COO/CFO LATAM, 500-5000 empleados]
- Problema que les resuelve: [...]
- Por qué ahora: [...]
- Lo que NO somos: [excluye lo que confunde — ej: NO es para devs,
  NO es para académicos]
```

```
[Campo 5 — Restricciones]
Restricciones:
- Tiempo: yo puedo invertir [X] minutos por semana
- Recursos humanos: yo + tú (Mini Estefany) + [otros si los hay]
- Plataforma: Substack
- Idioma: [español/inglés/ambos]
- Presupuesto: [si aplica]
```

```
[Campo 6 — Stakeholders]
Stakeholders:
- Aprobador final: yo
- Feedback editorial: [nombres + cómo te comunicas con ellos]
- Distribución: [quién amplifica — redes propias, comunidad, etc.]
```

```
[Campo 7 — Fuentes clave de conocimiento]
Fuentes:
- Material propio: [grabaciones, clases, comunidad, etc.]
- Fuentes externas: lo definimos en el siguiente paso (research playbook)
```

El bot va guardando el canvas como un documento `canvas_capability.md` y vas a poder pedírselo de vuelta cuando quieras.

---

## Parte 4 — Diseñar el flujo de Research (Día 1, ~2 horas)

Aquí es donde la mayoría de newsletters automáticos fallan. La diferencia entre un newsletter "AI-slop" y uno de calidad está aquí.

### Paso 4.1 — Define los criterios de fuentes ANTES de buscar fuentes

**Mensaje crítico (textual del chat real):**

```
Antes de elegir las fuentes, definamos los criterios que SÍ o SÍ
deben cumplir. Si una fuente no los cumple, jamás se puede consultar.

Sé muy riguroso. Quiero que valides:
- Quién está creando ese artículo (autoría verificable)
- Que tenga credibilidad verificable por alguien sin conflicto
  de interés
- Que no sea un blog random
- Que la fuente original sea trazable en ≤2 pasos
- Que tenga fecha + autor visibles
- Que aporte datos primarios, no opiniones recicladas

Dame un documento .md con los criterios. SIEMPRE que vayamos a
hacer research, el primer paso es chequear que las fuentes cumplen.
Si no las cumplen, no se usan.

Y vuelvo a hacer el check al final cuando tengamos el borrador:
si hay UN dato, una palabra, una referencia que no esté 100%
verificable y confiable, el artículo no sirve. Punto.
```

El bot responderá con un documento de criterios. **Apruébalo o ajústalo.** Una vez aprobado, queda como `criterios_fuentes.md` en el workspace y el bot lo aplica en cada research.

### Paso 4.2 — Mapeo de fuentes en 3 tiers

**Mensaje:**

```
Ahora con esos criterios, hagamos un deep research y elige las
fuentes que vamos a usar. Quiero:

TIER 1 — fuentes primarias indiscutibles
(research institucional, blogs oficiales)

TIER 2 — análisis editorial de calidad
(publicaciones especializadas)

TIER 3 — contexto y señales
(redes sociales, sólo para flavor)

Por cada fuente que propongas:
- Cómo accedes (público, paywall, API, scraping)
- Qué cobertura tiene para mi tema
- A cuáles NO puedes entrar (paywall etc.) y qué puedo hacer
  yo para habilitártelas
```

El bot va a hacer su research y proponer ~15 fuentes. **Ejemplo real para AI for Executives:**

| Tier | Fuentes (Estefany aprobó) |
|---|---|
| 1 | BCG, McKinsey, HBR, OpenAI blog, Anthropic, Reuters AI |
| 2 | VentureBeat, MIT Technology Review, MIT Sloan Management Review, TechCrunch AI, Import AI (Jack Clark), Benedict Evans, Exponential View (Azeem Azhar) |
| 3 | LinkedIn de ejecutivos C-level |
| Regional | CEPAL, IDB (para LATAM) |

### Paso 4.3 — Define el filtro editorial y el scoring

**Mensaje:**

```
Por cada artículo/noticia que encuentres, hazte UNA pregunta:

"¿Le cambia algo a [PERSONA OBJETIVO] esta semana?"

Si NO → descartas, no existe.
Si SÍ → pasa al scoring.

Scoring de 5 criterios con pesos:
| Criterio                | Peso | Pregunta clave |
| ----------------------- | ---- | -------------- |
| Relevancia para audience| 30%  | ¿Le cambia algo concreto esta semana?     |
| Calidad de fuente       | 25%  | ¿Tier 1 con dato verificable?              |
| Urgencia / Timing       | 20%  | ¿Pierde valor si espera 2 semanas?         |
| Accionabilidad          | 15%  | ¿Hay algo que [audience] puede hacer?      |
| Unicidad                | 10%  | ¿Puede encontrarlo fácilmente en otro lado?|

Score 1-4 → descartado, no entra a Notion.
Score 5+ → entra al banco de research en Notion.
Score 9-10 → me avisas de inmediato por Telegram (es urgente).
```

### Paso 4.4 — Crea el Banco de Research en Notion

**Mensaje:**

```
Crea una database en Notion en mi página [LINK] llamada
"Banco de Research".

PERO ESPÉRATE — antes de crearla, dime qué columnas vas a poner
y aprobamos juntas. Es muy importante que tú y yo siempre,
siempre, siempre estemos demasiado alineadas.
```

> Esta línea — "siempre que vayas a crear algo, cuéntame lo que vas a crear y llegamos a aprobación" — es **load-bearing**. Sin esta regla, el bot crea cosas que no querías. Con esta regla, todo es deliberate.

El bot propone columnas tipo:

```
1. Título — hook editorial con fuente + hora
2. Score — 5-10
3. Fuente — nombre + URL
4. Tipo de contenido — News / Análisis / Caso de uso / Reporte /
                       Señal temprana / Entrevista
5. Formato de edición sugerido — Edición Profunda / Herramientas /
                                  Briefing-Noticia / Briefing-Movimiento /
                                  Briefing-Radar / Múltiple
6. Resumen ejecutivo — 2-3 líneas: qué pasó + implicación
7. Estado — Nuevo / Seleccionado / En producción / Publicado / Descartado
```

Apruebas. El bot la crea vía la API de Notion.

---

## Parte 5 — Diseñar los Playbooks de Producción (Día 2)

Un playbook = una receta repetible para producir UN tipo de edición. Si tu newsletter tiene 3 tipos, necesitas 3 playbooks.

### Patrón general para diseñar un playbook

**Mensaje:**

```
Vamos a crear un flujo de trabajo muy detallado para el primer tipo
de contenido. Quiero que vayamos paso a paso, acción por acción.

Antes de montar el playbook, alineemos:
1. Objetivo de este tipo de edición
2. Puntos clave que sí o sí debe cubrir
3. Estructura fija (qué secciones, en qué orden)
4. Extensión (palabras, minutos de lectura)
5. Voz y tono (con referencias si tienes)
6. Fuentes que aplican vs. fuentes que no aplican

Después de alinear esos 6, montamos el playbook completo
paso a paso. Cada paso debe decir:
- quién lo hace (tú o yo)
- qué hace
- cuánto se demora
- qué output produce
- a quién notifica
```

### Estructura fija — el patrón de oro

Para la **Edición Profunda** de AI for Executives (1,000–1,500 palabras), el bot propuso esta estructura y se quedó como template:

```
TENSIÓN → ANÁLISIS → CASO REAL → ACCIONABLE → PREGUNTA DE CIERRE
```

Otros patrones que funcionan según el tipo:

- **Briefing/News**: TOP 3 NOTICIAS → MOVIMIENTO ESTRATÉGICO → SEÑAL TEMPRANA
- **Tutorial/Tool**: PROBLEMA → SOLUCIÓN → STEP-BY-STEP → ERRORES COMUNES
- **Análisis**: HIPÓTESIS → DATOS → CONTRAARGUMENTO → SÍNTESIS

### Master Prompt — el corazón de la voz

El **Master Prompt** es el documento que define cómo escribe el bot. Va versionado (V1.0, V1.3, V2.1, V2.2).

**Plantilla de Master Prompt (basada en AI for Executives V2.2):**

```markdown
# Master Prompt — [NOMBRE NEWSLETTER] V2.2

## Identidad
- Newsletter para [audience precisa]
- Tono: [colega informado que comparte hallazgos / no consultor que señala errores]
- Lector: [perfil cognitivo — ocupado, inteligente, escéptico]

## Tono obligatorio
- Directo pero respetuoso
- Confiado sin ser arrogante
- Conversacional sin ser informal
- Realista-positivo: reconocer retos sin dramatizar

## Ganchos — SIEMPRE usar
- Preguntas genuinas: "¿Por qué algunas empresas logran X y otras no?"
- Datos concretos: "Schneider Electric tiene 100 casos de AI en producción"
- Casos reales: "Lo que hizo X empresa resuelve una duda común"

## Prohibiciones — NUNCA
- Adjetivos vacíos ("revolucionario", "disruptivo", "increíble")
- Listas tipo "5 razones por las que…"
- Hooks tipo "Imagina que…"
- Fuentes no verificables
- Datos sin atribución
- Citar "según expertos" sin nombrar al experto

## Estructura por tipo de edición
[bloque por cada tipo]

## Checklist QA — antes de entregar el borrador
- [ ] Todas las fuentes pasan los 6 criterios
- [ ] Cero párrafos de relleno (cada uno aporta o se elimina)
- [ ] Cada afirmación tiene respaldo verificable trazable en ≤2 pasos
- [ ] No hay generalidades sin caso concreto
- [ ] El gancho de apertura es una pregunta o un dato, no un adjetivo
- [ ] La pregunta de cierre invita a pensar, no a comprar
```

**Cómo se lo das al bot:**

```
Voy a pegarte el Master Prompt V1.0 del newsletter. Quiero que:
1. Lo guardes como master_prompt.md en el workspace del proyecto
2. SIEMPRE lo consultes antes de escribir cualquier borrador
3. Cuando hagamos cambios, subes la versión (V1.0 → V1.1)
4. Antes de marcar "listo" un borrador, pasa el checklist literalmente

[pegas el Master Prompt aquí]
```

### Ejemplo de playbook completo aprobado

Este es el playbook **literal** que quedó montado para la Edición Profunda. Sirve como template:

```
PLAYBOOK DE PRODUCCIÓN — Edición Profunda (Lunes)
Versión 1.0

PASO 1 — SELECCIÓN DE TEMA (Lunes — TÚ, 10 min)
Bot revisa el banco de Notion, ordena por score y presenta los 3
mejores temas con tensión ejecutiva y recomendación. Eliges uno.

PASO 2 — BRIEF EDITORIAL (inmediatamente — Bot, ~15 min)
Bot manda por Telegram: tensión de apertura, tesis, caso real,
accionable, pregunta de cierre, fuentes confirmadas.

PASO 3 — APROBACIÓN DEL BRIEF (TÚ, ~2 min)
Si apruebas → arranca el borrador.
Si no → ajuste del brief primero.

PASO 4 — RESEARCH PROFUNDO + BORRADOR (Bot, ~75 min)
Escritura completa con estructura fija. Borrador queda dentro
de la entrada en DB Contenido en Notion.

PASO 5 — QA RIGUROSO (Bot, antes de entregar)
Checklist obligatorio:
- Fuentes pasan los 6 criterios
- Cero relleno
- Afirmaciones con respaldo
- Checklist de 5 preguntas de calidad editorial
Solo cuando todo es ✅ → "Listo para revisión" en Notion + Telegram.

PASO 6 — NOTIFICACIÓN AL EQUIPO (Bot vía Slack)
Mensaje a #marketing con link al borrador y deadline para comentar.

PASO 7 — INCORPORACIÓN DE FEEDBACK (Bot)
Lee comentarios en Notion, incorpora lo relevante, actualiza el borrador.

PASO 8 — REVISIÓN FINAL (TÚ, máx. 20 min)
Lees la versión final con feedback incorporado. Editas en Notion
o pides ajustes por Telegram. Apruebas.

PASO 9 — PUBLICACIÓN (TÚ, 5 min)
Copias de Notion, pegas en Substack, publicas.

TIEMPOS TOTALES:
- Bot: ~90 min
- Tú: ~30 min
```

---

## Parte 6 — Conectar herramientas externas

### Notion (obligatorio)

**Mensaje:**

```
Voy a darte acceso a Notion. Mi NOTION_TOKEN es: secret_xxx
Mi página de HQ es: [URL]

Antes de crear nada:
1. Confirma que tienes acceso a la página
2. Lista todas las páginas a las que sí puedes acceder
3. Si encuentras páginas privadas que NO debería ver tu API,
   avísame para revocar acceso

Pregunta de privacidad: si alguien random de mi equipo te
escribe en otra parte, ¿podría preguntarte qué hay en mis
páginas privadas de Notion y tú le contestarías? Quiero que esa
info solo viva entre tú y yo.
```

> Esa última pregunta es real del chat. La respuesta del bot debería ser que la sesión de Telegram es tu sesión privada y el contenido no se filtra a otras sesiones; si no te lo confirma, no integres.

**Estructura recomendada del HQ en Notion (lo que quedó en AI for Executives):**

```
Substack (página principal)
├── Proyecto (columna 1)
│   ├── Canvas del Capability
│   ├── Dashboard de métricas
│   └── Benchmark de competencia
└── Contenido (columna 2)
    ├── Guía Editorial Vx
    ├── Master Prompt Vx
    ├── Guía de Tono y Estilo
    ├── Playbook Research
    ├── Playbook Edición Profunda
    ├── Playbook Herramientas en Acción
    ├── Playbook Briefing Ejecutivo
    ├── Playbook Nuggets
    ├── Criterios de Fuentes
    ├── DB Banco de Research
    └── DB Contenido Substack (pipeline de producción)
```

Las dos DBs deben estar **relacionadas** (la DB de Contenido tiene una columna que apunta a las entradas del Banco que usó como fuente).

### Slack (recomendado para feedback de equipo)

**Mensaje:**

```
Conéctate a mi Slack. Mi SLACK_BOT_TOKEN es: xoxb-xxx
El canal donde te quiero es: #marketing
Las personas que dan feedback son: [Persona A], [Persona B]

Flujo:
- Cuando tengas un borrador listo en Notion, mandas mensaje a
  #marketing con link público al borrador y deadline para comentar.
- Cuando [A] o [B] respondan al mensaje de Slack o pongan
  comentarios en Notion, los lees y los incorporas al borrador.
- Si el feedback es ambiguo, me preguntas a mí antes de aplicarlo.
```

> Truco real: el bot puede leer **comentarios de Notion** y **respuestas de hilo en Slack** sin que tú tengas que reenviárselos. Esto es lo que cierra el feedback loop sin que tú seas el intermediario.

### API keys de modelos (obligatorio)

Ya lo cubrimos en Parte 2.4 (Groq + opcional OpenAI). Estas viven en el workspace del bot.

### Substack (manual, no hay API pública para publicar)

**Realidad del estado del arte:** Substack no expone API para publicar. El bot **no puede publicar directamente**. El flujo real es:

```
1. Bot escribe el borrador en Notion
2. Tú copias del Notion
3. Pegas en el editor de Substack
4. Revisas el formato (imágenes, divisores)
5. Le das publish
```

Toma ~5 min por edición. Es el único paso manual no-eliminable hoy.

---

## Parte 7 — Programar los Crons (Día 2-3)

Aquí es donde el sistema se vuelve **autónomo**. Sin crons, el bot solo actúa cuando le escribes. Con crons, el bot se despierta solo y produce.

### Mensaje para configurar los crons

**Plantilla literal (basada en el chat real):**

```
Dejemos cronometrizado todo el sistema. Necesito 4 crons:

1. CRON DIARIO — Research + Nugget check
   Hora: 6:00 AM (zona: America/Bogota)
   Acción:
   - Recorrer las 14 fuentes de Tier 1, 2 y regionales
   - Aplicar filtro editorial + scoring
   - Score 5+ → entra al Banco de Research en Notion
   - Score 9-10 → me avisas por Telegram inmediato
   - Revisar si hay alguna noticia que merezca un Nugget
     (alerta corta a la comunidad). Si sí, me pasas borrador.

2. CRON LUNES — Arranque Edición Profunda
   Hora: 6:30 AM (zona: America/Bogota)
   Acción:
   - Revisar banco de la semana
   - Preparar top 3 temas con score, tensión y recomendación
   - Mandarme por Telegram para que yo elija

3. CRON MIÉRCOLES — Arranque Herramientas en Acción
   Hora: 6:30 AM (zona: America/Bogota)
   Acción:
   - Revisar si hay transcripción de clase de Cinthya/Dago
     del martes en Notion
   - Si SÍ → preparar borrador
   - Si NO → activar plan B: research de caso de uso de la semana
     y proponer borrador desde ahí

4. CRON VIERNES — Arranque Briefing Ejecutivo
   Hora: 7:00 AM (zona: America/Bogota)
   Acción:
   - Tomar el research consolidado de la semana
   - Armar borrador con: Top 3 noticias + Movimiento estratégico
     + Señal temprana
   - Mandarme link del borrador en Notion

REGLAS:
- Si hay material para Nugget + post el mismo día → Nugget primero,
  borrador después
- Si el cron de un día no tiene material → me avisas, no inventas
- Zona horaria: America/Bogota maneja los cambios de horario solo
```

El bot confirma:

```
Bot: Cron está configurado con America/Bogota timezone, así que
     manejo la conversión automáticamente. Corre a las 6am hora
     Colombia sin importar cambios de horario.
```

### Cómo verificar que los crons quedaron bien

```
Tú: Dime todos los crons activos y cuándo corren.
```

El bot debería responder con una tabla. Si falta alguno, lo vuelves a configurar.

---

## Parte 8 — Feedback loops y QA continuo

### Loop 1 — Feedback del bot hacia ti (Telegram)

Por defecto: cuando termine un borrador, te avisa por Telegram. Puedes pedir que también te mande **resumen diario** del banco:

```
Adicional, todos los días después del cron de research, mándame
un resumen ejecutivo de:
- Cuántos artículos entraron al banco
- Cuál fue el de mayor score
- Si hay algo urgente (9-10) que requiera mi atención
```

### Loop 2 — Feedback de tu equipo hacia el bot (Notion + Slack)

Configurado en Parte 6. Reglas claras:

- Equipo comenta en **Notion** sobre el borrador → bot lee y aplica
- Equipo responde al mensaje de **Slack** del bot → bot lee y aplica
- Si feedback es ambiguo → bot **te pregunta a ti** antes de aplicar

### Loop 3 — QA antes de publicar (interno del bot)

Cada borrador pasa por el checklist del Master Prompt antes de marcarse "Listo para revisión". El bot **no** te entrega un borrador sin pasar el QA.

### Loop 4 — Mejora continua del sistema

Cada vez que tú corriges algo manualmente, el bot debería:

```
Tú: Vi que en el borrador usaste [adjetivo X]. No me gusta porque
    [razón]. Ajusta el Master Prompt para que nunca más uses
    palabras de esa categoría. Sube la versión.

Bot: Listo. Master Prompt actualizado a V1.4. Agregado a "Prohibiciones":
     [regla nueva]. Aplicará desde el próximo borrador.
```

> Esto es lo que hace que el sistema mejore semana a semana. Sin este loop, el bot mantiene los mismos errores indefinidamente.

---

## Parte 9 — Plantillas reutilizables

Pegas estas plantillas en tus primeros días con OpenClaw. Cambias las variables `[…]` y listo.

### Plantilla A — Mensaje de identidad

```
Tú eres [NOMBRE_AGENTE] y yo soy [TU_NOMBRE].

Tu rol: [descripción en 2-3 líneas, con énfasis en valores que importan
— calidad, rigor, velocidad, empatía, lo que sea].

Lo que más te caracteriza: [el ADN no-negociable].

Eres genio, sabes todo, y haces todo con un nivel de detalle excepcional.
Siempre verificas antes de afirmar.
Siempre pides aprobación antes de crear cosas externas.
Siempre subes la versión cuando actualizas un documento.
```

### Plantilla B — Mensaje de contexto del mundo

```
Contexto rápido para que puedas operar.

EMPRESA / PROYECTO: [...]
MI ROL: [...]
STAKEHOLDERS:
- [Persona] — [rol, cómo te comunicas con ella]
- ...

VALORES NO-NEGOCIABLES:
- [valor 1]
- [valor 2]

CULTURA DE TRABAJO:
- [cómo se decide]
- [cómo se aprueba]
- [qué nunca se hace]
```

### Plantilla C — Mensaje de criterios de fuentes

```
Antes de elegir fuentes para nuestro newsletter, definamos los
criterios. Sé riguroso. Una fuente entra solo si cumple TODOS:

1. Autoría verificable (nombre real + credenciales públicas)
2. Sin conflicto de interés con el tema que reporta
3. NO es un blog random / SEO farm
4. Cita su fuente original (trazabilidad ≤2 pasos)
5. Tiene fecha de publicación visible
6. Aporta dato primario, no opinión reciclada

Crea criterios_fuentes.md y SIEMPRE consúltalos:
- Al INICIO del research (filtrar qué fuentes considerar)
- Al FINAL del borrador (verificar cada cita)

Si UN dato no es verificable, el artículo no sale. Punto.
```

### Plantilla D — Mensaje de scoring

```
Filtro editorial: por cada pieza pregúntate
"¿Le cambia algo a [AUDIENCE] esta semana?"
- NO → descartas
- SÍ → scoring

Scoring 5 criterios, pesos:
| Criterio                 | Peso | Pregunta |
|--------------------------|------|----------|
| Relevancia para audience | 30%  | ¿cambia algo concreto esta semana? |
| Calidad de fuente        | 25%  | ¿Tier 1 + dato verificable?         |
| Urgencia / Timing        | 20%  | ¿pierde valor si espera 2 semanas?  |
| Accionabilidad           | 15%  | ¿qué puede hacer [audience] con esto?|
| Unicidad                 | 10%  | ¿se consigue fácil en otro lado?    |

Reglas:
- Score < 5 → descartado
- Score 5-8 → entra al banco
- Score 9-10 → me avisas inmediato por Telegram
```

### Plantilla E — Mensaje de cron setup

```
Configura los siguientes crons en zona America/[ciudad]:

[Cron 1]
- Hora: HH:MM (DD si es semanal)
- Acción: [acción específica]
- Output: [a dónde va el resultado]
- Notificación: [quién recibe el ping]

[Cron 2]
...

Reglas globales:
- Si no hay material en un cron → me avisas, NO inventas
- Prioridad cuando coinciden tareas el mismo día: [orden]
```

### Plantilla F — Mensaje de revisión semanal del sistema

(Mandarlo cada lunes para que el sistema mejore)

```
Revisión semanal del sistema.

1. ¿Cuántas ediciones publicamos esta semana?
2. ¿Cuál tuvo mejor performance y por qué (apertura, clics, comentarios)?
3. ¿Qué error o fricción detectaste tú esta semana?
4. ¿Qué deberíamos cambiar en el Master Prompt o playbooks?
5. ¿Qué fuente no aportó nada esta semana y deberíamos jubilar?
6. ¿Qué fuente nueva valdría la pena agregar?

Después de tu análisis, propón cambios concretos al sistema.
Si los apruebo, los aplicas y subes versión de los docs afectados.
```

---

## Parte 10 — Troubleshooting (errores que vas a tener)

### Error 1 — "No tengo herramienta de transcripción de audio"

**Síntoma:** mandas voz y el bot dice que no puede transcribir.

**Fix:** No es un Skill, es que falta API key. Pásale tu `GROQ_API_KEY` (Parte 2.4) o tu `OPENAI_API_KEY`. La key se guarda y queda funcional.

### Error 2 — "Esta fuente la sacaste tú, no yo"

**Síntoma:** el bot incluye una afirmación con una "fuente" que no estaba en el banco verificado.

**Ejemplo del chat real:**
> Bot: *"Sin fuente confirmada no la puedo usar 🔒. La de Project Glasswing no la saqué yo — esa noticia vino de tu mensaje. Confírmame si está en el banco de Notion o dame el link original."*

**Fix:** este es un caso bueno. El bot está enforce-eando la regla de fuentes. Hay dos respuestas correctas:
- (a) Mandas el link primario → el bot lo verifica → la incluye
- (b) Si no tienes link primario → la dejas fuera. **No le pidas que la incluya igual.**

**Anti-fix (mal):** "ignora la regla esta vez". Si lo haces, el bot empieza a relajar el rigor en cascadas siguientes. Aguanta el rigor.

### Error 3 — Bot creó cosas en Notion sin avisar

**Síntoma:** entras a Notion y hay una página/DB que tú no autorizaste.

**Fix:** refuerza la regla:

```
Recordatorio: SIEMPRE que vayas a crear algo nuevo en Notion,
Slack o el workspace, me cuentas qué vas a crear, me das la
estructura, y esperas mi aprobación. Sin excepción.
Borra lo que creaste sin aprobar y arrancamos de cero.
```

### Error 4 — Cron no disparó

**Síntoma:** llega el lunes y no recibes el top 3 de temas.

**Diagnóstico:**

```
Tú: Lista todos los crons activos con su próxima ejecución
    y su última ejecución exitosa.

Bot: [listado]
```

Si el cron del lunes no aparece → no quedó configurado. Repite la Parte 7.
Si aparece pero no corrió → puede ser zona horaria mal configurada o que el bot estaba en otro proceso. Pídele logs:

```
Tú: ¿Por qué no corrió el cron del lunes? Dame el log.
```

### Error 5 — Borrador muy AI-slop

**Síntoma:** el borrador tiene adjetivos vacíos, hooks tipo "imagina", generalidades sin caso concreto.

**Fix:** actualiza el Master Prompt con las prohibiciones específicas que viste. La voz se entrena rechazando ejemplos puntuales.

```
Tú: En el borrador de hoy usaste "revolucionario", "disruptivo"
    y "el futuro está aquí". Esos tres adjetivos son banderas
    rojas. Agrega esta categoría al Master Prompt como prohibida
    y sube versión.
```

### Error 6 — El bot olvidó algo importante

**Síntoma:** preguntas algo que ya habían acordado y el bot no recuerda.

**Causa probable:** no se guardó en un archivo del workspace. La memoria de sesión es robusta pero los acuerdos críticos deben ir a un `.md` versionado.

**Fix:**

```
Tú: ¿Tenemos esto guardado en un archivo del workspace? Si no,
    guárdalo en [archivo].md y consúltalo cada vez que sea relevante.
```

### Error 7 — El bot quiere usar fuentes nuevas que no validamos

**Síntoma:** propone una fuente que no está en tu lista validada.

**Fix correcto:** pídele que pase la fuente por los 6 criterios. Si pasa, la añaden a la lista validada (subiendo versión). Si no pasa, la descarta.

### Error 8 — Demasiado contenido todos los días

**Síntoma:** el cron diario te manda 15 cosas. Saturación.

**Fix:** sube el umbral de notificación:

```
Tú: Sube el umbral de aviso inmediato a 9.5 en vez de 9.
    Todo lo demás solo lo dejas en el banco silenciosamente.
    Resumen ejecutivo solo los lunes.
```

---

## Parte 11 — Cómo replicar todo esto en CUALQUIER tema

El sistema completo es agnóstico al tema. Solo cambian las variables. Esta es la lista de variables que mapean del newsletter "AI for Executives" a uno tuyo:

| Variable | Newsletter ejemplo | Tu newsletter |
|---|---|---|
| Tema | Inteligencia artificial para ejecutivos | [...] |
| Audience | CEO/COO/CFO LATAM 500-5000 empleados | [...] |
| Tono | Colega informado, directo, escéptico | [...] |
| Cadencia | 3x semana (Lun/Mier/Vie) | [...] |
| Tier 1 sources | BCG, McKinsey, HBR, OpenAI, Anthropic, Reuters AI | [tus equivalentes] |
| Tier 2 sources | VentureBeat, MIT Tech Review, etc. | [...] |
| KPI | Top 5 tecnología Substack ES, 45%+ open rate | [...] |
| Cron timezone | America/Bogota | [...] |
| Equipo feedback | Cinthya y Dago vía Slack #30x-marketing | [...] |
| Plataforma publicación | Substack | [Substack/Beehiiv/Ghost/email propio] |

### Mensaje único de bootstrap (versión condensada)

Si quisieras montar TODO en una sola sesión (~3-4 horas de conversación intensa), este es el orden:

```
1. /start
2. [Identidad — Plantilla A]
3. [Contexto del mundo — Plantilla B]
4. Habilitar audio (API key)
5. Canvas de capability (campo por campo)
6. [Criterios de fuentes — Plantilla C]
7. Deep research de fuentes Tier 1/2/3 → aprobación
8. [Scoring — Plantilla D]
9. Crear DB Banco de Research en Notion
10. Crear DB Pipeline de Contenido en Notion
11. Diseñar Master Prompt V1.0
12. Diseñar Playbook por cada tipo de edición
13. Conectar Slack
14. [Cron setup — Plantilla E]
15. Test: pídele que corra el cron de research manualmente y revisa el output
16. Producir tu primer borrador end-to-end
17. Iterar Master Prompt con lo que aprendiste del primer borrador
```

---

## Apéndice A — Comandos y conceptos de OpenClaw que vale conocer

| Concepto | Qué es |
|---|---|
| `/start` | Inicia el wizard del bot (solo se usa una vez) |
| Workspace | Filesystem del bot en `/root/.openclaw/workspace/projects/<tu-proyecto>/` |
| Skill | Capacidad nueva que se "instala" en el bot (transcripción, web scraping, etc.) |
| Cron | Tarea programada que despierta al bot a una hora específica |
| Memory | Archivos `.md` que el bot guarda como contexto persistente |
| Bootstrap file | El archivo de identidad inicial — se reemplaza tras `/start` |
| API key storage | Las keys quedan en un `*_config.md` del workspace |
| Projects | El bot puede manejar **múltiples proyectos en paralelo**; cada uno tiene su carpeta |

> Confirmado en el chat real: *"Si mañana empezamos un proyecto nuevo de ventas, lo manejo en paralelo sin que interfiera con el de Substack. Cada proyecto tiene su espacio, sus documentos y su contexto."*

---

## Apéndice B — Estructura de archivos del workspace (ejemplo real)

```
/root/.openclaw/workspace/projects/ai_for_executives/
├── identity.md
├── canvas_capability.md
├── benchmark_v2.md
├── guia_editorial_v1.3.md
├── master_prompt_v2.2.md
├── guia_tono_y_estilo.md
├── contexto_mundo_corporativo.md
├── criterios_fuentes.md
├── fuentes_validadas.md
├── playbook_research_v1.md
├── playbook_edicion_profunda_v1.md
├── playbook_herramientas_en_accion_v1.1.md
├── playbook_briefing_ejecutivo_v1.1.md
├── playbook_nuggets_v1.md
├── notion_config.md          # credenciales Notion
├── slack_config.md           # credenciales Slack
├── api_keys.md               # Groq, OpenAI, etc.
└── crons.md                  # listado de crons activos
```

Pídele al bot `muéstrame la estructura del workspace` cuando quieras verificar qué tiene.

---

## Apéndice C — Filosofía del builder (lo que separa este sistema de "un bot que escribe newsletters")

Cinco principios que se ven en el chat real y que vale internalizar antes de configurar tu propio agente:

1. **Calidad antes que velocidad.** El bot puede producir 10 borradores por día. La regla es "uno bueno por día". El rigor mata el slop.

2. **Cero datos sin fuente verificable.** Si la afirmación no tiene respaldo trazable, no entra. Sin excepciones. *"Sin fuente confirmada no la puedo usar 🔒"* es la actitud correcta.

3. **El humano es el último filtro de voz.** El bot puede emular el tono pero la decisión final de "esto sí suena como yo" es tuya. No la delegues.

4. **Aprobación antes de creación.** Aplicado a Notion, Slack, archivos del workspace, cualquier cambio externo. El bot propone, tú apruebas.

5. **Iteración por versiones.** Los documentos suben de versión cuando cambian. Esto te da historial y te permite revertir si algo se rompe.

---

## Cierre

Este sistema le toma a Estefany **~80 minutos por semana** y publica 3 ediciones de calidad. La inversión inicial fue intensa (un día largo de canvas + playbooks + crons), pero a partir de la semana 2 el sistema funciona prácticamente solo: el bot investiga, filtra, redacta, espera tu aprobación, incorpora feedback del equipo, y te entrega borradores listos para pegar en Substack.

La lección más profunda del chat: **OpenClaw no es una herramienta, es un colaborador**. Lo configuras como configurarías a un nuevo miembro del equipo — con contexto, valores, playbooks, deadlines, y revisiones semanales. Solo que este miembro no se cansa, no se va, recuerda todo, y mejora con cada iteración.

---

*Guía generada a partir del análisis del chat real de configuración entre Estefany Benavides y "Mini Estefany" (OpenClaw) — Marzo a Mayo 2026, Telegram export.*
