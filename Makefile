VERSION=$(shell ./lazybrake --version|perl -p -e 's/^\D+//; chomp')

ifndef prefix
# This little trick ensures that make install will succeed both for a local
# user and for root. It will also succeed for distro installs as long as
# prefix is set by the builder.
prefix=$(shell perl -e 'if($$< == 0 or $$> == 0) { print "/usr" } else { print "$$ENV{HOME}/.local"}')

# Some additional magic here, what it does is set BINDIR to ~/bin IF we're not
# root AND ~/bin exists, if either of these checks fail, then it falls back to
# the standard $(prefix)/bin. This is also inside ifndef prefix, so if a
# prefix is supplied (for instance meaning this is a packaging), we won't run
# this at all
BINDIR ?= $(shell perl -e 'if(($$< > 0 && $$> > 0) and -e "$$ENV{HOME}/bin") { print "$$ENV{HOME}/bin";exit; } else { print "$(prefix)/bin"}')
endif

DISTFILES = COPYING Makefile NEWS README.md lazybrake.1

default: test
test:
	perl6 -c lazybrake

install:
	mkdir -p "$(BINDIR)"
	cp lazybrake "$(BINDIR)"
	chmod 755 "$(BINDIR)/lazybrake"
	[ -e lazybrake.1 ] && mkdir -p "$(DATADIR)/man/man1" && cp lazybrake.1 "$(DATADIR)/man/man1" || true
localinstall:
	mkdir -p "$(BINDIR)"
	ln -sf $(shell pwd)/lazybrake $(BINDIR)/
	[ -e lazybrake.1 ] && mkdir -p "$(DATADIR)/man/man1" && ln -sf $(shell pwd)/lazybrake.1 "$(DATADIR)/man/man1" || true
# Create a manpage from the POD
man:
	pod2man --name "lazybrake" --center "" --release "lazybrake $(VERSION)" ./manpage.pod ./lazybrake.1
# Create the tarball
distrib: clean man
	mkdir -p lazybrake-$(VERSION)
	cp -r $(DISTFILES) ./lazybrake-$(VERSION)
	tar -jcvf lazybrake-$(VERSION).tar.bz2 ./lazybrake-$(VERSION)
	rm -rf lazybrake-$(VERSION)
	rm -f lazybrake.1
# Clean up the tree
clean:
	rm -f `find|egrep '~$$'`
	rm -f lazybrake-*.tar.bz2 lazybrake-*.tar.bz2.sig
	rm -rf lazybrake-$(VERSION)
	rm -f lazybrake.1
