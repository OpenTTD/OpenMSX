# Makefile for OpenSFX set

MAKEFILELOCAL=Makefile.local
MAKEFILECONFIG=Makefile.config

SHELL = /bin/sh

# Add some OS detection and guess an install path (use the system's default)
OSTYPE:=$(shell uname -s)
ifeq ($(OSTYPE),Linux)
INSTALLDIR:=$(HOME)/.openttd/gm
else
ifeq ($(OSTYPE),Darwin)
INSTALLDIR:=$(HOME)/Documents/OpenTTD/gm
else
ifeq ($(shell echo "$(OSTYPE)" | cut -d_ -f1),MINGW32)
INSTALLDIR:=C:\Documents and Settings\$(USERNAME)\My Documents\OpenTTD\gm
else
INSTALLDIR:=
endif
endif
endif

# define a few repository references used also in makefile.config
REPO_REVISION := $(shell hg parent --template="{rev}\n")
REPO_MODIFIED := $(shell [ -n "`hg status '.' | grep -v '^?'`" ] && echo "M" || echo "")
REPO_TAGS     := $(shell hg parent --template="{tags}" | grep -v "tip" | cut -d\  -f1)

include ${MAKEFILECONFIG}

# OS detection: Cygwin vs Linux
ISCYGWIN := $(shell [ ! -d /cygdrive/ ]; echo $$?)

# this overrides definitions from above:
-include ${MAKEFILELOCAL}

DIR_BASE       := $(FILENAME)-
VERSION_STRING := $(shell [ -n "$(REPO_TAGS)" ] && echo $(REPO_TAGS)$(REPO_MODIFIED) || echo $(REPO_NIGHTLYNAME)-r$(REPO_REVISION)$(REPO_MODIFIED))
DIR_NAME       := $(shell [ -n "$(REPO_TAGS)" ] && echo $(DIR_BASE)$(VERSION_STRING) || echo $(DIR_BASE)$(REPO_NIGHTLYNAME))
DIR_NAME_SRC   := $(DIR_BASE)$(VERSION_STRING)-source
# Tarname has no version: overwrite for make install
TAR_FILENAME   := $(DIR_NAME).$(TAR_SUFFIX)
# The release filenames bear the version being built.
ZIP_FILENAME   := $(DIR_BASE)$(VERSION_STRING).$(ZIP_SUFFIX)
BZIP_FILENAME  := $(DIR_BASE)$(VERSION_STRING).$(BZIP2_SUFFIX)
MIDI_FILES     := $(shell cat $(LIST_FILENAME) | scripts/midifiles.py)

REPO_DIRS      := $(dir $(BUNDLE_FILES))

-include ${MAKEFILELOCAL}

vpath

.PHONY: clean all bundle bundle_tar bundle_zip bundle_bzip install release release_zip remake test
.SUFFIXES:
# Now, the fun stuff:

# Target for all:
all : test_rev $(REPO_FILENAME)

test :
	$(_E) "Local installation directory: $(INSTALLDIR)"
	$(_E) "Repository revision:          r$(REPO_REVISION)"
	$(_E) "REPO title:                   $(REPO_TITLE)"
	$(_E) "REPO filename:                $(REPO_FILENAME)"
	$(_E) "Documentation filenames:      $(DOC_FILENAMES)"
	$(_E) "Bundle files:                 $(BUNDLE_FILES)"
	$(_E) "Midi files:                   $(MIDI_FILES)"
	$(_E) "Bundle filenames:             Tar=$(TAR_FILENAME) Zip=$(ZIP_FILENAME) Bz2=$(BZIP_FILENAME)"
	$(_E) "Dirs (base and full):         $(DIR_BASE) / $(DIR_NAME)"
	$(_E) "Path to Unix2Dos:             $(UNIX2DOS)"
	$(_E) "===="

$(REPO_FILENAME) : $(LIST_FILENAME) $(MIDI_FILES) $(DESC_FILENAME) $(README_FILENAME) $(CHANGELOG_FILENAME) $(LICENSE_FILENAME) $(REV_FILENAME)
	$(_E) "[Generating:] $(REPO_FILENAME)"
	@echo "[metadata]" > $(REPO_FILENAME)
	@echo "name        = $(REPO_NAME)" >> $(REPO_FILENAME)
	@echo "shortname   = $(REPO_SHORTNAME)" >> $(REPO_FILENAME)
	@echo "version     = $(REPO_REVISION)" >> $(REPO_FILENAME)
	$(_V) cat $(DESC_FILENAME) | sed 's/$$/ [$(REPO_TITLE)]/' >> $(REPO_FILENAME)

	@echo "" >> $(REPO_FILENAME)
	@echo "[files]" >> $(REPO_FILENAME)
	$(_V) cat $(LIST_FILENAME) | scripts/playlist.py >> $(REPO_FILENAME)

	@echo "" >> $(REPO_FILENAME)
	@echo "[md5s]" >> $(REPO_FILENAME)
	$(_V) cat $(LIST_FILENAME) | scripts/sanitize_list.py | scripts/md5list.py >> $(REPO_FILENAME)
	
	@echo "" >> $(REPO_FILENAME)
	@echo "[names]" >> $(REPO_FILENAME)
	$(_V) cat $(LIST_FILENAME) | scripts/sanitize_list.py | scripts/namelist.py >> $(REPO_FILENAME)
	
	@echo "" >> $(REPO_FILENAME)
	@echo "[origin]" >> $(REPO_FILENAME)
	@echo "$(REPO_ORIGIN)" >> $(REPO_FILENAME)
	$(_E) "[Done] Basesound successfully generated."
	$(_E) ""

