clc
clear
close all

sim = bistatic;

%% User inputs : Transmitter - Receiver Position
sim.TX_Position = [-1 1.3]*1;
sim.RX_Position = [2.1 -1.2]*1;
%% User inputs : Transmitter - Receiver Elements
sim.RX_N = 8;
sim.TX_N = 6;
sim.setTRXPos(1,0,0);
%% User inputs : Ground Truth Target Points 
DownSampling = 150;
humanScale = .3;
sim.readHumanTopview('human.png',DownSampling,humanScale);

%% User inputs : Target Movement
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

%% User inputs : Detection Threshold
DetectionTHR = .7;

%% Simulation : Output is CloudPointsSeuence
CloudPointsSeuence=[];
while ~sim.SimFinished
    subplot(221)
    hold off
    GroundTruth = [];
    for i = 1: length(sim.targets)
        PosInfo = sim.updateTargetPosition(sim.targets(i).Info.Pos,sim.targets(i).Info);
        sim.targets(i).Info.Pos = PosInfo.P ;
        sim.targets(i).Info.xy = sim.rotHuman(rad2deg(-PosInfo.dir));
        sim.targets(i).Info.xy = sim.targets(i).Info.xy + repmat(sim.targets(i).Info.Pos,size(sim.targets(i).Info.xy,1),1);
        plot(sim.targets(i).Info.xy(:,1),sim.targets(i).Info.xy(:,2),'.')
        GroundTruth = [GroundTruth;sim.targets(i).Info.xy];
        hold all
    end
    plot(sim.TX_Pos(:,1),sim.TX_Pos(:,2),'sr')
    plot(sim.RX_Pos(:,1),sim.RX_Pos(:,2),'ok')
    sim.signal = sim.getSignal();
    image = sim.getImage();
    L = 4;
    xlim([-L L])
    ylim([-L L])
    xlabel('x (m)')
    ylabel('y (m)')
    grid on
    axis equal
    title(['TX-RX Array, Ground Trurh, Time=' num2str(sim.time)])
    subplot(222)
    image2plot = abs(fliplr(image)');
    imagesc(image2plot)
    title('Radar Image')
    axis equal
    subplot(223)

    CloudPoints = sim.getCloudPoints(image,1,DetectionTHR);
    plot(CloudPoints(:,1),CloudPoints(:,2),'.')
    xlim([-L L])
    ylim([-L L])
    xlim([-5 5])
    ylim([-5 5])
    xlabel('x (m)')
    ylabel('y (m)')
    title('Detected Points')
    grid on
    axis equal
    subplot(224)
    hold off
    for i = 1: length(sim.targets)
        PosInfo = sim.updateTargetPosition(sim.targets(i).Info.Pos,sim.targets(i).Info);
        sim.targets(i).Info.Pos = PosInfo.P ;
        sim.targets(i).Info.xy = sim.rotHuman(rad2deg(-PosInfo.dir));
        sim.targets(i).Info.xy = sim.targets(i).Info.xy + repmat(sim.targets(i).Info.Pos,size(sim.targets(i).Info.xy,1),1);
        plot(sim.targets(i).Info.xy(:,1),sim.targets(i).Info.xy(:,2),'.b')
        hold on
    end
    plot(CloudPoints(:,1),CloudPoints(:,2),'.r')
    xlim([-L L])
    ylim([-L L])
    axis equal
    plot(sim.TX_Pos(:,1),sim.TX_Pos(:,2),'sr')
    plot(sim.RX_Pos(:,1),sim.RX_Pos(:,2),'ok')
    xlim([-5 5])
    ylim([-5 5])
    xlabel('x (m)')
    ylabel('y (m)')
    title('Detected Points+Ground Truth')
    grid on

    drawnow
    pause(.1)
    ind = length(CloudPointsSeuence)+1;
    CloudPointsSeuence(ind).GroundTruth=GroundTruth;
    CloudPointsSeuence(ind).CloudPoints=CloudPoints;
    CloudPointsSeuence(ind).Time=sim.time;
    sim.updateTime()
end
save CloudPointsSeuence.mat CloudPointsSeuence