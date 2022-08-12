cmd="";

include <../_utils_v2/NopSCADlib/core.scad>
include <../_utils_v2/NopSCADlib/vitamins/stepper_motors.scad>
include <../_utils_v2/NopSCADlib/vitamins/extrusion_brackets.scad>

use <../_utils_v2/Getriebe.scad>
use <../_utils_v2/_round/polyround.scad>
use <../_utils_v2/fillet.scad>
use <../_utils_v2/m3-m8.scad>

include <config.scad>
include <report.scad>
use <upet_planetary.scad>

gear_big_cut_offsd=2;

module cylinder_bevel(d,bevel,fn)
{
	rotate_extrude($fn=fn[1])
	translate ([d/2,0,0])
	difference()
	{
		square(size=bevel,center=false);
		translate ([bevel,bevel,0])
			circle (r=bevel,$fn=fn[0]);
	}
}

module proto_slot2020_cr(length)
{
	color ("#668866")
	translate ([0,0,0])
	scale ([1,1,length/100])
	translate ([0,0,-50])
		import ("proto/slot2020.stl");
}

module proto_slot4020_cr(length)
{
	color ("#668866")
	scale ([1,1,length/100])
	translate ([0,0,-50])
	rotate ([90,0,90])
		import ("proto/40x20x100VSlotExtrusion.stl");
	report_slot(h=length);
}

module proto_pet_volcano()
{
	translate ([31,44,3.12])
	rotate ([180,90,90])
		import ("proto/pet_volcano.stl");
	
	report ("Volcano heatblock");
	report ("Heater Cartridge 12V 40W 6*20mm");
	report ("100K NTC 3950 Thermistor");
	report ("M6x10 or M6x12 bolt");

	report_m3(screw=30);
	report_m3(screw=30);
	report_m3_slot_nut();
	report_m3_slot_nut();
	report_m3_washer();
	report_m3_washer();
	report_m4_washer();
	report_m4_washer();
	report_m5_washer();
	report_m5_washer();
}

module proto_slot()
{
	translate (slot_tr)
	translate (stand_tr[0])
	rotate ([0,90,0])
		proto_slot4020_cr(length=slot_length);
}

module proto()
{
	translate (volcano_tr)
		proto_pet_volcano();
	
	translate ([0,-motor_out,0])
	rotate_small_gear()
	translate_rotate (motor_tr)
		NEMA(NEMA17ali, shaft_angle = 0, jst_connector = false);
	report_nema17();
		
	proto_slot();
}

module gear_small()
{
	rotate_small_gear()
	translate ([0,-motor_out,0])
	difference()
	{
		union()
		{
			translate_rotate(small_gear_tr)
			translate ([-small_gear_r,0,0])
				translate ([0,small_gear_mirror?-4.4:0,0])
				mirror ([0,small_gear_mirror?1:0,0])
				schneckenradsatz_small(
					  modul=gear_big_modul
					, zahnzahl=gear_big_d
					, gangzahl=gear_small_d
					, breite=gear_big_h
					, laenge=gear_small_h
					, bohrung_schnecke=0
					, bohrung_rad=0
					, eingriffswinkel=eingriffswinkel
					, steigungswinkel=gear_big_steigungswinkel
					, optimiert=false
					, zusammen_gebaut=true
				);
			translate_rotate (small_gear_pad_tr)
				cylinder(d=small_gear_pad[0],h=small_gear_pad[1],$fn=40);
				
			translate_rotate (small_gear_pad_tr)
			{
				dd=nobearing?small_gear_bearing[0]:small_gear_bearing[2]-0.4;
				hadd=nobearing?dd/2:0;
				hh=(24+gear_small_h+small_gear_bearing[1]+1)-dd/2;
				cylinder(d=dd,h=hh+hadd,$fn=80);
				translate ([0,0,hh])
					sphere (d=dd,$fn=80);
			}
		}
		
		translate_rotate (small_gear_pad_tr)
		translate ([0,0,-0.01])
			cylinder(d=5+0.4,h=24+gear_small_h-6,$fn=40);
			
		translate_rotate (small_gear_pad_tr)
		rotate ([90,0,0])
		translate ([0,12,-7])
		{
			screw=6;
			m3_screw(h=screw,cap_out=10);
			translate ([0,0,screw-4.8])
			rotate ([0,0,180])
				m3_square_nut();
		}
	}
}
      
module cylinder_bevel_outer(d,bevel,fn)
{
	rotate_extrude($fn=fn[1])
	{
		square(size=[d/2-bevel,bevel],center=false);
		translate ([d/2-bevel,bevel,0])
		difference()
		{
			circle (r=bevel,$fn=fn[0]);
			translate ([-bevel,0,0])
				square(size=[bevel*2,bevel],center=false);
		}
	}
}

gear_cut=[gear_big_d-10,gear_big_h-4];
fil_rays=10;

module gear_big_fix(add=false,part="",report=false)
{
	screw=10;
	rays=3;
	angle=360/rays;
	
	topcut=part=="top"?4:0;
	
	cut_shape_h=body_dim[2]-body_dim[4];
	cut=[2.4,2.4,10];
	hh=14;
	cut_shape_r=2;
	cut_shape2_up=11;
	module cut_shape(offs=[0,0])
	{
		offset(r=cut_shape_r)
		offset(delta=-cut_shape_r)
		difference()
		{
			circle(d=body_dim[1]-cut[0]*2+offs[0]*2,$fn=100);
			circle(d=body_dim[0]+cut[1]*2-offs[1]*2,$fn=100);
			for (a=[0:rays-1])
				rotate ([0,0,-angle/2+a*angle+angle/2])
				translate ([-cut[2]/2,0])
					square ([cut[2],body_dim[1]]);
		}
	}
	module cut_shape2(offs=[0,0])
	{
		offset(r=cut_shape_r)
		offset(delta=-cut_shape_r)
		difference()
		{
			circle(d=body_dim[1]-cut[0]*2+offs[0]*2,$fn=100);
			circle(d=body_dim[0]+cut[1]*2-offs[1]*2,$fn=100);
		}
	}
	module lock_cut()
	{
		translate ([0,0,body_dim[2]-body_dim[4]-hh-topcut])
		rotate ([0,0,-angle/2-90])
		rotate_extrude(angle=angle,$fn=60)
			square ([body_dim[0],hh+topcut*2]);
	}
	
	if ((part=="middle")&& add)
	{
		intersection()
		{
			translate ([0,0,cut_shape_h-hh])
			linear_extrude (0.2)
				cut_shape(offs=cut);
			lock_cut();
		}
	}
	if ((part=="middle" || part=="top")&&(!add))
	{
		difference()
		{
			union()
			{
				linear_extrude (cut_shape_h+topcut)
					cut_shape();		
				translate ([0,0,cut_shape2_up])
				linear_extrude (cut_shape_h+topcut-cut_shape2_up*2)
					cut_shape2();		
			}
			lock_cut();
		}
	}
	if ((part=="bottom")&&(!add))
	{
		translate ([0,0,-gear_big_h/2-0.01])
		difference()
		{
			linear_extrude (cut_shape_h+topcut)
				cut_shape();
			
			lock_cut();
		}
	}
	
	for (a=[0:rays-1])
	{
		rr=4;
		rotate ([0,0,-angle/2+a*angle+angle/2])
		translate ([0,(body_dim[0]+body_dim[1])/4,0])
		{
			nutdiff=3;
			if (add)
			{
				protect=0.3;
				
				translate ([0,0,m3_nut_h()+0.2])
				translate ([0,0,screw-nutdiff])
				rotate([0,0,90])
					m3_nut(h=0.3);
				
				translate ([0,0,body_dim[2]])
				rotate ([180,0,180])
				translate ([0,0,-0.2])
				translate ([0,0,screw-nutdiff])
				rotate([0,0,90])
					m3_nut(h=protect);			
			}
			else
			{
				for (p=[
					[[0,0,0],[0,0,0]]
					,[[0,0,body_dim[2]],[180,0,180]]
					])
				translate (p[0])
				rotate (p[1])
				{
					if (report)
					{
						report_m3_hexnut();
						report_m3(screw=screw);
						report_m3_washer();
					}
					
					m3_screw(h=screw+2);
					m3_washer();
					
					translate ([0,0,screw-nutdiff])
					rotate([0,0,90])
					hull()
					{
						nut(G=m3_nut_G()+0.2,H=m3_nut_h()+0.2);
						translate ([20,0,0])
							nut(G=m3_nut_G()+0.2,H=m3_nut_h()+0.2);
					}
				}
			}
		}
	}
}

module gear_big(part="",report=false)
{
	rr=body_dim[1]/2-(body_dim[1]-body_dim[0])/4;
	washer_fix_hh=4;
	
