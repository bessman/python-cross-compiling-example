Python Cross Compiling Example
==============================

This repository is a worked example of cross compiling a non-trivial Python app
to run on Linux on ARM. It is a fork from https://github.com/benfogle/python-cross-compiling-example.
The makefile above will download all dependencies, build them, and produce a tarball containing:

- Python 3.6 for linux-gnueabihf
- Numpy (with OpenBLAS)
- Pandas
- Scipy
- Scikit-learn


Building
========

The makefile is written and tested on Debian Stretch. Consult
``docker/Dockerfile`` in this repository for details of the prerequisites that
should be installed on the build machine.

To build, it should be enough to run ``make``.

To build using Docker, first build the image:

.. code:: sh

    $ docker build https://raw.githubusercontent.com/ezeenova/python-cross-compiling-example/linux-gnu-armhf/docker/Dockerfile

Then run the image:

.. code:: sh

    $ docker run --rm \
        -v /path/to/working:/working \
        -v /path/to/output:/output \
        -v /path/to/this/repo:/source \
        <image>

Where ``working`` is a scratch directory for intermediate build files.


Running
=======

To run, move the resulting files to the target device. Rather than
run Python directly, which requires setting ``LD_LIBRARY_PATH``, run the script
``bin/apython``, which will set it for you.

