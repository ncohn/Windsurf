function binary = isbinary(filename, varargin)
%ISBINARY  Determines whether a file is a binary file or ASCII formatted
%
%   Determines whether a file is a binary file or ASCII formatted by
%   reading the first 32kB of the file (GNU grep standard) and looking for
%   characters with an ASCII number smaller than 32 and not 9, 10 or 13
%   (tab, newline, return)
%
%   Syntax:
%   binary = isbinary(filename, varargin)
%
%   Input:
%   filename  = Path to file to be checked
%   varargin  = none
%
%   Output:
%   binary    = Boolean that is true in case of a binary file and false
%               otherwise
%
%   Example
%   if isbinary('data.dat'); disp('This is a binary file!'); end;
%
%   See also is*

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
% Created: 01 Mar 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: isbinary.m 7407 2012-10-08 07:46:41Z hoonhout $
% $Date: 2012-10-08 09:46:41 +0200 (Mon, 08 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7407 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/isbinary.m $
% $Keywords: $

%% check input

if ~exist(filename, 'file')
    error(['File "' filename '" not found']);
end

%% read file

fid = fopen(filename, 'r');
data = fread(fid, 32*1024);
fclose(fid);

%% search for non-ascii characters

if isempty(varargin) || isempty(varargin{1}) || varargin{1}<0
    fraction = .5;
else
    fraction = varargin{1};
end

if ~any(data < 32 & ~ismember(data, [9 10 13])) && sum(data > 126 | data == 63)/length(data) < fraction
    binary = false;
else
    binary = true;
end