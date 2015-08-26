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
# @TODO: create different folders for debug and release
objects_debug := $(patsubst %.c, %.o, $(wildcard *.c)) $(patsubst %.cpp, %.o, $(wildcard *.cpp))
objects_release := $(patsubst %.c, %.o, $(wildcard *.c)) $(patsubst %.cpp, %.o, $(wildcard *.cpp))

.PHONY: all
all : $(TARGET)_debug $(TARGET)_release

# debug and release are phony targets
.PHONY: debug
debug: $(TARGET)_debug

.PHONY: release
release: $(TARGET)_release

$(TARGET)_debug : $(objects_debug)
	$(CXX) -o $@ $^

$(TARGET)_release: $(objects_release)
	echo $^
	$(CXX) -o $@ $^

# Compile differently for debug and release targets
# @TODO Create different folders for debug and release
%.o : %.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $^
	$(CXX) -MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)

# Include dependencies
-include $(objects_debug:.o=.d)
-include $(objects_release:.o=.d)

# @TODO Placehoder for gcov
.PHONY: gcov

# @TODO Placeholder for unit test
.PHONY: unittest

.PHONY: clean
clean:
	-rm $(TARGET)_debug $(TARGET)_release $(objects_debug) $(objects_release)
