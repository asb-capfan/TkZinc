# -*- coding: iso-8859-1 -*-
#  Pictorial Functions  :
#  ----------------------
#      set_gradients
#      get_pattern
#      get_texture
#      get_image
#      init_pixmaps
#      zincitem_predominantcolor
#      zncolor_to_rgb
#      hexargbcolor
#      create_graduate
#      path_graduate
#      mediancolor
#      lightingcolor
#      rgb_to_lch
#      lch_to_rgb
#      rgb_to_hls
#      hls_to_rgb

import PIL.Image, PIL.ImageTk
import re
from math import pi, radians, atan2, sqrt, sin, cos

# initialisation et partage de ressources couleurs et images
textures = {}
IMAGES = {}
bitmaps = {}
AVERAGE_COLOR = '#777777'


_GRADIENTS = []

# constante white point (conversion couleur espace CIE XYZ)
(Xw, Yw, Zw) = (95.047, 100.0, 108.883)

def set_gradients(zinc, **grads):
    """
    #---------------------------------------------------------------------------
    # Graphics::set_gradients
    # création de gradient nommés Zinc
    #---------------------------------------------------------------------------
    # paramètres :
    #   widget : <widget> identifiant du widget zinc
    #    **grads : <dictionnaire> de définition de couleurs zinc
    #---------------------------------------------------------------------------
    """
    global _GRADIENTS
    if (not _GRADIENTS):
        _GRADIENTS = []
        for (name, gradient) in grads.items():
            zinc.gname(gradient, name)
            _GRADIENTS.append(name)

def rgb_dec2hex(rgb):
    """
    #---------------------------------------------------------------------------
    # Graphics::rgb_dec2hex
    # conversion d'une couleur RGB (255,255,255) au format Zinc '#ffffff'
    #---------------------------------------------------------------------------
    # paramètres :
    #  rgb : <rgbColorList> liste de couleurs au format RGB
    #---------------------------------------------------------------------------
    """
    return "#%04x%04x%04x"% rgb

def path_graduate(zinc, numcolors, style):
    """
    #---------------------------------------------------------------------------
    # Graphics::path_graduate
    # création d'un jeu de couleurs dégradées pour item pathline
    #---------------------------------------------------------------------------
    """
    typ = style['type']
    if (typ == 'linear'):
        return create_graduate(numcolors, style['colors'], 2)
    elif (typ == 'double'):
        colors1 = create_graduate(numcolors/2+1,
                                 style['colors'][0])
        colors2 = create_graduate(numcolors/2+1,
                                 style['colors'][1])
        colors = []
        for i in xrange(numcolors+1):
            colors.extend([colors1[i], colors2[i]])
        return colors
    elif (typ == 'transversal'):
        (c1, c2) = style['colors']
        colors = [c1, c2]
        for i in xrange(numcolors):
            colors.extend([c1, c2])

    return colors

def create_graduate(totalsteps, refcolors, repeat = 1):
    """
    #---------------------------------------------------------------------------
    # Graphics::create_graduate
    # création d'un jeu de couleurs intermédiaires (dégradé) entre n couleurs
    #---------------------------------------------------------------------------
    """
    colors = []

    numgraduates = len(refcolors) - 1
    if (numgraduates < 1):
        raise ValueError("Le degradé necessite\
        au moins 2 couleurs de référence...")
    steps = None
    if (numgraduates > 1):
        steps = totalsteps/(numgraduates - 1)
    else:
        steps = totalsteps

    for c in xrange(numgraduates):
        (c1, c2) = (refcolors[c], refcolors[c + 1])

        for i in xrange(steps):
            color = mediancolor(c1, c2, i / (steps - 1))
            for it in xrange(repeat):
                colors.append(color)

        if (c < numgraduates - 1):
            for k in xrange(repeat):
                colors.pop()

    return colors

