#!/usr/bin/python
# -*- coding: iso-8859-1 -*-
#
# Zinc.py -- Python interface to the tkzinc widget.
#
# Authors         : Frederic Lepied, Patrick Lecoanet
# Created Date    : Thu Jul 22 09:36:04 1999
#
# $Id$
#
#
# Copyright (c) 1999 CENA --
#
# See the file "Copyright" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
#

__version__  = "$Revision$"
__revision__ = "$Revision$"

from Tkinter import *
import new
import os
import locale, types
import traceback

ZINC_CURRENT_POSITION = -2
ZINC_SPEED_VECTOR     = -3
ZINC_LEADER           = -4
ZINC_CONNECTION       = -5
_LIBLOADED            = 0
_VERSION              = ""
ZINC_NO_PART          = ""

# current part dictionnary
ZINC_DPART = { 'position'      : ZINC_CURRENT_POSITION, 
         'speedvector'   : ZINC_SPEED_VECTOR , 
         'leader'        : ZINC_LEADER, 
         'connection'    : ZINC_CONNECTION}
# notes : 'field' will be return when currentpart is a field 

def havetkzinc( window ):
  '''load Zinc dynamic sharable object library , test if everything is ok
if  ok :return zinc version
if nok : return 0 '''
  global _LIBLOADED
  global _VERSION
  if ( _LIBLOADED == 1 ) : 
    return _VERSION
  try:
    if os.environ.has_key( 'auto_path' ):
      ldir = os.environ['auto_path'].split( ':' )
      ldir.reverse()
      for adir in ldir :
        window.tk.call( 'eval', 
                  "set auto_path "
                  + "[linsert $auto_path 0 %s]" % ( adir ) )
    window.tk.call( 'eval', 'package require Tkzinc' )
    # Call a function from the package to autoload it
    # and verify that all is OK.
    sversion = window.tk.call( 'zinc' ) + " Zinc.py %s" % __version__
  except TclError:
    traceback.print_exc()
    return 0
  _LIBLOADED = 1
  _VERSION = sversion
  return sversion

class ZincException:
  def __call__( self ):
    raise self

  def __init__( self, message ):
    self.message = message
    
  def __str__( self ):
    return self.message

