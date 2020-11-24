/**       Path.cpp
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
#include "Zinc.hpp"
#include "ZincInternal.hpp"

#include <math.h>

// convert degree to radians
const double convertRatio = atan2 (1., 1.) * 4. / 180.;

/**
 * Calculate d % m for doubles
 * this is because the C % works only for integers
 */
inline double modulo (double d, double m)
{
  return d - (floor (d / m) * m);
//  return d;
}
  
/**
 * Append the point to the real path
 *
 * @param x,y the point coordinate
 * @param c true if the point is a control point
 */
inline void ZincPath::addPoint (double x, double y, bool c)
{
  // update last control point
  lastX = x;
  lastY = y;

  // we can't use a flat list since zinc accepts flat list only for simple
  // lines
  Tcl_Obj* point[3];
  int i = 2;
  //create a point object
  //an object for x
  point[0] = Tcl_NewDoubleObj (x);
  // an object for y
  point[1] = Tcl_NewDoubleObj (y);
  // an object for 'c' only if needed
  if (c)
  {
    point[2] = Tcl_NewStringObj ("c", -1);
    i = 3;
  }

  // the point (this increments refcount)
  Tcl_Obj* tmp = Tcl_NewListObj (i, point);
  // append the point to the list
  Zinc::z_tcl_call ( Tcl_ListObjAppendElement (Zinc::interp, path, tmp),
               "addpoint Error:");
}

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
void ZincPath::convertFromSvg (double x0, double y0, double &rx, double &ry,
                               double &phi, bool largeArc, bool sweep,
                               double x, double y, double &cx, double &cy,
                               double &theta, double &delta)
{
  /* all this strictly follow the script given in "SVG essentials"
   * p85 : convert an elliptical arc fo SVG to an elliptical arc
   * based around a central point
   */

  // temporary variables
  double dx2, dy2, phiR, x1, y1;
  double rxSq, rySq, x1Sq, y1Sq;
  double sign, sq, coef, radiusCheck;
  double cx1, cy1, sx2, sy2;
  double p, n, ux, uy, vx, vy;

  // compute 1/2 distance between current and final point
  dx2 = (x0 - x) / 2.;
  dy2 = (y0 - y) / 2.;

  //convert from degree to radians
  phi = modulo (phi, 360.);
  phiR = phi * convertRatio;

  //compute (x1, y1)
  x1 = cos (phiR) * dx2 + sin (phiR) * dy2;
  y1 = -sin (phiR) * dx2 + cos (phiR) * dy2;

  // make sure radii are large enough
  rx = fabs (rx); ry = fabs (ry);
  rxSq = rx * rx;
  rySq = ry * ry;
  x1Sq = x1 * x1;
  y1Sq = y1 * y1;

  radiusCheck = (x1Sq / rxSq) + (y1Sq / rySq);
  if (radiusCheck > 1.)
  {
    rx *= sqrt (radiusCheck);
    ry *= sqrt (radiusCheck);
    rxSq = rx * rx;
    rySq = ry * ry;
  }

  //step 2 compute (cx1, cy1)
  sign = (largeArc == sweep) ? -1. : 1.;
  sq = ((rxSq * rySq) - (rxSq * y1Sq) - (rySq * x1Sq)) /
    ((rxSq * y1Sq) + (rySq * x1Sq));
  sq = (sq < 0.) ? 0. : sq;
  coef = (sign * sqrt (sq));
  cx1 = coef * ((rx * y1) / ry);
  cy1 = coef * -((ry * x1) / rx);

  //step 3 : compute (cx, cy) from (cx1, cy1)
  sx2 = (x0 + x) / 2;
  sy2 = (y0 + y) / 2;

  cx = sx2 + (cos (phiR) * cx1 - sin (phiR) * cy1);
  cy = sy2 + (sin (phiR) * cx1 + cos (phiR) * cy1);

  //step 4 : compute angle start angle extent
  ux = (x1 - cx1) / rx;
  uy = (y1 - cy1) / ry;
  vx = (-x1 - cx1) / rx;
  vy = (-y1 - cy1) / ry;
  n = sqrt ((ux *ux) + (uy * uy));
  p = ux; // 1 * ux + 0 * uy
  sign = (uy < 0.) ? -1. : 1.;

  theta = sign * acos (p /n);
  theta = theta / convertRatio;

  n = sqrt ((ux * ux + uy * uy) * (vx * vx + vy * vy));
  p = ux * vx + uy * vy;
  sign = ((ux * vy - uy * vx) < 0.) ? -1. : 1.;
  delta = sign * acos (p / n);
  delta = delta / convertRatio;;

  if (!sweep && delta > 0.)
  {
    delta -= 360.;
  }
  else if (sweep && delta < 0.)
  {
    delta += 360.;
  }

//  delta = modulo (delta, 360.);
//  theta = modulo (theta, 360.);
}


/**
 * The public constructor
 *
 * @param x,y the initial point
 */  
ZincPath::ZincPath (double x, double y)
  : firstX (x), firstY (y)
{
  // create a default path
  path = Tcl_NewListObj (0, NULL);
  // the path must not be deleted by tcl
  Tcl_IncrRefCount (path);
  // add the first point
  addPoint (x, y, false);
}

/**
 * The public destructor
 *
 * @warning Do not destroy a ZincPath if Zinc is not loaded
 */
ZincPath::~ZincPath ()
{
  //decrement reference count on all objs in list -> free
  Tcl_SetIntObj (path, 1);
  //decrement reference count on the list -> free
  Tcl_DecrRefCount (path);
}

/**
 * Close current path
 */
