####################################################################################################
# @author: clark.li
# @date: 2015/10/22
#
# This makefile defines the rule to program binary through stlink
#
# Variables that need to be defined outside this makefile:
#   TARGET: A phony target name. For example: program
#   $(TARGET)_bin: Input binary file
#   $(TARGET)_offset: Memory offset to program at
#
# N.B. This makefile might be included multiple times for different target names, so
# most variables in this file are expanded as simple variables
#
####################################################################################################

# Do not add to dependency list of all

.PHONY: $(TARGET)
$(TARGET): $($(TARGET)_bin)
	st-flash write $^ $($(TARGET)_offset)
