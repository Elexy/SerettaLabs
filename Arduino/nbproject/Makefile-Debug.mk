#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Environment
MKDIR=mkdir
CP=cp
GREP=grep
NM=nm
CCADMIN=CCadmin
RANLIB=ranlib
CC=avr-gcc
CCC=avr-g++
CXX=avr-g++
FC=
AS=avr-as
PROC=proc

# Macros
CND_PLATFORM=Arduino-Linux-x86
CND_CONF=Debug
CND_DISTDIR=dist

# Include project Makefile
include Makefile

# Object Directory
OBJECTDIR=build/${CND_CONF}/${CND_PLATFORM}

# Object Files
OBJECTFILES= \
	${OBJECTDIR}/_ext/1934543511/hm55b_demo.o \
	${OBJECTDIR}/_ext/115974649/sample.o \
	${OBJECTDIR}/_ext/211669895/Voltmeter.o \
	${OBJECTDIR}/_ext/1281413429/blink_ports.o \
	${OBJECTDIR}/_ext/547487057/dnslkup.o \
	${OBJECTDIR}/_ext/852600806/OneWire.o \
	${OBJECTDIR}/_ext/789580810/blink_demo.o \
	${OBJECTDIR}/_ext/2062104086/remoteLcdSimple.o \
	${OBJECTDIR}/_ext/63692127/snapNikon.o \
	${OBJECTDIR}/_ext/582884869/pingPong.o \
	${OBJECTDIR}/_ext/463658012/Panels_v1.o \
	${OBJECTDIR}/_ext/712873253/rtc_demo.o \
	${OBJECTDIR}/_ext/1902336143/bmp085demo.o \
	${OBJECTDIR}/_ext/2105639550/relay.o \
	${OBJECTDIR}/_ext/24577374/combi_demo.o \
	${OBJECTDIR}/_ext/1714345299/PortsRF12.o \
	${OBJECTDIR}/_ext/2095602672/Casita.o \
	${OBJECTDIR}/_ext/174783529/RF12demo.o \
	${OBJECTDIR}/_ext/839454485/expander.o \
	${OBJECTDIR}/_ext/1676417548/etherNodeV1.o \
	${OBJECTDIR}/_ext/1221762584/remoteLcd.o \
	${OBJECTDIR}/_ext/1360930046/lcd.o \
	${OBJECTDIR}/_ext/757478011/thermo_demo.o \
	${OBJECTDIR}/_ext/1110123111/etherNode.o \
	${OBJECTDIR}/_ext/2043702211/crypRecv.o \
	${OBJECTDIR}/_ext/509525655/SMDdemo.o \
	${OBJECTDIR}/_ext/1767390736/uart_demo.o \
	${OBJECTDIR}/_ext/1714345299/PortsBMP085.o \
	${OBJECTDIR}/_ext/2042142686/rgbRemote.o \
	${OBJECTDIR}/_ext/334661687/lux_demo.o \
	${OBJECTDIR}/_ext/1472/rooms.o \
	${OBJECTDIR}/_ext/2044860281/h48c_demo.o \
	${OBJECTDIR}/_ext/918302547/isp_flash.o \
	${OBJECTDIR}/_ext/1038578755/memory_demo.o \
	${OBJECTDIR}/_ext/1584035932/input_demo.o \
	${OBJECTDIR}/_ext/165178468/nunchuk_demo.o \
	${OBJECTDIR}/_ext/1264210944/tempSensors.o \
	${OBJECTDIR}/_ext/1038516071/glcdNode.o \
	${OBJECTDIR}/_ext/313699030/rbbb_server.o \
	${OBJECTDIR}/_ext/277626487/payload.o \
	${OBJECTDIR}/_ext/1814036566/isp_prepare.o \
	${OBJECTDIR}/_ext/1238906640/dsTest.o \
	${OBJECTDIR}/applet/Arduino.o \
	${OBJECTDIR}/_ext/1467641285/radioBlip.o \
	${OBJECTDIR}/_ext/790184199/blink_xmit.o \
	${OBJECTDIR}/_ext/78174252/button_demo.o \
	${OBJECTDIR}/_ext/2105338391/rooms.o \
	${OBJECTDIR}/_ext/643761879/tsl230demo.o \
	${OBJECTDIR}/_ext/1190364858/rf12serial.o \
	${OBJECTDIR}/_ext/1835683373/recv433demo.o \
	${OBJECTDIR}/_ext/1800941064/ookScope.o \
	${OBJECTDIR}/_ext/935235885/livingRoom.o \
	${OBJECTDIR}/_ext/108587176/gravity_demo.o \
	${OBJECTDIR}/_ext/52601745/eemem.o \
	${OBJECTDIR}/_ext/1911062258/temp_ds18.o \
	${OBJECTDIR}/_ext/1902752914/bmp085recv.o \
	${OBJECTDIR}/_ext/789997581/blink_recv.o \
	${OBJECTDIR}/_ext/1714345299/PortsSHT11.o \
	${OBJECTDIR}/_ext/328066322/roomNode.o \
	${OBJECTDIR}/_ext/943080983/isp_capture.o \
	${OBJECTDIR}/_ext/1980993951/fs20demo.o \
	${OBJECTDIR}/_ext/688848764/lcd_demo.o \
	${OBJECTDIR}/_ext/1184179066/ds18b20Par.o \
	${OBJECTDIR}/_ext/547487057/websrv_help_functions.o \
	${OBJECTDIR}/_ext/858162176/qti_demo.o \
	${OBJECTDIR}/_ext/966881593/lcd_demo.o \
	${OBJECTDIR}/_ext/1464910812/heading_demo.o \
	${OBJECTDIR}/_ext/547487057/EtherCard.o \
	${OBJECTDIR}/_ext/1163662022/RF12.o \
	${OBJECTDIR}/_ext/779051245/pir_demo.o \
	${OBJECTDIR}/_ext/547487057/enc28j60.o \
	${OBJECTDIR}/_ext/1783635068/accel2125_demo.o \
	${OBJECTDIR}/_ext/1175993748/ppt.o \
	${OBJECTDIR}/_ext/216475102/sht11demo.o \
	${OBJECTDIR}/_ext/547487057/ip_arp_udp_tcp.o \
	${OBJECTDIR}/_ext/1108752800/etherNode.o \
	${OBJECTDIR}/_ext/94269941/relay_demo.o \
	${OBJECTDIR}/_ext/1309236602/packetBuf.o \
	${OBJECTDIR}/_ext/1714345299/PortsLCD.o \
	${OBJECTDIR}/_ext/546976305/kaku_demo.o \
	${OBJECTDIR}/_ext/951619913/output_stepper.o \
	${OBJECTDIR}/_ext/1714345299/Ports.o \
	${OBJECTDIR}/main.o \
	${OBJECTDIR}/_ext/2071537574/dcf77demo.o \
	${OBJECTDIR}/_ext/381317857/powerdown_demo.o \
	${OBJECTDIR}/_ext/1259877238/isp_repair.o \
	${OBJECTDIR}/_ext/2043672097/crypSend.o \
	${OBJECTDIR}/_ext/875643124/dimmer_demo.o \
	${OBJECTDIR}/_ext/1163662022/RF12sio.o \
	${OBJECTDIR}/_ext/1707157574/blinker.o \
	${OBJECTDIR}/_ext/1204213830/rf12stream.o


