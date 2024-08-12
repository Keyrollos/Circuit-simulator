% cleaning the workspace, and cmd window
clear all;
clc;

% running the first SPICE netlist
fprintf('the first netlist:\n');
[sum,num]=Solve_AMP_Circuit('lab 2 AMS course part 3.cir');

clear all; % used to bypass an error only with Octave (not MATLAB)



