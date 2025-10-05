decompress_cpp := decompress.cpp

decompress_obj := $(decompress_cpp:.cpp=.obj)

decompress_lib := decompress.lib

$(decompress_obj): $(decompress_cpp)
	cl /nologo /MT /TP /O2 /c /DWIN32 /DNDEBUG /D_LIB /FIcrn_core.h /I..\inc /I..\crnlib $^

$(decompress_lib): $(decompress_obj)
	lib /nologo $^ /out:$(decompress_lib)

.PHONY: distclean
distclean:
	del $(decompress_obj)

.PHONY: clean
clean:
	del $(decompress_obj) $(decompress_lib)

.PHONY: all
all: $(decompress_lib)
