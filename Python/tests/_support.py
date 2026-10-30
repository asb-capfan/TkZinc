"""Load the source package, whose directory is mapped to Zinc when installed."""

import importlib.util
from pathlib import Path
import sys

PACKAGE = Path(__file__).resolve().parents[1] / "library"
if "Zinc" not in sys.modules:
    spec = importlib.util.spec_from_file_location(
        "Zinc", PACKAGE / "__init__.py", submodule_search_locations=[str(PACKAGE)]
    )
    Zinc = importlib.util.module_from_spec(spec)
    sys.modules["Zinc"] = Zinc
    spec.loader.exec_module(Zinc)
else:
    Zinc = sys.modules["Zinc"]
