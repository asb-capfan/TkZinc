/**       Zinc.hpp
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
 *   Here is the declaration of the Zinc object
 *
 *      08/03/05
 *
 *      Contributors:
 *           Benoit Peccatte <peccatte@intuilab.com>
 *           David Thevenin <thevenin@intuilab.com>
 *
 */
#include "ZincTypes.hpp"
#include "ZincObjects.hpp"
#include "ZincPath.hpp"
#include "ZincExtern.hpp"
#include <tcl.h>

#ifndef ZINC_HEADER
#define ZINC_HEADER


/** Number of objects in the pool */
const int ZINC_POOL_COUNT   = 7;
/** maximum number of parameter in a zinc function */
const int  ZINC_PARAM_COUNT = 10;

/**Defaults zinc group */
const int DEFAULT_GROUP = 1;

/**
 * This class contains a zinc widget and members to create and modify items
 */
class Zinc
{
  friend class ZincPath;
  
public:
  Tcl_Obj *id;           ///< the id of this object
  WidgetObjCmd objCmd;   ///< the command associated with this object
  ClientData wi;         ///< the zinc object itself
  String tclCb;          ///< name of the binding callback
  int znId;              ///< the znCount at creation time
  String window;         ///< the window which contains the widget

  static int znCount;                   ///< count to create unique ids
  static Tcl_CmdInfo topCmdInfo;        ///< the command associated with toplevel
  static Tcl_CmdInfo zncCmdInfo;        ///< the command associated with zinc
  static Tcl_CmdInfo imgCmdInfo;        ///< the command associated with image
  static Tcl_CmdInfo fntCmdInfo;        ///< the command associated with font
  static Tcl_CmdInfo focCmdInfo;        ///< the command associated with fous
  static Tcl_CmdInfo bndCmdInfo;        ///< the command associated with bind
  static Tcl_Obj* pool[ZINC_POOL_COUNT];///< a pool of tclobj ready to be used
  static Tcl_Obj* p1[ZINC_PARAM_COUNT]; ///< table of pointeur use for parameters
  static Tcl_Obj* p2[ZINC_PARAM_COUNT]; ///< table of pointeur use for parameters

public:
  static Tcl_Interp *interp;            ///< the tcl interpreter

  /**
   * The public constructor
   *
   * @param renderingMode ZINC_BACKEND_X11 or ZINC_BACKEND_OPENGL
   */
  Zinc (int renderingMode);

  /**
   * The public destructor
   */
  ~Zinc ();

  /**
   * Change window title
   *
   * @param title the title string
   */
  void setTitle (String title);

/*****************************************
          WIDGET PROPERTIES
*****************************************/
  
  /**
   * Call zinc->configure ( -backcolor )
   *
   * @param value the backcolor to set
   */
  void setBackcolor (String value);

  /**
   * Call zinc->cget ( -backcolor )
   *
   * @return backcolor value
   */
  String getBackcolor ();

  /**
   * Call zinc->configure ( -forecolor )
   *
   * @param value the forecolor to set
   */
  void setForecolor (String value);

  /**
   * Call zinc->cget ( -forecolor )
   *
   * @return forecolor value
   */
  String getForecolor ();

  /**
   * Call zinc->configure ( -width )
   *
   * @param value the width to set
   */
  void setWidth (int value);

  /**
   * Call zinc->cget ( -width )
   *
   * @return width value
   */
  int getWidth ();

  /**
   * Call zinc->configure ( -height )
   *
   * @param value the height to set
   */
  void setHeight (int value);

  /**
   * Call zinc->cget ( -height )
   *
   * @return height value
   */
  int getHeight ();

  /**
   * Call zinc->configure ( -borderwidth )
   *
   * @param value the borderwidth to set
   */
  void setBorderwidth (int value);

  /**
   * Call zinc->cget ( -borderwidth )
   *
   * @return borderwidth value
   */
  int getBorderwidth ();

  /**
   * Call zinc->configure ( -font )
   *
   * @param value the font to set
   */
  void setFont (ZincFont* value);

