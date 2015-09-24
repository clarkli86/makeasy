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
# N.B. This makefile might be included multiple times for different target names, so any arguments
# that are used in the rule must be saved using empty targets. See the example of $(TARGET)_clean
#
####################################################################################################

# Variables in target and pre-requisites are expanded when makefile is read, but
# the variables in the rule are expanded when the target is executed. Thus variables like TARGET, CC_FLAGS may have been overwriten when the rule gets executed so
# they should not be referenced directly in the rule.
# To overcome this issue, a local variable STORED_TARGET_NAME is created to save the
# target name when this makefile is read. It is also an empty target so $(TARGET)_clean also remembers the target name when this makefile is read.
#
# Although target name can be retrieved by spliting $(TARGET)_clean using underscore, the method above employs one of most import features of make.
stored_target_name := $(TARGET)
.PHONY: $(stored_target_name)
$(stored_target_name):

# Save the arguments in empty targets
$(TARGET)_debug_CFLAGS := -g $($(TARGET)_CFLAGS) $($(TARGET)_CXXFLAGS) $(addprefix -I, $($(TARGET)_include_dirs))
$(TARGET)_release_CFLAGS := $($(TARGET)_CFLAGS) $($(TARGET)_CXXFLAGS) $(addprefix -I, $($(TARGET)_include_dirs))
$(TARGET)_debug_CPPFLAGS := -g $($(TARGET)_CPPFLAGS) $($(TARGET)_CXXFLAGS) $(addprefix -I, $($(TARGET)_include_dirs))
$(TARGET)_release_CPPFLAGS := $($(TARGET)_CPPFLAGS) $($(TARGET)_CXXFLAGS) $(addprefix -I, $($(TARGET)_include_dirs))
$(TARGET)_debug_LDFLAGS := -g $($(TARGET)_LDFLAGS)
$(TARGET)_release_LDFLAGS := $($(TARGET)_LDFLAGS)
$(TARGET)_debug_LDLIBS := -g $($(TARGET)_LDLIBS)
$(TARGET)_release_LDLIBS := $($(TARGET)_LDLIBS)

test:
	echo $(TARGET)_debug_CFLAGS

# Create objects for all .c and .cpp in current directory
# Filter sources before patsubst otherwise .cpp/.c will appear in the final value of objects_debug
objects_debug := \
	$(patsubst %.c, debug/%.o, $(filter %.c, $($(TARGET)_sources))) \
	$(patsubst %.cpp, debug/%.o, $(filter %.cpp, $($(TARGET)_sources))) \
	$(patsubst %.cc, debug/%.o, $(filter %.cc, $($(TARGET)_sources)))
objects_release := \
	$(patsubst %.c, release/%.o, $(filter %.c, $($(TARGET)_sources))) \
	$(patsubst %.cpp, release/%.o, $(filter %.cpp, $($(TARGET)_sources))) \
	$(patsubst %.cc, release/%.o, $(filter %.cc, $($(TARGET)_sources)))

# @TODO Use absolute path of source files
# Remove all references to upper level folders
objects_debug := $(subst ../,, $(objects_debug))
# Add upper level folders to implicit rule search path
VPATH += .:..

# Include dependencies
-include $(objects_debug:.o=.d)
-include $(objects_release:.o=.d)

$(TARGET)_debug : $(objects_debug)
	$(CXX) $(LDFLAGS) $(debug_LDFLAGS) -o $@ $^ $(LDLIBS) $(debug_LIBFLAGS)

$(TARGET)_release: $(objects_release)
	$(CXX) $(LDFLAGS) $(release_LDFLAGS) -o $@ $^ $(LDLIBS) $(release_LIBFLAGS)

# Compile differently for debug and release targets
# @TODO this debug_CPPFLAGS seems to always trigger a rebuild.
# Alternative is to save the flags into a file like linux kernel KBuild
# Another alternative is to define this whole file as a macro so flags are expanded when
# this macro is called
debug/%.o : %.cpp
	mkdir -p $(dir $@)
	$(CXX) $($(name)_debug_CXXFLAGS) $($(name)_debug_CPPFLAGS) -c $< -o $@
	$(CXX) $($(name)_debug_CXXFLAGS) $($(name)_debug_CPPFLAGS) -MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

release/%.o : %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(release_CXXFLAGS) $(release_CPPFLAGS) $(includes) \
		-c $(filter %.cpp, $^) -o $@
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(release_CXXFLAGS) $(release_CPPFLAGS) $(includes) \
		-MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

debug/%.o : %.cc
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(debug_CXXFLAGS) $(debug_CPPFLAGS) $(includes) \
		-c $< -o $@
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(debug_CXXFLAGS) $(debug_CPPFLAGS) $(includes) \
		-MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

release/%.o : %.cc
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(release_CXXFLAGS) $(release_CPPFLAGS) $(includes) \
		-c $< -o $@
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(release_CXXFLAGS) $(release_CPPFLAGS) $(includes) \
		-MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

debug/%.o : %.c
	echo $(lastword $^)
	mkdir -p $(dir $@)
	$(CC) $($(name)_debug_CXXFLAGS) $($(name)_debug_CFLAGS) -c $< -o $@
	$(CC) $($(name)_debug_CXXFLAGS) $($(name)_debug_CFLAGS) -MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

release/%.o : %.c
	mkdir -p $(dir $@)
	$(CC) $(CXXFLAGS) $(CFLAGS) $(release_CXXFLAGS) $(release_CFLAGS) $(includes) \
		-c $(filter %.c, $^) -o $@
	$(CC) $(CXXFLAGS) $(CFLAGS) $(release_CXXFLAGS) $(release_CFLAGS) $(includes) \
		-MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

.PHONY: $(TARGET)_clean
$(TARGET)_clean : $(stored_target_name)
	rm -rf $<_debug $<_release $(objects_debug) $(objects_release) $(objects_debug:.o=.d) $(objects_release:.o=.d)

# when make debug at top level, $(TARGET)_debug will be built
debug: $(TARGET)_debug
release: $(TARGET)_release
clean: $(TARGET)_clean
