TARGET := test

# used by both C and CXX. Applied implicity to $(CC)
CPPFLAGS := -Wall -Werror
CFLAGS := -std=c99
CXXFLAGS := -std=c++11

$(TARGET)_debug_CPPFLAGS := -g -pg
$(TARGET)_release_CPPFLAGS :=

# Placeholder for variables used by implicit rules
LDFLAGS :=
LDLIBS :=

# Placeholder for dependency file search dirs. Separated by colon
VPATH :=

# Create objects for all .c and .cpp in current directory
objects_debug := $(patsubst %.c, debug/%.o, $(wildcard *.c)) $(patsubst %.cpp, debug/%.o, $(wildcard *.cpp))
objects_release := $(patsubst %.c, release/%.o, $(wildcard *.c)) $(patsubst %.cpp, release/%.o, $(wildcard *.cpp))

.PHONY: all
all : $(TARGET)_debug $(TARGET)_release

# debug and release are phony targets
.PHONY: debug
debug: $(TARGET)_debug

.PHONY: release
release: $(TARGET)_release

# Include dependencies
-include $(objects_debug:.o=.d)
-include $(objects_release:.o=.d)

$(TARGET)_debug : $(objects_debug)
	$(CXX) -g -pg -o $@ $^

$(TARGET)_release: $(objects_release)
	$(CXX) -o $@ $^

# Compile differently for debug and release targets
debug/%.o : %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -g -pg -c $(filter %.cpp, $^) -o $@
	$(CXX) -MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

release/%.o : %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $(filter %.cpp, $^) -o $@
	$(CXX) -MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

debug/%.o : %.c
	mkdir -p $(dir $@)
	$(CC) $(CXXFLAGS) $(CLAGS) -g -pg -c $(filter %.c, $^) -o $@
	$(CC) -MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

release/%.o : %.c
	mkdir -p $(dir $@)
	$(CC) $(CXXFLAGS) $(CLAGS) -c $(filter %.c, $^) -o $@
	$(CC) -MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

# @TODO Placehoder for gcov
.PHONY: gcov

# @TODO Placeholder for unit test
.PHONY: unittest

.PHONY: clean
clean:
	-rm $(TARGET)_debug $(TARGET)_release $(objects_debug) $(objects_release)
