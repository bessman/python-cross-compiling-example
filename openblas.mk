OPENBLAS_URL := http://github.com/xianyi/OpenBLAS/archive/v0.2.20.tar.gz
OPENBLAS_TAR := $(call download,$(OPENBLAS_URL))
OPENBLAS_EXTRACT := $(call extract,$(OPENBLAS_TAR),OpenBLAS-0.2.20)
OPENBLAS := $(INSTALL)/lib/libopenblas.so

$(OPENBLAS_EXTRACT)/Makefile: $(OPENBLAS_EXTRACT).extracted $(host-toolchain)

$(OPENBLAS): $(OPENBLAS_EXTRACT)/Makefile
	$(MAKE) -C $(OPENBLAS_EXTRACT) \
		CC=$(CROSS_CC) \
		FC=$(CROSS_FC) \
		HOSTCC=gcc \
		TARGET=CORTEXA9
	$(MAKE) -C $(OPENBLAS_EXTRACT) \
		PREFIX=$(INSTALL) \
		install

$(compile-host-1): $(OPENBLAS)
