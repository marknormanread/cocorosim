
__includes[
  "user_includes.nls"   ;; files to be included that are specific to a partner's work (and you do not wish to be over-written
                        ;; every time you 'svn up;) should be placed in this file. I recommend that this file is NOT put into
                        ;; the svn, for the same reason. 
                        
  ;; included files that are critical to the simulation. 
  "core/SimCore.nls" 
  "core/Physics_RigidBody.nls"   ;; physics implementing rigid body physics (velocities, and accelerations under force)
  "core/Physics_Rails.nls"       ;; physics implementing the principle that AUVs run on rails (more or less)  
  "OS/OS.nls" 
  "OS/HAL.nls" 
  "hardware/RobotModel.nls" 
  "hardware/Sensors.nls"
  "core/Utils.nls"
]



extensions [profiler] 

breed [AUVs-DUMMY]
breed [AUVs-Jeff]
breed [AUVs-Lily]
breed [basestations-DUMMY]
breed [basestations]
breed [water-surfaces]
breed [black-boxes]


globals [
  ; DO_NOT_CHANGE starts here
  time ; real time in seconds
  ticklength           ;; length of time in seconds that a single tick represents
  patchlength          ;; the length of a patch in meters
  
  experiment-existing? ; flag to confirm if Experiment setup was okay
  robotmodel-existing? ; flag to confirm if Robotmodel setup was okay
  controller-existing? ; flag to confirm if Controller setup was okay
  HAL-existing? ; flag to confirm if HAL setup was okay   
  
  all-robots           ; agentset of all AUVs and base-stations together. 
  all-AUVs             ; agentset of all AUVs (excluding base-stations)
  all-base-stations    ; the agent set of all base-stations (which may be empty, or one). 
  
  number-of-all-robots ; count all-robots; all robots know the number of deployed robots
  tank-perimeter
  ; DO_NOT_CHANGE ends here
  ]
 
  
patches-own [    
  ; DO_NOT_CHANGE starts here
  border? ; glass walls of water tank
  water? ; place where AUVs can be
  ground? ; brown patches on the bottom
  pressure
  patch-ground-distance
  electric-value ;value for the patches that expresses the actual electric-value on this spot
  chemical-concentration ; for "chemcical leak" scenarios.  
  ; DO_NOT_CHANGE ends here  
  ]


turtles-own [
  ; DO_NOT_CHANGE starts here 
  is-robot? ; flag to discriminate other turtles (e.g. water surface, black boxes) from robots. 
            ; This is probably redundant now, but other partners might still be using it. 
            
  is-AUV?   ; flag to discriminate other turtles (e.g. water surface, black boxes) from AUVs
  is-base?  ; flat to discriminate the base station from other turtles (such as water, black boxes, AUVs). 
  
  number-of-sensors
  number-of-actuators
  
  list-of-sensor-descriptions
  list-of-sensor-volt-values
  list-of-sensor-integer-values
  
  list-of-actuator-descriptions
  list-of-actuator-integer-values
  list-of-actuator-volt-values
  
  desired-movement ; inertial vector of the robot, describing its kinetic forward energy

  near-robots
  ; DO_NOT_CHANGE ends here  
  
   
  ]



to startup ; #################################################################################################################################
  ; This procedure is called only once when the model is loaded into NetLogo; everything stays the same, but multiple setups (when using BehaviourSpace) do not lead to excessive RAM usage anymore
  load-shapes-3d "./core/ShapeCore.shape"
  print "3D shapes are loaded"  
end


to setup ; #################################################################################################################################

  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  set ticklength 0.5
  set patchlength 0.1

  set rigid-body-physics true    ;; which physics engine to use, rigid body or "AUV's on rails". Rigid body permits use of currents. 
  
  experiment-setup ; Experiment world is created, Robots are created; Controllers & HAL are initialized
  utils-setup ; Tools for evaluating the experiment are initialized   
  experiment-startup ; called once, after the arena and the robots were created

end


to go ; #################################################################################################################################

  experiment-go-first ; first action before all turtles and patches have acted
  
  OS-update    ;; performs operating system function such operating the HAL and executing controlers.  
  
  ask all-robots ;; following OS-update, which sets updates actuator settings, the physical motion of the robots is performed.
  [
    core-perform-motion ; calculates (preferred) motion and performs physical motion
  ]
  core-update-physics     ; updates things like currents, should they exist
  experiment-update-world ; updates all patches
  utils-update ; updates the evaluation tools
  experiment-go-last ; last action after all turtles and patches have acted
  tick ; this tick is the NetLogo internal counter that is increased at the end of each go procedure.
  set time time + 0.5 ; increase the real time by the right amount; at the moment one tick is 0.5 seconds.

