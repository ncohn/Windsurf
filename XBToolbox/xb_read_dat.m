function xb = xb_read_dat(fname, varargin)
%XB_READ_DAT  Reads DAT formatted output files from XBeach
%
%   Reads DAT formatted output files from XBeach in the form of an XBeach
%   structure. Specific variables can be requested in the varargin by means
%   of an exact match, dos-like filtering or regular expressions (see
%   strfilter)
%
%   Syntax:
%   xb = xb_read_dat(fname, varargin)
%
%   Input:
%   fname       = directory name that contains the dat files.
%   varargin    = vars:     variable filters
%                 start:    Start positions for reading in each dimension,
%                           first item is zero
%                 length:   Number of data items to be read in each
%                           dimension, negative is unlimited
%                 stride:   Stride to be used in each dimension
%                 index:    Cell array with indices to read in each
%                           dimension (overwrites start/length/stride)
%                 dims:     Force the use of certain dimensions in
%                           xb_dat_read. These dimensions are used for all
%                           requested variables!
%
%   Output:
%   xb          = XBeach structure array
%
%   Example
%   xb = xb_read_dat('.')
%   xb = xb_read_dat('H.dat')
%   xb = xb_read_dat('path_to_model/')
%   xb = xb_read_dat('path_to_model/H.dat')
%   xb = xb_read_dat('.', 'vars', 'H')
%   xb = xb_read_dat('.', 'vars', 'H*')
%   xb = xb_read_dat('.', 'vars', '/_mean$')
%   xb = xb_read_dat('path_to_model/', 'vars', {'H', 'u*', '/_min$'})
%
%   See also xb_read_output, xb_read_netcdf, strfilter

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
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: xb_read_dat.m 7687 2012-11-14 15:16:12Z hoonhout $
% $Date: 2012-11-14 16:16:12 +0100 (Wed, 14 Nov 2012) $
% $Author: hoonhout $
% $Revision: 7687 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_read_dat.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'vars', {{}}, ...
    'start', [], ...
    'length', [], ...
    'stride', [], ...
    'index', [], ...
    'dims', [] ...
);

OPT = setproperty(OPT, varargin{:});

if ~iscell(OPT.vars); OPT.vars = {OPT.vars}; end;

%% read dat files

if ~exist(fname, 'file')
    error(['File does not exist [' fname ']'])
end

xb = xs_empty();

% get filelist
if length(fname) > 3 && strcmpi(fname(end-3:end), '.dat')
    names = dir(fname);
    fdir = fileparts(fname);
else
    names = dir([fname filesep '*.dat']);
    fdir = fname;
end

if isempty(fdir); fdir = fullfile('.', ''); end;

% allocate dims in xbeach struct
d = xs_empty();
d = xs_set(d, 'START', OPT.start, 'LENGTH', OPT.length, 'STRIDE', OPT.stride, 'INDEX', OPT.index);
d = xs_meta(d, mfilename, 'dimensions', fdir);
xb = xs_set(xb, 'DIMS', d);

% read dat files one-by-one
for i = 1:length(names)
    varname = names(i).name(1:length(names(i).name)-4);
    
    % skip, if not requested
    if ~isempty(OPT.vars) && ~any(strfilter(varname, OPT.vars)); continue; end;
    if any(strcmpi(varname, {'xy', 'dims'})); continue; end;
    
    filename = [varname '.dat'];
    fpath = fullfile(fdir, filename);
    
    % check if file is binary
    if isbinary(fpath, xb_getpref('binary_factor'))
        
        % determine dimensions
        if ~isempty(OPT.dims)
            dims     = OPT.dims;
            dimnames = {};
        else
            [dims dimnames] = xb_dat_dims(fpath);
        end

        % read dat file
        dat = xb_dat_read(fpath, dims, ...
            'start', OPT.start, 'length', OPT.length, 'stride', OPT.stride, 'index', OPT.index);

        xb = xs_set(xb, varname, dat);
        
        % add dimensions
        [nc_dims dims idx_dims] = xb_dims2nc(dims);
        if length(dimnames) == length(idx_dims)
            idx = strcmpi(varname, {xb.data.name});
            xb.data(idx).dimensions = dimnames(idx_dims);
        end
    end
end

% store dims in struct
dims = xb_read_dims(fdir);
f = fieldnames(dims);
for i = 1:length(f)
    d = xs_set(d, f{i}, dims.(f{i}));
end
xb = xs_set(xb, 'DIMS', d);

% set meta data
xb = xs_meta(xb, mfilename, 'output', fname);