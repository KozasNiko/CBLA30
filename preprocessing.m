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
TFS_VOLTAGE             = 400*unit("V");                          % [V]
TFS_LENGTH              = 28.6*unit("m");                         % [m]
TFS_RES_PER_LENGTH      = 0.0007*unit("ohm")/unit("m");           % [ohm/m]

% injection system (INJ)
INJ_DISS_COEFF          = 0.02;                                   % [-]

% storage system (STO)
STO_INNER_RADIUS        = 1.088*unit("m");                        % [m]
STO_LENGTH              = 2.176*unit("m");                        % [m]
STO_COND                = 0.1045*unit("W")/(unit("m")*unit("K")); % [W/mK]
STO_CONV_COEFF_ENV      = 11.4*unit("W")/(unit("m")*unit("K"));   % [W/mK]
STO_WALL_THICKNESS      = 350*unit("mm");                         % [mm]
STO_DENSITY             = 3900*unit("kg")/unit("m3");             % [kg/m^3]
STO_HEAT_CAPACITY       = 1000*unit("J")/(unit("kg")*unit("K"));  % [J/kgK]
STO_TEMP_ENV            = 293*unit("K");                          % [K]
STO_TEMP_INIT           = 473.15*unit("K");                       % [K]
STO_TEMP_MAX            = 586.15*unit("K");                       % [K]
STO_TEMP_MIN            = 373.15*unit("K");                       % [K]

% extraction system (EXT)
EXT_DISS_COEFF          = 0.659;                                  % [-]

% transport to demand (TTD)
TTD_FLUID_VELOCITY      = 0.67*unit("m")/unit("s");               % [m/s]
TTD_FLUID_DENSITY       = 1000*unit("kg")/unit("m3");             % [kg/m^3]
TTD_FLUID_HEAT_CAPACITY = 4184*unit("J")/(unit("kg")*unit("K"));  % [J/kgK]
TTD_WALL_THICKNESS      = 10*unit("mm");                          % [mm]
TTD_INS_THICKNESS       = 15*unit("mm");                          % [mm]
TTD_INNER_RADIUS        = 20*unit("mm");                          % [mm]
TTD_LENGTH              = 35*unit("m");                           % [m]
TTD_WALL_COND           = 50*unit("W")/(unit("m")*unit("K"));     % [W/mK]
TTD_INS_COND            = 0.04*unit("W")/(unit("m")*unit("K"));   % [W/mK]
TTD_CONV_COEFF_ENV      = 6.41*unit("W")/(unit("m2")*unit("K"));  % [W/m^2K]
TTD_ALPHA               = 0.1;                                    % [-]
TTD_RES_PER_LENGTH      = 0.0007*unit("ohm")/unit("m");           % [ohm/m]

%demand (DEM)
DEM_ENERGY_RATIO        = 0.7;                                    % [-]

%controller (CON)
CON_DISS_COEFF_EL_TO_TH = 0.1;                                    % [-]

%% Compute additional constants
stoVolume = pi * STO_INNER_RADIUS^2 * STO_LENGTH;
stoMass = stoVolume * STO_DENSITY;
stoEnergyMax = stoMass * STO_HEAT_CAPACITY * (STO_TEMP_MAX - STO_TEMP_MIN);
stoEnergyMax = stoEnergyMax  / (3.6e6 * unit("J")/unit("kWh"));
stoEnergyMin = 0*unit("kWh");
stoEnergyInit = stoMass * STO_HEAT_CAPACITY * (STO_TEMP_INIT - STO_TEMP_MIN);
stoEnergyInit = stoEnergyInit  / (3.6e6 * unit("J")/unit("kWh"));