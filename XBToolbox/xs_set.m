function xs = xs_set(xs, varargin)
%XS_SET  Sets variables in XStruct
%
%   Sets one or more variables in a XStruct. If a variable doesn't
%   exist yet, it is created. Units can be added by providing a cell array
%   containing the variable itself and a string containing the units, thus
%   {data, units}. Please add a flag '-units' to the varagin, if done so to
%   ensure proper parsing. Substructures can be editted by preceding the
%   field name with the structure name and a dot, for example: bcfile.Tp
%
%   Syntax:
%   xs   = xs_set(xs, varargin)
%
%   Input:
%   xs          = XStruct array
%   varargin    = Name/value pairs of variables to be set
%
%   Output:
%   xs          = Updated XStruct array
%
%   Example
%   xs  = xs_set(xs, 'zb', zb, 'zs', zs)
%   xs  = xs_set(xs, '-units', 'zb', {zb 'm+NAP'}, 'zs', {zs 'm+NAP'})
%   xs  = xs_set(xs, 'bcfile.Tp', 12)
%
%   See also xs_get, xs_show

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 24 Nov 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xs_set.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 17:30:24 +0200 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/xstruct_fun/xs_set.m $
% $Keywords: $

%% read request

if ~xs_check(xs); xs = xs_empty(); end;

% determin if units are provided
has_units = false;
idx = strcmpi('-units', varargin);
if any(idx)
    has_units = true;
    varargin = varargin(~idx);
end

if isempty(varargin)
    names = {};
    values = {};
elseif length(varargin) == 1
    names = varargin;
    values = {input([names{1} ': '])};
else
    l = length(varargin)-mod(length(varargin),2);
    names = varargin(1:2:l-1);
    values = varargin(2:2:l);
end

%% read variables

for i = 1:length(names)
    idx = strcmpi(names{i}, {xs.data.name});
    
    if ~any(idx)
        re = regexp(names{i},'^(?<sub>.+?)\.(?<field>.+)$','names');
        if ~isempty(re)
            % perform operation on substruct
            sub = xs_get(xs, re.sub);
            if xs_check(sub)
                xs = xs_set(xs, re.sub, xs_set(sub, re.field, values{i}));
                continue;
            end
        else
            % field doesn't exist, create it
            idx = length(xs.data)+1;
            xs.data(idx).name = names{i};
        end
    end
    
    if iscell(values{i}) && length(values{i}) == 2 && has_units
        val = values{i};
        if ischar(val{2}) || isempty(val{2})
            % fill field with units
            xs.data(idx).value = val{1};
            xs.data(idx).units = val{2};
        else
            % fill field without units
            xs.data(idx).value = values{i};
        end
    else
        % fill field without units
        xs.data(idx).value = values{i};
    end
end

% set meta data
xs = xs_meta(xs, mfilename);
