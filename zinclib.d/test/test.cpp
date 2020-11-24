/**       test.cpp
 *      zinclib
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
#include <stack>
#include <queue>

#define CNT 5000

ZincPath *path;
Zinc *zn;
Zinc *zn2;
int stop = 0;
String gradient = String("=axial 0 | blue | red");
std::queue<ZincItem*> pile;

void znCb (Zinc *zinc,  ZincItem *item, ZincEvent *event, void *userData)
{
  printf ("Callback : x=%d y=%d k=%d t=%ld K=%s\n",
          event->x, event->y, event->k, event->t, event->K.c_str ());
  try
  {
    ZincItem *rect;
    int j;
    if (stop == 0)
    {
      for (int i (0) ; i < CNT ; i++ )
      {
        j = i%300;

        rect = zn->itemCreateRectangle (NULL, 10+j, 10+j, 100, 100);
        zn->itemSetFilled (rect, 1);
        zn->itemSetFillcolor (rect, gradient);
        pile.push(rect);
      }
      stop = 1;
    }
    else
    {
      for (int i (0) ; i < CNT ; i++ )
      {
        rect = pile.front();
//        printf("rect %d %s\n",i,Tcl_GetString(rect->object));
        zn->itemRemove (rect);
        delete rect;
        pile.pop();
      }
      stop = 0;
    }
  }
  catch (ZincException e)
  {
    printf("ERRORCB : %s\n",e.what ());
  }
//  return 0;
}

void znCb2 (Zinc *zinc,  ZincItem *item, ZincEvent *event, void *userData)
{
  printf ("Callback2 : x=%d y=%d k=%d t=%1d K=%s\n",
          event->x, event->y, event->k, event->t, event->K.c_str ());
///  return 0;
}

int main (int argc, char** argv)
{
  try
  {
    Zinc::loadZinc (argv[0]);
    String black = String("white");
    String red = String("red");
    String texte = String("Bonjour lé gen");
    zn = new Zinc (ZINC_BACKEND_OPENGL);

    zn->setWidth (600);
    zn->setHeight (400);

    printf ("%s\n",zn->getBackcolor ().c_str());
    zn->setBackcolor (black);
    printf ("%s\n",zn->getBackcolor ().c_str());

    ZincItem *g1;
    ZincItem *g2;
    printf("create group1\n");
    g1 = zn->itemCreateGroup (NULL);
    printf("create group2\n");
    g2 = zn->itemCreateGroup (g1);

    printf("create rect\n");
    ZincItem *rect;
    rect = zn->itemCreateRectangle (g1, 10, 10, 100, 100);
    zn->itemSetFilled (rect, 1);
    zn->itemSetFillcolor (rect, red);
    printf("create arc\n");
    ZincItem *arc;
    arc = zn->itemCreateArc (NULL, 10, 10, 200, 200);

    zn->itemSetClosed (arc, 1);
    zn->itemSetExtent (arc, 230);
    zn->itemSetFilled (arc, 1);
    zn->itemSetFillcolor (arc, gradient);

    printf ("create text\n");
    ZincItem *text = zn->itemCreateText (g2);
    zn->itemSetText (text, texte);
    zn->itemSetPosition (text, 10, 200);
    delete text;
 
    printf ("create curve\n");
    path = new ZincPath(5,5);
    path->lineTo (100,5);
    path->lineTo (200,100);
    ZincItem *curve = zn->itemCreateCurve (g2, path);
    path->lineTo (200,200);
    delete curve;

    printf("create icon\n");
    ZincImage *image = zn->createImageFromFile ("paper.gif");
    ZincItem *icon = zn->itemCreateIcon (g2, image);
    zn->itemSetPosition (icon, 200, 10);
    
    printf("binding\n");
    zn->focus (arc);
    zn->itemBind (arc, String("<KeyPress-a>"), znCb, NULL);
    zn->itemBind (arc, String("<Button-1>"), znCb2, NULL);

    
/*    zn2 = new Zinc (ZINC_BACKEND_OPENGL);
    ZincItem *rect2;
    rect2 = zn2->itemCreateRectangle (NULL, 10, 10, 100, 100);
    zn2->focus (rect2);
    zn2->itemSetFilled (rect2, 1);
    zn2->itemSetFillcolor (rect2, red);
    zn2->setWidth (600);
    zn2->setHeight (400);
    zn2->itemBind (rect2, String("<KeyPress-a>"), znCb2, NULL);
*/    
    Zinc::zincMainLoop ();

    delete g1;
    delete g2;
    delete icon;
    delete image;
    delete arc;
    delete rect;
    delete (zn);
  }
  catch (ZincException e)
  {
    printf("ERROR : %s\n",e.what ());
  }
}
