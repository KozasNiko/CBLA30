% Pre-processing script for the EST Simulink model. This script is invoked
% before the Simulink model Initials running (initFcn callback function).

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

% mass
unit("kg") = 1.;
unit("g") = unit("kg")/1000;


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
shcFluidSupplyTransport = 4184*unit("J")/(unit("K")*unit("kg"));       % PLACEHOLDER specific heat capacity of transport fluid
tFluidSupplyTransport = 298*unit("K");                                 % PLACEHOLDER initial temperature of the transport fluid
tSurroundingsSupplyTransport = 298*unit("K");                          % PLACEHOLDER (constant) temperature of the environment
tPipeSupplyTransport = 20*unit("mm");                                  % PLACEHOLDER wall thickness of pipes
tInsSupplyTransport = 20*unit("mm");                                  % PLACEHOLDER radial thickness of insulation
irPipeSupplyTransport = 20*unit("mm");                                 % PLACEHOLDER internal radius of the pipes
l1PipeSupplyTransport = 30*unit("m");                                  % PLACEHOLDER length of pipe from panels to storage
l2PipeSupplyTransport = 30*unit("m");                                  % PLACEHOLDER length of pipe from storage to panels
tcPipeSupplyTransport = 50*unit("W")/(unit("m")*unit("K"));            % PLACEHOLDER thermal conductivity of pipe
tcInsSupplyTransport = 0.04*unit("W")/(unit("m")*unit("K"));            % PLACEHOLDER thermal conductivity of insulation
ccSurroundingsSupplyTransport = 20*unit("W")/(unit("m")*unit("K")); % PLACEHOLDER convective heat transfer coefficient of surroundings

% injection system
aInjection = 0.1; % Dissipation coefficient
rInjection = 0.1; % Remaining energy coefficient

% storage system

% cylindrical storage tank:
rStorage              = 0.5*unit("m"); % PLACEHOLDER inner radius of storage tank
lStorage              = 3*unit("m"); % PLACEHOLDER inner length of storage tank
tcStorage             = 50*unit("W")/(unit("m")*unit("K")); % PLACEHOLDER thermal conductivity of tank
ccSurroundingsStorage = 20*unit("W")/(unit("m")*unit("K")); % PLACEHOLDER convective heat transfer coefficient of surrounding fluid
eStorage              = 0.06;                                  % PLACEHOLDER emissivity of tank
tStorage              = 100*unit("mm");                        % PLACEHOLDER wall thickness of tank
dStorageMaterial      = 5000*unit("kg")/unit("m")/unit("m")/unit("m"); % PLACEHOLDER density of energy storage material
shcStorageMaterial    = 4184*unit("J")/(unit("K")*unit("kg")); % PLACEHOLDER specific heat capacity of storage material
tSurroundingsStorage  = 298*unit("K"); % PLACEHOLDER surrounding temperature of storage
tStartStorage         = 298*unit("K"); % PLACEHOLDER Initialing temperature of storage material
tMaxStorage = 363.15*unit("K"); % PLACEHOLDER maximum storage temperature
tMinStorage = 273.15*unit("K"); % PLACEHOLDER minimum storage temperature

% extraction system
aExtraction = 1-0.337; % Dissipation coefficient

% transport to demand
vFluidDemandTransport = 5*unit("m")/unit("s");                         % PLACEHOLDER velocity of transport fluid
dFluidDemandTransport = 1000*unit("kg")/unit("m")/unit("m")/unit("m"); % PLACEHOLDER density of transport fluid
shcFluidDemandTransport = 4184*unit("J")/(unit("K")*unit("kg"));       % PLACEHOLDER specific heat capacity of transport fluid
tFluidDemandTransport = 298*unit("K");                                 % PLACEHOLDER initial temperature of the transport fluid
tSurroundingsDemandTransport = 298*unit("K");                          % PLACEHOLDER (constant) temperature of the environment
tPipeDemandTransport = 20*unit("mm");                                  % PLACEHOLDER wall thickness of pipes
tInsDemandTransport = 20*unit("mm");                                  % PLACEHOLDER radial thickness of insulation
irPipeDemandTransport = 20*unit("mm");                                 % PLACEHOLDER internal radius of the pipes
lPipeDemandTransport = 30*unit("m");                                   % PLACEHOLDER length of pipe between energy input into pipes and demand
tcPipeDemandTransport = 50*unit("W")/(unit("m")*unit("K"));            % PLACEHOLDER thermal conductivity of pipe
tcInsDemandTransport = 0.04*unit("W")/(unit("m")*unit("K"));            % PLACEHOLDER thermal conductivity of insulation
ccSurroundingsDemandTransport = 20*unit("W")/(unit("m")*unit("K")); % PLACEHOLDER convective heat transfer coefficient of surroundings

pdDemandTransport = 400; % PLACEHOLDER V potential difference of cable
lDemandTransport = 30*unit("m"); % PLACEHOLDER length of cable
rplDemandTransport = 0.00049; % PLACEHOLDER ohm/m resistance per unit length of cable


%demand
aElectricityDemand = 0.7; % Ratio of the demand that needs to be met in electricity, rest is heat

%controller
aElectricToThermal = 0.01; % PLACEHOLDER dissipation coefficient of converting from electric to thermal energy 
aThermalToElectric = 0.01; % PLACEHOLDER dissipation coefficient of converting from thermal to electric energy 





%% Compute additional constants

VStorage = pi * rStorage^2 * lStorage;
mStorage = VStorage * dStorageMaterial;
EStorageMax = mStorage * shcStorageMaterial * (tMaxStorage - tMinStorage);
EStorageMax = EStorageMax  / (3.6e6 * unit("J")/unit("kWh"));
EStorageMin = 0*unit("kWh");
EStorageInitial = mStorage * shcStorageMaterial * (tStartStorage - tMinStorage);
EStorageInitial = EStorageInitial  / (3.6e6 * unit("J")/unit("kWh"));