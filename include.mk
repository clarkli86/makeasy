####################################################################################################
# @author: clark.li
# @date: 2015/09/23
#
# Include to use functions in this makefile library
#
####################################################################################################
# Get directory of this makefile
topdir := $(dir $(lastword $(MAKEFILE_LIST)))

# Folder to place interdiatary objects
builddir ?= build

# Include common functions. topdir is defined in
include $(topdir)/functions.mk

# Define this target before any other
.PHONY: all
all :

# Target-specific pre-requisites will be added to these targets in targets/makefiles
.PHONY: clean
clean :

# $(call add_gcc_target, target_name, sources, include_dirs,
#   cflags, cppflags, cxxflags, ldflags, ldlibs)
define add_gcc_target
TARGET := $(1)
# When this macro is expanded, TARGET is not defined. All references to it will empty.
# Escape $(TARGET) so it can be expanded after TARGET is defined
$$(TARGET)_sources := $(2)
$$(TARGET)_include_dirs := $(3)
$$(TARGET)_CFLAGS := $(4)
$$(TARGET)_CPPFLAGS := $(5)
$$(TARGET)_CXXFLAGS := $(6)
$$(TARGET)_LDFLAGS := $(7)
$$(TARGET)_LDLIBS := $(8)

include $(topdir)/targets/gcc_base.mk

endef

# $(call add_gcc_arm_none_eabi_target, target_name, arm_sources, thumb_sources,
#   include_dirs, cflags, cppflags, cxxflags, ldflags, ldlibs)
# Add ARM bare-metal targets
define add_gcc_arm_none_eabi_target
TARGET := $(1)
# When this macro is expanded, TARGET is not defined. All references to it will empty.
# Escape $(TARGET) so it can be expanded after TARGET is defined
# This is the cross compile prefix for gcc. For example: arm-none-eabi- or arm-v5te-none-eabi-
$$(TARGET)_cross := $(2)
$$(TARGET)_arm_sources := $(3)
$$(TARGET)_thumb_sources := $(4)
$$(TARGET)_include_dirs := $(5)
$$(TARGET)_CFLAGS := $(6)
$$(TARGET)_CPPFLAGS := $(7)
$$(TARGET)_CXXFLAGS := $(8)
$$(TARGET)_LDFLAGS := $(9)
$$(TARGET)_LDLIBS := $(10)

include $(topdir)/targets/gcc_arm_none_eabi.mk

endef