end



to record-movie
  __clear-all-and-reset-ticks
  setup
     
  movie-start "chain-formation.mov"
  movie-set-frame-rate 10
  movie-grab-view ;; show the initial state

  
  repeat 3000
  [
      
    go
    if ticks mod 5 = 0
    [ movie-grab-view ]
  ]
  movie-close
  
end
@#$#@#$#@
GRAPHICS-WINDOW
0
0
245
184
25
25
3.0
1
10
1
1
1
0
1
1
1
-25
25
-25
25
-2
20
1
1
1
ticks
30.0

BUTTON
46
46
133
79
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
160
46
251
79
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
43
98
357
126
use slider in 3D View to increase speed
16
0.0
1

BUTTON
44
165
161
198
NIL
record-movie
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
403
75
575
108
exp-AUVs
exp-AUVs
1
15
9
1
1
NIL
HORIZONTAL

TEXTBOX
404
40
554
68
This is the number of AUVs in the experiment
11
0.0
1

TEXTBOX
181
161
331
231
Don't use this until you have completed an algorithm. It allows you to record a video of your success!
11
0.0
1

@#$#@#$#@
## A NOTE ON DEVELOPING IN COCOROSIM

This is only relevant to you if you are going to write or change code... The documentation on how the simulation works is below. 

The CoCoRoSim directory structure in the svn repository has been amended to follow a traditional svn work-flow. At its highest level, the cocorosim directory contains two directories: "trunk" and "branches". 

The trunk will must ALWAYS contain correct, executable, non-broken code. It will reflect the ongoing development of the simulation, but it must always work. 

Branches can contain specific versions of the simulation, such as releases (should this be required for publications that make use of the simulation), or development activities that can result in broken code. Branches contain copies of trunk code, at certain points in time, and perhaps with certain alterations. So, if you submit a paper with results and you want to keep a copy of the code used to generate them, create a branch, copy the code you used into there, and leave it as it is. Trunk development may continue, but your branch will never change (unless you change it). If you are developing a new controller or robot, then your code will likely have bugs or compilation errors in it from time to time. Please do the development in a branch. You copy the trunk code into a branch and start working on it. When your development is stable, you can re-integrate the branch code into the trunk; the trunk has been updated with your new stable code, and as far as anyone else was concerned, the trunk was never broken. If your development takes a long time, you can update your branch with the latest trunk code, to make sure the system you are working on is the most recent version of cocorosim.

If you have any questions about this system, or need help, please email Mark (at York, mnr101@ohm.york.ac.uk), or consult this online book on svn. http://svnbook.red-bean.com/

## WHAT IS IT?

This is the CoCoRo Simulator "CoCoRoSim". 

It is a basic 3D AUV swarm simulator which is aimed at providing "prove-of-concept" simulations for underwater swarms. Although it includes some basic physics calculations it should never be thought of as a "real-world" simulator for our AUVs. It is organized in the main procedure which also includes 5 different (user) files, each of which aimed at certain partners of the CoCoRo project:

SimCore - this file is the main part of the Simulator (including the movement physics calculations) and should only be changed by UNIGRAZ and UY.

RobotModel - this file describes the robot types (sensors, actuators, etc.) and should only be changed by USTUTT and SSSA. With the information provided here the robots are created and during the runtime the sensors and actuators are updated accordingly.

HAL - The hardware abstraction layer file describes how the raw values of each sensor (usually volts) are being processed into information that is then available for the controller and also how the controller output (usually integers) is processed for the actuators. This file should only be changed by UY.

Utils - This files should be used to write procedures that evaluate the experiment. Here every partner can put procedures that gather the data to investigate the swarm performance etc.

Inside the "user_includes.nls":

Experiment - this file describes the experimental setup (water depth, ground structure, borders, etc.) and also how many AUVs of each type are used in the experiment and where they start. It also describes which changes take place during an experiment (water current, certain events). This file should only be changed by ULB.

Controller - This file describes the program that steers the AUVs during runtime. Please mind that the controller must only use information that "went through" the HAL and not the "raw" sensor values. Every partner can implement his own controller, to work with your own controller we suggest that you use your own local (= not committed per SVN!) "user_includes.nls" file where you can include your own controller by changing the line: __includes["user/ControllerXXX.nls"].