  /**
   * Call zinc->cget ( -font )
   *
   * @return font value
   */
  ZincFont* getFont ();

/*****************************************
          WIDGET METHODS
*****************************************/

  /**
   * Get the bounding box of an item
   *
   * @param item the item to get bbox
   * @param bbox a table where we'll put the bounding box
   *             bbox[0] = x0, bbox[1] = y0, bbox[2] = xc, bbox[3] = yc
   */
  void bbox (ZincItem* item, double bbox[4]);

  /**
   * Get the bounding box of an item in its parent group
   *
   * @param item the item to get bbox in its parent group
   * @param bbox a table where we'll put the bounding box
   *             bbox[0] = x0, bbox[1] = y0, bbox[2] = xc, bbox[3] = yc
   */
  void relativeBbox (ZincItem* item, double bbox[4]);


  /**
   * Change the group of an item
   *
   * @param item the item to move
   * @param parentGroup new group for the item
   */
  void chggroup (ZincItem *item, ZincItem *parentGroup);

  /**
   * Clone an item
   *
   * @param item the item to clone
   * @return the cloned item
   */
  ZincItem* clone (ZincItem *item);

  /**
   * Get the number of contour of an item
   *
   * @return number of contour
   */
  int contour (ZincItem *item);

  /**
   * Set the contour of an item to the one of an other
   *
   * @param item the item on which we set the contour
   * @param flag the operation to do on the contour
   * @param reference the item to set contour from
   * @return the number of contour
   */
  int contour (ZincItem *item, itemOperator flag, ZincItem *reference);

  /**
   * Set the contour of an item
   *
   * @param item the item on which we set the contour
   * @param add true to add a path, false to remove
   * @param reference the new contour
   * @return the number of contour
   */
  int contour (ZincItem *item, bool add, ZincPath *contour);

  /**
   * Set or modify the coordinates of an item
   *
   * @param item the item to modify
   * @param contour new coords for the item
   * @param add true to add coords, false to replace
   * @param contourIndex the contour do modify
   * @param coordIndex the coordinate to modify (WARNING, path must be one
   *                   point if the is not the default)
   */
  void coords (ZincItem *item, ZincPath *contour, bool add,
               int contourIndex = -1, int coordIndex = -1);

  /**
   * Remove coords of an item
   *
   * @param item the item to modify
   * @param coordIndex the coordinate to rmove
   * @param contourIndex the contour on which we remove
   */
  void coordsRemove (ZincItem *item, int coordIndex, int contourIndex = -1);

  /**
   * Add a tag to an item
   *
   * @param item the item to add tag to
   * @param tag a tag to add
   */
  void addTag (ZincItem *item, String tag);

  /**
   * Remove a tag from an item
   *
   * @param item the item to remove tag from
   * @param tag a tag to remove (nothing to remove all tags)
   */  
  void dTag (ZincItem *item, String tag = String(""));

  /**
   * List all tags of an item
   * It's up to the caller to delete the resulting table and strings
   *
   * @param item the item to list tag from
   * @param lagList a pointer to a table of String containing tags
   * @return the number of tags
   */
  int getTags (ZincItem *item, String*** tagList);

  /**
   * Set the focus to an item
   *
   * @param item the item to set the focus to
   */
  void focus (ZincItem *item);

  /**
   * Tell if the name is a gradient name
   *
   * @param gname a gradient name
   * @return true if the name is a gradient name, false otherwise
   */
  bool isGname (String gname);

  /**
   * Create a named gradient
   *
   * @param gradient a gradient
   * @param gname a gradient name
   */
  void gname (String gradient, String gname);

  /**
   * Retreive the group of an item
   *
   * @param item the item to get the group from
   * @return the group
   */
  ZincItem* group (ZincItem *item);

  /**
   * Reorder items to lower one
   *
   * @param item the item to lower
   */
  void lower (ZincItem *item);

  /**
   * Reorder items to lower one
   *
   * @param item the item to lower
   * @param belowThis and item that will be over item
   */
  void lower (ZincItem *item, ZincItem *belowThis);

