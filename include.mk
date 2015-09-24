####################################################################################################
# @author: clark.li
# @date: 2015/09/23
#
# Include to use functions in this makefile library
#
####################################################################################################
# Get directory of this makefile
topdir := $(dir $(lastword $(MAKEFILE_LIST)))

# Define this target before any other
.PHONY: all
all : debug release

# Target-specific pre-requisites will be added to these targets in targets/makefiles
.PHONY: clean
clean :

.PHONY: debug
debug:

.PHONY: release
release:

# $(call clear_variables)
define clear_variables
# These variables are common to every target makefile
# @TODO Is this stll needed
DLIBS :=
endef

# @TODO Move this functio to gcc_base.mk and the actual makefile to gcc_base_impl.mk
# $(call add_gcc_target, target_name, sources, include_dirs,
#   cflags, cppflags, cxxflags, ldflags, ldlibs)
define add_gcc_target
# Call parameter to simple variables for gcc_base.mk
TARGET := $(1)
# @TODO $(1)_sources work but $(TARGET)_sources do not?
# $$(TARGET)_sources also works, why?
# Is it because when this macro is expanded, TARGET is not defined. So references to it need to be escaped. Otherwise
# it is expanded to defined _sources := $(2)
$$(TARGET)_sources := $(2)
$$(TARGET)_include_dirs := $(3)
$$(TARGET)_CFLAGS := $(4)
$$(TARGET)_CPPFLAGS := $(5)
$$(TARGET)_CXXFLAGS := $(6)
$$(TARGET)_LDFLAGS := $(7)
$$(TARGET)_LDLIBS := $(8)
include $(topdir)/targets/gcc_base.mk

$(eval, $(call, clear_variables))
endef
