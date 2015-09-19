####################################################################################################
# @author: clark.li
# @date: 2015/09/08
#
# This makefile defines the common targets of C/C++ applications. It also automatically generates
# dependencies files.
#
# Variables that need to be defined outside this makefile:
#   includes: C/C++ header directories
#   sources: C/C++ sources that need to be compiled and linked
#   TARGET: Target application name
#   CXX: C++ compiler
#   CC: C++ compiler
#   CFLAGS: C only compiler flags
#   CPPFLAGS: C++ only compiler flags
#   CXXFLAGS: C/C++ common compiler flags
#
# Flags that can be optinally defined for additional libraries:
#   USE_GTEST: Set it to 1 to link to gtest and use its main() as application entry
####################################################################################################

###############################################################################
# Link to googletest library and use it as application entry
###############################################################################
ifeq (1, ${USE_GOOGLETEST})
	include $(makefiles_dir)/targets/googletest.mk
endif
ifeq (1, ${USE_GOOGLEMOCK})
	include $(makefiles_dir)/targets/googlemock.mk
endif

# Create objects for all .c and .cpp in current directory
# Filter sources before patsubst otherwise .cpp/.c will appear in the final value of objects_debug
objects_debug = $(patsubst %.c, debug/%.o, $(filter %.c, $(sources))) $(patsubst %.cpp, debug/%.o, $(filter %.cpp, $(sources))) $(patsubst %.cc, debug/%.o, $(filter %.cc, $(sources)))
objects_release = $(patsubst %.c, release/%.o, $(filter %.c, $(sources))) $(patsubst %.cpp, release/%.o, $(filter %.cpp, $(sources))) $(patsubst %.cc, release/%.o, $(filter %.cc, $(sources)))

# Remove all references to upper level folders
objects_debug := $(subst ../,, $(objects_debug))
# Add upper level folders to implicit rule search path
VPATH += .:..

# @TODO
# When I have more than one target (linux, smartfusion2), this all needs to defined in the top-level
# makefile. linux and smartfusion2 need to be passed to the target makefiles as target name.
# When top-level Makefile includes targets/gcc_base.mk and targets/smart_fusion_2.mk, the targets are
# all, linux_debug, linux_release, smartfusion2_debug, smartfusion2_release
.PHONY: all
all : $(TARGET)_debug $(TARGET)_release

# Debug target to print variable values
.PHONY: target
target:
	echo $(subst_debug)

# debug and release are phony targets
.PHONY: debug
debug: $(TARGET)_debug

.PHONY: release
release: $(TARGET)_release

# Include dependencies
-include $(objects_debug:.o=.d)
-include $(objects_release:.o=.d)

$(TARGET)_debug : $(objects_debug)
	$(CXX) $(LDFLAGS) $(debug_LDFLAGS) -o $@ $^ $(LDLIBS) $(debug_LIBFLAGS)

$(TARGET)_release: $(objects_release)
	$(CXX) $(LDFLAGS) $(release_LDFLAGS) -o $@ $^ $(LDLIBS) $(release_LIBFLAGS)

# Compile differently for debug and release targets
debug/%.o : %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(debug_CXXFLAGS) $(debug_CPPFLAGS) $(includes) \
		-c $(filter %.cpp, $^) -o $@
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(debug_CXXFLAGS) $(debug_CPPFLAGS) $(includes) \
		-MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

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
	mkdir -p $(dir $@)
	$(CC) $(CXXFLAGS) $(CFLAGS) $(debug_CXXFLAGS) $(debug_CFLAGS) $(includes) \
		-c $(filter %.c, $^) -o $@
	$(CC) $(CXXFLAGS) $(CFLAGS) $(debug_CXXFLAGS) $(debug_CFLAGS) $(includes) \
		-MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

release/%.o : %.c
	mkdir -p $(dir $@)
	$(CC) $(CXXFLAGS) $(CFLAGS) $(release_CXXFLAGS) $(release_CFLAGS) $(includes) \
		-c $(filter %.c, $^) -o $@
	$(CC) $(CXXFLAGS) $(CFLAGS) $(release_CXXFLAGS) $(release_CFLAGS) $(includes) \
		-MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

# @TODO Placehoder for gcov
.PHONY: gcov

.PHONY: clean
clean:
	-rm $(TARGET)_debug $(TARGET)_release $(objects_debug) $(objects_release) $(objects_debug:.o=.d) $(objects_release:.o=.d)
