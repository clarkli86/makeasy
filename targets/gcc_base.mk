####################################################################################################
# @author: clark.li
# @date: 2015/09/08
#
# This makefile defines the common targets of C/C++ applications. It also automatically generates
# dependencies files.
#
# Variables that need to be defined outside this makefile:
#   TARGET: Target application name
#   $(TARGET)_sources: C/C++ sources that need to be compiled and linked
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
$(TARGET)_objects := $(call source_to_obj, $(builddir)/$(TARGET), $($(TARGET)_sources))

# Add include dirs to CXXFLAGS
# Be careful the space before the first argument to to_include_dir matters
$(TARGET)_CXXFLAGS += $(call to_include_dir,$(TARGET)_include_dirs)

# Include dependencies
-include $($(TARGET)_objects:.o=.d)

# Add to dependency list of all
all : $(TARGET)

$(TARGET) : $($(TARGET)_objects)
	$(call link.cxx.app, $(CXX), $($@_LDFLAGS), $($@_LDLIBS))

# Getting target name from $@ seems the easiest way to get the original TARGET value.
# The following approach have been tried and failed:
#  * Target-specific variable. It is expanded when rule is executed
#  * Define variables like $(TARGET)_xxx. It always references the last assigned value of
#    $(TARGET) because $(TARGET) itself can get overwriten
#  * Define phony target like $(TARGET)_xxx and add it as pre-requisites. This phony target
#    always triggers a rebuild.
#  * Define orderly pre-requisites. Not supported by pattern rule
#
#  The following approaches have not been tried:
#  * Save the flags to a file like Linux Kernel KBuild
#  * Define this whole file as a macro so flags are expanded when this macro is called
$(builddir)/$(TARGET)/%.o : target = $(word 2, $(subst /, , $@))
$(builddir)/$(TARGET)/%.o : %.cpp
	$(call mk_obj_dir)
	$(call compile.cxx, $(CXX), $($(target)_CXXFLAGS) $($(target)_CPPFLAGS))
	$(call generate_dependency, $(CXX), $($(target)_CXXFLAGS) $($(target)_CPPFLAGS))

$(builddir)/$(TARGET)/%.o : %.cc
	$(call mk_obj_dir)
	$(call compile.cxx, $(CXX), $($(target)_CXXFLAGS) $($(target)_CPPFLAGS))
	$(call generate_dependency, $(CXX), $($(target)_CXXFLAGS) $($(target)_CPPFLAGS))

$(builddir)/$(TARGET)/%.o : %.c
	$(call mk_obj_dir)
	$(call compile.cxx, $(CC), $($(target)_CXXFLAGS) $($(target)_CFLAGS))
	$(call generate_dependency, $(CC), $($(target)_CXXFLAGS) $($(target)_CFLAGS))

.PHONY: $(TARGET)_clean
# Retrieve target name from $@
$(TARGET)_clean : target = $(@:_clean=)
$(TARGET)_clean :
	$(RM) -rf $(target) $($(target)_objects) $($(target)_objects:.o=.d)

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
