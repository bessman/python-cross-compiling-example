# To download packages, we use direct URLs from PyPI. We could have used "pip
# download" as well, but that runs "python setup.py egg_info" on the downloaded
# package. In the case of matplotlib and maybe others, this triggers a
# dependency check that fails because we can't give this command arguments.

$(build-python-modules): $(crossenv)
	. $(CROSSENV_ACTIVATE) \
	&& build-pip install wheel Cython numpy Tempita \
	&& cross-expose wheel setuptools
	touch $@

PYTHON_SHLIBS := m

NUMPY_URL := https://files.pythonhosted.org/packages/04/b6/d7faa70a3e3eac39f943cc6a6a64ce378259677de516bd899dd9eb8f9b32/numpy-1.16.0.zip
NUMPY_ZIP := $(call download,$(NUMPY_URL))
NUMPY_EXTRACT := $(call extract,$(NUMPY_ZIP),numpy-1.16.0)
NUMPY_WHEEL := $(WORKING)/wheels/numpy-1.16.0-cp36-cp36m-linux_arm.whl

$(NUMPY_WHEEL): $(NUMPY_EXTRACT).extracted \
		$(build-python-modules) | $(WHEELS)
	. $(CROSSENV_ACTIVATE) \
	&& cd $(NUMPY_EXTRACT) \
	&& LAPACK=None BLAS=None ATLAS=None \
		cross-python setup.py build_ext --libraries $(PYTHON_SHLIBS) \
			bdist_wheel --dist-dir=$(WHEELS)

$(host-python-wheels): $(NUMPY_WHEEL)

PANDAS_URL := https://files.pythonhosted.org/packages/d2/1b/dd36a304c9e78b64abf828d261f2e62e1be2447bc3bc06ccad5250265b27/pandas-0.24.0.tar.gz
PANDAS_TAR := $(call download,$(PANDAS_URL))
PANDAS_EXTRACT := $(call extract,$(PANDAS_TAR))
PANDAS_WHEEL := $(WHEELS)/pandas-0.24.0-cp36-cp36m-linux_arm.whl

# Force this after numpy build so that cross-expose doesn't mess
# things up in a parallel build.
$(PANDAS_WHEEL): $(PANDAS_EXTRACT).extracted $(build-python-modules) \
		$(NUMPY_WHEEL) | $(WHEELS)
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
		numpy==1.16.0 pandas==0.24.0 \
		pip setuptools
	touch $@
