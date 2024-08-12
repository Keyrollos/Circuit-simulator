% cleaning the workspace, and cmd window
clear all;
clc;
pkg load symbolic;
% running the first SPICE netlist
fprintf('the first netlist:\n');
[sum,num]=Solve_AC_Circuit('lab 2 AMS course part 2 criticallydamped.cir');

clear all; % used to bypass an error only with Octave (not MATLAB)


fprintf('the second netlist:\n');
[sum,num]=Solve_AC_Circuit('lab 2 AMS course part 2 overdamped.cir');
% add a line here to run the second netlist

fprintf('the third netlist:\n');
[sum,num]=Solve_AC_Circuit('lab 2 AMS course part 2 underdamped.cir');