class Zinc( Widget ):
  def __str__( self ):
    return( "Zinc instance" )
  def __init__( self, master = None, cnf = None, **kw ):
    if kw.has_key( 'backward_compatibility' ):
      self.currentpart = self.__oldcurrentpart
      self.configure   = self.__oldconfigure
      self.scale       = self.__oldscale
      self.translate   = self.__oldtranslate
      del kw['backward_compatibility']
      #Pour éviter des effets de bord 
      #si on met comme valeur par défaut de cnf
      #à {} 
    if cnf is None :
      cnf = {}
    if master :
      self.version = havetkzinc( master )
    else:
      master = Frame()
      master.pack()
      self.version = havetkzinc( master )
    Widget.__init__( self, master, 'zinc', cnf, kw )
    self.items = {}
    #BootStrap Root
    classe = eval( 'Group' )
    obj = None
    kw['id'] = 1
    obj = new.instance( classe, kw )
    self.items[1] = obj

  def mainloop( self ):
    """
    Run the events mainloop 
    """
    self.tk.mainloop()
    
  def add( self, itemType, *args, **kw ):
    """
    listTypes = zinc.add()
    id        = zinc.add(type, group)
    id        = zinc.add(type, group, initargs, **options)
    type=[arc|curve|rectangle|triangles|tabular|track|waypoint|group|icon|map|reticle|text|window]
    """
    args = list( args )
    args = args+list( self._options( kw ) )
    try:
      return self.tk.getint( 
        self.tk.call( self._w, 'add', itemType, *args ) )
    except TclError, excpt :
      ZincException( "%s\nType %s\nArgs : %s"%( excpt, itemType, args ) )()
  
  def addtag( self, *args ):
    """
    zinc.addtag(tag, searchSpec)
    This command add the given tag to all items matching
    the search specification.
    If the tag is already present on some item,
    nothing is done for that item.
    The command has no effect if no item satisfy
    the given criteria. The command returns an empty string.
    """
    self.tk.call( self._w, 'addtag', *args )

  def addtag_above( self, newtag, tagOrId ):
    """
    zinc.addtag_above(tag, tagOrId)
    """
    self.addtag( newtag, 'above', tagOrId )

  def addtag_all( self, newtag ):
    """
    A ne plus utiliser
    Utiliser addtag_withtag
    """
    self.addtag( newtag, 'all' )

  def addtag_ancestors( self, newtag, tagOrId, *ltagOrId ):
    """
    zinc.addtag_ancestors(tag, tagOrId, *listTagOrId)
    """
    self.addtag( newtag, 'ancestors', tagOrId, *ltagOrId )

  def addtag_atpriority( self, newtag, pri, tagOrId = 1 ):
    """
    zinc.addtag_atpriority(tag, priority, tagOrId = 1)
    """
    
    self.addtag( newtag, 'atpriority', pri, tagOrId )

  def addtag_below( self, newtag, tagOrId ):
    """
    zinc.addtag_below(tag, tagOrId)
    """
    self.addtag( newtag, 'below', tagOrId )

  def addtag_closest( self, newtag, x, y, halo = None, startItem = 1, recursive = 0 ):
    """
    zinc.addtag_closest(tag, x, y, halo = None, startItem = 1, recursive = 0)
    """
    self.addtag( newtag, 'closest', x, y, halo, startItem, recursive )    

  def addtag_enclosed( self, newtag, x1, y1, x2, y2, inGroup = 1, recursive = 0 ):
    """
    zinc.addtag_enclosed(tag, x1, y1, x2, y2, inGroup = 1, recursive = 0)
    """
    self.addtag( newtag, 'enclosed', x1, y1, x2, y2, inGroup, recursive )   

  def addtag_overlapping( self, newtag, x1, y1, x2, y2, inGroup = 1, recursive = 0 ):
    """
    zinc.addtag_overlapping(tag, x1, y1, x2, y2, inGroup = 1, recursive = 0)
    """
    self.addtag( newtag, 'overlapping', x1, y1, x2, y2, inGroup, recursive )

  def addtag_withtag( self, newtag, tagOrId ):
    """
    zinc.addtag_withtag(tag, tagOrId)
    """
    self.addtag( newtag, 'withtag', tagOrId )

  def addtag_withtype( self, newtag, type, tagOrId = 1 ):
    """
    zinc.addtag_withtype(tag, type, tagOrId = 1)
    """
    self.addtag( newtag, 'withtype', type, tagOrId )

  def anchorxy( self, *args ):
    """
    (x, y) = zinc.anchorxy(tagOrId, anchor)
    """
    return self.tk.call( self._w, 'anchorxy', *args )

  def bbox( self, *args ):
    """
    (xo, yo, xc, yc) = zinc.bbox(tagOrId, ?fieldIndex?)
    """
    return self.tk.call( self._w, 'bbox', *args )

  def becomes( self ):
    """
    zinc.becomes()
    """
    self.tk.call( self._w, 'becomes' )

  def bind_tag( self, tagOrId, sequence = None, func = None, add = None ):
    '''
    return a funcid which can be usefull for unbinding
    listBindings = zinc.bind_tag(tagOrId)
    listbindings = zinc.bind_tag(tagOrId, sequence)
    zinc.bind_tag(tagOrId, sequence, '')
    zinc.bind_tag(tagOrId, sequence, command)
    '''
    return self._bind( ( self._w, 'bind', tagOrId ), 
          sequence, func, add )

  def cget( self, option ):
    """
    val = zinc.cget(option)
    """
    return self.tk.call( self._w, 'cget', '-' + option )

  def chggroup( self, *args ):
    """
    zinc.chggroup(tagOrId, group, ?adjustTransform?)
    """
    self.tk.call( self._w, 'chggroup', *args )

  def clone( self, *args, **kw):
    """
    id = zinc.clone(tagOrId, **attributs)
    """
    args = list( args ) + list( self._options( kw ) )
    return self.tk.call( self._w, 'clone', *args)

  def __oldconfigure( self, **kw ):
    return Widget.configure( self, **kw )
    
  def configure( self, **kw ):
    """
    listOptions = zinc.configurez()
    listOptions = zinc.configurez(option)
    zinc.configurez(**options)
    """
    res  = Widget.configure( self, **kw )
    dico = {}
    if res:
      for i, j in res.items():
        dico[i] = j[3:]
      return dico

  def contour( self, *args ):
    """
    contourNum = zinc.contour(tagOrId)
    contourNum = zinc.contour(tagOrId, operatorAndFlag, coordListOrTagOrId)
    """
    return self.tk.call( self._w, 'contour', *args )

  def coords( self, *args ):
    """
    zinc.coords(tagOrId, contourIndex)
    zinc.coords(tagOrId, contourIndex, coordList)
    zinc.coords(tagOrId, contourIndex, coordIndex)
    zinc.coords(tagOrId, contourIndex, coordIndex, coordList)
    zinc.coords(tagOrId, 'remove', contourIndex, coordIndex)
    zinc.coords(tagOrId, 'add', contourIndex, coordList)
    zinc.coords(tagOrId, 'add', contourIndex, coordIndex, coordList)
    zinc.coords(tagOrId)
    zinc.coords(tagOrId, coordList)
    zinc.coords(tagOrId, 'remove', coordIndex)
    zinc.coords(tagOrId, 'add', coordList)
    """   
    return self.tk.call( self._w, 'coords', *args )

  def __buggyoldcurrentpart( self ):
    '''
    return a string (result from zinc current part function) and an
    integer representing either the number of the field either
    the number of the item part either ZINC_NO_PART   
    '''
    scurrentp = self.tk.call( self._w, 'currentpart' )
    if scurrentp == "":
      rvalue = ZINC_NO_PART
    else:
      try:
        rvalue = locale.atoi( scurrentp )
      except:
        try:
          rvalue = ZINC_DPART[scurrentp]
        except:
          rvalue = ZINC_NO_PART
      else:
        # string to integer succeeded
        scurrentp = "field"
    return( scurrentp, rvalue )
  
  def __oldcurrentpart( self ):
    '''return a string and an integer ;
the string is among "field", "position", "speedvector", "leader", "connection", "",
the number is the number of the part , or the field number in case of "field";
ex: 
no part return '', ZINC_NO_PART
'''
    scurrentp = self.tk.call( self._w, 'currentpart' )
    print "Zinc::__oldcurrentpart scurrentp = [%s]" % scurrentp
    # warning : read this first :
    # return a string among 'position', 'speedvector', 'leader', 'connection' ,''
    #        or an int representing the number of a field label
    # 
    # print "Zinc::currentpart cp=%s  ,type(cp)=%s" % (scurrentp,type(scurrentp))
    if scurrentp == "":
      rvalue = ZINC_NO_PART
    elif type( scurrentp ) == type( 1 ):
      # meaning a field
      # the subtil thing is here ! warning !
      rvalue    = scurrentp
      scurrentp = "field"
    else:
      # scurrentp is a string different from ""
      try:
        rvalue = ZINC_DPART[scurrentp]
      except:
        print "Zinc::currentpart unknown item part" 
        rvalue = ZINC_NO_PART

    return scurrentp, rvalue

  def currentpart( self ):
    '''
    num = zinc.currentpart()
    '''
    return  str( self.tk.call( self._w, 'currentpart' ) )
    

  def cursor( self, *args ):
    """
    zinc.cursor(tagOrId, index)
    """
    self.tk.call( self._w, 'cursor', *args )
    
  def dchars( self, *args ):
    """
    zinc.dchars( tagOrId, first )
    zinc.dchars( tagOrId, first,last )
    """
    self.tk.call( self._w, 'dchars', *args )
    
  def dtag( self, *args ):
    """
    zinc.dtag(tagOrId)
    zinc.dtag(tagOrId, tagToDelete)
    """
    self.tk.call( self._w, 'dtag', *args )

  def find( self, *args ):
    return self._getints( 
      self.tk.call( self._w, 'find', *args ) ) or ()

  def find_above( self, tagOrId ):
    """
    listItems=zinc.find_above(tagOrId)}
    """
    return self.find( 'above', tagOrId )

  def find_all( self ):
    return self.find( 'all' )
  
  def find_ancestors( self, newtag, tagOrId, *tagOrId2 ):
    """
    listItems=zinc.find_ancestor(tag, tagOrId, ?tagOrId2?)
    """
    return self.find( newtag, 'ancestors', tagOrId, *tagOrId2 )

  def find_atpriority( self, pri, *tagOrId ):
    """
    listItems=zinc.find_atpriority(pri, ?tagOrId?)
    """
    return self.find( 'atpriority', pri, *tagOrId )

  def find_below( self, tagOrId ):
    """
    listItems=zinc.find_below(tagOrId)
    """
    return self.find( 'below', tagOrId )

  def find_closest( self, x, y, *options ):
    """
    listItems=zinc.find_closest(x, y, ?halo?, ?startItem?, ?recursive?)
    """
    return self.find( 'closest', x, y, *options )

  def find_enclosed( self, x1, y1, x2, y2 ):
    """
    listItems=zinc.find_enclosed(x1, y1, x2, y2, inGroup=1, recursive=0)
    """
    return self.find( 'enclosed', x1, y1, x2, y2 )

  def find_overlapping( self, x1, y1, x2, y2, *options ):
    """
    listItems=zinc.find_overlapping( x1, y1, x2, y2, ?inGroup?, ?recursive?)
    """
    return self.find( 'overlapping', x1, y1, x2, y2, *options )

  def find_withtag( self, tagOrId ):
    """
    listItems=zinc.find_withtag( tagOrId)
    """
    return self.find( 'withtag', tagOrId )

  def find_withtype( self, type, *tagOrId ):
    """
    listItems=zinc.find_withtype( type, ?tagOrId?)
    """
    return self.find( 'withtype', type, *tagOrId )


  def fit( self, *args ):
    """
    listControls=zinc.fit(coordList,error)
    """
    return self.tk.call( self._w, 'fit', *args )
    
  def focus( self, *args ):
    """
    zinc.focus(tagOrId, ?itemPart?)
    """
    self.tk.call( self._w, 'focus', *args )

  def gdelete( self, *args ):
    """
    zinc.gdelete(gradientName)
    """
    self.tk.call( self._w, 'gdelete', *args )

  def gettags( self, *args ):
    """
    listTags=zinc.gettags(tagorid)
    """
    return self.tk.splitlist( self.tk.call( self._w, 'gettags', *args ) )

  def gname( self, *args ):
    """
    zinc.gname(gradientDesc, gradientName)
    bExist=zinc.gname(gradientName)
    """
    return self.tk.call( self._w, 'gname', *args )
  
  def group( self, *args ):
    """
    group=zinc.group(tagOrId)
    """
    return self.tk.call( self._w, 'group', *args )

  def hasanchors( self, *args ):
    """
    bool=zinc.hasanchors(tagOrId)
    """
    return self.tk.call( self._w, 'hasanchors', *args )

  def hasfields( self, *args ):
    """
    bool=zinc.hasfields(tagOrId)
    """
    return self.tk.call( self._w, 'hasfield', *args )

  def hastag( self, *args ):
    """
    bool=zinc.hastag(tagOrId, tag)
    """
    return self.tk.call( self._w, 'hastag', *args )

  def index( self, *args ):
    """
    num = zinc.index(tagOrId, index)
    """
    return self.tk.call( self._w, 'tagOrId', *args )

  def insert( self, *args ):
    """
    zinc.insert(tagOrId, before, string)
    """
    self.tk.call( self._w, 'insert', *args )

  def itemcget( self, tagOrId, option ):
    """
    val=zinc.itemcget(tagOrId, attr)
    """
    return self.tk.call( self._w, 'itemcget', tagOrId, '-'+option )

  def itemfieldget( self, tagOrId, field, option ):
    """
    val=zinc.itemcget(tagOrId, field, attr)
    """
    return self.tk.call( self._w, 'itemcget', tagOrId, field, '-'+option )

  def itemconfigure( self, tagOrId, field=None, **kw ):
    '''
    either get the dictionnary of possible attributes (if kw is None)
    either allow to set Items attributes or Field attributes
    
    listAttribs=zinc.itemconfigure(tagOrId)
    listAttribs=zinc.itemconfigure(tagOrId, attrib)
    zinc.itemconfigure(tagOrId, **attributs)
    listAttribs=zinc.itemconfigure(tagOrId, fieldIs, attrib)
    zinc.itemconfigure(TagOrId,fieldId,**attributs)
    '''
    if not kw:
      cnf = {}
      for var_x in self.tk.split( 
        field != None and self.tk.call( self._w, 'itemconfigure', 
                          ( tagOrId, field ) ) or
        self.tk.call( self._w, 'itemconfigure', ( tagOrId, ) ) ):
        cnf[var_x[0][1:]] = ( var_x[0][1:], ) + var_x[1:]
      return cnf
    if field != None:
      args = ( tagOrId, str( field ), )+ self._options( {}, kw )
      self.tk.call( self._w, 'itemconfigure', *args )
    else:
      args = ( tagOrId, ) + self._options( {}, kw )
      self.tk.call( self._w, 'itemconfigure', *args )

  # _dp voir si cette instruction est a execute ici
  # permet de creer un synonyme de itemconfigure
  itemconfig = itemconfigure

  def loweritem( self, *args ):
    """
    zinc.loweritem(tagOrId)
    zinc.loweritem(tagOrId, belowThis)
    Reorder all the items given by tagOrId so that
    they will be under the item given by belowThis.
    If tagOrId name more than one item,
    their relative order will be preserved.
    If tagOrId doesn't name an item, an error is raised.
    If  belowThis name more than one item, the bottom most them is used.
    If belowThis  doesn't name an item, an error is raised.
    If belowThis is omitted the items are put
    at the bottom most position of their respective groups.
    The command ignore all items named by tagOrId
    that are not in the same group than belowThis or,
    if not specified, in the same group than the first item
    named by tagOrId. The command returns an empty string.
    As a side affect of this command, the -priority  attribute
    of all the reordered items is ajusted to match the priority
    of the  belowThis item (or the priority of the bottom most item)
    """
    self.tk.call( self._w, 'lower', *args )

  def monitor( self, *args ):
    """
    bool = zinc.monitor()
    zinc.monitor(bool)
    """
    return self.tk.call( self._w, 'monitor', *args )

  def numparts( self, *args ):
    """
    num = zinc.numparts(tagOrId)
    """
    return self.tk.call( self._w, 'numparts', *args )

  def postcript( self, *args ):
    """
    Not Yet Implemented
    zinc.postscript()
    """
    return self.tk.call( self._w, 'postscript', *args )

  def raiseitem( self, *args ):
    """
    Correspond à l'appel raise de la documentation
    le mot raise est reservé en python
    zinc.raiseitem(tagOrId)
    zinc.raiseitem(tagOrId, aboveThis)
    """
    self.tk.call( self._w, 'raise', *args )

  def remove( self, *args ):
    """
    zinc.remove(tagOrId, ?tagOrId,...?)
    """
    self.tk.call( self._w, 'remove', *args )
  
  def rotate( self, *args ):
    """
    zinc.rotate(tagOrId, angle)
    zinc.rotate(tagOrId, angle, centerX, centerY)
    """
    self.tk.call( self._w, 'rotate', *args )

  def __oldscale( self, xFactor=None, yFactor=None, tagOrId=None ):
    if yFactor == None:
      return self.tk.getdouble( self.tk.call( 'scale' ) )
    else:
      if tagOrId == None:
        self.tk.call( self._w, 'scale', xFactor, yFactor )
      else:
        self.tk.call( self._w, 'scale', tagOrId, xFactor, yFactor )

  def scale( self, *args ):
    """
    zinc.scale(tagOrIdOrTName, xFactor, yFactor)
    zinc.scale(tagOrIdOrTName, xFactor, yFactor, centerX, centerY)
    Add a scale factor to the items or the transform described
    by tagOrId.
    If  tagOrId describes a named transform then this transform
    is used to do the operation. If tagOrId describes more than
    one item then all the items are affected by the operation.
    If tagOrId describes neither a named transform nor an item,
    an error is raised.
    A separate factor is specified for X and Y.
    The optional parameters describe the center of scaling,
    which defaults to the origin.
    """
    if not len( args ):
      return self.tk.getdouble( self.tk.call( self._w, 'scale' ) )
    else:
      self.tk.call( self._w, 'scale', *args )
        
  def select( self, *args ):
    """
    zinc.select('adjust', tagOrId, index)
    Adjust the end of the selection in tagOrId
    that is nearest to the character given by index so
    that it is at index.
    The other end of the selection is made the anchor
    for future select to commands.
    If the selection is not currently in tagOrId,
    this command behaves as the select to command.
    The command returns an empty string.
    zinc.select('clear')
    Clear the selection if it is in the widget.
    If the selection is not in the widget,
    the command has no effect. Return an empty string.
    zinc.select('from', tagOrId, index)
    Set the selection anchor point for the widget
    to be just before the character given by index
    in the item described by tagOrId.
    The command has no effect on the selection,
    it sets one end of the selection so that future
    select to can actually set the selection.
    The command returns an empty string.
    (item,part) = zinc.select('item')
    Returns a list of two elements.
    The first is the id of the selected item
    if the selection is in an item on this widget;
    Otherwise the first element is an empty string.
    The second element is the part of the item
    (track, waypoint or tabular item only) or the empty string.
    zinc.select('to', tagOrId, index)
    Set the selection to be the characters that lies
    between the selection anchor and  index in the item described
    by tagOrId. The selection includes the character given
    by index and includes the character given by the anchor point
    if  index is greater or equal to the anchor point.
    The anchor point is set by the most recent select adjust
    or select from command issued for this widget.
    If the selection anchor point for the widget is not currently
    in tagOrId, it is set to the character given by index.
    The command returns an empty string.
    Manipulates the selection as requested by option.
    tagOrId describes the target item.
    This item must support text indexing and selection. I
    f more than one item is referred to by tagOrId,
    the first in display list order that support both text
    indexing and selection will be used.
    Some forms of the command include an index  parameter,
    this parameter describes a textual position within the
    item and should be a valid index as described in
    Text indices.
    """
    return self.tk.call( self._w, 'select', *args )

  def skew( self, *args ):
    """
    zinc.skew(tagOrIdOrTName,xSkewAngle, ySkewAngle)
    Add a skew (or shear) transform to the to the items
    or the transform described by tagOrIdOrTName.
    If tagOrId describes a named transform then this transform
    is used to do the operation.
    If tagOrId describes more than one item then all the
    items are affected by the operation.
    If tagOrId describes neither a named transform nor an item,
    an error is raised. The angles are given in radian.
    """
    return self.tk.call( self._w, 'skew', *args )

  def smooth( self, *args ):
    """
    zinc.smooth(coordList)
    This command computes a sequence of segments
    that will smooth the polygon described by the vertices
    in coordList and returns a list of lists describing points
    of the generated segments. These segments are approximating
    a Bezier curve. coordList should be either a flat list
    of an even number of coordinates in x, y order, or a list
    of lists of point coordinates X, Y.
    The returned list can be used to create or change the contour
    of a curve item.
    """
    return self.tk.call( self._w, 'smooth', *args )

  def tapply( self, *args ):
    """
    Not Yet Implemented
    zinc.tapply()
    """
    return self.tk.call( self._w, 'tapply', *args )

  def tcompose( self, *args ):
    """
    zinc.tcompose(tagOrIdOrTName, tName)
    zinc.tcompose(tagOrIdOrTName, tName, invert)
    """
    return self.tk.call( self._w, 'tapply', *args )

  def tdelete( self, *args ):
    """
    zinc.tdelete(tName)
    Destroy a named transform.
    If the given name is not found among the named transforms,
    an error is raised.
    """
    self.tk.call( self._w, 'tdelete', *args )
  
  def transform( self, *args ):
    """
    listCoords=zinc.transform(tagOrIdTo, coordList)
    listCoords=zinc.transform(tagOrIdFrom, tagOrIdTo, coordList)
    This command returns a list of coordinates obtained by transforming the coordinates given in coordList
    from the coordinate space of the transform or item described by tagOrIdFrom to the coordinate space
    of the transform or item described by  tagOrIdTo.
    If tagOrIdFrom is omitted it defaults to the window coordinate space.
    If either tagOrIdFrom or tagOrIdTo describes more than one item,
    the topmost in display list order is used. If either tagOrIdFrom or tagOrIdTo
    doesn't describe either a transform or an item, an error is raised.
    The coordList should either be a flat list containing an even number of coordinates
    each point having two coordinates, or a list of lists each sublist of the form [ X Y ?pointtype? ].
    The returned coordinates list will be isomorphic to the list given as argument. 

    It is possible to convert from window coordinate space to the coordinate space of any item.
    This is done by omitting ?tagOrIdFrom? and specifying in tagOrIdTo, the id of the item.
    It can also be done by using the predefined tag 'device' as first argument. 

    It is also possible to convert from the coordinate space of an item to the window coordinate
    space by using the predefined tag 'device' as second argument. 

    """
    return self._getdoubles( self.tk.call( self._w, 'transform', *args ) )

