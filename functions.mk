####################################################################################################
# @author: clark.li
# @date: 2015/09/30
#
# Common functions used by makefiles
#
####################################################################################################

# $(call source_to_obj, objdir, sources)
# Convert C/C++ sources to target object files
source_to_obj = \
	$(patsubst %.s, $(1)/%.o, $(abspath $(filter %.s, $(2)))) \
	$(patsubst %.c, $(1)/%.o, $(abspath $(filter %.c, $(2)))) \
	$(patsubst %.cpp, $(1)/%.o, $(abspath $(filter %.cpp, $(2)))) \
	$(patsubst %.cc, $(1)/%.o, $(abspath $(filter %.cc, $(2))))

# $(call to_include_dirs, include_dirs_var)
# Add gcc-style include dirs
to_include_dir = $(addprefix -I, $($(1)))

# $(call mk_obj_dir)
# Must be used in recipes only. It references to automatic variable $@
define mk_obj_dir
	mkdir -p $(dir $@)
endef

# $(call generate_dependency, compiler, flags)
# Must be used in recipes only. It references to automatic variable $< and $@
define generate_dependency
	$(1) $(2) -MM $< | sed 's|[a-zA-Z0-9_-]*\.o|$(dir $@)&|' > $(@:.o=.d)
endef

# $(call compile.cxx, compiler, flags)
# Must be used in recipes only. It references to automatic variable $< and $@
define compile.cxx
	$(1) $(2) -c $< -o $@
endef

# $(call link.cxx.app, linker, ldflags, ldlibs)
# Must be used in recipes only. It references to automatic variable $< and $@
define link.cxx.app
	$(1) $^ -o $@ $(2) $(3)
endef
