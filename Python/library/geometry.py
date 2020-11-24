# -*- coding: iso-8859-1 -*-
"""
#  Geometrical basic Functions :
#  -----------------------------
#      perpendicular_point
#      line_angle
#      linenormal
#      vertex_angle
#      arc_pts
#      rad_point
#      bezier_compute
#      bezier_segment
#      bezier_point
"""

from math import pi, radians, atan2, sin, cos

# limite globale d'approximation courbe bezier
bezierClosenessThreshold = .2
def perpendicular_point (point, line): 
    """
    #---------------------------------------------------------------------------
    # Graphics::perpendicular_point
    # retourne les coordonnées du point perpendiculaire abaissé d'un point
    # sur une ligne
    #---------------------------------------------------------------------------
    # paramètres :
    # point : <coords> coordonnées du point de référence
    #  line : <coordsList> coordonnées des 2 points de la ligne de référence
    #---------------------------------------------------------------------------
    """
    (p1, p2) = line

    # cas partiuculier de lignes ortho.
    min_dist = .01
    if (abs(p2[1] - p1[1]) < min_dist) :
        # la ligne de référence est horizontale
        return (point[0], p1[1])

    elif (abs(p2[0] - p1[0]) < min_dist) :
        # la ligne de référence est verticale
        return (p1[0], point[1])

    a1 = float(p2[1] - p1[1]) / float(p2[0] - p1[0])
    b1 = p1[1] - (a1 * p1[0])

    a2 = -1.0 / a1
    b2 = point[1] - (a2 * point[0])

    x = (b2 - b1) / (a1 - a2)
    y = (a1 * x) + b1

    return (x, y)

def line_angle(startpoint, endpoint):
    """
    #---------------------------------------------------------------------------
    # Graphics::line_angle
    # retourne l'angle d'un point par rapport à un centre de référence
    #---------------------------------------------------------------------------
    # paramètres :
    # startpoint : <coords> coordonnées du point de départ du segment
    #   endpoint : <coords> coordonnées du point d'extremité du segment
    #---------------------------------------------------------------------------
    """
    angle = atan2(endpoint[1] - startpoint[1], endpoint[0] - startpoint[0])

    angle += pi/2
    angle *= float(180)/pi
    if (angle < 0):
        angle += 360  

    return angle

def linenormal(startpoint, endpoint):
    """
    #---------------------------------------------------------------------------
    # Graphics::linenormal
    # retourne la valeur d'angle perpendiculaire à une ligne
    #---------------------------------------------------------------------------
    # paramètres :
    # startpoint : <coords> coordonnées du point de départ du segment
    #   endpoint : <coords> coordonnées du point d'extremité du segment
    #---------------------------------------------------------------------------
    """
    angle = line_angle(startpoint, endpoint) + 90

    if (angle > 360):
        angle -= 360
    return angle

def vertex_angle(pt0, pt1, pt2):
    """
    #---------------------------------------------------------------------------
    # Graphics::vertex_angle
    # retourne la valeur de l'angle formée par 3 points
    # ainsi que l'angle de la bisectrice
    #---------------------------------------------------------------------------
    # paramètres :
    # pt0 : <coords> coordonnées du premier point de définition de l'angle
    # pt1 : <coords> coordonnées du deuxième point de définition de l'angle
    # pt2 : <coords> coordonnées du troisième point de définition de l'angle
    #---------------------------------------------------------------------------
    """
    angle1 = line_angle(pt0, pt1)
    angle2 = line_angle(pt2, pt1)

    if angle2 < angle1 :
        angle2 += 360 
    alpha = angle2 - angle1
    bisectrice = angle1 + (float(alpha)/2)

    return (alpha, bisectrice)


