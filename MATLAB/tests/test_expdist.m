function test_expdist()

%% GPU

% one localization
S_gpu = [0 0.5 1];
M_gpu = [1 2 3];
sig1_gpu = [0.3 0.7];
sig2_gpu = [0.4 0.9];
tmpRR_gpu = [0 1 0; -1 0 0; 0 0 1];
c_gpu = mex_expdist(S_gpu, M_gpu, sig2_gpu, sig1_gpu, tmpRR_gpu);

% two localizations
S2_gpu = [0.1 0.2 0.3; 0.2 0.3 0.4];
M2_gpu = [0.2 0.4 0.6; 0.3 0.5 0.7];
sig12_gpu = [0.7 0.8; 0.8 0.9];
sig22_gpu = [0.6 0.7; 0.7 0.8];
tmpRR2_gpu = [0 -1 0; 1 0 0; 0 0 1];
c2_gpu = mex_expdist(S2_gpu, M2_gpu, sig22_gpu, sig12_gpu, tmpRR2_gpu);

%% CPU

% one localization
S_cpu = [0 0.5 1];
M_cpu = [1 2 3];
sig1_cpu = [0.3 0.7];
sig2_cpu = [0.4 0.9];
tmpRR_cpu = [0 1 0; -1 0 0; 0 0 1];
c_cpu = mex_expdist_cpu(S_cpu, M_cpu, sig2_cpu, sig1_cpu, tmpRR_cpu);

% two localizations
S2_cpu = [0.1 0.2 0.3; 0.2 0.3 0.4];
M2_cpu = [0.2 0.4 0.6; 0.3 0.5 0.7];
sig12_cpu = [0.7 0.8; 0.8 0.9];
sig22_cpu = [0.6 0.7; 0.7 0.8];
tmpRR2_cpu = [0 -1 0; 1 0 0; 0 0 1];
c2_cpu = mex_expdist_cpu(S2_cpu, M2_cpu, sig22_cpu, sig12_cpu, tmpRR2_cpu);

%% compare input

% one localization
assert(isequal(S_gpu, S_cpu));
assert(isequal(M_gpu, M_cpu));
assert(isequal(sig1_gpu, sig1_cpu));
assert(isequal(sig2_gpu, sig2_cpu));
assert(isequal(tmpRR_gpu, tmpRR_cpu));

% two localizations
assert(isequal(S2_gpu,S2_cpu));
assert(isequal(M2_gpu, M2_cpu));
assert(isequal(sig12_gpu, sig12_cpu));
assert(isequal(sig22_gpu, sig22_cpu));
assert(isequal(tmpRR2_gpu, tmpRR2_cpu));

%% print output
fprintf(['\n\tc_gpu:  ' num2str(c_gpu)]);
fprintf(['\tc2_gpu: ' num2str(c2_gpu) '\n']);
fprintf(['\tc_cpu:  ' num2str(c_cpu)]);
fprintf(['\tc2_cpu: ' num2str(c2_cpu) '\n\n']);

%% compare output
tolerance = 1e-4;
assert(abs(c_gpu - c_cpu) < tolerance);
assert(abs(c2_gpu - c2_cpu) < tolerance);

end