	translate_rotate(big_gear_tr)
	union()
	{
		difference()
		{
			union()
			{
				if (part!="middle" && part!="top")
				translate ([gear_big_d/2,0,0])
				mirror([0,big_gear_mirror?1:0,0])
				{
					schneckenradsatz_big(
						modul=gear_big_modul
						, zahnzahl=gear_big_d
						, gangzahl=gear_small_d
						, breite=gear_big_h
						, laenge=gear_small_h
						, bohrung_schnecke=0
						, bohrung_rad=0
						, eingriffswinkel=eingriffswinkel
						, steigungswinkel=gear_big_steigungswinkel
						, optimiert=false
						, zusammen_gebaut=true
					);
				}
				
				cylinder (d=body_dim[1],h=body_dim[2]-body_dim[4]+0.01,$fn=100);
				
				//translate ([0,0,body_dim[2]-body_dim[4]])
					//cylinder (d=body_dim[3],h=body_dim[4],$fn=200);
				
				union()
				{
					hh=body_dim[4];
					dhh=body_dim[4]-hh;
					
					translate ([0,0,body_dim[2]-body_dim[4]])
						cylinder (d=body_dim[3],h=hh,$fn=200);
				
					translate ([0,0,body_dim[2]-body_dim[4]])
					{
						fn=200;
						cylinder (d=body_dim[1],h=hh+0.01,$fn=fn);
						translate ([0,0,hh])
							cylinder(d1=body_dim[1]+dhh*2,d2=body_dim[1],h=dhh,$fn=fn);
					}
				
					translate ([0,-rr,body_dim[2]-body_dim[4]])
					{
						fn=100;
						dd=m5_screw_diameter()+8;
						cylinder(d=dd+dhh*2,h=hh+0.01,$fn=fn);
						translate ([0,0,hh])
							cylinder(d1=dd+dhh*2,d2=dd,h=dhh,$fn=fn);
					}
				}
				
				
			}
			
			translate ([0,0,body_dim[2]+0.1])
			{
				angle=360/fil_rays;
				dd=4;
				for (a=[0:fil_rays-1]) let (ar=a*angle)
					rotate ([180,0,ar])
					translate ([body_dim[3]/2-dd/2-3,0,0])
						cylinder (d=dd,h=body_dim[4]+0.2,$fn=20);
			}
			
			translate ([0,0,-20])
				cylinder (d=body_dim[0],h=100,$fn=60);

			out=[5-1];
			translate ([0,0,-gear_big_h/2-0.01])
			{
				linear_extrude(gear_big_h+0.02)
				{
					r=3;
					offset(r=r)
					offset(delta=-r)
					difference()
					{
						circle (d=gear_big_d-out[0]*2,$fn=200);
						circle (d=body_dim[1],$fn=100);
						rays=[4,8];
						angle=360/rays[1];
						for (a=[0:rays[1]-1])
							rotate ([0,0,a*angle])
							translate ([0,-rays[0]/2,0])
								square ([gear_big_d,rays[0]]);
					}
				}
				//cylinder (d=body_dim[0],h=gear_big_h+0.01,$fn=60);
			}
			
			translate ([0,0,-gear_big_h/2-0.01])
			{
				r1=(gear_big_d-out[0]*2)/2;
				r2=body_dim[1]/2;
				h=gear_big_h-3;
				rotate_extrude($fn=200)
				polygon(polyRound([
					 [r2,0,0]
					,[r2,h,3]			
					,[r1,h,3]			
					,[r1,0,0]			
				],20));
			}
			
			translate ([0,-rr,body_dim[2]+body_dim[4]+0.01])
			rotate ([180,0,0])
			{
				if (report)
				{
					report_m5_bolt(screw=16);
					report_m5_nut();
					report_m5_washer();
					report ("DIN 6798A washer");
				}
				cylinder(d=m5_screw_diameter(),h=filament_fix_screw+6,$fn=40);
				translate ([0,0,filament_fix_screw-m5_nut_H()-2])
				{
					hull()
						for (i=[0,20])
							translate ([0,i,0])
							rotate ([0,0,90])
								nut(G=9.25,H=m5_nut_H());
					hull()
						for (i=[-rr,20])
							translate ([0,i,-washer_fix_hh+0.01])
								cylinder(d=m5_washer_diameter(),h=washer_fix_hh,$fn=60);
				}
			}
			gear_big_fix(part=part,report=report);
		}
		
		translate ([0,0,washer_fix_hh+0.2])
		translate ([0,-rr,body_dim[2]+body_dim[4]])
		rotate ([180,0,0])
		translate ([0,0,filament_fix_screw-m5_nut_H()-2])
			cylinder(d=m5_screw_diameter()+2,h=0.2,$fn=40);
		
		gear_big_fix(add=true,part=part);
	}
}

module gear_big_parted(op=0)
{
	if (op==0)
	{
		translate_rotate(big_gear_tr)
		translate ([gear_big_d/2,0,0])
		mirror([0,big_gear_mirror?1:0,0])
		translate ([-gear_big_d/2,0,-gear_big_h/2-0.01])
			cylinder (d=gear_big_d*2,h=gear_big_h+0.02,$fn=10);
	}
	if (op==1)
	{
		translate_rotate(big_gear_tr)
		translate ([gear_big_d/2,0,0])
		mirror([0,big_gear_mirror?1:0,0])
		translate ([-gear_big_d/2,0,body_dim[2]-body_dim[4]-0.01])
			cylinder (d=gear_big_d*2,h=body_dim[4]+0.02,$fn=10);
	}
}

module gear_big_bottom()
{
	intersection()
	{
		gear_big(part="bottom");
		gear_big_parted();
	}
}

module gear_big_top()
{
	intersection()
	{
		gear_big(part="top");
		gear_big_parted(op=1);
	}
}

module gear_big_middle()
{
	difference()
	{
		gear_big(part="middle",report=true);
		gear_big_parted(op=0);
		gear_big_parted(op=1);
	}
}

module motor_plate()
{
	down_fix=0.5;
	
	motor_fix_plate=8-1;
	add=motor_fix_plate-1.15;
	
	th=6;
	th_add=3;
	w=NEMA_width(NEMA17ali);
	r=4;
	points_motor=polyRound([
		 [-w/2,-w/2-motor_out,r]
		,[-w/2,w/2+add,0]
		,[w/2,w/2+add,0]
		,[w/2,-w/2-motor_out,r]
	],1);
	
	points_proj=polyRound([
		 [-w/2,w/2+add-motor_fix_plate,0]
		,[-w/2,w/2+add,0]
		,[w/2,w/2+add,0]
		,[w/2,w/2+add-motor_fix_plate,0]
	],1);
	
	dimf=[21
		,small_gear_bearing[1]+small_gear_bearing_p];
	addf=9.5;
	
	module bearing_fix()
	{
		hull()
		{
			rotate_small_gear()
			translate_rotate(small_gear_fix_tr)
			translate ([-motor_out,0,0])
			rotate([90,0,0])
				cylinder (d=dimf[0],h=dimf[1],$fn=60);
				
			rotate_small_gear()
			translate_rotate(small_gear_fix_tr)
			translate ([dimf[0]/2+addf,-dimf[1],-dimf[0]/2])
					cube ([motor_fix_plate,dimf[1],dimf[0]]);
		}
	}
	module motor_fix(fig=false)
	{
		rotate_small_gear()
		translate_rotate (motor_tr)
		{
			linear_extrude(th+th_add)
				polygon(points_motor);
			if (fig)
			{
				translate ([0,-motor_out,0])
					cylinder (d=w+2*2,h=th+th_add,$fn=200);
			}
		}
	}
	module plate()
	{
		hull()
		{
			rotate_small_gear()
			translate_rotate (motor_tr)
			linear_extrude(th+th_add)
				polygon(points_proj);			
				
			translate_rotate (stand_tr)
			translate ([0,gear_big_d/2,stand[4]])
				linear_extrude(motor_fix_plate)
					circle (d=stand[3]);
				
			rotate_small_gear()
			translate_rotate(small_gear_fix_tr)
			translate ([dimf[0]/2+addf,-dimf[1],-dimf[0]/2])
					cube ([motor_fix_plate,dimf[1],dimf[0]]);
		}
	}
	
