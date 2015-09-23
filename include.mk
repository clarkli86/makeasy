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
TARGET :=
sources :=
include_dirs :=
CFLAGS :=
CPPFLAGS :=
CXXFLAGS :=
LDFLAGS :=
LDLIBS :=
endef

# $(call add_gcc_target, target_name, sources, include_dirs,
#   cflags, cppflags, cxxflags, ldflags, ldlibs)
define add_gcc_target
# Call parameter to simple variables for gcc_base.mk
TARGET := $(1)
sources := $(2)
include_dirs := $(3)
# @TODO This might be a problem when a second target is added, the second target
# might refine target_CFLAGS. As a result, the first target rule may use the
# value of target_CFLAGS defined for the second target
CFLAGS := $(4)
CPPFLAGS := $(5)
CXXFLAGS := $(6)
LDFLAGS := $(7)
LDLIBS := $(8)
include $(topdir)/targets/gcc_base.mk

$(eval, $(call, clear_variables))
endef