IMPORTANT: To open and change these user files you have to click on the "Procedures" Tab and select one of the included files from the "includes" dropdown-chooser.

To understand how certain procedures in this simulator work, please refer to the "NetLogo Dictionary" that can be found on the navigation bar to the left here: http://ccl.northwestern.edu/netlogo/docs/

## HOW IT WORKS

There are two main procedures:

## I) SETUP 

Executed once when the "setup" button was pressed. 

First, the world is created with all physical properties, then the robots are created and their HAL and controllers are initialized.

## II) GO 

Executed again and again after the "go" button was pressed once, stops when the "go" button is pressed again.

Each simulated second consists of a certain number of "ticks". During every tick each robot 

1) updates its sensors (according to its "list-of-sensors-descriptions") and writes raw sensor values (which are usually Volts ranging from 0 to 5) into its "list-of-sensor-volt-values" array.

2) then uses its HAL to read in these raw sensor values and (as of now) translates them into integer values and writes them into its "list-of-sensor-integer-values" array.

3) then uses its controller to read in these integer values and reacts to them by changing its "list-of-actuator-integer-values" according to its "list-of-actuator-descriptions".

4) then uses its HAL to read in these integer actuator values and (as of now) translates them into raw volt values and writes them into its "list-of-actuator-volt-values" array.

5) then performs its motion in the "core-perform-motion" procedure. For more info see "PHYSICS" below.

After that the world is updated (currents, events, etc.).   
Then all the utilities (functions that help to evaluate the simulation runs) are updated.

## HOW TO USE IT

UNIGRAZ has quickly developed this simulator to be able to show some simulated swarm behaviour (shoaling) at the Kickoff meeting. However, as of now (June 2011) all implemented procedures are very crude and do not represent the real robots to a sufficient level. All implemented procedures and sensor/actuator physics are very basic and should serve as a sort of template for those who will implement their own, more realistic sensors, actuators and so on. UNIGRAZ tried to use everything that should be used in the future CoCoRoSim, so that everyone also knows where his contributions should go and what the interfaces are (where to read/write the sensor and actuator values, which value ranges to expect, etc.).

## IMPORTANT NOTES

You can increase/decrease the simulation speed by using the slider in the 3D View. This slider only decreases/increases the view update frequency which does not affect the simulation. As of now, 1 "tick" represents 0.5 seconds in real time.

Please do not use the NetLogo functions "in-cone" and "in-radius". These functions are extremely inefficient because they were optimized for only verly large swarms of thousands of agents in a 2D world. Instead use our own "AUVs-in-cone" and "own-in-radius" functions which can be found in the Utils.nls.

We distinguish the distance sensors by calling them "active" or "passive" sensors. Even though these sensors can be just one sensor on the real AUV (e.g. blue lught sensor) we split them into two sensors in the simulation for the two modes that this sensor can be used. For us, "passive" means that the AUV only looks for other emitted signals (light or acoustic) whereas an "active" sensors means that the AUV emits a signal and looks for the reflection of this signal. Thus, "passive" sensors are used for perceiving other AUVs and "active" sensors are used for perceiving obstacles and borders which, due to the reflected signal, have only about half the range of the "passive" sensor. As of 27.07.2011 only a border detection has been implemented, obstacle detection is not implemented yet.

The Controller_EMPTY controller uses a border avoidance that, in the long run, results in all AUVs circling the test arena counter-clockwise. This is because when they have very close border patches in front, the AUVs strictly make a left turn. Sometimes, when directly approaching a corner, the AUVs will drive straight into the corner because of their tries to evade the left and right border. In the long run (dozens of hours), a lot of AUVs might get stuck in the corners if the avoidance behaviour is too weak. A physical "bumping" against obstacles should be implemented.

The border senors use global knowledge (=distance to north, east, south and west borders) to calculate the distance. Even though these distances are the limited to the sensor range, this use of global information should not be made. We chose this preliminary solution because if we made the sensing of the border patches similar to the sensing of the near AUVs by using our own in-cone, this would be very time costly as there are much more border patches (ca. 4*70*20=5600) than AUVs (15). 

We have implemented that the AUVs stop instantly (= get stuck) when they are located on a borderpatch or a groundpatch. To turn this off, simply set "stop-on-obstacle-collisions?" to FALSE in the Experiment.nls setup. Controller_EMPTY also has a simply AUV-to-AUV collision avoidance that makes the AUVs stop their thrusters and only make a slow right turn if there is another AUV very close in front. If this fails to avoid a collision (due to momentum), the turtle identifier can be printed in the command center. This can be turned on with the "print-AUV-collisions?" parameter in the Experiment.nls setup. 

