(*  action.ml
 *  Copyright (C) 2014 Edouard Evangelisti
 * 
 *  This file is part of Ocelot (OCaml Cellular Automata).
 *    
 *  OCelot is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 * 
 *  Ocelot is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Ocelot.  If not, see <http://www.gnu.org/licenses/>
 *)


open Scanf
open Printf

let counter = ref 0

let create_params birth death =
  let module P =
   struct
    let n_rows = !Draw.nrows
    let n_cols = !Draw.ncols
    let states = !Draw.cell_states
    let birth_rules = birth
    let death_rules = death
   end
  in (module P : CA.PARAMS)

let list_of_num_string s =
  let rec loop res = function
    | 0 -> res
    | i -> let j = i - 1 in
      loop (Char.code s.[j] - 48 :: res) j
  in loop [] (String.length s) 

let neg_list_of_num_string s =
  let rec loop res = function
    | 0 -> res
    | i -> let j = i - 1 in
      let num = Char.code s.[j] - 48 in
      loop (List.filter (fun i -> i <> num) res) j
  in loop [0; 1; 2; 3; 4; 5; 6; 7; 8] (String.length s)

let parse_rule str =
  sscanf str "%[0-9]/%[0-9]" (fun s b -> 
    create_params (list_of_num_string b) (neg_list_of_num_string s)
  )


(* Rules here: http://psoup.math.wisc.edu/mcell/rullex_life.html *)
module Params =
 struct
  let life ()          = parse_rule "23/3"
  let life34 ()        = parse_rule "34/34"
  let life2x2 ()       = parse_rule "125/36"
  let gnarl ()         = parse_rule "1/1"
  let flakes ()        = parse_rule "012345678/3"
  let assimilation ()  = parse_rule "4567/345"
  let amoeba ()        = parse_rule "1358/357"
  let diamoeba ()      = parse_rule "5678/35678"
  let coral ()         = parse_rule "45678/3"
  let maze ()          = parse_rule "12345/3"
  let mice ()          = parse_rule "12345/37"
  let move ()          = parse_rule "245/368"
  let walled_cities () = parse_rule "2345/45678"
  let stains ()        = parse_rule "235678/3678"
  let coagulations ()  = parse_rule "235678/378"
  let mazectric ()     = parse_rule "1234/3"
  let serviettes ()    = parse_rule "/234"
  let day_and_night () = parse_rule "34678/3678"
 end

type ca =
  | AMOEBA 
  | ASSIMILATION
  | COAGULATIONS
  | CORAL 
  | DAY_AND_NIGHT
  | DIAMOEBA 
  | FLAKES
  | GNARL
  | LIFE
  | LIFE34
  | LIFE2X2
  | MAZE
  | MAZECTRIC
  | MICE
  | MOVE
  | SERVIETTES
  | STAINS
  | WALLED_CITIES

let ca_list = ["LIFE", LIFE; "LIFE34", LIFE34; "2X2", LIFE2X2;
  "GNARL", GNARL; "FLAKES", FLAKES; 
  "ASSIMILATION", ASSIMILATION; "AMOEBA", AMOEBA; "DIAMOEBA", DIAMOEBA;
  "CORAL", CORAL; "MAZE", MAZE; "MICE", MICE; "MOVE", MOVE; "WALLED CITIES",
  WALLED_CITIES; "STAINS", STAINS; "COAGULATIONS", COAGULATIONS; "MAZECTRIC",
  MAZECTRIC; "SERVIETTES", SERVIETTES; "DAY AND NIGHT", DAY_AND_NIGHT]

let ca_of_string ca_name = List.assoc ca_name ca_list

let get_module typ = 
  let par = Params.(match typ with
    | LIFE          -> life ()
    | LIFE34        -> life34 ()
    | LIFE2X2       -> life2x2 ()
    | GNARL         -> gnarl ()
    | FLAKES        -> flakes ()
    | ASSIMILATION  -> assimilation ()
    | AMOEBA        -> amoeba ()
    | DIAMOEBA      -> diamoeba ()
    | CORAL         -> coral ()
    | MAZE          -> maze ()
    | MICE          -> mice ()
    | MOVE          -> move ()
    | WALLED_CITIES -> walled_cities ()
    | STAINS        -> stains ()
    | COAGULATIONS  -> coagulations ()
    | MAZECTRIC     -> mazectric ()
    | SERVIETTES    -> serviettes ()
    | DAY_AND_NIGHT -> day_and_night ()) in
  let module P = (val par : CA.PARAMS) in
  (module CA.Make(P) : CA.S)

let curr_param = ref None
let is_running = ref true
let curr_timeout = ref None

let get_time ca_name =
  let open Unix in
  let tm = localtime (time ()) in
  sprintf "./%s-%02d-%02d-%02d-%02d:%02d:%02d" ca_name
    tm.tm_mday (tm.tm_mon + 1) (tm.tm_year mod 100) 
    tm.tm_hour tm.tm_min tm.tm_sec

let play ?(folder = ".") ca_name () =
  if !is_running then Gaux.may (fun (mdl, old) -> 
    let module CA = (val mdl : CA.S) in
    let x = Unix.gettimeofday () in
    let uni = CA.evolve old in
    let y = Unix.gettimeofday () in
    let save_as = if GUI.ca_save_as_png#active then (
      incr counter; 
      Some (sprintf "%s/IMG_%06d.png" folder !counter)
    ) else None in
    Draw.populate ?save_as uni;
    let z = Unix.gettimeofday () in
    ksprintf GUI.display#set_title "%s (Calc %.1f ms, Disp %.1f ms)"
      ca_name (1000. *. (y -. x)) (1000. *. (z -. y));
    (*printf "%.1f\t%.1f\n" (1000. *. (y -. x)) (1000. *. (z -. y));*)
    curr_param := Some (mdl, uni)
  ) !curr_param;
  true

let evolve () =
  Gaux.may Glib.Timeout.remove !curr_timeout;
  counter := 0;
  let ca_name = match GEdit.text_combo_get_active GUI.ca_choice with 
    | None -> "UNKNOWN" (* Should never happen. *) 
    | Some ca_name -> ca_name in
  let folder = if GUI.ca_save_as_png#active then (
    let dir = get_time ca_name in
    Unix.mkdir dir 0o755;
    Some dir
  ) else None in
   curr_timeout := Some (Glib.Timeout.add 
    ~ms:GUI.ca_speed#value_as_int
    ~callback:(play ?folder ca_name))

let initialize () =
  Gaux.may (fun ca_name ->
    let mdl = get_module (ca_of_string ca_name) in
    let module M = (val mdl : CA.S) in
    let ini = M.create (truncate GUI.ca_seed#value) in
    curr_param := Some (mdl, ini);
    Draw.init ();
    Draw.populate ini;
    GUI.main_window#show ();
    ignore (evolve ())
  ) (GEdit.text_combo_get_active GUI.ca_choice)

let run () = is_running := true
let pause () = is_running := false
