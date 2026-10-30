import os
from pathlib import Path
import tkinter as tk
import unittest
import shutil
import subprocess
import sys
import tempfile

from _support import Zinc
from Zinc import graphics, pictorial


class WidgetTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        try:
            root = tk.Tk()
        except tk.TclError as error:
            if os.environ.get("TKZINC_TEST_REQUIRE_NATIVE"):
                raise
            raise unittest.SkipTest(str(error))
        try:
            if not Zinc.havetkzinc(root):
                if os.environ.get("TKZINC_TEST_REQUIRE_NATIVE"):
                    raise RuntimeError("Native TkZinc package is required")
                raise unittest.SkipTest("Native Tcl/Tk TkZinc package is unavailable")
        finally:
            root.destroy()

    def setUp(self):
        self.root = tk.Tk()
        self.root.withdraw()
        self.zinc = Zinc.Zinc(self.root, width=200, height=200, render=0)

    def tearDown(self):
        self.root.destroy()

    def test_items_and_transformations(self):
        item = self.zinc.add("rectangle", 1, (0, 0, 20, 10), filled=True)
        self.assertIn(item, self.zinc.find_all())
        self.zinc.translate(item, 5, 10)
        self.assertEqual(tuple(self.zinc.transform(item, 'device', (0, 0))), (5.0, 10.0))
        self.zinc.remove(item)
        self.assertNotIn(item, self.zinc.find_all())

    def test_root_group_and_item_wrappers(self):
        root_group = self.zinc.items[1]
        self.assertIs(root_group.zinc, self.zinc)
        rect = Zinc.Rectangle(self.zinc, root_group, (0, 0, 10, 10))
        self.assertIs(rect.getGroup(), root_group)
        rect["".join(("co", "ords"))] = ((2, 3), (12, 13))
        self.assertEqual(tuple(rect.coords()[0]), (2.0, 3.0))

    def test_invalid_item_raises_zinc_exception(self):
        with self.assertRaises(Zinc.ZincException):
            self.zinc.add("does-not-exist", 1)

    def test_item_configuration(self):
        item = self.zinc.add("rectangle", 1, (0, 0, 10, 10))
        self.zinc.itemconfigure(item, fillcolor="blue")
        self.assertEqual(self.zinc.itemcget(item, "fillcolor"), "blue")
        self.assertIn("fillcolor", self.zinc.itemconfigure(item))

    def test_second_interpreter(self):
        other_root = tk.Tk()
        other_root.withdraw()
        try:
            other = Zinc.Zinc(other_root, render=0)
            self.assertEqual(other.type(1), "group")
        finally:
            other_root.destroy()

    def test_mapinfo_duplicate(self):
        source = Zinc.Mapinfo(self.zinc)
        duplicate = source.duplicate()
        try:
            self.assertIs(duplicate.interp, source.interp)
            self.assertNotEqual(duplicate.name, source.name)
        finally:
            duplicate.delete()
            source.delete()

    def test_library_path_with_spaces(self):
        native_dir = os.environ.get('TKZINC_TEST_LIBRARY_DIR')
        if not native_dir:
            self.skipTest('Set TKZINC_TEST_LIBRARY_DIR for the local-library path test')
        with tempfile.TemporaryDirectory(prefix='tkzinc path with spaces ') as directory:
            shutil.copy(Path(native_dir) / 'pkgIndex.tcl', directory)
            for pattern in ('libTkzinc*.so', 'Tkzinc*.dll', 'libTkzinc*.dylib'):
                for library in Path(native_dir).glob(pattern):
                    shutil.copy(library, directory)
            # Windows retains loaded DLLs for the lifetime of the process.
            # Load the copy in a child so TemporaryDirectory can remove it.
            code = """
import os
import sys
import tkinter as tk
sys.path.insert(0, sys.argv[1])
from _support import Zinc
root = tk.Tk()
root.withdraw()
root.tk.call('set', 'auto_path', ())
os.environ['auto_path'] = sys.argv[2]
assert Zinc.havetkzinc(root), 'Cannot load TkZinc from a path containing spaces'
root.destroy()
"""
            result = subprocess.run(
                [sys.executable, '-c', code, str(Path(__file__).parent), directory],
                capture_output=True, text=True, timeout=30,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_geometry_builder(self):
        item = graphics.build_zinc_item(self.zinc, 1, itemtype="rectangle",
                                        coords=((0, 0), (10, 20)))
        self.assertEqual(self.zinc.type(item), "rectangle")

    def test_image_uses_widget_interpreter(self):
        image_file = Path(__file__).resolve().parents[1] / "demos" / "paper.gif"
        image = pictorial.get_image(self.zinc, str(image_file), storage={})
        self.assertGreater(image.width(), 0)
        self.zinc.add("icon", 1, image=image)


if __name__ == "__main__":
    unittest.main()
