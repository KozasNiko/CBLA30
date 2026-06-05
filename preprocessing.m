% Pre-processing script for the EST Simulink model. This script is invoked
% before the Simulink model Initials running (initFcn callback function).

%% Load the supply and demand data
addpath('C:\Users\nikol\Desktop\Uni\Year 2\Q4\EST\EST-model-main\scripts')

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
pdSupplyTransport = 400; % PLACEHOLDER V operating voltage of the transport system
lSupplyTransport = 35*unit("m"); % length of cable
rplSupplyTransport = 0.00049; % PLACEHOLDER ohm/m resistance per unit length of cable

% injection system
aInjection = 0.1; % PLACEHOLDER Dissipation coefficient

% storage system

% cylindrical storage tank:
rStorage              = 0.5*unit("m"); % PLACEHOLDER inner radius of storage tank
lStorage              = 3*unit("m"); % PLACEHOLDER inner length of storage tank
tcStorage             = 50*unit("W")/(unit("m")*unit("K")); % PLACEHOLDER thermal conductivity of tank
ccSurroundingsStorage = 20*unit("W")/(unit("m")*unit("K")); % PLACEHOLDER convective heat transfer coefficient of surrounding fluid
eStorage              = 0.06;                                  % PLACEHOLDER emissivity of tank
tStorage              = 100*unit("mm");                        % PLACEHOLDER wall thickness of tank
dStorageMaterial      = 5000*unit("kg")/(unit("m")^3); % PLACEHOLDER density of energy storage material
shcStorageMaterial    = 4184*unit("J")/(unit("K")*unit("kg")); % PLACEHOLDER specific heat capacity of storage material
tSurroundingsStorage  = 287*unit("K"); % surrounding temperature of storage
tStartStorage         = 287*unit("K"); % PLACEHOLDER Initial temperature of storage material
tMaxStorage = 363.15*unit("K"); % PLACEHOLDER maximum storage temperature
tMinStorage = 287*unit("K"); % PLACEHOLDER minimum storage temperature

% extraction system
aExtraction = 1-0.337; % Dissipation coefficient

% transport to demand
vFluidDemandTransport = 5*unit("m")/unit("s");                         % PLACEHOLDER velocity of transport fluid
dFluidDemandTransport = 1000*unit("kg")/(unit("m")^3); % PLACEHOLDER density of transport fluid
shcFluidDemandTransport = 4.18*unit("J")/(unit("K")*unit("g"));       % specific heat capacity of transport fluid
tFluidDemandTransport = 343*unit("K");                                 % initial temperature of the transport fluid
tSurroundingsDemandTransport = 296*unit("K");                          % temperature of the environment
tPipeDemandTransport = 10*unit("mm");                                  % PLACEHOLDER wall thickness of pipes
tInsDemandTransport = 20*unit("mm");                                  % PLACEHOLDER radial thickness of insulation
irPipeDemandTransport = 8.75*unit("mm");                                 % PLACEHOLDER internal radius of the pipes
lPipeDemandTransport = 35*unit("m");                                   % PLACEHOLDER length of pipe between energy input into pipes and demand
tcPipeDemandTransport = 54*unit("W")/(unit("m")*unit("K"));            % thermal conductivity of pipe
tcInsDemandTransport = 0.046*unit("W")/(unit("m")*unit("K"));            % thermal conductivity of insulation
ccSurroundingsDemandTransport = 5*unit("W")/(unit("m")^2*unit("K")); % convective heat transfer coefficient of surroundings

alphaDemandTransport = 0.01; % Factor by which the potential difference is increased to provide a more stable system
lDemandTransport = 35*unit("m"); % PLACEHOLDER length of cable
rplDemandTransport = 0.00049; % PLACEHOLDER ohm/m resistance per unit length of cable


%demand
aElectricityDemand = 0.7; % Ratio of the demand that needs to be met in electricity, rest is heat

%controller
aElectricToThermal = 0.01; % PLACEHOLDER dissipation coefficient of converting from electric to thermal energy 

%% Compute additional constants

VStorage = pi * rStorage^2 * lStorage;
mStorage = VStorage * dStorageMaterial;
EStorageMax = mStorage * shcStorageMaterial * (tMaxStorage - tMinStorage);
EStorageMax = EStorageMax  / (3.6e6 * unit("J")/unit("kWh"));
EStorageMin = 0*unit("kWh");
EStorageInitial = mStorage * shcStorageMaterial * (tStartStorage - tMinStorage);
EStorageInitial = EStorageInitial  / (3.6e6 * unit("J")/unit("kWh"));