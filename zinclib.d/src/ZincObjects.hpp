/**       ZincObjects.hpp
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
#include "ZincTypes.hpp"

#include <exception>
#include <string>
#include <tcl.h>

#ifndef ZINC_OBJECTS
#define ZINC_OBJECTS

// Object representing a zinc item
class ZincItem
{
protected:
  /**
   * The protected default constructor
   */
  ZincItem ();

public:
  Tcl_Obj *object;  //the object we are storing

  /**
   * The public constructor
   *
   * @param obj the object we want to store
   */
  ZincItem (Tcl_Obj *obj);

  /**
   * The public destructor
   */
  virtual ~ZincItem ();
};

// Object representing a zinc image
class ZincImage : public ZincItem
{
  /**
   * The private constructor
   */
  ZincImage ();

  bool madeFromInternal;

public:
  /**
   * The public constructor (redefine the inherited one)
   *
   * @param obj the object we want to store
   */
  ZincImage (Tcl_Obj *obj);

  /**
   * The public constructor (redefine the inherited one)
   *
   * @param obj the object we want to store
   */
  ZincImage (Tcl_Obj *obj, bool internal);

  /**
   * The public destructor
   */
  virtual ~ZincImage ();
};

// Object representing a zinc bitmap
class ZincBitmap : public ZincItem
{
  /**
   * The private constructor
   */
  ZincBitmap ();

  bool madeFromInternal;

public:
  /**
   * The public constructor (redefine the inherited one)
   *
   * @param obj the object we want to store
   */
  ZincBitmap (Tcl_Obj *obj);

  /**
   * The public constructor (redefine the inherited one)
   *
   * @param obj the object we want to store
   */
  ZincBitmap (Tcl_Obj *obj, bool internal);

  /**
   * The public constructor (redefine the inherited one)
   *
   * @param name the name of a predefined bitmap
   */
  ZincBitmap (String name);
  
  /**
   * The public destructor
   */
  virtual ~ZincBitmap ();
};

// Object representing a zinc font
class ZincFont
{
  /**
   * The public default constructor
   */
  ZincFont ();

public:
  String name;

  /**
   * The public constructor
   */
  ZincFont (const char *font);

};

/**
 * Exceptions that are throwed by zinclib
 */
class ZincException : public std::exception
{

private:
  String msg;   // the exception message
  String file;  // file where exception have been caught
  int line;     // line where exception have been caught

public:
  /**
   * A public constructor with a String parameter
   *
   * @param msg the error message
   */
  ZincException (String msg, char *file, int lineNo);

  /**
   * Copy constructor
   *
   * @param exception the original exception
   */
  ZincException (const ZincException &exception);

  /**
   * Public destructor
   */
  virtual ~ZincException () throw();

  /**
   * Retreive the exception message
   *
   * @return the message
   */
  const char* what () const throw ();
};

#endif