%.txt: %.ptxt
	$(_E) "[Generating:] $@"
	$(_V) cat $< \
		| sed -e "s/$(REPO_TITLE_DUMMY)/$(REPO_TITLE)/" \
		| sed -e "s/$(REPO_FILENAME_DUMMY)/$(REPO_FILENAME)/" \
		| sed -e "s/$(REPO_REVISION_DUMMY)/$(REPO_REVISION)/" \
		> $@
	
docs/readme.txt: docs/readme.ptxt
	$(_E) "[Generating:] $@"
	$(_V) cat $< \
		| sed -e "s/$(REPO_TITLE_DUMMY)/$(REPO_TITLE)/" \
		| sed -e "s/$(REPO_FILENAME_DUMMY)/$(REPO_FILENAME)/" \
		| sed -e "s/$(REPO_REVISION_DUMMY)/$(REPO_REVISION)/" \
		> $@
	$(_V) cat $(LIST_FILENAME) | scripts/sanitize_list.py | scripts/authorlist.py >> $@

$(REV_FILENAME):
	echo "$(REPO_REVISION)" > $(REV_FILENAME)
test_rev:
	@echo "[Version check]"
	@echo "$(shell [ "`cat $(REV_FILENAME)`" = "$(VERSION_STRING)" ] && echo "No change." || (echo "Change detected." && echo "$(VERSION_STRING)" > $(REV_FILENAME)))"

# Clean the source tree
clean:
	$(_E) "[Cleaning]"
	$(_V)-rm -rf *.orig *.pre *.bak *~ $(DOC_FILENAMES) $(SRCDIR)/*.bak

mrproper: clean
	$(_V)-rm -rf $(DIR_BASE)* $(REPO_FILENAME) $(DIR_NAME_SRC)

$(DIR_NAME) : $(BUNDLE_FILES) $(MIDI_FILES)
	$(_E) "[BUNDLE]"
	$(_E) "[Generating:] $@/."
	$(_V)if [ -e $@ ]; then rm -rf $@; fi
	$(_V)mkdir $@
	$(_V)-for i in $(BUNDLE_FILES); do cp $$i $@; done
	$(_V)-for i in $(MIDI_FILES); do cp $$i $@; done
bundle: $(DIR_NAME)

#%.$(TXT_SUFFIX): %.$(PTXT_SUFFIX)
#	$(_E) "[Generating:] $@"
#	$(_V) cat $< \
#		| sed -e "s/$(CAT_TITLE_DUMMY)/$(CAT_TITLE)/" \
#		| sed -e "s/$(REPO_FILENAME_DUMMY)/$(REPO_FILENAME)/" \
#		| sed -e "s/$(REVISION_DUMMY)/$(CAT_REVISION)/" \
#		> $@

%.$(TAR_SUFFIX): % $(BUNDLE_FILES)
# Create the release bundle with all files in one tar
	$(_E) "[Generating:] $@"
	$(_V)$(TAR) $(TAR_FLAGS) $@ $(basename $@)
	$(_E)

bundle_tar: $(TAR_FILENAME)
bundle_zip: $(ZIP_FILENAME)
$(ZIP_FILENAME): $(DIR_NAME)
	$(_E) "[Generating:] $@"
	$(_V)$(ZIP) $(ZIP_FLAGS) $@ $^
bundle_bzip: $(BZIP_FILENAME)
$(BZIP_FILENAME): $(TAR_FILENAME)
	$(_E) "[Generating:] $@"
	$(_V)$(BZIP) $(BZIP_FLAGS) $^

# Installation process
install: $(TAR_FILENAME) $(INSTALLDIR)
	$(_E) "[INSTALL] to $(INSTALLDIR)"
	$(_V)-cp -r $(DIR_NAME) $(INSTALLDIR)
#	$(_V)-cp $(REPO_FILENAM) $(INSTALLDIR)
#	$(_V)-cp $(TAR_FILENAME) $(INSTALLDIR)
#	$(_E)

bundle_src:
	$(_V) rm -rf $(DIR_NAME_SRC)
	$(_V) mkdir -p $(DIR_NAME_SRC)
	$(_V) cp -R $(SRCDIR) $(DOCDIR) Makefile Makefile.config $(DIR_NAME_SRC)
	$(_V) cp Makefile.local.sample $(DIR_NAME_SRC)/Makefile.local
	$(_V) echo 'REPO_REVISION = $(REPO_REVISION)' >> $(DIR_NAME_SRC)/Makefile.local
	$(_V) echo 'REPO_MODIFIED = $(REPO_MODIFIED)' >> $(DIR_NAME_SRC)/Makefile.local
	$(_V) echo 'REPO_TAGS    = $(REPO_TAGS)'    >> $(DIR_NAME_SRC)/Makefile.local
	$(_V) $(MAKE) -C $(DIR_NAME_SRC) mrproper
	$(_V) $(TAR) --gzip -cf $(DIR_NAME_SRC).tar.gz $(DIR_NAME_SRC)
	$(_V) rm -rf $(DIR_NAME_SRC)


$(INSTALLDIR):
	$(_E) "Install dir didn't exist. Creating $@"
	$(_V) mkdir -p $(INSTALLDIR)

remake: clean all
