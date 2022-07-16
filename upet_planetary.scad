include <../_utils_v2/NopSCADlib/core.scad>
include <../_utils_v2/NopSCADlib/vitamins/stepper_motors.scad>
include <../_utils_v2/NopSCADlib/vitamins/extrusion_brackets.scad>

use <../_utils_v2/Getriebe.scad>
use <../_utils_v2/_round/polyround.scad>
use <../_utils_v2/fillet.scad>
use <../_utils_v2/m3-m8.scad>

include <config.scad>
include <report.scad>

modul = 1;
outer_diameter=9;
planet_diameter=14;
planet_count=3;
height=10; 
outer_diameter_add=1;
screw_diameter=1;
motor_shaft_diameter=5.4;
conical=30;
conical_fix=0;

fix_hh=7;
fix_dd=20;

up=9.4;
top=5.5;
block_height=up+height;
planetary_height=block_height+top;
carrier_height=4;

bearings = [
 [10,4,5] //mr105zz
,[11,5,5] //685zz
,[16,5,5] //625zz
,[10,4,3] //623zz
,[9,3,5] //mr95
];
bearing=bearings[3];
planetary_satellite_washer_height=0.8;

planetary_rod=[8,0.4];

module planetary_top()
{
	od = outer_diameter + 2*planet_diameter;
	difference()
	{
		cut=4;
		w=NEMA_width(NEMA17);
			
		translate ([0,0,height])
			linear_extrude(top)
				polygon(polyRound([
					 [-w/2,-w/2,cut]
					,[w/2,-w/2,cut]
					,[w/2,w/2,cut]
					,[-w/2,w/2,cut]
				],1));
		
		translate ([0,0,height])
		translate ([0,0,-0.01])
		{
			cylinder (d=planetary_carrier_od()+2,h=carrier_height+0.4,$fn=200);
			cylinder (d=planetary_carrier_od()-4,h=20,$fn=200);
		}
		
		for (x=[-1,1])
			for (y=[-1,1])
				translate ([NEMA_hole_pitch(NEMA17)/2*x,NEMA_hole_pitch(NEMA17)/2*y,-up-2])
					cylinder (d=3.4,h=100,$fn=40);		
	}
}

module gear_small_p(addz=0,top=false)
{
	rotate([-motor_tr[1].x,-motor_tr[1].y,-motor_tr[1].z])
	translate([-motor_tr[0].x,-motor_tr[0].y,-motor_tr[0].z])
	difference()
	{
		union()
		{
			if(top)
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
			translate ([0,0,-addz])
				cylinder(d=small_gear_pad[0],h=small_gear_pad[1]+addz,$fn=40);
			/*	
			translate_rotate (small_gear_pad_tr)
			{
				dd=nobearing?small_gear_bearing[0]:small_gear_bearing[2]-0.2;
				hadd=dd/2;
				hh=(24+gear_small_h+small_gear_bearing[1]+1)-dd/2;
				cylinder(d=dd,h=hh+hadd,$fn=80);
				translate ([0,0,hh])
					sphere (d=dd,$fn=80);
			}
			*/
		}
		translate_rotate (small_gear_pad_tr)
		{
			cut=4;
			translate ([0,0,small_gear_pad[1]+cut])
			{
				hh=gear_small_h-cut;
				cylinder(d=4.5,h=hh,$fn=80);
				in=4;
				translate ([0,0,hh-in])
					cylinder(d1=4.5,d2=5.5,h=in,$fn=80);
			}
		}
	}
}

function planetary_carrier_od()=outer_diameter + 2*planet_diameter - 3;
module planetary_carrier(top=false)
{
	d_planet = modul*planet_diameter;
	d_sun = modul*outer_diameter;
	a = modul*(outer_diameter + planet_diameter)/2;		
	{
		difference()
		{
			union()
			{
				translate ([0,0,height])
				difference()
				{
					cylinder (d=planetary_carrier_od(),h=carrier_height,$fn=200);
					
					//antifriction
					cut=[1,1];
					dd=planetary_carrier_od()-cut[1]*2;
					translate ([0,0,carrier_height-cut[0]])
						cylinder (d1=dd-cut[1]*2,d2=dd,h=cut[0]+0.01,$fn=200);
					
				}
				translate ([0,0,-up+planetary_height])
					gear_small_p(addz=8,top=top);
				translate ([0,0,0.01])
				for(n=[0:planet_count-1])
					translate(kugel_zu_kart([a,90,360/planet_count*n]))
					rotate([0,0,n*360*d_sun/(d_planet)])
					{
						cut=2;
						translate ([0,0,cut-0.01])
							cylinder (d=planetary_rod[0],h=height-cut,$fn=80);
						cylinder (d2=planetary_rod[0],d1=planetary_rod[0]-cut,h=cut,$fn=80);
					}
			}
			translate ([0,0,height-0.01])
				cylinder (d=7.0,h=12,$fn=200);
		}
	}
}

