SQLITE_VERSION := 3.26.0
SQLITE_URL := https://sqlite.org/2018/sqlite-autoconf-3260000.tar.gz
SQLITE_TAR := $(call download,$(SQLITE_URL))
SQLITE_EXTRACT := $(call extract,$(SQLITE_TAR))
SQLITE := $(INSTALL)/lib/libsqlite3.so

$(SQLITE_EXTRACT)/Makefile: $(SQLITE_EXTRACT).extracted $(host-toolchain)
	cd $(dir $@) \
	&& ./configure \
		--prefix=$(INSTALL) \
		--host=$(HOST) \
		--build=$(BUILD) \
		CFLAGS="$(CROSS_CFLAGS)" \
		LDFLAGS="$(CROSS_LDFLAGS)" \
		CC="$(CROSS_CC)"

$(SQLITE): $(SQLITE_EXTRACT)/Makefile
	$(MAKE) -C $(SQLITE_EXTRACT)
	$(MAKE) -C $(SQLITE_EXTRACT) install

$(compile-host-1): $(SQLITE)
