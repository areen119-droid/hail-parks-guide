"""Builds train_guide.ipynb from this folder's code.

The notebook embeds features.py verbatim, so the features used for training
always match the ones the app uses. Run: python build_notebook.py
"""
import json
from pathlib import Path

HERE = Path(__file__).parent


def md(text):
    return {"cell_type": "markdown", "metadata": {}, "source": text.strip()}


def code(text):
    return {"cell_type": "code", "metadata": {}, "execution_count": None,
            "outputs": [], "source": text.strip()}


features_src = (HERE / "features.py").read_text(encoding="utf-8")

cells = [
    md("""
# Hail Parks Guide: training the guide's chatbot model

This notebook trains a small neural network that recognizes what a visitor is
asking (an "intent"), using the examples in `intents.json`.

**Steps**
1. Run all cells (Runtime → Run all).
2. When asked, upload `ml/intents.json` from the project.
3. At the end, `hail_guide_model.zip` downloads. Unzip it into the project's
   `assets/ml/` folder (replace the old files), then run the app.
"""),
    md("## 1. Upload the training data"),
    code("""
import json, random
import numpy as np
import tensorflow as tf
from google.colab import files

uploaded = files.upload()  # choose ml/intents.json
data = json.loads(next(iter(uploaded.values())).decode("utf-8"))
print(len(data["intents"]), "intents,",
      sum(len(i["examples"]) for i in data["intents"]), "examples")
"""),
    md("""
## 2. Turn text into numbers

The model can't read text, so each question becomes a list of 0s and 1s: one
spot for each word and each 3-letter piece of a word seen in the training data.
The 3-letter pieces let the model handle different spellings and prefixes
like ال and و. **The app repeats this exact code in Dart.**
"""),
    code(features_src),
    code("""
random.seed(42); np.random.seed(42); tf.random.set_seed(42)

labels = [i["tag"] for i in data["intents"]]
examples = [(e, labels.index(i["tag"])) for i in data["intents"] for e in i["examples"]]
vocab = sorted(set().union(*[features(e) for e, _ in examples]))
index = {f: n for n, f in enumerate(vocab)}

def vectorize(text):
    v = np.zeros(len(vocab), dtype=np.float32)
    for f in features(text):
        if f in index:
            v[index[f]] = 1.0
    return v

print("vocabulary size:", len(vocab))
print("example:", examples[0][0], "->", sorted(features(examples[0][0]))[:8], "...")
"""),
    md("""
## 3. Check accuracy on questions the model hasn't seen

We hide 20% of the examples of each intent, train on the rest, and test on the
hidden ones. This tells us how well the model handles new phrasings.
"""),
    code("""
def build_model():
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(len(vocab),)),
        tf.keras.layers.Dense(64, activation="relu"),
        tf.keras.layers.Dropout(0.4),
        tf.keras.layers.Dense(len(labels), activation="softmax"),
    ])
    model.compile(optimizer="adam", loss="sparse_categorical_crossentropy",
                  metrics=["accuracy"])
    return model

train_rows, test_rows = [], []
for tag_id in range(len(labels)):
    rows = [r for r in examples if r[1] == tag_id]
    random.shuffle(rows)
    cut = max(1, len(rows) // 5)
    test_rows += rows[:cut]
    train_rows += rows[cut:]

X_train = np.array([vectorize(t) for t, _ in train_rows])
y_train = np.array([y for _, y in train_rows])
X_test = np.array([vectorize(t) for t, _ in test_rows])
y_test = np.array([y for _, y in test_rows])

model = build_model()
model.fit(X_train, y_train, epochs=150, batch_size=16, verbose=0)
loss, acc = model.evaluate(X_test, y_test, verbose=0)
print(f"Accuracy on unseen questions: {acc:.0%} ({len(test_rows)} questions)")

pred = model.predict(X_test, verbose=0).argmax(axis=1)
print("\\nMistakes:")
for (text, true), p in zip(test_rows, pred):
    if p != true:
        print(f"  '{text}': expected {labels[true]}, got {labels[p]}")
"""),
    md("## 4. Try your own questions"),
    code("""
def ask(question):
    probs = model.predict(vectorize(question)[None, :], verbose=0)[0]
    top = probs.argsort()[::-1][:3]
    print(question, "->", ", ".join(f"{labels[i]} {probs[i]:.0%}" for i in top))

for q in ["وين اروح مع عيالي", "ابي اكل بيتزا", "متى افضل وقت للزيارة",
          "وين اشوف النجوم", "مين حاتم الطائي", "ابغى كوفي هادي"]:
    ask(q)
"""),
    md("""
## 5. Train the final model on all examples and export it

`hail_guide_model.tflite` is the trained model the app runs on the phone.
`vocab.json` and `labels.json` let the app turn questions into numbers and
read the answer. `test_cases.json` lets the app check it gets the same results.
"""),
    code("""
X_all = np.array([vectorize(t) for t, _ in examples])
y_all = np.array([y for _, y in examples])
final_model = build_model()
final_model.fit(X_all, y_all, epochs=150, batch_size=16, verbose=0)
print(f"Accuracy on training examples: {final_model.evaluate(X_all, y_all, verbose=0)[1]:.0%}")

converter = tf.lite.TFLiteConverter.from_keras_model(final_model)
open("hail_guide_model.tflite", "wb").write(converter.convert())

json.dump({"feature_version": FEATURE_VERSION, "features": vocab},
          open("vocab.json", "w", encoding="utf-8"), ensure_ascii=False)
json.dump(labels, open("labels.json", "w", encoding="utf-8"), ensure_ascii=False)

checks = ["وين اروح مع عيالي", "ابي اكل بيتزا", "وين اشوف الغروب", "شكرا", "جبة"]
cases = []
for q in checks:
    probs = final_model.predict(vectorize(q)[None, :], verbose=0)[0]
    cases.append({"question": q, "label": labels[int(probs.argmax())],
                  "confidence": float(probs.max())})
json.dump(cases, open("test_cases.json", "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print(json.dumps(cases, ensure_ascii=False, indent=2))
"""),
    code("""
import zipfile
with zipfile.ZipFile("hail_guide_model.zip", "w") as z:
    for name in ["hail_guide_model.tflite", "vocab.json", "labels.json", "test_cases.json"]:
        z.write(name)
files.download("hail_guide_model.zip")
"""),
]

notebook = {
    "nbformat": 4,
    "nbformat_minor": 5,
    "metadata": {
        "kernelspec": {"name": "python3", "display_name": "Python 3"},
        "language_info": {"name": "python"},
        "colab": {"provenance": []},
    },
    "cells": cells,
}
for cell in notebook["cells"]:
    cell["source"] = [line + "\n" for line in cell["source"].split("\n")]
    cell["source"][-1] = cell["source"][-1].rstrip("\n")

(HERE / "train_guide.ipynb").write_text(
    json.dumps(notebook, ensure_ascii=False, indent=1), encoding="utf-8")
print("wrote train_guide.ipynb")