NetLogo only uses 1 CPU for the simulation. Multiple CPUs can only be used in the "Tools->BehaviourSpace" mode which can be used for parallel simulations, e.g. parameter sweeps.

For ground detection we have implemented that each water patch knows its distance to the ground and that each AUV can get this information from the waterpatch. This usage of global knowledge should not be made, but we hope that a harware partner can implement a more realistic distance-to-ground sensor because we do not know how such a sensor would look like (sonar?).

As of now there are no transparent patches in NetLogo 3D. This means that all borders, obstacles and (chemical) substances in the water can only be displayed as intransparent cubes. AS of nwo, the south border is invisible for better a better side view. This may change in future versions of NetLogo 3D.

For sensors and actuators, the integer and volt values should be handled the following way: If the sensors perceives nothing, or the actuator is turned off (with the exception of the buoyancy actuator), the values should be 0(V) or 0 (integer). If the sensor perceives the maximum intensity (e.g. AUV or obstacle very close) then the values should be 5(V) or 255 (integer).  The actuators can be used with negative values -2.5(V) or -127 (integer) and positive values up to 2.5(V) or 127 (integer) to allow for downward/upward movement (bouyancy) and forward/backward movement (thrusters).

If you create sliders or choosers etc. on the Interface for evaluation/testing, please remove them before you save and commit because the interface should always only have the "setup" and "go" buttons. Every other parameter should be determined in the according parameters text file (not yet implemented; use golbal variables in the setup functions until then).

Parameters that end with a "?" are boolean flags that indicate if something is turned on (e.g. "stop-on-obstacle-collisions?") or if something is correct (e.g. "experiment-existing?"). Only use boolean values for such parameters, i.e. use TRUE or FALSE instead of "1" or "0".

To quickly inspect the actual internal values of each AUV (e.g. sensor values) during a simulation you can use the 3D interface: Right-click on the AUV -> turtle X -> inspect turtle X. Here you can also click on "watch" turtle, which means that the camera follows this AUV. This helps when evaluating new behaviours and to see if the internal values are as expected.

## HOW TO IMPLEMENT YOUR OWN AUV

As of now there are four possible robot types which are implemented using a group name, or "breeds":

AUVs-DUMMY  
AUVs-USTUTT  
AUVs-SSSA  
base-stations

UNIGRAZ has created a "dummy" AUV using the AUVs-DUMMY breed. Such an AUV is created in the "experiment-setup-robots" procedure where you can change the number of certain AUVs created and also the place where they are created. 

As of now, 2 of these AUVs-DUMMY are created on patches which are "water" and whch are at a certain depth. At creation ("sprout-AUVs-DUMMY") each AUV is first given each AUVs' default values in the "core-set-default-robot-settings" procedure.   
Then it is given the shape "uboot" (which is described in the /core/ShapeCore.shape file) and colored yellow and given a random heading.   
Then it is given its sensors and actuators according to the descriptions in the "robotmodel-add-sensors-DUMMY" and "robotmodel-add-actuators-DUMMY" procedures.

This use of AUVs-DUMMY should serve as some sort of template how to implement your own AUV. Just remember to use your own procedure names (e.g. "robotmodel-add-sensors-USTUTT").

## HOW TO IMPLEMENT YOUR OWN CONTROLLER

To implement you own controller you 

1) first have to copy the "Controller_EMPTY.nls" from the /user directory and rename it to your own controller (e.g. "Controller_ULB_TargetFinder.nls".

2) then you have to change the   
__includes  
in the first line of the "Procedures" Tab to include the   
"Controller_ULB_TargetFinder.nls" instead of (!!) any other "Controller_XXX.nls".

3) then you have to open this controller by clicking on the "Procedures" Tab and selecting the "Controller_ULB_TargetFinder.nls" from the dropdown-chooser.

4) then, in this file, you can use any values from the "list-of-sensor-integer-values" for calculations and use the "controller-actuator-XXX" functions to change the movement of the AUV.   
You can of course implement new "controller-actuator-XXX" functions, but these functions must only change the "list-of-actuator-integer-values" which can only range from 0 to 255!

Never change the "Controller_EMPTY.nls" or any other controller .nls but your own ones!

## THE SHOALING CONTROLLER

