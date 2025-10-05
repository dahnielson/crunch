compress_cpp := compress.cpp

compress_obj := $(compress_cpp:.cpp=.obj)

compress_lib := compress.lib

$(compress_obj): $(compress_cpp)
	cl /nologo /MT /TP /O2 /c /DWIN32 /DNDEBUG /D_LIB /FIcrn_core.h /I..\inc /I..\crnlib $^

$(compress_lib): $(compress_obj)
	lib /nologo $^ /out:$(compress_lib)

.PHONY: distclean
distclean:
	del $(compress_obj)

.PHONY: clean
clean:
	del $(compress_obj) $(compress_lib)

.PHONY: all
all: $(compress_lib)
