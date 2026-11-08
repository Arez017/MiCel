"""
Red neuronal MLP desde cero (NumPy) para clasificación de intenciones.
Incluye: forward, backpropagation, gradiente descendente, softmax, ReLU.
"""
from __future__ import annotations

import json
import re
import unicodedata
import random
from pathlib import Path
from dataclasses import dataclass

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = ROOT / "data" / "intents.json"
MODEL_DIR = ROOT / "model"
MODEL_DIR.mkdir(parents=True, exist_ok=True)


def _strip_accents(s: str) -> str:
    # garantía -> garantia (para que coincida el vocabulario)
    nk = unicodedata.normalize("NFD", s)
    return "".join(c for c in nk if unicodedata.category(c) != "Mn")


def tokenize(text: str) -> list[str]:
    text = _strip_accents(text.lower())
    text = re.sub(r"[^a-z0-9\s]", " ", text)
    return [t for t in text.split() if t]


def stem_simple(w: str) -> str:
    """Stemming muy simple en español (sufijos comunes)."""
    for suf in ("ciones", "ciones", "mente", "ando", "iendo", "ados", "idas", "ores", "oras", "es", "os", "as", "ar", "er", "ir"):
        if len(w) > 4 and w.endswith(suf):
            return w[: -len(suf)]
    return w


class Vocabulary:
    def __init__(self):
        self.word2idx: dict[str, int] = {}
        self.idx2word: list[str] = []

    def fit(self, docs: list[list[str]]):
        words = sorted({stem_simple(w) for doc in docs for w in doc})
        self.idx2word = words
        self.word2idx = {w: i for i, w in enumerate(words)}

    def bag(self, tokens: list[str]) -> np.ndarray:
        v = np.zeros(len(self.word2idx), dtype=np.float64)
        for w in tokens:
            s = stem_simple(w)
            if s in self.word2idx:
                v[self.word2idx[s]] = 1.0
        return v

    @property
    def size(self) -> int:
        return len(self.idx2word)


def softmax(x: np.ndarray) -> np.ndarray:
    e = np.exp(x - np.max(x, axis=1, keepdims=True))
    return e / np.sum(e, axis=1, keepdims=True)


def relu(x: np.ndarray) -> np.ndarray:
    return np.maximum(0.0, x)


def relu_grad(x: np.ndarray) -> np.ndarray:
    return (x > 0).astype(np.float64)


@dataclass
class MLP:
    """MLP: input → hidden ReLU → hidden ReLU → softmax."""

    w1: np.ndarray
    b1: np.ndarray
    w2: np.ndarray
    b2: np.ndarray
    w3: np.ndarray
    b3: np.ndarray

    @staticmethod
    def create(n_in: int, n_h1: int, n_h2: int, n_out: int, seed: int = 42) -> "MLP":
        rng = np.random.default_rng(seed)
        # He init
        return MLP(
            w1=rng.normal(0, np.sqrt(2 / n_in), (n_in, n_h1)),
            b1=np.zeros(n_h1),
            w2=rng.normal(0, np.sqrt(2 / n_h1), (n_h1, n_h2)),
            b2=np.zeros(n_h2),
            w3=rng.normal(0, np.sqrt(2 / n_h2), (n_h2, n_out)),
            b3=np.zeros(n_out),
        )

    def forward(self, x: np.ndarray):
        z1 = x @ self.w1 + self.b1
        a1 = relu(z1)
        z2 = a1 @ self.w2 + self.b2
        a2 = relu(z2)
        z3 = a2 @ self.w3 + self.b3
        a3 = softmax(z3)
        cache = (x, z1, a1, z2, a2, z3, a3)
        return a3, cache

    def backward(self, cache, y_onehot: np.ndarray):
        x, z1, a1, z2, a2, z3, a3 = cache
        m = x.shape[0]
        # Softmax + cross-entropy
        dz3 = (a3 - y_onehot) / m
        dw3 = a2.T @ dz3
        db3 = np.sum(dz3, axis=0)
        da2 = dz3 @ self.w3.T
        dz2 = da2 * relu_grad(z2)
        dw2 = a1.T @ dz2
        db2 = np.sum(dz2, axis=0)
        da1 = dz2 @ self.w2.T
        dz1 = da1 * relu_grad(z1)
        dw1 = x.T @ dz1
        db1 = np.sum(dz1, axis=0)
        return dw1, db1, dw2, db2, dw3, db3

    def step(self, grads, lr: float):
        dw1, db1, dw2, db2, dw3, db3 = grads
        self.w1 -= lr * dw1
        self.b1 -= lr * db1
        self.w2 -= lr * dw2
        self.b2 -= lr * db2
        self.w3 -= lr * dw3
        self.b3 -= lr * db3


