# BiStatic Cloud Point Generation for Multi Target Tracking

Run BiStatic2DCloudPointGeneration.m 
Cloud Point for Bistatic Array Radar
![Alt Simulation Output](https://github.com/UL-Radar-Group/BiStaticCloudPoint/blob/main/Output.PNG?raw=true "Output")

# Input example:
### User inputs : Transmitter - Receiver Position
sim.TX_Position = [-1 1.3];

sim.RX_Position = [2.1 -1.2];
### User inputs : Transmitter - Receiver Elements
sim.RX_N = 8;
sim.TX_N = 6;
sim.setTRXPos(1,0,0);
### User inputs : Ground Truth Target Points 
DownSampling = 150;

humanScale = .3;

sim.readHumanTopview('human.png',DownSampling,humanScale);

### User inputs : Target Movement
k=1;

sim.targets(k).Info = TrackingBasedTargetModelinfo();

sim.targets(k).Info.Pos = [2,2];

k=k+1;

sim.targets(k).Info = TrackingBasedTargetModelinfo();

sim.targets(k).Info.Pos = [3,1];

sim.targets(k).Info.T = 8;

sim.targets(k).Info.a = 1;

sim.targets(k).Info.t0 = 1.3;

k=k+1;

sim.targets(k).Info = TrackingBasedTargetModelinfo();

sim.targets(k).Info.Pos = [2,2.5];

sim.targets(k).Info.T = 3;

sim.targets(k).Info.a = .5;

sim.targets(k).Info.t0 = 1.3;

### User inputs : Detection Threshold
DetectionTHR = .7;
