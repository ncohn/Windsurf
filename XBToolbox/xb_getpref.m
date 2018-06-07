function varargout = xb_getpref(varargin)
%XB_GETPREF  Gets values for XBeach Toolbox preferences
%
%   Gets values for XBeach Toolbox preferences and initlises default
%   preferences if not done yet.
%
%   Syntax:
%   varargout = xb_getpref(varargin)
%
%   Input:
%   varargin  = list of preference names
%
%   Output:
%   varargout = list of corresponding preference values
%
%   Example
%   version = xb_getpref('version');
%   [user pass] = xb_getpref('ssh_user', 'ssh_pass');
%
%   See also xb_defpref, xb_setpref

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 05 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_getpref.m 3837 2011-01-10 09:29:20Z hoonhout $
% $Date: 2011-01-10 10:29:20 +0100 (ma, 10 jan 2011) $
% $Author: hoonhout $
% $Revision: 3837 $
% $HeadURL: https://repos.deltares.nl/repos/OpenEarthTools/trunk/matlab/applications/xbeach/xb_lib/xb_getpref.m $
% $Keywords: $

%% get xbeach preferences

if ~ispref('xbeach'); xb_defpref; end;

varargout = {};
for i = 1:length(varargin)
    if ispref('xbeach', varargin{i})
        varargout{i} = getpref('xbeach', varargin{i});
    else
        varargout{i} = [];
    end
end