def load_dataset():
    raw = json.loads(DATA_PATH.read_text(encoding="utf-8"))
    tags = []
    patterns = []
    responses = {}
    for intent in raw["intents"]:
        tag = intent["tag"]
        tags.append(tag)
        responses[tag] = intent["responses"]
        for p in intent["patterns"]:
            patterns.append((tokenize(p), tag))
    tags = sorted(set(tags))
    tag2idx = {t: i for i, t in enumerate(tags)}
    return patterns, tags, tag2idx, responses


def train(epochs: int = 800, lr: float = 0.08, h1: int = 32, h2: int = 16):
    patterns, tags, tag2idx, responses = load_dataset()
    vocab = Vocabulary()
    vocab.fit([toks for toks, _ in patterns])

    X = np.stack([vocab.bag(toks) for toks, _ in patterns])
    y_idx = np.array([tag2idx[t] for _, t in patterns])
    y = np.eye(len(tags))[y_idx]

    model = MLP.create(vocab.size, h1, h2, len(tags))
    history = []

    for ep in range(1, epochs + 1):
        # shuffle
        perm = np.random.permutation(len(X))
        Xs, ys = X[perm], y[perm]
        probs, cache = model.forward(Xs)
        loss = -np.mean(np.sum(ys * np.log(probs + 1e-9), axis=1))
        preds = np.argmax(probs, axis=1)
        acc = np.mean(preds == np.argmax(ys, axis=1))
        grads = model.backward(cache, ys)
        model.step(grads, lr)
        history.append({"epoch": ep, "loss": float(loss), "acc": float(acc)})
        if ep % 100 == 0 or ep == 1:
            print(f"epoch {ep:4d}  loss={loss:.4f}  acc={acc:.3f}")

    # guardar
    np.savez(
        MODEL_DIR / "mlp_weights.npz",
        w1=model.w1,
        b1=model.b1,
        w2=model.w2,
        b2=model.b2,
        w3=model.w3,
        b3=model.b3,
    )
    meta = {
        "words": vocab.idx2word,
        "tags": tags,
        "responses": responses,
        "history": history[-20:],
        "final_acc": history[-1]["acc"],
        "final_loss": history[-1]["loss"],
        "architecture": {
            "type": "MLP",
            "layers": [vocab.size, h1, h2, len(tags)],
            "activations": ["relu", "relu", "softmax"],
            "loss": "cross_entropy",
            "optimizer": "sgd",
            "epochs": epochs,
            "lr": lr,
        },
    }
    (MODEL_DIR / "meta.json").write_text(
        json.dumps(meta, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print("Modelo guardado en", MODEL_DIR)
    return model, vocab, tags, responses


class ChatbotInference:
    def __init__(self):
        data = np.load(MODEL_DIR / "mlp_weights.npz")
        self.model = MLP(
            w1=data["w1"],
            b1=data["b1"],
            w2=data["w2"],
            b2=data["b2"],
            w3=data["w3"],
            b3=data["b3"],
        )
        meta = json.loads((MODEL_DIR / "meta.json").read_text(encoding="utf-8"))
        self.vocab = Vocabulary()
        self.vocab.idx2word = meta["words"]
        self.vocab.word2idx = {w: i for i, w in enumerate(meta["words"])}
        self.tags = meta["tags"]
        self.responses = meta["responses"]

    def predict(self, text: str, threshold: float = 0.28):
        toks = tokenize(text)
        x = self.vocab.bag(toks).reshape(1, -1)
        probs, _ = self.model.forward(x)
        idx = int(np.argmax(probs, axis=1)[0])
        conf = float(probs[0, idx])
        tag = self.tags[idx]
        if conf < threshold:
            return {
                "tag": "desconocido",
                "confidence": conf,
                "reply": (
                    "No estoy seguro de entender. Prueba con: estado de orden, "
                    "coins, garantía, precios u horarios."
                ),
            }
        reply = random.choice(self.responses.get(tag, ["Entendido."]))
        return {"tag": tag, "confidence": conf, "reply": reply}


if __name__ == "__main__":
    train()
    bot = ChatbotInference()
    for q in ["hola", "donde esta mi orden", "que son los coins", "asdfgh"]:
        print(q, "→", bot.predict(q))