# C Compiler Flags
CFLAGS=

# CC Compiler Flags
CCFLAGS=
CXXFLAGS=

# Fortran Compiler Flags
FFLAGS=

# Assembler Flags
ASFLAGS=

# Link Libraries and Options
LDLIBSOPTIONS=

# Build Targets
.build-conf: ${BUILD_SUBPROJECTS}
	"${MAKE}"  -f nbproject/Makefile-Debug.mk dist/Debug/Arduino-Linux-x86/arduino

dist/Debug/Arduino-Linux-x86/arduino: ${OBJECTFILES}
	${MKDIR} -p dist/Debug/Arduino-Linux-x86
	${LINK.cc} -o ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/arduino ${OBJECTFILES} ${LDLIBSOPTIONS} 

${OBJECTDIR}/_ext/1934543511/hm55b_demo.o: ../libraries/Ports/examples/hm55b_demo/hm55b_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1934543511
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1934543511/hm55b_demo.o ../libraries/Ports/examples/hm55b_demo/hm55b_demo.pde

${OBJECTDIR}/_ext/115974649/sample.o: ../libraries/OneWire/examples/sample/sample.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/115974649
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/115974649/sample.o ../libraries/OneWire/examples/sample/sample.pde

${OBJECTDIR}/_ext/211669895/Voltmeter.o: ../Voltmeter/Voltmeter.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/211669895
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/211669895/Voltmeter.o ../Voltmeter/Voltmeter.pde