	union()
	{
		difference()
		{
			union()
			{
				fillet(r=12,steps=48)
				{
					bearing_fix();
					plate();
				}
				fillet(r=12,steps=48)
				{
					motor_fix();
					plate();
				}
				motor_fix(fig=true);
			}
			
			rotate_small_gear()
			translate_rotate (motor_tr)
			rotate ([90,0,0])
			{
				xadd=4.5;
				xoffs=-xadd;
				r=[6,6];
				diff=[8-2+xadd,2+xadd];
				yy=[15+6,50-6];
				zz=-40;
				hull()
				{
					for (p1=[-diff[0],diff[0]])
						translate ([p1+xoffs,yy[0],zz])
							cylinder (d=r[0],h=30,$fn=40);
					for (p1=[-diff[1],diff[1]])
						translate ([p1+xoffs,yy[1],zz])
							cylinder (d=r[1],h=30,$fn=40);
				}
				/*
				sdim=[1.6,3,40];
				xout=6;
				translate ([diff[0]+xout,yy[0],zz])
				rotate ([0,0,10])
					cube (sdim);
				translate ([diff[1]+xout,yy[1],zz])
				rotate ([0,0,10])
					cube (sdim);
				*/
			}
			
			report ("685 bearing");
			report_m5_screw_only(screw=16);
			
			rotate_small_gear()
			translate_rotate(small_gear_fix_tr)
			translate ([-motor_out,0,0])
			rotate([90,0,0])
			translate([0,0,-0.01])
			{
				cylinder (d=small_gear_bearing[0]-2
					,h=small_gear_bearing[1]+small_gear_bearing_p+0.02,$fn=60);
			}
				
			rotate_small_gear()
			translate_rotate(small_gear_fix_tr)
			translate ([-motor_out,0,0])
			rotate([90,0,0])
			translate([0,0,-0.01])
			{
				dd=small_gear_bearing[0]+0.2;
				hh=small_gear_bearing[1]+0.4;
				cylinder (d=dd,h=hh,$fn=60);
				cut=1;
				cylinder (d2=dd,d1=dd+cut*2,h=cut,$fn=60);
				translate ([-small_gear_bearing[0]/2,0,0])
					cylinder (d=small_gear_bearing[0]*0.3,h=small_gear_bearing[1]+0.4,$fn=60);
			}
				
			translate ([0,0,down_fix])
			translate_rotate (stand_tr)
			translate ([0,gear_big_d/2,stand[4]-0.1])
				linear_extrude(motor_fix_plate+0.2)
					circle (d=spool_axis[0]);
					
			rotate_small_gear()
			translate_rotate (motor_tr)
			translate ([0,-motor_out,0])
			{
				translate ([0,0,-0.1])
					cylinder(d=30,h=th+4+0.2,$fn=80);
				for (x=[-1,1])
					for (y=[-1,1])
					translate ([x*31/2,y*31/2,th])
					rotate([180,0,0])
					{
						m3_screw(h=10,cap_out=10);
						m3_washer();
						report_m3(screw=35);
						report_m3_washer();
					}
			}
			
			spool_axis_fix(down=down_fix,report=true);
		}
		spool_axis_fix_add(down=down_fix);
	}
}

spool_axis_fix_nut=16;
spool_axis_fix_rays=6;

module spool_axis_fix(down=0,nuts=true,report=false)
{
	translate ([0,0,down])
	translate_rotate (spool_axis_tr)
	translate ([0,0,-spool_axis[3]+0.01])
	{
		angle=360/spool_axis_fix_rays;
		for (a=[0:spool_axis_fix_rays-1])
			rotate([0,0,a*angle])
			translate ([spool_axis[0]/2+(spool_axis[2]-spool_axis[0])/4
				,0
				,spool_axis[3]-gear_big_h/2-m5_cap_h()])
			rotate ([180,0,0])
			{
				if (report)
				{
					report_m5_screw(screw=20);
					report_m5_nut();
				}
				m5n_screw_washer(thickness=40,washer_out=20);
				translate([0,0,spool_axis_fix_nut])
				rotate ([0,0,90])
					m5_nut(h=20);
			}
	}
}

module spool_axis_fix_add(down=0)
{
	translate ([0,0,down])
	translate_rotate (spool_axis_tr)
	translate ([0,0,-spool_axis[3]+0.01])
	{
		angle=360/spool_axis_fix_rays;
		for (a=[0:spool_axis_fix_rays-1])
			rotate([0,0,a*angle])
			translate ([spool_axis[0]/2+(spool_axis[2]-spool_axis[0])/4
				,0
				,spool_axis[3]-gear_big_h/2-m5_cap_h()])
			rotate ([180,0,0])
			{
				translate([0,0,spool_axis_fix_nut])
				rotate ([0,0,90])
					m5_nut(h=0.2);
			}
	}
}

module spool_axis()
{
	th=6;
	difference()
	{
		translate_rotate (spool_axis_tr)
		{
			translate ([0,0,-gear_big_h/2])
				cylinder (d=spool_axis[0],h=spool_axis[1]+gear_big_h/2,$fn=100);
			translate ([0,0,-spool_axis[3]+0.01])
				cylinder(d=spool_axis[2],h=spool_axis[3]-gear_big_h/2,$fn=100);
		}
		translate_rotate (spool_axis_tr)
		translate([0,0,-spool_axis[3]-0.1])
			cylinder (d=spool_axis[0]-th*2
					,h=spool_axis[1]+spool_axis[3]+0.2,$fn=100);		
		spool_axis_fix();
	}
}

module stand(nuts=false)
{
	slot_cur=20;//slot;
	points=polyRound([
		 [-stand[0]/2,0,4]
		,[stand[0]/2,0,4]
		,[stand[0]/2,slot_cur+stand[2],0]
		,[-stand[0]/2,slot_cur+stand[2],0]
	],1);	

	module main()
	{
		translate_rotate (stand_tr)
		linear_extrude (stand[2])
			translate ([-stand[0]/2,-stand_zadd,0])
				square (size=[stand[0],stand[1]+stand_zadd]);
	}
	
	union()
	{
		difference()
		{
			union()
			{			
				//fillet(r=2,steps=6)//14,16
				{
					translate ([0,-slot_cur+0.01,-stand_slot_th-stand_zadd+0.01])
					translate (stand_tr[0])
					linear_extrude(stand_slot_th)
						polygon(points);
					
					main();	
				}
				
				//hull()
				{
					translate_rotate (stand_tr)
						translate ([0,gear_big_d/2,0])
						linear_extrude(stand[4])
							circle (d=stand[3]);
					main();
				}
			}
			
			translate_rotate (stand_tr)
				translate ([0,gear_big_d/2,-0.1])
				linear_extrude(stand[4]+0.2)
					circle (d=spool_axis[0]);	
					
			offs=14;
			for (x=[-stand[0]/2+offs,stand[0]/2-offs])
			for (y=[-10/*,-30*/])
			translate ([x,y,4-stand_slot_th-stand_zadd])
			translate (stand_tr[0])
			rotate ([180,0,0])
			{
				m5n_screw_washer(thickness=40,washer_out=20);
				report_m5_point();
			}
			
			translate ([0,0-stand[4],0])
				spool_axis_fix(report=nuts);
		}
		translate ([0,0-stand[4],0])
			spool_axis_fix_add();
	}
}

module endstop_flag()
{
	tube_corr=[0,8,4];
	flag_corr=[1,9-6];
	
	translate (endstop_tr)
	translate([12,8,4])
	difference()
	{
		union()
		{
			xx=3.5;
			diff=0.4;
			hh=endstop_dim.x+endstop_screw_out*2;
			translate([xx-hh/2,endstop_screw_tr.x,endstop_screw_tr.y])
			rotate ([0,90,0])
			{
				cylinder (d=endstop_screw_d,h=hh,$fn=80);
				translate ([0,0,endstop_screw_out+endstop_thickness+diff])
					cylinder (d=endstop_screw_d+4,h=endstop_dim.x-endstop_thickness*2-diff*2,$fn=80);
			}
			
			translate ([xx,-3-tube_corr[0],endstop_screw_tr.y])
			rotate ([-90,0,0])
			fillet(r=1,steps=8)
			{
				translate ([0,0,-tube_corr[2]])
				cylinder (d=endstop_tube,h=20+tube_corr[0]+tube_corr[1]+tube_corr[2],$fn=80);
				sl=1.6;
				translate([-sl/2,0,0])
				{
					dim=[sl,16+flag_corr[0],6+flag_corr[1]];
					rotate ([90,0,90])
					linear_extrude(dim.x)
						polygon(polyRound([
							 [0,0,0]
							,[dim.y,0,2.5+3]
							,[dim.y,dim.z,6.5+3]
							,[0,dim.z,0]
						],20));
				}
			}
		}
		translate ([3.5,-3,endstop_screw_tr.y])
		rotate ([-90,0,0])
		translate ([0,0,-10])
			cylinder (d=4.9,h=60,$fn=80);
		report_m5_bolt(screw=30);
	}
}

endstop_fix_screw_offsv=0.2;

