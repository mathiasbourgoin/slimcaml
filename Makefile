all:build

build:slimcaml.cma tool.cma

install: slimcaml.cma
	ocamlfind install slimcaml *.cm* META

uninstall :
	ocamlfind remove slimcaml

slimcaml.cma:slimcaml.cmo
	ocamlfind ocamlc -a $< -o $@

slimcaml.cmo:slimcaml.ml
	 ocamlfind ocamlc -I +camlp4 -pp camlp4of dynlink.cma camlp4lib.cma  $< $@


test: slimcaml.cma test.ml
	@echo "ORIGINAL"
	@echo "--------"
	@echo
	@cat test.ml
	@echo
	@echo
	@echo "--------------------------------------------------------------------------------"
	@echo
	@echo "MODIFIED"
	@echo "--------"
	@echo
	@camlp4 -I +camlp4 -parser o -parser op -printer o slimcaml.cma test.ml


clean:
	rm -rf *.cmo *,cmx *.out *~ *.cmi camlprog.exe *.cma *.asm





gen_gram.cma:gen_gram.cmo
	ocamlfind ocamlc -a $< -o $@

gen_gram.cmo:gen_gram.ml
	 ocamlfind ocamlc -I +camlp4 -pp camlp4of dynlink.cma camlp4lib.cma  $< 


test2: gen_gram.cma rules
	@echo "ORIGINAL"
	@echo "--------"
	@echo
	@cat rules
	@echo
	@echo
	@echo "--------------------------------------------------------------------------------"
	@echo
	@echo "MODIFIED"
	@echo "--------"
	@echo
	@camlp4 -I +camlp4 -parser o -parser op -printer o gen_gram.cma -impl rules