  /**
   * Reorder items to raise one
   *
   * @param item the item to raise
   */
  void raise (ZincItem *item);

  /**
   * Reorder items to raise one
   *
   * @param item the item to raise
   * @param aboveThis an item that will be under item
   */
  void raise (ZincItem *item, ZincItem *aboveThis);

  /**
   * Return the type of an item
   *
   * @param item an item
   * @return the type of the item
   */
   itemType type (ZincItem *item);

  /**
   * Create a Zinc Tag that can be used in place of any item
   *  for zinc functions that must be called using tagOrId
   *
   * @param tag the text of the tag
   * @return a tag item
   */
  ZincItem* createTag(String tag);

/*****************************************
          ITEMS MANIPULATION
*****************************************/
  /**
   * Suppress an item
   *
   * @param item the item to suppress
   */
  void itemRemove (ZincItem *item);

  /**
   * Create a group item
   *
   * @param parentGroup group where we'll put the new group, if NULL we create
   * in the defaults group
   * @return the group item
   */
  ZincItem *itemCreateGroup (ZincItem *parentGroup);

  /**
   * Create a rectangle item
   *
   * @param parentGroup group where we'll put it
   * @param x y width height the coordinates of the new rectangle
   * @return the rectangle item
   */
  ZincItem *itemCreateRectangle (ZincItem *parentGroup, double x, double y,
                                double width, double height);

  /**
   * Create an arc item
   *
   * @param parentGroup group where we'll put it
   * @param x y width height the coordinates of the new rectangle
   * @return the arc item
   */
  ZincItem *itemCreateArc (ZincItem *parentGroup, double x, double y,
                           double width, double height);

  /**
   * Create a text item
   *
   * @param parentGroup group where we'll put it
   * @return the text item
   */
  ZincItem *itemCreateText (ZincItem *parentGroup);

  /**
   * Create a curve item
   *
   * @param parentGroup group where we'll put it
   * @param path the path to display
   * @return the curve item
   */
  ZincItem *itemCreateCurve (ZincItem *parentGroup, ZincPath *path);

  /**
   * Create an icon item
   *
   * @param parentGroup group where we'll put it
   * @param image a zincImage to display
   * @return the icon item
   */
  ZincItem *itemCreateIcon (ZincItem *parentGroup, ZincImage* image);


/**************************************************
                    BINDING
**************************************************/

  /**
   * Bind a function to an event on the zinc widget
   *
   * @param eventSpecification tcl style event specicication
   * @param callBack the function which will be called back
   * @param userData data we will give back to the callback when called
   * @param add false to replace existing bind or true to add
   */
  void bind (String eventSpecification,
             ZincWidgetCallback callBack, void *userData, bool add = false);

  /**
   * Annulate a binding
   *
   * @param eventSpecification tcl style event specicication
   */
  void unbind (String eventSpecification);
  
  /**
   * Bind a function to an event on an item
   *
   * @param item the item on which to bind
   * @param eventSpecification tcl style event specicication
   * @param callBack the function which will be called back
   * @param userData data we will give back to the callback when called
   * @param add false to replace existing bind or true to add
   */
  void itemBind (ZincItem *item, String eventSpecification,
                 ZincItemCallback callBack, void *userData, bool add = false);

  /**
   * Annulate a binding
   *
   * @param item the item on which to unbind
   * @param eventSpecification tcl style event specicication
   */
  void itemUnbind (ZincItem *item, String eventSpecification);

/**************************************************
           TRANSFORMATION METHODS
**************************************************/

  /**
   * Translate the item
   *
   * @param item the item to which we apply the transform
   * @param dx dy translation vector
   */
  void itemTranslate (ZincItem * item, double dx, double dy);

  /**
   * Translate the item
   *
   * @param item the item to which we apply the transform
   * @param x y translation vector
   * @param absolute true if the translation is absolute
   */
  void itemTranslate (ZincItem * item, double x, double y, bool absolute);

  /**
   * Rotate an item
   *
   * @param item the item to which we apply the transform
   * @param angle the angle to rotate in radian
   */
  void itemRotate (ZincItem * item, double angle);

