classdef TiffSeries < handle
    properties
        Basename;
        Path;

        Z;
        C;
        T;
        
        vGlobPattern;
        vFileList;
    end
    methods
        function obj = TiffSeries(filename)
            if(exist(filename, 'file'))
                [p f e v] = fileparts(filename); %#ok<NASGU>
                if(regexpi(e, '^\.tif{1,2}$'))
                    obj.Basename = [f e];
                    obj.Path = p;
                    
                    obj.vGlobPattern = fullfile(p, ...
                        regexprep([f e], '(z|c|t)\d+', '$1*', ...
                        'ignorecase') );
                else
                    me = MException('TiffSeries:InvalidFileFormat', ...
                                    'This class only accepts tiff files');
                    throw(me);
                end
            else
                me = MException('TiffSeries:FileNotFound', 'File not found: %s', filename);
                throw(me);
            end
        end
        
        function imagery = Fetch(obj, varargin)
            files = obj.MatchFileList(varargin{:});
            imagery = [];
            if(~isempty(files))
                slice_dim = size(imread(files{1}));
                n = numel(files);
                imagery = zeros(horzcat(slice_dim, n));
                for i = 1:size(imagery, 3)
                    imagery(:,:,i) = imread(files{i});
                end
            end
        end
        
        function LoadFileList(obj)
            filelist = ls(obj.vGlobPattern);
            obj.vFileList = regexp(filelist, '\s+', 'split');
            obj.Z = uint16(zeros(numel(filelist), 1));
            obj.C = uint16(zeros(numel(filelist), 1));
            obj.T = uint16(zeros(numel(filelist), 1));
            for i = 1:numel(obj.vFileList)
                [pz pc pt] = obj.makepattern(obj.vFileList{i});
                obj.Z(i) = sscanf(sscanf(obj.vFileList{i}, pz), '%u');
                obj.C(i) = sscanf(sscanf(obj.vFileList{i}, pz), '%u');
                obj.T(i) = sscanf(sscanf(obj.vFileList{i}, pz), '%u');
            end
        end
        
        function match = MatchFileList(obj, varargin)
            p = inputParser;
            p.addParamValue('Z', []);
            p.addParamValue('C', []);
            p.addParamValue('T', []);
            
            p.parse(varargin{:})
            

            tmp = obj.vFileList;
            for i = 1:numel(tmp)
                if
            end
            match = sort(tmp);
        end
    end
    
    
    function [pz pc pt] = makepatterns(filename)
        [p f e v] = fileparts(filename);
        pz = fullfile(p, ...
            regexprep([f e], '(z)\d+', '$1%[0123456789]+', 'ignorecase'));
        pc = fullfile(p, ...
            regexprep([f e], '(c)\d+', '$1%[0123456789]+', 'ignorecase'));
        pt = fullfile(p, ...
            regexprep([f e], '(t)\d+', '$1%[0123456789]+', 'ignorecase'));
    end
end

