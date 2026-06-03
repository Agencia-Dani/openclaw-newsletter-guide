# OpenClaw Newsletter — Master Guía

Guía completa para configurar un OpenClaw que produzca un newsletter editorial con cadencia, research curado, scoring y escritura — basada en la implementación real de **AI for Executives** (Substack, marzo–abril 2026).

---

## 📄 Documentos principales

| Archivo | Qué es |
|---|---|
| **`Master-Guia-OpenClaw-Newsletter.pdf`** | El entregable final. PDF profesional, 60 páginas, con cover, tabla de contenidos y formato listo para leer o compartir. |
| `Newsletter-Config-PreMayo10.md` | Fuente en Markdown del PDF. Edita aquí cuando quieras actualizar la guía. |

---

## 🛠️ Scripts y materiales de construcción

| Archivo | Para qué sirve |
|---|---|
| `make_pdf.py` | Convierte el Markdown a PDF. Corre `python3 make_pdf.py` (con `DYLD_LIBRARY_PATH=/opt/homebrew/lib` en macOS) para regenerar el PDF después de editar el `.md`. |
| `transcribe-all.sh` | Script que transcribió los 68 audios del export de Telegram con `trx` + Whisper. Útil si quieres re-correr la transcripción. |
| `transcribe.log` | Log de la última corrida de transcripción. |
| `transcripts/` | Los 68 audios transcritos a texto, en orden cronológico (`audio_1@...txt` hasta `audio_68@...txt`). Material crudo del análisis. |

---

## 📦 Archive

`archive/` contiene versiones anteriores de la guía y análisis históricos que ya no están vigentes pero se mantienen como referencia. Ver `archive/README.md`.

---

## 🔄 Cómo regenerar el PDF después de editar la guía

```bash
cd /Users/estefanybenavides/Documents/Claude/workspace/openclaw-guide
DYLD_LIBRARY_PATH=/opt/homebrew/lib python3 make_pdf.py
```

Dependencias (solo se instalan una vez):
- `brew install pango gdk-pixbuf libffi`
- `pip3 install --user --break-system-packages markdown weasyprint pygments`

---

## 📌 Cosas para acordarse del proyecto

- **Identidad del agente**: la guía configura la *función editorial* — el agente puede tener otras funciones que se configuran aparte
- **Transcripción de audio**: el bot instala Whisper local él mismo, sin API keys de terceros
- **Cron diario**: `0 6 * * * @ America/Bogota` — validar siempre la timezone, la expresión cron se interpreta en la timezone configurada
- **Notion**: 2 databases — Banco de Research (todo lo filtrado score 5+) y Pipeline de Contenido (borradores en producción)
- **Substack**: publicación final es manual (Substack no expone API pública)

---

*Última actualización del paquete: 3 junio 2026*
