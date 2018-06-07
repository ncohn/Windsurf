function [start len stride] = xb_index(dims, start, len, stride)
%XB_INDEX  Makes sure that start/len/stride are of equal and right len and contain no invalid values
%
%   Makes sure that start/len/stride are of equal and right len and
%   contain no negative or otherwise invalid values.
%
%   Syntax:
%   [start len stride] = xb_index(dims, start, len, stride)
%
%   Input:
%   dims      = Array with dimension sizes of original data (result of
%               size())
%   start     = Starting indices per dimension
%   len       = Length per dimension
%   stride    = Strides per dimension
%
%   Output:
%   start     = Starting indices per dimension
%   len    = len per dimension
%   stride    = Strides per dimension
%
%   Example
%   [start len stride] = xb_index(dims, start, len, stride)
%
%   See also xb_dat_read, xb_read_netcdf

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
% Created: 07 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_index.m 5902 2012-03-29 17:03:51Z hoonhout $
% $Date: 2012-03-29 19:03:51 +0200 (do, 29 mrt 2012) $
% $Author: hoonhout $
% $Revision: 5902 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_lib/xb_index.m $
% $Keywords: $

%% fix index

if isempty(start);  start   = zeros(size(dims));    end;
if isempty(len);    len     = -ones(size(dims));    end;
if isempty(stride); stride  = ones(size(dims));     end;

start (length(start) +1:length(dims))   = 0;
len   (length(len)   +1:length(dims))   = -1;
stride(length(stride)+1:length(dims))   = 1;

start = max(0,start);
start = min(dims-1,start);
stride = max(1,stride);
len(len<0) = dims(len<0);
len = min(1+floor((dims-start)./stride),len);
