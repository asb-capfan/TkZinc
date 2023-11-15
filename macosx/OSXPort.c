/*
 * OSXPort.c -- Compatibility layer for Mac OS X
 *
 * Authors		: Patrick Lecoanet.
 * Creation date	:
 *
 * $Id$
 */

/*
 *  Copyright (c) 2005 - CENA, Patrick Lecoanet --
 *
 * This code is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This code is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this code; if not, write to the Free
 * Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 */

#ifdef MAC_OSX_TK

#include "Types.h"
#include <Carbon/Carbon.h>


#ifndef MIN
#define MIN(a, b) 	((a) <= (b) ? (a) : (b))
#endif
#ifndef MAX
#define MAX(a, b) 	((a) >= (b) ? (a) : (b))
#endif


/*
 *----------------------------------------------------------------------
 *
 * ZnPointInRegion --
 *
 *	Test whether the specified point is inside a region.
 *
 * Results:
 *	Returns the boolean result of the test.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */
int
ZnPointInRegion(TkRegion reg,
                int      x,
                int      y)
{
  RgnHandle rgn = (RgnHandle) reg;
  Point     pt;

  pt.h = x;
  pt.v = y;

  return (int) PtInRgn(pt, rgn);
}

/*
 *----------------------------------------------------------------------
 *
 * ZnUnionRegion --
 *
 *	Compute the union of two regions.
 *
 * Results:
 *	Returns the result in the dr_return region.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */
void
ZnUnionRegion(TkRegion sra,
              TkRegion srb,
              TkRegion dr_return)
{
  RgnHandle srcRgnA = (RgnHandle) sra;
  RgnHandle srcRgnB = (RgnHandle) srb;
  RgnHandle destRgn = (RgnHandle) dr_return;

  UnionRgn(srcRgnA, srcRgnB, destRgn);
}

/*
 *----------------------------------------------------------------------
 *
 * ZnOffsetRegion --
 *
 *	Offset a region by the specified pixel offsets.
 *
 * Results:
 *	Returns the result in the dr_return region.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */
void
ZnOffsetRegion(TkRegion reg,
               int      dx,
               int      dy)
{
  RgnHandle rgn = (RgnHandle) reg;
  OffsetRgn(rgn, (short) dx, (short) dy);
}

/*
 *----------------------------------------------------------------------
 *
 * ZnPolygonRegion --
 *
 *	Compute a region from a polygon.
 *
 * Results:
 *	Returns the result in the dr_return region.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */
TkRegion
ZnPolygonRegion(XPoint *points,
                int    n,
                int	   fill_rule)
{
  RgnHandle rgn;
  int       i;

  rgn = NewRgn();

  OpenRgn();
  MoveTo((short) points[0].x, (short) points[0].y);
  for (i = 1; i < n; i++) {
    LineTo((short) points[i].x, (short) points[i].y);
  }
  LineTo((short) points[0].x, (short) points[0].y);
  CloseRgn(rgn);
  
  return (TkRegion) rgn;
}

#if 0
/*
 *----------------------------------------------------------------------
 *
 * XFillRectangles --
 *
 *	Fill multiple rectangular areas in the given drawable.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Draws onto the specified drawable.
 *
 *----------------------------------------------------------------------
 */
void
XFillRectangles(Display    *display,
                Drawable   d,
                GC         gc,
                XRectangle *rectangles,
                int        nrectangles)
{
}

/*
 *----------------------------------------------------------------------
 *
 * XFillRectangle --
 *
 *	Fills a rectangular area in the given drawable.  This procedure
 *	is implemented as a call to XFillRectangles.
 *
 * Results:
 *	None
 *
 * Side effects:
 *	Fills the specified rectangle.
 *
 *----------------------------------------------------------------------
 */
void
XFillRectangle(Display      *display,
               Drawable     d,
               GC           gc,
               int          x,
               int          y,
               unsigned int width,
               unsigned int height)
{
}

/*
 *----------------------------------------------------------------------
 *
 * XDrawLines --
 *
 *	Draw connected lines.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Renders a series of connected lines.
 *
 *----------------------------------------------------------------------
 */
void
XDrawLines(Display  *display,
           Drawable d,
           GC       gc,
           XPoint   *points,
           int      npoints,
           int      mode)
{
}

/*
 *----------------------------------------------------------------------
 *
 * XDrawLine --
 *
 *	Draw a single line between two points in a given drawable. 
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Draws a single line segment.
 *
 *----------------------------------------------------------------------
 */
void
XDrawLine(Display  *display,
          Drawable d,
          GC       gc,
          int      x1,
          int      y1,
          int      x2,
          int      y2)
{
}

/*
 *----------------------------------------------------------------------
 *
 * XFillPolygon --
 *
 *	Draws a filled polygon.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Draws a filled polygon on the specified drawable.
 *
 *----------------------------------------------------------------------
 */
void
XFillPolygon(Display  *display,
             Drawable d,
             GC       gc,
             XPoint   *points,
             int      npoints,
             int      shape,
             int      mode)
{
}

/*
 *----------------------------------------------------------------------
 *
 * XDrawRectangle --
 *
 *	Draws a rectangle.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Draws a rectangle on the specified drawable.
 *
 *----------------------------------------------------------------------
 */
void
XDrawRectangle(Display *display,
               Drawable d,
               GC gc,
               int x,
               int y,
               unsigned int width,
               unsigned int height)
{
}

/*
 *----------------------------------------------------------------------
 *
 * XDrawArc --
 *
 *	Draw an arc.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Draws an arc on the specified drawable.
 *
 *----------------------------------------------------------------------
 */
void
XDrawArc(Display      *display,
         Drawable     d,
         GC           gc,
         int          x,
         int          y,
         unsigned int width,
         unsigned int height,
         int          start,
         int          extent)
{
}

/*
 *----------------------------------------------------------------------
 *
 * XFillArc --
 *
 *	Draw a filled arc.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Draws a filled arc on the specified drawable.
 *
 *----------------------------------------------------------------------
 */
void
XFillArc(Display      *display,
         Drawable     d,
         GC           gc,
         int          x,
         int          y,
         unsigned int width,
         unsigned int height,
         int          start,
         int          extent)
{
}
#endif

#endif
