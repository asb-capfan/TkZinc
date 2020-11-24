/**       items.cpp
 *      zinclib/tests
 *
 *   This software is the property of IntuiLab SA, France.
 *   All rights reserved.
 *
 *   Redistribution and use in source and binary forms, with or without
 *   modification, are permitted provided that the following conditions
 *   are met:
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *   3. The name of the author may not be used to endorse or promote products
 *      derived from this software without specific prior written permission.
 * 
 *   THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 *   IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *   OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *   IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 *   INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *   NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 *   THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 *   Some tests for zinclib
 *
 *      08/03/05
 *
 *      Contributors:
 *           Benoit Peccatte <peccatte@intuilab.com>
 *
 */


#include "Zinc.hpp"
#include <math.h>
//global variable
Zinc *zn;

const double PI = atan2 (1., 1.) * 4.;

//prepare constants
//black color
String black = String ("white");
// red color
String red = String ("red");
// sample text
String texte = String ("Hello world");
// sample gradient
String gradient = String ("=axial 0 | blue | white 50 | red");
// sample gradient
String gradient2 = String ("=axial 0 | yellow | green 50 | red");

//Let's test all item types
int main (int argc, char** argv)
{
  //catch exceptions
  try
  {
    //don't forget to load zinc
    Zinc::loadZinc (argv[0]);
    ZincPath *path;

    //create the widget
    zn = new Zinc (ZINC_BACKEND_OPENGL);

    //give it parameters
    zn->setWidth (600);
    zn->setHeight (400);

    //change background color
    printf ("%s\n",zn->getBackcolor ().c_str ());
    zn->setBackcolor (black);
    printf ("%s\n",zn->getBackcolor ().c_str ());

    ZincItem *g1;
    ZincItem *g2;
    //create a group
    g1 = zn->itemCreateGroup (NULL);
    // create another group (with parent)
    g2 = zn->itemCreateGroup (g1);

    //create a rectangle
    ZincItem *rect;
    rect = zn->itemCreateRectangle (g1, 10, 10, 100, 100);
    // fill the rectangle
    zn->itemSetFilled (rect, 1);
    // remove the rectangle
    zn->itemRemove (rect);
    delete rect;

    //try a second one
    rect = zn->itemCreateRectangle (g1, 10, 10, 100, 100);
    // fill the rectangle
    zn->itemSetFilled (rect, 1);
    // in red
    zn->itemSetFillcolor (rect, red);
    zn->itemSetTransformation (rect, cos (PI / 4), sin (PI / 4),
                               -sin (PI / 4), cos (PI / 4), 100, 0);
    delete rect;

    // create an arc
    ZincItem *arc;
    arc = zn->itemCreateArc (NULL, 10, 10, 200, 200);

    // give parameters to the arc
    zn->itemSetClosed (arc, 1);
    zn->itemSetExtent (arc, 230);
    // fill the arc
    zn->itemSetFilled (arc, 1);
    // with a gradient
    zn->itemSetFillcolor (arc, gradient);
    delete arc;

    // create a sample text
    ZincItem *text = zn->itemCreateText (g2);
    zn->itemSetText (text, texte);
    zn->itemSetPosition (text, 10, 300);
    zn->itemSetPosition (text, 10, 300);
    delete text;

    // create a curve
    path = new ZincPath(200,200);
    //test lineto
    path->lineTo (250,250);
    //test quadraticBezierTo
    path->quadraticBezierTo (300,200, 300,300);
    //test cubicBezierTo
    path->cubicBezierTo (400,400, 500,300, 400,200);
    path->curveTo (500,200, 500,100, 400,100);

    //test arcs
    path->arcTo (100, 100, 0, false, true, 300, 100);


    // test close
    path->close ();
    //display the curve
    ZincItem *pa = zn->itemCreateCurve (g2, path);
    zn->contour (pa, false, path);
    zn->contour (pa, true, path);
    delete path;
    // fill the arc
    zn->itemSetFilled (pa, 1);
    // with a gradient
    zn->itemSetFillcolor (pa, gradient2);
    zn->itemTranslate (pa, 30, 30, false);

    // test bounding box
    double bbox[4];
    zn->bbox (pa, bbox);
    printf ("bbox %f, %f, %f, %f\n", bbox[0], bbox[1], bbox[2], bbox[3]);
    delete pa;
    
    // create an icon from a file
    ZincImage *image = zn->createImageFromFile ("paper.gif");
    ZincItem *icon = zn->itemCreateIcon (g2, image);
    printf("icon width %d, height %d\n",
           zn->getImageWidth (image), zn->getImageHeight (image));
    zn->itemSetPosition (icon, 200, 10);
    zn->itemTranslate (icon, -20, 10);
    zn->itemRotate (icon, 0);
    zn->itemRotate (icon, -45, 0, 0);
    zn->itemRotate (icon, 45, true);
    zn->itemRotate (icon, 45, 0, 0, true);
    delete icon;

    // another icon to test other transforms
    ZincItem *icon2 = zn->itemCreateIcon (g2, image);
    zn->itemSetPosition (icon2, 300, 10);
    zn->itemScale (icon2, 3., 3.);
    zn->itemScale (icon2, .5, .5, 0, 0);
    zn->itemSkew (icon2, 10, 10);
    zn->itemSkewX (icon2, -10);
    zn->itemSkewY (icon2, -10);

    // test bounding box
    zn->relativeBbox (icon2, bbox);
    printf ("relativeBbox %f, %f, %f, %f\n", bbox[0], bbox[1], bbox[2], bbox[3]);
    delete icon2;


    // another icon to test other transforms
    ZincItem *icon3 = zn->itemCreateIcon (g2, image);
    zn->itemSetPosition (icon3, 400, 10);
    zn->itemScale (icon3, 3., 3.);
    zn->itemResetTransformation (icon3);
    double a, b, c, d, e, f;
    zn->itemGetTransformation (icon3, &a, &b, &c, &d, &e, &f);
    printf ("Transform %f %f %f %f %f %f\n", a, b, c, d, e, f);
    zn->itemSetTransformation (icon3, a, b, c, d, e, f+20);
    zn->itemMatrix (icon3, 2, 0, 0, 2, 1, 1);
    delete icon3;
    delete image;

    delete g1;
    delete g2;
    
    //run all this
    Zinc::zincMainLoop ();

    // delete the widget
    delete (zn);
  }
  catch (ZincException e)
  {
    printf("ERROR : %s\n",e.what ());
  }
}
