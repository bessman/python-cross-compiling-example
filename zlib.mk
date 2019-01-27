ZLIB_VERSION := 1.2.11
ZLIB_URL := https://www.zlib.net/zlib-1.2.11.tar.gz
ZLIB_TAR := $(call download,$(ZLIB_URL))
ZLIB_EXTRACT := $(call extract,$(ZLIB_TAR))
ZLIB := $(INSTALL)/lib/libz.so

$(ZLIB_EXTRACT)/Makefile: $(ZLIB_EXTRACT).extracted $(host-toolchain)
	cd $(dir $@) \
	&& CHOST="$(HOST)" \
		CFLAGS="$(CROSS_CFLAGS)" \
		LDFLAGS="$(CROSS_LDFLAGS)" \
		CC="$(CROSS_CC)" \
		./configure \
			--prefix=$(INSTALL)

$(ZLIB): $(ZLIB_EXTRACT)/Makefile
	$(MAKE) -C $(ZLIB_EXTRACT)
	$(MAKE) -C $(ZLIB_EXTRACT) install

$(compile-host-1): $(ZLIB)
