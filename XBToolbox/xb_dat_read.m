function dat = xb_dat_read(fname, dims, varargin)
%XB_DAT_READ  Bytewise reading of XBeach DAT files using strides
%
%   Reading of XBeach DAT files. Two read methods are available: minimal
%   reads and minimal memory. The former minimizes the number of fread
%   calls, while the latter minimizes the amount of data read into memory.
%   In case the number of reads is for both methods equal, the memory
%   method is used. This method is also used if the average number of reads
%   per item is less than with the read method. The method used can also be
%   forced. The requested data can be determined using start and end
%   indices for each dimension and strides. This approach is similar to the
%   netCDF toolbox. The dimensions of the DAT file provided are in general
%   in the order x,y,t. The dimension order of the output is t,y,x to match
%   the netCDF conventions. The start and end indices and strides should be
%   provided in t,y,x order. The result is a matrix containing the
%   requested data.
%
%   Syntax:
%   dat = xb_dat_read(fname, dims, varargin)
%
%   Input:
%   fname       = Filename of DAT file
%   dims        = Array with lengths of all dimensions in DAT file
%   varargin    = start:    Start positions for reading in each dimension,
%                           first item is zero
%                 length:   Number of data items to be read in each
%                           dimension, negative is unlimited
%                 stride:   Stride to be used in each dimension
%                 index:    Cell array with indices to read in each
%                           dimension (overwrites start/length/stride)
%                 threshold:Fraction of items to read in order to switch to
%                           read method
%                 maxreads: Maximum reads in memory method
%                 force:    Force read method (read/memory)
%
%   Output:
%   dat         = Matrix with dimensions defined in dims containing
%                 requested data from DAT file
%
%   Preferences:
%   dat_method  = Force read method (read/memory)
%
%               Preferences overwrite default options (not explicitly
%               defined options) and can be set and retrieved using the
%               xb_setpref and xb_getpref functions.
%
%   Example
%   dat = xb_dat_read(fname, [100 3 20]);
%   dat = xb_dat_read(fname, [100 3 20], 'start', 10, 'length', 90, 'stride', 2);
%   dat = xb_dat_read(fname, [100 3 20], 'start', [10 1 1], 'length', [20 -1 -1], 'stride', [2 2 2]);
%
%   See also xb_read_dat, xb_read_output, xb_dat_dims, xb_dat_type

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

% $Id: xb_dat_read.m 5938 2012-04-06 12:16:15Z hoonhout $
% $Date: 2012-04-06 14:16:15 +0200 (vr, 06 apr 2012) $
% $Author: hoonhout $
% $Revision: 5938 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_dat/xb_dat_read.m $
% $Keywords: $

%% read options

if ndims(dims) < 2; error(['DAT file should be at least 2D [' num2str(ndims(dims)) ']']); end;

OPT = struct( ...
    'start', [], ...
    'length', [], ...
    'stride', [], ...
    'index', [], ...
    'threshold', .5, ...
    'maxreads', 100, ...
    'force', '' ...
);

OPT = setproperty(OPT, varargin{:});

%% check options

dat = [];

% convert dat dimensions to output dimensions
[dims_out dims] = xb_dims2nc(dims);

[OPT.start OPT.length OPT.stride] = xb_index(dims_out, OPT.start, OPT.length, OPT.stride);

% append index cell
if ~isempty(OPT.index)
    if ~iscell(OPT.index); OPT.index = {OPT.index}; end;
    for i = length(OPT.index)+1:length(dims_out)
        OPT.index{i} = [1:dims_out(i)]-1;
    end
    
    sz = [1 1];
    if ~any(diff(OPT.index{3})>1); sz(1) = length(OPT.index{3}); end;
    if ~any(diff(OPT.index{2})>1); sz(2) = length(OPT.index{2}); end;
else
    sz = [1 1];
    if OPT.stride(3) == 1; sz(1) = OPT.length(3); end;
    if OPT.stride(2) == 1; sz(2) = OPT.length(2); end;
end

dims_out(end+1:5) = 1;

%% determine read method

nitems = prod(OPT.length);
nreads = nitems/prod(sz);

