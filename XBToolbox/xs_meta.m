function xs = xs_meta(xs, func, type, file)
%XS_META  Sets meta data of XStruct
%
%   Sets meta data of XStruct.
%
%   Syntax:
%   xs = xs_meta(xs, func, type)
%
%   Input:
%   xs          = XStruct array
%   func        = Name of function that sets the meta data (mfilename)
%   type        = Type of data in structure (params, waves, etc)
%   file        = File (string) or files (cell) containing filenames of 
%                 original data files
%
%   Output:
%   xs  = Updated XStruct array
%
%   Example
%   xs = xs_meta(xs, mfilename, 'waves', files)
%
%   See also xs_set, xs_show

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

% $Id: xs_meta.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 17:30:24 +0200 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/xstruct_fun/xs_meta.m $
% $Keywords: $

%% set meta data

if ~xs_check(xs); error('Invalid XStruct'); end;

xs.date = datestr(now);

if exist('func', 'var')
    xs.function = func;
end

if exist('type', 'var')
    xs.type = type;
end

if exist('file', 'var')
    if iscell(file)
        for i = 1:length(file)
            file{i} = abspath(file{i});
        end
        file = sprintf('%s\n', file{:});
        file = file(1:end-1);
    else
        file = abspath(file);
    end
    
    xs.file = file;
end