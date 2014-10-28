(*  draw.mli
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

(* {2 Drawing parameters} *)

val nrows : int ref
(* Number of rows of the universe. Default value is 130. *)

val ncols : int ref
(* Number of columns of the universe. Default value is 170. *)

val border_width : int ref
(* Empty space used as border for the universe. Default value is 5 pixels. *)

val cell_states : int ref
(* Number of different states for cells. Default value is 100. *)

type color_type = 
  | BACKGROUND       (* Background color (default: "#ffffff").              *)
  | GRADIENT_1       (* Initial color of the gradient (default: "#cbff26"). *)
  | GRADIENT_2       (* Mid color of the gradient (default: "#ff0000").     *)
  | GRADIENT_3       (* Last color of the gradient (default: "#010a5c").    *)
  | GRADIENT of char (* Internal use only.                                  *)
(* The different types of colors. *)

val define_color : color_type -> string -> unit
(* [define_color typ "#abcdef"] defines ["#abcdef"] as [typ] color. *)

val synchronize : unit -> unit

val expose : GdkEvent.Expose.t -> bool

val init : unit -> unit
(* Draw background and sets antialiasing and so on. *)

val populate : ?save_as:string -> CA.cell CA.matrix -> unit
(* Draw the current state of the universe and, if needed, saves it. *)