  /**
   * Rotate an item
   *
   * @param item the item to which we apply the transform
   * @param angle the angle to rotate in radian
   * @param x y the center of the rotation
   */
  void itemRotate (ZincItem * item, double angle, double x, double y);

  /**
   * Rotate an item
   *
   * @param item the item to which we apply the transform
   * @param angle the angle to rotate
   * @param degree true for an angle in degree, false for an angle in radians
   */
  void itemRotate (ZincItem * item, double angle, bool degree);

  /**
   * Rotate an item
   *
   * @param item the item to which we apply the transform
   * @param angle the angle to rotate in radian
   * @param x y the center of the rotation
   * @param degree true for an angle in degree, false for an angle in radians
   */
  void itemRotate (ZincItem * item, double angle, double x, double y,
                   bool degree);

  /**
   * Scale an item
   *
   * @param item the item to which we apply the transform
   * @param ax horizontal scale
   * @param ay vertical scale
   */
  void itemScale (ZincItem * item, double ax, double ay);

  /**
   * Scale an item using a specified center
   *
   * @param item the item to which we apply the transform
   * @param ax horizontal scale
   * @param ay vertical scale
   * @param cx cy center of the scale
   */
  void itemScale (ZincItem * item, double ax, double ay, double cx, double cy);

  
  /**
   * Skew an item
   *
   * @param item the item to which we apply the transform
   * @param sx horizontal skew
   * @param sy vertical skew
   */
  void itemSkew (ZincItem * item, double sx, double sy);

  /**
   * Skew an item horizontaly
   *
   * @param item the item to which we apply the transform
   * @param sx horizontal skew
   */
  void itemSkewX (ZincItem * item, double sx);

  /**
   * Skew an item verticaly
   *
   * @param item the item to which we apply the transform
   * @param sy vertical skew
   */
  void itemSkewY (ZincItem * item, double sy);

  /**
   * Reset all transformations associated with the item
   *
   * @param item the item to which we apply the transform
   */
  void itemResetTransformation (ZincItem * item);

  /**
   * Replace current transform by a matrix
   *
   * @param item the item to which we apply the transform
   * @param a,b,c,d,e,f the new transform matrix 
   */
  void itemSetTransformation (ZincItem * item,
                              double a, double b, double c,
                              double d, double e, double f);

  /**
   * Get current transform matrix
   *
   * @param item the item to which we apply the transform
   * @param a,b,c,d,e,f places where we'll put the transform matrix
   */
  void itemGetTransformation (ZincItem * item,
                              double *a, double *b, double *c,
                              double *d, double *e, double *f);

  /**
   * Multiply current transform by a matrix
   *
   * @param item the item to which we apply the transform
   * @param a,b,c,d,e,f the new transform matrix 
   */
  void itemMatrix (ZincItem * item,
                   double a, double b, double c,
                   double d, double e, double f);

/*******************************************************
             AUTOGENERATED METHODS (itemconfigure)
"code.hpp" in Tkzins/generic source from :
   ./gen.pl Arc.c Attrs.c Color.c Curve.c Draw.c  Group.c
        Image.c List.c Item.c Icon.c Rectangle.c tkZinc.c Text.c
*******************************************************/

  /**
   * Call zinc->itemconfigure ( -closed )
   * @param item the item to configure
   * @param value the closed to set
   */
  void itemSetClosed (ZincItem * item, bool value);

  /**
   * Call zinc->itemcget ( -closed )
   * @param item the item to get closed from
   * @return closed value
   */
  bool itemGetClosed (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -composealpha )
   * @param item the item to configure
   * @param value the composealpha to set
   */
  void itemSetComposealpha (ZincItem * item, bool value);

  /**
   * Call zinc->itemcget ( -composealpha )
   * @param item the item to get composealpha from
   * @return composealpha value
   */
  bool itemGetComposealpha (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -composerotation )
   * @param item the item to configure
   * @param value the composerotation to set
   */
  void itemSetComposerotation (ZincItem * item, bool value);

  /**
   * Call zinc->itemcget ( -composerotation )
   * @param item the item to get composerotation from
   * @return composerotation value
   */
  bool itemGetComposerotation (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -composescale )
   * @param item the item to configure
   * @param value the composescale to set
   */
  void itemSetComposescale (ZincItem * item, bool value);

  /**
   * Call zinc->itemcget ( -composescale )
   * @param item the item to get composescale from
   * @return composescale value
   */
  bool itemGetComposescale (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -extent )
   * @param item the item to configure
   * @param value the extent to set
   */
  void itemSetExtent (ZincItem * item, unsigned int value);

  /**
   * Call zinc->itemcget ( -extent )
   * @param item the item to get extent from
   * @return extent value
   */
  unsigned int itemGetExtent (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -fillcolor )
   * @param item the item to configure
   * @param value the fillcolor to set
   */
  void itemSetFillcolor (ZincItem * item, String value);

  /**
   * Call zinc->itemcget ( -fillcolor )
   * @param item the item to get fillcolor from
   * @return fillcolor value
   */
  String itemGetFillcolor (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -filled )
   * @param item the item to configure
   * @param value the filled to set
   */
  void itemSetFilled (ZincItem * item, bool value);

  /**
   * Call zinc->itemcget ( -filled )
   * @param item the item to get filled from
   * @return filled value
   */
  bool itemGetFilled (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -fillpattern )
   * @param item the item to configure
   * @param value the fillpattern to set
   */
  void itemSetFillpattern (ZincItem * item, ZincBitmap * value);

  /**
   * Call zinc->itemcget ( -fillpattern )
   * @param item the item to get fillpattern from
   * @return fillpattern value
   */
  ZincBitmap * itemGetFillpattern (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -linecolor )
   * @param item the item to configure
   * @param value the linecolor to set
   */
  void itemSetLinecolor (ZincItem * item, String value);

  /**
   * Call zinc->itemcget ( -linecolor )
   * @param item the item to get linecolor from
   * @return linecolor value
   */
  String itemGetLinecolor (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -linepattern )
   * @param item the item to configure
   * @param value the linepattern to set
   */
  void itemSetLinepattern (ZincItem * item, ZincBitmap * value);

  /**
   * Call zinc->itemcget ( -linepattern )
   * @param item the item to get linepattern from
   * @return linepattern value
   */
  ZincBitmap * itemGetLinepattern (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -linestyle )
   * @param item the item to configure
   * @param value the linestyle to set
   */
  void itemSetLinestyle (ZincItem * item, lineStyle value);

  /**
   * Call zinc->itemcget ( -linestyle )
   * @param item the item to get linestyle from
   * @return linestyle value
   */
  lineStyle itemGetLinestyle (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -linewidth )
   * @param item the item to configure
   * @param value the linewidth to set
   */
  void itemSetLinewidth (ZincItem * item, double value);

  /**
   * Call zinc->itemcget ( -linewidth )
   * @param item the item to get linewidth from
   * @return linewidth value
   */
  double itemGetLinewidth (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -pieslice )
   * @param item the item to configure
   * @param value the pieslice to set
   */
  void itemSetPieslice (ZincItem * item, bool value);

  /**
   * Call zinc->itemcget ( -pieslice )
   * @param item the item to get pieslice from
   * @return pieslice value
   */
  bool itemGetPieslice (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -priority )
   * @param item the item to configure
   * @param value the priority to set
   */
  void itemSetPriority (ZincItem * item, unsigned int value);

  /**
   * Call zinc->itemcget ( -priority )
   * @param item the item to get priority from
   * @return priority value
   */
  unsigned int itemGetPriority (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -sensitive )
   * @param item the item to configure
   * @param value the sensitive to set
   */
  void itemSetSensitive (ZincItem * item, bool value);

  /**
   * Call zinc->itemcget ( -sensitive )
   * @param item the item to get sensitive from
   * @return sensitive value
   */
  bool itemGetSensitive (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -startangle )
   * @param item the item to configure
   * @param value the startangle to set
   */
  void itemSetStartangle (ZincItem * item, unsigned int value);

  /**
   * Call zinc->itemcget ( -startangle )
   * @param item the item to get startangle from
   * @return startangle value
   */
  unsigned int itemGetStartangle (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -tile )
   * @param item the item to configure
   * @param value the tile to set
   */
  void itemSetTile (ZincItem * item, ZincBitmap * value);

  /**
   * Call zinc->itemcget ( -tile )
   * @param item the item to get tile from
   * @return tile value
   */
  ZincBitmap * itemGetTile (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -visible )
   * @param item the item to configure
   * @param value the visible to set
   */
  void itemSetVisible (ZincItem * item, bool value);

  /**
   * Call zinc->itemcget ( -visible )
   * @param item the item to get visible from
   * @return visible value
   */
  bool itemGetVisible (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -capstyle )
   * @param item the item to configure
   * @param value the capstyle to set
   */
  void itemSetCapstyle (ZincItem * item, capStyle value);

  /**
   * Call zinc->itemcget ( -capstyle )
   * @param item the item to get capstyle from
   * @return capstyle value
   */
  capStyle itemGetCapstyle (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -fillrule )
   * @param item the item to configure
   * @param value the fillrule to set
   */
  void itemSetFillrule (ZincItem * item, fillRule value);

  /**
   * Call zinc->itemcget ( -fillrule )
   * @param item the item to get fillrule from
   * @return fillrule value
   */
  fillRule itemGetFillrule (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -joinstyle )
   * @param item the item to configure
   * @param value the joinstyle to set
   */
  void itemSetJoinstyle (ZincItem * item, joinStyle value);

  /**
   * Call zinc->itemcget ( -joinstyle )
   * @param item the item to get joinstyle from
   * @return joinstyle value
   */
  joinStyle itemGetJoinstyle (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -relief )
   * @param item the item to configure
   * @param value the relief to set
   */
  void itemSetRelief (ZincItem * item, relief value);

  /**
   * Call zinc->itemcget ( -relief )
   * @param item the item to get relief from
   * @return relief value
   */
  relief itemGetRelief (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -smoothrelief )
   * @param item the item to configure
   * @param value the smoothrelief to set
   */
  void itemSetSmoothrelief (ZincItem * item, bool value);

  /**
   * Call zinc->itemcget ( -smoothrelief )
   * @param item the item to get smoothrelief from
   * @return smoothrelief value
   */
  bool itemGetSmoothrelief (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -alpha )
   * @param item the item to configure
   * @param value the alpha to set
   */
  void itemSetAlpha (ZincItem * item, unsigned int value);

  /**
   * Call zinc->itemcget ( -alpha )
   * @param item the item to get alpha from
   * @return alpha value
   */
  unsigned int itemGetAlpha (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -atomic )
   * @param item the item to configure
   * @param value the atomic to set
   */
  void itemSetAtomic (ZincItem * item, bool value);

  /**
   * Call zinc->itemcget ( -atomic )
   * @param item the item to get atomic from
   * @return atomic value
   */
  bool itemGetAtomic (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -clip )
   * @param item the item to configure
   * @param value the clip to set
   */
  void itemSetClip (ZincItem * item, ZincItem * value);

  /**
   * Call zinc->itemcget ( -clip )
   * @param item the item to get clip from
   * @return clip value
   */
  ZincItem * itemGetClip (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -anchor )
   * @param item the item to configure
   * @param value the anchor to set
   */
  void itemSetAnchor (ZincItem * item, anchor value);

  /**
   * Call zinc->itemcget ( -anchor )
   * @param item the item to get anchor from
   * @return anchor value
   */
  anchor itemGetAnchor (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -color )
   * @param item the item to configure
   * @param value the color to set
   */
  void itemSetColor (ZincItem * item, String value);

  /**
   * Call zinc->itemcget ( -color )
   * @param item the item to get color from
   * @return color value
   */
  String itemGetColor (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -connecteditem )
   * @param item the item to configure
   * @param value the connecteditem to set
   */
  void itemSetConnecteditem (ZincItem * item, ZincItem * value);

  /**
   * Call zinc->itemcget ( -connecteditem )
   * @param item the item to get connecteditem from
   * @return connecteditem value
   */
  ZincItem * itemGetConnecteditem (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -connectionanchor )
   * @param item the item to configure
   * @param value the connectionanchor to set
   */
  void itemSetConnectionanchor (ZincItem * item, anchor value);

  /**
   * Call zinc->itemcget ( -connectionanchor )
   * @param item the item to get connectionanchor from
   * @return connectionanchor value
   */
  anchor itemGetConnectionanchor (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -image )
   * @param item the item to configure
   * @param value the image to set
   */
  void itemSetImage (ZincItem * item, ZincImage * value);

  /**
   * Call zinc->itemcget ( -image )
   * @param item the item to get image from
   * @return image value
   */
  ZincImage * itemGetImage (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -mask )
   * @param item the item to configure
   * @param value the mask to set
   */
  void itemSetMask (ZincItem * item, ZincBitmap * value);

  /**
   * Call zinc->itemcget ( -mask )
   * @param item the item to get mask from
   * @return mask value
   */
  ZincBitmap * itemGetMask (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -alignment )
   * @param item the item to configure
   * @param value the alignment to set
   */
  void itemSetAlignment (ZincItem * item, alignment value);

  /**
   * Call zinc->itemcget ( -alignment )
   * @param item the item to get alignment from
   * @return alignment value
   */
  alignment itemGetAlignment (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -font )
   * @param item the item to configure
   * @param value the font to set
   */
  void itemSetFont (ZincItem * item, ZincFont * value);

  /**
   * Call zinc->itemcget ( -font )
   * @param item the item to get font from
   * @return font value
   */
  ZincFont * itemGetFont (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -overstriked )
   * @param item the item to configure
   * @param value the overstriked to set
   */
  void itemSetOverstriked (ZincItem * item, bool value);

  /**
   * Call zinc->itemcget ( -overstriked )
   * @param item the item to get overstriked from
   * @return overstriked value
   */
  bool itemGetOverstriked (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -spacing )
   * @param item the item to configure
   * @param value the spacing to set
   */
  void itemSetSpacing (ZincItem * item, short value);

  /**
   * Call zinc->itemcget ( -spacing )
   * @param item the item to get spacing from
   * @return spacing value
   */
  short itemGetSpacing (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -text )
   * @param item the item to configure
   * @param value the text to set
   */
  void itemSetText (ZincItem * item, String value);

  /**
   * Call zinc->itemcget ( -text )
   * @param item the item to get text from
   * @return text value
   */
  String itemGetText (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -underlined )
   * @param item the item to configure
   * @param value the underlined to set
   */
  void itemSetUnderlined (ZincItem * item, bool value);

  /**
   * Call zinc->itemcget ( -underlined )
   * @param item the item to get underlined from
   * @return underlined value
   */
  bool itemGetUnderlined (ZincItem * item);

  /**
   * Call zinc->itemconfigure ( -width )
   * @param item the item to configure
   * @param value the width to set
   */
  void itemSetWidth (ZincItem * item, unsigned short value);

  /**
   * Call zinc->itemcget ( -width )
   * @param item the item to get width from
   * @return width value
   */
  unsigned short itemGetWidth (ZincItem * item);


/*******************************************************
             END OF AUTOGENERATED METHODS
*******************************************************/

  /**
   * Call zinc->itemconfigure ( -firstend )
   *
   * @param item the item to set firstend to
   * @param a,b,c values used to set end
   */
  void itemSetFirstend (ZincItem * item, double a, double b, double c);
  
  /**
   * Call zinc->itemcget ( -firstend )
   *
   * @param item the item to get firstend from
   * @param a,b,c values used to sedwhere we'll put end
   */
  void itemGetFirstend (ZincItem * item, double *a, double *b, double *c);

  /**
   * Call zinc->itemconfigure ( -lastend )
   *
   * @param item the item to set lastend to
   * @param a,b,c values used to set end
   */
  void itemSetLastend (ZincItem * item, double a, double b, double c);