${OBJECTDIR}/_ext/1281413429/blink_ports.o: ../libraries/Ports/examples/blink_ports/blink_ports.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1281413429
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1281413429/blink_ports.o ../libraries/Ports/examples/blink_ports/blink_ports.pde

${OBJECTDIR}/_ext/547487057/dnslkup.o: ../libraries/EtherCard/dnslkup.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/547487057
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/547487057/dnslkup.o ../libraries/EtherCard/dnslkup.cpp

${OBJECTDIR}/_ext/852600806/OneWire.o: ../libraries/OneWire/OneWire.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/852600806
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/852600806/OneWire.o ../libraries/OneWire/OneWire.cpp

${OBJECTDIR}/_ext/789580810/blink_demo.o: ../libraries/Ports/examples/blink_demo/blink_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/789580810
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/789580810/blink_demo.o ../libraries/Ports/examples/blink_demo/blink_demo.pde

${OBJECTDIR}/_ext/2062104086/remoteLcdSimple.o: ../remoteLcdSimple/remoteLcdSimple.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/2062104086
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/2062104086/remoteLcdSimple.o ../remoteLcdSimple/remoteLcdSimple.pde

${OBJECTDIR}/_ext/63692127/snapNikon.o: ../libraries/Ports/examples/snapNikon/snapNikon.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/63692127
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/63692127/snapNikon.o ../libraries/Ports/examples/snapNikon/snapNikon.pde

${OBJECTDIR}/_ext/582884869/pingPong.o: ../libraries/RF12/examples/pingPong/pingPong.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/582884869
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/582884869/pingPong.o ../libraries/RF12/examples/pingPong/pingPong.pde

${OBJECTDIR}/_ext/463658012/Panels_v1.o: ../Panels_v1/Panels_v1.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/463658012
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/463658012/Panels_v1.o ../Panels_v1/Panels_v1.pde

${OBJECTDIR}/_ext/712873253/rtc_demo.o: ../libraries/Ports/examples/rtc_demo/rtc_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/712873253
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/712873253/rtc_demo.o ../libraries/Ports/examples/rtc_demo/rtc_demo.pde

${OBJECTDIR}/_ext/1902336143/bmp085demo.o: ../libraries/Ports/examples/bmp085demo/bmp085demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1902336143
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1902336143/bmp085demo.o ../libraries/Ports/examples/bmp085demo/bmp085demo.pde

${OBJECTDIR}/_ext/2105639550/relay.o: ../relay/relay.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/2105639550
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/2105639550/relay.o ../relay/relay.pde

${OBJECTDIR}/_ext/24577374/combi_demo.o: ../libraries/Ports/examples/combi_demo/combi_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/24577374
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/24577374/combi_demo.o ../libraries/Ports/examples/combi_demo/combi_demo.pde

${OBJECTDIR}/_ext/1714345299/PortsRF12.o: ../libraries/Ports/PortsRF12.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1714345299
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1714345299/PortsRF12.o ../libraries/Ports/PortsRF12.cpp

${OBJECTDIR}/_ext/2095602672/Casita.o: ../Casita/Casita.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/2095602672
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/2095602672/Casita.o ../Casita/Casita.pde

${OBJECTDIR}/_ext/174783529/RF12demo.o: ../libraries/RF12/examples/RF12demo/RF12demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/174783529
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/174783529/RF12demo.o ../libraries/RF12/examples/RF12demo/RF12demo.pde

${OBJECTDIR}/_ext/839454485/expander.o: ../libraries/Ports/examples/expander/expander.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/839454485
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/839454485/expander.o ../libraries/Ports/examples/expander/expander.pde

${OBJECTDIR}/_ext/1676417548/etherNodeV1.o: ../etherNodeV1/etherNodeV1.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1676417548
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1676417548/etherNodeV1.o ../etherNodeV1/etherNodeV1.pde

