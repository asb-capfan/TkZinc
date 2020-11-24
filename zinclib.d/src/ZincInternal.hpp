/**       ZincInternal.hpp
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
 *   Here we defines macros and constants that are only used within Zinclib code
 *
 *      08/03/05
 *
 *      Contributors:
 *           Benoit Peccatte <peccatte@intuilab.com>
 *           David Thevenin <thevenin@intuilab.com>
 *
 */

#include <string>
#include <stdio.h>
#ifdef _WIN32
#define snprintf _snprintf
#endif

#include "ZincObjects.hpp"
#ifndef BAZAR
#define BAZAR

#define MAX_NUM_LENGTH 32

// The base name of the TCL function that serve for callbacks
#define Z_TCLCB "zincTclCb"

/**
 * These are macro for shortness and readability of code.
 * They take one Tcl_Obj from the pool and put one value into it. This object
 * is returned. They all have the same signature.
 *
 * @param no the id of the Tcl_Obj to take within the pool (max is
 *    ZINC_POOL_COUNT-1)
 * @param value the value to put in the extracted object
 * @return the object from the pool
 */
// make a boolean object
#define Z_BOO_POOL(no, value) ( Tcl_SetBooleanObj (pool[no], value), pool[no] )
// make an integer object
#define Z_INT_POOL(no, value) ( Tcl_SetIntObj (pool[no], value), pool[no] )
// make a double object
#define Z_DBL_POOL(no, value) ( Tcl_SetDoubleObj (pool[no], value), pool[no] )
// make a string object
#define Z_STR_POOL(no, value, length) ( Tcl_SetStringObj (pool[no],       \
                                                          value, length), \
                                        pool[no] )

/**
 * Make a list object
 *
 * @param no the id of the Tcl_Obj to take within the pool
 * @param value a table of pointer to Tcl_Obj to put in the list
 * @param size the number objects in the table
 * @return the list object from the pool
 */
#define Z_LST_POOL(no, value, size) ( Tcl_SetListObj (pool[no], size, value),\
                                      pool[no] )

/**
 * Clear a list object. Tcl_Obj used in a list object have a refcount
 * incremented and as such can't be reused for anything else. To free those
 * object you need to clean the list object after use.
 *
 * @param no the id of a Tcl_Obj within the pool which contains a list to
 * clear
 */
#define Z_CLEANLIST(no) Tcl_SetIntObj (pool[no], 0)


/**
 * Create a constant Tcl_Obj that can be reused as a parameter later
 *
 * @parameter string define the name and the value ov the object
 */
//create an option object (value prefixed by '-')
#define Z_DEFINE_ZOPT(string) Tcl_Obj* ZOPT_##string = Tcl_NewStringObj ("-" #string, -1);
//create a function object
#define Z_DEFINE_ZFCT(string) Tcl_Obj* ZFCT_##string = Tcl_NewStringObj (#string, -1);
//create an item object
#define Z_DEFINE_ZITM(string) Tcl_Obj* ZITM_##string = Tcl_NewStringObj (#string, -1);

/**
 * Macro to return a parentGroup Tcl_Obj. If a NULL is group given, it returns
 * the default one.
 *
 * @param parentGroup the parent group to take
 */
#define Z_PARENTGROUP(parentGroup)  \
  ( (parentGroup != NULL) ? parentGroup->object : DEFAULT_GROUP_OBJ );

/**
 * Convert an integer to a string
 *
 * @param integer the integer to convert
 */
inline std::string itos (int integer)
{
  char tmp[MAX_NUM_LENGTH];
  // use standard function to convert
  if (snprintf (tmp, MAX_NUM_LENGTH, "%d", integer) < 0)
  {
    throw ZincException ("Error converting integer", __FILE__, __LINE__ );
  }
  return std::string (tmp);
}

/**
 * Convert a long to a string
 *
 * @param l the long to convert
 */
inline std::string ltos (long l)
{
  char tmp[MAX_NUM_LENGTH];
  // use standard function to convert
  if (snprintf (tmp, MAX_NUM_LENGTH, "%ld", l) < 0)
  {
    throw ZincException ("Error converting long", __FILE__, __LINE__ );
  }
  return std::string (tmp);
}

/**
 * Convert a double to a string
 *
 * @param double the integer to convert
 */
inline std::string dtos (double d)
{
  char tmp[MAX_NUM_LENGTH];
  // use standard function to convert
  if (snprintf (tmp, MAX_NUM_LENGTH, "%f", d) < 0)
  {
    throw ZincException ("Error converting double", __FILE__, __LINE__ );
  }
  return std::string (tmp);
}

/**
 * How To call Zinc or Tcl functions:
 *
 * All arguments of the function are Tcl_Obj. To accelerate their call, there
 * is a pool of preconstructed Tcl_Obj and some often used constant Tcl_Obj.
 * p1 and p2 are tables of pointers to be used for arguments.
 * Fill p1 using either predefined objects like ZITM_* or a pool objet that
 * you can fill with the value you want.
 *  Ex : p1[1] = ZFCT_add;
 * Macros have been defined to fill and use a pool object
 *  Ex : p1[2] = Z_INT_POOL(1, 200);
 * Do not use twice the same pool index for the same function call.
 * p2 is used to construct and argument which is a list of Tcl_Obj.
 * To call the function use Z_TCL_CALL which automaticly handle error return
 * codes or Z_COMMAND to call a Zinc command which handle all arguments too.
 */
#endif
