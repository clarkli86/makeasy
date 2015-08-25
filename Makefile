TARGET := test

# used by both C and CXX. Applied implicity to $(CC)
CPPFLAGS := -Wall -Werror
CFLAGS := -std=c99
CXXFLAGS := -std=c++11

# Placeholder for variables used by implicit rules
LDFLAGS :=
LDLIBS :=

objects := main.o c_source.o

$(TARGET) : $(objects)
	$(CXX) -o test $^

%.o : %.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $^

PHONY: clean
clean:
	-rm $(TARGET) $(objects)
