#!/usr/bin/perl

#   This software is the property of IntuiLab SA, France.
#   All rights reserved.
#
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions
#   are met:
#   1. Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#   2. Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#   3. The name of the author may not be used to endorse or promote products
#      derived from this software without specific prior written permission.
# 
#   THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
#   IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
#   OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#   IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
#   INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
#   NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#   THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


$a="";

$res = "";
$undone = "";
$enum = "";
$enum2 = "";
open CODE,">code.cpp";
open HPP,">code.hpp";
while (<>)
{
  if( /{ ZN_CONFIG_(\w+), "-(\w+)"/ )
  {
	if(defined $opt{$2})
	{
	   next if($opt{$2} == $1);
	   die("ERROR different TYPE\n");
	}
	$opt{$2} = $1;
        if( $1 eq "BOOL" )
        { $e = 0; $t = "bool"; $T = "BOO"; }
        elsif( $1 eq "FLAG" )
        { $e = 0; $t = "int"; $T= "INT"; }
	elsif( $1 eq "GRADIENT" )
	{ $e = 0; $t = "String"; $T= "STR"; }
	elsif( $1 eq "UINT" )
	{ $e = 0; $t = "unsigned int"; $T= "INT"; }
	elsif( $1 eq "INT" )
	{ $e = 0; $t = "int"; $T= "INT"; }
	elsif( $1 eq "LINE_STYLE" )
	{ $e = 1; $t = "ineStyle"; $T="lineStyles"; }
	elsif( $1 eq "DIM" )
	{ $e = 0; $t = "double"; $T= "DBL"; }
	elsif( $1 eq "ANGLE" )
	{ $e = 0; $t = "unsigned int"; $T= "INT"; }
	elsif( $1 eq "PRI" )
	{ $e = 0; $t = "unsigned int"; $T= "INT"; }
	elsif( $1 eq "RELIEF" )
	{ $e = 1; $t = "relief"; $T="reliefs"; }
	elsif( $1 eq "ALPHA" )
	{ $e = 0; $t = "unsigned int"; $T= "INT"; }
	elsif( $1 eq "TEXT" )
	{ $e = 0; $t = "String"; $T= "STR"; }
	elsif( $1 eq "ALIGNMENT" )
	{ $e = 1; $t = "alignment"; $T="alignments"; }
	elsif( $1 eq "USHORT" )
	{ $e = 0; $t = "unsigned short"; $T= "INT"; }
	elsif( $1 eq "SHORT" )
	{ $e = 0; $t = "short"; $T= "INT"; }
	elsif( $1 eq "STRING" )
	{ $e = 0; $t = "String"; $T= "STR"; }
	elsif( $1 eq "FONT" )
	{ $e = 0; $t = "ZincFont *"; $T= "PSTR"; }
	elsif( $1 eq "ITEM" )
	{ $e = 0; $t = "ZincItem *"; $T= "PTR"; }
	elsif( $1 eq "BITMAP" )
	{ $e = 0; $t = "ZincBitmap *"; $T= "PTR"; }
	elsif( $1 eq "IMAGE" )
	{ $e = 0; $t = "ZincImage *"; $T= "PTR"; }
	elsif( $1 eq "ANCHOR" )
	{ $e = 1; $t = "anchor"; $T="anchors"; }
	elsif( $1 eq "LINE_SHAPE" )
	{ $e = 1; $t = "lineShape"; $T="lineShapes"; }
	elsif( $1 eq "CAP_STYLE" )
	{ $e = 1; $t = "capStyle"; $T="capStyles"; }
	elsif( $1 eq "JOIN_STYLE" )
	{ $e = 1; $t = "joinStyle"; $T="joinStyles"; }
	elsif( $1 eq "FILL_RULE" )
	{ $e = 1; $t = "fillRule"; $T="fillRules"; }
	elsif( $1 eq "EDGE_LIST" )
	{ $e = 1; $t = "edgeList"; $T="edgeLists"; }
	else
	{
	   $undone .= "$2: $1\n";
	   next;
        }

	$t2 = $2;
	substr($t2,0,1) =~ tr/[a-z]/[A-Z]/;
	if($e==1)
	{
	  if($en{$1}!=1)
	  {
	    $enum .= "$t { t_$T };\n";
	    $enum2.= "const char* $T"."Strings [1] = { \"t$T\" };\n";
	    $enum2.= "Tcl_Obj* $T [1] = { Tcl_NewStringObj (\"t$T\", -1) };\n";
	    $en{$1}=1;
	  }
	}
        print HPP "  /**\n";
        print HPP "   * Call zinc->itemconfigure ( -$2 )\n";
	print HPP "   * \@param item the item to configure\n";
	print HPP "   * \@param value the $2 to set\n";
        print HPP "   */\n";
	print HPP "  void itemSet$t2 (ZincItem * item, $t value);\n\n";
        print HPP "  /**\n";
        print HPP "   * Call zinc->itemcget ( -$2 )\n";
	print HPP "   * \@param item the item to get $2 from\n";
	print HPP "   * \@return $2 value\n";
        print HPP "   */\n";
	if ($t eq "String")
	{
	  print HPP "  String itemGet$t2 (ZincItem * item);\n\n";
	}
	else
	{
	  print HPP "  $t itemGet$t2 (ZincItem * item);\n\n";
	}
	$res .= "Z_DEFINE_ZOPT ($2);   //the \"-$2\" option\n";
	
        print CODE "/**\n";
        print CODE " * Call zinc->itemconfigure ( -$2 )\n";
	print CODE " *\n";
	print CODE " * \@param item the item to configure\n";
	print CODE " * \@param value the $2 to set\n";
        print CODE " */\n";
        print CODE "void Zinc::itemSet$t2 (ZincItem * item, $t value)\n";
        print CODE "{\n";
	print CODE "  //prepare arguments : .zinc itemconfigure item attribute value\n";
        print CODE "  p1[0] = id;\n";
	print CODE "  p1[1] = ZFCT_itemconfigure;\n";
	print CODE "  p1[2] = item->object;\n";
        print CODE "  p1[3] = ZOPT_$2;\n";
	if( $e==1 )
	{
	   print CODE "  p1[4] = ".$T."[value];\n";
	}
	elsif ($T eq "PTR")
	{
	  print CODE "  p1[4] = value->object;\n";
	}
	elsif ($T eq "PSTR")
	{
	  print CODE "  p1[4] = Z_STR_POOL (0, value->name.c_str(), value->name.length());\n";
        }
	elsif ($T eq "STR")
	{
	    print CODE "  p1[4] = Z_".$T."_POOL (1, value.c_str (), value.length ());\n";
        }
	else
	{
	    print CODE "  p1[4] = Z_".$T."_POOL (1, value);\n";
        }
	print CODE "  //call the zinc function with 5 arguments in internal form\n";
        print CODE "  z_command (5, \"itemSet$t2 Failed : \");\n";
        print CODE "}\n\n";
	
	print CODE "/**\n";
	print CODE " * Call zinc->itemcget ( -$2 )\n";
	print CODE " *\n";
	print CODE " * \@param item the item to get $2 from\n";
	print CODE " * \@return $2 value\n";
	print CODE " */\n";
	if ($t eq "String")
	{
	  print CODE "String Zinc::itemGet$t2 (ZincItem * item)\n";
	}
	else
	{
	  print CODE "$t Zinc::itemGet$t2 (ZincItem * item)\n";
	}
	print CODE "{\n";
        print CODE "  Tcl_Obj* tmp;\n";
	print CODE "  //discard all old results\n";
	print CODE "  Tcl_ResetResult (interp);\n";
	print CODE "  //prepare arguments : .zinc itemcget item \n";
        print CODE "  p1[0] = id;\n";
	print CODE "  p1[1] = ZFCT_itemcget;\n";
	print CODE "  p1[2] = item->object;\n";
        print CODE "  p1[3] = ZOPT_$2;\n";	
	print CODE "  //call the zinc function with 4 arguments in internal form\n";
        print CODE "  z_command (4, \"itemGet$t2 Failed : \");\n\n";
	print CODE "  //retreive the result trough the tcl interpreter and convert it\n";
	print CODE "  tmp = Tcl_GetObjResult (interp);\n";
	if($e == 1)
	{
	  print CODE "  int value;\n";
	  print CODE "  z_tcl_call (Tcl_GetIndexFromObj (interp, tmp,\n";
	  print CODE "                                   $T"."Strings, \n";
	  print CODE "                                   \"$T\",\n";
	  print CODE "                                   0, &value),\n";
	  print CODE "              \"itemGet$t2 Failed : \")\n";
	  print CODE "  return $t (value);\n";
	}
	elsif ( $T eq "STR")
	{
	  print CODE "  return String (Tcl_GetStringFromObj (tmp, NULL));\n";
	}
	elsif ( $T eq "PSTR")
	{
	  print CODE "  return new ZincFont (String (Tcl_GetStringResult (interp)));\n";
	}
	elsif ( $T eq "PTR" )
	{
	  if( $t =~ /ZincItem/ )
	  {
	    print CODE "  return new ZincItem(tmp);\n";
	  }
	  else if ( $t =~ /ZincImage/ )
	  {
	    print CODE "  return new ZincImage(tmp);\n";
	  }
	  else
	  {
	    print CODE "  return new ZincBitmap(tmp);\n";
	  }
	}
	elsif ( $T eq "INT" )
	{
	  print CODE "  int value;\n";
	  print CODE "  z_tcl_call (Tcl_GetIntFromObj (interp, tmp, &value),\n";
	  print CODE "              \"itemGet$t2 Failed : \");\n";
	  print CODE "  return ($t)value;\n";
	}
	elsif ( $T eq "DBL" )
	{
	  print CODE "  double value;\n";
	  print CODE "  z_tcl_call (Tcl_GetDoubleFromObj (interp, tmp, &value),\n";
	  print CODE "              \"itemGet$t2 Failed : \");\n";
	  print CODE "  return ($t)value;\n";
	}
	elsif ( $T eq "BOO" )
	{
	  print CODE "  int value;\n";
	  print CODE "  z_tcl_call (Tcl_GetBooleanFromObj (interp, tmp, &value),\n";
	  print CODE "              \"itemGet$t2 Failed : \");\n";
	  print CODE "  return ($t)value;\n";
	}
	else
	{
	  die("generationg error\n");
        }
	print CODE "}\n\n";

	$done .= "$2: $1\n";
  }
}

print "--- CONSTANTES\n";
print $res;
print "--- ENUMS.h\n";
print $enum;
print "--- ENUMS.c\n";
print $enum2;
print "--- FAIT\n";
print $done;
print "--- PAS FAIT\n";
print $undone;
