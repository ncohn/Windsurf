function [dims names type] = xb_dat_dims(filename, varargin)
%XB_DAT_DIMS  Returns the lengths of all dimensions of a XBeach DAT file
%
%   Returns an array with the lengths of all dimensions of a XBeach DAT
%   file. The functionality works similar to the Matlab size() function on
%   variables.
%
%   Syntax:
%   dims = xb_dat_dims(filename, varargin)
%
%   Input:
%   filename    = Filename of DAT file
%   varargin    = ftype:    datatype of DAT file (double/single)
%
%   Output:
%   dims        = Array with lengths of dimensions
%   names       = Cell array with names of dimensions (x/y/t/d/gd/theta)
%   type        = String identifying the type of DAT file
%                 (wave/sediment/graindist/bedlayers/point/drifter/2d)
%
%   Example
%   dims = xb_dat_dims(filename)
%
%   See also xb_dat_read, xb_dat_type, xb_read_dat

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
% Created: 06 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_dat_dims.m 5636 2011-12-23 09:27:25Z hoonhout $
% $Date: 2011-12-23 10:27:25 +0100 (vr, 23 dec 2011) $
% $Author: hoonhout $
% $Revision: 5636 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_dat/xb_dat_dims.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'ftype', 'double' ...
);

OPT = setproperty(OPT, varargin{:});

bytes = struct( ...
    'integer', 4, ...
    'single', 4, ...
    'double', 8 ...
);

%% read output info

xbout = xb_get_output;

%% read file and model info

if ~exist(filename, 'file')
    error(['File does not exist [' filename ']']);
end

[fdir fname fext] = fileparts(filename);

if isempty(fdir); fdir = '.'; end;

d = xb_read_dims(fdir);
f = dir(fullfile(filename, ''));

if ~isfield(d, 'globalx') || ~isfield(d, 'globaly') || ~isfield(d, 'globaltime')
    error('Primary dimensions x, y and/or t unknown');
end

% modify data type, if output info is available
guess = false;
if ~isempty(xbout)
    idx = strcmpi(fname, {xbout.name});
    if any(idx)
        ftype = xbout(idx).type;
        if ~isfield(bytes, ftype)
            switch ftype
                case 'real*8'
                    ftype = 'double';
            end
        end
        byt = bytes.(ftype);
    else
        guess = true;
    end
else
    guess = true;
end

if guess
    if any(strcmpi(fname, {'wetu', 'wetv', 'wetz'}))
        OPT.ftype = 'integer';
    end
    
    byt = bytes.(OPT.ftype);
end

%% determine dimensions

if regexp(fname, '^(point|rugau)\d+$')
    
    % point data
    nvars = floor(f.bytes/byt/d.pointtime)-1;
    dims = [d.pointtime nvars+1];
    names = {'pointtime' 'variables'};
    type = 'point';
    
elseif regexp(fname, '^(drifter)\d+$')
    
    % drifter data
    time = floor(f.bytes/byt/3);
    dims = [time 3];
    names = {'pointtime' 'variables'};
    type = 'drifter';
    
else

    % determine space dimensions
    nx = d.globalx;
    ny = d.globaly;

    % determine time dimension
    if regexp(fname, '_(mean|max|min|var)$')
        tname = 'meantime';
    else
        tname = 'globaltime';
    end
    
    nt = d.(tname);

    % set minimal dimensions
    dims = [nx ny nt];
    names = {'globalx' 'globaly' tname};
    type = '2d';

    if f.bytes < prod(dims)*byt
        % smaller than minimal, adjust time assuming file is incomplete
        warning('OET:xbeach:dimensions', ['File is smaller than minimum size, probably incomplete [' filename ']']);

        nt = floor(f.bytes/byt/nx/ny);
        dims = [nx ny nt];
    elseif f.bytes > prod(dims)*byt
        % larger than minimal dimensions, search alternatives
        
        ads = [d.wave_angle d.sediment_classes d.bed_layers d.sediment_classes*d.bed_layers];
        
        if ~isempty(xbout)
            % read variable names from xbeach source code
            cat = {};
            
            idx = find(([xbout.ndims] == 3));
            dim = reshape([xbout(idx).dims], 3, length(idx));
            cat{1} = {xbout(idx(strcmpi(dim(3,:), 'ntheta'))).name};
            cat{2} = {xbout(idx(strcmpi(dim(3,:), 'max(nd,2)'))).name};
            cat{3} = {xbout(idx(strcmpi(dim(3,:), 'ngd'))).name};
            
            idx = find(([xbout.ndims] == 4));
            dim = reshape([xbout(idx).dims], 4, length(idx));
            cat{4} = {xbout(idx(strcmpi(dim(3,:), 'max(nd,2)')&strcmpi(dim(4,:), 'ngd'))).name};
        else
            % user default variable names
            cat = { {'cgx' 'cgy' 'cx' 'cy' 'ctheta' 'ee' 'thet' 'costhet' 'sinthet' 'sigt' 'rr'} ...
                    {'dzbed'} ...
                    {'ccg' 'ccbg' 'Tsg' 'Susg' 'Svsg' 'Subg' 'Svbg' 'ceqbg' 'ceqsg' 'ero' 'depo_im' 'depo_ex'} ...
                    {'pbbed'} ...
            };
        end
    
        i = ismember(ads, f.bytes/byt/prod(dims));

        if sum(i) == 0
            % no match, use filename and adjust time
            for j = 1:length(cat)
                if any(strcmpi(fname, cat{j}))
                    i(:) = false;
                    i(j) = true;
                    break;
                end
            end
            
            if any(i)
                nt = floor(f.bytes/byt/nx/ny/ads(i));
            else
                nt = floor(f.bytes/byt/nx/ny);
            end
        end
        
        if sum(i) > 1
            % multiple matches, use filename
            for j = find(i)
                if j > length(cat); continue; end;
                if any(strcmpi(fname, cat{j}))
                    i(:) = false;
                    i(j) = true;
                    break;
                end
            end
        end
                
        if sum(i) == 1
            % single match, use it
            switch find(i)
                case 1
                    % waves
                    dims = [nx ny d.wave_angle nt];
                    names = {'globalx' 'globaly' 'wave_angle' tname};
                    type = 'wave';
                case 2
                    % sediments
                    dims = [nx ny d.sediment_classes nt];
                    names = {'globalx' 'globaly' 'sediment_classes' tname};
                    type = 'sediment';
                case 3
                    % grain distribution
                    dims = [nx ny d.bed_layers nt];
                    names = {'globalx' 'globaly' 'bed_layers' tname};
                    type = 'graindist';
                case 4
                    % bed layers
                    dims = [nx ny d.sediment_classes d.bed_layers nt];
                    names = {'globalx' 'globaly' 'sediment_classes' 'bed_layers' tname};
                    type = 'bedlayers';
                otherwise
                    % huh?!
                    dims = [];
            end
        else
            % no name match, no size match, assume it is a normal x,y,t dat
            % file that is too long
            dims = [nx ny nt];
            names = {'globalx' 'globaly' tname};
            type = '2d';
        end
    end
end

if isempty(dims)
    warning('OET:xbeach:dimensions', ['Dimensions could not be determined [' filename ']']);
    
    names = {};
    type = 'unknown';
end
