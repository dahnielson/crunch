.PHONY: distclean
distclean:
	cd crnlib && $(MAKE) $(MAKECMDGOALS) && cd ..
	cd decompress && $(MAKE) $(MAKECMDGOALS) && cd ..
	cd compress && $(MAKE) $(MAKECMDGOALS) && cd ..
	cd crunch && $(MAKE) $(MAKECMDGOALS) && cd ..

.PHONY: clean
clean:
	cd crnlib && $(MAKE) $(MAKECMDGOALS) && cd ..
	cd decompress && $(MAKE) $(MAKECMDGOALS) && cd ..
	cd compress && $(MAKE) $(MAKECMDGOALS) && cd ..
	cd crunch && $(MAKE) $(MAKECMDGOALS) && cd ..

.PHONY: all
all:
	cd crnlib && $(MAKE) $(MAKECMDGOALS) && cd ..
	cd decompress && $(MAKE) $(MAKECMDGOALS) && cd ..
	cd compress && $(MAKE) $(MAKECMDGOALS) && cd ..
	cd crunch && $(MAKE) $(MAKECMDGOALS) && cd ..
