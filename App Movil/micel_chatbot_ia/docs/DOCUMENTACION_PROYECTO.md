# Chatbot inteligente MiCEL — Documentación del proyecto

## 1. Introducción
### 1.1 Problema
Los clientes del taller necesitan orientación 24/7 (estado de reparación, coins, garantía) sin saturar al personal.

### 1.2 Objetivo
Diseñar, entrenar e implementar un chatbot basado en una **red neuronal artificial propia** (no APIs externas de LLM) capaz de clasificar la intención del usuario y responder de forma coherente.

### 1.3 Alcance
- Dataset de intenciones del dominio taller.
- Modelo MLP entrenado con backpropagation.
- API de inferencia.
- Interfaz móvil (Flutter) o web de prueba.
- Evaluación (accuracy, matriz de confusión / pruebas manuales).

## 2. Marco teórico (resumen para el documento)
- Inteligencia artificial y PLN básico.
- Red neuronal: neurona, pesos, bias, función de activación.
- Perceptrón multicapa (MLP).
- Forward propagation.
- Función de pérdida (cross-entropy).
- Backpropagation y descenso de gradiente.
- Representación bag-of-words.
- Softmax para clasificación multiclase.

## 3. Metodología
### 3.1 Dataset
Archivo `data/intents.json`: etiquetas (tags), patrones de usuario y respuestas.
Ej.: saludo, orden_estado, coins, garantia, precios, horario, …

### 3.2 Preprocesamiento
1. Minúsculas y limpieza de signos.
2. Tokenización.
3. Stemming simple en español.
4. Vector bag-of-words (presencia de palabra = 1).

### 3.3 Arquitectura
```
Entrada (V) → Densa + ReLU (32) → Densa + ReLU (16) → Softmax (N_intenciones)
```
- Inicialización He.
- Pérdida: cross-entropy.
- Optimizador: SGD (lr ≈ 0.08).
- Épocas: 800 (ajustable).

### 3.4 Entrenamiento
```bash
cd micel_chatbot_ia
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
python train/nn_scratch.py
```
Salida: `model/mlp_weights.npz` + `model/meta.json` (accuracy final).

### 3.5 Inferencia
1. Texto → tokens → bag-of-words.
2. Forward del MLP.
3. Clase con mayor probabilidad (si confidence ≥ umbral).
4. Respuesta aleatoria del tag.

### 3.6 API
```bash
uvicorn api.server:app --host 0.0.0.0 --port 8001
```
`POST /chat` JSON `{"message":"hola"}` → reply, tag, confidence.

## 4. Integración móvil (Flutter)
- Pantalla de chat que consume `POST http://<IP>:8001/chat`.
- Mostrar respuesta y opcionalmente la confianza (demo técnica).

## 5. Resultados
- Accuracy de entrenamiento (reportar la de `meta.json`).
- Tabla de pruebas: pregunta → tag predicho → ¿correcto?
- Limitaciones: vocabulario cerrado, sin generación libre de texto, depende del dataset.

## 6. Conclusiones
- Se implementó una IA **entrenada por el equipo**, no un wrapper de ChatGPT.
- El MLP es adecuado para clasificación de intenciones con pocos datos.
- Trabajo futuro: más patrones, embeddings, red más profunda, datos reales de clientes.

## 7. Anexos
- Código `train/nn_scratch.py` (forward/backward).
- Capturas de entrenamiento y de la app.
- Diagrama de arquitectura.
