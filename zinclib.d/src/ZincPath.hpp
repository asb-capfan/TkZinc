/**       Path.hpp
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
 *   Here we defines The ZincPath object
 *
 *      08/03/05
 *
 *      Contributors:
 *           Benoit Peccatte <peccatte@intuilab.com>
 *
 */
#include "ZincTypes.hpp"

#include <list>
#include <tcl.h>

#ifndef ZINC_PATH
#define ZINC_PATH

class ZincPath
{
  double firstX, firstY;     //first point's coordinate
  double lastX, lastY;       //last point's coordinate
  Tcl_Obj* path;             //list of points

  /**
   * Append the point to the real path
   *
   * @param x,y the point coordinate
   * @param c true if the point is a control point
   */
  inline void addPoint (double x, double y, bool c);

  /**
   * Convert ellipse from SVG form to centered form (used only by arcTo)
   *
   * @param x0,y0 origin of the arc
   * @param rx x-radius of ellipse in degree (can be modified)
   * @param ry y-radius of ellipse in degree (can be modified)
   * @param phi rotation of ellipse in degree (can be modified)
   * @param largeArc true if the large part of the ellipse
   * @param sweep true for a positive angle direction for the drawing
   * @param x,y destination point
   * @param cx,cy center coordinate
   * @param theta begining of arc in degree
   * @param delta extent of arc in degree
   */
  void convertFromSvg (double x0, double y0, double &rx, double &ry, double &phi,
                       bool larcgeArc, bool sweep, double x, double y,
                       double &cx, double &cy, double &theta, double &delta);


public:
  /**
   * The public constructor
   *
   * @param x,y the initial point
   */  
  ZincPath (double x, double y);

  /**
   * The public destructor
   *
   * @warning Do not destroy a ZincPath if Zinc is not loaded
   */
  ~ZincPath ();

  /******************************************
       ZincPath manipulation
  ******************************************/
  /**
   * Close current path
   */
  void close ();

  /**
   * Draw a line from current point to next point
   *
   * @param x,y next point
   */
  void lineTo (double x, double y);

  /**
   * Draw a cubic bezier using specified control and destination points
   * call cubicBezierTo
   *
   * @param cx1,cy1 first control point
   * @param cx2,cy2 second control point
   * @param x,y destination point
   */
  void curveTo (double cx1, double cy1, double cx2, double cy2,
                double x, double y);

  /**
   * Draw a cubic bezier using specified control and destination points
   *
   * @param cx1,cy1 first control point
   * @param cx2,cy2 second control point
   * @param x,y destination point
   */
  void cubicBezierTo (double cx1, double cy1, double cx2, double cy2,
                      double x, double y);

  /**
   * Draw a quadratic bezier using specified control and destination point
   *
   * @param cx1,cy1 first control point
   * @param cx2,cy2 second control point
   * @param x,y destination point
   */
  void quadraticBezierTo (double cx, double cy, double x, double y);

  /**
   * Draw an arc from current point to x,y
   *
   * @param rx x-radius of ellipse
   * @param ry y-radius of ellipse
   * @param xAxisRotation rotation of ellipse
   * @param largeArc true if the large part of the ellipse
   * @param sweepFlag true for a positive angle direction for the drawing
   * @param x,y destination point
   */
  void arcTo (double rx, double ry, double xAxisRotation, bool largeArc,
              bool sweepFlag, double x, double y);
  
  /**
   * Return a Tcl_Obj* containing a list of coords points
   *  It's up to the caller to delete the resulting table
   *
   * @return a Tcl_Obj* of type list
   */
  Tcl_Obj* getTable ();

};

#endif