void ZincPath::close ()
{
  addPoint (firstX, firstY, false);
}

/**
 * Draw a line from current point to next point
 *
 * @param x,y next point
 */
void ZincPath::lineTo (double x, double y)
{
  addPoint (x, y, false);
}

/**
 * Draw a cubic bezier using specified control and destination points
 * call cubicBezierTo
 *
 * @param cx1,cy1 first control point
 * @param cx2,cy2 second control point
 * @param x,y destination point
 */
void ZincPath::curveTo (double cx1, double cy1, double cx2, double cy2,
                    double x, double y)
{
  cubicBezierTo (cx1, cy1, cx2, cy2, x, y);
}

/**
 * Draw a cubic bezier using specified control and destination points
 *
 * @param cx1,cy1 first control point
 * @param cx2,cy2 second control point
 * @param x,y destination point
 */
void ZincPath::cubicBezierTo (double cx1, double cy1,
                          double cx2, double cy2,
                          double x, double y)
{
  addPoint (cx1, cy1, true);
  addPoint (cx2, cy2, true);
  addPoint (x, y, false);
}

/**
 * Draw a quadratic bezier using specified control and destination point
 *
 * @param cx1,cy1 first control point
 * @param cx2,cy2 second control point
 * @param x,y destination point
 */
void ZincPath::quadraticBezierTo (double cx, double cy, double x, double y)
{
  // convert from a quadratic bezier to a cubic bezier
  // since that's what is supported by zinc
  /* [[x1, y1], [qx, qy, 'q'], [x2,y2]]
     cx1 = x1 + (qx - x1) * 2/3
     cy1 = y1 + (qy - y1) * 2/3
     cx2 = qx + (x2 - qx)/3
     cy2 = qy + (y2 - qy)/3
  */
  double cx1 = lastX + (cx - lastX) * 2/3;
  double cy1 = lastY + (cy - lastY) * 2/3;
  double cx2 = cx + (x - cx) / 3;
  double cy2 = cy + (y - cy) / 3;
  addPoint (cx1, cy1, true);
  addPoint (cx2, cy2, true);
  addPoint (x, y, false);
}

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
void ZincPath::arcTo (double rx, double ry, double xAxisRotation, bool largeArc,
                      bool sweepFlag, double x, double y)
{
  double sx, sy, start, arc;
  // convert to a centered representation
  convertFromSvg (lastX, lastY, rx, ry, xAxisRotation, largeArc, sweepFlag,
                  x, y, sx, sy, start, arc);
        
  // this is all taken from first case study for Intuikit

  /* convert to a curve representation
   * For a good approximation, we need 8 quadratic Bezier
   * to make a circle : the maximal angle is 45°
   */
  // local variables
  int segs;
  double segAngle, angle, angleMid;
  double cosphi, sinphi, tx, ty;
  double previousX, previousY;
  double bx, by, qx, qy;
  double cx1, cy1, cx2, cy2;

  //1) calculate segment counts
  segs = int (ceil (fabs (arc) / 45.));

  //let's create segments of the same angle
  //2) calculate this angle
  segAngle = arc / double(segs) * convertRatio;
  
  xAxisRotation = xAxisRotation * convertRatio;
  start = start * convertRatio;
  
  //3) Our fake starting point (relative to (x,y))
  // true start point is (x,y)
  sx = lastX - cos (start) * rx;
  sy = lastY - sin (start) * ry;  

  /* 4) calculate values that will be used for a rotation
   * of centre (x,y) and angle phi
   * the matrix is :
   *     cos(phi)   -sin(phi)  tx
   *     sin(phi)    cos(phi)  ty
   *     0            0        1
   */
  cosphi = cos (xAxisRotation);
  sinphi = sin (xAxisRotation);
  tx = (1. - cosphi) * lastX + sinphi * lastY;
  ty = (1. - cosphi) * lastY - sinphi * lastX;

  //5) save crrent values
  previousX = lastX;
  previousY = lastY;
  angle = start;

  //6) we already got the first point
  
  //7) calculate segments
  for (int i(0) ; i < segs ; i++)
  {
    //7.1) increment angle
    angle += segAngle;
    
    //7.2) calculate intermediate angle value
    angleMid = angle - segAngle / 2.;

    //7.3) calculate last point of the segment from center and rays
    bx = sx + cos (angle) * rx;
    by = sy + sin (angle) * ry;

    //7.4) calculate control point for the quadratic bezier curve
    qx = sx + cos (angleMid) * (rx / cos (segAngle / 2.));
    qy = sy + sin (angleMid) * (ry / cos (segAngle / 2.));

    //7.5) calculate control points for the equivalent bezier curve
    cx1 = previousX + (qx - previousX) * 2. / 3.;
    cy1 = previousY + (qy - previousY) * 2. / 3.;
    cx2 = qx + (bx - qx) / 3.;
    cy2 = qy + (by - qy) / 3.;

    //7.6) add points
    addPoint (cosphi * cx1 - sinphi * cy1 + tx,
              sinphi * cx1 + cosphi * cy1 + ty, true);
    addPoint (cosphi * cx2 - sinphi * cy2 + tx,
              sinphi * cx2 + cosphi * cy2 + ty, true);
    addPoint (cosphi * bx - sinphi * by + tx,
              sinphi * bx + cosphi * by + ty, false);

    //7.7) Save last point
    previousX = bx;
    previousY = by;
  }

}

/**
 * Return a table of Tcl_Obj* containing a liste of coords points
 *  It's up to the caller to delete the resulting table
 *
 * @return a Tcl_Obj* of type list
 */
Tcl_Obj* ZincPath::getTable ()
{
  return path;
}


