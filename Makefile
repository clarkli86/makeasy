### Begin command line arguments
# If link to gtest source code
LINK_GTEST ?= 0
GTEST_DIR ?= googletest
### End command line arguments

ifeq (1, ${LINK_GTEST})
	include gtest.mk
endif

# Target application name
TARGET := test

# used by both C and CXX. Applied implicity to $(CC)
CPPFLAGS += -Wall -Werror
CFLAGS += -std=c99
CXXFLAGS += -std=c++11

$(TARGET)_debug_CPPFLAGS := -g -pg
$(TARGET)_release_CPPFLAGS :=

# Placeholder for variables used by implicit rules
LDFLAGS +=
LDLIBS +=

# Placeholder for dependency file search dirs. Separated by colon
VPATH :=

sources += main.cpp c_source.c

# Create objects for all .c and .cpp in current directory
objects_debug := $(patsubst %.c, debug/%.o, $(filter %.c, $(sources))) $(patsubst %.cpp, debug/%.o, $(filter %.cpp, $(sources))) $(patsubst %.cc, debug/%.o, $(filter %.cc, $(sources)))
objects_release := $(patsubst %.c, release/%.o, $(filter %.c, $(sources))) $(patsubst %.cpp, release/%.o, $(filter %.cpp, $(sources))) $(patsubst %.cc, release/%.o, $(filter %.cc, $(sources)))

.PHONY: all
all : $(TARGET)_debug $(TARGET)_release

.PHONY: target
target:
	echo $(objects_debug)

# debug and release are phony targets
.PHONY: debug
debug: $(TARGET)_debug

.PHONY: release
release: $(TARGET)_release

# Include dependencies
-include $(objects_debug:.o=.d)
-include $(objects_release:.o=.d)

$(TARGET)_debug : $(objects_debug)
	$(CXX) $(LDFLAGS) $(LDLIBS) -g -pg -o $@ $^

$(TARGET)_release: $(objects_release)
	$(CXX) $(LDFLAGS) $(LDLIBS) -o $@ $^

# Compile differently for debug and release targets
debug/%.o : %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(includes) -g -pg -c $(filter %.cpp, $^) -o $@
	$(CXX) $(includes) -MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

release/%.o : %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(includes) -c $(filter %.cpp, $^) -o $@
	$(CXX) $(includes) -MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

debug/%.o : %.cc
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(includes) -g -pg -c $< -o $@
	$(CXX) $(includes) -MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

release/%.o : %.cc
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(includes) -c $< -o $@
	$(CXX) $(includes) -MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

debug/%.o : %.c
	mkdir -p $(dir $@)
	$(CC) $(CXXFLAGS) $(CLAGS) $(includes) -g -pg -c $(filter %.c, $^) -o $@
	$(CC) $(includes) -MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

release/%.o : %.c
	mkdir -p $(dir $@)
	$(CC) $(CXXFLAGS) $(CLAGS) $(includes) -c $(filter %.c, $^) -o $@
	$(CC) $(includes) -MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

# @TODO Placehoder for gcov
.PHONY: gcov

# @TODO Placeholder for unit test
.PHONY: unittest

.PHONY: clean
clean:
	-rm $(TARGET)_debug $(TARGET)_release $(objects_debug) $(objects_release)