def arc_pts(center, radius, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::arc_pts
    # calcul des points constitutif d'un arc
    #---------------------------------------------------------------------------
    # paramètres :
    #  center : <coordonnées> centre de l'arc,
    #  radius : <dimension> rayon de l'arc,
    # options :
    #  -angle : <angle> angle de départ en degré de l'arc (par défaut 0)
    # -extent : <angle> delta angulaire en degré de l'arc (par défaut 360),
    #   -step : <dimension> pas de progresion en degré (par défaut 10)
    #---------------------------------------------------------------------------
    """
    if center is None :
        center = [0, 0]
    if (options.has_key('angle')) :
        angle = options['angle']
    else:
        angle = 0
    if (options.has_key('extent')) :
        extent = options['extent']
    else:
        extent = 360
    if (options.has_key('step')) :
        step = options['step']
    else:
        step = 10
    pts = []

    if (extent > 0 and step > 0) :
        #A Verifier !
        alpha = angle
        while(alpha <= angle+extent):
            (x_n, y_n) = rad_point(center, radius, alpha)
            pts.append((x_n, y_n))
            angle += step
            
    elif (extent < 0 and step < 0) :
        #Ca me semble buggue !!
        #Si extent négatif, il faut aussi que step le soit
        #Si ca boucle !
        alpha = angle
        while(alpha >= angle+extent):
            pts.append(rad_point(center, radius, alpha))
            alpha += step
    else:
        raise ValueError("Step and Extent havent the same sign")
    return tuple(pts)

def rad_point(center, radius, angle):
    """
    #---------------------------------------------------------------------------
    # Graphics::rad_point
    # retourne le point circulaire défini par centre-rayon-angle
    #---------------------------------------------------------------------------
    # paramètres :
    # center : <coordonnée> coordonnée [x,y] du centre de l'arc,
    # radius : <dimension> rayon de l'arc,
    #  angle : <angle> angle du point de circonférence avec le centre du cercle
    #---------------------------------------------------------------------------
    """
    alpha = radians(angle)

    xpt = center[0] + (radius * cos(alpha))
    ypt = center[1] + (radius * sin(alpha))

    return (xpt, ypt)

def bezier_segment(coords, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::bezier_segment
    # Calcul d'une approximation de segment (Quadratique ou Cubique) de bezier
    #---------------------------------------------------------------------------
    # paramètres :
    #    points : <[P1, C1, <C1>, P2]> liste des points définissant
    #             le segment de bezier
    #
    # options :
    #  -tunits : <integer> nombre pas de division des segments bezier
    #            (par défaut 20)
    # -skipend : <boolean> : ne pas retourner le dernier point du
    #            segment (chainage)
    #---------------------------------------------------------------------------
    """
    if (options.has_key('tunits')) :
        tunits = options['tunits']
    else:
        tunits = 20

    
    if options.has_key('skipend'):
        skipendpt = options['skipend']
    else:
        skipendpt = None

    pts = []

    if (skipendpt) :
        lastpt = tunits-1
    else:
        lastpt = tunits 
    for i in xrange(0, lastpt+1):
        if (i) :
            t = (i/tunits)
        else:
            t = i
        pts.append(bezier_point(t, coords))

    return pts


def bezier_point(t, coords):
    """
    #---------------------------------------------------------------------------
    # Graphics::bezier_point
    # calcul d'un point du segment (Quadratique ou Cubique) de bezier
    # params :
    # t = <n> (représentation du temps : de 0 à 1)
    # coords = (P1, C1, <C1>, P2) liste des points définissant le segment
    # de bezier P1 et P2 : extémités du segment et pts situés sur la courbe
    # C1 <C2> : point(s) de contrôle du segment
    #---------------------------------------------------------------------------
    # courbe bezier niveau 2 sur (P1, P2, P3)
    # P(t) = (1-t)²P1 + 2t(1-t)P2 + t²P3
    #
    # courbe bezier niveau 3 sur (P1, P2, P3, P4)
    # P(t) = (1-t)³P1 + 3t(1-t)²P2 + 3t²(1-t)P3 + t³P4
    #---------------------------------------------------------------------------
    """
    ncoords = len(coords)
    if  ncoords == 3:
        (p1, c1, p2) = coords
        c2 = None
    elif ncoords == 4:
        (p1, c1, c2, p2) = coords

    # extrémités : points sur la courbe
    #A VERIFIER
    #Pas compris
    if (not t):
        return tuple(p1)
    if (t >= 1.0):
        return p2


    t2 = t * t
    t3 = t2 * t
    pt = []

    # calcul pour x et y
    for i in (0, 1) :

        if (c2) :
            r1 = (1 - (3*t) + (3*t2) -    t3)  * p1[i]
            r2 = ((3*t) - (6*t2) + (3*t3)) * c1[i]
            r3 = ((3*t2) - (3*t3)) * c2[i]
            r4 = (t3)  * p2[i]

            pt[i] = (r1 + r2 + r3 + r4)

        else :
            r1 = (1 - (2*t) +    t2)  * p1[i]
            r2 = ((2*t) - (2*t2)) * c1[i]
            r3 = (t2)  * p2[i]

            pt[i] = (r1 + r2 + r3)

    return tuple(pt)

def bezier_compute(coords, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::bezier_compute
    # Retourne une liste de coordonnées décrivant un segment de bezier
    #---------------------------------------------------------------------------
    # paramètres :
    #     coords : <coordsList> liste des points définissant le segment
    #              de bezier
    #
    # options :
    # -precision : <dimension> seuil limite du calcul d'approche de la courbe
    #   -skipend : <boolean> : ne pas retourner le dernier point du segment
    #              (chaînage bezier)
    #---------------------------------------------------------------------------
    """
    if (options.has_key('precision')) :
        precision = options['precision']
    else:
        precision = bezierClosenessThreshold
    lastit = []

    subdivide_bezier(coords, lastit, precision)

    if (not options.has_key('skipend') or not options['skipend']):
        lastit.append(coords[3]) 

    return lastit

def smallenough_bezier(bezier, precision):
    """
    #---------------------------------------------------------------------------
    # Graphics::smallEnought
    # intégration code Stéphane Conversy : calcul points bezier
    # (précision auto ajustée)
    #---------------------------------------------------------------------------
    # distance is something like num/den with den=sqrt(something)
    # what we want is to test that distance is smaller than precision,
    # so we have distance < precision ?  eq. to distance^2 < precision^2 ?
    # eq. to (num^2/something) < precision^2 ?
    # eq. to num^2 < precision^2*something
    # be careful with huge values though (hence 'long long')
    # with common values: 9add 9mul
    #---------------------------------------------------------------------------
    """
    (pt_x, pt_y) = (0, 1)
    (a, b) = (bezier[0], bezier[3])

    den = ((a[pt_y]-b[pt_y])*(a[pt_y]-b[pt_y])) + ((b[pt_x]-a[pt_x])*(b[pt_x]-a[pt_x]))
    p = precision*precision

    # compute distance between P1|P2 and P0|P3
    mat = bezier[1]
    num1 = ((mat[pt_x]-a[pt_x])*(a[pt_y]-b[pt_y])) + ((mat[pt_y]-a[pt_y])*(b[pt_x]-a[pt_x]))

    mat = bezier[2]
    num2 = ((mat[pt_x]-a[pt_x])*(a[pt_y]-b[pt_y])) + ((mat[pt_y]-a[pt_y])*(b[pt_x]-a[pt_x]))

    # take the max
    num1 = max(num1, num2)

    if (p*den > (num1*num1)):
        return 1
    else:
        return 0

def subdivide_bezier(bezier, it, precision, integeropt):
    """
    #---------------------------------------------------------------------------
    # Graphics::subdivide_bezier
    # subdivision d'une courbe de bezier
    #---------------------------------------------------------------------------
    """
    (b0, b1, b2, b3) = bezier

    if (smallenough_bezier(bezier, precision)) :
        it.append((b0[0], b0[1]))

    else :
        (left, right) = (None, None)

        for i in (0, 1) :

            if (integeropt) :
                # int optimized (6+3=9)add + (5+3=8)shift

                left[0][i] = b0[i]
                left[1][i] = (b0[i] + b1[i]) >> 1
                # keep precision
                left[2][i] = (b0[i] + b2[i] + (b1[i] << 1)) >> 2
                
                tmp = (b1[i] + b2[i])
                left[3][i] = (b0[i] + b3[i] + (tmp << 1) + tmp) >> 3
                
                right[3][i] = b3[i]
                right[2][i] = (b3[i] + b2[i]) >> 1
                # keep precision
                right[1][i] = (b3[i] + b1[i] + (b2[i] << 1) ) >> 2
                right[0][i] = left[3][i]

            else :
                # float
                
                left[0][i] = b0[i]
                left[1][i] = float(b0[i] + b1[i]) / 2
                left[2][i] = float(b0[i] + (2*b1[i]) + b2[i]) / 4
                left[3][i] = float(b0[i] + (3*b1[i]) + (3*b2[i]) + b3[i]) / 8
                
                right[3][i] = b3[i]
                right[2][i] = float(b3[i] + b2[i]) / 2
                right[1][i] = float(b3[i] + (2*b2[i]) + b1[i]) / 4
                right[0][i] = float(b3[i] + (3*b2[i]) + (3*b1[i]) + b0[i]) / 8

      

        subdivide_bezier(left, it, precision, integeropt)
        subdivide_bezier(right, it, precision, integeropt)


#Local Variables:
#mode : python
#tab-width: 4
#end:
