TARGET := test

# used by both C and CXX. Applied implicity to $(CC)
CPPFLAGS := -Wall -Werror
CFLAGS := -std=c99
CXXFLAGS := -std=c++11

# Placeholder for variables used by implicit rules
LDFLAGS :=
LDLIBS :=

# Create objects for all .c and .cpp in current directory
objects := $(patsubst %.c, %.o, $(wildcard *.c)) $(patsubst %.cpp, %.o, $(wildcard *.cpp))

$(TARGET) : $(objects)
	$(CXX) -o test $^

%.o : %.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $^

PHONY: clean
clean:
	-rm $(TARGET) $(objects)
