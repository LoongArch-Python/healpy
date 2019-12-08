import numpy as np
cimport numpy as np
from libcpp.vector cimport vector

import cython
from healpy import npix2nside, nside2npix
from healpy.pixelfunc import maptype

from _common cimport Healpix_Map, RING, ndarray2map

cdef extern from "hotspots.h":
    cdef void hotspots(const Healpix_Map[double] &inmap,
                       Healpix_Map[double] &outmap,
                       vector[int] &maskmin,
                       vector[int] &maskmax);

def hotspots_healpy(m):
    """Find extrema in the 2-D field on the sphere.

    Parameters
    ----------
    m : array-like, shape (Npix,)
      The input map.

    Returns
    -------
    outmap : array-like, shape (Npix,)
      Out map of extrema (other pixels are set to UNSEEN)

    min_pixels : array_like
      Pixel number for minima

    max_pixels : array_like
      Pixel number for maxima

    Example
    -------
    >>> import healpy as hp
    >>> import numpy as np
    >>> nside = 16
    >>> outmap, min_pixels, max_pixels = hp.hotspots(np.random.randn(12*nside**2))

    """

    info = maptype(m)
    if info == 0:
        mi = m.astype(np.float64, order='C', copy=True)
    elif info == 1:
        mi = m[0].astype(np.float64, order='C', copy=True)
    else:
        raise ValueError("Wrong input map (must be a valid healpix map)")

    # View the ndarray as a Healpix_Map
    M = ndarray2map(mi, RING)

    # Declare output arrays
    npix = mi.size
    mhs = np.empty(npix, dtype=np.float64)
    MHS = ndarray2map(mhs, RING)
    cdef vector[int] vmin;
    cdef vector[int] vmax;

    hotspots(M[0], MHS[0], vmin, vmax)

    del M, MHS
    return mhs, np.array(vmin), np.array(vmax)
