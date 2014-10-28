(*  cA.mli
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

type cell = bool * char
type 'a matrix = 'a array array

(* {2 Input parameters} *)
module type PARAMS =
 sig
  val n_rows : int
  (* Number of rows of the universe. *)
  val n_cols : int
  (* Number of columns of the universe. *)
  val states : int
  (* Number of states for each cell type. *)
  val birth_rules : int list
  (* Birth rules for each cell type. *)
  val death_rules : int list
  (* Death rules for each cell type. *)
 end

(* {2 Universe functions} *)
module type S =
 sig
  val n_rows : int
  (* Number of rows. *)
  val n_cols : int
  (* Number of columns. *)
  val states : int
  (* Number of states for living cells. *)
  val import : ?filename:string -> unit -> cell matrix
  (* Import a predefined universe (for benchmarking). *)
  val export : ?filename:string -> cell matrix -> unit
  (* Export the given universe (for benchmarking). *)
  val create : seed:int -> cell matrix
  (* Inoculation of the universe. *)
  val evolve : cell matrix -> cell matrix
  (* Computes the next generation of the universe. *)
 end

module Make : functor (P : PARAMS) -> S
(* Functor to build a multi-state cellular automaton. *)
