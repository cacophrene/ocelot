(*  gUI.ml
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

module Default = struct
  let png_save = false
  let seed = 2000.0
  let speed = 50.0
end

let app_name = "Ocelot 1.0"

let main_window =
  GMain.init ();
  let wnd = GWindow.window
    ~title:app_name
    ~resizable:false
    ~position:`CENTER () in
  wnd#connect#destroy GMain.quit;
  wnd

let spacing = 5
let border_width = 5

let vbox = GPack.vbox
  ~spacing
  ~border_width
  ~packing:main_window#add ()

let table = GPack.table
  ~border_width
  ~row_spacings:spacing
  ~col_spacings:spacing
  ~homogeneous:true
  ~packing:(vbox#pack ~expand:false) ()

let strings = [
  "LIFE";
  "LIFE34";
  "2X2";
  "GNARL";
  "FLAKES";
  "ASSIMILATION";
  "AMOEBA"; 
  "DIAMOEBA";
  "CORAL";
  "MAZE";
  "MICE";
  "MOVE";
  "WALLED CITIES";
  "STAINS";
  "COAGULATIONS";
  "MAZECTRIC";
  "SERVIETTES";
  "DAY AND NIGHT"
]

let ca_choice = GEdit.combo_box_text
  ~strings
  ~active:0
  ~packing:(table#attach ~left:0 ~top:0 ~expand:`X) ()

let set_active_ca x =
  let rec loop n = function
    | [] -> () (* Unknown cellular automaton. *)
    | y :: rem -> if x = y then (fst ca_choice)#set_active n
      else loop (n + 1) rem
  in loop 0 strings

let adjustment = GData.adjustment
  ~lower:1.0 
  ~upper:20000.
  ~page_size:0.
  ~value:Default.seed ()

let ca_seed = GEdit.spin_button
  ~adjustment
  ~numeric:true
  ~update_policy:`IF_VALID
  ~value:Default.seed
  ~packing:(table#attach ~left:1 ~top:0 ~expand:`X) ()

let adjustment = GData.adjustment
  ~lower:5.0 
  ~upper:2000.
  ~page_size:0.
  ~value:Default.speed ()

let ca_speed = GEdit.spin_button
  ~adjustment
  ~numeric:true
  ~update_policy:`IF_VALID
  ~value:Default.speed
  ~packing:(table#attach ~left:0 ~top:1 ~expand:`X) ()

let ca_save_as_png = GButton.check_button
  ~active:Default.png_save
  ~label:"Save as PNG files"
  ~packing:(table#attach ~left:1 ~top:1 ~expand:`X) ()

let initialize = GButton.button
  ~label:"START THE AUTOMATON"
  ~packing:(table#attach ~left:0 ~top:2 ~expand:`X) ()

let pause = GButton.toggle_button
  ~label:"PAUSE"
  ~packing:(table#attach ~left:1 ~top:2 ~expand:`X) ()

let display = 
  let wnd = GWindow.window
    ~width:900 ~height:700
    ~resizable:false
    ~position:`NONE () in
  (* This window should not be removed. *)
  wnd#event#connect#delete (fun _ -> true);
  main_window#connect#destroy wnd#destroy;
  wnd

let scroll = GBin.scrolled_window
  ~hpolicy:`NEVER 
  ~vpolicy:`NEVER
  ~border_width
  ~packing:display#add ()

let toolbox = ref None

let init f =
  let fg = GMisc.drawing_area ~packing:scroll#add_with_viewport () in
  fg#event#add [`EXPOSURE];
  fg#event#connect#expose f;
  ignore (fg#misc#connect#size_allocate (fun {Gtk.width; height} ->
    let bg = GDraw.pixmap ~width ~height () in
    let t  = Cairo_lablgtk.create bg#pixmap in
    let dt = {Custom_types.fg; bg; width; height; t} in 
    toolbox := Some dt
  ))
