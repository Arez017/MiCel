# Chatbot MiCEL — Red neuronal desde cero (proyecto académico)

Este módulo es **independiente** del panel Laravel principal.
Objetivo: demostrar una IA propia (MLP + backpropagation en NumPy) para el examen.

## Estructura
```
micel_chatbot_ia/
  data/intents.json      # dataset de intenciones
  train/nn_scratch.py    # entrenamiento + inferencia (NumPy)
  model/                 # pesos y meta (se generan al entrenar)
  api/server.py          # FastAPI
  docs/DOCUMENTACION_PROYECTO.md
  requirements.txt
```

## Pasos rápidos
```bash
pip install -r requirements.txt
python train/nn_scratch.py
uvicorn api.server:app --port 8001
```

Probar:
```bash
curl -X POST http://127.0.0.1:8001/chat -H "Content-Type: application/json" -d "{\"message\":\"hola\"}"
```

## Documentación
Ver `docs/DOCUMENTACION_PROYECTO.md` — úsalo como base del informe del examen.
