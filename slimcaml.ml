open Camlp4.PreCast
open Syntax
open Ast



let rec string_of_ident i = 
  let aux = function
    | <:ident< $lid:s$ >> -> s
    | <:ident< $uid:s$ >> -> s
    | <:ident< $i1$.$i2$ >> -> "" ^ (string_of_ident i1) ^ "." ^ (string_of_ident i2)
    | <:ident< $i1$($i2$) >> -> "" ^ (string_of_ident i1) ^ " " ^ (string_of_ident i2)
    | _ -> assert false
  in aux i

type name 'e = { expr : 'e; tvar : string; loc : loc }

let rec tvar_of_ident =
  function
    | <:ident< $lid:x$ >> | <:ident< $uid:x$ >> -> x
    | <:ident< $uid:x$.$xs$ >> -> x ^ "__" ^ tvar_of_ident xs
    | _ -> failwith "internal error in the Grammar extension" 

let mk_name _loc i =
  {expr = <:expr< $id:i$ >>; tvar = tvar_of_ident i; loc = _loc}

let expr_of_string = Syntax.Gram.parse_string Syntax.expr_eoi

let delete_rules = ref []

let replace_rules = ref []

let globals = ref []

let gen (_loc, e,l,e2) =
let glob = string_of_ident e in
let rule =     (List.fold_left (fun a b -> (
      if a <> "" && b <> "" then
        a^" ; "^ b
      else 
        a ^ b)) "" l)in
  let del = Printf.sprintf "DELETE_RULE Gram %s : %s  END" glob rule
 in
delete_rules := del :: !delete_rules;
if not (List.mem glob !globals) then
globals := glob :: !globals;
let new_rule =
Printf.sprintf "%s : \n[[ %s -> print_endline (%s^\" : not available with this subsyntax of OCaml\"); exit 0"
glob rule (string_of_ident e2) in
replace_rules := new_rule :: !replace_rules;
<:expr<>>


    EXTEND Gram
    GLOBAL: str_item expr;


str_item:
[[
"BEGIN"; l = LIST0 expr; "END" -> 
print_endline "open Camlp4.PreCast
open Syntax
open Ast\n\n";

List.iter print_endline !delete_rules;

Printf.printf "EXTEND Gram\nGLOBAL:%s;" (List.fold_left (fun a b -> a ^" "^b) "" !globals);

List.iter print_endline !replace_rules;

print_endline "\n\nEND";
<:str_item< >>
]];
  
expr: AFTER "top"
    [
	
      [e=ident; ":";  l = LIST0 elems; "->"; e2=ident ->  
  gen (_loc,e,l,e2)
]
];

elems:
  [[
    u = ident -> (string_of_ident u)
| s=STRING->  ("\""^s^ "\"")
| ";"  -> ""

]];

END

