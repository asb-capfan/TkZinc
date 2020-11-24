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
//global variable
Zinc *zn;
Zinc *zn2;

//prepare constants
//black color
String black = String("white");
// red color
String red = String("blue");
// sample text
String texte = String("Hello world");
// sample gradient
String gradient = String("=axial 0 | blue | white 50 | red");


void znCb (Zinc *zinc,  ZincItem *item, ZincEvent *event, void *userData)
{
  printf ("Callback1 : x=%d y=%d k=%d t=%ld K=%s w=%d h=%d X=%d Y=%d b=%d\n",
          event->x, event->y, event->k, event->t, event->K.c_str (),
          event->w, event->h, event->X, event->Y, event->b );
}


void znCb2 (Zinc *zinc,  ZincItem *item, ZincEvent *event, void *userData)
{
  printf ("Callback2 : x=%d y=%d k=%d t=%ld K=%s w=%d h=%d X=%d Y=%d b=%d\n",
          event->x, event->y, event->k, event->t, event->K.c_str (),
          event->w, event->h, event->X, event->Y, event->b );
}

void znCb3 (Zinc *zinc, ZincEvent *event, void *userData)
{
  printf ("Callback3 : x=%d y=%d k=%d t=%ld K=%s w=%d h=%d X=%d Y=%d b=%d\n",
          event->x, event->y, event->k, event->t, event->K.c_str (),
          event->w, event->h, event->X, event->Y, event->b );
}

//Let's test all item types
int main (int argc, char** argv)
{
  //catch exceptions
  try
  {
    //don't forget to load zinc
    Zinc::loadZinc (argv[0]);

    //create the widget
    zn = new Zinc (ZINC_BACKEND_OPENGL);

    //give it parameters
    zn->setWidth (600);
    zn->setHeight (400);
    zn->setTitle("window1");

    //change background color
    printf ("Backcolor %s\n",zn->getBackcolor ().c_str());
    // test background color
    zn->setBackcolor (black);
    printf ("Backcolor %s\n",zn->getBackcolor ().c_str());

    //change foreground color
    printf ("Forecolor %s\n",zn->getForecolor ().c_str());
    // test foreground color
    zn->setForecolor (red);
    printf ("Forecolor %s\n",zn->getForecolor ().c_str());

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
    // in red
    zn->itemSetFillcolor (rect, red);

    //test change group
    zn->chggroup (rect, g2);
    ZincItem *g = zn->group (rect);
    printf("Group %x\n", (int)g);
    delete g;
    zn->chggroup (rect, g1);

    // test bindings
    zn->focus (rect);
    zn->itemBind (rect, String("<KeyPress-a>"), znCb, NULL);
    zn->itemBind (rect, String("<Button-1>"), znCb2, NULL);
    zn->itemBind (rect, String("<KeyPress-a>"), znCb2, NULL,true);

    //test widget properties
    printf ("Borderwidth %d\n", zn->getBorderwidth ());
    zn->setBorderwidth (3);
    printf ("Borderwidth %d\n", zn->getBorderwidth ());

    // fonts
    ZincFont *font = zn->createFont ("courier", 24);
    printf ("setFont\n");
    zn->setFont (font);
    printf ("fontAscent %d\n", zn->getFontAscent (font));
    ZincItem* text = zn->itemCreateText (NULL);
    zn->itemSetText (text, texte);
    zn->itemSetPosition (text, 10, 300);
    printf ("itemsetFont\n");
    zn->itemSetFont (text, font);
    delete text;
    delete font;

    //test a second widget
    zn2 = new Zinc (ZINC_BACKEND_OPENGL);
    zn2->setWidth (600);
    zn2->setHeight (800);
    zn2->setHeight (400);
    zn2->setHeight (600);
    zn2->setTitle("window2");
    printf("Dimension %d x %d\n",
           zn2->getWidth(), zn2->getHeight());
    ZincItem *rect2;

    //something on the 2nd widget
    rect2 = zn2->itemCreateRectangle (NULL, 100, 100, 100, 100);

    //binding on the 2nd widget directly
    zn2->focus (rect2);
    zn2->itemSetFilled (rect2, 1);
    zn2->itemSetFillcolor (rect2, gradient);
    zn2->bind (String("<KeyPress-a>"), znCb3, NULL);
    zn2->bind (String("<KeyPress-a>"), znCb3, NULL,true);
    zn2->unbind (String("<KeyPress-a>"));
    zn2->bind (String("<KeyPress-a>"), znCb3, NULL);

    //exception test
    try
    {
      zn->itemSetClip (rect2, rect2);
    }
    catch (ZincException &e)
    {
      printf("Exception OK SUCCESS %s OK SUCCESS\n", e.what());
    }

    delete rect;
    delete rect2;
    delete g1;
    delete g2;
    
    //run all this
    Zinc::zincMainLoop ();

    // delete the widget
    delete (zn);
  }
  catch (ZincException &e)
  {
    printf("ERROR : %s\n",e.what ());
  }
  catch (std::exception &e)
  {
    printf("STD ERROR : %s\n",e.what ());
  }
}
