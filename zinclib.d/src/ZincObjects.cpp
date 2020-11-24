/**       ZincObjects.cpp
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
 *   Here we defines classes that are items in zinc
 *
 *      08/03/05
 *
 *      Contributors:
 *           Benoit Peccatte <peccatte@intuilab.com>
 *           David Thevenin <thevenin@intuilab.com>
 *
 */
#include "ZincInternal.hpp"
#include "ZincObjects.hpp"
#include "Zinc.hpp"


/**
 * The protected default constructor
 */
ZincItem::ZincItem ()
{ }

/**
 * The public  constructor
 *
 * @param obj the object we want to store
 */
ZincItem::ZincItem (Tcl_Obj *obj)
  : object(obj)
{
  // manage refcount so that the tcl_obj can't be freed
  Tcl_IncrRefCount (object);
}

/**
 * The public destructor
 */
ZincItem::~ZincItem ()
{
  // dercrement refcount to free tcl_obj
  Tcl_DecrRefCount (object);
}

/**
 * The public  constructor
 *
 * @param obj the object we want to store
 */
ZincImage::ZincImage (Tcl_Obj *obj)
  : ZincItem (obj), madeFromInternal (false)
{ }

/**
 * The public  constructor
 *
 * @param obj the object we want to store
 */
ZincImage::ZincImage (Tcl_Obj *obj, bool internal)
  : ZincItem (obj), madeFromInternal (internal)
{ }

/**
 * The public destructor
 */
ZincImage::~ZincImage ()
{
  // do not delete returned values
  if (madeFromInternal)
    return;

  // delete using string commands
  const char* para[5];
  para[0] = "image";
  para[1] = "delete";
  para[2] = Tcl_GetString(object);

  // call the function with 3 arguments
  int res = (*Zinc::imgCmdInfo.proc)(Zinc::imgCmdInfo.clientData,
                                     Zinc::interp, 3, para);
  Zinc::z_tcl_call (res, "delete ZincImage Failed : ");
}

/**
 * The public constructor (redefine the inherited one)
 *
 * @param obj the object we want to store
 */
ZincBitmap::ZincBitmap (Tcl_Obj *obj)
  : ZincItem (obj), madeFromInternal (false)
{ }

/**
 * The public constructor (redefine the inherited one)
 *
 * @param obj the object we want to store
 */
ZincBitmap::ZincBitmap (Tcl_Obj *obj, bool internal)
  : ZincItem (obj), madeFromInternal (internal)
{ }

/**
 * The public constructor (redefine the inherited one)
 *
 * @param name the name of a predefined bitmap
 */
ZincBitmap::ZincBitmap (String name)
  : madeFromInternal (true)
{
  object = Tcl_NewStringObj (name.c_str(), name.length ());
  Tcl_IncrRefCount (object);
}

/**
 * The public destructor
 */
ZincBitmap::~ZincBitmap ()
{
  // do not delete Zinc default bitmaps or returned values
  if (madeFromInternal)
    return;

  // delete using string commands
  const char* para[5];
  para[0] = "image";
  para[1] = "delete";
  para[2] = Tcl_GetString(object);

  // call the function with 3 arguments
  int res = (*Zinc::imgCmdInfo.proc)(Zinc::imgCmdInfo.clientData,
                                     Zinc::interp, 3, para);
  Zinc::z_tcl_call (res, "delete ZincBitmap Failed : ");
}

/**
 * The public constructor
 */
ZincFont::ZincFont (const char *font)
  : name (String (font))
{ }

/**
 * A public constructor with a String parameter
 *
 * @param msg the error message
 */
ZincException::ZincException (String p_msg, char *p_file, int p_lineNo)
  : msg (p_msg), file(p_file), line(p_lineNo)
{ }

/**
 * Copy constructor
 *
 * @param exception the original exception
 */
ZincException::ZincException (const ZincException &e)
  : msg (e.msg), file(e.file), line(e.line)
{ }

/**
 * Public destructor
 */
ZincException::~ZincException () throw()
{ }

/**
 * Retreive the exception message
 *
 * @return the message
 */
const char* ZincException::what () const throw ()
{
  String result = "Zinc Exception : ";
  result += msg + " file " + file + ", line " + itos  (line);
  return result.c_str ();
}
