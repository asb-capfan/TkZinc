import unittest

from _support import Zinc
from Zinc import geometry, graphics, pictorial


class HelpersTest(unittest.TestCase):
    def test_exception_is_catchable(self):
        with self.assertRaisesRegex(Zinc.ZincException, "failure"):
            Zinc.ZincException("failure")()

    def test_coordinate_validation(self):
        self.assertTrue(graphics.is_flat_list([0, 1, 2.5, 3]))
        self.assertFalse(graphics.is_flat_list([0, "x"]))
        with self.assertRaises(ValueError):
            graphics.is_flat_list([1, 2, 3])
        self.assertTrue(graphics.is_point((0, 1)))
        self.assertTrue(graphics.is_point([1, 2, "c"]))
        self.assertFalse(graphics.is_point([1, 2, "invalid"]))

    def test_arc_in_both_directions(self):
        for extent, step in ((90, 45), (-90, -45)):
            with self.subTest(extent=extent):
                points = geometry.arc_pts((0, 0), 10, extent=extent, step=step)
                self.assertEqual(len(points), 3)
                self.assertAlmostEqual(points[-1][0], 0)
                self.assertAlmostEqual(abs(points[-1][1]), 10)

    def test_bezier_has_intermediate_points(self):
        points = geometry.bezier_segment(((0, 0), (10, 20), (20, 0)), tunits=4)
        self.assertEqual(points[0], (0, 0))
        self.assertEqual(points[2], (10, 10))
        self.assertEqual(points[-1], (20, 0))

    def test_adaptive_bezier(self):
        points = geometry.bezier_compute(((0, 0), (0, 10), (20, 10), (20, 0)))
        self.assertGreater(len(points), 2)
        self.assertEqual(points[0], (0, 0))
        self.assertEqual(points[-1], (20, 0))

    def test_color_formats(self):
        self.assertEqual(pictorial.zncolor_to_rgb("#123456;25"), (18, 52, 86, 25))
        self.assertEqual(pictorial.zncolor_to_rgb("#ffff00008000"), (65535, 0, 32768, 100))
        with self.assertRaises(ValueError):
            pictorial.zncolor_to_rgb("not a color")
        self.assertAlmostEqual(pictorial.hexa2rgb("#808080")[0], 128 / 255)

    def test_gradient_interpolates(self):
        colors = pictorial.create_graduate(5, ("#000000", "#ffffff"))
        self.assertEqual(len(colors), 5)
        self.assertNotEqual(colors[0], colors[2])
        self.assertNotEqual(colors[2], colors[-1])
        with self.assertRaises(ValueError):
            pictorial.create_graduate(1, ("#000000", "#ffffff"))

    def test_double_gradient_has_pairs(self):
        colors = pictorial.path_graduate(None, 4, {
            "type": "double",
            "colors": (("#000000", "#ffffff"), ("#ff0000", "#0000ff")),
        })
        self.assertEqual(len(colors), 10)

    def test_color_spaces_round_trip(self):
        rgb = (0.3, 0.5, 0.8)
        result = pictorial.hls_to_rgb(*pictorial.rgb_to_hls(*rgb))
        for actual, expected in zip(result, rgb):
            self.assertAlmostEqual(actual, expected)

    def test_number_formatting(self):
        self.assertEqual(pictorial._trunc(1.2345, 2), "1.23")


if __name__ == "__main__":
    unittest.main()