planetary_carrier_cut_z=[25,14];
module planetary_carrier_cut(offs=0)
{
	dim=[50,50,80];
	translate ([0,-offs,planetary_carrier_cut_z[0]])
	{
		translate ([-dim.x/2,0,-offs])
			cube (dim);
		translate ([-dim.x/2,-dim.y+0.01,planetary_carrier_cut_z[1]-offs])
			cube (dim);
	}
}

module planetary_carrier_fix(report=false)
{
	h=10;
	translate ([0,0,planetary_carrier_cut_z[0]+planetary_carrier_cut_z[1]/2])
	rotate ([90,0,0])
	translate ([0,0,-h/2])
	{
		if (report)
		{
			report_m3(screw=h);
			report_m3_washer();
			report_m3_hexnut();
		}
		
		m3_screw(h=h);
		m3_washer();
		translate ([0,0,h-2])
		{
			m3_nut_inner();
			translate ([0,0,m3_nut_h()-0.01])
				m3_nut(h=10);
		}
	}
}
module planetary_carrier_bottom()
{
	difference()
	{
		planetary_carrier(top=false);
		planetary_carrier_cut(offs=0.1);
		planetary_carrier_fix(report=true);
	}
}

module planetary_carrier_top()
{
	difference()
	{
		intersection()
		{
			planetary_carrier(top=true);
			planetary_carrier_cut(offs=-0.1);
		}
		planetary_carrier_fix();
	}
}

module planetary_sun()
{
	screw=6;
	offs=0.8;
	difference()
	{
		union()
		{
			pfeilrad (modul=modul
						,zahnzahl=outer_diameter
						,breite=height
						,bohrung=1
						,eingriffswinkel=conical
						,schraegungswinkel=-conical_fix
						,optimiert=false);
			rotate_extrude($fn=80)
				polygon (polyRound([
					 [0,-fix_hh,0]
					,[fix_dd/2,-fix_hh,0]
					,[fix_dd/2,0,0.5]
					,[0,0,0]
				],20));
		}
		translate ([0,0,height-offs])
			cylinder (d=outer_diameter*2,h=10,$fn=8);
		translate ([0,0,-fix_hh])
		{
			translate ([0,0,-0.01])
			difference()
			{
				hh=fix_hh+height+0.2;
				cylinder (d=motor_shaft_diameter,h=hh,$fn=96);
				translate ([motor_shaft_diameter/2-0.5,-5,+hh-8])
					cube ([10,10,hh]);
			}
			
			rays=2;
			angle=360/rays;
			for (a=[0:rays-1])
				rotate ([0,0,a*angle])
				translate ([screw+motor_shaft_diameter/2-1,0,3])
				rotate ([0,-90,0])
				{
					for (a=[180])
					rotate ([0,0,a])
					{
						m3_screw(h=screw,cap_side_out=10);
						report_m3(screw=screw);
						report_m3_washer();
					}
					rotate ([0,0,90])
					translate ([0,0,screw-4])
					{
						m3_square_nut(offs=0.4,offsv=0.2);
						report_m3_squarenut();
					}
				}
		}
	}
}

module planetary_body()
{
	od = outer_diameter + 2*planet_diameter;
	difference()
	{
		union()
		{
			pfeilhohlrad (modul=modul
				, zahnzahl=od
				, breite=height
				, randbreite=outer_diameter_add
				, eingriffswinkel=conical
				, schraegungswinkel=-conical_fix
			); 
			cut=4;
			w=NEMA_width(NEMA17);
			
			difference()
			{
				translate ([0,0,-up])
				linear_extrude(block_height)
					polygon(polyRound([
						 [-w/2,-w/2,cut]
						,[w/2,-w/2,cut]
						,[w/2,w/2,cut]
						,[-w/2,w/2,cut]
					],1));
				translate ([0,0,-up-2])
					cylinder (d=od-4,h=25,$fn=100);
				translate ([0,0,0])
					cylinder (d=od+4,h=25,$fn=100);
			}
		}
		
		for (x=[-1,1])
		for (y=[-1,1])
		translate ([NEMA_hole_pitch(NEMA17)/2*x,NEMA_hole_pitch(NEMA17)/2*y,-up-2])
			cylinder (d=3.4,h=25,$fn=40);		
	}
}

