function [symbolic_ans numeric_ans] = Solve_AMP_Circuit(netlist_directory)

%{
Part 1: reading the netlist
Part 2: parsing the netlist
Part 3: creating the matrices
Part 4: solving the matrices
%}

%__Part 1__

%loading netlist
raw_netlist = fopen(netlist_directory);
raw_netlist = fscanf(raw_netlist, '%c');

%Deleting multiple spaces, etc. using regular expressions
netlist = regexprep(raw_netlist,' *',' ');
netlist = regexprep(netlist,' I','I');
netlist = regexprep(netlist,' R','R');
netlist = regexprep(netlist,' V','V');
netlist = regexprep(netlist,' C','C');
netlist = regexprep(netlist,' L','L');
netlist = regexprep(netlist,' E','E');
netlist = regexprep(netlist,' G','G');
netlist = regexp(netlist,'[^\n]*','match');

%__Part 2__
%You may visit "ParseNetlist.m"
[R_Node_1 R_Node_2 R_Values R_Names R_Control_Node_1 R_Control_Node_2] = ParseNetlistAMP(netlist, 'R');
[V_Node_1 V_Node_2 V_Values V_Names V_Control_Node_1 V_Control_Node_2] = ParseNetlistAMP(netlist, 'V');
[I_Node_1 I_Node_2 I_Values I_Names I_Control_Node_1 I_Control_Node_2] = ParseNetlistAMP(netlist, 'I');
[C_Node_1 C_Node_2 C_Values C_Names C_Control_Node_1 C_Control_Node_2] = ParseNetlistAMP(netlist, 'C');
[L_Node_1 L_Node_2 L_Values L_Names L_Control_Node_1 L_Control_Node_2] = ParseNetlistAMP(netlist, 'L');
[E_Node_1 E_Node_2 E_Values E_Names E_Control_Node_1 E_Control_Node_2] = ParseNetlistAMP(netlist, 'E');
[G_Node_1 G_Node_2 G_Values G_Names G_Control_Node_1 G_Control_Node_2] = ParseNetlistAMP(netlist, 'G');

%Counting nodes
%Nodes should be named in order 0, 1, 2, 3, ..
%We will combine all parsed nodes, then find the maximum number which is
%the number of nodes assuming that they are named in order

nodes_list = [R_Node_1 R_Node_2 V_Node_1 V_Node_2 I_Node_1 I_Node_2 C_Node_1 C_Node_2 L_Node_1 L_Node_2 E_Node_1 E_Node_2 G_Node_1 G_Node_2];
nodes_number = max(str2double(nodes_list));


%__Part 3__
%Matrices_size = no. nodes + no. Vsources
matrices_size = nodes_number + numel(V_Names);

%Z matrix
%Initialize zero matrix
unit_matrix = cell(matrices_size, 1);
for i = 1:1:numel(unit_matrix)
    unit_matrix{i} = ['0'];
end
z = unit_matrix;

%stamping Isources
for I = 1:1:numel(I_Names)
    current_node_1 = str2double(I_Node_1(I));
    current_node_2 = str2double(I_Node_2(I));
    current_name = I_Names{I};
    if current_node_1 ~= 0
        z{current_node_1} = [z{current_node_1} '-' current_name];
    end
    if current_node_2 ~= 0
        z{current_node_2} = [z{current_node_2} '+' current_name];
    end
end
%stamping Vsources
for V = 1:1:numel(V_Names)
    z{nodes_number + V} = [V_Names{V}];
end
%stamping VCVS
for E = 1:1:numel(E_Names)
    z{nodes_number+numel(V_Names)+E} = 0;
end
Z = str2sym(z);

%X matrix
x = cell(matrices_size, 1);
for node = 1:1:nodes_number
    x{node} = ['V_' num2str(node)];
end
%Stamping Vsources
for V = 1:1:numel(V_Names)
    x{nodes_number + V} = ['I_' V_Names{V}];
end
%stamping VCVS
for E = 1:1:numel(E_Names)
    x{nodes_number+numel(V_Names)+E} = ['I_' E_Names{E}];
end
X = str2sym(x);

%A matrix
%_G matirix
G = repmat(unit_matrix(1:nodes_number), 1, nodes_number);
%Stamping R
for R = 1:1:numel(R_Names)
    current_node_1 = str2double(R_Node_1(R));
    current_node_2 = str2double(R_Node_2(R));
    current_name = R_Names{R};
    if current_node_1 ~= 0
        G{current_node_1, current_node_1} = [G{current_node_1, current_node_1} '+1/' current_name];
    end
    if current_node_2 ~= 0
       G{current_node_2,current_node_2}=[G{current_node_2, current_node_2} '+1/' current_name];
        % add a line here to assign an element in G matrix
    end
    if current_node_1 ~= 0 && current_node_2 ~= 0
        G{current_node_1,current_node_2}=[G{current_node_1, current_node_2} '-1/' current_name];
        G{current_node_2,current_node_1}=[G{current_node_2, current_node_1} '-1/' current_name];
        % add a line here to assign an element in G matrix
        % add a line here to assign an element in G matrix
    end
end
%Stamping C
for C = 1:1:numel(C_Names)
    current_node_1 = str2double(C_Node_1(C));
    current_node_2 = str2double(C_Node_2(C));
    current_name = C_Names{C};
    if current_node_1 ~= 0
        G{current_node_1, current_node_1} = [G{current_node_1, current_node_1} '+iw' current_name];
    end
    if current_node_2 ~= 0
       G{current_node_2,current_node_2}=[G{current_node_2, current_node_2} '+iw' current_name];
        % add a line here to assign an element in G matrix
    end
    if current_node_1 ~= 0 && current_node_2 ~= 0
        G{current_node_1,current_node_2}=[G{current_node_1, current_node_2} '-iw' current_name];
        G{current_node_2,current_node_1}=[G{current_node_2, current_node_1} '-iw' current_name];
        % add a line here to assign an element in G matrix
        % add a line here to assign an element in G matrix
    end