${OBJECTDIR}/_ext/1221762584/remoteLcd.o: ../remoteLcd/remoteLcd.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1221762584
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1221762584/remoteLcd.o ../remoteLcd/remoteLcd.pde

${OBJECTDIR}/_ext/1360930046/lcd.o: ../lcd/lcd.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1360930046
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1360930046/lcd.o ../lcd/lcd.pde

${OBJECTDIR}/_ext/757478011/thermo_demo.o: ../libraries/Ports/examples/thermo_demo/thermo_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/757478011
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/757478011/thermo_demo.o ../libraries/Ports/examples/thermo_demo/thermo_demo.pde

${OBJECTDIR}/_ext/1110123111/etherNode.o: ../etherNode/etherNode.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1110123111
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1110123111/etherNode.o ../etherNode/etherNode.pde

${OBJECTDIR}/_ext/2043702211/crypRecv.o: ../libraries/RF12/examples/crypRecv/crypRecv.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/2043702211
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/2043702211/crypRecv.o ../libraries/RF12/examples/crypRecv/crypRecv.pde

${OBJECTDIR}/_ext/509525655/SMDdemo.o: ../libraries/Ports/examples/SMDdemo/SMDdemo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/509525655
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/509525655/SMDdemo.o ../libraries/Ports/examples/SMDdemo/SMDdemo.pde

${OBJECTDIR}/_ext/1767390736/uart_demo.o: ../libraries/Ports/examples/uart_demo/uart_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1767390736
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1767390736/uart_demo.o ../libraries/Ports/examples/uart_demo/uart_demo.pde

${OBJECTDIR}/_ext/1714345299/PortsBMP085.o: ../libraries/Ports/PortsBMP085.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1714345299
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1714345299/PortsBMP085.o ../libraries/Ports/PortsBMP085.cpp

${OBJECTDIR}/_ext/2042142686/rgbRemote.o: ../libraries/RF12/examples/rgbRemote/rgbRemote.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/2042142686
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/2042142686/rgbRemote.o ../libraries/RF12/examples/rgbRemote/rgbRemote.pde

${OBJECTDIR}/_ext/334661687/lux_demo.o: ../libraries/Ports/examples/lux_demo/lux_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/334661687
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/334661687/lux_demo.o ../libraries/Ports/examples/lux_demo/lux_demo.pde

${OBJECTDIR}/_ext/1472/rooms.o: ../rooms.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/rooms.o ../rooms.pde

${OBJECTDIR}/_ext/2044860281/h48c_demo.o: ../libraries/Ports/examples/h48c_demo/h48c_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/2044860281
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/2044860281/h48c_demo.o ../libraries/Ports/examples/h48c_demo/h48c_demo.pde

${OBJECTDIR}/_ext/918302547/isp_flash.o: ../libraries/Ports/examples/isp_flash/isp_flash.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/918302547
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/918302547/isp_flash.o ../libraries/Ports/examples/isp_flash/isp_flash.pde

${OBJECTDIR}/_ext/1038578755/memory_demo.o: ../libraries/Ports/examples/memory_demo/memory_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1038578755
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1038578755/memory_demo.o ../libraries/Ports/examples/memory_demo/memory_demo.pde

${OBJECTDIR}/_ext/1584035932/input_demo.o: ../libraries/Ports/examples/input_demo/input_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1584035932
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1584035932/input_demo.o ../libraries/Ports/examples/input_demo/input_demo.pde

${OBJECTDIR}/_ext/165178468/nunchuk_demo.o: ../libraries/Ports/examples/nunchuk_demo/nunchuk_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/165178468
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/165178468/nunchuk_demo.o ../libraries/Ports/examples/nunchuk_demo/nunchuk_demo.pde

${OBJECTDIR}/_ext/1264210944/tempSensors.o: ../libraries/tempSensors/tempSensors.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1264210944
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1264210944/tempSensors.o ../libraries/tempSensors/tempSensors.cpp

${OBJECTDIR}/_ext/1038516071/glcdNode.o: ../libraries/RF12/examples/glcdNode/glcdNode.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1038516071
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1038516071/glcdNode.o ../libraries/RF12/examples/glcdNode/glcdNode.pde

