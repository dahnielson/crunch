crunch_cpp := corpus_gen.cpp corpus_test.cpp crunch.cpp

crunch_obj := $(crunch_cpp:.cpp=.obj)

crunch_exe := ..\bin\crunch.exe

$(crunch_obj): $(crunch_cpp)
	cl /nologo /MT /TP /O2 /c /DWIN32 /DNDEBUG /D_CONSOLE /I..\inc /I..\crnlib $^

$(crunch_exe): $(crunch_obj)
	link /nologo /SUBSYSTEM:CONSOLE Kernel32.lib libvcruntime.lib libcmt.lib ../crnlib/crnlib.lib $^ /out:$(crunch_exe)

.PHONY: distclean
distclean:
	del $(crunch_obj)

.PHONY: clean
clean:
	del $(crunch_obj) $(crunch_exe)

.PHONY: all
all: $(crunch_exe)
