# To download packages, we use direct URLs from PyPI. We could have used "pip
# download" as well, but that runs "python setup.py egg_info" on the downloaded
# package. In the case of matplotlib and maybe others, this triggers a
# dependency check that fails because we can't give this command arguments.

$(build-python-modules): $(crossenv)
	. $(CROSSENV_ACTIVATE) \
	&& build-pip install wheel numpy scipy Cython Tempita \
	&& cross-expose wheel setuptools
	touch $@

PYTHON_SHLIBS := m

NUMPY_URL := https://github.com/numpy/numpy/archive/v1.16.1.tar.gz
NUMPY_ZIP := $(call download,$(NUMPY_URL))
NUMPY_EXTRACT := $(call extract,$(NUMPY_ZIP),numpy-1.16.1)
NUMPY_WHEEL := $(WORKING)/wheels/numpy-1.16.1-cp36-cp36m-linux_arm.whl
NUMPY_CORE_LIB := lib/python3.6/site-packages/numpy/core/lib

$(NUMPY_EXTRACT)/site.cfg: $(NUMPY_EXTRACT).extracted
	echo '[openblas]' > $@
	echo 'libraries = openblas' >> $@
	echo "library_dirs = $(INSTALL)/lib" >> $@
	echo "include_dirs = $(INSTALL)/include" >> $@

# Scipy needs to statically link numpy.core's libnpymath. The build
# script tries to use build-numpy which won't work, so we need to move
# host-numpy.core to build-numpy.
$(NUMPY_WHEEL): $(NUMPY_EXTRACT)/site.cfg \
		$(build-python-modules) | $(WHEELS)
	. $(CROSSENV_ACTIVATE) \
	&& cd $(NUMPY_EXTRACT) \
	&& F90=$(CROSS_FC) \
		F77=$(CROSS_FC) \
		AR=$(CROSS_AR) \
		RANLIB=$(CROSS_RANLIB) \
		LD=$(CROSS_LD) \
		cross-python setup.py build_ext \
			--libraries $(PYTHON_SHLIBS) \
			bdist_wheel --dist-dir=$(WHEELS) \
	&& pip install  -I --prefix=$(INSTALL) -f $(WHEELS) \
		numpy==1.16.1 \
	&& rm -r $(CROSSENV)/build/$(NUMPY_CORE_LIB) \
	&& ln -s $(INSTALL)/$(NUMPY_CORE_LIB) \
		$(CROSSENV)/build/$(NUMPY_CORE_LIB)

$(host-python-wheels): $(NUMPY_WHEEL)


SCIPY_URL := https://github.com/scipy/scipy/releases/download/v1.2.0/scipy-1.2.0.tar.xz
SCIPY_ZIP := $(call download,$(SCIPY_URL))
SCIPY_EXTRACT := $(call extract,$(SCIPY_ZIP))
SCIPY_WHEEL := $(WORKING)/wheels/scipy-1.2.0-cp36-cp36m-linux_arm.whl

$(SCIPY_EXTRACT)/site.cfg: $(SCIPY_EXTRACT).extracted
	echo '[openblas]' > $@
	echo 'libraries = openblas' >> $@
	echo "library_dirs = $(INSTALL)/lib" >> $@
	echo "include_dirs = $(INSTALL)/include" >> $@
	echo "runtime_library_dirs = $(INSTALL)/lib" >> $@

$(SCIPY_WHEEL): $(SCIPY_EXTRACT)/site.cfg $(build-python-modules) \
		$(NUMPY_WHEEL) | $(WHEELS)
	. $(CROSSENV_ACTIVATE) \
	&& cd $(SCIPY_EXTRACT) \
	&& F90=$(CROSS_FC) \
	F77=$(CROSS_FC) \
	AR=$(CROSS_AR) \
	RANLIB=$(CROSS_RANLIB) \
	LD=$(CROSS_LD) \
	cross-python setup.py build_ext \
	--libraries $(PYTHON_SHLIBS) \
	bdist_wheel --dist-dir=$(WHEELS) \

$(host-python-wheels): $(SCIPY_WHEEL)


SKLEARN_URL := https://github.com/scikit-learn/scikit-learn/archive/0.20.2.tar.gz
SKLEARN_ZIP := $(call download,$(SKLEARN_URL))
SKLEARN_EXTRACT := $(call extract,$(SKLEARN_ZIP),scikit-learn-0.20.2)
SKLEARN_WHEEL := $(WORKING)/wheels/scikit_learn-0.20.2-cp36-cp36m-linux_arm.whl

$(SKLEARN_EXTRACT)/site.cfg: $(SKLEARN_EXTRACT).extracted
	echo '[openblas]' > $@
	echo 'libraries = openblas' >> $@
	echo "library_dirs = $(INSTALL)/lib" >> $@
	echo "include_dirs = $(INSTALL)/include" >> $@
	echo "runtime_library_dirs = $(INSTALL)/lib" >> $@

$(SKLEARN_WHEEL): $(SKLEARN_EXTRACT)/site.cfg $(build-python-modules) \
		$(NUMPY_WHEEL) $(SCIPY_WHEEL) | $(WHEELS)
	. $(CROSSENV_ACTIVATE) \
	&& cd $(SKLEARN_EXTRACT) \
	&& cross-expose numpy scipy \
	&& F90=$(CROSS_FC) \
	F77=$(CROSS_FC) \
	AR=$(CROSS_AR) \
	RANLIB=$(CROSS_RANLIB) \
	LD=$(CROSS_LD) \
	cross-python setup.py build_ext \
	--libraries $(PYTHON_SHLIBS) \
	bdist_wheel --dist-dir=$(WHEELS) \
	&& cross-expose -u numpy scipy

$(host-python-wheels): $(SKLEARN_WHEEL)


PANDAS_URL := https://files.pythonhosted.org/packages/d2/1b/dd36a304c9e78b64abf828d261f2e62e1be2447bc3bc06ccad5250265b27/pandas-0.24.0.tar.gz
PANDAS_TAR := $(call download,$(PANDAS_URL))
PANDAS_EXTRACT := $(call extract,$(PANDAS_TAR))
PANDAS_WHEEL := $(WHEELS)/pandas-0.24.0-cp36-cp36m-linux_arm.whl

# Force this after numpy build so that cross-expose doesn't mess
# things up in a parallel build.
$(PANDAS_WHEEL): $(PANDAS_EXTRACT).extracted $(build-python-modules) \
		$(NUMPY_WHEEL) $(SCIPY_WHEEL) | $(WHEELS)
	. $(CROSSENV_ACTIVATE) \
	&& cd $(PANDAS_EXTRACT) \
	&& cross-expose Cython numpy Tempita \
	&& cross-python setup.py build_ext --libraries $(PYTHON_SHLIBS) \
			bdist_wheel --dist-dir=$(dir $@) \
	&& cross-expose -u Cython numpy Tempita

$(host-python-wheels): $(PANDAS_WHEEL)

$(host-python-modules): $(host-python-wheels)
	. $(CROSSENV_ACTIVATE) \
	&& pip install -I --prefix=$(INSTALL) -f $(WHEELS) \
		numpy==1.16.1 pandas==0.24.0 scipy==1.2.0 \
		scikit-learn==0.20.2	pip setuptools
	touch $@
