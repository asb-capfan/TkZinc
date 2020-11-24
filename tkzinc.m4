#
# Include the TEA standard macro set
#

builtin(include,tclconfig/tcl.m4)

#
# Zinc specific macros below.
#
#
# ALL the new macros here need to be modified to
# detect the various packages needed and to get their paths.
# Right now all this is statically defined in the macros.
#
#------------------------------------------------------------------------
# ZINC_ENABLE_GL --
#
#	Specify if openGL support should be used.
#	Code for managing a damage area can also be enabled.
#
# Arguments:
#	none
#	
# Results:
#
#	Adds the following arguments to configure:
#		--enable-gl=[yes,no,damage]
#
#	Defines the following vars:
#		GL_INCLUDES	OpenGL include files path
#		GL_LIBS		additional libraries needed for GL
#		LIBS		Modified to reflect the need of new
#				libraries
#		GL		Defined if GL support is enabled
#		GL_DAMAGE	Defined if damage support has been
#				requested
#
#------------------------------------------------------------------------

AC_DEFUN(ZINC_ENABLE_GL, [
     AC_MSG_CHECKING([for build with GL])
     AC_ARG_ENABLE(gl,
 		  [  --enable-gl             build with openGL support (yes,no,damage) [[no]]],
 		  [tcl_ok=$enableval], [tcl_ok=no])

     AC_ARG_WITH(glew-includes,
                 AC_HELP_STRING([--with-glew-includes],[directory containing glew includes]),
                                 GL_INCLUDES="${GL_INCLUDES} -I\"${withval}\"", GL_INCLUDES="$GL_INCLUDES -I/usr/local/include")
     AC_ARG_WITH(glew-lib,
                 AC_HELP_STRING([--with-glew-lib],[directory containing glew lib]),
                                GLEW_LIB="${withval}", GLEW_LIB="/usr/local/lib")
     if test "$tcl_ok" = "no"; then
 	GL_LIBS=
 	GL_INCLUDES=
 	AC_MSG_RESULT([no])
     else
	if test "${TEA_PLATFORM}" = "windows" ; then
	    GL_LIBS="${GLEW_LIB}/libglew32.a -lglu32 -lopengl32"
	elif test "${TEA_WINDOWINGSYSTEM}" = "aqua" ; then
	    GL_LIBS="-L${GLEW_LIB} -lGLEW -framework AGL -framework OpenGL"
 	    GL_INCLUDES="${GL_INCLUDES}"
         else
 	    GL_LIBS="-L${GLEW_LIB} -lGLEW -lGL"
 	    GL_INCLUDES="${GL_INCLUDES} -I/usr/include"
         fi

 	AC_DEFINE(GL)
 	if test "$tcl_ok" = "damage"; then
 	    AC_DEFINE(GL_DAMAGE)
         fi

 	LIBS="$LIBS $GL_LIBS"

 	if test "$tcl_ok" = "yes"; then
 	    AC_MSG_RESULT([yes (standard)])
 	else
 	    AC_MSG_RESULT([yes (with damage support)])
 	fi
     fi

     AC_SUBST(GL_LIBS)
     AC_SUBST(GL_INCLUDES)
])

#------------------------------------------------------------------------
# ZINC_ENABLE_ATC --
#
#	Specify if the Atc code should be included.
#
# Arguments:
#	none
#	
# Results:
#
#	Adds the following arguments to configure:
#		--enable-atc=[yes,no]
#
#	Defines the following vars:
#		ATC		Defined if ATC support is enabled
#
#------------------------------------------------------------------------

 AC_DEFUN(ZINC_ENABLE_ATC, [
     AC_MSG_CHECKING([for build with the ATC extensions])
     AC_ARG_ENABLE(atc,
 		  [  --enable-atc             build with ATC extensions [[yes]]],
 		  [tcl_ok=$enableval], [tcl_ok=yes])
     if test "$tcl_ok" = "no"; then
		 Atc_SOURCES=
 	AC_MSG_RESULT([no])
     else
 	AC_DEFINE(ATC)
        TEA_ADD_SOURCES([OverlapMan.c])
        TEA_ADD_SOURCES([Track.c])
        TEA_ADD_SOURCES([Reticle.c])
        TEA_ADD_SOURCES([Map.c])
        TEA_ADD_SOURCES([MapInfo.c])
 	AC_MSG_RESULT([yes])
     fi
  AC_SUBST(Atc_SOURCES)
])

#------------------------------------------------------------------------
# ZINC_ENABLE_SHAPE --
#
#	Specify if the X shape extension support should be included.
#
# Arguments:
#	none
#	
# Results:
#
#	Adds the following arguments to configure:
#		--enable-shape=[yes,no]
#
#	Defines the following vars:
#		SHAPE		Defined if shape support is enabled
#
#	Adjust LIBS to include the X extension library
#
#------------------------------------------------------------------------

AC_DEFUN(ZINC_ENABLE_SHAPE, [
     AC_MSG_CHECKING([for build with X shape support])
     AC_ARG_ENABLE(shape,
 		  [  --enable-shape          build with X shape support (if applicable) [[yes]]],
 		  [tcl_ok=$enableval], [tcl_ok=yes])
     if test "$tcl_ok" = "no"; then
 	AC_MSG_RESULT([no])
     else
         if test "${TEA_PLATFORM}" = "windows" ; then
 	    AC_MSG_RESULT([no (not available on windows)])
	elif test "${TEA_WINDOWINGSYSTEM}" = "aqua" ; then
 	    AC_MSG_RESULT([no (not available on windows)])
        else
 	    AC_DEFINE(SHAPE)
 	    AC_MSG_RESULT([yes])
	    LIBS="${LIBS} -lXext"
 	fi
     fi
])