def lightingcolor (color, new_l) :
    """
    #---------------------------------------------------------------------------
    # Graphics::lightingcolor
    # modification d'une couleur par sa composante luminosité
    #---------------------------------------------------------------------------
    # paramètres :
    #  color : <color> couleur au format zinc
    #   new_l : <pourcent> (de 0 à 1) nouvelle valeur de luminosité
    #---------------------------------------------------------------------------
    """
    (h, l, s) = 0, 0, 0
    rgb = hexa2rgb(color)
    h, l, s = rgb_to_hls(rgb)
    new_l = min(new_l, 1) 
    (n_r, n_g, n_b) = hls_to_rgb(h, new_l, s)
    return hexargbcolor(n_r*255, n_g*255, n_b*255)


def get_predominantcolor(colors):
    """
    #---------------------------------------------------------------------------
    # Graphics::get_predominantcolor
    # donne la couleur dominante
    #---------------------------------------------------------------------------
    # paramètres :
    #  colors : <color>* liste de couleurs au format zinc
    #---------------------------------------------------------------------------
    """
    (rs, gs, bs, as, numcolors) = (0, 0, 0, 0, 0)
    for color in colors :
        (r, g, b, a) = zncolor_to_rgb(color)
        rs += r
        gs += g
        bs += b
        as += a
        numcolors += 1

    new_r = int(rs/numcolors)
    new_g = int(gs/numcolors)
    new_b = int(bs/numcolors)
    new_a = int(as/numcolors)

    newcolor = hexargbcolor(new_r, new_g, new_b, new_a)
    return newcolor

def zincitem_predominantcolor(widget, item):
    """
    #---------------------------------------------------------------------------
    # Graphics::zincitem_predominantcolor
    # retourne la couleur dominante d'un item ('barycentre' gradiant fillcolor)
    #---------------------------------------------------------------------------
    # paramètres :
    #  widget : <widget> identifiant du widget zinc
    #    item : <tagOrId> identifiant de l'item zinc
    #---------------------------------------------------------------------------
    """
    typ = widget.type(item)
    if not typ :
        raise ValueError("Not a Valid Item %s" % item)
    if (typ == 'text' or typ == 'icon') :
        return widget.itemcget(item, 'color')

    elif (typ == 'triangles' or
          typ == 'rectangle' or
          typ == 'arc' or
          typ == 'curve') :

        colors = []

        if (typ == 'triangles') :
            colors =  widget.itemcget(item, 'colors')
        else :
            grad =  widget.itemcget(item, 'fillcolor')
            regexp = re.compile(
                "^=(?P<class>\w+)(?P<params>[^|]+)\|(?P<colorparts>.*)$")
            res = regexp.match(grad)
            if (res is None):
                #couleur simple
                return grad
            else:
                #Gradient
                colorspart = res.group('colorparts').split("|")
                regexp_color = re.compile("^(?P<color>^\S+).*") 
                for colorpart in colorspart:                  
                    res = regexp_color.match(colorpart)
                    if res:
                        colors.append(res.group('color'))
                    else :
                        raise ValueError("Impossible case!!")
        return get_predominantcolor(colors)
    else :
        return AVERAGE_COLOR

def mediancolor (color1, color2, rate) :
    """
    #---------------------------------------------------------------------------
    # Graphics::mediancolor
    # calcul d'une couleur intermédiaire défini par un ratio ($rate)
    # entre 2 couleurs
    #---------------------------------------------------------------------------
    # paramètres :
    #  color1 : <color> première couleur zinc
    #  color2 : <color> seconde couleur zinc
    #    rate : <pourcent> (de 0  à 1) position de la couleur intermédiaire
    #---------------------------------------------------------------------------
    """
    if (rate > 1):
        rate = 1
    if (rate < 0):
        rate = 0

    (r0, g0, b0, a0) = zncolor_to_rgb(color1)
    (r1, g1, b1, a1) = zncolor_to_rgb(color2)

    r = r0 + int((r1 - r0) * rate)
    g = g0 + int((g1 - g0) * rate)
    b = b0 + int((b1 - b0) * rate)
    a = a0 + int((a1 - a0) * rate)

    return hexargbcolor(r, g, b, a)


