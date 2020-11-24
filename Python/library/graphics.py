# -*- coding: iso-8859-1 -*-
"""
#-------------------------------------------------------------------------------
#
#      Graphics.py
#      some graphic design functions
#
#-------------------------------------------------------------------------------
#  Functions to create complexe graphic component :
#  ------------------------------------------------
#      build_zinc_item          (realize a zinc item from description hash table
#                              management of enhanced graphics functions)
#
#      repeat_zinc_item         (duplication of given zinc item)
#
#  Function to compute complexe geometrical forms :
#  (text header of functions explain options for each form,
#  function return curve coords using control points of cubic curve)
#  -----------------------------------------------------------------
#     rounded_rectangle_coords (return curve coords of rounded rectangle)
#     hippodrome_coords       (return curve coords of circus form)
#     ellipse_coords          (return curve coords of ellipse form)
#     polygon_coords          (return curve coords of regular polygon)
#     roundedcurve_coords     (return curve coords of rounded curve)
#     polyline_coords         (return curve coords of polyline)
#     shiftpath_coords        (return curve coords of shifting path)
#     tabbox_coords           (return curve coords of tabbox's pages)
#     pathline_coords         (return triangles coords of pathline)
#
#  Function to compute 2D 1/2 relief and shadow :
#  function build zinc items (triangles and curve) to simulate this
#  -----------------------------------------------------------------
#     graphicitem_relief    (return triangle items simulate relief of given item)
#     polyline_relief_params (return triangle coords
#                           and lighting triangles color list)
#     graphicitem_shadow    (return triangles and curve items
#                           simulate shadow of given item))
#     polyline_shadow_params (return triangle and curve coords
#                           and shadow triangles color list))
#
#
#-------------------------------------------------------------------------------
#      Authors: Jean-Luc Vinot <vinot@cena.fr>
#      PM2PY: Guillaume Vidon <vidon@ath.cena.fr> 
#
# $Id$ 
#-------------------------------------------------------------------------------
"""
VERSION = "1.0"
__revision__ = "0.1"

import logging
import types
import re
from geometry import *
from pictorial import *
from math import pi, radians, atan2, sqrt, sin, cos

graphiclogger = logging.getLogger('Graphics')
debug = graphiclogger.debug
error = graphiclogger.error
exception = graphiclogger.exception
log = lambda msg : graphiclogger.log(logging.DEBUG, msg)

# constante facteur point directeur (conique -> quadratique)
const_ptd_factor = .5523

def transdic(**dict):
    newdic={}
    for key, val in dict.items():
        if (type(val) is types.ListType):
            newdic[key] = tuple(val)
        else:
            newdic[key] = val
    return newdic
    
def is_flat_list(apts):
    if reduce(lambda x, y : x and (type(y) in ( types.FloatType, types.IntType)),
              apts):
        if len(apts) % 2:
            raise ValueError("Not a valid Coords list")
        else :
            return True
    else :
        return False

def is_point(apoint):
    if (type(apoint) in ( types.TupleType, types.ListType)):
        if len(apoint) == 2 :
            if reduce(lambda x, y : x and (type(y) in ( types.FloatType, types.IntType)),
                      apts):
                return True
            else :
                return False
        elif reduce(lambda x, y : x and (type(y) in ( types.FloatType, types.IntType)),
                    apts[:-1])\
                    and type(apts[-1]) in ('c', 'n'):
            return True
        else :
            return False
    else :
        return False
                
# def is_tuple_list(apts):
#     if reduce(lambda x, y : x \
#               and is_point(x)),
#               apts):
                  
    
def lpts2coords(lpts):
    coords = []
    if (type(lpts) in ( types.TupleType, types.ListType )):
        for point in lpts :
            coords.append(tuple(point))
    return tuple(coords)
            
def coords2lpts(coords):
    lpts = []
    if (type(coords) in ( types.TupleType, types.ListType )):
        for point in coords :
            lpts.append(list(point))
    else :
        raise ValueError("Invalid Coords %s "%coords)
    return lpts

