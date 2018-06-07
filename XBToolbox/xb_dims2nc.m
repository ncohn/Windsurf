function [nc_dims dat_dims idx_dims] = xb_dims2nc(dat_dims)
%XB_DIMS2NC  Convert DAT formatted dimensions to NC formatted dimensions
%
%   Does some dimension flipping.
%
%   Syntax:
%   [nc_dims dat_dims idx_dims] = xb_dims2nc(dat_dims)
%
%   Input:
%   dat_dims  = dimensions in DAT file
%
%   Output:
%   nc_dims   = dimensions in NC file
%   dat_dims  = dimensions in DAT file, guaranteed to have 3 or more items
%   idx_dims  = index vectors to convert DAT dims to NC dims
%
%   Example
%   nc_dims = xb_dims2nc(dat_dims)
%
%   See also xb_read_dims

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 23 Dec 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_dims2nc.m 5639 2011-12-27 16:55:15Z hoonhout $
% $Date: 2011-12-27 17:55:15 +0100 (di, 27 dec 2011) $
% $Author: hoonhout $
% $Revision: 5639 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_lib/xb_dims2nc.m $
% $Keywords: $

%% convert dimensions

l = length(dat_dims);

switch l
    case 2
        dat_dims = [1 dat_dims([2 1])];
        idx_dims = [l+1 2 1];
    case 3
        idx_dims = [l 2 1];
    otherwise
        idx_dims = [l 2 1 3:l-1];
end

nc_dims  = dat_dims(idx_dims);