def zncolor_to_rgb (zncolor):
    """
    #---------------------------------------------------------------------------
    # Graphics::zncolor_to_rgb
    # conversion d'une couleur Zinc au format RGBA (255,255,255,100)
    #---------------------------------------------------------------------------
    # paramètres :
    #  zncolor : <color> couleur au format hexa zinc (#ffffff ou #ffffffffffff)
    #---------------------------------------------------------------------------
    """
    #Recherche du format d'entrée
    # ffffff ou ffffffffffff avec ou sans alpha
    #test présence alpha
    res = []
    res.append(
        re.match(
        "^#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2});(?P<alpha>\d{1,3})$"
        ,zncolor))
    res.append(
        re.match(
        "^#([0-9a-fA-F]{4})([0-9a-fA-F]{4})([0-9a-fA-F]{4});(?P<alpha>\d{1,3})$"
        ,zncolor))
    #Pas de alpha
    res.append(re.match("^#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$"
                        ,zncolor))
    res.append(re.match("^#([0-9a-fA-F]{4})([0-9a-fA-F]{4})([0-9a-fA-F]{4})$"
                        ,zncolor))
    res.sort()
    resultat = res.pop()
    if res is None:
        raise ValueError("Not a valid zinc color")
    alpha = 100
    res = resultat.groupdict()
    if res.has_key('alpha'):
        alpha = int(res['alpha'])
    else:
        alpha = 100

    R = int(resultat.group(1), 16)
    G = int(resultat.group(2), 16)
    B = int(resultat.group(3), 16)

    return (R, G, B, alpha)

