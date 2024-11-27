#!/usr/bin/env python
"""Strip cells with "hide" tags from the notebooks."""

import argparse

import nbformat
from nbconvert import NotebookExporter
from traitlets.config import Config


def main():
    parser = argparse.ArgumentParser(
        prog="stripnb.py", description="Strip solutions from a Jupyter notebook"
    )
    parser.add_argument("path_inp", help="Input notebook with solutions")
    parser.add_argument(
        "path_out", help="Output notebook from which solutions are stripped."
    )
    args = parser.parse_args()
    strip_notebook(args.path_inp, args.path_out)


def strip_notebook(inp, out):
    config = Config()
    config.TagRemovePreprocessor.remove_cell_tags = ("hide",)
    config.TagRemovePreprocessor.enabled = True
    config.NotebookExporter.preprocessors = [
        "nbconvert.preprocessors.TagRemovePreprocessor"
    ]
    with open(inp) as fh:
        nb1 = nbformat.read(fh, as_version=4)
    json_str, _ = NotebookExporter(config=config).from_notebook_node(nb1)
    with open(out, "w") as fh:
        fh.write(json_str)


if __name__ == "__main__":
    main()
