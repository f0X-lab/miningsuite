% SIG.SAVE
% (Not available yet.)
%
% Copyright (C) 2017-2018 Olivier Lartillot
% All rights reserved.
% License: New BSD License. See full text of the license in LICENSE.txt in
% the main folder of the MiningSuite distribution.

function varargout = save(varargin)
arg = varargin{1};

if isa(arg,'sig.design')
    e = arg.eval;
    arg = e{1};
end

if isa(arg,'sig.Signal')
    varargout = arg.save(varargin{2:end});
    return
end

varargout = sig.operate('sig','save',struct,@init,@main,varargin);


function [x type] = init(x,option)
type = '?';


function out = main(x,option,postoption)
out = {x{1}.save(option)};