if isempty(OPT.force)
    force = xb_getpref('dat_method');
    if isempty(force)
        if regexp(fname, '(point|rugau|drifter)\d+.dat$')
            method = 'read';
        elseif ~isempty(OPT.index)
            method = 'memory';
        elseif nitems/prod(dims) < OPT.threshold && nreads < OPT.maxreads
            method = 'memory';
        else
            method = 'read';
        end
    else
        method = force;
    end
else
    method = OPT.force;
end

%% read dat

fname = fullfile(fname, '');

if exist(fname, 'file')
    f = dir(fname);
    
    % determine filetype
    byt = round(f.bytes/prod(dims));

    if ~isnan(byt)
        switch byt
            case 1
                ftype = 'int';
            case 4
                ftype = 'single';
            case 8
                ftype = 'double';
            otherwise
                ftype = 'double';
                warning('OET:xbeach:dimensions', ['Your filesize is weird, I assume it contains doubles [' fname ']']);
        end

        fid = fopen(fname, 'r');

        switch method
            case 'read'
                % METHOD: minimal reads

                dat = nan(dims_out);

                % read entire file
                for i = 1:dims_out(1)
                    for j = 1:prod(dims_out(4:end))
                        dat(i,:,:,j) = fread(fid, dims(1:2), ftype)';
                    end
                end

                % dispose data out of range
                for i = 1:length(dims)
                    if isempty(OPT.index)
                        if OPT.start(i) > 0 || OPT.length(i) < dims_out(i) || OPT.stride(i) > 1
                            idx = num2cell(repmat(':',1,length(dims_out)));
                            idx{i} = 1+OPT.start(i)+[0:OPT.length(i)-1]*OPT.stride(i);
                            dat = dat(idx{:});
                        end
                    else
                        idx = num2cell(repmat(':',1,length(dims_out)));
                        idx{i} = max(min(OPT.index{i}+1, dims_out(i)),1);
                        dat = dat(idx{:});
                    end
                end
            case 'memory'
                % METHOD: minimal memory

                loops = num2cell(ones(1,5));
                
                if isempty(OPT.index)
                    dat = nan(OPT.length);

                    % build loop index
                    for i = 1:length(dims)
                        loops{i} = 1+OPT.start(i)+[0:OPT.length(i)-1]*OPT.stride(i);
                    end
                    
                    % determine dimensions to remove from loop and read at
                    % once (maximum x and y)
                    if sz(1) > 1; loops{3} = 1+OPT.start(3); end;
                    if sz(2) > 1; loops{2} = 1+OPT.start(2); end;
                else
                    dat = nan(cell2mat(cellfun(@length, OPT.index, 'UniformOutput', false)));
                    
                    % build loop index
                    for i = 1:length(OPT.index)
                        loops{i} = max(min(OPT.index{i}+1, dims_out(i)),1);
                    end
                    
                    if sz(1) > 1; loops{3} = 1+min(OPT.index{3}); end;
                    if sz(2) > 1; loops{2} = 1+min(OPT.index{2}); end;
                end

                % build output index
                idx = [{1} num2cell(repmat(':',1,2)) {1}];

                % loop through data arrays
                for i = 1:length(loops{1})
                    for j = 1:length(loops{5})
                        for k = 1:length(loops{4})

                            % select starting point of current data array
                            ii =    (loops{4}(k)-1);
                            ii = ii+(loops{5}(j)-1)*dims_out(4);
                            ii = ii+(loops{1}(i)-1)*prod(dims_out(4:5));
                            ii = ii*prod(dims(1:2));

                            idx{1} = i;
                            idx{5} = j;
                            idx{4} = k;

                            % loop through current data array
                            for n = 1:length(loops{3})
                                for m = 1:length(loops{2})

                                    if sz(1) == 1; idx{3} = n; end;
                                    if sz(2) == 1; idx{2} = m; end;

                                    iii = ii + (loops{2}(m)-1)*dims(1) + (loops{3}(n)-1);

                                    % set pointer to data point to be read and read
                                    fseek(fid, iii*byt, 'bof');
                                    dat(idx{:}) = fread(fid, sz, ftype)';
                                end
                            end
                        end
                    end
                end
            otherwise
                error(['Unknown read method [' method ']']);
        end
    
        fclose(fid);
    else
        dat = [];
    end
else
    error(['File not found [' fname ']']);
end
