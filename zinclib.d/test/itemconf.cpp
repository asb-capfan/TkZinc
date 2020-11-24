/**       itemconf.cpp
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

//prepare constants
//white color
String white = String ("white");
// red color
String red = String ("red");
// blue color
String blue = String ("blue");
// sample text
String texte = String ("Hello world");
// sample gradient
String gradient = String ("=axial 0 | blue | white 50 | red");
// sample gradient
String gradient2 = String ("=axial 0 | yellow | green 50 | red");
// gradient name
String gname = "g1";
// empty tag
String tag = String("");

String image =
"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";

//Let's test all item types
int main (int argc, char** argv)
{
  double a,b,c,d,e,f;
  //catch exceptions
  try
  {
    //don't forget to load zinc
    Zinc::loadZinc (argv[0]);
    //create the widget
    zn = new Zinc (ZINC_BACKEND_OPENGL);

    //give it parameters
    zn->setWidth (800);
    zn->setHeight (600);

    ZincItem *g1;
    //create a group
    g1 = zn->itemCreateGroup (NULL);
    //create a rectangle
    ZincItem *rect;
    rect = zn->itemCreateRectangle (g1, 10, 10, 100, 100);

    // create an arc
    ZincItem *arc;
    arc = zn->itemCreateArc (NULL, 10, 10, 200, 200);

    // create a curve
    ZincPath* path = new ZincPath(200,200);
    //test lineto
    path->lineTo (250,250);
    //test quadraticBezierTo
    path->quadraticBezierTo (300,200, 300,300);

    //path->close ();
    //display the curve
    ZincItem *curve = zn->itemCreateCurve (g1, path);
     
    // create a sample text
    ZincItem *text = zn->itemCreateText (g1);
    zn->itemSetPosition (text, 10, 300);

    ZincItem *empty = zn->createTag(tag);
    /**************************************
           tests simple sets and gets
    **************************************/

    //transformations
    zn->itemRotate (rect, 45, true);
    zn->itemSetTransformation (rect, 1, 0, 0, 1, 0, 0);
    zn->itemGetTransformation (rect, &a, &b, &c, &d, &e, &f);
    printf ("Transformation \n%f,%f,%f,%f,%f,%f\n", a, b, c, d, e, f);

    //closed
    zn->itemSetClosed (arc, 1);
    printf ("Closed %d\n",zn->itemGetClosed (arc));

    //composeAlpha
    zn->itemSetComposealpha (rect, 1);
    printf ("composeAlpha %d\n", zn->itemGetComposealpha (rect));

    //Composerotation
    zn->itemSetComposerotation (rect, 1);
    printf ("Composerotation %d\n", zn->itemGetComposerotation (rect));
    
    //Composescale
    zn->itemSetComposescale(rect,1);
    printf ("Composescale %d\n", zn->itemGetComposescale (rect));

    //extent
    zn->itemSetExtent (arc, 230);
    printf ("Extent %d\n", zn->itemGetExtent (arc));

    //fillcolor
    zn->itemSetFillcolor(rect, red);
    printf ("Fillcolor %s\n", zn->itemGetFillcolor (rect).c_str ());

    //filled
    zn->itemSetFilled (rect, 1);
    printf ("Filled %d\n", zn->itemGetFilled (rect));

    //linecolor
    zn->itemSetLinecolor (arc, blue);
    printf ("linecolor %s\n", zn->itemGetLinecolor (arc).c_str ());

    //linestyle
    zn->itemSetLinestyle (arc, lineStyle_dashed);
    printf ("linestyle %d\n", zn->itemGetLinestyle (arc));

    //linewidth
    zn->itemSetLinewidth (arc, 3);
    printf ("linewidth %f\n", zn->itemGetLinewidth (arc));

    //piesplice
    zn->itemSetPieslice (arc, 1);
    printf ("piesplice %d\n", zn->itemGetPieslice (arc));

    //priority
    zn->itemSetPriority (rect, 10);
    printf ("priority %d\n", zn->itemGetPriority (rect));

    //Sensitive
    zn->itemSetSensitive (rect, 1);
    printf ("Sensitive %d\n", zn->itemGetSensitive (rect));

    //Startangle
    zn->itemSetStartangle (arc, 90);
    printf ("Startangle %d\n", zn->itemGetStartangle (arc));

    //SetVisible
    zn->itemSetVisible (rect, 1);
    printf ("Visible %d\n", zn->itemGetVisible (rect));

    //Capstyle
    zn->itemSetCapstyle (curve, capStyle_projecting);
    printf ("Capstyle %d\n", zn->itemGetCapstyle (curve));

    //Fillrule
    zn->itemSetFillrule (curve, fillRule_negative);
    printf ("Fillrule %d\n", zn->itemGetFillrule (curve));

    //Joinstyle
    zn->itemSetJoinstyle (curve, joinStyle_miter);
    printf ("Joinstyle %d\n", zn->itemGetJoinstyle (curve));

    //Relief
    zn->itemSetRelief (curve, relief_groove);
    printf ("Relief %d\n", zn->itemGetRelief (curve));
    
    //Smoothrelief
    zn->itemSetSmoothrelief (curve, 1);
    printf ("Smoothrelief %d\n", zn->itemGetSmoothrelief (curve));

    //alpha
    zn->itemSetAlpha (g1, 75);
    printf ("alpha %d\n", zn->itemGetAlpha (g1));

    //Atomic
    zn->itemSetAtomic (g1, 1);
    printf ("Atomic %d\n", zn->itemGetAtomic (g1));

    //Anchor
    zn->itemSetAnchor (text, anchor_nw);
    printf ("Anchor %d\n", zn->itemGetAnchor (text));

    //Color
    zn->itemSetColor (text, blue);
    printf ("Color %s\n", zn->itemGetColor (text).c_str ());

    //ConnectedItem
    zn->itemSetConnecteditem (text, rect);
    ZincItem *it0 = zn->itemGetConnecteditem (text);
    printf ("ConnectedItem %x\n", (int)it0);

    //Connectionanchor
    zn->itemSetConnectionanchor (text, anchor_se);
    printf ("Connectionanchor %d\n", zn->itemGetConnectionanchor (text));

    //Alignment
    zn->itemSetAlignment (text, alignment_right);
    printf ("Alignment %d\n", zn->itemGetAlignment (text));

    //Overstriked
    zn->itemSetOverstriked (text, 1);
    printf ("Overstriked %d\n", zn->itemGetOverstriked (text));

    //Spacing
    zn->itemSetSpacing (text, 10);
    printf ("Spacing %d\n", zn->itemGetSpacing (text));

    //text
    zn->itemSetText (text, texte);
    printf ("text %s\n", zn->itemGetText (text).c_str ());

    //Underlined
    zn->itemSetUnderlined (text, 1);
    printf ("Underlined %d\n", zn->itemGetUnderlined (text));

    //width
    zn->itemSetWidth (text, 500);
    printf ("width %d\n", zn->itemGetWidth (text));
    
    //Clip
    zn->itemSetClip (g1, rect);
    ZincItem *it1 = zn->itemGetClip (g1);
    printf ("Clip %x\n", (int)it1);
    zn->itemSetClip (g1, empty);


    /**************************************
         tests more sets and gets
    **************************************/

    //firt end
    double a,b,c;
    zn->itemSetLastend (curve, 5, 6, 7);
    zn->itemGetLastend (curve, &a, &b, &c);
    printf ("lastend %f, %f, %f\n", a, b, c);
    
    //last end        
    zn->itemSetFirstend (curve, 5, 6, 7);
    zn->itemGetFirstend (curve, &a, &b, &c);
    printf ("firstend %f, %f, %f\n", a, b, c);


    // position
    zn->itemGetPosition (text, &a, &b);
    printf ("position %f, %f\n", a, b);

    //font
    ZincFont *fn = zn->itemGetFont (text);
    printf("Font %s\n", fn->name.c_str ());

    // add tags
    zn->addTag (rect, String ("tag0"));
    zn->addTag (rect, String ("tag1"));

    //tags
    String **taglist;
    int count = zn->getTags (rect, &taglist);
    for ( int i = 0 ; i < count ; i++ )
    {
      printf("Tag %d : %s\n", i, taglist[i]->c_str ());
    }

    // delete tag
    zn->dTag (rect, String ("tag0"));

    // new rectangle
    ZincItem *r2;
    r2 = zn->itemCreateRectangle (g1, 210, 210, 300, 300);

    //icons
    ZincImage* img = zn->createImageFromData (image);
    ZincItem *icon = zn->itemCreateIcon (g1, img);
    zn->itemTranslate (icon, 500,10);

    //getImage
    ZincImage *it2 = zn->itemGetImage (icon);
    printf("Image %x\n", (int)it2);

    //bitmaps
    ZincBitmap *bm = zn->createBitmapFromName ("AlphaStipple5");
    zn->itemSetFillpattern (r2, bm);

    //fillpattern
    zn->itemSetFillpattern (curve, bm);
    ZincBitmap *it3 = zn->itemGetFillpattern (curve);
    printf("fillpattern %x\n", (int)it3);
    
    //tile
    zn->itemSetTile (curve, bm);
    ZincBitmap *it4 = zn->itemGetTile (curve);
    printf("Tile %x\n", (int)it4);

    //mask
    zn->itemSetMask (icon, bm);
    ZincBitmap *it5 =  zn->itemGetMask (icon);
    printf("Mask %x\n", (int)it5);

    //linepattern
    zn->itemSetLinepattern (curve, bm);
    ZincBitmap *it6 = zn->itemGetLinepattern (curve);
    printf("linepattern %x\n", (int)it6);

    /****************************************
         tests other functions for items
    ****************************************/

    // raise and lower
    zn->raise (icon);
    zn->lower (icon);
    zn->raise (icon, r2);
    zn->lower (icon, r2);

    //gradient name related
    printf("Not gname %d\n", zn->isGname (gname));
    zn->gname (gradient, gname);
    printf("Is gname %d\n", zn->isGname (gname));

    //clone
    ZincItem *i2 = zn->clone (icon);
    zn->itemTranslate (i2, 50, 50);

    // type
    printf("Type %d\n", zn->type (icon));

    //font
    delete fn;
    fn = zn->getFont ();
    printf("Font %s\n", fn->name.c_str ());

    // get contour
    printf ("n Contours %d\n", zn->contour (rect));
    
    // set contour
    ZincItem *curve2 = zn->itemCreateCurve (g1, path);
    zn->contour (curve2, item_add_clockwise, r2);
    zn->contour (curve2, item_add_counterclockwise, rect);

    // set coords
    zn->coords (curve2, path, false );
    zn->coords (curve2, path, true, 1, 1 );

    //remove coords
    //zn->coordsRemove (curve2, 0);

    //deletes
    delete path;
    delete empty;
    delete arc;
    delete r2;
    for(int i=0;i<count;i++)
    {
      delete taglist[i];
    }
    delete[] taglist;
    delete bm;
    delete it0;
    delete it1;
    delete it2;
    delete it3;
    delete it4;
    delete it5;
    delete it6;
    delete curve2;
    delete rect;
    delete img;
    delete icon;
    delete i2;
    delete g1;
    delete text;
    delete fn;
    delete curve;
      
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