#ANCIENNE IMPLEMENTATION
  def __oldtranslate( self, dx=None, dy=None, tagOrId=None ):   
    if dx == None:
      return self._getints( self.tk.call( 'translate' ) )
    else:
      if tagOrId == None:
        self.tk.call( self._w, 'translate', dx, dy )
      else:
        self.tk.call( self._w, 'translate', tagOrId, dx, dy )

  def translate( self, *args ):
    """
    zinc.translate(tagOrIdOrTName, xAmount, yAmount)
    zinc.translate(tagOrIdOrTName, xAmount, yAmount, absolute)
    Add a translation to the items or the transform described by tagOrIdOrTName.
    If  tagOrIdOrTName describes a named transform then this transform is used
    to do the operation.
    If tagOrIdOrTName describes more than one item then all the items are affected
    by the opration.
    If tagOrIdOrTName describes neither a named transform nor an item,
    an error is raised. A separate value is specified for X and Y.
    If the optionnal ?absolute? parameter is true,
    it will set an absolute translation to the tagOrIdOrTName
    """
    if ( len( args ) == 1 ):
      return self._getints( self.tk.call( self._w, 'translate' ) )
    else:
      self.tk.call( self._w, 'translate', *args )

  def treset( self, *args ):
    """
    zinc.treset(tagOrIdOrTName)
    Set the named transform or the transform for the items described by tagOrIdOrTName
    to identity. If tagOrIdOrTName describes neither a named transform nor an item,
    an error is raised.
    """
    self.tk.call( self._w, 'treset', *args )
  
  def trestore( self, *args ):
    """
    zinc.trestore(tagOrId, tName)
    Set the transform for the items described by tagOrId to the transform named by tName.
    If tagOrId doesn't describe any item or if the transform named  tName doesn't exist,
    an error is raised.
    """
    self.tk.call( self._w, 'trestore', *args )
  
  def tsave( self, *args ):
    """
    zinc.tsave(tName)
    zinc.tsave(tagOrIdOrTName, tName)
    zinc.tsave(tagOrIdOrTName, tName, invert)
    Create (or reset) a transform associated with the name tName
    with initial value the transform associated with the item tagOrIdOrTName.
    If tagOrIdOrTName describes more than one item, the topmost in display list order is used.
    If tagOrIdOrTName doesn't describe any item or named transformation, an error is raised.
    If tName already exists, the transform is set to the new value.
    This command is the only way to create a named transform.
    If tagOrIdOrTName is not specified, the command returns a boolean telling
    if the name is already in use.
    The invert boolean, if specified, cause the transform to be inverted prior to be saved. 

    It is possible to create a new named transformation from the identity
    by using the predefined tag 'identity': $zinc->tsave('identity', 'myTransfo'); 
    """
    return self.tk.call( self._w, 'tsave', *args )

  def tget( self, *args ):
    """
    zinc.tget(tagOrId)
    zinc.tget(tagOrIdOrTName, selector)
    selector:={'all'|'translation'|'scale'|'rotation'|'skew'}
    With only one argument, get the six elements of the 3x4 matrix
    used in affine transformation for tagOrIdOrTName.
    The result is compatible with the tset method.
    With optional second parameter 'all' returns the transform
    decomposed in translation, scale, rotation, skew
    and return the list in this order,
    With 'translation', 'scale', 'rotation', 'skew' optional
    second parameter, returns the corresponding values.
    """
    return self.tk.call( self._w, 'tget', *args )
    
  def tset( self, *args ):
    """
    zinc.tset(tagOrIdOrName, m00, m01, m10, m11, m20, m21)
    Set the six elements of the 3x4 matrix used in affine transformation for tagOrIdOrTName.
    BEWARE that depending on mij values,
    it is possible to define a not inversible matrix which will end up in core dump.
    This method must BE USED CAUTIOUSLY.
    """
    return self.tk.call( self._w, 'tset', *args )

  def type( self, tagOrId ):
    """
    name=zinc.type(tagOrId)
    If more than one item is named by tagOrId,
    then the type of the topmost item in display list order is returned.
    If no items are named by tagOrId, an error is raised.
    """
    return self.tk.call( self._w, 'type', tagOrId )

  def vertexat( self, *args ):
    """
    (contour,vertex,edgevertex)=zinc.vertexat(tagOrId,x,y)
    """
    return self.tk.call( self._w, 'vertexat', *args )

  def xview(self, *args):
      """Query and change horizontal position of the view."""
      if not args:
          return self._getdoubles(self.tk.call(self._w, 'xview'))
      self.tk.call((self._w, 'xview') + args)
  def xview_moveto(self, fraction):
      """Adjusts the view in the window so that FRACTION of the
      total width of the canvas is off-screen to the left."""
      self.tk.call(self._w, 'xview', 'moveto', fraction)
  def xview_scroll(self, number, what):
      """Shift the x-view according to NUMBER which is measured in "units" or "pages" (WHAT)."""
      self.tk.call(self._w, 'xview', 'scroll', number, what)
  def yview(self, *args):
      """Query and change vertical position of the view."""
      if not args:
          return self._getdoubles(self.tk.call(self._w, 'yview'))
      self.tk.call((self._w, 'yview') + args)
  def yview_moveto(self, fraction):
      """Adjusts the view in the window so that FRACTION of the
      total height of the canvas is off-screen to the top."""
      self.tk.call(self._w, 'yview', 'moveto', fraction)
  def yview_scroll(self, number, what):
      """Shift the y-view according to NUMBER which is measured in "units" or "pages" (WHAT)."""
      self.tk.call(self._w, 'yview', 'scroll', number, what)