module endstop_fix_screw(add=false)
{
	hh=12;
	translate (endstop_tr)
	translate([12,8,4])
	for (x=[-6.1,13])
		translate ([x,0,4.6])
			rotate ([0,180,0])
		{
			if (add)
			{
				translate ([0,0,hh])
				translate ([0,0,-endstop_fix_screw_offsv])
					cylinder (d=5,h=0.2,$fn=20);
			}
			else
			{
				m3_screw(17);
				translate ([0,0,hh])
				rotate ([0,0,90])
					nut(G=m3_nut_G()+0.2,H=20);
					//m3_nut(h=20);
			}
		}
}
module endstop_fix_screw_add()
{
	endstop_fix_screw(add=true);
}

endstop_xadd=4;

module endstopcut()
{
	translate (endstop_tr)
	translate([12,8,4])
	translate ([-17,-5.5,-0.2])
	{
		cube([32,11,16]);
		cube([38,11,6]);
		zadd=10;
		translate ([0,0,-endstop_up-zadd+1])
			cube([7,11,endstop_up+zadd-1]);
		translate ([14,1,-2])
			cube([12,9,3]);
	}
}

module endstop_base()
{
	difference()
	{
		union()
		{
			translate (endstop_tr)
			{
				cube (endstop_dim);
				dim=[endstop_thickness,endstop_dim.y,endstop_top];
				gr=[
					 [0,12,10]
					,[8,33,40]
					,[0,dim.z,8]
				];
				points=[
					 [0,0,0]
					,[dim.y,0,0]
					,[dim.y+gr[0].x,0+gr[0].y,gr[0].z]
					,[dim.y+gr[1].x,0+gr[1].y,gr[1].z]
					,[dim.y+gr[2].x,0+gr[2].y,gr[2].z]
					//,[dim.y,dim.z,2]
					,[0,dim.z,2]
				];
				
				for (t=[[-endstop_xadd,0,0],[endstop_dim.x-endstop_thickness,0,0]])
					translate (t)
					rotate ([90,0,90])
					linear_extrude (dim.x+endstop_xadd)
						polygon(polyRound(points,20));
//					cube (dim);
				
				//dimb=[endstop_dim.x,1.6,endstop_top-10];
				//cube (dimb);
			}
		}
	
		report_optical_switch();
		endstopcut();
		endstop_fix_screw();
		
		translate (endstop_tr)
		translate([12,8,4])			
		translate([100,endstop_screw_tr.x,endstop_screw_tr.y])
		mirror([0,1,0])
		{
			dd=endstop_screw_d+0.8;
			outs=[-endstop_screw_d-4-4,20];
			rotate ([-90,0,90])
			linear_extrude(200)
			polygon(polyRound([
				 [-dd/2,dd/2,dd/2]
				,[dd/2,dd/2,dd/2]
			
				,[dd/2,outs[0]+dd/2,dd/2]	
				,[dd/2+outs[1],outs[0]+dd/2,0]
			
				,[dd/2+outs[1],outs[0]-dd/2,0]
				,[-dd/2,outs[0]-dd/2,dd/2]
			],20));
		}
	}
}

module endstop_fix()
{
	fdim=[endstop_dim.x+endstop_xadd*2,endstop_dim.y,endstop_up];
	out=0;
	out_screw=out-7;
	pdim=[fdim.x+out*2,20,4];
	ldim=[fdim.x,endstop_back+20,pdim.z];

	union()
	{
		difference()
		{
			translate (endstop_tr)
			translate ([0,0,-endstop_up])
			{
				difference()
				{
					th=6;
					union()
					{
						translate ([-endstop_xadd,0,0])
						fillet(r=4,steps=8)
						{
							linear_extrude(ldim.z)
							polygon(polyRound([
								 [0,0,4]
								,[ldim.x,0,4]
								,[ldim.x,ldim.y,4]
								,[0,ldim.y,4]
							],1));
							cube (fdim);
						}
						translate ([-endstop_xadd,0,0])
						fillet(r=4,steps=1)
						{
							linear_extrude(ldim.z)
							polygon(polyRound([
								 [0,0,4]
								,[ldim.x,0,4]
								,[ldim.x,ldim.y,4]
								,[0,ldim.y,4]
							],1));
							translate ([-out,endstop_back,0])
							{
								linear_extrude(pdim.z)
								polygon(polyRound([
									 [0,0,4]
									,[pdim.x,0,4]
									,[pdim.x,pdim.y,4]
									,[0,pdim.y,4]
								],1));
							}
						}
					}
					for (x=[-out_screw,endstop_dim.x+out_screw])
						translate ([x,10+endstop_back,pdim.z])
						rotate ([0,180,0])
						{
							m5n_screw_washer(thickness=pdim.z,washer_out=0,washer_spere=true);
							report_m5_point();
						}
					
					translate ([th,-1,4])
						cube ([fdim.x-th*2,fdim.y+2,fdim.z-4-th]);
					translate ([-1,th,4])
						cube ([fdim.x+2,fdim.y-th*2,fdim.z-4-th]);
				}
			}

			endstop_fix_screw();
			endstopcut();
		}
		endstop_fix_screw_add();
	}
}
	
module screw_cap()
{
	dim=[1,3.6,12,9.4,5.4,2];
	difference()
	{
		h=dim[0]+dim[1];
		union()
		{
			rays=6;
			angle=360/rays;
			for (a=[0:rays-1])
				fillet(r=0.8,steps=8)
				{
					cylinder (d=dim[2],h=h,$fn=180);
					
					hull()
					{
						rotate ([0,0,a*angle])
						translate ([dim[2]/2+dim[5],0,0])
							cylinder (d=4,h=h,$fn=80);
						cylinder (d=4,h=h,$fn=80);
					}
				}
		}
		translate([0,0,dim[0]])
			cylinder (d=dim[3],h=dim[1]+0.1,$fn=6);
		translate([0,0,-0.1])
			cylinder (d=dim[4],h=h+0.2,$fn=80);
	}
}

module gear_big_cut(offs=[2,3])
{
	gear_cut=[gear_big_d-10,gear_big_h-4];
	rr=body_dim[1]/2-(body_dim[1]-body_dim[0])/4;
	washer_fix_hh=4;
	fil_rays=20;
	
	translate_rotate(big_gear_tr)
	{
		translate ([0,0,-gear_big_h/2-offs[1]])
			cylinder (d=body_dim[3]+gear_big_cut_offsd+offs[0]*2,h=body_dim[2]+gear_big_h/2+offs[1]*2,$fn=100);
	}
}

module power_to_slot(dim,add=false,sgn=1,screw_offset=0)
{
	screwt=[4,40,9];
	
	union()
	{
		difference()
		{
			translate ([-dim.x,-dim.y/2,0])
				cube (dim);
			for (y=[-10,10])
				translate ([-4,y+power_to_slot_out/2*sgn,10])
				rotate ([0,90,0])
				{
					m5n_screw_washer(thickness=6,washer_out=20);
					report_m5_screw_only(screw=10);
				}
			
			for (y=[-screwt[1]/2,screwt[1]/2])
				translate ([-screwt[2]+screw_offset,y+power_to_slot_out/2*sgn,screwt[0]])
				{
					rotate ([0,180,0]) 
					translate ([0,0,-10])
					hull()
					{
						cylinder(d=3.4,h=30,$fn=40);
						translate ([screw_offset,0,0])
							cylinder(d=3.4,h=30,$fn=40);
					}
					rotate ([0,0,90])
						m3_square_nut(offs=0.4,offsv=0.2);
					report_m3(screw=10);
					report_m3_squarenut();
				}
		}
		if (add)
		for (y=[-10,10])
			translate ([-4,y+power_to_slot_out/2*sgn,10])
			rotate ([0,90,0])
				m5n_screw_washer_add(h=0.3);
	}
}

