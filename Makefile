PKG=ch341prog

prefix = /usr/local
bindir = $(prefix)/bin
sharedir = $(prefix)/share
mandir = $(sharedir)/man
man1dir = $(mandir)/man1

# Modern compiler flags
CFLAGS ?= -std=c17 -O2 -Wall -Wextra -Wpedantic -D_POSIX_C_SOURCE=200809L \
       $(shell pkg-config --cflags libusb-1.0)
LDFLAGS ?= $(shell pkg-config --libs libusb-1.0)

$(PKG): main.c ch341a.c ch341a.h
	$(CC) $(CFLAGS) ch341a.c main.c -o $(PKG) $(LDFLAGS)
clean:
	rm *.o $(PKG) -f
install-udev-rule:
	cp 99-ch341a-prog.rules /etc/udev/rules.d/
	udevadm control --reload-rules
.PHONY: clean install-udev-rule

install: $(PKG)
	install $(PKG) $(DESTDIR)$(bindir)
	install -m 0664 99-ch341a-prog.rules $(DESTDIR)/etc/udev/rules.d/99-ch341a-prog.rules

debian/changelog:
	#gbp dch --debian-tag='%(version)s' -S -a --ignore-branch -N '$(VERSION)'
	dch --create -v 1.0-1 --package $(PKG)

deb:
	dpkg-buildpackage -b -us -uc
.PHONY: install debian/changelog deb