${OBJECTDIR}/_ext/313699030/rbbb_server.o: ../libraries/EtherCard/examples/rbbb_server/rbbb_server.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/313699030
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/313699030/rbbb_server.o ../libraries/EtherCard/examples/rbbb_server/rbbb_server.pde

${OBJECTDIR}/_ext/277626487/payload.o: ../libraries/payload/payload.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/277626487
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/277626487/payload.o ../libraries/payload/payload.cpp

${OBJECTDIR}/_ext/1814036566/isp_prepare.o: ../libraries/Ports/examples/isp_prepare/isp_prepare.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1814036566
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1814036566/isp_prepare.o ../libraries/Ports/examples/isp_prepare/isp_prepare.pde

${OBJECTDIR}/_ext/1238906640/dsTest.o: ../dsTest/dsTest.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1238906640
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1238906640/dsTest.o ../dsTest/dsTest.pde

${OBJECTDIR}/applet/Arduino.o: applet/Arduino.cpp 
	${MKDIR} -p ${OBJECTDIR}/applet
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/applet/Arduino.o applet/Arduino.cpp

${OBJECTDIR}/_ext/1467641285/radioBlip.o: ../libraries/RF12/examples/radioBlip/radioBlip.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1467641285
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1467641285/radioBlip.o ../libraries/RF12/examples/radioBlip/radioBlip.pde

${OBJECTDIR}/_ext/790184199/blink_xmit.o: ../libraries/Ports/examples/blink_xmit/blink_xmit.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/790184199
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/790184199/blink_xmit.o ../libraries/Ports/examples/blink_xmit/blink_xmit.pde

${OBJECTDIR}/_ext/78174252/button_demo.o: ../libraries/Ports/examples/button_demo/button_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/78174252
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/78174252/button_demo.o ../libraries/Ports/examples/button_demo/button_demo.pde

${OBJECTDIR}/_ext/2105338391/rooms.o: ../rooms/rooms.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/2105338391
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/2105338391/rooms.o ../rooms/rooms.pde

${OBJECTDIR}/_ext/643761879/tsl230demo.o: ../libraries/Ports/examples/tsl230demo/tsl230demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/643761879
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/643761879/tsl230demo.o ../libraries/Ports/examples/tsl230demo/tsl230demo.pde

${OBJECTDIR}/_ext/1190364858/rf12serial.o: ../libraries/RF12/examples/rf12serial/rf12serial.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1190364858
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1190364858/rf12serial.o ../libraries/RF12/examples/rf12serial/rf12serial.pde

${OBJECTDIR}/_ext/1835683373/recv433demo.o: ../libraries/Ports/examples/recv433demo/recv433demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1835683373
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1835683373/recv433demo.o ../libraries/Ports/examples/recv433demo/recv433demo.pde

${OBJECTDIR}/_ext/1800941064/ookScope.o: ../ookScope/ookScope.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1800941064
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1800941064/ookScope.o ../ookScope/ookScope.pde

${OBJECTDIR}/_ext/935235885/livingRoom.o: ../livingRoom/livingRoom.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/935235885
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/935235885/livingRoom.o ../livingRoom/livingRoom.pde

${OBJECTDIR}/_ext/108587176/gravity_demo.o: ../libraries/Ports/examples/gravity_demo/gravity_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/108587176
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/108587176/gravity_demo.o ../libraries/Ports/examples/gravity_demo/gravity_demo.pde

${OBJECTDIR}/_ext/52601745/eemem.o: ../libraries/Ports/examples/eemem/eemem.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/52601745
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/52601745/eemem.o ../libraries/Ports/examples/eemem/eemem.pde

${OBJECTDIR}/_ext/1911062258/temp_ds18.o: ../temp_ds18/temp_ds18.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1911062258
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1911062258/temp_ds18.o ../temp_ds18/temp_ds18.pde

${OBJECTDIR}/_ext/1902752914/bmp085recv.o: ../libraries/Ports/examples/bmp085recv/bmp085recv.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1902752914
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1902752914/bmp085recv.o ../libraries/Ports/examples/bmp085recv/bmp085recv.pde

