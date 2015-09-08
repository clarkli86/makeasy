####################################################################################################
# @author: clark.li
# @date: 2015/09/08
#
# Template Main Makefile for C/C++ applicatons.
#
# This file should only be changed when choosing a target platform or passing flags to the platform.
# Sources should be added in souces.mk. Flags should be added in flags.mk.
# If a new target platform is needed, consider adding a new makefile under targets
#
# Flags that can be optinally defined for additional libraries:
#   USE_GTEST: Set it to 1 to link to gtest and use its main() as application entry
####################################################################################################

####################################################################################################
# Target application name
####################################################################################################
TARGET := test

####################################################################################################
# Source files
####################################################################################################
include sources.mk

####################################################################################################
# Include compiler and linker flags
####################################################################################################
include flags.mk

####################################################################################################
# Optional flags for gcc target
####################################################################################################
USE_GOOGLETEST ?= 1
## When using googletest, it may be necessary to set its main folder
GTEST_DIR ?= googletest

####################################################################################################
# Targets makefile
####################################################################################################
makefiles_dir = ../
include $(makefiles_dir)/targets/gcc_base.mk