class ZincItem:
  def __init__( self, zinc, itemType, group = 1, *args, **kw ):
    self.zinc  = zinc
    texture    = None
    fillpatern = None
    scale      = None
    translate  = None
    if kw.has_key( 'texture' ):
      texture = kw['texture']
      del kw['texture']

    if kw.has_key( 'fillpatern' ):
      fillpastern = kw['fillpatern']
      del kw['fillpatern']

    if kw.has_key( 'scale' ):
      scale = kw['scale']
      del kw['scale']

    if kw.has_key( 'rotate' ):
      rotate = kw['rotate']
      del kw['rotate']

    if kw.has_key( 'translate' ):
      translate = kw['translate']
      del kw['translate']
      
    if kw.has_key( 'cloneid' ):
      cloneid = kw['cloneid']
      del kw['cloneid']
    else:
      cloneid = 0 
    group = str( group )
    #        sys.stdout.flush()
    if cloneid == 0 :
      self.id = zinc.add( itemType, group, *args, **kw )
    else :
      self.id = self.zinc.clone(cloneid, *args, **kw)

    zinc.items[self.id] = self
    texture = None
    if fillpatern:
      self.itemconfigure( fillpatern )
    if scale:
      self.scale( scale )     
    if translate:
      self.translate( translate )
    
    
  def __str__( self ):
    return str( self.id )

  def __repr__( self ):
    return str( self.id )

  def bbox( self, *args ):
    return self.zinc.bbox( self.id, *args )
  
  def clone( self, *args, **kw):
    '''id = zincitem.clone(*args,**kw) '''
    # print "ZincItem::clone"
        # on cherche tagOrId
    # nidcloned = self.find_above(tagOrId)
    sclonedtype = self.type()
    sclonedgroupid = self.zinc.group(self.id)

    # ajout cle 'cloneid' (voir ZincItem::__init__) 
    kw['cloneid'] = self.id
        # on cree un nouveau ZincItem meme type,
    return(ZincItem(self.zinc, sclonedtype, sclonedgroupid, **kw ))
  
  def delete( self ):
    del self.zinc.items[self.id]
    try:
      self.zinc.remove( self.id )
    except:
      pass
  def __getitem__( self, key ):
    '''allow to get attribute by self["key"] '''
    if ( key == "coords" ):
      return self.zinc.coords( self.id )
    return self.zinc.itemcget( self.id, key )

  def __setitem__( self, key, value ):
    '''allow to set item attrbutes, eg. for a track position attributes
    just writing :
    a = ZincItem(myzinc, ...)
    a["position"]    = (x,y)
    Notes : when setting multiple attributes
    using itemconfigure is more efficient '''
    if ( key is "coords" ):
      self.zinc.coords( self.id, value )
    else:
      self.zinc.itemconfigure( self.id, **{key:value} )
      
  def getGroup( self ):
    groupid = self.zinc.group( self.id )
    return self.zinc.items[groupid]
    
  def keys( self ):
    if not hasattr( self, '_keys' ):
      self._keys = {}
      config = self.zinc.itemconfig( self.id )
      for x in config.keys():
        self._keys[x] = config[x][1]
    return self._keys

  def has_key( self, key ):
    return key in self.keys()

  def bind( self, sequence=None, command=None, add=None ):
    '''return a funcid which can be used to unbind
notes: unbinding can be done by bind("<seq>","") or using native tkinter
unbind method '''
    return( self.zinc.bind_tag( self.id, sequence, command, add ) )
    
  def cget( self, attr ):
    return self.zinc.itemcget( self.id, attr )
       
  def coords( self, *args, **kw ):
    return self.zinc.coords( self.id, *args, **kw )

  def fieldcget( self, field, attr ):
    return self.zinc.itemfieldcget( self.id, field, attr )

  def itemconfigure( self, field=None, **kw ):
    self.zinc.itemconfigure( self.id, field, **kw )

  def rotate( self, *args ):
    return self.zinc.rotate( self.id, *args )
  
  def scale( self, *args ):
    return self.zinc.scale( self.id, *args )

  def transforms( self, *args ):
    """
    zincitem.transform(tozincitem, coordList)
    This command returns a list of coordinates obtained by transforming the coordinates given in coordList
    from the coordinate space of item to the coordinate space
    of the tozincitem item.
    The coordList should either be a flat list containing an even number of coordinates
    each point having two coordinates, or a list of lists each sublist of the form [ X Y ?pointtype? ].
    The returned coordinates list will be isomorphic to the list given as argument. 
    """
    return self.zinc.transforms( self.id, *args )

  def translate( self, *args ):
    """
    zincitem.translate( xAmount, yAmount)
    zincitem.translate( xAmount, yAmount, absolute)
    Add a translation to the item.
    A separate value is specified for X and Y.
    If the optionnal ?absolute? parameter is true,
    it will set an absolute translation to the item   
    """
    self.zinc.translate( self.id, *args )

  def tset( self, *args ):
    """
    zincitemtset(m00, m01, m10, m11, m20, m21)
    Set the six elements of the 3x4 matrix used in affine transformation.
    BEWARE that depending on mij values,
    it is possible to define a not inversible matrix which will end up in core dump.
    This method must BE USED CAUTIOUSLY.     
    """
    self.zinc.tset( self.id, *args )

  def type( self ):
    """
    name=zincitemtype()
    This command returns the type of the item.
    """
    return self.zinc.type( self.id )

  def tsave( self, *args ):
    """
    zincitemtsave( tName)
    zincitemtsave( tName, invert)
    Create a transform associated with the name tName
    with initial value the transform associated with the item.
    If tName already exists, the transform is set to the new value.
    This command is the only way to create a named transform.
    The invert boolean, if specified, cause the transform to be inverted prior to be saved. 
    """
    return self.zinc.tsave( self.id, *args )

  def treset( self, *args ):
    """
    zincitemtreset()
    Set the named transform or the transform for the item
    to identity. If there are no named transform,
    an error is raised.
    """
    self.zinc.treset( self.id, *args )
    
  def trestore( self, *args ):
    """
    zincitemtrestore( tName)
    Set the transform for the item to the transform named by tName.
    If the transform named  tName doesn't exist, an error is raised.
    """
    self.zinc.trestore( self.id, *args )
    
  def tget( self, *args ):
    """
    zincitemtget()
    zincitemtget(selector)
    selector:={'all'|'translation'|'scale'|'rotation'|'skew'}
    With only one argument, get the six elements of the 3x4 matrix
    used in affine transformation.
    The result is compatible with the tset method.
    With optional second parameter 'all' returns the transform
    decomposed in translation, scale, rotation, skew
    and return the list in this order,
    With 'translation', 'scale', 'rotation', 'skew' optional
    second parameter, returns the corresponding values.
    """   
    return self.zinc.tget( self.id, *args )


