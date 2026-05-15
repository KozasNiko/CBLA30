% Pre-processing script for the EST Simulink model. This script is invoked
% before the Simulink model starts running (initFcn callback function).

%% Load the supply and demand data
addpath('C:\Users\nikol\Desktop\Uni\Year 2\Q4\EST\EST-model-main\scripts')

global unit;
unit = containers.Map;

% time
unit("s")    = 1.;
unit("min")  = 60*unit("s");
unit("h")    = 60*unit("min");
unit("day")  = 24*unit("h");
unit("year") = 365*unit("day");

% energy
unit("J")  = 1.;
unit("kJ") = 1000*unit("J");
unit("MJ") = 1000*unit("kJ");
unit("GJ") = 1000*unit("MJ");

% power
unit("W")  = unit("J")/unit("s");
unit("kW") = 1000*unit("W");
unit("MW") = 1000*unit("kW");
unit("GW") = 1000*unit("MW");

% energy (Wh)
unit("Wh")  = unit("W") *unit("h");
unit("kWh") = unit("kW")*unit("h");
unit("MWh") = unit("MW")*unit("h");
unit("GWh") = unit("GW")*unit("h");

% length
unit("m") = 1.;
unit("mm") = unit("m")/1000;
unit("km") = 1000*unit("m");

% temperature
unit("K") = 1.;

% temperature
unit("g") = 1.;
unit("kg") = 1000*unit("g");

timeUnit   = 's';

supplyFile = "Team26_supply.csv";
supplyUnit = "kW";

% load the supply data
Supply = loadSupplyData(supplyFile, timeUnit, supplyUnit);

demandFile = "Team26_demand.csv";
demandUnit = "kW";

% load the demand data
Demand = loadDemandData(demandFile, timeUnit, demandUnit);

%% Simulation settings

deltat = 15*unit("min");
stopt  = min([Supply.Timeinfo.End, Demand.Timeinfo.End]);

%% System parameters

% transport from supply
vFluidSupplyTransport = 5*unit("m")/unit("s");                         % PLACEHOLDER velocity of transport fluid
dFluidSupplyTransport = 1000*unit("kg")/unit("m")/unit("m")/unit("m"); % PLACEHOLDER density of transport fluid
shcFluidSupplyTransport = 4.184*unit("J")/(unit("K")*unit("g"));       % PLACEHOLDER specific heat capacity of transport fluid
tFluidSupplyTransport = 273*unit("K");                                 % PLACEHOLDER initial temperature of the transport fluid
tSurroundingsSupplyTransport = 273*unit("K");                          % PLACEHOLDER (constant) temperature of the environment
tPipeSupplyTransport = 10*unit("mm");                                  % PLACEHOLDER wall thickness of pipes
irPipeSupplyTransport = 20*unit("mm");                                 % PLACEHOLDER internal radius of the pipes
l1PipeSupplyTransport = 30*unit("m");                                  % PLACEHOLDER length of pipe from panels to storage
l2PipeSupplyTransport = 30*unit("m");                                  % PLACEHOLDER length of pipe from storage to panels
tcPipeSupplyTransport = 50000*unit("W")/(unit("m")*unit("K"));         % PLACEHOLDER thermal conductivity of pipe
ccSurroundingsSupplyTransport = 50000*unit("W")/(unit("m")*unit("K")); % PLACEHOLDER convective heat transfer coefficient of surroundings

% injection system
aInjection = 0.1; % Dissipation coefficient

% storage system
EStorageMax     = 3388.9.*unit("kWh"); % Maximum energy
EStorageMin     = 0.0*unit("kWh"); % Minimum energy
EStorageInitial = 0.0*unit("kWh"); % Initial energy
bStorage        = 0/unit("s");  % Storage dissipation coefficient

% extraction system
aExtraction = 1-0.337; % Dissipation coefficient

% transport to demand
aDemandTransport = 0.01; % Dissipation coefficient
