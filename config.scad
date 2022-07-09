include <../_utils_v2/NopSCADlib/core.scad>
include <../_utils_v2/NopSCADlib/vitamins/stepper_motors.scad>
include <../_utils_v2/NopSCADlib/vitamins/extrusion_brackets.scad>

use <../_utils_v2/Getriebe.scad>
use <../_utils_v2/_round/polyround.scad>
use <../_utils_v2/fillet.scad>
use <../_utils_v2/m3-m8.scad>

slot=40;

//                          corner  body    boss    boss          shaft
//                          side, length, radius, radius, radius, depth, shaft, length,      holes, cap heights
NEMA17ali  = ["NEMA17ali",   42.3, 38.3,     53.6/2, 25,     11,     2,     5,     24,          31,    [11.5,  9]];

eingriffswinkel=10;
gear_big_steigungswinkel=10;
gear_big_modul=1;
gear_big_d=70;
gear_small_d=3;
gear_big_h=8-2;
gear_small_h=30;
small_gear_r = gear_small_d/(2*sin(gear_big_steigungswinkel));

filament_fix_screw=18+2;	

// inner diameter, outer diameter, height, cap diameter,cap thickness
body_dim = [33-13,60-18,40,gear_big_d,3];
big_gear_tr=[[0,0,gear_big_d/2],[0,90,-90]];
big_gear_mirror=false;
small_gear_mirror=true;
small_gear_block_mirror=false;
small_gear_angle=180;//75+60;
small_gear_tr=[[0,0,-small_gear_r],[0,0,90]];
small_gear_fix_tr=[[gear_small_h/2+4,0,-small_gear_r],[0,0,90]];
motor_tr=[vec_add(small_gear_tr[0],[-40,0,0]),[0,90,0]];
small_gear_pad_tr=[vec_add(motor_tr[0],[4,0,0]),motor_tr[1]];

small_gear_pad=[small_gear_r*2,abs(motor_tr[0].z-small_gear_tr[0].z)
	+abs(motor_tr[0].x-small_gear_tr[0].x)-16.8];
// inner diameter, height, cap diameter,cap thickness
spool_axis=[body_dim[0]-1,body_dim[2],body_dim[0]+30,14];
spool_axis_tr=[[0,0,gear_big_d/2],[90,0,0]];

stand_zadd=4;
stand_slot_th=8;
//width,height,thickness,spool fix diameter and thickness
stand = [50,gear_big_d/2,6,spool_axis[2],6];
stand_tr=[[0,spool_axis[3],0],[90,0,180]];

// outer,height,inner
bearings = [
 [10,4,5] //mr105zz
,[11,5,5] //685zz
,[16,5,5] //625zz
,[10,4,3] //623zz
,[9,3,5] //mr95
,[16,5,8] //688zz
,[22,7,8] //608zz
];
small_gear_bearing=bearings[1];
//thickness,bottom
small_gear_bearing_p=3;
nobearing=false;

slot_length=145;
slot_tr=[slot_length/2-30,-slot+20,-stand_slot_th-stand_zadd-10];
volcano_tr=[slot_length-55,-12,-3.5];
brdiff=14.2;
bradd=1+0.3;
bracket_tr_y=volcano_tr.y+26;
bracket_tr_z=volcano_tr.z-8.5;
bracket_outer=[4,3];
bracket_tr=[
	  [[volcano_tr.x-brdiff+bradd,bracket_tr_y,bracket_tr_z],[0,0,-90]]
	 ,[[volcano_tr.x+brdiff+bradd,bracket_tr_y,bracket_tr_z],[0,0,-90]]
];


power_to_slot_out=7.5+3;
power_to_slot_left_dim=[24/2,53+power_to_slot_out,20+40];
power_to_slot_right_fix=14;
power_to_slot_right_x=10;
power_to_slot_right_dim=[24/2+power_to_slot_right_x,53+power_to_slot_out,50+power_to_slot_right_fix];
slot_left_tr=[[slot_tr.x-slot_length/2,slot_tr.y-power_to_slot_out/2+14,slot_tr.z-10],[0,0,0]];
slot_right_tr=[[slot_tr.x+slot_length/2,slot_tr.y-power_to_slot_out/2+14,slot_tr.z-10],[0,0,180]];
power_to_slot_up=[2,4];
power_to_slot_cut=[4,7];

endstop_thickness=3;
endstop_top=34+14+4;
endstop_dim=[31,26,4];
endstop_tr=[-12-60,-8-22-24,-4];

endstop_screw_d=6;
endstop_screw_out=2;
endstop_screw_tr=[10,22];

endstop_tube=14;

endstop_up=8;
endstop_back=40-20;

motor_out=2;

//thickness bottom
filament_case=[2,2+1.6+1.6];

spool_bearing=bearings[6];
// bottom part(bottom,top),bottom height; top part height,thickness,diameter
//,fix height diameter
spool_dim=[90,40,10+5,2,3,40,30,28];

oled_width=27.3;
oled_height=27.75;
screen_width=23;
screen_height=13.5;
function stand_tr(x,y)=[(oled_width/2-2.1-2.5/2)*x,(oled_height/2-2.1)*y-0.3,0];

function vec_add (v1,v2)=[v1.x+v2.x,v1.y+v2.y,v1.z+v2.z];
module translate_rotate(tr) 
{
	for (i=[0:$children-1]) 
		translate (tr[0])
		rotate(tr[1])
			children(i);
}

module rotate_small_gear()
{
	for (i=[0:$children-1]) 
		translate([0,0,gear_big_d/2])
		rotate([0,small_gear_angle,0])
		translate([0,0,-gear_big_d/2])
		mirror([small_gear_block_mirror?1:0,0,0])
			children(i);
}

