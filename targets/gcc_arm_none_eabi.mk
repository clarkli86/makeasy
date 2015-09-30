####################################################################################################
# @author: clark.li
# @date: 2015/09/30
#
# This makefile defines the common targets of C/C++ applications. It also automatically generates
# dependencies files.
#
# Variables that need to be defined outside this makefile:
#   TARGET: Target application name
#   $(TARGET)_asm_sources: Assembly sources that need to be compiled and linked
#   $(TARGET)_arm_sources: C/C++ sources that need to be compiled to ARM instructions
#   $(TARGET)_thumb_sources: C/C++ sources that need to be compiled to THUMB instructions
#   $(TARGET)_include_dirs: C/C++ header directories
#   $(TARGET)_CFLAGS: C only compiler flags
#   $(TARGET)_CPPFLAGS: C++ only compiler flags
#   $(TARGET)_CXXFLAGS: C/C++ common compiler flags
#   $(TARGET)_LDFLAGS: Linker flags
#   $(TARGET)_LDLIBS: Libraries to link with
#
# N.B. This makefile might be included multiple times for different target names, so
# most variables in this file are expanded as simple variables
#
####################################################################################################

# Create objects for all .c and .cpp in current directory
# Filter sources before patsubst otherwise .cpp/.c will appear in the final value of objects_debug
$(TARGET)_asm_objects := $(call source_to_obj, $(builddir)/$(TARGET), $($(TARGET)_asm_sources))
$(TARGET)_arm_objects := $(call source_to_obj, $(builddir)/$(TARGET), $($(TARGET)_arm_sources))
$(TARGET)_thumb_objects := $(call source_to_obj, $(builddir)/$(TARGET), $($(TARGET)_thumb_sources))

# Include dependencies
-include $($(TARGET)_asm_objects:.o=.d) $($(TARGET)_arm_objects:.o=.d) $($(TARGET)_thumb_objects:.o=.d)

# Add to dependency list of all
all : $(TARGET)

$(TARGET) : $($(TARGET)_asm_objects) $($(TARGET)_arm_objects) $($(TARGET)_thumb_objects)
	$(call link.cxx.app, $(CXX), $($@_LDFLAGS), $($@_LIBFLAGS))

# $(call instruction_set)
# Must be called from recipes. It uses automatic variable $@
# It returns -marm or -mthumb according whether $@ is in $(TARGET)_arm_objects
arm_instruction_set = \
	$(if $(filter $@, $($(target)_arm_objects)), -marm, \
	$(if $(filter $@, $($(target)_thumb_objects)), -mthumb,))

# Getting target name from $@
$(builddir)/$(TARGET)/%.o : target = $(word 2, $(subst /, , $@))

# Can't use Static Pattern Rule like
# $(TARGET)_arm_objects : $(builddir)/$(TARGET)/%.o : %.cpp
# Because the targets in Static Pattern Rule can only appear once. It cannot be used for %.cpp
# %.cc and %.c at the same time.
# arm_instruction_set function is used to check whether target is an arm object or thumb object
$(builddir)/$(TARGET)/%.o : %.cpp
	$(call mk_obj_dir)
	$(call compile.cxx, $(CXX), $(arm_instruction_set) $($(target)_CXXFLAGS) $($(target)_CPPFLAGS))
	$(call generate_dependency, $(CXX), $($(target)_CXXFLAGS) $($(target)_CPPFLAGS))

$(builddir)/$(TARGET)/%.o : %.cc
	$(call mk_obj_dir)
	$(call compile.cxx, $(CXX), $(arm_instruction_set) $($(target)_CXXFLAGS) $($(target)_CPPFLAGS))
	$(call generate_dependency, $(CXX), $($(target)_CXXFLAGS) $($(target)_CPPFLAGS))

$(builddir)/$(TARGET)/%.o : %.c
	$(call mk_obj_dir)
	$(call compile.cxx, $(CC),  $(arm_instruction_set) $($(target)_CXXFLAGS) $($(target)_CFLAGS))
	$(call generate_dependency, $(CC), $($(target)_CXXFLAGS) $($(target)_CFLAGS))

.PHONY: $(TARGET)_clean
# Retrieve target name from $@
$(TARGET)_clean : target = $(@:_clean=)
$(TARGET)_clean :
	$(RM) -rf $(target) \
		$($(target)_asm_objects) $($(target)_asm_objects:.o=.d) \
		$($(target)_arm_objects) $($(target)_arm_objects:.o=.d) \
		$($(target)_thumb_objects) $($(target)_thumb_objects:.o=.d)

# when make debug at top level, $(TARGET)_debug will be built
clean: $(TARGET)_clean

############################## NOT USED ###########################################################
# Variables in target and pre-requisites are expanded when makefile is read, but
# the variables in the rule are expanded when the target is executed. Thus variables like TARGET, CC_FLAGS may have been overwriten when the rule gets executed so
# they should not be referenced directly in the rule.
# To overcome this issue, a local variable STORED_TARGET_NAME is created to save the
# target name when this makefile is read. It is also an empty target so $(TARGET)_clean also remembers the target name when this makefile is read.
#
# Although target name can be retrieved by spliting $(TARGET)_clean using underscore, the method above employs one of most import features of make.
# stored_target_name := $(TARGET)
# .PHONY: $(stored_target_name)
# $(stored_target_name):
############################## NOT USED ###########################################################