module slot_left()
{
	difference()
	{
		union()
		{
			translate_rotate (slot_left_tr)
				power_to_slot(dim=power_to_slot_left_dim, add=true);
			translate ([0,-power_to_slot_left_dim.y/2,20.1])
			translate_rotate (slot_left_tr)
			{
				dim=[power_to_slot_up[1],power_to_slot_left_dim.y,power_to_slot_up[0]-0.1];
				//cube(dim);
				ex=2;
				points=polyRound([
					 [0,0,0]
					,[0,dim.z+ex,0]
					,[0,dim.z,ex]
					,[dim.x,dim.z,1]
					,[dim.x,0,0]
				],20);
				
				translate ([0,dim.y,0])
				rotate ([90,0,0])
				linear_extrude(dim.y)
					polygon(points);
			}
		}

		translate ([-power_to_slot_cut[1],-power_to_slot_left_dim.y/2-0.1,20-power_to_slot_cut[0]+0.1])
		translate_rotate (slot_left_tr)
		{
			dim=[power_to_slot_cut[1]+0.1,power_to_slot_left_dim.y+0.2,power_to_slot_cut[0]];
			
			//cube(dim);	
			ex=2;
			points=polyRound([
				 [0,0,1]
				,[0,dim.z,1]
				,[dim.x,dim.z,0]
				,[dim.x,-ex,0]
				,[dim.x,0,ex]
			],20);
			
			translate ([0,dim.y,0])
			rotate ([90,0,0])
			linear_extrude(dim.y)
				polygon(points);
		}
		
		translate ([0,30,0])
		scale ([1,2,1])
			gear_big_cut();
			
		translate ([0,0,power_to_slot_up[0]])
		translate_rotate (slot_left_tr)
		translate ([-30,12.8+3,20])
		{
			dim=[60,40,80];
			rotate ([90,0,90])
			linear_extrude(dim.x)
				polygon(polyRound([
					 [0,0,8]
					,[dim.y,0,8]
					,[dim.y,dim.z,0]
					,[0,dim.z,0]
				],20));
		}

		translate ([0,0,power_to_slot_up[0]])
		translate_rotate (slot_left_tr)
		translate ([-30,-power_to_slot_left_dim.y/2+5,20])
		{
			dim=[60,37.8,32];
			rotate ([90,0,90])
			linear_extrude(dim.x)
				polygon(polyRound([
					 [0,0,6]
					,[dim.y,0,6]
					,[dim.y,dim.z,6]
					,[0,dim.z,6]
				],20));
		}
	}
}

module slot_right()
{
	difference()
	{
		union()
		{
			translate_rotate (slot_right_tr)
				power_to_slot(dim=power_to_slot_right_dim,sgn=-1,screw_offset=5);
			//translate ([0,power_to_slot_right_dim.y/2,20.1])
			//translate_rotate (slot_right_tr)
			//	cube([power_to_slot_up[1],power_to_slot_right_dim.y,power_to_slot_up[0]-0.1]);
		}
		
		tr=[-power_to_slot_right_dim.x-1,power_to_slot_right_dim.y/2-power_to_slot_out,20];
		
		translate ([0,4,power_to_slot_up[0]])
		translate_rotate (slot_right_tr)
		translate (tr)
		{
			dim=[40,2,power_to_slot_right_dim.z-tr.z-power_to_slot_up[0]+0.01];
			//#cube (dim);
			small=1.2;
			points=[
				 [0,0,0]
				,[dim.y,0,0]
				,[dim.y,dim.z,0]
				,[dim.y-small,dim.z,0]
				,[dim.y-small,dim.z-power_to_slot_right_fix,0]
				,[0,dim.z-power_to_slot_right_fix,1]
			];
			rotate ([90,0,90])
			linear_extrude(dim.x)
				polygon(polyRound(points,20));
		}
		
		w=60;
		translate_rotate (slot_right_tr)
		translate (tr)
		translate ([0,-w-5.5-4,0])
		{
			dim=[40,w,power_to_slot_right_dim.z-tr.z+0.01];
			nutcut=6;
			//cube (dim);
			rotate ([90,0,90])
			linear_extrude(dim.x)
				polygon(polyRound([
					 [0,0,8]
					,[dim.y,0,8]
					,[dim.y,dim.z-power_to_slot_right_fix-power_to_slot_up[0],nutcut/2]
					,[dim.y-nutcut,dim.z-power_to_slot_right_fix-power_to_slot_up[0],nutcut/2]
					,[dim.y-nutcut,dim.z,0]
					,[0,dim.z,0]
				],20));
		}
		
		translate ([power_to_slot_right_dim.x/2,-power_to_slot_right_dim.y/2,power_to_slot_right_dim.z-power_to_slot_right_fix/2])
		translate_rotate (slot_right_tr)
		rotate ([90,0,0])
		{
			screw=20.1;
			m5_screw(h=30);
			hull()
			for (out=[0,20])
			translate ([0,out,4])
			rotate ([0,0,90])
				nut(G=9.4,H=m5_nut_H());
			
			report_m5_bolt(screw=16);
			report_m5_nut();
		}

		translate ([power_to_slot_right_dim.x*2-power_to_slot_right_x,power_to_slot_right_dim.y/2+0.01,-0.01])
		translate_rotate (slot_right_tr)
		{
			r=power_to_slot_right_x/2;
			dim=[power_to_slot_right_dim.x,power_to_slot_right_dim.y+0.02,45+r];
			translate ([0,0,dim.z])
			rotate ([-90,0,0])
			linear_extrude (dim.y)
				polygon(polyRound([
					 [0,-r,0]
					,[dim.x-2*r,-r,0]
					,[dim.x-2*r,0,r]
					,[dim.x,0,r]
					,[dim.x,dim.z,0]
					,[0,dim.z,0]
				],20));
		}
	}
}

module spool_axis_spacer(hh=1)
{
	th=6;
	difference()
	{
		translate_rotate (spool_axis_tr)
		translate ([0,0,-spool_axis[3]+0.01])
			cylinder(d=spool_axis[2],h=hh,$fn=100);
		translate_rotate (spool_axis_tr)
		translate ([0,0,-spool_axis[3]-0.01])
			cylinder (d=spool_axis[0]+1,h=spool_axis[1]+gear_big_h/2,$fn=100);
		
		translate ([0,-hh+1,0])
			spool_axis_fix();
	}
}

module spool_bottom()
{
	difference()
	{
		hh=3;
		rotate_extrude($fn=200)
			polygon(polyRound([
				 [0,0,0]
				,[spool_dim[0]/2,0,0]
				,[spool_dim[0]/2,hh,1]
				,[spool_dim[1]/2,hh,2]
				,[spool_dim[1]/2,spool_dim[2],3]
				,[0,spool_dim[2],0]
			],20));
		translate ([0,0,spool_dim[2]-spool_bearing[1]])
		{
			report ("608 bearing");
			cut=1;
			dd=spool_bearing[0];
			hh=spool_bearing[1]+0.01;
			cylinder (d=dd,h=hh,$fn=60);
			translate ([0,0,hh-cut])
				cylinder (d1=dd,d2=dd+cut,h=cut,$fn=60);
			
			c2=[2.4-1.4,1.6];
			rays=22;
			angle=360/rays;
			for (a=[0:rays-1])
				rotate ([0,0,a*angle])
				translate ([0,-c2[1]/2,0])
					cube ([dd/2+c2[0],c2[1],hh]);
		}
		translate ([0,0,-0.1])
		{
			dd=spool_bearing[2]+3;
			hh=spool_dim[2]+0.2;
			cut=5;
			cylinder (d=dd,h=hh,$fn=60);
			cylinder (d1=dd+cut*2,d2=dd,h=cut,$fn=60);
		}
		
		cut=[38,60];
		rays=5;
		angle=360/rays;
		for (a=[0:rays-1])
			rotate([0,0,a*angle])
			translate ([spool_dim[1]/2+cut[1]/2+1.6,0,-0.1])
			linear_extrude (spool_dim[2]+0.2)
			scale ([cut[1]/cut[0],1,1])
				circle (d=cut[0],$fn=120);
	}
}

module spool_top(part=0)
{
	hh=spool_bearing[1]-1;
	translate ([0,0,spool_dim[2]])
	{
		difference()
		{
			union()
			{
				if (part==0)
				{
					translate ([0,0,-hh+0.01])
					{
						cut=1;
						dd=spool_bearing[2]-0.3;
						cylinder (d1=dd-cut*2,d2=dd,h=cut,$fn=60);
						translate ([0,0,cut-0.01])
							cylinder (d=dd,h=hh-cut,$fn=60);
					}
					cylinder (d=spool_bearing[2]+2,h=spool_dim[3]+0.01,$fn=60);
				}
				if (part==1)
				{
					translate ([0,0,spool_dim[3]])
						cylinder (d=spool_dim[5],h=spool_dim[4]+0.01,$fn=120);
					translate ([0,0,spool_dim[3]+spool_dim[4]])
						cylinder (d=spool_dim[7],h=spool_dim[6],$fn=120);
				}
			}
			
			screw=20;
			translate ([0,0,-hh])
			{
				report_m3_hexnut();
				report_m3_washer();
				report_m3(screw=screw);
				m3_screw(h=screw);
				translate ([0,0,screw+-3-5])
				{
					m3_nut_inner(h=100);
					translate([0,0,m3_nut_h()])
						m3_nut(h=100);
				}
			}
		}
	}
}

module spool_washer()
{
	washer=4;
		difference()
		{
			cylinder (d=spool_bearing[2]+2,h=spool_dim[3]+0.01,$fn=60);
			m3_screw(h=20);
			m3_washer();
		}
}

module printer_filament_case(op=0)
{
	dd=body_dim[3]+filament_case[1]*2;
	dd2=12+6;
	ftr=[0,-(dd/2+dd2/2-1),0];
	ftr_angle=[[0,-90],[180,90]];

