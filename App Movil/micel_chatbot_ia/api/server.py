"""
API de inferencia del chatbot (red neuronal propia) + diálogo simple.
uvicorn api.server:app --host 0.0.0.0 --port 8001
"""
from __future__ import annotations

from pathlib import Path
import sys
import random

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "train"))

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from nn_scratch import ChatbotInference

app = FastAPI(title="MiCEL Chatbot NN", version="1.1")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

bot = ChatbotInference()

# Seguimientos por intención (más dinámico)
FOLLOWUPS = {
    "saludo": ["¿Qué son los coins?", "Garantía de pantalla", "Estado de mi orden"],
    "orden_estado": ["¿Cuánto demora?", "Garantía", "¿Qué llevo al taller?"],
    "coins": ["¿Cómo soy VIP?", "Garantía", "Precios"],
    "garantia": ["Garantía de pantalla", "Garantía de batería", "Precios"],
    "precios": ["Precio de pantalla", "Precio de batería", "Garantía"],
    "horario": ["¿Qué llevo al taller?", "Estado de mi orden"],
    "que_llevar": ["Estado de mi orden", "Horario", "Garantía"],
    "despedida": ["Hola"],
    "gracias": ["¿Otra consulta?", "Garantía", "Coins"],
    "desconocido": ["Hola", "¿Qué son los coins?", "Garantía", "Precios"],
}

CLARIFY = {
    "garantia": [
        "¿Es por cambio de **pantalla** (3 meses) o de **batería** (6 meses)?",
        "Puedo detallarte pantalla, batería, pin o software. ¿Cuál te interesa?",
    ],
    "precios": [
        "¿Buscas precio de **pantalla**, **batería** o **pin de carga**?",
        "Dime el tipo de servicio y te doy el rango referencial en Bs.",
    ],
    "orden_estado": [
        "Si tienes el código (ej. OS-0012), escríbelo. Si no, usa Seguimiento en la app.",
    ],
}


class ChatIn(BaseModel):
    message: str = Field(..., min_length=1, max_length=500)
    history: list[dict] = Field(default_factory=list)


class ChatOut(BaseModel):
    reply: str
    tag: str
    confidence: float
    suggestions: list[str] = []
    model: str = "MLP-scratch-numpy"


def _last_user_and_bot(history: list[dict]):
    last_bot_tag = None
    for h in reversed(history):
        if h.get("role") == "assistant" and h.get("tag"):
            last_bot_tag = h.get("tag")
            break
    return last_bot_tag


def enrich_reply(message: str, base: dict) -> dict:
    tag = base["tag"]
    conf = base["confidence"]
    reply = base["reply"]
    msg = message.lower()

    # Detalles finos sin re-entrenar
    if "pantalla" in msg and tag in ("garantia", "precios", "desconocido"):
        if "garant" in msg or tag == "garantia":
            reply = (
                "🛡️ **Garantía de pantalla: 3 meses**\n"
                "Cubre defectos del repuesto/instalación. No cubre golpes ni humedad.\n"
                "Trae tu recibo u orden al taller."
            )
            tag = "garantia"
            conf = max(conf, 0.9)
        else:
            reply = (
                "💰 **Pantalla** (referencial): Bs 180 – 350 según modelo.\n"
                "El técnico confirma el monto exacto en el local."
            )
            tag = "precios"
            conf = max(conf, 0.9)
    elif "bateria" in msg or "batería" in msg:
        if "garant" in msg or tag == "garantia":
            reply = (
                "🛡️ **Garantía de batería: 6 meses**\n"
                "Cubre fallas de la batería instalada. No cubre hinchazón por mal uso o golpes."
            )
            tag = "garantia"
            conf = max(conf, 0.9)
        else:
            reply = "💰 **Batería** (referencial): Bs 80 – 150 según modelo."
            tag = "precios"
            conf = max(conf, 0.9)

    # Si la confianza es media, añade pregunta aclaratoria
    if tag in CLARIFY and conf < 0.85 and tag != "desconocido":
        reply = reply + "\n\n" + random.choice(CLARIFY[tag])
    elif tag in CLARIFY and random.random() < 0.35:
        reply = reply + "\n\n" + random.choice(CLARIFY[tag])

    # Toque personal si saluda
    if tag == "saludo":
        reply = reply + "\n\nPuedes tocar las sugerencias de abajo o escribir libremente."

    suggestions = FOLLOWUPS.get(tag, FOLLOWUPS["desconocido"])
    return {
        "reply": reply,
        "tag": tag,
        "confidence": conf,
        "suggestions": suggestions,
    }


@app.get("/health")
def health():
    return {"ok": True, "model": "MLP bag-of-words + dialogue"}


@app.post("/chat", response_model=ChatOut)
def chat(body: ChatIn):
    base = bot.predict(body.message)
    out = enrich_reply(body.message, base)
    return ChatOut(
        reply=out["reply"],
        tag=out["tag"],
        confidence=out["confidence"],
        suggestions=out["suggestions"],
    )
