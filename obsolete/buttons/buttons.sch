EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Switch:SW_SPST SW1
U 1 1 628674E4
P 2300 1800
F 0 "SW1" H 2300 2035 50  0000 C CNN
F 1 "SW_LEFT" H 2300 1944 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 2300 1800 50  0001 C CNN
F 3 "~" H 2300 1800 50  0001 C CNN
	1    2300 1800
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_SPST SW2
U 1 1 62867C05
P 2300 2200
F 0 "SW2" H 2300 2435 50  0000 C CNN
F 1 "SW_RIGHT" H 2300 2344 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 2300 2200 50  0001 C CNN
F 3 "~" H 2300 2200 50  0001 C CNN
	1    2300 2200
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_SPST SW3
U 1 1 628684F0
P 2300 2600
F 0 "SW3" H 2300 2835 50  0000 C CNN
F 1 "SW_UP" H 2300 2744 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 2300 2600 50  0001 C CNN
F 3 "~" H 2300 2600 50  0001 C CNN
	1    2300 2600
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_SPST SW4
U 1 1 62868774
P 2300 3000
F 0 "SW4" H 2300 3235 50  0000 C CNN
F 1 "SW_DOWN" H 2300 3144 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 2300 3000 50  0001 C CNN
F 3 "~" H 2300 3000 50  0001 C CNN
	1    2300 3000
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_SPST SW5
U 1 1 628689D6
P 2300 3400
F 0 "SW5" H 2300 3635 50  0000 C CNN
F 1 "SW_CENTER" H 2300 3544 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 2300 3400 50  0001 C CNN
F 3 "~" H 2300 3400 50  0001 C CNN
	1    2300 3400
	1    0    0    -1  
$EndComp
$Comp
L Device:R R1
U 1 1 628693E5
P 2850 1800
F 0 "R1" V 2643 1800 50  0000 C CNN
F 1 "470" V 2734 1800 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad1.05x0.95mm_HandSolder" V 2780 1800 50  0001 C CNN
F 3 "~" H 2850 1800 50  0001 C CNN
	1    2850 1800
	0    1    1    0   
$EndComp
Wire Wire Line
	2100 1800 1650 1800
Wire Wire Line
	1650 1800 1650 2200
$Comp
L power:GND #PWR0101
U 1 1 6286A85B
P 1650 3700
F 0 "#PWR0101" H 1650 3450 50  0001 C CNN
F 1 "GND" H 1655 3527 50  0000 C CNN
F 2 "" H 1650 3700 50  0001 C CNN
F 3 "" H 1650 3700 50  0001 C CNN
	1    1650 3700
	1    0    0    -1  
$EndComp
Wire Wire Line
	2100 2200 1650 2200
Connection ~ 1650 2200
Wire Wire Line
	1650 2200 1650 2600
Wire Wire Line
	2100 2600 1650 2600
Connection ~ 1650 2600
Wire Wire Line
	1650 2600 1650 3000
Wire Wire Line
	2100 3000 1650 3000
Connection ~ 1650 3000
Wire Wire Line
	1650 3000 1650 3400
Wire Wire Line
	2100 3400 1650 3400
Connection ~ 1650 3400
Wire Wire Line
	1650 3400 1650 3700
$Comp
L Device:R R2
U 1 1 62870557
P 2850 2200
F 0 "R2" V 2643 2200 50  0000 C CNN
F 1 "4.7K" V 2734 2200 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad1.05x0.95mm_HandSolder" V 2780 2200 50  0001 C CNN
F 3 "~" H 2850 2200 50  0001 C CNN
	1    2850 2200
	0    1    1    0   
$EndComp
$Comp
L Device:R R3
U 1 1 62870875
P 2850 2600
F 0 "R3" V 2643 2600 50  0000 C CNN
F 1 "10K" V 2734 2600 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad1.05x0.95mm_HandSolder" V 2780 2600 50  0001 C CNN
F 3 "~" H 2850 2600 50  0001 C CNN
	1    2850 2600
	0    1    1    0   
