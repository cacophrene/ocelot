(*  cA.ml
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

module type PARAMS =
 sig
  val n_rows : int
  val n_cols : int
  val states : int
  val birth_rules : int list
  val death_rules : int list
 end

module type S =
 sig
  val n_rows : int
  val n_cols : int
  val states : int
  val import : ?filename:string -> unit -> cell matrix
  val export : ?filename:string -> cell matrix -> unit
  val create : seed:int -> cell matrix
  val evolve : cell matrix -> cell matrix
 end

module Make (P : PARAMS) : S =
 struct
  let n_rows = P.n_rows
  let n_cols = P.n_cols
  let states = min P.states 255 (* States are stored as characters. *)

  let export ?(filename = "matrix.ocelot") mat =
    let och = open_out_bin filename in
    output_value och mat;
    close_out och

  let import ?(filename = "matrix.ocelot") () =
    let ich = open_in_bin filename in
    let mat : cell matrix = input_value ich in
    close_in ich;
    mat

  let f000 = (false, '\000')
  let t000 = (true , '\000')
  let t001 = (true , '\001')

  let create ~seed =
    let mat = Array.make_matrix n_rows n_cols f000 in
    Random.self_init ();
    for i = 1 to seed do
      Random.(mat.(int n_rows).(int n_cols) <- t001)
    done;
    mat

  let next_col c = if c + 1 = n_cols then 0 else c + 1
  let next_row r = if r + 1 = n_rows then 0 else r + 1
  let prev_col c = if c - 1 < 0 then n_cols - 1 else c - 1
  let prev_row r = if r - 1 < 0 then n_rows - 1 else r - 1

  let norm (_, s) = if s = '\000' then 0 else 1 

  (* Moore neighborhood is composed of 8 adjacent cells. *)
  let moore_neighborhood mat r c =
    let pr = mat.(prev_row r) and nr = mat.(next_row r)
    and pc = prev_col c and nc = next_col c and mr = mat.(r) in 
    norm pr.(pc) + norm pr.(c) + norm pr.(nc) +
    norm mr.(pc) +               norm mr.(nc) +
    norm nr.(pc) + norm nr.(c) + norm nr.(nc)

  let next_state mat r c (modi, cur) =
    let mem = List.mem (moore_neighborhood mat r c) in
    match cur with
      | '\000' when mem P.birth_rules -> t001
      | '\000'                        -> f000
      |    _   when mem P.death_rules -> t000
      |    _                          -> let n = Char.code cur in
        if n = states then (false, cur) else (true, Char.(chr (1 + n)))

  let evolve mat = Array.(mapi (fun r -> mapi (next_state mat r)) mat)
 end