class Arc( ZincItem ):
    def __init__( self, zinc, *args, **kw ):
        """
        The arc type expects a list of four floating point numbers xo yo xc yc,
        giving the coordinates of the origin and the corner of the enclosing rectangle.
        The origin should be the top left vertex of the enclosing rectangle and the corner
        the bottom right vertex of the rectangle.
        """
        ZincItem.__init__( self, zinc, 'arc', *args, **kw )    

class Group( ZincItem ):
    def __init__( self, zinc, *args, **kw ):
        """
        These type do not expect type specific arguments.
        """
        ZincItem.__init__( self, zinc, 'group', *args, **kw )    

    def getGroup( self ):
        """Retourne l'objet de type Group
        auquel est attache l'item"""
        ###Gestion du boostrap
        if self.id == 1:
            return self.zinc.items[1]
        else:
            return ZincItem.getGroup( self )

  #TODO: Extension. Renvoie les références aux ZincItems contenus dans le Groupe
    def getNode( self ):
        """
        """
        pass
            
class Icon( ZincItem ):
    def __init__( self, zinc, *args, **kw ):
        """
        These type do not expect type specific arguments.
        """
        ZincItem.__init__( self, zinc, 'icon', *args, **kw )    

class Map( ZincItem ):
    def __init__( self, zinc, *args, **kw ):
        """
        These type do not expect type specific arguments.
        """
        ZincItem.__init__( self, zinc, 'map', *args, **kw )
  