To activate this controller you have to change the   
__includes  
in the first line of the "Procedures" Tab to include the   
"Controller_UNIGRAZ_Shoaling.nls" instead of (!!) any other "Controller_XXX.nls".

UNIGRAZ has already implemented a very basic form of shoaling for the AUV swarm.   
To do this we gave each AUV 4 distance sensors to each side of the AUV, each reporting the minimal distance of another near AUV in the cone to each side. This means that each AUV only gets 4 values each tick and uses these values to decide whether there are other AUVs around and if these AUVs are too close or too far away on each side. The AUV then either stops or increases or decreases the values for the two actuators to either stop, turn towards or turn away from certain shoal mates. All these reactions are added up and result in some sort of basic shoaling behaviour (= avoiding collision + staying together + swimming around randomly).

## EXTENDING THE SIMULATOR

Each partner is strongely encouraged to contribute to this simulator.   
Everything that has been developed for the real AUVs should also be represented in this simulator. The amount of realism in doing so should be wisely chosen as not to slow down the simulator too much, but also mind that there should never be "perfect" implementations (e.g. sensor values without noise). 

If, for example, USTUTT invents a new kind of sensor that, for example, can count the number of other AUVs inside a certain range, this sensor should be implemented in the simulator ASAP. If SSSA changes the arrangement of the actuators, this should be reflected in the robotmodel descriptions.

## PHYSICS

UNIGRAZ implemented the basics of underwater-physics. At this time four "kinetic calculations" are implemented: movement in x- and y-direction, buoyancy (including weigth force), flow-resistance and the inertia.

The calculation of the flow-resistance is based on the following formula:

  	( 1 / ( 2 * m ) * cw * density * A * v² )

  m ................ mass of the AUV
  cw .............. drag coefficient
  density ...... density of water
  A ................. reference area
  v ................. velocity
  

The movement in z-direction is controlled via the buoyancy with the input-voltage between 0V and 5V. An input-voltage of 2.5(V) means, that the AUV has the exact water density and thus will stay at the current depth (unless inertia moves it a little).

core-calculate-thrust  
The movement in x- and y-direction is realised via the calculation of two different values: the distance the AUV coveres and the angle of the AUV. To decrease the failure of the simulation the movement is separated into a pre-movement-turn, forward-movement and a post-movement-turn.

core-calculate-physics-movement

## TO-DO LIST

- reading in paramenters from the parameter text files (?).  
- template "utility" procedure for simulation evaluation.  
- procedures for making movie.  
- dynamic physical parameters depending on tick length ("time").  
- easy generation of experiments, e.g. seabed (valleys etc.) and obstacles.  
- more realistic ground and border sensors (they use global info as of now).  
- better corner avoidance bbehaviour (for all controllers)  
- "bumping" physics for collisions with obstacles/borders/other AUVs

## CHANGELOG

25.10.2011 - UNIGRAZ changed "core-calculate-thrust" to allow forward- and backward-motion  
23.10.2011 - UNIGRAZ fixed "AUVs-in-cone"  
07.11.2011 - Merged some UNIGRAZ stuff back into this trunk. Debugged "AUVs-in-cone".  
21.09.2011 - New controller "UNIGRAZ_Shoaling_and_Swarmsize". Uses local broadcasts to estimate swarmsize.  
02.09.2011 - Added, but "commented" (=turned off) code for adding 1 static basestation. Added a new AUV sensor (acoustic distance sensor to basestation) that is needed for confinement (=virtual fence). Added confinement-behaviour to the controller_EMPTY, but it is turned off.  
27.07.2011 - Small improvements, UY fixed "number-of-all-robots" bug; Controller_EMPTY now has simple AUV collision avoidance behaviour; adapted Shoaling controller; More "Important Notes".  
25.07.2011 - Added own "AUVs-in-cone" function that is much faster than the NetLogo "in-cone" function; this drastically improves the simulator speed; added ground sensor and use it in Controller_EMPTY; added border sensor and adapted Controller_EMPTY to have border avoidance and correlated random walk behaviour; changed ground patches to roughly indicate depth through color; changed camera position to face north (heading 0°); adapted UNIGRAZ_Shoaling controller  
19.07.2011 - Added obstacle/border (=active) distance sensor and ground sensor template; added borders on all sides; added "Important Notes" to the documentation.  
14.07.2011 - Testing and benchmarking own in-cone; "own-in-radius" implemented and put into Utils.nls  
27.06.2011 - Simulator released. Own "in-cone" not implemented yet.  
24.06.2011 - Simulator Documentation finished.   
17.06.2011 - Attempt to implement an own, more efficient "in-cone" procedure.  
20.05.2011 - Documentation started.  
10.05.2011 - Early alpha version of the simulator shown at Kickoff meeting.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

base
true
0
Circle -7500403 true true 96 96 108
Rectangle -7500403 true true 60 135 240 165
Rectangle -7500403 true true 135 60 165 240
Circle -7500403 true true 116 -4 67
Circle -7500403 true true 116 236 67
Circle -7500403 true true -4 116 67
Circle -7500403 true true 236 116 67
Circle -2674135 true false 135 15 30
Circle -1184463 true false 15 135 30
Circle -13345367 true false 255 135 30
Circle -13840069 true false 135 255 30
Line -11221820 false 150 45 150 255
Line -11221820 false 45 150 270 150
Line -11221820 false 135 165 165 135
Circle -11221820 false false 129 129 42
Circle -11221820 false false 108 108 85

body
true
0
Circle -7500403 true true 125 27 50
Rectangle -7500403 true true 126 53 175 264
Circle -7500403 true true 127 236 50
Circle -7500403 true true 120 66 62
Circle -7500403 true true 120 188 62

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
true
0
Circle -7500403 false true 0 0 300
Circle -7500403 false true 14 16 266
Circle -7500403 false true 38 38 222

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

mirror
false
0
Rectangle -7500403 false true 75 75 225 225

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

pisa
true
0

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

shark
true
0
Polygon -7500403 true true 153 17 149 12 146 29 145 -1 138 0 119 53 107 110 117 196 133 246 134 261 99 290 112 291 142 281 175 291 185 290 158 260 154 231 164 236 161 220 156 214 160 168 164 91
Polygon -7500403 true true 161 101 166 148 164 163 154 131
Polygon -7500403 true true 108 112 83 128 74 140 76 144 97 141 112 147
Circle -16777216 true false 129 32 12
Line -16777216 false 134 78 150 78
Line -16777216 false 134 83 150 83
Line -16777216 false 134 88 150 88
Polygon -7500403 true true 125 222 118 238 130 237
Polygon -7500403 true true 157 179 161 195 156 199 152 194

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

submarine
true
0
Circle -7500403 true true 120 15 60
Circle -7500403 true true 120 225 60
Rectangle -7500403 true true 120 45 180 255
Circle -7500403 true true 99 84 42
Circle -7500403 true true 159 84 42
Circle -7500403 true true 99 234 42
Circle -7500403 true true 159 234 42
Circle -16777216 true false 105 90 30
Circle -16777216 true false 165 90 30
Circle -16777216 true false 105 240 30
Circle -16777216 true false 165 240 30
Line -2674135 false 150 45 150 270
Line -2674135 false 135 135 135 225
Line -2674135 false 165 135 165 225
Circle -7500403 false true 135 30 30

surface
true
0

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

uboot
true
0

ufo top
false
0
Circle -1 true false 15 15 270
Circle -16777216 false false 15 15 270
Circle -7500403 true true 75 75 150
Circle -16777216 false false 75 75 150
Circle -7500403 true true 60 60 30
Circle -7500403 true true 135 30 30
Circle -7500403 true true 210 60 30
Circle -7500403 true true 240 135 30
Circle -7500403 true true 210 210 30
Circle -7500403 true true 135 240 30
Circle -7500403 true true 60 210 30
Circle -7500403 true true 30 135 30
Circle -16777216 false false 30 135 30
Circle -16777216 false false 60 210 30
Circle -16777216 false false 135 240 30
Circle -16777216 false false 210 210 30
Circle -16777216 false false 240 135 30
Circle -16777216 false false 210 60 30
Circle -16777216 false false 135 30 30
Circle -16777216 false false 60 60 30

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 3D 5.0.1
@#$#@#$#@
setup
watch turtle 0
repeat 500 [ go ]
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Emergent_Taxis_Swarmsize_Distances" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 50 [go]</go>
    <timeLimit steps="200"/>
    <metric>mean-dist</metric>
    <steppedValueSet variable="number-of-AUVs" first="1" step="1" last="20"/>
  </experiment>
  <experiment name="Emergent_Taxis_Swarmsize_Distances_new" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 50 [go]</go>
    <timeLimit steps="200"/>
    <metric>mean-dist</metric>
    <enumeratedValueSet variable="number-of-AUVs">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