	he=body_dim[2]+spool_axis[3]+filament_case[0]+3;
	hh=op==0?he:2;
	hhtr=op==0?0:he+0.1;
	dinner=op==0?0:-4;
	
	hears=op==0?9:hh;
	
	cutangle=90+45;
	cutray=44-4;

	gear_big_cut_offs=[1+dinner*2,spool_axis[3]];
	
	rc=(body_dim[3]+gear_big_cut_offsd+gear_big_cut_offs[0]*2)/2-0.2;
	rco=dd/2-rc+0.1;
	
	difference()
	{
		rr=op==0?4:0;
		union()
		fillet(r=rr,steps=16)
		{
			translate_rotate(big_gear_tr)
			translate ([0,0,hhtr])
			{
				for (a=ftr_angle)
				rotate ([0,0,a[0]])
				union()
				fillet(r=6,steps=12)
				{
					translate ([0,0,-spool_axis[3]])
					hull()
					{
						fn=80;
						cylinder (d=dd2,h=hh,$fn=fn);
						translate([0,0,hh-hears])
						translate(ftr)
						{
							cylinder (d=dd2,h=hears,$fn=fn);
							if (op==0)
								sphere (d=dd2,$fn=fn);
						}
					}
								
					translate ([0,0,-spool_axis[3]])
						cylinder (d=dd,h=hh,$fn=200);
				}
			}
			if (op==0)	
			{
				translate_rotate(big_gear_tr)
				{
					offs=[2,2,1];
					dim=[4+offs.x*2,rco+offs.y,cutray+offs.z*2];
					rotate([0,0,cutangle])
					translate ([-dim.x/2,rc,-offs.z])
						cube (dim);
				}
			}
		}
		translate ([0,-gear_big_h/2-filament_case[0],0])
			gear_big_cut(offs=gear_big_cut_offs);
		
		for (a=ftr_angle)
		translate_rotate(big_gear_tr)
		rotate ([0,0,a[0]])
		translate ([0,0,-spool_axis[3]])
		translate(ftr)
		rotate ([0,0,a[1]])
		{
			translate ([0,0,hh-45])
				cylinder (d=m5_screw_diameter(),h=200,$fn=60);
			translate ([0,0,hh-10])
			hull()
			{
				rotate ([0,0,90])
				m5_nut();
				translate ([0,-20,0])
				rotate ([0,0,90])
					m5_nut();
			}
			
			if (op==0)
			{
				report_m5_nut();
				report_m5_bolt(screw=16);
			}
		}
		
		spool_axis_fix();
		
		slot_cur=200;
		points=polyRound([
			 [-stand[0]/2,0,4]
			,[stand[0]/2,0,4]
			,[stand[0]/2,slot_cur+stand[2],0]
			,[-stand[0]/2,slot_cur+stand[2],0]
		],1);	
		translate ([0,-slot_cur+0.01,-stand_slot_th-stand_zadd+0.01])
		translate (stand_tr[0])
			linear_extrude(stand_slot_th+0.6)
				polygon(points);
		
		if (op==0)	
		{
			translate_rotate(big_gear_tr)
			{
				dim=[4,rco+20,cutray];
				rotate([0,0,cutangle])
				translate ([-dim.x/2,rc,0])
					cube (dim);
			}
		}
	}
}

slot=20;
device_back=6.1+1;
device_bottom=slot+21.5+1;
board_h=23+7;
under_board=3;

module device_box(x,y,thickness,offs=0,plate=true,down=0,up=0)
{
	//cut=[7.4,5.6];
	cut=[0,0];
	points1=[
		 [-thickness,0]
		,[-device_back-thickness,0]
		,[-device_back-thickness,-slot]
		,[-thickness,-slot]
		,[-thickness,-device_bottom+cut[0]]
		,[-thickness-cut[1],-device_bottom+up]
		,[y,-device_bottom+up]
		,[y,-down]
	];
	translate ([-x/2,0,0])
	rotate ([90,0,90])
	linear_extrude(x)
	offset(delta=offs)
		polygon(points1);
	
	ears=16;
	r=3;
	points2=[
		 [-x/2-ears,0,r]
		,[x/2+ears,0,r]
		,[x/2+ears,-20,r]
		,[-x/2-ears,-20,r]
	];
	
	if (plate)
	difference()
	{
		th=4;
		translate ([0,-device_back-thickness+th,0])
		rotate ([90,0,0])
		linear_extrude(th)
			polygon(polyRound(points2,1));
			
		translate ([0,-device_back-thickness+4,0])
		for (xx=[-1,1])
			translate ([(x/2+ears-8)*xx,0,-10])
			rotate ([90,0,0])
				m5n_screw_washer(thickness=4,washer_out=10);
	}
}

module board_cut(op,thickness,h)
{
	w=86.36;
	l=33.655;
	offs=[1,4.42-1.6];
	ww=w+offs.x*2;
	ll=l+offs.y*2;
	screws1=[
		 [-w/2+6.350,+l/2-3.810]
		,[w/2-5.08,-l/2+4.450]
	];
	screw2_offs=[4.4,1.4];
	screws2=[
		 [-w/2-screw2_offs.x,-l/2+screw2_offs.y,-90]
		,[-w/2-screw2_offs.x,+l/2-screw2_offs.y,-90]
		,[w/2+screw2_offs.x,-l/2+screw2_offs.y,90]
		,[w/2+screw2_offs.x,+l/2-screw2_offs.y,90]
	];
	if (op=="cut1")
	{
		translate ([-ww/2,0,-device_bottom+(device_bottom-ll)/2])
			cube ([ww,board_h+under_board,ll]);
		add1=[20,1,6*2];
		translate ([-ww/2,0,-device_bottom+(device_bottom-l)/2])
		translate ([-add1[0],add1[1],add1[2]/2])
			cube ([ww+add1[0],board_h+under_board-add1[1],l-add1[2]]);
		add2=[40,7,6*2];
		translate ([-ww/2,0,-device_bottom+(device_bottom-l)/2])
		translate ([0,add2[1],add2[2]/2])
			cube ([ww+add2[0],board_h+under_board-add2[1],l-add2[2]]);
		
		dd=6;
		diff=[dd+1,dd+1];
		for (y=[-2:2])
			for (x=[-5:5])
			{
				xadd=diff.x/2*(y % 2);
				translate ([diff.x*x+xadd,0,-device_bottom/2+diff.y*y])
				rotate ([-90,90,0])
				{
					cylinder (d=dd,h=50,$fn=6);
					translate ([0,0,board_h+under_board+1])
						cylinder (d=dd+3.2,h=50,$fn=6);
				}
			}
	}
	
	fix_nut_offs=2.6-1.0;
	hex_nut_offs=4;
	hex_nut_screw=10;

	screw3=10;
	screw3_x=48.5;
	
	if (op=="add1")
	{
		translate ([0,0,-device_bottom/2])
		{
			for (s=screws1)
			translate ([s[0],0,s[1]])
			rotate ([-90,0,0])
			{
				cylinder (d=7.4,h=under_board,$fn=60);
				cylinder (d=9,h=1,$fn=60);
			}
		}
	}
	if (op=="cut2")
	{
		translate ([0,0,-device_bottom/2])
		{
			for (s=screws1)
			translate ([s[0],-2,s[1]])
			rotate ([-90,0,0])
			{
				cylinder (d=3.5,h=6,$fn=60);
				
				translate ([0,0,fix_nut_offs])
				rotate ([180,0,0])
				{
					m3_nut_inner();
					translate ([0,0,m3_nut_h()-0.01])
						m3_nut(h=100);
				}
			}
		}
		
		translate ([0,0,-device_bottom/2])
			for (s=screws2)
			translate ([s[0],h,s[1]])
			rotate ([90,s[2],0])
			{
				m3_screw(h=hex_nut_screw);
				translate ([0,0,hex_nut_screw-hex_nut_offs])
					m3_square_nut(offs=0.4,offsv=0.2);
			}
			
		for (x=[-1,1])
			translate ([x*screw3_x,-device_back-under_board+screw3+1,-15])
			rotate ([90,0,0])
			{
				m3_screw(h=screw3,cap_out=20);
				translate ([0,0,screw3-m3_nut_h()])
					m3_nut(h=m3_nut_h()+2);
			}
	}
	if (op=="add2")
	{
		translate ([0,0,-device_bottom/2])
		{
			for (s=screws1)
			translate ([s[0],-2,s[1]])
			rotate ([-90,0,0])
			{
				translate ([0,0,fix_nut_offs+0.3])
				rotate ([180,0,0])
				{
					cylinder (d=8,h=0.3,$fn=6);
				}
			}
		}
		translate ([0,0,-device_bottom/2])
		for (s=screws2)
		translate ([s[0],h,s[1]])
		rotate ([90,s[2],0])
		{
			translate ([0,0,hex_nut_screw-hex_nut_offs-0.2-0.3])
				cylinder (d=6,h=0.3,$fn=6);
		}

		for (x=[-1,1])
			translate ([x*screw3_x,-device_back-under_board+screw3+1,-15])
			rotate ([90,0,0])
			{
				translate ([0,0,screw3-m3_nut_h()-0.3])
					m3_nut(h=0.3);
			}
	}
}

