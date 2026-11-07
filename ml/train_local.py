"""Runs the training notebook on this computer instead of Colab.

Needs Python 3.12 with TensorFlow 2.18. Run from the project folder:
    python ml/train_local.py
It runs the same cells as train_guide.ipynb and writes the model files
straight into assets/ml/.
"""
import json
import os
from pathlib import Path

HERE = Path(__file__).parent
OUT = HERE.parent / "assets" / "ml"

notebook = json.loads((HERE / "train_guide.ipynb").read_text(encoding="utf-8"))
cells = ["".join(c["source"]) for c in notebook["cells"] if c["cell_type"] == "code"]

# The first cell uploads intents.json in Colab; read it from disk instead.
cells[0] = cells[0].replace("from google.colab import files\n", "").replace(
    "uploaded = files.upload()  # choose ml/intents.json\n"
    'data = json.loads(next(iter(uploaded.values())).decode("utf-8"))',
    f'data = json.loads(open(r"{HERE / "intents.json"}", encoding="utf-8").read())')
# The last cell zips and downloads the files in Colab; not needed here.
cells = cells[:-1]

os.chdir(OUT)
scope = {}
for cell in cells:
    exec(compile(cell, "train_guide.ipynb", "exec"), scope)
print("model files written to", OUT)
