APYTHON := $(INSTALL)/bin/apython
$(APYTHON): $(TOP)/apython
	install -m 755 $< $@

# We need some shared libs from the cross toolchain on the target.
LIBSTDCXX := libstdc++.so.6.0.22
$(INSTALL)/lib/$(LIBSTDCXX): | $(INSTALL)/lib
	cp $(CROSS_SYSROOT)/lib/$(LIBSTDCXX) $(INSTALL)/lib \
	&& ln -s $(INSTALL)/lib/$(LIBSTDCXX) \
		$(INSTALL)/lib/libstdc++.so.6 \

LIBGFORTRAN := libgfortran.so.3.0.0
$(INSTALL)/lib/$(LIBGFORTRAN): | $(INSTALL)/lib
	cp $(LIBGFORTRAN) $(INSTALL)/lib \
	&& ln -s $(INSTALL)/lib/$(LIBGFORTRAN) \
		$(INSTALL)/lib/libgfortran.3.so

$(cross-libs): $(INSTALL)/lib/$(LIBGFORTRAN) $(INSTALL)/lib/$(LIBSTDCXX)

PACKAGE := $(OUTPUT)/$(notdir $(INSTALL)).tar

$(package): $(PACKAGE)
$(PACKAGE): $(host-python-modules) $(APYTHON) $(cross-libs)
	tar -C $(dir $(INSTALL)) -cf $@ $(notdir $(INSTALL)) \
		--exclude=*.la \
		--exclude=*.a \
		--exclude=test \
		--exclude=tests \
		--exclude=man \
		--exclude=pkgconfig \
		--exclude=include


clean: clean-package

.PHONY: clean-package
clean-package:
	rm -rf $(PACKAGE)
