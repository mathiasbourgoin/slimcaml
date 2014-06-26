let array = ("array",[
("expr", "SELF; \"<-\"; expr LEVEL \"top\"", "Array");
("expr", "SELF; \".\"; \"(\"; SELF; \")\"", "Array");
])



let all = [
array;
]

let only = ref []

let delete_rules = ref []

let replace_rules = ref []

let globals = ref []

let gen l =
List.iter (fun (glob,rule,info) ->
  let del = Printf.sprintf "DELETE_RULE Gram %s : %s  END" glob rule
 in
delete_rules := del :: !delete_rules;
if not (List.mem glob !globals) then
globals := glob :: !globals;
let new_rule =
Printf.sprintf "%s : \n[[ %s -> Printf.eprintf \"%s : not available with this subsyntax of OCaml\n\" ; exit 42]];\n"
glob rule info in
replace_rules := new_rule :: !replace_rules)
l



let list_of_info info =
List.find (fun (i,l) -> info = i) all


let print_header oc =
output_string oc "open Camlp4.PreCast\nopen Syntax\nopen Ast\n\n"

let print_body oc =
List.iter (fun s -> output_string oc (s^"\n")) !delete_rules;
output_string oc  (Printf.sprintf "EXTEND Gram\nGLOBAL:%s;\n\n" (List.fold_left (fun a b -> a ^" "^b) "" !globals));
List.iter (fun s -> output_string oc (s^"\n")) !replace_rules

let print_end oc =
output_string oc "END\n";
close_out oc

let _ = 
let args = 
List.map (fun (info,l) -> 
(("-disable-"^(String.lowercase info)),
Arg.Unit (fun () -> only := (list_of_info info):: !only), ("disable "^(String.lowercase info))))
 all in

Arg.parse args (fun s -> ()) "";
match !only with
| [] -> 
List.iter (fun (i,l) -> gen l; 
let oc = open_out ("pp_disable_"^i^".ml") in
print_header oc;
print_body oc;
print_end oc;
) all
| _ -> (
let oc = open_out ("pp_disable_custom.ml") in
print_header oc;
print_body oc;
print_end oc)




