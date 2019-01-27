OPENSSL_URL := https://www.openssl.org/source/openssl-1.1.0g.tar.gz
OPENSSL_TAR := $(call download,$(OPENSSL_URL))
OPENSSL_EXTRACT := $(call extract,$(OPENSSL_TAR))
OPENSSL_LIB := $(INSTALL)/lib/libssl.a

$(OPENSSL_EXTRACT)/Makefile: $(OPENSSL_EXTRACT).extracted $(host-toolchain)
	cd $(dir $@) \
	&& ./Configure \
		--prefix=$(INSTALL) \
		$(CROSS_CPPFLAGS) \
		$(CROSS_CFLAGS) \
		$(CROSS_LDFLAGS) \
		linux-armv4

$(OPENSSL_LIB): export CC = $(CROSS_CC)
$(OPENSSL_LIB): export CROSS_SYSROOT = $(HOST_SYSROOT)
$(OPENSSL_LIB): $(OPENSSL_EXTRACT)/Makefile
	$(MAKE) -C $(OPENSSL_EXTRACT)
	$(MAKE) -C $(OPENSSL_EXTRACT) install_dev

$(compile-host-1): $(OPENSSL_LIB)