class Curve( ZincItem ):
    def __init__( self, zinc, *args, **kw ):
        """
        The curve type expects either a flat list or a list of lists.
        In the first case, the flat list must be a list of floating point numbers
        x0 y0 x1 y1 ... xn yn, giving the coordinates of the curve vertices.
        The number of values should be even (or the last value will be discarded)
        but the list can be empty to build an empty invisible curve.
        In the second case,thelist must contain lists of 2 or 3 elements:
        xi, yi and and an optionnal point type. Currently,
        the only available point type is 'c' for a cubic bezier control point.
        For example, the following list is an example of 2 beziers segments
        with a straight segment in-between:
        ( [x0, y0], [x1, y1, 'c'], [x2, y2, 'c'], [x3, y3], [x4, y4, 'c'], [x5, y5] )
        
        As there is only on control point, [x4, y4, 'c'] ,
        for the second cubic bezier,
        the omitted second control point will be defaulted to the same point.
        a named tuple contours can give to define new contours in curve.
        contours=(<contour1>,...)
        <contour>=(<point1>,...)
        A curve can be defined later with the contour or coords commands.
        As a side effect of the curve behavior,
        a one vertex curve is essentially the same as an empty curve,
        it only waste some more memory.
        
        """
        contours = []
        if kw.has_key( 'contours' ):
            contours = kw['contours']
            del kw['contours']
        ZincItem.__init__( self, zinc, 'curve', *args, **kw )
        for contour in contours:
            self.zinc.contour( self.id, *contour )
    

