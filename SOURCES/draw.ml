(*  draw.ml
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
open Custom_types

let nrows = ref 130
let ncols = ref 170
let cell_states = ref 100
let border_width = ref 5
let gradient_colors = ref [||]



module Color = struct
  let ratio x = float x /. 255. (* required by Cairo. *)
  let parse s = sscanf s "#%2x%2x%2x" (fun r g b -> ratio r, ratio g, ratio b)
  let bg = ref (parse "#ffffff")
  let g1 = ref (parse "#cbff26")
  let g2 = ref (parse "#ff0000")
  let g3 = ref (parse "#010a5c")
end



module Gradient = struct
  let sub (r1, g1, b1) (r2, g2, b2) n =
    let dr = (r2 -. r1) /. float n 
    and dg = (g2 -. g1) /. float n
    and db = (b2 -. b1) /. float n in
    let gr = Array.make n (r1, g1, b1) in
    for i = 1 to n - 1 do
      let r, g, b = gr.(i - 1) in
      gr.(i) <- (r +. dr, g +. dg, b +. db)
    done;
    gr
  let make () =
    let half = !cell_states lsr 1 in
    Color.(Array.append (sub !g1 !g2 half) (sub !g2 !g3 half))
end



(* Creates gradient only once. *)
let rec get_state_color = ref (fun s ->
  gradient_colors := Gradient.make ();
  get_state_color := Array.get !gradient_colors;
  !gradient_colors.(s)
)

type color_type = 
  | BACKGROUND
  | GRADIENT_1
  | GRADIENT_2
  | GRADIENT_3
  | GRADIENT of char
    
let define_color typ str =
  let open Color in
  let color = match typ with
    | BACKGROUND -> bg
    | GRADIENT_1 -> g1
    | GRADIENT_2 -> g2
    | GRADIENT_3 -> g3
    | _          -> invalid_arg "Draw.define_color"
  in color := parse str

let select_color t typ =
  let red, green, blue = match typ with
    | BACKGROUND -> !Color.bg
    | GRADIENT_1 -> !Color.g1
    | GRADIENT_2 -> !Color.g2
    | GRADIENT_3 -> !Color.g3
    | GRADIENT n -> !get_state_color (Char.code n - 1)
  in Cairo.set_source_rgb t ~red ~green ~blue

let retrieve fun_name =
  match !GUI.toolbox with
  | None -> invalid_arg fun_name
  | Some tbx -> tbx

let synchronize () =
  let {width; height; fg; _} = retrieve "synchronize" in
  fg#misc#draw (Some (Gdk.Rectangle.create ~x:0 ~y:0 ~width ~height))

let expose ev =
  let d = retrieve "expose" in
  let open Gdk.Rectangle in
  let r = GdkEvent.Expose.area ev in
  let x = x r and y = y r and width = width r and height = height r in
  let drawing = new GDraw.drawable d.fg#misc#window in
  drawing#put_pixmap ~x ~y ~xsrc:x ~ysrc:y ~width ~height d.bg#pixmap;
  false



let fresh_background t width height =
  select_color t BACKGROUND;
  Cairo.rectangle t ~x:0. ~y:0. ~width ~height;
  Cairo.fill t;
  Cairo.stroke t

let init () =
  let open Cairo in
  let d = retrieve "Draw.init" in
  set_antialias d.t ANTIALIAS_NONE;
  stroke d.t;
  fresh_background d.t (float d.width) (float d.height);
  synchronize ()

let rows t ~xini ~yini ~sq_size nr nc =
  let open Cairo in
  for r = 0 to nr do
    let y = yini +. float (r * sq_size) in
    move_to t ~x:xini ~y;
    line_to t ~x:(xini +. float (nc * sq_size)) ~y;
    stroke t;
  done

let cols t ~xini ~yini ~sq_size nr nc =
  let open Cairo in
  for c = 0 to nc do
    let x = xini +. float (c * sq_size) in
    move_to t ~x ~y:yini;
    line_to t ~x ~y:(yini +. float (nr * sq_size));
    stroke t;
  done

type graph_params = {
  xr: float; 
  yr: float; 
  sq_size: int; 
  radius: float;
  circles: Cairo.image_surface array;
}

let pi = acos (-1.0)
let angle1 = 0.0
let angle2 = 2.0 *. pi

let draw_circles r =
  let open Cairo in
  let d = truncate r lsl 1 + 1 in
  let rec loop res = function
    | 0 -> Array.of_list res
    | i -> let j = i - 1 in
      let s = image_surface_create FORMAT_RGB24 ~width:d ~height:d in
      let t = create s in
      select_color t BACKGROUND;
      set_antialias t ANTIALIAS_SUBPIXEL;
      rectangle t ~x:0. ~y:0. ~width:(float d) ~height:(float d);
      fill t;
      select_color t (if j = 0 then BACKGROUND else (GRADIENT (Char.chr j)));
      arc t ~xc:r ~yc:r ~radius:r ~angle1 ~angle2;
      fill t;
      stroke t;
      loop (s :: res) j
  in loop [] (!cell_states + 1)


(* Memoized function. *)
let rec get_params = ref (fun () ->
  let d = retrieve "Draw.get_params" in 
  let w_unit = (d.width - !border_width lsl 1) / !ncols
  and h_unit = (d.height - !border_width lsl 1) / !nrows in
  let sq_size = min w_unit h_unit in
  let radius = float (sq_size lsr 1) in
  let xr = float (d.width - sq_size * !ncols) /. 2. +. radius
  and yr = float (d.height - sq_size * !nrows) /. 2. +. radius in
  let circles = draw_circles radius in
  let res = {xr; yr; sq_size; radius; circles} in
  get_params := (fun () -> res);
  res
)

let populate ?save_as mat =
  let d = retrieve "Draw.populate" in
  let {xr; yr; sq_size; radius; circles} = !get_params () in
  Array.iteri (fun r -> Array.iteri (fun c (modi, chr) ->
    if modi then begin
      let x = xr +. float (c * sq_size)
      and y = yr +. float (r * sq_size) in
      Cairo.set_source_surface d.t circles.(Char.code chr) x y;
      Cairo.paint d.t
    end
  )) mat;
  Cairo.stroke d.t;
  Gaux.may (Cairo_png.surface_write_to_file (Cairo.get_target d.t)) save_as;
  synchronize ()
