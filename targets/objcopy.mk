####################################################################################################
# @author: clark.li
# @date: 2015/10/22
#
# This makefile defines the rule to make binary file from ELF
#
# Variables that need to be defined outside this makefile:
#   TARGET: Target application name
#   $(TARGET)_cross: Cross-compiler prefix
#   $(TARGET)_elf: Input ELF file
#   $(TARGET): Output BIN file
#
# N.B. This makefile might be included multiple times for different target names, so
# most variables in this file are expanded as simple variables
#
####################################################################################################

# Add to dependency list of all
all : $(TARGET)

$(TARGET): $($(TARGET)_elf)
	$($(@)_cross)objcopy -O binary $^ $@

.PHONY: $(TARGET)_clean
# Retrieve target name from $@
$(TARGET)_clean : target = $(@:_clean=)
$(TARGET)_clean :
	$(RM) -rf $(target) \

clean: $(TARGET)_clean
