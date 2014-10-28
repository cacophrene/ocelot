(*  action.mli
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

val ca_of_string : string -> ca
(* Retrieve the constructor a cellular automaton from its string 
  * representation. *)

val initialize : unit -> unit

val run : unit -> unit
(* Starts the cellular automaton. *)

val pause : unit -> unit
(* No more evolution of the given cellular automaton. *)
