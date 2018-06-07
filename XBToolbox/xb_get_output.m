function output = xb_get_output(fpath)
%XB_GET_OUTPUT  Reads the spaceparams.tmpl file from the XBeach source code into a struct
%
%   Reads the spaceparans.tmpl file from the XBeach source code into a
%   struct. The file contains information on the possible output variables,
%   their dimensions, name and description.
%
%   Syntax:
%   output = xb_get_output(fpath)
%
%   Input:
%   fpath   = Path to spaceparams.tmpl
%
%   Output:
%   output  = Structure array containing data from spaceparams.tmpl
%
%   Example
%   output = xb_get_output
%   output = xb_get_output('spaceparams.tmpl')
%
%   See also xb_get_params

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
% Created: 28 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_get_output.m 3767 2010-12-29 16:21:12Z hoonhout $
% $Date: 2010-12-29 17:21:12 +0100 (wo, 29 dec 2010) $
% $Author: hoonhout $
% $Revision: 3767 $
% $HeadURL: https://repos.deltares.nl/repos/OpenEarthTools/trunk/matlab/applications/xbeach/xb_io/xb_get_output.m $
% $Keywords: $

%% search spaceparams.tmpl

if ~exist('fpath','var')
    fpath = abspath(fullfile(fileparts(which(mfilename)), '..', '..', '..', '..', 'fortran', 'XBeach', 'spaceparams.tmpl'));
else
    if ~exist(fpath, 'file')
        fpath = abspath(fullfile(fileparts(which(mfilename)), '..', '..', '..', '..', 'fortran', 'XBeach', 'spaceparams.tmpl'));
    end
end

%% read spaceparams.tmpl

output = struct( ...
    'type', {}, ...
    'name', {}, ...
    'ndims', {}, ...
    'dims', {}, ...
    'units', {}, ...
    'mpi', {}, ...
    'description', {} ...
);

if exist(fpath, 'file')
    i = 1;
    fid = fopen(fpath);

    % read file line by line
    while ~feof(fid)
        fline = fgetl(fid);

        % ignore comments
        if regexp(fline, '^\s*\!'); continue; end;

        % read name, type and number of dimensions
        re = '^\s*(?<type>.+?)\s+(?<ndims>\d+?)\s+(?<name>.+?)\s+(?<ext>.+?)\s*$';
        m1 = regexp(fline, re, 'names');

        % ignore line, if no match can be found
        if isempty(m1); disp(fline); continue; end;

        % read dimensions, mpi settings, units and description
        re = ['^\s*(?<dims>(.+?\s+){' m1.ndims '})(?<mpi>b|d)\s+\[(?<units>.+?)\]\s+(?<description>.+?)\s*$'];
        m2 = regexp(m1.ext, re, 'names');

        % ignore line, if no match can be found
        if isempty(m2); continue; end;

        % convert dimension string to cell array
        if isempty(m2.dims)
            output(i).dims = [];
        else
            dims = regexprep(m2.dims, '(s|par)%', '');
            output(i).dims = regexp(strtrim(dims), '\s+', 'split');
            idx = ~cellfun(@isempty, cellfun(@str2num, output(i).dims, 'UniformOutput', false));
            output(i).dims(idx) = num2cell(cellfun(@str2num, output(i).dims(idx)));
        end

        % store line in output structure
        output(i).type = m1.type;
        output(i).name = m1.name;
        output(i).ndims = str2num(m1.ndims);
        output(i).units = m2.units;
        output(i).mpi = m2.mpi;
        output(i).description = m2.description;

        i = i + 1;
    end
    
    fclose(fid);
end