${OBJECTDIR}/_ext/789997581/blink_recv.o: ../libraries/Ports/examples/blink_recv/blink_recv.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/789997581
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/789997581/blink_recv.o ../libraries/Ports/examples/blink_recv/blink_recv.pde

${OBJECTDIR}/_ext/1714345299/PortsSHT11.o: ../libraries/Ports/PortsSHT11.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1714345299
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1714345299/PortsSHT11.o ../libraries/Ports/PortsSHT11.cpp

${OBJECTDIR}/_ext/328066322/roomNode.o: ../libraries/RF12/examples/roomNode/roomNode.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/328066322
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/328066322/roomNode.o ../libraries/RF12/examples/roomNode/roomNode.pde

${OBJECTDIR}/_ext/943080983/isp_capture.o: ../libraries/Ports/examples/isp_capture/isp_capture.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/943080983
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/943080983/isp_capture.o ../libraries/Ports/examples/isp_capture/isp_capture.pde

${OBJECTDIR}/_ext/1980993951/fs20demo.o: ../libraries/RF12/examples/fs20demo/fs20demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1980993951
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1980993951/fs20demo.o ../libraries/RF12/examples/fs20demo/fs20demo.pde

${OBJECTDIR}/_ext/688848764/lcd_demo.o: ../lcd_demo/lcd_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/688848764
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/688848764/lcd_demo.o ../lcd_demo/lcd_demo.pde

${OBJECTDIR}/_ext/1184179066/ds18b20Par.o: ../ds18b20Par/ds18b20Par.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1184179066
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1184179066/ds18b20Par.o ../ds18b20Par/ds18b20Par.pde

${OBJECTDIR}/_ext/547487057/websrv_help_functions.o: ../libraries/EtherCard/websrv_help_functions.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/547487057
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/547487057/websrv_help_functions.o ../libraries/EtherCard/websrv_help_functions.cpp

${OBJECTDIR}/_ext/858162176/qti_demo.o: ../libraries/Ports/examples/qti_demo/qti_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/858162176
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/858162176/qti_demo.o ../libraries/Ports/examples/qti_demo/qti_demo.pde

${OBJECTDIR}/_ext/966881593/lcd_demo.o: ../libraries/Ports/examples/lcd_demo/lcd_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/966881593
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/966881593/lcd_demo.o ../libraries/Ports/examples/lcd_demo/lcd_demo.pde

${OBJECTDIR}/_ext/1464910812/heading_demo.o: ../libraries/Ports/examples/heading_demo/heading_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1464910812
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1464910812/heading_demo.o ../libraries/Ports/examples/heading_demo/heading_demo.pde

${OBJECTDIR}/_ext/547487057/EtherCard.o: ../libraries/EtherCard/EtherCard.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/547487057
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/547487057/EtherCard.o ../libraries/EtherCard/EtherCard.cpp

${OBJECTDIR}/_ext/1163662022/RF12.o: ../libraries/RF12/RF12.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1163662022
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1163662022/RF12.o ../libraries/RF12/RF12.cpp

${OBJECTDIR}/_ext/779051245/pir_demo.o: ../libraries/Ports/examples/pir_demo/pir_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/779051245
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/779051245/pir_demo.o ../libraries/Ports/examples/pir_demo/pir_demo.pde

${OBJECTDIR}/_ext/547487057/enc28j60.o: ../libraries/EtherCard/enc28j60.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/547487057
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/547487057/enc28j60.o ../libraries/EtherCard/enc28j60.cpp

${OBJECTDIR}/_ext/1783635068/accel2125_demo.o: ../libraries/Ports/examples/accel2125_demo/accel2125_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1783635068
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1783635068/accel2125_demo.o ../libraries/Ports/examples/accel2125_demo/accel2125_demo.pde

${OBJECTDIR}/_ext/1175993748/ppt.o: ../mpptControler/ppt.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1175993748
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1175993748/ppt.o ../mpptControler/ppt.pde

${OBJECTDIR}/_ext/216475102/sht11demo.o: ../libraries/Ports/examples/sht11demo/sht11demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/216475102
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/216475102/sht11demo.o ../libraries/Ports/examples/sht11demo/sht11demo.pde

${OBJECTDIR}/_ext/547487057/ip_arp_udp_tcp.o: ../libraries/EtherCard/ip_arp_udp_tcp.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/547487057
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/547487057/ip_arp_udp_tcp.o ../libraries/EtherCard/ip_arp_udp_tcp.cpp