def build_zinc_item(widget, pgroup = 1, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::build_zinc_item
    # Création d'un objet Zinc de représentation
    #---------------------------------------------------------------------------
    # types d'items valides :
    # les items natifs zinc : group, rectangle, arc, curve, text, icon
    # les items ci-après permettent de spécifier des curves 'particulières' :
    # -roundedrectangle : rectangle à coin arrondi
    #       -hippodrome : hippodrome
    #          -ellipse : ellipse un centre 2 rayons
    #         -polygone : polygone régulier à n cotés (convexe ou en étoile)
    #     -roundedcurve : curve multicontours à coins arrondis (rayon unique)
    #         -polyline : curve multicontours à coins arrondis (le rayon pouvant
    #                     être défini 
    #                     spécifiquement pour chaque sommet)
    #         -pathline : création d'une ligne 'épaisse' avec l'item Zinc 
    #                     triangles décalage par rapport à un chemin donné 
    #                     (largeur et sens de décalage)
    #                     dégradé de couleurs de la ligne (linéaire, transversal
    #                     ou double)
    #---------------------------------------------------------------------------
    # paramètres :
    # widget : <widget> identifiant du widget Zinc
    # parentgroup : <tagOrId> identifiant du group parent
    #
    # options :
    #   -itemtype : type de l'item à construire (type zinc ou metatype)
    #     -coords : <coords|coordsList> coordonnées de l'item
    # -metacoords : <hastable> calcul de coordonnées par type 
    #               d'item différent de itemtype
    #   -contours : <contourList> paramètres multi-contours
    #     -params : <hastable> arguments spécifiques de l'item à passer
    #               au widget
    #    -addtags : [list of specific tags] to add to params -tags
    #    -texture : <imagefile> ajout d'une texture à l'item
    #    -pattern : <imagefile> ajout d'un pattern à l'item
    #     -relief : <hastable> création d'un relief à l'item invoque la fonction
    #               graphicitem_relief()
    #     -shadow : <hastable> création d'une ombre portée à l'item invoque
    #               la fonction graphicitem_shadow()
    #      -scale : <scale_factor|[xscale_factor,yscale_factor]> application
    #               d'une transformation zinc->scale à l'item
    #  -translate : <[delta_x,delta_y]> application d'un transformation zinc->translate
    #               à l'item.
    #     -rotate : <angle> application d'une transformation zinc->rotate
    #               (en degré) à l'item
    #       -name : <str> nom de l'item
    #               spécifiques item group :
    #       -clip : <coordList|hashtable> paramètres de clipping d'un item group
    #               (coords ou item)
    #      -items : <hashtable> appel récursif de la fonction permettant
    #               d'inclure des items au groupe
    #---------------------------------------------------------------------------
    #
    #---------------------------------------------------------------------------
    """

    if options.has_key('parentgroup'):
        parentgroup = options['parentgroup']
    else :
        parentgroup = pgroup
    try:
        itemtype = options['itemtype']
    except KeyError:
        raise ValueError("Must have itemtype option")
    try:
        coords = options['coords']
    except KeyError:
        try:
            coords = options['metacoords']
        except KeyError :
            raise ValueError("Must have coords or metacoords option")
        
    if options.has_key('params'):
        params = options['params']
    else:
        params = {}

    #return unless($widget and $itemtype
    #and ($coords or $options{'-metacoords'}))

    try:
        name = options['name']
    except KeyError:
        name = None

    item = None
    metatype = None
    items = []
    reliefs = []
    shadows = []
    tags = []

    #--------------------
    # GEOMETRIE DES ITEMS

    # gestion des types d'items particuliers et à raccords circulaires
    if (itemtype in ( 'roundedrectangle',
                      'hippodrome',
                      'polygone',
                      'ellipse',
                      'roundedcurve',
                      'polyline',
                      'curveline')):

        # par défaut la curve sera fermée -closed = 1
        if not params.has_key('closed'):
            params['closed'] = 1
        metatype = itemtype
        itemtype = 'curve'

        # possibilité de définir les coordonnées initiales par metatype
        if (options.has_key('metacoords')) :
            options['coords'] = meta_coords( **options['metacoords'])

    # création d'une pathline à partir d'item zinc triangles
    elif (itemtype == 'pathline') :
        itemtype = 'triangles'
        if (options.has_key('metacoords')) :
            coords = meta_coords( **options['metacoords'])
          
        if (options.has_key('graduate')) :
            numcolors = len(coords)
            lcolors = path_graduate(widget,
                                    numcolors,
                                    options['graduate'])
            params['colors'] = tuple(lcolors)

        if options.has_key('coords'):
            coords = pathline_coords(**options)
        else:
            coords = pathline_coords(coords, **options)

        # création d'une boite à onglet
    elif (itemtype == 'tabbox') :
        return build_tabboxitem(widget, parentgroup, **options)

    # calcul des coordonnées finales de la curve
    if (metatype is not None):
        coords = meta_coords(type = metatype, **options)


    # gestion du multi-contours (accessible pour tous les types
    # d'items géometriques)
    if (options.has_key('contours') and (metatype is not None)) :
        lcontours = options['contours']
        contours=[]
        numcontours = len(contours)
        for contour in lcontours:
            # radius et corners peuvent être défini
            # spécifiquement pour chaque contour
            (atype, way, addcoords,) = contour[:3]
            if len(contour) >= 4:
                radius = contour[3]
            else :
                radius = None
            if len(contour) >= 5:
                corners = contour[4]
            else:
                corners = None
            if len(contour) >= 6:
                corners_radius = contour[5]
            else :
                corners_radius = None
            if (radius is None):
                if options.has_key('radius'):
                    radius = options['radius']
                else :
                    raise ValueError("radius option requiered")

            newcoords = meta_coords(type = metatype,
                                    coords = addcoords,
                                    radius = radius,
                                    corners = corners,
                                    corners_radius = corners_radius
                                    )
            contours.append((atype, way, newcoords))

        options['contours'] = contours

    #----------------------
    # REALISATION DES ITEMS

    # ITEM GROUP
    # gestion des coordonnées et du clipping
    if (itemtype == 'group') :
        item = widget.add(itemtype,
                          parentgroup,
                          **params)
        widget.addtag_withtag(name, item)
        if coords:
            widget.coords(item, tuple(coords))

        # clipping du groupe par item ou par géometrie
        if (options.has_key('clip')) :
            clipbuilder = options['clip']
            clip = None

            # création d'un item de clipping
            if (type(clipbuilder) is types.DictType
                and clipbuilder.has_key('itemtype')):
                clip = build_zinc_item(widget, item, **clipbuilder)

            elif (type(clipbuilder) in (types.TupleType, types.ListType)
                  or widget.type(clipbuilder)) :
                clip = clipbuilder

            if (clip):
                widget.itemconfigure(item, clip = clip)

        # créations si besoin des items contenus dans le groupe
        if (options.has_key('items')
            and type(options['items']) is types.DictType) :
            for (itemname, itemstyle) in options['items'].items() :
                if not itemstyle.has_key('name'):
                    itemstyle['name'] = itemname
                build_zinc_item(widget, item, **itemstyle)


    # ITEM TEXT ou ICON
    elif (itemtype in ('text', 'icon')) :
        imagefile = None
        if (itemtype == 'icon') :
            imagefile = params['image']
            image = get_image(widget, imagefile)
            if (image) :
                params['image'] = image
            else:
                params['image'] = ""
    

        item = widget.add(itemtype,
                          parentgroup,
                          position = coords,
                          **params
                          )
        if imagefile:
            params['image'] = imagefile 


    # ITEMS GEOMETRIQUES -> CURVE
    else :
        nparams=params
        item = widget.add(itemtype,
                          parentgroup,
                          lpts2coords(coords),
                          **params
                          )

        if (itemtype == 'curve' and options.has_key('contours')) :
            for contour in options['contours'] :
                contour = list(contour)
                contour[2] = tuple(contour[2])
                widget.contour(item, *contour)
                             
        # gestion du mode norender
        if (options.has_key('texture')) :
            texture = get_texture(widget, options['texture'])
            if texture:
                widget.itemconfigure(item, tile = texture)

        if (options.has_key('pattern')) :
            bitmap = get_pattern(**options['pattern'])
            if bitmap:
                widget.itemconfigure(item, fillpattern = bitmap)

    # gestion des tags spécifiques
    if (options.has_key('addtags')) :
        tags = options['addtags']

        params_tags = params['tags']
        if params_tags:
            tags.extend(params_tags) 

        widget.itemconfigure(item, tags = tags)

    #-------------------------------
    # TRANSFORMATIONS ZINC DE L'ITEM

    # transformation scale de l'item si nécessaire
    if (options.has_key('scale')) :
        scale = options['scale']
        if (type(scale) is not types.TupleType) :
            scale = (scale, scale) 
        widget.scale(item, scale)
  

    # transformation rotate de l'item si nécessaire
    if (options.has_key('rotate')):
        widget.rotate(item, radians(options['rotate'])) 

    # transformation translate de l'item si nécessaire
    if (options.has_key('translate')):
        widget.translate(item, options['translate'])


    # répétition de l'item
    if (options.has_key('repeat')) :
        items.extend((item,
                      repeat_zinc_item(widget, item, **options['repeat'])))

    #-----------------------
    # RELIEF ET OMBRE PORTEE

    # gestion du relief
    if (options.has_key('relief')) :
        if (len(items)) :
            target = items
        else:
            target = item
        reliefs.extend(graphicitem_relief(widget,
                                          target, **options['relief']))

    # gestion de l'ombre portée
    if (options.has_key('shadow')) :
        if (len(items)) :
            target = items
        else:
            target = item
        shadows.extend(graphicitem_shadow(widget,
                                         target, **options['shadow']))
  

    if len(reliefs):
        items.extend(reliefs)
    if len(shadows):
        items.extend(shadows)

    if len(items):
        return items
    else:
        return item

def repeat_zinc_item(widget,
                     item,
                     num = 2,
                     dxy = (0,0),
                     angle = None,
                     params = None,
                     copytag = None) :
    """
    #---------------------------------------------------------------------------
    # Graphics::repeat_zinc_item
    # Duplication (clonage) d'un objet Zinc de représentation
    #---------------------------------------------------------------------------
    # paramètres :
    # widget : <widget> identifiant du widget zinc
    #   item : <tagOrId> identifiant de l'item source
    # options :
    #     -num : <n> nombre d'item total (par defaut 2)
    #     -dxy : <[delta_x, delta_y]> translation entre 2 duplications (par defaut [0,0])
    #   -angle : <angle> rotation entre 2 duplications
    # -copytag : <sting> ajout d'un tag indexé pour chaque copie
    #  -params : <hashtable> {clef => [value list]}> valeur de paramètre
    #            de chaque copie
    #---------------------------------------------------------------------------
    """
    clones = []
    delta_x, delta_y = dxy
    # duplication d'une liste d'items -> appel récursif
    if (type(item) in (types.TupleType, types.ListType)) :
        for part in item :
            clones.append(repeat_zinc_item(widget,
                                           part,
                                           dxy,
                                           angle,
                                           params,
                                           copytag))

        return clones

    tags = []

    if (copytag) :
        tags = widget.itemcget(item, 'tags')
        widget.itemconfigure(item, tags = tags + ("%s0"%copytag,))

    for i in xrange(1, num) :
        clone = None

        if (copytag) :
            clone = widget.clone(item, tags = tags + ("%s%s"%(copytag, i),))
        else :
            clone = widget.clone(item)

        clones.append(clone)
        widget.translate(clone, delta_x*i, delta_y*i)
        if angle :
            widget.rotate(clone, radians(angle*i))

        if (params is not None ) :
            widget.itemconfigure(clone, **params )
    return clones


#MUST BE TESTED
def meta_coords( type,
                 coords,
                 **options ):
    """
    #---------------------------------------------------------------------------
    # FONCTIONS GEOMETRIQUES
    #---------------------------------------------------------------------------
    
    #---------------------------------------------------------------------------
    # Graphics::meta_coords
    # retourne une liste de coordonnées en utilisant la fonction du type
    # d'item spécifié
    #---------------------------------------------------------------------------
    # paramètres : (passés par %options)
    #   -type : <string> type de primitive utilisée
    # -coords : <coordsList> coordonnées nécessitée par la fonction [type]_coords
    #
    # les autres options spécialisées au type seront passés
    # à la fonction [type]coords
    #---------------------------------------------------------------------------
    """
    pts = None

    if (type == 'roundedrectangle'):
        log('Coords for roundedrectangle')
        pts = rounded_rectangle_coords(coords, **options)

    elif (type == 'hippodrome') :
        log('Coords for hippodrome')
        pts = hippodrome_coords(coords, **options)

    elif (type == 'ellipse') :
        log('Coords for ellipse')
        pts = ellipse_coords(coords, **options)

    elif (type == 'roundedcurve') :
        log('Coords for roundedcurve')
        pts = roundedcurve_coords(coords, **options)

    elif (type == 'polygone') :
        log('Coords for polygone')
        pts = polygon_coords(coords, **options)

    elif (type == 'polyline') :
        log('Coords for polyline')
        pts = polyline_coords(coords, **options)
    
    elif (type == 'curveline') :
        log('Coords for curveline')
        pts = curveline_coords(coords, **options)

    return pts


def zincitem_2_curvecoords( widget, item,
                            linear = 0,
                            realcoords = 0,
                            adjust = 1,
                            ):
    """
    #--------------------------------------------------------------------------
    # Graphics::zincitem_2_curvecoords
    # retourne une liste des coordonnées 'Curve' d'un l'item Zinc
    # rectangle, arc ou curve
    #--------------------------------------------------------------------------
    # paramètres :
    # widget : <widget> identifiant du widget zinc
    #   item : <tagOrId> identifiant de l'item source
    # options :
    #     -linear : <boolean> réduction à des segments non curviligne
    #               (par défaut 0)
    # -realcoords : <boolean> coordonnées à transformer dans le groupe père
    #               (par défaut 0)
    #     -adjust : <boolean> ajustement de la courbe de bezier (par défaut 1)
    #--------------------------------------------------------------------------
    """
    itemtype = widget.type(item)

    if not itemtype :
        raise ValueError("Not a Valid Item %s" % item)

    itemcoords = widget.coords(item)
    coords = None
    multi = []

    if (itemtype == 'rectangle') :
        coords = rounded_rectangle_coords(itemcoords, radius = 0)

    elif (itemtype == 'arc') :
        coords = ellipse_coords(itemcoords)
        if linear :
            coords = curve2polyline_coords(coords, adjust) 

    elif (itemtype == 'curve') :
        numcontours = widget.contour(item)

        if (numcontours < 2) :
            if linear:
                coords = curve2polyline_coords(itemcoords, adjust)
        else :
            if (linear) :
                multi = curveitem2polyline_coords(widget, item)

            else :
                for contour in xrange(0, numcontours):
                    points = widget.coords(item, contour)
                    multi.extend(points)
            coords = multi

    if (realcoords) :
        parentgroup = widget.group(item)
        if (len(multi)) :
            newcoords = []
            for points in multi :
                transcoords = widget.transform(item, parentgroup, points)
                newcoords.extend(transcoords)
            coords = newcoords
        else :
            transcoords =  widget.transform(item, parentgroup, coords)
            coords = transcoords

    return coords

def rounded_rectangle_coords( coords, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::rounded_rectangle_coords
    # calcul des coords du rectangle à coins arrondis
    #---------------------------------------------------------------------------
    # paramètres :
    # coords : <coordsList> coordonnées bbox (haut-gauche et bas-droite)
    #          du rectangle
    # options :
    #  -radius : <dimension> rayon de raccord d'angle
    # -corners : <booleanList> liste des raccords de sommets
    #            [0 (aucun raccord)|1] par défaut [1,1,1,1]
    #---------------------------------------------------------------------------
    """
    (x_0, y_0, x_n, y_n) = (coords[0][0], coords[0][1],
                        coords[1][0], coords[1][1])

    if (options.has_key('radius')):
        radius = options['radius']
    else:
        radius = None
  
    if (options.has_key('corners')):
        corners = options['corners']
    else:
        corners = [1, 1, 1, 1]

    # attention aux formes 'négatives'
    if (x_n < x_0) :
        (x_0, x_n) = (x_n, x_0)
      
    if (y_n < y_0) :
        (y_0, y_n) = (y_n, y_0)

    height = min(x_n -x_0, y_n - y_0)
    #radius non defini dans les parametres
    if (radius is None) :
        radius = int(height/10)
        radius = max(radius, 3)
      
    #radius defini mais trop petit
    if ( radius < 2) :
        return ((x_0, y_0), (x_0, y_n), (x_n, y_n), (x_n, y_0))

    # correction de radius si necessaire
    max_rad = height
    #CODE BIZARRE
    #Comment corners ne peut être non défini
    #a ce niveau ?
    #  max_rad /= 2 if (!defined corners)
    if (corners is None):
        max_rad /= 2
    radius = min(max_rad, radius)

    # points remarquables
    ptd_delta = radius * const_ptd_factor
    (x_2, x_3) = (x_0 + radius, x_n - radius)
    (x_1, x_4) = (x_2 - ptd_delta, x_3 + ptd_delta)
    (y_2, y_3) = (y_0 + radius, y_n - radius)
    (y_1, y_4) = (y_2 - ptd_delta, y_3 + ptd_delta)

    # liste des 4 points sommet du rectangle : angles sans raccord circulaire
    angle_pts = ((x_0, y_0), (x_0, y_n), (x_n, y_n), (x_n, y_0))

    # liste des 4 segments quadratique : raccord d'angle = radius
    roundeds = [[(x_2, y_0), (x_1, y_0, 'c'), (x_0, y_1, 'c'), (x_0, y_2),],
                [(x_0, y_3), (x_0, y_4, 'c'), (x_1, y_n, 'c'), (x_2, y_n),],
                [(x_3, y_n), (x_4, y_n, 'c'), (x_n, y_4, 'c'), (x_n, y_3),],
                [(x_n, y_2), (x_n, y_1, 'c'), (x_4, y_0, 'c'), (x_3, y_0),]]

    pts = []
    previous = None
    for i  in xrange(0, 4):
        #BUGS ??
        if (corners[i]):
            if (previous is not None) :
                # on teste si non duplication de point
                (nx, ny) = roundeds[i][0]
                if (previous[0] == nx and previous[1] == ny) :
                    pts.pop()
            pts.extend(roundeds[i])
            previous = roundeds[i][3]
        else :
            pts.append(angle_pts[i])

    return pts

def ellipse_coords(coords, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::ellipse_coords
    # calcul des coords d'une ellipse
    #---------------------------------------------------------------------------
    # paramètres :
    # coords : <coordsList> coordonnées bbox du rectangle exinscrit
    # options :
    # -corners : <booleanList> liste des raccords de sommets
    # [0 (aucun raccord)|1] par défaut [1,1,1,1]
    #---------------------------------------------------------------------------
    """
    (x_0, y_0, x_n, y_n) = (coords[0][0], coords[0][1],
                        coords[1][0], coords[1][1])

    if options.has_key('corners') :
        corners = options.has_key('corners')
    else:
        corners = [1, 1, 1, 1]

    # attention aux formes 'négatives'
    if (x_n < x_0) :
        xs = x_0
        (x_0, x_n) = (x_n, xs)
    if (y_n < y_0) :
        ys = y_0
        (y_0, y_n) = (y_n, ys)

    # points remarquables
    delta_x = (x_n - x_0)/2 * const_ptd_factor
    delta_y = (y_n - y_0)/2 * const_ptd_factor
    (x_2, y_2) = ((x_0+x_n)/2, (y_0+y_n)/2)
    (x_1, x_3) = (x_2 - delta_x, x_2 + delta_x)
    (y_1, y_3) = (y_2 - delta_y, y_2 + delta_y)

    # liste des 4 points sommet de l'ellipse : angles sans raccord circulaire
    angle_pts = ((x_0, y_0), (x_0, y_n), (x_n, y_n), (x_n, y_0))

    # liste des 4 segments quadratique : raccord d'angle = arc d'ellipse
    roundeds = (((x_2, y_0), (x_1, y_0, 'c'), (x_0, y_1, 'c'), (x_0, y_2), ),
                ((x_0, y_2), (x_0, y_3, 'c'), (x_1, y_n, 'c'), (x_2, y_n), ),
                ((x_2, y_n), (x_3, y_n, 'c'), (x_n, y_3, 'c'), (x_n, y_2), ),
                ((x_n, y_2), (x_n, y_1, 'c'), (x_3, y_0, 'c'), (x_2, y_0), ))

    pts = []
    previous = None
    for i in xrange(0, 4):
        if (corners[i]) :
            if (previous) :
                # on teste si non duplication de point
                (nx, ny) = roundeds[i][0]
                if (previous[0] == nx and previous[1] == ny) :
                    pts.pop()
            
            
            pts.extend(roundeds[i])
            previous = roundeds[i][3]

        else :
            pts.append(angle_pts[i])

    return pts


def hippodrome_coords(coords, **options) :
    """
    #---------------------------------------------------------------------------
    # Graphics::hippodrome_coords
    # calcul des coords d'un hippodrome
    #---------------------------------------------------------------------------
    # paramètres :
    # coords : <coordsList> coordonnées bbox du rectangle exinscrit
    # options :
    # -orientation : orientation forcée de l'hippodrome [horizontal|vertical]
    #     -corners : liste des raccords de sommets [0|1] par défaut [1,1,1,1]
    #       -trunc : troncatures [left|right|top|bottom|both]
    #---------------------------------------------------------------------------
    """
    (x_0, y_0, x_n, y_n) = (coords[0][0],
                            coords[0][1],
                            coords[1][0],
                            coords[1][1])

    if (options.has_key('orientation')) :
        orientation = options['orientation']
    else:
        orientation = 'none'

    # orientation forcée de l'hippodrome
    # (sinon hippodrome sur le plus petit coté)
    if (orientation == 'horizontal') :
        height = abs(y_n - y_0)
    elif (orientation == 'vertical') :
        height = abs(x_n - x_0)
    else:
        height = min(abs(x_n - x_0), abs(y_n - y_0))
    radius = height/2
    corners = (1, 1, 1, 1)

    if  (options.has_key('corners')) :
        corners = options['corners']

    elif (options.has_key('trunc')) :
        trunc = options['trunc']
        if (trunc == 'both') :
            return ((x_0, y_0), (x_0, y_n), (x_n, y_n), (x_n, y_0))
        else :
            if (trunc == 'left'):
                corners = (0, 0, 1, 1)
            elif (trunc == 'right'):
                corners = (1, 1, 0, 0)
            elif (trunc == 'top'):
                corners = (0, 1, 1, 0)
            elif (trunc == 'bottom') :
                corners = (1, 0, 0, 1)
            else :
                corners = (1, 1, 1, 1)

    # l'hippodrome est un cas particulier de roundedRectangle
    # on retourne en passant la 'configuration' à la fonction
    # générique rounded_rectangle_coords
    return rounded_rectangle_coords(coords,
                                  radius = radius,
                                  corners = corners)

def polygon_coords(coords, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::polygon_coords
    # calcul des coords d'un polygone régulier
    #---------------------------------------------------------------------------
    # paramètres :
    # coords : <coords> point centre du polygone
    # options :
    #      -numsides : <integer> nombre de cotés
    #        -radius : <dimension> rayon de définition du polygone
    #                  (distance centre-sommets)
    #  -inner_radius : <dimension> rayon interne (polygone type étoile)
    #       -corners : <booleanList> liste des raccords de sommets [0|1]
    #                  par défaut [1,1,1,1]
    # -corner_radius : <dimension> rayon de raccord des cotés
    #    -startangle : <angle> angle de départ en degré du polygone
    #---------------------------------------------------------------------------
    """
    if options.has_key('numsides'):
        numsides = options['numsides']
    else :
        numsides = 0
    if options.has_key('radius'):
        radius = options['radius']
    else:
        radius = None
    if (numsides < 3 or not radius) :
        raise ValueError("Vous devez au moins spécifier "
                         +"un nombre de cotés >= 3 et un rayon...\n")

    if (coords is None):
        coords = (0, 0)
    if (options.has_key('startangle')) :
        startangle = options['startangle']
    else:
        startangle = 0
    anglestep = 360/numsides
    if options.has_key('inner_radius'):
        inner_radius = options['inner_radius']
    else:
        inner_radius = None
    pts = []

    # points du polygone
    for i in xrange(0, numsides):
        (xp, yp) = rad_point(coords, radius, startangle + (anglestep*i))
        pts.append((xp, yp))

        # polygones 'étoiles'
        if (inner_radius) :
            (xp, yp) = rad_point(coords, inner_radius,
                                 startangle + (anglestep*(i+ 0.5)))
            pts.append((xp, yp))
    
    pts.reverse()

    if (options.has_key('corner_radius')) :
        if options.has_key('corners'):
            corners = options['corners']
        else:
            corners = None
        return roundedcurve_coords(pts,
                                   radius = options['corner_radius'],
                                   corners = corners)
    else :
        return pts


def rounded_angle(widget, parentgroup, coords, radius) :
    """
    #---------------------------------------------------------------------------
    # Graphics::rounded_angle
    # THIS FUNCTION IS NO MORE USED, NEITHER EXPORTED
    # curve d'angle avec raccord circulaire
    #---------------------------------------------------------------------------
    # paramètres :
    # widget : identifiant du widget Zinc
    # parentgroup : <tagOrId> identifiant de l'item group parent
    # coords : <coordsList> les 3 points de l'angle
    # radius : <dimension> rayon de raccord
    #---------------------------------------------------------------------------
    """
    (pt0, pt1, pt2) = coords

    (corner_pts, center_pts) = rounded_angle_coords(coords, radius)
    (cx_0, cy_0) = center_pts

    if (parentgroup is None) :
        parentgroup = 1 

    pts = [pt0]
    pts.extend(corner_pts)
    pts.append(pt2)
    
    widget.add('curve',
               parentgroup,
               lpts2coords(pts),
               closed = 0,
               linewidth = 1,
               priority = 20,
               )


def rounded_angle_coords (coords, radius) :
    """
    #---------------------------------------------------------------------------
    # Graphics::rounded_angle_coords
    # calcul des coords d'un raccord d'angle circulaire
    #---------------------------------------------------------------------------
    # le raccord circulaire de 2 droites sécantes est traditionnellement
    # réalisé par un
    # arc (conique) du cercle inscrit de rayon radius tangent à ces 2 droites
    #
    # Quadratique :
    # une approche de cette courbe peut être réalisée simplement par le calcul
    # de 4 points
    # spécifiques qui définiront - quelle que soit la valeur de l'angle formé
    # par les 2
    # droites - le segment de raccord :
    # - les 2 points de tangence au cercle inscrit seront les points de début
    #   et de fin
    # du segment de raccord
    # - les 2 points de controle seront situés chacun sur le vecteur
    #   reliant le point de
    # tangence au sommet de l'angle (point secant des 2 droites)
    # leur position sur ce vecteur peut être simplifiée comme suit :
    # - à un facteur de 0.5523 de la distance au sommet pour
    #   un angle >= 90° et <= 270°
    # - à une 'réduction' de ce point vers le point de tangence
    #   pour les angles limites
    # de 90° vers 0° et de 270° vers 360°
    # ce facteur sera légérement modulé pour recouvrir plus précisement
    # l'arc correspondant
    #---------------------------------------------------------------------------
    # coords : <coordsList> les 3 points de l'angle
    # radius : <dimension> rayon de raccord
    #---------------------------------------------------------------------------
    """
    (pt0, pt1, pt2) = coords

    # valeur d'angle et angle formé par la bisectrice
    (angle, bisecangle)  = vertex_angle(pt0, pt1, pt2)

    # distance au centre du cercle inscrit : rayon/sinus demi-angle
    asin = sin(radians(angle/2))
    
    if (asin) :
        delta = abs(radius / asin)
    else:
        delta = radius

    # point centre du cercle inscrit de rayon $radius
    if (angle < 180) :
        refangle = bisecangle + 90
    else :
        refangle = bisecangle - 90
        
    (cx_0, cy_0) = rad_point(pt1, delta, refangle)

    # points de tangeance : pts perpendiculaires du centre aux 2 droites
    (px_1, py_1) = perpendicular_point((cx_0, cy_0), (pt0, pt1))
    (px_2, py_2) = perpendicular_point((cx_0, cy_0), (pt1, pt2))

    # point de controle de la quadratique
    # facteur de positionnement sur le vecteur pt.tangence, sommet
    ptd_factor =  const_ptd_factor
    if (angle < 90 or angle > 270) :
        if (angle < 90) :
            diffangle = angle
        else:
            diffangle =  360 - angle
        if (diffangle > 15) :
            ptd_factor -= (((90 - diffangle)/90) * (ptd_factor/4)) 
        ptd_factor = (diffangle/90) * (ptd_factor
                                       + ((1 - ptd_factor)
                                          * (90 - diffangle)/90))
    else :
        diffangle = abs(180 - angle)
        if (diffangle > 15) :
            ptd_factor += (((90 - diffangle)/90) * (ptd_factor/3))

    # delta xy aux pts de tangence
    (d1x, d1y) = ((pt1[0] - px_1) * ptd_factor, (pt1[1] - py_1) *  ptd_factor)
    (d2x, d2y) = ((pt1[0] - px_2) * ptd_factor, (pt1[1] - py_2) *  ptd_factor)

    # les 4 points de l'arc 'quadratique'
    corner_pts = [(px_1, py_1), (px_1+d1x, py_1+d1y, 'c'),
                  (px_2+d2x, py_2+d2y, 'c'), (px_2, py_2)]

    
    # retourne le segment de quadratique et le centre du cercle inscrit
    return (corner_pts, (cx_0, cy_0))


def roundedcurve_coords(coords, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::roundedcurve_coords
    # retourne les coordonnées d'une curve à coins arrondis
    #---------------------------------------------------------------------------
    # paramètres :
    # coords : <coordsList> liste de coordonnées des points de la curve
    # options :
    #  -radius : <dimension> rayon de raccord d'angle
    #  -corners : <booleanList> liste des raccords de sommets [0|1]
    # par défaut [1,1,1,1]
    #---------------------------------------------------------------------------
    """
    numfaces = len(coords)
    curve_pts = []

    if (options.has_key('radius')) :
        radius = options['radius']
    else:
        radius = 0
    corners = None
    if options.has_key('corners') :
        corners = options['corners']

    for index in xrange(numfaces):
        if (corners is not None) :
            if (index+1 > len(corners)) or not corners[index] :
                curve_pts.append(coords[index])
                continue

        if (index) :
            prev = index - 1
        else :
            prev = numfaces - 1
        if (index > numfaces - 2) :
            next = 0
        else :
            next = index + 1
        anglecoords = (coords[prev], coords[index], coords[next])
            
        quad_pts = rounded_angle_coords(anglecoords, radius)[0]
        curve_pts.extend(quad_pts)
    return curve_pts


def polyline_coords(coords, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::polyline_coords
    # retourne les coordonnées d'une polyline
    #---------------------------------------------------------------------------
    # paramètres :
    # coords : <coordsList> liste de coordonnées des sommets de la polyline
    # options :
    #  -radius : <dimension> rayon global de raccord d'angle
    # -corners : <booleanList> liste des raccords de sommets [0|1]
    #            par défaut [1,1,1,1],
    # -corners_radius : <dimensionList> liste des rayons de raccords de sommets
    #---------------------------------------------------------------------------
    """
    numfaces = len(coords)
    curve_pts = []

    if (options.has_key('radius')) :
        radius = options['radius']
    else:
        radius = 0
    if options.has_key('corners_radius'):
        corners_radius = options['corners_radius']
        corners = corners_radius
    else:
        corners_radius = None
        if options.has_key('corners'):
            corners = options['corners']
        else:
            corners = None

    for index in xrange(0, numfaces):
        if (corners is not None
            and (len(corners) - 1 < index
                 or not corners[index])):
            curve_pts.append(coords[index])
        else :
            if (index) :
                prev = index - 1
            else:
                prev = numfaces - 1
            if (index > numfaces - 2) :
                next = 0
            else:
                next = index + 1
            anglecoords = (coords[prev], coords[index], coords[next])

            if (corners_radius) :
                rad = corners_radius[index]
            else:
                rad = radius
            quad_pts = rounded_angle_coords(anglecoords, rad)[0]
            curve_pts.extend(quad_pts)

    return curve_pts

def pathline_coords (coords, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::pathline_coords
    # retourne les coordonnées d'une pathline
    #---------------------------------------------------------------------------
    # paramètres :
    # coords : <coordsList> liste de coordonnées des points du path
    # options :
    #    -closed : <boolean> ligne fermée
    #  -shifting : <out|center|in> sens de décalage du path (par défaut center)
    # -linewidth : <dimension> epaisseur de la ligne
    #---------------------------------------------------------------------------
    """
    numfaces = len(coords)
    pts = []

    if options.has_key('closed'):
        closed = options['closed']
    else:
        closed = None
    if (options.has_key('linewidth')) :
        linewidth = options['linewidth']
    else:
        linewidth = 2
          
    if (options.has_key('shifting')) :
        shifting = options['shifting']
    else:
        shifting = 'center'

    if ( not numfaces or linewidth < 2):
        raise ValueError("Invalid PathLine_coords")

    if (closed) :
        previous = coords[numfaces - 1]
    else:
        previous = None
      
    next = coords[1]
    if (shifting == 'center'):
        linewidth /= 2

    for i in xrange(0, numfaces):
        pt = coords[i]

        if (previous is None) :
            # extrémité de curve sans raccord -> angle plat
            previous = (pt[0] + (pt[0] - next[0]), pt[1] + (pt[1] - next[1]))

        (angle, bisecangle) = vertex_angle(previous, pt, next)

        # distance au centre du cercle inscrit : rayon/sinus demi-angle
        asin = sin(radians(angle/2))
        if (asin) :
            delta = abs(linewidth / asin)
        else:
            delta = linewidth

        if (shifting == 'out' or shifting == 'in') :
            if (shifting == 'out') :
                adding = -90
            else:
                adding = 90
            pts.append(rad_point(pt, delta, bisecangle + adding))
            pts.append(pt)

        else :
            pts.append(rad_point(pt, delta, bisecangle-90))
            pts.append(rad_point(pt, delta, bisecangle+90))

        if (i == numfaces - 2) :
            if (closed) :
                next = coords[0]
            else:
                next = (coords[i+1][0] + (coords[i+1][0] - pt[0]),
                        coords[i+1][1] + (coords[i+1][1] - pt[1]))
        elif (i == numfaces - 1):
            next = None
        else :
            next = coords[i+2]
    
        previous = coords[i]

    if (closed) :
        pts.extend((pts[0], pts[1], pts[2], pts[3]))

    return pts


def curveline_coords(coords, **options) :
    """
    #---------------------------------------------------------------------------
    # Graphics::curveline_coords
    # retourne les coordonnées d'une curveLine
    #---------------------------------------------------------------------------
    # paramètres :
    # coords : <coordsList> liste de coordonnées des points de la ligne
    # options :
    #    -closed : <boolean> ligne fermée
    #  -shifting : <out|center|in> sens de décalage du contour
    #              (par défaut center)
    # -linewidth : <dimension> epaisseur de la ligne
    #---------------------------------------------------------------------------
    """
    numfaces = len(coords)
    gopts = []
    backpts = []
    pts = []

    if options.has_key('closed'):
        closed = options['closed']
    else:
        closed = None
    if (options.has_key('linewidth')) :
        linewidth = options['linewidth']
    else:
        linewidth = 2
    if (options.has_key('shifting')) :
        shifting = options['shifting']
    else:
        shifting = 'center'

    if( not numfaces or linewidth < 2):
        raise ValueError("Bad coords %s or linewidth %s"%(numfaces, linewidth))

    if (closed) :
        previous = coords[numfaces - 1]
    else:
        previous = None
        
    next = coords[1]
    if (shifting == 'center'):
        linewidth /= 2 

    for i in xrange(0, numfaces):
        pt = coords[i]

        if ( previous is None ) :
            # extrémité de curve sans raccord -> angle plat
            previous = (pt[0] + (pt[0] - next[0]), pt[1] + (pt[1] - next[1]))
            

        (angle, bisecangle) = vertex_angle(previous, pt, next)

        # distance au centre du cercle inscrit : rayon/sinus demi-angle
        asin = sin(radians(angle/2))
        if (asin) :
            delta = abs(linewidth / asin)
        else:
            delta = linewidth

        if (shifting == 'out' or shifting == 'in') :
            if (shifting == 'out') :
                adding = -90
            else:
                adding = 90
            pts.append(rad_point(pt, delta, bisecangle + adding))
            pts.append(pt)

        else :
            pts = rad_point(pt, delta, bisecangle+90)
            gopts.append(pts)
            pts = rad_point(pt, delta, bisecangle-90)
            backpts.insert(0, pts)

        if (i == numfaces - 2) :
            if (closed) :
                next = coords[0]
            else:
                next = (coords[i+1][0] +
                        (coords[i+1][0] - pt[0]), coords[i+1][1]
                        + (coords[i+1][1] - pt[1]))
        else :
            next = coords[i+2]

        previous = coords[i]

    gopts.extend(backpts)

    if (closed) :
        gopts.extend ((gopts[0], gopts[1]))

    return gopts


def shiftpath_coords(coords, **options) :
    """
    #---------------------------------------------------------------------------
    # Graphics::shiftpath_coords
    # retourne les coordonnées d'un décalage de path
    #---------------------------------------------------------------------------
    # paramètres :
    # coords : <coordsList> liste de coordonnées des points du path
    # options :
    #   -closed : <boolean> ligne fermée
    # -shifting : <'out'|'in'> sens de décalage du path (par défaut out)
    #    -width : <dimension> largeur de décalage (par défaut 1)
    #---------------------------------------------------------------------------
    """
    numfaces = len(coords)

    if options.has_key('closed'):
        closed = options['closed']
    else:
        closed = None
    if (options.has_key('width')) :
        width = options['width']
    else:
        width = 1
    if (options.has_key('shifting')) :
        shifting = options['shifting']
    else:
        shifting = 'out'

    if (not numfaces or not width):
        return coords 

    pts = []
    
    if (closed) :
        previous = coords[numfaces - 1]
    else:
        previous = None
    next = coords[1]

    for i in xrange(0, numfaces):
        pt = coords[i]

        if ( previous is None ) :
            # extrémité de curve sans raccord -> angle plat
            previous = (pt[0] + (pt[0] - next[0]), pt[1] + (pt[1] - next[1]))
            

        (angle, bisecangle) = vertex_angle(previous, pt, next)

        # distance au centre du cercle inscrit : rayon/sinus demi-angle
        asin = sin(radians(angle/2))
        if (asin) :
            delta = abs(width / asin)
        else:
            delta = width

        if (shifting == 'out') :
            adding = -90
        else:
            adding = 90
        (x, y) = rad_point(pt, delta, bisecangle + adding)
        pts.append((x, y))


        if (i > numfaces - 3) :
            if (closed) :
                next = coords[0]
            else:
                next = (pt[0] + (pt[0] - previous[0]),
                        pt[1] + (pt[1] - previous[1]))

        else :
            next = coords[i+2]

        previous = coords[i]

    return pts




def curveitem2polyline_coords(widget, item, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::curveitem2polyline_coords
    # Conversion des coordonnées Znitem curve (multicontours)
    # en coordonnées polyline(s)
    #---------------------------------------------------------------------------
    # paramètres :
    # widget : <widget> identifiant du widget zinc
    #   item : <tagOrId> identifiant de l'item source
    # options :
    # -tunits : <integer> nombre pas de division des segments bezier
    #           (par défaut 20)
    # -adjust : <boolean> ajustement de la courbe de bezier (par défaut 1)
    #---------------------------------------------------------------------------
    """
    if (not widget.type(item)):
        raise ValueError("Item Not Found")
    coords = []
    numcontours = widget.contour(item)
    #parentgroup = widget.group(item)

    for contour in xrange(0, numcontours):
        points = widget.coords(item, contour)
        contourcoords = curve2polyline_coords(points, **options)

        coords.append(contourcoords)

    return coords

def curve2polyline_coords(points, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::curve2polyline_coords
    # Conversion curve -> polygone
    #---------------------------------------------------------------------------
    # paramètres :
    # points : <coordsList> liste des coordonnées curve à transformer
    # options :
    # -tunits : <integer> nombre pas de division des segments bezier
    #           (par défaut 20)
    # -adjust : <boolean> ajustement de la courbe de bezier (par défaut 1)
    #---------------------------------------------------------------------------
    """
    if (options.has_key('tunits')) :
        tunits = options['tunits']
    else:
        tunits = 20
    if (options.has_key('adjust')) :
        adjust = options['adjust']
    else:
        adjust = 1

    poly = []
    previous = None
    bseg = []
    numseg = 0
    #prevtype = None

    for point in points:
        if len(point) == 3:
            (x, y, c) = point
        elif len(point) == 2:
            (x, y, c) = (point, None)
        else:
            ValueError("Bad point")
        if (c == 'c') :
            if not len(bseg) and previous:
                bseg.append(previous)
            bseg.append(point)
            
        else :
            if (len (bseg)) :
                bseg.append(point)
                if (adjust) :
                    pts = bezier_compute(bseg, skipend = 1)
                    del pts[0]
                    del pts[0]
                    poly.extend(pts)
                     
                else :
                    pts = bezier_segment(bseg, tunits = tunits, skipend = 1)
                    del pts[0]
                    del pts[0]
                    poly.extend(pts)

                bseg = []
                numseg += 1
                #prevtype = 'bseg'

            else :
                poly.append((x, y))
                #prevtype = 'line'

        previous = point


    return poly


def build_tabboxitem(widget, parentgroup, **options):
    """
    #-------------------------------------------------------------------------------
    # Graphics::build_tabboxitem
    # construit les items de représentations Zinc d'une boite à onglets
    #-------------------------------------------------------------------------------
    # paramètres :
    #      widget : <widget> identifiant du widget zinc
    # parentgroup : <tagOrId> identifiant de l'item group parent
    #
    #    options :
    #     -coords : <coordsList> coordonnées haut-gauche et bas-droite
    #               du rectangle
    #               englobant du Tabbox
    #     -params : <hastable> arguments spécifiques des items curve
    #               à passer au widget
    #    -texture : <imagefile> ajout d'une texture aux items curve
    #  -tabtitles : <hashtable> table de hash de définition des titres onglets
    #  -pageitems : <hashtable> table de hash de définition des pages internes
    #     -relief : <hashtable> table de hash de définition du relief de forme
    #
    # (options de construction géometrique passées à tabbox_coords)
    #  -numpages : <integer> nombre de pages (onglets) de la boite
    #    -anchor : <'n'|'e'|'s'|'w'> ancrage (positionnement) de la ligne
    #              d'onglets
    # -alignment : <'left'|'center'|'right'> alignement des onglets sur le coté
    #              d'ancrage
    #  -tabwidth : <'auto'>|<dimension>|<dimensionList> : largeur des onglets
    #              'auto' largeur répartie, les largeurs sont auto-ajustée
    #              si besoin.
    # -tabheight : <'auto'>|<dimension> : hauteur des onglets
    #  -tabshift : <'auto'>|<dimension> offset de 'biseau' entre base et haut de
    #              l'onglet (défaut auto)
    #    -radius : <dimension> rayon des arrondis d'angle
    #   -overlap : <'auto'>|<dimension> offset de recouvrement/séparation entre
    #              onglets
    #   -corners : <booleanList> liste 'spécifique' des raccords de sommets [0|1]
    #---------------------------------------------------------------------------
    """
    if options.has_key('coords') :
        coords = options['coords']
    else:
        raise ValueError("Coords needed")
    if options.has_key('params'):
        params = options['params']
    else:
        params = {}
    if params.has_key('tags'):
        tags = params['tags']
    else :
        tags = []
    texture = None

    if (options.has_key('texture')) :
        texture = get_texture(widget,
                             options['texture'])
        

    if options.has_key('tabtitles'):
        titlestyle = options['tabtitles']
    else :
        titlestyle = None
    if (titlestyle) :
        titles = titlestyle['text']
    else:
        titles = None

    tabs = []
    (shapes, tcoords, invert) = tabbox_coords(**options)
    if (invert) :
        k = len(shapes)
    else:
        k = -1
    shapes.reverse()
    for shape in shapes :
        if (invert) :
            k -= 1
        else :
            k += +1
        group = widget.add('group', parentgroup)
        params['tags'] = tags
        params['tags'] += (k, 'intercalaire')
        form = widget.add('curve',
                          group,
                          lpts2coords(shape),
                          **params)
        if texture :
            widget.itemconfigure(form, tile = texture)

        if (options.has_key('relief')) :
            graphicitem_relief(widget, form, **options['relief'])
            

        if (options.has_key('page')) :
            build_zinc_item(widget, group, **options['page'])
    
        if (titles) :
            if (invert) :
                tindex = k
            else:
                tindex = len(shapes) - k
            titlestyle['itemtype'] = 'text'
            titlestyle['coords'] = tcoords[tindex]
            titlestyle['params']['text'] = titles[tindex]
            ltags = list(tags)
            ltags.append(tindex)
            ltags.append('titre')
            titlestyle['params']['tags'] = tuple(ltags)
            build_zinc_item(widget, group, **titlestyle)

    return tabs


def tabbox_coords(coords, **options):
    """
    #---------------------------------------------------------------------------
    # tabbox_coords
    # Calcul des shapes de boites à onglets
    #---------------------------------------------------------------------------
    # paramètres :
    # coords : <coordList> coordonnées haut-gauche bas-droite du rectangle
    #          englobant de la tabbox
    # options
    #  -numpages : <integer> nombre de pages (onglets) de la boite
    #    -anchor : <'n'|'e'|'s'|'w'> ancrage (positionnement) de la
    #              ligne d'onglets
    # -alignment : <'left'|'center'|'right'> alignement des onglets
    #              sur le coté d'ancrage
    #  -tabwidth : <'auto'>|<dimension>|<dimensionList> : largeur des onglets
    #              'auto' largeur répartie, les largeurs sont auto-ajustée
    #               si besoin.
    # -tabheight : <'auto'>|<dimension> : hauteur des onglets
    #  -tabshift : <'auto'>|<dimension> offset de 'biseau' entre base et haut
    #              de l'onglet (défaut auto)
    #    -radius : <dimension> rayon des arrondis d'angle
    #   -overlap : <'auto'>|<dimension> offset de recouvrement/séparation
    #              entre onglets
    #   -corners : <booleanList> liste 'spécifique' des raccords
    #              de sommets [0|1]
    #---------------------------------------------------------------------------
    """
    (x_0, y_0) = coords[0]
    (x_n, y_n) = coords[1]
    shapes, titles_coords = [], []
    inverse = None

    #loptions = options.keys()
    if options.has_key('numpages'):
        numpages = options['numpages']
    else:
        numpages = 0
    
    if (not x_0 or not y_0 or not x_n or not y_n or not numpages) :
        raise ValueError("Vous devez au minimum spécifier\
        le rectangle englobant et le nombre de pages")

    if (options.has_key('anchor')) :
        anchor = options['anchor']
    else:
        anchor = 'n'
    if (options.has_key('alignment')) :
        alignment = options['alignment']
    else:
        alignment ='left'


    if (options.has_key('tabwidth')) :
        nlen = options['tabwidth']
    else:
        nlen ='auto'
    if (options.has_key('tabheight')) :
        thick = options['tabheight']
    else:
        thick ='auto'
    if (options.has_key('tabshift')) :
        biso = options['tabshift']
    else:
        biso = 'auto'
    if (options.has_key('radius')) :
        radius = options['radius']
    else:
        radius = 0
    if (options.has_key('overlap')) :
        overlap = options['overlap']
    else:
        overlap = 0
    if (options.has_key('corners')):
        corners = options['corners']
    else:
        corners = None
    if (anchor in ( 'n', 's')) :
        orientation = 'horizontal'
    else:
        orientation = 'vertical'
    if (orientation == 'horizontal') :
        maxwidth = (x_n - x_0)
    else:
        maxwidth = (y_n - y_0)
    tabswidth = 0
    align = 1

    if (nlen == 'auto') :
        tabswidth = maxwidth
        nlen = float(tabswidth + (overlap * (numpages - 1)))/numpages
    else :
        if (type(nlen) in (types.TupleType, types.ListType )) :
            for w in nlen :
                tabswidth += (w - overlap)
      
            tabswidth += overlap
        else :
            tabswidth = (nlen * numpages) - (overlap * (numpages - 1))
    

        if (tabswidth > maxwidth) :
            tabswidth = maxwidth
            nlen = float(tabswidth + (overlap * (numpages - 1)))/numpages

        if (alignment == 'center' and ((maxwidth - tabswidth) > radius)):
            align = 0 


    if (thick == 'auto') :
        if (orientation == 'horizontal') :
            thick = int((y_n - y_0)/10)
        else:
            thick = int((x_n - y_0)/10)
        thick = max(10, thick) 
        thick = min(40, thick)

    if (biso == 'auto') :
        biso = int(thick/2)

    if ((alignment == 'right' and anchor != 'w') or
        (anchor == 'w' and alignment != 'right')) :

        if (type(nlen) in (types.TupleType, types.ListType)) :
            for p in xrange(0, numpages):
                nlen[p] *= -1
        else :
            nlen *= -1
        biso *= -1
        overlap *= -1

    if (alignment == 'center') :
        (biso1, biso2) = (biso/2, biso/2)
    else:
        (biso1, biso2) = (0, biso)

    cadre, tabdxy = [], []
    xref, yref = 0, 0
    if (orientation == 'vertical') :
        if (anchor == 'w'):
            thick *= -1 
        if (anchor == 'w') :
            (startx, endx) = (x_0, x_n)
        else:
            (startx, endx) = (x_n, x_0)
        if ((anchor == 'w' and alignment != 'right') or 
            (anchor == 'e' and alignment == 'right')) :
            (starty, endy) = (y_n, y_0)
        else:
            (starty, endy) = (y_0, y_n)

        xref = startx - thick
        yref = starty
        if  (alignment == 'center') :
            if (anchor == 'w') :
                ratio = -2
            else:
                ratio = 2
            yref += (float(maxwidth - tabswidth)/ratio)

        cadre = ((xref, endy), (endx, endy), (endx, starty), (xref, starty))

        # flag de retournement de la liste des pts de curve si nécessaire
        # -> sens anti-horaire
        inverse = (alignment == 'right')

    else :
        if (anchor == 's'):
            thick *= -1
            (starty, endy) = (y_n, y_0)
        else :
            (starty, endy) = (y_0, y_n)
            
        if (alignment == 'right') :
            (startx, endx) = (x_n, x_0)
        else:
            (startx, endx) = (x_0, x_n)


        yref = starty + thick
        if (alignment == 'center') :
            xref = x_0 + (float(maxwidth - tabswidth)/2)
        else :
            xref = startx

        cadre = ((endx, yref), (endx, endy), (startx, endy), (startx, yref))

        # flag de retournement de la liste des pts de curve si nécessaire
        # -> sens anti-horaire
        inverse = ((anchor == 'n' and alignment != 'right')
                   or (anchor == 's' and alignment == 'right'))
         
        
    for i in xrange(0, numpages):
        pts = []

        # décrochage onglet
        #push (pts, ([xref, yref])) if i > 0

        # cadre
        pts.extend(cadre)

        # points onglets
        if (i > 0 or not align) :
            pts.append((xref, yref)) 

        if (type(nlen) in (types.TupleType, types.ListType)) :
            tw = nlen[i]
        else:
            tw = nlen

        if (type(nlen) in (types.TupleType, types.ListType)) :
            slen = len(nlen)
        else:
            slen = nlen
        
        if (orientation == 'vertical') :
            tabdxy = ((thick, biso1), (thick, tw - biso2), (0, tw))
        else:
            tabdxy = ((biso1, -thick), (tw - biso2, -thick), (tw, 0))
        for delta_xy in tabdxy :
            pts.append((xref + delta_xy[0], yref + delta_xy[1]))
    

        if (radius) :
            if (not options.has_key('corners')) :
                if (i > 0 or not align) :
                    corners =  (0, 1, 1, 0, 0, 1, 1, 0)
                else :
                    corners = (0, 1, 1, 0, 1, 1, 0, 0, 0)
      
            curvepts = roundedcurve_coords(pts,
                                          radius = radius,
                                          corners = corners)
            lcurvepts = list(curvepts)
            if (inverse):
                lcurvepts.reverse()
            shapes.append(lcurvepts)
        else :
            if (inverse):
                pts.reverse()
            shapes.append(pts)

        if (orientation == 'horizontal') :
            titles_coords.append((float(xref) + (tw - (biso2 - biso1))/2,
                                  float(yref) - (thick/2)))
            xref += (tw - overlap)

        else :
            titles_coords.append( (float(xref) + (thick/2),
                                   yref + (slen - ((biso2 - biso1)/2))/2))
            yref += (slen - overlap)
            
    return (shapes, titles_coords, inverse)


def graphicitem_relief(widget, item, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::graphicitem_relief
    # construit un relief à l'item Zinc en utilisant des items Triangles
    #---------------------------------------------------------------------------
    # paramètres :
    #  widget : <widget> identifiant du widget zinc
    #    item : <tagOrId> identifiant de l'item zinc
    # options : <hash> table d'options
    #     -closed : <boolean> le relief assure la fermeture de forme (défaut 1)
    #     -profil : <'rounded'|'flat'> type de profil (defaut 'rounded')
    #     -relief : <'raised'|'sunken'> (défaut 'raised')
    #       -side : <'inside'|'outside'> relief interne ou externe à la forme
    #               (défaut 'inside')
    #      -color : <color> couleur du relief (défaut couleur de la forme)
    #   -smoothed : <boolean> facettes relief lissées ou non (défaut 1)
    # -lightangle : <angle> angle d'éclairage (défaut valeur générale widget)
    #      -width : <dimension> 'épaisseur' du relief en pixel
    #       -fine : <boolean> mode précision courbe de bezier
    #               (défaut 0 : auto-ajustée)
    #-------------------------------------------------------------------------------
    """
    items = []

    # relief d'une liste d'items -> appel récursif
    if (type(item) in (types.TupleType, types.ListType)) :
        for part in item :
            items.extend(graphicitem_relief(widget, part, **options))
    else :
        itemtype = widget.type(item)
        if not itemtype:
            raise ValueError("Bad Item")

        parentgroup = widget.group(item)
        if (options.has_key('priority')) :
            priority = options['priority']
        else :
            priority = widget.itemcget(item, 'priority')+1

        # coords transformés (polyline) de l'item
        adjust = not options['fine']
        for coords in zincitem_2_curvecoords(widget,
                                           item, linear = 1,
                                           realcoords = 1,
                                           adjust = adjust) :
            (pts, colors) = polyline_relief_params(widget,
                                                 item,
                                                 coords,
                                                 **options)

            items.append(widget.add('triangles',
                                    parentgroup,
                                    pts,
                                    priority = priority,
                                    colors = colors))


        # renforcement du contour
        if (widget.itemcget(item, 'linewidth')) :
            items.append(widget.clone(item,
                                      filled = 0,
                                      priority = priority+1))

    return items


def polyline_relief_params(widget, item, coords, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::polyline_relief_params
    # retourne la liste des points et des couleurs nécessaires à la construction
    # de l'item Triangles du relief
    #---------------------------------------------------------------------------
    # paramètres :
    #  widget : <widget> identifiant widget Zinc
    #    item : <tagOrId> identifiant item Zinc
    # options : <hash> table d'options
    #     -closed : <boolean> le relief assure la fermeture de forme (défaut 1)
    #     -profil : <'rounded'|'flat'> type de profil (defaut 'rounded')
    #     -relief : <'raised'|'sunken'> (défaut 'raised')
    #       -side : <'inside'|'outside'> relief interne ou externe à la forme
    #               (défaut 'inside')
    #      -color : <color> couleur du relief (défaut couleur de la forme)
    #   -smoothed : <boolean> facettes relief lissées ou non (défaut 1)
    # -lightangle : <angle> angle d'éclairage (défaut valeur générale widget)
    #      -width : <dimension> 'épaisseur' du relief en pixel
    #---------------------------------------------------------------------------
    """

    if (options.has_key('closed')) :
        closed = options['closed']
    else:
        closed = 1
    if (options.has_key('profil')) :
        profil = options['profil']
    else:
        profil = 'rounded'
    if (options.has_key('relief')) :
        relief = options['relief']
    else :
        relief = 'raised'
    if (options.has_key('side')) :
        side = options['side']
    else:
        side = 'inside'
    if (options.has_key('color')) :
        basiccolor = options['color']
    else:
        basiccolor = zincitem_predominantcolor(widget, item)
    if (options.has_key('smooth')) :
        smoothed = options['smooth']
    else:
        smoothed = 1
    if (options.has_key('lightangle')) :
        lightangle = options['lightangle']
    else:
        lightangle = widget.cget('lightangle')

    if options.has_key('width'):
        width = options['width']
    else:
        raise ValueError('Options must have width field')
    if ( width < 1) :
        (x_0, y_0, x_1, y_1) = widget.bbox(item)
        width = min(x_1 -x_0, y_1 - y_0)/10
        if (width < 2) :
            width = 2

    numfaces = len(coords)
    if (closed):
        previous = coords[numfaces - 1]
    else:
        previous = None
    next = coords[1]

    pts = []
    colors = []
    alpha = 100
    m = re.compile("^(?P<color>#[0-9a-fA-F]{6});(?P<alpha>\d{1,2})$")
    res = m.match(basiccolor)
    if (res is not None) :
        (basiccolor, alpha) = res.group('color'), res.group('alpha')

    if ( options.has_key('color')):
        color = options['color']
        res = m.match(color)
        if ((res is None) and (profil == 'flat')):
            alpha /= 2

    if (profil == 'rounded') :
        reliefalphas = [0, alpha]
    else:
        reliefalphas = [alpha, alpha]

    for i in xrange(0, numfaces):
        pt = coords[i]

        if (previous) :
            # extrémité de curve sans raccord -> angle plat
            previous = (pt[0] + (pt[0] - next[0]), pt[1] + (pt[1] - next[1]))
    

        (angle, bisecangle) = vertex_angle(previous, pt, next)

        # distance au centre du cercle inscrit : rayon/sinus demi-angle
        asin = sin(radians(angle/2))
        if (asin) :
            delta = abs(width / asin)
        else:
            delta = width
        if (side == 'outside') :
            decal = -90
        else:
            decal = 90

        shift_pt = rad_point(pt, delta, bisecangle+decal)
        pts.append(shift_pt)
        pts.append(pt)

        if (smoothed and i) :
            pts.append(shift_pt)
            pts.append(pt)
    

        faceangle = 360 -(linenormal(previous, next)+90)

        light = abs(lightangle - faceangle)
        if (light > 180):
            light = 360 - light
        if light < 1:
            light = 1 

        if (relief == 'sunken') :
            lumratio = (180-light)/180
        else:
            lumratio = light/180

        if ( not smoothed and i) :
            #A VOIR
            #OBSCURE
            colors.extend((colors[-2], colors[-1]))

        if (basiccolor) :
            # création des couleurs dérivées
            shade = lightingcolor(basiccolor, lumratio)
            color0 = "%s;%s"% (shade, reliefalphas[0])
            color1 = "%s;%s"% (shade, reliefalphas[1])
            colors.extend((color0, color1))

        else :
            c = (255*lumratio)
            color0 = hexargbcolor(c, c, c, reliefalphas[0])
            color1 = hexargbcolor(c, c, c, reliefalphas[1])
            colors.extend((color0, color1))
    

        if (i == (numfaces - 2)) :
            if (closed) :
                next = coords[0]
            else:
                next = (coords[i+1][0] + (coords[i+1][0] - pt[0]),
                        coords[i+1][1] + (coords[i+1][1] - pt[1]))
        else :
            next = coords[i+2]

        previous = coords[i]

    if (closed) :
        pts.extend((pts[0], pts[1], pts[2], pts[3]))
        colors.extend((colors[0], colors[1]))

        if (not smoothed) :
            pts.extend((pts[0], pts[1], pts[2], pts[3]))
            colors.extend((colors[0], colors[1]))
    
    return (pts, colors)


def graphicitem_shadow(widget, item, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::graphicitem_shadow
    # Création d'une ombre portée à l'item
    #---------------------------------------------------------------------------
    # paramètres :
    #  widget : <widget> identifiant widget Zinc
    #    item : <tagOrId> identifiant item Zinc
    # options : <hash> table d'options
    #    -opacity : <percent> opacité de l'ombre (défaut 50)
    #     -filled : <boolean> remplissage totale de l'ombre (hors bordure) (defaut 1)
    # -lightangle : <angle> angle d'éclairage (défaut valeur générale widget)
    #   -distance : <dimension> distance de projection de l'ombre en pixel
    #  -enlarging : <dimension> grossi de l'ombre portée en pixels (defaut 0)
    #      -width : <dimension> taille de diffusion/diffraction (défaut 4)
    #      -color : <color> couleur de l'ombre portée (défaut black)
    #---------------------------------------------------------------------------
    """
    items = []

    # relief d'une liste d'items -> appel récursif
    if (type(item) in (types.TupleType, types.ListType)) :
        for part in item :
            items.append(graphicitem_shadow(widget, part, **options))
        return items

    else :

        itemtype = widget.type(item)

        if not itemtype :
            raise ValueError("Not a valid Item Id %s"%item)

        # création d'un groupe à l'ombre portée
        if (options.has_key('parentgroup')) :
            parentgroup = options['parentgroup']
        else:
            parentgroup = widget.group(item)
        if (options.has_key('priority')) :
            priority = options['priority']
        else:
            priority = widget.itemcget(item, 'priority')-1
        priority = max(0, priority) 

        shadow = widget.add('group', parentgroup, priority = priority)
            
        if (itemtype == 'text') :
            if (options.has_key('opacity')) :
                opacity = options['opacity']
            else:
                opacity = 50
            if (options['color']) :
                color = options['color']
            else:
                color = '#000000'
            
            clone = widget.clone(item, color = "%s;%s"% (color, opacity))
            widget.chggroup(clone, shadow)

        else :

            # création des items (de dessin) de l'ombre
            if ( options.has_key('filled')) :
                filled = options['filled']
            else:
                filled = 1
      
            # coords transformés (polyline) de l'item
            for coords in zincitem_2_curvecoords(widget,
                                               item,
                                               linear = 1,
                                               realcoords = 1) :
                (t_pts, i_pts, colors) = polyline_shadow_params( coords,
                                                               **options)
                
                # option filled : remplissage hors bordure
                # de l'ombre portée (item curve)
                if (filled) :
                    if (len(items)) :
                        widget.contour(items[0], 'add', 0, i_pts)
	
                    else :
                        items.append( widget.add('curve', shadow, i_pts,
                                                  linewidth = 0,
                                                  filled = 1,
                                                  fillcolor = colors[0],
                                                  ))
                        
                # bordure de diffusion de l'ombre (item triangles)
                items.append( widget.add('triangles', shadow, t_pts,
                                          colors = colors))
      

        # positionnement de l'ombre portée
        if (options.has_key('distance')) :
            distance = options['distance']
        else:
            distance = 10
        if (options.has_key('lightangle')) :
            lightangle = options['lightangle']
        else:
            lightangle = widget.cget('lightangle')

        (delta_x, delta_y) = rad_point((0, 0),
                             distance,
                             lightangle+180)
        widget.translate(shadow, delta_x, -delta_y)

    return shadow


def polyline_shadow_params(coords, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::polyline_shadow_params
    # retourne les listes des points et de couleurs nécessaires à la 
    # construction des items triangles (bordure externe) et curve
    # (remplissage interne) de l'ombre portée
    #---------------------------------------------------------------------------
    # paramètres :
    #    coords : coordonnées
    # options : <hash> table d'options
    #    -opacity : <percent> opacité de l'ombre (défaut 50)
    # -lightangle : <angle> angle d'éclairage (défaut valeur générale widget)
    #   -distance : <dimension> distance de projection de l'ombre en pixel
    #               (défaut 10)
    #  -enlarging : <dimension> grossi de l'ombre portée en pixels (defaut 2)
    #      -width : <dimension> taille de diffusion/diffraction
    #               (défaut distance -2)
    #      -color : <color> couleur de l'ombre portée (défaut black)
    #---------------------------------------------------------------------------
    """
    if (options.has_key('distance')) :
        distance = options['distance']
    else:
        distance = 10
    if (options.has_key('width')) :
        width = options['width']
    else:
        width = distance-2
    if (options.has_key('opacity')) :
        opacity = options['opacity']
    else:
        opacity = 50
    if (options.has_key('color')) :
        color = options['color']
    else:
        color ='#000000'
    if (options.has_key('enlarging')) :
        enlarging = options['enlarging']
    else :
        enlarging = 2

    if (enlarging) :
        coords = shiftpath_coords(coords,
                                 width = enlarging,
                                 closed = 1,
                                 shifting = 'out')

    numfaces = len(coords)
    previous = coords[numfaces - 1]
    next = coords[1]

    t_pts = []
    i_pts = []
    colors = []
    (color0, color1) = ("%s;%s"% (color, opacity), "%s;0"% color)

    for i in xrange(0, numfaces):
        pt = coords[i]

        #A VOIR
        #Je ne vois pas quand cela peut arriver
        if (not previous) :
            # extrémité de curve sans raccord -> angle plat
            previous = (pt[0] + (pt[0] - next[0]), pt[1] + (pt[1] - next[1]))

        (angle, bisecangle) = vertex_angle(previous, pt, next)

        # distance au centre du cercle inscrit : rayon/sinus demi-angle
        asin = sin(radians(angle/2))
        if (asin) :
            delta = abs(width / asin)
        else :
            delta =  width
        decal = 90

        shift_pt = rad_point(pt, delta, bisecangle+decal)
        i_pts.append(shift_pt)
        t_pts.append(shift_pt)
        t_pts.append(pt)
        
        colors.append(color0)
        colors.append(color1)
        if (i == numfaces - 2) :
            next = coords[0]
        else :
            next = coords[i+2]

        previous = coords[i]

    # fermeture
    t_pts.extend((t_pts[0], t_pts[1], t_pts[2], t_pts[3]))
    i_pts.extend((t_pts[0], t_pts[1]))
    colors.extend((color0, color1, color0, color1))

    return (t_pts, i_pts, colors)





#Local Variables:
#mode : python
#tab-width: 4
#end:
