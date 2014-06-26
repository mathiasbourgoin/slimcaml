PP=$(wildcard pp*.ml)
PPOBJ=$(PP:.ml=.cma)
TESTS=test1.ml test2.ml

all:build

build: 
	ocp-build -init || ocp-build init

clean: 
	ocp-build -init || ocp-build init
	ocp-build -clean || ocp-build clean
	rm -rf *~ *.cm* pp_disable*.ml a.out


install: 
	ocp-build -init || ocp-build init
	ocp-build -install || ocp-build install


uninstall: 
	ocp-build -init || ocp-build init
	ocp-build -uninstall || ocp-build uninstall

buildpp: build
	_obuild/slimcaml/slimcaml.asm

test: buildpp $(PPOBJ) $(TESTSOBJ) 
	for pp in $(PPOBJ) ; do \
	for test in $(TESTS); do \
	echo "ocamlc -pp \"camlp4of $$pp\" $$test -c"; \
	ocamlc -pp "camlp4of $$pp" $$test -c; \
	done \
	done


%.cma:%.cmo
	ocamlfind ocamlc -a  $< -o $@

%.cmo:%.ml
	 ocamlfind ocamlc -I +camlp4 -pp camlp4of dynlink.cma camlp4lib.cma $<

