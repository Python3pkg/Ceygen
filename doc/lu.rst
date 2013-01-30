==================================
LU decomposition-powered functions
==================================

This module contains algebraic functions powered by the LU matrix decomposition (as
provided by the <`Eigen/LU`_> include), most notably matrix inverse and determinant.

.. module:: ceygen.lu

.. function:: inv(x[, out=None])

   Return matrix inverse computed using LU decomposition with partial pivoting. It is your
   responsibility to ensure that *x* is invertible, otherwise you get undefined result
   without any warning.

   :param x: matrix to invert
   :type x: |matrix|
   :param out: |out|
   :type out: |matrix|
   :raises: |valueerror|
   :raises: |typeerror|
   :rtype: |matrix|

.. _`Eigen/LU`: http://eigen.tuxfamily.org/dox/QuickRefPage.html#QuickRef_Headers

.. include:: definitions.rst