class Rectangle( ZincItem ):
    def __init__( self, zinc, *args, **kw ):
        """
        The rectangle type expects a list of four floating point numbers xo yo xc yc,
        giving the coordinates of the origin and the corner of the rectangle.
        """
        ZincItem.__init__( self, zinc, 'rectangle', *args, **kw )    

class Reticle( ZincItem ):
    def __init__( self, zinc, *args, **kw ):
        """
        These type do not expect type specific arguments.
        """
        ZincItem.__init__( self, zinc, 'reticle', *args, **kw )    

class Tabular( ZincItem ):
    def __init__( self, zinc, *args, **kw ):
        ZincItem.__init__( self, zinc, 'tabular', *args, **kw )    

class Text( ZincItem ):
    def __init__( self, zinc, *args, **kw ):
        """
        These type do not expect type specific arguments.
        """
        ZincItem.__init__( self, zinc, 'text', *args, **kw )    

class Track( ZincItem ):
    def __init__( self, zinc, *args, **kw ):
        ZincItem.__init__( self, zinc, 'track', *args, **kw )
  
class WayPoint( ZincItem ):
  def __init__( self, zinc, *args, **kw ):
    ZincItem.__init__( self, zinc, 'waypoint', *args, **kw )
  

# Class to hold mapinfos used by the Map Item class 
class Mapinfo:
    def __init__( self, interp, name = None ):
        """
        @type name: string
        @param name: Name of mapinfo. Must be used carrefully !
        Create a new empty map description.
        The new mapinfo object named name or internal id if name is omitted
        """
        if name :
            self.name = name
        else:
            self.name = `id( self )`
            self.interp = interp.tk
            apply( self.interp.call, ( 'mapinfo', self.name, 'create' ) )
    
    def __repr__( self ):
        return self.name

    def __del__( self ):
        self.delete()

    def delete( self ):
        """
        Delete the mapinfo object.
        All maps that refer to the deleted mapinfo are updated to reflect the change.
        """
        self.interp.call( 'mapinfo', self.name, 'delete' )


    def duplicate( self, *args ):
        """
        B{Optional}
        @type name: Name of the new mapinfo
        @param name: Must be use carrefully !!
        Create a new mapinfo that is a exact copy of this mapinfo Object.
        """
        classe = Mapinfo
        obj = new.instance( classe )
        if len( args ):
            new_name = args[0]
        else:
            new_name = str( obj )
        self.interp.call( 'mapinfo', self.name, 'duplicate', new_name )
        return obj
    
    def add_text( self, text_style, line_style, x, y, text ):
        """
        Add a new graphical element to the mapinfo object text. 
        This element describes a line of text.
        @type text_style: {normal|underlined}
        @param text_style: text style 
        @type line_style: string
        @param line_style: a line style (simple, dashed,  dotted, mixed, marked) to be used for the underline
        @type X: int
        @param X: Coord on X axe
        @type Y: int
        @param Y: Coord on Y axe
        @type text: string
        @param : a string describing the text.
    
        """
        self.interp.call( 'mapinfo', self.name, 'add', 'text', text_style, 
                         line_style, x, y, text )

    def add_line( self, line_style, width, x1, y1, x2, y2 ):
        """
        Add a new graphical element to the mapinfo object line.
        This element describes a line segment.
        @type line_style: {simple|dashed|dotted|mixed|marked}
        @param line_style: a line style
        @type width: int
        @param width: the line width in pixels
        @type x1: int
        @param x1: coords on X axe
        @type x2: int
        @param x2: coords on Y axe
        @type x3: int
        @param x3:  end vertices on X axe
        @type x4: int
        @param x4: end vertices on Y axe
        four integer values setting the X and Y coordinates of the two end vertices.
        """
        self.interp.call( 'mapinfo', self.name, 'add', 'line', line_style, 
                         width, x1, y1, x2, y2 )

    def add_arc( self, line_style, width, cx, cy, radius, start, extent ):
        """
        Add a new graphical element to the mapinfo object arc.
        
        @type line_style: {simple|dashed|dotted|mixed|marked}
        @param line_style: a line style
        @type width: int 
        @param width: the line width in pixels
        @type cx: int
        @param cx: X of arc center
        @type cy: int 
        @param cy: Y of arc center
        @type radius: int 
        @param radius: the arc radius
        @type start: int
        @param start: the start angle (in degree)
        @type extent: int
        @param extent: the angular extent of the arc (in degree).
        
        """
        self.interp.call( 'mapinfo', self.name, 'add', 'arc', line_style, 
                         width, cx, cy, radius, start, extent )
        
    def add_symbol( self, x, y, index ):
        """
        Add a new graphical element to the mapinfo object symbol.
        @type x: int
        @param x: position on X
        @type y: int
        @param y: position on Y
        
        @type index: int
        @param : an integer setting the symbol index in the -symbols list of the map item
        
        """
        self.interp.call( 'mapinfo', self.name, 'add', 'symbol', x, y, index )
    
    def count( self, type ):
        """
        @type type: {text|arc|line|symbol}
        @param type:
        Return an integer value that is the number of elements matching type in the mapinfo.
        type may be one the legal element types   
        """
        return self.interp.call( 'mapinfo', self.name, 'count', type )
    
    def get( self, type, index ):
        """
        Return the parameters of the element at index with type type in the mapinfo.
        The returned value is a list.
        The exact number of parameters in the list and their meaning depend on type and is accurately described in mapinfo add.
        type may be one the legal element types as described in the mapinfo add command.
        Indices are zero based and elements are listed by type.
        """
        return self.interp.call( 'mapinfo', self.name, 'remove', type, index )

    def replace( self, type, index, *args ):
        """
        Replace all parameters for the element at index with type type in the mapinfo.
        The exact number and content for args depend on  type and is accurately described in mapinfo add.
        type may be one the legal element types as described in the mapinfo add command.
        Indices are zero based and elements are listed by type.
        """
        return self.interp.call( 'mapinfo', self.name, 'replace', 
                 type, index, args )

    def remove( self, type, index ):
        """
        Remove the element at index with type type in the mapinfo.
        type may be one the legal element types as described in the mapinfo add command. Indices are zero based and elements are listed by type.
        """
        return self.interp.call( 'mapinfo', self.name, 'remove', type, index )
    
    def scale( self, factor ):
        """
        """
        self.interp.call( 'mapinfo', self.name, 'scale', factor )
        
    def translate( self, xAmount, yAmount ):
        """
        """
        self.interp.call( 'mapinfo', self.name, 'translate', xAmount, yAmount )
    
