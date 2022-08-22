clc
clear
close all
load CloudPointsSeuence
for ind = 1:length(CloudPointsSeuence)
    hold off
    plot(CloudPointsSeuence(ind).GroundTruth(:,1),CloudPointsSeuence(ind).GroundTruth(:,2),'.')
    hold on
    plot(CloudPointsSeuence(ind).CloudPoints(:,1),CloudPointsSeuence(ind).CloudPoints(:,2),'.r')
    xlim([-5 5])
    ylim([-5 5])
    xlabel('x (m)')
    ylabel('y (m)')
    title(['Time = ' num2str(CloudPointsSeuence(ind).Time)])
    grid on
    drawnow
    pause(.1)
end