$EndComp
$Comp
L Device:R R4
U 1 1 62870A75
P 2850 3000
F 0 "R4" V 2643 3000 50  0000 C CNN
F 1 "1K" V 2734 3000 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad1.05x0.95mm_HandSolder" V 2780 3000 50  0001 C CNN
F 3 "~" H 2850 3000 50  0001 C CNN
	1    2850 3000
	0    1    1    0   
$EndComp
$Comp
L Device:R R5
U 1 1 62870E51
P 2850 3400
F 0 "R5" V 2643 3400 50  0000 C CNN
F 1 "2.2K" V 2734 3400 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad1.05x0.95mm_HandSolder" V 2780 3400 50  0001 C CNN
F 3 "~" H 2850 3400 50  0001 C CNN
	1    2850 3400
	0    1    1    0   
$EndComp
Wire Wire Line
	2500 1800 2700 1800
Wire Wire Line
	2500 2200 2700 2200
Wire Wire Line
	2500 2600 2700 2600
Wire Wire Line
	2500 3000 2700 3000
Wire Wire Line
	2500 3400 2700 3400
$Comp
L Device:R R6
U 1 1 62872EF1
P 3000 1400
F 0 "R6" V 2793 1400 50  0000 C CNN
F 1 "4.7K" V 2884 1400 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad1.05x0.95mm_HandSolder" V 2930 1400 50  0001 C CNN
F 3 "~" H 3000 1400 50  0001 C CNN
	1    3000 1400
	-1   0    0    1   
$EndComp
Wire Wire Line
	3000 1550 3000 1800
Wire Wire Line
	3000 1800 3000 2200
Connection ~ 3000 1800
Connection ~ 3000 2200
Wire Wire Line
	3000 2200 3000 2600
Connection ~ 3000 2600
Wire Wire Line
	3000 2600 3000 3000
Connection ~ 3000 3000
Wire Wire Line
	3000 3000 3000 3400
$Comp
L power:VCC #PWR0102
U 1 1 62874D36
P 3000 1050
F 0 "#PWR0102" H 3000 900 50  0001 C CNN
F 1 "VCC" H 3017 1223 50  0000 C CNN
F 2 "" H 3000 1050 50  0001 C CNN
F 3 "" H 3000 1050 50  0001 C CNN
	1    3000 1050
	1    0    0    -1  
$EndComp
Wire Wire Line
	3000 1050 3000 1250
$Comp
L Connector_Generic:Conn_01x03 J1
U 1 1 6288F7CA
P 3950 1700
F 0 "J1" H 4030 1742 50  0000 L CNN
F 1 "Conn_01x03" H 4030 1651 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Vertical" H 3950 1700 50  0001 C CNN
F 3 "~" H 3950 1700 50  0001 C CNN
	1    3950 1700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0103
U 1 1 62893383
P 3600 1450
F 0 "#PWR0103" H 3600 1200 50  0001 C CNN
F 1 "GND" H 3605 1277 50  0000 C CNN
F 2 "" H 3600 1450 50  0001 C CNN
F 3 "" H 3600 1450 50  0001 C CNN
	1    3600 1450
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR0104
U 1 1 62895436
P 3600 1700
F 0 "#PWR0104" H 3600 1550 50  0001 C CNN
F 1 "VCC" H 3617 1873 50  0000 C CNN
F 2 "" H 3600 1700 50  0001 C CNN
F 3 "" H 3600 1700 50  0001 C CNN
	1    3600 1700
	0    -1   -1   0   
$EndComp
Wire Wire Line
	3750 1700 3600 1700
Text GLabel 3550 1900 0    50   Input ~ 0
Button
Wire Wire Line
	3550 1900 3650 1900
Wire Wire Line
	3650 1900 3650 1800
Wire Wire Line
	3650 1800 3750 1800
Wire Wire Line
	3600 1450 3650 1450
Wire Wire Line
	3650 1450 3650 1600
Wire Wire Line
	3650 1600 3750 1600
Text GLabel 3350 2600 2    50   Input ~ 0
Button
Wire Wire Line
	3000 2600 3350 2600
$EndSCHEMATC