end
%Stamping L
for L = 1:1:numel(L_Names)
    current_node_1 = str2double(L_Node_1(L));
    current_node_2 = str2double(L_Node_2(L));
    current_name = L_Names{L};
    if current_node_1 ~= 0
        G{current_node_1, current_node_1} = [G{current_node_1, current_node_1} '+1/iw' current_name];
    end
    if current_node_2 ~= 0
       G{current_node_2,current_node_2}=[G{current_node_2, current_node_2} '+1/iw' current_name];
        % add a line here to assign an element in G matrix
    end
    if current_node_1 ~= 0 && current_node_2 ~= 0
        G{current_node_1,current_node_2}=[G{current_node_1, current_node_2} '-1/iw' current_name];
        G{current_node_2,current_node_1}=[G{current_node_2, current_node_1} '-1/iw' current_name];
        % add a line here to assign an element in G matrix
        % add a line here to assign an element in G matrix
    end
end
%Stamping VCCS
for G = 1:1:numel(G_Names)
    current_node_1 = str2double(G_Node_1(G));
    current_node_2 = str2double(G_Node_2(G));
    current_name = G_Names{G};
    control_node_1=str2double(G_Control_Node_1(G));
    control_node_2=str2double(G_Control_Node_2(G));
    if current_node_1 ~= 0 && control_node_1 ~= 0
        G{current_node_1, control_node_1} = [G{current_node_1, control_node_1} '+1' current_name];
    end
    if current_node_1 ~= 0 && control_node_2 ~= 0
       G{current_node_1,control_node_2}=[G{current_node_1, control_node_2} '-1' current_name];
        % add a line here to assign an element in G matrix
    end
    if current_node_2 ~= 0 && control_node_1 ~= 0
        G{current_node_2,control_node_1}=[G{current_node_2, control_node_1} '-1' current_name];
    end
     if current_node_2 ~= 0 && control_node_2 ~= 0
        G{current_node_2,control_node_2}=[G{current_node_2, control_node_2} '+1' current_name];
    end
end

%B matrix
B = repmat(unit_matrix, 1, numel(V_Names));
%Stamping Vsource
for V = 1:1:numel(V_Names)
    current_node_1 = str2double(V_Node_1(V));
    current_node_2 = str2double(V_Node_2(V));
    if current_node_1 ~= 0
        B{current_node_1,V}="1";
        % add a line here to assign an element in B matrix
    end
    if current_node_2 ~= 0
        B{current_node_2,V}="-1";
        % add a line here to assign an element in B matrix
    end
end
for E = 1:1:numel(E_Names)
    current_node_1 = str2double(E_Node_1(E));
    current_node_2 = str2double(E_Node_2(E));
    if current_node_1 ~= 0
        B{current_node_1,numel(V_Names)+E}="1";
        % add a line here to assign an element in B matrix
    end
    if current_node_2 ~= 0
        B{current_node_2,numel(V_Names)+E}="-1";
        % add a line here to assign an element in B matrix
    end
end

%C matrix
for V = 1:1:numel(V_Names)
  C = B.';
end
for E = 1:1:numel(E_Names)
    current_node_1 = str2double(E_Node_1(E));
    current_node_2 = str2double(E_Node_2(E));
    current_name = E_Names{E};
    control_node_1=str2double(E_Control_Node_1(E));
    control_node_2=str2double(E_Control_Node_2(E));
     if  control_node_1 ~= 0
        C{numel(V_Names)+E, control_node_1} = [C{E, control_node_1} '-1' current_name];
     end
     if control_node_2 ~= 0
       C{numel(V_Names)+E,control_node_2}=[C{E, control_node_2} '+1' current_name];
     end
     if current_node_1 ~= 0
        C{numel(V_Names)+E,current_node_1}="1";
     end
     if current_node_2 ~= 0
        C{numel(V_Names)+E,current_node_2}="-1";
     end
end

%Combining all in A matrix
a = [G; C(:,1:nodes_number)];
a = [a B];

A = str2sym(a);

%__Part 4__
%Symbolic
symbolic_ans = A\Z;

%Numeric
%Fetch variables values
for R=1:1:numel(R_Names)
    eval([R_Names{R} ' = ' num2str(R_Values{R}) ';']);
end

for V=1:1:numel(V_Names)
    eval([V_Names{V} ' = ' num2str(V_Values{V}) ';'])
    % add a line here to assign voltage sources values into double variables
end

for V=1:1:numel(I_Names)
    eval([I_Names{V} ' = ' num2str(I_Values{V}) ';'])
    % add a line here to assign voltage sources values into double variables
end
for C=1:1:numel(C_Names)
    eval([C_Names{C} ' = ' num2str(C_Values{C}) ';']);
end
for L=1:1:numel(L_Names)
    eval([L_Names{L} ' = ' num2str(L_Values{L}) ';']);
end
for E=1:1:numel(E_Names)
    eval([E_Names{E} ' = ' num2str(E_Values{E}) ';']);
end
for G=1:1:numel(G_Names)
    eval([G_Names{G} ' = ' num2str(G_Values{G}) ';']);
end
numeric_ans=subs(symbolic_ans)
%Substitute

% add a line here to substitute the symoblic solutions with the variables created in the previous step, and save it into num array

%Print
for i = 1:1:numel(symbolic_ans)
    fprintf('%s = %f\n', char(X(i)), double(numeric_ans(i)));
end
