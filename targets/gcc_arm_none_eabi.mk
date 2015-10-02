####################################################################################################
# @author: clark.li
# @date: 2015/09/30
#
# This makefile defines the common targets of C/C++ applications. It also automatically generates
# dependencies files.
#
# Variables that need to be defined outside this makefile:
#   TARGET: Target application name
#   $(TARGET)_cross: Cross-compiler prefix
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
$(TARGET)_arm_objects := $(call source_to_obj, $(builddir)/$(TARGET), $($(TARGET)_arm_sources))
$(TARGET)_thumb_objects := $(call source_to_obj, $(builddir)/$(TARGET), $($(TARGET)_thumb_sources))

# Add include dirs to CXXFLAGS
# Be careful the space before the first argument to to_include_dir matters
$(TARGET)_CXXFLAGS += $(call to_include_dir,$(TARGET)_include_dirs)

# Include dependencies
-include $($(TARGET)_arm_objects:.o=.d) $($(TARGET)_thumb_objects:.o=.d)

# Add to dependency list of all
all : $(TARGET)

$(TARGET) : $($(TARGET)_arm_objects) $($(TARGET)_thumb_objects)
	$(call link.cxx.app, $($@_cross)$(CXX), $($@_LDFLAGS), $($@_LDLIBS))

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
	$(call compile.cxx, $($(target)_cross)$(CXX), $(arm_instruction_set) $($(target)_CXXFLAGS) $($(target)_CPPFLAGS))
	$(call generate_dependency, $($(target)_cross)$(CXX), $($(target)_CXXFLAGS) $($(target)_CPPFLAGS))

$(builddir)/$(TARGET)/%.o : %.cc
	$(call mk_obj_dir)
	$(call compile.cxx, $($(target)_cross)$(CXX), $(arm_instruction_set) $($(target)_CXXFLAGS) $($(target)_CPPFLAGS))
	$(call generate_dependency, $($(target)_cross)$(CXX), $($(target)_CXXFLAGS) $($(target)_CPPFLAGS))

$(builddir)/$(TARGET)/%.o : %.c
	$(call mk_obj_dir)
	$(call compile.cxx, $($(target)_cross)$(CC),  $(arm_instruction_set) $($(target)_CXXFLAGS) $($(target)_CFLAGS))
	$(call generate_dependency, $($(target)_cross)$(CC), $($(target)_CXXFLAGS) $($(target)_CFLAGS))

$(builddir)/$(TARGET)/%.o : %.s
	$(call mk_obj_dir)
	$(call compile.cxx, $($(target)_cross)$(CC),  $(arm_instruction_set) $($(target)_CXXFLAGS) $($(target)_CFLAGS))
	$(call generate_dependency, $($(target)_cross)$(CC), $($(target)_CXXFLAGS) $($(target)_CFLAGS))

.PHONY: $(TARGET)_clean
# Retrieve target name from $@
$(TARGET)_clean : target = $(@:_clean=)
$(TARGET)_clean :
	$(RM) -rf $(target) \
		$($(target)_arm_objects) $($(target)_arm_objects:.o=.d) \
		$($(target)_thumb_objects) $($(target)_thumb_objects:.o=.d)

# when make debug at top level, $(TARGET)_debug will be built
clean: $(TARGET)_clean
