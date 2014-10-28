(*  gUI.mli
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

val app_name : string
(* Application name. *)

val main_window : GWindow.window
(* Main window. *)

val display : GWindow.window
(* Tool window to display the cellular automaton. *)

val ca_choice : GEdit.combo_box GEdit.text_combo
(* Cellular automata list. *)

val ca_seed : GEdit.spin_button
(* Value used for the seed. *)

val ca_speed : GEdit.spin_button
(* Duration, in milliseconds, between two generations. Default is 80 ms. *)

val ca_save_as_png : GButton.toggle_button
(* Indicates whether the successive states are saved as PNG files. *)

val initialize : GButton.button
(* Run the given cellular automaton (see [ca_choice] above). *)

val pause : GButton.toggle_button
(* Suspend the execution. *)

val set_active_ca : string -> unit
(* Defines the current cellular automaton. *) 

val toolbox : Custom_types.drawing_toolbox option ref
(* Toolbox which is used for drawing purposes. *)

val init : (GdkEvent.Expose.t -> bool) -> unit
(* Update the toolbox above and define the expose function. *)