${OBJECTDIR}/_ext/1108752800/etherNode.o: ../libraries/EtherCard/examples/etherNode/etherNode.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1108752800
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1108752800/etherNode.o ../libraries/EtherCard/examples/etherNode/etherNode.pde

${OBJECTDIR}/_ext/94269941/relay_demo.o: ../libraries/Ports/examples/relay_demo/relay_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/94269941
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/94269941/relay_demo.o ../libraries/Ports/examples/relay_demo/relay_demo.pde

${OBJECTDIR}/_ext/1309236602/packetBuf.o: ../libraries/RF12/examples/packetBuf/packetBuf.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1309236602
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1309236602/packetBuf.o ../libraries/RF12/examples/packetBuf/packetBuf.pde

${OBJECTDIR}/_ext/1714345299/PortsLCD.o: ../libraries/Ports/PortsLCD.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1714345299
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1714345299/PortsLCD.o ../libraries/Ports/PortsLCD.cpp

${OBJECTDIR}/_ext/546976305/kaku_demo.o: ../libraries/RF12/examples/kaku_demo/kaku_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/546976305
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/546976305/kaku_demo.o ../libraries/RF12/examples/kaku_demo/kaku_demo.pde

${OBJECTDIR}/_ext/951619913/output_stepper.o: ../libraries/Ports/examples/output_stepper/output_stepper.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/951619913
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/951619913/output_stepper.o ../libraries/Ports/examples/output_stepper/output_stepper.pde

${OBJECTDIR}/_ext/1714345299/Ports.o: ../libraries/Ports/Ports.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1714345299
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1714345299/Ports.o ../libraries/Ports/Ports.cpp

${OBJECTDIR}/main.o: main.pde 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/main.o main.pde

${OBJECTDIR}/_ext/2071537574/dcf77demo.o: ../libraries/Ports/examples/dcf77demo/dcf77demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/2071537574
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/2071537574/dcf77demo.o ../libraries/Ports/examples/dcf77demo/dcf77demo.pde

${OBJECTDIR}/_ext/381317857/powerdown_demo.o: ../libraries/Ports/examples/powerdown_demo/powerdown_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/381317857
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/381317857/powerdown_demo.o ../libraries/Ports/examples/powerdown_demo/powerdown_demo.pde

${OBJECTDIR}/_ext/1259877238/isp_repair.o: ../libraries/Ports/examples/isp_repair/isp_repair.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1259877238
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1259877238/isp_repair.o ../libraries/Ports/examples/isp_repair/isp_repair.pde

${OBJECTDIR}/_ext/2043672097/crypSend.o: ../libraries/RF12/examples/crypSend/crypSend.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/2043672097
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/2043672097/crypSend.o ../libraries/RF12/examples/crypSend/crypSend.pde

${OBJECTDIR}/_ext/875643124/dimmer_demo.o: ../libraries/Ports/examples/dimmer_demo/dimmer_demo.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/875643124
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/875643124/dimmer_demo.o ../libraries/Ports/examples/dimmer_demo/dimmer_demo.pde

${OBJECTDIR}/_ext/1163662022/RF12sio.o: ../libraries/RF12/RF12sio.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1163662022
	${RM} $@.d
	$(COMPILE.cc) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1163662022/RF12sio.o ../libraries/RF12/RF12sio.cpp

${OBJECTDIR}/_ext/1707157574/blinker.o: ../blinker/blinker.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1707157574
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1707157574/blinker.o ../blinker/blinker.pde

${OBJECTDIR}/_ext/1204213830/rf12stream.o: ../libraries/RF12/examples/rf12stream/rf12stream.pde 
	${MKDIR} -p ${OBJECTDIR}/_ext/1204213830
	${RM} $@.d
	$(COMPILE.c) -g -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1204213830/rf12stream.o ../libraries/RF12/examples/rf12stream/rf12stream.pde

# Subprojects
.build-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r build/Debug
	${RM} dist/Debug/Arduino-Linux-x86/arduino

# Subprojects
.clean-subprojects:

# Enable dependency checking
.dep.inc: .depcheck-impl

include .dep.inc