module planetary_satellite_washer()
{
	difference()
	{
		cylinder (d=bearing[2]+3,h=planetary_satellite_washer_height,$fn=60);
		translate ([0,0,-0.1])
			cylinder (d=bearing[2]+0.4,h=planetary_satellite_washer_height+0.2,$fn=60);
	}
}

module planetary_satellite()
{
	offs=[0.4,planetary_satellite_washer_height,0];
	bearing_fix_h=0.8;
	difference()
	{
		union()
		{
			intersection()
			{
				difference()
				{
					pfeilrad (modul=modul
								, zahnzahl=planet_diameter
								, breite=height
								, bohrung=screw_diameter
								, eingriffswinkel=conical
								, schraegungswinkel=-conical_fix
							);	
					translate ([0,0,height-offs[1]-offs[2]])
						cylinder (d=planet_diameter*2,h=20,$fn=8);
				}
				translate ([0,0,offs[0]])
				{
					dd=planet_diameter+3;
					cut=1.4;
					translate ([0,0,cut-0.01])
						cylinder (d=dd,h=height-cut*2-sum(offs)+0.02,$fn=80);
					cylinder (d2=dd,d1=dd-cut*2,h=cut,$fn=80);
					translate ([0,0,height-cut-sum(offs)])
						cylinder (d1=dd,d2=dd-cut*2,h=cut,$fn=80);
				}
			}
			translate ([0,0,offs[0]])
				cylinder (d=planetary_rod[0]+planetary_rod[1]*2+1.2*2,h=height-offs[0],$fn=80);//666666
		}
		translate ([0,0,-0.1])
			cylinder (d=planetary_rod[0]+planetary_rod[1]*2,h=height+0.2,$fn=80);//666666
	}
}

module planetary(modul
	, zahnzahl_sonne
	, zahnzahl_planet
	, anzahl_planeten
	, breite
	, randbreite
	, bohrung
	, eingriffswinkel=20
	, schraegungswinkel=0
	, zusammen_gebaut=true
	, optimiert=true)
{

	// Dimensions-Berechnungen
	d_sonne = modul*zahnzahl_sonne;										// Teilkreisdurchmesser Sonne
	d_planet = modul*zahnzahl_planet;									// Teilkreisdurchmesser Planeten
	achsabstand = modul*(zahnzahl_sonne +  zahnzahl_planet) / 2;		// Abstand von Sonnenrad-/Hohlradachse und Planetenachse
	zahnzahl_hohlrad = zahnzahl_sonne + 2*zahnzahl_planet;				// Anzahl der Zähne des Hohlrades
    d_hohlrad = modul*zahnzahl_hohlrad;									// Teilkreisdurchmesser Hohlrad

	drehen = istgerade(zahnzahl_planet);								// Muss das Sonnenrad gedreht werden?
		
	n_max = floor(180/asin(modul*(zahnzahl_planet)/(modul*(zahnzahl_sonne +  zahnzahl_planet))));
																		// Anzahl Planetenräder: höchstens so viele, wie ohne
																		// Überlappung möglich

	// Zeichnung
	rotate([0,0,180/zahnzahl_sonne*drehen])
		planetary_sun();
		//pfeilrad (modul, zahnzahl_sonne, breite, bohrung, eingriffswinkel, -schraegungswinkel, optimiert);		
		// Sonnenrad

	if (zusammen_gebaut){
        if(anzahl_planeten==0){
            list = [ for (n=[2 : 1 : n_max]) if ((((zahnzahl_hohlrad+zahnzahl_sonne)/n)==floor((zahnzahl_hohlrad+zahnzahl_sonne)/n))) n];
            anzahl_planeten = list[0];										// Ermittele Anzahl Planetenräder
             achsabstand = modul*(zahnzahl_sonne + zahnzahl_planet)/2;		// Abstand von Sonnenrad-/Hohlradachse
            for(n=[0:1:anzahl_planeten-1]){
                translate(kugel_zu_kart([achsabstand,90,360/anzahl_planeten*n]))
					rotate([0,0,n*360*d_sonne/d_planet])
						pfeilrad (modul, zahnzahl_planet, breite, bohrung, eingriffswinkel, schraegungswinkel);	// Planetenräder
            }
       }
       else{
            achsabstand = modul*(zahnzahl_sonne + zahnzahl_planet)/2;		// Abstand von Sonnenrad-/Hohlradachse
            for(n=[0:1:anzahl_planeten-1]){
                translate(kugel_zu_kart([achsabstand,90,360/anzahl_planeten*n]))
                rotate([0,0,n*360*d_sonne/(d_planet)])
					planetary_satellite();
                    //pfeilrad (modul, zahnzahl_planet, breite, bohrung, eingriffswinkel, schraegungswinkel);	
					// Planetenräder
            }
		}
	}
	else{
		planetenabstand = zahnzahl_hohlrad*modul/2+randbreite+d_planet;		// Abstand Planeten untereinander
		for(i=[-(anzahl_planeten-1):2:(anzahl_planeten-1)]){
			translate([planetenabstand, d_planet*i,0])
				pfeilrad (modul, zahnzahl_planet, breite, bohrung, eingriffswinkel, schraegungswinkel);	// Planetenräder
		}
	}

	//pfeilhohlrad (modul, zahnzahl_hohlrad, breite, randbreite, eingriffswinkel, schraegungswinkel); // Hohlrad
	planetary_body();
}

