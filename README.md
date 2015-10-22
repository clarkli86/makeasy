This is a template makefile for small-scale applications

# Example
```Makefile
include makeasy/include.mk
# First target is a debug build with -g flags
$(eval $(call add_gcc_target, test_debug, c_source.c main.cpp, , -std=c99 -g -pg, -std=c++11 -g -pg, -Wall -Werror, , ))
# Second target is a release build without -g flags
$(eval $(call add_gcc_target, test_release, c_source.c main.cpp, , , -std=c++11, -Wall -Werror, , ))
# Create binary file from ELF
$(eval $(call add_objcopy_target, test_release.bin,, test_release))
# More targets
```

# Features
1. Common targets (application, clean)
2. You own Makefile will be very small
3. Automatically generate and include make dependencies
4. Support multiple targets (debug, release, different platforms)

# Similar projects
1. Shake-N-Make (http://wanderinghorse.net/computing/make/)
   It only supports sources in the same directory
2. EMake (https://code.google.com/p/easymake/)
   It requires special comments to get project information