class Videomap ( Mapinfo ):
    """
    create a mapinfo from a proprietary
    file format for simple maps, in use in french Air Traffic Control Centres. The format is the
    binary cautra4 (with x and y in 1/8nm units) 
    """
    def __init__( self, tk, *args ):
        """
        @type  filename: 
        @param filename:
        @type  mapinfoname: 
        @param mapinfoname: 
        Load the videomap sub-map located at position index in the file named  fileName into a mapinfo object named mapInfoName. It is possible, if needed, to use the videomap ids command to help translate a sub-map id into a sub-map file index.
        """
        self.tk = tk.tk
        args    = args + ( self, )
        self.tk.call( 'videomap', 'load', *args )
        

    def ids( self, filename ):
        """
        @type  filename: string
        @param filename: filename where to search syb-map
        B{Class Method}
        Return all sub-map ids that are described in the videomap file described by  fileName.
        The ids are listed in file order. This command makes possible to iterate through a videomap file
        one sub-map at a time, to know how much sub-maps are there and to sort them according to their ids.
        """
        return self.tk.call( 'videomap', 'ids', filename )

class Colors:
  """
  Classe abstraite utilitaire permettant de gérer sous forme d'objet
  les couleurs aux formats Zinc
  """
  def __init__( self ):
    self.lColors = []
  
  #TODO:
  def getColorsIter( self ):
    """
    Renvoie un itérateur sur les couleurs
    """
    return self.lColors.__iter__()
    
    def addColor( self, color, alpha = 100, 
           colorposition = 0, mid_span_position = 50 ):
      self.lColors.append( ( color, alpha, colorposition, mid_span_position ) )

  def __repr__( self ):
    res = ""
    for i in self.lColors:
      res = "%s%s;%s %s %s|" % ( res, i[0], i[1], i[2], i[3] )
    return res[:-1]
    
class AxialGradientColor( Colors ):
    def __init__( self, *params ):
        """
        params : degre or  x1, y1, x2, y2 which define angle and extension of the axe
        =axial degre | gradient_step1 | ... | gradient_stepn or
        =axial x1 y1 x2 y2 | gradient_step1 | ... | gradient_stepn
        """
        Colors.__init__( self )
        count = 0
        self.params = ""
        for i in params:
            self.params = "%s %s" % ( self.params, str( i ) )
            count += 1
        if ( count != 1 ) and ( count != 4 ):
            raise Exception( "Bad Format of params %s" % count )
        
    def __repr__( self ):
        res = "=axial %s" % self.params
        if not ( len( self.lColors ) ):
            raise Exception( "Bad Format, must have  one color less" )
        res = "%s | %s" % ( res, Colors.__repr__( self ) )
        return res
                
class RadialGradientColor( Colors ):
    def __init__( self, *params ):
        """
        =radial x y | gradient_step1 | ... | gradient_stepn  or
        =radial x1 y1 x2 y2 | gradient_step1 | ... | gradient_stepn
        The x y parameters define the center of the radial.
        The x1 y1 x2 y2 parameters define both the center and the extension of the radial.
        """
        Colors.__init__( self )
        count = 0
        self.params = ""
        for i in params:
            self.params = "%s %s" % ( self.params, str( i ) )
            count += 1
        if ( ( count!= 2 ) and ( count != 4 ) ):
            raise Exception( "Bad Format of params %s"%count )
        
    def __repr__( self ):
        res = "=radial %s " % self.params
        if not ( len( self.lColors ) ):
            raise Exception( "Bad Format, must have  one color less" )
        res = "%s | %s" % ( res, Colors.__repr__( self ) )
        return res

class PathGradientColor( Colors ):
    def __init__( self, *params ):
        """
    =path x y | gradient_step1 | ... | gradient_stepn
    The x y parameters define the center of the gradient. 
        """
        Colors.__init__( self )
        count       = 0
        self.params = ""
        for i in params:
            self.params = "%s %s" % ( self.params, str( i ) )
            count += 1
        if ( count != 2 ):
            raise Exception( "Bad Format of params %s" % count )
        
    def __repr__( self ):
        res = "=path %s " % self.params
        if not ( len( self.lColors ) ):
            raise Exception( "Bad Format, must have  one color less" )
        res = "%s | %s" % ( res, Colors.__repr__( self ) )
        return res

class ConicalGradientColor( Colors ):
    def __init__( self, *params ):
        """
        =conical degre | gradient_step1 | ... | gradient_stepn or
        =conical degre x y | gradient_step1 | ... | gradient_stepn or
        =conical x1 y1 x2 y2 | gradient_step1 | ... | gradient_stepn
        
        The degre parameter defines the angle of the cone in the usual trigonometric sense.
        The optional x y parameters define the center of the cone.
        By default, it is the center of the bounding-box.
        The x1 y1 x2 y2 parameters define the center and the angle of the cone.

        All x and y coordinates are expressed in percentage of the bounding box,
        relatively to the center of the bounding box.
        So 0 0 means the center while -50 -50 means the lower left corner of the bounding box. 

        If none of the above gradient type specification is given,
        the gradient will be drawn as an axial gradient with a null angle. 
        """
        Colors.__init__( self )
        count = 0
        self.params = ""
        for i in params:
            self.params = "%s %s" % ( self.params, str( i ) )
            count += 1
        if ( count != 1 ) and ( count != 3 ) and ( count != 4 ):
            raise Exception( "Bad Format of params %s" % count )
        
    def __repr__( self ):
        res = "=conical %s " % self.params
        if not ( len( self.lColors ) ):
            raise Exception( "Bad Format, must have  one color less" )
        res = "%s | %s" % ( res, Colors.__repr__( self ) )
        return res
                
        
# ---- self-test ----------------------------------------------------------
if __name__ == '__main__':
  from Tkinter import *
  import Zinc
  def createItem( zinc, group, ev ):
    print >> sys.stdout, "CreateIHM"
    sys.stdout.flush()
    Zinc.Rectangle( zinc, group, 
             ( 100, 100, 150, 150 ), 
             linewidth = "10", linecolor = '#FFFF00', 
             relief = "roundgroove", filled = 1, 
             fillcolor = "red", tags = ( "hello", "test" ) )
    sys.stdout.write( "hello_clic" + str( ev ) )
    
  z  = Zinc.Zinc( master = None, render = 1, height = 200, width = 400 )
  g1 = Zinc.Group( z, 1 ) 
  r  = Zinc.Rectangle( z, g1, ( 0, 0, 400, 200 ), 
                 linewidth = "10", 
                 linecolor = '#FFFF00', 
                 relief    = "roundgroove", 
                 filled    = 1, 
                 fillcolor = "#FFFFFF", 
                 tags      = ( "hello", "test" ) )
  t = Zinc.Text( z, g1, position = ( 40, 100 ), text = z.version )
# z.bind_tag("hello","<1>",lambda ev,z=z,g=g1 : createItem(z,g,ev)) 
  z.configure( backcolor = 'black' )
  z.pack()
  z.mainloop()

# Zinc.py ends here

