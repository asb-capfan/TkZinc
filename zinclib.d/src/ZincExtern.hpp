/**       ZincExtern.hpp
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
 *   Here we create TkZinc library headers since they don't exist
 *
 *      08/03/05
 *
 *      Contributors:
 *           Benoit Peccatte <peccatte@intuilab.com>
 *
 */
#include <tcl.h>

#ifndef ZINC_EXTERN
#define ZINC_EXTERN


// those are function have been created within a C compiler
extern "C"
{

  //The TkZinc function that initialises tkzinc
  int Tkzinc_Init(Tcl_Interp *interp);

  //The TkZinc function that creates a zinc object
  int ZincObjCmd(ClientData client_data,    // Main window associated with interpreter.
                 Tcl_Interp *interp,        // Current interpreter. 
                 int        argc,           // Number of arguments.
                 Tcl_Obj   *CONST  args[]); // Argument objects.

  //The TkZinc function that is called by tcl when calling ".zinc fct ..."
#ifdef _WIN32
  typedef int (__cdecl *WidgetObjCmd)
                           (ClientData client_data,   // Information about the widget.
                            Tcl_Interp *interp,       // Current interpreter.
                            int        argc,          // Number of arguments.
                            Tcl_Obj    *CONST args[]); // Argument objects.
#else
  typedef int (*WidgetObjCmd)
                   (ClientData client_data,   // Information about the widget.
                    Tcl_Interp *interp,       // Current interpreter.
                    int        argc,          // Number of arguments.
                    Tcl_Obj    *CONST args[]) // Argument objects.
          __attribute__((cdecl));
#endif
}

#endif