def rgb_to_lch(r, g, b) :
    """
    #---------------------------------------------------------------------------
    # ALGORYTHMES DE CONVERSION ENTRE ESPACES DE COULEURS
    #---------------------------------------------------------------------------
    #---------------------------------------------------------------------------
    # Graphics::rgb_to_lch
    # Algorythme de conversion RGB -> CIE LCH°
    #---------------------------------------------------------------------------
    # paramètres :
    #  r : <pourcent> (de 0 à 1) valeur de la composante rouge de la couleur RGB
    #  g : <pourcent> (de 0 à 1) valeur de la composante verte de la couleur RGB
    #  b : <pourcent> (de 0 à 1) valeur de la composante bleue de la couleur RGB
    #---------------------------------------------------------------------------
    """
    # Conversion RGBtoXYZ
    gamma = 2.4
    rgblimit = 0.03928

    if (r > rgblimit):
        r = ((r + 0.055)/1.055)**gamma
    else :
        r = r / 12.92

    if (g > rgblimit) :
        g = ((g + 0.055)/1.055)**gamma
    else:
        g = g / 12.92
      
    if (b > rgblimit) :
        b = ((b + 0.055)/1.055)**gamma
    else:
        b = b / 12.92

    r *= 100
    g *= 100
    b *= 100

    X = (0.4124 * r) + (0.3576 * g) + (0.1805 * b)
    Y = (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
    Z = (0.0193 * r) + (0.1192 * g) + (0.9505 * b)

    # Conversion XYZtoLab
    gamma = 1/3
    (L, A, B) = 0, 0, 0

    if (Y == 0) :
        (L, A, B) = (0, 0, 0)
    else :
        #Utilisation des constantes white point (variables globale)
        (Xs, Ys, Zs) = (X/Xw, Y/Yw, Z/Zw)

    
        if (Xs > 0.008856) :
            Xs = Xs**gamma
        else :
            Xs = (7.787 * Xs) + (16/116)
            
        if (Ys > 0.008856) :
            Ys = Ys**gamma
        else :
            Ys = (7.787 * Ys) + (16/116)
            
        if (Zs > 0.008856) :
            Zs = Zs**gamma
        else :
            Zs = (7.787 * Zs) + (16/116)

        L = (116.0 * Ys) - 16.0

        A = 500 * (Xs - Ys)
        B = 200 * (Ys - Zs)

    # conversion LabtoLCH 
    (C, H) = 0, 0


    if (A == 0) :
        H = 0
    else :
        H = atan2(B, A)
    
        if (H > 0) :
            H = (H / pi) * 180

        else :
            H = 360 - ( abs(H) / pi) * 180



    C = sqrt(A**2 + B**2)
    
    return (L, C, H)

def lch_to_rgb (L, C, H) :
    """
    #---------------------------------------------------------------------------
    # Graphics::lch_to_rgb
    # Algorythme de conversion CIE L*CH -> RGB
    #---------------------------------------------------------------------------
    # paramètres :
    #  L : <pourcent> (de 0 à 1) valeur de la composante luminosité
    #  de la couleur CIE LCH
    #  C : <pourcent> (de 0 à 1) valeur de la composante saturation
    #  de la couleur CIE LCH
    #  H : <pourcent> (de 0 à 1) valeur de la composante teinte
    #  de la couleur CIE LCH
    #---------------------------------------------------------------------------
    """
    (a, b) = 0, 0
    
    # Conversion LCHtoLab
    a = cos( radians(H)) * C
    b = sin( radians(H)) * C
    
    # Conversion LabtoXYZ
    gamma = 3
    (X, Y, Z) = 0, 0, 0
    
    Ys = (L + 16.0) / 116.0
    Xs = (a / 500) + Ys
    Zs = Ys - (b / 200)
    
    if ((Ys**gamma) > 0.008856) :
        Ys = Ys**gamma
    else :
        Ys = (Ys - 16 / 116) / 7.787

    if ((Xs**gamma) > 0.008856) :
        Xs = Xs**gamma
    else :
        Xs = (Xs - 16 / 116) / 7.787
        
    if ((Zs**gamma) > 0.008856) :
        Zs = Zs**gamma
    else :
        Zs = (Zs - 16 / 116) / 7.787


    X = Xw * Xs
    Y = Yw * Ys
    Z = Zw * Zs

    # Conversion XYZtoRGB
    gamma = 1/2.4
    rgblimit = 0.00304
    (R, G, B) = (0, 0, 0)
    
    X /= 100
    Y /= 100
    Z /= 100

    R = (3.2410 * X) + (-1.5374 * Y) + (-0.4986 * Z)
    G = (-0.9692 * X) + (1.8760 * Y) + (0.0416 * Z)
    B = (0.0556 * X) + (-0.2040 * Y) + (1.0570 * Z)

    if (R > rgblimit) :
        R = (1.055 * (R**gamma)) - 0.055
    else :
        R = (12.92 * R)
        
    if (G > rgblimit) :
        G = (1.055 * (G**gamma)) - 0.055
    else :
        G = (12.92 * G)
        
    if (B > rgblimit) :
        B = (1.055 * (B**gamma)) - 0.055
    else :
        B = (12.92 * B)

    if (R < 0) :
        R = 0
    elif (R > 1.0) :
        R = 1.0
    else :
        R = _trunc(R, 5)
      
    if (G < 0) :
        G = 0
    elif (G > 1.0) :
        G = 1.0
    else :
        G = _trunc(G, 5)
      
    if (B < 0) :
        B = 0
    elif (B > 1.0) :
        B = 1.0
    else :
        B = _trunc(B, 5)

    return (R, G, B)

def rgb_to_hls(r, g, b):
    """
    #---------------------------------------------------------------------------
    # Graphics::rgb_to_hls
    # Algorythme de conversion RGB -> HLS
    #---------------------------------------------------------------------------
    #  r : <pourcent> (de 0 à 1) valeur de la composante rouge de la couleur RGB
    #  g : <pourcent> (de 0 à 1) valeur de la composante verte de la couleur RGB
    #  b : <pourcent> (de 0 à 1) valeur de la composante bleue de la couleur RGB
    #---------------------------------------------------------------------------
    """
    H, L, S = 0, 0, 0
    minv, maxv, diffv = 0, 0, 0 
    maxv = max(r, g, b)
    minv = min(r, g, b)

    # calcul de la luminosité
    L = (maxv + minv) / 2

    # calcul de la saturation
    if (maxv == minv) :
        # couleur a-chromatique (gris) r = g = b
        S = 0
        H = None
        return [H, L, S]

    # couleurs "Chromatiques" --------------------

    # calcul de la saturation
    if (L <= 0.5) :
        S = (maxv - minv) / (maxv + minv)

    else :
        S = (maxv - minv) / (2 - maxv - minv)

    # calcul de la teinte
    diffv = maxv - minv

    if (r == maxv) :
        # couleur entre jaune et magenta
        H = (g - b) / diffv

    elif (g == maxv) :
        # couleur entre cyan et jaune
        H = 2 + (b - r) / diffv

    elif (b == maxv) :
        # couleur entre magenta et cyan
        H = 4 + (r - g) / diffv

    # Conversion en degrés
    H *= 60

    # pour éviter une valeur négative
    if (H < 0) :
        H += 360

    return [H, L, S]

def hls_to_rgb (H, L, S):
    """
    #---------------------------------------------------------------------------
    # Graphics::hls_to_rgb
    # Algorythme de conversion HLS -> RGB
    #---------------------------------------------------------------------------
    # paramètres :
    #  H : <pourcent>(de 0 à 1) valeur de la composante teinte de la couleur HLS
    #  L : <pourcent>(de 0 à 1) valeur de la composante luminosité de la
    #      couleur HLS
    #  S : <pourcent>(de 0 à 1) valeur de la composante saturation
    #      de la couleur HLS
    #---------------------------------------------------------------------------
    """
    (R, G, B) = 0, 0, 0
    (p1, p2) = 0, 0


    if (L <= 0.5) : 
        p2 = L + (L * S)
    
    else :
        p2 = L + S - (L * S)

    p1 = 2.0 * L - p2

    if (S == 0) :
        # couleur a-chromatique (gris)
        # R = G = B = L
        R = L
        G = L
        B = L

    else :
        # couleurs "Chromatiques"
        R = hls_value(p1, p2, H + 120)
        G = hls_value(p1, p2, H)
        B = hls_value(p1, p2, H - 120)
    
    return [R, G, B]

def hls_value(q1, q2, hue):
    """
    #---------------------------------------------------------------------------
    # Graphics::hls_value (sous fonction interne hls_to_rgb)
    #---------------------------------------------------------------------------
    """
    value = None

    hue = hue % 360

    if (hue < 60) : 
        value = q1 + (q2 - q1) * hue / 60

    elif (hue < 180) : 
        value = q2

    elif (hue < 240) :
        value = q1 + (q2 - q1) * (240 - hue) / 60

    else :
        value = q1

    return value

def hexargbcolor(r, g, b, a = None):
    """
    #---------------------------------------------------------------------------
    # Graphics::hexargbcolor
    # conversion d'une couleur RGB (255,255,255) au format Zinc '#ffffff'
    #---------------------------------------------------------------------------
    """
    hexacolor = "#%02x%02x%02x"% (r, g, b)
    if ( a is not None ):
        hexacolor = "%s;%d"% (hexacolor, a)
    return hexacolor



def hexa2rgb(hexastr):
    """
    #---------------------------------------------------------------------------
    # Graphics::hexa2rgb
    # conversion d'une couleur au format Zinc '#ffffff' en RGB (255,255,255) 
    #---------------------------------------------------------------------------    
    """
    r, g, b = 0, 0, 0
    regex = re.compile("^#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$")
    res = regex.match(hexastr)
    if res is not None :
        r = int(res.group(1), 16)
        g = int(res.group(2), 16)
        b = int(res.group(3), 16)
        return (r/255, g/255, b/255)
    else :
        raise ValueError("Not a hexa color")

def get_pattern (filename, **options):
    """
    #---------------------------------------------------------------------------
    # RESOURCES GRAPHIQUES PATTERNS, TEXTURES, IMAGES, GRADIENTS, COULEURS...
    #---------------------------------------------------------------------------
    #---------------------------------------------------------------------------
    # Graphics::get_pattern
    # retourne la ressource bitmap en l'initialisant si première utilisation
    #---------------------------------------------------------------------------
    # paramètres :
    # filename : nom du fichier bitmap pattern
    # options
    # -storage : <hastable> référence de la table de stockage de patterns
    #---------------------------------------------------------------------------
    """
    if (options.has_key('storage')):
        table = options['storage']
    else :
        table = bitmaps
    if (not table.has_key(filename)) :
        bitmap = "@%s"% (find_inc(filename))
        table[filename] = bitmap
    return table[filename]

def get_texture(widget, filename, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::get_texture
    # retourne l'image de texture en l'initialisant si première utilisation
    #---------------------------------------------------------------------------
    # paramètres :
    #   widget : <widget> identifiant du widget zinc
    # filename : nom du fichier texture
    # options
    # -storage : <hastable> référence de la table de stockage de textures
    #---------------------------------------------------------------------------
    """
    if (options.has_key('storage')):
        table = options['storage']
    else :
        table = textures
    return get_image(widget, filename, storage = table)

class FileNotFound (Exception):
    """
    #---------------------------------------------------------------------------
    # Graphics::FileNotFound
    # Classe d'exception levée lorsqu'un fichier n'est pas trouvé
    # paramètres :
    #   filename : nom du fichier
    #---------------------------------------------------------------------------    
    """
    def __init__(self, filename):
        Exception.__init__(self, "File %s not Found"%(filename))

def find_inc(name):
    """
    #---------------------------------------------------------------------------
    # Graphics::find_inc
    # recherche le fichier dans les répertoires de PYTHONPATH
    #---------------------------------------------------------------------------
    """
    import sys
    import os.path
    for path in sys.path:
        tfile = os.path.join(path, name)
        if (os.path.isfile(tfile)):
            return tfile
    raise FileNotFound(name)
            
    
def get_image(zinc, filename, storage = {}):
    """
    #---------------------------------------------------------------------------
    # Graphics::get_image
    # retourne la ressource image en l'initialisant si première utilisation
    #---------------------------------------------------------------------------
    # paramètres :
    #   widget : <widget> identifiant du widget zinc
    # filename : nom du fichier image
    # options
    # storage : <hastable> référence de la table de stockage d'images
    #---------------------------------------------------------------------------
    """
    if (not storage.has_key(filename)):
        im = PIL.Image.open(find_inc(filename))
        #Cela marche uniquement si Tkinter.Tk a une instance
        image = PIL.ImageTk.PhotoImage(im)
        storage[filename] = image
    return storage[filename]

def init_pixmaps(widget, *pixfiles, **options):
    """
    #---------------------------------------------------------------------------
    # Graphics::init_pixmaps
    # initialise une liste de fichier image
    #---------------------------------------------------------------------------
    # paramètres :
    #    widget : <widget> identifiant du widget zinc
    # filenames : <filenameList> list des noms des fichier image
    # options
    #  storage : <hastable> référence de la table de stockage d'images
    #---------------------------------------------------------------------------
    """
    imgs = []
    for pixfile in pixfiles:
        imgs.append(get_image(widget, pixfile, **options))
    return imgs

def _trunc(f, n):
    """
    #---------------------------------------------------------------------------
    # Graphics::_trunc
    # fonction interne de troncature des nombres: n = position décimale 
    #---------------------------------------------------------------------------
    """
    import fpformat
    return fpformat.fix(f, n)

#Local Variables:
#mode : python
#tab-width: 4
#end:
