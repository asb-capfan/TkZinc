/**       ZincTypes.hpp
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
 *   Here we defines types and constants that may be usefull for a zinclib user
 *
 *      08/03/05
 *
 *      Contributors:
 *           Benoit Peccatte <peccatte@intuilab.com>
 *
 */
#include <string>

#ifndef ZINC_TYPES
#define ZINC_TYPES

typedef std::string String;

/**********************************
   Predeclaration of Zinc types
**********************************/
class Zinc;
class ZincPath;
class ZincItem;
class ZincImage;
class ZincFont;
struct ZincEvent;

/*******************************************************
     Signature to use when binding with a callback
*******************************************************/
typedef void (*ZincItemCallback)
             (Zinc *zinc,        // Information about the widget.
              ZincItem *item,    // the item being evented
              ZincEvent *event,  // event information
              void *userData);   // user data provided with bind

typedef void (*ZincWidgetCallback)
             (Zinc *zinc,        // Information about the widget.
              ZincEvent *event,  // event information
              void *userData);   // user data provided with bind


/***********************************
       Library constants
***********************************/

// Rendering model
const int ZINC_BACKEND_X11 = 0;
const int ZINC_BACKEND_OPENGL = 1;


/***********************************
       Library enums
***********************************/

//Styles for line items
typedef enum
{
  lineStyle_simple = 0,  
  lineStyle_dashed,
  lineStyle_mixed,
  lineStyle_dotted
} lineStyle;

//Styles for line cap
typedef enum
{
  capStyle_butt = 0,
  capStyle_projecting,
  capStyle_round
} capStyle;

//List of fill rules
typedef enum
{
  fillRule_odd = 0 ,
  fillRule_nonzero,
  fillRule_positive,
  fillRule_negative,
  fillRule_abs_geq_2
} fillRule;

//list of join style
typedef enum
{
  joinStyle_bevel = 0,
  joinStyle_miter,
  joinStyle_round
} joinStyle;

//list of reliefs
typedef enum
{
  relief_flat = 0,
  relief_raised,
  relief_sunken,
  relief_ridge,
  relief_groove,
  relief_roundraised,
  relief_roundsunken,
  relief_roundridge,
  relief_roundgroove,
  relief_raisedrule,
  relief_sunkenrule
} relief;

//List of alignments
typedef enum
{
  alignment_left = 0,
  alignment_right,
  alignment_center
} alignment;

//list of anchors
typedef enum
{
  anchor_nw = 0,
  anchor_n,
  anchor_ne,
  anchor_e,
  anchor_se,
  anchor_s,
  anchor_sw,
  anchor_w,
  anchor_center
} anchor;

//actions to take when calling contour
typedef enum
{
  item_add_clockwise,
  item_add_counterclockwise,
  item_remove
} itemOperator;

//list of possible itemtypes
typedef enum
{
  item_group,
  item_arc,
  item_text,
  item_rectangle,
  item_curve,
  item_icon
} itemType;

//informations contained in an event
struct ZincEvent
{
  int x,y;  // pointer position                none -> 0
  int k;    // keycode                         none -> 0
  long t;   // timestamp                       none -> 0
  int w,h;  // window width,heigth             none -> 0
  int X,Y;  // pointer position within display none -> 0
  int b;    // button pressed                  none -> 0
  String K; // keysym                          none -> "??"
};



#endif