module planetary_satellites(modul
	, zahnzahl_sonne
	, zahnzahl_planet
	, anzahl_planeten
	, breite
	, randbreite
	, bohrung
	, eingriffswinkel=20
	, schraegungswinkel=0
	, zusammen_gebaut=true
	, optimiert=true)
{

	// Dimensions-Berechnungen
	d_sonne = modul*zahnzahl_sonne;										// Teilkreisdurchmesser Sonne
	d_planet = modul*zahnzahl_planet;									// Teilkreisdurchmesser Planeten
	achsabstand = modul*(zahnzahl_sonne +  zahnzahl_planet) / 2;		// Abstand von Sonnenrad-/Hohlradachse und Planetenachse
	zahnzahl_hohlrad = zahnzahl_sonne + 2*zahnzahl_planet;				// Anzahl der Zähne des Hohlrades
    d_hohlrad = modul*zahnzahl_hohlrad;									// Teilkreisdurchmesser Hohlrad

	drehen = istgerade(zahnzahl_planet);								// Muss das Sonnenrad gedreht werden?
		
	n_max = floor(180/asin(modul*(zahnzahl_planet)/(modul*(zahnzahl_sonne +  zahnzahl_planet))));
	
	if (zusammen_gebaut)
	{
		achsabstand = modul*(zahnzahl_sonne + zahnzahl_planet)/2;		// Abstand von Sonnenrad-/Hohlradachse
		for(n=[0:1:anzahl_planeten-1])
		{
			translate(kugel_zu_kart([achsabstand,90,360/anzahl_planeten*n]))
			rotate([0,0,n*360*d_sonne/(d_planet)])
				planetary_satellite();
				//pfeilrad (modul, zahnzahl_planet, breite, bohrung, eingriffswinkel, schraegungswinkel);	
				// Planetenräder
		}
	}
}

module test_planetary()
{
	planetary(modul=modul,zahnzahl_sonne=outer_diameter,zahnzahl_planet=planet_diameter,anzahl_planeten=planet_count
					,breite=height,randbreite=outer_diameter_add,bohrung=screw_diameter,eingriffswinkel=conical
					,schraegungswinkel=conical_fix,zusammen_gebaut=true,optimiert=false);
}

module test_planetary_satellites()
{
	planetary_satellites(modul=modul,zahnzahl_sonne=outer_diameter,zahnzahl_planet=planet_diameter,anzahl_planeten=planet_count
					,breite=height,randbreite=outer_diameter_add,bohrung=screw_diameter,eingriffswinkel=conical
					,schraegungswinkel=conical_fix,zusammen_gebaut=true,optimiert=false);
}

translate ([0,0,up-planetary_height])
{
	//test_planetary();
	//planetary_sun();
	//planetary_body();
	//test_planetary_satellites();
	//planetary_satellite();
	
	//planetary_carrier();
	planetary_carrier_bottom();
	//planetary_carrier_top();
	//planetary_top();
	//planetary_satellite_washer();
}	
//translate ([0,0,-planetary_height])NEMA(NEMA17ali, shaft_angle = 0, jst_connector = false);
//color ("yellow") translate ([NEMA_hole_pitch(NEMA17)/2,NEMA_hole_pitch(NEMA17)/2,-2-planetary_height])cylinder (d=3.2,h= 30,$fn=40);