function xs = xs_empty()
%XS_EMPTY  Creates an empty XStruct
%
%   Creates an empty XStruct
%
%   Syntax:
%   xs = xs_empty()
%
%   Input:
%   none
%
%   Output:
%   xs  = XStruct array
%
%   Example
%   xs = xs_empty()
%
%   See also xs_check, xs_set, xs_get, xs_show

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

% $Id: xs_empty.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 17:30:24 +0200 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/xstruct_fun/xs_empty.m $
% $Keywords: $

%% create structure

xs = struct( ...
    'date', datestr(now), ...
    'function', mfilename, ...
    'type', '', ...
    'file', '', ...
    'data', struct( ...
        'name', {}, ...
        'value', {}, ...
        'units', {}, ...
        'dimensions', {} ...
    ) ...
);
