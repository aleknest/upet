is_reported=true;

module deb (s)
{
	if (is_reported)
	{
		//echo (str("<b style='color:green'>",s));
		echo (s);
	}
}

module report(s)
{
	deb(s);
}

module report_slot(h)
{
	deb(str("4020 slot: ",h,"mm"));
}

module report_m3_hexnut()
{
	deb(str("M3 nut (hex)"));
}

module report_m3_squarenut()
{
	deb(str("M3 nut (thin square)"));
}

module report_m3(screw)
{
	deb(str("M3x",screw," DIN912"));
}

module report_m3_washer()
{
	deb(str("M3 washer"));
}

module report_m4_washer()
{
	deb(str("M4 washer"));
}

module report_nema17()
{
	deb(str("Nema 17 motor"));
}

module report_optical_switch()
{
	deb(str("optical switch"));
}

module report_m5_screw_only(screw)
{
	deb(str("M5x",screw," DIN912"));
}

module report_m5_screw(screw)
{
	report_m5_screw_only(screw=screw);
	report_m5_washer();
}

module report_m5_nut()
{
	deb(str("M5 nut"));
}

module report_m5_washer()
{
	deb(str("M5 washer"));
}

module report_m5_bolt(screw)
{
	deb(str("M5x",screw," bolt"));
}

module report_m5_point()
{
	report_m5_screw(10);
	deb(str("M5 t-slot nut"));
}

module report_m3_slot_nut()
{
	deb(str("M3 t-slot nut"));
}
