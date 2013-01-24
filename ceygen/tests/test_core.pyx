# -*- coding: utf-8 -*-
# Copyright (c) 2013 Matěj Laitl <matej@laitl.cz>
# Distributed under the terms of the GNU General Public License v2 or any
# later version of the license, at your option.

"""Tests for core"""

import numpy as np

from support import CeygenTestCase
cimport ceygen.core as c

class TestCore(CeygenTestCase):

    def test_dotvv(self):
        x_np = np.array([1., 2., 3.])
        y_np = np.array([4., 5., 6.])
        self.assertAlmostEqual(c.dotvv(x_np, y_np), 32.)
        cdef double[:] x = x_np
        cdef double[:] y = y_np
        self.assertAlmostEqual(c.dotvv(x, y), 32.)

    def test_dotvv_strides(self):
        x = np.array([[1., 2.], [3., 4.]])
        e1 = np.array([1., 0.])
        e2 = np.array([0., 1.])

        self.assertAlmostEqual(c.dotvv(x[0, :], e1), 1.)
        self.assertAlmostEqual(c.dotvv(x[0, :], e2), 2.)
        self.assertAlmostEqual(c.dotvv(x[1, :], e1), 3.)
        self.assertAlmostEqual(c.dotvv(x[1, :], e2), 4.)

        self.assertAlmostEqual(c.dotvv(x[:, 0], e1), 1.)
        self.assertAlmostEqual(c.dotvv(x[:, 0], e2), 3.)
        self.assertAlmostEqual(c.dotvv(x[:, 1], e1), 2.)
        self.assertAlmostEqual(c.dotvv(x[:, 1], e2), 4.)

    def test_dotvv_baddims(self):
        x = np.array([1., 2., 3.])
        y = np.array([4., 5.])
        z = np.array([[1., 2.], [3., 4.]])
        def dotvv(x, y):
            # wrap up because c.dotvv is cython-only (not callable from Python)
            return c.dotvv(x, y)

        self.assertRaises(StandardError, dotvv, x, y)
        self.assertRaises(StandardError, dotvv, x, z)

    def test_dotvv_none(self):
        x = np.array([1., 2., 3.])
        def dotvv(x, y):
            return c.dotvv(x, y)
        self.assertRaises(StandardError, dotvv, x, None)
        self.assertRaises(StandardError, dotvv, x, "Hello")
        self.assertRaises(StandardError, dotvv, None, x)
        self.assertRaises(StandardError, dotvv, "Hello", x)

    def test_dotmv(self):
        x_np = np.array([[1., 2., 3.], [3., 2., 1.]])
        y_np = np.array([4., 5., 6.])
        self.assertApproxEqual(c.dotmv(x_np, y_np), np.array([32., 28.]))
        self.assertApproxEqual(c.dotmv(x_np, y_np), np.array([32., 28.]).T)
        self.assertApproxEqual(c.dotmv(x_np, y_np, None), np.array([32., 28.]))
        out_np = np.zeros(2)
        out2_np = c.dotmv(x_np, y_np, out_np)
        self.assertApproxEqual(out_np, np.array([32., 28.]))  # test that it actually uses out
        self.assertApproxEqual(out2_np, np.array([32., 28.]))

        cdef double[:, :] x = x_np
        cdef double[:] y = y_np
        self.assertApproxEqual(c.dotmv(x, y), np.array([32., 28.]))
        cdef double[:] out = out_np
        cdef double[:] out2 = c.dotmv(x_np, y_np, out)
        self.assertApproxEqual(out, np.array([32., 28.]))  # test that it actually uses out
        self.assertApproxEqual(out2, np.array([32., 28.]))

    def test_dotmv_transposed(self):
        x_np = np.array([[1., 2., 3.], [3., 2., 1.]])
        y_np = np.array([4., 5.])
        self.assertApproxEqual(c.dotmv(x_np.T, y_np), np.array([19., 18., 17.]))

    def test_dotmv_strides(self):
        big = np.array([[[1., 2.], [3., 4.]],
                        [[5., 6.], [7., 8.]]])
        e1 = np.array([1., 0.])
        e2 = np.array([0., 1.])
        self.assertApproxEqual(c.dotmv(big[0, :, :], e1), np.array([1., 3.]))
        self.assertApproxEqual(c.dotmv(big[0, :, :], e2), np.array([2., 4.]))
        self.assertApproxEqual(c.dotmv(big[1, :, :], e1), np.array([5., 7.]))
        self.assertApproxEqual(c.dotmv(big[1, :, :], e2), np.array([6., 8.]))

        self.assertApproxEqual(c.dotmv(big[:, 0, :], e1), np.array([1., 5.]))
        self.assertApproxEqual(c.dotmv(big[:, 0, :], e2), np.array([2., 6.]))
        self.assertApproxEqual(c.dotmv(big[:, 1, :], e1), np.array([3., 7.]))
        self.assertApproxEqual(c.dotmv(big[:, 1, :], e2), np.array([4., 8.]))

        self.assertApproxEqual(c.dotmv(big[:, :, 0], e1), np.array([1., 5.]))
        self.assertApproxEqual(c.dotmv(big[:, :, 0], e2), np.array([3., 7.]))
        self.assertApproxEqual(c.dotmv(big[:, :, 1], e1), np.array([2., 6.]))
        self.assertApproxEqual(c.dotmv(big[:, :, 1], e2), np.array([4., 8.]))

    def test_dotmv_baddims(self):
        def dotmv(x, y, out=None):
            return c.dotmv(x, y, out)
        X = np.array([[1., 2., 3.],[2., 3., 4.]])
        y = np.array([1., 2., 3.])
        self.assertRaises(StandardError, dotmv, np.array([1., 2.]), np.array([1., 2.]))
        self.assertRaises(StandardError, dotmv, X, np.array([1., 2.]))
        self.assertRaises(StandardError, dotmv, X, np.array([1.]))
        self.assertRaises(StandardError, dotmv, X.T, y)

        # good x, y dims, but bad out dims
        self.assertRaises(StandardError, dotmv, X, y, np.zeros(1))
        self.assertRaises(StandardError, dotmv, X, y, np.zeros(3))

    def test_dotmv_none(self):
        x, y, out = np.array([[3.]]), np.array([2.]), np.zeros(1)
        for X in (x, None):
            for Y in (y, None):
                for out in (None, out):
                    if X is x and Y is y:
                        continue  # this case would be valid
                    try:
                        c.dotmv(X, Y, out)
                    except StandardError as e:
                        #print e
                        pass
                    else:
                        self.fail("StandardError was not raised (X={0}, Y={1}, out={2}".format(X, Y, out))