module board_box(part)
{
	w=105;
	board_top=2;
	thickness=3.0;
	h=board_h+under_board+board_top;
	
	module cut_parts(offs=0)
	{
		translate ([-w/2-50,h-board_top-offs,-60])
			cube ([w+100,20,61]);
	}
	
	module cut_parts2(offs=0)
	{
		translate ([-w/2-50,-device_back-under_board-offs-0.01,-60])
			cube ([w+100,device_back,61]);
	}
	
	module body(lighter=true)
	{
		union()
		{
			difference()
			{
				union()
				{
					difference()
					{
						device_box(x=w,y=h,thickness=thickness);
						//offs=1.6;
						//cc=30;
						//if (lighter)
						//translate ([6.3,offs,0])
						//	device_box(x=w-cc,y=h,thickness=thickness,offs=-offs,plate=false);
						board_cut(op="cut1",thickness=thickness,h=h);
					}
					board_cut(op="add1",thickness=thickness,h=h);
				}
				board_cut(op="cut2",thickness=thickness,h=h);
			}
			board_cut(op="add2",thickness=thickness,h=h);
		}
	}
	
	if (part=="plate")
	{
		intersection()
		{
			body();
			cut_parts2(offs=0.1);
		}
	}
	if (part=="bottom")
	{
		difference()
		{
			body();
			cut_parts(offs=0.1);
			cut_parts2(offs=0.0);
		}
	}
	if (part=="top")
	{
		intersection()
		{
			body(lighter=false);
			cut_parts(offs=0);
		}
	}
}

module oled(op,thickness=3)
{
	screw=10;
	oled_screw_d=2.5+0.2;
	oled_stand=1.3+0.5;
	if (op==1)
	{
		translate ([-oled_width/2,-oled_height/2,0])
			cube ([oled_width,oled_height,thickness]);
		for (x=[-1,1])
			for (y=[-1,1])
				translate ([0,0,-oled_stand+0.01])
				translate (stand_tr(x,y))
					cylinder (d=oled_screw_d+0.8*2,h=oled_stand+0.02,$fn=40);
	}
	
	if (op==2)
	{
		translate ([0,1.5-0.5,0])
		translate ([-screen_width/2,-screen_height/2,0])
		{
			zz=2;
			out=3;
			translate ([0,0,-0.1])
				cube ([screen_width,screen_height,zz+0.2]);
			hull()
			{
				translate ([0,0,zz])
					cube ([screen_width,screen_height,0.01]);
				translate ([-out,-out,zz+out])
					cube ([screen_width+out*2,screen_height+out*2,0.01]);
			}
		}

		wire_width=14;
		wire_height=3;
		translate ([0,10,0])
		translate ([-wire_width/2,0,0])
		{
			translate ([0,0,-0.1])
				cube ([wire_width,wire_height,1.0]);
		}
	
		screw=10;
		for (x=[-1,1])
			for (y=[-1,1])
				translate (stand_tr(x,y))
				{
					translate ([0,0,-oled_stand])
						cylinder (d=oled_screw_d,h=screw+10,$fn=20);
					out=1.8;
					translate ([0,0,thickness-out])
						cylinder (d1=oled_screw_d,d2=oled_screw_d+out*2,h=out+0.01,$fn=20);
				}
	}
}

module encoder(op)
{
	hh=8-2;
	if (op==1)
	{
		dd=17;
		hull()
		{
			cylinder (d=dd,h=hh,$fn=80);
			translate ([-dd/2,dd/2,0])
				cube ([dd,0.1,hh]);
		}
	}
	translate ([0,0,-2])
	if (op==3)
	{
		translate ([0,0,4])
			cylinder (d=15,h=0.4,$fn=80);
	}
	if (op==2)
	{
		translate ([0,0,-0.1])
			cylinder (d=15,h=4.1,$fn=80);
		translate ([0,0,0])
			cylinder (d=7.5,h=10,$fn=80);
		
		cut=[2.5,1.01,1.1];
		rotate ([0,0,90])
		translate ([-cut.x/2,5.5,hh-cut.z+0.1])
			cube (cut);
	}
}

//x,y,thickness box,down,thickness inner,up
/*
display=[80-15,40,0,25-10,2.4,0];
yy_display=display[1]+display[2];
alpha_display=acos(display[3]/(sqrt(yy_display*yy_display+display[3]*display[3])));

module display_box(part="")
{
	yt=yy_display/2+4;
	zt=yt/tan(alpha_display);
	tr=[0,yt,-zt];

	tr_oled=[21-15/2,tr.y,tr.z];
	rot_oled=[0,0,180];
	tr_encoder=[-21+15/2,tr.y,tr.z];

	screw_x=21;
	screw3=6;
	
	module body()
	{
		union()
		{
			difference()
			{
				union()
				{
					difference()
					{
						device_box(x=display[0],y=display[1],thickness=display[2],down=display[3],up=display[5]);
						
						translate ([0,20,-20])
						rotate ([0,90,0])
							cylinder (d=12,h=100,$fn=80);
					
						translate ([-display[0]/2+display[4],0,0])
						rotate ([90,0,90])
						linear_extrude(display[0]-display[4]*2)
						offset(-display[4])
						polygon([
							 [0,0]
							,[display[1],-display[3]]
							,[display[1],-60]
							,[0,-60]
						]);
					}
					translate (tr_oled)
					rotate ([-90+alpha_display,0,0])
					rotate (rot_oled)
					translate ([0,0,-display[4]])
						oled(op=1,thickness=display[4]);
		
					translate (tr_encoder)
					rotate ([-90+alpha_display,0,0])
					rotate ([180,0,0])
						encoder(op=1);
				}
				
				for (x=[-1,1])
					translate ([x*screw_x,1,-15])
					rotate ([90,0,0])
					{
						m3_screw(h=screw3,cap_out=5);
						translate ([0,0,screw3-m3_nut_h()])
							m3_nut(h=m3_nut_h()+20);
					}
				
				translate (tr_oled)
				rotate ([-90+alpha_display,0,0])
				rotate (rot_oled)
				translate ([0,0,-display[4]])
					oled(op=2,thickness=display[4]);
		
				translate (tr_encoder)
				rotate ([-90+alpha_display,0,0])
				rotate ([180,0,0])
					encoder(op=2);
			}
			
			for (x=[-1,1])
				translate ([x*screw_x,1,-15])
				rotate ([90,0,0])
				{
					translate ([0,0,screw3-m3_nut_h()-0.3])
						cylinder(d=8,h=0.3,$fn=20);
				}
		}
	}
	
	module cut_parts(offs=0)
	{
		h=board_h+under_board;
		translate ([-display[0]/2-50,-20-offs,-60])
			cube ([display[0]+100,20,61]);
	}
	
	if (part=="")
		body();
	if (part=="plate")
	intersection()
	{
		body();
		cut_parts(offs=0.1);
	}
	if (part=="top")
	difference()
	{
		body();
		cut_parts(offs=0);
	}
}
*/
module encoder_knob_body(d,h)
{
	r=4;
	difference ()
	{
		minkowski()
		{
			cylinder (d=d-r*2,h=h-r,$fn=100);
			sphere (r=r,$fn=100);
		}
		rotate ([180,0,0])
			cylinder (d=d+1,h=r+1);
	}
}

module encoder_knob()
{
	down_knob=2.5;
	difference ()
	{
		dd=22-8-0.5;
		hh=14+down_knob+1;
		translate ([0,0,-down_knob])
			encoder_knob_body(d=dd,h=hh);
		
		rays_o=12;
		angle_o=360/rays_o;
		for (a=[0:rays_o-1])
			rotate ([0,0,a*angle_o])
			translate ([dd/2,0,-20])
				cylinder(d=1.6,h=50,$fn=40);
			
		translate ([0,0,-0.01])
		difference ()
		{
			di=6.2;
			hi=13+down_knob;
			
			rays_i=10;
			yy=1;
			
			union()
			{
				cut=1;
				translate ([0,0,-down_knob])
				fillet(r=cut,steps=4)
				{
					cylinder (d=di,h=hi,$fn=100);
					cylinder (d1=di+cut*2,d2=di,h=cut,$fn=100);
				}
				angle_i=360/rays_i;
				for (a=[0:rays_i-1])
					rotate ([0,0,a*angle_i])
					translate ([0,-yy/2,-down_knob])
						cube ([di/2+1,yy,hi]);
			}
					
			translate ([-10,1.7,-0.01])
				cube ([20,20,20]);
		}
	}
}

//x,y,thickness box,down,thickness inner,up
display2=[80-15,22,0,25-10,2.4,0];
//yy_display=display[1]+display[2];
//alpha_display=acos(display[3]/(sqrt(yy_display*yy_display+display[3]*display[3])));
module display_box2(part="")
{
	tr_oled=[21-15/2,display2[1],-device_bottom/2];
	rot_oled=[90,0,180];
	tr_encoder=[-21+15/2,display2[1],-device_bottom/2];
	rot_encoder=[90,0,0];

	screw_x=21;
	screw3=6;

	ears=16;
	r=3;
	function points_ears(x)=[
		 [-x/2-ears,0,r]
		,[x/2+ears,0,r]
		,[x/2+ears,-20,r]
		,[-x/2-ears,-20,r]
	];
	th=4;
	
	union()
	{
		difference()
		{
			union()
			{
				difference()
				{
					union()
					{
						translate ([-display2[0]/2,0,-device_bottom])
							cube ([display2[0],display2[1],device_bottom]);
						translate ([0,-device_back-display2[2]+th,0])
						translate ([-display2[0]/2,0,-20])
							cube ([display2[0],display2[1],20]);
						
						difference()
						{
							translate ([0,-device_back-display2[2]+th,0])
							rotate ([90,0,0])
							linear_extrude(th)
								polygon(polyRound(points_ears(display2[0]),1));
							
							translate ([0,-device_back-display2[2]+4,0])
							for (xx=[-1,1])
								translate ([(display2[0]/2+ears-8)*xx,0,-10])
								rotate ([90,0,0])
									m5n_screw_washer(thickness=4,washer_out=10);
						}						
					}
					translate ([-display2[0]/2+display2[4],-40-display2[4],-device_bottom+display2[4]])
						cube ([display2[0]-display2[4]*2,display2[1]+40,device_bottom-display2[4]*2]);

					
					translate ([0,10,-20])
					rotate ([0,90,0])
						cylinder (d=12,h=100,$fn=80);
				}
				translate (tr_oled)
				rotate (rot_oled)
				translate ([0,0,-display2[4]])
					oled(op=1,thickness=display2[4]);
	
				translate (tr_encoder)
				rotate (rot_encoder)
					encoder(op=1);
			}
			
			translate (tr_oled)
			rotate (rot_oled)
			translate ([0,0,-display2[4]])
				oled(op=2,thickness=display2[4]);
	
			translate (tr_encoder)
			rotate (rot_encoder)
				encoder(op=2);
		}
	}
}

module list(s)
{
	echo(str("list:",s));
}
if (cmd=="list")
{
	list("board/bottom");
	list("board/top");
	list("board/plate");
	
	/*
	list("display/top");
	list("display/plate");
	*/
	list("display/box");
	list("display/encoder_knob");
	
	list("printer/filament_case");
	list("printer/filament_case_top");
	
	list("main/gear_big_top");
	list("main/gear_big_bottom");
	list("main/gear_big_middle");

	list("planetary/planetary_carrier_top");
	list("planetary/planetary_carrier_bottom");
	list("planetary/planetary_sun");
	list("planetary/planetary_body");
	list("planetary/planetary_satellite");
	list("planetary/planetary_carrier");
	list("planetary/planetary_top");
	
	list("main/stand");
	list("main/spool_axis");
	list("main/motor_plate");
	
	list("main/volcano_fix");
	
	list("main/endstop");
	list("main/endstop_flag");
	
	list("main/screw_cap");
	
	list("power_supply/fix_left");
	list("power_supply/fix_right");	

	list("spool/bottom");
	list("spool/top_inner");
	list("spool/top");
	list("spool/washer");
}

if (cmd=="main/stand")
	rotate ([-90,0,0])
		stand();
if (cmd=="main/spool_axis")
	rotate ([-90,0,0])
		spool_axis();
if (cmd=="main/motor_plate")
	rotate ([-90,0,0])
		motor_plate();
if (cmd=="main/gear_big_top")
	rotate ([-90,0,0])
		gear_big_top();
if (cmd=="main/gear_big_bottom")
	rotate ([90,0,0])
		gear_big_bottom();
if (cmd=="main/gear_big_middle")
	rotate ([-90,0,0])
		gear_big_middle();
if (cmd=="main/endstop")
	rotate ([0,0,0])
	union()
	{
		endstop_base();		
		endstop_fix();		
	}
if (cmd=="main/endstop_flag")
	rotate ([90,0,0])
		endstop_flag();		
if (cmd=="main/screw_cap")
	rotate ([0,0,0])
		screw_cap();
if (cmd=="power_supply/fix_left")
	rotate ([0,-90,0])
		slot_left();
if (cmd=="power_supply/fix_right")
	rotate ([0,-90,0])
		slot_right();
		
if (cmd=="planetary/planetary_sun")
	rotate ([0,0,0])
		planetary_sun();
if (cmd=="planetary/planetary_body")
	rotate ([0,0,0])
		planetary_body();
if (cmd=="planetary/planetary_satellite")
	rotate ([0,0,0])
		planetary_satellite();
if (cmd=="planetary/planetary_carrier_bottom")
	rotate ([180,0,0])
		planetary_carrier_bottom();
if (cmd=="planetary/planetary_carrier_top")
	rotate ([180,0,0])
		planetary_carrier_top();
if (cmd=="planetary/planetary_carrier")
	rotate ([0,0,0])
		planetary_carrier();
if (cmd=="planetary/planetary_top")
	rotate ([180,0,0])
		planetary_top();

if (cmd=="printer/filament_case")
	rotate ([-90,0,0])
		printer_filament_case();
if (cmd=="printer/filament_case_top")
	rotate ([-90,0,0])
		printer_filament_case(op=1);

if (cmd=="spool/bottom")
	rotate ([0,0,0])
		spool_bottom();
if (cmd=="spool/top_inner")
	rotate ([180,0,0])
		spool_top(part=0);
if (cmd=="spool/top")
	rotate ([0,0,0])
		spool_top(part=1);
if (cmd=="spool/washer")
	rotate ([180,0,0])
		spool_washer();

if (cmd=="board/bottom")
	rotate ([90,0,0])
		board_box(part="bottom");
if (cmd=="board/top")
	rotate ([90,0,0])
		board_box(part="top");
if (cmd=="board/plate")
	rotate ([90,0,0])
		board_box(part="plate");
/*
if (cmd=="display/top")
	rotate ([-alpha_display+270,0,0])
		display_box(part="top");
if (cmd=="display/plate")
	rotate ([90,0,0])
		display_box(part="plate");
*/
if (cmd=="display/box")
	rotate ([90,0,0])
		display_box2();
if (cmd=="display/encoder_knob")
	rotate ([0,0,0])
		encoder_knob();

if (cmd=="report_machine")
{
	report("Led power supply MN-100W12V, size 175*53*21mm, https://www.aliexpress.com/item/1005002290063769.html");
	proto();
	stand();
	motor_plate();
	spool_axis();
	slot_left();
	slot_right();
	
	rotate([0,0,180])
	{
		endstop_base();
		endstop_fix();
		endstop_flag();
	}

	gear_big_bottom();
	gear_big_middle();
	gear_big_top();

	planetary_sun();
	planetary_body();
	planetary_satellite();
	planetary_carrier_bottom();
	planetary_carrier_top();
	planetary_carrier();
	planetary_top();
}
if (cmd=="report_printer")
{
	printer_filament_case();
	printer_filament_case(op=1);
	spool_axis();
	stand(nuts=true);
}

if (cmd=="report_spool")
{
	spool_bottom();
	spool_top(part=0);
	spool_top(part=1);
	spool_washer();
}

if (cmd=="")
{
	if (false)
	{
		proto();
		gear_small();
		gear_big();
	
		motor_plate();
		spool_axis();
		stand();
	
		rotate([0,0,180])
		{
			endstop_base();
			endstop_fix();
			endstop_flag();
		}
		slot_left();
		slot_right();
		
		//screw_cap();
		//printer_filament_case();
	}
	else
	{
		//stand();
		//spool_axis();
		//screw_cap();
		//motor_plate();
		//gear_big_bottom();
		//gear_big_middle();
		gear_big_top();
		
		//spool_bottom();
		//spool_top(part=0);
		//spool_top(part=1);
		//spool_washer();
		
		//endstop_flag();
		//endstop_base();
		//endstop_fix();
		
		//printer_filament_case();
		//printer_filament_case(op=1);
		
		//slot_left();
		//slot_right();

//		board_box(part="plate");
//		board_box(part="bottom");
//		board_box(part="top");

//		display_box(part="top");
//		display_box(part="plate");

//		display_box2();

//		encoder_knob();
	}
}