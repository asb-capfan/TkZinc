#!/usr/bin/python
# -*- coding: iso-8859-1 -*-
from distutils.core import setup
setup(name="python-zinc",
      version="1.0",
      description="Zinc for Python",
      author="Guillaume Vidon",
      author_email="vidon at ath.cena.fr",
      license="GPL",
      url="http://www.tkzinc.org",
      py_modules=[],
      package_dir = {"Zinc" : "library"},
      packages = ["Zinc",],
      data_files=[('share/doc/zinc-python/demos/Graphics',
                   ['demos/testGraphics.py','demos/paper.gif'])])
                  

#Local Variables:
#mode: python
#End:
