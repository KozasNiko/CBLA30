% Post-processing script for the EST Simulink model. This script is invoked
% after the Simulink model is finished running (stopFcn callback function).

close all;
figure;

%% Supply and demand
subplot(2,2,1);
plot(tout/unit("day"), powerFromSupply/unit("W"));
hold on;
plot(tout/unit("day"), powerToDemand/unit("W"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Supply and demand');
xlabel('Time [day]');
ylabel('Power [W]');
legend("Supply","Demand");

%% Stored energy
subplot(2,2,2);
plot(tout/unit("day"), energySTO/unit("J"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Storage');
xlabel('Time [day]');
ylabel('Energy [J]');

%% Energy losses
subplot(2,2,3);
plot(tout/unit("day"), diss/unit("W"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Losses');
xlabel('Time [day]');
ylabel('Dissipation rate [W]');

%% Load balancing
subplot(2,2,4);
plot(tout/unit("day"), powerSold/unit("W"));
hold on;
plot(tout/unit("day"), powerBought/unit("W"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Load balancing');
xlabel('Time [day]');
ylabel('Power [W]');
legend("Sell","Buy");

figure;
%% Controller energy conversion dissipation
subplot(2,2,1);
plot(tout/unit("day"), dissCON/unit("W"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Controller energy conversion dissipation');
xlabel('Time [day]');
ylabel('Power [W]');

%% Energy transport dissipation
subplot(2,2,2);
plot(tout/unit("day"), dissTRA/unit("W"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Energy transport dissipation');
xlabel('Time [day]');
ylabel('Power [W]');

%% Energy storage dissipation
subplot(2,2,3);
plot(tout/unit("day"), dissSTO/unit("W"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Energy storage dissipation');
xlabel('Time [day]');
ylabel('Power [W]');

%% dT thermal demand transport
subplot(2,2,4);
plot(tout/unit("day"), deltaTempToTTD/unit("K"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Temperature range of thermal demand transport');
xlabel('Time [day]');
ylabel('Temperature [K]');

%% Pie charts

% integrate the power signals in time
energyFromTFS = trapz(tout, powerFromTFS);
energyToTTD   = trapz(tout, powerToTTD);
energySold    = trapz(tout, powerSold);
energyBought  = trapz(tout, powerBought);
energyToINJ   = trapz(tout, powerToINJ);
energyFromEXT = trapz(tout, powerFromEXT);
dissEnergySTO = trapz(tout, dissSTO);
energyDirect  = energyFromTFS - energySold - energyToINJ;
energySurplus = energyToINJ-energyFromEXT-dissEnergySTO;

figure;
tiles = tiledlayout(1,2);

ax = nexttile;
pie(ax, [energyDirect, energyToINJ, energySold]/energyFromTFS);
lgd = legend({"Direct to demand", "To storage", "Sold"});
lgd.Layout.Tile = "south";
title(sprintf("Received energy %3.2e [J]", energyFromTFS/unit('J')));

ax = nexttile;
pie(ax, [energyDirect, energyFromEXT, energyBought]/energyToTTD);
lgd = legend({"Direct from supply", "From storage", "Bought"});
lgd.Layout.Tile = "south";
title(sprintf("Delivered energy %3.2e [J]", energyToTTD/unit('J')));