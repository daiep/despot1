%% DESPOT1 to estimate T1 and proton density Mo
%
%   Input:
%           -   S: Set of T1-weighted signals from different flip angles,
%                  pixel-based
%           -   FA: Set of flip angles used corresponding to S
%           -   TR: TR of sequence (ms or s)
%   Output:
%           -   T1: Calcuted T1 (same as TR)
%           -   Mo: Calculated proton density
%
%   Linear fitting of y = ax+b
%   Rapid combined T1 and T2 mapping using gradient recalled acquisition in the steady state.
%   Deoni et al. MRM 2003;49:515-526
%
%   Author: Kwok-shing Chan @ University of Aberdeen
%   Date created: Jan 11, 2016
%   Date last edited: July 15, 2016
%
function [T1, Mo] = DESPOT1(S, FA, TR)
    if length(S) < 2
        display('Only one point to fit.');
    end
    
    opts = optimset('lsqnonlin');
    options = optimset(opts,'Display','off','MaxIter',100);

    %% Test for fat T1
    E1_lb = exp(-TR/40e-3);  E1_ub = exp(-TR/5000e-3);
    [T10, Mo0] = DESPOT1_QuickEsti(abs(S),FA,TR);

    c0 = [exp(-TR./T10), Mo0];
    lb = [E1_lb, min(S)];
    ub = [E1_ub, 2*Mo0];
    [res, norm] = lsqnonlin(@(x)fitError_DESPOT1(x,S,FA), c0,lb,ub,options);

        T1 = abs(-TR./log(res(1)));
        Mo = abs(res(2));

function [T1map, Momap] = DESPOT1_QuickEsti(S,FA,TR)

x = S./tand(FA);
y = S./sind(FA);

y_diff = y(2) - y(1);
x_diff = x(2) - x(1);

m = y_diff./x_diff;

T1 = -TR./log(m);
T1(isnan(T1)) = 0;
T1(T1>5) = 5;
T1map = abs(T1);

m_new = exp(-TR./T1);
Momap = mean((y-repmat(m_new,2,1).*x)./(1-repmat(m_new,2,1)));

function [fiter] = fitError_DESPOT1(x,S_meas,FA)
E1 = x(1);
Mo = x(2);

S_fit = E1.*(S_meas./tand(FA))+Mo*(1-E1);
fiter = S_fit - S_meas./sind(FA);

