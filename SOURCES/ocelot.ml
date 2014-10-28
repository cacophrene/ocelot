(*  ocelot.ml
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

open Arg
open GUI

let args = align [
  ("-b", String Draw.(define_color BACKGROUND),
    " Background color of the universe.");
  ("-c", Set_int Draw.ncols,
    " Number of columns of the universe (default: 170).");
  ("-c1", String Draw.(define_color GRADIENT_1),
    " First color of the gradient used to draw multi-state cells.");
  ("-c2",String Draw.(define_color GRADIENT_2),
    " Second color of the gradient used to draw multi-state cells.");
  ("-c3", String Draw.(define_color GRADIENT_3),
    " Last color of the gradient used to draw multi-state cells.");
  ("-p", Bool ca_save_as_png#set_active,
    " Save frames as PNG images (default: false).");
  ("-r", Set_int Draw.nrows,
    " Number of rows of the universe (default: 120).");
  ("-s", Set_int Draw.cell_states,
    " Number of different states of cells.");
  ("-v", Float ca_speed#set_value,
    " Duration, in milliseconds, between two generations (default: 50 ms).");
  ("--backcolor", String Draw.(define_color BACKGROUND),
    " Background color of the universe.");
  ("--color1", String Draw.(define_color GRADIENT_1),
    " First color of the gradient used to draw multi-state cells.");
  ("--color2",String Draw.(define_color GRADIENT_2),
    " Second color of the gradient used to draw multi-state cells.");
  ("--color3", String Draw.(define_color GRADIENT_3),
    " Last color of the gradient used to draw multi-state cells.");
  ("--columns", Set_int Draw.ncols,
    " Number of columns of the universe (default: 170).");
  ("--png-files", Bool ca_save_as_png#set_active,
    " Save frames as PNG images (default: false).");
  ("--rows", Set_int Draw.nrows,
    " Number of rows of the universe (default: 120).");
  ("--seed", Float ca_seed#set_value,
    " Number of random activation of cells (defaut: 2000). ");
  ("--states", Set_int Draw.cell_states,
    " Number of different states of cells.");
  ("--speed", Float ca_speed#set_value,
    " Duration, in milliseconds, between two generations (default: 50 ms).");
]

let _ =
  Arg.parse args set_active_ca "Usage: cellauto [OPTIONS] [AUTOMATON]";
  Printexc.record_backtrace true;
  init Draw.expose;
  initialize#connect#clicked ~callback:Action.initialize; 
  pause#connect#toggled (fun () ->
    pause#set_label (
     match pause#active with
      | true  -> Action.pause (); "RESTART"
      | false -> Action.run (); "PAUSE"
    )
  );
  (* Without this, the call to Draw.init would trigger an exception. *)
  display#misc#realize ();
  Draw.init ();
  display#show ();
  main_window#show ();
  GMain.main ()
