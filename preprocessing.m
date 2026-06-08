% Pre-processing script for the EST Simulink model. This script is invoked
% before the Simulink model Initials running (initFcn callback function).

%% Load the supply and demand data
addpath('C:\Users\nikol\Desktop\Uni\Year 2\Q4\EST\EST-model-main\scripts')

timeUnit   = 's';

supFile = "Team26_supply.csv";
supUnit = "kW";

% load the supply data
supPower = loadSupplyData(supFile, timeUnit, supUnit);

demFile = "Team26_demand.csv";
demUnit = "kW";

% load the demand data
demPower = loadDemandData(demFile, timeUnit, demUnit);

%% Simulation settings

deltat = 15*unit("min");
stopt  = min([supPower.Timeinfo.End, demPower.Timeinfo.End]);

%% System parameters

% transport from supply (TFS)
TFS_VOLTAGE = 400; %  V operating voltage of the transport system
TFS_LENGTH = 28.6*unit("m"); % length of cable
TFS_RES_PER_LENGTH = 0.0007; %  ohm/m resistance per unit length of cable

% injection system (INJ)
INJ_DISS_COEFF = 0.02; % PLACEHOLDER Dissipation coefficient

% storage system (STO)
STO_INNER_RADIUS              = 1.088*unit("m"); % inner radius of storage tank
STO_LENGTH              = 2.176*unit("m"); %  inner length of storage tank
STO_COND             = 0.1045*unit("W")/(unit("m")*unit("K")); % thermal conductivity of tank
STO_CONV_COEFF_ENV = 11.4*unit("W")/(unit("m")*unit("K")); %  convective heat transfer coefficient of surrounding fluid
STO_EMISSIVITY              = 0.90;                                  %  Emissivity of tank
STO_WALL_THICKNESS              = 350*unit("mm");                        % wall thickness of tank
STO_DENSITY      = 3900*unit("kg")/(unit("m")^3); %  density of energy storage material
STO_HEAT_CAPACITY = 1000*unit("J")/(unit("K")*unit("kg")); %  specific heat capacity of storage material
STO_TEMP_ENV  = 293*unit("K"); %  surrounding temperature of storage
STO_TEMP_INIT         = 473.15*unit("K"); %  Initial temperature of storage material
STO_TEMP_MAX = 586.15*unit("K"); %  maximum storage temperature
STO_TEMP_MIN = 373.15*unit("K"); %  minimum storage temperature

% extraction system (EXT)
EXT_DISS_COEFF = 1-0.341; % Dissipation coefficient

% transport to demand (TTD)
TTD_FLUID_VELOCITY = 0.67*unit("m")/unit("s");                        %  velocity of transport fluid
TTD_FLUID_DENSITY = 1000*unit("kg")/unit("m")/unit("m")/unit("m"); %  density of transport fluid
TTD_FLUID_HEAT_CAPACITY = 4184*unit("J")/(unit("K")*unit("kg"));       %  specific heat capacity of transport fluid
TTD_FLUID_TEMP_INIT = 343*unit("K");                                 %  initial temperature of the transport fluid
TTD_WALL_THICKNESS = 10*unit("mm");                                  %   wall thickness of pipes
TTD_INS_THICKNESS = 150*unit("mm");                                   % tInsDemandTransport radial thickness of insulation
TTD_INNER_RADIUS = 20*unit("mm");                                 %  internal radius of the pipes
TTD_LENGTH = 35*unit("m");                                   %  length of pipe between energy input into pipes and demand
TTD_WALL_COND = 50*unit("W")/(unit("m")*unit("K"));            %  thermal conductivity of pipe wall
TTD_INS_COND = 0.04*unit("W")/(unit("m")*unit("K"));            %  thermal conductivity of insulation
TTD_CONV_COEFF_ENV = 6.41*unit("W")/(unit("m")^2*unit("K")); %  convective heat transfer coefficient of surroundings

TTD_ALPHA = 0.01; % Factor by which the potential difference is increased to provide a more stable system
TTD_RES_PER_LENGTH = 0.0007; %  ohm/m resistance per unit length of cable

%demand (DEM)
DEM_ENERGY_RATIO = 0.7; % Ratio of the demand that needs to be met in electricity, rest is heat

%controller (CON)
CON_DISS_COEFF_EL_TO_TH = 0.1; %  dissipation coefficient of converting from electric to thermal energy 

%% Compute additional constants
stoVolume = pi * STO_INNER_RADIUS^2 * STO_LENGTH;
stoMass = stoVolume * STO_DENSITY;
stoEnergyMax = stoMass * STO_HEAT_CAPACITY * (STO_TEMP_MAX - STO_TEMP_MIN);
stoEnergyMax = stoEnergyMax  / (3.6e6 * unit("J")/unit("kWh"));
stoEnergyMin = 0*unit("kWh");
stoEnergyInit = stoMass * STO_HEAT_CAPACITY * (STO_TEMP_INIT - STO_TEMP_MIN);
stoEnergyInit = stoEnergyInit  / (3.6e6 * unit("J")/unit("kWh"));