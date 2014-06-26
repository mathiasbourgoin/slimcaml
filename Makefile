all:build

build: 
	ocp-build -init || ocp-build init

clean: 
	ocp-build -init || ocp-build init
	ocp-build -clean || ocp-build clean


install: 
	ocp-build -init || ocp-build init
	ocp-build -install || ocp-build install


uninstall: 
	ocp-build -init || ocp-build init
	ocp-build -uninstall || ocp-build uninstall