  /**
   * Call zinc->itemcget ( -lastend )
   *
   * @param item the item to get lastend from
   * @param a,b,c values used to sedwhere we'll put end
   */
  void itemGetLastend (ZincItem * item, double *a, double *b, double *c);

  /**
   * Call zinc->itemconfigure ( -position )
   *
   * @param item the item to get width fromset position to
   * @param x,y position
   */
  void itemSetPosition (ZincItem * item, double x, double y);

  /**
   * Call zinc->itemcget ( -position )
   *
   * @param item the item to get position from
   * @param x,y position
   */
  void itemGetPosition (ZincItem * item, double *x, double *y);

  /**
   * Create an image object from a file
   *
   * @param image the image reference (a file name)
   */
  ZincImage* createImageFromFile (String image);

  /**
   * Create an image object using base64 data
   *
   * @param image the image reference (a base64 String or binary data)
   */
  ZincImage* createImageFromData (String image);

  /**
   * Create a bitmap object from a file
   *
   * @param image the bitmap reference (a file name)
   */
  ZincBitmap* createBitmapFromFile (String image);

  /**
   * Create a bitmap object base64 data
   *
   * @param image the bitmap reference (a base64 String or binary data)
   */
  ZincBitmap* createBitmapFromData (String image);

  /**
   * Create a bitmap object using a predefined name
   *
   * @param image the bitmap reference (a name)
   */
  ZincBitmap* createBitmapFromName (String image);

  /**
   * Create an image object
   *
   * @param width Width of image
   * @param height Height of image
   * @param aggBuffer An AGG buffer
   */
  ZincImage* createImageFromAGGBuffer (int width, int height, unsigned char *aggBuffer);


  /**
   * Create a font object
   *
   * @param family the font mamily
   * @param size if a positive number, it is in points, if a negative number,
   *   its absolute value is a size in pixels.
   * @param bold 1 for a bold font, 0 for a normal font, -1 for unspecified
   * @param italic 1 an italic font, 0 for a roman font, -1 for unspecified
   * @param underline 1 for an underlined, 0 for a normal font, -1 for
   *    unspecified
   * @param overstrike 1 for an overstriked font, 0 for a normal font, -1 for unspecified
   */
  ZincFont* createFont (String family, int size, int bold = -1,
                        int italic = -1, int underline = -1,
                        int overstrike = -1);
 
  /**
   * Get font ascent
   *
   * @param font the font
   * @return the font ascent
   */
  int getFontAscent (ZincFont* font);

  /**
   * Get Image width
   *
   * @param ZincImage the image to get width from
   * @return the width of the image
   */
  int getImageWidth (ZincImage *image);
  
  /**
   * Get Image height
   *
   * @param ZincImage the image to get height from
   * @return the height of the image
   */
  int getImageHeight (ZincImage *image);
  
/*******************************************************
                STATIC PROCEDURES
*******************************************************/

  /**
   * Loads the zinc library and initialize tcl and tk
   *
   * @param argv0 the name of the execytable as passed in argv[0]
   */
  static void loadZinc (char *argv0) throw (ZincException);

  /**
   * Run tk mainloop and returns when there is no more Tk window
   */
  static void zincMainLoop ();

/*******************************************************
               errors management
*******************************************************/
  /**
   * This is inline because it is called frequently and needs to be optimized
   * Use this when you need to call a function that can return a TCL error code.
   *
   * @param fct the full function call
   * @param msg the error message to throw in case of error
   */ 
  static void z_tcl_call (int result, char* p_msg) throw (ZincException);

  /**
   * This is a inline because it is called frequently and needs to be optimized
   * Use this to call the zinObjectCommand fuction. The call is made using the
   * pre allocated table p1, it must contain Tcl_Obj thar are parameters to
   * the zinObjectCommand function. A parameter indicate how many parameters
   * are passed to the zinObjectCommand function.
   *
   * @param count the number of parameters in p1
   * @param msg the error message to throw in case of error
   */ 
  void z_command (int count, char* p_msg) throw (ZincException);

};

#endif
