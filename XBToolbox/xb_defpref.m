function xb_defpref()
%XB_DEFPREF  Sets default preferences for XBeach Toolbox
%
%   Sets default preferences for XBeach Toolbox
%
%   Syntax:
%   xb_defpref()
%
%   Input:
%   none
%
%   Output:
%   none
%
%   Example
%   xb_defpref;
%
%   See also xb_setpref, xb_getpref

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

% $Id: xb_defpref.m 7408 2012-10-08 07:47:29Z hoonhout $
% $Date: 2012-10-08 09:47:29 +0200 (Mon, 08 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7408 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_lib/xb_defpref.m $
% $Keywords: $

%% general
setpref('xbeach', 'version', 1.0);          % toolbox version
setpref('xbeach', 'verbose', false);        % set verbose output of especially modelsetup functions

%% xb_io
setpref('xbeach', 'dat_method', '');        % determine method for partial reading of dat files (memory/read)
setpref('xbeach', 'binary_factor', '');     % fraction of obscure ascii characters in file to be interpreted as binary

%% xb_human
setpref('xbeach', 'interactive', true);     % enable interactive links in output

%% xb_modelsetup
setpref('xbeach', 'grid_finalise', {});     % default grid finalization options

%% xb_run
setpref('xbeach', 'ssh_user', '');          % default ssh user
setpref('xbeach', 'ssh_pass', '');          % default ssh password

setpref('xbeach', 'runs', []);              % system variable to store most recent runs
setpref('xbeach', 'queue', []);             % system variable to queue runs

setpref('xbeach', 'interval', []);          % default check interval for runs to finish