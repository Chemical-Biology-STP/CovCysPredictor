"""Streamlit front‑end for CovCys Predictor
=======================================
Launch with:
    streamlit run cov_cys_app.py

This app provides a user‑friendly wrapper for the covalent‑cysteine prediction
pipeline. Upload a **cleaned** PDB file, click **Run prediction**, and you’ll
receive per‑cysteine scores (✅/❌) as a table, plus CSV download and raw‑JSON
options.

How it works
------------
1. The PDB is written to a unique temp workspace.
2. The helper script `run_cysteine_prediction.sh` is invoked **via `bash`** so
   we don’t depend on executable bits or a she‑bang.
3. The script drops a `<stub>_results.txt` JSON file in the output dir; we read
   and visualise it.
"""

from __future__ import annotations

import json
import subprocess
import tempfile
from pathlib import Path

import pandas as pd
import streamlit as st

#######################
# Configuration
#######################
PROJECT_ROOT = Path("/home/yipy/GitHub/CovCysPredictor")
RUN_SCRIPT = PROJECT_ROOT / "run_cysteine_prediction.sh"

#######################
# UI
#######################
st.title("Covalent‑Cysteine Predictor")

uploaded_pdb = st.file_uploader(
    "Upload a *cleaned* PDB file", type=["pdb"], accept_multiple_files=False
)

run = st.button("Run prediction", disabled=uploaded_pdb is None)

# Reset display when a new file is chosen
if "last_filename" not in st.session_state:
    st.session_state.last_filename = None

if uploaded_pdb and uploaded_pdb.name != st.session_state.last_filename:
    st.session_state.pop("results_df", None)
    st.session_state.pop("raw_json", None)
    st.session_state.last_filename = uploaded_pdb.name

#######################
# Run prediction
#######################
if run and uploaded_pdb:
    with st.status("Running predictor…", expanded=True):
        with tempfile.TemporaryDirectory() as tmp:
            tmpdir = Path(tmp)
            # write pdb
            pdb_path = tmpdir / uploaded_pdb.name
            pdb_path.write_bytes(uploaded_pdb.getbuffer())

            output_dir = tmpdir / "out"
            output_dir.mkdir()

            try:
                subprocess.run(
                    ["bash", str(RUN_SCRIPT), str(pdb_path), str(output_dir)],
                    cwd=PROJECT_ROOT,
                    capture_output=True,
                    text=True,
                    check=True,
                )
            except subprocess.CalledProcessError as e:
                st.error("Prediction failed:\n" + e.stderr)
                st.stop()

            # parse results
            txt_file = output_dir / f"{pdb_path.stem}_results.txt"
            raw_dict = json.loads(txt_file.read_text())
            df = (
                pd.DataFrame.from_dict(raw_dict, orient="index")
                .rename_axis("cys_id")
                .reset_index()
            )

            # map booleans/ints to symbols
            symbol_map = {True: "✅", False: "❌"}
            df["predicted_modifiable"] = df["predicted_modifiable"].map(
                symbol_map
            )
            df["any_fpocket"] = df["any_fpocket"].astype(bool).map(symbol_map)

            st.session_state.results_df = df
            st.session_state.raw_json = raw_dict

#######################
# Display
#######################
if "results_df" in st.session_state:
    st.subheader("Per‑cysteine scores")
    st.dataframe(st.session_state.results_df, hide_index=True)

    csv_bytes = st.session_state.results_df.to_csv(index=False).encode()
    st.download_button(
        "Download CSV",
        csv_bytes,
        file_name="cysteine_scores.csv",
        mime="text/csv",
    )

    with st.expander("Raw JSON results"):
        st.json(st.session_state.raw_json)
